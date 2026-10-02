class_name BuffetLayout
extends RefCounted
## The Endless Buffet's map as plain data (no scene nodes), so it can be unit-tested headless: the
## rounded-rectangle table the whole zone sits on, the Gravy River with its crossings (crouton rafts and a
## rotating lazy susan), the pancake / cheese / butter mesas that only the jelly bounce pads reach, the picket
## fence of giant forks with its three golem gates, anchors, hidden chests, enemy homes, props and signs.
## `BuffetBuilder` turns it into meshes; `BuffetScene` makes it playable.
##
## Coordinates: metres, x east, z south, y up. The hub (The Grand Pantry) is in the south; the river cuts
## the table in two; the three northern districts (Cheddar Cliffs, Layer-Cake Town, Pancake Plateau) lie
## beyond the river AND behind a golem gate each.

const MIN_CORNER: Vector2 = Vector2(4.0, 4.0)
const MAX_CORNER: Vector2 = Vector2(96.0, 76.0)
const CORNER_RADIUS: float = 12.0
## Terrain mesh resolution (metres per cell).
const TERRAIN_STEP: float = 1.25
const CLIFF_WIDTH: float = 1.6
## The river: centre line z(x), half width, and the soup surface height.
const RIVER_BASE_Z: float = 44.0
const RIVER_HALF_WIDTH: float = 3.4
const SOUP_LEVEL: float = -0.35
const RIVER_BED: float = -1.3
## Rafts and the lazy susan.
const RAFT_RADIUS: float = 1.7
const RAFT_MOVE: float = 5.0
const RAFT_PAUSE: float = 3.0
const SUSAN_RADIUS: float = 4.3
const SUSAN_PILLAR: float = 1.2
const SUSAN_OMEGA: float = 0.42
## The picket fence line (z) with the three gates, and the half width of every gap.
const FENCE_Z: float = 30.0
const GATE_HALF_WIDTH: float = 2.5
const GATE_BLOCKER_RADIUS: float = 2.2
const GATE_XS: Array[float] = [22.0, 50.0, 78.0]

enum Surface { VOID, GROUND, MESA, CLIFF, SOUP }


class Mesa:
	extends RefCounted
	var id: String = ""
	var title: String = ""
	var center: Vector2 = Vector2.ZERO
	var radius: float = 5.0
	var height: float = 5.0
	## "pancake", "cheese" or "butter" - decides the cliff's look.
	var style: String = "pancake"


class Pad:
	extends RefCounted
	var id: String = ""
	var pos: Vector2 = Vector2.ZERO
	var radius: float = 1.25
	## Layout anchor the pad launches you to.
	var dest_anchor: String = ""
	var color: Color = Color(1.0, 0.4, 0.75)
	var title: String = ""


class Raft:
	extends RefCounted
	var id: String = ""
	## Ferry end points (centre of the raft at each stop): a = south bank end, b = north bank end.
	var a: Vector2 = Vector2.ZERO
	var b: Vector2 = Vector2.ZERO
	## Seconds into the cycle where this raft starts (so the two ferries are not in sync).
	var offset: float = 0.0
	var title: String = ""


class Susan:
	extends RefCounted
	var id: String = ""
	var center: Vector2 = Vector2.ZERO
	var radius: float = SUSAN_RADIUS
	var omega: float = SUSAN_OMEGA
	var title: String = ""


class Prop:
	extends RefCounted
	## Food Kit based: "broccoli", "cauliflower", "fork", "knife", "spoon", "cake", "donut", "pie", "pancakes",
	## "cheese", "loaf", "plate", "pot", "mug", "shaker", "lollipop", "jar", "cupcake", "layer_cake", "icecream",
	## "pudding"; procedural: "stall", "oven", "fountain", "table", "gazebo", "stage", "freezer", "kitchen_door",
	## "arch", "stew_pot", "wheel", "salt_flat", "candy_jar", "bread_hollow", "counter", "cabinet", "signal"
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
	## 180 = the front faces the camera (south).
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


