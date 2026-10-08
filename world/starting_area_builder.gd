class_name StartingAreaBuilder
extends WalkableArea
## Builds the small forest clearing the hero wakes up in, from the same KayKit hex pieces as the
## town (per the asset style lock). Deliberately tiny and enclosed: there is nowhere to go but
## the cave mouth. Mirrors `TownBuilder`'s cell/obstacle/anchor model at a much smaller scale.

## 'M' a dense treeline (blocked, walls the clearing in - up close, KayKit's mountain meshes
## are too large to sit right next to the camera, so the wall is trees, not a mountain model),
## 'T' grass with trees (walkable), '#' grass, 'G' cave mouth (the way into the Trial of the
## Hollow), 'S' spawn (where the hero wakes up).
## New brief (third), Part D: 'H' is a hidden tunnel, tucked into the bottom-left corner of the
## treeline where a normal 'M' would be - no marker/glow, just a standard interact prompt once the
## player is genuinely close (see `docs/design/secrets.md`).
## Story v2: 'L' is the Path-ology Lab's hidden entrance in the south treeline. While `lab_open` is false (until Rip opens the forest portal, postgame) it is built and
## blocked exactly like a treeline cell, with nothing to see or to interact with; only the "lab" anchor says where it will be.
## Polish round: 'N' is a camouflaged nook in the treeline with a hidden chest in it (see HIDDEN_CHESTS).
const MAP: Array[String] = [
	"MMMNM",
	"N#G#M",
	"M#T#N",
	"H#S#M",
	"MMLMM",
]

## Polish round: 3 hidden chests in nooks of the treeline: id -> {cell, offset, gold}. Gold only, because the hero has no profile yet (no items, cards or equipment
## exist before the element is chosen). No marker, no glow: the interact prompt (1.5 m) is the only tell. Documented in docs/design/secrets.md.
const HIDDEN_CHESTS: Dictionary = {
	"start_west": {"cell": Vector2i(0, 1), "offset": Vector3(0.45, 0.0, 0.1), "gold": 40},
	"start_east": {"cell": Vector2i(4, 2), "offset": Vector3(-0.4, 0.0, 0.15), "gold": 25},
	"start_cave": {"cell": Vector2i(3, 0), "offset": Vector3(-0.35, 0.0, 0.35), "gold": 70},
}

const OBSTACLE_TREE: float = 0.32

var walkable: Dictionary = {}
var obstacles: Array[Vector3] = []
## Named world positions: "spawn", "gate".
var anchors: Dictionary = {}
var root: Node3D
var clouds: Array[Node3D] = []
## Part H: true once the postgame has revealed the lab entrance (set before `build`).
var lab_open: bool = false
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


## The treeline mixes tall pines, small groves and boulders so the ring is not one blob type (the walkable cells keep the two single trees).
const TREELINE: Array[String] = ["tree_single_A", "tree_single_B", "tree_single_A", "trees_A_small", "trees_B_small", "rock_single_C", "tree_single_B", "trees_A_medium"]


func build(parent: Node3D) -> void:
	_rng.seed = 3
	root = Node3D.new()
	root.name = "StartingArea"
	parent.add_child(root)
	for row: int in range(MAP.size()):
		var line: String = MAP[row]
		for col: int in range(line.length()):
			_build_cell(col, row, line[col])
	_build_hidden_chests()
	_build_far_trees()


func _build_cell(col: int, row: int, symbol: String) -> void:
	var center: Vector3 = HexGrid.cell_to_world(col, row)
	if symbol == "L":
		anchors["lab"] = center + Vector3(0, 0, -0.6)
		if not lab_open:
			symbol = "M"
	ModelKit.place(root, ModelKit.tile("hex_grass"), center)
	if symbol == "M":
		# A dense treeline, close enough together to read as a wall without being walkable.
		for i: int in range(4):
			var offset: Vector3 = _scatter(center, 0.15, 0.85)
			var tree: String = TREELINE[_rng.randi() % TREELINE.size()]
			ModelKit.place(root, ModelKit.nature(tree), offset, _rng.randf() * 360.0, _rng.randf_range(0.9, 1.9))
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
		"H":
			# Hidden tunnel: walkable and camouflaged by trees like 'T', but with no distinct
			# model of its own - matching the town's hidden chests, where only the interact prompt
			# (and only up close) gives a secret away, never a marker or glow.
			for i: int in range(3):
				var offset: Vector3 = _scatter(center, 0.3, 0.8)
				var tree: String = ["tree_single_A", "tree_single_B"][_rng.randi() % 2]
				ModelKit.place(root, ModelKit.nature(tree), offset, _rng.randf() * 360.0, _rng.randf_range(1.1, 1.5))
				obstacles.append(Vector3(offset.x, offset.z, OBSTACLE_TREE * 1.3))
			anchors["tunnel"] = center
		"N":
			for i: int in range(3):
				var offset: Vector3 = _scatter(center, 0.55, 0.95)
				var tree: String = ["tree_single_A", "tree_single_B"][_rng.randi() % 2]
				ModelKit.place(root, ModelKit.nature(tree), offset, _rng.randf() * 360.0, _rng.randf_range(1.1, 1.5))
				obstacles.append(Vector3(offset.x, offset.z, OBSTACLE_TREE * 1.3))
		"L":
			_build_lab_hatch(center)
		"S":
			anchors["spawn"] = center


