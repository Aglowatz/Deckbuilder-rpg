class_name DnaLayout
extends RefCounted
## The D.N.A.'s floor plan and everything placed on it, as plain data (no scene nodes), so it can
## be unit-tested headless: rooms, walls, props, signs, lights, anchors, enemy homes, chests.
## `DnaBuilder` turns this into meshes; `DnaScene` makes it playable.
##
## Coordinates: a grid of 1 m cells, x east, z south; cell (cx, cz) is centred on world
## ((cx + 0.5), 0, (cz + 0.5)). The hub (lobby + breakroom) is in the south, the zone gets
## deeper to the north: cubicle farms west/east, the filing maze north-west, the mail room in the
## middle, the elevator bank and executive floor north, the records basement north-east.
##
## D.N.A. slice (docs/art/dna_slice.md, the Gainlands corrections applied from the start): the office is an open-air civic plaza under an overcast sky, its rooms are
## courts walled by knee-high stone balustrades (never hiding the hero), every doorway is at least four cells wide (LINK_WIDTH), the props are a few tidy pieces at
## the walls, the boards are the ones that label something, and the way in is a walked approach causeway from the south with a gate (no elevator, no portal). The
## Hall of Final Approvals stands beyond the executive floor's north edge with its stair coming down to the floor (HALL_*). Positions of everything that is
## played (anchors, chests, enemies, gates) are unchanged except the spawn and exit, which moved onto the approach.

const W: int = 90
const H: int = 72
## Every doorway between rooms is at least this many cells wide (four hero widths and more).
const LINK_WIDTH: int = 4
## The approach causeway from the south edge into the lobby (x APPROACH_X0 .. APPROACH_X1 - 1, z APPROACH_Z0 .. APPROACH_Z1 - 1) and its gate at the lobby wall.
const APPROACH_X0: int = 44
const APPROACH_X1: int = 49
const APPROACH_Z0: int = 60
const APPROACH_Z1: int = 68
const GATE_Z: float = 60.5
## The last metre of the causeway: walking onto it (after having been well inside the zone) leaves for town (DnaScene).
const EXIT_EDGE_Z: float = 67.3
## The Hall of Final Approvals: centre (x, z), its box (w, h, d); its stair foot meets the executive floor's north edge at HALL_FOOT_Z.
const HALL_CENTER: Vector2 = Vector2(45.5, -18.2)
const HALL_SIZE: Vector3 = Vector3(64.0, 40.0, 24.0)
const HALL_FOOT_Z: float = 1.45

enum Cell { VOID, FLOOR, WALL, SOLID }
enum Floor { NONE, CARPET, TILE, CONCRETE, EXEC, LINO }

## A rectangle of walkable floor: id, rect (cells), floor look, area name for the HUD/zone sign.
class Room:
	extends RefCounted
	var id: String = ""
	var rect: Rect2i = Rect2i()
	var floor_kind: Floor = Floor.CARPET
	var title: String = ""
	var safe: bool = false


## A static prop: what it is (`kind`), where and how. Kinds: "model" (a Kenney / KayKit model, `model` = file name), "card" (a painted kit cut-out facing the camera,
## `model` = the kit id, `model_scale` = its height in metres), "piece" (a kit-textured procedural piece built by DnaProps, `model` = its name), "" (a blocker only).
class Prop:
	extends RefCounted
	var kind: String = "model"
	var model: String = ""
	var pos: Vector3 = Vector3.ZERO
	var yaw: float = 0.0
	var model_scale: float = 1.0
	## Blocks movement within this radius (0 = decoration only).
	var radius: float = 0.0
	## Optional non-uniform scale (used for stretched boxes), (0,0,0) = uniform `model_scale`.
	var stretch: Vector3 = Vector3.ZERO


## A sign/poster/memo: text key (ZoneStoryText), position, which way it faces, font scale.
class Sign:
	extends RefCounted
	var key: String = ""
	var pos: Vector3 = Vector3.ZERO
	var yaw: float = 0.0
	var size: float = 1.0
	## "sign" (hanging name sign), "poster" (framed, on a wall), "memo" (small note).
	var style: String = "sign"


class LightSpot:
	extends RefCounted
	var pos: Vector3 = Vector3.ZERO
	var color: Color = Color.WHITE
	## Flicker group 0-3 (0 = steady); each group flickers on its own rhythm.
	var group: int = 0


var cells: PackedByteArray = PackedByteArray()
var floors: PackedByteArray = PackedByteArray()
var rooms: Array[Room] = []
var props: Array[Prop] = []
var signs: Array[Sign] = []
var lights: Array[LightSpot] = []
## Named world positions: "spawn", "exit", "heal", "vendor", "dolores", "barnaby", "pip", "quiz",
## "matching", "puzzle", "mini_dungeon", "main_dungeon", "coffee", "time_clock", "suggestion",
## "printer", "chest_<n>" ...
var anchors: Dictionary = {}
## [{type, home, patrol}] for the roaming enemies.
var enemy_spawns: Array[Dictionary] = []
## Chest anchors by id (positions of the hidden chests).
var chests: Dictionary = {}
## Thin cubicle partitions as line segments (a, b) in world xz - circles are laid along them.
var partitions: Array[Vector4] = []
## Void cells that get no balustrade (the executive floor's north edge where the Hall's stair comes down): Vector2i -> true.
var open_edges: Dictionary = {}
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func build() -> void:
	_rng.seed = 1291
	cells.resize(W * H)
	floors.resize(W * H)
	_rooms_and_corridors()
	_furnish_lobby()
	_furnish_approach()
	_furnish_breakroom()
	_furnish_farm("farm_a", Rect2i(2, 26, 32, 18), 33, 3)
	_furnish_farm("farm_b", Rect2i(56, 26, 32, 18), 77, 3)
	_furnish_mail_room()
	_furnish_filing_maze()
	_furnish_elevator_bank()
	_furnish_records()
	_furnish_executive()
	_furnish_coolers()
	_polish_chests()
	_enemies()
	_finish_walls()



