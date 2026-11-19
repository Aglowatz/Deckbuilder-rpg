class_name DnaWasteland
extends RefCounted
## Fable Nov 15 (Part 1): the land outside the D.N.A.'s buildings is a wasteland like the one outside the Capital - the same cracked ash
## ground (the scenery apron, `data/art/zone_looks.json` "dna": TEX-CAP-ASH with patches of TEX-CAP-CRACKEDROAD) and the Capital's own
## wasteland kit, tinted toward the D.N.A.'s grey-green: stretches of broken low wall (`CapitalLandmarks.ruin_fragment`), ruined house
## shells further out (`ruined_house`: CAP-WALL-RUIN), rubble mounds (CAP-SHEET-RUBBLE) and rubble rows at the buildings' feet
## (CAP-PROP-RUBBLE-ROW), dead twisted trees (CAP-TREE-DEAD), purple crystal clusters (CAP-PLANT-CRYSTAL), ash drifts (CAP-DEC-ASH), dark
## tufts of dead grass (StyleGrass), old dead lamp posts (`CapitalProps.street_lamp`) and the odd fallen statue (`fallen_statue`,
## CAPI-PROP-STATUE-FALLEN). A few office touches stay as debris: a tipped cabinet, a leaning filing tower, drifts of forms.
##
## Nothing here is walked (every piece stands off the floor and its walls), nothing is solid, and nothing rises between the camera and
## the hero: the camera trails south of the hero, so a piece with floor to its north may only stand as high as `north_cap` allows (the
## Capital rim's rule). Placement is a fixed seed over a jittered grid and the distance to the buildings, so it is the same every visit
## and never a row. The floating paper (DnaPaperDrift) is untouched. Low-end keeps about half.

const K = preload("res://world/capital/capital_kit.gd")
const SEED: int = 5115
## The ground the wasteland covers (cells): well past the buildings on every side; the fog and the backdrop take over beyond.
const AREA: Rect2i = Rect2i(-36, -32, 162, 132)
const STEP: float = 4.0
## The Capital's pieces are tinted toward the D.N.A.'s grey-green; the crystals keep their purple, a little cooled.
const TINT: Color = Color(0.76, 0.88, 0.8)
const CRYSTAL_TINT: Color = Color(0.86, 0.92, 0.94)
const TUFT_BASE: Color = Color(0.1, 0.13, 0.12)
const TUFT_TIP: Color = Color(0.24, 0.3, 0.26)
## Nothing stands here: the causeway and its bridge stub, the far landmarks (the Filing Tower, the Endless Queue, the Records Stair) and
## the Hall of Final Approvals with its stair.
const KEEP_OUT: Array[Rect2] = [
	Rect2(40.5, 58.0, 12.0, 30.0), Rect2(-24.5, 5.0, 15.0, 16.0), Rect2(90.5, 8.0, 9.5, 36.0), Rect2(90.0, -3.0, 11.0, 12.0),
	Rect2(11.0, -32.0, 69.0, 34.0),
]
## How far north of a spot floor still counts as "in front of the camera" (metres) and the rise allowed per metre of that distance.
const NORTH_REACH: int = 22
const NORTH_SLOPE: float = 0.42
const NORTH_BASE: float = 0.55
## The most of each kind at full quality, and the least distance between two of a kind (metres).
const MAX: Dictionary = {"house": 9, "fragment": 30, "statue": 3, "crystal": 28, "tree": 72, "mound": 46, "lamp": 12}
const SPACING: Dictionary = {"house": 17.0, "fragment": 8.5, "statue": 30.0, "crystal": 8.0, "tree": 5.5, "mound": 5.5, "lamp": 12.0}
const HOUSE_SHAPES: Array[Array] = [[6.4, 4.2, 4.6, 3.0], [7.6, 4.8, 5.2, -2.0], [5.4, 3.6, 4.2, 5.0], [8.2, 5.2, 5.0, 1.0]]
const MOUNDS: Array[String] = ["CAP-SHEET-RUBBLE-01", "CAP-SHEET-RUBBLE-05", "CAP-SHEET-RUBBLE-06", "CAP-SHEET-RUBBLE-03"]
## The old lamp posts along the approach, either side of the causeway and the bridge stub (x, z, lean in degrees): a loose avenue, some
## posts missing, one leaning.
const APPROACH_LAMPS: Array[Vector3] = [
	Vector3(38.9, 62.4, 0.0), Vector3(54.3, 63.6, 0.0), Vector3(38.4, 69.8, 4.0), Vector3(54.8, 71.2, 0.0), Vector3(39.2, 77.4, 0.0),
	Vector3(54.1, 79.6, -7.0),
]
## The office debris kept in the wasteland: [id, x, z, height, roll in degrees (a card lying on its side)].
const OFFICE_DEBRIS: Array = [
	# Batch 16 (Nov 16): the painted tipped cabinet and archive crates (they were upright cabinet cards turned on their side)
	["DNA-PROP-CABINET-TIPPED", 35.6, 65.4, 1.2, 0.0], ["DNA-PROP-CABINET-TIPPED", 58.2, 67.6, 1.15, 0.0], ["DNA-SHEET-FILING-TOWERS-01", 31.2, 62.8, 2.2, 9.0],
	["DNA-PROP-CRATES", 66.5, 63.2, 1.4, 0.0], ["DNA-SHEET-FILING-TOWERS-03", 14.5, 50.6, 2.1, -7.0], ["DNA-PROP-CABINET-TIPPED", 63.4, 51.2, 1.15, 0.0],
	["DNA-PROP-CRATES", 33.2, 67.4, 1.3, 0.0], ["DNA-PROP-CRATES", 17.4, 52.0, 1.25, 0.0],
]
## Drifts of paper and forms on the ash: [id, x, z, width, yaw].
const PAPER_DRIFTS: Array = [
	["DEC-PAPERS", 36.8, 66.6, 2.0, 30.0], ["DNA-DEC-FORMS-01", 34.2, 63.6, 1.4, -20.0], ["DEC-PAPERS", 57.6, 65.8, 1.9, 110.0],
	["DNA-DEC-FORMS-03", 60.2, 69.0, 1.3, 55.0], ["DNA-DEC-FORMS-02", 30.0, 64.2, 1.3, 75.0], ["DEC-PAPERS", 65.6, 64.8, 1.7, -40.0],
	["DNA-DEC-FORMS-05", 15.6, 52.2, 1.3, 10.0], ["DEC-PAPERS", 62.4, 53.0, 1.8, 150.0],
]
## The rubble rows at the foot of the south faces (CAP-PROP-RUBBLE-ROW): [x0, x1, z].
const RUBBLE_ROWS: Array[Array] = [[20.5, 39.4, 61.5], [51.6, 58.5, 61.5], [4.5, 19.0, 45.4], [59.5, 90.0, 45.4]]
const RUBBLE_ROW_HEIGHT: float = 0.95