var mesas: Array[Mesa] = []
var pads: Array[Pad] = []
var rafts: Array[Raft] = []
var susans: Array[Susan] = []
var props: Array[Prop] = []
var signs: Array[Sign] = []
var areas: Array[Area] = []
## Soup ponds: [Vector3(x, z, radius)].
var ponds: Array[Vector3] = []
## Named world positions (xz meaningful; y is 0 here, the builder adds the ground height).
var anchors: Dictionary = {}
## [{type, home, patrol}] for the roaming enemies.
var enemy_spawns: Array[Dictionary] = []
## Hidden chest positions by id (never on the map).
var chests: Dictionary = {}
## Walking paths: [{line, width}].
var paths: Array[Dictionary] = []
## Places where the terrain is levelled flat at height 0: [Vector3(x, z, radius)].
var flat_spots: Array[Vector3] = []
## Static obstacles (x, z, radius) from props, the fence, the dividers and the susan pillar.
var obstacles: Array[Vector3] = []
## Where each golem gate's guardian stands: gate id -> Vector3(x, 0, z).
var gate_positions: Dictionary = {}
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func build() -> void:
	_rng.seed = 4242
	_mesas()
	_pads()
	_ponds()
	_platforms()
	_anchors()
	_chests()
	_enemies()
	_areas()
	_paths()
	_flat_spots()
	_features()
	_fence()
	_signs()
	_scatter()
	_index_obstacles()


# ---- Ground ----------------------------------------------------------------------------------


## Metres from the table's edge (positive inside the rounded rectangle).
static func edge_distance(x: float, z: float) -> float:
	var center: Vector2 = (MIN_CORNER + MAX_CORNER) * 0.5
	var half: Vector2 = (MAX_CORNER - MIN_CORNER) * 0.5
	var q: Vector2 = Vector2(absf(x - center.x), absf(z - center.y)) - (half - Vector2(CORNER_RADIUS, CORNER_RADIUS))
	var outside: float = Vector2(maxf(q.x, 0.0), maxf(q.y, 0.0)).length()
	var inside: float = minf(maxf(q.x, q.y), 0.0)
	return -(outside + inside - CORNER_RADIUS)


## The river's centre line z at x.
static func river_z(x: float) -> float:
	return RIVER_BASE_Z + 2.2 * sin(0.065 * x + 0.4)


## How deep into the river (x, z) is: positive in the soup, negative on land.
func soup_depth(x: float, z: float) -> float:
	var best: float = RIVER_HALF_WIDTH - absf(z - river_z(x))
	for pond: Vector3 in ponds:
		best = maxf(best, pond.z - Vector2(x - pond.x, z - pond.y).length())
	return best


func mesa_at(x: float, z: float) -> Mesa:
	for mesa: Mesa in mesas:
		if Vector2(x - mesa.center.x, z - mesa.center.y).length() <= mesa.radius:
			return mesa
	return null


func surface_at(x: float, z: float) -> Surface:
	if edge_distance(x, z) < 0.0:
		return Surface.VOID
	for mesa: Mesa in mesas:
		var distance: float = Vector2(x - mesa.center.x, z - mesa.center.y).length()
		if distance <= mesa.radius:
			return Surface.MESA
		if distance <= mesa.radius + CLIFF_WIDTH:
			return Surface.CLIFF
	if soup_depth(x, z) > 0.0:
		return Surface.SOUP
	return Surface.GROUND


func _hills(x: float, z: float) -> float:
	return 0.85 * sin(x * 0.085 + 0.7) * cos(z * 0.10 + 0.3) + 0.35 * sin(x * 0.17 + z * 0.06 + 1.0) + 0.3 * cos(z * 0.15 - x * 0.05)


## Rolling mashed-potato hills, flat around buildings and the hub, carved down in the river, a steep wall
## around each mesa, a rolled-down rim at the table's edge.
func ground_height(x: float, z: float) -> float:
	var edge: float = edge_distance(x, z)
	if edge < 0.0:
		return -5.0 + edge * 0.6
	for mesa: Mesa in mesas:
		var distance: float = Vector2(x - mesa.center.x, z - mesa.center.y).length()
		if distance <= mesa.radius:
			return mesa.height
		if distance < mesa.radius + CLIFF_WIDTH:
			var t: float = smoothstep(0.0, 1.0, (distance - mesa.radius) / CLIFF_WIDTH)
			return lerpf(mesa.height, _base_height(x, z), t)
	return _base_height(x, z)


func _base_height(x: float, z: float) -> float:
	var flat: float = 1.0
	for spot: Vector3 in flat_spots:
		var distance: float = Vector2(x - spot.x, z - spot.y).length()
		flat = minf(flat, smoothstep(spot.z * 0.7, spot.z * 1.3, distance))
	var hills: float = _hills(x, z) * flat * smoothstep(1.0, 5.0, -soup_depth(x, z))
	var edge: float = clampf(edge_distance(x, z) / 4.0, 0.0, 1.0)
	var land: float = hills - (1.0 - edge) * 0.9
	var depth: float = soup_depth(x, z)
	if depth > -1.8:
		# Banks slope into the soup; the bed is below the soup surface.
		var bank: float = smoothstep(-1.8, 0.4, depth)
		return lerpf(land, RIVER_BED + 0.3 * clampf(depth, 0.0, 2.0), bank)
	return land


