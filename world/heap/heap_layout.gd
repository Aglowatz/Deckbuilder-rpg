class_name HeapLayout
extends RefCounted
## The Verdant Dump's map as plain data (no scene nodes), so it can be unit-tested headless. Since the v2 rebuild (docs/art/verdant_dump_v2.md) it is a
## narrow, deep valley rising in TERRACES from the market at the south entrance to the Rotheart at the north: the Market Terrace (T0, the hub), the
## Ravine (the turquoise river below, crossed by vine bridges), the Farm Terrace (T1), the Compost Terrace (T2) and the Overgrown Plateau (T3), joined by
## stone stairs, a giant root ramp, vine ladders, a scree slope (mount only) and the trash chutes back down; the river comes down a gorge along the west
## edge in falls and turns east into the ravine. Walkable ground has ONE height per (x, z): verticality is terraces and cliffs; nothing walkable lies
## under a bridge. `HeapBuilder` turns it into meshes; `HeapScene` makes it playable.
##
## Coordinates: metres, x east, z south, y up. ONE walkable zone (docs/design/subarea_removal.md) in six regions (`REGION_IDS`, several circles per id).

const MIN_CORNER: Vector2 = Vector2(18.0, 4.0)
const MAX_CORNER: Vector2 = Vector2(82.0, 136.0)
const CORNER_RADIUS: float = 6.0
const TERRAIN_STEP: float = 1.25
const CLIFF_WIDTH: float = 1.6
## The terraces: heights and the base z of the cliff edge below each (the edge wanders, see `tier_edge_z`). T0 ends at the ravine.
const TIER_HEIGHTS: Array[float] = [0.0, 3.0, 6.5, 10.0]
const TIER_EDGE_Z: Array[float] = [1000.0, 62.0, 38.0]
const TIER_EDGE_WAVE: float = 1.4
## The ravine: the river's centre line z(x), its water half width, the cliff bank either side and the levels (the water lies below the market).
const STREAM_BASE_Z: float = 96.0
const STREAM_HALF_WIDTH: float = 4.2
const BANK_WIDTH: float = 0.9
const WATER_LEVEL: float = -2.4
const STREAM_BED: float = -3.4
## The ravine ends at the drain against the east wall; the land neck east of it carries the stone stairs.
const RAVINE_END_X: float = 73.5
const DRAIN: Vector3 = Vector3(71.0, 97.2, 3.6)
## The west gorge: the river's course down the terraces before it turns into the ravine (x centre, water half width, from z).
const GORGE_X: float = 21.2
const GORGE_HALF_WIDTH: float = 2.4
const GORGE_FROM_Z: float = 38.0
## The sludge chasm across the compost terrace (a capsule: from, to, radius), bridged by the east vine bridge.
const CHASM_A: Vector2 = Vector2(69.0, 40.5)
const CHASM_B: Vector2 = Vector2(69.0, 62.0)
const CHASM_RADIUS: float = 2.3
## A vine bridge's half width and the deck's lift over its abutments.
const BRIDGE_HALF_WIDTH: float = 1.35
const BRIDGE_HEIGHT: float = 0.12
## Legacy names (the ravine replaced the stream; the tyre wall and the districts are gone). Kept so the older smokes compile.
const BRIDGE_REACH: float = 5.3
const WALL_Z: float = 46.0
const GAP_HALF_WIDTH: float = 2.5
const BARRICADE_RADIUS: float = 2.2
const GAP_XS: Array[float] = [48.0]
const DIVIDER_XS: Array[float] = []
## The kerb round a ramp: within this of a ramp's sides the land is a cliff where the heights disagree.
const RAMP_KERB: float = 0.8
const RAMP_STEP_DEPTH: float = 0.9
## The declutter rules (docs/art/zone_rollout_playbook.md section 5): main roads four hero-widths, spurs a little less, nothing solid near a route
## edge, open ground round every anchor, an empty plaza round the hub with the hub's things on its rim.
const MAIN_PATH_WIDTH: float = 4.2
const SIDE_PATH_WIDTH: float = 3.6
const PATH_CLEARANCE: float = 2.4
const ANCHOR_CLEARANCE: float = 5.5
const PLAZA_CENTER: Vector2 = Vector2(50.0, 120.0)
const PLAZA_RADIUS: float = 9.5
## The way in from town: a plank-and-tyre bridge from the land's south rim out over the overflow pool to its far landing. The hero arrives on it and
## walks north into the market; walking off the far end leaves for town.
const ENTRANCE_X: float = 50.0
const ENTRANCE_HALF_WIDTH: float = 2.3
const ENTRANCE_Z0: float = 134.0
const ENTRANCE_Z1: float = 150.0
const ENTRANCE_RAIL: float = 0.3
## The landmarks: where each stands and its size (w, h, d). The Rotheart (the main dungeon) is a colossal tree beyond the north rim on the plateau's
## level, seen from the whole valley, its root gate on the land; Junk Mountain is a view beyond the north-east corner; the Trash Panda Throne (the
## side dungeon's door) stands beyond the north-west rim at the end of the avenue; the windmill on the farm terrace's west edge; the greenhouse is
## the market's centrepiece.
const ROTHEART: Vector2 = Vector2(50.0, -30.0)
const ROTHEART_SIZE: Vector3 = Vector3(76.0, 46.0, 56.0)
const ROOT_GATE: Vector2 = Vector2(50.0, 5.5)
const ROOT_GATE_SIZE: Vector3 = Vector3(10.0, 6.0, 4.0)
const JUNK_MOUNTAIN: Vector2 = Vector2(100.0, -4.0)
const JUNK_MOUNTAIN_SIZE: Vector3 = Vector3(48.0, 28.0, 26.0)
const THRONE: Vector2 = Vector2(31.0, -3.5)
const THRONE_SIZE: Vector3 = Vector3(18.0, 14.0, 12.0)
const WINDMILL: Vector2 = Vector2(28.0, 67.0)
const WINDMILL_SIZE: Vector3 = Vector3(5.0, 12.0, 5.0)
const GREENHOUSE: Vector2 = PLAZA_CENTER
const GREENHOUSE_SIZE: Vector3 = Vector3(9.0, 5.5, 6.5)
## Flat, kept-clear ground under the region landmarks and the pieces that reach the land: (x, z, radius).
const LANDMARK_SPOTS: Array[Vector3] = [Vector3(50.0, 120.0, 7.5), Vector3(28.0, 67.0, 4.0), Vector3(50.0, 7.0, 7.0), Vector3(31.0, 6.0, 5.0)]
## What the landmarks block, as layout data (x, z, radius), so a layout-only reader (the walkability probe, the chest scan) sees them too.
const LANDMARK_BLOCKERS: Array[Vector3] = [
	Vector3(47.6, 120.0, 2.6), Vector3(50.0, 120.0, 2.6), Vector3(52.4, 120.0, 2.6),
	Vector3(28.0, 67.0, 2.5),
	Vector3(46.5, 5.5, 1.8), Vector3(50.0, 4.0, 2.0), Vector3(53.5, 5.5, 1.8),
	Vector3(31.0, 5.2, 2.4),
]
## Where each region picture is shot from (the camera looks north): `bash tools/shot.sh res://scenes/heap_zone.tscn <name> --at=po_<region>`.
## Not anchors: neither destinations of the walkability probe nor kept-clear ground. po_stream is the reference's view: the market's edge at the
## arched bridge's foot, the ravine and the terraces climbing beyond.
const PO_CAMERAS: Dictionary = {
	"po_hub": Vector2(50.0, 128.5), "po_junk_peaks": Vector2(72.0, 88.0), "po_farm_rows": Vector2(34.0, 89.0),
	"po_stream": Vector2(46.0, 106.0), "po_wetlands": Vector2(52.5, 30.5), "po_throne_approach": Vector2(40.0, 18.0),
}
## The six regions in reading order (ids of `areas`), for the docs and the tests.
const REGION_IDS: Array[String] = ["commons", "farm", "peaks", "stream", "wetlands", "throne"]
## The scattered decoration kinds, as opposed to the features of `_features`.
const TREE_KINDS: Array[String] = ["tree", "bush", "rock", "mushrooms", "flowers"]

