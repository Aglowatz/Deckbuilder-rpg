class_name CapitalBuilder
extends ZoneMap
## Turns the `CapitalLayout` into meshes and answers the `ZoneMap` queries (walkability, line of sight, anchors, chests, enemy
## homes, areas, the minimap's extent). The look depends on the story state: the broken services (the Beefcake blackout, the
## Gourmand shuttered stalls, the Necrocrat restless graves, the Refusemancer heaps), whether the gate is open, which rifts are
## sealed, and whether Primm has fallen (the facade crumbles, the citizens are free). See `docs/design/story_bible.md` Part 10.

const M = preload("res://world/capital/capital_materials.gd")
const P = preload("res://world/capital/capital_props.gd")
const B = preload("res://world/buffet/buffet_props.gd")
const DISTORTION: Shader = preload("res://world/capital/rift_distortion.gdshader")
## Everything south of this z is the underground hideout: it lives on visual layer 2 so the sun does not light it.
const CREASE_Z: float = 128.0
const CREASE_LAYER: int = 2

var layout: CapitalLayout = CapitalLayout.new()
var root: Node3D
var story: ZoneStoryText
var time: float = 0.0
## While false the gate barrier blocks the opening (set from the flag by the scene, flipped by `open_gate`).
var gate_open: bool = false
## The story state the look depends on (read from the Session when built).
var ctx: Dictionary = {}
var prop_nodes: Dictionary = {}
## The great wall's pieces and their boxes (`CapitalScene` hides a faded piece that blocks the lens, VD-22).
var great_wall: Array[Node3D] = []
var great_wall_boxes: Array[AABB] = []
var rift_nodes: Dictionary = {}

var _buckets: Dictionary = {}
var _spinners: Array[Node3D] = []
var _orbits: Array[Node3D] = []
var _rift_discs: Array[MeshInstance3D] = []
var _rift_cores: Array[Node3D] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _barrier: Node3D


func build(parent: Node3D) -> void:
	_rng.seed = 4242
	layout.build()
	story = ZoneStoryText.for_zone(CapitalZone.ID)
	ctx = story_context()
	gate_open = bool(Session.flags.get(str(CapitalZone.FLAG_GATE_OPEN), false)) or bool(ctx.get("final", false))
	root = Node3D.new()
	root.name = "Capital"
	parent.add_child(root)
	_build_ground()
	_build_buildings()
	_build_boundaries()
	_build_landmarks()
	_build_props()
	_build_signs()
	_build_rifts()
	_build_cracks()
	_build_chests()
	_finish_layers()
	_index_obstacles()
	# the repeated kit models (the identical row, the mausoleums, the Reek's yards, the ruins, the rifts' ground, the crystals) merge by material
	# and 16 m cell: a few dozen draw calls instead of hundreds (the iGPU is bound by draw calls); they cast no shadow, which the flat noon wants
	KitBatch.merge_static(root)


## The world state the look depends on, from the Session's flags.
static func story_context() -> Dictionary:
	var freed: Dictionary = {}
	for zone_id: String in ZoneDefs.ids():
		freed[zone_id] = ZoneCompletion.is_completed(Session.flags, zone_id)
	return {
		"free": freed,
		"dark": CapitalDebuffs.darkness(Session.flags),
		"final": bool(Session.flags.get(str(CapitalZone.FLAG_FREED), false)),
	}


func _is_free(zone_id: String) -> bool:
	return bool((ctx.get("free", {}) as Dictionary).get(zone_id, false)) or bool(ctx.get("final", false))


# ---- Queries (the ZoneMap interface) -----------------------------------------------------------------


func anchor(anchor_name: String) -> Vector3:
	return layout.anchors.get(anchor_name, Vector3.ZERO) as Vector3


func has_anchor(anchor_name: String) -> bool:
	return layout.anchors.has(anchor_name)


func chest_positions() -> Dictionary:
	return layout.chests


func enemy_spawns() -> Array[Dictionary]:
	return layout.enemy_spawns


func area_at(pos: Vector3) -> Array[String]:
	var area: CapitalLayout.Area = layout.area_at(pos.x, pos.z)
	if area == null:
		return [] as Array[String]
	return [area.id, area.title] as Array[String]


func is_floor_at(pos: Vector3) -> bool:
	var cell: Vector2i = layout.cell_of(pos.x, pos.z)
	return layout.cell_at(cell.x, cell.y) == CapitalLayout.Cell.GROUND


func map_bounds() -> Rect2:
	return Rect2(0.0, 0.0, float(CapitalLayout.W), float(CapitalLayout.H))


func add_blocker(pos: Vector3, radius: float) -> void:
	_add_obstacle(Vector3(pos.x, pos.z, radius))


func is_walkable(pos: Vector3, body_radius: float = StorybookScale.BODY_RADIUS) -> bool:
	for offset: Vector2 in [Vector2.ZERO, Vector2(body_radius, 0.0), Vector2(-body_radius, 0.0), Vector2(0.0, body_radius), Vector2(0.0, -body_radius)]:
		var cell: Vector2i = layout.cell_of(pos.x + offset.x, pos.z + offset.y)
		if layout.cell_at(cell.x, cell.y) != CapitalLayout.Cell.GROUND:
			return false
	if _hits_obstacle(pos, body_radius):
		return false
	if not gate_open and _hits_gate(pos, body_radius):
		return false
	return true


## Enemies also stay out of the rifts.
func is_enemy_walkable(pos: Vector3, body_radius: float = 0.25) -> bool:
	if not is_walkable(pos, body_radius):
		return false
	for entry: Dictionary in CapitalRifts.all():
		if CapitalRifts.is_sealed(Session.flags, str(entry["id"])):
			continue
		if Vector2(pos.x, pos.z).distance_to(Vector2(float(entry["x"]), float(entry["z"]))) <= float(entry["radius"]) + 0.9:
			return false
	return true


func has_line_of_sight(a: Vector3, b: Vector3) -> bool:
	var steps: int = maxi(1, int(a.distance_to(b) / 0.6))
	for index: int in range(steps + 1):
		var point: Vector3 = a.lerp(b, float(index) / float(steps))
		var cell: Vector2i = layout.cell_of(point.x, point.z)
		if layout.cell_at(cell.x, cell.y) != CapitalLayout.Cell.GROUND:
			return false
		if _hits_obstacle(point, 0.1):
			return false
	return true


## Lifts the gate barrier: the opening becomes walkable and the barrier slides up.
func open_gate() -> void:
	gate_open = true
	if _barrier != null:
		var tween: Tween = _barrier.create_tween()
		tween.tween_property(_barrier, "position:y", 4.5, 1.4)
		tween.tween_callback(func() -> void: _barrier.visible = false)


func _bucket_key(x: float, z: float) -> Vector2i:
	return Vector2i(int(floorf(x / 4.0)), int(floorf(z / 4.0)))


func _add_obstacle(obstacle: Vector3) -> void:
	var key: Vector2i = _bucket_key(obstacle.x, obstacle.y)
	var list: Array = _buckets.get(key, []) as Array
	list.append(obstacle)
	_buckets[key] = list


func _hits_obstacle(pos: Vector3, radius: float) -> bool:
	var key: Vector2i = _bucket_key(pos.x, pos.z)
	for dz: int in range(-1, 2):
		for dx: int in range(-1, 2):
			var list: Variant = _buckets.get(key + Vector2i(dx, dz))
			if list == null:
				continue
			for obstacle: Vector3 in (list as Array):
				var ox: float = pos.x - obstacle.x
				var oz: float = pos.z - obstacle.y
				var reach: float = obstacle.z + radius
				if ox * ox + oz * oz < reach * reach:
					return true
	return false


