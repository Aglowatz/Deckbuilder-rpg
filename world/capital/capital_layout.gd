class_name CapitalLayout
extends RefCounted
## The Capital's map as plain data (no scene nodes), so it can be unit-tested headless: a 1 m cell grid (ground /
## solid / void), districts, buildings, props, signs, rifts, anchors, hidden chests and enemy homes. `CapitalBuilder`
## turns it into meshes; `CapitalScene` makes it playable.
##
## Coordinates: metres, x east, z south, y up (the ground is flat). From the south: the Outskirts (the road from town,
## abandoned checkpoints, the first rifts, a hidden service-tunnel hatch), the city wall with the Approved Gate (a
## 10 m opening, closed by a barrier until the gate battle is won), then Checkpoint Plaza, and inside the walls the four
## broken districts (the Reek and Grave Row in the west, the Transit Yards and the Hungry Quarter in the east), Primm's
## Perfection (the facade town in the middle, behind its own low wall), the Castle Approach with the doors of Primm's
## Castle in the north, the Correction Ward (north-east) and Checkpoint Row (north-west). The resistance hideout, the
## Crease, is a separate underground hall far to the south (reached by hatches and ladders, never walked to).

const W: int = 120
const H: int = 126
## The y (z) of the gate wall's rows and the gate opening's x range (inclusive cells).
const WALL_Z0: int = 60
const WALL_Z1: int = 63
const GATE_X0: int = 55
const GATE_X1: int = 64

enum Cell { VOID, GROUND, SOLID }
enum Floor { NONE, GRAVEL, ROAD, PLAZA, LAWN, GRAY, SOIL, METAL, TILE, HUB, GRASS, DEAD }


class Building:
	extends RefCounted
	var rect: Rect2 = Rect2()
	var height: float = 5.0
	## "house" (identical facade house), "ruin", "factory", "stall", "shop" (painted facade storefront), "crypt",
	## "hall", "tower", "wall", "ward", "castle", "hut".
	var style: String = "ruin"
	## Lean in degrees (crumbling buildings tilt a little).
	var lean: float = 0.0
	var variant: int = 0
	var tint: Color = Color.WHITE
	## Which of the broken-service districts it belongs to ("" = none) - freed districts repair/re-light it.
	var district: String = ""


class Prop:
	extends RefCounted
	var kind: String = ""
	var pos: Vector3 = Vector3.ZERO
	var yaw: float = 0.0
	var model_scale: float = 1.0
	## Blocks movement within this radius (0 = decoration only).
	var radius: float = 0.0
	var variant: int = 0
	var district: String = ""


class Sign:
	extends RefCounted
	var key: String = ""
	var pos: Vector3 = Vector3.ZERO
	var yaw: float = 0.0
	var size: float = 1.0
	## "sign" (post sign), "poster" (framed), "banner" (a hung decree), "wall" (painted on a wall).
	var style: String = "sign"


class Area:
	extends RefCounted
	var id: String = ""
	var title: String = ""
	var rect: Rect2i = Rect2i()


class Rift:
	extends RefCounted
	var id: String = ""
	var pos: Vector2 = Vector2.ZERO
	var radius: float = 1.8
	var big: bool = false
	## Sealable rifts can be closed (after beating their guardian) for a reward; big ones stay until Primm falls.
	var sealable: bool = false
	## Gold / item / card / equipment for sealing it.
	var reward: Dictionary = {}


var cells: PackedByteArray = PackedByteArray()
var floors: PackedByteArray = PackedByteArray()
var areas: Array[Area] = []
var buildings: Array[Building] = []
var props: Array[Prop] = []
var signs: Array[Sign] = []
var rifts: Array[Rift] = []
var anchors: Dictionary = {}
var chests: Dictionary = {}
var enemy_spawns: Array[Dictionary] = []
## Static obstacles (x, z, radius), indexed by the builder.
var obstacles: Array[Vector3] = []
## Where the gate barrier stands (circles that block the opening until the gate is open): [Vector3(x, z, radius)].
var gate_blockers: Array[Vector3] = []
## Cracks in the ground: [{pos: Vector2, yaw: float, length: float}].
var cracks: Array[Dictionary] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func build() -> void:
	_rng.seed = 1010
	cells.resize(W * H)
	floors.resize(W * H)
	_ground()
	_areas()
	_anchors()
	_chests()
	_rifts()
	_walls_and_gate()
	_facade()
	_reek()
	_grave_row()
	_transit_yards()
	_hungry_quarter()
	_approach()
	_checkpoint_row()
	_ward()
	_outskirts()
	_plaza()
	_crease()
	_street_lamps()
	_enemies()
	_cracks()
	_index_obstacles()


# ---- Grid helpers ----------------------------------------------------------------------------------


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


func is_ground_cell(cx: int, cz: int) -> bool:
	return cell_at(cx, cz) == Cell.GROUND


func cell_of(x: float, z: float) -> Vector2i:
	return Vector2i(int(floorf(x)), int(floorf(z)))


func _set_cells(rect: Rect2i, cell: Cell, floor_kind: Floor = Floor.NONE) -> void:
	for cz: int in range(rect.position.y, rect.end.y):
		for cx: int in range(rect.position.x, rect.end.x):
			if in_bounds(cx, cz):
				cells[cz * W + cx] = cell
				if floor_kind != Floor.NONE:
					floors[cz * W + cx] = floor_kind


func _floor_rect(rect: Rect2i, floor_kind: Floor) -> void:
	for cz: int in range(rect.position.y, rect.end.y):
		for cx: int in range(rect.position.x, rect.end.x):
			if in_bounds(cx, cz) and cells[cz * W + cx] != Cell.VOID:
				floors[cz * W + cx] = floor_kind


func walkable_cell_count() -> int:
	var count: int = 0
	for value: int in cells:
		if value == Cell.GROUND:
			count += 1
	return count


# ---- Ground and areas --------------------------------------------------------------------------------


