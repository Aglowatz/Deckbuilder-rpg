class_name TownBuilder
extends WalkableArea
## Builds the starter town island from KayKit hex pieces and describes where things are:
## which cells can be walked on, where the obstacles are and where the interactable spots sit.
## Used by the title backdrop (just visuals) and by the playable town scene.

## '.' water, '#' grass, 'T' grass with trees, 'M' mountain (blocked), 'R' rocks,
## K market, D deck station, W wellspring, G dungeon gate, H/h houses, S spawn, F windmill,
## C church, Y hall of records (codex), Z hidden vendor, X sealed vault (locked-gate secret).
## New brief, Part C: the original town (rows 0-9, cols 0-14 below - unchanged except opening 3
## cells of col 0 so the West Woods can reach it) is now the center of a ~3x-area island with 5
## districts around it, one per zone entrance (Part E's corrupted NPCs lock/unlock these; see
## `docs/design/open_questions.md` D65):
##   - **North Uplands** (rows -5..-1): a mountain-pass overlook leading to the Final entrance
##     (gold, open from the start) at the true north edge.
##   - **West Woods** (cols -6..-1, rows 0-9): winding forest leading to the Refusemancer entrance at the
##     west edge.
##   - **Harbor Dock** (cols 15-20, rows 0-9): the Harbor Quarter's canal continuing out to the
##     Gourmand entrance at the east edge.
##   - **Beefcake Flats** (rows 10-14): open ground south of the Secluded Grove leading to the Beefcake
##     entrance at the south edge.
##   - **Grave Hollow** (the southwest corner: rows 10-12, cols -6..-1): a misty pocket off the
##     Beefcake Flats leading to the Grave entrance at the west edge.
## `ROW_OFFSET`/`COL_OFFSET` convert a string's own (row, col) index into world-space coordinates,
## so the original 10x15 core keeps exactly the same world coordinates (and thus the same
## anchors/spawn/every other unchanged reference) it always had - it is simply no longer the
## outer edge of the map.
const ROW_OFFSET: int = 5
const COL_OFFSET: int = 6

const MAP: Array[String] = [
	"......R.#T##TM##.#MR#......",
	"......###M#T##M#R.M##......",
	"......M##R######T#TR#......",
	"......##TM#T.##.###.#......",
	"......###.###.##TT##R......",
	"#.#T..##############MR##T#T",
	"#R#MT###############T#MRM.#",
	"##.###################T###R",
	"RR##################T#####T",
	"####################T######",
	"R##TTT##############T##.#.#",
	"RTT#T####################T#",
	"#T##T#############....#TTMM",
	"T#T#R##############..RTTT#.",
	"M##################..#MM#.#",
	"#.##T###############T......",
	"####################M......",
	"T#T#.TT###############R##..",
	"......##############T......",
	"......T#############.......",
	"......###############......",
	"......T#############T......",
	"......##############T......",
	"......T#############M......",
	"......###############......",
	"......T#############T......",
	"......##############R......",
	"......M#############M......",
]

## The town is spread out: every hex cell is SCALE times its tile size (tiles are scaled, props are not), so there are wide walkways between buildings.
const SCALE: float = 1.8

## Cells (col, row) planted with a clump of trees framing the town's centre, clear of every road of `TownLayout` and every storefront.
const TREE_CLUMPS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(11, 0), Vector2i(13, 0), Vector2i(13, 1),
	Vector2i(1, 8), Vector2i(0, 9), Vector2i(1, 10), Vector2i(13, 10), Vector2i(12, 11), Vector2i(13, 12),
	Vector2i(2, 14), Vector2i(1, 15),
]

## Where the original giant chest stands (hex cell, world coordinates): the end of the peninsula that reaches out from the south-east shore (see MAP row 17).
const GIANT_CHEST_CELL: Vector2i = Vector2i(18, 12)
## Brief 16, Group G: the old vault's lever (hex cell) and the mountain cell the new Four-Seal Vault is set into.
const LEVER_CELL: Vector2i = Vector2i(1, 17)
const FOUR_SEAL_CELL: Vector2i = Vector2i(0, -3)

const OBSTACLE_TREE: float = 0.32
const OBSTACLE_ROCK: float = 0.35

