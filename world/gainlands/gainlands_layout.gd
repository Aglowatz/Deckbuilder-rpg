class_name GainlandsLayout
extends RefCounted
## The Gainlands' map as plain data (no scene nodes), so it can be unit-tested headless: the sandstone plateau, the fortress mesa, the canyons and the
## bridges across them, the floating islands, named anchors, hidden chests, enemy homes, props, signs, routes and named areas. `GainlandsBuilder` turns it
## into meshes; `GainlandsScene` makes it playable.
##
## Coordinates: metres, x east, z south, y up. Gainlands v2 (docs/art/gainlands_v2.md): the land is a sandstone plateau PLATEAU_Y above the sea, made of
## flat-topped land polygons that meet edge to edge (LAND: the south lands with the plaza, the left and right lands and the middle ridge; the forecourt; the
## fortress mesa MESA_Y high). The canyons are the gaps between them (water below), crossed by stone bridges (SPANS); the mesa is reached by the STAIRS.
## The rope bridge from town arrives at the south rim. Three routes leave the plaza: the middle road along the ridge to the stairs (guarded), the left road
## through the mill lands past the Iron Cave, the right road through the markets to the Swolympus overlook; both side roads loop to the forecourt.
## The islands hover OUTSIDE the land (so 2D walkability is unambiguous), high above it, and are only reachable by thrower or portal (`GainlandsTravel`).

## The plateau top (the plaza, the paths) and the fortress mesa, in metres above the look rig's sea plane (WorldScenery.WATER_Y -0.36).
const PLATEAU_Y: float = 4.0
const MESA_Y: float = 7.6
## How far past an island's edge the player can still step before falling (metres).
const FALL_MARGIN: float = 0.9
## The lowest walkable ground: the plateau dips no more than this (well above the sea in the canyons).
const MIN_GROUND: float = PLATEAU_Y - 0.4
## Rough extents of the land (for loops over the map and the clouds).
const CENTER: Vector2 = Vector2(56.0, 42.0)
const RADII: Vector2 = Vector2(56.0, 50.0)
## The hero stops this far from any drop (a cliff, a canyon, the foot of the mesa).
const EDGE_STOP: float = 0.35
## Trees: a few hardy, wind-bent ones and cypress accents (Gainlands v2, Part D: gym equipment is the decoration now).
const TREE_COUNT: int = 16
const ROCK_COUNT: int = 22
## Main walking routes are at least this wide (metres; the hero is about 0.7 m across, the brief asks for 4 hero-widths).
const MAIN_PATH_WIDTH: float = 4.6
const SIDE_PATH_WIDTH: float = 3.6
## The middle road (the most direct way to the fortress) is the widest.
const MIDDLE_PATH_WIDTH: float = 5.2
## Nothing solid stands closer than this to a path edge.
const PATH_CLEARANCE: float = 2.4
## The region landmarks kept from the removed sub-areas (SR-8): the Wheel in the mill lands, the Champions Arch in the left lands' north, the Sky Tree on its own
## islet high beyond the north-west (a view, never walked). Nothing solid stands within their clearance.
const HERO_WHEEL: Vector2 = Vector2(30.0, 44.0)
const HERO_WHEEL_CLEARANCE: float = 6.5
const CHAMPIONS_ARCH: Vector2 = Vector2(32.0, 33.0)
const CHAMPIONS_ARCH_CLEARANCE: float = 7.5
const SKY_TREE: Vector3 = Vector3(-6.0, 22.0, -30.0)
## The hub plaza: open ground this far round the "hub" anchor; props, signs and dressing stand on its rim or beyond (GC-7).
const PLAZA_RADIUS: float = 8.5

## The way in from town (GC-8): a timber-and-rope bridge from the plateau's south rim out over the water to the town side. The hero arrives at its far end and
## walks across into the zone; walking off the far end leaves for town. Deck BRIDGE_HALF_WIDTH either side of x = BRIDGE_X, from z BRIDGE_Z0 (on the rim) to BRIDGE_Z1.
const BRIDGE_X: float = 56.0
const BRIDGE_HALF_WIDTH: float = 2.3
const BRIDGE_Z0: float = 86.5
const BRIDGE_Z1: float = 106.0
## The deck arches up this much in the middle.
const BRIDGE_RISE: float = 0.55
## The rails: the walkable deck is the half width minus this.
const BRIDGE_RAIL: float = 0.3
## The House of Gains (GC-10): the fortress-gym stands on its own rock behind the mesa, its gate facing the mesa top (the dungeon entrance spot).
const HOUSE_OF_GAINS: Vector2 = Vector2(56.0, -20.0)
const HOUSE_OF_GAINS_SIZE: Vector3 = Vector3(40.0, 34.0, 26.0)
## The wide stairs from the forecourt up the mesa's south face (x, z, w, d: the top step at z, the foot at z + d).
const STAIRS: Rect2 = Rect2(50.0, 9.0, 12.0, 8.0)
## The gym hall in the plaza (Part C): a solid block the plaza's lanes go round (x, z, w, d).
const GYM_HALL: Rect2 = Rect2(49.5, 58.25, 13.0, 8.5)

enum Surface { VOID, GROUND, ISLAND, RIM, BRIDGE }