func _ground() -> void:
	_set_cells(Rect2i(2, 64, 116, 30), Cell.GROUND, Floor.GRAVEL)       # the Outskirts (x 2..117, z 64..93)
	_set_cells(Rect2i(2, 2, 116, 58), Cell.GROUND, Floor.ROAD)          # the city inside the wall (z 2..59)
	_set_cells(Rect2i(GATE_X0, WALL_Z0, GATE_X1 - GATE_X0 + 1, WALL_Z1 - WALL_Z0 + 1), Cell.GROUND, Floor.ROAD)  # the gate
	_set_cells(Rect2i(4, 100, 37, 21), Cell.GROUND, Floor.HUB)          # the Crease (x 4..40, z 100..120)
	_floor_rect(Rect2i(2, 64, 116, 30), Floor.GRAVEL)
	_floor_rect(Rect2i(42, 45, 37, 15), Floor.PLAZA)                    # Checkpoint Plaza
	_floor_rect(Rect2i(43, 16, 35, 28), Floor.LAWN)                     # inside the facade
	_floor_rect(Rect2i(57, 16, 6, 28), Floor.PLAZA)                     # the facade's avenue
	_floor_rect(Rect2i(2, 36, 40, 24), Floor.SOIL)                      # the Reek
	_floor_rect(Rect2i(2, 16, 40, 20), Floor.GRAY)                      # Grave Row
	_floor_rect(Rect2i(79, 36, 39, 24), Floor.METAL)                    # the Transit Yards
	_floor_rect(Rect2i(79, 16, 39, 20), Floor.TILE)                     # the Hungry Quarter
	_floor_rect(Rect2i(28, 2, 65, 14), Floor.PLAZA)                     # the Castle Approach
	_floor_rect(Rect2i(93, 2, 25, 14), Floor.GRAY)                      # the Correction Ward


func _add_area(id: String, title: String, rect: Rect2i) -> void:
	var area: Area = Area.new()
	area.id = id
	area.title = title
	area.rect = rect
	areas.append(area)


func _areas() -> void:
	_add_area("crease", "The Crease", Rect2i(4, 100, 37, 21))
	_add_area("gate", "The Approved Gate", Rect2i(GATE_X0 - 6, 56, 22, 12))
	_add_area("plaza", "Checkpoint Plaza", Rect2i(42, 45, 37, 15))
	_add_area("perfection", "Primm's Perfection", Rect2i(42, 15, 37, 30))
	_add_area("reek", "The Reek", Rect2i(2, 36, 40, 24))
	_add_area("grave", "Grave Row", Rect2i(2, 16, 40, 20))
	_add_area("transit", "The Transit Yards", Rect2i(79, 36, 39, 24))
	_add_area("hungry", "The Hungry Quarter", Rect2i(79, 16, 39, 20))
	_add_area("approach", "The Castle Approach", Rect2i(28, 2, 65, 14))
	_add_area("ward", "The Correction Ward", Rect2i(93, 2, 25, 14))
	_add_area("yard", "Checkpoint Row", Rect2i(2, 2, 26, 14))
	_add_area("outskirts", "The Outskirts", Rect2i(2, 64, 116, 30))


func area_at(x: float, z: float) -> Area:
	var cell: Vector2i = cell_of(x, z)
	for area: Area in areas:
		if area.rect.has_point(cell):
			return area
	return null


# ---- Anchors, chests, rifts ------------------------------------------------------------------------------


func _anchor(anchor_name: String, x: float, z: float) -> void:
	anchors[anchor_name] = Vector3(x, 0.0, z)


func _anchors() -> void:
	# The Outskirts.
	_anchor("spawn", 60.0, 89.0)
	_anchor("exit", 60.0, 92.0)
	_anchor("camp", 50.0, 88.0)
	_anchor("gate_captain", 60.0, 67.0)
	_anchor("guard_height", 52.0, 68.0)
	_anchor("guard_queue", 68.0, 68.0)
	_anchor("tunnel_in", 7.0, 72.0)
	_anchor("checkpoint_a", 28.0, 84.0)
	_anchor("checkpoint_b", 95.0, 82.0)
	_anchor("queue_sign", 60.0, 76.0)
	# The gate and Checkpoint Plaza.
	_anchor("gate_inside", 60.0, 57.5)
	_anchor("exit_booth", 67.0, 53.0)
	_anchor("complaint_1", 47.0, 52.0)
	_anchor("manhole", 45.0, 57.0)
	_anchor("plaza_statue", 60.0, 50.0)
	_anchor("guard_in_1", 53.0, 57.0)
	_anchor("guard_in_2", 67.0, 57.0)
	_anchor("net_plaza", 55.0, 52.0)
	# Primm's Perfection.
	_anchor("facade_gate", 60.0, 44.5)
	_anchor("fountain", 60.0, 30.0)
	_anchor("complaint_2", 62.0, 41.0)
	_anchor("portrait_f1", 54.5, 42.0)
	_anchor("portrait_f2", 62.5, 33.0)
	_anchor("portrait_f3", 60.0, 18.0)
	_anchor("speaker_1", 56.0, 36.0)
	_anchor("speaker_2", 64.0, 26.0)
	_anchor("speaker_3", 59.0, 43.0)
	for index: int in range(_facade_citizen_spots().size()):
		_anchor("citizen_%d" % (index + 1), _facade_citizen_spots()[index].x, _facade_citizen_spots()[index].y)
	_anchor("door_1", 49.0, 37.0)
	_anchor("door_2", 71.0, 37.0)
	_anchor("door_3", 49.0, 25.0)
	_anchor("door_4", 71.0, 25.0)
	# The Reek (Refusemancers).
	_anchor("gus", 20.0, 44.0)
	_anchor("heap_1", 9.0, 40.0)
	_anchor("heap_2", 31.0, 55.0)
	_anchor("heap_3", 14.0, 56.5)
	_anchor("sick_patch", 29.0, 42.0)
	_anchor("seed", 36.0, 49.0)
	_anchor("net_reek", 35.0, 42.0)
	# Grave Row (Necrocrats).
	_anchor("tilda", 24.0, 29.0)
	_anchor("permit_window", 14.0, 23.0)
	_anchor("stamp", 7.0, 18.0)
	_anchor("marrow_plot", 32.0, 22.0)
	_anchor("net_grave", 35.0, 27.0)
	# The Transit Yards (Beefcakes).
	_anchor("bram", 92.0, 50.0)
	_anchor("wheel_1", 99.0, 42.0)
	_anchor("wheel_2", 109.0, 53.0)
	_anchor("wheel_3", 96.0, 57.0)
	_anchor("cable", 112.0, 40.0)
	_anchor("net_transit", 88.0, 44.0)
	# The Hungry Quarter (Gourmands).
	_anchor("odile", 96.0, 28.0)
	_anchor("recipe_1", 86.0, 20.0)
	_anchor("recipe_2", 111.0, 22.0)
	_anchor("recipe_3", 101.0, 33.0)
	_anchor("dispenser", 88.0, 30.0)
	_anchor("net_hungry", 90.0, 26.0)
	# The Castle Approach, the Ward and Checkpoint Row.
	_anchor("castle_door", 60.0, 5.5)
	_anchor("net_approach", 60.0, 10.0)
	_anchor("portrait_a1", 45.0, 8.0)
	_anchor("portrait_a2", 75.0, 8.0)
	_anchor("portrait_a3", 52.0, 12.0)
	_anchor("approach_sign", 66.0, 12.0)
	_anchor("ward_window", 101.0, 11.0)
	_anchor("ward_patient", 110.0, 7.0)
	_anchor("ward_speaker", 98.0, 5.0)
	_anchor("yard_sign", 14.0, 11.0)
	# The Crease (the hub): everything is underground, south of the world.
	_anchor("crease_spawn", 22.0, 116.0)
	_anchor("rift_station", 28.0, 112.0)
	_anchor("mabbit", 14.0, 106.0)
	_anchor("fig", 31.0, 106.0)
	_anchor("fig_crate", 36.0, 110.0)
	_anchor("heal", 22.0, 104.0)
	_anchor("ladder_up", 7.0, 112.0)
	_anchor("tunnel_out", 38.0, 114.0)
	
	for index: int in range(NETWORK_DESTINATIONS.size()):
		_anchor("shaft_" + NETWORK_DESTINATIONS[index], 9.0 + 5.0 * float(index), 118.5)