## Grid cells the player may stand on.
var walkable: Dictionary = {}
## Circular obstacles as Vector3(x, z, radius).
var obstacles: Array[Vector3] = []
## Named world positions: "spawn", "market", "well", "gate", "deck", plus NPC spots.
var anchors: Dictionary = {}
var root: Node3D
## The decorative clouds (a scene may hand them to a `CloudFader`).
var clouds: Array[Node3D] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


## The map after `_prepare_map`: MAP with the roads of `TownLayout` carved through anything that would block them.
var _map: Array[String] = []


func build(parent: Node3D, decorate_far: bool = true) -> void:
	_rng.seed = 7
	root = Node3D.new()
	root.name = "Town"
	parent.add_child(root)
	_prepare_map()
	_plan_connectors()
	_build_water()
	for row: int in range(_map.size()):
		var line: String = _map[row]
		for col: int in range(line.length()):
			_build_cell(col - COL_OFFSET, row - ROW_OFFSET, line[col])
	if decorate_far:
		_build_far_scenery()
	_build_props()
	_build_zone_portals()


## Copies MAP and carves the town's roads through it: mountains, trees and rocks within 3 m of a road become plain grass, and so does water inside the
## town centre (so a road never ends at a shore). Also plants the few decorative tree clumps framing the centre.
func _prepare_map() -> void:
	var rows: Array[PackedStringArray] = []
	for line: String in MAP:
		var chars: PackedStringArray = PackedStringArray()
		for index: int in range(line.length()):
			chars.append(line[index])
		rows.append(chars)
	for cell: Vector2i in TREE_CLUMPS:
		var map_row: int = cell.y + ROW_OFFSET
		var map_col: int = cell.x + COL_OFFSET
		if map_row >= 0 and map_row < rows.size() and map_col >= 0 and map_col < rows[map_row].size() and rows[map_row][map_col] == "#":
			rows[map_row][map_col] = "T"
	for point: Vector3 in TownLayout.road_points(1.0):
		var around: Vector2i = HexGrid.world_to_cell(point / SCALE)
		for d_row: int in range(-2, 3):
			for d_col: int in range(-2, 3):
				var cell: Vector2i = Vector2i(around.x + d_col, around.y + d_row)
				if cell_center(cell.x, cell.y).distance_to(point) > 3.0:
					continue
				var map_row: int = cell.y + ROW_OFFSET
				var map_col: int = cell.x + COL_OFFSET
				if map_row < 0 or map_row >= rows.size() or map_col < 0 or map_col >= rows[map_row].size():
					continue
				var symbol: String = rows[map_row][map_col]
				if symbol == "M" or symbol == "T" or symbol == "R":
					rows[map_row][map_col] = "#"
				elif symbol == "." and cell.x >= 0 and cell.x <= 14 and cell.y >= -5 and cell.y <= 22:
					rows[map_row][map_col] = "#"
	_map.clear()
	for chars: PackedStringArray in rows:
		_map.append("".join(chars))


func cell_center(col: int, row: int) -> Vector3:
	return HexGrid.cell_to_world(col, row) * SCALE


## `pad` cells of open water surround the island past its actual (map-size-derived) edges, so
## this keeps working regardless of how big MAP is instead of a hand-tuned bounding box.
const WATER_PAD: int = 5


func _build_water() -> void:
	for row: int in range(-ROW_OFFSET - WATER_PAD, MAP.size() - ROW_OFFSET + WATER_PAD):
		for col: int in range(-COL_OFFSET - WATER_PAD, MAP[0].length() - COL_OFFSET + WATER_PAD):
			var map_row: int = row + ROW_OFFSET
			var map_col: int = col + COL_OFFSET
			var inside: bool = map_row >= 0 and map_row < _map.size() and map_col >= 0 and map_col < _map[0].length() and _map[map_row][map_col] != "."
			if inside:
				continue
			if _blocked_cells.has(Vector2i(col, row)) and _island_cells.has(Vector2i(col, row)):
				continue
			var water: Node3D = ModelKit.tile("hex_water")
			ModelKit.place(root, water, cell_center(col, row), 0.0, SCALE)
	_build_connector_water()


## Brief 16, Group D: what lies beyond each passageway (see TownConnectors). The plans are made first so the water and the far scenery leave room for them.
var _connector_plans: Dictionary = {}
var _island_cells: Dictionary = {}
var _blocked_cells: Dictionary = {}