## The land: [points, level] with level 1 = the plateau, 2 = the mesa. Polygons meet edge to edge (shared vertices), never overlap; the canyons are the gaps.
const SOUTH: Array[Vector2] = [
	Vector2(60, 88), Vector2(65, 87.5), Vector2(72, 86), Vector2(80, 87), Vector2(88, 86), Vector2(97, 83), Vector2(104, 78), Vector2(108, 70), Vector2(106, 62),
	Vector2(109, 54), Vector2(106, 46), Vector2(107, 38), Vector2(105, 31), Vector2(108, 25), Vector2(106, 17), Vector2(101, 13), Vector2(95, 10), Vector2(86, 9),
	Vector2(79, 11), Vector2(75, 15), Vector2(74.5, 24), Vector2(72, 31), Vector2(68, 38), Vector2(67, 46), Vector2(66, 52), Vector2(64, 54.5), Vector2(61, 54),
	# the ridge's east side, north to the forecourt: rocky narrows at z 47, 37.5 and 28 where the road guards stand (Part G)
	Vector2(61, 50), Vector2(59.4, 47), Vector2(61, 44), Vector2(61, 40), Vector2(59.2, 37.5), Vector2(61, 35), Vector2(61, 31), Vector2(59.4, 28), Vector2(61, 25),
	Vector2(61, 22), Vector2(51, 22),
	Vector2(51, 25), Vector2(52.6, 28), Vector2(51, 31), Vector2(51, 35), Vector2(52.8, 37.5), Vector2(51, 40), Vector2(51, 44), Vector2(52.6, 47), Vector2(51, 50),
	Vector2(51, 54), Vector2(48, 54.5), Vector2(46, 52), Vector2(45, 46), Vector2(44, 38), Vector2(42, 31), Vector2(38, 24), Vector2(37.5, 15), Vector2(33, 11),
	Vector2(27, 15), Vector2(22, 20.5), Vector2(12, 20.5), Vector2(6, 22), Vector2(5, 29), Vector2(7, 37), Vector2(4, 44), Vector2(3, 53), Vector2(6, 61),
	Vector2(5, 69), Vector2(9, 77), Vector2(16, 82), Vector2(24, 85), Vector2(32, 87), Vector2(39, 86), Vector2(46, 87.5), Vector2(52, 88),
]
const FORECOURT: Array[Vector2] = [Vector2(42, 14), Vector2(70, 14), Vector2(70, 22), Vector2(61, 22), Vector2(51, 22), Vector2(42, 22)]
const MESA: Array[Vector2] = [Vector2(40, -6.5), Vector2(72, -6.5), Vector2(72, 14), Vector2(70, 14), Vector2(42, 14), Vector2(40, 14)]
## Stone bridges across the canyons (x, z, w, d): the left lands and the right lands to the forecourt. Walkable between their parapets, flat at PLATEAU_Y.
const SPANS: Array[Rect2] = [Rect2(36.0, 15.5, 7.0, 5.0), Rect2(69.0, 15.5, 7.5, 5.0)]
const SPAN_RAIL: float = 0.4
## The rocky narrows of the middle road (x, z): where its three guards stand (Part G).
const NARROWS: Array[Vector2] = [Vector2(56, 47), Vector2(56, 37.5), Vector2(56, 28)]
## Rock that rises out of the sea next to the land (not walkable): the Iron Cave's cliff in the north-west (x, z, w, d, top height) and the fortress rock.
const CAVE_CLIFF: Rect2 = Rect2(3.0, 1.0, 25.0, 19.5)
const CAVE_CLIFF_TOP: float = 13.5


class Island:
	extends RefCounted
	var id: String = ""
	var title: String = ""
	var center: Vector2 = Vector2.ZERO
	var radius: float = 7.0
	var height: float = 10.0


class Prop:
	extends RefCounted
	## "mill", "wheel", "bench_press", "log_rack", "dumbbell_rack", "boulder", "tree", "hut", "stage", "tub", "stall", "mirror", "pylon", "crystal", "cavern"
	var kind: String = ""
	var pos: Vector3 = Vector3.ZERO
	var yaw: float = 0.0
	var model_scale: float = 1.0
	## Blocks movement within this radius (0 = decoration only).
	var radius: float = 0.0
	var variant: int = 0


class Sign:
	extends RefCounted
	var key: String = ""
	var pos: Vector3 = Vector3.ZERO
	## 180 = the front faces the camera (south); other values turn it away.
	var yaw: float = 0.0
	var size: float = 1.0
	## "sign" (post sign), "poster" (framed), "memo" (small note).
	var style: String = "sign"


class Area:
	extends RefCounted
	var id: String = ""
	var title: String = ""
	var center: Vector2 = Vector2.ZERO
	var radius: float = 10.0


var islands: Array[Island] = []
var props: Array[Prop] = []
var signs: Array[Sign] = []
var areas: Array[Area] = []
## Named world positions (xz meaningful; y is 0 here, the builder adds the ground height).
var anchors: Dictionary = {}
## [{type, home, patrol, id?, guard?, escorts?}] for the enemies (guards stand in the middle road, Part G).
var enemy_spawns: Array[Dictionary] = []
## Hidden chest positions by id (never on the map).
var chests: Dictionary = {}
## Energy pipes: polylines of Vector2 (xz), laid on the terrain.
var pipes: Array[PackedVector2Array] = []
## Paved routes: [{line, width, route}] with route "middle", "left", "right", "plaza" or "spur".
var paths: Array[Dictionary] = []
## Spots where the terrain is levelled flat: [Vector3(x, z, radius)].
var flat_spots: Array[Vector3] = []
## Axis-aligned solid rectangles (x, z, w, d): the gym hall and other buildings with straight walls.
var blocker_rects: Array[Rect2] = []
## The lifting yards (Part D): [{id, center, size, items: [{kind, pos, yaw, radius}]}]; every item is also a solid "gym:<kind>" prop.
var yards: Array[Dictionary] = []
## The power lines (Part D): each an Array[Vector3] of tower bases (x, base height, z) in cable order; the towers stand on sandstone stacks off the
## walkable land (in the sea by the rims, in the canyons, on the Iron Cave's cliff), so they never block a route.
var power_lines: Array = []
## The sandstone stacks the towers stand on: Vector4(x, z, radius, top height).
var stacks: Array[Vector4] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func build() -> void:
	_rng.seed = 5150
	_islands()
	_anchors()
	_chests()
	_enemies()
	_areas()
	_paths_and_pipes()
	_flat_spots()
	_features()
	_signs()
	_scatter()


# ---- Land ------------------------------------------------------------------------------------------


static var _polygons: Array[PackedVector2Array] = []
static var _levels: PackedInt32Array = PackedInt32Array()
## The edge-distance raster: metres from each cell centre to the nearest place where the level changes (a drop or the mesa's foot), 0 off the land.
const GRID_ORIGIN: Vector2 = Vector2(-2.0, -10.0)
const GRID_CELL: float = 0.5
const GRID_W: int = 236
const GRID_H: int = 204
static var _edge: PackedFloat32Array = PackedFloat32Array()


## The land polygons and their levels (built once).
static func land_polygons() -> Array[PackedVector2Array]:
	if _polygons.is_empty():
		for entry: Array in [[SOUTH, 1], [FORECOURT, 1], [MESA, 2]]:
			var points: PackedVector2Array = PackedVector2Array()
			for point: Vector2 in (entry[0] as Array):
				points.append(point)
			_polygons.append(points)
			_levels.append(int(entry[1]))
	return _polygons


static func land_level(index: int) -> int:
	land_polygons()
	return _levels[index]


## 0 off the land, 1 on the plateau, 2 on the fortress mesa.
static func level_at(x: float, z: float) -> int:
	var polygons: Array[PackedVector2Array] = land_polygons()
	var p: Vector2 = Vector2(x, z)
	for index: int in range(polygons.size()):
		if Geometry2D.is_point_in_polygon(p, polygons[index]):
			return _levels[index]
	return 0


static func is_main_ground(x: float, z: float) -> bool:
	return level_at(x, z) > 0


