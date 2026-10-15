class_name GainlandsBuilder
extends ZoneMap
## Turns a `GainlandsLayout` into the Gainlands' 3D world and answers walkability queries: the
## rolling faceted main land (a polar mesh so its edge is exactly the walkable edge), the floating
## islands with rocky undersides, a sea of clouds, KayKit mills/trees/rocks plus the procedural
## wheels, gym equipment and stages of `GainlandsProps`, copper energy pipes with travelling
## pulses, signs, and the hidden chests. `animate()` moves everything that moves.

const M = preload("res://world/gainlands/gainlands_materials.gd")
const KAYKIT_TREES: Array[String] = ["tree_single_A", "tree_single_B"]
const KAYKIT_ROCKS: Array[String] = ["rock_single_A", "rock_single_B", "rock_single_C", "rock_single_D", "rock_single_E"]
const RINGS: int = 38
const SECTORS: int = 132

var layout: GainlandsLayout = GainlandsLayout.new()
var root: Node3D
var story: ZoneStoryText
## 1.0 = idle; the wheels spin faster once the grid is powered.
var wheel_speed: float = 0.45

var _buckets: Dictionary = {}
var _spinners: Array[Node3D] = []
var _fans: Array[Node3D] = []
var _bobbers: Array[Node3D] = []
var _y_spinners: Array[Node3D] = []
var _z_spinners: Array[Node3D] = []
var _screens: Array[MeshInstance3D] = []
var _clouds: Array[Node3D] = []
var _pulses: Array[Dictionary] = []
var _hamsters: Array[Node3D] = []
var _time: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func build(parent: Node3D) -> void:
	_rng.seed = 77
	layout.build()
	story = ZoneStoryText.for_zone(GainlandsZone.ID)
	root = Node3D.new()
	root.name = "Gainlands"
	parent.add_child(root)
	_build_main_land()
	_build_islands()
	_build_bridge()
	_build_house_of_gains()
	_build_swolympus()
	_build_swolympus_gate()
	_build_clouds()
	_build_props()
	_build_pipes()
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


func height_at(pos: Vector3) -> float:
	return layout.ground_height(pos.x, pos.z)


func area_at(pos: Vector3) -> Array[String]:
	var area: GainlandsLayout.Area = layout.area_at(pos.x, pos.z)
	if area == null:
		return [] as Array[String]
	return [area.id, area.title] as Array[String]


func is_floor_at(pos: Vector3) -> bool:
	var surface: GainlandsLayout.Surface = layout.surface_at(pos.x, pos.z)
	# dressing, foliage and decals go on grass only: the bridge deck is walkable but not a floor to plant on
	return surface == GainlandsLayout.Surface.GROUND or surface == GainlandsLayout.Surface.ISLAND


func map_bounds() -> Rect2:
	var bounds: Rect2 = Rect2(GainlandsLayout.CENTER - GainlandsLayout.RADII * 1.1, GainlandsLayout.RADII * 2.2)
	for island: GainlandsLayout.Island in layout.islands:
		bounds = bounds.merge(Rect2(island.center - Vector2(island.radius, island.radius), Vector2(island.radius, island.radius) * 2.0))
	bounds = bounds.merge(Rect2(GainlandsLayout.BRIDGE_X - GainlandsLayout.BRIDGE_HALF_WIDTH - 2.0, GainlandsLayout.BRIDGE_Z0 - 2.0, GainlandsLayout.BRIDGE_HALF_WIDTH * 2.0 + 4.0, GainlandsLayout.BRIDGE_Z1 - GainlandsLayout.BRIDGE_Z0 + 6.0))
	bounds = bounds.merge(GainlandsLayout.CAUSEWAY.grow(2.0))
	return bounds


## The island whose rim the player is standing past (stepping there means falling), or null.
func fall_island(pos: Vector3) -> GainlandsLayout.Island:
	if layout.surface_at(pos.x, pos.z) == GainlandsLayout.Surface.RIM:
		return layout.island_at(pos.x, pos.z)
	return null


## The island the player is standing on (its top), or null on the main land.
func island_under(pos: Vector3) -> GainlandsLayout.Island:
	var surface: GainlandsLayout.Surface = layout.surface_at(pos.x, pos.z)
	if surface == GainlandsLayout.Surface.ISLAND or surface == GainlandsLayout.Surface.RIM:
		return layout.island_at(pos.x, pos.z)
	return null


func add_blocker(pos: Vector3, radius: float) -> void:
	_add_obstacle(Vector3(pos.x, pos.z, radius))


