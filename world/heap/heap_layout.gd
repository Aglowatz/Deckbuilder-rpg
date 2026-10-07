class_name HeapLayout
extends RefCounted
## The Verdant Dump's map as plain data (no scene nodes), so it can be unit-tested headless: a rounded-rectangle
## stretch of farmland and junkyard with a recycling stream across it, compost pits, two junk mountains, patchwork
## fields, a scree field only a mount can cross, a wall of tires with gaps (one plugged by a junk barricade), named
## anchors, hidden chests, enemy homes, props and signs. `HeapBuilder` turns it into meshes; `HeapScene` makes it
## playable.
##
## Coordinates: metres, x east, z south, y up. The hub (The Compost Grange) is in the south; the recycling stream cuts
## the land in two; north of it are three districts (Rust Peak in the west, the Landfill Depths in the centre, the
## scree fields and the scrap barn in the east) separated by dividers and a wall of tires.

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

enum Surface { VOID, GROUND, PEAK, CLIFF, HAZARD, ROUGH }


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
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func build() -> void:
	_rng.seed = 8181
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
	var land: float = hills - (1.0 - edge) * 0.9
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
	_peak("rust", "Rust Peak", Vector2(16.0, 16.0), 6.0, 7.0)


func _chute(id: String, title: String, pos: Vector2, path: PackedVector2Array, dest: String) -> void:
	var chute: Chute = Chute.new()
	chute.id = id
	chute.title = title
	chute.pos = pos
	chute.path = path
	chute.dest_anchor = dest
	chutes.append(chute)


func _chutes() -> void:
	_chute("chute_a", "Trash Chute (Mount Scrapmore)", Vector2(83.6, 58.2), PackedVector2Array([Vector2(83.6, 58.2), Vector2(80.0, 61.5), Vector2(77.0, 63.0), Vector2(75.0, 62.5)]), "chute_a_end")
	_chute("chute_b", "Trash Chute (Rust Peak)", Vector2(20.0, 13.5), PackedVector2Array([Vector2(20.0, 13.5), Vector2(25.0, 10.5), Vector2(30.0, 11.0), Vector2(33.5, 13.0)]), "chute_b_end")


func _bridges() -> void:
	for x: float in [22.0, 50.0, 78.0]:
		var bridge: Bridge = Bridge.new()
		bridge.id = "bridge_west" if x < 30.0 else ("bridge_center" if x < 60.0 else "bridge_east")
		bridge.x = x
		bridges.append(bridge)


func _pits_and_scree() -> void:
	pits = [Vector3(84.0, 72.0, 3.2), Vector3(30.0, 66.0, 3.0)] as Array[Vector3]
	scree = [Vector3(79.0, 17.0, 13.5)] as Array[Vector3]


# ---- Anchors, chests, enemies -----------------------------------------------------------------


func _at(name: String, x: float, z: float) -> void:
	anchors[name] = Vector3(x, 0.0, z)