static func _ensure_edge() -> void:
	if not _edge.is_empty():
		return
	var levels: PackedInt32Array = PackedInt32Array()
	levels.resize(GRID_W * GRID_H)
	for row: int in range(GRID_H):
		for col: int in range(GRID_W):
			levels[row * GRID_W + col] = level_at(GRID_ORIGIN.x + (float(col) + 0.5) * GRID_CELL, GRID_ORIGIN.y + (float(row) + 0.5) * GRID_CELL)
	var big: float = 1e6
	_edge.resize(GRID_W * GRID_H)
	for row: int in range(GRID_H):
		for col: int in range(GRID_W):
			var i: int = row * GRID_W + col
			var level: int = levels[i]
			if level == 0:
				_edge[i] = 0.0
				continue
			var border: bool = col == 0 or row == 0 or col == GRID_W - 1 or row == GRID_H - 1
			if not border:
				border = levels[i - 1] != level or levels[i + 1] != level or levels[i - GRID_W] != level or levels[i + GRID_W] != level
			_edge[i] = GRID_CELL * 0.5 if border else big
	# two-pass chamfer distance (1, sqrt 2) in cell units
	var diagonal: float = GRID_CELL * 1.41421
	for row: int in range(GRID_H):
		for col: int in range(GRID_W):
			var i: int = row * GRID_W + col
			var d: float = _edge[i]
			if d == 0.0:
				continue
			if col > 0:
				d = minf(d, _edge[i - 1] + GRID_CELL)
			if row > 0:
				d = minf(d, _edge[i - GRID_W] + GRID_CELL)
				if col > 0:
					d = minf(d, _edge[i - GRID_W - 1] + diagonal)
				if col < GRID_W - 1:
					d = minf(d, _edge[i - GRID_W + 1] + diagonal)
			_edge[i] = d
	for row: int in range(GRID_H - 1, -1, -1):
		for col: int in range(GRID_W - 1, -1, -1):
			var i: int = row * GRID_W + col
			var d: float = _edge[i]
			if d == 0.0:
				continue
			if col < GRID_W - 1:
				d = minf(d, _edge[i + 1] + GRID_CELL)
			if row < GRID_H - 1:
				d = minf(d, _edge[i + GRID_W] + GRID_CELL)
				if col < GRID_W - 1:
					d = minf(d, _edge[i + GRID_W + 1] + diagonal)
				if col > 0:
					d = minf(d, _edge[i + GRID_W - 1] + diagonal)
			_edge[i] = d


## Metres from the nearest drop or level change (positive on the land, negative off it).
static func main_edge_distance(x: float, z: float) -> float:
	if not is_main_ground(x, z):
		return -1.0
	_ensure_edge()
	var gx: float = (x - GRID_ORIGIN.x) / GRID_CELL - 0.5
	var gz: float = (z - GRID_ORIGIN.y) / GRID_CELL - 0.5
	var col: int = clampi(int(floorf(gx)), 0, GRID_W - 2)
	var row: int = clampi(int(floorf(gz)), 0, GRID_H - 2)
	var fx: float = clampf(gx - float(col), 0.0, 1.0)
	var fz: float = clampf(gz - float(row), 0.0, 1.0)
	var i: int = row * GRID_W + col
	var top: float = lerpf(_edge[i], _edge[i + 1], fx)
	var bottom: float = lerpf(_edge[i + GRID_W], _edge[i + GRID_W + 1], fx)
	return maxf(lerpf(top, bottom, fz) - GRID_CELL * 0.5, 0.0)


func island_at(x: float, z: float) -> Island:
	for island: Island in islands:
		if Vector2(x - island.center.x, z - island.center.y).length() <= island.radius + FALL_MARGIN:
			return island
	return null


## True on the bridge deck from town (rails included); the bridge overlaps the rim so the walk from the plateau to planks is seamless.
static func on_bridge(x: float, z: float) -> bool:
	return absf(x - BRIDGE_X) <= BRIDGE_HALF_WIDTH and z >= BRIDGE_Z0 and z <= BRIDGE_Z1


## The deck's height at z: a gentle arch from the rim to the far landing.
static func bridge_height(z: float) -> float:
	var t: float = clampf((z - BRIDGE_Z0) / (BRIDGE_Z1 - BRIDGE_Z0), 0.0, 1.0)
	return PLATEAU_Y + 0.05 + BRIDGE_RISE * sin(PI * t)


## The stone span (index into SPANS) under (x, z), or -1.
static func span_at(x: float, z: float) -> int:
	for index: int in range(SPANS.size()):
		if SPANS[index].has_point(Vector2(x, z)):
			return index
	return -1


static func on_stairs(x: float, z: float) -> bool:
	return STAIRS.has_point(Vector2(x, z))


## The stairs' walking height: the mesa top at the top step, the forecourt at the foot.
static func stairs_height(z: float) -> float:
	var t: float = clampf((z - STAIRS.position.y - 0.6) / (STAIRS.size.y - 1.2), 0.0, 1.0)
	return lerpf(MESA_Y, PLATEAU_Y, t)


## What is under (x, z): the bridge from town or a stone span (BRIDGE), the land (GROUND, the stairs included), an island's top, the unfenced rim just
## past an island's edge (stepping there means falling), or nothing.
func surface_at(x: float, z: float) -> Surface:
	if on_bridge(x, z) or span_at(x, z) >= 0:
		return Surface.BRIDGE
	if on_stairs(x, z) or is_main_ground(x, z):
		return Surface.GROUND
	var island: Island = island_at(x, z)
	if island == null:
		return Surface.VOID
	var distance: float = Vector2(x - island.center.x, z - island.center.y).length()
	return Surface.ISLAND if distance <= island.radius else Surface.RIM


## The sandstone plateau: level, with a low rugged swell (flattened under the paved routes and the flat spots), the mesa flat on top, the stairs and spans as built.
func ground_height(x: float, z: float) -> float:
	if on_bridge(x, z):
		return bridge_height(z)
	if on_stairs(x, z):
		return stairs_height(z)
	if span_at(x, z) >= 0:
		return PLATEAU_Y + 0.05
	var level: int = level_at(x, z)
	if level == 0:
		var island: Island = island_at(x, z)
		if island != null:
			return island.height
		return PLATEAU_Y
	if level == 2:
		return MESA_Y
	var swell: float = 0.32 * sin(x * 0.13 + 0.7) * cos(z * 0.11 + 0.3) + 0.14 * sin(x * 0.31 + z * 0.17 + 1.0)
	# the Swolympus overlook rises a little above the market lands
	var overlook: float = 0.9 * (1.0 - smoothstep(4.0, 11.0, Vector2(x - 103.0, z - 21.0).length()))
	var flat: float = 1.0 - path_weight(x, z)
	for spot: Vector3 in flat_spots:
		var distance: float = Vector2(x - spot.x, z - spot.y).length()
		flat = minf(flat, smoothstep(spot.z * 0.7, spot.z * 1.3, distance))
	return PLATEAU_Y + maxf(swell * flat + overlook, MIN_GROUND - PLATEAU_Y)


