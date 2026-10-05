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
const CREASE_Z: float = 96.0
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
var rift_nodes: Dictionary = {}

var _buckets: Dictionary = {}
var _spinners: Array[Node3D] = []
var _orbits: Array[Node3D] = []
var _rift_discs: Array[MeshInstance3D] = []
var _rift_cores: Array[MeshInstance3D] = []
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
	_build_castle()
	_build_props()
	_build_signs()
	_build_rifts()
	_build_cracks()
	_build_chests()
	_finish_layers()
	_index_obstacles()


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


func is_walkable(pos: Vector3, body_radius: float = 0.22) -> bool:
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
			return Color(0.86, 0.82, 0.74).lerp(Color(0.8, 0.76, 0.68), 0.35 if checker else n * 0.1)
		CapitalLayout.Floor.PLAZA:
			return Color(0.92, 0.88, 0.8).lerp(Color(0.84, 0.8, 0.72), 0.5 if checker else 0.0)
		CapitalLayout.Floor.LAWN:
			return Color(0.32, 0.82, 0.3) * (1.0 if stripe else 0.9)
		CapitalLayout.Floor.SOIL:
			return Color(0.3, 0.74, 0.3) * (1.0 if stripe else 0.92)
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
	for half: Array in [["Wasteland", Color(0.6, 0.55, 0.44), 60.0, 340.0], ["Meadow", Color(0.3, 0.7, 0.28), -280.0, 340.0]]:
		var plane: MeshInstance3D = MeshInstance3D.new()
		var mesh: PlaneMesh = PlaneMesh.new()
		mesh.size = Vector2(700.0, float(half[3]))
		plane.mesh = mesh
		plane.material_override = M.flat(half[1] as Color)
		plane.position = Vector3(60.0, -0.4, float(half[2]) + float(half[3]) * 0.5)
		plane.name = str(half[0])
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
	_build_houses(houses)


func _building_node(building: CapitalLayout.Building) -> Node3D:
	var node: Node3D = Node3D.new()
	var rect: Rect2 = building.rect
	var center: Vector3 = Vector3(rect.position.x + rect.size.x * 0.5, 0.0, rect.position.y + rect.size.y * 0.5)
	node.position = center
	var w: float = rect.size.x
	var d: float = rect.size.y
	var h: float = building.height
	var free: bool = _district_free(int(center.x), int(center.z))
	match building.style:
		"wall":
			_wall(node, w, d, h, building.district == "facade")
		"tower":
			_tower(node, w, d, h)
		"castle":
			_box(node, Vector3(w, h, d), M.shiny(Color(0.2, 0.18, 0.26), 0.4), Vector3(0, h * 0.5, 0))
			_box(node, Vector3(w + 0.4, 0.5, d + 0.4), M.shiny(M.GOLD, 0.3), Vector3(0, h, 0))
		"ward":
			_box(node, Vector3(w, h, d), M.flat(Color(0.34, 0.34, 0.38)), Vector3(0, h * 0.5, 0))
			_box(node, Vector3(w + 0.3, 0.3, d + 0.3), M.flat(M.STONE_DARK), Vector3(0, h, 0))
		"tram":
			_tram(node, w, d, h)
		"shop":
			_shop(node, building)
		"stall":
			_stall(node, w, d, h, free)
		"factory":
			_factory(node, w, d, h, free or not bool(ctx.get("dark", false)))
		"crypt":
			_crypt(node, w, d, h, free)
		"house":
			_ruined(node, w, d, h * 0.6, building.lean + 6.0, Color(0.9, 0.86, 0.84), true)
		_:
			_ruined(node, w, d, h, building.lean, M.BRICK_DEAD if building.variant % 2 == 0 else M.STONE_GRAY, free)
	node.rotation_degrees.y = 0.0
	return node


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


