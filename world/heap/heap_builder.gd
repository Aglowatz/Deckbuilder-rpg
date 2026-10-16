class_name HeapBuilder
extends ZoneMap
## Turns a `HeapLayout` into the Verdant Dump's 3D world and answers walkability queries: the faceted patchwork land
## with its layered earth rim, the recycling stream and compost pits (hazards you fall into), the two junk
## mountains, the scree only a mount can cross, the wall of tires with its junk barricades, vine bridges and
## beanstalks that grow on request, trash chutes, Kenney Nature / Survival / Car Kit dressing, signs and the hidden
## chests. `animate()` moves everything that moves.

const H = preload("res://world/heap/heap_materials.gd")
const P = preload("res://world/heap/heap_props.gd")
const B = preload("res://world/buffet/buffet_props.gd")

var layout: HeapLayout = HeapLayout.new()
var root: Node3D
var story: ZoneStoryText
var time: float = 0.0
## True while the player rides a mount: the scree is only walkable then.
var mounted: bool = false
var bridge_nodes: Dictionary = {}
var ladder_nodes: Dictionary = {}
var barricade_nodes: Dictionary = {}
var crop_nodes: Dictionary = {}
var stable_nodes: Dictionary = {}
var chute_nodes: Dictionary = {}
## How far each bridge has grown (0 = bare, 1 = done), by growth id.
var bridge_progress: Dictionary = {}
var ladder_progress: Dictionary = {}
## The hero landmarks by id (DUMP-HERO-ROTHEART, DUMP-HERO-JUNK-MOUNTAIN, DUMP-HERO-TRASH-PANDA-THRONE, DUMP-HERO-WINDMILL,
## DUMP-HERO-COMMONS-GREENHOUSE, HEAP-ROOT-GATE), see `_build_landmarks`.
var landmarks: Dictionary = {}
var rotheart: Node3D
## The Rotheart heart's real light (made by the scene, `HeapScene._dress_zone`), pulsed with its glow in `animate`.
var heart_light: OmniLight3D
## The zone is freed (set by the scene before `build`): the corruption gradient recedes to `corruption.freed` of itself.
var freed: bool = false

var _buckets: Dictionary = {}
var _barricade_blockers: Dictionary = {}
var _smashed: Dictionary = {}
var _spinners: Array[Node3D] = []
var _bobbers: Array[Node3D] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func build(parent: Node3D) -> void:
	_rng.seed = 33
	layout.build()
	story = ZoneStoryText.for_zone(HeapZone.ID)
	root = Node3D.new()
	root.name = "Heap"
	parent.add_child(root)
	_build_rim()
	_build_terrain()
	_build_hazards()
	_build_floor()
	_build_overflow()
	_build_entrance()
	_build_landmarks()
	_build_bridges()
	_build_ladders()
	_build_chutes()
	_build_props()
	_build_barricades()
	_build_signs()
	_build_chests()
	_index_obstacles()


# ---- Queries (the ZoneMap interface) ------------------------------------------------------------


func anchor(anchor_name: String) -> Vector3:
	var base: Vector3 = layout.anchors.get(anchor_name, Vector3.ZERO) as Vector3
	return Vector3(base.x, layout.ground_height(base.x, base.z), base.z)


func has_anchor(anchor_name: String) -> bool:
	return layout.anchors.has(anchor_name)


func chest_positions() -> Dictionary:
	var result: Dictionary = {}
	for id: Variant in layout.chests.keys():
		var base: Vector3 = layout.chests[id] as Vector3
		result[str(id)] = Vector3(base.x, layout.ground_height(base.x, base.z), base.z)
	return result


func enemy_spawns() -> Array[Dictionary]:
	return layout.enemy_spawns


func area_at(pos: Vector3) -> Array[String]:
	var area: HeapLayout.Area = layout.area_at(pos.x, pos.z)
	if area == null:
		return [] as Array[String]
	return [area.id, area.title] as Array[String]


func is_floor_at(pos: Vector3) -> bool:
	var surface: HeapLayout.Surface = layout.surface_at(pos.x, pos.z)
	return surface == HeapLayout.Surface.GROUND or surface == HeapLayout.Surface.PEAK or surface == HeapLayout.Surface.ROUGH or surface == HeapLayout.Surface.BRIDGE


func map_bounds() -> Rect2:
	var bounds: Rect2 = Rect2(HeapLayout.MIN_CORNER - Vector2(2, 2), HeapLayout.MAX_CORNER - HeapLayout.MIN_CORNER + Vector2(4, 4))
	return bounds.expand(Vector2(HeapLayout.ENTRANCE_X, HeapLayout.ENTRANCE_Z1 + 4.0))


## True when (x, z) lies on a stretch of vine bridge that has already grown.
func on_grown_bridge(pos: Vector3) -> bool:
	var bridge: HeapLayout.Bridge = layout.bridge_at(pos.x, pos.z)
	if bridge == null:
		return false
	return layout.bridge_fraction(bridge, pos.z) <= float(bridge_progress.get(bridge.id, 0.0)) + 0.0001


func height_at(pos: Vector3) -> float:
	var surface: HeapLayout.Surface = layout.surface_at(pos.x, pos.z)
	if surface == HeapLayout.Surface.BRIDGE:
		return 0.0
	if surface == HeapLayout.Surface.HAZARD and on_grown_bridge(pos):
		return HeapLayout.BRIDGE_HEIGHT
	return layout.ground_height(pos.x, pos.z)


## True when (x, z) is in the stream or a pit with no grown bridge under it: the player falls in.
func is_in_hazard(pos: Vector3) -> bool:
	return layout.surface_at(pos.x, pos.z) == HeapLayout.Surface.HAZARD and not on_grown_bridge(pos)


func add_blocker(pos: Vector3, radius: float) -> void:
	_add_obstacle(Vector3(pos.x, pos.z, radius))


