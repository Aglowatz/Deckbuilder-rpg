class_name HeapLayout
extends RefCounted
## The Verdant Dump's map as plain data (no scene nodes), so it can be unit-tested headless: a rounded-rectangle
## stretch of farmland and junkyard with a recycling stream across it, compost pits, two junk mountains, patchwork
## fields, a scree field only a mount can cross, a wall of tires with gaps (one plugged by a junk barricade), named
## anchors, hidden chests, enemy homes, props and signs. `HeapBuilder` turns it into meshes; `HeapScene` makes it
## playable.
##
## Coordinates: metres, x east, z south, y up. ONE walkable zone (docs/design/subarea_removal.md) in six regions
## (docs/art/heap_slice.md): Compost Commons (the hub, south centre, reached over the entrance bridge from town), the
## Farm Rows (south-west), the Junk Peaks (the whole east side: Mount Scrapmore and the county fair at its foot south
## of the stream, the scree fields north of it, Junk Mountain beyond the north-east corner), the Stream (the recycling
## stream with its three vine bridges, the dam and the north bank road), the Wetlands (the centre district behind the
## junk barricade, the land growing twisted toward the Rotheart beyond the north rim) and the Throne Approach (the
## north-west district through the open west gap: the avenue past Rust Peak to the Trash Panda Throne beyond the rim,
## the side dungeon's door). Laid out by the declutter rules of docs/art/zone_rollout_playbook.md section 5.

const MIN_CORNER: Vector2 = Vector2(4.0, 4.0)
const MAX_CORNER: Vector2 = Vector2(96.0, 76.0)
const CORNER_RADIUS: float = 12.0
const TERRAIN_STEP: float = 1.25
const CLIFF_WIDTH: float = 1.6
## The recycling stream: centre line z(x), half width and the water level.
const STREAM_BASE_Z: float = 43.0
const STREAM_HALF_WIDTH: float = 3.2
const WATER_LEVEL: float = -0.3
const STREAM_BED: float = -1.2
## A vine bridge's half width and how far past the stream's centre it reaches on each side.
const BRIDGE_HALF_WIDTH: float = 1.35
const BRIDGE_REACH: float = 5.3
const BRIDGE_HEIGHT: float = 0.12
## The wall of tires along z = WALL_Z, its three gaps and the half width of every gap.
const WALL_Z: float = 30.0
const GAP_HALF_WIDTH: float = 2.5
const BARRICADE_RADIUS: float = 2.2
const GAP_XS: Array[float] = [22.0, 50.0, 78.0]
## The dividers between the three northern districts (x), from the back edge down to the wall.
const DIVIDER_XS: Array[float] = [38.0, 64.0]
## The declutter rules (docs/art/zone_rollout_playbook.md section 5): main roads four hero-widths, spurs a little less, nothing solid near a route
## edge, open ground round every anchor, an empty plaza round the hub with the hub's things on its rim.
const MAIN_PATH_WIDTH: float = 4.2
const SIDE_PATH_WIDTH: float = 3.6
const PATH_CLEARANCE: float = 2.4
const ANCHOR_CLEARANCE: float = 5.5
const PLAZA_CENTER: Vector2 = Vector2(50.0, 64.0)
const PLAZA_RADIUS: float = 9.5
## The way in from town: a plank-and-tyre bridge from the land's south rim out over the overflow pool to its far landing. The hero arrives on it and
## walks north into the Compost Commons; walking off the far end leaves for town. Deck ENTRANCE_HALF_WIDTH either side of x = ENTRANCE_X, z from
## ENTRANCE_Z0 (on the rim) to ENTRANCE_Z1; the kerbs ENTRANCE_RAIL wide hold the hero on the deck.
const ENTRANCE_X: float = 50.0
const ENTRANCE_HALF_WIDTH: float = 2.3
const ENTRANCE_Z0: float = 74.0
const ENTRANCE_Z1: float = 90.0
const ENTRANCE_RAIL: float = 0.3
## The stand-in landmarks (docs/art/heap_slice.md): where each stands and its size (w, h, d). The Rotheart (the main dungeon) is a colossal tree beyond
## the north rim, seen from the whole zone, with its root gate on the land where the main_dungeon spot stands; Junk Mountain is a view beyond the
## north-east corner over the scree; the Trash Panda Throne (the side dungeon's door) stands beyond the north-west rim at the end of the avenue; the
## windmill stands at the farm rows' west edge; the greenhouse is the Commons' centrepiece.
const ROTHEART: Vector2 = Vector2(50.0, -16.0)
const ROTHEART_SIZE: Vector3 = Vector3(44.0, 46.0, 44.0)
const ROOT_GATE: Vector2 = Vector2(50.0, 5.5)
const ROOT_GATE_SIZE: Vector3 = Vector3(10.0, 6.0, 4.0)
const JUNK_MOUNTAIN: Vector2 = Vector2(108.0, -6.0)
const JUNK_MOUNTAIN_SIZE: Vector3 = Vector3(48.0, 28.0, 26.0)
const THRONE: Vector2 = Vector2(31.0, -3.5)
const THRONE_SIZE: Vector3 = Vector3(18.0, 14.0, 12.0)
const WINDMILL: Vector2 = Vector2(8.5, 64.0)
const WINDMILL_SIZE: Vector3 = Vector3(5.0, 12.0, 5.0)
const GREENHOUSE: Vector2 = PLAZA_CENTER
const GREENHOUSE_SIZE: Vector3 = Vector3(9.0, 5.5, 6.5)
## Flat, kept-clear ground under the region landmarks and the pieces that reach the land: (x, z, radius).
const LANDMARK_SPOTS: Array[Vector3] = [Vector3(50.0, 64.0, 7.5), Vector3(8.5, 64.0, 4.0), Vector3(50.0, 7.0, 7.0), Vector3(31.0, 6.0, 5.0)]
## What the landmarks block, as layout data (x, z, radius), so a layout-only reader (the walkability probe, the chest scan) sees them too: the
## greenhouse's footprint, the windmill's tower, the root gate's two roots and its hollow, the throne's steps.
const LANDMARK_BLOCKERS: Array[Vector3] = [
	Vector3(47.6, 64.0, 2.6), Vector3(50.0, 64.0, 2.6), Vector3(52.4, 64.0, 2.6),
	Vector3(8.5, 64.0, 2.5),
	Vector3(46.5, 5.5, 1.8), Vector3(50.0, 4.0, 2.0), Vector3(53.5, 5.5, 1.8),
	Vector3(31.0, 5.2, 2.4),
]
## Where each region paint-over is shot from (the camera looks north): `bash tools/shot.sh res://scenes/heap_zone.tscn <name> --at=po_<region>`.
## Not anchors: they are neither destinations of the walkability probe nor kept-clear ground (docs/art/heap_slice.md lists what each frames).
const PO_CAMERAS: Dictionary = {
	"po_hub": Vector2(50.0, 72.5), "po_junk_peaks": Vector2(80.0, 71.0), "po_farm_rows": Vector2(11.5, 70.0),
	"po_stream": Vector2(50.0, 51.0), "po_wetlands": Vector2(50.0, 22.0), "po_throne_approach": Vector2(32.0, 17.0),
}
## The six regions in reading order (ids of `areas`), for the docs and the tests.
const REGION_IDS: Array[String] = ["commons", "farm", "peaks", "stream", "wetlands", "throne"]
## The scattered decoration kinds (Kenney nature multimeshes), as opposed to the features of `_features`.
const TREE_KINDS: Array[String] = ["tree", "bush", "rock", "mushrooms", "flowers"]

