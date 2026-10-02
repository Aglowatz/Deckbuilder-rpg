class_name ZonePlaceholderBuilder
extends WalkableArea
## Part G: the reusable "coming soon" zone template - a tiny, tinted clearing with a sign and a
## portal back to town. Built from the same KayKit hex pieces as everywhere else (style lock);
## the only thing that changes per zone is the tint (`ZonePortals.Info.tint`). A real zone
## replaces this builder (and `ZonePlaceholderScene`) outright when one is actually built - this
## is deliberately not meant to be extended, just swapped out.

## 'M' treeline (blocked), '#' grass, 'P' the portal back to town, 'S' spawn.
const MAP: Array[String] = [
	"MMMMM",
	"M#P#M",
	"M#T#M",
	"M#S#M",
	"MMMMM",
]

const OBSTACLE_TREE: float = 0.32

var walkable: Dictionary = {}
var obstacles: Array[Vector3] = []
## Named world positions: "spawn", "portal".
var anchors: Dictionary = {}
var root: Node3D
var tint: Color = Color.WHITE
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func build(parent: Node3D) -> void:
	_rng.seed = 11
	root = Node3D.new()
	root.name = "ZonePlaceholder"
	parent.add_child(root)
	for row: int in range(MAP.size()):
		var line: String = MAP[row]
		for col: int in range(line.length()):
			_build_cell(col, row, line[col])


func cell_center(col: int, row: int) -> Vector3:
	return HexGrid.cell_to_world(col, row)


func _build_cell(col: int, row: int, symbol: String) -> void:
	var center: Vector3 = HexGrid.cell_to_world(col, row)
	# Plain grass (ModelKit.tile already applies its own base green tint) - the zone's identity
	# comes from the portal tower's tint, not from re-tinting the ground on top of that.
	ModelKit.place(root, ModelKit.tile("hex_grass"), center)
	if symbol == "M":
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
		"P":
			var portal: Node3D = ModelKit.building("tower_A")
			ModelKit.tint(portal, tint)
			ModelKit.place(root, portal, center, 180.0, 1.05)
			obstacles.append(Vector3(center.x, center.z, 0.9))
			anchors["portal"] = center + Vector3(0, 0, 1.05)
		"S":
			anchors["spawn"] = center


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


func is_floor_at(pos: Vector3) -> bool:
	return walkable.has(HexGrid.world_to_cell(pos))


func map_bounds() -> Rect2:
	return HexGrid.bounds_of(walkable.keys())
