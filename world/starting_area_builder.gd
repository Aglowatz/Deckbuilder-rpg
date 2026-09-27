class_name StartingAreaBuilder
extends WalkableArea
## Builds the small forest clearing the hero wakes up in, from the same KayKit hex pieces as the
## town (per the asset style lock). Deliberately tiny and enclosed: there is nowhere to go but
## the cave mouth. Mirrors `TownBuilder`'s cell/obstacle/anchor model at a much smaller scale.

## 'M' a dense treeline (blocked, walls the clearing in - up close, KayKit's mountain meshes
## are too large to sit right next to the camera, so the wall is trees, not a mountain model),
## 'T' grass with trees (walkable), '#' grass, 'G' cave mouth (the way into the Trial of the
## Hollow), 'S' spawn (where the hero wakes up).
const MAP: Array[String] = [
	"MMMMM",
	"M#G#M",
	"M#T#M",
	"M#S#M",
	"MMMMM",
]

const OBSTACLE_TREE: float = 0.32

var walkable: Dictionary = {}
var obstacles: Array[Vector3] = []
## Named world positions: "spawn", "gate".
var anchors: Dictionary = {}
var root: Node3D
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func build(parent: Node3D) -> void:
	_rng.seed = 3
	root = Node3D.new()
	root.name = "StartingArea"
	parent.add_child(root)
	for row: int in range(MAP.size()):
		var line: String = MAP[row]
		for col: int in range(line.length()):
			_build_cell(col, row, line[col])
	_build_far_trees()


func _build_cell(col: int, row: int, symbol: String) -> void:
	var center: Vector3 = HexGrid.cell_to_world(col, row)
	ModelKit.place(root, ModelKit.tile("hex_grass"), center)
	if symbol == "M":
		# A dense treeline, close enough together to read as a wall without being walkable.
		for i: int in range(4):
			var offset: Vector3 = _scatter(center, 0.15, 0.85)
			var tree: String = ["tree_single_A", "tree_single_B"][_rng.randi() % 2]
			ModelKit.place(root, ModelKit.nature(tree), offset, _rng.randf() * 360.0, _rng.randf_range(1.2, 1.7))
		return
	walkable[Vector2i(col, row)] = true
	match symbol:
		"T":
			for i: int in range(2):
				var offset: Vector3 = _scatter(center, 0.4, 0.85)
				var tree: String = ["tree_single_A", "tree_single_B"][_rng.randi() % 2]
				ModelKit.place(root, ModelKit.nature(tree), offset, _rng.randf() * 360.0, _rng.randf_range(1.1, 1.5))
				obstacles.append(Vector3(offset.x, offset.z, OBSTACLE_TREE * 1.3))
		"G":
			ModelKit.place(root, ModelKit.building("mine"), center, 0.0, 1.35)
			obstacles.append(Vector3(center.x, center.z, 1.0))
			anchors["gate"] = center + Vector3(0, 0, 1.1)
		"S":
			anchors["spawn"] = center


func _build_far_trees() -> void:
	# A ring of mountains beyond the far (cave) side only, well clear of the camera, which sits
	# close behind the spawn side - KayKit's mountain meshes are large enough to swallow the
	# camera if placed anywhere near it (row 4, the spawn side, must stay clear).
	for col: int in range(-2, 7):
		var far: Vector3 = HexGrid.cell_to_world(col, -3)
		ModelKit.place(root, ModelKit.tile("hex_grass"), far)
		var mountain: String = ["mountain_A_grass_trees", "mountain_B_grass_trees"][_rng.randi() % 2]
		ModelKit.place(root, ModelKit.nature(mountain), far, float(_rng.randi_range(0, 5)) * 60.0, 1.2)
	for i: int in range(3):
		var cloud: Node3D = ModelKit.nature("cloud_small" if i % 2 == 0 else "cloud_big")
		ModelKit.place(root, cloud, Vector3(_rng.randf_range(-4, 12), _rng.randf_range(6, 9), _rng.randf_range(-10, -2)), 0.0, 1.8)


func _scatter(center: Vector3, min_radius: float, max_radius: float) -> Vector3:
	var angle: float = _rng.randf() * TAU
	var distance: float = _rng.randf_range(min_radius, max_radius)
	return center + Vector3(cos(angle), 0.0, sin(angle)) * distance


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