enum Surface { VOID, GROUND, PEAK, CLIFF, HAZARD, ROUGH, BRIDGE }


class Peak:
	extends RefCounted
	var id: String = ""
	var title: String = ""
	var center: Vector2 = Vector2.ZERO
	var radius: float = 5.0
	var height: float = 5.0


class Chute:
	extends RefCounted
	var id: String = ""
	var title: String = ""
	var pos: Vector2 = Vector2.ZERO
	var radius: float = 1.3
	## The slide's route (x, z), from the top down to the landing.
	var path: PackedVector2Array = PackedVector2Array()
	var dest_anchor: String = ""


class Bridge:
	extends RefCounted
	var id: String = ""
	var x: float = 0.0


class Prop:
	extends RefCounted
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
	var yaw: float = 180.0
	var size: float = 1.0
	## "sign" (post sign), "poster" (framed), "memo" (small note), "menu" (chalkboard).
	var style: String = "sign"


class Area:
	extends RefCounted
	var id: String = ""
	var title: String = ""
	var center: Vector2 = Vector2.ZERO
	var radius: float = 10.0


var peaks: Array[Peak] = []
var chutes: Array[Chute] = []
var bridges: Array[Bridge] = []
var props: Array[Prop] = []
var signs: Array[Sign] = []
var areas: Array[Area] = []
## Compost pits: [Vector3(x, z, radius)].
var pits: Array[Vector3] = []
## Scree fields (rough terrain only a mount can cross): [Vector3(x, z, radius)].
var scree: Array[Vector3] = []
var anchors: Dictionary = {}
var enemy_spawns: Array[Dictionary] = []
var chests: Dictionary = {}
var paths: Array[Dictionary] = []
var flat_spots: Array[Vector3] = []
## Static obstacles (x, z, radius).
var obstacles: Array[Vector3] = []
## Where each junk barricade stands: barricade id -> Vector3(x, 0, z).
var barricade_positions: Dictionary = {}
## The corruption gradient (data/zone_styles/heap.json "corruption"): the land grows darker and violet toward the Rotheart, with fewer flowers.
var corruption: Dictionary = {}
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func build() -> void:
	_rng.seed = 8181
	corruption = ZoneStyles.style("heap").get("corruption", {}) as Dictionary
	_peaks()
	_chutes()
	_bridges()
	_pits_and_scree()
	_anchors()
	_chests()
	_enemies()
	_areas()
	_paths()
	_flat_spots()
	_features()
	_wall()
	_signs()
	_scatter()
	_index_obstacles()


# ---- Ground ----------------------------------------------------------------------------------


static func edge_distance(x: float, z: float) -> float:
	var center: Vector2 = (MIN_CORNER + MAX_CORNER) * 0.5
	var half: Vector2 = (MAX_CORNER - MIN_CORNER) * 0.5
	var q: Vector2 = Vector2(absf(x - center.x), absf(z - center.y)) - (half - Vector2(CORNER_RADIUS, CORNER_RADIUS))
	var outside: float = Vector2(maxf(q.x, 0.0), maxf(q.y, 0.0)).length()
	var inside: float = minf(maxf(q.x, q.y), 0.0)
	return -(outside + inside - CORNER_RADIUS)


static func stream_z(x: float) -> float:
	return STREAM_BASE_Z + 2.5 * sin(0.055 * x + 1.2)


## True on the entrance bridge's deck (kerbs included); the deck overlaps the rim so the walk from land to planks is seamless.
static func on_entrance(x: float, z: float) -> bool:
	return absf(x - ENTRANCE_X) <= ENTRANCE_HALF_WIDTH and z >= ENTRANCE_Z0 and z <= ENTRANCE_Z1


## How deep into hazard (stream or pit) (x, z) is: positive in it, negative on land.
func hazard_depth(x: float, z: float) -> float:
	var best: float = STREAM_HALF_WIDTH - absf(z - stream_z(x))
	for pit: Vector3 in pits:
		best = maxf(best, pit.z - Vector2(x - pit.x, z - pit.y).length())
	return best


func peak_at(x: float, z: float) -> Peak:
	for peak: Peak in peaks:
		if Vector2(x - peak.center.x, z - peak.center.y).length() <= peak.radius:
			return peak
	return null


func in_scree(x: float, z: float) -> bool:
	for field: Vector3 in scree:
		if Vector2(x - field.x, z - field.y).length() <= field.z:
			return true
	return false


func surface_at(x: float, z: float) -> Surface:
	if on_entrance(x, z):
		return Surface.BRIDGE
	if edge_distance(x, z) < 0.0:
		return Surface.VOID
	for peak: Peak in peaks:
		var distance: float = Vector2(x - peak.center.x, z - peak.center.y).length()
		if distance <= peak.radius:
			return Surface.PEAK
		if distance <= peak.radius + CLIFF_WIDTH:
			return Surface.CLIFF
	if hazard_depth(x, z) > 0.0:
		return Surface.HAZARD
	if in_scree(x, z):
		return Surface.ROUGH
	return Surface.GROUND


func _hills(x: float, z: float) -> float:
	return 0.9 * sin(x * 0.09 + 0.4) * cos(z * 0.11 + 0.9) + 0.35 * sin(x * 0.17 + z * 0.07 + 2.0) + 0.3 * cos(z * 0.14 - x * 0.06)