var root: Node3D
## What stands where (tests, the report): kind -> Array[Vector3].
var placed: Dictionary = {"house": [], "fragment": [], "statue": [], "crystal": [], "tree": [], "mound": [], "lamp": [], "debris": [], "drift": [], "row": []}
var tufts: int = 0
var _layout: DnaLayout
## Overnight Nov 18: the grand hall - nothing of the wasteland stands in the walled-in gaps between rooms (they are hall floor now).
var _hall: DnaHall
var _dist: PackedFloat32Array = PackedFloat32Array()


static func build(parent: Node3D, layout: DnaLayout, quality: int) -> DnaWasteland:
	var wasteland: DnaWasteland = DnaWasteland.new()
	wasteland.root = Node3D.new()
	wasteland.root.name = "Wasteland"
	wasteland.root.set_meta(&"no_wind", true)
	parent.add_child(wasteland.root)
	wasteland._layout = layout
	wasteland._hall = DnaHall.new(layout)
	wasteland._distance_field()
	wasteland._place(GraphicsQuality.foliage_density(quality), quality)
	return wasteland


# ---- where things may stand ----------------------------------------------------------------------------------------------------------


func _index(cx: int, cz: int) -> int:
	return (cz - AREA.position.y) * AREA.size.x + (cx - AREA.position.x)


