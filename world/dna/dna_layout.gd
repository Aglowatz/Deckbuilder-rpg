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

const W: int = 90
const H: int = 64

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


## A static prop: a model (path relative to the pack folders - see DnaBuilder.MODELS), where and how.
class Prop:
	extends RefCounted
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
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func build() -> void:
	_rng.seed = 1291
	cells.resize(W * H)
	floors.resize(W * H)
	_rooms_and_corridors()
	_furnish_lobby()
	_furnish_breakroom()
	_furnish_farm("farm_a", Rect2i(2, 26, 32, 18), 33, 3)
	_furnish_farm("farm_b", Rect2i(56, 26, 32, 18), 77, 3)
	_furnish_mail_room()
	_furnish_filing_maze()
	_furnish_elevator_bank()
	_furnish_records()
	_furnish_executive()
	_enemies()
	_finish_walls()


# ---- Grid helpers --------------------------------------------------------------------------


static func cell_center(cx: int, cz: int) -> Vector3:
	return Vector3(float(cx) + 0.5, 0.0, float(cz) + 0.5)


static func world_to_cell(pos: Vector3) -> Vector2i:
	return Vector2i(int(floorf(pos.x)), int(floorf(pos.z)))


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


## A corridor / doorway: just carved floor that takes the floor look of `like`.
func _link(rect: Rect2i, floor_kind: Floor) -> void:
	_carve(rect, floor_kind)


# ---- Floor plan ----------------------------------------------------------------------------


func _rooms_and_corridors() -> void:
	_room("lobby", Rect2i(36, 46, 20, 14), Floor.TILE, "The Lobby", true)
	_room("breakroom", Rect2i(18, 48, 17, 12), Floor.LINO, "The Breakroom", true)
	_link(Rect2i(35, 52, 1, 3), Floor.LINO)
	_room("farm_a", Rect2i(2, 26, 32, 18), Floor.CARPET, "Cubicle Farm A")
	_room("farm_b", Rect2i(56, 26, 32, 18), Floor.CARPET, "Cubicle Farm B")
	_room("mail", Rect2i(36, 28, 18, 14), Floor.TILE, "The Mail Room")
	_room("maze", Rect2i(2, 4, 32, 18), Floor.CONCRETE, "The Filing Department")
	_room("bank", Rect2i(36, 16, 18, 8), Floor.TILE, "The Elevator Bank")
	_room("records", Rect2i(56, 4, 32, 20), Floor.CONCRETE, "The Records Basement")
	_room("exec", Rect2i(36, 2, 18, 12), Floor.EXEC, "The Executive Floor")
	# Corridors and doorways.
	_link(Rect2i(43, 42, 4, 4), Floor.TILE)   # lobby <-> mail room
	_link(Rect2i(24, 44, 3, 4), Floor.LINO)   # breakroom <-> farm A
	_link(Rect2i(34, 33, 2, 3), Floor.CARPET) # farm A <-> mail room
	_link(Rect2i(54, 33, 2, 3), Floor.CARPET) # mail room <-> farm B
	_link(Rect2i(43, 24, 4, 4), Floor.TILE)   # mail room <-> elevator bank
	_link(Rect2i(15, 22, 3, 4), Floor.CONCRETE) # farm A <-> filing maze
	_link(Rect2i(34, 17, 2, 3), Floor.CONCRETE) # filing maze <-> elevator bank
	_link(Rect2i(54, 18, 2, 3), Floor.CONCRETE) # elevator bank <-> records
	_link(Rect2i(43, 14, 4, 2), Floor.EXEC)   # elevator bank <-> executive floor
	_link(Rect2i(70, 24, 3, 2), Floor.CONCRETE) # farm B <-> records basement
	anchors["spawn"] = cell_center(45, 53)


# ---- Prop helpers --------------------------------------------------------------------------


func _prop(model: String, pos: Vector3, yaw: float = 0.0, model_scale: float = 1.0, radius: float = 0.0) -> Prop:
	var prop: Prop = Prop.new()
	prop.model = model
	prop.pos = pos
	prop.yaw = yaw
	prop.model_scale = model_scale
	prop.radius = radius
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