func ground_height(x: float, z: float) -> float:
	var edge: float = edge_distance(x, z)
	if edge < 0.0:
		if on_entrance(x, z):
			return 0.0
		return -5.0 + edge * 0.6
	for peak: Peak in peaks:
		var distance: float = Vector2(x - peak.center.x, z - peak.center.y).length()
		if distance <= peak.radius:
			return peak.height
		if distance < peak.radius + CLIFF_WIDTH:
			var t: float = smoothstep(0.0, 1.0, (distance - peak.radius) / CLIFF_WIDTH)
			return lerpf(peak.height, _base_height(x, z), t)
	return _base_height(x, z)


func _base_height(x: float, z: float) -> float:
	var flat: float = 1.0
	for spot: Vector3 in flat_spots:
		var distance: float = Vector2(x - spot.x, z - spot.y).length()
		flat = minf(flat, smoothstep(spot.z * 0.7, spot.z * 1.3, distance))
	var hills: float = _hills(x, z) * flat * smoothstep(1.0, 5.0, -hazard_depth(x, z))
	var edge: float = clampf(edge_distance(x, z) / 4.0, 0.0, 1.0)
	# the rim dips toward the edge everywhere but at the bridge head, where the land meets the deck level
	var dip: float = (1.0 - edge) * 0.9 * smoothstep(3.0, 7.0, absf(x - ENTRANCE_X)) if z > 68.0 else (1.0 - edge) * 0.9
	var land: float = hills - dip
	var depth: float = hazard_depth(x, z)
	if depth > -1.8:
		var bank: float = smoothstep(-1.8, 0.4, depth)
		return lerpf(land, STREAM_BED + 0.3 * clampf(depth, 0.0, 2.0), bank)
	return land


func area_at(x: float, z: float) -> Area:
	var best: Area = null
	for area: Area in areas:
		if Vector2(x - area.center.x, z - area.center.y).length() <= area.radius:
			if best == null or area.radius < best.radius:
				best = area
	return best


func path_weight(x: float, z: float) -> float:
	var best: float = 0.0
	for path: Dictionary in paths:
		var line: PackedVector2Array = path["line"] as PackedVector2Array
		var half: float = float(path["width"]) * 0.5
		for i: int in range(line.size() - 1):
			var closest: Vector2 = Geometry2D.get_closest_point_to_segment(Vector2(x, z), line[i], line[i + 1])
			var distance: float = closest.distance_to(Vector2(x, z))
			best = maxf(best, 1.0 - smoothstep(half * 0.7, half * 1.2, distance))
	return best


## Metres from the nearest route EDGE (negative on the route itself, positive out on the land): nothing solid stands inside PATH_CLEARANCE.
func path_edge_distance(x: float, z: float) -> float:
	var best: float = 1e9
	for path: Dictionary in paths:
		var line: PackedVector2Array = path["line"] as PackedVector2Array
		var half: float = float(path["width"]) * 0.5
		for i: int in range(line.size() - 1):
			var closest: Vector2 = Geometry2D.get_closest_point_to_segment(Vector2(x, z), line[i], line[i + 1])
			best = minf(best, closest.distance_to(Vector2(x, z)) - half)
	return best


## How twisted the land is at (x, z), 0 (the Commons and the farms, healthy) to 1 (the Rotheart's roots): the data of `corruption`
## (start_z, end_z, centre_x, spread) shapes a band that deepens northward and is strongest in the centre district.
func corruption_at(x: float, z: float) -> float:
	if corruption.is_empty():
		return 0.0
	var start_z: float = float(corruption.get("start_z", 36.0))
	var end_z: float = float(corruption.get("end_z", 10.0))
	var north: float = clampf((start_z - z) / maxf(start_z - end_z, 0.001), 0.0, 1.0)
	north = north * north * (3.0 - 2.0 * north)
	var centre_x: float = float(corruption.get("centre_x", 50.0))
	var spread: float = float(corruption.get("spread", 30.0))
	var across: float = 1.0 - smoothstep(spread * 0.4, spread, absf(x - centre_x))
	return north * (0.55 + 0.45 * across)


## The bridge strip (grown or not) that (x, z) lies on, or null.
func bridge_at(x: float, z: float) -> Bridge:
	for bridge: Bridge in bridges:
		if absf(x - bridge.x) <= BRIDGE_HALF_WIDTH and absf(z - stream_z(bridge.x)) <= BRIDGE_REACH:
			return bridge
	return null


## 0 at the bridge's south end, 1 at its north end, for a point on it.
func bridge_fraction(bridge: Bridge, z: float) -> float:
	var zc: float = stream_z(bridge.x)
	return clampf((zc + BRIDGE_REACH - z) / (2.0 * BRIDGE_REACH), 0.0, 1.0)


# ---- Peaks, chutes, bridges, hazards -------------------------------------------------------------


func _peak(id: String, title: String, center: Vector2, radius: float, height: float) -> void:
	var peak: Peak = Peak.new()
	peak.id = id
	peak.title = title
	peak.center = center
	peak.radius = radius
	peak.height = height
	peaks.append(peak)


func _peaks() -> void:
	_peak("scrapmore", "Mount Scrapmore", Vector2(86.0, 56.0), 4.5, 5.0)
	_peak("rust", "Rust Peak", Vector2(16.0, 16.0), 5.0, 7.0)


func _chute(id: String, title: String, pos: Vector2, path: PackedVector2Array, dest: String) -> void:
	var chute: Chute = Chute.new()
	chute.id = id
	chute.title = title
	chute.pos = pos
	chute.path = path
	chute.dest_anchor = dest
	chutes.append(chute)


func _chutes() -> void:
	# Mount Scrapmore's chute lands at the fair's road end; Rust Peak's runs down its west side (its east side is the throne avenue).
	_chute("chute_a", "Trash Chute (Mount Scrapmore)", Vector2(83.6, 58.2), PackedVector2Array([Vector2(83.6, 58.2), Vector2(80.0, 61.5), Vector2(77.0, 63.0), Vector2(75.0, 62.5)]), "chute_a_end")
	_chute("chute_b", "Trash Chute (Rust Peak)", Vector2(13.5, 14.0), PackedVector2Array([Vector2(13.5, 14.0), Vector2(9.0, 16.5), Vector2(7.5, 20.0), Vector2(8.5, 23.5)]), "chute_b_end")


