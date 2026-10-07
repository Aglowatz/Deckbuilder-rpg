class_name GainlandsLayout
extends RefCounted
## The Gainlands' map as plain data (no scene nodes), so it can be unit-tested headless: the rolling
## main land, the floating islands, named anchors, hidden chests, enemy homes, props (mills, hamster
## wheels, boulder gym equipment, trees), energy pipes, signs and named areas. `GainlandsBuilder`
## turns it into meshes; `GainlandsScene` makes it playable.
##
## Coordinates: metres, x east, z south, y up. The main land is a wobbly ellipse; the hub (The Swole
## Station) is in the south, the zone gets wilder to the north. The islands hover OUTSIDE the main
## land's footprint (so 2D walkability is unambiguous and the camera never looks through one), high
## above the clouds, and are only reachable by thrower or portal (see `GainlandsTravel`).

const CENTER: Vector2 = Vector2(52.0, 46.0)
const RADII: Vector2 = Vector2(44.0, 34.0)
## How far past an island's edge the player can still step before falling (metres).
const FALL_MARGIN: float = 0.9
## Terrain mesh resolution (metres per cell).
const TERRAIN_STEP: float = 2.0
## Depth of the main land's cliff skirt below the grass.
const CLIFF_DEPTH: float = 16.0

enum Surface { VOID, GROUND, ISLAND, RIM }


class Island:
	extends RefCounted
	var id: String = ""
	var title: String = ""
	var center: Vector2 = Vector2.ZERO
	var radius: float = 7.0
	var height: float = 10.0


class Prop:
	extends RefCounted
	## "mill", "wheel", "bench_press", "log_rack", "dumbbell_rack", "boulder", "tree", "hut", "arch",
	## "gate", "cavern", "stage", "tub", "stall", "mirror", "station", "pylon", "crystal"
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
## [{type, home, patrol}] for the roaming enemies.
var enemy_spawns: Array[Dictionary] = []
## Hidden chest positions by id (never on the map).
var chests: Dictionary = {}
## Energy pipes: polylines of Vector2 (xz), laid on the terrain.
var pipes: Array[PackedVector2Array] = []
## Dirt paths: [polyline, width].
var paths: Array[Dictionary] = []
## Spots where the terrain is levelled flat at height 0: [Vector3(x, z, radius)].
var flat_spots: Array[Vector3] = []
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


# ---- Ground ----------------------------------------------------------------------------------


static func radius_factor(angle: float) -> float:
	return 1.0 + 0.05 * sin(3.0 * angle + 0.6) + 0.035 * sin(5.0 * angle + 2.0) + 0.02 * sin(9.0 * angle)


## Normalised distance from the main land's centre: < 1 is inside (relative to the wobbly edge).
static func main_depth(x: float, z: float) -> float:
	var v: float = (x - CENTER.x) / RADII.x
	var w: float = (z - CENTER.y) / RADII.y
	var distance: float = sqrt(v * v + w * w)
	return distance / radius_factor(atan2(w, v))


static func is_main_ground(x: float, z: float) -> bool:
	return main_depth(x, z) <= 1.0


## Metres from the edge of the main land (positive inside).
static func main_edge_distance(x: float, z: float) -> float:
	return (1.0 - main_depth(x, z)) * minf(RADII.x, RADII.y)


func island_at(x: float, z: float) -> Island:
	for island: Island in islands:
		if Vector2(x - island.center.x, z - island.center.y).length() <= island.radius + FALL_MARGIN:
			return island
	return null


## What is under (x, z): main ground, an island's top, the unfenced rim just past an island's edge
## (stepping there means falling), or nothing.
func surface_at(x: float, z: float) -> Surface:
	if is_main_ground(x, z):
		return Surface.GROUND
	var island: Island = island_at(x, z)
	if island == null:
		return Surface.VOID
	var distance: float = Vector2(x - island.center.x, z - island.center.y).length()
	return Surface.ISLAND if distance <= island.radius else Surface.RIM