func area_at(x: float, z: float) -> Area:
	var best: Area = null
	for area: Area in areas:
		if Vector2(x - area.center.x, z - area.center.y).length() <= area.radius:
			if best == null or area.radius < best.radius:
				best = area
	return best


## The route segments bucketed by PATH_CELL cells (each segment in every cell its band touches), so the path queries look at a handful of segments.
const PATH_CELL: float = 8.0
## Beyond this many metres from every path edge the queries just say "far" (FAR_FROM_PATHS).
const FAR_FROM_PATHS: float = 99.0
var _segments: Dictionary = {}


func _index_paths() -> void:
	_segments.clear()
	for path: Dictionary in paths:
		var line: PackedVector2Array = path["line"] as PackedVector2Array
		var half: float = float(path["width"]) * 0.5
		for i: int in range(line.size() - 1):
			var a: Vector2 = line[i]
			var b: Vector2 = line[i + 1]
			var box: Rect2 = Rect2(a, Vector2.ZERO).expand(b).grow(half + 0.1)
			for cz: int in range(int(floorf(box.position.y / PATH_CELL)), int(floorf(box.end.y / PATH_CELL)) + 1):
				for cx: int in range(int(floorf(box.position.x / PATH_CELL)), int(floorf(box.end.x / PATH_CELL)) + 1):
					var key: Vector2i = Vector2i(cx, cz)
					if not _segments.has(key):
						_segments[key] = []
					(_segments[key] as Array).append([a, b, half])


func path_weight(x: float, z: float) -> float:
	var best: float = 0.0
	var key: Vector2i = Vector2i(int(floorf(x / PATH_CELL)), int(floorf(z / PATH_CELL)))
	for segment: Variant in _segments.get(key, []) as Array:
		var data: Array = segment as Array
		var half: float = float(data[2])
		var closest: Vector2 = Geometry2D.get_closest_point_to_segment(Vector2(x, z), data[0] as Vector2, data[1] as Vector2)
		best = maxf(best, 1.0 - smoothstep(half * 0.85, half * 1.05, closest.distance_to(Vector2(x, z))))
	return best


## Metres from the nearest path EDGE (negative on the path itself, positive beside it): nothing solid inside PATH_CLEARANCE. Far from every path: FAR_FROM_PATHS.
func path_edge_distance(x: float, z: float) -> float:
	var best: float = FAR_FROM_PATHS
	var key: Vector2i = Vector2i(int(floorf(x / PATH_CELL)), int(floorf(z / PATH_CELL)))
	for dz: int in range(-1, 2):
		for dx: int in range(-1, 2):
			for segment: Variant in _segments.get(key + Vector2i(dx, dz), []) as Array:
				var data: Array = segment as Array
				var closest: Vector2 = Geometry2D.get_closest_point_to_segment(Vector2(x, z), data[0] as Vector2, data[1] as Vector2)
				best = minf(best, closest.distance_to(Vector2(x, z)) - float(data[2]))
	return best


## The routes' polylines by name ("middle", "left", "right"), for the tests and the walk smoke.
func route(route_name: String) -> PackedVector2Array:
	var result: PackedVector2Array = PackedVector2Array()
	for path: Dictionary in paths:
		if str(path.get("route", "")) == route_name:
			for point: Vector2 in (path["line"] as PackedVector2Array):
				if result.is_empty() or result[result.size() - 1] != point:
					result.append(point)
	return result


# ---- Islands, anchors, chests, enemies --------------------------------------------------------


func _island(id: String, title: String, center: Vector2, radius: float, height: float) -> void:
	var island: Island = Island.new()
	island.id = id
	island.title = title
	island.center = center
	island.radius = radius
	island.height = height
	islands.append(island)


func _islands() -> void:
	_island("pec", "Pec Perch", Vector2(-14.0, 0.0), 8.0, PLATEAU_Y + 8.0)
	_island("delt", "Delt Deck", Vector2(100.0, -10.0), 7.0, PLATEAU_Y + 10.0)
	_island("glute", "Glute Garden", Vector2(124.0, 68.0), 7.0, PLATEAU_Y + 6.0)
	_island("calf", "Calf Cove", Vector2(-15.0, 58.0), 6.5, PLATEAU_Y + 4.0)


func _at(name: String, x: float, z: float) -> void:
	anchors[name] = Vector3(x, 0.0, z)


## An anchor on an island, `offset` from its centre.
func _on_island(name: String, island_id: String, dx: float, dz: float) -> void:
	for island: Island in islands:
		if island.id == island_id:
			_at(name, island.center.x + dx, island.center.y + dz)


func _anchors() -> void:
	# The plaza (The Swole Station): the hero arrives on the bridge from town (GC-8) and walks north through the stone gateway into an open square; the gym
	# hall (GYM_HALL) fills its north half and the three routes leave round it. Everything that matters stands on the square's edges, facing it: the Rift
	# Station portal and the mirror west, Benchley's and the tub east, the hermit at the start of the left road.
	_at("spawn", BRIDGE_X, BRIDGE_Z1 - 6.0)
	_at("exit", BRIDGE_X, BRIDGE_Z1 - 2.0)
	_at("hub", 56.0, 77.0)
	_at("rift_station", 42.0, 75.0)
	_at("flex_mirror", 43.0, 83.0)
	_at("heal", 68.0, 76.5)
	_at("tony", 69.0, 71.0)
	_at("brenda", 44.0, 69.0)
	_at("station", 56.0, 71.5)  # the gym hall's open front (Part C)
	# Left lands: the mill lands (tall windmills, the Hero Wheel, Professor Pump's lecture log), the Iron Cave in the north-west cliff, the Champions Arch and
	# the Pump Shrine on the north rim, the throwers west and north.
	_at("quiz", 22.0, 68.0)
	_at("giant_chest", 14.0, 72.0)  # Brief 16: Shiro Swindle's giant chest, beside the west lifting yard ("a giant chest next to a gym")
	_at("thrower_west", 9.0, 47.0)
	_at("land_west", 12.0, 54.0)
	_at("land_calf", 11.0, 60.0)
	_at("mini_dungeon", 15.0, 24.5)  # the Iron Cave's mouth in the north-west cliff (Part F)
	_at("shrine", 36.5, 28.5)  # the Pump Shrine beside the Champions Arch (SR-7): the hero stands here, the shrine itself is just north
	_at("thrower_pec", 31.0, 19.5)
	_at("land_pec", 28.0, 23.0)
	# Right lands: the market row (Benchley's stalls, the protein stand, Chet's studio), the lifting yard right of the entrance (Gary), the wheel works
	# (Gus, the power grid, the colossal wheel), the east thrower, the Delt ripper, the Swolympus overlook in the north-east.
	_at("protein_stand", 80.0, 70.0)
	_at("minigame", 90.0, 72.0)
	_at("spot_me", 78.0, 80.5)
	_at("gus", 89.0, 55.0)
	_at("puzzle", 93.0, 45.0)
	_at("run_wheel", 99.0, 41.5)
	_at("thrower_east", 101.0, 63.0)
	_at("land_east", 97.0, 67.0)
	_at("land_glute", 98.5, 58.5)
	_at("ripper_delt", 88.0, 18.0)
	_at("land_delt", 93.0, 22.0)
	_at("swolympus_gate", 103.0, 22.0)  # the locked trailhead gate at the overlook, where the ridge to Mount Swolympus starts (SR-4, Part F)
	_at("vault_lever", 104.5, 48.5)  # Brief 16: the hidden vault lever behind the farthest weight racks, on the east rim
	# The House of Gains gate on the mesa top, in front of the fortress doors (GC-10).
	_at("main_dungeon", 56.0, -3.5)
	# The islands (throw or portal only).
	_on_island("arrive_pec", "pec", -1.0, -2.0)
	_on_island("thrower_pec_back", "pec", 3.0, 3.0)
	_on_island("flex_mirror_pec", "pec", -4.0, 2.0)
	_on_island("ripper_calf", "pec", -4.0, -4.0)
	_on_island("arrive_delt", "delt", 1.0, -1.0)
	_on_island("ripper_delt_back", "delt", -2.0, 3.0)
	_on_island("thrower_glute", "delt", 4.0, 2.0)
	_on_island("arrive_glute", "glute", -3.0, -2.0)
	_on_island("thrower_glute_back", "glute", -2.0, 3.0)
	_on_island("arrive_calf", "calf", 2.0, -1.0)
	_on_island("ripper_calf_back", "calf", 3.0, 3.0)