## A row of tube lights down the middle of a room (every `step` cells), on flicker groups 1-3.
func _tube_row(rect: Rect2i, step: int, rows: int = 1, color: Color = Color(0.72, 1.0, 0.82)) -> void:
	var group: int = 1
	for row: int in range(rows):
		var cz: float = float(rect.position.y) + (float(row) + 0.5) * float(rect.size.y) / float(rows)
		var cx: int = rect.position.x + step / 2
		while cx < rect.end.x:
			_light(Vector3(float(cx) + 0.5, 1.9, cz), group, color)
			group = group % 3 + 1
			cx += step


# Furniture scale: Kenney's kit is built for a taller world than our 0.68 m hero.
const F: float = 1.35


func _desk_set(pos: Vector3, yaw: float, screen: bool = true) -> void:
	_prop("desk", pos, yaw, F, 0.0)
	if screen:
		var forward: Vector3 = Vector3(sin(deg_to_rad(yaw)), 0.0, cos(deg_to_rad(yaw)))
		_prop("computerScreen", pos + Vector3(0, 0.38 * F, 0) + forward * 0.0, yaw, F * 0.9)
		_prop("computerKeyboard", pos + Vector3(0, 0.38 * F, 0) + forward * 0.22, yaw, F * 0.9)


## Circular blockers along a straight segment (for desks, partitions...).
func _blockers(a: Vector3, b: Vector3, radius: float, spacing: float = 0.45) -> void:
	var length: float = a.distance_to(b)
	var count: int = maxi(1, int(ceilf(length / spacing)))
	for i: int in range(count + 1):
		var point: Vector3 = a.lerp(b, float(i) / float(count))
		var blocker: Prop = Prop.new()
		blocker.model = ""
		blocker.pos = point
		blocker.radius = radius
		props.append(blocker)


func _partition(a: Vector3, b: Vector3) -> void:
	partitions.append(Vector4(a.x, a.z, b.x, b.z))
	_blockers(a, b, 0.2)


# ---- Lobby (hub, safe) ---------------------------------------------------------------------


func _furnish_lobby() -> void:
	var r: Rect2i = Rect2i(36, 46, 20, 14)
	_tube_row(r, 5, 2)
	# Reception desk across the north end, Dolores behind it.
	for i: int in range(6):
		var pos: Vector3 = cell_center(40 + i * 2, 49)
		_prop("desk", pos, 0.0, F)
		_blockers(pos + Vector3(-0.5, 0, 0), pos + Vector3(0.5, 0, 0), 0.32, 0.4)
	_prop("computerScreen", cell_center(41, 49) + Vector3(0, 0.5, 0), 0.0, F * 0.9)
	_prop("computerScreen", cell_center(45, 49) + Vector3(0, 0.5, 0), 0.0, F * 0.9)
	_prop("radio", cell_center(49, 49) + Vector3(0, 0.5, 0), 180.0, F)
	anchors["dolores"] = cell_center(44, 48)
	_sign("sign.lobby_main", Vector3(46.0, 1.7, 46.2), 0.0, "sign", 1.25)
	_sign("sign.motto", Vector3(40.0, 1.15, 46.2), 0.0, "poster", 0.9)
	_sign("sign.take_number", Vector3(51.5, 1.15, 46.2), 0.0, "poster", 0.9)
	_sign("sign.now_serving", Vector3(49.0, 1.7, 49.4), 180.0, "sign", 0.9)
	_sign("sign.fun_day", Vector3(55.8, 1.2, 52.5), 90.0, "poster", 0.95)
	# Seating by the south wall, plants in the corners.
	for x: int in [38, 41]:
		_prop("loungeSofa", cell_center(x, 57), 180.0, F, 0.5)
	_prop("pottedPlant", cell_center(37, 47), 0.0, F, 0.3)
	_prop("pottedPlant", cell_center(54, 47), 0.0, F, 0.3)
	_prop("pottedPlant", cell_center(54, 58), 0.0, F, 0.3)
	_prop("lampSquareFloor", cell_center(37, 58), 0.0, F, 0.15)
	_prop("rugRectangle", cell_center(45, 53), 0.0, 2.3)
	# Requisitions desk (vendor) on the east side.
	anchors["pip"] = cell_center(52, 53)
	_prop("desk", cell_center(52, 54) + Vector3(0, 0, 0.3), 0.0, F)
	_blockers(cell_center(51, 54), cell_center(53, 54), 0.35, 0.4)
	_prop("bookcaseClosedWide", cell_center(54, 52), 270.0, F, 0.4)
	_prop("cardboardBoxClosed", cell_center(54, 55), 20.0, F, 0.3)
	_sign("sign.requisitions", Vector3(52.5, 1.55, 52.0), 0.0, "sign", 0.9)
	# Elevator back to the surface (the exit) on the south wall.
	anchors["exit"] = cell_center(46, 58)
	_sign("sign.exit", Vector3(46.0, 1.7, 59.4), 180.0, "sign", 1.0)
	anchors["exit_door"] = cell_center(46, 59)
	_sign("poster.safety", Vector3(36.2, 1.15, 56.0), 270.0, "poster", 0.85)
	_sign("poster.synergy", Vector3(36.2, 1.15, 50.0), 270.0, "poster", 0.85)
	anchors["lobby_center"] = cell_center(45, 53)