func _anchors() -> void:
	var wz: float = stream_z(22.0)
	var cz: float = stream_z(50.0)
	var ez: float = stream_z(78.0)
	# The Compost Grange (hub, south centre).
	_at("spawn", 50.0, 70.5)
	_at("rift_station", 43.0, 67.0)
	_at("hub", 50.0, 64.0)
	_at("exit", 50.0, 74.2)
	_at("heal", 41.0, 62.0)
	_at("hob", 60.5, 63.5)
	# Brief 16: Shiro Swindle's giant chest, on the heap's south-west shoulder.
	_at("giant_chest", 22.8, 73.8)
	_at("marigold", 50.0, 58.5)
	_at("wren", 43.5, 67.0)
	_at("compost_bin", 58.0, 69.5)
	_at("shrine", 66.0, 67.5)
	_at("trough", 64.0, 72.0)
	_at("stable_1", 35.0, 70.0)
	# Patchwork fields and the druid grove (south-west).
	_at("crop_1", 13.0, 57.0)
	_at("crop_2", 17.5, 57.0)
	_at("crop_3", 22.0, 57.0)
	_at("quiz", 19.0, 65.0)
	_at("pickup_bean_1", 9.0, 57.0)
	_at("pickup_fert_1", 13.0, 69.0)
	_at("pickup_junk_1", 26.0, 60.0)
	_at("animal_1", 27.0, 52.0)
	_at("animal_2", 31.0, 72.0)
	# The county fair grounds and Mount Scrapmore (south-east).
	_at("minigame", 74.0, 66.0)
	_at("pickup_bean_2", 92.0, 64.0)
	_at("pickup_fert_2", 69.5, 71.5)
	_at("pickup_junk_2", 68.0, 60.0)
	_at("animal_3", 90.0, 70.0)
	_at("mound_a", 86.0, 63.5)
	_at("ladder_a_top", 86.0, 58.5)
	_at("chute_a_end", 75.0, 62.5)
	# The stream crossings: south banks (where you grow things) and north banks (where you arrive).
	_at("sorrel", 46.0, cz + 5.8)
	_at("mound_west", 18.5, wz + 5.6)
	_at("mound_east", 74.5, ez + 5.6)
	_at("bank_west", 22.0, wz + 5.8)
	_at("bank_center", 50.0, cz + 5.8)
	_at("bank_east", 78.0, ez + 5.8)
	_at("land_west", 22.0, wz - 5.8)
	_at("land_center", 50.0, cz - 5.8)
	_at("land_east", 78.0, ez - 5.8)
	# The north bank.
	_at("stable_2", 62.0, 34.5)
	_at("pickup_bean_3", 30.0, 37.0)
	_at("pickup_fert_3", 86.0, 37.0)
	_at("pickup_junk_3", 44.0, 36.0)
	_at("barricade_dam", 36.5, 35.5)
	_at("barricade_gate", 50.0, WALL_Z)
	# Rust Peak district (north-west).
	_at("mound_b", 16.0, 24.5)
	_at("ladder_b_top", 16.0, 19.5)
	_at("puzzle", 16.0, 13.2)
	_at("chute_b_end", 33.5, 13.0)
	# The Landfill Depths and the closed door (north-centre).
	_at("mini_dungeon", 44.0, 10.0)
	_at("main_dungeon", 57.0, 10.0)


func _chests() -> void:
	chests = {
		"chest_fridge": Vector3(73.6, 0.0, 72.4),
		"chest_compost": Vector3(7.5, 0.0, 72.5),
		"chest_peak_a": Vector3(84.0, 0.0, 54.4),
		"chest_hay": Vector3(68.0, 0.0, 37.0),
		"chest_log": Vector3(26.0, 0.0, 7.0),
		"chest_peak_b": Vector3(12.5, 0.0, 14.0),
		"chest_car": Vector3(60.5, 0.0, 22.0),
		"chest_barn": Vector3(88.0, 0.0, 21.0),
		# Polish round: a third summit chest on each peak, one up the scree, three in the far corners.
		"chest_peak_c": Vector3(19.8, 0.0, 11.4),
		"chest_peak_d": Vector3(90.0, 0.0, 54.0),
		"chest_scree_ne": Vector3(82.2, 0.0, 4.8),
		"chest_corner_nw": Vector3(8.4, 0.0, 7.2),
		"chest_back_edge": Vector3(34.8, 0.0, 4.8),
		"chest_thicket_s": Vector3(4.8, 0.0, 28.2),
	}


