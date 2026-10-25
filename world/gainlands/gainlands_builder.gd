class_name GainlandsBuilder
extends ZoneMap
## Turns a `GainlandsLayout` into the Gainlands' 3D world and answers walkability queries: the
## sandstone plateau with its canyons, cliffs, stairs and stone spans (`GainlandsTerrain`, Gainlands v2),
## waterfalls, background mesas, the floating islands with rocky undersides, the mills, wheels, gym
## equipment and stages of `GainlandsProps`, copper energy pipes with travelling pulses, signs, and the
## hidden chests. `animate()` moves everything that moves.

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
	LoadTiming.detail("gainlands: layout.build")
	story = ZoneStoryText.for_zone(GainlandsZone.ID)
	root = Node3D.new()
	root.name = "Gainlands"
	parent.add_child(root)
	_build_land()
	LoadTiming.detail("gainlands: _build_land")
	_build_islands()
	LoadTiming.detail("gainlands: _build_islands")
	_build_bridge()
	LoadTiming.detail("gainlands: _build_bridge")
	_build_plaza()
	LoadTiming.detail("gainlands: _build_plaza")
	_build_house_of_gains()
	LoadTiming.detail("gainlands: _build_house_of_gains")
	_build_swolympus()
	LoadTiming.detail("gainlands: _build_swolympus")
	_build_swolympus_gate()
	LoadTiming.detail("gainlands: _build_swolympus_gate")
	_build_region_landmarks()
	LoadTiming.detail("gainlands: _build_region_landmarks")
	_build_clouds()
	LoadTiming.detail("gainlands: _build_clouds")
	_build_props()
	LoadTiming.detail("gainlands: _build_props")
	_build_yards()
	LoadTiming.detail("gainlands: _build_yards")
	_build_power()
	LoadTiming.detail("gainlands: _build_power")
	_build_pipes()
	LoadTiming.detail("gainlands: _build_pipes")
	_build_signs()
	LoadTiming.detail("gainlands: _build_signs")
	_build_chests()
	LoadTiming.detail("gainlands: _build_chests")
	_index_obstacles()
	LoadTiming.detail("gainlands: _index_obstacles")


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
	# dressing, foliage and decals go on open ground only: the bridges, the stairs and the paved roads are walkable but not a floor to plant on
	if surface == GainlandsLayout.Surface.ISLAND:
		return true
	if surface != GainlandsLayout.Surface.GROUND or GainlandsLayout.on_stairs(pos.x, pos.z):
		return false
	return layout.path_weight(pos.x, pos.z) < 0.5


## Footsteps: planks on the bridge from town, stone on the spans, stairs and roads, dirt on the sandstone, grass on the islands.
func surface_at(pos: Vector3) -> StringName:
	var surface: GainlandsLayout.Surface = layout.surface_at(pos.x, pos.z)
	if surface == GainlandsLayout.Surface.BRIDGE:
		return &"wood" if GainlandsLayout.on_bridge(pos.x, pos.z) else &"stone"
	if surface == GainlandsLayout.Surface.ISLAND:
		return &"grass"
	if GainlandsLayout.on_stairs(pos.x, pos.z) or layout.path_weight(pos.x, pos.z) > 0.5:
		return &"stone"
	return &"dirt"