## Water coolers (Oct 19, the office interior): one in a corner of each room, a metre off the wall, never on a route or near an interact spot.
const COOLERS: Array[Vector3] = [
	Vector3(38.4, 0.0, 58.9), Vector3(29.0, 0.0, 49.0), Vector3(3.4, 0.0, 27.2), Vector3(87.0, 0.0, 27.2), Vector3(38.4, 0.0, 41.0),
	Vector3(37.0, 0.0, 22.6), Vector3(37.0, 0.0, 12.6), Vector3(87.0, 0.0, 22.6),
]


func _furnish_coolers() -> void:
	for pos: Vector3 in COOLERS:
		var cell: Vector2i = world_to_cell(pos)
		if not is_floor(cell.x, cell.y):
			continue
		_piece("water_cooler", pos, 0.0)
		_blockers(pos, pos, 0.3, 1.0)


## Polish round: 6 more hidden chests, the hardest deep in the Filing Department's maze (docs/design/secrets.md). World metres; none is within
## 4 m of an interact spot.
func _polish_chests() -> void:
	chests["chest_maze_3"] = Vector3(2.4, 0.0, 11.4)
	chests["chest_maze_4"] = Vector3(9.6, 0.0, 4.8)
	chests["chest_maze_5"] = Vector3(8.4, 0.0, 17.4)
	chests["chest_records_2"] = Vector3(87.6, 0.0, 4.8)
	chests["chest_exec_2"] = Vector3(52.2, 0.0, 2.4)
	chests["chest_farm_c"] = Vector3(87.6, 0.0, 43.2)


# ---- Grid helpers --------------------------------------------------------------------------


static func cell_center(cx: int, cz: int) -> Vector3:
	return Vector3(float(cx) + 0.5, 0.0, float(cz) + 0.5)


static func world_to_cell(pos: Vector3) -> Vector2i:
	return Vector2i(int(floorf(pos.x)), int(floorf(pos.z)))


## True on the approach causeway (the way in and out).
static func on_approach(x: float, z: float) -> bool:
	return x >= float(APPROACH_X0) and x < float(APPROACH_X1) and z >= float(APPROACH_Z0) and z < float(APPROACH_Z1)


func in_bounds(cx: int, cz: int) -> bool:
	return cx >= 0 and cz >= 0 and cx < W and cz < H


func cell_at(cx: int, cz: int) -> Cell:
	if not in_bounds(cx, cz):
		return Cell.VOID
	return cells[cz * W + cx] as Cell


func floor_at(cx: int, cz: int) -> Floor:
	if not in_bounds(cx, cz):
		return Floor.NONE
	return floors[cz * W + cx] as Floor


func is_floor(cx: int, cz: int) -> bool:
	return cell_at(cx, cz) == Cell.FLOOR


func floor_cell_count() -> int:
	var count: int = 0
	for value: int in cells:
		if value == Cell.FLOOR or value == Cell.SOLID:
			count += 1
	return count


func walkable_cell_count() -> int:
	var count: int = 0
	for value: int in cells:
		if value == Cell.FLOOR:
			count += 1
	return count


func room_at(pos: Vector3) -> Room:
	var cell: Vector2i = world_to_cell(pos)
	for room: Room in rooms:
		if room.rect.has_point(cell):
			return room
	return null


func _put(cx: int, cz: int, cell: Cell, floor_kind: Floor = Floor.NONE) -> void:
	if not in_bounds(cx, cz):
		return
	cells[cz * W + cx] = cell
	if floor_kind != Floor.NONE:
		floors[cz * W + cx] = floor_kind


func _carve(rect: Rect2i, floor_kind: Floor) -> void:
	for cz: int in range(rect.position.y, rect.end.y):
		for cx: int in range(rect.position.x, rect.end.x):
			_put(cx, cz, Cell.FLOOR, floor_kind)


func _room(id: String, rect: Rect2i, floor_kind: Floor, title: String, safe: bool = false) -> Room:
	var room: Room = Room.new()
	room.id = id
	room.rect = rect
	room.floor_kind = floor_kind
	room.title = title
	room.safe = safe
	rooms.append(room)
	_carve(rect, floor_kind)
	return room


## A corridor / doorway: just carved floor that takes the floor look of `like`. Every doorway is at least LINK_WIDTH cells across (GC-1: wide, clear routes).
func _link(rect: Rect2i, floor_kind: Floor) -> void:
	_carve(rect, floor_kind)


# ---- Floor plan ----------------------------------------------------------------------------