func _island_point(island_id: String, dx: float, dz: float) -> Vector3:
	for island: Island in islands:
		if island.id == island_id:
			return Vector3(island.center.x + dx, 0.0, island.center.y + dz)
	return Vector3.ZERO


func _chests() -> void:
	# Side paths carry the loot (brief): two in the left lands' pockets, two in the right lands', one on the mesa beside the fortress; the rest on the islands.
	chests = {
		"chest_ground_0": Vector3(9.5, 0.0, 64.0),
		"chest_ground_1": Vector3(104.5, 0.0, 68.5),
		"chest_ground_2": Vector3(43.0, 0.0, -4.0),
		"chest_ground_3": Vector3(97.5, 0.0, 13.5),
		"chest_ground_4": Vector3(33.0, 0.0, 15.5),
		"chest_pec": _island_point("pec", -6.2, -1.0),
		"chest_delt": _island_point("delt", 5.0, -3.0),
		"chest_glute": _island_point("glute", 4.0, 2.0),
		"chest_calf": _island_point("calf", -4.0, 2.0),
		# Polish round: a second chest on each floating island (throw or portal only).
		"chest_pec_2": _island_point("pec", 5.0, -2.9),
		"chest_delt_2": _island_point("delt", -4.8, -2.5),
		"chest_glute_2": _island_point("glute", 1.5, -5.4),
		"chest_calf_2": _island_point("calf", -2.8, -4.5),
	}


## The middle road's guards (Part G): one group at each of the ridge's rocky narrows, standing in the road; a guard's challenge circle spans the narrows, so
## the only way along the ridge is through them. GUARD_RADIUS is centre to centre (the hero's body is inside it before the battle starts).
const GUARD_RADIUS: float = 3.6


func _enemies() -> void:
	enemy_spawns = [
		# the middle road: three guard groups, about 9.5 m apart (zone HP does not heal between battles: a brute, a golem, then a brute with two training partners)
		{"type": "brute", "home": Vector3(NARROWS[0].x, 0.0, NARROWS[0].y), "patrol": 0.0, "id": "guard_mid_1", "guard": GUARD_RADIUS, "escorts": 2},
		{"type": "golem", "home": Vector3(NARROWS[1].x, 0.0, NARROWS[1].y), "patrol": 0.0, "id": "guard_mid_2", "guard": GUARD_RADIUS, "escorts": 1},
		{"type": "brute", "home": Vector3(NARROWS[2].x, 0.0, NARROWS[2].y), "patrol": 0.0, "id": "guard_mid_3", "guard": GUARD_RADIUS, "escorts": 2},
		# the side roads: optional roamers off the road (they can be walked round)
		{"type": "golem", "home": Vector3(33.0, 0.0, 52.0), "patrol": 3.5},
		{"type": "sprite", "home": Vector3(22.0, 0.0, 34.0), "patrol": 5.0},
		{"type": "brute", "home": Vector3(84.0, 0.0, 40.0), "patrol": 4.0},
		{"type": "sprite", "home": Vector3(94.0, 0.0, 31.0), "patrol": 5.0},
	]


func _area(id: String, title: String, x: float, z: float, radius: float) -> void:
	var area: Area = Area.new()
	area.id = id
	area.title = title
	area.center = Vector2(x, z)
	area.radius = radius
	areas.append(area)


func _areas() -> void:
	_area("hub", "The Swole Station", 56.0, 75.0, 15.0)
	_area("mills", "Mill Mesa", 22.0, 52.0, 20.0)
	_area("cave", "The Iron Cliffs", 18.0, 26.0, 10.0)
	_area("market", "Market Row", 84.0, 68.0, 13.0)
	_area("wheels", "The Wheel Works", 96.0, 44.0, 13.0)
	_area("overlook", "Swolympus Overlook", 102.0, 20.0, 9.0)
	_area("north", "The Gauntlet", 56.0, 38.0, 11.0)
	_area("steps", "The House of Gains Steps", 56.0, 8.0, 14.0)
	_area("field", "The Gainlands", 56.0, 42.0, 90.0)
	for island: Island in islands:
		_area("island_" + island.id, island.title, island.center.x, island.center.y, island.radius + 1.0)


func _path(points: Array[Vector2], width: float, route_name: String) -> void:
	paths.append({"line": PackedVector2Array(points), "width": width, "route": route_name})