## The player may wade into the water or a pit (and fall in); never off the land or up a cliff, and onto the scree only
## on a mount.
func is_walkable(pos: Vector3, body_radius: float = StorybookScale.BODY_RADIUS) -> bool:
	var surface: HeapLayout.Surface = layout.surface_at(pos.x, pos.z)
	if surface == HeapLayout.Surface.BRIDGE:
		# the way in: the deck between the kerbs; the kerbs are the edge
		return absf(pos.x - HeapLayout.ENTRANCE_X) <= HeapLayout.ENTRANCE_HALF_WIDTH - HeapLayout.ENTRANCE_RAIL and not _hits_obstacle(pos, body_radius)
	if surface == HeapLayout.Surface.VOID or surface == HeapLayout.Surface.CLIFF:
		return false
	if surface == HeapLayout.Surface.ROUGH and not mounted:
		return false
	if HeapLayout.edge_distance(pos.x, pos.z) < 0.35:
		return false
	return not _hits_obstacle(pos, body_radius) and not _hits_barricade(pos, body_radius)


## Enemies stay on dry ground, summits and the scree: never in the water, a pit or on a cliff.
func is_enemy_walkable(pos: Vector3, body_radius: float = 0.25) -> bool:
	var surface: HeapLayout.Surface = layout.surface_at(pos.x, pos.z)
	if surface != HeapLayout.Surface.GROUND and surface != HeapLayout.Surface.PEAK and surface != HeapLayout.Surface.ROUGH:
		return false
	if HeapLayout.edge_distance(pos.x, pos.z) < 0.6 or layout.hazard_depth(pos.x, pos.z) > -0.9:
		return false
	return not _hits_obstacle(pos, body_radius) and not _hits_barricade(pos, body_radius)


func has_line_of_sight(a: Vector3, b: Vector3) -> bool:
	var steps: int = maxi(1, int(a.distance_to(b) / 0.6))
	for i: int in range(steps + 1):
		var point: Vector3 = a.lerp(b, float(i) / float(steps))
		var surface: HeapLayout.Surface = layout.surface_at(point.x, point.z)
		if surface == HeapLayout.Surface.VOID or surface == HeapLayout.Surface.CLIFF or surface == HeapLayout.Surface.HAZARD:
			return false
		if _hits_obstacle(point, 0.1) or _hits_barricade(point, 0.1):
			return false
	return true


func barricade_radius(barricade_id: String) -> float:
	return HeapLayout.BARRICADE_RADIUS if barricade_id == "gate" else 1.8


func is_barricade_standing(barricade_id: String) -> bool:
	return _barricade_blockers.has(barricade_id) and not _smashed.has(barricade_id)


## Removes a junk barricade from the walkability (the scene plays the smash).
func smash_barricade(barricade_id: String) -> void:
	_smashed[barricade_id] = true


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


func _hits_barricade(pos: Vector3, radius: float) -> bool:
	for id: Variant in _barricade_blockers.keys():
		if _smashed.has(id):
			continue
		var blocker: Vector3 = _barricade_blockers[id] as Vector3
		var reach: float = barricade_radius(str(id)) + radius
		if Vector2(pos.x - blocker.x, pos.z - blocker.z).length_squared() < reach * reach:
			return true
	return false


func _index_obstacles() -> void:
	for obstacle: Vector3 in layout.obstacles:
		_add_obstacle(obstacle)
	for id: String in layout.barricade_positions.keys():
		_barricade_blockers[id] = layout.barricade_positions[id] as Vector3


## The slide route of a chute as world points (x, y, z): from the top, down the mountain, to the landing.
func chute_points(chute: HeapLayout.Chute) -> Array[Vector3]:
	var points: Array[Vector3] = []
	var top: float = layout.ground_height(chute.path[0].x, chute.path[0].y)
	var end: Vector2 = chute.path[chute.path.size() - 1]
	var bottom: float = layout.ground_height(end.x, end.y)
	for index: int in range(chute.path.size()):
		var t: float = float(index) / float(maxi(chute.path.size() - 1, 1))
		var ground: float = layout.ground_height(chute.path[index].x, chute.path[index].y)
		var slope: float = lerpf(top, bottom, t)
		points.append(Vector3(chute.path[index].x, maxf(ground, slope) + 0.25, chute.path[index].y))
	return points


# ---- Terrain ----------------------------------------------------------------------------------------


static func _noise(x: float, z: float) -> float:
	return fposmod(sin(x * 12.9898 + z * 78.233) * 43758.5453, 1.0)


func _tri(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, color: Color) -> void:
	for vertex: Vector3 in [a, b, c]:
		surface.set_color(color)
		surface.add_vertex(vertex)


func _vertex(x: float, z: float) -> Vector3:
	var edge: float = HeapLayout.edge_distance(x, z)
	if edge < 0.0:
		# Outside the table: collapse the vertex onto the outline (a couple of Newton steps along the distance gradient) at the rim height, so the terrain ends in a clean
		# curve instead of a sawtooth of grid triangles dropping away; the table rim below hangs from this edge.
		var snapped: Vector2 = Vector2(x, z)
		for i: int in range(3):
			var here: float = HeapLayout.edge_distance(snapped.x, snapped.y)
			var gradient: Vector2 = Vector2(
				HeapLayout.edge_distance(snapped.x + 0.01, snapped.y) - HeapLayout.edge_distance(snapped.x - 0.01, snapped.y),
				HeapLayout.edge_distance(snapped.x, snapped.y + 0.01) - HeapLayout.edge_distance(snapped.x, snapped.y - 0.01)).normalized()
			snapped += gradient * (0.02 - here)
		return Vector3(snapped.x, layout.ground_height(snapped.x, snapped.y), snapped.y)
	return Vector3(x, layout.ground_height(x, z), z)


