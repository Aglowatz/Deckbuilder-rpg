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
##   - **West Woods** (cols -6..-1, rows 0-9): winding forest leading to the Root entrance at the
##     west edge.
##   - **Harbor Dock** (cols 15-20, rows 0-9): the Harbor Quarter's canal continuing out to the
##     Tide entrance at the east edge.
##   - **Ember Flats** (rows 10-14): open ground south of the Secluded Grove leading to the Ember
##     entrance at the south edge.
##   - **Grave Hollow** (the southwest corner: rows 10-12, cols -6..-1): a misty pocket off the
##     Ember Flats leading to the Grave entrance at the west edge.
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
	"#.#T....MMTTM..MMTTMMR##T#T",
	"#R#MT#..T#G#TT.TT##RT#MRM.#",
	"##.####T#H#hF#.T#Y#T##T###R",
	"RR######K##D#T#T####T#####T",
	"#######T##W##R.T##Z#T######",
	"R##TTT..#C###T.T####T##.#.#",
	"RTT#T#..R#S#T..T##T######T#",
	"#T##T#..TT###TT##T....#TTMM",
	"T#T#R#..T#####X###T..RTTT#.",
	"M#####..MTTT#T#TTTM..#MM#.#",
	"#.##T###T#TT##MM##T#T......",
	"################.###M......",
	"T#T#.TT#T######T..##T......",
	".......#T###.#T#####T......",
	"......TM###M##R.##T#.......",
]

const OBSTACLE_TREE: float = 0.32
const OBSTACLE_ROCK: float = 0.35

## Grid cells the player may stand on.
var walkable: Dictionary = {}
## Circular obstacles as Vector3(x, z, radius).
var obstacles: Array[Vector3] = []
## Named world positions: "spawn", "market", "well", "gate", "deck", plus NPC spots.
var anchors: Dictionary = {}
var root: Node3D
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func build(parent: Node3D, decorate_far: bool = true) -> void:
	_rng.seed = 7
	root = Node3D.new()
	root.name = "Town"
	parent.add_child(root)
	_build_water()
	for row: int in range(MAP.size()):
		var line: String = MAP[row]
		for col: int in range(line.length()):
			_build_cell(col - COL_OFFSET, row - ROW_OFFSET, line[col])
	if decorate_far:
		_build_far_scenery()
	_build_props()
	_build_zone_portals()


func cell_center(col: int, row: int) -> Vector3:
	return HexGrid.cell_to_world(col, row)


## `pad` cells of open water surround the island past its actual (map-size-derived) edges, so
## this keeps working regardless of how big MAP is instead of a hand-tuned bounding box.
const WATER_PAD: int = 5


func _build_water() -> void:
	for row: int in range(-ROW_OFFSET - WATER_PAD, MAP.size() - ROW_OFFSET + WATER_PAD):
		for col: int in range(-COL_OFFSET - WATER_PAD, MAP[0].length() - COL_OFFSET + WATER_PAD):
			var map_row: int = row + ROW_OFFSET
			var map_col: int = col + COL_OFFSET
			var inside: bool = map_row >= 0 and map_row < MAP.size() and map_col >= 0 and map_col < MAP[0].length() and MAP[map_row][map_col] != "."
			if inside:
				continue
			var water: Node3D = ModelKit.tile("hex_water")
			ModelKit.place(root, water, HexGrid.cell_to_world(col, row))