## Rolling hills on the main land, flattened around buildings and the hub; flat on islands.
func ground_height(x: float, z: float) -> float:
	var island: Island = island_at(x, z)
	if island != null and not is_main_ground(x, z):
		return island.height
	var hills: float = 1.15 * sin(x * 0.085 + 0.7) * cos(z * 0.10 + 0.3) + 0.45 * sin(x * 0.19 + z * 0.07 + 1.0) + 0.35 * cos(z * 0.17 - x * 0.05)
	var flat: float = 1.0
	for spot: Vector3 in flat_spots:
		var distance: float = Vector2(x - spot.x, z - spot.y).length()
		flat = minf(flat, smoothstep(spot.z * 0.7, spot.z * 1.3, distance))
	# The very edge of the plateau rolls down a little so it reads as a cliff top.
	var edge: float = clampf(main_edge_distance(x, z) / 5.0, 0.0, 1.0)
	return hills * flat - (1.0 - edge) * 0.8


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
	_island("pec", "Pec Perch", Vector2(14.0, 14.0), 8.0, 11.0)
	_island("delt", "Delt Deck", Vector2(90.0, 10.0), 7.0, 14.0)
	_island("glute", "Glute Garden", Vector2(110.0, 52.0), 7.0, 9.0)
	_island("calf", "Calf Cove", Vector2(-6.0, 56.0), 6.5, 7.0)


func _at(name: String, x: float, z: float) -> void:
	anchors[name] = Vector3(x, 0.0, z)


func _anchors() -> void:
	# The Swole Station hub (south of the main land).
	_at("spawn", 52.0, 68.0)
	_at("rift_station", 58.5, 66.0)
	_at("hub", 52.0, 64.0)
	_at("exit", 52.0, 74.0)
	_at("heal", 44.0, 62.0)
	_at("tony", 61.0, 63.0)
	# Brief 16: Shiro Swindle's giant chest, tucked out west of the hub (see NinjaBoss).
	_at("giant_chest", 24.0, 63.6)
	_at("brenda", 52.0, 59.5)
	_at("gus", 45.0, 68.0)
	_at("station", 52.0, 55.0)
	_at("protein_stand", 61.0, 69.0)
	_at("flex_mirror", 41.0, 68.0)
	# Fields.
	_at("quiz", 22.0, 40.0)
	_at("minigame", 69.0, 52.0)
	_at("puzzle", 77.0, 44.0)
	_at("run_wheel", 86.0, 42.6)
	_at("spot_me", 71.0, 68.0)
	_at("mini_dungeon", 66.0, 25.0)
	_at("main_dungeon", 50.0, 19.0)
	# Travel points on the main land.
	_at("thrower_pec", 32.0, 26.0)
	_at("ripper_delt", 70.0, 26.0)
	_at("thrower_east", 88.0, 46.0)
	_at("thrower_west", 16.0, 48.0)
	# Landing spots on the main land (where throws and portals from the islands arrive).
	_at("land_pec", 33.0, 29.0)
	_at("land_delt", 70.0, 29.0)
	_at("land_glute", 85.0, 49.0)
	_at("land_calf", 18.0, 51.0)
	_at("land_west", 18.0, 46.0)
	_at("land_east", 86.0, 44.0)
	# Island 1: Pec Perch.
	_at("arrive_pec", 13.0, 12.0)
	_at("thrower_pec_back", 17.0, 17.0)
	_at("flex_mirror_pec", 10.0, 16.0)
	_at("ripper_calf", 10.0, 10.0)
	# Island 2: Delt Deck.
	_at("arrive_delt", 91.0, 9.0)
	_at("ripper_delt_back", 88.0, 13.0)
	_at("thrower_glute", 94.0, 12.0)
	# Island 3: Glute Garden.
	_at("arrive_glute", 107.0, 50.0)
	_at("thrower_glute_back", 108.0, 55.0)
	# Island 4: Calf Cove.
	_at("arrive_calf", -4.0, 55.0)
	_at("ripper_calf_back", -3.0, 59.0)