func _hits_gate(pos: Vector3, radius: float) -> bool:
	for blocker: Vector3 in layout.gate_blockers:
		var reach: float = blocker.z + radius
		if Vector2(pos.x - blocker.x, pos.z - blocker.y).length_squared() < reach * reach:
			return true
	return false


func _index_obstacles() -> void:
	for obstacle: Vector3 in layout.obstacles:
		_add_obstacle(obstacle)


# ---- Ground ---------------------------------------------------------------------------------------------


static func _noise(x: float, z: float) -> float:
	return fposmod(sin(x * 12.9898 + z * 78.233) * 43758.5453, 1.0)


func _district_free(cx: int, cz: int) -> bool:
	var area: CapitalLayout.Area = layout.area_at(float(cx) + 0.5, float(cz) + 0.5)
	if area == null:
		return false
	match area.id:
		"reek":
			return _is_free("refusemancer")
		"grave":
			return _is_free("necrocrat")
		"transit":
			return _is_free("beefcake")
		"hungry":
			return _is_free("gourmand")
	return bool(ctx.get("final", false))


func _floor_color(kind: CapitalLayout.Floor, cx: int, cz: int) -> Color:
	var n: float = 0.5 + 0.5 * sin(float(cx) * 0.21 + sin(float(cz) * 0.17) * 2.0) * sin(float(cz) * 0.19 + float(cx) * 0.05)
	var checker: bool = (cx + cz) % 2 == 0
	var inside: bool = cz < CapitalLayout.WALL_Z0
	var color: Color = M.ROAD
	if inside and kind != CapitalLayout.Floor.HUB:
		return _inside_color(kind, cx, cz, n, checker)
	match kind:
		CapitalLayout.Floor.GRAVEL:
			# barren, cracked wasteland: dry ash-tan ground with dark crack cells and the odd pale bone-dry patch
			color = Color(0.55, 0.5, 0.4).lerp(Color(0.38, 0.34, 0.3), n * 0.8)
			if (cx * 5 + cz * 3) % 13 == 0 or (cx * 3 - cz * 4 + 400) % 17 == 0:  # thin diagonal cracks
				color = color.darkened(0.16)
		CapitalLayout.Floor.ROAD:
			color = M.ROAD.lerp(Color(0.28, 0.28, 0.33), n * 0.6)
		CapitalLayout.Floor.PLAZA:
			color = M.PLAZA_STONE.lerp(Color(0.7, 0.68, 0.62), 0.25 if checker else 0.0)
		CapitalLayout.Floor.LAWN:
			var stripe: bool = (cx / 2) % 2 == 0
			color = M.LAWN_GREEN * (1.0 if stripe else 0.88)
		CapitalLayout.Floor.GRAY:
			color = Color(0.4, 0.4, 0.45).lerp(Color(0.3, 0.3, 0.34), n)
		CapitalLayout.Floor.SOIL:
			color = M.SOIL.lerp(Color(0.24, 0.2, 0.17), n)
		CapitalLayout.Floor.METAL:
			color = M.METAL.darkened(0.25).lerp(Color(0.32, 0.34, 0.4), 0.3 if checker else 0.0)
		CapitalLayout.Floor.TILE:
			color = M.TILE_A if checker else M.TILE_B
		CapitalLayout.Floor.HUB:
			color = M.HUB_WOOD.lerp(Color(0.3, 0.2, 0.14), 0.5 if cz % 2 == 0 else 0.0)
		CapitalLayout.Floor.GRASS:
			color = Color(0.3, 0.45, 0.25)
		CapitalLayout.Floor.DEAD:
			color = Color(0.35, 0.3, 0.25)
	if _district_free(cx, cz):
		# A freed district is warmer and livelier (greens in the Reek, bright tiles in the Hungry Quarter...).
		color = color.lerp(Color(0.85, 0.8, 0.6), 0.25)
		if kind == CapitalLayout.Floor.SOIL:
			color = color.lerp(Color(0.3, 0.55, 0.25), 0.35)
	return color


## Inside the walls everything is idyllic (Brief 13): lush striped lawns, clean cream streets, pastel paving. The districts keep a faint hint of their
## identity (a slightly different tone) so the map still reads, but nothing looks broken from the ground.
func _inside_color(kind: CapitalLayout.Floor, cx: int, cz: int, n: float, checker: bool) -> Color:
	var stripe: bool = (cx / 2) % 2 == 0
	match kind:
		CapitalLayout.Floor.ROAD:
			return Color(0.78, 0.72, 0.64).lerp(Color(0.7, 0.64, 0.58), 0.35 if checker else n * 0.1)
		CapitalLayout.Floor.PLAZA:
			return Color(0.84, 0.78, 0.7).lerp(Color(0.72, 0.66, 0.6), 0.5 if checker else 0.0)
		CapitalLayout.Floor.LAWN:
			return Color(0.3, 0.7, 0.32) * (1.0 if stripe else 0.88)
		CapitalLayout.Floor.SOIL:
			return Color(0.28, 0.64, 0.3) * (1.0 if stripe else 0.9)
		CapitalLayout.Floor.GRAY:
			return Color(0.84, 0.8, 0.78).lerp(Color(0.78, 0.74, 0.74), 0.5 if checker else 0.0)
		CapitalLayout.Floor.METAL:
			return Color(0.8, 0.84, 0.88).lerp(Color(0.72, 0.78, 0.84), 0.5 if checker else 0.0)
		CapitalLayout.Floor.TILE:
			return Color(0.98, 0.86, 0.9) if checker else Color(0.86, 0.94, 0.9)
	return Color(0.4, 0.8, 0.32)


func _build_ground() -> void:
	_build_ground_mesh(Rect2i(0, 0, CapitalLayout.W, int(CREASE_Z)), 1, "Ground")
	_build_ground_mesh(Rect2i(0, int(CREASE_Z), CapitalLayout.W, CapitalLayout.H - int(CREASE_Z)), CREASE_LAYER, "CreaseGround")
	# Beyond the map: dusty wasteland south of the wall, lush meadow north of it (so the void is never the sky and each side keeps its mood to the horizon).
	var wall: float = float(CapitalLayout.WALL_Z0)
	for half: Array in [["Wasteland", Color(0.6, 0.55, 0.44), wall, 340.0], ["Meadow", Color(0.3, 0.7, 0.28), wall - 340.0, 340.0]]:
		var plane: MeshInstance3D = MeshInstance3D.new()
		var mesh: PlaneMesh = PlaneMesh.new()
		mesh.size = Vector2(700.0, float(half[3]))
		plane.mesh = mesh
		plane.material_override = M.flat(half[1] as Color)
		plane.position = Vector3(60.0, -0.4, float(half[2]) + float(half[3]) * 0.5)
		plane.name = str(half[0])
		plane.set_meta(&"no_range_cull", true)
		plane.set_meta(&"no_occlusion_fade", true)
		root.add_child(plane)