func is_walkable(pos: Vector3, body_radius: float = StorybookScale.BODY_RADIUS) -> bool:
	var surface: GainlandsLayout.Surface = layout.surface_at(pos.x, pos.z)
	if surface == GainlandsLayout.Surface.VOID:
		return false
	if surface == GainlandsLayout.Surface.BRIDGE:
		if GainlandsLayout.on_bridge(pos.x, pos.z):
			# the deck between the rope rails; the far landing is the edge of the world (walking off it leaves for town, GainlandsScene)
			return absf(pos.x - GainlandsLayout.BRIDGE_X) <= GainlandsLayout.BRIDGE_HALF_WIDTH - GainlandsLayout.BRIDGE_RAIL and not _hits_obstacle(pos, body_radius)
		# the causeway to the House of Gains gate: its parapets are the edge (only the sides shrink: the land end must join the meadow with no gap)
		return absf(pos.x - GainlandsLayout.HOUSE_OF_GAINS.x) <= GainlandsLayout.CAUSEWAY.size.x * 0.5 - 0.3 and not _hits_obstacle(pos, body_radius)
	if surface == GainlandsLayout.Surface.GROUND and layout.main_edge_distance(pos.x, pos.z) < 0.35:
		return false
	return not _hits_obstacle(pos, body_radius)


func has_line_of_sight(a: Vector3, b: Vector3) -> bool:
	var steps: int = maxi(1, int(a.distance_to(b) / 0.6))
	for i: int in range(steps + 1):
		var point: Vector3 = a.lerp(b, float(i) / float(steps))
		var surface: GainlandsLayout.Surface = layout.surface_at(point.x, point.z)
		if surface == GainlandsLayout.Surface.VOID or surface == GainlandsLayout.Surface.RIM:
			return false
		if _hits_obstacle(point, 0.1):
			return false
	return true


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


func _index_obstacles() -> void:
	for prop: GainlandsLayout.Prop in layout.props:
		if prop.radius > 0.0:
			_add_obstacle(Vector3(prop.pos.x, prop.pos.z, prop.radius))
	for id: Variant in layout.chests.keys():
		var chest: Vector3 = layout.chests[id] as Vector3
		_add_obstacle(Vector3(chest.x, chest.z, 0.18))


# ---- Terrain ----------------------------------------------------------------------------------------


static func _noise(x: float, z: float) -> float:
	return fposmod(sin(x * 12.9898 + z * 78.233) * 43758.5453, 1.0)


func _tri(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, color: Color) -> void:
	for vertex: Vector3 in [a, b, c]:
		surface.set_color(color)
		surface.add_vertex(vertex)


func _land_point(ring: int, sector: int, rings: int, sectors: int) -> Vector3:
	var fraction: float = float(ring) / float(rings)
	var angle: float = TAU * float(sector % sectors) / float(sectors)
	var factor: float = GainlandsLayout.radius_factor(angle)
	var x: float = GainlandsLayout.CENTER.x + cos(angle) * GainlandsLayout.RADII.x * factor * fraction
	var z: float = GainlandsLayout.CENTER.y + sin(angle) * GainlandsLayout.RADII.y * factor * fraction
	return Vector3(x, layout.ground_height(x, z), z)


func _grass_color(p: Vector3, centroid: Vector3) -> Color:
	var shade: float = clampf((centroid.y + 1.6) / 3.2, 0.0, 1.0)
	var color: Color = M.GRASS_LOW.lerp(M.GRASS_HIGH, shade)
	color = color.lightened((_noise(centroid.x * 0.7, centroid.z * 0.7) - 0.5) * 0.04)
	var path: float = layout.path_weight(centroid.x, centroid.z)
	if path > 0.0:
		color = color.lerp(M.PATH.lightened((_noise(p.x, p.z) - 0.5) * 0.08), path)
	var hub_distance: float = Vector2(centroid.x - 52.0, centroid.z - 64.0).length()
	if hub_distance < 9.0:
		color = color.lerp(Color(0.78, 0.66, 0.5), 1.0 - smoothstep(6.5, 9.0, hub_distance))
	return color