func _paths_and_pipes() -> void:
	# The plaza: from the bridge head to the square, and two lanes round the gym hall that meet behind it at the foot of the middle road.
	_path([Vector2(56, 88), Vector2(56, 72)], MIDDLE_PATH_WIDTH, "plaza")
	_path([Vector2(56, 72), Vector2(46.5, 70), Vector2(45.5, 57.5), Vector2(51, 55.6), Vector2(56, 55.6)], MAIN_PATH_WIDTH, "middle")
	_path([Vector2(56, 72), Vector2(65.5, 70), Vector2(66.2, 57.5), Vector2(61, 55.6), Vector2(56, 55.6)], MAIN_PATH_WIDTH, "plaza")
	# MIDDLE: straight along the ridge to the forecourt and up the stairs to the gate (the most direct way; its guards stand in the narrows).
	_path([Vector2(56, 55.6), Vector2(56, 22), Vector2(56, 17), Vector2(56, 9), Vector2(56, -2.5)], MIDDLE_PATH_WIDTH, "middle")
	# LEFT: west through the mill lands, north past the Iron Cave, east along the north rim, over the west canyon to the forecourt.
	_path([Vector2(45.5, 62), Vector2(36, 60), Vector2(26, 57), Vector2(17, 50), Vector2(15, 40), Vector2(18, 31), Vector2(25, 26), Vector2(31, 23.5),
		Vector2(36, 18), Vector2(43, 18), Vector2(50, 18)], MAIN_PATH_WIDTH, "left")
	# RIGHT: east through the market row, north through the wheel works to the Swolympus overlook, west along the north rim, over the east canyon.
	_path([Vector2(66.5, 62), Vector2(76, 64.5), Vector2(86, 63), Vector2(93, 55), Vector2(96.5, 46), Vector2(99, 36.5), Vector2(101, 27), Vector2(95, 20.5),
		Vector2(86, 15.5), Vector2(76, 18), Vector2(69, 18), Vector2(62, 18)], MAIN_PATH_WIDTH, "right")
	# spurs: the Iron Cave, the overlook, the west thrower, the lifting yard right of the entrance, the studio, the north throwers
	_path([Vector2(18, 31), Vector2(15.3, 26.8)], SIDE_PATH_WIDTH, "spur")
	_path([Vector2(101, 27), Vector2(103, 23)], SIDE_PATH_WIDTH, "spur")
	_path([Vector2(17, 50), Vector2(10, 48.5)], SIDE_PATH_WIDTH, "spur")
	_path([Vector2(60, 84), Vector2(71, 82)], SIDE_PATH_WIDTH, "spur")
	_path([Vector2(86, 63), Vector2(90, 69)], SIDE_PATH_WIDTH, "spur")
	_path([Vector2(31, 23.5), Vector2(31, 20.5)], SIDE_PATH_WIDTH, "spur")
	_path([Vector2(86, 15.5), Vector2(88, 17.5)], SIDE_PATH_WIDTH, "spur")
	_index_paths()
	# the energy pipes of the power grid: from the colossal wheel to the grid panel and on to Gus's yard
	pipes = [
		PackedVector2Array([Vector2(103.5, 40.0), Vector2(103.0, 45.0), Vector2(98.0, 49.0), Vector2(95.0, 49.5)]),
		PackedVector2Array([Vector2(95.0, 49.5), Vector2(92.0, 52.0), Vector2(86.0, 52.5)]),
	]


func _flat_spots() -> void:
	flat_spots = [
		Vector3(56.0, 76.0, 13.0), Vector3(GYM_HALL.get_center().x, GYM_HALL.get_center().y, 8.0), Vector3(22.0, 68.0, 4.5), Vector3(90.0, 72.0, 5.5),
		Vector3(78.0, 80.5, 6.0), Vector3(93.0, 45.0, 4.0), Vector3(99.0, 38.0, 6.5), Vector3(15.0, 24.5, 4.5), Vector3(9.0, 47.0, 3.5), Vector3(101.0, 63.0, 3.5),
		Vector3(88.0, 18.0, 3.5), Vector3(31.0, 19.5, 3.5), Vector3(80.0, 70.0, 4.0), Vector3(12.0, 72.0, 5.0), Vector3(89.0, 55.0, 4.0),
		Vector3(HERO_WHEEL.x, HERO_WHEEL.y, 5.5), Vector3(CHAMPIONS_ARCH.x, CHAMPIONS_ARCH.y, 6.0), Vector3(36.5, 27.0, 3.5),
	]


# ---- Props -----------------------------------------------------------------------------------


func _prop(kind: String, x: float, z: float, yaw: float = 0.0, model_scale: float = 1.0, radius: float = 0.0, variant: int = 0) -> void:
	var prop: Prop = Prop.new()
	prop.kind = kind
	prop.pos = Vector3(x, 0.0, z)
	prop.yaw = yaw
	prop.model_scale = model_scale
	prop.radius = radius
	prop.variant = variant
	props.append(prop)


func _features() -> void:
	blocker_rects = [GYM_HALL]
	# The plaza edges: the hot tub and Benchley's stall east, the mirror west.
	_prop("tub", 68.0, 76.5, 0.0, 1.0, 1.7)
	_prop("stall", 72.5, 71.5, 250.0, 1.0, 1.4)
	_prop("mirror", 41.5, 82.5, 90.0, 1.0, 0.7)
	# The market row (right road): stalls along its north kerb, the protein stand's stall.
	_prop("stall", 80.0, 73.0, 180.0, 0.9, 1.2, 1)
	_prop("stall", 76.0, 57.5, 10.0, 1.0, 1.4)
	_prop("stall", 83.0, 56.5, -10.0, 1.0, 1.4, 1)
	_prop("stage", 90.0, 75.5, 180.0, 1.0, 2.2)
	# Tall windmills in the mill lands (Part D makes them proper multi-storey mills), their sails turning.
	_prop("mill", 36.0, 68.0, 20.0, 1.0, 3.2)
	_prop("mill", 39.0, 40.0, 200.0, 1.0, 3.2)
	_prop("mill", 30.0, 79.0, -30.0, 1.0, 3.2)
	_prop("hut", 22.0, 64.5, 0.0, 1.0, 1.5)
	# Colossal hamster wheels at the wheel works (the first one is the one you can run); the stands collide, the wheel itself is walk-through.
	_prop("wheel", 99.0, 37.0, 0.0, 1.0, 0.0, 0)
	_prop("wheel", 87.0, 33.0, 0.0, 0.85, 0.0, 1)
	_prop("wheel", 104.0, 56.0, 0.0, 0.75, 0.0, 2)
	for stand: Vector3 in [Vector3(99.0, 35.2, 0.7), Vector3(99.0, 38.8, 0.7), Vector3(87.0, 31.5, 0.6), Vector3(87.0, 34.5, 0.6), Vector3(104.0, 54.7, 0.55), Vector3(104.0, 57.3, 0.55)]:
		_prop("pylon", stand.x, stand.y, 0.0, 1.0, stand.z)
	# The Iron Cave mouth in the north-west cliff face (Part F builds the cave).
	_prop("cavern", 15.0, 21.3, 0.0, 1.0, 2.2)
	_yards()
	_power()
	# Island dressing: crystals, the mirror on Pec Perch.
	for crystal: Array in [["pec", -2.0, 0.0], ["delt", 2.0, 1.0], ["glute", -1.0, -1.0], ["calf", 1.0, 1.0]]:
		var at: Vector3 = _island_point(str(crystal[0]), float(crystal[1]), float(crystal[2]))
		_prop("crystal", at.x, at.z, 0.0, 1.0, 0.5)
	var mirror: Vector3 = _island_point("pec", -4.0, 3.3)
	_prop("mirror", mirror.x, mirror.z, 0.0, 1.0, 0.7)