func _enemies() -> void:
	enemy_spawns = [
		{"type": "golem", "home": Vector3(28.0, 0.0, 58.0), "patrol": 3.5},
		{"type": "scarecrow", "home": Vector3(79.0, 0.0, 72.0), "patrol": 2.5},
		{"type": "gulls", "home": Vector3(70.0, 0.0, 52.0), "patrol": 5.0},
		{"type": "golem", "home": Vector3(28.0, 0.0, 22.0), "patrol": 3.0},
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


func _areas() -> void:
	_area("hub", "The Compost Grange", 50.0, 64.0, 12.0)
	_area("fields", "The Patchwork Fields", 17.0, 59.0, 13.0)
	_area("grove", "The Appliance Grove", 19.0, 65.0, 4.5)
	_area("fair", "The County Fair Grounds", 73.0, 67.0, 9.0)
	_area("scrapmore_top", "Mount Scrapmore Summit", 86.0, 56.0, 6.0)
	_area("scrapmore", "Mount Scrapmore", 86.0, 58.0, 10.0)
	_area("stream", "The Recycling Stream", 50.0, 43.0, 6.0)
	_area("bank", "The North Bank", 50.0, 35.0, 14.0)
	_area("rust_top", "Rust Peak Summit", 16.0, 16.0, 7.5)
	_area("rust", "The Rust Peak Yards", 22.0, 18.0, 15.0)
	_area("landfill", "The Landfill Rim", 50.0, 17.0, 14.0)
	_area("scree", "The Scree Fields", 79.0, 17.0, 13.5)
	_area("meadow", "The Verdant Dump", 50.0, 45.0, 60.0)


func _paths() -> void:
	var hub: Vector2 = Vector2(50.0, 62.0)
	var wz: float = stream_z(22.0)
	var cz: float = stream_z(50.0)
	var ez: float = stream_z(78.0)
	paths = [
		{"line": PackedVector2Array([hub, Vector2(36.0, 58.0), Vector2(24.0, 60.0), Vector2(19.0, 64.0)]), "width": 2.4},
		{"line": PackedVector2Array([hub, Vector2(66.0, 64.0), Vector2(74.0, 64.0)]), "width": 2.4},
		{"line": PackedVector2Array([hub, Vector2(50.0, 54.0), Vector2(50.0, cz + 4.0)]), "width": 2.4},
		{"line": PackedVector2Array([Vector2(36.0, 58.0), Vector2(26.0, 52.0), Vector2(22.0, wz + 4.0)]), "width": 2.2},
		{"line": PackedVector2Array([Vector2(66.0, 64.0), Vector2(74.0, 54.0), Vector2(78.0, ez + 4.0)]), "width": 2.2},
		{"line": PackedVector2Array([Vector2(22.0, wz - 4.0), Vector2(22.0, 34.0), Vector2(50.0, 34.0), Vector2(78.0, 34.0), Vector2(78.0, ez - 4.0)]), "width": 2.2},
		{"line": PackedVector2Array([Vector2(50.0, cz - 4.0), Vector2(50.0, 34.0)]), "width": 2.2},
		{"line": PackedVector2Array([Vector2(22.0, 34.0), Vector2(22.0, 26.0), Vector2(16.0, 24.5)]), "width": 2.0},
		{"line": PackedVector2Array([Vector2(50.0, 34.0), Vector2(50.0, 12.0)]), "width": 2.4},
		{"line": PackedVector2Array([Vector2(44.0, 12.0), Vector2(57.0, 12.0)]), "width": 2.2},
		{"line": PackedVector2Array([hub, Vector2(40.0, 69.0), Vector2(35.0, 70.0)]), "width": 2.0},
		{"line": PackedVector2Array([Vector2(74.0, 64.0), Vector2(80.0, 63.0), Vector2(86.0, 63.5)]), "width": 2.0},
	]


func _flat_spots() -> void:
	flat_spots = [Vector3(50.0, 64.0, 14.0)] as Array[Vector3]
	for key: Variant in anchors.keys():
		var anchor: Vector3 = anchors[key] as Vector3
		flat_spots.append(Vector3(anchor.x, anchor.z, 3.2))
	for chute: Chute in chutes:
		flat_spots.append(Vector3(chute.pos.x, chute.pos.y, 2.0))
	for peak: Peak in peaks:
		flat_spots.append(Vector3(peak.center.x, peak.center.y, peak.radius + CLIFF_WIDTH + 1.0))
	flat_spots.append(Vector3(22.0, 34.0, 5.0))
	flat_spots.append(Vector3(50.0, 34.0, 5.0))
	flat_spots.append(Vector3(78.0, 34.0, 5.0))


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
	# The Compost Grange: a scrap-built barn on the north side, a scrap windmill, the harvest table, the swap shed,
	# the compost bin, the druid shrine, the trough, a stable and the arch back down to the Path of the Refusemancer.
	_prop("barn", 50.0, 53.4, 0.0, 1.0, 4.2)
	_prop("windmill", 38.0, 54.5, 0.0, 1.0, 1.5)
	_prop("windmill", 63.0, 54.5, 0.0, 0.85, 1.3)
	_prop("harvest_table", 41.0, 62.0, 90.0, 1.0, 1.5)
	_prop("swap_shed", 60.5, 65.4, 200.0, 1.0, 1.2)
	_prop("compost_bin", 58.0, 69.5, 180.0, 1.0, 1.4)
	_prop("shrine", 66.0, 67.5, 0.0, 1.0, 1.2)
	_prop("trough", 64.0, 72.0, 0.0, 1.0, 1.2)
	_prop("stable", 35.0, 70.0, 0.0, 1.0, 1.8)
	_prop("arch", 50.0, 75.4, 0.0, 1.0, 0.0)
	# The patchwork fields and the grove (south-west).
	_prop("crop_plot", 13.0, 57.0, 0.0, 1.0, 0.0, 0)
	_prop("crop_plot", 17.5, 57.0, 0.0, 1.0, 0.0, 1)
	_prop("crop_plot", 22.0, 57.0, 0.0, 1.0, 0.0, 2)
	_prop("appliance_ring", 19.0, 64.0, 0.0, 1.0, 0.0)
	_prop("compost_heap", 8.5, 71.4, 0.0, 1.0, 0.0)
	_prop("scarecrow", 17.5, 53.0, 20.0, 1.0, 0.7)
	# The county fair grounds and Mount Scrapmore (south-east).
	_prop("fair_stage", 74.0, 63.6, 0.0, 1.0, 1.9)
	_prop("fridge", 76.5, 72.8, 200.0, 1.0, 0.9)
	_prop("haybale", 70.0, 58.0, 30.0, 1.0, 1.0, 0)
	_prop("beanstalk_mound", 86.0, 63.5, 0.0, 1.0, 0.0, 0)
	_prop("beanstalk_mound", 18.5, stream_z(22.0) + 5.6, 0.0, 1.0, 0.0, 1)
	_prop("beanstalk_mound", 74.5, stream_z(78.0) + 5.6, 0.0, 1.0, 0.0, 2)
	_prop("beanstalk_mound", 16.0, 24.5, 0.0, 1.0, 0.0, 3)
	# The north bank: the junk dam, a haybale for the chest, the second stable.
	_prop("junk_dam", 36.5, 35.5, 0.0, 1.0, 0.0)
	_prop("haybale", 66.5, 37.6, 10.0, 1.0, 1.0, 1)
	_prop("stable", 62.0, 34.5, 0.0, 1.0, 1.8)
	# Rust Peak yards: the hollow log, rusted cars and tyre heaps.
	_prop("hollow_log", 26.0, 8.5, 10.0, 1.0, 0.0)
	_prop("car_husk", 30.0, 26.0, 40.0, 1.0, 1.7, 0)
	_prop("junk_pile", 8.5, 24.0, 0.0, 1.2, 2.4, 0)
	_prop("junk_pile", 31.0, 16.5, 0.0, 1.0, 2.2, 1)
	# The Landfill Depths, the closed door, the cars and heaps of the rim.
	_prop("landfill_gate", 44.0, 7.8, 0.0, 1.0, 3.0)
	_prop("composting_door", 57.0, 7.8, 0.0, 1.0, 3.0)
	_prop("car_husk", 61.5, 24.0, 160.0, 1.0, 1.7, 1)
	_prop("car_husk", 39.5, 20.0, 80.0, 1.0, 1.7, 2)
	_prop("junk_pile", 46.0, 25.0, 0.0, 1.1, 2.3, 2)
	_prop("junk_pile", 56.0, 19.5, 0.0, 1.3, 2.6, 0)
	_prop("tire_stack", 38.5, 12.5, 0.0, 1.0, 1.0)
	_prop("tire_stack", 62.0, 15.0, 0.0, 1.0, 1.0)
	# The scree fields: a scrap barn and scrap windmills, hay, wrecks.
	_prop("barn", 82.0, 14.0, 0.0, 0.9, 3.8)
	_prop("windmill", 70.0, 10.0, 0.0, 1.0, 1.5)
	_prop("windmill", 90.0, 28.0, 0.0, 0.9, 1.4)
	_prop("car_husk", 88.0, 11.0, 200.0, 1.0, 1.7, 3)
	_prop("junk_pile", 72.0, 24.0, 0.0, 1.0, 2.2, 1)
	_prop("haybale", 92.0, 18.0, 0.0, 1.0, 1.0, 2)
	# Standing wrecks and a washing-machine pile along the roads.
	_prop("appliance_pile", 44.0, 52.0, 20.0, 1.0, 0.0)
	_prop("appliance_pile", 57.0, 52.0, -25.0, 1.0, 0.0)
	_prop("car_husk", 33.0, 40.0, 10.0, 1.0, 1.7, 0)
	_prop("tire_stack", 66.0, 40.0, 0.0, 1.0, 1.0)


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
	for divider_x: float in [36.0, 64.0]:
		var z: float = 5.0
		while z <= WALL_Z - 1.0:
			_prop("divider", divider_x, z, 0.0, 1.0, 0.55, int(z) % 3)
			z += 1.0
	barricade_positions["gate"] = Vector3(50.0, 0.0, WALL_Z)
	barricade_positions["dam"] = Vector3(36.5, 0.0, 35.5)


func _sign(key: String, x: float, z: float, yaw: float = 180.0, size: float = 1.0, style: String = "sign") -> void:
	var sign: Sign = Sign.new()
	sign.key = key
	sign.pos = Vector3(x, 0.0, z)
	sign.yaw = 180.0 + clampf(yaw - 180.0, -12.0, 12.0)
	sign.size = size
	sign.style = style
	signs.append(sign)


func _signs() -> void:
	var wz: float = stream_z(22.0)
	var cz: float = stream_z(50.0)
	var ez: float = stream_z(78.0)
	_sign("sign.hub_main", 50.0, 67.6, 180.0, 1.2)
	_sign("sign.hub_motto", 46.0, 58.2, 170.0, 1.0, "menu")
	_sign("sign.exit", 54.0, 73.0, 180.0)
	_sign("sign.heal_table", 43.5, 63.4, 180.0)
	_sign("sign.swap_shed", 63.5, 62.5, 200.0)
	_sign("sign.compost_bin", 55.5, 71.5, 160.0)
	_sign("sign.shrine", 68.8, 66.0, 190.0)
	_sign("sign.trough", 61.5, 73.5, 170.0, 0.9, "memo")
	_sign("sign.stable_1", 37.8, 71.5, 160.0)
	_sign("sign.oath", 54.5, 58.2, 190.0, 1.0, "poster")
	_sign("sign.fields", 24.5, 54.5, 150.0)
	_sign("sign.crops", 14.5, 59.4, 180.0, 0.9, "memo")
	_sign("sign.grove", 22.4, 66.6, 190.0)
	_sign("sign.fair", 69.5, 61.0, 170.0)
	_sign("sign.fair_stage", 70.8, 66.4, 180.0)
	_sign("sign.scrapmore", 82.0, 66.4, 180.0)
	_sign("sign.beanstalk_rule", 88.8, 65.4, 200.0, 0.9, "memo")
	_sign("sign.stream", 26.0, wz + 5.0, 190.0)
	_sign("sign.stream_warning", 46.0, cz + 8.4, 180.0, 0.9, "memo")
	_sign("sign.bridge_west", 17.0, wz + 7.6, 180.0)
	_sign("sign.bridge_center", 53.8, cz + 7.6, 200.0)
	_sign("sign.bridge_east", 74.0, ez + 7.6, 180.0)
	_sign("sign.bank", 40.0, 38.0, 170.0)
	_sign("sign.dam", 33.4, 37.6, 190.0)
	_sign("sign.stable_2", 59.4, 36.0, 170.0)
	_sign("sign.barricade", 53.8, 32.4, 190.0)
	_sign("sign.rust", 20.5, 28.2, 180.0)
	_sign("sign.landfill", 47.4, 11.8, 180.0)
	_sign("sign.main_dungeon", 57.0, 12.6, 180.0, 1.5)
	_sign("sign.inspector_note", 60.0, 12.4, 190.0, 0.9, "memo")
	_sign("sign.seed_shrine", 12.8, 15.5, 190.0)
	_sign("sign.scree", 74.0, 30.2, 170.0)
	_sign("sign.scree_rule", 82.4, 30.4, 190.0, 0.9, "memo")
	_sign("sign.junk_menu", 52.0, 26.5, 180.0, 1.0, "menu")
	_sign("sign.log_note", 23.5, 10.4, 190.0, 0.9, "memo")


## Trees, bushes, flowers and rocks scattered over the land, kept clear of paths, anchors and features.
func _scatter() -> void:
	var keep_clear: Array[Vector3] = []
	for key: Variant in anchors.keys():
		var anchor: Vector3 = anchors[key] as Vector3
		keep_clear.append(Vector3(anchor.x, anchor.z, 3.4))
	for chest_id: Variant in chests.keys():
		var chest: Vector3 = chests[chest_id] as Vector3
		keep_clear.append(Vector3(chest.x, chest.z, 1.4))
	for feature: Prop in props:
		if feature.kind == "wall_tires" or feature.kind == "divider":
			keep_clear.append(Vector3(feature.pos.x, feature.pos.z, 1.2))
		else:
			keep_clear.append(Vector3(feature.pos.x, feature.pos.z, 3.0 if feature.radius > 0.0 else 2.2))
	for spawn: Dictionary in enemy_spawns:
		var home: Vector3 = spawn["home"] as Vector3
		keep_clear.append(Vector3(home.x, home.z, 3.0))
	for chute: Chute in chutes:
		for point: Vector2 in chute.path:
			keep_clear.append(Vector3(point.x, point.y, 2.2))
	keep_clear.append(Vector3(50.0, 64.0, 13.0))
	# Overgrown woods and bushes.
	_scatter_kind("tree", Rect2(5.0, 5.0, 30.0, 24.0), 14, keep_clear, 1.6, 0.5, 1.0, 1.4)
	_scatter_kind("tree", Rect2(36.0, 31.0, 28.0, 8.0), 6, keep_clear, 1.8, 0.5, 1.0, 1.3)
	_scatter_kind("tree", Rect2(5.0, 50.0, 30.0, 25.0), 16, keep_clear, 1.6, 0.5, 1.0, 1.4)
	_scatter_kind("tree", Rect2(36.0, 48.0, 30.0, 6.0), 6, keep_clear, 1.8, 0.5, 1.0, 1.3)
	_scatter_kind("tree", Rect2(66.0, 48.0, 28.0, 27.0), 10, keep_clear, 1.8, 0.5, 1.0, 1.3)
	_scatter_kind("tree", Rect2(5.0, 31.0, 90.0, 10.0), 10, keep_clear, 1.8, 0.5, 1.0, 1.3)
	_scatter_kind("bush", Rect2(5.0, 5.0, 90.0, 70.0), 40, keep_clear, 1.0, 0.45, 0.9, 1.4)
	_scatter_kind("flowers", Rect2(5.0, 5.0, 90.0, 70.0), 40, keep_clear, 0.8, 0.0, 0.9, 1.4)
	_scatter_kind("rock", Rect2(5.0, 5.0, 90.0, 70.0), 24, keep_clear, 1.8, 0.0, 0.9, 1.6)
	_scatter_kind("mushrooms", Rect2(5.0, 5.0, 40.0, 70.0), 14, keep_clear, 1.0, 0.0, 0.9, 1.4)
	_scatter_kind("tire_stack", Rect2(5.0, 5.0, 90.0, 70.0), 16, keep_clear, 1.6, 0.9, 0.9, 1.2)


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
		if surface != Surface.GROUND and not (surface == Surface.ROUGH and kind in ["rock", "tire_stack", "bush"]):
			continue
		if not _is_clear(x, z, keep_clear):
			continue
		_prop(kind, x, z, _rng.randf() * 360.0, _rng.randf_range(scale_min, scale_max), radius, _rng.randi() % 4)
		keep_clear.append(Vector3(x, z, gap + radius))
		placed += 1


func _is_clear(x: float, z: float, keep_clear: Array[Vector3]) -> bool:
	for spot: Vector3 in keep_clear:
		if Vector2(x - spot.x, z - spot.y).length() < spot.z:
			return false
	for path: Dictionary in paths:
		var line: PackedVector2Array = path["line"] as PackedVector2Array
		for i: int in range(line.size() - 1):
			var closest: Vector2 = Geometry2D.get_closest_point_to_segment(Vector2(x, z), line[i], line[i + 1])
			if closest.distance_to(Vector2(x, z)) < float(path["width"]) * 0.5 + 1.0:
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