func _rooms_and_corridors() -> void:
	_room("lobby", Rect2i(36, 46, 20, 14), Floor.TILE, "The Lobby", true)
	_room("breakroom", Rect2i(18, 48, 17, 12), Floor.LINO, "The Breakroom", true)
	_link(Rect2i(35, 51, 1, 4), Floor.LINO)
	_room("farm_a", Rect2i(2, 26, 32, 18), Floor.CARPET, "Cubicle Farm A")
	_room("farm_b", Rect2i(56, 26, 32, 18), Floor.CARPET, "Cubicle Farm B")
	_room("mail", Rect2i(36, 28, 18, 14), Floor.TILE, "The Mail Room")
	_room("maze", Rect2i(2, 4, 32, 18), Floor.CONCRETE, "The Filing Department")
	_room("bank", Rect2i(36, 16, 18, 8), Floor.TILE, "The Elevator Bank")
	_room("records", Rect2i(56, 4, 32, 20), Floor.CONCRETE, "The Records Basement")
	_room("exec", Rect2i(36, 2, 18, 12), Floor.EXEC, "The Executive Floor")
	# The approach causeway: the way in from town, south of the lobby.
	_link(Rect2i(APPROACH_X0, APPROACH_Z0, APPROACH_X1 - APPROACH_X0, APPROACH_Z1 - APPROACH_Z0), Floor.TILE)
	# Corridors and doorways, all LINK_WIDTH or wider.
	_link(Rect2i(43, 42, 4, 4), Floor.TILE)   # lobby <-> mail room
	_link(Rect2i(23, 44, 5, 4), Floor.LINO)   # breakroom <-> farm A
	_link(Rect2i(34, 32, 2, 5), Floor.CARPET) # farm A <-> mail room
	_link(Rect2i(54, 32, 2, 5), Floor.CARPET) # mail room <-> farm B
	_link(Rect2i(43, 24, 4, 4), Floor.TILE)   # mail room <-> elevator bank
	_link(Rect2i(14, 22, 5, 4), Floor.CONCRETE) # farm A <-> filing maze
	_link(Rect2i(34, 16, 2, 5), Floor.CONCRETE) # filing maze <-> elevator bank
	_link(Rect2i(54, 17, 2, 5), Floor.CONCRETE) # elevator bank <-> records
	_link(Rect2i(43, 14, 4, 2), Floor.EXEC)   # elevator bank <-> executive floor
	_link(Rect2i(69, 24, 5, 2), Floor.CONCRETE) # farm B <-> records basement
	# A fresh visit starts on the causeway facing the gate; the exit spot waits at its far end.
	anchors["spawn"] = Vector3(46.5, 0.0, 64.5)
	anchors["exit"] = Vector3(46.5, 0.0, 66.6)
	anchors["gate"] = Vector3(46.5, 0.0, GATE_Z)
	anchors["rift_station"] = Vector3(48.5, 0.0, 55.5)
	# Brief 16: Shiro Swindle's giant chest, in the open floor north-west of the lobby (see NinjaBoss).
	anchors["giant_chest"] = Vector3(28.2, 0.0, 42.6)
	# Brief 16: the hidden vault lever, at the far west end of the office.
	anchors["vault_lever"] = Vector3(7.2, 0.0, 42.6)


# ---- Prop helpers --------------------------------------------------------------------------


func _prop(model: String, pos: Vector3, yaw: float = 0.0, model_scale: float = 1.0, radius: float = 0.0) -> Prop:
	var prop: Prop = Prop.new()
	prop.kind = "model"
	prop.model = model
	prop.pos = pos
	prop.yaw = yaw
	prop.model_scale = model_scale
	prop.radius = radius
	props.append(prop)
	return prop


## A painted kit cut-out facing the camera: `height` metres tall, blocking `radius` (0 = walk through).
func _card(id: String, pos: Vector3, height: float, radius: float = 0.0) -> Prop:
	var prop: Prop = Prop.new()
	prop.kind = "card"
	prop.model = id
	prop.pos = pos
	prop.model_scale = height
	prop.radius = radius
	props.append(prop)
	return prop


## A kit-textured procedural piece (DnaProps): `name` is the piece, `yaw` turns it, `model_scale` its length where the piece takes one.
func _piece(piece_name: String, pos: Vector3, yaw: float = 0.0, length: float = 1.0) -> Prop:
	var prop: Prop = Prop.new()
	prop.kind = "piece"
	prop.model = piece_name
	prop.pos = pos
	prop.yaw = yaw
	prop.model_scale = length
	props.append(prop)
	return prop


func _sign(key: String, pos: Vector3, yaw: float = 0.0, style: String = "sign", size: float = 1.0) -> void:
	var made: Sign = Sign.new()
	made.key = key
	made.pos = pos
	made.yaw = yaw
	made.style = style
	made.size = size
	signs.append(made)


func _light(pos: Vector3, group: int = 0, color: Color = Color(0.72, 1.0, 0.82)) -> void:
	var spot: LightSpot = LightSpot.new()
	spot.pos = pos
	spot.group = group
	spot.color = color
	lights.append(spot)


## A ghost lamp post (the kit card, 2.6 m) with its pooled light at the lantern, on flicker group `group`.
func _lamp(pos: Vector3, group: int = 0, color: Color = Color(0.72, 1.0, 0.82)) -> void:
	_card("DNA-PROP-GHOSTLAMP", pos, 2.6, 0.22)
	_light(pos + Vector3(0, 2.1, 0), group, color)


## A ghost lamp at a wall cell round a room, standing on the floor just inside the wall (Oct 19: the walls are full height, so the lamp moved off the parapet cap
## onto the floor's edge, a small blocker). Skipped where the wall cell is a doorway or touches no floor.
func _wall_lamp(pos: Vector3, group: int = 0, color: Color = Color(0.72, 1.0, 0.82)) -> void:
	var cell: Vector2i = world_to_cell(pos)
	if is_floor(cell.x, cell.y):
		return
	var toward: Vector3 = Vector3.ZERO
	for ring: Array in [[Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)], [Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(-1, -1)]]:
		for step: Vector2i in ring:
			if is_floor(cell.x + step.x, cell.y + step.y):
				toward = Vector3(float(step.x), 0.0, float(step.y)).normalized()
				break
		if toward != Vector3.ZERO:
			break
	if toward == Vector3.ZERO:
		return
	var foot: Vector3 = cell_center(cell.x, cell.y) + toward * 0.82
	_card("DNA-PROP-GHOSTLAMP", Vector3(foot.x, 0.0, foot.z), 2.6, 0.16)
	_light(foot + Vector3(0, 2.1, 0), group, color)