## The distance (metres) from every cell to the nearest cell of the buildings (floor, wall or solid) or the causeway: two chamfer passes.
func _distance_field() -> void:
	_dist.resize(AREA.size.x * AREA.size.y)
	for cz: int in range(AREA.position.y, AREA.end.y):
		for cx: int in range(AREA.position.x, AREA.end.x):
			var built: bool = _layout.cell_at(cx, cz) != DnaLayout.Cell.VOID or DnaLayout.on_approach(float(cx) + 0.5, float(cz) + 0.5)
			_dist[_index(cx, cz)] = 0.0 if built else 999.0
	var diagonal: float = 1.41421
	for cz: int in range(AREA.position.y, AREA.end.y):
		for cx: int in range(AREA.position.x, AREA.end.x):
			var best: float = _dist[_index(cx, cz)]
			if cx > AREA.position.x:
				best = minf(best, _dist[_index(cx - 1, cz)] + 1.0)
			if cz > AREA.position.y:
				best = minf(best, _dist[_index(cx, cz - 1)] + 1.0)
				if cx > AREA.position.x:
					best = minf(best, _dist[_index(cx - 1, cz - 1)] + diagonal)
				if cx < AREA.end.x - 1:
					best = minf(best, _dist[_index(cx + 1, cz - 1)] + diagonal)
			_dist[_index(cx, cz)] = best
	for cz: int in range(AREA.end.y - 1, AREA.position.y - 1, -1):
		for cx: int in range(AREA.end.x - 1, AREA.position.x - 1, -1):
			var best: float = _dist[_index(cx, cz)]
			if cx < AREA.end.x - 1:
				best = minf(best, _dist[_index(cx + 1, cz)] + 1.0)
			if cz < AREA.end.y - 1:
				best = minf(best, _dist[_index(cx, cz + 1)] + 1.0)
				if cx < AREA.end.x - 1:
					best = minf(best, _dist[_index(cx + 1, cz + 1)] + diagonal)
				if cx > AREA.position.x:
					best = minf(best, _dist[_index(cx - 1, cz + 1)] + diagonal)
			_dist[_index(cx, cz)] = best


## The distance from (x, z) to the nearest building cell; INF outside the area.
func distance_at(x: float, z: float) -> float:
	var cx: int = int(floorf(x))
	var cz: int = int(floorf(z))
	if not AREA.has_point(Vector2i(cx, cz)):
		return INF
	return _dist[_index(cx, cz)]


## How high a piece at (x, z) may stand: unlimited (99) with no building within NORTH_REACH metres to its north (within `half` metres
## either side), else low enough to stay under the camera's line to a hero standing there.
func north_cap(x: float, z: float, half: float = 1.0) -> float:
	var cz: int = int(floorf(z))
	for step: int in range(1, NORTH_REACH + 1):
		for dx: float in [-half, 0.0, half]:
			var cx: int = int(floorf(x + dx))
			if _layout.cell_at(cx, cz - step) != DnaLayout.Cell.VOID or DnaLayout.on_approach(float(cx) + 0.5, float(cz - step) + 0.5):
				return NORTH_BASE + NORTH_SLOPE * float(step)
	return 99.0


## Nov 18 evening: the street behind the building fronts (DnaStreet) is kept clear like the landmarks (the Filing Tower and the Records Stair
## moved, see DnaBuilder).
static func kept_out(x: float, z: float, margin: float = 0.0) -> bool:
	for rect: Rect2 in KEEP_OUT:
		if rect.grow(margin).has_point(Vector2(x, z)):
			return true
	for rect: Rect2 in DnaStreet.footprints():
		if rect.grow(margin + 0.6).has_point(Vector2(x, z)):
			return true
	return false


func _far_enough(kind: String, pos: Vector3, spacing: float = -1.0) -> bool:
	var least: float = float(SPACING.get(kind, 4.0)) if spacing < 0.0 else spacing
	for other: Variant in placed[kind] as Array:
		var at: Vector3 = other as Vector3
		if Vector2(at.x - pos.x, at.z - pos.z).length() < least:
			return false
	return true


func _room(kind: String, share: float) -> bool:
	return (placed[kind] as Array).size() < int(ceilf(float(MAX[kind]) * share))


# ---- the pieces ----------------------------------------------------------------------------------------------------------------------