enum Surface { VOID, GROUND, PEAK, CLIFF, HAZARD, ROUGH, BRIDGE }


class Peak:
	extends RefCounted
	var id: String = ""
	var title: String = ""
	var center: Vector2 = Vector2.ZERO
	var radius: float = 5.0
	## Absolute height of the summit.
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


## A way between two terraces: a rectangle (x, z) whose ground runs from `y0` at its south end to `y1` at its north end. Kinds: "stairs" (stepped,
## stone), "ramp" (a giant root slope), "ladder" (a short steep vine ladder, two to three hero-widths), "scree" (a junk slope only a mount crosses).
class Ramp:
	extends RefCounted
	var id: String = ""
	var kind: String = "stairs"
	var rect: Rect2 = Rect2()
	var y0: float = 0.0
	var y1: float = 0.0

	func height_at(z: float) -> float:
		var t: float = clampf((rect.end.y - z) / maxf(rect.size.y, 0.001), 0.0, 1.0)
		if kind == "stairs":
			var steps: int = maxi(2, int(ceilf(rect.size.y / HeapLayout.RAMP_STEP_DEPTH)))
			t = floorf(t * float(steps) + 0.5) / float(steps)
		return lerpf(y0, y1, t)


## A vine bridge across a gap: from `a` (its south or west end, on the land at `y_a`) to `b` (at `y_b`), a deck BRIDGE_HALF_WIDTH either side of the
## line that arches `rise` metres in the middle. Grown segment by segment from `a`.
class Bridge:
	extends RefCounted
	var id: String = ""
	var a: Vector2 = Vector2.ZERO
	var b: Vector2 = Vector2.ZERO
	var y_a: float = 0.0
	var y_b: float = 0.0
	var rise: float = 1.0
	## Legacy: the x of the old straight spans (the centre line's x for the ravine bridges).
	var x: float = 0.0

	func length() -> float:
		return a.distance_to(b)

	func fraction_at(x_at: float, z_at: float) -> float:
		var d: Vector2 = b - a
		return clampf((Vector2(x_at, z_at) - a).dot(d) / maxf(d.length_squared(), 0.001), 0.0, 1.0)

	func deck_height(t: float) -> float:
		return lerpf(y_a, y_b, t) + rise * sin(PI * t) + HeapLayout.BRIDGE_HEIGHT


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
var ramps: Array[Ramp] = []
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
	_ramps()
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


## The ravine's centre line: the river winds west to east below the market.
static func stream_z(x: float) -> float:
	return STREAM_BASE_Z + 1.5 * sin(0.1 * x + 0.5)


## The z of the cliff below terrace `tier` (1..3) at x: north of it the land is that terrace, south of it the one below (the ravine below T1).
static func tier_edge_z(tier: int, x: float) -> float:
	if tier <= 0:
		return 1000.0
	if tier == 1:
		return stream_z(x) - STREAM_HALF_WIDTH - BANK_WIDTH
	return TIER_EDGE_Z[tier - 1] + TIER_EDGE_WAVE * sin((0.12 if tier == 2 else 0.1) * x + (0.3 if tier == 2 else 2.0))


## Which terrace (0..3) the plain land at (x, z) belongs to.
static func tier_at(x: float, z: float) -> int:
	for tier: int in [3, 2, 1]:
		if z < tier_edge_z(tier, x):
			return tier
	return 0


static func tier_height(tier: int) -> float:
	return TIER_HEIGHTS[clampi(tier, 0, TIER_HEIGHTS.size() - 1)]


## True on the entrance bridge's deck (kerbs included); the deck overlaps the rim so the walk from land to planks is seamless.
static func on_entrance(x: float, z: float) -> bool:
	return absf(x - ENTRANCE_X) <= ENTRANCE_HALF_WIDTH and z >= ENTRANCE_Z0 and z <= ENTRANCE_Z1


## The river's water level in the gorge at z: it steps down with the terraces (half a metre under each) and is the ravine's below z GORGE_FROM.
static func gorge_water_level(z: float) -> float:
	if z >= stream_z(GORGE_X) - STREAM_HALF_WIDTH - 1.5:
		return WATER_LEVEL
	return tier_height(tier_at(GORGE_X + 4.0, z)) - 0.5


## How deep into water or a pit (x, z) is: positive in it, negative on land.
func hazard_depth(x: float, z: float) -> float:
	var best: float = -1e9
	if x <= RAVINE_END_X:
		best = STREAM_HALF_WIDTH - absf(z - stream_z(x))
	best = maxf(best, DRAIN.z - Vector2(x - DRAIN.x, z - DRAIN.y).length())
	if z >= GORGE_FROM_Z and z <= stream_z(GORGE_X):
		best = maxf(best, GORGE_HALF_WIDTH - absf(x - GORGE_X))
	var on_chasm: Vector2 = Geometry2D.get_closest_point_to_segment(Vector2(x, z), CHASM_A, CHASM_B)
	best = maxf(best, CHASM_RADIUS - on_chasm.distance_to(Vector2(x, z)))
	for pit: Vector3 in pits:
		best = maxf(best, pit.z - Vector2(x - pit.x, z - pit.y).length())
	return best


## True in the steep bank just outside the water (the ravine's and the gorge's cliff lips, the chasm's edge, a pit's rim).
func on_bank(x: float, z: float) -> bool:
	var depth: float = hazard_depth(x, z)
	return depth <= 0.0 and depth > -BANK_WIDTH


func peak_at(x: float, z: float) -> Peak:
	for peak: Peak in peaks:
		if Vector2(x - peak.center.x, z - peak.center.y).length() <= peak.radius:
			return peak
	return null


func ramp_at(x: float, z: float) -> Ramp:
	for ramp: Ramp in ramps:
		if ramp.rect.has_point(Vector2(x, z)):
			return ramp
	return null


func in_scree(x: float, z: float) -> bool:
	for field: Vector3 in scree:
		if Vector2(x - field.x, z - field.y).length() <= field.z:
			return true
	var ramp: Ramp = ramp_at(x, z)
	return ramp != null and ramp.kind == "scree"