func _build_ground_mesh(rect: Rect2i, layer: int, node_name: String) -> void:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(-1)
	for cz: int in range(rect.position.y, rect.end.y):
		for cx: int in range(rect.position.x, rect.end.x):
			if layout.cell_at(cx, cz) == CapitalLayout.Cell.VOID:
				continue
			var kind: CapitalLayout.Floor = layout.floor_at(cx, cz)
			var color: Color = _floor_color(kind, cx, cz)
			var x: float = float(cx)
			var z: float = float(cz)
			var p00: Vector3 = Vector3(x, 0.0, z)
			var p10: Vector3 = Vector3(x + 1.0, 0.0, z)
			var p01: Vector3 = Vector3(x, 0.0, z + 1.0)
			var p11: Vector3 = Vector3(x + 1.0, 0.0, z + 1.0)
			for tri: Array in [[p00, p10, p11], [p00, p11, p01]]:
				for point: Vector3 in tri:
					surface.set_color(color)
					surface.set_normal(Vector3.UP)
					surface.add_vertex(point)
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = surface.commit()
	instance.material_override = M.terrain()
	instance.name = node_name
	instance.layers = layer
	# one mesh for the whole floor: the zone's 48 m range cull measures to its centre, so it never culls or fades
	instance.set_meta(&"no_range_cull", true)
	instance.set_meta(&"no_occlusion_fade", true)
	root.add_child(instance)


# ---- Buildings --------------------------------------------------------------------------------------------