func _plan_connectors() -> void:
	_connector_plans.clear()
	_island_cells.clear()
	_blocked_cells.clear()
	for zone_id: String in PORTAL_CELLS.keys():
		var cell: Vector2i = PORTAL_CELLS[zone_id] as Vector2i
		var out: Vector3 = PORTAL_OUT.get(zone_id, Vector3(0, 0, -1)) as Vector3
		var plan: Dictionary = TownConnectors.plan(cell_center(cell.x, cell.y), out)
		_connector_plans[zone_id] = plan
		for island_cell: Variant in plan["cells"] as Array:
			_island_cells[island_cell as Vector2i] = true
			_blocked_cells[island_cell as Vector2i] = true
		for corridor_cell: Variant in plan["corridor"] as Array:
			_blocked_cells[corridor_cell as Vector2i] = true


## Water around each island where the usual pad of water tiles does not reach.
func _build_connector_water() -> void:
	var row_low: int = -ROW_OFFSET - WATER_PAD
	var row_high: int = MAP.size() - ROW_OFFSET + WATER_PAD
	var col_low: int = -COL_OFFSET - WATER_PAD
	var col_high: int = MAP[0].length() - COL_OFFSET + WATER_PAD
	var placed: Dictionary = {}
	for plan: Variant in _connector_plans.values():
		var center_cell: Vector2i = (plan as Dictionary)["center_cell"] as Vector2i
		for row: int in range(center_cell.y - TownConnectors.WATER_RADIUS, center_cell.y + TownConnectors.WATER_RADIUS + 1):
			for col: int in range(center_cell.x - TownConnectors.WATER_RADIUS - 1, center_cell.x + TownConnectors.WATER_RADIUS + 2):
				var key: Vector2i = Vector2i(col, row)
				if placed.has(key) or _island_cells.has(key):
					continue
				if row >= row_low and row < row_high and col >= col_low and col < col_high:
					continue
				placed[key] = true
				ModelKit.place(root, ModelKit.tile("hex_water"), cell_center(col, row), 0.0, SCALE)


func _build_cell(col: int, row: int, symbol: String) -> void:
	if symbol == ".":
		return
	var center: Vector3 = cell_center(col, row)
	ModelKit.place(root, ModelKit.tile("hex_grass"), center, 0.0, SCALE)
	var yaw: float = float(_rng.randi_range(0, 5)) * 60.0
	match symbol:
		"M":
			var mountain: String = ["mountain_A_grass_trees", "mountain_B_grass_trees", "mountain_C_grass_trees"][_rng.randi() % 3]
			ModelKit.place(root, ModelKit.nature(mountain), center, yaw, SCALE)
			return
		"T":
			walkable[Vector2i(col, row)] = true
			for i: int in range(3):
				var offset: Vector3 = _scatter(center, 0.4 * SCALE, 0.85 * SCALE)
				var tree: String = ["tree_single_A", "tree_single_B"][_rng.randi() % 2]
				ModelKit.place(root, ModelKit.nature(tree), offset, _rng.randf() * 360.0, _rng.randf_range(1.1, 1.5))
				obstacles.append(Vector3(offset.x, offset.z, OBSTACLE_TREE * 1.3))
		"R":
			walkable[Vector2i(col, row)] = true
			var rock_pos: Vector3 = _scatter(center, 0.2 * SCALE, 0.7 * SCALE)
			ModelKit.place(root, ModelKit.nature("rock_single_%s" % ["A", "B", "C", "D", "E"][_rng.randi() % 5]), rock_pos, _rng.randf() * 360.0, 1.3)
			# Polish round: small decorative rocks never block the hero (OBSTACLE_ROCK is kept for the doc of what it used to be).
		_:
			walkable[Vector2i(col, row)] = true


func _building(model: String, center: Vector3, yaw: float, model_scale: float, radius: float) -> void:
	ModelKit.place(root, ModelKit.building(model), center, yaw, model_scale)
	obstacles.append(Vector3(center.x, center.z, radius))