## Ghost lamps on the balustrade round a room: one at each corner and every `step` cells along the north and south walls, flicker groups cycling 1-3.
func _lamp_ring(rect: Rect2i, step: int, color: Color = Color(0.72, 1.0, 0.82), _inset: float = 0.0) -> void:
	var group: int = 1
	var x0: float = float(rect.position.x) - 0.5
	var x1: float = float(rect.end.x) + 0.5
	var z0: float = float(rect.position.y) - 0.5
	var z1: float = float(rect.end.y) + 0.5
	var x: float = x0
	while x <= x1 + 0.01:
		for z: float in [z0, z1]:
			_wall_lamp(Vector3(x, 0.0, z), group, color)
			group = group % 3 + 1
		x += float(step)
		if x > x1 and x < x1 + float(step) - 0.01:
			x = x1


# Furniture scale: Kenney's kit is built for a taller world than our 0.68 m hero.
const F: float = 1.35


## Circular blockers along a straight segment (for desks, partitions...).
func _blockers(a: Vector3, b: Vector3, radius: float, spacing: float = 0.45) -> void:
	var length: float = a.distance_to(b)
	var count: int = maxi(1, int(ceilf(length / spacing)))
	for i: int in range(count + 1):
		var point: Vector3 = a.lerp(b, float(i) / float(count))
		var blocker: Prop = Prop.new()
		blocker.kind = ""
		blocker.model = ""
		blocker.pos = point
		blocker.radius = radius
		props.append(blocker)


func _partition(a: Vector3, b: Vector3) -> void:
	partitions.append(Vector4(a.x, a.z, b.x, b.z))
	_blockers(a, b, 0.2)


# ---- Lobby (hub, safe) ---------------------------------------------------------------------


## The Lobby Plaza (GC-7 applied from the start): an empty middle, the things that matter round its rim with breathing room. Agnes behind the front counter along the
## north wall, Clerk Ledgerbone at the Requisitions desk on the east wall, the Rift Express in the south-east, the gate to the approach in the south wall; two office
## plants in the north corners and ghost lamps at the corners are the whole dressing.
func _furnish_lobby() -> void:
	var r: Rect2i = Rect2i(36, 46, 20, 14)
	_lamp_ring(r, 9, Color(0.72, 1.0, 0.82), 1.2)
	# The front counter across the north end, Agnes Overdue behind it.
	_piece("counter", Vector3(44.0, 0.0, 49.4), 0.0, 7.0)
	_blockers(Vector3(40.6, 0, 49.4), Vector3(47.4, 0, 49.4), 0.36, 0.4)
	anchors["dolores"] = cell_center(44, 48)
	_sign("sign.lobby_main", Vector3(46.0, 1.7, 46.2), 0.0, "sign", 1.25)
	_card("DNA-PLANT-OFFICE", cell_center(37, 47), 1.7, 0.3)
	_card("DNA-PLANT-OFFICE", cell_center(54, 47), 1.7, 0.3)
	# Requisitions desk (vendor) on the east side: the kit desk, a cabinet behind it.
	anchors["pip"] = cell_center(52, 53)
	_card("DNA-PROP-DESK", cell_center(52, 54) + Vector3(0, 0, 0.3), 1.3)
	_blockers(cell_center(51, 54), cell_center(53, 54), 0.35, 0.4)
	_card("DNA-SHEET-CABINETS-01", cell_center(54, 52) + Vector3(0.3, 0, 0), 1.5, 0.35)
	_sign("sign.requisitions", Vector3(52.5, 1.55, 52.0), 0.0, "sign", 0.9)
	# The way in and out: the gate in the south wall onto the approach causeway (the exit spot stands at the causeway's far end).
	anchors["exit_door"] = Vector3(46.5, 0.0, 59.5)
	_sign("sign.exit", Vector3(43.2, 1.7, 59.4), 180.0, "sign", 1.0)
	anchors["lobby_center"] = cell_center(45, 53)


## The approach causeway: a stone causeway with ghost lamps at its head and foot; a gate (DnaLandmarks) stands at the lobby wall; a bridge stub beyond its far end
## reads as the way back to town (DnaBuilder draws both).
func _furnish_approach() -> void:
	_wall_lamp(Vector3(43.5, 0.0, 63.5), 2)
	_wall_lamp(Vector3(49.5, 0.0, 63.5), 3)
	_wall_lamp(Vector3(43.5, 0.0, 67.5), 1)
	_wall_lamp(Vector3(49.5, 0.0, 67.5), 2)


# ---- Breakroom (hub, safe) -----------------------------------------------------------------


func _furnish_breakroom() -> void:
	var r: Rect2i = Rect2i(18, 48, 17, 12)
	_lamp_ring(r, 8, Color(0.8, 1.0, 0.85), 1.0)
	# Kitchen counter along the north wall with the coffee machine on it; the barista behind it.
	_piece("counter", Vector3(23.5, 0.0, 49.4), 0.0, 7.0)
	_blockers(Vector3(20.1, 0, 49.4), Vector3(26.9, 0, 49.4), 0.4, 0.45)
	_piece("coffee_machine", Vector3(22.5, 0.0, 49.3), 0.0)
	anchors["coffee"] = cell_center(22, 50)
	anchors["barnaby"] = cell_center(25, 50)  # 2.5 m east of the coffee machine so the two prompts never fight (open space round every interactable)
	_sign("sign.coffee", Vector3(22.5, 1.5, 48.2), 0.0, "poster", 0.8)
	# One round table in the middle, a bench (the healing couch) in the south-east corner under a lily.
	_piece("round_table", cell_center(26, 54), 0.0)
	_blockers(cell_center(26, 54), cell_center(26, 54), 0.7, 0.5)
	_piece("bench", cell_center(31, 57), 180.0, 2.4)
	_blockers(cell_center(30, 57) + Vector3(-0.2, 0, 0), cell_center(32, 57) + Vector3(0.2, 0, 0), 0.4, 0.45)
	_card("DNA-PLANT-LILY", cell_center(33, 58) + Vector3(0.2, 0, 0.2), 1.2, 0.2)
	_card("DNA-PLANT-OFFICE", cell_center(19, 58), 1.6, 0.3)
	anchors["heal"] = cell_center(31, 55)
	_sign("sign.heal_couch", Vector3(31.5, 1.5, 58.4), 180.0, "poster", 0.8)
	# Time clock on the west wall.
	anchors["time_clock"] = cell_center(19, 53)
	_sign("sign.time_clock", Vector3(18.2, 1.55, 53.5), 270.0, "poster", 0.8)
	# Suggestion box by the doorway to the lobby.
	anchors["suggestion"] = cell_center(33, 51)
	_sign("sign.suggestion_box", Vector3(33.5, 1.5, 50.2), 0.0, "poster", 0.8)
	anchors["breakroom_center"] = cell_center(26, 54)