func _build_main_land() -> void:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(-1)
	for ring: int in range(RINGS):
		for sector: int in range(SECTORS):
			var p00: Vector3 = _land_point(ring, sector, RINGS, SECTORS)
			var p01: Vector3 = _land_point(ring, sector + 1, RINGS, SECTORS)
			var p10: Vector3 = _land_point(ring + 1, sector, RINGS, SECTORS)
			var p11: Vector3 = _land_point(ring + 1, sector + 1, RINGS, SECTORS)
			if ring == 0:
				var centroid: Vector3 = (p00 + p10 + p11) / 3.0
				_tri(surface, p00, p11, p10, _grass_color(p00, centroid))
			else:
				var c1: Vector3 = (p00 + p10 + p11) / 3.0
				var c2: Vector3 = (p00 + p11 + p01) / 3.0
				_tri(surface, p00, p11, p10, _grass_color(p00, c1))
				_tri(surface, p00, p01, p11, _grass_color(p00, c2))
	# The cliff skirt and rocky underside hang from the outer ring.
	var previous: Array[Vector3] = []
	for sector: int in range(SECTORS):
		previous.append(_land_point(RINGS, sector, RINGS, SECTORS))
	var layers: int = 6
	for layer: int in range(1, layers + 1):
		var t: float = float(layer) / float(layers)
		var current: Array[Vector3] = []
		for sector: int in range(SECTORS):
			var top: Vector3 = _land_point(RINGS, sector, RINGS, SECTORS)
			var inward: float = lerpf(1.0, 0.12, pow(t, 1.4))
			var depth: float = -GainlandsLayout.CLIFF_DEPTH * 0.6 * t - 24.0 * pow(maxf(t - 0.35, 0.0), 1.2)
			var jitter: float = (_noise(float(sector) * 3.1, float(layer) * 7.7) - 0.5) * 2.4
			var base_x: float = GainlandsLayout.CENTER.x + (top.x - GainlandsLayout.CENTER.x) * inward
			var base_z: float = GainlandsLayout.CENTER.y + (top.z - GainlandsLayout.CENTER.y) * inward
			current.append(Vector3(base_x, depth + jitter * t, base_z))
		for sector: int in range(SECTORS):
			var next: int = (sector + 1) % SECTORS
			var rock: Color = M.ROCK.lerp(M.ROCK_DARK, t).lightened((_noise(float(sector), float(layer)) - 0.5) * 0.12)
			if layer == 1:
				rock = Color(0.52, 0.42, 0.3).lerp(M.ROCK, 0.3).lightened((_noise(float(sector), 3.3) - 0.5) * 0.1)
			_tri(surface, previous[sector], previous[next], current[sector], rock)
			_tri(surface, previous[next], current[next], current[sector], rock.darkened(0.04))
		previous = current
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	surface.generate_normals()  # without normals the terrain ignores every directional light and shows only the ambient colour
	mesh_instance.mesh = surface.commit()
	mesh_instance.material_override = M.terrain()
	mesh_instance.set_meta(StyleToon.META_NO_TOON, true)  # the vertex-coloured terrain keeps its own material (the double-sided toon variant draws nothing on it)
	mesh_instance.name = "MainLand"
	mesh_instance.set_meta(&"no_occlusion_fade", true)  # terrain never dissolves (the island rock used to dither when the camera passed near it)
	mesh_instance.set_meta(&"no_range_cull", true)  # one huge mesh: the 48 m range cull measured to its centre and hid the whole meadow from the bridge (GC-9)
	root.add_child(mesh_instance)


func _build_islands() -> void:
	for island: GainlandsLayout.Island in layout.islands:
		var surface: SurfaceTool = SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		surface.set_smooth_group(-1)
		var sectors: int = 30
		var rings: int = 5
		var height: float = island.height
		for ring: int in range(rings):
			for sector: int in range(sectors):
				var points: Array[Vector3] = []
				for pair: Vector2i in [Vector2i(ring, sector), Vector2i(ring, sector + 1), Vector2i(ring + 1, sector), Vector2i(ring + 1, sector + 1)]:
					var fraction: float = float(pair.x) / float(rings)
					var angle: float = TAU * float(pair.y % sectors) / float(sectors)
					var wobble: float = 1.0 - 0.05 * _noise(float(pair.y % sectors), island.center.x) * smoothstep(0.7, 1.0, fraction)
					points.append(Vector3(island.center.x + cos(angle) * island.radius * fraction * wobble, height, island.center.y + sin(angle) * island.radius * fraction * wobble))
				var tint: float = _noise(points[0].x, points[0].z)
				var color: Color = M.GRASS_HIGH.lerp(M.GRASS_LOW, tint * 0.6)
				if ring == 0:
					_tri(surface, points[0], points[3], points[2], color)
				else:
					_tri(surface, points[0], points[3], points[2], color)
					_tri(surface, points[0], points[1], points[3], color.lightened(0.03))
		var previous: Array[Vector3] = []
		for sector: int in range(sectors):
			var angle: float = TAU * float(sector) / float(sectors)
			var wobble: float = 1.0 - 0.05 * _noise(float(sector), island.center.x)
			previous.append(Vector3(island.center.x + cos(angle) * island.radius * wobble, height, island.center.y + sin(angle) * island.radius * wobble))
		var layers: int = 5
		for layer: int in range(1, layers + 1):
			var t: float = float(layer) / float(layers)
			var current: Array[Vector3] = []
			for sector: int in range(sectors):
				var angle: float = TAU * float(sector) / float(sectors)
				var inward: float = lerpf(1.0, 0.06, pow(t, 1.3))
				var depth: float = height - 1.4 * minf(t * 3.0, 1.0) - island.radius * 1.25 * pow(t, 1.25)
				var jitter: float = (_noise(float(sector) * 2.3, float(layer) + island.center.y) - 0.5) * 1.2
				current.append(Vector3(island.center.x + cos(angle) * island.radius * inward, depth + jitter * t, island.center.y + sin(angle) * island.radius * inward))
			for sector: int in range(sectors):
				var next: int = (sector + 1) % sectors
				var rock: Color = Color(0.5, 0.38, 0.26).lerp(M.ROCK_DARK, t) if layer == 1 else M.ROCK.lerp(M.ROCK_DARK, t)
				rock = rock.lightened((_noise(float(sector), float(layer) * 5.0) - 0.5) * 0.14)
				_tri(surface, previous[sector], previous[next], current[sector], rock)
				_tri(surface, previous[next], current[next], current[sector], rock.darkened(0.05))
			previous = current
		var instance: MeshInstance3D = MeshInstance3D.new()
		surface.generate_normals()
		instance.mesh = surface.commit()
		instance.material_override = M.terrain()
		instance.set_meta(StyleToon.META_NO_TOON, true)
		instance.name = "Island_" + island.id
		instance.set_meta(&"no_occlusion_fade", true)
		instance.set_meta(&"no_range_cull", true)
		root.add_child(instance)