## The kerb beside a ramp: within RAMP_KERB of its long sides and more than half a metre above or below its deck.
func _on_ramp_kerb(x: float, z: float, plain_height: float) -> bool:
	var p: Vector2 = Vector2(x, z)
	for ramp: Ramp in ramps:
		var grown: Rect2 = ramp.rect.grow(RAMP_KERB)
		if not grown.has_point(p) or ramp.rect.has_point(p):
			continue
		if z < ramp.rect.position.y or z > ramp.rect.end.y:
			continue
		# stairs and the root ramp have cheek walls and rails all the way (the only ways on are their ends, so a barricade at the foot really plugs them)
		if ramp.kind == "stairs" or ramp.kind == "ramp":
			return true
		if absf(ramp.height_at(z) - plain_height) > 0.35:
			return true
	return false


func surface_at(x: float, z: float) -> Surface:
	if on_entrance(x, z):
		return Surface.BRIDGE
	if edge_distance(x, z) < 0.0:
		return Surface.VOID
	var ramp: Ramp = ramp_at(x, z)
	if ramp != null:
		return Surface.ROUGH if ramp.kind == "scree" else Surface.GROUND
	for peak: Peak in peaks:
		var distance: float = Vector2(x - peak.center.x, z - peak.center.y).length()
		if distance <= peak.radius:
			return Surface.PEAK
		if distance <= peak.radius + CLIFF_WIDTH:
			return Surface.CLIFF
	var bridge: Bridge = bridge_at(x, z)
	var depth: float = hazard_depth(x, z)
	if depth > 0.0:
		return Surface.HAZARD
	if bridge != null:
		return Surface.GROUND  # the abutment
	if depth > -BANK_WIDTH:
		return Surface.CLIFF
	for tier: int in [1, 2, 3]:
		var edge: float = tier_edge_z(tier, x)
		if z >= edge and z < edge + CLIFF_WIDTH:
			return Surface.CLIFF
	if _on_ramp_kerb(x, z, _plain_height(x, z)):
		return Surface.CLIFF
	if in_scree(x, z):
		return Surface.ROUGH
	return Surface.GROUND


func _hills(x: float, z: float) -> float:
	return 0.35 * sin(x * 0.19 + 0.4) * cos(z * 0.17 + 0.9) + 0.15 * sin(x * 0.31 + z * 0.13 + 2.0)


## The terrace height at (x, z) with the cliff bands between terraces (a steep lerp CLIFF_WIDTH south of each edge) and the gentle hills, no ramps,
## no peaks, no water: the "plain" land.
func _plain_height(x: float, z: float) -> float:
	var tier: int = tier_at(x, z)
	var height: float = tier_height(tier)
	var feature: float = 1.0
	if tier < 3:
		var edge: float = tier_edge_z(tier + 1, x)
		var into: float = edge + CLIFF_WIDTH - z
		if into > 0.0:
			# the cliff band below the next terrace (on the dry land: at the ravine the banks take over)
			height = lerpf(tier_height(tier), tier_height(tier + 1), smoothstep(0.0, 1.0, into / CLIFF_WIDTH))
		feature = minf(feature, smoothstep(0.0, 3.0, absf(z - edge - CLIFF_WIDTH * 0.5) - CLIFF_WIDTH * 0.5))
	if tier >= 1:
		var below: float = tier_edge_z(tier, x)
		feature = minf(feature, smoothstep(0.0, 3.0, below - z))
	for spot: Vector3 in flat_spots:
		feature = minf(feature, smoothstep(spot.z * 0.7, spot.z * 1.3, Vector2(x - spot.x, z - spot.y).length()))
	for ramp: Ramp in ramps:
		var p: Vector2 = Vector2(x, z)
		var nearest: Vector2 = Vector2(clampf(x, ramp.rect.position.x, ramp.rect.end.x), clampf(z, ramp.rect.position.y, ramp.rect.end.y))
		feature = minf(feature, smoothstep(0.0, 3.0, nearest.distance_to(p)))
	feature = minf(feature, smoothstep(0.5, 3.5, -hazard_depth(x, z)))
	return height + _hills(x, z) * feature


func ground_height(x: float, z: float) -> float:
	var edge: float = edge_distance(x, z)
	if edge < 0.0:
		if on_entrance(x, z):
			return 0.0
		if z > MAX_CORNER.y - 2.0 and x > MIN_CORNER.x + 2.0 and x < MAX_CORNER.x - 2.0:
			# the south rim steps down a metre to the meadow the overflow pool lies in (the entrance bridge crosses it)
			return -1.0 * smoothstep(0.0, 2.5, -edge)
		# the valley's walls: the land climbs steeply beyond the west, east and north rims, except on the Rotheart's mound behind the north rim (flat, the
		# plateau's level, so the tree and its roots stand where the root gate is)
		var inner: Vector2 = Vector2(clampf(x, MIN_CORNER.x + 0.5, MAX_CORNER.x - 0.5), clampf(z, MIN_CORNER.y + 0.5, MAX_CORNER.y - 0.5))
		var mound: float = 1.0 - smoothstep(30.0, 40.0, absf(x - ROTHEART.x)) if z < MIN_CORNER.y else 0.0
		return tier_height(tier_at(inner.x, inner.y)) + (smoothstep(0.0, 6.0, -edge) * 6.5 + (-edge) * 0.08) * (1.0 - mound)
	var ramp: Ramp = ramp_at(x, z)
	if ramp != null:
		return ramp.height_at(z)
	for peak: Peak in peaks:
		var distance: float = Vector2(x - peak.center.x, z - peak.center.y).length()
		if distance <= peak.radius:
			return peak.height
		if distance < peak.radius + CLIFF_WIDTH:
			var t: float = smoothstep(0.0, 1.0, (distance - peak.radius) / CLIFF_WIDTH)
			return lerpf(peak.height, _plain_height(x, z), t)
	var depth: float = hazard_depth(x, z)
	var bridge: Bridge = bridge_at(x, z)
	if depth > 0.0:
		return _bed_level(x, z) + 0.0
	if bridge != null:
		# the abutments: flat at the terrace the bridge end stands on
		return bridge.y_a if bridge.fraction_at(x, z) < 0.5 else bridge.y_b
	if depth > -BANK_WIDTH:
		var land: float = _plain_height(x, z)
		return lerpf(land, _bed_level(x, z), smoothstep(0.0, 1.0, (depth + BANK_WIDTH) / BANK_WIDTH))
	return _plain_height(x, z)


## The bottom of the water or sludge at (x, z): a metre under its level.
func _bed_level(x: float, z: float) -> float:
	return water_level_at(x, z) - 1.0