## Height of the surface a character stands on: ground, a mesa top, or the soup's raft/susan level (0).
func standing_height(x: float, z: float) -> float:
	return ground_height(x, z)


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


# ---- Dynamic platforms ------------------------------------------------------------------------


## Where a raft's centre is `time` seconds into the game: waits at each bank, then glides across.
func raft_position(raft: Raft, time: float) -> Vector2:
	var cycle: float = 2.0 * (RAFT_MOVE + RAFT_PAUSE)
	var phase: float = fposmod(time + raft.offset, cycle)
	var u: float = 0.0
	if phase < RAFT_PAUSE:
		u = 0.0
	elif phase < RAFT_PAUSE + RAFT_MOVE:
		u = smoothstep(0.0, 1.0, (phase - RAFT_PAUSE) / RAFT_MOVE)
	elif phase < 2.0 * RAFT_PAUSE + RAFT_MOVE:
		u = 1.0
	else:
		u = 1.0 - smoothstep(0.0, 1.0, (phase - 2.0 * RAFT_PAUSE - RAFT_MOVE) / RAFT_MOVE)
	return raft.a.lerp(raft.b, u)


## The raft carrying (x, z) at `time`, or null.
func raft_under(x: float, z: float, time: float, margin: float = 0.0) -> Raft:
	for raft: Raft in rafts:
		if raft_position(raft, time).distance_to(Vector2(x, z)) <= RAFT_RADIUS + margin:
			return raft
	return null


func susan_under(x: float, z: float, margin: float = 0.0) -> Susan:
	for susan: Susan in susans:
		var distance: float = susan.center.distance_to(Vector2(x, z))
		if distance <= susan.radius + margin and distance > SUSAN_PILLAR - 0.2:
			return susan
	return null


# ---- Mesas, pads, ponds, platforms -----------------------------------------------------------


func _mesa(id: String, title: String, center: Vector2, radius: float, height: float, style: String) -> void:
	var mesa: Mesa = Mesa.new()
	mesa.id = id
	mesa.title = title
	mesa.center = center
	mesa.radius = radius
	mesa.height = height
	mesa.style = style
	mesas.append(mesa)


func _mesas() -> void:
	_mesa("butte", "Butter Butte", Vector2(68.0, 54.0), 4.2, 3.0, "butter")
	_mesa("cheddar", "Cheddar Overlook", Vector2(14.0, 14.0), 5.2, 5.0, "cheese")
	_mesa("pancake", "Pancake Summit", Vector2(82.0, 16.0), 7.0, 6.5, "pancake")


func _pad(id: String, title: String, pos: Vector2, dest: String, color: Color) -> void:
	var pad: Pad = Pad.new()
	pad.id = id
	pad.title = title
	pad.pos = pos
	pad.dest_anchor = dest
	pad.color = color
	pads.append(pad)


func _pads() -> void:
	var pink: Color = Color(1.0, 0.38, 0.72)
	var lime: Color = Color(0.5, 1.0, 0.35)
	var orange: Color = Color(1.0, 0.65, 0.2)
	_pad("pad_butte", "Strawberry Jelly Pad", Vector2(61.0, 58.5), "land_butte", pink)
	_pad("pad_butte_back", "Strawberry Jelly Pad (down)", Vector2(70.6, 56.2), "land_butte_down", pink)
	_pad("pad_cheddar", "Lime Jelly Pad", Vector2(23.0, 20.0), "land_cheddar", lime)
	_pad("pad_cheddar_back", "Lime Jelly Pad (down)", Vector2(16.8, 16.2), "land_cheddar_down", lime)
	_pad("pad_pancake", "Orange Jelly Pad", Vector2(73.0, 22.0), "land_pancake", orange)
	_pad("pad_pancake_back", "Orange Jelly Pad (down)", Vector2(86.5, 12.0), "land_pancake_down", orange)


func _ponds() -> void:
	ponds = [Vector3(29.0, 66.0, 3.0)] as Array[Vector3]


func _raft(id: String, title: String, x: float, offset: float) -> void:
	var raft: Raft = Raft.new()
	raft.id = id
	raft.title = title
	var z: float = river_z(x)
	raft.a = Vector2(x, z + 2.5)
	raft.b = Vector2(x, z - 2.5)
	raft.offset = offset
	rafts.append(raft)