## The service-tunnel network's destinations: shaft id -> the street anchor it surfaces at.
const NETWORK_DESTINATIONS: Array[String] = ["plaza", "reek", "grave", "hungry", "transit", "approach"]


func _facade_citizen_spots() -> Array[Vector2]:
	return [Vector2(49.0, 35.0), Vector2(71.0, 35.0), Vector2(55.5, 29.0), Vector2(64.5, 29.0), Vector2(49.0, 23.0), Vector2(71.0, 23.0), Vector2(55.5, 41.5), Vector2(64.5, 41.0), Vector2(60.0, 26.0)] as Array[Vector2]


func _chests() -> void:
	chests = {
		"chest_wreck": Vector3(14.0, 0.0, 89.0),
		"chest_rock": Vector3(113.0, 0.0, 70.0),
		"chest_reek": Vector3(5.0, 0.0, 52.0),
		"chest_crypt": Vector3(5.0, 0.0, 21.0),
		"chest_cellar": Vector3(114.0, 0.0, 18.0),
		"chest_wheel": Vector3(114.0, 0.0, 56.0),
		"chest_lane": Vector3(45.0, 0.0, 13.5),
		"chest_corner": Vector3(90.0, 0.0, 3.5),
		"chest_ward": Vector3(115.0, 0.0, 4.0),
		# Polish round: two behind the facade houses, two in the Crease, one in the ward's far end, one in the farthest corner of Checkpoint Row.
		"chest_facade_back": Vector3(75.6, 0.0, 16.8),
		"chest_facade_west": Vector3(43.8, 0.0, 22.2),
		"chest_crease_e": Vector3(40.2, 0.0, 100.8),
		"chest_crease_w": Vector3(4.8, 0.0, 100.8),
		"chest_ward_n": Vector3(95.4, 0.0, 8.4),
		"chest_yard_corner": Vector3(2.4, 0.0, 2.4),
	}


func _add_rift(id: String, x: float, z: float, radius: float, big: bool, sealable: bool, reward: Dictionary = {}) -> void:
	var rift: Rift = Rift.new()
	rift.id = id
	rift.pos = Vector2(x, z)
	rift.radius = radius
	rift.big = big
	rift.sealable = sealable
	rift.reward = reward
	rifts.append(rift)
	_anchor("rift_" + id, x, z)
	if sealable:
		_anchor("seal_" + id, x + radius + 1.6, z + 0.4)


func _rifts() -> void:
	for entry: Dictionary in CapitalRifts.all():
		_add_rift(str(entry["id"]), float(entry["x"]), float(entry["z"]), float(entry["radius"]), bool(entry["big"]), bool(entry["sealable"]), entry["reward"] as Dictionary)


# ---- Props / buildings / signs helpers ----------------------------------------------------------------------



func _prop(kind: String, x: float, z: float, yaw: float = 0.0, model_scale: float = 1.0, radius: float = 0.0, variant: int = 0, district: String = "") -> Prop:
	var prop: Prop = Prop.new()
	prop.kind = kind
	prop.pos = Vector3(x, 0.0, z)
	prop.yaw = yaw
	prop.model_scale = model_scale
	prop.radius = radius
	prop.variant = variant
	prop.district = district
	props.append(prop)
	return prop


func _sign(key: String, x: float, z: float, yaw: float = 0.0, size: float = 1.0, style: String = "sign") -> void:
	var sign_data: Sign = Sign.new()
	sign_data.key = key
	sign_data.pos = Vector3(x, 0.0, z)
	sign_data.yaw = yaw
	sign_data.size = size
	sign_data.style = style
	signs.append(sign_data)


## A building: marks its cells SOLID (never over an anchor) and records it for the builder.
func _building(style: String, x: float, z: float, w: float, d: float, height: float, lean: float = 0.0, district: String = "", variant: int = 0) -> Building:
	var building: Building = Building.new()
	building.style = style
	building.rect = Rect2(x, z, w, d)
	building.height = height
	building.lean = lean
	building.district = district
	building.variant = variant
	buildings.append(building)
	_set_cells(Rect2i(int(floorf(x)), int(floorf(z)), int(ceilf(x + w)) - int(floorf(x)), int(ceilf(z + d)) - int(floorf(z))), Cell.SOLID)
	return building