func _bridges() -> void:
	for x: float in [22.0, 50.0, 78.0]:
		var bridge: Bridge = Bridge.new()
		bridge.id = "bridge_west" if x < 30.0 else ("bridge_center" if x < 60.0 else "bridge_east")
		bridge.x = x
		bridges.append(bridge)


func _pits_and_scree() -> void:
	pits = [Vector3(84.0, 72.0, 3.2), Vector3(28.0, 69.0, 3.0)] as Array[Vector3]
	scree = [Vector3(79.0, 17.0, 13.5)] as Array[Vector3]


# ---- Anchors, chests, enemies -----------------------------------------------------------------


func _at(name: String, x: float, z: float) -> void:
	anchors[name] = Vector3(x, 0.0, z)


func _anchors() -> void:
	var wz: float = stream_z(22.0)
	var cz: float = stream_z(50.0)
	var ez: float = stream_z(78.0)
	# The way in: the entrance bridge from town. A fresh visit starts on its deck facing north; the exit spot waits at its far landing.
	_at("spawn", ENTRANCE_X, ENTRANCE_Z1 - 6.0)
	_at("exit", ENTRANCE_X, ENTRANCE_Z1 - 2.0)
	# Compost Commons: the plaza round the greenhouse, the hub's things on its rim (the hub anchor is the plaza's south half, where you wake).
	_at("hub", 50.0, 70.0)
	_at("rift_station", 44.0, 73.0)
	_at("heal", 40.5, 63.5)
	_at("wren", 42.5, 69.0)
	_at("stable_1", 38.0, 70.5)
	_at("marigold", 56.0, 57.0)
	_at("hob", 61.0, 60.0)
	_at("compost_bin", 57.5, 70.5)
	_at("trough", 63.0, 72.5)
	_at("shrine", 69.0, 71.0)
	# The Farm Rows (south-west): the crop plots, the druid grove and the quiz, the pickups, the escaped animals, the giant chest's corner.
	_at("crop_1", 12.0, 56.0)
	_at("crop_2", 17.0, 56.0)
	_at("crop_3", 22.0, 56.0)
	_at("quiz", 19.0, 66.0)
	_at("pickup_bean_1", 9.0, 53.0)
	_at("pickup_fert_1", 15.0, 71.0)
	_at("pickup_junk_1", 27.0, 56.5)
	_at("animal_1", 27.0, 52.0)
	_at("animal_2", 32.5, 73.5)
	# Brief 16: Shiro Swindle's giant chest, on the heap's south-west shoulder.
	_at("giant_chest", 22.8, 73.8)
	# The Junk Peaks, south half: the county fair at Mount Scrapmore's foot, the sprout mound and the beanstalk, the secret corner with the lever.
	_at("minigame", 73.0, 59.5)
	_at("pickup_bean_2", 93.0, 60.0)
	_at("pickup_fert_2", 66.0, 70.0)
	_at("pickup_junk_2", 66.0, 57.0)
	_at("animal_3", 91.0, 66.5)
	_at("mound_a", 86.0, 63.5)
	_at("ladder_a_top", 86.0, 58.5)
	_at("chute_a_end", 75.0, 62.5)
	# Brief 16: the hidden vault lever, half buried on the heap's east side.
	_at("vault_lever", 90.0, 72.0)
	# The Stream: the south banks (where you grow things), the north banks (where you arrive), the dam and the goat stable at the bank's west end.
	_at("sorrel", 46.0, cz + 5.8)
	_at("mound_west", 18.5, wz + 5.6)
	_at("mound_east", 74.5, ez + 5.6)
	_at("bank_west", 22.0, wz + 5.8)
	_at("bank_center", 50.0, cz + 5.8)
	_at("bank_east", 78.0, ez + 5.8)
	_at("land_west", 22.0, wz - 5.8)
	_at("land_center", 50.0, cz - 5.8)
	_at("land_east", 78.0, ez - 5.8)
	_at("stable_2", 12.0, 38.0)
	_at("pickup_bean_3", 30.0, 37.5)
	_at("pickup_fert_3", 86.0, 37.5)
	_at("pickup_junk_3", 44.0, 37.5)
	_at("barricade_dam", 36.5, 35.5)
	_at("barricade_gate", 50.0, WALL_Z)
	# The Throne Approach (north-west): the avenue past Rust Peak (the Seed Shrine on its summit) to the Trash Panda Throne beyond the rim.
	_at("mound_b", 16.0, 24.5)
	_at("ladder_b_top", 16.0, 19.5)
	_at("puzzle", 16.0, 13.2)
	_at("chute_b_end", 8.5, 23.5)
	_at("mini_dungeon", 31.0, 9.5)
	# The Wetlands (north centre, behind the junk barricade): the road to the Rotheart's root gate.
	_at("main_dungeon", 50.0, 9.2)


func _chests() -> void:
	chests = {
		"chest_fridge": Vector3(73.6, 0.0, 72.4),
		"chest_compost": Vector3(7.5, 0.0, 72.5),
		"chest_peak_a": Vector3(84.0, 0.0, 54.4),
		"chest_hay": Vector3(68.0, 0.0, 37.0),
		"chest_log": Vector3(35.0, 0.0, 12.0),
		"chest_peak_b": Vector3(12.5, 0.0, 14.0),
		"chest_car": Vector3(60.5, 0.0, 22.0),
		"chest_barn": Vector3(88.0, 0.0, 21.0),
		# Polish round: a third summit chest on each peak, one up the scree, three in the far corners.
		"chest_peak_c": Vector3(18.5, 0.0, 12.5),
		"chest_peak_d": Vector3(90.0, 0.0, 54.0),
		"chest_scree_ne": Vector3(82.2, 0.0, 4.8),
		"chest_corner_nw": Vector3(8.4, 0.0, 7.2),
		"chest_back_edge": Vector3(34.8, 0.0, 4.8),
		"chest_thicket_s": Vector3(4.8, 0.0, 28.2),
	}


func _enemies() -> void:
	enemy_spawns = [
		{"type": "golem", "home": Vector3(30.0, 0.0, 55.5), "patrol": 3.5},
		{"type": "scarecrow", "home": Vector3(79.0, 0.0, 72.0), "patrol": 2.5},
		{"type": "gulls", "home": Vector3(70.0, 0.0, 52.0), "patrol": 5.0},
		{"type": "golem", "home": Vector3(26.0, 0.0, 28.5), "patrol": 3.0},
		{"type": "scarecrow", "home": Vector3(50.0, 0.0, 20.0), "patrol": 3.0},
		{"type": "gulls", "home": Vector3(74.0, 0.0, 14.0), "patrol": 5.0},
		{"type": "gulls", "home": Vector3(40.0, 0.0, 34.5), "patrol": 4.0},
	]