func _platforms() -> void:
	_raft("raft_west", "Crouton Raft (west crossing)", 22.0, 0.0)
	_raft("raft_east", "Crouton Raft (east crossing)", 78.0, 5.5)
	var susan: Susan = Susan.new()
	susan.id = "susan_center"
	susan.title = "The Lazy Susan"
	susan.center = Vector2(50.0, river_z(50.0))
	susans.append(susan)


# ---- Anchors, chests, enemies -----------------------------------------------------------------


func _at(name: String, x: float, z: float) -> void:
	anchors[name] = Vector3(x, 0.0, z)


func _anchors() -> void:
	# The Grand Pantry (hub, south centre).
	_at("spawn", 50.0, 70.5)
	_at("hub", 50.0, 64.0)
	_at("exit", 50.0, 74.2)
	_at("heal", 41.0, 62.0)
	_at("dolcetta", 60.5, 63.5)
	_at("odalys", 50.0, 58.5)
	_at("tarragon", 43.5, 67.0)
	_at("oven", 58.0, 69.5)
	_at("soup_fountain", 50.0, 64.5)
	_at("fortune_cookie", 65.0, 67.5)
	_at("old_meatloaf", 36.0, 68.0)
	# Broccoli Forest (south-west).
	_at("quiz", 19.0, 62.0)
	_at("pickup_truffle", 9.0, 56.0)
	_at("pickup_basil", 14.0, 60.0)
	# Candy Field (south-east).
	_at("minigame", 82.0, 62.0)
	_at("taste_test", 88.0, 55.0)
	_at("pickup_saffron", 92.0, 69.0)
	# Salt flats and the meadow in between.
	_at("pickup_sea_salt", 38.0, 51.5)
	# Butter Butte.
	_at("land_butte", 68.0, 54.8)
	_at("land_butte_down", 62.5, 61.5)
	_at("pickup_honey", 69.5, 52.8)
	# Gravy Bank (north of the river), reached by raft or the lazy susan.
	_at("land_west", 22.0, river_z(22.0) - 5.6)
	_at("land_center", 50.0, river_z(50.0) - 5.6)
	_at("land_east", 78.0, river_z(78.0) - 5.6)
	_at("bank_west", 22.0, river_z(22.0) + 5.6)
	_at("bank_center", 50.0, river_z(50.0) + 5.6)
	_at("bank_east", 78.0, river_z(78.0) + 5.6)
	_at("pickup_hot_pepper", 62.0, 36.0)
	# The three golem gates (the guardians stand in the gaps of the picket fence).
	_at("gate_ingredient", 22.0, FENCE_Z)
	_at("gate_quest", 50.0, FENCE_Z)
	_at("gate_battle", 78.0, FENCE_Z)
	# Cheddar Cliffs (north-west).
	_at("land_cheddar", 13.5, 15.5)
	_at("land_cheddar_down", 22.0, 24.5)
	# Layer-Cake Town (north-centre).
	_at("mini_dungeon", 44.0, 10.0)
	_at("main_dungeon", 57.0, 10.0)
	# Pancake Plateau (north-east).
	_at("puzzle", 82.0, 13.5)
	_at("land_pancake", 79.5, 18.5)
	_at("land_pancake_down", 74.5, 26.5)


func _chests() -> void:
	chests = {
		"chest_loaf": Vector3(11.5, 0.0, 68.5),
		"chest_butte": Vector3(66.0, 0.0, 52.8),
		"chest_candy": Vector3(73.5, 0.0, 71.5),
		"chest_salt": Vector3(27.5, 0.0, 52.0),
		"chest_cheddar": Vector3(11.5, 0.0, 12.0),
		"chest_wheel": Vector3(29.0, 0.0, 8.4),
		"chest_pancake": Vector3(87.0, 0.0, 17.0),
		"chest_cake": Vector3(60.5, 0.0, 22.0),
	}


func _enemies() -> void:
	enemy_spawns = [
		{"type": "loaf", "home": Vector3(24.0, 0.0, 56.0), "patrol": 3.5},
		{"type": "jelly", "home": Vector3(80.0, 0.0, 69.0), "patrol": 3.0},
		{"type": "meatball", "home": Vector3(76.0, 0.0, 50.5), "patrol": 5.0},
		{"type": "loaf", "home": Vector3(32.0, 0.0, 22.0), "patrol": 3.5},
		{"type": "jelly", "home": Vector3(50.0, 0.0, 20.0), "patrol": 3.0},
		{"type": "meatball", "home": Vector3(72.0, 0.0, 16.0), "patrol": 4.0},
		{"type": "meatball", "home": Vector3(40.0, 0.0, 34.0), "patrol": 4.0},
	]