func _scatter(center: Vector3, min_radius: float, max_radius: float) -> Vector3:
	var angle: float = _rng.randf() * TAU
	var distance: float = _rng.randf_range(min_radius, max_radius)
	return center + Vector3(cos(angle), 0.0, sin(angle)) * distance


func _build_far_scenery() -> void:
	# A mountain range behind the island, hills at the sides, drifting clouds overhead - pushed
	# out past the real (now ~3x bigger) island edges rather than a fixed old-map-sized box.
	var west_edge: int = -COL_OFFSET
	var east_edge: int = MAP[0].length() - COL_OFFSET
	var north_edge: int = -ROW_OFFSET
	var far_row: int = north_edge - 2
	for col: int in range(west_edge - 2, east_edge + 3):
		if _blocked_cells.has(Vector2i(col, far_row)):
			continue
		var far: Vector3 = cell_center(col, far_row)
		ModelKit.place(root, ModelKit.tile("hex_grass"), far, 0.0, SCALE)
		var mountain: String = ["mountain_A_grass_trees", "mountain_B_grass_trees", "mountain_C_grass_trees"][_rng.randi() % 3]
		ModelKit.place(root, ModelKit.nature(mountain), far, float(_rng.randi_range(0, 5)) * 60.0, 1.4 * SCALE)
	var hill_cells: Array[Vector2i] = [
		Vector2i(west_edge - 2, 1), Vector2i(west_edge - 2, 6), Vector2i(west_edge - 2, 11),
		Vector2i(east_edge + 2, 2), Vector2i(east_edge + 2, 7), Vector2i(east_edge + 2, 0),
	]
	for cell: Vector2i in hill_cells:
		if _blocked_cells.has(cell):
			continue
		var pos: Vector3 = cell_center(cell.x, cell.y)
		ModelKit.place(root, ModelKit.tile("hex_grass"), pos, 0.0, SCALE)
		ModelKit.place(root, ModelKit.nature(["hills_A_trees", "hills_B_trees"][_rng.randi() % 2]), pos, float(_rng.randi_range(0, 5)) * 60.0, SCALE)
# Few, small and high (they used to be huge and drift in front of the camera); CloudFader fades any that still get between the camera and the hero.	for i: int in range(5):		var cloud: Node3D = ModelKit.nature("cloud_big" if i % 2 == 0 else "cloud_small")		var cloud_scale: float = 0.9 if i % 2 == 0 else 0.65		ModelKit.place(root, cloud, Vector3(_rng.randf_range(west_edge - 3, east_edge + 5) * SCALE, _rng.randf_range(24, 30), _rng.randf_range(far_row - 3, 14) * SCALE), 0.0, cloud_scale)		clouds.append(cloud)


func _build_props() -> void:
	_build_centre()
	# New brief, Part E: 4 corrupted NPCs, one per element district, close enough to their own
	# path. Visual corruption (tint + particle effect) is TownScene's job, not the builder's.
	anchors["npc_beefcake"] = cell_center(6, 20) + Vector3(0.3, 0, 0.4)
	anchors["npc_gourmand"] = cell_center(16, 3) + Vector3(-0.3, 0, 0.4)
	anchors["npc_refusemancer"] = cell_center(-3, 2) + Vector3(0.3, 0, -0.3)
	anchors["npc_necrocrat"] = cell_center(-3, 11) + Vector3(0.3, 0, 0.3)
	# Brief 16: the giant chest (Shiro Swindle's original trap) sits at the tip of a lonely peninsula in the south-east, in the middle of nowhere,
	# far from every building and NPC; the old lever that seals the vault stays near the Secluded Grove.
	var chest_pos: Vector3 = cell_center(GIANT_CHEST_CELL.x, GIANT_CHEST_CELL.y) + Vector3(0.1, 0, 0.0)
	harbor_chest_node = GiantChestEvent.make_chest(root, chest_pos, 200.0)
	obstacles.append(Vector3(chest_pos.x, chest_pos.z, 0.5))
	anchors["chest"] = chest_pos + Vector3(0.0, 0, 1.5)
	# Brief 16: the old vault's lever now sits far from it (the south-west of the long southern strip), where only an explorer finds it.
	var lever_pos: Vector3 = cell_center(LEVER_CELL.x, LEVER_CELL.y) + Vector3(0.3, 0, 0.2)
	ModelKit.place(root, ModelKit.prop("ladder"), lever_pos, 90.0, 1.0)
	obstacles.append(Vector3(lever_pos.x, lever_pos.z, 0.2))
	anchors["lever"] = lever_pos + Vector3(0.4, 0, 0.2)
	# Brief 16: the Four-Seal Vault - a door in the south face of the mountain at FOUR_SEAL_CELL, reached from the open ground south of it.
	var vault4_mountain: Vector3 = cell_center(FOUR_SEAL_CELL.x, FOUR_SEAL_CELL.y)
	anchors["vault4_mouth"] = vault4_mountain + Vector3(0, 0, 1.5)
	anchors["vault4"] = (anchors["vault4_mouth"] as Vector3) + Vector3(0, 0, 1.4)
	obstacles.append(Vector3(vault4_mountain.x, vault4_mountain.z + 1.5, 1.2))
	_build_hidden_chests()
	expansion = TownExpansion.build(root, self)
	_build_dev_shrine()
	_build_graveyard()