func _build_cell(col: int, row: int, symbol: String) -> void:
	if symbol == ".":
		return
	var center: Vector3 = HexGrid.cell_to_world(col, row)
	ModelKit.place(root, ModelKit.tile("hex_grass"), center)
	var yaw: float = float(_rng.randi_range(0, 5)) * 60.0
	match symbol:
		"M":
			var mountain: String = ["mountain_A_grass_trees", "mountain_B_grass_trees", "mountain_C_grass_trees"][_rng.randi() % 3]
			ModelKit.place(root, ModelKit.nature(mountain), center, yaw)
			return
		"T":
			walkable[Vector2i(col, row)] = true
			for i: int in range(3):
				var offset: Vector3 = _scatter(center, 0.4, 0.85)
				var tree: String = ["tree_single_A", "tree_single_B"][_rng.randi() % 2]
				ModelKit.place(root, ModelKit.nature(tree), offset, _rng.randf() * 360.0, _rng.randf_range(1.1, 1.5))
				obstacles.append(Vector3(offset.x, offset.z, OBSTACLE_TREE * 1.3))
		"R":
			walkable[Vector2i(col, row)] = true
			var rock_pos: Vector3 = _scatter(center, 0.2, 0.7)
			ModelKit.place(root, ModelKit.nature("rock_single_%s" % ["A", "B", "C", "D", "E"][_rng.randi() % 5]), rock_pos, _rng.randf() * 360.0, 1.3)
			obstacles.append(Vector3(rock_pos.x, rock_pos.z, OBSTACLE_ROCK * 1.3))
		"K":
			walkable[Vector2i(col, row)] = true
			_building("market", center, 0.0, 1.25, 1.1)
			anchors["market"] = center + Vector3(0, 0, 1.15)
		"D":
			walkable[Vector2i(col, row)] = true
			_building("tavern", center, 0.0, 1.25, 0.95)
			anchors["deck"] = center + Vector3(0, 0, 1.1)
		"W":
			walkable[Vector2i(col, row)] = true
			_building("well", center, 0.0, 1.5, 0.6)
			anchors["well"] = center + Vector3(0, 0, 0.9)
		"G":
			walkable[Vector2i(col, row)] = true
			_building("mine", center, 0.0, 1.35, 1.0)
			anchors["gate"] = center + Vector3(0, 0, 1.1)
		"H":
			walkable[Vector2i(col, row)] = true
			_building("home_A", center, -15.0, 1.35, 0.7)
		"h":
			walkable[Vector2i(col, row)] = true
			_building("home_B", center, 15.0, 1.35, 0.7)
		"F":
			walkable[Vector2i(col, row)] = true
			_building("windmill", center, 0.0, 1.25, 0.8)
		"C":
			walkable[Vector2i(col, row)] = true
			_building("church", center, 0.0, 1.2, 0.85)
		"Y":
			walkable[Vector2i(col, row)] = true
			_building("tower_A", center, 0.0, 1.3, 0.85)
			anchors["codex"] = center + Vector3(0, 0, 1.05)
		"Z":
			walkable[Vector2i(col, row)] = true
			_building("blacksmith", center, 0.0, 1.25, 0.9)
			anchors["hidden_vendor"] = center + Vector3(0, 0, 1.05)
		"X":
			walkable[Vector2i(col, row)] = true
			_building("castle", center, 0.0, 1.1, 1.15)
			anchors["vault"] = center + Vector3(0, 0, 1.3)
		"S":
			walkable[Vector2i(col, row)] = true
			anchors["spawn"] = center
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
		var far: Vector3 = HexGrid.cell_to_world(col, far_row)
		ModelKit.place(root, ModelKit.tile("hex_grass"), far)
		var mountain: String = ["mountain_A_grass_trees", "mountain_B_grass_trees", "mountain_C_grass_trees"][_rng.randi() % 3]
		ModelKit.place(root, ModelKit.nature(mountain), far, float(_rng.randi_range(0, 5)) * 60.0, 1.4)
	var hill_cells: Array[Vector2i] = [
		Vector2i(west_edge - 2, 1), Vector2i(west_edge - 2, 6), Vector2i(west_edge - 2, 11),
		Vector2i(east_edge + 2, 2), Vector2i(east_edge + 2, 7), Vector2i(east_edge + 2, 0),
	]
	for cell: Vector2i in hill_cells:
		var pos: Vector3 = HexGrid.cell_to_world(cell.x, cell.y)
		ModelKit.place(root, ModelKit.tile("hex_grass"), pos)
		ModelKit.place(root, ModelKit.nature(["hills_A_trees", "hills_B_trees"][_rng.randi() % 2]), pos, float(_rng.randi_range(0, 5)) * 60.0)
	for i: int in range(9):
		var cloud: Node3D = ModelKit.nature("cloud_big" if i % 2 == 0 else "cloud_small")
		ModelKit.place(root, cloud, Vector3(_rng.randf_range(west_edge - 5, east_edge + 7), _rng.randf_range(7, 10), _rng.randf_range(far_row - 5, 8)), 0.0, 2.2)