# ---- Cubicle farms -------------------------------------------------------------------------


## A grid of 3x3 cubicles opening south onto 2-cell aisles. `farm_id` picks decor, `seed_x` the
## cell where its special cubicle goes. Aisle rows: the farm's first/last rows are left clear. Each cubicle holds one kit desk (its clerk's station) and nothing else;
## the partitions are knee-high paneling (DnaBuilder) that fades when it stands in the way.
func _furnish_farm(farm_id: String, r: Rect2i, _unused: int, _unused2: int) -> void:
	_lamp_ring(r, 10)
	var block_x0: int = r.position.x + 2
	var cols: int = (r.size.x - 4) / 3
	# Row tops (z of the cubicle's north partition) with a 2-cell aisle beneath each row.
	var tops: Array[int] = [r.position.y + 2, r.position.y + 7, r.position.y + 12]
	var coffin_cell: int = 3 if farm_id == "farm_a" else 6
	var cubicle_index: int = 0
	for row: int in range(tops.size()):
		var top: int = tops[row]
		for col: int in range(cols):
			var x0: int = block_x0 + col * 3
			var home: Vector3 = Vector3(float(x0) + 1.5, 0.0, float(top) + 1.5)
			# North partition and the shared west partition (east for the last cubicle).
			_partition(Vector3(float(x0), 0, float(top)), Vector3(float(x0 + 3), 0, float(top)))
			_partition(Vector3(float(x0), 0, float(top)), Vector3(float(x0), 0, float(top + 3) - 0.2))
			if col == cols - 1:
				_partition(Vector3(float(x0 + 3), 0, float(top)), Vector3(float(x0 + 3), 0, float(top + 3) - 0.2))
			var special: bool = row == 1 and col == coffin_cell
			if special and farm_id == "farm_a":
				# The cubicle with a coffin.
				_prop("coffin_decorated", home + Vector3(0, 0, 0.1), 90.0, 0.62, 0.0)
				_blockers(home + Vector3(-0.3, 0, 0.1), home + Vector3(0.3, 0, 0.1), 0.35, 0.4)
				_sign("memo.cubicle_coffin", Vector3(home.x - 1.4, 0.9, home.z - 1.45) + Vector3(0, 0, 0), 0.0, "memo", 0.8)
			else:
				_card("DNA-PROP-DESK", home + Vector3(0, 0, -0.85), 1.25)
				_blockers(home + Vector3(-0.5, 0, -0.85), home + Vector3(0.5, 0, -0.85), 0.34, 0.4)
			cubicle_index += 1
	# Room dressing: one board naming the farm at its south wall (the aisles are 2 m: nothing else stands in them).
	var south_z: float = float(r.end.y) - 0.2
	if farm_id == "farm_a":
		_sign("sign.cubicle_farm_a", Vector3(float(r.position.x) + 8.0, 1.7, south_z + 0.0), 180.0, "sign", 1.1)
		anchors["farm_a_center"] = cell_center(r.position.x + 15, r.position.y + 9)
		anchors["farm_a_aisle"] = cell_center(r.position.x + 15, r.position.y + 10)
	else:
		_sign("sign.cubicle_farm_b", Vector3(float(r.position.x) + 8.0, 1.7, south_z), 180.0, "sign", 1.1)
		anchors["farm_b_center"] = cell_center(r.position.x + 15, r.position.y + 9)
		# The quiz master's corner office, in the south-east of farm B (walled off with partitions).
		var qx: float = float(r.end.x) - 6.0
		var qz: float = float(r.end.y) - 5.0
		_partition(Vector3(qx, 0, qz), Vector3(qx + 5.0, 0, qz))
		_partition(Vector3(qx, 0, qz), Vector3(qx, 0, qz + 2.2))
		_card("DNA-PROP-DESK", Vector3(qx + 3.6, 0, qz + 1.4), 1.25)
		_blockers(Vector3(qx + 3.1, 0, qz + 1.4), Vector3(qx + 4.1, 0, qz + 1.4), 0.34, 0.4)
		_card("DNA-SHEET-CABINETS-03", Vector3(qx + 4.8, 0, qz + 0.8), 1.5, 0.3)
		anchors["quiz"] = Vector3(qx + 2.4, 0.0, qz + 1.7)
		_sign("sign.quiz", Vector3(qx + 2.5, 1.5, qz + 0.1), 0.0, "sign", 0.95)
		# The haunted printer (an interactable) on the far west of farm B.
		anchors["printer"] = cell_center(r.position.x + 1, r.position.y + 16)
		_blockers(cell_center(r.position.x + 1, r.position.y + 16) + Vector3(0, 0, -0.4), cell_center(r.position.x + 1, r.position.y + 16) + Vector3(0, 0, 0.4), 0.35, 0.4)
		_sign("sign.printer", Vector3(float(r.position.x) + 0.3, 1.3, float(r.position.y) + 16.5), 90.0, "poster", 0.75)
		_light(cell_center(r.position.x + 1, r.position.y + 16) + Vector3(0.4, 0.9, 0), 0, Color(0.55, 1.0, 0.6))
	# An unclaimed corner cubicle's stash (hidden chest) in each farm.
	var chest_key: String = "chest_%s" % farm_id
	var cx: float = float(r.position.x) + 1.0 if farm_id == "farm_b" else float(r.end.x) - 1.2
	var cz2: float = float(r.position.y) + 0.8
	chests[chest_key] = Vector3(cx, 0.0, cz2)