# ---- Breakroom (hub, safe) -----------------------------------------------------------------


func _furnish_breakroom() -> void:
	var r: Rect2i = Rect2i(18, 48, 17, 12)
	_tube_row(r, 5, 2, Color(0.8, 1.0, 0.85))
	# Kitchen counter along the north wall: cabinets, sink, coffee machine, microwave, fridges.
	var counter: Array[String] = ["kitchenCabinet", "kitchenCabinet", "kitchenCabinet", "kitchenSink", "kitchenCabinet", "kitchenCabinet", "kitchenCabinet"]
	for i: int in range(counter.size()):
		var pos: Vector3 = cell_center(20 + i, 49) + Vector3(0, 0, -0.1)
		_prop(counter[i], pos, 0.0, F * 1.05, 0.0)
	_blockers(cell_center(20, 49) + Vector3(-0.4, 0, 0), cell_center(26, 49) + Vector3(0.4, 0, 0), 0.4, 0.45)
	_prop("kitchenCoffeeMachine", cell_center(22, 49) + Vector3(0, 0.45 * F * 1.05, -0.1), 0.0, F * 1.4)
	_prop("kitchenMicrowave", cell_center(24, 49) + Vector3(0, 0.45 * F * 1.05, -0.1), 0.0, F * 1.3)
	_prop("kitchenFridgeLarge", cell_center(28, 49), 0.0, F, 0.0)
	_prop("kitchenFridge", cell_center(30, 49), 0.0, F, 0.0)
	_blockers(cell_center(28, 49), cell_center(30, 49), 0.4, 0.45)
	anchors["coffee"] = cell_center(22, 50)
	anchors["barnaby"] = cell_center(21, 50)
	anchors["barnaby"] = cell_center(23, 50)
	_sign("sign.coffee", Vector3(22.5, 1.5, 48.2), 0.0, "poster", 0.8)
	_sign("memo.coffee", Vector3(24.5, 1.25, 48.2), 0.0, "memo", 0.8)
	_sign("memo.lunch", Vector3(29.0, 1.55, 48.2), 0.0, "memo", 0.8)
	# Tables and chairs.
	for table_x: int in [22, 27]:
		var table_pos: Vector3 = cell_center(table_x, 54)
		_prop("tableRound", table_pos + Vector3(0, 0, 0), 0.0, F, 0.6)
		for k: int in range(4):
			var angle: float = float(k) * PI * 0.5
			var offset: Vector3 = Vector3(cos(angle), 0, sin(angle)) * 0.85
			_prop("chair", table_pos + offset, rad_to_deg(-angle) + 90.0, F, 0.0)
	# The healing couch (an interactable spot): a long sofa and a rug in the SE corner.
	_prop("loungeSofaLong", cell_center(31, 57), 180.0, F, 0.0)
	_blockers(cell_center(30, 57) + Vector3(-0.2, 0, 0), cell_center(32, 57) + Vector3(0.2, 0, 0), 0.4, 0.45)
	_prop("rugRectangle", cell_center(30, 55), 0.0, 1.5)
	_prop("lampSquareFloor", cell_center(33, 58), 0.0, F, 0.15)
	_prop("pottedPlant", cell_center(19, 58), 0.0, F, 0.3)
	_prop("pottedPlant", cell_center(19, 49), 0.0, F, 0.3)
	anchors["heal"] = cell_center(31, 55)
	_sign("sign.heal_couch", Vector3(31.5, 1.5, 58.4), 180.0, "poster", 0.8)
	# Time clock on the west wall.
	anchors["time_clock"] = cell_center(19, 53)
	_sign("sign.time_clock", Vector3(18.2, 1.55, 53.5), 270.0, "poster", 0.8)
	_sign("poster.wellness", Vector3(18.2, 1.15, 56.5), 270.0, "poster", 0.85)
	_sign("poster.hang_in_there", Vector3(33.8, 1.15, 52.0), 90.0, "poster", 0.85)
	# Suggestion box by the doorway to the lobby.
	anchors["suggestion"] = cell_center(33, 51)
	_sign("sign.suggestion_box", Vector3(33.5, 1.5, 50.2), 0.0, "poster", 0.8)
	_prop("trashcan", cell_center(20, 58), 0.0, F, 0.25)
	anchors["breakroom_center"] = cell_center(26, 54)