## The way in from town (GC-8): the timber-and-rope bridge from the south rim to its far landing. Its rails are the walkable edge (`is_walkable`), its gate posts block.
func _build_bridge() -> void:
	var length: float = GainlandsLayout.BRIDGE_Z1 - GainlandsLayout.BRIDGE_Z0
	var bridge: Node3D = GainlandsLandmarks.rope_bridge(length, GainlandsLayout.BRIDGE_HALF_WIDTH * 2.0, GainlandsLayout.BRIDGE_RISE, GainlandsLayout.MIN_GROUND + 0.1)
	bridge.name = "Bridge"
	root.add_child(bridge)
	bridge.position = Vector3(GainlandsLayout.BRIDGE_X, 0.0, GainlandsLayout.BRIDGE_Z0)
	for circle: Variant in bridge.get_meta("circles", []) as Array:
		var local: Vector3 = circle as Vector3
		_add_obstacle(Vector3(GainlandsLayout.BRIDGE_X + local.x, GainlandsLayout.BRIDGE_Z0 + local.y, local.z))


## The House of Gains (GC-10): the fortress-gym on its own rock beyond the north rim, its causeway reaching onto the plateau, smoke from its foundry chimneys.
## The gatehouse towers block; the causeway is a layout surface (walkable).
func _build_house_of_gains() -> void:
	var house: Node3D = GainlandsLandmarks.build({"id": "GAIN-HERO-HOUSE-OF-GAINS", "kind": "fortress", "size": [GainlandsLayout.HOUSE_OF_GAINS_SIZE.x, GainlandsLayout.HOUSE_OF_GAINS_SIZE.y, GainlandsLayout.HOUSE_OF_GAINS_SIZE.z]})
	if house == null:
		return
	root.add_child(house)
	house.position = Vector3(GainlandsLayout.HOUSE_OF_GAINS.x, 0.0, GainlandsLayout.HOUSE_OF_GAINS.y)
	for piece: Node in house.find_children("*", "MeshInstance3D", true, false):
		piece.set_meta(&"no_range_cull", true)  # the goal must show from the whole zone (the 48 m cull would hide it from the hub)
		piece.set_meta(&"no_occlusion_fade", true)
	for circle: Variant in house.get_meta("circles", []) as Array:
		var local: Vector3 = circle as Vector3
		_add_obstacle(Vector3(house.position.x + local.x, house.position.z + local.y, local.z))
	var chimney_index: int = 0
	for chimney: Variant in house.get_meta("chimneys", []) as Array:
		chimney_index += 1
		var top: Vector3 = house.position + (chimney as Vector3)
		var smoke: CPUParticles3D = CPUParticles3D.new()
		smoke.name = "FoundrySmoke%d" % chimney_index
		smoke.amount = 18
		smoke.lifetime = 6.0
		smoke.preprocess = 6.0
		smoke.direction = Vector3(0.35, 1.0, 0.1)
		smoke.spread = 12.0
		smoke.initial_velocity_min = 1.4
		smoke.initial_velocity_max = 2.2
		smoke.gravity = Vector3(0.6, 0.35, 0.0)
		smoke.scale_amount_min = 1.2
		smoke.scale_amount_max = 2.2
		smoke.scale_amount_curve = _smoke_curve()
		var puff: SphereMesh = SphereMesh.new()
		puff.radius = 1.0
		puff.height = 2.0
		puff.radial_segments = 7
		puff.rings = 4
		smoke.mesh = puff
		smoke.material_override = M.translucent(Color(0.42, 0.4, 0.44), 0.42, 0.0)
		smoke.position = top
		smoke.set_meta(&"no_occlusion_fade", true)
		smoke.set_meta(&"no_range_cull", true)
		root.add_child(smoke)


static func _smoke_curve() -> Curve:
	var curve: Curve = Curve.new()
	curve.add_point(Vector2(0.0, 0.4))
	curve.add_point(Vector2(0.5, 1.0))
	curve.add_point(Vector2(1.0, 1.6))
	return curve


## Mount Swolympus in the distance (GC-11): the limestone mountain of the trailhead concept stands out in the void beyond the north-east rim, behind the locked gate
## and the sealed Iron Cavern, so the postgame bonus is visible but never on the route.
const SWOLYMPUS_DISTANT: Vector3 = Vector3(112.0, -4.0, 2.0)