func _sign(key: String, x: float, z: float, yaw: float = 0.0, size: float = 1.0, style: String = "sign") -> void:
	var sign: Sign = Sign.new()
	sign.key = key
	sign.pos = Vector3(x, 0.0, z)
	sign.yaw = 180.0 + clampf(yaw - 180.0, -12.0, 12.0)
	sign.size = size
	sign.style = style
	signs.append(sign)


## Corrective pass (GC-2): only boards that point somewhere or carry a quiz answer (hub_power, ripper_rule, main_dungeon), plus one poster.
func _signs() -> void:
	_sign("sign.hub_main", 47.0, 80.5, 170.0, 1.2)
	_sign("sign.hub_power", 46.0, 73.5, 170.0)
	_sign("sign.exit", 60.8, 86.0, 180.0)
	_sign("sign.vendor", 66.0, 73.5, 190.0)
	_sign("sign.ripper_rule", 84.5, 21.0, 190.0)
	_sign("sign.mini_dungeon", 19.5, 25.0, 180.0)
	_sign("sign.main_dungeon", 60.5, -2.5, 180.0, 1.4)
	_sign("sign.beefcake_poster", 63.8, 69.5, 170.0, 1.0, "poster")
	_sign("sign.record_board", 26.0, 36.5, 180.0)  # the Record Board of the old Proving Grounds, at the Champions Arch (SR-7)


## The lifting yards' ground (gym mat in the painted terrain): x, z, w, d.
func yard_rects() -> Array[Rect2]:
	var result: Array[Rect2] = []
	for yard: Dictionary in yards:
		var size: Vector2 = yard["size"] as Vector2
		result.append(Rect2((yard["center"] as Vector2) - size * 0.5, size))
	return result


## Yard presets: [kind, local x, local z, yaw, blocking radius]. Storybook scale (GainlandsGym); every solid piece blocks through its circle.
const YARD_PRESETS: Dictionary = {
	"lifting": {"size": Vector2(8.0, 5.0), "items": [["squat_rack", -2.4, -0.6, 0.0, 1.25], ["bench", 0.4, 0.4, 90.0, 0.75], ["dumbbell_rack", 2.5, -1.4, 0.0, 1.15], ["plate_stack", -3.3, 1.6, 0.0, 0.45], ["chalk_bucket", 1.7, 1.7, 0.0, 0.3]]},
	"strongman": {"size": Vector2(9.0, 6.0), "items": [["atlas_stones", -1.5, -1.8, 0.0, 1.8], ["tire_pair", 2.8, 0.8, 0.0, 1.4], ["sled_track", -1.0, 1.8, 0.0, 0.0], ["chalk_bucket", 3.8, -2.2, 0.0, 0.3]]},
	"rig": {"size": Vector2(7.0, 4.0), "items": [["pullup_frame", -1.6, -0.4, 0.0, 1.2], ["rope_station", 1.8, -0.6, 0.0, 0.8], ["kettlebell_rack", 1.0, 1.2, 0.0, 0.9], ["plate_stack", -3.0, 1.3, 0.0, 0.45]]},
}


## Gainlands v2, Part D: gym equipment is the decoration. Small yards at the path edges and in the side pockets (none on the middle road, where the fights
## are, none in the plaza: the gym hall is the plaza's gym), each on its own rubber mat; Gary's yard right of the entrance is the biggest.
func _yards() -> void:
	_yard("west_strongman", "strongman", Vector2(21.0, 76.0))
	_yard("west_rig", "rig", Vector2(36.0, 47.5))
	_yard("west_lifting", "lifting", Vector2(38.5, 53.0))
	_yard("east_strongman", "strongman", Vector2(100.0, 74.5))
	_yard("east_lifting", "lifting", Vector2(93.0, 79.5))
	_yard("east_rig", "rig", Vector2(78.0, 44.0))
	# Gary's yard, right of the entrance (the Boulder Gym): a full set round the spot where Gary lies under his bar
	var gary: Array = [
		["squat_rack", 74.5, 79.0, 0.0, 1.25], ["bench", 77.0, 83.6, 90.0, 0.75], ["dumbbell_rack", 74.6, 84.4, 0.0, 1.15], ["atlas_stones", 84.2, 78.6, 0.0, 1.8],
		["tire_pair", 85.0, 83.0, 0.0, 1.4], ["kettlebell_rack", 82.0, 77.4, 0.0, 0.9], ["plate_stack", 72.6, 77.0, 0.0, 0.45], ["chalk_bucket", 81.4, 84.6, 0.0, 0.3],
	]
	var items: Array = []
	for entry: Array in gary:
		items.append(_yard_item(str(entry[0]), Vector2(float(entry[1]), float(entry[2])), float(entry[3]), float(entry[4])))
	yards.append({"id": "gary", "center": Vector2(79.5, 81.0), "size": Vector2(15.0, 9.0), "items": items})


func _yard(id: String, preset: String, center: Vector2, yaw: float = 0.0) -> void:
	var data: Dictionary = YARD_PRESETS[preset] as Dictionary
	var turn: Basis = Basis(Vector3.UP, deg_to_rad(yaw))
	var items: Array = []
	for entry: Array in (data["items"] as Array):
		var local: Vector3 = turn * Vector3(float(entry[1]), 0.0, float(entry[2]))
		items.append(_yard_item(str(entry[0]), center + Vector2(local.x, local.z), float(entry[3]) + yaw, float(entry[4])))
	var size: Vector2 = data["size"] as Vector2
	if absf(fposmod(yaw, 180.0) - 90.0) < 1.0:
		size = Vector2(size.y, size.x)
	yards.append({"id": id, "center": center, "size": size, "items": items})


func _yard_item(kind: String, at: Vector2, yaw: float, radius: float) -> Dictionary:
	if kind != "sled_track" and kind != "chalk_bucket":
		flat_spots.append(Vector3(at.x, at.y, maxf(radius, 1.0) + 0.6))
	_prop("gym:" + kind, at.x, at.y, yaw, 1.0, radius)
	return {"kind": kind, "pos": Vector3(at.x, 0.0, at.y), "yaw": yaw, "radius": radius}


## Gainlands v2, Part D: the power lines. Tall lattice towers on sandstone stacks: one line down the west rim to the Iron Cave's cliff and the left canyon's
## mouth, one down the east rim past the Swolympus overlook to the right canyon's mouth, and one across the whole zone from the west sea over both canyons and
## the middle road to the east sea. Heights: the stacks' tops (the cliff's top for the tower on it).
const STACK_TOP: float = PLATEAU_Y + 0.6
const CANYON_STACK_TOP: float = PLATEAU_Y - 0.9