func _place(share: float, quality: int) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = SEED
	share = clampf(share, 0.45, 1.0)
	var shells: Node3D = Node3D.new()
	shells.name = "Shells"
	root.add_child(shells)
	var cards: KitMesh = KitMesh.new()
	K.materials(cards)
	var decals: KitMesh = KitMesh.new()
	K.materials(decals)
	_approach_lamps(shells)
	# every cell of a jittered grid is a candidate; the ones nearest the buildings (and so nearest the hero) are served first, so the
	# budget of each kind is spent where it is seen and thins out toward the fog
	var candidates: Array[Dictionary] = []
	var z: float = float(AREA.position.y)
	while z < float(AREA.end.y):
		var x: float = float(AREA.position.x)
		while x < float(AREA.end.x):
			var candidate: Dictionary = {"x": x + rng.randf_range(0.0, STEP), "z": z + rng.randf_range(0.0, STEP), "pick": rng.randf(), "variant": rng.randi() % 1000, "turn": rng.randf_range(-0.35, 0.35)}
			x += STEP
			candidate["distance"] = distance_at(float(candidate["x"]), float(candidate["z"]))
			if float(candidate["distance"]) == INF or float(candidate["distance"]) < 2.6 or kept_out(float(candidate["x"]), float(candidate["z"]), 1.0):
				continue
			if _hall != null and not _hall.is_outside(Vector2i(int(floorf(float(candidate["x"]))), int(floorf(float(candidate["z"]))))):
				continue
			candidate["order"] = float(candidate["distance"]) + float(candidates.size() % 7) * 0.9
			candidates.append(candidate)
		z += STEP
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if float(a["order"]) != float(b["order"]):
			return float(a["order"]) < float(b["order"])
		return float(a["x"]) * 131.0 + float(a["z"]) < float(b["x"]) * 131.0 + float(b["z"]))
	for candidate: Dictionary in candidates:
		if true:
			var px: float = float(candidate["x"])
			var pz: float = float(candidate["z"])
			var pick: float = float(candidate["pick"])
			var variant: int = int(candidate["variant"])
			var turn: float = float(candidate["turn"])
			var distance: float = float(candidate["distance"])
			var pos: Vector3 = Vector3(px, 0.0, pz)
			var cap: float = north_cap(px, pz)
			if pick < 0.1 and distance >= 9.0 and distance <= 26.0 and _room("house", share):
				var shape: Array = HOUSE_SHAPES[variant % HOUSE_SHAPES.size()]
				var height: float = float(shape[1]) + float(shape[2]) * 0.4
				if north_cap(px, pz, float(shape[0]) * 0.5) >= height and _far_enough("house", pos) and not kept_out(px, pz, 5.0):
					_stand(shells, CapitalLandmarks.ruined_house(float(shape[0]), float(shape[1]), float(shape[2]), float(shape[3]), variant % 4), pos, turn)
					(placed["house"] as Array).append(pos)
					K.ground_card(decals, "CAP-DEC-ASH", Vector3(px, 0.05, pz + float(shape[2]) * 0.5 + 1.0), float(shape[0]) * 1.3, 0.0)
					continue
			if pick < 0.3 and distance >= 4.0 and distance <= 20.0 and _room("fragment", share):
				var length: float = 3.0 + float(variant % 5) * 0.6
				var wall_height: float = minf(1.3 + float(variant % 4) * 0.4, cap - 0.3)
				if wall_height >= 0.9 and _far_enough("fragment", pos) and _far_enough("house", pos, 7.0) and not kept_out(px, pz, 3.0) and distance_at(px - length * 0.5, pz) >= 3.0 and distance_at(px + length * 0.5, pz) >= 3.0:
					_stand(shells, CapitalLandmarks.ruin_fragment(length, wall_height, variant % 6), pos, turn)
					(placed["fragment"] as Array).append(pos)
					K.ground_card(decals, "CAP-DEC-ASH", Vector3(px, 0.05, pz + 0.9), length * 1.2, turn)
					continue
			if pick < 0.38 and distance >= 3.5 and distance <= 12.0 and cap >= 1.7 and _room("statue", share):
				if _far_enough("statue", pos) and _far_enough("house", pos, 6.0) and _far_enough("fragment", pos, 3.5):
					if (placed["statue"] as Array).size() == 1 and EnvKit.has_art("CAPI-PROP-STATUE-FALLEN"):
						# the odd one: the Capital's golden fallen statue, greyed, lying in the ash
						K.card(cards, "CAPI-PROP-STATUE-FALLEN", pos, 1.5, Vector3(0, 0, 1), variant % 2 == 0, Color(0.62, 0.7, 0.66))
					else:
						_stand(shells, CapitalProps.fallen_statue(), pos, turn)
					(placed["statue"] as Array).append(pos)
					K.ground_card(decals, "CAP-DEC-ASH", Vector3(px, 0.05, pz + 0.4), 3.4, turn)
					continue
			if pick < 0.52 and distance >= 3.0 and distance <= 22.0 and _room("crystal", share):
				var crystal_height: float = minf(1.3 + float(variant % 6) * 0.3, cap - 0.2)
				if crystal_height >= 0.8 and _far_enough("crystal", pos) and _far_enough("house", pos, 5.0) and _far_enough("fragment", pos, 2.5):
					K.card(cards, "CAP-PLANT-CRYSTAL", pos + Vector3(0.0, -0.08, 0.0), crystal_height, Vector3(0, 0, 1), variant % 2 == 1, CRYSTAL_TINT)
					if variant % 2 == 0:
						K.card(cards, "CAP-PLANT-CRYSTAL", pos + Vector3(0.9, -0.08, 0.35), crystal_height * 0.6, Vector3(0, 0, 1), true, CRYSTAL_TINT)
					(placed["crystal"] as Array).append(pos)
					continue
			if pick < 0.78 and distance >= 3.0 and _room("tree", share):
				var tree_height: float = minf(2.6 + float(variant % 8) * 0.3, cap - 0.2)
				if tree_height >= 1.4 and _far_enough("tree", pos) and _far_enough("house", pos, 4.5) and _far_enough("fragment", pos, 2.0):
					K.card(cards, "CAP-TREE-DEAD", pos + Vector3(0.0, -0.06, 0.0), tree_height, Vector3(0, 0, 1), variant % 2 == 0, TINT)
					(placed["tree"] as Array).append(pos)
					continue
			if distance <= 18.0 and _room("mound", share):
				var mound_height: float = minf(0.8 + float(variant % 4) * 0.2, cap)
				if mound_height >= 0.6 and _far_enough("mound", pos) and _far_enough("house", pos, 5.0) and _far_enough("statue", pos, 3.0) and _far_enough("tree", pos, 1.6):
					K.card(cards, MOUNDS[variant % MOUNDS.size()], pos + Vector3(0.0, -0.05, 0.0), mound_height, Vector3(0, 0, 1), variant % 2 == 0, TINT)
					K.ground_card(decals, "CAP-DEC-ASH", Vector3(px, 0.05, pz + 0.3), 2.6 + float(variant % 3) * 0.5, turn)
					(placed["mound"] as Array).append(pos)
					# an old lamp post now and then beside a mound, well away from the buildings' own lamps
					if variant % 4 == 0 and distance >= 6.0 and cap >= 4.0 and _room("lamp", share) and _far_enough("lamp", pos):
						_lamp(shells, pos + Vector3(1.4, 0.0, -0.6), float(variant % 9) - 4.0)
	_rubble_rows(cards)
	_office_debris(quality)
	_tufts(rng, int(620.0 * share))
	for mesh_and_name: Array in [[cards, "WastelandCards"], [decals, "WastelandAsh"]]:
		var body: MeshInstance3D = (mesh_and_name[0] as KitMesh).instance(str(mesh_and_name[1]))
		_quiet(body)
		root.add_child(body)
	# off the walkable map and under the camera's line (north_cap): nothing here needs to fade for the hero or cast a sun shadow; the
	# shells merge into a few batches (one draw per material per cell instead of one per piece)
	for node: Node in shells.find_children("*", "MeshInstance3D", true, false):
		_quiet(node as MeshInstance3D)
		node.set_meta(&"kit_static", true)
	if shells.is_inside_tree():
		KitBatch.merge_static(shells, 64.0)
		for node: Node in shells.find_children("*", "MeshInstance3D", true, false):
			_quiet(node as MeshInstance3D)