# ---- Mail room (the pneumatic tube puzzle) --------------------------------------------------


func _furnish_mail_room() -> void:
	var r: Rect2i = Rect2i(36, 28, 18, 14)
	_lamp_ring(r, 9, Color(0.75, 0.95, 1.0), 1.0)
	_sign("sign.mailroom", Vector3(45.0, 1.7, 28.25), 0.0, "sign", 1.15)
	_sign("sign.puzzle", Vector3(45.0, 1.15, 28.25), 0.0, "poster", 0.85)
	# The routing terminal: a console with three screens in the middle of the room.
	var terminal: Vector3 = cell_center(44, 35)
	anchors["puzzle"] = terminal + Vector3(1.0, 0, 1.0)
	_piece("console", terminal, 0.0, 3.0)
	_blockers(terminal + Vector3(-1.4, 0, 0), terminal + Vector3(1.4, 0, 0), 0.34, 0.4)
	_light(terminal + Vector3(0, 1.0, 0.6), 0, Color(0.55, 1.0, 0.8))
	# Sorting cabinets in one row along the north wall; the wall tube pipes are drawn by the builder.
	for x: float in [37.6, 39.6, 41.4, 49.0, 50.8, 52.6]:
		_card("DNA-SHEET-CABINETS-%02d" % [2 if int(x) % 2 == 0 else 4], Vector3(x, 0.0, 28.9), 1.3, 0.45)
	anchors["mail_center"] = cell_center(45, 38)


# ---- Filing maze ---------------------------------------------------------------------------


func _furnish_filing_maze() -> void:
	var r: Rect2i = Rect2i(2, 4, 32, 18)
	_sign("sign.filing_maze", Vector3(16.5, 1.7, 21.8), 180.0, "sign", 1.1)
	# Fill the whole room with solid cabinet cells, then carve a perfect maze (cell pitch 3: 2x2
	# floor + 1 wall) and open some extra walls so there are loops, not only dead ends.
	var cols: int = (r.size.x + 1) / 3
	var rows: int = (r.size.y + 1) / 3
	for cz: int in range(r.position.y, r.end.y):
		for cx: int in range(r.position.x, r.end.x):
			_put(cx, cz, Cell.SOLID)
	var visited: Dictionary = {}
	var open_walls: Dictionary = {}
	var stack: Array[Vector2i] = [Vector2i(cols / 2, rows - 1)]
	visited[stack[0]] = true
	while not stack.is_empty():
		var current: Vector2i = stack[stack.size() - 1]
		var options: Array[Vector2i] = []
		for step: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var next: Vector2i = current + step
			if next.x >= 0 and next.y >= 0 and next.x < cols and next.y < rows and not visited.has(next):
				options.append(next)
		if options.is_empty():
			stack.pop_back()
			continue
		var pick: Vector2i = options[_rng.randi() % options.size()]
		visited[pick] = true
		open_walls[_edge(current, pick)] = true
		stack.append(pick)
	for extra: int in range(14):
		var a: Vector2i = Vector2i(_rng.randi_range(0, cols - 1), _rng.randi_range(0, rows - 1))
		var steps: Array[Vector2i] = [Vector2i(1, 0), Vector2i(0, 1)]
		var b: Vector2i = a + steps[_rng.randi() % 2]
		if b.x < cols and b.y < rows:
			open_walls[_edge(a, b)] = true
	var degree: Dictionary = {}
	for ix: int in range(cols):
		for iz: int in range(rows):
			var x0: int = r.position.x + ix * 3
			var z0: int = r.position.y + iz * 3
			for dz: int in range(2):
				for dx: int in range(2):
					_put(x0 + dx, z0 + dz, Cell.FLOOR, Floor.CONCRETE)
			var here: Vector2i = Vector2i(ix, iz)
			if ix + 1 < cols and open_walls.has(_edge(here, Vector2i(ix + 1, iz))):
				_put(x0 + 2, z0, Cell.FLOOR, Floor.CONCRETE)
				_put(x0 + 2, z0 + 1, Cell.FLOOR, Floor.CONCRETE)
				degree[here] = int(degree.get(here, 0)) + 1
				degree[Vector2i(ix + 1, iz)] = int(degree.get(Vector2i(ix + 1, iz), 0)) + 1
			if iz + 1 < rows and open_walls.has(_edge(here, Vector2i(ix, iz + 1))):
				_put(x0, z0 + 2, Cell.FLOOR, Floor.CONCRETE)
				_put(x0 + 1, z0 + 2, Cell.FLOOR, Floor.CONCRETE)
				degree[here] = int(degree.get(here, 0)) + 1
				degree[Vector2i(ix, iz + 1)] = int(degree.get(Vector2i(ix, iz + 1), 0)) + 1
	# The entrance corridors cut through the outer cabinet ring; make sure they stay open (LINK_WIDTH wide).
	_carve(Rect2i(14, 22, 5, 1), Floor.CONCRETE)
	_carve(Rect2i(14, 20, 5, 2), Floor.CONCRETE)
	_carve(Rect2i(32, 16, 2, 5), Floor.CONCRETE)
	_carve(Rect2i(30, 16, 2, 5), Floor.CONCRETE)
	# Dead ends: hidden chests (3), and the matching-game NPC's alcove in the deepest one.
	var dead_ends: Array[Vector2i] = []
	for ix: int in range(cols):
		for iz: int in range(rows):
			if int(degree.get(Vector2i(ix, iz), 0)) == 1:
				dead_ends.append(Vector2i(ix, iz))
	dead_ends.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.y < b.y or (a.y == b.y and a.x < b.x))
	var picks: Array[Vector2i] = []
	if not dead_ends.is_empty():
		picks.append(dead_ends[0])
		picks.append(dead_ends[dead_ends.size() - 1])
		picks.append(dead_ends[dead_ends.size() / 2])
	var chest_index: int = 0
	for pick: Vector2i in picks:
		var chest_pos: Vector3 = cell_center(r.position.x + pick.x * 3, r.position.y + pick.y * 3) + Vector3(0.9, 0.0, 0.9)
		chests["chest_maze_%d" % chest_index] = chest_pos
		chest_index += 1
	# The Rec Room alcove (Kyle's corner): the NW corner cell of the maze: a bench and his old television.
	var nw: Vector3 = cell_center(r.position.x, r.position.y) + Vector3(0.5, 0, 0.5)
	anchors["matching"] = nw + Vector3(0.0, 0.0, 0.2)
	_piece("bench", nw + Vector3(0.0, 0.0, -0.45), 0.0, 1.4)
	_piece("television", nw + Vector3(1.55, 0, 0.55), 270.0)
	_blockers(nw + Vector3(1.55, 0, 0.55), nw + Vector3(1.55, 0, 0.55), 0.25, 0.4)
	_light(nw + Vector3(0.8, 0.9, 0.4), 0, Color(0.85, 0.6, 1.0))
	_sign("sign.matching", Vector3(nw.x - 0.5, 1.5, nw.z - 0.9), 0.0, "poster", 0.8)
	# Ghost lamps at the maze's two doorways (never inside: a lamp in a 2 m maze cell closes it) so the maze isn't pitch dark.
	for point: Vector2 in [Vector2(13.5, 23.5), Vector2(19.5, 23.5), Vector2(34.5, 15.5), Vector2(34.5, 21.5)]:
		_wall_lamp(Vector3(point.x, 0.0, point.y), 2, Color(0.7, 1.0, 0.8))
	anchors["maze_entrance"] = cell_center(16, 21)