func _clear_of_anchors(x: float, z: float, w: float, d: float, margin: float) -> bool:
	var rect: Rect2 = Rect2(x - margin, z - margin, w + margin * 2.0, d + margin * 2.0)
	for key: Variant in anchors.keys():
		var pos: Vector3 = anchors[key] as Vector3
		if rect.has_point(Vector2(pos.x, pos.z)):
			return false
	for rift: Rift in rifts:
		if rect.grow(rift.radius + 1.5).has_point(rift.pos):
			return false
	for chest: Variant in chests.values():
		if rect.has_point(Vector2((chest as Vector3).x, (chest as Vector3).z)):
			return false
	return true


## A grid of buildings across `area`: every `step` metres, skipping where something important stands and a few at random
## (those become open ground, so the streets are irregular).
func _block_grid(area: Rect2, step: Vector2, size: Vector2, style: String, district: String, skip_chance: float, height_range: Vector2, lean: float = 0.0) -> void:
	var x: float = area.position.x
	while x + size.x <= area.end.x:
		var z: float = area.position.y
		while z + size.y <= area.end.y:
			var offset_x: float = _rng.randf_range(-1.0, 1.0)
			var offset_z: float = _rng.randf_range(-0.8, 0.8)
			var bx: float = floorf(x + offset_x)
			var bz: float = floorf(z + offset_z)
			var skipped: bool = _rng.randf() < skip_chance
			var tall: float = _rng.randf_range(height_range.x, height_range.y)
			var tilt: float = _rng.randf_range(-lean, lean)
			if not skipped and _clear_of_anchors(bx, bz, size.x, size.y, 3.0):
				_building(style, bx, bz, size.x, size.y, tall, tilt, district, _rng.randi() % 3)
			z += step.y
		x += step.x


# ---- The wall and the gate --------------------------------------------------------------------------------------


func _walls_and_gate() -> void:
	# The city wall: rows 60..63 across the whole width except the gate opening; towers frame the opening.
	_building("wall", 2.0, float(WALL_Z0), float(GATE_X0 - 2), float(WALL_Z1 - WALL_Z0 + 1), 7.0, 0.0, "", 0)
	_building("wall", float(GATE_X1 + 1), float(WALL_Z0), float(118 - GATE_X1 - 1), float(WALL_Z1 - WALL_Z0 + 1), 7.0, 0.0, "", 0)
	_building("tower", float(GATE_X0 - 5), float(WALL_Z0 - 1), 5.0, 6.0, 11.0, 0.0, "", 0)
	_building("tower", float(GATE_X1 + 1), float(WALL_Z0 - 1), 5.0, 6.0, 11.0, 0.0, "", 1)
	# The barrier that closes the opening: circles along the gap, removed when the gate battle is won.
	var gx: float = float(GATE_X0) + 0.5
	while gx <= float(GATE_X1) + 1.0:
		gate_blockers.append(Vector3(gx, float(WALL_Z0) + 1.0, 1.15))
		gx += 1.4
	_sign("sign.gate_main", 60.0, float(WALL_Z0) - 1.5, 0.0, 1.4, "banner")
	_sign("sign.gate_requirements", 55.0, 65.0, 0.0, 1.0, "sign")
	_sign("sign.gate_exit", 65.0, 65.0, 0.0, 1.0, "sign")
	_sign("sign.gate_height", 50.5, 66.0, 0.0, 0.9, "sign")
	_sign("sign.gate_inside", 60.0, float(WALL_Z1) + 2.5, 180.0, 1.2, "banner")
	_sign("sign.gate_exit_inside", 66.5, 56.0, 180.0, 0.9, "sign")
	# Walls around the whole city, drawn as scenery (the void already keeps you in).
	_prop("gate_barrier", 60.0, float(WALL_Z0) + 1.0, 0.0, 1.0, 0.0)


# ---- Primm's Perfection (the facade town) -------------------------------------------------------------------------


func _facade() -> void:
	# The low white wall around the showcase: x 42..78, z 15..44, with a 6 m entrance in the south (x 57..62).
	_building("wall", 42.0, 15.0, 37.0, 1.0, 1.4, 0.0, "facade", 1)
	_building("wall", 42.0, 15.0, 1.0, 30.0, 1.4, 0.0, "facade", 1)
	_building("wall", 78.0, 15.0, 1.0, 30.0, 1.4, 0.0, "facade", 1)
	_building("wall", 42.0, 44.0, 15.0, 1.0, 1.4, 0.0, "facade", 1)
	_building("wall", 63.0, 44.0, 16.0, 1.0, 1.4, 0.0, "facade", 1)
	_prop("facade_arch", 60.0, 44.5, 0.0, 1.0, 0.0)
	# Sixteen identical houses: 4 columns x 4 rows, two each side of the avenue; the four middle-row ones nearest the
	# avenue are painted storefronts instead (doors that do not open).
	var xs: Array[float] = [44.0, 50.0, 66.0, 72.0]
	var zs: Array[float] = [18.0, 24.0, 30.0, 36.0]
	var shop_index: int = 0
	for column: int in range(xs.size()):
		for row: int in range(zs.size()):
			var is_shop: bool = (column == 1 or column == 2) and row == 3
			if is_shop:
				shop_index += 1
			var house: Building = _building("shop" if is_shop else "house", xs[column], zs[row], 4.0, 4.0, 3.4 if not is_shop else 3.8, 0.0, "facade", shop_index)
			house.tint = Color.WHITE
	# Regulation lawns, hedges, a fountain with a golden statue of Primm in the avenue.
	_prop("fountain", 60.0, 30.0, 0.0, 1.0, 2.2)
	for hedge_z: float in [20.0, 26.0, 32.0, 38.0]:
		_prop("hedge", 55.0, hedge_z + 2.0, 90.0, 1.0, 0.0)
		_prop("hedge", 65.0, hedge_z + 2.0, 90.0, 1.0, 0.0)
	for lamp_z: float in [20.0, 28.0, 36.0, 42.0]:
		_prop("lamp_perfect", 58.0, lamp_z, 0.0, 1.0, 0.25)
		_prop("lamp_perfect", 62.0, lamp_z, 0.0, 1.0, 0.25)
	_prop("statue_primm", 60.0, 22.0, 180.0, 1.5, 1.2)
	_prop("statue_primm", 46.0, 42.0, 150.0, 1.0, 0.7)
	_prop("statue_primm", 74.0, 42.0, 210.0, 1.0, 0.7)
	for portrait: String in ["portrait_f1", "portrait_f2", "portrait_f3"]:
		var anchor_pos: Vector3 = anchors[portrait] as Vector3
		_prop("portrait", anchor_pos.x, anchor_pos.z, 0.0, 1.0, 0.45, 0)
	for speaker: String in ["speaker_1", "speaker_2", "speaker_3"]:
		var speaker_pos: Vector3 = anchors[speaker] as Vector3
		_prop("loudspeaker", speaker_pos.x, speaker_pos.z, 0.0, 1.0, 0.3)
	_prop("complaint_box", 62.0, 41.0, 0.0, 1.0, 0.35)
	_prop("bench", 54.0, 33.0, 90.0, 1.0, 0.0)
	_prop("bench", 66.0, 33.0, 270.0, 1.0, 0.0)
	_sign("sign.facade_welcome", 60.0, 45.5, 0.0, 1.3, "banner")
	_sign("sign.facade_hats", 56.0, 41.0, 0.0, 0.8, "sign")
	_sign("sign.facade_spontaneity", 64.0, 33.5, 0.0, 0.8, "sign")
	_sign("sign.facade_smile", 56.0, 24.0, 0.0, 0.8, "sign")
	_sign("sign.facade_lawns", 52.0, 38.5, 0.0, 0.7, "sign")
	_sign("sign.facade_hedges", 68.0, 22.0, 0.0, 0.7, "sign")
	_sign("sign.facade_queue", 64.0, 20.0, 0.0, 0.7, "sign")
	_sign("sign.facade_loudspeaker", 60.0, 40.0, 0.0, 0.7, "sign")
	_sign("sign.facade_shop_1", 52.0, 40.0, 0.0, 0.9, "wall")
	_sign("sign.facade_shop_2", 68.0, 40.0, 0.0, 0.9, "wall")
	_sign("sign.facade_back", 60.0, 16.8, 0.0, 0.9, "wall")