# ---- Cubicle farms -------------------------------------------------------------------------


## A grid of 3x3 cubicles opening south onto 2-cell aisles. `farm_id` picks decor, `seed_x` the
## cell where its special cubicle goes. Aisle rows: the farm's first/last rows are left clear.
func _furnish_farm(farm_id: String, r: Rect2i, _unused: int, _unused2: int) -> void:
	_tube_row(r, 6, 3)
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
				_prop("candle_triple", home + Vector3(0.9, 0.0, -0.9), 0.0, 1.4, 0.0)
				_light(home + Vector3(0.9, 0.8, -0.9), 0, Color(1.0, 0.7, 0.35))
			else:
				_desk_set(home + Vector3(0, 0, -0.95), 0.0)
				_blockers(home + Vector3(-0.45, 0, -0.95), home + Vector3(0.45, 0, -0.95), 0.34, 0.4)
				_prop("chairDesk", home + Vector3(0.0, 0.0, -0.1), _rng.randf_range(150.0, 210.0), F, 0.0)
				if _rng.randf() < 0.25:
					_prop("plantSmall%d" % _rng.randi_range(1, 3), home + Vector3(-0.55, 0.38 * F, -1.0), _rng.randf() * 360.0, F * 1.1, 0.0)
				if _rng.randf() < 0.2:
					_prop("cardboardBoxOpen", home + Vector3(0.9, 0.0, 0.4), _rng.randf() * 360.0, F, 0.0)
			cubicle_index += 1
		# Aisle decor.
		if row == 0:
			_prop("pottedPlant", Vector3(float(r.position.x) + 1.0, 0.0, float(top + 4)), 0.0, F, 0.3)
	# Room dressing.
	var north_z: float = float(r.position.y) + 0.2
	var south_z: float = float(r.end.y) - 0.2
	if farm_id == "farm_a":
		_sign("sign.cubicle_farm_a", Vector3(float(r.position.x) + 8.0, 1.7, south_z + 0.0), 180.0, "sign", 1.1)
		_sign("poster.performance", Vector3(float(r.position.x) + 16.0, 1.15, south_z), 180.0, "poster", 0.9)
		_sign("memo.fun_day", Vector3(float(r.position.x) + 20.0, 1.2, south_z), 180.0, "memo", 0.85)
		_sign("memo.hr", Vector3(float(r.position.x) + 26.0, 1.2, south_z), 180.0, "memo", 0.85)
		_sign("poster.safety", Vector3(float(r.position.x) + 0.2, 1.15, float(r.position.y) + 8.0), 270.0, "poster", 0.85)
		# Water cooler by the corridor to the lobby side.
		_prop("kitchenFridgeSmall", Vector3(float(r.position.x) + 28.5, 0.0, north_z + 0.5), 0.0, F, 0.0)
		anchors["farm_a_center"] = cell_center(r.position.x + 15, r.position.y + 9)
		anchors["farm_a_aisle"] = cell_center(r.position.x + 15, r.position.y + 10)
	else:
		_sign("sign.cubicle_farm_b", Vector3(float(r.position.x) + 8.0, 1.7, south_z), 180.0, "sign", 1.1)
		_sign("memo.motto", Vector3(float(r.position.x) + 14.0, 1.2, south_z), 180.0, "memo", 0.85)
		_sign("memo.reorg", Vector3(float(r.position.x) + 20.0, 1.2, south_z), 180.0, "memo", 0.85)
		_sign("poster.hang_in_there", Vector3(float(r.position.x) + 26.0, 1.15, south_z), 180.0, "poster", 0.9)
		_sign("memo.parking", Vector3(float(r.position.x) + 30.8, 1.2, float(r.position.y) + 8.0), 90.0, "memo", 0.85)
		anchors["farm_b_center"] = cell_center(r.position.x + 15, r.position.y + 9)
		# The quiz master's corner office, in the south-east of farm B (walled off with partitions).
		var qx: float = float(r.end.x) - 6.0
		var qz: float = float(r.end.y) - 5.0
		_partition(Vector3(qx, 0, qz), Vector3(qx + 5.0, 0, qz))
		_partition(Vector3(qx, 0, qz), Vector3(qx, 0, qz + 2.2))
		_desk_set(Vector3(qx + 3.6, 0, qz + 1.4), 0.0)
		_blockers(Vector3(qx + 3.1, 0, qz + 1.4), Vector3(qx + 4.1, 0, qz + 1.4), 0.34, 0.4)
		_prop("bookcaseClosed", Vector3(qx + 4.8, 0, qz + 0.8), 270.0, F, 0.0)
		anchors["quiz"] = Vector3(qx + 2.4, 0.0, qz + 1.7)
		_sign("sign.quiz", Vector3(qx + 2.5, 1.5, qz + 0.1), 0.0, "sign", 0.95)
		# The haunted printer (an interactable) on the far west of farm B.
		anchors["printer"] = cell_center(r.position.x + 1, r.position.y + 16)
		_prop("kitchenStove", cell_center(r.position.x + 1, r.position.y + 16) + Vector3(0, 0, 0), 90.0, F * 0.95, 0.0)
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
	_tube_row(r, 5, 2, Color(0.75, 0.95, 1.0))
	_sign("sign.mailroom", Vector3(45.0, 1.7, 28.25), 0.0, "sign", 1.15)
	_sign("sign.puzzle", Vector3(45.0, 1.15, 28.25), 0.0, "poster", 0.85)
	# The routing terminal: a desk with three screens in the middle of the room.
	var terminal: Vector3 = cell_center(44, 35)
	anchors["puzzle"] = terminal + Vector3(1.0, 0, 1.0)
	for i: int in range(3):
		_prop("desk", terminal + Vector3(float(i) - 1.0, 0, 0), 0.0, F)
		_prop("computerScreen", terminal + Vector3(float(i) - 1.0, 0.5, -0.05), 0.0, F)
	_blockers(terminal + Vector3(-1.4, 0, 0), terminal + Vector3(1.4, 0, 0), 0.34, 0.4)
	_prop("chairDesk", terminal + Vector3(0.0, 0, 0.75), 180.0, F, 0.0)
	_light(terminal + Vector3(0, 1.0, 0.6), 0, Color(0.55, 1.0, 0.8))
	# Mail sorting shelves along the walls and boxes; wall tube pipes are drawn by the builder.
	for x: int in range(38, 52, 2):
		_prop("bookcaseOpen", cell_center(x, 29), 0.0, F, 0.0)
	_blockers(cell_center(38, 29), cell_center(51, 29), 0.35, 0.45)
	for x: int in [39, 41, 49, 51]:
		_prop("cardboardBoxClosed", cell_center(x, 40), _rng.randf() * 360.0, F, 0.3)
	_prop("cardboardBoxOpen", cell_center(52, 39), 40.0, F, 0.3)
	anchors["mail_center"] = cell_center(45, 38)