static func _quiet(body: MeshInstance3D) -> void:
	body.set_meta(PaintedClasses.META_NO_PAINT, true)
	body.set_meta(&"no_occlusion_fade", true)
	body.set_meta(&"no_range_cull", true)
	body.set_meta(&"no_wind", true)
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _stand(parent: Node3D, piece: Node3D, pos: Vector3, turn: float) -> void:
	piece.position = pos
	piece.rotation.y = turn
	parent.add_child(piece)


func _lamp(parent: Node3D, pos: Vector3, lean_degrees: float) -> void:
	if distance_at(pos.x, pos.z) < 2.6 or kept_out(pos.x, pos.z):
		return
	var lamp: Node3D = CapitalProps.street_lamp(false)
	lamp.name = "OldLamp"
	lamp.position = pos
	lamp.rotation_degrees = Vector3(0.0, 90.0 if pos.x < DnaLayout.AXIS_X else -90.0, lean_degrees)
	parent.add_child(lamp)
	(placed["lamp"] as Array).append(pos)


## The loose avenue of dead lamp posts beside the causeway (the Capital's gate road has the same posts).
func _approach_lamps(parent: Node3D) -> void:
	for entry: Vector3 in APPROACH_LAMPS:
		_lamp(parent, Vector3(entry.x, 0.0, entry.y), entry.z)