# ---- The Reek (Refusemancers: garbage hidden behind the facade) -----------------------------------------------------


func _reek() -> void:
	_block_grid(Rect2(3.0, 37.0, 34.0, 22.0), Vector2(12.0, 11.0), Vector2(7.0, 6.0), "ruin", "refusemancer", 0.25, Vector2(3.0, 6.0), 4.0)
	for index: int in range(18):
		var x: float = _rng.randf_range(4.0, 36.0)
		var z: float = _rng.randf_range(38.0, 58.0)
		if _clear_of_anchors(x - 1.2, z - 1.2, 2.4, 2.4, 2.5) and cell_at(int(x), int(z)) == Cell.GROUND:
			_prop("junk_pile", x, z, _rng.randf_range(0.0, 360.0), _rng.randf_range(0.8, 1.7), 1.3, index % 3, "refusemancer")
	for heap_anchor: String in ["heap_1", "heap_2", "heap_3"]:
		var pos: Vector3 = anchors[heap_anchor] as Vector3
		_prop("compost_heap", pos.x, pos.z, 0.0, 1.0, 0.0, 0, "refusemancer")
	var patch: Vector3 = anchors["sick_patch"] as Vector3
	_prop("sick_patch", patch.x, patch.z, 0.0, 1.0, 0.0, 0, "refusemancer")
	var gus_pos: Vector3 = anchors["gus"] as Vector3
	_prop("stall_shack", gus_pos.x + 2.5, gus_pos.z - 1.0, 0.0, 1.0, 1.4)
	var seed_pos: Vector3 = anchors["seed"] as Vector3
	_prop("seed_jar", seed_pos.x, seed_pos.z, 0.0, 1.0, 0.0)
	_sign("sign.reek_main", 12.0, 38.0, 0.0, 1.1, "banner")
	_sign("sign.reek_untidy", 18.0, 41.0, 0.0, 0.9, "sign")
	_sign("sign.reek_compost_ban", 26.0, 47.0, 0.0, 0.9, "sign")
	_sign("sign.reek_behind_facade", 34.0, 57.0, 0.0, 0.9, "sign")
	_sign("sign.reek_sick_patch", 29.0, 44.0, 0.0, 0.8, "sign")
	_sign("sign.net_reek", 35.0, 40.0, 0.0, 0.7, "sign")


# ---- Grave Row (Necrocrats: the permit-locked cemetery) ---------------------------------------------------------------


func _grave_row() -> void:
	_block_grid(Rect2(3.0, 17.0, 34.0, 18.0), Vector2(13.0, 11.0), Vector2(6.0, 6.0), "crypt", "necrocrat", 0.35, Vector2(3.0, 5.5), 2.0)
	# Rows of graves (small obstacles) in the middle of the district.
	for row: int in range(3):
		for column: int in range(8):
			var x: float = 4.0 + float(column) * 1.8 + (24.0 if column > 5 else 0.0) * 0.0
			var z: float = 31.0 + float(row) * 1.6
			if _clear_of_anchors(x - 0.4, z - 0.4, 0.8, 0.8, 1.6) and cell_at(int(x), int(z)) == Cell.GROUND:
				_prop("grave", x, z, 0.0, 1.0, 0.45, (row + column) % 3, "necrocrat")
	var tilda_pos: Vector3 = anchors["tilda"] as Vector3
	_prop("parlor", tilda_pos.x + 3.0, tilda_pos.z - 1.5, 0.0, 1.0, 1.8)
	var permit: Vector3 = anchors["permit_window"] as Vector3
	_prop("permit_office", permit.x, permit.z - 1.4, 0.0, 1.0, 1.6)
	_prop("notary_booth", 7.0, 17.0, 0.0, 1.0, 0.9)
	var plot: Vector3 = anchors["marrow_plot"] as Vector3
	_prop("family_plot", plot.x, plot.z, 0.0, 1.0, 0.0)
	_prop("manhole", 35.0, 27.0, 0.0, 1.0, 0.0)
	_sign("sign.grave_main", 12.0, 18.0, 0.0, 1.1, "banner")
	_sign("sign.grave_permit", 16.0, 21.5, 0.0, 0.9, "sign")
	_sign("sign.grave_queue", 11.0, 25.0, 0.0, 0.8, "sign")
	_sign("sign.grave_waiting", 26.0, 32.0, 0.0, 0.8, "sign")
	_sign("sign.grave_plot", 31.0, 24.0, 0.0, 0.8, "sign")
	_sign("sign.net_grave", 35.0, 29.0, 0.0, 0.7, "sign")


