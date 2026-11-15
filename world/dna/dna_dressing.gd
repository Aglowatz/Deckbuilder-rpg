class_name DnaDressing
extends RefCounted
## The hand-dressed pass for the D.N.A. hub (docs/art/dna_slice.md, Part C): a few zone kit clusters (data/art/zone_kits/dna_clusters.json) tucked against the walls
## of the lobby, the breakroom, the mail room, the elevator bank, the records basement and the farms, and the kit's ground decals (coffee rings on the office floors,
## queue footprints along the way in and the main route). Nothing goes on a route, in the plaza middle, within reach of an anchor or a chest, or in the executive
## court (the Hall's forecourt stays open). Placement respects walkability; solid pieces register blockers. The generic furniture scatter is off for this zone (DN-5).

var root: Node3D
var count: int = 0
var _builder: DnaBuilder
var _anchors: Array[Vector3] = []
var _placed: Array[Vector2] = []

## cluster, anchor, offset (x, z) from the anchor, yaw (the back of the cluster faces -z rotated by yaw: 0 north wall, 90 west wall, 180 south wall, -90 east wall).
const KIT_CLUSTERS: Array = [
	["lily_nook", "lobby_center", Vector2(-7.2, 4.8), 180.0],
	["paper_towers", "breakroom_center", Vector2(3.0, -4.2), 0.0],
	["paper_towers", "mail_center", Vector2(7.0, 2.8), 180.0],
	["lamp_planter", "bank_center", Vector2(-7.0, 2.4), 180.0],
	["cabinet_row", "records_center", Vector2(-9.0, -8.6), 0.0],
	["paper_towers", "farm_b_center", Vector2(13.0, -8.6), 0.0],
	["clerk_desk", "farm_a_center", Vector2(-13.0, 8.0), 180.0],
]
## kit decal id, anchor, offset, size (m), yaw.
const DECALS: Array = [
	["DNA-DEC-COFFEE", "breakroom_center", Vector2(-1.5, -1.2), 1.1, 20.0], ["DNA-DEC-COFFEE", "breakroom_center", Vector2(2.6, 1.0), 0.9, 140.0],
	["DNA-DEC-COFFEE", "coffee", Vector2(0.4, 1.4), 0.8, 300.0], ["DNA-DEC-COFFEE", "lobby_center", Vector2(5.5, 2.2), 1.0, 60.0],
	["DNA-DEC-COFFEE", "farm_a_center", Vector2(2.0, 1.0), 0.9, 10.0], ["DNA-DEC-COFFEE", "farm_b_center", Vector2(-3.0, 1.0), 0.9, 200.0],
	["DNA-DEC-FOOT", "spawn", Vector2(0.0, -2.6), 2.6, 0.0], ["DNA-DEC-FOOT", "gate", Vector2(0.3, 2.2), 2.4, 4.0],
	["DNA-DEC-FOOT", "gate", Vector2(-0.3, -2.6), 2.4, -3.0], ["DNA-DEC-FOOT", "lobby_center", Vector2(0.4, -4.6), 2.4, 2.0],
	["DNA-DEC-FOOT", "lobby_center", Vector2(-0.3, -9.4), 2.4, -5.0], ["DNA-DEC-FOOT", "mail_center", Vector2(0.2, 5.0), 2.6, 3.0],
	["DNA-DEC-FOOT", "mail_center", Vector2(-0.2, -5.6), 2.6, -2.0], ["DNA-DEC-FOOT", "bank_center", Vector2(0.0, -2.2), 2.4, 1.0],
	# art import Oct 29: dropped forms, DENIED stamps and tickets (DNA-DEC-FORMS, stamp shapes only, no lettering)
	["DNA-DEC-FORMS-01", "lobby_center", Vector2(-4.0, 3.4), 0.9, 25.0], ["DNA-DEC-FORMS-02", "mail_center", Vector2(3.2, -2.0), 1.0, -10.0],
	["DNA-DEC-FORMS-04", "records_center", Vector2(-3.0, 2.6), 1.1, 70.0], ["DNA-DEC-FORMS-05", "breakroom_center", Vector2(1.6, 2.4), 0.8, 160.0],
	["DNA-DEC-FORMS-01", "farm_a_center", Vector2(-4.0, -2.0), 0.9, 300.0], ["DNA-DEC-FORMS-02", "farm_b_center", Vector2(4.0, 2.4), 0.9, 15.0],
]