func _build_boundaries() -> void:
	var wall_color: StandardMaterial3D = M.flat(Color(0.3, 0.29, 0.36))
	# The city's outer walls (north, west, east).
	var north_a: Node3D = Node3D.new()
	root.add_child(north_a)
	north_a.position = Vector3(23.0, 0.0, 0.0)
	_box(north_a, Vector3(44.0, 9.0, 3.0), wall_color, Vector3(0, 4.5, 0))
	var north_b: Node3D = Node3D.new()
	root.add_child(north_b)
	north_b.position = Vector3(97.0, 0.0, 0.0)
	_box(north_b, Vector3(44.0, 9.0, 3.0), wall_color, Vector3(0, 4.5, 0))
	for side_x: float in [0.0, 119.0]:
		_box(root, Vector3(2.5, 9.0, 62.0), wall_color, Vector3(side_x, 4.5, 31.0))
	# The Outskirts' edge: broken fence and low black rock.
	for side_x: float in [0.5, 119.5]:
		_box(root, Vector3(2.5, 3.0, 32.0), M.flat(Color(0.18, 0.17, 0.2)), Vector3(side_x, 1.5, 79.0))
	_box(root, Vector3(120.0, 3.0, 2.5), M.flat(Color(0.18, 0.17, 0.2)), Vector3(60.0, 1.5, 94.8))
	# The Crease's walls (inside layer 2).
	for rect: Rect2 in [Rect2(3.0, 99.0, 39.0, 1.0), Rect2(3.0, 121.0, 39.0, 1.0), Rect2(3.0, 99.0, 1.0, 23.0), Rect2(41.0, 99.0, 1.0, 23.0)]:
		var wall: Vector3 = Vector3(rect.position.x + rect.size.x * 0.5, 2.6, rect.position.y + rect.size.y * 0.5)
		_box(root, Vector3(rect.size.x, 5.2, rect.size.y), M.flat(M.BRICK_DEAD.darkened(0.3)), wall)