# ---- The Transit Yards (Beefcakes: the energy wheels and the dead lines) -----------------------------------------------


func _transit_yards() -> void:
	_block_grid(Rect2(84.0, 37.0, 32.0, 22.0), Vector2(14.0, 11.0), Vector2(8.0, 6.0), "factory", "beefcake", 0.4, Vector2(3.5, 6.0), 2.0)
	for wheel: String in ["wheel_1", "wheel_2", "wheel_3"]:
		var pos: Vector3 = anchors[wheel] as Vector3
		_prop("energy_wheel", pos.x, pos.z - 3.0, 0.0, 1.0, 2.6, 0, "beefcake")
	var bram_pos: Vector3 = anchors["bram"] as Vector3
	_prop("crate_stack", bram_pos.x - 2.0, bram_pos.z - 1.0, 0.0, 1.0, 1.0)
	_building("tram", 92.0, 35.4, 12.0, 2.2, 2.8, 0.0, "beefcake", 0)
	for pylon_x: float in [86.0, 94.0, 102.0, 110.0]:
		_prop("pylon", pylon_x, 58.0, 0.0, 1.0, 0.5, 0, "beefcake")
	var cable_pos: Vector3 = anchors["cable"] as Vector3
	_prop("power_cable", cable_pos.x, cable_pos.z, 0.0, 1.0, 0.0, 0, "beefcake")
	_prop("manhole", 88.0, 44.0, 0.0, 1.0, 0.0)
	_sign("sign.transit_main", 90.0, 38.0, 0.0, 1.1, "banner")
	_sign("sign.transit_cardio", 97.0, 47.0, 0.0, 0.9, "sign")
	_sign("sign.transit_lines", 86.0, 54.0, 0.0, 0.8, "sign")
	_sign("sign.transit_lights", 104.0, 57.0, 0.0, 0.8, "sign")
	_sign("sign.transit_cable", 112.0, 42.0, 0.0, 0.8, "sign")
	_sign("sign.net_transit", 88.0, 46.0, 0.0, 0.7, "sign")


# ---- The Hungry Quarter (Gourmands: shuttered stalls, the paste dispenser) -------------------------------------------------


func _hungry_quarter() -> void:
	_block_grid(Rect2(84.0, 17.0, 32.0, 18.0), Vector2(11.0, 9.0), Vector2(6.0, 5.0), "stall", "gourmand", 0.3, Vector2(2.6, 4.0), 1.5)
	var dispenser: Vector3 = anchors["dispenser"] as Vector3
	_prop("paste_dispenser", dispenser.x, dispenser.z, 90.0, 1.0, 0.8, 0, "gourmand")
	var odile_pos: Vector3 = anchors["odile"] as Vector3
	_prop("kitchen_cart", odile_pos.x + 2.4, odile_pos.z - 1.0, 0.0, 1.0, 1.2, 0, "gourmand")
	for recipe: String in ["recipe_1", "recipe_2", "recipe_3"]:
		var pos: Vector3 = anchors[recipe] as Vector3
		_prop("recipe_card", pos.x, pos.z, 0.0, 1.0, 0.0, 0, "gourmand")
	_prop("manhole", 90.0, 26.0, 0.0, 1.0, 0.0)
	_sign("sign.hungry_main", 94.0, 18.0, 0.0, 1.1, "banner")
	_sign("sign.hungry_paste", 90.0, 31.5, 0.0, 0.9, "sign")
	_sign("sign.hungry_closed", 100.0, 22.0, 0.0, 0.8, "sign")
	_sign("sign.hungry_nutrition", 108.0, 31.0, 0.0, 0.8, "sign")
	_sign("sign.hungry_menu", 86.0, 24.0, 0.0, 0.8, "sign")
	_sign("sign.net_hungry", 90.0, 28.0, 0.0, 0.7, "sign")


# ---- The Castle Approach ---------------------------------------------------------------------------------------------------


func _approach() -> void:
	# The castle's gate house: solid mass across the north with a 12 m door opening at x 54..65.
	_building("castle", 44.0, 0.0, 10.0, 3.0, 16.0, 0.0, "", 0)
	_building("castle", 66.0, 0.0, 10.0, 3.0, 16.0, 0.0, "", 1)
	_building("castle", 54.0, 0.0, 12.0, 1.0, 14.0, 0.0, "", 2)
	_prop("castle_door", 60.0, 2.0, 0.0, 1.0, 0.0)
	for index: int in range(6):
		var x: float = 46.0 + float(index) * 5.6
		_prop("statue_primm", x, 6.0 + (0.0 if index % 2 == 0 else 3.0), 180.0, 1.0, 0.7)
	for portrait: String in ["portrait_a1", "portrait_a2", "portrait_a3"]:
		var pos: Vector3 = anchors[portrait] as Vector3
		_prop("portrait", pos.x, pos.z, 0.0, 1.0, 0.45, 1)
	for lamp_x: float in [48.0, 56.0, 64.0, 72.0]:
		_prop("lamp_perfect", lamp_x, 12.0, 0.0, 1.0, 0.25)
	_prop("manhole", 60.0, 10.0, 0.0, 1.0, 0.0)
	_sign("sign.castle_main", 60.0, 3.2, 0.0, 1.5, "banner")
	_sign("sign.castle_avenue", 52.0, 13.0, 0.0, 0.9, "sign")
	_sign("sign.castle_warning", 66.0, 12.0, 0.0, 0.9, "sign")
	_sign("sign.net_approach", 60.0, 12.0, 0.0, 0.7, "sign")


# ---- Checkpoint Row (north-west: abandoned checkpoints) -------------------------------------------------------------------------


func _checkpoint_row() -> void:
	_block_grid(Rect2(3.0, 3.0, 22.0, 11.0), Vector2(11.0, 8.0), Vector2(6.0, 4.0), "ruin", "", 0.35, Vector2(3.0, 6.0), 5.0)
	for index: int in range(5):
		_prop("barrier", 4.0 + float(index) * 5.0, 14.2, 0.0, 1.0, 0.0)
	_prop("booth", 14.0, 12.5, 0.0, 1.0, 0.8, 0)
	_sign("sign.yard_main", 14.0, 9.5, 0.0, 1.0, "banner")
	_sign("sign.yard_abandoned", 22.0, 12.0, 0.0, 0.8, "sign")
	_sign("sign.yard_form", 8.0, 12.0, 0.0, 0.8, "sign")