func map_bounds() -> Rect2:
	var bounds: Rect2 = Rect2(GainlandsLayout.GRID_ORIGIN, Vector2(GainlandsLayout.GRID_W, GainlandsLayout.GRID_H) * GainlandsLayout.GRID_CELL)
	for island: GainlandsLayout.Island in layout.islands:
		bounds = bounds.merge(Rect2(island.center - Vector2(island.radius, island.radius), Vector2(island.radius, island.radius) * 2.0))
	bounds = bounds.merge(Rect2(GainlandsLayout.BRIDGE_X - GainlandsLayout.BRIDGE_HALF_WIDTH - 2.0, GainlandsLayout.BRIDGE_Z0 - 2.0, GainlandsLayout.BRIDGE_HALF_WIDTH * 2.0 + 4.0, GainlandsLayout.BRIDGE_Z1 - GainlandsLayout.BRIDGE_Z0 + 6.0))
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
		# a stone span over a canyon: its parapets are the edge (only the sides shrink: both ends overlap the land with no gap)
		var span: Rect2 = GainlandsLayout.SPANS[GainlandsLayout.span_at(pos.x, pos.z)]
		return absf(pos.z - span.get_center().y) <= span.size.y * 0.5 - GainlandsLayout.SPAN_RAIL and not _hits_obstacle(pos, body_radius)
	# the mesa stairs: walkable between their cheek walls; beside them the walls (and the mesa's edge) stop the hero
	var stairs: Rect2 = GainlandsLayout.STAIRS
	if GainlandsLayout.on_stairs(pos.x, pos.z):
		return absf(pos.x - stairs.get_center().x) <= stairs.size.x * 0.5 - 0.6 and not _hits_obstacle(pos, body_radius)
	if stairs.grow(0.6).has_point(Vector2(pos.x, pos.z)) and (pos.x < stairs.position.x or pos.x > stairs.end.x):
		return false
	if surface == GainlandsLayout.Surface.GROUND and GainlandsLayout.main_edge_distance(pos.x, pos.z) < GainlandsLayout.EDGE_STOP:
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


## Straight-walled solids (the gym hall): the hero's body stays outside each rectangle.
var _rects: Array[Rect2] = []


func add_rect_blocker(rect: Rect2) -> void:
	_rects.append(rect)


func _hits_obstacle(pos: Vector3, radius: float) -> bool:
	for rect: Rect2 in _rects:
		if rect.grow(radius).has_point(Vector2(pos.x, pos.z)):
			return true
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
	for rect: Rect2 in layout.blocker_rects:
		add_rect_blocker(rect)


# ---- Terrain ----------------------------------------------------------------------------------------


static func _noise(x: float, z: float) -> float:
	return fposmod(sin(x * 12.9898 + z * 78.233) * 43758.5453, 1.0)


func _tri(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, color: Color) -> void:
	for vertex: Vector3 in [a, b, c]:
		surface.set_color(color)
		surface.add_vertex(vertex)


## The plateau (Gainlands v2, Part B): the land mesh, the fortress rock and the Iron Cave's cliff, background mesas in the sea, the stairs up the mesa, the stone
## spans over the canyons and the waterfalls.
func _build_land() -> void:
	root.add_child(GainlandsTerrain.land(layout))
	var cliff: Rect2 = GainlandsLayout.CAVE_CLIFF
	var iron: Node3D = Node3D.new()
	iron.name = "IronCliff"
	root.add_child(iron)
	# the cave's cliff: a broad sandstone rock whose south face (the cave mouth's wall) stands right on the left lands' north rim, a narrower tier stacked on its back
	iron.add_child(GainlandsTerrain.rock(PackedVector2Array([cliff.position, Vector2(cliff.end.x - 3.0, cliff.position.y - 1.0), Vector2(cliff.end.x + 1.0, cliff.position.y + 8.0),
		Vector2(cliff.end.x, cliff.end.y), Vector2(cliff.position.x + 2.0, cliff.end.y), Vector2(cliff.position.x - 2.0, cliff.position.y + 10.0)]), GainlandsLayout.CAVE_CLIFF_TOP, "IronCliffBase", GainlandsTerrain.SAND, true))
	iron.add_child(GainlandsTerrain.rock(GainlandsTerrain.blob_outline(Vector2(cliff.get_center().x - 1.0, cliff.position.y + 6.0), Vector2(9.0, 5.0), 10, 7.7), GainlandsLayout.CAVE_CLIFF_TOP + 4.0, "IronCliffTop"))
	var rock_x0: float = GainlandsLayout.HOUSE_OF_GAINS.x - GainlandsLayout.HOUSE_OF_GAINS_SIZE.x * 0.55
	var rock_x1: float = GainlandsLayout.HOUSE_OF_GAINS.x + GainlandsLayout.HOUSE_OF_GAINS_SIZE.x * 0.55
	var rock_z0: float = GainlandsLayout.HOUSE_OF_GAINS.y - GainlandsLayout.HOUSE_OF_GAINS_SIZE.z * 0.6
	root.add_child(GainlandsTerrain.rock(PackedVector2Array([Vector2(rock_x0 + 3.0, rock_z0), Vector2(rock_x1 - 3.0, rock_z0), Vector2(rock_x1, rock_z0 + 6.0), Vector2(rock_x1 - 1.0, -6.4),
		Vector2(rock_x0 + 1.0, -6.4), Vector2(rock_x0, rock_z0 + 6.0)]), GainlandsLayout.MESA_Y - 0.05, "FortressRock", GainlandsTerrain.SAND, true))
	var index: int = 0
	for mesa: Vector4 in BACKGROUND_MESAS:
		index += 1
		root.add_child(GainlandsTerrain.terraced(Vector2(mesa.x, mesa.y), Vector2(mesa.z, mesa.z * 0.8), mesa.w, 2 if mesa.z >= 8.0 else 1, "Mesa%d" % index, float(index) * 3.7))
	root.add_child(GainlandsTerrain.stairs())
	for rect: Rect2 in GainlandsLayout.SPANS:
		root.add_child(GainlandsTerrain.span(rect))
	for fall: Array in WATERFALLS:
		var lip: Vector2 = fall[0] as Vector2
		root.add_child(GainlandsWater.waterfall(Vector3(lip.x, layout.ground_height(lip.x, lip.y) - 0.15, lip.y), float(fall[1]), fall[2] as Vector2))