func _build_props() -> void:
	var market: Vector3 = anchors.get("market", Vector3.ZERO) as Vector3
	_prop("crate_A_big", market + Vector3(-1.0, 0, -0.5), 20.0, 1.1, 0.3)
	_prop("barrel", market + Vector3(1.1, 0, -0.4), 0.0, 1.1, 0.25)
	_prop("sack", market + Vector3(0.9, 0, 0.3), 30.0, 1.1, 0.0)
	var gate: Vector3 = anchors.get("gate", Vector3.ZERO) as Vector3
	_prop("weaponrack", gate + Vector3(-1.2, 0, -0.3), 10.0, 1.2, 0.3)
	_prop("flag_blue", gate + Vector3(1.0, 0, -0.2), 0.0, 1.3, 0.15)
	var deck: Vector3 = anchors.get("deck", Vector3.ZERO) as Vector3
	_prop("barrel", deck + Vector3(1.05, 0, -0.5), 0.0, 1.1, 0.25)
	_prop("bucket_water", deck + Vector3(-1.0, 0, 0.0), 0.0, 1.2, 0.0)
	var spawn: Vector3 = anchors.get("spawn", Vector3.ZERO) as Vector3
	_prop("tent", spawn + Vector3(-1.6, 0, -0.8), 25.0, 1.1, 0.7)
	_prop("wheelbarrow", spawn + Vector3(1.4, 0, -0.9), -30.0, 1.1, 0.3)
	_prop("target", cell_center(6, 5) + Vector3(0.2, 0, 0.0), 200.0, 1.1, 0.35)
	anchors["npc_well"] = (anchors.get("well", Vector3.ZERO) as Vector3) + Vector3(1.5, 0, 0.6)
	anchors["npc_gate"] = gate + Vector3(-2.0, 0, 0.9)
	anchors["npc_market"] = market + Vector3(0.1, 0, 0.55)
	# New brief, Part F: the item vendor's stall (Wick), a short walk from the card vendor.
	var item_vendor_center: Vector3 = cell_center(10, 5)
	_building("barracks", item_vendor_center, -20.0, 1.2, 0.85)
	anchors["item_vendor"] = item_vendor_center + Vector3(0, 0, 1.05)
	anchors["npc_item_vendor"] = item_vendor_center + Vector3(1.0, 0, 0.6)
	# New brief, Part C: the equipment vendor's stall, a short walk south of the item vendor.
	var equipment_vendor_center: Vector3 = cell_center(10, 7)
	_building("blacksmith", equipment_vendor_center, 20.0, 1.25, 0.9)
	anchors["equipment_vendor"] = equipment_vendor_center + Vector3(0, 0, 1.05)
	anchors["npc_equipment_vendor"] = equipment_vendor_center + Vector3(1.0, 0, 0.6)
	# New brief, Part E: 4 corrupted NPCs, one per element district, close enough to their own
	# district's edge gate to read as "belongs to that zone" without blocking the district's main
	# path. Visual corruption (tint + particle effect) is TownScene's job, not the builder's.
	anchors["npc_ember"] = cell_center(5, 10) + Vector3(0.3, 0, 0.4)
	anchors["npc_tide"] = cell_center(16, 3) + Vector3(-0.3, 0, 0.4)
	anchors["npc_root"] = cell_center(-3, 2) + Vector3(0.3, 0, -0.3)
	anchors["npc_grave"] = cell_center(-3, 11) + Vector3(0.3, 0, 0.3)
	# Secluded Grove secrets: a chest tucked behind trees, and the old lever that seals the vault.
	var chest_pos: Vector3 = cell_center(11, 7) + Vector3(-0.3, 0, 0.4)
	ModelKit.place(root, ModelKit.dungeon_prop("chest_gold"), chest_pos, 40.0, 0.9)
	anchors["chest"] = chest_pos + Vector3(0.5, 0, 0.5)
	var lever_pos: Vector3 = (anchors.get("vault", Vector3.ZERO) as Vector3) + Vector3(1.4, 0, -0.6)
	ModelKit.place(root, ModelKit.prop("ladder"), lever_pos, 90.0, 1.0)
	obstacles.append(Vector3(lever_pos.x, lever_pos.z, 0.2))
	anchors["lever"] = lever_pos + Vector3(0.4, 0, 0.2)
	_build_hidden_chests()
	_build_dev_shrine()
	_build_graveyard()