func _area(id: String, title: String, x: float, z: float, radius: float) -> void:
	var area: Area = Area.new()
	area.id = id
	area.title = title
	area.center = Vector2(x, z)
	area.radius = radius
	areas.append(area)


## The six regions (several circles may share an id; the smallest circle containing a point names it).
func _areas() -> void:
	_area("commons", "Compost Commons", 50.0, 65.0, 13.0)
	_area("farm", "The Farm Rows", 18.0, 62.0, 16.0)
	_area("peaks", "The Junk Peaks", 80.0, 62.0, 16.0)
	_area("peaks", "The Junk Peaks", 80.0, 17.0, 15.5)
	_area("stream", "The Stream", 22.0, 42.0, 10.0)
	_area("stream", "The Stream", 50.0, 42.0, 10.0)
	_area("stream", "The Stream", 78.0, 42.0, 10.0)
	_area("stream", "The Stream", 36.0, 40.0, 7.0)
	_area("stream", "The Stream", 64.0, 40.0, 7.0)
	_area("stream", "The Stream", 10.0, 38.0, 7.0)
	_area("stream", "The Stream", 90.0, 38.0, 7.0)
	_area("wetlands", "The Wetlands", 51.0, 18.0, 15.0)
	_area("throne", "The Throne Approach", 20.0, 17.0, 17.0)
	_area("meadow", "The Verdant Dump", 50.0, 45.0, 60.0)


func _paths() -> void:
	# Routes are wide and clear: main roads MAIN_PATH_WIDTH, spurs SIDE_PATH_WIDTH, nothing solid within PATH_CLEARANCE of their edges; every region
	# hangs on a loop (plaza - farm - the farm spur - the south bank road - plaza; plaza - fair - the fair spur - the south bank road - plaza; the three
	# crossings - the north bank road - the three gaps).
	var wz: float = stream_z(22.0)
	var cz: float = stream_z(50.0)
	var ez: float = stream_z(78.0)
	var plaza_s: Vector2 = Vector2(50.0, 71.5)
	var plaza_n: Vector2 = Vector2(50.0, 56.5)
	var plaza_w: Vector2 = Vector2(40.5, 64.5)
	var plaza_e: Vector2 = Vector2(59.5, 64.0)
	paths = [
		# the Commons: the way in, and the four roads off the plaza's rim
		{"line": PackedVector2Array([plaza_s, Vector2(50.0, ENTRANCE_Z0 + 1.0)]), "width": MAIN_PATH_WIDTH},
		{"line": PackedVector2Array([plaza_n, Vector2(50.0, 54.0), Vector2(50.0, cz + 4.0)]), "width": MAIN_PATH_WIDTH},
		{"line": PackedVector2Array([plaza_w, Vector2(34.0, 62.0), Vector2(18.0, 62.0)]), "width": MAIN_PATH_WIDTH},
		{"line": PackedVector2Array([plaza_e, Vector2(68.0, 63.0), Vector2(76.0, 62.0)]), "width": MAIN_PATH_WIDTH},
		# the south bank road from the west crossing past the plaza's north junction to the east crossing
		{"line": PackedVector2Array([Vector2(22.0, wz + 4.0), Vector2(36.0, 50.0), Vector2(50.0, 54.0), Vector2(64.0, 50.0), Vector2(78.0, ez + 4.0)]), "width": MAIN_PATH_WIDTH},
		# the farm's spur to the west crossing and the fair's spur to the sprout mound
		{"line": PackedVector2Array([Vector2(34.0, 62.0), Vector2(30.0, 50.5)]), "width": SIDE_PATH_WIDTH},
		{"line": PackedVector2Array([Vector2(76.0, 62.0), Vector2(83.0, 63.5)]), "width": SIDE_PATH_WIDTH},
		# the north bank road between the three crossings and the three gaps
		{"line": PackedVector2Array([Vector2(22.0, wz - 4.0), Vector2(22.0, 34.0), Vector2(50.0, 34.0), Vector2(78.0, 34.0), Vector2(78.0, ez - 4.0)]), "width": MAIN_PATH_WIDTH},
		{"line": PackedVector2Array([Vector2(50.0, cz - 4.0), Vector2(50.0, 34.0)]), "width": MAIN_PATH_WIDTH},
		# the throne avenue: through the west gap, past Rust Peak's east cliff, to the throne's steps
		{"line": PackedVector2Array([Vector2(22.0, 34.0), Vector2(22.0, 31.0), Vector2(26.0, 27.0), Vector2(31.0, 22.0), Vector2(31.0, 11.5)]), "width": MAIN_PATH_WIDTH},
		# the wetlands road: through the barricade gap to the Rotheart's root gate
		{"line": PackedVector2Array([Vector2(50.0, 34.0), Vector2(50.0, 11.0)]), "width": MAIN_PATH_WIDTH},
		# the scree track: through the east gap toward the scrap barn (a mount's road)
		{"line": PackedVector2Array([Vector2(78.0, 34.0), Vector2(78.0, 22.0), Vector2(80.0, 19.0)]), "width": SIDE_PATH_WIDTH},
	]