## Sandstone mesas standing in the sea round the plateau (x, z, radius, top height): the reference's skyline of rock columns. Views only, off the land.
const BACKGROUND_MESAS: Array[Vector4] = [
	Vector4(-22.0, 30.0, 7.0, 9.0), Vector4(-24.0, 78.0, 9.0, 6.5), Vector4(128.0, 34.0, 8.0, 10.0), Vector4(132.0, 92.0, 10.0, 7.0), Vector4(12.0, 104.0, 9.0, 5.0),
	Vector4(102.0, 104.0, 8.0, 6.0), Vector4(18.0, -26.0, 10.0, 12.0), Vector4(92.0, -30.0, 9.0, 11.0), Vector4(-30.0, 104.0, 7.0, 4.0), Vector4(140.0, 60.0, 6.0, 8.0),
]
## Waterfalls: [lip (x, z) on a cliff edge, width, outward direction]: under the bridge head, into both canyons, over the west and east rims.
const WATERFALLS: Array = [
	[Vector2(47.5, 87.4), 2.4, Vector2(0.0, 1.0)], [Vector2(45.6, 50.0), 1.8, Vector2(1.0, 0.0)], [Vector2(66.6, 48.0), 1.8, Vector2(-1.0, 0.0)],
	[Vector2(4.6, 66.0), 2.2, Vector2(-1.0, 0.0)], [Vector2(106.9, 66.0), 2.0, Vector2(1.0, 0.0)], [Vector2(25.0, 85.6), 2.6, Vector2(0.0, 1.0)],
]


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
	var bridge: Node3D = GainlandsLandmarks.rope_bridge(length, GainlandsLayout.BRIDGE_HALF_WIDTH * 2.0, GainlandsLayout.BRIDGE_RISE, GainlandsLayout.PLATEAU_Y + 0.05, false)
	bridge.name = "Bridge"
	root.add_child(bridge)
	bridge.position = Vector3(GainlandsLayout.BRIDGE_X, 0.0, GainlandsLayout.BRIDGE_Z0)
	for circle: Variant in bridge.get_meta("circles", []) as Array:
		var local: Vector3 = circle as Vector3
		_add_obstacle(Vector3(GainlandsLayout.BRIDGE_X + local.x, GainlandsLayout.BRIDGE_Z0 + local.y, local.z))