func _area(id: String, title: String, x: float, z: float, radius: float) -> void:
	var area: Area = Area.new()
	area.id = id
	area.title = title
	area.center = Vector2(x, z)
	area.radius = radius
	areas.append(area)


func _areas() -> void:
	_area("hub", "The Grand Pantry", 50.0, 64.0, 12.0)
	_area("forest", "Broccoli Forest", 17.0, 61.0, 15.0)
	_area("candy", "Candy Field", 82.0, 62.0, 14.0)
	_area("salt", "The Salt Flats", 36.0, 52.0, 8.0)
	_area("butte", "Butter Butte", 68.0, 54.0, 5.8)
	_area("river", "The Gravy River", 50.0, 44.0, 6.0)
	_area("bank", "Gravy Bank", 50.0, 35.0, 14.0)
	_area("cheddar_top", "Cheddar Overlook", 14.0, 14.0, 6.8)
	_area("cheddar", "Cheddar Cliffs", 20.0, 17.0, 16.0)
	_area("cake", "Layer-Cake Town", 50.0, 17.0, 14.0)
	_area("pancake_top", "Pancake Summit", 82.0, 16.0, 8.6)
	_area("pancake", "Pancake Plateau", 80.0, 18.0, 15.0)
	_area("meadow", "Mashed Potato Meadow", 50.0, 45.0, 60.0)


func _paths() -> void:
	var hub: Vector2 = Vector2(50.0, 62.0)
	var wz: float = river_z(22.0)
	var cz: float = river_z(50.0)
	var ez: float = river_z(78.0)
	paths = [
		{"line": PackedVector2Array([hub, Vector2(36.0, 56.0), Vector2(24.0, 60.0), Vector2(19.0, 62.0)]), "width": 2.4},
		{"line": PackedVector2Array([hub, Vector2(70.0, 62.0), Vector2(82.0, 62.0)]), "width": 2.4},
		{"line": PackedVector2Array([hub, Vector2(50.0, 54.0), Vector2(50.0, cz + 4.0)]), "width": 2.4},
		{"line": PackedVector2Array([Vector2(36.0, 56.0), Vector2(26.0, 52.0), Vector2(22.0, wz + 4.0)]), "width": 2.2},
		{"line": PackedVector2Array([Vector2(70.0, 60.0), Vector2(76.0, 53.0), Vector2(78.0, ez + 4.0)]), "width": 2.2},
		{"line": PackedVector2Array([Vector2(22.0, wz - 4.0), Vector2(22.0, 34.0), Vector2(50.0, 34.0), Vector2(78.0, 34.0), Vector2(78.0, ez - 4.0)]), "width": 2.2},
		{"line": PackedVector2Array([Vector2(50.0, cz - 4.0), Vector2(50.0, 34.0)]), "width": 2.2},
		{"line": PackedVector2Array([Vector2(22.0, 34.0), Vector2(22.0, 22.0), Vector2(23.0, 20.0)]), "width": 2.0},
		{"line": PackedVector2Array([Vector2(50.0, 34.0), Vector2(50.0, 12.0)]), "width": 2.4},
		{"line": PackedVector2Array([Vector2(44.0, 12.0), Vector2(57.0, 12.0)]), "width": 2.2},
		{"line": PackedVector2Array([Vector2(78.0, 34.0), Vector2(78.0, 24.0), Vector2(73.0, 22.0)]), "width": 2.0},
		{"line": PackedVector2Array([hub, Vector2(56.0, 60.0), Vector2(61.0, 58.5)]), "width": 2.0},
		{"line": PackedVector2Array([hub, Vector2(58.0, 68.0), Vector2(65.0, 67.5)]), "width": 2.0},
		{"line": PackedVector2Array([hub, Vector2(42.0, 68.0), Vector2(36.0, 68.0)]), "width": 2.0},
	]