func _chests() -> void:
	chests = {
		"chest_ground_0": Vector3(18.0, 0.0, 36.0),
		"chest_ground_1": Vector3(78.0, 0.0, 64.0),
		"chest_ground_2": Vector3(58.0, 0.0, 22.0),
		"chest_pec": Vector3(7.8, 0.0, 13.0),
		"chest_delt": Vector3(95.0, 0.0, 7.0),
		"chest_glute": Vector3(114.0, 0.0, 54.0),
		"chest_calf": Vector3(-10.0, 0.0, 58.0),
		# Polish round: a second chest on each floating island (throw or portal only) and two tucked away on the main land.
		"chest_pec_2": Vector3(19.0, 0.0, 11.1),
		"chest_delt_2": Vector3(85.2, 0.0, 7.5),
		"chest_glute_2": Vector3(111.5, 0.0, 46.6),
		"chest_calf_2": Vector3(-8.8, 0.0, 51.5),
		"chest_ground_3": Vector3(93.0, 0.0, 36.0),
		"chest_ground_4": Vector3(17.4, 0.0, 25.2),
	}


func _enemies() -> void:
	enemy_spawns = [
		{"type": "brute", "home": Vector3(34.0, 0.0, 50.0), "patrol": 4.0},
		{"type": "brute", "home": Vector3(74.0, 0.0, 62.0), "patrol": 4.0},
		{"type": "golem", "home": Vector3(44.0, 0.0, 34.0), "patrol": 3.5},
		{"type": "golem", "home": Vector3(84.0, 0.0, 54.0), "patrol": 3.5},
		{"type": "sprite", "home": Vector3(56.0, 0.0, 40.0), "patrol": 7.0},
		{"type": "sprite", "home": Vector3(30.0, 0.0, 60.0), "patrol": 6.0},
	]


func _area(id: String, title: String, x: float, z: float, radius: float) -> void:
	var area: Area = Area.new()
	area.id = id
	area.title = title
	area.center = Vector2(x, z)
	area.radius = radius
	areas.append(area)


func _areas() -> void:
	_area("hub", "The Swole Station", 52.0, 64.0, 12.0)
	_area("mills", "Mill Meadow", 30.0, 42.0, 16.0)
	_area("wheels", "Hamster Wheel Heights", 82.0, 40.0, 14.0)
	_area("gym", "The Boulder Gym", 72.0, 68.0, 11.0)
	_area("studio", "Studio 3AM", 69.0, 52.0, 6.0)
	_area("north", "Leg Day Ridge", 56.0, 22.0, 20.0)
	_area("field", "The Gainlands", 52.0, 46.0, 60.0)
	for island: Island in islands:
		_area("island_" + island.id, island.title, island.center.x, island.center.y, island.radius + 1.0)


func _paths_and_pipes() -> void:
	var hub: Vector2 = Vector2(52.0, 62.0)
	paths = [
		{"line": PackedVector2Array([hub, Vector2(48.0, 52.0), Vector2(36.0, 42.0), Vector2(24.0, 40.0)]), "width": 2.4},
		{"line": PackedVector2Array([hub, Vector2(62.0, 54.0), Vector2(72.0, 50.0), Vector2(80.0, 42.0)]), "width": 2.4},
		{"line": PackedVector2Array([hub, Vector2(52.0, 44.0), Vector2(50.0, 30.0), Vector2(50.0, 20.0)]), "width": 2.4},
		{"line": PackedVector2Array([Vector2(50.0, 30.0), Vector2(60.0, 26.0), Vector2(70.0, 26.0)]), "width": 2.0},
		{"line": PackedVector2Array([Vector2(50.0, 30.0), Vector2(40.0, 27.0), Vector2(32.0, 26.0)]), "width": 2.0},
		{"line": PackedVector2Array([hub, Vector2(64.0, 68.0), Vector2(71.0, 68.0)]), "width": 2.2},
		{"line": PackedVector2Array([Vector2(80.0, 42.0), Vector2(86.0, 46.0), Vector2(88.0, 46.0)]), "width": 2.0},
		{"line": PackedVector2Array([Vector2(24.0, 40.0), Vector2(18.0, 46.0), Vector2(16.0, 48.0)]), "width": 2.0},
	]
	pipes = [
		PackedVector2Array([Vector2(82.0, 44.0), Vector2(79.0, 52.0), Vector2(74.0, 58.0), Vector2(66.0, 60.5), Vector2(58.0, 61.0)]),
		PackedVector2Array([Vector2(46.0, 56.0), Vector2(38.0, 50.0), Vector2(28.0, 46.0), Vector2(22.0, 50.0)]),
		PackedVector2Array([Vector2(28.0, 46.0), Vector2(30.0, 36.0), Vector2(32.0, 32.0)]),
		PackedVector2Array([Vector2(86.0, 36.0), Vector2(80.0, 30.0), Vector2(72.0, 28.0)]),
	]