## Gainlands v2, Part C: the stone gateway at the bridge head (pillars and banners) and the gym hall in the plaza (GYM_HALL: the layout's rectangle blocks it).
func _build_plaza() -> void:
	var gateway: Node3D = GainlandsPlaza.gateway(GainlandsLayout.BRIDGE_HALF_WIDTH * 2.0)
	root.add_child(gateway)
	gateway.position = Vector3(GainlandsLayout.BRIDGE_X, GainlandsLayout.PLATEAU_Y, GATEWAY_Z)
	for circle: Variant in gateway.get_meta("circles", []) as Array:
		var local: Vector3 = circle as Vector3
		_add_obstacle(Vector3(gateway.position.x + local.x, gateway.position.z + local.y, local.z))
	var hall_rect: Rect2 = GainlandsLayout.GYM_HALL
	var hall: Node3D = GainlandsPlaza.gym_hall(Vector3(hall_rect.size.x, GYM_HALL_HEIGHT, hall_rect.size.y))
	hall.set_meta("concept", "GAIN-HERO-GYM-HALL")  # modelled after the painted concept (art import Oct 20; was a STANDIN)
	root.add_child(hall)
	hall.position = Vector3(hall_rect.get_center().x, GainlandsLayout.PLATEAU_Y, hall_rect.get_center().y)


## Where the gateway's pillars stand: just inside the south rim at the bridge head.
const GATEWAY_Z: float = 87.3
## The gym hall's wall height to the eaves (about two storeys of the storybook scale).
const GYM_HALL_HEIGHT: float = 4.6


## The House of Gains (GC-10): the fortress-gym on its own rock beyond the north rim, its causeway reaching onto the plateau, smoke from its foundry chimneys.
## The gatehouse towers block; the causeway is a layout surface (walkable).
func _build_house_of_gains() -> void:
	var house: Node3D = GainlandsLandmarks.build({"id": "GAIN-HERO-HOUSE-OF-GAINS", "kind": "fortress", "size": [GainlandsLayout.HOUSE_OF_GAINS_SIZE.x, GainlandsLayout.HOUSE_OF_GAINS_SIZE.y, GainlandsLayout.HOUSE_OF_GAINS_SIZE.z], "causeway": false})
	if house == null:
		return
	root.add_child(house)
	house.position = Vector3(GainlandsLayout.HOUSE_OF_GAINS.x, GainlandsLayout.MESA_Y, GainlandsLayout.HOUSE_OF_GAINS.y)
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
const SWOLYMPUS_DISTANT: Vector3 = Vector3(126.0, -5.0, -30.0)


func _build_swolympus() -> void:
	var mountain: Node3D = GainlandsLandmarks.build({"id": "GAIN-HERO-SWOLYMPUS", "kind": "mound", "size": [56.0, 46.0, 40.0], "color": "#8a7a68", "accent": "#f7ebd3"})
	if mountain == null:
		return
	mountain.name = "DistantSwolympus"
	root.add_child(mountain)
	mountain.position = SWOLYMPUS_DISTANT
	mountain.rotation_degrees.y = 215.0
	for piece: Node in mountain.find_children("*", "MeshInstance3D", true, false):
		piece.set_meta(&"no_range_cull", true)
		piece.set_meta(&"no_occlusion_fade", true)
	# Gainlands v2, Part F: the land bridge from the overlook (behind the sealed gate) toward the mountain, ending at a collapsed span over a chasm
	root.add_child(GainlandsCave.swolympus_ridge(SWOLYMPUS_RIDGE[0], SWOLYMPUS_RIDGE[1], SWOLYMPUS_RIDGE[2], SWOLYMPUS_RIDGE[3], GainlandsLayout.PLATEAU_Y - 0.1))


## The ridge to Mount Swolympus: its start just off the overlook's rim behind the gate, the near end of the collapse, the far side of the chasm, the mountain's foot.
const SWOLYMPUS_RIDGE: Array[Vector2] = [Vector2(106.8, 16.2), Vector2(110.0, 6.5), Vector2(111.8, 2.0), Vector2(115.0, -6.0)]