func _rubble_rows(cards: KitMesh) -> void:
	if not EnvKit.has_art("CAP-PROP-RUBBLE-ROW"):
		return
	var index: int = 0
	var aspect: float = EnvKit.aspect("CAP-PROP-RUBBLE-ROW")
	for row: Array in RUBBLE_ROWS:
		var x: float = float(row[0])
		while x < float(row[1]) - 1.0:
			var height: float = RUBBLE_ROW_HEIGHT * (1.0 if index % 2 == 0 else 1.16)
			var width: float = minf(height * aspect, float(row[1]) - x)
			height = width / aspect
			var at: Vector3 = Vector3(x + width * 0.5, -0.05, float(row[2]) + (0.14 if index % 2 == 0 else 0.0))
			if distance_at(at.x, at.z) >= 0.9 and not kept_out(at.x, at.z) and (_hall == null or _hall.is_outside(Vector2i(int(floorf(at.x)), int(floorf(at.z))))):
				K.card(cards, "CAP-PROP-RUBBLE-ROW", at, height, Vector3(0, 0, 1), index % 2 == 1, TINT)
				(placed["row"] as Array).append(at)
			x += width * 0.94
			index += 1


## The office touches: a tipped cabinet, a leaning tower of files, drifts of forms. Only where the ground is clear of the buildings.
func _office_debris(quality: int) -> void:
	for entry: Array in OFFICE_DEBRIS:
		var spot: Vector3 = Vector3(float(entry[1]), 0.0, float(entry[2]))
		if distance_at(spot.x, spot.z) < 1.6 or not EnvKit.has_art(str(entry[0])):
			continue
		var piece: Node3D = KitPieces.stand(root, str(entry[0]), spot, float(entry[3]), false)
		if piece == null:
			continue
		var roll: float = deg_to_rad(float(entry[4]))
		piece.rotation.z = roll
		if absf(float(entry[4])) > 45.0:
			piece.position.y = 0.4  # lying on its side, a little sunk in the ash
		(placed["debris"] as Array).append(spot)
	if quality <= 0:
		return
	for entry: Array in PAPER_DRIFTS:
		var center: Vector3 = Vector3(float(entry[1]), 0.0, float(entry[2]))
		if distance_at(center.x, center.z) < 1.2 or not EnvKit.has_art(str(entry[0])):
			continue
		if KitPieces.ground(root, str(entry[0]), center, float(entry[4]), float(entry[3])) != null:
			(placed["drift"] as Array).append(center)


## Dark tufts of dead grass over the ash, thicker near the buildings and thinning out; one MultiMesh.
func _tufts(rng: RandomNumberGenerator, amount: int) -> void:
	var transforms: Array[Transform3D] = []
	var tries: int = 0
	while transforms.size() < amount and tries < amount * 12:
		tries += 1
		var x: float = rng.randf_range(float(AREA.position.x) + 4.0, float(AREA.end.x) - 4.0)
		var z: float = rng.randf_range(float(AREA.position.y) + 4.0, float(AREA.end.y) - 4.0)
		var distance: float = distance_at(x, z)
		if distance < 1.4 or distance > 34.0 or kept_out(x, z) or rng.randf() < (distance - 8.0) / 40.0:
			continue
		var size: float = rng.randf_range(1.2, 2.1)
		transforms.append(Transform3D(Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3(size, size * rng.randf_range(0.8, 1.2), size)), Vector3(x, 0.0, z)))
	tufts = transforms.size()
	if transforms.is_empty():
		return
	var field: MultiMeshInstance3D = StyleGrass.multimesh_instance(transforms, TUFT_BASE, TUFT_TIP)
	field.name = "WastelandTufts"
	field.set_meta(&"no_range_cull", true)
	field.set_meta(&"no_occlusion_fade", true)
	field.set_meta(PaintedClasses.META_NO_PAINT, true)
	root.add_child(field)


## Every standing piece's spot (tests, the probe).
func all_spots() -> Array[Vector3]:
	var result: Array[Vector3] = []
	for kind: String in ["house", "fragment", "statue", "crystal", "tree", "mound", "lamp", "debris"]:
		for spot: Variant in placed[kind] as Array:
			result.append(spot as Vector3)
	return result