func _flat_spots() -> void:
	flat_spots = [
		Vector3(52.0, 64.0, 13.0), Vector3(22.0, 40.0, 4.5), Vector3(69.0, 52.0, 5.5), Vector3(77.0, 44.0, 4.0),
		Vector3(83.0, 38.0, 6.5), Vector3(72.0, 68.0, 8.0), Vector3(66.0, 25.0, 6.0), Vector3(50.0, 19.0, 7.0),
		Vector3(32.0, 26.0, 3.5), Vector3(70.0, 26.0, 3.5), Vector3(88.0, 46.0, 3.5), Vector3(16.0, 48.0, 3.5),
		Vector3(22.0, 52.0, 4.5), Vector3(30.0, 32.0, 4.5), Vector3(40.0, 46.0, 4.5), Vector3(78.0, 28.0, 5.5),
		Vector3(90.0, 58.0, 5.0),
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
	# The hub: the Station building, hot tub, vendor stall, the arch back to the Beefcake Path.
	# The Station is the KayKit tavern at 2.5x: about 2.9 m wide and 3.3 m deep, so four 1 m colliders trace its real footprint (a single 4 m circle used to wall off the hub from the north fields).
	_prop("station", 52.0, 53.5, 0.0, 1.0, 0.0)
	for foot: Vector2 in [Vector2(-0.55, -0.9), Vector2(0.55, -0.9), Vector2(-0.55, 0.7), Vector2(0.55, 0.7)]:
		_prop("pylon", 52.0 + foot.x, 53.5 + foot.y, 0.0, 1.0, 1.0)
	_prop("tub", 44.0, 62.0, 0.0, 1.0, 1.7)
	_prop("stall", 63.0, 64.5, 200.0, 1.0, 1.4)
	_prop("arch", 52.0, 75.0, 0.0, 1.0, 0.0)
	_prop("stall", 61.0, 70.5, 160.0, 0.9, 1.2, 1)
	_prop("mirror", 41.0, 66.8, 90.0, 1.0, 0.7)
	# Giant mills (west) - the KayKit windmill at 3x, sails spinning.
	_prop("mill", 22.0, 52.0, 20.0, 3.0, 3.0)
	_prop("mill", 30.0, 32.0, -30.0, 3.4, 3.2)
	_prop("mill", 40.0, 46.0, 200.0, 2.8, 2.8)
	# Colossal hamster wheels (east), the first one is the one you can run.
	_prop("wheel", 86.0, 38.0, 0.0, 1.0, 0.0, 0)
	_prop("wheel", 78.0, 30.0, 0.0, 0.85, 0.0, 1)
	_prop("wheel", 92.0, 58.0, 0.0, 0.75, 0.0, 2)
	# Wheel stands collide, the wheel itself is walk-through.
	for stand: Vector3 in [Vector3(86.0, 36.2, 0.7), Vector3(86.0, 39.8, 0.7), Vector3(78.0, 28.5, 0.6), Vector3(78.0, 31.5, 0.6), Vector3(92.0, 56.7, 0.55), Vector3(92.0, 59.3, 0.55)]:
		_prop("pylon", stand.x, stand.y, 0.0, 1.0, stand.z)
	# Mini dungeon cavern, main dungeon gate, the studio stage.
	_prop("cavern", 66.0, 22.0, 0.0, 1.0, 3.0)
	_prop("gate", 50.0, 15.0, 0.0, 1.0, 0.0)
	_prop("stage", 69.0, 49.5, 0.0, 1.0, 2.2)
	_prop("hut", 22.0, 37.0, 0.0, 1.0, 1.5)
	# Outdoor gym equipment, boulders and logs (south-east).
	_prop("bench_press", 66.0, 72.0, 10.0, 1.0, 1.4)
	_prop("bench_press", 76.0, 72.0, -10.0, 1.0, 1.4)
	_prop("dumbbell_rack", 79.0, 68.0, 90.0, 1.0, 1.4)
	_prop("log_rack", 70.0, 63.0, 0.0, 1.0, 1.0)
	_prop("log_rack", 74.0, 75.0, 180.0, 1.0, 1.0)
	_prop("barbell", 71.0, 69.5, 0.0, 1.0, 0.0)
	_prop("boulder", 62.0, 76.0, 0.0, 1.6, 1.2, 1)
	_prop("boulder", 80.0, 74.0, 40.0, 1.3, 1.0, 3)
	# Island dressing: the thrower platforms, the mirror, crystals.
	_prop("crystal", 12.0, 14.0, 0.0, 1.0, 0.5)
	_prop("crystal", 92.0, 11.0, 0.0, 1.0, 0.5)
	_prop("crystal", 109.0, 51.0, 0.0, 1.0, 0.5)
	_prop("crystal", -5.0, 57.0, 0.0, 1.0, 0.5)
	_prop("mirror", 10.0, 17.3, 0.0, 1.0, 0.7)


func _sign(key: String, x: float, z: float, yaw: float = 0.0, size: float = 1.0, style: String = "sign") -> void:
	var sign: Sign = Sign.new()
	sign.key = key
	sign.pos = Vector3(x, 0.0, z)
	sign.yaw = 180.0 + clampf(yaw - 180.0, -12.0, 12.0)
	sign.size = size
	sign.style = style
	signs.append(sign)


func _signs() -> void:
	_sign("sign.hub_main", 52.0, 66.0, 180.0, 1.2)
	_sign("sign.hub_power", 47.0, 59.0, 160.0)
	_sign("sign.exit", 55.5, 73.0, 180.0)
	_sign("sign.heal_tub", 45.5, 64.5, 180.0)
	_sign("sign.protein_stand", 62.5, 67.5, 200.0)
	_sign("sign.flex_mirror", 42.5, 65.5, 180.0)
	_sign("sign.vendor", 64.5, 61.5, 200.0)
	_sign("sign.mills", 27.0, 44.0, 90.0)
	_sign("sign.quiz", 24.0, 41.5, 160.0)
	_sign("sign.studio", 66.5, 55.5, 180.0)
	_sign("sign.puzzle", 76.0, 46.5, 180.0)
	_sign("sign.wheel", 83.0, 44.0, 180.0)
	_sign("sign.gym", 70.0, 65.5, 180.0)
	_sign("sign.spot_me", 75.5, 66.8, 180.0)
	_sign("sign.thrower_rule", 34.6, 28.0, 150.0)
	_sign("sign.ripper_rule", 66.8, 28.0, 200.0)
	_sign("sign.thrower_east", 90.4, 47.8, 200.0)
	_sign("sign.thrower_west", 13.6, 49.8, 160.0)
	_sign("sign.mini_dungeon", 64.0, 26.5, 180.0)
	_sign("sign.main_dungeon", 50.0, 18.0, 180.0, 1.6)
	_sign("sign.leg_day_note", 54.0, 18.5, 180.0, 0.9, "memo")
	_sign("sign.energy_poster", 48.0, 58.0, 200.0, 1.0, "poster")
	_sign("sign.beefcake_poster", 56.5, 58.0, 160.0, 1.0, "poster")
	_sign("sign.pec_perch", 15.0, 15.5, 180.0)
	_sign("sign.delt_deck", 89.0, 11.5, 180.0)
	_sign("sign.glute_garden", 108.0, 53.0, 180.0)
	_sign("sign.calf_cove", -3.0, 57.5, 180.0)
	_sign("sign.edge_warning", 17.0, 10.0, 200.0, 0.9, "memo")
	_sign("sign.edge_warning", 87.0, 7.0, 200.0, 0.9, "memo")
	_sign("sign.hamster_fact", 24.0, 49.0, 120.0, 0.9, "memo")


## Trees and rocks scattered over the main land, kept clear of paths, anchors and features.
func _scatter() -> void:
	var keep_clear: Array[Vector3] = []
	for key: Variant in anchors.keys():
		var anchor: Vector3 = anchors[key] as Vector3
		keep_clear.append(Vector3(anchor.x, anchor.z, 3.2))
	for chest_id: Variant in chests.keys():
		var chest: Vector3 = chests[chest_id] as Vector3
		keep_clear.append(Vector3(chest.x, chest.z, 1.1))
	for feature: Prop in props:
		keep_clear.append(Vector3(feature.pos.x, feature.pos.z, 3.0 if feature.radius > 0.0 else 2.0))
	for spawn: Dictionary in enemy_spawns:
		var home: Vector3 = spawn["home"] as Vector3
		keep_clear.append(Vector3(home.x, home.z, 2.5))
	var placed: int = 0
	var attempts: int = 0
	while placed < 150 and attempts < 4000:
		attempts += 1
		var x: float = _rng.randf_range(CENTER.x - RADII.x, CENTER.x + RADII.x)
		var z: float = _rng.randf_range(CENTER.y - RADII.y, CENTER.y + RADII.y)
		if main_edge_distance(x, z) < 1.8 or not _is_clear(x, z, keep_clear):
			continue
		_prop("tree", x, z, _rng.randf() * 360.0, _rng.randf_range(1.1, 1.8), 0.4, _rng.randi() % 2)
		keep_clear.append(Vector3(x, z, 1.0))
		placed += 1
	var rocks: int = 0
	attempts = 0
	while rocks < 40 and attempts < 2000:
		attempts += 1
		var rx: float = _rng.randf_range(CENTER.x - RADII.x, CENTER.x + RADII.x)
		var rz: float = _rng.randf_range(CENTER.y - RADII.y, CENTER.y + RADII.y)
		if main_edge_distance(rx, rz) < 1.5 or not _is_clear(rx, rz, keep_clear):
			continue
		_prop("boulder", rx, rz, _rng.randf() * 360.0, _rng.randf_range(0.8, 1.5), 0.0, _rng.randi() % 5)
		keep_clear.append(Vector3(rx, rz, 1.2))
		rocks += 1
	# A few trees and boulders on each island, away from the travel points and the chest.
	for island: Island in islands:
		var on_island: int = 0
		var tries: int = 0
		while on_island < 5 and tries < 200:
			tries += 1
			var angle: float = _rng.randf() * TAU
			var distance: float = _rng.randf_range(island.radius * 0.45, island.radius * 0.8)
			var tx: float = island.center.x + cos(angle) * distance
			var tz: float = island.center.y + sin(angle) * distance
			if not _is_clear(tx, tz, keep_clear):
				continue
			_prop("tree" if on_island % 2 == 0 else "boulder", tx, tz, _rng.randf() * 360.0, _rng.randf_range(1.0, 1.4), 0.4 if on_island % 2 == 0 else 0.0, _rng.randi() % 2)
			keep_clear.append(Vector3(tx, tz, 1.2))
			on_island += 1


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