## The level of the water or sludge at (x, z): the ravine's and the drain's below the market, the gorge's stepping down the terraces, the chasm's and
## the pits' half a metre under their terrace.
func water_level_at(x: float, z: float) -> float:
	for pit: Vector3 in pits:
		if Vector2(x - pit.x, z - pit.y).length() <= pit.z + 1.0:
			return tier_height(tier_at(pit.x, pit.y)) - 0.5
	if Geometry2D.get_closest_point_to_segment(Vector2(x, z), CHASM_A, CHASM_B).distance_to(Vector2(x, z)) <= CHASM_RADIUS + 1.0:
		return TIER_HEIGHTS[2] - 0.5
	if x <= RAVINE_END_X and STREAM_HALF_WIDTH + BANK_WIDTH + 0.6 - absf(z - stream_z(x)) > 0.0:
		return WATER_LEVEL
	if DRAIN.z + 1.0 - Vector2(x - DRAIN.x, z - DRAIN.y).length() > 0.0:
		return WATER_LEVEL
	if x < GORGE_X + GORGE_HALF_WIDTH + 1.5 and z >= GORGE_FROM_Z - 0.5 and z <= stream_z(GORGE_X) + 2.0:
		return gorge_water_level(z)
	return tier_height(tier_at(x, z)) - 0.5


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


## How twisted the land is at (x, z), 0 (the market and the farm, healthy) to 1 (the Rotheart's roots): the data of `corruption` (start_z, end_z,
## centre_x, spread) shapes a band that deepens northward (up the terraces) and is strongest on the centre line.
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
	var p: Vector2 = Vector2(x, z)
	for bridge: Bridge in bridges:
		var t: float = bridge.fraction_at(x, z)
		if t <= 0.0 or t >= 1.0:
			continue
		if Geometry2D.get_closest_point_to_segment(p, bridge.a, bridge.b).distance_to(p) <= BRIDGE_HALF_WIDTH:
			return bridge
	return null


## 0 at the bridge's a end, 1 at its b end, for a point on it.
func bridge_fraction(bridge: Bridge, x: float, z: float) -> float:
	return bridge.fraction_at(x, z)


# ---- Peaks, ramps, chutes, bridges, hazards -------------------------------------------------------------


func _peak(id: String, title: String, center: Vector2, radius: float, height: float) -> void:
	var peak: Peak = Peak.new()
	peak.id = id
	peak.title = title
	peak.center = center
	peak.radius = radius
	peak.height = height
	peaks.append(peak)


## Mount Scrapmore rises from the farm terrace's east end, Rust Peak from the plateau's west; the compost overlook is a knoll on the compost terrace
## reached by a vine ladder (a side pocket with a chest).
func _peaks() -> void:
	_peak("scrapmore", "Mount Scrapmore", Vector2(70.5, 79.0), 4.5, TIER_HEIGHTS[1] + 5.0)
	_peak("rust", "Rust Peak", Vector2(29.0, 22.0), 4.5, TIER_HEIGHTS[3] + 5.0)
	_peak("overlook", "The Compost Overlook", Vector2(36.0, 44.0), 3.0, TIER_HEIGHTS[2] + 2.5)


func _ramp(id: String, kind: String, x0: float, x1: float, z0: float, z1: float, y0: float, y1: float) -> void:
	var ramp: Ramp = Ramp.new()
	ramp.id = id
	ramp.kind = kind
	ramp.rect = Rect2(x0, z0, x1 - x0, z1 - z0)
	ramp.y0 = y0
	ramp.y1 = y1
	ramps.append(ramp)


## The ways up: the east stone stairs from the market to the farm terrace (past the drain), the central stairs, the giant root ramp and the west vine
## ladder from the farm terrace to the compost terrace, the stone stairs behind the junk barricade and the scree slope (mount only) from the compost
## terrace to the plateau, and the vine ladder up the compost overlook.
func _ramps() -> void:
	_ramp("stairs_east", "stairs", 76.0, 80.0, 90.0, 104.0, TIER_HEIGHTS[0], TIER_HEIGHTS[1])
	_ramp("stairs_mid", "stairs", 48.0, 52.0, 56.0, 68.0, TIER_HEIGHTS[1], TIER_HEIGHTS[2])
	_ramp("root_ramp", "ramp", 62.0, 67.0, 54.0, 70.0, TIER_HEIGHTS[1], TIER_HEIGHTS[2])
	_ramp("ladder_west", "ladder", 43.0, 45.4, 59.0, 64.5, TIER_HEIGHTS[1], TIER_HEIGHTS[2])
	_ramp("stairs_top", "stairs", 46.0, 50.0, 32.0, 44.0, TIER_HEIGHTS[2], TIER_HEIGHTS[3])
	_ramp("scree_slope", "scree", 72.0, 80.0, 34.0, 46.0, TIER_HEIGHTS[2], TIER_HEIGHTS[3])
	_ramp("ladder_overlook", "ladder", 34.8, 37.2, 46.5, 49.5, TIER_HEIGHTS[2], TIER_HEIGHTS[2] + 2.5)


func _chute(id: String, title: String, pos: Vector2, path: PackedVector2Array, dest: String) -> void:
	var chute: Chute = Chute.new()
	chute.id = id
	chute.title = title
	chute.pos = pos
	chute.path = path
	chute.dest_anchor = dest
	chutes.append(chute)


## Mount Scrapmore's chute slides down its west side onto the farm terrace; Rust Peak's flies over the gorge's head down to the compost terrace.
func _chutes() -> void:
	_chute("chute_a", "Trash Chute (Mount Scrapmore)", Vector2(67.0, 77.5), PackedVector2Array([Vector2(67.0, 77.5), Vector2(63.0, 76.5), Vector2(58.5, 76.0), Vector2(54.0, 76.0)]), "chute_a_end")
	_chute("chute_b", "Trash Chute (Rust Peak)", Vector2(26.5, 24.0), PackedVector2Array([Vector2(26.5, 24.0), Vector2(23.5, 28.0), Vector2(22.5, 34.0), Vector2(24.5, 41.0), Vector2(27.0, 50.0)]), "chute_b_end")


func _bridge(id: String, a: Vector2, b: Vector2, y_a: float, y_b: float, rise: float) -> void:
	var bridge: Bridge = Bridge.new()
	bridge.id = id
	bridge.a = a
	bridge.b = b
	bridge.y_a = y_a
	bridge.y_b = y_b
	bridge.rise = rise
	bridge.x = a.x
	bridges.append(bridge)


## Where a ravine bridge's ends stand: a little past the banks on each lip.
static func ravine_bridge_ends(x: float) -> Array[Vector2]:
	var reach: float = STREAM_HALF_WIDTH + BANK_WIDTH + 0.7
	return [Vector2(x, stream_z(x) + reach), Vector2(x, stream_z(x) - reach)]


## The arched vine bridge in the middle (Druid Sorrel's), the west vine bridge (a bean) and the east vine bridge across the sludge chasm (a bean).
func _bridges() -> void:
	var centre: Array[Vector2] = ravine_bridge_ends(46.0)
	_bridge("bridge_center", centre[0], centre[1], TIER_HEIGHTS[0], TIER_HEIGHTS[1], 1.8)
	var west: Array[Vector2] = ravine_bridge_ends(28.0)
	_bridge("bridge_west", west[0], west[1], TIER_HEIGHTS[0], TIER_HEIGHTS[1], 1.4)
	_bridge("bridge_east", Vector2(64.5, 50.0), Vector2(73.5, 50.0), TIER_HEIGHTS[2], TIER_HEIGHTS[2], 0.6)