# ---- Filing maze ---------------------------------------------------------------------------


func _furnish_filing_maze() -> void:
	var r: Rect2i = Rect2i(2, 4, 32, 18)
	_tube_row(r, 5, 2, Color(0.7, 0.95, 0.75))
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
	# The entrance corridors cut through the outer cabinet ring; make sure they stay open.
	_carve(Rect2i(15, 22, 3, 1), Floor.CONCRETE)
	_carve(Rect2i(15, 20, 3, 2), Floor.CONCRETE)
	_carve(Rect2i(32, 17, 2, 3), Floor.CONCRETE)
	_carve(Rect2i(30, 17, 2, 3), Floor.CONCRETE)
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
	# The Rec Room alcove (Skylar's corner): the NW corner cell of the maze.
	var nw: Vector3 = cell_center(r.position.x, r.position.y) + Vector3(0.5, 0, 0.5)
	anchors["matching"] = nw + Vector3(0.0, 0.0, 0.2)
	_prop("loungeSofa", nw + Vector3(0.0, 0.0, -0.45), 0.0, F * 0.9, 0.0)
	_prop("televisionVintage", nw + Vector3(1.55, 0, 0.55), 270.0, F, 0.25)
	_prop("speaker", nw + Vector3(1.6, 0, -0.5), 270.0, F, 0.2)
	_light(nw + Vector3(0.8, 0.9, 0.4), 0, Color(0.85, 0.6, 1.0))
	_sign("sign.matching", Vector3(nw.x - 0.5, 1.5, nw.z - 0.9), 0.0, "poster", 0.8)
	# Maze lamps on the outside corners so the maze isn't pitch dark.
	for point: Vector2 in [Vector2(10, 8), Vector2(22, 8), Vector2(10, 17), Vector2(22, 17), Vector2(28, 12)]:
		_light(Vector3(point.x, 1.4, point.y), 2, Color(0.7, 1.0, 0.8))
	anchors["maze_entrance"] = cell_center(16, 21)