func _terrain_color(centroid: Vector3) -> Color:
	var x: float = centroid.x
	var z: float = centroid.z
	var jitter: float = (_noise(x * 0.7, z * 0.7) - 0.5) * 0.03
	var edge: float = HeapLayout.edge_distance(x, z)
	if edge < 0.0:
		return H.GRASS_DARK.lerp(H.DIRT, clampf(absf(centroid.y) / 2.5, 0.0, 1.0))
	var surface: HeapLayout.Surface = layout.surface_at(x, z)
	if surface == HeapLayout.Surface.CLIFF:
		var stripe: int = int(floorf(centroid.y / 0.6 + _noise(x, z) * 2.0)) % 4
		return [H.RUST, H.METAL_DARK, H.MOSS, H.RUST_DARK][stripe].lightened(jitter)
	if surface == HeapLayout.Surface.PEAK:
		var patch: float = _noise(floorf(x * 0.8), floorf(z * 0.8))
		if patch < 0.3:
			return H.RUST.lerp(H.MOSS, 0.4).lightened(jitter)
		return H.MOSS.lerp(H.GRASS, 0.5).lightened(jitter)
	var depth: float = layout.hazard_depth(x, z)
	if depth > -0.4:
		for pit: Vector3 in layout.pits:
			if Vector2(x - pit.x, z - pit.y).length() <= pit.z + 0.4:
				return H.SLUDGE.darkened(0.2)
		return Color(0.18, 0.32, 0.3)
	var color: Color = H.GRASS.lerp(H.MEADOW, _noise(floorf(x * 0.3), floorf(z * 0.3))).lightened(jitter)
	var area: HeapLayout.Area = layout.area_at(x, z)
	if area != null:
		match area.id:
			"farm":
				var cell: int = (int(floorf(x / 4.0)) * 3 + int(floorf(z / 4.0)) * 5) % 4
				color = [H.GOLD_FIELD, H.GRASS, H.DIRT, H.MEADOW][absi(cell)].lightened(jitter)
			"peaks":
				color = color.lerp(H.RUST if z > HeapLayout.WALL_Z else H.STONE.lerp(H.DIRT, _noise(x, z) * 0.6), 0.35)
			"throne":
				color = color.lerp(H.RUST, 0.3)
			"wetlands":
				color = color.lerp(H.SLUDGE.lightened(0.15), 0.35 + 0.25 * _noise(floorf(x * 0.5), floorf(z * 0.5)))
	if surface == HeapLayout.Surface.ROUGH:
		color = H.STONE.lerp(H.DIRT, _noise(x * 1.3, z * 1.3) * 0.7).lightened(jitter)
	if depth > -2.0:
		color = color.lerp(H.DIRT_DARK, smoothstep(-2.0, -0.4, depth) * 0.7)
	# the corruption gradient (data/zone_styles/heap.json): violet and dark toward the Rotheart
	var twist: float = twist_at(x, z)
	if twist > 0.0:
		var tint: Color = Color.html(str(layout.corruption.get("tint", "#5a2f6e")))
		color = color.lerp(tint, twist * float(layout.corruption.get("ground", 0.5))).darkened(twist * float(layout.corruption.get("darken", 0.2)))
	var plaza_distance: float = Vector2(x - HeapLayout.PLAZA_CENTER.x, z - HeapLayout.PLAZA_CENTER.y).length()
	if plaza_distance < HeapLayout.PLAZA_RADIUS + 3.0:
		color = color.lerp(H.DIRT.lerp(H.STRAW, 0.4 + _noise(floorf(x * 1.5), floorf(z * 1.5)) * 0.25), 1.0 - smoothstep(HeapLayout.PLAZA_RADIUS, HeapLayout.PLAZA_RADIUS + 3.0, plaza_distance))
	var path: float = layout.path_weight(x, z)
	if path > 0.0 and surface == HeapLayout.Surface.GROUND:
		color = color.lerp(H.DIRT.lightened(0.1 + jitter), path * 0.85)
	return color


func _build_terrain() -> void:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(-1)
	var step: float = HeapLayout.TERRAIN_STEP
	var x0: float = HeapLayout.MIN_CORNER.x - 2.0 * step
	var z0: float = HeapLayout.MIN_CORNER.y - 2.0 * step
	var cols: int = int(ceilf((HeapLayout.MAX_CORNER.x - HeapLayout.MIN_CORNER.x) / step)) + 4
	var rows: int = int(ceilf((HeapLayout.MAX_CORNER.y - HeapLayout.MIN_CORNER.y) / step)) + 4
	for row: int in range(rows):
		for col: int in range(cols):
			var x: float = x0 + float(col) * step
			var z: float = z0 + float(row) * step
			var p00: Vector3 = _vertex(x, z)
			var p10: Vector3 = _vertex(x + step, z)
			var p01: Vector3 = _vertex(x, z + step)
			var p11: Vector3 = _vertex(x + step, z + step)
			var c1: Vector3 = (p00 + p10 + p11) / 3.0
			var c2: Vector3 = (p00 + p11 + p01) / 3.0
			_tri(surface, p00, p10, p11, _terrain_color(c1))
			_tri(surface, p00, p11, p01, _terrain_color(c2))
	surface.generate_normals()
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = surface.commit()
	instance.material_override = H.terrain()
	instance.name = "Land"
	instance.set_meta(&"no_range_cull", true)
	instance.set_meta(&"no_occlusion_fade", true)
	root.add_child(instance)