func _box(parent: Node3D, size: Vector3, material: Material, pos: Vector3, rot_deg: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	return B.box(parent, size, material, pos, rot_deg)


func _build_buildings() -> void:
	var houses: Array[CapitalLayout.Building] = []
	for building: CapitalLayout.Building in layout.buildings:
		if building.style == "house" and not bool(ctx.get("final", false)):
			houses.append(building)
			continue
		var node: Node3D = _building_node(building)
		if node != null:
			node.name = "Building_%s" % building.style
			root.add_child(node)
			if building.style in ["wall", "tower"] and building.district != "facade":
				great_wall.append(node)
				great_wall_boxes.append(AABB(Vector3(building.rect.position.x, 0.0, building.rect.position.y), Vector3(building.rect.size.x, building.height + 1.5, building.rect.size.y)).grow(0.6))
	_build_houses(houses)


## Flags the kit model's main mesh under `node` for `KitBatch.merge_static` (built once, never changed at run time).
static func _batchable(node: Node) -> void:
	for mesh: Node in node.find_children("Body", "MeshInstance3D", true, false):
		mesh.set_meta(&"kit_static", true)


func _building_node(building: CapitalLayout.Building) -> Node3D:
	var node: Node3D = Node3D.new()
	var rect: Rect2 = building.rect
	var center: Vector3 = Vector3(rect.position.x + rect.size.x * 0.5, 0.0, rect.position.y + rect.size.y * 0.5)
	node.position = center
	var w: float = rect.size.x
	var d: float = rect.size.y
	var h: float = building.height
	var free: bool = _district_free(int(center.x), int(center.z))
	var final_state: bool = bool(ctx.get("final", false))
	var state: String = "restored" if free else "broken"
	match building.style:
		"wall":
			if building.district == "facade":
				_wall(node, w, d, h, true)
			else:
				node.add_child(CapitalLandmarks.wall_piece(w, h, d, int(rect.position.x)))
		"tower":
			node.add_child(CapitalLandmarks.gate_tower(w, h, d))
		"castle":
			_box(node, Vector3(w, h, d), M.shiny(Color(0.52, 0.4, 0.46), 0.4), Vector3(0, h * 0.5, 0))
			_box(node, Vector3(w + 0.4, 0.5, d + 0.4), M.shiny(M.GOLD, 0.3), Vector3(0, h, 0))
		"ward":
			node.add_child(CapitalLandmarks.build({"id": "CAP-HERO-CORRECTION-WARD", "size": [w, h, d], "piece": _ward_piece(rect), "final": final_state}))
		"tram":
			_tram(node, w, d, h)
		"shed":
			node.add_child(CapitalLandmarks.build({"id": "CAP-HERO-TRAM-SHED", "size": [w, h, d], "state": state}))
		"shop":
			_shop(node, building)
		"stall":
			# the identical row faces its lane: the west row looks east, the east row west (the model's front is its local +z)
			var house: Node3D = CapitalLandmarks.build({"id": "CAP-HERO-IDENTICAL-ROW", "size": [d, h, w], "state": state})
			house.rotation_degrees.y = 90.0 if center.x < 100.0 else -90.0
			node.add_child(house)
		"factory":
			_factory(node, w, d, h, free or not bool(ctx.get("dark", false)))
		"crypt":
			node.add_child(CapitalLandmarks.build({"id": "CAP-HERO-GRAVE-ROW", "size": [w, h, d], "state": state}))
		"house":
			_ruined(node, w, d, h * 0.6, building.lean + 6.0, Color(0.9, 0.86, 0.84), true)
		_:
			if building.district == "refusemancer":
				# the Reek's back yards face the back lane (x 17..21)
				var yard: Node3D = CapitalLandmarks.build({"id": "CAP-HERO-THE-REEK", "size": [d, h, w], "state": state, "seed": int(rect.position.x * 7.0 + rect.position.y)})
				yard.rotation_degrees.y = 90.0 if center.x < 19.0 else -90.0
				node.add_child(yard)
			else:
				# the ruined outpost's fallen guardhouses, from the kit (pale crumbling brick, a slumped broken roof, the outpost sheet's doors and windows)
				node.add_child(CapitalLandmarks.ruined_house(w, h, d, building.lean, int(rect.position.x)))
	node.rotation_degrees.y = 0.0
	if building.style in ["stall", "crypt", "ruin"]:
		_batchable(node)
	if building.style in ["wall", "tower"]:
		# the great wall dominates every outside view: its long pieces never range-cull (they still fade when they hide the hero)
		CapitalLandmarks.mark_view(node, true)
	return node


## Which piece of the Correction Ward's compound a "ward" wall is (`CapitalDistricts.ward_piece`): the long north one is the Ward's front.
static func _ward_piece(rect: Rect2) -> String:
	if rect.size.x >= 20.0:
		return "north"
	if rect.size.x > rect.size.y:
		return "south_w" if rect.get_center().x < 101.0 else "south_e"
	return "side_w" if rect.get_center().x < 101.0 else "side_e"


## A crumbling building: leaning walls, a bite out of the top, dark windows, rubble. A freed district is upright and lit.
func _ruined(node: Node3D, w: float, d: float, h: float, lean: float, color: Color, repaired: bool) -> void:
	var body_color: Color = color if not repaired else color.lightened(0.18)
	var body: MeshInstance3D = _box(node, Vector3(w, h, d), M.flat(body_color), Vector3(0, h * 0.5, 0))
	if not repaired:
		body.rotation_degrees.z = lean * 0.6
		body.position.y = h * 0.5 - absf(lean) * 0.03
	var top_w: float = w * 0.55
	_box(node, Vector3(top_w, h * 0.35, d * 0.7), M.flat(body_color.darkened(0.18)), Vector3(-w * 0.18, h + (0.0 if repaired else -h * 0.08), 0.0), Vector3(0, 0, lean if not repaired else 0.0))
	if repaired:
		_box(node, Vector3(w + 0.5, 0.4, d + 0.5), M.flat(M.STONE_DARK), Vector3(0, h + h * 0.35, 0))
	var cols: int = maxi(1, int(w / 2.2))
	for index: int in range(cols):
		var wx: float = -w * 0.5 + (float(index) + 0.5) * w / float(cols)
		var lit: bool = repaired or (index + int(w)) % 4 == 0
		var window_material: StandardMaterial3D = M.glow(Color(1.0, 0.8, 0.45), 1.4) if repaired else (M.glow(Color(0.7, 0.35, 1.0), 1.2) if lit else M.flat(M.SOOT))
		_box(node, Vector3(0.7, 0.9, 0.06), window_material, Vector3(wx, h * 0.6, d * 0.5 + 0.02))
	if not repaired:
		for index: int in range(4):
			var size: Vector3 = Vector3(_rng.randf_range(0.4, 1.0), _rng.randf_range(0.3, 0.7), _rng.randf_range(0.4, 1.0))
			_box(node, size, M.flat(body_color.darkened(0.25)), Vector3(_rng.randf_range(-w * 0.6, w * 0.6), size.y * 0.5, d * 0.5 + _rng.randf_range(0.2, 1.0)), Vector3(0, _rng.randf_range(0, 90), _rng.randf_range(-12, 12)))


func _wall(node: Node3D, w: float, d: float, h: float, is_facade: bool) -> void:
	if is_facade:
		_box(node, Vector3(w, h, d), M.shiny(M.WHITE, 0.3), Vector3(0, h * 0.5, 0))
		_box(node, Vector3(w + 0.1, 0.18, d + 0.12), M.shiny(M.GOLD, 0.3), Vector3(0, h + 0.05, 0))
		return
	_box(node, Vector3(w, h, d), M.flat(Color(0.6, 0.55, 0.5)), Vector3(0, h * 0.5, 0))
	var along_x: bool = w >= d
	var length: float = w if along_x else d
	var count: int = int(length / 1.8)
	for index: int in range(count):
		var offset: float = -length * 0.5 + (float(index) + 0.5) * length / float(count)
		var merlon: Vector3 = Vector3(offset, h + 0.4, 0.0) if along_x else Vector3(0.0, h + 0.4, offset)
		_box(node, Vector3(1.0, 0.8, d + 0.2) if along_x else Vector3(w + 0.2, 0.8, 1.0), M.flat(Color(0.5, 0.46, 0.43)), merlon)


func _tower(node: Node3D, w: float, d: float, h: float) -> void:
	_box(node, Vector3(w, h, d), M.flat(Color(0.36, 0.35, 0.42)), Vector3(0, h * 0.5, 0))
	_box(node, Vector3(w + 0.8, 0.8, d + 0.8), M.flat(Color(0.3, 0.29, 0.36)), Vector3(0, h, 0))
	var roof: MeshInstance3D = B.mesh_at(node, P._prism(w + 1.2, 3.4, d + 1.2), M.shiny(M.GOLD, 0.35), Vector3(0, h + 2.5, 0))
	roof.name = "TowerRoof"
	_box(node, Vector3(0.9, 1.2, 0.1), M.glow(Color(1.0, 0.8, 0.45), 1.4), Vector3(0, h * 0.6, d * 0.5 + 0.02))


func _tram(node: Node3D, w: float, d: float, h: float) -> void:
	_box(node, Vector3(w, h, d), M.flat(Color(0.5, 0.28, 0.2)), Vector3(0, h * 0.5 + 0.3, 0))
	for index: int in range(5):
		_box(node, Vector3(1.4, 0.8, 0.06), M.glow(Color(0.5, 0.55, 0.6), 0.2), Vector3(-w * 0.4 + 2.0 * float(index), h * 0.7 + 0.3, d * 0.5 + 0.02))
	_box(node, Vector3(w, 0.2, d + 0.4), M.flat(M.STONE_DARK), Vector3(0, h + 0.4, 0))


func _shop(node: Node3D, building: CapitalLayout.Building) -> void:
	var w: float = building.rect.size.x
	var d: float = building.rect.size.y
	var h: float = building.height
	var final_state: bool = bool(ctx.get("final", false))
	_box(node, Vector3(w, h, 0.5 if not final_state else d), M.flat(M.WHITE if not final_state else Color(0.8, 0.76, 0.74)), Vector3(0, h * 0.5, -d * 0.5 + 0.25) if not final_state else Vector3(0, h * 0.5, 0))
	var awning_color: Color = [Color(0.9, 0.3, 0.35), Color(0.3, 0.55, 0.9)][building.variant % 2]
	_box(node, Vector3(w + 0.3, 0.25, 1.2), M.flat(awning_color), Vector3(0, h * 0.62, -d * 0.5 + 0.9), Vector3(14, 0, 0))
	_box(node, Vector3(1.4, 2.0, 0.06), M.flat(Color(0.3, 0.5, 0.65)), Vector3(0, 1.0, -d * 0.5 + 0.52))
	_box(node, Vector3(1.2, 0.9, 0.06), M.flat(Color(0.7, 0.9, 1.0)), Vector3(-1.2, 1.6, -d * 0.5 + 0.52))


func _build_houses(houses: Array[CapitalLayout.Building]) -> void:
	if houses.is_empty():
		return
	var bodies: MultiMesh = _multimesh(BoxMesh.new(), houses.size(), false)
	var roofs: MultiMesh = _multimesh(P._prism(1.0, 1.0, 1.0), houses.size(), false)
	var doors: MultiMesh = _multimesh(BoxMesh.new(), houses.size() * 3, false)
	for index: int in range(houses.size()):
		var house: CapitalLayout.Building = houses[index]
		var rect: Rect2 = house.rect
		var center: Vector3 = Vector3(rect.position.x + rect.size.x * 0.5, 0.0, rect.position.y + rect.size.y * 0.5)
		bodies.set_instance_transform(index, Transform3D(Basis.IDENTITY.scaled(Vector3(rect.size.x, house.height, rect.size.y)), center + Vector3(0, house.height * 0.5, 0)))
		roofs.set_instance_transform(index, Transform3D(Basis.IDENTITY.scaled(Vector3(rect.size.x + 0.7, 1.5, rect.size.y + 0.7)), center + Vector3(0, house.height + 0.75, 0)))
		doors.set_instance_transform(index * 3, Transform3D(Basis.IDENTITY.scaled(Vector3(0.8, 1.7, 0.1)), center + Vector3(0, 0.85, rect.size.y * 0.5 + 0.02)))
		doors.set_instance_transform(index * 3 + 1, Transform3D(Basis.IDENTITY.scaled(Vector3(0.7, 0.8, 0.1)), center + Vector3(-1.3, 1.9, rect.size.y * 0.5 + 0.02)))
		doors.set_instance_transform(index * 3 + 2, Transform3D(Basis.IDENTITY.scaled(Vector3(0.7, 0.8, 0.1)), center + Vector3(1.3, 1.9, rect.size.y * 0.5 + 0.02)))
	_add_multimesh(bodies, M.shiny(M.WHITE, 0.4), "HouseBodies")
	_add_multimesh(roofs, M.shiny(M.ROOF_RED, 0.4), "HouseRoofs")
	_add_multimesh(doors, M.glow(Color(1.0, 0.85, 0.5), 0.7), "HouseDoors")


func _stall(node: Node3D, w: float, d: float, h: float, open: bool) -> void:
	_box(node, Vector3(w, h, d), M.flat(Color(0.5, 0.42, 0.36) if not open else Color(0.78, 0.6, 0.4)), Vector3(0, h * 0.5, 0))
	var awning_colors: Array[Color] = [Color(0.9, 0.3, 0.3), Color(0.95, 0.85, 0.3), Color(0.3, 0.7, 0.4)]
	for index: int in range(5):
		var stripe: Color = awning_colors[index % 3] if open else Color(0.36, 0.34, 0.34)
		_box(node, Vector3(w / 5.0, 0.12, 1.4), M.flat(stripe), Vector3(-w * 0.4 + float(index) * w / 5.0, h + 0.1, d * 0.5 + 0.55), Vector3(18, 0, 0))
	if open:
		_box(node, Vector3(w * 0.8, 0.1, 0.8), M.flat(M.WOOD), Vector3(0, 1.0, d * 0.5 + 0.4))
		for index: int in range(4):
			B.ball(node, 0.18, M.flat([Color(0.9, 0.3, 0.2), Color(0.95, 0.8, 0.2), Color(0.4, 0.7, 0.3), Color(0.9, 0.5, 0.2)][index]), Vector3(-w * 0.3 + 0.55 * float(index), 1.25, d * 0.5 + 0.4))
		B.ball(node, 0.22, M.glow(M.LANTERN, 2.4), Vector3(-w * 0.45, h + 0.5, d * 0.5 + 0.5))
		B.ball(node, 0.22, M.glow(M.LANTERN, 2.4), Vector3(w * 0.45, h + 0.5, d * 0.5 + 0.5))
		B.steam(node, Vector3(0, h + 0.3, d * 0.2), 8, 0.2, 0.9)
	else:
		_box(node, Vector3(w * 0.9, h * 0.6, 0.1), M.flat(Color(0.2, 0.2, 0.22)), Vector3(0, h * 0.4, d * 0.5 + 0.06))
		_box(node, Vector3(w * 0.9, 0.12, 0.14), M.flat(M.WOOD_DARK), Vector3(0, h * 0.45, d * 0.5 + 0.14), Vector3(0, 0, 25))
		_box(node, Vector3(w * 0.9, 0.12, 0.14), M.flat(M.WOOD_DARK), Vector3(0, h * 0.45, d * 0.5 + 0.14), Vector3(0, 0, -25))


func _factory(node: Node3D, w: float, d: float, h: float, lit: bool) -> void:
	_box(node, Vector3(w, h, d), M.flat(Color(0.34, 0.37, 0.44)), Vector3(0, h * 0.5, 0))
	_box(node, Vector3(w + 0.3, 0.3, d + 0.3), M.flat(M.STONE_DARK), Vector3(0, h, 0))
	B.cylinder(node, 0.45, 0.55, h * 0.9, M.flat(Color(0.28, 0.28, 0.32)), Vector3(w * 0.3, h + h * 0.4, -d * 0.2), 10)
	_box(node, Vector3(w * 0.5, h * 0.55, 0.08), M.flat(Color(0.2, 0.22, 0.28)), Vector3(0, h * 0.28, d * 0.5 + 0.03))
	for index: int in range(3):
		_box(node, Vector3(w * 0.22, 0.2, 0.06), M.glow(Color(0.4, 0.8, 1.0), 2.0) if lit else M.flat(Color(0.18, 0.2, 0.24)), Vector3(-w * 0.3 + float(index) * w * 0.3, h * 0.82, d * 0.5 + 0.03))


func _crypt(node: Node3D, w: float, d: float, h: float, free: bool) -> void:
	_box(node, Vector3(w, h, d), M.flat(Color(0.5, 0.5, 0.54)), Vector3(0, h * 0.5, 0))
	B.mesh_at(node, P._prism(w + 0.6, 1.4, d + 0.6), M.flat(Color(0.42, 0.42, 0.46)), Vector3(0, h + 0.7, 0))
	_box(node, Vector3(1.2, 2.2, 0.1), M.flat(Color(0.1, 0.1, 0.12)), Vector3(0, 1.1, d * 0.5 + 0.03))
	var glow_color: Color = Color(1.0, 0.8, 0.4) if free else Color(0.5, 1.0, 0.7)
	B.ball(node, 0.2, M.glow(glow_color, 2.0), Vector3(w * 0.38, 1.8, d * 0.5 + 0.3))
	if not free:
		B.ball(node, 0.5, M.translucent(Color(0.5, 1.0, 0.7), 0.18, 0.8), Vector3(0, h + 1.2, 0))


func _multimesh(mesh: Mesh, count: int, use_colors: bool) -> MultiMesh:
	var multimesh: MultiMesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_colors = use_colors
	multimesh.mesh = mesh
	multimesh.instance_count = count
	return multimesh


func _add_multimesh(multimesh: MultiMesh, material: Material, node_name: String) -> void:
	var holder: MultiMeshInstance3D = MultiMeshInstance3D.new()
	holder.multimesh = multimesh
	holder.material_override = material
	holder.name = node_name
	root.add_child(holder)


# ---- Boundaries and the castle ---------------------------------------------------------------------------


## A broken wall of lumpy charcoal-violet boulders along a line (rotated, mixed sizes and tones) instead of one long black box: the south edge of the Outskirts no longer
## reads as a black band across the screen.
func _rock_wall(from: Vector3, to: Vector3) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = int(from.x * 31.0 + from.z * 17.0)
	var length: float = from.distance_to(to)
	var along: Vector3 = (to - from).normalized()
	var distance: float = 0.0
	while distance < length:
		var size: Vector3 = Vector3(rng.randf_range(1.6, 3.4), rng.randf_range(0.4, 1.0), rng.randf_range(1.4, 2.6))
		var tone: float = rng.randf_range(0.2, 0.34)
		var color: Color = Color(tone, tone * 0.95, tone * 1.2)
		var pos: Vector3 = from + along * distance + Vector3(0.0, size.y * 0.5 - 0.2, rng.randf_range(-0.5, 0.5))
		_box(root, size, M.flat(color), pos, Vector3(rng.randf_range(-6.0, 6.0), rng.randf_range(-35.0, 35.0), rng.randf_range(-8.0, 8.0)))
		distance += size.x * 0.8


func _build_boundaries() -> void:
	var top: float = float(CapitalLayout.WALL_Z0)
	# The city's outer walls: north either side of the castle hill, west and east down to the great wall; the same flawless white kit wall as the
	# great wall (CAP-HERO-GREAT-WALL-GATE), one wall round the whole city.
	var hill: Rect2i = CapitalLayout.HILL
	for span: Vector2 in [Vector2(0.0, float(hill.position.x)), Vector2(float(hill.end.x), 120.0)]:
		var north: Node3D = Node3D.new()
		north.name = "CityWallNorth"
		root.add_child(north)
		north.position = Vector3((span.x + span.y) * 0.5, 0.0, 0.5)
		var piece: Node3D = CapitalLandmarks.wall_piece(span.y - span.x, 9.0, 3.0, int(span.x) + 1)
		piece.rotation_degrees.y = 180.0
		north.add_child(piece)
		CapitalLandmarks.mark_view(north, true)
	for side_x: float in [0.0, 119.0]:
		var side: Node3D = Node3D.new()
		side.name = "CityWallSide"
		root.add_child(side)
		side.position = Vector3(side_x, 0.0, top * 0.5)
		var side_piece: Node3D = CapitalLandmarks.wall_piece(2.5, 9.0, top, int(side_x) + 3)
		side_piece.rotation_degrees.y = 180.0 if side_x < 60.0 else 0.0  # the cracks start on the outer face, never inside the city
		side.add_child(side_piece)
		CapitalLandmarks.mark_view(side, true)
	# The outside's edge: broken fence and low black rock.
	var out_top: float = float(CapitalLayout.WALL_Z1 + 1)
	var out_depth: float = float(CapitalLayout.OUT_Z1) + 1.0 - out_top
	for side_x: float in [0.5, 119.5]:
		_box(root, Vector3(2.5, 3.0, out_depth), M.flat(Color(0.18, 0.17, 0.2)), Vector3(side_x, 1.5, out_top + out_depth * 0.5))
	_rock_wall(Vector3(0.0, 0.0, float(CapitalLayout.OUT_Z1) + 1.8), Vector3(56.0, 0.0, float(CapitalLayout.OUT_Z1) + 1.8))
	_rock_wall(Vector3(64.0, 0.0, float(CapitalLayout.OUT_Z1) + 1.8), Vector3(120.0, 0.0, float(CapitalLayout.OUT_Z1) + 1.8))
	# The Crease's walls (inside layer 2).
	var dz: float = float(CapitalLayout.CREASE_Z0 - 100)
	for rect: Rect2 in [Rect2(3.0, 99.0 + dz, 39.0, 1.0), Rect2(3.0, 121.0 + dz, 39.0, 1.0), Rect2(3.0, 99.0 + dz, 1.0, 23.0), Rect2(41.0, 99.0 + dz, 1.0, 23.0)]:
		var wall: Vector3 = Vector3(rect.position.x + rect.size.x * 0.5, 2.6, rect.position.y + rect.size.y * 0.5)
		_box(root, Vector3(rect.size.x, 5.2, rect.size.y), M.flat(M.BRICK_DEAD.darkened(0.3)), wall)


## The hero landmarks (`CapitalLandmarks`, modelled after the kit's concepts): Primm's Castle on its hill at the city's heart, the great gate's
## crown between its towers, the broken watchtower, the resistance camp, the Old Service Tunnels' mouth in the wall. Each is one node off the root.
var landmarks: Dictionary = {}
## The castle's rift-light cracks (pulsed slowly in `animate`; null once Primm has fallen).
var _castle_cracks: StandardMaterial3D
var _rift_lights: Array[OmniLight3D] = []


func _build_landmarks() -> void:
	var final_state: bool = bool(ctx.get("final", false))
	var castle: Node3D = CapitalLandmarks.build({"id": "CAP-HERO-PRIMMS-CASTLE", "final": final_state})
	_place_landmark("castle", castle, Vector3.ZERO)
	_castle_cracks = castle.get_meta("cracks") as StandardMaterial3D if castle.has_meta("cracks") else null
	_place_landmark("watchtower", CapitalLandmarks.build({"id": "CAP-HERO-WATCHTOWER"}), Vector3(CapitalLayout.WATCHTOWER.x, 0.0, CapitalLayout.WATCHTOWER.y))
	CapitalLandmarks.mark_view(landmarks["watchtower"] as Node3D, true)
	_place_landmark("camp", CapitalLandmarks.build({"id": "CAP-HERO-RESISTANCE-CAMP"}), Vector3.ZERO)
	# one low mesh round the hero's standing ground: its box crosses the lens line, so the fader would ghost the whole camp (the tents stay low)
	CapitalLandmarks.mark_view(landmarks["camp"] as Node3D)
	_place_landmark("tunnel_mouth", CapitalLandmarks.build({"id": "CAP-HERO-SERVICE-TUNNEL"}), Vector3(CapitalLayout.TUNNEL_MOUTH.x, 0.0, CapitalLayout.TUNNEL_MOUTH.y))
	CapitalLandmarks.mark_view(landmarks["tunnel_mouth"] as Node3D, true)
	# the gate's crown over the opening, between the towers: part of the great wall (it fades, and hides round the lens, like the wall)
	var gate_x: float = float(CapitalLayout.GATE_X0 + CapitalLayout.GATE_X1 + 1) * 0.5
	var gate_z: float = float(CapitalLayout.WALL_Z0 + CapitalLayout.WALL_Z1 + 1) * 0.5
	var arch: Node3D = CapitalLandmarks.build({"id": "CAP-HERO-GREAT-WALL-GATE", "final": final_state})
	_place_landmark("gate", arch, Vector3(gate_x, 0.0, gate_z))
	CapitalLandmarks.mark_view(arch, true)
	great_wall.append(arch)
	great_wall_boxes.append(AABB(Vector3(gate_x - 5.2, 8.8, gate_z - 2.4), Vector3(10.4, 6.4, 4.8)).grow(0.6))


## The castle's own distance haze for the half the hero stands in (data/zone_styles/capital_outside.json / capital_inside.json "far_haze", CAP-22): a
## lighter haze than the mood's fog, so the castle reads over the great wall from every outside region and the same from both halves.
func set_castle_haze(inside: bool) -> void:
	var castle: Node3D = landmarks.get("castle") as Node3D
	if castle == null:
		return
	var haze: Dictionary = ZoneStyles.style("capital_inside" if inside else "capital_outside").get("far_haze", {}) as Dictionary
	var value: Color = Color.html(str(haze.get("color", "#a8a0b4")))
	value.a = float(haze.get("density", 0.002))
	for mesh: Node in castle.find_children("*", "GeometryInstance3D", true, false):
		(mesh as GeometryInstance3D).set_instance_shader_parameter("far_haze", value)


func _place_landmark(id: String, node: Node3D, pos: Vector3) -> void:
	root.add_child(node)
	node.position = pos
	landmarks[id] = node


# ---- Props, signs, rifts ----------------------------------------------------------------------------------


func _prop_key(kind: String, pos: Vector3) -> String:
	return "%s@%d,%d" % [kind, int(roundf(pos.x * 10.0)), int(roundf(pos.z * 10.0))]


func _build_props() -> void:
	for prop: CapitalLayout.Prop in layout.props:
		var node: Node3D = P.build(prop, ctx, story)
		if node == null:
			continue
		root.add_child(node)
		node.position = prop.pos
		node.rotation_degrees.y = prop.yaw if prop.kind != "rift_crystals" else 0.0  # painted crystal cards face the camera side
		if not prop.kind in ["statue_primm", "fountain"] and prop.model_scale != 1.0:
			node.scale = Vector3.ONE * prop.model_scale
		prop_nodes[_prop_key(prop.kind, prop.pos)] = node
		if prop.kind == "gate_barrier":
			_barrier = node
			node.visible = not gate_open
		if prop.kind == "energy_wheel":
			var spin: Node3D = node.get_node_or_null("Spin") as Node3D
			if spin != null:
				_spinners.append(spin)
	_apply_initial_states()


## Props whose look follows a saved flag: picked-up pickups vanish, a planted patch blooms, the cut cable sparks...
func _apply_initial_states() -> void:
	for prop: CapitalLayout.Prop in layout.props:
		var node: Node3D = prop_nodes.get(_prop_key(prop.kind, prop.pos)) as Node3D
		if node == null:
			continue
		match prop.kind:
			"sick_patch":
				set_prop_state("sick_patch", prop.pos, bool(Session.flags.get(str(CapitalZone.FLAG_SEED_PLANTED), false)))
			"power_cable":
				set_prop_state("power_cable", prop.pos, bool(Session.flags.get(str(CapitalZone.FLAG_CABLE_CUT), false)))
			"paste_dispenser":
				set_prop_state("paste_dispenser", prop.pos, bool(Session.flags.get(str(CapitalZone.FLAG_PASTE_SPOILED), false)))
			"family_plot":
				set_prop_state("family_plot", prop.pos, bool(Session.flags.get(str(CapitalZone.FLAG_LAID_TO_REST), false)))
			"tunnel_hatch_cover":
				set_prop_state("tunnel_hatch_cover", prop.pos, Session.found_secret(CapitalZone.SECRET_TUNNEL))
			"compost_heap", "recipe_card", "seed_jar":
				node.visible = not _pickup_taken_at(prop)
			"portrait":
				set_prop_state("portrait", prop.pos, Session.found_secret(CapitalZone.secret_id("deface", _anchor_name_at(prop.pos))))


func _anchor_name_at(pos: Vector3) -> String:
	for key: Variant in layout.anchors.keys():
		var anchor_pos: Vector3 = layout.anchors[key] as Vector3
		if absf(anchor_pos.x - pos.x) < 0.01 and absf(anchor_pos.z - pos.z) < 0.01:
			return str(key)
	return ""


func _pickup_taken_at(prop: CapitalLayout.Prop) -> bool:
	var anchor_name: String = _anchor_name_at(prop.pos)
	return not anchor_name.is_empty() and Session.found_secret(CapitalZone.secret_id("pick", anchor_name))


## Flips a prop between its `Off` and `On` groups (or shows its `Defaced` group).
func set_prop_state(kind: String, pos: Vector3, on: bool) -> void:
	var node: Node3D = prop_nodes.get(_prop_key(kind, pos)) as Node3D
	if node == null:
		return
	var off: Node3D = node.get_node_or_null("Off") as Node3D
	var on_group: Node3D = node.get_node_or_null("On") as Node3D
	var defaced: Node3D = node.get_node_or_null("Defaced") as Node3D
	if off != null:
		off.visible = not on
	if on_group != null:
		on_group.visible = on
	if defaced != null:
		defaced.visible = on


func prop_at_anchor(kind: String, anchor_name: String) -> Node3D:
	return prop_nodes.get(_prop_key(kind, anchor(anchor_name))) as Node3D


func _build_signs() -> void:
	# G-03: no readable text in the world. Primm's banners carry the ruler's emblem, boards and wall plaques one pictogram; the words are read by using
	# the sign (ZoneScene adds a "sign" spot).
	for sign_data: CapitalLayout.Sign in layout.signs:
		var width: float = 1.5 * sign_data.size
		var height: float = 1.5 * sign_data.size
		var node: Node3D = Node3D.new()
		root.add_child(node)
		node.position = sign_data.pos
		node.rotation_degrees.y = sign_data.yaw + 180.0
		var mid: float = 1.45 + height * 0.5
		match sign_data.style:
			"banner":
				mid = 2.6 + height * 0.5
				for side: float in [-1.0, 1.0]:
					B.cylinder(node, 0.07, 0.09, 2.6 + height, M.flat(M.STONE_DARK), Vector3(side * (width * 0.5 + 0.1), (2.6 + height) * 0.5, 0), 6)
				B.box(node, Vector3(width + 0.5, 0.12, 0.14), M.shiny(M.GOLD, 0.3), Vector3(0, 2.6 + height, 0))
				B.box(node, Vector3(width, height, 0.06), M.flat(Color(0.88, 0.8, 0.62)), Vector3(0, mid, 0))
			"wall":
				mid = 1.8 + height * 0.5
				B.box(node, Vector3(width, height, 0.05), M.flat(Color(0.9, 0.88, 0.8)), Vector3(0, mid, 0))
			_:
				var board: Node3D = B.sign_post(width, height, "sign")
				board.set_meta(PaintedClasses.META_NO_PAINT, true)  # signs stay plain so the pictogram reads
				node.add_child(board)
		node.scale = Vector3.ONE * 0.5  # smaller than the old high camera needed: at the low camera a signboard covers the hero
		node.add_child(IconSign.picture(Vector2(width, height) * 0.8, sign_icon(sign_data.key), Vector3(0, mid, 0.1)))


## The icon id a sign shows. Primm's official banners show the ruler's emblem (the same one as the zone rulers' banners); the Wrinkles' own signs do not.
const SIGN_ICONS: Dictionary = {
	"sign.gate_main": RulerPresence.EMBLEM_ICON, "sign.gate_requirements": "ICON-RES-REDTAPE", "sign.gate_exit": "ICON-MAP-EXIT",
	"sign.gate_height": "ICON-STAT-DEFENSE", "sign.gate_inside": RulerPresence.EMBLEM_ICON, "sign.gate_exit_inside": "ICON-MAP-EXIT",
	"sign.facade_welcome": RulerPresence.EMBLEM_ICON, "sign.facade_hats": "ICON-UI-WARDROBE", "sign.facade_spontaneity": "ICON-RES-REDTAPE",
	"sign.facade_smile": "ICON-UI-CHARACTER", "sign.facade_lawns": "ICON-RES-REDTAPE", "sign.facade_hedges": "ICON-RES-REDTAPE",
	"sign.facade_queue": "ICON-RES-REDTAPE", "sign.facade_loudspeaker": "ICON-NODE-EVENT", "sign.facade_shop_1": "ICON-RES-INGREDIENT",
	"sign.facade_shop_2": "ICON-UI-COLLECTION", "sign.facade_back": "ICON-NODE-LOCKED",
	"sign.reek_main": RulerPresence.EMBLEM_ICON, "sign.reek_untidy": "ICON-RES-GARBAGE", "sign.reek_compost_ban": "ICON-NODE-LOCKED",
	"sign.reek_behind_facade": "ICON-RES-GARBAGE", "sign.reek_sick_patch": "ICON-NODE-ELITE", "sign.net_reek": "ICON-MAP-TRAVEL",
	"sign.grave_main": RulerPresence.EMBLEM_ICON, "sign.grave_permit": "ICON-RES-REDTAPE", "sign.grave_queue": "ICON-RES-REDTAPE",
	"sign.grave_waiting": "ICON-ESSENCE-N", "sign.grave_plot": "ICON-NODE-LOCKED", "sign.net_grave": "ICON-MAP-TRAVEL",
	"sign.transit_main": RulerPresence.EMBLEM_ICON, "sign.transit_cardio": "ICON-ENERGY-B", "sign.transit_lines": "ICON-NODE-LOCKED",
	"sign.transit_lights": "ICON-ENERGY-GENERIC", "sign.transit_cable": "ICON-NODE-ELITE", "sign.net_transit": "ICON-MAP-TRAVEL",
	"sign.hungry_main": RulerPresence.EMBLEM_ICON, "sign.hungry_paste": "ICON-MECH-PLATE", "sign.hungry_closed": "ICON-NODE-LOCKED",
	"sign.hungry_nutrition": "ICON-RES-REDTAPE", "sign.hungry_menu": "ICON-MECH-PLATE", "sign.net_hungry": "ICON-MAP-TRAVEL",
	"sign.castle_main": RulerPresence.EMBLEM_ICON, "sign.castle_avenue": "ICON-MECH-PEEK", "sign.castle_warning": "ICON-NODE-ELITE",
	"sign.net_approach": "ICON-MAP-TRAVEL",
	"sign.yard_main": RulerPresence.EMBLEM_ICON, "sign.yard_abandoned": "ICON-NODE-DONE", "sign.yard_form": "ICON-RES-REDTAPE",
	"sign.ward_main": RulerPresence.EMBLEM_ICON, "sign.ward_permit": "ICON-RES-REDTAPE", "sign.ward_rules": "ICON-RES-REDTAPE",
	"sign.out_welcome": RulerPresence.EMBLEM_ICON, "sign.out_queue": "ICON-RES-REDTAPE", "sign.out_abandoned_a": "ICON-NODE-DONE",
	"sign.out_abandoned_b": "ICON-NODE-DONE", "sign.out_rift": "ICON-NODE-ELITE", "sign.out_exit_rules": "ICON-MAP-EXIT",
	"sign.out_tunnel_clue": "ICON-MAP-QUEST", "sign.out_old_works": "ICON-NODE-LOCKED",
	"sign.plaza_main": RulerPresence.EMBLEM_ICON, "sign.plaza_exit_interview": "ICON-MAP-EXIT", "sign.plaza_complaints": "ICON-TOKEN-CONTRACT",
	"sign.plaza_manhole": "ICON-MAP-QUEST", "sign.net_plaza": "ICON-MAP-TRAVEL",
	"sign.crease_main": "ICON-UI-QUESTS", "sign.crease_wrinkle": "ICON-UI-CHARACTER", "sign.crease_network": "ICON-UI-MAP",
	"sign.crease_rules": "ICON-TOKEN-CONTRACT",
}


static func sign_icon(key: String) -> String:
	return IconSign.icon_for(key, SIGN_ICONS)


func _rift_material(color: Color, alpha: float, energy: float) -> StandardMaterial3D:
	return M.translucent(color, alpha, energy)


func _build_rifts() -> void:
	for entry: Dictionary in CapitalRifts.all():
		var rift_id: String = str(entry["id"])
		if CapitalRifts.is_sealed(Session.flags, rift_id):
			continue
		var node: Node3D = _make_rift(entry)
		root.add_child(node)
		node.position = Vector3(float(entry["x"]), 0.0, float(entry["z"]))
		rift_nodes[rift_id] = node


func _make_rift(entry: Dictionary) -> Node3D:
	var radius: float = float(entry["radius"])
	var big: bool = bool(entry["big"])
	var rift_id: String = str(entry["id"])
	# The kit's rift (CAP-HERO-RIFT): the scorched ground, the glowing rim at the hazard's reach, the jagged tear and its floating shards, each
	# copy varied by its id.
	var node: Node3D = CapitalLandmarks.build({"id": "CAP-HERO-RIFT", "seed": rift_id.hash() % 1000, "radius": radius, "big": big})
	node.name = "Rift_%s" % rift_id
	var rim: MeshInstance3D = node.get_node_or_null("Rim") as MeshInstance3D
	if rim != null:
		_rift_discs.append(rim)
	var tear: Node3D = node.get_node_or_null("Tear") as Node3D
	if tear != null:
		_rift_cores.append(tear)
	var orbit: Node3D = node.get_node_or_null("Orbit") as Node3D
	if orbit != null:
		_orbits.append(orbit)
	var scale_factor: float = float(node.get_meta("size", 1.0))
	# Warped light: a lens of rippling screen around the tear.
	var lens: MeshInstance3D = MeshInstance3D.new()
	var lens_mesh: SphereMesh = SphereMesh.new()
	lens_mesh.radius = 1.3 * scale_factor
	lens_mesh.height = 3.6 * scale_factor
	lens_mesh.radial_segments = 24
	lens_mesh.rings = 12
	lens.mesh = lens_mesh
	var lens_material: ShaderMaterial = ShaderMaterial.new()
	lens_material.shader = DISTORTION
	lens_material.render_priority = 5
	lens.material_override = lens_material
	lens.position = Vector3(0, 0.35 * scale_factor + 1.6 * scale_factor, 0)
	lens.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	lens.name = "Lens"
	node.add_child(lens)
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = M.RIFT_VIOLET
	light.light_energy = 2.8
	light.omni_range = radius * 1.4 + 2.5  # round the tear and its scorched ground (a wider reach cost 2-3 ms on Medium where several rifts share a view)
	light.position = Vector3(0, 1.8 * scale_factor, 0)
	node.add_child(light)
	_rift_lights.append(light)
	var sparks: CPUParticles3D = CPUParticles3D.new()
	sparks.amount = 20
	sparks.lifetime = 2.0
	sparks.preprocess = 2.0
	sparks.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	sparks.emission_sphere_radius = radius * 0.6
	sparks.direction = Vector3.UP
	sparks.spread = 25.0
	sparks.initial_velocity_min = 0.6
	sparks.initial_velocity_max = 1.4
	sparks.gravity = Vector3.ZERO
	var spark_mesh: SphereMesh = SphereMesh.new()
	spark_mesh.radius = 0.05
	spark_mesh.height = 0.1
	spark_mesh.radial_segments = 4
	spark_mesh.rings = 2
	sparks.mesh = spark_mesh
	sparks.material_override = M.glow(M.RIFT_CYAN, 3.0)
	node.add_child(sparks)
	return node


## Closes a rift: it collapses and is gone (the scene awards the reward and sets the flag).
func close_rift(rift_id: String) -> void:
	var node: Node3D = rift_nodes.get(rift_id) as Node3D
	if node == null:
		return
	rift_nodes.erase(rift_id)
	var tween: Tween = node.create_tween()
	tween.set_parallel(true)
	tween.tween_property(node, "scale", Vector3(0.05, 0.05, 0.05), 0.9).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(node.queue_free)


func _build_cracks() -> void:
	if layout.cracks.is_empty():
		return
	var multimesh: MultiMesh = _multimesh(BoxMesh.new(), layout.cracks.size(), false)
	for index: int in range(layout.cracks.size()):
		var crack: Dictionary = layout.cracks[index]
		var pos: Vector2 = crack["pos"] as Vector2
		var basis: Basis = Basis(Vector3.UP, deg_to_rad(float(crack["yaw"]))).scaled(Vector3(float(crack["length"]), 0.02, 0.16))
		multimesh.set_instance_transform(index, Transform3D(basis, Vector3(pos.x, 0.03, pos.y)))
	_add_multimesh(multimesh, M.glow(Color(0.12, 0.06, 0.2), 0.6) if not bool(ctx.get("final", false)) else M.flat(Color(0.2, 0.2, 0.22)), "Cracks")


func _build_chests() -> void:
	for id: Variant in layout.chests.keys():
		var chest: Node3D = ModelKit.dungeon_prop("chest_gold")
		root.add_child(chest)
		chest.position = layout.chests[id] as Vector3
		chest.rotation_degrees.y = _rng.randf() * 360.0
		chest.scale = Vector3.ONE * 0.225
		chest_nodes[str(id)] = chest


## Everything in the underground hideout is moved onto visual layer 2 (the sun does not light it).
func _finish_layers() -> void:
	for child: Node in root.get_children():
		if child is Node3D and (child as Node3D).position.z >= CREASE_Z and (child as Node3D).position.z < float(CapitalLayout.H) + 4.0:
			_set_layers(child, CREASE_LAYER)


func _set_layers(node: Node, layer: int) -> void:
	if node is GeometryInstance3D:
		(node as GeometryInstance3D).layers = layer
	if node is Light3D:
		(node as Light3D).light_cull_mask = layer
	for child: Node in node.get_children():
		_set_layers(child, layer)


# ---- Animation ---------------------------------------------------------------------------------------------


func animate(delta: float) -> void:
	time += delta
	for spin: Node3D in _spinners:
		spin.rotation.z += float(spin.get_meta("spin_speed", 0.8)) * delta
	for orbit: Node3D in _orbits:
		orbit.rotation.y += 0.6 * delta
	for index: int in range(_rift_discs.size()):
		var disc: MeshInstance3D = _rift_discs[index]
		if is_instance_valid(disc):
			disc.scale = Vector3.ONE * (1.0 + 0.03 * sin(time * 2.0 + float(index)))
	for index: int in range(_rift_cores.size()):
		var tear: Node3D = _rift_cores[index]
		if is_instance_valid(tear):
			tear.scale = Vector3(1.0 + 0.06 * sin(time * 2.3 + float(index) * 2.0), 1.0 + 0.03 * sin(time * 1.7 + float(index)), 1.0)
	for index: int in range(_rift_lights.size()):
		var light: OmniLight3D = _rift_lights[index]
		if is_instance_valid(light):
			light.light_energy = 2.8 * (0.8 + 0.2 * sin(time * 1.6 + float(index) * 1.3))
	if _castle_cracks != null:
		# the castle's hairline cracks leak a slow, faint pulse of rift light
		_castle_cracks.emission_energy_multiplier = 2.4 * (0.62 + 0.38 * (0.5 + 0.5 * sin(time * 0.7)))