func _build_swolympus() -> void:
	var mountain: Node3D = GainlandsLandmarks.build({"id": "GAIN-HERO-SWOLYMPUS", "kind": "mound", "size": [38.0, 30.0, 22.0], "color": "#8a7a68", "accent": "#f7ebd3"})
	if mountain == null:
		return
	mountain.name = "DistantSwolympus"
	root.add_child(mountain)
	mountain.position = SWOLYMPUS_DISTANT
	mountain.rotation_degrees.y = 215.0
	for piece: Node in mountain.find_children("*", "MeshInstance3D", true, false):
		piece.set_meta(&"no_range_cull", true)
		piece.set_meta(&"no_occlusion_fade", true)


## The locked trailhead gate to Mount Swolympus (SR-4): the trailhead gate model of the concept (GAIN-HERO-TRAILHEAD-GATE) stands on the north-east rim at the
## `swolympus_gate` anchor facing the meadow, its opening closed by a plank-and-timber barrier (GC-11), with nothing walkable behind it. The towers and the
## barrier block the hero; the spot in front of it says "coming soon" (GainlandsZone.SWOLYMPUS_GATE) and E only toasts.
const SWOLYMPUS_GATE_SIZE: Vector3 = Vector3(10.0, 7.0, 1.4)
const SWOLYMPUS_GATE_YAW: float = -45.0


func _build_swolympus_gate() -> void:
	var base: Vector3 = layout.anchors.get("swolympus_gate", Vector3.ZERO) as Vector3
	var gate: Node3D = GainlandsLandmarks.build({"id": "GAIN-HERO-TRAILHEAD-GATE", "kind": "arch", "size": [SWOLYMPUS_GATE_SIZE.x, SWOLYMPUS_GATE_SIZE.y, SWOLYMPUS_GATE_SIZE.z]})
	if gate == null:
		return
	gate.name = "SwolympusGate"
	root.add_child(gate)
	gate.position = Vector3(base.x, layout.ground_height(base.x, base.z), base.z)
	gate.rotation_degrees.y = SWOLYMPUS_GATE_YAW
	var basis: Basis = Basis(Vector3.UP, deg_to_rad(SWOLYMPUS_GATE_YAW))
	for circle: Variant in gate.get_meta("circles", []) as Array:
		var local: Vector3 = circle as Vector3
		var world: Vector3 = gate.position + basis * Vector3(local.x, 0.0, local.y)
		_add_obstacle(Vector3(world.x, world.z, local.z))
	# the closed panel in the opening: bleached planks with two crossed timbers and an iron band, the width of the opening between the towers
	var opening: float = SWOLYMPUS_GATE_SIZE.x * 0.6
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("plank", EnvKit.material("GAIN-WALL-BLEACH" if EnvKit.has("GAIN-WALL-BLEACH") else "ENV-WALL-PLANK", false, Color(0.8, 0.72, 0.6)))
	mesh.set_material("iron", EnvKit.material("GAIN-WALL-IRON" if EnvKit.has("GAIN-WALL-IRON") else "ENV-WALL-FOUNDATION"))
	mesh.box("plank", Vector3(0, 2.0, 0), Vector3(opening - 0.3, 4.0, 0.24), Basis.IDENTITY, 0.02, 0.9)
	mesh.box("iron", Vector3(0, 3.85, 0.15), Vector3(opening - 0.2, 0.3, 0.1), Basis.IDENTITY, 0.0)
	for sign_dir: float in [-1.0, 1.0]:
		mesh.box("iron", Vector3(0, 2.0, 0.17), Vector3(0.36, opening * 0.95, 0.14), Basis(Vector3(0, 0, 1), sign_dir * 0.98), 0.0)
	var panel: MeshInstance3D = mesh.instance("Barrier")
	panel.set_meta(PaintedClasses.META_NO_PAINT, true)
	var holder: Node3D = Node3D.new()
	holder.name = "GateBarrier"
	holder.add_child(panel)
	gate.add_child(holder)
	for step: float in [-1.0, 0.0, 1.0]:
		var world: Vector3 = gate.position + basis * Vector3(step * opening * 0.3, 0.0, 0.0)
		_add_obstacle(Vector3(world.x, world.z, opening * 0.2))
	for piece: Node in gate.find_children("*", "MeshInstance3D", true, false):
		piece.set_meta(&"no_range_cull", true)
		piece.set_meta(&"no_occlusion_fade", true)  # a landmark at the rim: its towers never dissolve beside the hero (nothing walkable behind it)


## The cloud models (adopted by a `CloudFader` so none can block the view).
func cloud_nodes() -> Array[Node3D]:
	return _clouds