## The town's centre (`TownLayout`): every shop, civic building and the arena, with the anchors the scene and the tests use.
func _build_centre() -> void:
	anchors["plaza"] = TownLayout.PLAZA
	anchors["spawn"] = TownLayout.SPAWN
	for shop: TownLayout.Shop in TownLayout.shops():
		_place_shop(shop)
	# Beside the storefronts: a few crates and barrels (never in the street).
	for shop: TownLayout.Shop in TownLayout.shops():
		if shop.key in ["market", "deck", "gate", "equipment_vendor", "item_vendor"]:
			_prop("crate_A_big", shop.center + shop.right() * (shop.radius + 0.55) - shop.front() * 0.3, 20.0, 1.1, 0.3)
			_prop("barrel", shop.center - shop.right() * (shop.radius + 0.5) - shop.front() * 0.2, 0.0, 1.1, 0.25)
	var gate_shop: TownLayout.Shop = _shop_for("gate")
	_prop("weaponrack", gate_shop.center - gate_shop.front() * 1.1 + gate_shop.right() * 1.3, 10.0, 1.2, 0.3)
	_prop("flag_blue", gate_shop.door_spot() - gate_shop.right() * 1.1, 0.0, 1.3, 0.15)
	# Grand Clashatorium: a colosseum at the end of Champions' Road, its gate facing north onto the avenue.
	var arena_center: Vector3 = TownLayout.ARENA_CENTER
	ArenaBuilding.build(root, arena_center)
	var arena_radius: float = ArenaBuilding.world_radius()
	obstacles.append(Vector3(arena_center.x, arena_center.z, arena_radius + 0.15))
	anchors["arena"] = arena_center + Vector3(0, 0, -(arena_radius + 0.95))
	anchors["arena_gate"] = arena_center + Vector3(0, 0, -(arena_radius + 0.2))
	anchors["npc_arena"] = arena_center + Vector3(1.8, 0, -(arena_radius + 0.9))


func _shop_for(key: String) -> TownLayout.Shop:
	for shop: TownLayout.Shop in TownLayout.shops():
		if shop.key == key:
			return shop
	return null


func _place_shop(shop: TownLayout.Shop) -> void:
	var front: Vector3 = shop.front()
	var right: Vector3 = shop.right()
	match shop.kind:
		"building":
			_building(shop.model, shop.center, shop.yaw, shop.scale_value, shop.radius)
	if shop.key.is_empty():
		return
	var spot: Vector3 = shop.door_spot()
	anchors[shop.key] = spot
	match shop.key:
		"rift_station":
			anchors["rift_station"] = shop.center
			anchors["npc_rift_station"] = shop.center + Vector3(-2.0, 0.0, 0.9)
		"tailor":
			anchors["npc_tailor"] = shop.center + front * 1.6 + right * 0.8
			anchors["tailor_mannequin"] = shop.center + front * 1.4 - right * 1.0
		"alchemist":
			anchors["npc_alchemist"] = shop.center + front * 1.0 + right * 1.15
			anchors["alchemist_door"] = shop.center + front * 0.55
		"gate":
			anchors["npc_gate"] = shop.center + front * 1.6 + right * 1.9
		"elder_home":
			anchors["npc_elder"] = shop.center + front * 1.8
			anchors["npc_well"] = anchors["npc_elder"]
		"well":
			anchors["well"] = shop.center + front * 0.9
		"hidden_vendor", "vault", "church", "deck", "codex":
			pass
		_:
			anchors["npc_%s" % shop.key] = shop.center + front * 1.75