func _flat_spots() -> void:
	flat_spots = [Vector3(PLAZA_CENTER.x, PLAZA_CENTER.y, 14.0), Vector3(ENTRANCE_X, ENTRANCE_Z0 + 1.0, 5.0)] as Array[Vector3]
	for key: Variant in anchors.keys():
		var anchor: Vector3 = anchors[key] as Vector3
		flat_spots.append(Vector3(anchor.x, anchor.z, 3.2))
	for chute: Chute in chutes:
		for point: Vector2 in chute.path:
			flat_spots.append(Vector3(point.x, point.y, 2.5))
	for peak: Peak in peaks:
		flat_spots.append(Vector3(peak.center.x, peak.center.y, peak.radius + CLIFF_WIDTH + 1.0))
	flat_spots.append(Vector3(22.0, 34.0, 5.0))
	flat_spots.append(Vector3(50.0, 34.0, 5.0))
	flat_spots.append(Vector3(78.0, 34.0, 5.0))
	for spot: Vector3 in LANDMARK_SPOTS:
		flat_spots.append(spot)


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
	# Compost Commons: the hub's things round the plaza's rim (the greenhouse centrepiece and the windmill are landmarks, see HeapBuilder), the
	# scrap-built barn north-west of the plaza off the road north.
	_prop("barn", 38.0, 57.5, 20.0, 1.0, 4.2)
	_prop("harvest_table", 40.5, 63.5, 90.0, 1.0, 1.5)
	_prop("swap_shed", 63.5, 57.5, 200.0, 1.0, 1.2)
	_prop("compost_bin", 57.5, 70.5, 180.0, 1.0, 1.4)
	_prop("shrine", 69.0, 71.0, 0.0, 1.0, 1.2)
	_prop("trough", 63.0, 72.5, 0.0, 1.0, 1.2)
	_prop("stable", 38.0, 70.5, 0.0, 1.0, 1.8)
	# The Farm Rows: three crop plots in a row, the druid grove's appliance ring, the compost heap in the corner, a scarecrow over the crops.
	_prop("crop_plot", 12.0, 56.0, 0.0, 1.0, 0.0, 0)
	_prop("crop_plot", 17.0, 56.0, 0.0, 1.0, 0.0, 1)
	_prop("crop_plot", 22.0, 56.0, 0.0, 1.0, 0.0, 2)
	_prop("appliance_ring", 19.0, 65.0, 0.0, 1.0, 0.0)
	_prop("compost_heap", 8.5, 71.4, 0.0, 1.0, 0.0)
	_prop("scarecrow", 17.0, 52.0, 20.0, 1.0, 0.7)
	# The Junk Peaks, south: the fair stage facing the road, the fridge in the secret corner, the sprout mounds.
	_prop("fair_stage", 73.0, 56.0, 0.0, 1.0, 1.9)
	_prop("fridge", 76.5, 72.8, 200.0, 1.0, 0.9)
	_prop("beanstalk_mound", 86.0, 63.5, 0.0, 1.0, 0.0, 0)
	_prop("beanstalk_mound", 18.5, stream_z(22.0) + 5.6, 0.0, 1.0, 0.0, 1)
	_prop("beanstalk_mound", 74.5, stream_z(78.0) + 5.6, 0.0, 1.0, 0.0, 2)
	_prop("beanstalk_mound", 16.0, 24.5, 0.0, 1.0, 0.0, 3)
	# The Stream: the junk dam at the water's edge, the haybale that hides a chest, the goat stable at the bank's west end.
	_prop("junk_dam", 36.5, 39.0, 0.0, 1.0, 0.0)
	_prop("haybale", 66.5, 38.6, 10.0, 1.0, 1.0, 1)
	_prop("stable", 12.0, 38.0, 0.0, 1.0, 1.8)
	# The Throne Approach: the hollow log by its chest, tyre stacks either side of the throne's steps.
	_prop("hollow_log", 35.0, 13.5, 10.0, 1.0, 0.0)
	_prop("tire_stack", 25.5, 12.0, 0.0, 1.0, 1.0)
	_prop("tire_stack", 36.5, 9.5, 0.0, 1.0, 1.0)
	# The Wetlands: a junk cluster in each corner by the wall, the car husk that hides a chest.
	_prop("junk_pile", 41.0, 26.0, 0.0, 1.1, 2.3, 2)
	_prop("tire_stack", 44.0, 27.5, 0.0, 1.0, 1.0)
	_prop("junk_pile", 59.0, 27.0, 0.0, 1.2, 2.3, 0)
	_prop("tire_stack", 56.0, 28.0, 0.0, 1.0, 1.0)
	_prop("car_husk", 62.5, 24.5, 160.0, 1.0, 1.7, 1)
	# The Junk Peaks, north (the scree): the scrap barn with its chest behind, a wreck and a junk pile at the gap, hay by the barn.
	_prop("barn", 82.0, 14.0, 0.0, 0.9, 3.8)
	_prop("car_husk", 88.0, 11.0, 200.0, 1.0, 1.7, 3)
	_prop("junk_pile", 72.0, 24.0, 0.0, 1.0, 2.2, 1)
	_prop("haybale", 92.0, 18.0, 0.0, 1.0, 1.0, 2)


func _wall() -> void:
	# The wall of tires along z = WALL_Z with a gap at each crossing.
	var x: float = 5.0
	while x <= 95.0:
		var in_gap: bool = false
		for gap_x: float in GAP_XS:
			if absf(x - gap_x) < GAP_HALF_WIDTH - 0.01:
				in_gap = true
		if not in_gap:
			_prop("wall_tires", x, WALL_Z, 0.0, 1.0, 0.5, int(x) % 3)
		x += 1.0
	# Dividers between the three northern districts.
	for divider_x: float in DIVIDER_XS:
		var z: float = 5.0
		while z <= WALL_Z - 1.0:
			_prop("divider", divider_x, z, 0.0, 1.0, 0.55, int(z) % 3)
			z += 1.0
	barricade_positions["gate"] = Vector3(50.0, 0.0, WALL_Z)
	barricade_positions["dam"] = Vector3(36.5, 0.0, 39.0)


func _sign(key: String, x: float, z: float, yaw: float = 180.0, size: float = 1.0, style: String = "sign") -> void:
	var sign: Sign = Sign.new()
	sign.key = key
	sign.pos = Vector3(x, 0.0, z)
	sign.yaw = 180.0 + clampf(yaw - 180.0, -12.0, 12.0)
	sign.size = size
	sign.style = style
	signs.append(sign)