func _build_clouds() -> void:
	var specs: Array[Vector4] = []
	var tries: int = 0
	while specs.size() < 34 and tries < 400:
		tries += 1
		var x: float = _rng.randf_range(-30.0, 135.0)
		var z: float = _rng.randf_range(-22.0, 105.0)
		if GainlandsLayout.main_depth(x, z) < 1.25:
			continue
		var blocked: bool = false
		for island: GainlandsLayout.Island in layout.islands:
			if Vector2(x - island.center.x, z - island.center.y).length() < island.radius + 6.0:
				blocked = true
		if blocked:
			continue
		specs.append(Vector4(x, _rng.randf_range(-38.0, -16.0), z, _rng.randf_range(3.5, 7.0)))  # well below the meadow: a drifting cloud used to poke up through the grass (GC-3)
	# A thick layer well below the main land so the plateau floats in a sea of cloud.
	for index: int in range(16):
		var angle: float = TAU * float(index) / 16.0 + _rng.randf() * 0.3
		var distance: float = _rng.randf_range(10.0, 60.0)
		specs.append(Vector4(GainlandsLayout.CENTER.x + cos(angle) * distance, _rng.randf_range(-44.0, -34.0), GainlandsLayout.CENTER.y + sin(angle) * distance * 0.8, _rng.randf_range(10.0, 16.0)))
	for spec: Vector4 in specs:
		var cloud: Node3D = ModelKit.nature("cloud_big" if spec.w > 6.0 else "cloud_small")
		ModelKit.place(root, cloud, Vector3(spec.x, spec.y, spec.z), _rng.randf() * 360.0, spec.w)
		_clouds.append(cloud)


# ---- Props ----------------------------------------------------------------------------------------------


func _ground(x: float, z: float) -> Vector3:
	return Vector3(x, layout.ground_height(x, z), z)


func _build_props() -> void:
	var tree_transforms: Dictionary = {0: [], 1: []}
	var rock_transforms: Dictionary = {0: [], 1: [], 2: [], 3: [], 4: []}
	for prop: GainlandsLayout.Prop in layout.props:
		var pos: Vector3 = _ground(prop.pos.x, prop.pos.z)
		match prop.kind:
			"tree":
				# painted tree cards of the zone kit (TreeCards "oak" / "pine" swap to GAIN-TREE-OAK / -PINE): 2.5 - 4 heroes tall (G-01)
				var hub_distance: float = Vector2(pos.x - 52.0, pos.z - 64.0).length()
				var near: float = clampf((hub_distance - 10.0) / 24.0, 0.0, 1.0)
				# the paint-over keeps the hub open: small pines near the Station (whatever the layout variant), oaks and pines at full size out in the fields
				var variant: int = 1 if hub_distance < 20.0 else prop.variant % 2
				(tree_transforms[variant] as Array).append({"pos": pos, "scale": lerpf(0.5, clampf(prop.model_scale * 0.72, 0.8, 1.15), near)})
			"boulder":
				var rock_scale: float = prop.model_scale * (1.9 if prop.radius > 0.9 else 1.35)
				var rock_basis: Basis = Basis(Vector3.UP, deg_to_rad(prop.yaw)).scaled(Vector3.ONE * rock_scale)
				(rock_transforms[prop.variant % 5] as Array).append(Transform3D(rock_basis, pos - Vector3(0, 0.1, 0)))
			_:
				_place_feature(prop, pos)
	for variant: int in tree_transforms.keys():
		var entries: Array[Dictionary] = []
		entries.assign(tree_transforms[variant] as Array)
		KitFoliage.tree_field(root, "oak" if variant == 0 else "pine", entries, true)
	for variant: int in rock_transforms.keys():
		_add_multimesh(KAYKIT_ROCKS[variant], "nature", rock_transforms[variant] as Array)


## One shared mesh drawn many times (trees, rocks): a MultiMesh built from a KayKit model's mesh.
func _add_multimesh(model: String, folder: String, transforms: Array) -> void:
	if transforms.is_empty():
		return
	var source: Node3D = ModelKit.hex_model("decoration/%s" % folder, model)
	var found: Array[Node] = source.find_children("*", "MeshInstance3D", true, false)
	if found.is_empty():
		source.queue_free()
		return
	var mesh_instance: MeshInstance3D = found[0] as MeshInstance3D
	var multimesh: MultiMesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh_instance.mesh
	multimesh.instance_count = transforms.size()
	for index: int in range(transforms.size()):
		multimesh.set_instance_transform(index, transforms[index] as Transform3D)
	var holder: MultiMeshInstance3D = MultiMeshInstance3D.new()
	holder.multimesh = multimesh
	holder.name = "MM_" + model
	root.add_child(holder)
	source.queue_free()