## Art import Oct 29: the painted pieces of the kit sheets standing in the rooms (`KitPieces.stand`): id, anchor, height (m), blocking radius,
## how many. Each takes the first free spot of a ring round its anchor (`_free`: walkable, off the routes and doorways, clear of every
## anchor). Filing-cabinet towers in the cubicle farms and the records basement; ghost lamps and dead topiary in the lobby, the bank and the
## mail room. The ghost queue is a line of its own (`QUEUE`).
const KIT_PIECES: Array = [
	["DNA-SHEET-FILING-TOWERS-03", "farm_a_center", 6.2, 0.75, 1], ["DNA-SHEET-FILING-TOWERS-02", "farm_a_center", 4.6, 0.65, 1],
	["DNA-SHEET-FILING-TOWERS-01", "farm_b_center", 3.4, 0.55, 1], ["DNA-SHEET-FILING-TOWERS-03", "farm_b_center", 6.0, 0.75, 1],
	["DNA-SHEET-FILING-TOWERS-02", "records_center", 4.4, 0.65, 1],
	["DNA-SHEET-PROPS-01", "lobby_center", 2.6, 0.3, 2], ["DNA-SHEET-PROPS-02", "bank_center", 2.6, 0.3, 1], ["DNA-SHEET-PROPS-03", "mail_center", 2.6, 0.3, 1],
	["DNA-SHEET-PROPS-04", "lobby_center", 1.6, 0.4, 1], ["DNA-SHEET-PROPS-05", "bank_center", 1.6, 0.4, 1], ["DNA-SHEET-PROPS-06", "breakroom_center", 1.6, 0.4, 1],
]
const PIECE_RINGS: Array[float] = [7.0, 9.0, 5.5, 11.0]
## The queue of ghosts (DNA-SHEET-GHOST-QUEUE-01..06) waiting in a line with a brass queue post (DNA-SHEET-FILING-TOWERS-04) at its head: the
## anchor whose ring is tried, the gap between ghosts and the ghosts' height.
## The queue stands with its back to a wall (nothing walkable QUEUE_BACK metres behind it, -z), so it can never wall off a way across a room.
const QUEUE_CLEARANCE: float = 2.5
const QUEUE_BACK: float = 1.2
const QUEUE_LOBBY_HEAD: Vector3 = Vector3(47.0, 0.0, 47.2)
const QUEUE: Dictionary = {"anchors": ["lobby_center", "bank_center", "mail_center", "records_center", "breakroom_center"], "gap": 0.95, "height": 1.65, "post": "DNA-SHEET-FILING-TOWERS-04"}
## Batch 11 (Nov 2): the lobby's own dressing, the six cut-outs of DNA-SHEET-LOBBY (id, preferred spot by a wall of the lobby (x 36-56,
## z 46-60), height m, blocking radius). Placed after the ghost queue, each on the first free spot (`_free`: off the open middle, clear of
## the talk spots, the queue and each other) near its wish, so the queue keeps its place and the middle stays open.
const LOBBY_PROPS: Array = [
	# Overnight Nov 4-5, Part 1.10: the chairs and the ashtray stood inside the west passage (LOBBY_WEST_PASSAGE, x 35-39.4); they wait by the south wall now
	["DNA-SHEET-LOBBY-01", Vector3(45.0, 0.0, 59.1), 1.0, 0.7],   # bolted waiting chairs along the south wall, east of the exit
	["DNA-SHEET-LOBBY-05", Vector3(46.9, 0.0, 59.2), 1.1, 0.25],  # the brass ashtray at the end of the chairs
	["DNA-SHEET-LOBBY-03", Vector3(37.2, 0.0, 59.0), 1.5, 0.35],  # the half-dead rubber plant in the south-west corner
	["DNA-SHEET-LOBBY-04", Vector3(51.5, 0.0, 59.2), 1.6, 0.4],   # the notice board by the south wall, east of the exit
	["DNA-SHEET-LOBBY-06", Vector3(55.0, 0.0, 57.5), 1.9, 0.5],   # the dead vending machine against the east wall
	["DNA-SHEET-LOBBY-02", Vector3(39.5, 0.0, 50.8), 1.5, 0.25],  # TAKE A NUMBER by the counter's west end
	["DNA-PROP-SERVING-ORB", Vector3(49.6, 0.0, 47.0), 2.1, 0.3],  # Batch 15: the ghostly now-serving orb at the head of the ghost queue (north wall)
	["DNA-PROP-SERVING-ORB", Vector3(41.2, 0.0, 50.8), 2.1, 0.3],  # ... and a second one beside TAKE A NUMBER at the counter's west end
]
const LOBBY_NUDGES: Array[Vector3] = [Vector3.ZERO, Vector3(0, 0, -1), Vector3(0, 0, 1), Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 0, -2), Vector3(0, 0, 2), Vector3(2, 0, 0), Vector3(-2, 0, 0)]


