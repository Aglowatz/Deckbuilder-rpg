class_name TownBuilder
extends RefCounted
## Builds the starter town island from KayKit hex pieces and describes where things are:
## which cells can be walked on, where the obstacles are and where the interactable spots sit.
## Used by the title backdrop (just visuals) and by the playable town scene.

## '.' water, '#' grass, 'T' grass with trees, 'M' mountain (blocked), 'R' rocks,
## K market, D deck station, W wellspring, G dungeon gate, H/h houses, S spawn, F windmill, C church.
const MAP: Array[String] = [
	"..MMTTM..",
	"..T#G#TT.",
	".T#H#hF#.",
	".#K##D#T.",
	".T##W##R.",
	"..#C###T.",
	"..R#S#T..",
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
			_build_cell(col, row, line[col])
	if decorate_far:
		_build_far_scenery()
	_build_props()


func cell_center(col: int, row: int) -> Vector3:
	return HexGrid.cell_to_world(col, row)


func _build_water() -> void:
	for row: int in range(-5, MAP.size() + 5):
		for col: int in range(-6, 16):
			var inside: bool = row >= 0 and row < MAP.size() and col >= 0 and col < MAP[0].length() and MAP[row][col] != "."
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
	# A mountain range behind the island, hills at the sides, drifting clouds overhead.
	for col: int in range(-2, 14):
		var far: Vector3 = HexGrid.cell_to_world(col, -4)
		ModelKit.place(root, ModelKit.tile("hex_grass"), far)
		var mountain: String = ["mountain_A_grass_trees", "mountain_B_grass_trees", "mountain_C_grass_trees"][_rng.randi() % 3]
		ModelKit.place(root, ModelKit.nature(mountain), far, float(_rng.randi_range(0, 5)) * 60.0, 1.4)
	for cell: Vector2i in [Vector2i(-2, 1), Vector2i(-2, 4), Vector2i(11, 2), Vector2i(11, 5), Vector2i(12, 0)]:
		var pos: Vector3 = HexGrid.cell_to_world(cell.x, cell.y)
		ModelKit.place(root, ModelKit.tile("hex_grass"), pos)
		ModelKit.place(root, ModelKit.nature(["hills_A_trees", "hills_B_trees"][_rng.randi() % 2]), pos, float(_rng.randi_range(0, 5)) * 60.0)
	for i: int in range(6):
		var cloud: Node3D = ModelKit.nature("cloud_big" if i % 2 == 0 else "cloud_small")
		ModelKit.place(root, cloud, Vector3(_rng.randf_range(-6, 22), _rng.randf_range(7, 10), _rng.randf_range(-14, 8)), 0.0, 2.2)


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