## The layered earth under the land: a grass lip, soil, rock and dark rock, tapering downwards like a floating island.
func _build_rim() -> void:
	var layers: Array[Dictionary] = [
		{"top": -0.6, "bottom": -1.8, "inset": -0.3, "color": H.GRASS_DARK},
		{"top": -1.8, "bottom": -4.6, "inset": 0.3, "color": H.DIRT},
		{"top": -4.6, "bottom": -8.0, "inset": 1.1, "color": H.STONE},
		{"top": -8.0, "bottom": -12.0, "inset": 2.4, "color": H.METAL_DARK},
		{"top": -12.0, "bottom": -17.0, "inset": 4.6, "color": H.DIRT_DARK},
	]
	for layer: Dictionary in layers:
		var outline: PackedVector2Array = _outline(float(layer["inset"]))
		var surface: SurfaceTool = SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		surface.set_smooth_group(-1)
		var color: Color = layer["color"] as Color
		for index: int in range(outline.size()):
			var a: Vector2 = outline[index]
			var b: Vector2 = outline[(index + 1) % outline.size()]
			var shade: Color = color.lightened((_noise(a.x, a.y) - 0.5) * 0.14)
			var top: float = float(layer["top"])
			var bottom: float = float(layer["bottom"])
			_tri(surface, Vector3(a.x, top, a.y), Vector3(b.x, top, b.y), Vector3(a.x, bottom, a.y), shade)
			_tri(surface, Vector3(b.x, top, b.y), Vector3(b.x, bottom, b.y), Vector3(a.x, bottom, a.y), shade.darkened(0.05))
		surface.generate_normals()
		var instance: MeshInstance3D = MeshInstance3D.new()
		instance.mesh = surface.commit()
		instance.material_override = H.terrain()
		instance.name = "RimLayer"
		instance.set_meta(&"no_range_cull", true)
		instance.set_meta(&"no_occlusion_fade", true)
		root.add_child(instance)


func _outline(inset: float) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	var low: Vector2 = HeapLayout.MIN_CORNER + Vector2(inset, inset)
	var high: Vector2 = HeapLayout.MAX_CORNER - Vector2(inset, inset)
	var radius: float = maxf(HeapLayout.CORNER_RADIUS - inset, 1.0)
	var corners: Array[Vector2] = [Vector2(high.x - radius, low.y + radius), Vector2(high.x - radius, high.y - radius), Vector2(low.x + radius, high.y - radius), Vector2(low.x + radius, low.y + radius)]
	var arc_steps: int = 8
	for corner_index: int in range(4):
		var start: float = -PI * 0.5 + float(corner_index) * PI * 0.5
		for step: int in range(arc_steps + 1):
			var angle: float = start + PI * 0.5 * float(step) / float(arc_steps)
			points.append(corners[corner_index] + Vector2(cos(angle), sin(angle)) * radius)
	return points


func _build_floor() -> void:
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(420.0, 420.0)
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = plane
	instance.material_override = H.flat(Color(0.22, 0.36, 0.2))
	instance.position = Vector3(50.0, -26.0, 40.0)
	instance.name = "FarGround"
	instance.set_meta(&"no_range_cull", true)
	instance.set_meta(&"no_occlusion_fade", true)
	root.add_child(instance)


# ---- The way in and the landmarks (docs/art/heap_slice.md, Part A) -------------------------------------------


## The overflow pool the entrance bridge crosses: a sludge-green plane south of the rim, below the rim's top layer.
func _build_overflow() -> void:
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(140.0, 60.0)
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = plane
	instance.material_override = StyleWater.material(Color("6a9a78"), Color("2a4a3a"))
	instance.position = Vector3(50.0, -2.6, HeapLayout.MAX_CORNER.y + 30.0)
	instance.name = "OverflowPool"
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.set_meta(&"no_range_cull", true)
	instance.set_meta(&"no_occlusion_fade", true)
	instance.set_meta(PaintedClasses.META_NO_PAINT, true)
	root.add_child(instance)


## The plank bridge from the land's south rim out over the overflow pool to its far landing: the hero arrives on it and walks north into the
## Commons; its kerbs are the walkable edge (`is_walkable`), its gate pillars and landing posts block.
func _build_entrance() -> void:
	var length: float = HeapLayout.ENTRANCE_Z1 - HeapLayout.ENTRANCE_Z0
	var bridge: Node3D = HeapLandmarks.entrance_bridge(length, HeapLayout.ENTRANCE_HALF_WIDTH * 2.0)
	root.add_child(bridge)
	bridge.position = Vector3(HeapLayout.ENTRANCE_X, 0.0, HeapLayout.ENTRANCE_Z0)
	_add_circles(bridge, bridge.position, 0.0)
	_never_cull(bridge, true)


## The hero models (`HeapLandmarks` through `HeroLandmarks`, the approved concepts): the Rotheart, Junk Mountain and the Trash Panda Throne are views
## beyond the rim (never culled or faded; the throne's stair reaches the land and its circles block there), the windmill and the greenhouse stand on flat
## kept-clear ground with their circles solid, the root gate is the Rotheart's door on the land (the layout's LANDMARK_BLOCKERS carry the same circles
## for the layout-only readers). Spinners turn in `animate`; the Rotheart's heart pulses.
func _build_landmarks() -> void:
	rotheart = _place_landmark("DUMP-HERO-ROTHEART", _hero("DUMP-HERO-ROTHEART", HeapLayout.ROTHEART_SIZE), HeapLayout.ROTHEART, 0.0, true)
	_place_landmark("DUMP-HERO-JUNK-MOUNTAIN", _hero("DUMP-HERO-JUNK-MOUNTAIN", HeapLayout.JUNK_MOUNTAIN_SIZE), HeapLayout.JUNK_MOUNTAIN, -48.0, true)
	_place_landmark("DUMP-HERO-TRASH-PANDA-THRONE", _hero("DUMP-HERO-TRASH-PANDA-THRONE", HeapLayout.THRONE_SIZE), HeapLayout.THRONE, 0.0, true)
	_place_landmark("HEAP-ROOT-GATE", HeapLandmarks.root_gate(HeapLayout.ROOT_GATE_SIZE), HeapLayout.ROOT_GATE, 0.0, false)
	_place_landmark("DUMP-HERO-WINDMILL", _hero("DUMP-HERO-WINDMILL", HeapLayout.WINDMILL_SIZE), HeapLayout.WINDMILL, 0.0, false)
	_place_landmark("DUMP-HERO-COMMONS-GREENHOUSE", _hero("DUMP-HERO-COMMONS-GREENHOUSE", HeapLayout.GREENHOUSE_SIZE), HeapLayout.GREENHOUSE, 0.0, false)
	for node: Variant in landmarks.values():
		if (node as Node3D).has_meta("spinner"):
			_spinners.append((node as Node3D).get_meta("spinner") as Node3D)