func _power() -> void:
	stacks = [
		Vector4(-1.5, 74.0, 2.8, STACK_TOP), Vector4(-2.5, 46.0, 2.8, STACK_TOP), Vector4(37.5, 3.0, 2.4, STACK_TOP),
		Vector4(113.0, 78.0, 2.8, STACK_TOP), Vector4(113.5, 46.0, 2.8, STACK_TOP), Vector4(113.0, 18.0, 2.8, STACK_TOP), Vector4(74.5, 3.0, 2.4, STACK_TOP),
		Vector4(47.7, 40.5, 2.1, CANYON_STACK_TOP), Vector4(64.3, 40.5, 2.1, CANYON_STACK_TOP), Vector4(-3.0, 30.0, 2.6, STACK_TOP), Vector4(114.5, 32.0, 2.6, STACK_TOP),
	]
	var top: Callable = func(index: int) -> Vector3: return Vector3(stacks[index].x, stacks[index].w, stacks[index].y)
	power_lines = [
		[top.call(0), top.call(1), Vector3(24.0, CAVE_CLIFF_TOP, 15.0), top.call(2)] as Array[Vector3],
		[top.call(3), top.call(4), top.call(5), top.call(6)] as Array[Vector3],
		[top.call(9), top.call(7), top.call(8), top.call(10)] as Array[Vector3],
	]


## Where nothing solid may stand: round every anchor, chest, feature, enemy home and sign (radius in z).
func keep_clear_spots() -> Array[Vector3]:
	var keep_clear: Array[Vector3] = []
	for key: Variant in anchors.keys():
		var anchor: Vector3 = anchors[key] as Vector3
		keep_clear.append(Vector3(anchor.x, anchor.z, ANCHOR_CLEARANCE))
	for chest_id: Variant in chests.keys():
		var chest: Vector3 = chests[chest_id] as Vector3
		keep_clear.append(Vector3(chest.x, chest.z, 2.0))
	for feature: Prop in props:
		if feature.kind == "tree" or feature.kind == "boulder":
			continue
		keep_clear.append(Vector3(feature.pos.x, feature.pos.z, 4.5 if feature.radius > 0.0 else 3.0))
	for spawn: Dictionary in enemy_spawns:
		var home: Vector3 = spawn["home"] as Vector3
		keep_clear.append(Vector3(home.x, home.z, 3.0))
	for sign: Sign in signs:
		keep_clear.append(Vector3(sign.pos.x, sign.pos.z, 2.5))
	# the plaza and the bridge head stay open (GC-7, GC-8), and the gate on the mesa (GC-10)
	var hub: Vector3 = anchors["hub"] as Vector3
	keep_clear.append(Vector3(hub.x, hub.z, PLAZA_RADIUS + 2.5))
	keep_clear.append(Vector3(BRIDGE_X, BRIDGE_Z0, 6.0))
	keep_clear.append(Vector3(HOUSE_OF_GAINS.x, -1.0, 7.0))
	# the region landmarks (SR-8) keep their own open ground
	keep_clear.append(Vector3(HERO_WHEEL.x, HERO_WHEEL.y, HERO_WHEEL_CLEARANCE))
	keep_clear.append(Vector3(CHAMPIONS_ARCH.x, CHAMPIONS_ARCH.y, CHAMPIONS_ARCH_CLEARANCE))
	for rect: Rect2 in blocker_rects:
		keep_clear.append(Vector3(rect.get_center().x, rect.get_center().y, rect.size.length() * 0.5 + 1.0))
	return keep_clear


## Open ground round every anchor (NPCs, vendors, gates, travel points): nothing solid inside this radius.
const ANCHOR_CLEARANCE: float = 5.5
## Hardy trees and rocks stand in the band near the cliff edges (Part D: wind-bent trees and cypress at the rims, scrub in between).
const RIM_BAND: Vector2 = Vector2(1.2, 7.0)


## A few hardy trees and rocky outcrops along the rims, clear of paths, anchors and features.
func _scatter() -> void:
	var keep_clear: Array[Vector3] = keep_clear_spots()
	var placed: int = 0
	var attempts: int = 0
	while placed < TREE_COUNT and attempts < 6000:
		attempts += 1
		var x: float = _rng.randf_range(2.0, 110.0)
		var z: float = _rng.randf_range(-6.0, 90.0)
		if level_at(x, z) != 1:
			continue
		var edge: float = main_edge_distance(x, z)
		if edge < RIM_BAND.x + 0.6 or edge > RIM_BAND.y or not _is_clear(x, z, keep_clear):
			continue
		# variant 0: a wind-bent dry-land tree, 1: a cypress accent (GainlandsStructures)
		_prop("tree", x, z, _rng.randf_range(-15.0, 15.0), _rng.randf_range(0.9, 1.2), 0.4, _rng.randi() % 2)
		keep_clear.append(Vector3(x, z, 6.0))
		placed += 1
	var rocks: int = 0
	attempts = 0
	while rocks < ROCK_COUNT and attempts < 6000:
		attempts += 1
		var rx: float = _rng.randf_range(2.0, 110.0)
		var rz: float = _rng.randf_range(-6.0, 90.0)
		if level_at(rx, rz) == 0:
			continue
		var edge: float = main_edge_distance(rx, rz)
		if edge < RIM_BAND.x or edge > RIM_BAND.y - 2.0 or not _is_clear(rx, rz, keep_clear):
			continue
		_prop("boulder", rx, rz, _rng.randf() * 360.0, _rng.randf_range(0.9, 1.6), 0.0, _rng.randi() % 5)
		keep_clear.append(Vector3(rx, rz, 2.2))
		rocks += 1
	# A tree and a boulder or two on each island, away from the travel points and the chests.
	for island: Island in islands:
		var on_island: int = 0
		var tries: int = 0
		while on_island < 3 and tries < 200:
			tries += 1
			var angle: float = _rng.randf() * TAU
			var distance: float = _rng.randf_range(island.radius * 0.45, island.radius * 0.8)
			var tx: float = island.center.x + cos(angle) * distance
			var tz: float = island.center.y + sin(angle) * distance
			if not _is_clear(tx, tz, keep_clear):
				continue
			_prop("tree" if on_island % 2 == 0 else "boulder", tx, tz, _rng.randf() * 360.0, _rng.randf_range(1.0, 1.4), 0.4 if on_island % 2 == 0 else 0.0, _rng.randi() % 2)
			keep_clear.append(Vector3(tx, tz, 1.6))
			on_island += 1


func _is_clear(x: float, z: float, keep_clear: Array[Vector3]) -> bool:
	for spot: Vector3 in keep_clear:
		if Vector2(x - spot.x, z - spot.y).length() < spot.z:
			return false
	return path_edge_distance(x, z) >= PATH_CLEARANCE