static func _edge(a: Vector2i, b: Vector2i) -> String:
	if a.x > b.x or (a.x == b.x and a.y > b.y):
		return "%d,%d-%d,%d" % [b.x, b.y, a.x, a.y]
	return "%d,%d-%d,%d" % [a.x, a.y, b.x, b.y]


# ---- Elevator bank -------------------------------------------------------------------------


func _furnish_elevator_bank() -> void:
	var r: Rect2i = Rect2i(36, 16, 18, 8)
	_tube_row(r, 5, 1, Color(0.8, 1.0, 0.9))
	_sign("sign.elevator_bank", Vector3(45.0, 1.8, 24.0), 180.0, "sign", 1.0)
	# Four elevators along the north wall (doors drawn by the builder at these anchors).
	anchors["elevator_1"] = cell_center(39, 16) + Vector3(0.0, 0, 0.9)
	anchors["elevator_2"] = cell_center(43, 16) + Vector3(0.0, 0, 0.9)
	anchors["mini_dungeon"] = cell_center(48, 16) + Vector3(0.0, 0, 0.9)
	anchors["elevator_4"] = cell_center(52, 16) + Vector3(0.0, 0, 0.9)
	_sign("sign.elevator_rule", Vector3(43.5, 1.45, 16.2), 0.0, "poster", 0.8)
	_sign("sign.mini_dungeon", Vector3(48.5, 1.95, 16.2), 0.0, "sign", 0.85)
	_sign("memo.records", Vector3(40.5, 1.2, 16.2), 0.0, "memo", 0.8)
	_prop("loungeChair", cell_center(37, 22), 90.0, F, 0.4)
	_prop("pottedPlant", cell_center(37, 17), 0.0, F, 0.3)
	_prop("pottedPlant", cell_center(53, 22), 0.0, F, 0.3)
	_prop("tableCoffee", cell_center(50, 21), 0.0, F, 0.4)
	anchors["bank_center"] = cell_center(45, 20)


# ---- Records basement ----------------------------------------------------------------------