func _hero(id: String, size: Vector3) -> Node3D:
	return LandmarkKit.build({"id": id, "kind": "facade", "size": [size.x, size.y, size.z]})


## A landmark at (x, z) turned by `yaw`, hanging off the root (never chunk-culled): a view stands at y 0 off the land and never fades; a region
## landmark stands on the (flat) ground with its circles solid.
func _place_landmark(id: String, node: Node3D, at: Vector2, yaw: float, view: bool) -> Node3D:
	if node == null:
		return null
	root.add_child(node)
	node.position = Vector3(at.x, 0.0 if view else layout.ground_height(at.x, at.y), at.y)
	node.rotation_degrees.y = yaw
	_add_circles(node, node.position, yaw)
	_never_cull(node, view)
	landmarks[id] = node
	return node


## The blocking circles a built piece carries (meta "circles", local x, z, radius) at world position `pos` turned by `yaw` degrees.
func _add_circles(node: Node3D, pos: Vector3, yaw: float) -> void:
	var basis: Basis = Basis(Vector3.UP, deg_to_rad(yaw))
	for circle: Variant in node.get_meta("circles", []) as Array:
		var local: Vector3 = circle as Vector3
		var world: Vector3 = pos + basis * Vector3(local.x, 0.0, local.y)
		_add_obstacle(Vector3(world.x, world.z, local.z))


## Every mesh of a piece opts out of the range cull (and of the camera fade when `never_fade`): the far views and the floor the hero walks on.
func _never_cull(node: Node3D, never_fade: bool) -> void:
	var pieces: Array[Node] = node.find_children("*", "MeshInstance3D", true, false)
	pieces.append(node)
	for piece: Node in pieces:
		piece.set_meta(&"no_range_cull", true)
		if never_fade:
			piece.set_meta(&"no_occlusion_fade", true)


# ---- Hazards ----------------------------------------------------------------------------------------


func _build_hazards() -> void:
	var water: StandardMaterial3D = H.water()
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(-1)
	var half: float = HeapLayout.STREAM_HALF_WIDTH + 1.0
	var x: float = HeapLayout.MIN_CORNER.x - 1.0
	var step: float = 1.5
	while x < HeapLayout.MAX_CORNER.x + 1.0:
		var z_a: float = HeapLayout.stream_z(x)
		var z_b: float = HeapLayout.stream_z(x + step)
		var a0: Vector3 = Vector3(x, HeapLayout.WATER_LEVEL, z_a - half)
		var a1: Vector3 = Vector3(x, HeapLayout.WATER_LEVEL, z_a + half)
		var b0: Vector3 = Vector3(x + step, HeapLayout.WATER_LEVEL, z_b - half)
		var b1: Vector3 = Vector3(x + step, HeapLayout.WATER_LEVEL, z_b + half)
		_tri(surface, a0, b0, a1, Color(1, 1, 1))
		_tri(surface, b0, b1, a1, Color(1, 1, 1))
		x += step
	surface.generate_normals()
	var stream: MeshInstance3D = MeshInstance3D.new()
	stream.mesh = surface.commit()
	stream.material_override = StyleWater.material(Color("62c0a4"), Color("1b6670"))
	stream.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	stream.name = "RecyclingStream"
	stream.set_meta(&"no_range_cull", true)
	stream.set_meta(&"no_occlusion_fade", true)
	root.add_child(stream)
	for pit: Vector3 in layout.pits:
		var disc: CylinderMesh = CylinderMesh.new()
		disc.top_radius = pit.z + 0.7
		disc.bottom_radius = pit.z + 0.7
		disc.height = 0.04
		disc.radial_segments = 24
		var instance: MeshInstance3D = MeshInstance3D.new()
		instance.mesh = disc
		instance.material_override = H.sludge()
		instance.position = Vector3(pit.x, HeapLayout.WATER_LEVEL, pit.y)
		instance.name = "CompostPit"
		instance.set_meta(&"no_range_cull", true)
		instance.set_meta(&"no_occlusion_fade", true)
		root.add_child(instance)
		B.steam(root, Vector3(pit.x, 0.2, pit.y), 6, pit.z * 0.5, 0.7)
		for index: int in range(5):
			var angle: float = float(index) * 1.3
			var bubble: MeshInstance3D = B.ball(root, 0.16, H.flat(Color(0.5, 0.62, 0.2)), Vector3(pit.x + cos(angle) * pit.z * 0.5, HeapLayout.WATER_LEVEL + 0.05, pit.y + sin(angle) * pit.z * 0.5), Vector3(1, 0.5, 1))
			bubble.set_meta("phase", float(index))
			_bobbers.append(bubble)
	# Bottles and cans drifting along in the stream.
	var colors: Array[Color] = [Color(0.3, 0.7, 0.4), Color(0.8, 0.8, 0.85), Color(0.9, 0.7, 0.2), Color(0.3, 0.55, 0.9)]
	for index: int in range(22):
		var bx: float = 6.0 + float(index) * 4.0
		var bz: float = HeapLayout.stream_z(bx) + sin(float(index) * 1.7) * 2.0
		if layout.bridge_at(bx, bz) != null:
			continue
		var bottle: MeshInstance3D = B.cylinder(root, 0.07, 0.09, 0.4, H.flat(colors[index % colors.size()]), Vector3(bx, HeapLayout.WATER_LEVEL + 0.08, bz), 6)
		bottle.rotation_degrees = Vector3(80.0, float(index) * 40.0, 0.0)
		bottle.set_meta("phase", float(index))
		_bobbers.append(bottle)