func _flat_spots() -> void:
	flat_spots = [Vector3(50.0, 64.0, 14.0)] as Array[Vector3]
	for key: Variant in anchors.keys():
		var anchor: Vector3 = anchors[key] as Vector3
		flat_spots.append(Vector3(anchor.x, anchor.z, 3.2))
	for pad: Pad in pads:
		flat_spots.append(Vector3(pad.pos.x, pad.pos.y, 2.2))
	for mesa: Mesa in mesas:
		flat_spots.append(Vector3(mesa.center.x, mesa.center.y, mesa.radius + CLIFF_WIDTH + 1.0))
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
	# The Grand Pantry: a kitchen hall of cabinets along the north wall, stalls, a table, the oven, the soup
	# fountain and the arch back to the Path of the Gourmand.
	for index: int in range(5):
		_prop("cabinet", 41.0 + float(index) * 4.5, 55.2, 0.0, 1.0, 1.6, index % 2)
	_prop("fountain", 50.0, 64.5, 0.0, 1.0, 1.9)
	_prop("table", 41.0, 62.0, 90.0, 1.0, 1.5)
	_prop("stall", 60.5, 65.4, 200.0, 1.0, 1.2)
	_prop("oven", 58.0, 69.5, 180.0, 1.0, 1.6)
	_prop("arch", 50.0, 75.4, 0.0, 1.0, 0.0)
	_prop("dispenser", 65.0, 67.5, 200.0, 1.0, 0.8)
	_prop("broken_golem", 36.0, 68.0, 20.0, 1.0, 1.3)
	_prop("hub_pot", 38.0, 60.0, 0.0, 1.0, 0.0)
	# Broccoli Forest: the hollowed bread loaf with the quiz master, a second loaf hiding a chest.
	_prop("gazebo", 19.0, 59.2, 0.0, 1.0, 2.2)
	_prop("bread_hollow", 11.5, 68.8, 20.0, 1.0, 0.0)
	# Candy Field: the Dinner in a Dash set, the taste-test station, a giant candy jar.
	_prop("stage", 82.0, 58.6, 0.0, 1.0, 1.8)
	_prop("taste_station", 88.0, 55.0, 0.0, 1.0, 1.1)
	_prop("candy_jar", 75.4, 73.0, 0.0, 1.0, 1.2)
	# The salt flats: a giant salt shaker hiding a chest.
	_prop("shaker", 25.4, 53.8, 30.0, 1.0, 0.9, 0)
	_prop("shaker", 30.2, 50.2, -20.0, 1.0, 0.9, 1)
	# Butter Butte decoration.
	_prop("butter_pat", 66.5, 55.6, 0.0, 1.0, 0.0)
	# The north: Layer-Cake Town (buildings made of cake), the Walk-In Freezer, the shut Kitchen.
	_prop("layer_cake", 39.5, 20.0, 0.0, 1.3, 2.6, 0)
	_prop("layer_cake", 46.0, 24.5, 0.0, 1.0, 2.2, 1)
	_prop("layer_cake", 56.0, 20.0, 0.0, 1.5, 2.9, 2)
	_prop("layer_cake", 61.0, 25.5, 0.0, 1.1, 2.4, 3)
	_prop("layer_cake", 62.0, 16.5, 0.0, 0.9, 2.0, 1)
	_prop("layer_cake", 38.5, 12.5, 0.0, 1.0, 2.2, 3)
	_prop("freezer", 44.0, 7.8, 0.0, 1.0, 3.0)
	_prop("kitchen_door", 57.0, 7.8, 0.0, 1.0, 3.0)
	# Cheddar Cliffs: wheels of cheese, a giant cheese wedge wall.
	_prop("cheese_wheel", 29.5, 12.5, 20.0, 1.3, 2.7, 0)
	_prop("cheese_wheel", 8.5, 24.0, 10.0, 1.2, 3.0, 2)
	_prop("cheese_wheel", 31.0, 16.5, 0.0, 0.9, 2.3, 1)
	# Pancake Plateau: stacks of pancakes and the mystery stew pot on the summit.
	_prop("stew_pot", 82.0, 12.0, 0.0, 1.0, 1.9)
	_prop("pancake_stack", 70.0, 10.0, 0.0, 1.0, 2.4, 0)
	_prop("pancake_stack", 90.0, 28.0, 0.0, 0.9, 2.1, 1)
	_prop("pancake_stack", 68.0, 26.0, 0.0, 0.8, 1.9, 2)
	# Gravy Bank dressing: a spilled giant sundae and giant cutlery lying around.
	_prop("sundae", 34.0, 36.0, 0.0, 1.0, 1.0)
	_prop("sundae", 88.0, 36.0, 0.0, 0.9, 1.0)
	# Giant cutlery standing as pillars and plates as paving: dressing along the roads.
	_prop("fork", 44.0, 54.0, 20.0, 1.0, 0.0)
	_prop("spoon", 56.0, 54.0, -25.0, 1.0, 0.0)
	_prop("knife", 33.0, 40.0, 10.0, 1.0, 0.0)
	_prop("fork", 66.0, 38.0, 0.0, 1.0, 0.0)
	_prop("donut_arch", 22.0, 56.0, 90.0, 1.0, 0.0)
	_prop("donut_arch", 70.0, 62.0, 0.0, 1.0, 0.0)
	# The susan's central pillar (a giant pepper mill) and the ferries' posts.
	_prop("mill_pillar", 50.0, river_z(50.0), 0.0, 1.0, SUSAN_PILLAR)