static func build(parent: Node3D, builder: DnaBuilder, quality: int) -> DnaDressing:
	var dressing: DnaDressing = DnaDressing.new()
	dressing.root = Node3D.new()
	dressing.root.name = "DnaDressing"
	parent.add_child(dressing.root)
	dressing._builder = builder
	for key: Variant in builder.layout.anchors.keys():
		dressing._anchors.append(builder.anchor(str(key)))
	for pos: Variant in builder.layout.chests.values():
		dressing._anchors.append(pos as Vector3)
	dressing._ghost_queue()  # Fix pass Nov 4 (B): the queue claims its wall first (its old spot left with the bench)
	dressing._kit_clusters()
	dressing._kit_pieces()
	dressing._lobby_props()
	dressing._apron(quality)
	dressing._wasteland(quality)
	if quality > 0:
		dressing._decals()
	return dressing


func _kit_clusters() -> void:
	var index: int = 0
	for entry: Array in KIT_CLUSTERS:
		index += 1
		if not _builder.has_anchor(str(entry[1])):
			continue
		var offset: Vector2 = entry[2] as Vector2
		var pos: Vector3 = _builder.anchor(str(entry[1])) + Vector3(offset.x, 0.0, offset.y)
		if not _free(pos, 2.4, 2.0):
			continue
		var cluster: Node3D = PropClusters.make(str(entry[0]), 500 + index)
		if cluster == null:
			continue
		root.add_child(cluster)
		cluster.position = pos
		cluster.rotation_degrees.y = float(entry[3])
		_placed.append(Vector2(pos.x, pos.z))
		var basis: Basis = Basis(Vector3.UP, deg_to_rad(float(entry[3])))
		for circle: Variant in cluster.get_meta("circles", []) as Array:
			var local: Vector3 = circle as Vector3
			var world: Vector3 = pos + basis * Vector3(local.x, 0.0, local.y)
			_builder.add_blocker(Vector3(world.x, 0.0, world.z), local.z)
		count += 1


func _kit_pieces() -> void:
	for entry: Array in KIT_PIECES:
		var anchor_id: String = str(entry[1])
		if not _builder.has_anchor(anchor_id) or not EnvKit.has_art(str(entry[0])):
			continue
		var left: int = int(entry[4])
		for spot: Vector3 in _ring_spots(_builder.anchor(anchor_id)):
			if left <= 0:
				break
			if not _free(spot, 2.2, 1.8):
				continue
			if KitPieces.stand(root, str(entry[0]), spot, float(entry[2])) == null:
				break
			_builder.add_blocker(Vector3(spot.x, 0.0, spot.z), float(entry[3]))
			_placed.append(Vector2(spot.x, spot.z))
			count += 1
			left -= 1


## Spots on rings round `center` (PIECE_RINGS, every 30 degrees), nearest ring first.
func _ring_spots(center: Vector3) -> Array[Vector3]:
	var spots: Array[Vector3] = []
	for radius: float in PIECE_RINGS:
		for step: int in range(12):
			var angle: float = deg_to_rad(15.0 + 30.0 * float(step))
			spots.append(center + Vector3(cos(angle), 0.0, sin(angle)) * radius)
	return spots