# ---- Growth ---------------------------------------------------------------------------------------------


func _build_bridges() -> void:
	for bridge: HeapLayout.Bridge in layout.bridges:
		var node: Node3D = P.vine_bridge(2.0 * HeapLayout.BRIDGE_REACH)
		node.name = bridge.id
		_never_cull(node, true)
		root.add_child(node)
		node.position = Vector3(bridge.x, HeapLayout.BRIDGE_HEIGHT, HeapLayout.stream_z(bridge.x) + HeapLayout.BRIDGE_REACH)
		bridge_nodes[bridge.id] = node
		bridge_progress[bridge.id] = 0.0
		_show_growth(node, 0.0)


func _build_ladders() -> void:
	var mapping: Dictionary = {"ladder_a": "scrapmore", "ladder_b": "rust"}
	for growth_id: String in mapping.keys():
		var peak: HeapLayout.Peak = null
		for candidate: HeapLayout.Peak in layout.peaks:
			if candidate.id == str(mapping[growth_id]):
				peak = candidate
		var base: Vector3 = anchor("mound_a" if growth_id == "ladder_a" else "mound_b")
		var top: Vector3 = anchor(growth_id + "_top")
		var height: float = peak.height + 1.0
		var stalk: Node3D = P.beanstalk(height)
		stalk.name = growth_id
		root.add_child(stalk)
		stalk.position = Vector3(base.x, base.y + 0.3, base.z)
		var offset: Vector3 = Vector3(top.x - base.x, height, top.z - base.z)
		var count: int = stalk.get_child_count()
		for index: int in range(count):
			var t: float = float(index) / float(maxi(count - 1, 1))
			(stalk.get_child(index) as Node3D).position = Vector3(offset.x * t * t, offset.y * t, offset.z * t * t)
		ladder_nodes[growth_id] = stalk
		ladder_progress[growth_id] = 0.0
		_show_growth(stalk, 0.0)


## Shows the first `progress` (0..1) of a growing node's "Seg<n>" children, the last one scaling in.
func _show_growth(node: Node3D, progress: float) -> void:
	var count: int = node.get_child_count()
	var shown: float = progress * float(count)
	for index: int in range(count):
		var segment: Node3D = node.get_child(index) as Node3D
		var amount: float = clampf(shown - float(index), 0.0, 1.0)
		segment.visible = amount > 0.001
		segment.scale = Vector3.ONE * maxf(amount, 0.001)


func set_bridge_progress(growth_id: String, progress: float) -> void:
	bridge_progress[growth_id] = clampf(progress, 0.0, 1.0)
	if bridge_nodes.has(growth_id):
		_show_growth(bridge_nodes[growth_id] as Node3D, progress)


func set_ladder_progress(growth_id: String, progress: float) -> void:
	ladder_progress[growth_id] = clampf(progress, 0.0, 1.0)
	if ladder_nodes.has(growth_id):
		_show_growth(ladder_nodes[growth_id] as Node3D, progress)


func _build_chutes() -> void:
	for chute: HeapLayout.Chute in layout.chutes:
		var node: Node3D = P.chute(chute_points(chute))
		node.name = chute.id
		_never_cull(node, false)
		root.add_child(node)
		chute_nodes[chute.id] = node


# ---- Props ----------------------------------------------------------------------------------------------


## The corruption where it shows (0 healthy .. 1 at the Rotheart's roots): the layout's gradient, scaled down once the zone is freed (data `corruption.freed`).
func twist_at(x: float, z: float) -> float:
	var t: float = layout.corruption_at(x, z)
	return t * float(layout.corruption.get("freed", 0.0)) if freed else t


func _ground(x: float, z: float) -> Vector3:
	return Vector3(x, layout.ground_height(x, z), z)


func _build_props() -> void:
	# The trees and plants are the kit's painted cards in one MultiMesh field per kind (each card fades itself), chosen by the corruption gradient
	# (data/zone_styles/heap.json): vine oaks and tyre birches where it is healthy giving way to twisted trees toward the Rotheart through a soft dithered
	# band, wildflower beds to violet fungus, reeds where the ground is wet; the rocks stay Nature Kit models; everything else is a layout feature.
	var transforms: Dictionary = {}
	var cards: Dictionary = {}
	var crop_index: int = 0
	var c: Dictionary = layout.corruption
	var tree_edge: float = float(c.get("trees", 0.42))
	var tree_band: float = float(c.get("trees_band", 0.22))
	var fungus_from: float = float(c.get("fungus", 0.4))
	for prop: HeapLayout.Prop in layout.props:
		var pos: Vector3 = _ground(prop.pos.x, prop.pos.z)
		var t: float = twist_at(prop.pos.x, prop.pos.z)
		var dither: float = _noise(prop.pos.x * 0.37, prop.pos.z * 0.37)
		var area: HeapLayout.Area = layout.area_at(prop.pos.x, prop.pos.z)
		var wet: bool = area != null and area.id in ["wetlands", "stream"]
		match prop.kind:
			"tree":
				var twisted: bool = smoothstep(tree_edge - tree_band * 0.5, tree_edge + tree_band * 0.5, t) > dither
				var kind: String = "dump_twisted" if twisted else ("dump_oak" if prop.variant % 3 != 1 else "dump_birch")
				_card_at(cards, kind, pos, clampf(prop.model_scale * 0.95, 0.8, 1.25))
			"bush":
				if t > fungus_from and dither < smoothstep(fungus_from, fungus_from + 0.25, t):
					_card_at(cards, "dump_fungus", pos, clampf(prop.model_scale * 0.9, 0.7, 1.2))
				elif wet:
					_card_at(cards, "dump_reed", pos, clampf(prop.model_scale, 0.8, 1.3))
				else:
					_card_at(cards, "dump_wild", pos, clampf(prop.model_scale * 1.1, 0.9, 1.4))
			"flowers":
				if t > fungus_from + 0.1 and dither < 0.7:
					_card_at(cards, "dump_fungus", pos, 0.55)
				else:
					_card_at(cards, "dump_wild", pos, clampf(prop.model_scale * 0.7, 0.6, 0.95))
			"mushrooms":
				_card_at(cards, "dump_fungus", pos, clampf(prop.model_scale * 0.7, 0.55, 0.95))
			"rock":
				var rocks: Array[String] = ["rock_largeA", "rock_largeC", "rock_tallA", "rock_largeE"]
				_collect(transforms, rocks[prop.variant % rocks.size()], prop, pos, 1.6)
			_:
				var made: Node3D = _place_feature(prop, pos)
				if prop.kind == "crop_plot" and made != null:
					crop_index += 1
					crop_nodes[crop_index] = made
	for model: String in transforms.keys():
		_add_multimesh(model, transforms[model] as Array)
	for kind: String in cards.keys():
		var entries: Array[Dictionary] = []
		entries.assign(cards[kind] as Array)
		var field: MultiMeshInstance3D = KitFoliage.tree_field(root, kind, entries, not bool((TreeCards.KINDS[kind] as Dictionary).get("plant", false)))
		if field != null:
			field.set_meta(&"no_range_cull", true)