func _fence() -> void:
	# The picket fence of giant forks along z = FENCE_Z with a gap at each gate.
	var x: float = 5.0
	while x <= 95.0:
		var in_gap: bool = false
		for gate_x: float in GATE_XS:
			if absf(x - gate_x) < GATE_HALF_WIDTH - 0.01:
				in_gap = true
		if not in_gap:
			_prop("fence_fork", x, FENCE_Z, 0.0, 1.0, 0.5, int(x) % 3)
		x += 1.0
	# Dividers between the three northern districts.
	for divider_x: float in [36.0, 64.0]:
		var z: float = 5.0
		while z <= FENCE_Z - 1.0:
			_prop("divider", divider_x, z, 0.0, 1.0, 0.55, int(z) % 3)
			z += 1.0
	for gate_x: float in GATE_XS:
		var id: String = "ingredient" if gate_x < 30.0 else ("quest" if gate_x < 60.0 else "battle")
		gate_positions[id] = Vector3(gate_x, 0.0, FENCE_Z)


func _sign(key: String, x: float, z: float, yaw: float = 180.0, size: float = 1.0, style: String = "sign") -> void:
	var sign: Sign = Sign.new()
	sign.key = key
	sign.pos = Vector3(x, 0.0, z)
	sign.yaw = 180.0 + clampf(yaw - 180.0, -12.0, 12.0)
	sign.size = size
	sign.style = style
	signs.append(sign)


func _signs() -> void:
	_sign("sign.hub_main", 50.0, 67.6, 180.0, 1.2)
	_sign("sign.hub_motto", 46.0, 58.0, 170.0, 1.0, "menu")
	_sign("sign.exit", 54.0, 73.0, 180.0)
	_sign("sign.heal_table", 43.5, 63.4, 180.0)
	_sign("sign.vendor", 63.5, 62.5, 200.0)
	_sign("sign.oven", 55.5, 71.5, 160.0)
	_sign("sign.fountain", 47.6, 67.0, 175.0)
	_sign("sign.golem_oath", 54.5, 58.2, 190.0, 1.0, "poster")
	_sign("sign.cookie", 66.8, 66.0, 200.0)
	_sign("sign.old_meatloaf", 38.0, 66.5, 160.0, 0.9, "memo")
	_sign("sign.forest", 24.5, 58.0, 150.0)
	_sign("sign.quiz", 21.5, 63.6, 190.0)
	_sign("sign.truffle_note", 10.8, 57.8, 190.0, 0.9, "memo")
	_sign("sign.candy", 76.0, 58.5, 170.0)
	_sign("sign.studio", 79.0, 64.5, 180.0)
	_sign("sign.taste_test", 85.5, 55.5, 190.0)
	_sign("sign.salt", 33.0, 55.0, 160.0)
	_sign("sign.butte", 64.5, 59.6, 190.0)
	_sign("sign.pad_rule", 57.6, 60.4, 180.0, 0.9, "memo")
	_sign("sign.river", 26.0, 51.2, 190.0)
	_sign("sign.river_warning", 46.0, 50.4, 180.0, 0.9, "memo")
	_sign("sign.raft_west", 18.8, 50.0, 180.0)
	_sign("sign.susan", 53.5, 50.2, 200.0)
	_sign("sign.raft_east", 74.5, 49.0, 180.0)
	_sign("sign.bank", 40.0, 37.0, 170.0)
	_sign("sign.gate_ingredient", 26.0, 33.0, 170.0)
	_sign("sign.gate_quest", 54.0, 33.0, 190.0)
	_sign("sign.gate_battle", 74.0, 33.0, 170.0)
	_sign("sign.cheddar", 18.0, 26.0, 180.0)
	_sign("sign.cake_town", 46.0, 28.0, 180.0)
	_sign("sign.pancake", 76.0, 28.0, 180.0)
	_sign("sign.mini_dungeon", 47.5, 11.6, 180.0)
	_sign("sign.main_dungeon", 57.0, 12.6, 180.0, 1.5)
	_sign("sign.inspection_note", 60.0, 12.4, 190.0, 0.9, "memo")
	_sign("sign.stew", 78.5, 14.6, 180.0)
	_sign("sign.golem_rule", 50.0, 31.8, 180.0, 0.9, "memo")
	_sign("sign.cake_menu", 52.0, 26.5, 180.0, 1.0, "menu")
	_sign("sign.cheese_note", 24.0, 10.5, 190.0, 0.9, "memo")