## The locked trailhead gate to Mount Swolympus (SR-4): the trailhead gate model of the concept (GAIN-HERO-TRAILHEAD-GATE) stands on the north-east rim at the
## `swolympus_gate` anchor facing the meadow, its opening closed by a plank-and-timber barrier (GC-11), with nothing walkable behind it. The towers and the
## barrier block the hero; the spot in front of it says "sealed" (GainlandsZone.SWOLYMPUS_GATE), a padlock board hangs on the barrier and E only toasts.
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
	# a padlock board on the barrier (an icon, no lettering): sealed until the end game (GL2-F2)
	var lock: MeshInstance3D = IconSign.picture(Vector2(1.3, 1.3), "ICON-NODE-LOCKED", Vector3(0, 2.3, 0.32))
	lock.name = "LockIcon"
	holder.add_child(lock)
	gate.add_child(holder)
	for step: float in [-1.0, 0.0, 1.0]:
		var world: Vector3 = gate.position + basis * Vector3(step * opening * 0.3, 0.0, 0.0)
		_add_obstacle(Vector3(world.x, world.z, opening * 0.2))
	for piece: Node in gate.find_children("*", "MeshInstance3D", true, false):
		piece.set_meta(&"no_range_cull", true)
		piece.set_meta(&"no_occlusion_fade", true)  # a landmark at the rim: its towers never dissolve beside the hero (nothing walkable behind it)


## The region landmarks kept from the removed sub-areas (SR-8), placed by the declutter rules (open routes, breathing room, nothing in the plaza): the Wheel
## (GAIN-HERO-WHEEL, turning like the hub's wheels) in the mill meadow west of the plaza, the Champions Arch (GAIN-HERO-CHAMPIONS-ARCH) on the open training
## field between the mills and the dungeon road, the Sky Tree (GAIN-HERO-SKY-TREE) on its own islet high beyond the north-west rim as a view, and the Pump
## Shrine (SR-7) beside the arch. Every model blocks through its circles; the sky tree stands off the land and never culls or fades.
const SHRINE_OFFSET: Vector3 = Vector3(0.0, 0.0, -1.7)


func _build_region_landmarks() -> void:
	var wheel: Node3D = _place_landmark({"id": "GAIN-HERO-WHEEL", "kind": "wheel", "size": [9.0, 9.0, 4.0]}, "HeroWheel", Vector2(GainlandsLayout.HERO_WHEEL.x, GainlandsLayout.HERO_WHEEL.y), 25.0)
	if wheel != null and wheel.has_meta("spinner"):
		var spinner: Node3D = wheel.get_meta("spinner") as Node3D
		spinner.set_meta("phase", 0.7)
		spinner.set_meta("direction", 1.0)
		_spinners.append(spinner)
	_place_landmark({"id": "GAIN-HERO-CHAMPIONS-ARCH", "kind": "arch", "size": [9.0, 6.5, 1.4], "color": "#d9483b", "accent": "#f2c14e"}, "ChampionsArch", Vector2(GainlandsLayout.CHAMPIONS_ARCH.x, GainlandsLayout.CHAMPIONS_ARCH.y), 0.0)
	var shrine_anchor: Vector3 = layout.anchors.get("shrine", Vector3.ZERO) as Vector3
	var shrine_pos: Vector3 = shrine_anchor + SHRINE_OFFSET
	_place_landmark({"id": "pump_shrine", "kind": "shrine", "size": [2.4, 3.2, 2.4], "color": "#f7ebd3", "accent": "#7a5230", "glow": "#ff9a58", "surface": "GAIN-WALL-BLEACH", "accent_surface": "GAIN-TRIM-BRASS"}, "PumpShrine", Vector2(shrine_pos.x, shrine_pos.z), 0.0)
	# the Sky Garden's tree on a floating islet in the sky beyond the north-west rim: a view, never on a route
	var tree: Node3D = GainlandsLandmarks.build({"id": "GAIN-HERO-SKY-TREE", "kind": "giant_tree", "size": [18.0, 16.0, 18.0]})
	if tree != null:
		tree.name = "DistantSkyTree"
		root.add_child(tree)
		tree.position = GainlandsLayout.SKY_TREE
		tree.rotation_degrees.y = 140.0
		for piece: Node in tree.find_children("*", "MeshInstance3D", true, false):
			piece.set_meta(&"no_range_cull", true)
			piece.set_meta(&"no_occlusion_fade", true)