func _card_at(cards: Dictionary, kind: String, pos: Vector3, scale: float) -> void:
	var list: Array = cards.get(kind, []) as Array
	list.append({"pos": pos, "scale": scale})
	cards[kind] = list


func _collect(transforms: Dictionary, model: String, prop: HeapLayout.Prop, pos: Vector3, base_scale: float) -> void:
	var list: Array = transforms.get(model, []) as Array
	var basis: Basis = Basis(Vector3.UP, deg_to_rad(prop.yaw)).scaled(Vector3.ONE * prop.model_scale * base_scale)
	list.append(Transform3D(basis, pos))
	transforms[model] = list


func _add_multimesh(model: String, transforms: Array) -> void:
	if transforms.is_empty():
		return
	var source: Node3D = HeapModels.nature(model)
	for child: Node in source.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = child as MeshInstance3D
		var local: Transform3D = Transform3D.IDENTITY
		var walker: Node = mesh_instance
		while walker != source and walker != null:
			if walker is Node3D:
				local = (walker as Node3D).transform * local
			walker = walker.get_parent()
		var multimesh: MultiMesh = MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.mesh = mesh_instance.mesh
		multimesh.instance_count = transforms.size()
		for index: int in range(transforms.size()):
			multimesh.set_instance_transform(index, (transforms[index] as Transform3D) * local)
		var holder: MultiMeshInstance3D = MultiMeshInstance3D.new()
		holder.multimesh = multimesh
		holder.name = "MM_" + model
		var material: Material = mesh_instance.get_active_material(0)
		if material is StandardMaterial3D and (model.begins_with("tree") or model.begins_with("plant")):
			# The Nature Kit's greens are teal; warm them towards the Dump's earthy green.
			var warmed: StandardMaterial3D = (material as StandardMaterial3D).duplicate() as StandardMaterial3D
			warmed.albedo_color = warmed.albedo_color * Color(1.18, 1.0, 0.5)
			material = warmed
		if material != null:
			holder.material_override = material
		root.add_child(holder)
	source.queue_free()


func _place_feature(prop: HeapLayout.Prop, pos: Vector3) -> Node3D:
	var node: Node3D = null
	match prop.kind:
		"barn":
			node = P.barn(story)
		"windmill":
			node = P.windmill()
			if node.has_meta("spinner"):
				_spinners.append(node.get_meta("spinner") as Node3D)
		"harvest_table":
			node = P.harvest_table()
		"swap_shed":
			node = P.swap_shed(story)
		"compost_bin":
			node = P.compost_bin()
		"shrine":
			node = P.shrine(story)
		"trough":
			node = P.trough()
		"stable":
			node = P.stable("boar" if prop.pos.z > 50.0 else "goat")
			stable_nodes[1 if prop.pos.z > 50.0 else 2] = node
		"arch":
			node = P.exit_arch(story)
		"crop_plot":
			node = P.crop_plot(story)
		"appliance_ring":
			node = P.appliance_ring()
		"compost_heap":
			node = P.compost_heap()
		"scarecrow":
			node = P.scarecrow()
		"fair_stage":
			node = P.fair_stage(story)
		"fridge":
			node = P.fridge()
		"haybale":
			node = P.haybale(prop.variant)
		"beanstalk_mound":
			node = P.beanstalk_mound(prop.variant)
		"junk_dam":
			node = P.junk_dam()
			barricade_nodes["dam"] = node
		"hollow_log":
			node = P.hollow_log()
		"car_husk":
			node = P.car_husk(prop.variant)
		"junk_pile":
			node = P.junk_pile(prop.variant)
		"landfill_gate":
			node = P.landfill_gate(story)
		"composting_door":
			node = P.composting_door(story)
		"tire_stack":
			node = P.tire_stack(2 + prop.variant % 3)
		"wall_tires":
			node = P.wall_tires(prop.variant)
		"divider":
			node = P.divider_post(prop.variant)
		"appliance_pile":
			node = P.appliance_pile()
		_:
			return null
	root.add_child(node)
	node.position = pos
	node.rotation_degrees.y = prop.yaw
	if prop.model_scale != 1.0 and prop.kind in ["junk_pile", "windmill", "barn"]:
		node.scale = Vector3.ONE * prop.model_scale
	return node