static func _edge(a: Vector2i, b: Vector2i) -> String:
	if a.x > b.x or (a.x == b.x and a.y > b.y):
		return "%d,%d-%d,%d" % [b.x, b.y, a.x, a.y]
	return "%d,%d-%d,%d" % [a.x, a.y, b.x, b.y]


# ---- Elevator bank -------------------------------------------------------------------------


func _furnish_elevator_bank() -> void:
	var r: Rect2i = Rect2i(36, 16, 18, 8)
	_wall_lamp(Vector3(35.5, 0.0, 23.5), 1, Color(0.8, 1.0, 0.9))
	_wall_lamp(Vector3(54.5, 0.0, 23.5), 2, Color(0.8, 1.0, 0.9))
	_wall_lamp(Vector3(35.5, 0.0, 15.5), 3, Color(0.8, 1.0, 0.9))
	_wall_lamp(Vector3(54.5, 0.0, 15.5), 1, Color(0.8, 1.0, 0.9))
	_sign("sign.elevator_bank", Vector3(45.0, 1.8, 24.0), 180.0, "sign", 1.0)
	# Four elevators along the north wall (doors drawn by the builder at these anchors).
	anchors["elevator_1"] = cell_center(39, 16) + Vector3(0.0, 0, 0.9)
	anchors["elevator_2"] = cell_center(43, 16) + Vector3(0.0, 0, 0.9)
	anchors["mini_dungeon"] = cell_center(48, 16) + Vector3(0.0, 0, 0.9)
	anchors["elevator_4"] = cell_center(52, 16) + Vector3(0.0, 0, 0.9)
	_sign("sign.elevator_rule", Vector3(43.5, 1.45, 16.2), 0.0, "poster", 0.8)
	_sign("sign.mini_dungeon", Vector3(48.5, 1.95, 16.2), 0.0, "sign", 0.85)
	_card("DNA-PLANT-OFFICE", cell_center(37, 17), 1.6, 0.3)
	_card("DNA-PLANT-OFFICE", cell_center(53, 17), 1.6, 0.3)
	anchors["bank_center"] = cell_center(45, 20)


# ---- Records basement ----------------------------------------------------------------------


func _furnish_records() -> void:
	var r: Rect2i = Rect2i(56, 4, 32, 20)
	_lamp_ring(r, 10, Color(0.6, 0.95, 0.7), 1.0)
	_sign("sign.records", Vector3(72.0, 1.8, 23.8), 180.0, "sign", 1.15)
	_sign("sign.filed_complaint", Vector3(80.0, 1.8, 23.8), 180.0, "sign", 1.0)  # the Filed Complaint of the old Records Basement, on the same wall (SR-7)
	# Long shelving rows (solid cabinet blocks) with gaps, like stacks in an archive.
	for row_z: int in [8, 12, 16]:
		for x0: int in [59, 71, 79]:
			var length: int = 8 if x0 == 59 else (6 if x0 == 71 else 6)
			for dx: int in range(length):
				_put(x0 + dx, row_z, Cell.SOLID)
	# Two coffins in the aisles, a card catalogue and paper towers at the far east end, ghost lamps between the stacks.
	for pos: Vector2i in [Vector2i(65, 14), Vector2i(76, 10)]:
		_prop("coffin", cell_center(pos.x, pos.y), 90.0 * float(_rng.randi() % 2), 0.9, 0.0)
		_blockers(cell_center(pos.x, pos.y) + Vector3(0, 0, -0.35), cell_center(pos.x, pos.y) + Vector3(0, 0, 0.35), 0.3, 0.4)
	_card("DNA-SHEET-CABINETS-02", cell_center(85, 6), 1.3, 0.5)
	_card("DNA-SHEET-CABINETS-04", cell_center(83, 6) + Vector3(-0.2, 0, 0), 1.3, 0.5)
	_card("DNA-PROP-PAPER", cell_center(86, 12), 1.4, 0.35)
	_card("DNA-PROP-PAPER", cell_center(58, 7), 1.2, 0.3)
	for point: Vector2 in [Vector2(70.5, 10.5), Vector2(70.5, 18.5), Vector2(78.5, 14.5)]:
		_lamp(Vector3(point.x, 0.0, point.y), 3, Color(0.6, 0.95, 0.7))
	chests["chest_records_0"] = cell_center(86, 22) + Vector3(0.0, 0.0, 0.2)
	chests["chest_records_1"] = cell_center(57, 5) + Vector3(0.0, 0.0, 0.1)
	anchors["records_center"] = cell_center(72, 14)