## A landmark model on the main land at (x, z) turned by `yaw`: added to the root (never chunk-culled, never faded), its circles made solid.
func _place_landmark(spec: Dictionary, node_name: String, at: Vector2, yaw: float) -> Node3D:
	var node: Node3D = LandmarkKit.build(spec)
	if node == null:
		return null
	node.name = node_name
	root.add_child(node)
	node.position = Vector3(at.x, layout.ground_height(at.x, at.y), at.y)
	node.rotation_degrees.y = yaw
	var basis: Basis = Basis(Vector3.UP, deg_to_rad(yaw))
	for circle: Variant in node.get_meta("circles", []) as Array:
		var local: Vector3 = circle as Vector3
		var world: Vector3 = node.position + basis * Vector3(local.x, 0.0, local.y)
		_add_obstacle(Vector3(world.x, world.z, local.z))
	for piece: Node in node.find_children("*", "MeshInstance3D", true, false):
		piece.set_meta(&"no_range_cull", true)
	return node


## The cloud models (adopted by a `CloudFader` so none can block the view).
func cloud_nodes() -> Array[Node3D]:
	return _clouds


func _build_clouds() -> void:
	# Gainlands v2: the plateau stands 4 m over the sea now; the old cloud layer under the meadow sat under the water plane and cost draw calls for nothing.
	_clouds.clear()


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
				# Gainlands v2, Part D: a few hardy trees (variant 0 wind-bent, 1 cypress), leaning with the zone's one wind (towards +x) give or take the yaw
				var tree_basis: Basis = Basis(Vector3.UP, deg_to_rad(prop.yaw)).scaled(Vector3.ONE * prop.model_scale)
				(tree_transforms[prop.variant % 2] as Array).append(Transform3D(tree_basis, pos - Vector3(0, 0.05, 0)))
			"boulder":
				var rock_scale: float = prop.model_scale * (1.9 if prop.radius > 0.9 else 1.35)
				var rock_basis: Basis = Basis(Vector3.UP, deg_to_rad(prop.yaw)).scaled(Vector3.ONE * rock_scale)
				(rock_transforms[prop.variant % 5] as Array).append(Transform3D(rock_basis, pos - Vector3(0, 0.1, 0)))
			_:
				_place_feature(prop, pos)
	for variant: int in tree_transforms.keys():
		# Art import Oct 20: the painted GAIN-TREE-WINDBENT (5 m) / GAIN-TREE-CYPRESS (6.5 m) cards replace the built STANDIN trees once imported
		var tree_id: String = "GAIN-TREE-WINDBENT" if variant == 0 else "GAIN-TREE-CYPRESS"
		if EnvKit.has_art(tree_id):
			_tree_cards(tree_id, 5.0 if variant == 0 else 6.5, "HardyTrees%d" % variant, tree_transforms[variant] as Array)
		else:
			_tree_group(GainlandsStructures.windbent_mesh() if variant == 0 else GainlandsStructures.cypress_mesh(), "HardyTrees%d" % variant, tree_transforms[variant] as Array)
	for variant: int in rock_transforms.keys():
		_add_multimesh(KAYKIT_ROCKS[variant], "nature", rock_transforms[variant] as Array)


## The hardy trees: one shared mesh, one MeshInstance3D per tree (only a score of them) so the occlusion fader can dissolve the one standing between the
## camera and the hero (a MultiMesh cannot fade one tree); rigid (no toon wind: a trunk must not bend).
func _tree_group(mesh: Mesh, node_name: String, transforms: Array) -> void:
	if transforms.is_empty():
		return
	var holder: Node3D = Node3D.new()
	holder.name = node_name
	holder.set_meta(&"no_wind", true)
	root.add_child(holder)
	for index: int in range(transforms.size()):
		var tree: MeshInstance3D = MeshInstance3D.new()
		tree.name = "Hardy%d" % index
		tree.mesh = mesh
		tree.transform = transforms[index] as Transform3D
		tree.set_meta(PaintedClasses.META_NO_PAINT, true)
		holder.add_child(tree)