# ---- The Correction Ward (north-east) ------------------------------------------------------------------------------------------------


func _ward() -> void:
	# A walled ward building with an open door to the west, beds inside.
	_building("ward", 94.0, 2.0, 1.0, 12.0, 4.0, 0.0, "", 0)
	_building("ward", 94.0, 2.0, 22.0, 1.0, 4.0, 0.0, "", 0)
	_building("ward", 94.0, 13.0, 8.0, 1.0, 4.0, 0.0, "", 0)
	_building("ward", 108.0, 13.0, 8.0, 1.0, 4.0, 0.0, "", 0)
	for index: int in range(5):
		_prop("bed", 98.0 + float(index) * 3.6, 6.0, 0.0, 1.0, 0.0)
	_prop("loudspeaker", 98.0, 5.0, 0.0, 1.0, 0.3)
	_prop("window_booth", 101.0, 12.0, 0.0, 1.0, 0.0)
	_prop("manhole", 96.0, 8.0, 0.0, 1.0, 0.0)
	_sign("sign.ward_main", 105.0, 3.5, 0.0, 1.1, "banner")
	_sign("sign.ward_permit", 101.0, 9.5, 0.0, 0.8, "sign")
	_sign("sign.ward_rules", 112.0, 11.0, 0.0, 0.8, "sign")


# ---- The Outskirts -------------------------------------------------------------------------------------------------------------------


func _outskirts() -> void:
	for checkpoint: String in ["checkpoint_a", "checkpoint_b"]:
		var pos: Vector3 = anchors[checkpoint] as Vector3
		_prop("booth", pos.x, pos.z, 0.0, 1.0, 0.9, 1)
		_prop("barrier", pos.x - 3.0, pos.z + 1.0, 0.0, 1.0, 0.0)
		_prop("barrier", pos.x + 3.0, pos.z + 1.0, 0.0, 1.0, 0.0)
	_prop("campfire", 50.0, 88.0, 0.0, 1.0, 0.8)
	_prop("tent", 47.0, 87.0, 20.0, 1.0, 1.4)
	for index: int in range(26):
		var x: float = _rng.randf_range(4.0, 116.0)
		var z: float = _rng.randf_range(66.0, 92.0)
		if absf(x - 60.0) < 8.0 and z > 82.0:
			continue
		if not _clear_of_anchors(x - 1.0, z - 1.0, 2.0, 2.0, 3.0):
			continue
		var kind: String = ["rock", "tree_dead", "wreck", "rock", "queue_post"][index % 5]
		_prop(kind, x, z, _rng.randf_range(0.0, 360.0), _rng.randf_range(0.8, 1.6), 0.0 if kind == "rock" else (1.0 if kind != "queue_post" else 0.2), index % 3)
	_prop("wreck_stack", 14.0, 91.0, 30.0, 1.4, 1.6)
	_prop("tunnel_hatch_cover", 7.0, 72.0, 0.0, 1.0, 0.0)
	_prop("toppled_statue", 9.0, 70.0, 80.0, 1.3, 1.6)
	for index: int in range(7):
		_prop("queue_post", 54.0 + float(index) * 2.0, 72.0, 0.0, 1.0, 0.0)
	_prop("height_post", 50.5, 67.0, 0.0, 1.0, 0.25)
	_sign("sign.out_welcome", 60.0, 86.0, 0.0, 1.2, "banner")
	_sign("sign.out_queue", 60.0, 76.0, 0.0, 0.9, "sign")
	_sign("sign.out_abandoned_a", 28.0, 85.5, 0.0, 0.8, "sign")
	_sign("sign.out_abandoned_b", 95.0, 83.5, 0.0, 0.8, "sign")
	_sign("sign.out_rift", 33.0, 80.0, 0.0, 0.8, "sign")
	_sign("sign.out_exit_rules", 63.0, 88.0, 0.0, 0.8, "sign")
	_sign("sign.out_tunnel_clue", 12.0, 74.0, 0.0, 0.6, "sign")
	_sign("sign.out_old_works", 115.0, 80.0, 0.0, 0.6, "sign")


# ---- Checkpoint Plaza ----------------------------------------------------------------------------------------------------------------------


func _plaza() -> void:
	_prop("statue_primm", 60.0, 50.0, 180.0, 1.5, 1.4)
	_prop("booth", 67.0, 53.0, 90.0, 1.0, 0.9, 2)
	_prop("complaint_box", 47.0, 52.0, 0.0, 1.0, 0.35)
	_prop("manhole", 45.0, 57.0, 0.0, 1.0, 0.0)
	for guard: String in ["guard_in_1", "guard_in_2"]:
		var pos: Vector3 = anchors[guard] as Vector3
		_prop("barrier", pos.x, pos.z + 1.2, 0.0, 1.0, 0.0)
	for lamp_x: float in [46.0, 52.0, 68.0, 74.0]:
		_prop("lamp_perfect", lamp_x, 47.0, 0.0, 1.0, 0.25)
	_sign("sign.plaza_main", 60.0, 46.5, 0.0, 1.3, "banner")
	_sign("sign.plaza_exit_interview", 66.0, 55.5, 0.0, 0.8, "sign")
	_sign("sign.plaza_complaints", 47.0, 53.5, 0.0, 0.8, "sign")
	_sign("sign.plaza_manhole", 45.0, 58.5, 0.0, 0.5, "sign")
	_sign("sign.net_plaza", 55.0, 54.0, 0.0, 0.7, "sign")


# ---- The Crease (the resistance hideout, underground) ------------------------------------------------------------------------------------