func _furnish_records() -> void:
	var r: Rect2i = Rect2i(56, 4, 32, 20)
	_tube_row(r, 7, 2, Color(0.6, 0.95, 0.7))
	_sign("sign.records", Vector3(72.0, 1.8, 23.8), 180.0, "sign", 1.15)
	# Long shelving rows (solid cabinet blocks) with gaps, like stacks in an archive.
	for row_z: int in [8, 12, 16]:
		for x0: int in [59, 71, 79]:
			var length: int = 8 if x0 == 59 else (6 if x0 == 71 else 6)
			for dx: int in range(length):
				_put(x0 + dx, row_z, Cell.SOLID)
	# Coffins in the aisles and a records vault (a small crypt) at the far east end.
	for pos: Vector2i in [Vector2i(60, 10), Vector2i(65, 14), Vector2i(76, 10), Vector2i(84, 14), Vector2i(70, 20)]:
		_prop("coffin", cell_center(pos.x, pos.y), 90.0 * float(_rng.randi() % 2), 0.9, 0.0)
		_blockers(cell_center(pos.x, pos.y) + Vector3(0, 0, -0.35), cell_center(pos.x, pos.y) + Vector3(0, 0, 0.35), 0.3, 0.4)
	_prop("crypt-small", cell_center(85, 6), 180.0, 1.0, 0.0)
	_blockers(cell_center(85, 6) + Vector3(-0.5, 0, 0), cell_center(85, 6) + Vector3(0.5, 0, 0), 0.5, 0.45)
	for pos: Vector2i in [Vector2i(58, 6), Vector2i(66, 6), Vector2i(74, 6), Vector2i(82, 20), Vector2i(62, 21), Vector2i(86, 12)]:
		_prop("urn-square", cell_center(pos.x, pos.y), _rng.randf() * 360.0, 1.3, 0.2)
	for pos: Vector2i in [Vector2i(63, 5), Vector2i(79, 5), Vector2i(68, 22), Vector2i(83, 9)]:
		_prop("skull_candle", cell_center(pos.x, pos.y), _rng.randf() * 360.0, 1.6, 0.0)
		_light(cell_center(pos.x, pos.y) + Vector3(0, 0.5, 0), 0, Color(1.0, 0.65, 0.3))
	_prop("lantern-glass", cell_center(57, 22), 0.0, 1.6, 0.0)
	_sign("memo.records", Vector3(56.2, 1.2, 12.0), 270.0, "memo", 0.85)
	_sign("poster.hang_in_there", Vector3(87.8, 1.15, 16.0), 90.0, "poster", 0.9)
	chests["chest_records_0"] = cell_center(86, 22) + Vector3(0.0, 0.0, 0.2)
	chests["chest_records_1"] = cell_center(57, 5) + Vector3(0.0, 0.0, 0.1)
	anchors["records_center"] = cell_center(72, 14)


# ---- Executive floor -----------------------------------------------------------------------


func _furnish_executive() -> void:
	var r: Rect2i = Rect2i(36, 2, 18, 12)
	_tube_row(r, 6, 2, Color(1.0, 0.85, 0.6))
	_sign("sign.executive", Vector3(45.0, 1.8, 13.8), 180.0, "sign", 1.1)
	# A long boardroom table with chairs.
	for i: int in range(5):
		_prop("table", cell_center(40 + i * 2, 8), 0.0, F, 0.0)
	_blockers(cell_center(39, 8), cell_center(49, 8), 0.5, 0.45)
	for i: int in range(5):
		_prop("chair", cell_center(40 + i * 2, 6) + Vector3(0, 0, 0.25), 0.0, F, 0.0)
		_prop("chair", cell_center(40 + i * 2, 10) + Vector3(0, 0, -0.25), 180.0, F, 0.0)
	_prop("rugRectangle", cell_center(45, 8), 0.0, 3.4)
	for x: int in [37, 53]:
		_prop("lampSquareFloor", cell_center(x, 12), 0.0, F * 1.1, 0.15)
		_prop("pottedPlant", cell_center(x, 3), 0.0, F, 0.3)
	# The main dungeon's locked entrance: a big door on the north wall, "under renovation".
	anchors["main_dungeon"] = cell_center(45, 2) + Vector3(0.0, 0, 0.9)
	_sign("sign.main_dungeon", Vector3(45.0, 1.75, 2.0), 0.0, "sign", 1.15)
	chests["chest_exec"] = cell_center(36, 3) + Vector3(0.6, 0.0, 0.2)
	anchors["exec_center"] = cell_center(45, 11)


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


## Every void cell touching floor (including diagonally) becomes a wall.
func _finish_walls() -> void:
	var to_wall: Array[int] = []
	for cz: int in range(H):
		for cx: int in range(W):
			if cells[cz * W + cx] != Cell.VOID:
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