func _pits_and_scree() -> void:
	pits = [Vector3(23.0, 118.0, 3.0), Vector3(77.5, 56.0, 2.6)] as Array[Vector3]
	scree = [Vector3(72.0, 20.0, 11.0)] as Array[Vector3]


# ---- Anchors, chests, enemies -----------------------------------------------------------------


func _at(name: String, x: float, z: float) -> void:
	anchors[name] = Vector3(x, 0.0, z)


func _anchors() -> void:
	# The way in: the entrance bridge from town. A fresh visit starts on its deck facing north; the exit spot waits at its far landing.
	_at("spawn", ENTRANCE_X, ENTRANCE_Z1 - 6.0)
	_at("exit", ENTRANCE_X, ENTRANCE_Z1 - 2.0)
	# T0, the Market Terrace (Compost Commons): the plaza round the greenhouse, the hub's things on its rim (the hub anchor is where you wake).
	_at("hub", 50.0, 126.0)
	_at("rift_station", 42.0, 130.0)
	_at("heal", 39.5, 118.0)
	_at("wren", 41.0, 124.0)
	_at("stable_1", 36.0, 127.0)
	_at("marigold", 57.0, 112.0)
	_at("hob", 62.0, 116.0)
	_at("compost_bin", 58.0, 127.0)
	_at("trough", 64.0, 129.0)
	_at("shrine", 70.0, 127.0)
	_at("giant_chest", 24.0, 131.0)
	_at("vault_lever", 79.5, 127.0)
	_at("pickup_fert_1", 22.0, 110.5)
	_at("pickup_junk_1", 70.0, 108.0)
	_at("pickup_bean_1", 34.0, 106.0)
	_at("animal_2", 33.0, 132.0)
	_at("sorrel", 43.0, 104.0)
	_at("bank_center", 46.0, 103.0)
	_at("bank_west", 28.0, 103.0)
	_at("mound_west", 25.5, 105.5)
	# T1, the Farm Terrace (west) and the Junk Peaks (east): the bridge landings, the crops, the grove and the quiz, the dam, the goat stable, the fair,
	# Mount Scrapmore's mound and summit, the chute's landing.
	_at("land_center", 46.0, 88.0)
	_at("land_west", 29.0, 89.0)
	_at("stable_2", 30.0, 84.0)
	_at("barricade_dam", 29.0, 77.0)
	_at("crop_1", 29.0, 73.0)
	_at("crop_2", 34.0, 73.0)
	_at("crop_3", 39.0, 73.0)
	_at("quiz", 34.0, 82.0)
	_at("animal_1", 40.0, 68.0)
	_at("pickup_fert_2", 46.0, 80.0)
	_at("pickup_junk_2", 58.0, 72.0)
	_at("pickup_bean_2", 79.5, 78.0)
	_at("minigame", 60.0, 84.0)
	_at("mound_a", 70.5, 86.5)
	_at("ladder_a_top", 70.5, 81.5)
	_at("chute_a_end", 54.0, 76.0)
	_at("animal_3", 74.5, 91.0)
	# T2, the Compost Terrace: the stairs' landing, the sludge chasm's banks and the east pocket, the overlook's ladder, the Rust Peak chute's landing.
	_at("mound_east", 61.0, 53.0)
	_at("bank_east", 63.0, 50.0)
	_at("land_east", 75.0, 50.5)
	_at("pickup_fert_3", 38.0, 50.0)
	_at("pickup_junk_3", 75.0, 48.0)
	_at("pickup_bean_3", 40.0, 20.0)
	_at("chute_b_end", 27.0, 50.0)
	_at("barricade_gate", 48.0, 45.5)
	# T3, the Overgrown Plateau: the road to the root gate, the avenue past Rust Peak (the Seed Shrine on its summit) to the Trash Panda Throne.
	_at("mound_b", 29.0, 30.5)
	_at("ladder_b_top", 29.0, 25.5)
	_at("puzzle", 29.0, 19.5)
	_at("mini_dungeon", 31.0, 9.5)
	_at("main_dungeon", 50.0, 9.2)


func _chests() -> void:
	chests = {
		"chest_fridge": Vector3(74.5, 0.0, 131.5),
		"chest_compost": Vector3(21.5, 0.0, 107.5),
		"chest_peak_a": Vector3(68.5, 0.0, 77.5),
		"chest_hay": Vector3(55.6, 0.0, 66.5),
		"chest_log": Vector3(74.0, 0.0, 60.5),
		"chest_peak_b": Vector3(26.0, 0.0, 21.0),
		"chest_car": Vector3(58.0, 0.0, 24.0),
		"chest_barn": Vector3(79.0, 0.0, 18.0),
		"chest_peak_c": Vector3(32.0, 0.0, 20.5),
		"chest_peak_d": Vector3(73.0, 0.0, 77.0),
		"chest_scree_ne": Vector3(78.0, 0.0, 6.5),
		"chest_corner_nw": Vector3(21.0, 0.0, 7.0),
		"chest_back_edge": Vector3(40.0, 0.0, 6.0),
		"chest_thicket_s": Vector3(36.0, 0.0, 43.0),
	}