func _place_feature(prop: GainlandsLayout.Prop, pos: Vector3) -> void:
	var node: Node3D = null
	var kind_scale: float = prop.model_scale
	match prop.kind:
		"mill":
			node = ModelKit.building("windmill")
			ModelKit.tint(node, Color(1.05, 1.0, 0.9))
			var fan: Node = node.find_child("building_windmill_top_fan_blue", true, false)
			if fan is Node3D:
				_fans.append(fan as Node3D)
		"station":
			# the Swole Station platform modelled after GAIN-HERO-SWOLE-STATION (LandmarkKit -> HeroLandmarks); its posts, stall and bag block the hero
			node = LandmarkKit.build({"id": "GAIN-HERO-SWOLE-STATION", "kind": "hut", "size": [10.0, 6.0, 8.0], "color": "#f7ebd3", "accent": "#d9483b"})
			kind_scale = 1.0
			var basis: Basis = Basis(Vector3.UP, deg_to_rad(prop.yaw))
			for circle: Variant in node.get_meta("circles", []) as Array:
				var local: Vector3 = circle as Vector3
				var world: Vector3 = pos + basis * Vector3(local.x, 0.0, local.y)
				_add_obstacle(Vector3(world.x, world.z, local.z))
		"wheel":
			node = GainlandsProps.wheel(4.2, prop.variant > 0)
			var spinner: Node3D = node.get_meta("spinner") as Node3D
			spinner.set_meta("phase", float(prop.variant) * 1.3)
			spinner.set_meta("direction", -1.0 if prop.variant == 1 else 1.0)
			_spinners.append(spinner)
			if node.has_meta("bobber"):
				_hamsters.append(node.get_meta("bobber") as Node3D)
		"bench_press":
			node = GainlandsProps.bench_press()
		"log_rack":
			node = GainlandsProps.log_rack()
		"dumbbell_rack":
			node = GainlandsProps.dumbbell_rack()
		"barbell":
			node = GainlandsProps.lying_barbell()
		"tub":
			node = GainlandsProps.tub()
			if node.has_meta("bobber"):
				_bobbers.append(node.get_meta("bobber") as Node3D)
		"stall":
			node = GainlandsProps.stall(M.CLOTH_RED if prop.variant == 0 else M.CLOTH_BLUE)
		"arch":
			node = GainlandsProps.arch()
			if node.has_meta("spinner_z"):
				_z_spinners.append(node.get_meta("spinner_z") as Node3D)
		"gate":
			node = GainlandsProps.gate()
		"cavern":
			var mountain: Node3D = ModelKit.nature("mountain_A")
			ModelKit.place(root, mountain, pos + Vector3(0, -0.4, -1.8), 0.0, 3.4)
			node = GainlandsProps.cavern_mouth()
			node.position = pos + Vector3(0, 0, 2.2)
			root.add_child(node)
			return
		"stage":
			node = GainlandsProps.stage()
			if node.has_meta("screen"):
				_screens.append(node.get_meta("screen") as MeshInstance3D)
		"mirror":
			node = GainlandsProps.mirror()
		"hut":
			node = GainlandsProps.lecture_log()
		"crystal":
			node = GainlandsProps.crystal()
			if node.has_meta("bobber"):
				_bobbers.append(node.get_meta("bobber") as Node3D)
			if node.has_meta("spinner_y"):
				_y_spinners.append(node.get_meta("spinner_y") as Node3D)
		"pylon":
			return
		_:
			return
	root.add_child(node)
	node.position = pos
	node.rotation_degrees.y = prop.yaw
	if prop.kind in ["mill", "station"]:
		node.scale = Vector3.ONE * kind_scale
	elif prop.kind == "wheel":
		node.scale = Vector3.ONE * kind_scale
	else:
		node.scale = Vector3.ONE * (kind_scale if kind_scale != 1.0 else 1.0)


# ---- Energy pipes -----------------------------------------------------------------------------------


func _build_pipes() -> void:
	for line: PackedVector2Array in layout.pipes:
		var points: Array[Vector3] = []
		var length: float = 0.0
		for i: int in range(line.size() - 1):
			var a: Vector2 = line[i]
			var b: Vector2 = line[i + 1]
			var count: int = maxi(1, int(a.distance_to(b) / 1.6))
			for step: int in range(count):
				var p: Vector2 = a.lerp(b, float(step) / float(count))
				points.append(Vector3(p.x, layout.ground_height(p.x, p.y) + 0.4, p.y))
		var last: Vector2 = line[line.size() - 1]
		points.append(Vector3(last.x, layout.ground_height(last.x, last.y) + 0.4, last.y))
		var cumulative: PackedFloat32Array = PackedFloat32Array([0.0])
		for i: int in range(points.size() - 1):
			GainlandsProps.pipe_segment(root, points[i], points[i + 1])
			length += points[i].distance_to(points[i + 1])
			cumulative.append(length)
			if i % 3 == 0:
				var post: MeshInstance3D = MeshInstance3D.new()
				var post_mesh: BoxMesh = BoxMesh.new()
				post_mesh.size = Vector3(0.18, 0.6, 0.18)
				post.mesh = post_mesh
				post.material_override = M.flat(M.WOOD_DARK)
				post.position = points[i] - Vector3(0, 0.3, 0)
				root.add_child(post)
		for k: int in range(3):
			var pulse: MeshInstance3D = MeshInstance3D.new()
			var sphere: SphereMesh = SphereMesh.new()
			sphere.radius = 0.26
			sphere.height = 0.52
			sphere.radial_segments = 6
			sphere.rings = 3
			pulse.mesh = sphere
			pulse.material_override = M.glow(M.ENERGY, 3.2)
			root.add_child(pulse)
			_pulses.append({"node": pulse, "points": points, "cumulative": cumulative, "length": length, "offset": length * float(k) / 3.0, "speed": 3.2})


# ---- Signs and chests -----------------------------------------------------------------------------------