func _ghost_queue() -> void:
	if not EnvKit.has_art("DNA-SHEET-GHOST-QUEUE-01"):
		return
	var gap: float = float(QUEUE["gap"])
	# Fix pass Nov 4 (B): first along the lobby's north wall east of the counter (its old spot backed onto the bench, which left the west passage)
	var heads: Array[Vector3] = [QUEUE_LOBBY_HEAD]
	for anchor_id: Variant in QUEUE["anchors"] as Array:
		if _builder.has_anchor(str(anchor_id)):
			heads.append_array(_ring_spots(_builder.anchor(str(anchor_id))))
	for head: Vector3 in heads:
		var line: Array[Vector3] = []
		for index: int in range(7):
			line.append(head + Vector3(gap * float(index), 0.0, 0.0))
		# a whole line of solid figures: well clear of every anchor and NPC spot so it never walls off a way to someone (the walk smoke to Pip)
		if not line.all(func(p: Vector3) -> bool: return _free(p, QUEUE_CLEARANCE, 1.4) and not _builder.is_walkable(p + Vector3(0.0, 0.0, -QUEUE_BACK), 0.3)):
			continue
		KitPieces.stand(root, str(QUEUE["post"]), line[0], 1.3)
		for index: int in range(1, line.size()):
			KitPieces.stand(root, "DNA-SHEET-GHOST-QUEUE-%02d" % index, line[index], float(QUEUE["height"]), false)
		for p: Vector3 in line:
			_placed.append(Vector2(p.x, p.z))
			_builder.add_blocker(Vector3(p.x, 0.0, p.z), 0.35)
		count += 1
		return


## Batch 15 pass (Part 3.8): the apron outside the offices was flat grey to the horizon (the paper drift its only dressing). A light
## scatter of the kit's own pieces on it, either side of the approach causeway: filing towers and cabinets left out in the weather, a
## roped queue line that leads nowhere with a now-serving orb at its head, a ghost lamp or two, and forms and stamps on the ground.
## [id, x, z, height]: all off the walkable map (a spot that turns out to be floor is skipped), nothing solid, nothing on the causeway.
const APRON_PIECES: Array = [
	["DNA-SHEET-FILING-TOWERS-01", 38.6, 63.4, 2.3], ["DNA-SHEET-CABINETS-02", 36.4, 64.6, 1.5], ["DNA-PROP-PAPER", 40.4, 65.2, 0.7],
	["DNA-SHEET-FILING-TOWERS-03", 31.0, 62.6, 2.1], ["DNA-SHEET-CABINETS-05", 28.4, 64.0, 1.4], ["DNA-PROP-GHOSTLAMP", 33.6, 66.4, 2.4],
	["DNA-PROP-SERVING-ORB", 54.0, 63.2, 2.1], ["DNA-SHEET-FILING-TOWERS-04", 55.6, 63.6, 1.3], ["DNA-SHEET-FILING-TOWERS-04", 57.8, 64.0, 1.3],
	["DNA-SHEET-FILING-TOWERS-04", 60.0, 64.4, 1.3], ["DNA-SHEET-FILING-TOWERS-04", 62.2, 64.8, 1.3], ["DNA-SHEET-FILING-TOWERS-02", 52.4, 66.0, 2.2],
	["DNA-SHEET-CABINETS-03", 65.4, 62.8, 1.5], ["DNA-PROP-GHOSTLAMP", 59.0, 67.0, 2.4], ["DNA-PROP-PAPER", 51.2, 63.0, 0.7],
	["DNA-SHEET-FILING-TOWERS-05", 22.6, 60.6, 2.2], ["DNA-SHEET-CABINETS-01", 70.6, 61.4, 1.5],
]
## Ground decals: [id, x, z, width m, yaw].
const APRON_DECALS: Array = [
	["DNA-DEC-FORMS-01", 39.6, 66.8, 1.5, 20.0], ["DNA-DEC-FORMS-03", 35.0, 62.8, 1.3, -35.0], ["DEC-PAPERS", 30.2, 65.6, 1.8, 60.0],
	["DNA-DEC-FORMS-02", 53.4, 64.8, 1.4, -15.0], ["DNA-DEC-FORMS-05", 57.0, 66.0, 1.3, 40.0], ["DEC-PAPERS", 61.6, 62.6, 1.8, 110.0],
	["DNA-DEC-FORMS-04", 64.0, 66.6, 1.4, 5.0], ["DNA-DEC-FORMS-06", 26.0, 62.2, 1.3, 75.0], ["DNA-DEC-COFFEE", 37.8, 65.6, 0.9, 0.0],
	["DEC-PAPERS", 68.2, 64.6, 1.6, -50.0],
]
var apron_placed: int = 0