## id -> the chest's Node3D (the scene opens its lid and keeps it open once looted).
var chest_nodes: Dictionary = {}


func _build_hidden_chests() -> void:
	for id: String in HIDDEN_CHESTS.keys():
		var entry: Dictionary = HIDDEN_CHESTS[id] as Dictionary
		var cell: Vector2i = entry["cell"] as Vector2i
		var pos: Vector3 = HexGrid.cell_to_world(cell.x, cell.y) + (entry["offset"] as Vector3)
		var chest: Node3D = ModelKit.dungeon_prop("chest_gold")
		ModelKit.place(root, chest, pos, _rng.randf() * 360.0, 0.225)
		anchors["hidden_chest_%s" % id] = pos
		obstacles.append(Vector3(pos.x, pos.z, 0.18))
		chest_nodes[id] = chest


func _build_far_trees() -> void:
	# Polish round: the far hex strip is gone; `StartingForest` (built by the scene) surrounds the clearing with forest and a ring of far mountains.
	for i: int in range(2):
		var cloud: Node3D = ModelKit.nature("cloud_small")
		ModelKit.place(root, cloud, Vector3(_rng.randf_range(-4, 12), _rng.randf_range(16, 20), _rng.randf_range(-12, -4)), 0.0, 0.7)
		clouds.append(cloud)


## The Path-ology Lab's hatch (postgame, `lab_open`): a pale steel disc set in the forest floor with a cyan glow ring and a handle, the one thing in the clearing that is
## too clean. Walkable; the scene's `lab` anchor is where the player stands to descend.
func _build_lab_hatch(center: Vector3) -> void:
	var hatch: Node3D = Node3D.new()
	hatch.name = "LabHatch"
	hatch.position = center + Vector3(0.0, 0.03, 0.0)
	root.add_child(hatch)
	var steel: StandardMaterial3D = StandardMaterial3D.new()
	steel.albedo_color = Color("dfe8ea")
	steel.roughness = 0.35
	steel.metallic = 0.4
	var disc: MeshInstance3D = MeshInstance3D.new()
	var cylinder: CylinderMesh = CylinderMesh.new()
	cylinder.top_radius = 0.8
	cylinder.bottom_radius = 0.85
	cylinder.height = 0.12
	disc.mesh = cylinder
	disc.material_override = steel
	hatch.add_child(disc)
	var glow: StandardMaterial3D = StandardMaterial3D.new()
	glow.albedo_color = Color("74e8ff")
	glow.emission_enabled = true
	glow.emission = Color("74e8ff")
	glow.emission_energy_multiplier = 1.6
	var ring: MeshInstance3D = MeshInstance3D.new()
	var torus: TorusMesh = TorusMesh.new()
	torus.inner_radius = 0.72
	torus.outer_radius = 0.84
	ring.mesh = torus
	ring.material_override = glow
	ring.position = Vector3(0.0, 0.08, 0.0)
	hatch.add_child(ring)
	var handle: MeshInstance3D = MeshInstance3D.new()
	var bar: BoxMesh = BoxMesh.new()
	bar.size = Vector3(0.5, 0.08, 0.1)
	handle.mesh = bar
	handle.material_override = steel
	handle.position = Vector3(0.0, 0.14, 0.0)
	hatch.add_child(handle)
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color("74e8ff")
	light.light_energy = 1.2
	light.omni_range = 4.0
	light.position = Vector3(0.0, 0.8, 0.0)
	hatch.add_child(light)


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