func _crease() -> void:
	_set_cells(Rect2i(3, 99, 39, 1), Cell.SOLID)
	_set_cells(Rect2i(3, 121, 39, 1), Cell.SOLID)
	_set_cells(Rect2i(3, 99, 1, 23), Cell.SOLID)
	_set_cells(Rect2i(41, 99, 1, 23), Cell.SOLID)
	for column: float in [10.0, 18.0, 26.0, 34.0]:
		_prop("crease_column", column, 108.0, 0.0, 1.0, 0.5)
	_prop("crease_table", 14.0, 104.2, 0.0, 1.0, 1.1)
	_prop("crease_stall", 31.0, 104.2, 0.0, 1.0, 1.1)
	_prop("tea_urn", 22.0, 102.6, 0.0, 1.0, 0.7)
	_prop("map_table", 22.0, 110.0, 0.0, 1.0, 1.0)
	_prop("ladder", 7.0, 112.0, 0.0, 1.0, 0.0)
	_prop("tunnel_arch", 38.0, 114.0, 0.0, 1.0, 0.0)
	_prop("crease_crate", 36.0, 108.6, 0.0, 1.0, 0.8)
	for index: int in range(NETWORK_DESTINATIONS.size()):
		_prop("shaft_door", 9.0 + 5.0 * float(index), 119.0, 0.0, 1.0, 0.0, index)
	_prop("cot", 10.0, 102.0, 0.0, 1.0, 0.0)
	_prop("cot", 13.0, 102.0, 0.0, 1.0, 0.0)
	_sign("sign.crease_main", 22.0, 100.5, 0.0, 1.2, "banner")
	_sign("sign.crease_wrinkle", 31.0, 102.5, 0.0, 0.8, "wall")
	_sign("sign.crease_network", 22.0, 119.2, 0.0, 1.0, "wall")
	_sign("sign.crease_rules", 12.0, 100.8, 0.0, 0.8, "wall")


# ---- Street lamps (dead while the Beefcake service is down) ------------------------------------------------------------------------------


func _street_lamps() -> void:
	for z: float in [8.0, 16.0, 24.0, 32.0, 40.0, 48.0, 56.0]:
		_prop("lamp_street", 39.5, z, 0.0, 1.0, 0.25, 0, "beefcake")
		_prop("lamp_street", 80.5, z, 0.0, 1.0, 0.25, 0, "beefcake")
	for z: float in [68.0, 76.0, 84.0]:
		_prop("lamp_street", 56.5, z, 0.0, 1.0, 0.25, 0, "beefcake")
		_prop("lamp_street", 63.5, z, 0.0, 1.0, 0.25, 0, "beefcake")


# ---- Enemies ---------------------------------------------------------------------------------------------------------------------------------


func _spawn(type: String, x: float, z: float, patrol: float, id: String = "") -> void:
	var entry: Dictionary = {"type": type, "home": Vector3(x, 0.0, z), "patrol": patrol}
	if not id.is_empty():
		entry["id"] = id
	enemy_spawns.append(entry)


func _enemies() -> void:
	# The Outskirts.
	_spawn("officer", 38.0, 78.0, 5.0)
	_spawn("inspector", 82.0, 78.0, 5.0)
	_spawn("tidybot", 60.0, 72.0, 7.0)
	_spawn("wretch", 32.0, 76.0, 3.0, "guard_out_a")
	_spawn("swarm", 91.0, 73.0, 5.0)
	_spawn("officer", 108.0, 84.0, 5.0)
	# Inside the walls: Checkpoint Plaza has only the roving Tidy-Bots.
	_spawn("tidybot", 48.0, 50.0, 6.0)
	_spawn("tidybot", 72.0, 52.0, 6.0)
	# The Reek.
	_spawn("officer", 14.0, 50.0, 5.0)
	_spawn("wretch", 24.0, 49.0, 3.0, "guard_reek")
	_spawn("tidybot", 32.0, 47.0, 6.0)
	# Grave Row.
	_spawn("inspector", 14.0, 29.0, 5.0)
	_spawn("wretch", 22.0, 27.0, 3.0, "guard_grave")
	_spawn("officer", 36.0, 20.0, 5.0)
	# The Transit Yards.
	_spawn("officer", 88.0, 48.0, 5.0)
	_spawn("tidybot", 100.0, 57.0, 6.0)
	_spawn("swarm", 105.0, 50.0, 5.0)
	_spawn("inspector", 112.0, 46.0, 5.0)
	# The Hungry Quarter.
	_spawn("inspector", 92.0, 24.0, 5.0)
	_spawn("wretch", 104.0, 29.0, 3.0, "guard_hungry")
	_spawn("tidybot", 110.0, 32.0, 6.0)
	# The Castle Approach, Checkpoint Row and the Ward.
	_spawn("officer", 50.0, 9.0, 5.0)
	_spawn("inspector", 72.0, 6.0, 5.0)
	_spawn("wretch", 80.0, 10.0, 3.0, "guard_approach_e")
	_spawn("swarm", 38.0, 11.0, 5.0)
	_spawn("officer", 14.0, 8.0, 5.0)
	_spawn("tidybot", 8.0, 12.0, 6.0)
	_spawn("inspector", 102.0, 8.0, 4.0)
	_spawn("officer", 109.0, 11.0, 4.0)


## The id of the guardian that must fall before a rift can be sealed.
static func guardian_id(rift_id: String) -> String:
	return CapitalRifts.guardian_id(rift_id)


# ---- Cracks --------------------------------------------------------------------------------------------------------------------------------


func _cracks() -> void:
	# Cracked streets everywhere outside the facade (more around the rifts).
	for index: int in range(46):
		var pos: Vector2 = Vector2(_rng.randf_range(4.0, 116.0), _rng.randf_range(4.0, 58.0))
		if pos.x > 42.0 and pos.x < 78.0 and pos.y > 14.0 and pos.y < 45.0:
			continue
		if cell_at(int(pos.x), int(pos.y)) != Cell.GROUND:
			continue
		cracks.append({"pos": pos, "yaw": _rng.randf_range(0.0, 180.0), "length": _rng.randf_range(2.5, 6.5)})
	for rift: Rift in rifts:
		for index: int in range(5):
			var angle: float = TAU * float(index) / 5.0 + rift.radius
			cracks.append({"pos": rift.pos + Vector2(cos(angle), sin(angle)) * (rift.radius + 1.0), "yaw": rad_to_deg(angle), "length": 3.0 + rift.radius})


# ---- Obstacles ---------------------------------------------------------------------------------------------------------------------------------


func _index_obstacles() -> void:
	for prop: Prop in props:
		if prop.radius > 0.0:
			obstacles.append(Vector3(prop.pos.x, prop.pos.z, prop.radius))