## Broccoli forest, candy lollipops, mashed-potato bushes and plates, kept clear of paths, anchors and features.
func _scatter() -> void:
	var keep_clear: Array[Vector3] = []
	for key: Variant in anchors.keys():
		var anchor: Vector3 = anchors[key] as Vector3
		keep_clear.append(Vector3(anchor.x, anchor.z, 3.4))
	for chest_id: Variant in chests.keys():
		var chest: Vector3 = chests[chest_id] as Vector3
		keep_clear.append(Vector3(chest.x, chest.z, 1.4))
	for feature: Prop in props:
		if feature.kind == "fence_fork" or feature.kind == "divider":
			keep_clear.append(Vector3(feature.pos.x, feature.pos.z, 1.2))
		else:
			keep_clear.append(Vector3(feature.pos.x, feature.pos.z, 3.0 if feature.radius > 0.0 else 2.0))
	for spawn: Dictionary in enemy_spawns:
		var home: Vector3 = spawn["home"] as Vector3
		keep_clear.append(Vector3(home.x, home.z, 3.0))
	for pad: Pad in pads:
		keep_clear.append(Vector3(pad.pos.x, pad.pos.y, 3.0))
	keep_clear.append(Vector3(50.0, 64.0, 13.0))
	# Broccoli forest (dense, south-west) with cauliflower underbrush.
	_scatter_kind("broccoli", Rect2(6.0, 50.0, 26.0, 24.0), 46, keep_clear, 1.1, 0.5, 1.0, 1.6)
	_scatter_kind("cauliflower", Rect2(6.0, 50.0, 26.0, 24.0), 18, keep_clear, 1.0, 0.55, 0.9, 1.3)
	# A few broccoli trees elsewhere on the table.
	_scatter_kind("broccoli", Rect2(34.0, 50.0, 56.0, 24.0), 14, keep_clear, 1.4, 0.5, 0.9, 1.4)
	_scatter_kind("broccoli", Rect2(5.0, 31.0, 90.0, 10.0), 12, keep_clear, 1.4, 0.5, 0.9, 1.4)
	_scatter_kind("broccoli", Rect2(6.0, 5.0, 28.0, 24.0), 8, keep_clear, 1.4, 0.5, 0.9, 1.3)
	_scatter_kind("broccoli", Rect2(66.0, 5.0, 28.0, 24.0), 8, keep_clear, 1.4, 0.5, 0.9, 1.3)
	# Candy field lollipops.
	_scatter_kind("lollipop", Rect2(70.0, 50.0, 25.0, 24.0), 30, keep_clear, 1.4, 0.35, 0.9, 1.4)
	# Cauliflower bushes and cabbages over the rest.
	_scatter_kind("cauliflower", Rect2(34.0, 50.0, 56.0, 24.0), 14, keep_clear, 1.2, 0.55, 0.9, 1.2)
	_scatter_kind("cabbage", Rect2(5.0, 31.0, 90.0, 12.0), 10, keep_clear, 1.2, 0.55, 0.9, 1.2)
	_scatter_kind("cupcake", Rect2(37.0, 5.0, 26.0, 24.0), 8, keep_clear, 1.4, 0.55, 1.0, 1.5)
	_scatter_kind("muffin", Rect2(66.0, 5.0, 28.0, 24.0), 7, keep_clear, 1.4, 0.55, 1.0, 1.4)
	_scatter_kind("cheese_block", Rect2(6.0, 5.0, 28.0, 24.0), 9, keep_clear, 1.4, 0.8, 1.0, 1.5)


func _scatter_kind(kind: String, area: Rect2, count: int, keep_clear: Array[Vector3], gap: float, radius: float, scale_min: float, scale_max: float) -> void:
	var placed: int = 0
	var attempts: int = 0
	while placed < count and attempts < 600:
		attempts += 1
		var x: float = _rng.randf_range(area.position.x, area.end.x)
		var z: float = _rng.randf_range(area.position.y, area.end.y)
		if edge_distance(x, z) < 2.2 or soup_depth(x, z) > -1.6 or surface_at(x, z) != Surface.GROUND:
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