## Boards only where they label something (the quiz answers stay on the Commons board, the oath and the crop plots).
func _signs() -> void:
	var wz: float = stream_z(22.0)
	var cz: float = stream_z(50.0)
	var ez: float = stream_z(78.0)
	_sign("sign.hub_main", 46.5, 73.5, 180.0, 1.2)
	_sign("sign.oath", 55.5, 55.0, 190.0)
	_sign("sign.exit", 54.0, 73.0, 180.0)
	_sign("sign.heal_table", 39.0, 60.5, 180.0)
	_sign("sign.swap_shed", 66.0, 59.5, 200.0)
	_sign("sign.compost_bin", 60.5, 69.0, 160.0)
	_sign("sign.shrine", 71.5, 69.5, 190.0)
	_sign("sign.trough", 65.5, 74.5, 170.0, 0.9)
	_sign("sign.stable_1", 35.0, 71.0, 160.0)
	_sign("sign.fields", 26.0, 59.5, 150.0)
	_sign("sign.crops", 14.5, 59.4, 180.0, 0.9)
	_sign("sign.fair_stage", 70.0, 58.0, 180.0)
	_sign("sign.scrapmore", 83.0, 66.0, 180.0)
	_sign("sign.bridge_west", 17.0, wz + 7.6, 180.0)
	_sign("sign.bridge_center", 53.8, cz + 7.6, 200.0)
	_sign("sign.bridge_east", 74.0, ez + 7.6, 180.0)
	_sign("sign.dam", 33.5, 37.5, 190.0)
	_sign("sign.stable_2", 12.0, 35.5, 170.0)
	_sign("sign.barricade", 53.8, 32.4, 190.0)
	_sign("sign.landfill", 28.0, 11.0, 180.0)
	_sign("sign.main_dungeon", 54.5, 8.0, 180.0, 1.5)
	_sign("sign.seed_shrine", 12.8, 15.5, 190.0)
	_sign("sign.scree", 74.5, 31.2, 170.0)


## Where nothing scattered may stand: round every anchor, chest, feature, enemy home, sign and chute point, the plaza, the bridge head, the landmarks.
func keep_clear_spots() -> Array[Vector3]:
	var keep_clear: Array[Vector3] = []
	for key: Variant in anchors.keys():
		var anchor: Vector3 = anchors[key] as Vector3
		keep_clear.append(Vector3(anchor.x, anchor.z, ANCHOR_CLEARANCE))
	for chest_id: Variant in chests.keys():
		var chest: Vector3 = chests[chest_id] as Vector3
		keep_clear.append(Vector3(chest.x, chest.z, 2.0))
	for feature: Prop in props:
		if feature.kind == "wall_tires" or feature.kind == "divider":
			keep_clear.append(Vector3(feature.pos.x, feature.pos.z, 1.2))
		else:
			keep_clear.append(Vector3(feature.pos.x, feature.pos.z, 4.5 if feature.radius > 0.0 else 3.0))
	for spawn: Dictionary in enemy_spawns:
		var home: Vector3 = spawn["home"] as Vector3
		keep_clear.append(Vector3(home.x, home.z, 3.0))
	for chute: Chute in chutes:
		for point: Vector2 in chute.path:
			keep_clear.append(Vector3(point.x, point.y, 2.6))
	for sign: Sign in signs:
		keep_clear.append(Vector3(sign.pos.x, sign.pos.z, 2.5))
	keep_clear.append(Vector3(PLAZA_CENTER.x, PLAZA_CENTER.y, PLAZA_RADIUS + 2.5))
	keep_clear.append(Vector3(ENTRANCE_X, ENTRANCE_Z0, 6.0))
	for spot: Vector3 in LANDMARK_SPOTS:
		keep_clear.append(Vector3(spot.x, spot.y, spot.z + 1.0))
	return keep_clear


## Trees only at the land's edges and in framing groups, bushes at the edges and as reed beds in the wetlands, flowers in clumps along the paths
## (fewer toward the Rotheart), a few rocks on the rim, mushrooms in the druid grove. No scattered junk: junk stands in the clusters of `_features`.
func _scatter() -> void:
	var keep_clear: Array[Vector3] = keep_clear_spots()
	# the rim bands
	_scatter_kind("tree", Rect2(10.0, 70.0, 30.0, 5.0), 5, keep_clear, 1.8, 0.5, 1.0, 1.4)
	_scatter_kind("tree", Rect2(60.0, 70.0, 32.0, 5.0), 5, keep_clear, 1.8, 0.5, 1.0, 1.4)
	_scatter_kind("tree", Rect2(5.0, 30.0, 4.5, 24.0), 5, keep_clear, 1.8, 0.5, 1.0, 1.4)
	_scatter_kind("tree", Rect2(91.0, 36.0, 4.5, 22.0), 5, keep_clear, 1.8, 0.5, 1.0, 1.4)
	_scatter_kind("tree", Rect2(5.0, 5.0, 10.0, 5.0), 3, keep_clear, 1.8, 0.5, 1.0, 1.3)
	_scatter_kind("tree", Rect2(39.0, 5.0, 24.0, 3.5), 4, keep_clear, 1.8, 0.5, 1.0, 1.3)
	# framing groups: the plaza's south corners either side of the bridge head, the farm road's bend, the fair's back, the bank road's junctions
	_grove("tree", Vector2(41.0, 74.0), 3, 2.4, keep_clear)
	_grove("tree", Vector2(59.5, 74.5), 3, 2.4, keep_clear)
	_grove("tree", Vector2(30.0, 66.0), 3, 2.6, keep_clear)
	_grove("tree", Vector2(79.0, 53.0), 3, 2.6, keep_clear)
	_grove("tree", Vector2(31.0, 52.5), 3, 2.6, keep_clear)
	_grove("tree", Vector2(69.0, 47.0), 3, 2.6, keep_clear)
	_grove("tree", Vector2(14.0, 46.0), 3, 2.6, keep_clear)
	_grove("tree", Vector2(84.0, 46.0), 3, 2.6, keep_clear)
	_grove("tree", Vector2(24.0, 8.0), 3, 2.6, keep_clear)
	_grove("tree", Vector2(42.0, 14.0), 3, 2.6, keep_clear)
	_grove("tree", Vector2(60.0, 14.0), 3, 2.6, keep_clear)
	# bushes at the edges, reed beds in the wetlands
	_scatter_kind("bush", Rect2(5.0, 30.0, 6.0, 44.0), 6, keep_clear, 1.0, 0.45, 0.9, 1.4)
	_scatter_kind("bush", Rect2(89.0, 36.0, 6.0, 38.0), 6, keep_clear, 1.0, 0.45, 0.9, 1.4)
	_scatter_kind("bush", Rect2(5.0, 70.0, 90.0, 5.0), 6, keep_clear, 1.0, 0.45, 0.9, 1.4)
	_scatter_kind("bush", Rect2(39.0, 6.0, 24.0, 22.0), 16, keep_clear, 1.0, 0.45, 1.0, 1.5)
	# rocks on the rim, mushrooms in the druid grove
	_scatter_kind("rock", Rect2(5.0, 5.0, 90.0, 4.0), 4, keep_clear, 1.8, 0.0, 0.9, 1.6)
	_scatter_kind("rock", Rect2(5.0, 71.0, 90.0, 4.0), 4, keep_clear, 1.8, 0.0, 0.9, 1.6)
	_scatter_kind("mushrooms", Rect2(14.0, 62.0, 12.0, 10.0), 6, keep_clear, 1.0, 0.0, 0.9, 1.4)
	_flower_clumps(keep_clear)