## The hardy trees as painted cards, `height` metres times each tree's scale; one card per tree (the card shader fades the one in front of the hero).
func _tree_cards(id: String, height: float, node_name: String, transforms: Array) -> void:
	if transforms.is_empty():
		return
	var holder: Node3D = Node3D.new()
	holder.name = node_name
	root.add_child(holder)
	for index: int in range(transforms.size()):
		var at: Transform3D = transforms[index] as Transform3D
		var size: float = height * at.basis.get_scale().y
		var card: MeshInstance3D = KitFoliage.card(id, Vector2(size, size))
		card.name = "Hardy%d" % index
		card.position += at.origin
		holder.add_child(card)


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


var _mill_count: int = 0


## Storybook scale fixes of the Part A audit (docs/art/gainlands_v2.md): the procedural props that were built too big or too small.
const SCALE_FIX: Dictionary = {"stall": 1.12, "bench_press": 0.62, "barbell": 0.68, "log_rack": 0.75, "dumbbell_rack": 0.75}


func _place_feature(prop: GainlandsLayout.Prop, pos: Vector3) -> void:
	if prop.kind.begins_with("gym:"):
		return  # built with its yard (_build_yards)
	var node: Node3D = null
	var kind_scale: float = prop.model_scale * float(SCALE_FIX.get(prop.kind, 1.0))
	match prop.kind:
		"mill":
			# Gainlands v2, Part D: a four-storey tower mill (about 13 m to the cap; the KayKit windmill was 4.4 m), its sails turning
			node = GainlandsStructures.windmill()
			_mill_count += 1
			node.name = "TowerMill%d" % _mill_count  # unique: Godot renames duplicate siblings to @Node3D@N
			_fans.append(node.get_meta("spinner") as Node3D)
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
			# the Iron Cave's mouth in the north-west cliff face (the cliff itself is the IronCliff rock; its leg-day kit is the "cave" lifting yard)
			node = GainlandsCave.mouth()
			node.position = Vector3(pos.x, GainlandsLayout.PLATEAU_Y, GainlandsLayout.CAVE_CLIFF.end.y + 0.3)
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


# ---- Lifting yards and power lines (Part D) -------------------------------------------------------------


func _build_yards() -> void:
	for yard: Dictionary in layout.yards:
		var centre: Vector2 = yard["center"] as Vector2
		var origin: Vector3 = Vector3(centre.x, layout.ground_height(centre.x, centre.y), centre.y)
		root.add_child(GainlandsGym.yard(yard["items"] as Array, origin, "Yard_%s" % str(yard["id"])))


func _build_power() -> void:
	var index: int = 0
	for stack: Vector4 in layout.stacks:
		index += 1
		root.add_child(GainlandsTerrain.rock(GainlandsTerrain.blob_outline(Vector2(stack.x, stack.y), Vector2(stack.z, stack.z), 8, float(index) * 2.9), stack.w, "PylonStack%d" % index))
	index = 0
	for line: Variant in layout.power_lines:
		index += 1
		var points: Array[Vector3] = []
		points.assign(line as Array)
		var towers: MeshInstance3D = GainlandsStructures.pylons(points)
		towers.name = "Pylons%d" % index
		root.add_child(towers)
		var wires: MeshInstance3D = GainlandsStructures.cables(points)
		wires.name = "Cables%d" % index
		root.add_child(wires)


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
	"sign.calf_cove": "ICON-ESSENCE-B", "sign.edge_warning": "ICON-NODE-ELITE", "sign.hamster_fact": "ICON-MAP-QUEST", "sign.record_board": "ICON-MAP-MINIGAME",
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