## The castle: a huge dark-and-gold palace looming beyond the north wall.
func _build_castle() -> void:
	var castle: Node3D = Node3D.new()
	castle.name = "Castle"
	root.add_child(castle)
	castle.position = Vector3(60.0, 0.0, -2.0)
	var stone: StandardMaterial3D = M.shiny(Color(0.22, 0.2, 0.28), 0.4)
	_box(castle, Vector3(48.0, 22.0, 20.0), stone, Vector3(0, 11.0, -12.0))
	_box(castle, Vector3(18.0, 40.0, 14.0), stone, Vector3(0, 20.0, -14.0))
	B.mesh_at(castle, P._prism(20.0, 14.0, 16.0), M.shiny(M.GOLD, 0.3), Vector3(0, 47.0, -14.0))
	for side: float in [-1.0, 1.0]:
		B.cylinder(castle, 4.0, 4.4, 30.0, stone, Vector3(side * 25.0, 15.0, -8.0), 12)
		B.mesh_at(castle, P._prism(9.0, 10.0, 9.0), M.shiny(M.GOLD, 0.3), Vector3(side * 25.0, 35.0, -8.0))
	var windows: MultiMesh = _multimesh(BoxMesh.new(), 54, false)
	var window_index: int = 0
	for row: int in range(3):
		for column: int in range(18):
			var x: float = -21.0 + float(column) * 2.5
			windows.set_instance_transform(window_index, Transform3D(Basis.IDENTITY.scaled(Vector3(0.9, 1.6, 0.1)), castle.position + Vector3(x, 6.0 + float(row) * 5.0, -1.9)))
			window_index += 1
	_add_multimesh(windows, M.glow(Color(1.0, 0.8, 0.45), 1.6), "CastleWindows")
	# A banner with the portrait over the great door.
	var banner: MeshInstance3D = MeshInstance3D.new()
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(4.0, 5.0)
	banner.mesh = quad
	banner.material_override = M.textured(P.portrait_texture(1))
	banner.position = Vector3(60.0, 12.0, -1.7)
	root.add_child(banner)


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
		node.rotation_degrees.y = prop.yaw
		if prop.kind != "statue_primm" and prop.model_scale != 1.0:
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
	for sign_data: CapitalLayout.Sign in layout.signs:
		var lines: Array[String] = story.get_lines(sign_data.key)
		var longest: int = 0
		for line: String in lines:
			longest = maxi(longest, line.length())
		var width: float = clampf(float(longest) * 0.07 * sign_data.size + 0.7, 1.8, 3.8)
		var wrapped: int = 0
		for line: String in lines:
			wrapped += maxi(1, int(ceilf(float(line.length()) * 0.07 * sign_data.size / (width - 0.5))))
		var height: float = clampf(0.5 + 0.34 * float(wrapped) * sign_data.size, 0.9, 3.0)
		var node: Node3D = Node3D.new()
		root.add_child(node)
		node.position = sign_data.pos
		node.rotation_degrees.y = sign_data.yaw + 180.0
		var mid: float = 1.45 + height * 0.5
		var text_color: Color = Color(0.22, 0.12, 0.05)
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
				node.add_child(board)
		node.scale = Vector3.ONE * 0.6
		var text: Label3D = Label3D.new()
		text.text = "\n".join(lines)
		text.font = UIStyle.font_title()
		text.font_size = 40
		text.pixel_size = 0.0058 * sign_data.size
		text.modulate = text_color
		text.outline_size = 0
		text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text.width = (width - 0.4) / text.pixel_size
		text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		text.double_sided = false
		text.position = Vector3(0, mid, 0.1)
		node.add_child(text)


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
	var node: Node3D = Node3D.new()
	node.name = "Rift_%s" % str(entry["id"])
	var scale_factor: float = 1.6 if big else 1.0
	# The hazard disc on the ground.
	var disc: MeshInstance3D = MeshInstance3D.new()
	var disc_mesh: CylinderMesh = CylinderMesh.new()
	disc_mesh.top_radius = radius
	disc_mesh.bottom_radius = radius
	disc_mesh.height = 0.04
	disc_mesh.radial_segments = 24
	disc.mesh = disc_mesh
	disc.material_override = M.translucent(M.RIFT_VIOLET, 0.45, 1.0)
	disc.position = Vector3(0, 0.05, 0)
	disc.name = "Disc"
	node.add_child(disc)
	_rift_discs.append(disc)
	# The tear itself: a tall bright sliver in a violet shell.
	var core: MeshInstance3D = B.ball(node, 0.5, M.glow(Color(1.0, 0.95, 1.0), 4.0), Vector3(0, 1.5 * scale_factor, 0), Vector3(0.22, 1.5 * scale_factor, 0.08))
	core.name = "Core"
	_rift_cores.append(core)
	B.ball(node, 0.5, M.translucent(M.RIFT_VIOLET, 0.55, 2.2), Vector3(0, 1.5 * scale_factor, 0), Vector3(0.6, 1.9 * scale_factor, 0.35))
	# Orbiting debris.
	var orbit: Node3D = Node3D.new()
	orbit.name = "Orbit"
	node.add_child(orbit)
	_orbits.append(orbit)
	for index: int in range(10 if big else 6):
		var shard: MeshInstance3D = MeshInstance3D.new()
		var prism: PrismMesh = PrismMesh.new()
		prism.size = Vector3(0.16, _rng.randf_range(0.3, 0.7), 0.08)
		shard.mesh = prism
		shard.material_override = M.glow(M.RIFT_CYAN if index % 2 == 0 else M.RIFT_VIOLET, 1.8)
		var angle: float = TAU * float(index) / float(10 if big else 6)
		shard.position = Vector3(cos(angle) * radius * 0.85, 0.8 + _rng.randf_range(0.0, 1.8), sin(angle) * radius * 0.85)
		shard.rotation_degrees = Vector3(_rng.randf_range(0, 360), _rng.randf_range(0, 360), _rng.randf_range(0, 360))
		orbit.add_child(shard)
	# Warped light: a lens of rippling screen around the tear.
	var lens: MeshInstance3D = MeshInstance3D.new()
	var lens_mesh: SphereMesh = SphereMesh.new()
	lens_mesh.radius = radius * 1.5
	lens_mesh.height = radius * 3.0
	lens_mesh.radial_segments = 24
	lens_mesh.rings = 12
	lens.mesh = lens_mesh
	var lens_material: ShaderMaterial = ShaderMaterial.new()
	lens_material.shader = DISTORTION
	lens_material.render_priority = 5
	lens.material_override = lens_material
	lens.position = Vector3(0, 1.0, 0)
	lens.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	lens.name = "Lens"
	node.add_child(lens)
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = M.RIFT_VIOLET
	light.light_energy = 2.4
	light.omni_range = radius * 3.0 + 4.0
	light.position = Vector3(0, 1.6, 0)
	node.add_child(light)
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
		if child is Node3D and (child as Node3D).position.z >= CREASE_Z and (child as Node3D).position.z < 140.0:
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
			disc.scale = Vector3.ONE * (1.0 + 0.04 * sin(time * 3.0 + float(index)))
	for index: int in range(_rift_cores.size()):
		var core: MeshInstance3D = _rift_cores[index]
		if is_instance_valid(core):
			core.scale.x = 0.22 + 0.07 * sin(time * 7.0 + float(index) * 2.0)