## New brief (third), Part E: a debug-only "Dev Shrine" at the very bottom (south) edge of the
## town map, Beefcake Flats row - each interaction grants one level via the real level-up flow.
## Gated by DevTools.shrine_enabled() here, at the builder level, so it does not exist as a 3D
## object at all (not just an unreachable interaction) once DevTools says no - see D88 for why
## that matters for an exported release build specifically.
func _build_dev_shrine() -> void:
	if not DevTools.shrine_enabled():
		return
	var pos: Vector3 = cell_center(13, 14)
	_building("tower_B", pos, 0.0, 1.1, 0.85)
	# Row 14 is the map's southmost data row (open water beyond it) - approach from the north,
	# the walkable side, not south like most buildings default to.
	anchors["dev_shrine"] = pos + Vector3(0, 0, -1.05)


## Fourth brief, Part F: the Graveyard - a small, atmospheric pocket carved into Grave Hollow
## (fog, dead trees, makeshift grave markers, same asset family - no dedicated tombstone/coffin
## model exists in either approved pack, see docs/design/open_questions.md), built around The
## Restless Cairn (the "ominous object" that starts the scripted battle). Placed in the
## already-proven-safe Grave Hollow district (D67), at cells clear of the district's existing
## chest/NPC/portal anchors. Fog is TownScene's job (a particle effect), not the builder's - same
## split as the corrupted NPCs' corruption particles.
const GRAVEYARD_CENTER_CELL: Vector2i = Vector2i(-3, 10)


func _build_graveyard() -> void:
	var center: Vector3 = cell_center(GRAVEYARD_CENTER_CELL.x, GRAVEYARD_CENTER_CELL.y)
	var cairn: Node3D = Node3D.new()
	cairn.name = "RestlessCairn"
	# First tint pass (0.35, 0.35, 0.38) still read as a plain yellowish rock at a real distance,
	# not "dark, ominous stone" - screenshotted before deciding, not guessed (same discipline as
	# D61/D69). Multiplicative tint can't shift the model's own warm hue, only darken it, so this
	# leans much darker to actually win against the base texture, closer in spirit to D69's
	# "lightened+boosted" fix for the opposite problem (there, too pale; here, too bright).
	var base: Node3D = ModelKit.nature("rock_single_E")
	ModelKit.tint(base, Color(0.12, 0.11, 0.13))
	cairn.add_child(base)
	var top: Node3D = ModelKit.nature("rock_single_D")
	ModelKit.tint(top, Color(0.09, 0.08, 0.1))
	top.position = Vector3(0.05, 0.35, -0.05)
	top.scale = Vector3.ONE * 0.7
	cairn.add_child(top)
	ModelKit.place(root, cairn, center, _rng.randf() * 360.0, 1.15)
	obstacles.append(Vector3(center.x, center.z, 0.45))
	anchors["graveyard_cairn"] = center + Vector3(0.0, 0, 1.1)
	# Grave markers: no dedicated tombstone model exists in either approved pack, so plain rocks
	# stand in for them (an honest reuse, same spirit as the equipment vendor's blacksmith
	# building or Bertram Beetsworth's Knight model) - tinted a flatter grey so they read as worked
	# stone rather than wayside boulders.
	# Kept inside roughly one cell's own footprint (HexGrid.WIDTH is 2.0, ROW_SPACING ~1.73), and
	# entirely on the north/east/west sides (z <= -0.3, or |z| small with large |x|) - the south
	# corridor (positive z, small |x|) leading to the interact anchor above must stay clear, or
	## the approach (real player or the crude WASD test bot) gets blocked.
	var marker_offsets: Array[Vector3] = [
		Vector3(-0.9, 0, -0.3), Vector3(0.9, 0, -0.3), Vector3(-0.6, 0, -0.95),
		Vector3(0.6, 0, -0.95), Vector3(0.0, 0, -1.25),
	]
	var marker_models: Array[String] = ["rock_single_A", "rock_single_B", "rock_single_C"]
	for offset: Vector3 in marker_offsets:
		var marker: Node3D = ModelKit.nature(marker_models[_rng.randi() % marker_models.size()])
		ModelKit.tint(marker, Color(0.5, 0.5, 0.52))
		var pos: Vector3 = center + offset
		ModelKit.place(root, marker, pos, _rng.randf() * 360.0, 0.9)
		obstacles.append(Vector3(pos.x, pos.z, 0.3))
	# Dead trees: the pack's own bare/leafless "_cut" tree variant, no new asset needed - kept to
	# the east/west sides, clear of the south approach corridor.
	for offset: Vector3 in [Vector3(-1.15, 0, 0.05), Vector3(1.15, 0, 0.05)]:
		var pos: Vector3 = center + offset
		ModelKit.place(root, ModelKit.nature("tree_single_A_cut"), pos, _rng.randf() * 360.0, 1.2)
		obstacles.append(Vector3(pos.x, pos.z, 0.35))