## A tight group of count trees round center (the edge of a space), each kept clear of routes and anchors like the scatter.
func _grove(kind: String, center: Vector2, count: int, radius: float, keep_clear: Array[Vector3]) -> void:
	_scatter_kind(kind, Rect2(center - Vector2(radius, radius), Vector2(radius * 2.0, radius * 2.0)), count, keep_clear, 1.3, 0.5, 0.9, 1.3)


## Clumps of four to six flowers along the path edges (alternating sides every few metres) and along the farm's crop row; the corruption gradient
## thins them toward the Rotheart (`corruption.flowers` is how much of a clump survives at full corruption).
func _flower_clumps(_keep_clear: Array[Vector3]) -> void:
	# flowers are decoration (no radius): they keep a lighter distance than the solid scatter, so the busy south still gets its clumps
	var keep_clear: Array[Vector3] = []
	for key: Variant in anchors.keys():
		var anchor: Vector3 = anchors[key] as Vector3
		keep_clear.append(Vector3(anchor.x, anchor.z, 2.0))
	for chest_id: Variant in chests.keys():
		var chest: Vector3 = chests[chest_id] as Vector3
		keep_clear.append(Vector3(chest.x, chest.z, 1.5))
	for feature: Prop in props:
		if feature.kind in TREE_KINDS:
			continue
		keep_clear.append(Vector3(feature.pos.x, feature.pos.z, feature.radius + 0.8 if feature.radius > 0.0 else 2.0))
	for chute: Chute in chutes:
		for point: Vector2 in chute.path:
			keep_clear.append(Vector3(point.x, point.y, 2.0))
	keep_clear.append(Vector3(ENTRANCE_X, ENTRANCE_Z0, 4.0))
	for spot: Vector3 in LANDMARK_SPOTS:
		keep_clear.append(spot)
	var survive: float = float(corruption.get("flowers", 0.15))
	var side: float = 1.0
	for path: Dictionary in paths:
		var line: PackedVector2Array = path["line"] as PackedVector2Array
		var half: float = float(path["width"]) * 0.5
		for i: int in range(line.size() - 1):
			var a: Vector2 = line[i]
			var b: Vector2 = line[i + 1]
			var length: float = a.distance_to(b)
			var along: float = 3.5
			while along < length - 2.0:
				var at: Vector2 = a.lerp(b, along / length)
				var normal: Vector2 = Vector2(-(b - a).y, (b - a).x).normalized() * side
				var center: Vector2 = at + normal * (half + 1.3)
				var chance: float = lerpf(1.0, survive, corruption_at(center.x, center.y))
				if _rng.randf() < chance:
					_clump("flowers", center, 1.1, 4 + _rng.randi() % 3, keep_clear)
				side *= -1.0
				along += 7.0
	for center: Vector2 in [Vector2(9.0, 58.5), Vector2(14.5, 58.5), Vector2(19.5, 58.5), Vector2(24.5, 58.5)]:
		_clump("flowers", center, 1.0, 5, keep_clear)


## A clump of count decorations (radius 0) within `spread` of center, on open ground only.
func _clump(kind: String, center: Vector2, spread: float, count: int, keep_clear: Array[Vector3]) -> void:
	var placed: int = 0
	var attempts: int = 0
	while placed < count and attempts < 24:
		attempts += 1
		var angle: float = _rng.randf() * TAU
		var p: Vector2 = center + Vector2(cos(angle), sin(angle)) * _rng.randf_range(0.0, spread)
		if edge_distance(p.x, p.y) < 2.2 or hazard_depth(p.x, p.y) > -1.6 or surface_at(p.x, p.y) != Surface.GROUND:
			continue
		if path_edge_distance(p.x, p.y) < 0.4 or not _is_clear(p.x, p.y, keep_clear, 0.0):
			continue
		_prop(kind, p.x, p.y, _rng.randf() * 360.0, _rng.randf_range(0.9, 1.4), 0.0, _rng.randi() % 4)
		placed += 1


func _scatter_kind(kind: String, area: Rect2, count: int, keep_clear: Array[Vector3], gap: float, radius: float, scale_min: float, scale_max: float) -> void:
	var placed: int = 0
	var attempts: int = 0
	while placed < count and attempts < 600:
		attempts += 1
		var x: float = _rng.randf_range(area.position.x, area.end.x)
		var z: float = _rng.randf_range(area.position.y, area.end.y)
		var surface: Surface = surface_at(x, z)
		if edge_distance(x, z) < 2.2 or hazard_depth(x, z) > -1.6:
			continue
		if surface != Surface.GROUND and not (surface == Surface.ROUGH and kind in ["rock", "bush"]):
			continue
		if not _is_clear(x, z, keep_clear):
			continue
		_prop(kind, x, z, _rng.randf() * 360.0, _rng.randf_range(scale_min, scale_max), radius, _rng.randi() % 4)
		keep_clear.append(Vector3(x, z, gap + radius))
		placed += 1


func _is_clear(x: float, z: float, keep_clear: Array[Vector3], path_margin: float = PATH_CLEARANCE) -> bool:
	for spot: Vector3 in keep_clear:
		if Vector2(x - spot.x, z - spot.y).length() < spot.z:
			return false
	for path: Dictionary in paths:
		var line: PackedVector2Array = path["line"] as PackedVector2Array
		for i: int in range(line.size() - 1):
			var closest: Vector2 = Geometry2D.get_closest_point_to_segment(Vector2(x, z), line[i], line[i + 1])
			if closest.distance_to(Vector2(x, z)) < float(path["width"]) * 0.5 + path_margin:
				return false
	return true


# ---- Obstacles -------------------------------------------------------------------------------


func _index_obstacles() -> void:
	obstacles.clear()
	for prop: Prop in props:
		if prop.radius > 0.0:
			obstacles.append(Vector3(prop.pos.x, prop.pos.z, prop.radius))
	for chest_id: Variant in chests.keys():
		var chest: Vector3 = chests[chest_id] as Vector3
		obstacles.append(Vector3(chest.x, chest.z, 0.18))
	for blocker: Vector3 in LANDMARK_BLOCKERS:
		obstacles.append(blocker)