## New brief (third), Part E: a debug-only "Dev Shrine" at the very bottom (south) edge of the
## town map, Ember Flats row - each interaction grants one level via the real level-up flow.
## Gated by DevTools.shrine_enabled() here, at the builder level, so it does not exist as a 3D
## object at all (not just an unreachable interaction) once DevTools says no - see D88 for why
## that matters for an exported release build specifically.
func _build_dev_shrine() -> void:
	if not DevTools.shrine_enabled():
		return
	var pos: Vector3 = cell_center(10, 14)
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
	var base: Node3D = ModelKit.nature("rock_single_E")
	ModelKit.tint(base, Color(0.35, 0.35, 0.38))
	cairn.add_child(base)
	var top: Node3D = ModelKit.nature("rock_single_D")
	ModelKit.tint(top, Color(0.3, 0.3, 0.33))
	top.position = Vector3(0.05, 0.35, -0.05)
	top.scale = Vector3.ONE * 0.7
	cairn.add_child(top)
	ModelKit.place(root, cairn, center, _rng.randf() * 360.0, 1.15)
	obstacles.append(Vector3(center.x, center.z, 0.45))
	anchors["graveyard_cairn"] = center + Vector3(0.0, 0, 1.1)
	# Grave markers: no dedicated tombstone model exists in either approved pack, so plain rocks
	# stand in for them (an honest reuse, same spirit as the equipment vendor's blacksmith
	# building or Wendell Cobb's Knight model) - tinted a flatter grey so they read as worked
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
## misty hollow, on a quiet overlook, in a stand of trees off the Ember Flats - not clustered in
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
	"ember_flats": Vector2i(9, 12), "west_woods": Vector2i(-4, 5), "harbor_dock": Vector2i(17, 6),
	"grave_hollow": Vector2i(-4, 12), "uplands": Vector2i(8, -2),
	"uplands_ridge": Vector2i(11, -3), "harbor_dock_back": Vector2i(16, 2),
}
const HIDDEN_CHEST_OFFSETS: Dictionary = {
	"west_woods": Vector3(0.35, 0, -0.25), "harbor_dock": Vector3(-0.3, 0, 0.35),
	"grave_hollow": Vector3(0.3, 0, 0.3), "uplands": Vector3(-0.25, 0, -0.35),
	"ember_flats": Vector3(0.3, 0, -0.3),
	"uplands_ridge": Vector3(0.3, 0, 0.25), "harbor_dock_back": Vector3(-0.25, 0, 0.3),
}


## id -> the chest's Node3D, so TownScene can play an open animation on the real model.
var hidden_chest_nodes: Dictionary = {}


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
	"final": Vector2i(4, -5), "root": Vector2i(-6, 4), "tide": Vector2i(20, 4),
	"ember": Vector2i(7, 14), "grave": Vector2i(-6, 11),
}


func _build_zone_portals() -> void:
	for info: ZonePortals.Info in ZonePortals.all():
		var cell: Vector2i = PORTAL_CELLS.get(info.id, Vector2i.ZERO) as Vector2i
		var center: Vector3 = cell_center(cell.x, cell.y)
		var portal: Node3D = ModelKit.building("tower_A")
		ModelKit.tint(portal, info.tint)
		ModelKit.place(root, portal, center, 0.0, 1.05)
		obstacles.append(Vector3(center.x, center.z, 0.85))
		anchors["portal_%s" % info.id] = center + _portal_approach_offset(info.id)


## The interact anchor sits on the walkable, map-facing side of each edge gate (not a fixed
## direction) so the prompt/click target is always on the side the player actually approaches
## from.
func _portal_approach_offset(zone_id: String) -> Vector3:
	match zone_id:
		"final":
			return Vector3(0, 0, 1.0) # north edge - approach from the south
		"root":
			return Vector3(1.0, 0, 0) # west edge - approach from the east
		"tide":
			return Vector3(-1.0, 0, 0) # east edge - approach from the west
		"ember":
			return Vector3(0, 0, -1.0) # south edge - approach from the north
		"grave":
			return Vector3(1.0, 0, 0) # southwest corner - approach from the east
		_:
			return Vector3(0, 0, 1.0)


func _prop(model: String, position: Vector3, yaw: float, model_scale: float, radius: float) -> void:
	ModelKit.place(root, ModelKit.prop(model), position, yaw, model_scale)
	if radius > 0.0:
		obstacles.append(Vector3(position.x, position.z, radius))


## True when a character may stand at `pos` (on a walkable cell and clear of obstacles).
func is_walkable(pos: Vector3, body_radius: float = 0.22) -> bool:
	var cell: Vector2i = HexGrid.world_to_cell(pos)
	if not walkable.has(cell):
		return false
	for obstacle: Vector3 in obstacles:
		var dx: float = pos.x - obstacle.x
		var dz: float = pos.z - obstacle.y
		var reach: float = obstacle.z + body_radius
		if dx * dx + dz * dz < reach * reach:
			return false
	return true