## New brief, Part D: 5 hidden chests, scaled to 1/4 of the D38 chest above (0.9 -> 0.225) and
## tucked into real alcoves across the (now bigger) town - among trees, in a back alley, in a
## misty hollow, on a quiet overlook, in a stand of trees off the Beefcake Flats - not clustered in
## one district. No marker, glow or name plate (see TownScene._build_hidden_chests/_process - a
## separate, quieter system from the regular Spot the D38 chest above uses, which does have a
## marker): the only tell is the standard interact prompt, and only once the player is genuinely
## close. Exact locations and contents are also written to docs/design/secrets.md (a spoiler
## file) - see D67 (also D67 for why none of the 5 sit in the original 10x15 core: a real, still-
## unexplained rendering bug specific to that area, not a design choice - avoided rather than
## shipped).
## Fourth brief, Part E: 2 more hidden chests (equipment this time - see docs/design/secrets.md),
## same rules as the 5 above - one more in an already-proven-safe district (D67) rather than a
## new one, at a cell well clear of every existing anchor/chest in that district.
const HIDDEN_CHEST_CELLS: Dictionary = {
	"beefcake_flats": Vector2i(9, 12), "west_woods": Vector2i(-4, 5), "harbor_dock": Vector2i(17, 6),
	"grave_hollow": Vector2i(-4, 12), "uplands": Vector2i(8, -2),
	"uplands_ridge": Vector2i(11, -3), "harbor_dock_back": Vector2i(16, 2),
	# Polish round: 4 hard-to-find chests out on the shores and ridges (see docs/design/secrets.md).
	"clashatorium_west": Vector2i(0, 20), "harbor_pier": Vector2i(20, 0),
	"southeast_shore": Vector2i(14, 17), "northeast_ridge": Vector2i(14, -5),
}
const HIDDEN_CHEST_OFFSETS: Dictionary = {
	"west_woods": Vector3(0.35, 0, -0.25), "harbor_dock": Vector3(-0.3, 0, 0.35),
	"grave_hollow": Vector3(0.3, 0, 0.3), "uplands": Vector3(-0.25, 0, -0.35),
	"beefcake_flats": Vector3(0.3, 0, -0.3),
	"uplands_ridge": Vector3(0.3, 0, 0.25), "harbor_dock_back": Vector3(-0.25, 0, 0.3),
	"clashatorium_west": Vector3(-1.8, 0, -0.55), "harbor_pier": Vector3(1.2, 0, 0.0),
	"southeast_shore": Vector3(-1.2, 0, 0.6), "northeast_ridge": Vector3(1.8, 0, 0.6),
}


## id -> the chest's Node3D, so TownScene can play an open animation on the real model.
var hidden_chest_nodes: Dictionary = {}
## The Secluded Grove's big chest (the D38 one), so the scene can show it open once it has been looted.
var harbor_chest_node: Node3D
## Polish round: label -> world position of every added cottage, shed, stall and well (TownExpansion).
var expansion: Dictionary = {}