# ---- Executive floor -----------------------------------------------------------------------


## The executive floor is the forecourt of the Hall of Final Approvals: an open marble court, two dead topiaries and warm lamps at its sides, and the Hall's grand
## stair coming down to its north edge (the balustrade is left open there). The dungeon spot waits at the stair's foot.
func _furnish_executive() -> void:
	var r: Rect2i = Rect2i(36, 2, 18, 12)
	_wall_lamp(Vector3(35.5, 0.0, 13.5), 1, Color(1.0, 0.85, 0.6))
	_wall_lamp(Vector3(54.5, 0.0, 13.5), 2, Color(1.0, 0.85, 0.6))
	_wall_lamp(Vector3(35.5, 0.0, 6.5), 3, Color(1.0, 0.85, 0.6))
	_wall_lamp(Vector3(54.5, 0.0, 6.5), 1, Color(1.0, 0.85, 0.6))
	_sign("sign.executive", Vector3(45.0, 1.8, 13.8), 180.0, "sign", 1.1)
	_card("DNA-TREE-DEAD", cell_center(37, 3) + Vector3(0.2, 0, 0.2), 2.0, 0.4)
	_card("DNA-TREE-DEAD", cell_center(53, 3) + Vector3(-0.2, 0, 0.2), 2.0, 0.4)
	# The main dungeon: the foot of the Hall's stair on the north edge; the icon board stands beside it (no lettered plate over the spot).
	anchors["main_dungeon"] = cell_center(45, 2) + Vector3(0.0, 0, 0.9)
	_sign("sign.main_dungeon", Vector3(38.6, 1.75, 2.0), 0.0, "sign", 1.15)
	var stair_half: float = clampf(HALL_SIZE.x * 0.2, 3.0, 12.0) * 0.5
	for cx: int in range(int(floorf(HALL_CENTER.x - stair_half)), int(ceilf(HALL_CENTER.x + stair_half))):
		open_edges[Vector2i(cx, 1)] = true
	chests["chest_exec"] = cell_center(36, 3) + Vector3(0.6, 0.0, 0.2)
	anchors["exec_center"] = cell_center(45, 11)
	# The Stamp of Approval (the shrine of the old Executive Approach, SR-7) at the forecourt's east side: the hero stands at the anchor, the stamp just east of it.
	anchors["shrine"] = cell_center(51, 10)


# ---- Enemies -------------------------------------------------------------------------------


func _enemy(type: String, cell: Vector2i, patrol: float = 3.0) -> void:
	enemy_spawns.append({"type": type, "home": cell_center(cell.x, cell.y), "patrol": patrol})


func _enemies() -> void:
	# Cubicle Farm A: 2 managers + 1 intern + 1 courier. Farm B: manager, 2 interns, courier.
	_enemy("manager", Vector2i(10, 32), 4.0)
	_enemy("manager", Vector2i(26, 41), 4.0)
	_enemy("intern", Vector2i(18, 37), 4.0)
	_enemy("courier", Vector2i(8, 31), 5.0)
	_enemy("manager", Vector2i(70, 32), 4.0)
	_enemy("intern", Vector2i(62, 37), 4.0)
	_enemy("intern", Vector2i(80, 41), 4.0)
	_enemy("courier", Vector2i(75, 31), 5.0)
	# Records basement and the filing maze: tougher company deeper in.
	_enemy("manager", Vector2i(68, 18), 3.0)
	_enemy("intern", Vector2i(82, 18), 3.0)
	_enemy("courier", Vector2i(66, 10), 4.0)
	_enemy("intern", Vector2i(15, 19), 2.0)


# ---- Walls ---------------------------------------------------------------------------------


## Every void cell touching floor (including diagonally) becomes a wall (a knee-high balustrade in the builder), except the open edges.
func _finish_walls() -> void:
	var to_wall: Array[int] = []
	for cz: int in range(H):
		for cx: int in range(W):
			if cells[cz * W + cx] != Cell.VOID or open_edges.has(Vector2i(cx, cz)):
				continue
			var touches: bool = false
			for dz: int in range(-1, 2):
				for dx: int in range(-1, 2):
					var kind: Cell = cell_at(cx + dx, cz + dz)
					if kind == Cell.FLOOR or kind == Cell.SOLID:
						touches = true
			if touches:
				to_wall.append(cz * W + cx)
	for index: int in to_wall:
		cells[index] = Cell.WALL


# ---- Queries used by the scene and tests ---------------------------------------------------


## Flood fill over walkable cells from `from`; the set of reachable cells.
func reachable_from(from: Vector3) -> Dictionary:
	var start: Vector2i = world_to_cell(from)
	var seen: Dictionary = {}
	if not is_floor(start.x, start.y):
		return seen
	var queue: Array[Vector2i] = [start]
	seen[start] = true
	var head: int = 0
	while head < queue.size():
		var current: Vector2i = queue[head]
		head += 1
		for step: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var next: Vector2i = current + step
			if not seen.has(next) and is_floor(next.x, next.y):
				seen[next] = true
				queue.append(next)
	return seen