## Spread over the terraces and the routes: a golem by the west bridge's foot, a scarecrow at the east stairs' foot, gulls over the fair, a golem on the
## farm terrace, a scarecrow before the barricade, gulls over the scree and in the plateau's east pocket, a scarecrow by Scrapmore's east lane.
func _enemies() -> void:
	enemy_spawns = [
		{"type": "golem", "home": Vector3(30.0, 0.0, 109.0), "patrol": 3.5},
		{"type": "scarecrow", "home": Vector3(73.0, 0.0, 111.0), "patrol": 2.5},
		{"type": "gulls", "home": Vector3(66.0, 0.0, 87.0), "patrol": 5.0},
		{"type": "golem", "home": Vector3(40.0, 0.0, 87.0), "patrol": 3.0},
		{"type": "scarecrow", "home": Vector3(42.0, 0.0, 50.0), "patrol": 3.0},
		{"type": "gulls", "home": Vector3(70.0, 0.0, 24.0), "patrol": 5.0},
		{"type": "gulls", "home": Vector3(58.0, 0.0, 16.0), "patrol": 4.0},
		{"type": "scarecrow", "home": Vector3(78.0, 0.0, 76.0), "patrol": 2.5},
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
	_area("commons", "Compost Commons", 50.0, 118.0, 20.0)
	_area("commons", "Compost Commons", 32.0, 126.0, 14.0)
	_area("commons", "Compost Commons", 70.0, 126.0, 14.0)
	_area("stream", "The Ravine", 24.0, 96.0, 7.0)
	_area("stream", "The Ravine", 36.0, 96.0, 7.0)
	_area("stream", "The Ravine", 48.0, 96.0, 7.0)
	_area("stream", "The Ravine", 60.0, 96.0, 7.0)
	_area("stream", "The Ravine", 70.0, 96.0, 7.0)
	_area("stream", "The Ravine", 21.0, 44.0, 6.0)
	_area("stream", "The Ravine", 21.0, 56.0, 6.0)
	_area("stream", "The Ravine", 21.0, 68.0, 6.0)
	_area("stream", "The Ravine", 21.0, 80.0, 6.0)
	_area("stream", "The Ravine", 21.0, 90.0, 6.0)
	_area("farm", "The Farm Terrace", 36.0, 78.0, 15.0)
	_area("farm", "The Compost Terrace", 36.0, 50.0, 12.0)
	_area("farm", "The Compost Terrace", 52.0, 50.0, 12.0)
	_area("peaks", "The Junk Peaks", 68.0, 80.0, 13.0)
	_area("peaks", "The Junk Peaks", 75.0, 50.0, 9.0)
	_area("peaks", "The Junk Peaks", 72.0, 20.0, 15.0)
	_area("wetlands", "The Overgrown Plateau", 50.0, 22.0, 16.0)
	_area("throne", "The Throne Approach", 30.0, 18.0, 14.0)
	_area("meadow", "The Verdant Dump", 50.0, 70.0, 100.0)


func _paths() -> void:
	# Routes are wide and clear: main roads MAIN_PATH_WIDTH, spurs SIDE_PATH_WIDTH, nothing solid within PATH_CLEARANCE of their edges; every terrace
	# hangs on a loop and has two or three ways to the next.
	var centre: Array[Vector2] = ravine_bridge_ends(46.0)
	var west: Array[Vector2] = ravine_bridge_ends(28.0)
	var plaza_s: Vector2 = Vector2(50.0, 129.5)
	var plaza_n: Vector2 = Vector2(50.0, 110.5)
	var plaza_w: Vector2 = Vector2(40.5, 120.0)
	var plaza_e: Vector2 = Vector2(59.5, 120.0)
	paths = [
		# T0: the way in and the four roads off the plaza's rim (north to the arched bridge, west to the west bridge, east to the stone stairs)
		{"line": PackedVector2Array([plaza_s, Vector2(50.0, ENTRANCE_Z0 + 1.0)]), "width": MAIN_PATH_WIDTH},
		{"line": PackedVector2Array([plaza_n, Vector2(46.0, 104.0), centre[0]]), "width": MAIN_PATH_WIDTH},
		{"line": PackedVector2Array([plaza_w, Vector2(30.0, 120.0), Vector2(28.0, 106.0), west[0]]), "width": MAIN_PATH_WIDTH},
		{"line": PackedVector2Array([plaza_e, Vector2(70.0, 116.0), Vector2(78.0, 106.0), Vector2(78.0, 103.0)]), "width": MAIN_PATH_WIDTH},
		{"line": PackedVector2Array([Vector2(46.0, 104.0), Vector2(60.0, 105.0), Vector2(70.0, 108.0), Vector2(78.0, 106.0)]), "width": SIDE_PATH_WIDTH},
		# T1: the fair lane from the east stairs' top past Scrapmore's foot to the arched bridge's landing, the east lane to the root ramp, the main road
		# north to the central stairs, the farm lane to the west bridge's landing and the crop lane to the vine ladder
		{"line": PackedVector2Array([Vector2(78.0, 89.0), Vector2(70.0, 87.0), Vector2(62.0, 86.5), Vector2(52.0, 87.0), centre[1]]), "width": MAIN_PATH_WIDTH},
		{"line": PackedVector2Array([Vector2(78.0, 89.0), Vector2(78.0, 74.0), Vector2(70.0, 72.5), Vector2(64.5, 71.5)]), "width": MAIN_PATH_WIDTH},
		{"line": PackedVector2Array([centre[1], Vector2(48.0, 76.0), Vector2(50.0, 69.0)]), "width": MAIN_PATH_WIDTH},
		{"line": PackedVector2Array([centre[1], Vector2(36.0, 89.0), west[1]]), "width": MAIN_PATH_WIDTH},
		{"line": PackedVector2Array([centre[1], Vector2(42.0, 78.0), Vector2(42.0, 70.0), Vector2(44.2, 65.5)]), "width": SIDE_PATH_WIDTH},
		# T2: the landing, the road to the barricade stairs, the compost lane west to the overlook's ladder, the east bridge's banks and the scree slope
		{"line": PackedVector2Array([Vector2(50.0, 55.0), Vector2(48.0, 47.5)]), "width": MAIN_PATH_WIDTH},
		{"line": PackedVector2Array([Vector2(50.0, 55.0), Vector2(40.0, 56.0), Vector2(36.0, 51.0)]), "width": SIDE_PATH_WIDTH},
		{"line": PackedVector2Array([Vector2(50.0, 55.0), Vector2(57.0, 52.0), Vector2(64.0, 50.0)]), "width": SIDE_PATH_WIDTH},
		{"line": PackedVector2Array([Vector2(74.5, 50.0), Vector2(76.0, 47.5)]), "width": SIDE_PATH_WIDTH},
		# T3: the landing, the road to the root gate, the avenue to the throne's door and the lane round Rust Peak back to the landing
		{"line": PackedVector2Array([Vector2(48.0, 31.0), Vector2(50.0, 11.0)]), "width": MAIN_PATH_WIDTH},
		{"line": PackedVector2Array([Vector2(48.0, 31.0), Vector2(44.0, 22.0), Vector2(38.0, 16.0), Vector2(32.0, 12.5)]), "width": MAIN_PATH_WIDTH},
		{"line": PackedVector2Array([Vector2(32.0, 12.5), Vector2(26.0, 10.5), Vector2(21.0, 15.0), Vector2(20.5, 28.0), Vector2(25.0, 33.5), Vector2(35.0, 34.0), Vector2(42.0, 33.0), Vector2(44.5, 30.5), Vector2(48.0, 31.0)]), "width": SIDE_PATH_WIDTH},
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
	# T0, the market: the hub's things round the plaza's rim (the greenhouse is a landmark), three market stalls under patchwork awnings, the scrap-built
	# barn off the north road, the compost heap and its chest in the west corner, the fridge in the east corner.
	_prop("barn", 37.5, 108.0, 20.0, 1.0, 4.2)
	_prop("harvest_table", 39.5, 118.0, 90.0, 1.0, 1.5)
	_prop("swap_shed", 64.5, 113.5, 200.0, 1.0, 1.2)
	_prop("compost_bin", 58.0, 127.0, 180.0, 1.0, 1.4)
	_prop("shrine", 70.0, 127.0, 0.0, 1.0, 1.2)
	_prop("trough", 64.0, 129.0, 0.0, 1.0, 1.2)
	_prop("stable", 36.0, 127.0, 0.0, 1.0, 1.8)
	_prop("market_stall", 35.5, 115.0, 90.0, 1.0, 1.6, 0)
	_prop("market_stall", 67.0, 124.0, 270.0, 1.0, 1.6, 1)
	_prop("market_stall", 74.0, 120.0, 250.0, 1.0, 1.6, 2)
	_prop("compost_heap", 24.0, 114.0, 0.0, 1.0, 0.0)
	_prop("fridge", 77.0, 132.0, 200.0, 1.0, 0.9)
	_prop("beanstalk_mound", 25.5, 105.5, 0.0, 1.0, 0.0, 1)
	# T1, the farm terrace: the crop plots in a row, the druid grove's appliance ring, the scarecrow over the crops, the junk dam at the gorge, the goat
	# stable, the haybale that hides a chest; the fair stage at Scrapmore's foot and the sprout mound.
	_prop("crop_plot", 29.0, 73.0, 0.0, 1.0, 0.0, 0)
	_prop("crop_plot", 34.0, 73.0, 0.0, 1.0, 0.0, 1)
	_prop("crop_plot", 39.0, 73.0, 0.0, 1.0, 0.0, 2)
	_prop("appliance_ring", 34.0, 81.0, 0.0, 1.0, 0.0)
	_prop("scarecrow", 34.0, 69.0, 20.0, 1.0, 0.7)
	_prop("junk_dam", 26.5, 77.0, 90.0, 1.0, 0.0)
	_prop("stable", 30.0, 84.0, 90.0, 1.0, 1.8)
	_prop("haybale", 54.0, 66.0, 10.0, 1.0, 1.0, 1)
	_prop("fair_stage", 60.0, 80.5, 0.0, 1.0, 1.9)
	_prop("beanstalk_mound", 70.5, 86.5, 0.0, 1.0, 0.0, 0)
	# T2, the compost terrace: steaming compost heaps, the machinery pile by the gorge's fall, the east pocket's hollow log, the sprout mound.
	_prop("compost_heap", 37.0, 42.0, 0.0, 1.0, 0.0)
	_prop("compost_heap", 42.0, 58.5, 0.0, 1.0, 0.0)
	_prop("appliance_pile", 28.0, 58.0, 120.0, 1.0, 1.6)
	_prop("hollow_log", 73.0, 59.5, 10.0, 1.0, 0.0)
	_prop("beanstalk_mound", 61.0, 53.0, 0.0, 1.0, 0.0, 2)
	# T3, the plateau: the car husk that hides a chest, junk clusters, the tyre stacks either side of the throne's steps, Rust Peak's mound, the scrap
	# barn with its chest behind on the scree, a wreck and hay by it.
	_prop("car_husk", 60.0, 26.0, 160.0, 1.0, 1.7, 1)
	_prop("junk_pile", 41.0, 28.0, 0.0, 1.1, 2.3, 2)
	_prop("tire_stack", 56.0, 32.0, 0.0, 1.0, 1.0)
	_prop("beanstalk_mound", 29.0, 30.5, 0.0, 1.0, 0.0, 3)
	_prop("barn", 74.0, 13.0, 0.0, 0.9, 3.8)
	_prop("car_husk", 68.0, 9.0, 200.0, 1.0, 1.7, 3)
	_prop("junk_pile", 64.0, 24.0, 0.0, 1.0, 2.2, 1)
	_prop("haybale", 80.0, 12.0, 0.0, 1.0, 1.0, 2)


func _wall() -> void:
	# No tyre wall and no district dividers any more: the junk barricade plugs the foot of the stairs to the plateau, the junk dam chokes the gorge.
	barricade_positions["gate"] = Vector3(48.0, 0.0, 45.5)
	barricade_positions["dam"] = Vector3(26.5, 0.0, 77.0)


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
	_sign("sign.hub_main", 46.5, 129.5, 180.0, 1.2)
	_sign("sign.oath", 55.5, 108.0, 190.0)
	_sign("sign.exit", 54.0, 129.0, 180.0)
	_sign("sign.heal_table", 38.0, 114.5, 180.0)
	_sign("sign.swap_shed", 67.0, 115.5, 200.0)
	_sign("sign.compost_bin", 61.0, 125.0, 160.0)
	_sign("sign.shrine", 72.5, 125.5, 190.0)
	_sign("sign.trough", 66.5, 131.0, 170.0, 0.9)
	_sign("sign.stable_1", 33.0, 127.5, 160.0)
	_sign("sign.fields", 44.0, 84.0, 150.0)
	_sign("sign.crops", 31.5, 76.4, 180.0, 0.9)
	_sign("sign.fair_stage", 57.0, 82.5, 180.0)
	_sign("sign.scrapmore", 73.0, 88.0, 180.0)
	_sign("sign.bridge_west", 24.5, 101.5, 180.0)
	_sign("sign.bridge_center", 49.8, 101.5, 200.0)
	_sign("sign.bridge_east", 63.5, 53.5, 180.0)
	_sign("sign.dam", 30.0, 80.5, 190.0)
	_sign("sign.stable_2", 30.0, 87.8, 170.0)
	_sign("sign.barricade", 51.8, 47.0, 190.0)
	_sign("sign.landfill", 28.0, 11.0, 180.0)
	_sign("sign.main_dungeon", 54.5, 8.0, 180.0, 1.5)
	_sign("sign.seed_shrine", 31.5, 18.5, 190.0)
	_sign("sign.scree", 78.5, 49.0, 170.0)


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
		keep_clear.append(Vector3(feature.pos.x, feature.pos.z, 4.5 if feature.radius > 0.0 else 3.0))
	for spawn: Dictionary in enemy_spawns:
		var home: Vector3 = spawn["home"] as Vector3
		keep_clear.append(Vector3(home.x, home.z, 3.0))
	for chute: Chute in chutes:
		for point: Vector2 in chute.path:
			keep_clear.append(Vector3(point.x, point.y, 2.6))
	for sign: Sign in signs:
		keep_clear.append(Vector3(sign.pos.x, sign.pos.z, 2.5))
	for ramp: Ramp in ramps:
		var c: Vector2 = ramp.rect.get_center()
		keep_clear.append(Vector3(c.x, c.y, maxf(ramp.rect.size.x, ramp.rect.size.y) * 0.5 + 1.5))
	keep_clear.append(Vector3(PLAZA_CENTER.x, PLAZA_CENTER.y, PLAZA_RADIUS + 2.5))
	keep_clear.append(Vector3(ENTRANCE_X, ENTRANCE_Z0, 6.0))
	for spot: Vector3 in LANDMARK_SPOTS:
		keep_clear.append(Vector3(spot.x, spot.y, spot.z + 1.0))
	return keep_clear


## Trees at the valley's edges, along the cliff tops and in framing groups, bushes at the edges and as reed beds by the water, flowers in clumps along
## the paths (fewer toward the Rotheart), a few rocks on the rim, mushrooms in the druid grove and under the cliffs. No scattered junk: junk stands in the
## clusters of `_features`.
func _scatter() -> void:
	var keep_clear: Array[Vector3] = keep_clear_spots()
	# the valley's side bands (the west band stays north of the gorge's start and south of the ravine, where there is land)
	_scatter_kind("tree", Rect2(18.5, 102.0, 4.0, 30.0), 5, keep_clear, 1.8, 0.5, 1.0, 1.4)
	_scatter_kind("tree", Rect2(78.0, 108.0, 3.5, 24.0), 4, keep_clear, 1.8, 0.5, 1.0, 1.4)
	_scatter_kind("tree", Rect2(25.0, 64.0, 3.0, 22.0), 3, keep_clear, 1.8, 0.5, 1.0, 1.3)
	_scatter_kind("tree", Rect2(78.5, 48.0, 3.0, 36.0), 4, keep_clear, 1.8, 0.5, 1.0, 1.3)
	_scatter_kind("tree", Rect2(18.5, 5.0, 10.0, 8.0), 3, keep_clear, 1.8, 0.5, 1.0, 1.3)
	_scatter_kind("tree", Rect2(39.0, 5.0, 24.0, 3.5), 4, keep_clear, 1.8, 0.5, 1.0, 1.3)
	# along the cliff tops (the terraces' north edges, seen from below as a line of crowns)
	_scatter_kind("tree", Rect2(26.0, 88.0, 14.0, 2.5), 3, keep_clear, 1.6, 0.5, 1.0, 1.3)
	_scatter_kind("tree", Rect2(54.0, 88.5, 10.0, 2.5), 2, keep_clear, 1.6, 0.5, 1.0, 1.3)
	_scatter_kind("tree", Rect2(26.0, 60.0, 14.0, 2.2), 3, keep_clear, 1.6, 0.5, 1.0, 1.3)
	_scatter_kind("tree", Rect2(68.0, 60.0, 10.0, 2.2), 2, keep_clear, 1.6, 0.5, 1.0, 1.3)
	_scatter_kind("tree", Rect2(26.0, 36.0, 16.0, 2.2), 3, keep_clear, 1.6, 0.5, 1.0, 1.3)
	_scatter_kind("tree", Rect2(54.0, 36.0, 10.0, 2.2), 2, keep_clear, 1.6, 0.5, 1.0, 1.3)
	# framing groups: the market's south corners either side of the bridge head, the plaza's shoulders, the fair's back, the stairs' feet, the plateau
	_grove("tree", Vector2(41.0, 133.5), 3, 2.4, keep_clear)
	_grove("tree", Vector2(59.5, 134.0), 3, 2.4, keep_clear)
	_grove("tree", Vector2(29.0, 100.0), 2, 2.4, keep_clear)
	_grove("tree", Vector2(52.0, 102.0), 2, 2.2, keep_clear)
	_grove("tree", Vector2(72.0, 102.0), 3, 2.6, keep_clear)
	_grove("tree", Vector2(58.0, 92.0), 2, 2.2, keep_clear)
	_grove("tree", Vector2(56.0, 60.0), 3, 2.6, keep_clear)
	_grove("tree", Vector2(31.0, 57.0), 3, 2.6, keep_clear)
	_grove("tree", Vector2(42.0, 14.0), 3, 2.6, keep_clear)
	_grove("tree", Vector2(60.0, 14.0), 3, 2.6, keep_clear)
	_grove("tree", Vector2(24.0, 32.0), 3, 2.6, keep_clear)
	# bushes at the edges, reed beds by the water, under-cliff beds
	_scatter_kind("bush", Rect2(18.5, 102.0, 6.0, 32.0), 6, keep_clear, 1.0, 0.45, 0.9, 1.4)
	_scatter_kind("bush", Rect2(76.0, 108.0, 6.0, 26.0), 5, keep_clear, 1.0, 0.45, 0.9, 1.4)
	_scatter_kind("bush", Rect2(25.0, 64.0, 5.0, 24.0), 4, keep_clear, 1.0, 0.45, 0.9, 1.4)
	_scatter_kind("bush", Rect2(26.0, 40.0, 5.0, 20.0), 4, keep_clear, 1.0, 0.45, 0.9, 1.4)
	_scatter_kind("bush", Rect2(39.0, 6.0, 24.0, 22.0), 14, keep_clear, 1.0, 0.45, 1.0, 1.5)
	_scatter_kind("bush", Rect2(18.5, 5.0, 12.0, 10.0), 4, keep_clear, 1.0, 0.45, 0.9, 1.4)
	# rocks on the rim and the cliff tops, mushrooms in the druid grove and in the cliffs' shade
	_scatter_kind("rock", Rect2(18.5, 5.0, 63.0, 4.0), 4, keep_clear, 1.8, 0.0, 0.9, 1.6)
	_scatter_kind("rock", Rect2(18.5, 130.0, 63.0, 5.0), 4, keep_clear, 1.8, 0.0, 0.9, 1.6)
	_scatter_kind("rock", Rect2(26.0, 36.0, 50.0, 2.0), 3, keep_clear, 1.8, 0.0, 0.9, 1.4)
	_scatter_kind("mushrooms", Rect2(29.0, 78.0, 10.0, 8.0), 5, keep_clear, 1.0, 0.0, 0.9, 1.4)
	_scatter_kind("mushrooms", Rect2(26.0, 40.0, 50.0, 3.0), 6, keep_clear, 1.0, 0.0, 0.9, 1.4)
	_scatter_kind("mushrooms", Rect2(26.0, 64.0, 50.0, 3.0), 6, keep_clear, 1.0, 0.0, 0.9, 1.4)
	_flower_clumps(keep_clear)


## A tight group of count trees round center (the edge of a space), each kept clear of routes and anchors like the scatter.
func _grove(kind: String, center: Vector2, count: int, radius: float, keep_clear: Array[Vector3]) -> void:
	_scatter_kind(kind, Rect2(center - Vector2(radius, radius), Vector2(radius * 2.0, radius * 2.0)), count, keep_clear, 1.3, 0.5, 0.9, 1.3)


## Clumps of four to six flowers along the path edges (alternating sides every few metres) and along the farm's crop row; the corruption gradient
## thins them toward the Rotheart (`corruption.flowers` is how much of a clump survives at full corruption).
func _flower_clumps(_keep_clear: Array[Vector3]) -> void:
	# flowers are decoration (no radius): they keep a lighter distance than the solid scatter, so the busy market still gets its clumps
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
	for center: Vector2 in [Vector2(27.0, 75.5), Vector2(31.5, 75.5), Vector2(36.5, 75.5), Vector2(41.5, 75.5)]:
		_clump("flowers", center, 1.0, 5, keep_clear)
	# the reference's foreground: big clumps at the market's south corners, framing the view up the valley
	for center: Vector2 in [Vector2(22.0, 134.0), Vector2(78.0, 134.5), Vector2(36.0, 133.0), Vector2(64.0, 133.5), Vector2(20.5, 100.5), Vector2(60.0, 101.5)]:
		_clump("flowers", center, 1.6, 7, keep_clear)


## A clump of count decorations (radius 0) within `spread` of center, on open ground only.
func _clump(kind: String, center: Vector2, spread: float, count: int, keep_clear: Array[Vector3]) -> void:
	var placed: int = 0
	var attempts: int = 0
	while placed < count and attempts < 24:
		attempts += 1
		var angle: float = _rng.randf() * TAU
		var p: Vector2 = center + Vector2(cos(angle), sin(angle)) * _rng.randf_range(0.0, spread)
		if edge_distance(p.x, p.y) < 1.2 or hazard_depth(p.x, p.y) > -1.6 or surface_at(p.x, p.y) != Surface.GROUND:
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
		if edge_distance(x, z) < 1.0 or hazard_depth(x, z) > -1.6:
			continue
		if surface != Surface.GROUND and not (surface == Surface.ROUGH and kind in ["rock", "bush"]):
			continue
		if ramp_at(x, z) != null:
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