func _build_hidden_chests() -> void:
	for id: String in HIDDEN_CHEST_CELLS.keys():
		var cell: Vector2i = HIDDEN_CHEST_CELLS[id] as Vector2i
		var offset: Vector3 = HIDDEN_CHEST_OFFSETS[id] as Vector3
		var pos: Vector3 = cell_center(cell.x, cell.y) + offset
		var chest: Node3D = ModelKit.dungeon_prop("chest_gold")
		ModelKit.place(root, chest, pos, _rng.randf() * 360.0, 0.225)
		obstacles.append(Vector3(pos.x, pos.z, 0.18))
		anchors["hidden_chest_%s" % id] = pos
		hidden_chest_nodes[id] = chest


## New brief, Part C: 5 entrances at the true edges of the map (a `tower_A` shape, tinted per-
## element like the hex grass tiles are, so each is visually distinct without new art) - one per
## element plus the final area, each a clearly readable gate at the edge of its own district
## (see the MAP legend above). Each leads to `ZonePlaceholderScene`, a reusable "coming soon"
## template (`Session.enter_zone_portal`); no real zone is built here. Locking (element entrances
## start locked until their corrupted NPC is defeated, Part E) is presentation state that lives in
## `TownScene`, not here - `TownBuilder` only places the structure and its anchor.
const PORTAL_CELLS: Dictionary = {
	"final": Vector2i(4, -5), "refusemancer": Vector2i(-6, 4), "gourmand": Vector2i(20, 4),
	"beefcake": Vector2i(7, 22), "necrocrat": Vector2i(-6, 11),
}


## Which way each passageway leads out of the map (a unit vector on the ground).
const PORTAL_OUT: Dictionary = {
	"final": Vector3(0, 0, -1), "refusemancer": Vector3(-1, 0, 0), "gourmand": Vector3(1, 0, 0),
	"beefcake": Vector3(0, 0, 1), "necrocrat": Vector3(-1, 0, 0),
}
## How far inside the passage mouth the hero's arrival anchor sits, and the radius at which walking in counts as taking the passage.
const PORTAL_ENTRY: float = 3.0
const PORTAL_TRIGGER: float = 0.9
## id -> the passage's root node (the scene dims the far glow of locked ones).
var passage_nodes: Dictionary = {}


func _build_zone_portals() -> void:
	for info: ZonePortals.Info in ZonePortals.all():
		var cell: Vector2i = PORTAL_CELLS.get(info.id, Vector2i.ZERO) as Vector2i
		var center: Vector3 = cell_center(cell.x, cell.y)
		var out: Vector3 = PORTAL_OUT.get(info.id, Vector3(0, 0, -1)) as Vector3
		var passage: Node3D = TownPassages.build(info.id, info.display_name, info.tint, false)
		ModelKit.place(root, passage, center, TownPassages.yaw_for(out), 1.0)
		passage_nodes[info.id] = passage
		TownConnectors.build(root, info.id, center, out, _connector_plans[info.id] as Dictionary)
		var right: Vector3 = Vector3(-out.z, 0.0, out.x)
		for side: float in [-1.0, 1.0]:
			var post: Vector3 = center + right * side * (TownPassages.OPENING + 0.55)
			obstacles.append(Vector3(post.x, post.z, 0.55))
		anchors["portal_%s" % info.id] = center - out * PORTAL_ENTRY
		anchors["portal_%s_mouth" % info.id] = center


func _prop(model: String, position: Vector3, yaw: float, model_scale: float, radius: float) -> void:
	ModelKit.place(root, ModelKit.prop(model), position, yaw, model_scale)
	if radius > 0.0:
		obstacles.append(Vector3(position.x, position.z, radius))


## True when a character may stand at `pos` (on a walkable cell and clear of obstacles).
func is_walkable(pos: Vector3, body_radius: float = 0.22) -> bool:
	var cell: Vector2i = HexGrid.world_to_cell(pos / SCALE)
	if not walkable.has(cell):
		return false
	for obstacle: Vector3 in obstacles:
		var dx: float = pos.x - obstacle.x
		var dz: float = pos.z - obstacle.y
		var reach: float = obstacle.z + body_radius
		if dx * dx + dz * dz < reach * reach:
			return false
	return true


func is_floor_at(pos: Vector3) -> bool:
	return walkable.has(HexGrid.world_to_cell(pos / SCALE))


func map_bounds() -> Rect2:
	var rect: Rect2 = HexGrid.bounds_of(walkable.keys())
	return Rect2(rect.position * SCALE, rect.size * SCALE)