func _build_barricades() -> void:
	for barricade: HeapGrowth.Barricade in HeapGrowth.barricades():
		if barricade.id != "gate":
			continue
		var pos: Vector3 = layout.barricade_positions[barricade.id] as Vector3
		var node: Node3D = P.barricade(story)
		node.name = "Barricade_" + barricade.id
		root.add_child(node)
		node.position = _ground(pos.x, pos.z)
		barricade_nodes[barricade.id] = node


# ---- Signs and chests -----------------------------------------------------------------------------------


func _build_signs() -> void:
	for sign: HeapLayout.Sign in layout.signs:
		# G-03: no readable text in the world. A board carries one pictogram; the words are read by using the sign (ZoneScene adds a "sign" spot).
		var size: Vector2 = IconSign.board_size(sign.style, sign.size)
		var node: Node3D = P.sign_post(size.x, size.y, sign.style)
		node.set_meta(PaintedClasses.META_NO_PAINT, true)  # signs stay plain so the pictogram reads
		node.scale = Vector3.ONE * 0.5  # smaller than the old high camera needed: at the low camera a signboard covers the hero
		var pos: Vector3 = _ground(sign.pos.x, sign.pos.z)
		root.add_child(node)
		node.position = pos
		node.rotation_degrees.y = sign.yaw + 180.0
		var mid: float = 1.45 + size.y * 0.5
		if sign.style == "poster":
			mid = 1.4 + size.y * 0.5
		elif sign.style == "memo":
			mid = 1.1 + size.y * 0.5
		elif sign.style == "menu":
			mid = 1.3 + size.y * 0.5
		node.add_child(IconSign.picture(size * 0.78, sign_icon(sign.key), Vector3(0, mid, 0.1)))


## The icon id a sign shows (the keys are the `sign.*` story keys in the Verdant Dump's story file).
const SIGN_ICONS: Dictionary = {
	"sign.hub_main": "ICON-ENERGY-R", "sign.hub_motto": "ICON-ESSENCE-R", "sign.exit": "ICON-MAP-EXIT", "sign.heal_table": "ICON-MAP-HEAL",
	"sign.swap_shed": "ICON-MAP-VENDOR", "sign.compost_bin": "ICON-MECH-EATGARBAGE", "sign.shrine": "ICON-NODE-HEAL", "sign.trough": "ICON-RES-GARBAGE",
	"sign.stable_1": "ICON-MAP-QUEST", "sign.oath": "ICON-NODE-BOSS", "sign.fields": "ICON-MAP-TRAVEL", "sign.crops": "ICON-RES-INGREDIENT",
	"sign.grove": "ICON-MAP-TRAVEL", "sign.fair": "ICON-MAP-MINIGAME", "sign.fair_stage": "ICON-MAP-QUIZ", "sign.scrapmore": "ICON-MAP-PUZZLE",
	"sign.beanstalk_rule": "ICON-MAP-TRAVEL", "sign.stream": "ICON-MAP-TRAVEL", "sign.stream_warning": "ICON-NODE-ELITE", "sign.bridge_west": "ICON-MAP-TRAVEL",
	"sign.bridge_center": "ICON-MAP-TRAVEL", "sign.bridge_east": "ICON-MAP-TRAVEL", "sign.bank": "ICON-MAP-TRAVEL", "sign.dam": "ICON-MAP-PUZZLE",
	"sign.stable_2": "ICON-MAP-QUEST", "sign.barricade": "ICON-NODE-LOCKED", "sign.rust": "ICON-RES-IRON", "sign.landfill": "ICON-MAP-SIDEDUNGEON",
	"sign.main_dungeon": "ICON-MAP-DUNGEON", "sign.inspector_note": "ICON-NODE-ELITE", "sign.seed_shrine": "ICON-NODE-TREASURE", "sign.scree": "ICON-MAP-TRAVEL",
	"sign.scree_rule": "ICON-NODE-ELITE", "sign.junk_menu": "ICON-RES-GARBAGE", "sign.log_note": "ICON-NODE-TREASURE",
}


static func sign_icon(key: String) -> String:
	return IconSign.icon_for(key, SIGN_ICONS)


func _build_chests() -> void:
	var positions: Dictionary = chest_positions()
	for id: String in positions.keys():
		var pos: Vector3 = positions[id] as Vector3
		var chest: Node3D = ModelKit.dungeon_prop("chest_gold")
		root.add_child(chest)
		chest.position = pos
		chest.rotation_degrees.y = _rng.randf() * 360.0
		chest.scale = Vector3.ONE * 0.225
		chest_nodes[id] = chest


# ---- Animation --------------------------------------------------------------------------------------------


func animate(delta: float) -> void:
	time += delta
	for hub: Node3D in _spinners:
		hub.rotation.z += 0.35 * delta
	_pulse_heart()
	for node: Node3D in _bobbers:
		var phase: float = float(node.get_meta("phase", 0.0))
		node.position.y = HeapLayout.WATER_LEVEL + 0.08 + sin(time * 1.6 + phase) * 0.04
	H.water().emission_energy_multiplier = 0.1 + 0.05 * sin(time * 1.3)


## The Rotheart's slow heartbeat (and its root gate's, in step): the glows and the light swell and ease about once every five seconds (a double beat, gentle).
func _pulse_heart() -> void:
	var beat: float = 0.5 + 0.5 * sin(time * 1.25)
	beat = beat * beat * (0.8 + 0.2 * sin(time * 2.5 + 0.6))
	for node: Node3D in [rotheart, landmarks.get("HEAP-ROOT-GATE") as Node3D]:
		var material: StandardMaterial3D = node.get_meta("heart", null) as StandardMaterial3D if node != null else null
		if material != null:
			material.albedo_color = (material.get_meta("base_color", Color.WHITE) as Color) * (0.72 + 0.42 * beat)
	if heart_light != null:
		heart_light.light_energy = float(heart_light.get_meta("base_energy", 2.2)) * (0.65 + 0.55 * beat)