func _apron(quality: int) -> void:
	for entry: Array in APRON_PIECES:
		var spot: Vector3 = Vector3(float(entry[1]), 0.0, float(entry[2]))
		if _builder.is_floor_at(spot) or not EnvKit.has_art(str(entry[0])):
			continue
		if KitPieces.stand(root, str(entry[0]), spot, float(entry[3]), false) != null:
			apron_placed += 1
	if quality <= 0:
		return
	for entry: Array in APRON_DECALS:
		var center: Vector3 = Vector3(float(entry[1]), 0.0, float(entry[2]))
		if _builder.is_floor_at(center) or not EnvKit.has_art(str(entry[0])):
			continue
		KitPieces.ground(root, str(entry[0]), center, float(entry[4]), float(entry[3]))


## Fable Nov 14 (Part 3.6): the apron outside the offices is an organised wasteland, like the land outside the Capital but filed: straight
## rows running east-west either side of the approach causeway and beside the lobby, each row one kind of thing at an even spacing -
## filing cabinets (every third tipped over), a queue of rope posts that leads nowhere, stacks of crates, filing towers, dead trees
## (the Capital's and the D.N.A.'s own), rubble. Everything stands off the walkable map, nothing is solid, and the floating paper
## (DnaPaperDrift) is untouched. [kind, z, x from, x to, spacing]; a row is cut where the causeway and the lobby stand.
const WASTELAND_ROWS: Array = [
	# south of the lobby, both sides of the causeway
	["cabinets", 60.8, 6.0, 88.0, 2.9], ["queue", 63.3, 5.0, 89.0, 2.2], ["crates", 65.9, 7.0, 87.0, 3.6], ["trees", 68.6, 6.0, 88.0, 5.2],
	["towers", 71.2, 5.0, 89.0, 3.1], ["rubble", 73.9, 8.0, 86.0, 6.4], ["cabinets", 76.5, 6.0, 88.0, 2.9], ["trees", 79.4, 4.0, 90.0, 5.2],
	# beside the lobby, west and east (under the offices' south face)
	["towers", 46.2, -2.0, 15.0, 3.1], ["queue", 49.4, -3.0, 15.5, 2.2], ["crates", 52.6, -2.0, 15.0, 3.6], ["cabinets", 55.8, -3.0, 15.5, 2.9],
	["towers", 46.2, 57.0, 94.0, 3.1], ["queue", 49.4, 56.5, 95.0, 2.2], ["crates", 52.6, 57.0, 94.0, 3.6], ["cabinets", 55.8, 56.5, 95.0, 2.9],
]
## The causeway and the steps down from it stay clear (x range), and so does a metre round every older apron piece.
const WASTELAND_CAUSEWAY: Vector2 = Vector2(42.4, 50.6)
const WASTELAND_PIECES: Dictionary = {
	"cabinets": ["DNA-SHEET-CABINETS-01", "DNA-SHEET-CABINETS-02", "DNA-SHEET-CABINETS-04", "DNA-SHEET-CABINETS-03", "DNA-SHEET-CABINETS-06", "DNA-SHEET-CABINETS-05"],
	"towers": ["DNA-SHEET-FILING-TOWERS-01", "DNA-SHEET-FILING-TOWERS-03", "DNA-SHEET-FILING-TOWERS-02", "DNA-SHEET-FILING-TOWERS-05"],
	"queue": ["DNA-PROP-ROPE"],
	"trees": ["CAP-TREE-DEAD", "DNA-TREE-DEAD", "CAP-TREE-DEAD", "DNA-SHEET-PROPS-05"],
	"rubble": ["CAP-SHEET-RUBBLE-01", "CAP-PROP-RUBBLE-ROW", "CAP-SHEET-RUBBLE-02"],
}
const WASTELAND_HEIGHTS: Dictionary = {"cabinets": 1.5, "towers": 2.2, "queue": 1.05, "trees": 3.0, "rubble": 1.1}
const WASTELAND_CRATE: Vector3 = Vector3(0.8, 0.8, 0.8)
## Low-end keeps every other piece of each row.
var wasteland_placed: Dictionary = {}