func _build_signs() -> void:
	for sign: GainlandsLayout.Sign in layout.signs:
		# G-03: no readable text in the world. A board carries one pictogram (the minimap / icon set vocabulary); the words are read by using the sign (a talk popup).
		var size: Vector2 = IconSign.board_size(sign.style, sign.size)
		var node: Node3D = GainlandsProps.sign_post(size.x, size.y, sign.style)
		node.set_meta(PaintedClasses.META_NO_PAINT, true)  # signs stay plain so the pictogram reads
		node.scale = Vector3.ONE * 0.58  # smaller than the old high camera needed: at the low camera a signboard covers the hero
		var pos: Vector3 = _ground(sign.pos.x, sign.pos.z)
		root.add_child(node)
		node.position = pos
		node.rotation_degrees.y = sign.yaw + 180.0
		var mid: float = 1.45 + size.y * 0.5
		if sign.style == "poster":
			mid = 1.4 + size.y * 0.5
		elif sign.style == "memo":
			mid = 1.1 + size.y * 0.5
		node.add_child(IconSign.picture(size * 0.78, sign_icon(sign.key), Vector3(0, mid, 0.1)))


## The icon id a sign shows (minimap and icon-set pictograms; the keys are the `sign.*` story keys).
const SIGN_ICONS: Dictionary = {
	"sign.hub_main": "ICON-ENERGY-B", "sign.hub_power": "ICON-ENERGY-B", "sign.exit": "ICON-MAP-EXIT", "sign.heal_tub": "ICON-MAP-HEAL",
	"sign.protein_stand": "ICON-MECH-BUFF", "sign.flex_mirror": "ICON-MECH-PEEK", "sign.vendor": "ICON-MAP-VENDOR", "sign.mills": "ICON-ENERGY-B",
	"sign.quiz": "ICON-MAP-QUIZ", "sign.studio": "ICON-MAP-MINIGAME", "sign.puzzle": "ICON-MAP-PUZZLE", "sign.wheel": "ICON-MAP-PUZZLE",
	"sign.gym": "ICON-MAP-MINIGAME", "sign.spot_me": "ICON-MAP-QUEST", "sign.thrower_rule": "ICON-MAP-TRAVEL", "sign.ripper_rule": "ICON-MAP-TRAVEL",
	"sign.thrower_east": "ICON-MAP-TRAVEL", "sign.thrower_west": "ICON-MAP-TRAVEL", "sign.mini_dungeon": "ICON-MAP-SIDEDUNGEON",
	"sign.main_dungeon": "ICON-MAP-DUNGEON", "sign.leg_day_note": "ICON-STAT-ATTACK", "sign.energy_poster": "ICON-ENERGY-B",
	"sign.beefcake_poster": "ICON-ESSENCE-B", "sign.pec_perch": "ICON-ESSENCE-B", "sign.delt_deck": "ICON-ESSENCE-B", "sign.glute_garden": "ICON-ESSENCE-B",
	"sign.calf_cove": "ICON-ESSENCE-B", "sign.edge_warning": "ICON-NODE-ELITE", "sign.hamster_fact": "ICON-MAP-QUEST",
}


static func sign_icon(key: String) -> String:
	return IconSign.icon_for(key, SIGN_ICONS)


var _chest_visible_count: int = 0


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


# ---- Animation -----------------------------------------------------------------------------------------


func animate(delta: float) -> void:
	_time += delta
	for spinner: Node3D in _spinners:
		var direction: float = float(spinner.get_meta("direction", 1.0))
		spinner.rotation.z += wheel_speed * direction * delta
	for hamster: Node3D in _hamsters:
		hamster.position.y = 0.9 + absf(sin(_time * 9.0)) * 0.12
	for fan: Node3D in _fans:
		fan.rotate_object_local(Vector3.FORWARD, 0.7 * delta)
	for bobber: Node3D in _bobbers:
		bobber.position.y += sin(_time * 1.7 + bobber.position.x) * 0.002
	for spinner_y: Node3D in _y_spinners:
		spinner_y.rotation.y += 1.1 * delta
	for spinner_z: Node3D in _z_spinners:
		spinner_z.rotation.y += 0.8 * delta
	for screen: MeshInstance3D in _screens:
		var hue: float = fposmod(_time * 0.12, 1.0)
		screen.material_override = M.glow(Color.from_hsv(hue, 0.55, 1.0), 1.2)
	for cloud: Node3D in _clouds:
		cloud.position.x += 0.35 * delta
		if cloud.position.x > 150.0:
			cloud.position.x = -45.0
	for pulse: Dictionary in _pulses:
		var distance: float = fposmod(float(pulse["offset"]) + _time * float(pulse["speed"]), float(pulse["length"]))
		var cumulative: PackedFloat32Array = pulse["cumulative"] as PackedFloat32Array
		var points: Array = pulse["points"] as Array
		var index: int = 0
		while index < cumulative.size() - 2 and cumulative[index + 1] < distance:
			index += 1
		var span: float = maxf(cumulative[index + 1] - cumulative[index], 0.001)
		var along: float = clampf((distance - cumulative[index]) / span, 0.0, 1.0)
		(pulse["node"] as Node3D).position = (points[index] as Vector3).lerp(points[index + 1] as Vector3, along) + Vector3(0, 0.1, 0)