func _wasteland(quality: int) -> void:
	var holder: Node3D = Node3D.new()
	holder.name = "Wasteland"
	root.add_child(holder)
	var crates: Array[Transform3D] = []
	var taken: Array[Vector2] = []
	for entry: Array in APRON_PIECES:
		taken.append(Vector2(float(entry[1]), float(entry[2])))
	for row_index: int in range(WASTELAND_ROWS.size()):
		var row: Array = WASTELAND_ROWS[row_index] as Array
		var kind: String = str(row[0])
		var z: float = float(row[1])
		var step: float = float(row[4])
		var x: float = float(row[2]) + (step * 0.5 if row_index % 2 == 1 else 0.0)
		var index: int = 0
		while x <= float(row[3]):
			var spot: Vector3 = Vector3(x, 0.0, z)
			var here: Vector2 = Vector2(x, z)
			x += step
			index += 1
			if quality <= 0 and index % 2 == 0:
				continue
			if here.x > WASTELAND_CAUSEWAY.x and here.x < WASTELAND_CAUSEWAY.y and here.y > 58.0:
				continue
			if _near_floor(spot, 1.2) or taken.any(func(other: Vector2) -> bool: return other.distance_to(here) < 0.9):
				continue
			if kind == "crates":
				# a neat stack: two crates side by side and one on top, turned a little
				var turn: Basis = Basis(Vector3.UP, 0.12 * float(index % 3 - 1))
				crates.append(Transform3D(turn, spot + Vector3(-0.43, 0.4, 0.0)))
				crates.append(Transform3D(turn, spot + Vector3(0.43, 0.4, 0.0)))
				if index % 4 != 3:
					crates.append(Transform3D(turn * Basis(Vector3.UP, 0.3), spot + Vector3(0.0, 1.2, 0.0)))
				wasteland_placed[kind] = int(wasteland_placed.get(kind, 0)) + 1
				continue
			var ids: Array = WASTELAND_PIECES[kind] as Array
			var id: String = str(ids[index % ids.size()])
			if not EnvKit.has_art(id):
				id = str(ids[0])
			var height: float = float(WASTELAND_HEIGHTS[kind])
			if id == "DNA-TREE-DEAD" or id == "DNA-SHEET-PROPS-05":
				height = 2.0
			elif id == "CAP-PROP-RUBBLE-ROW":
				height = 0.7
			var piece: Node3D = KitPieces.stand(holder, id, spot, height, false)
			if piece == null:
				continue
			if kind == "cabinets" and index % 3 == 2:
				# tipped over: the card lies on its side, a little sunk
				piece.rotation.z = (PI * 0.5 - 0.08) * (1.0 if index % 2 == 0 else -1.0)
				piece.position.y = 0.42
			wasteland_placed[kind] = int(wasteland_placed.get(kind, 0)) + 1
	if not crates.is_empty():
		var mesh: BoxMesh = BoxMesh.new()
		mesh.size = WASTELAND_CRATE
		var field: MultiMesh = MultiMesh.new()
		field.transform_format = MultiMesh.TRANSFORM_3D
		field.mesh = mesh
		field.instance_count = crates.size()
		for i: int in range(crates.size()):
			field.set_instance_transform(i, crates[i])
		var instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
		instance.name = "WastelandCrates"
		instance.multimesh = field
		instance.material_override = EnvKit.material("ENV-PROP-CRATE", false, Color(0.62, 0.72, 0.68))
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		instance.set_meta(&"no_range_cull", true)
		holder.add_child(instance)


## True when any walkable floor lies within `margin` of `spot` (the wasteland keeps off the map and its walls).
func _near_floor(spot: Vector3, margin: float) -> bool:
	for offset: Vector3 in [Vector3.ZERO, Vector3(margin, 0, 0), Vector3(-margin, 0, 0), Vector3(0, 0, margin), Vector3(0, 0, -margin)]:
		if _builder.is_floor_at(spot + offset):
			return true
	return false


## Batch 11: the lobby's cut-outs (LOBBY_PROPS); each one that finds no free spot near its wish is left out. The ids placed are kept in
## `lobby_placed` (tests, the report).
var lobby_placed: Dictionary = {}


func _lobby_props() -> void:
	for entry: Array in LOBBY_PROPS:
		if not EnvKit.has_art(str(entry[0])):
			continue
		for nudge: Vector3 in LOBBY_NUDGES:
			var spot: Vector3 = (entry[1] as Vector3) + nudge
			if not _free(spot, 1.6, 1.2):
				continue
			if KitPieces.stand(root, str(entry[0]), spot, float(entry[2])) == null:
				break
			_builder.add_blocker(Vector3(spot.x, 0.0, spot.z), float(entry[3]))
			_placed.append(Vector2(spot.x, spot.z))
			lobby_placed[str(entry[0])] = spot
			count += 1
			break


## Free floor for a piece of dressing: walkable, `clearance` from every anchor and chest, `spacing` from the other pieces, off the plaza middle, off the executive court,
## off the approach and off the doorways (any cell within 2 m whose floor kind differs is a doorway or a room edge).
func _free(pos: Vector3, clearance: float, spacing: float) -> bool:
	if not _builder.is_walkable(pos, 0.6):
		return false
	var layout: DnaLayout = _builder.layout
	if Vector2(pos.x - layout.anchors["lobby_center"].x, pos.z - layout.anchors["lobby_center"].z).length() < 5.5:
		return false
	var room: DnaLayout.Room = layout.room_at(pos)
	if room == null or room.id == "exec":
		return false
	if DnaLayout.LOBBY_WEST_PASSAGE.grow(0.8).has_point(Vector2(pos.x, pos.z)):
		return false  # Fix pass Nov 4 (B), Part 3.3: the lobby's west passage stays clear
	if DnaLayout.on_approach(pos.x, pos.z):
		return false
	for anchor: Vector3 in _anchors:
		if Vector2(pos.x - anchor.x, pos.z - anchor.z).length() < clearance:
			return false
	for other: Vector2 in _placed:
		if other.distance_to(Vector2(pos.x, pos.z)) < spacing:
			return false
	return true


## Flat kit decals just above the floor (the sub-areas place theirs from data; the hub from this list).
func _decals() -> void:
	var by_id: Dictionary = {}
	for entry: Array in DECALS:
		var id: String = str(entry[0])
		if not EnvKit.has(id) or not _builder.has_anchor(str(entry[1])):
			continue
		var offset: Vector2 = entry[2] as Vector2
		var pos: Vector3 = _builder.anchor(str(entry[1])) + Vector3(offset.x, 0.0, offset.y)
		if not _builder.is_floor_at(pos):
			continue
		var size: float = float(entry[3])
		var yaw: float = deg_to_rad(float(entry[4]))
		var aspect: float = EnvKit.aspect(id)
		var half: Vector2 = Vector2(size * minf(aspect, 1.0), size * minf(1.0 / maxf(aspect, 0.001), 1.0)) * 0.5
		var basis: Basis = Basis(Vector3.UP, yaw)
		var mesh: KitMesh = by_id.get(id) as KitMesh
		if mesh == null:
			mesh = KitMesh.new()
			var material: StandardMaterial3D = EnvKit.material(id, true).duplicate() as StandardMaterial3D
			material.render_priority = 4
			material.cull_mode = BaseMaterial3D.CULL_BACK
			mesh.set_material("decal", material)
			by_id[id] = mesh
		var corners: Array[Vector3] = []
		for corner: Vector2 in [Vector2(-1, 1), Vector2(1, 1), Vector2(1, -1), Vector2(-1, -1)]:
			corners.append(pos + basis * Vector3(corner.x * half.x, 0.045, corner.y * half.y))
		mesh.quad("decal", corners, Vector3.UP, [], DnaLandmarks.CARD_UVS)
		count += 1
	for id: String in by_id.keys():
		var instance: MeshInstance3D = (by_id[id] as KitMesh).instance("Decals_%s" % id)
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		instance.set_meta(PaintedClasses.META_NO_PAINT, true)
		instance.set_meta(&"no_occlusion_fade", true)
		root.add_child(instance)
