class_name StartingAreaBuilder
extends WalkableArea
## Builds the Opening Forest the hero wakes up in (docs/art/opening_forest.md): a small clearing with the camp at the front, a worn path winding back and
## right to the cave mouth in a vine-draped cliff under a giant ancient tree, and a side nook. The ground plan is `OpeningForestLayout` (walkable where its
## floor is, minus the solid things on it); the pieces are `OpeningForestModels` (stand-ins until the OF- kit arrives). The forest beyond is
## `StartingForest` (built by the scene). The cave mouth is the way on (the Forgotten Cave, node-based); there is nothing else to enter.
##
## Secrets keep their behaviour: the hidden tunnel (anchor "tunnel", a pocket in the south-west treeline), three hidden chests (no marker, no glow) and,
## postgame, the Path-ology Lab hatch in a south-east pocket that is treeline (no floor, nothing to see) until `lab_open`.

## Polish round: 3 hidden chests: id -> {pos, gold}. Gold only, because the hero has no profile yet (no items, cards or equipment exist before the element
## is chosen). No marker, no glow: the interact prompt (1.5 m) is the only tell. Documented in docs/design/secrets.md.
const HIDDEN_CHESTS: Dictionary = OpeningForestLayout.HIDDEN_CHESTS
## How far inside the floor's edge the hero's centre must stay (the ferns and rocks at the rim read as the wall).
const EDGE_MARGIN: float = 0.1

var layout: OpeningForestLayout
var models: OpeningForestModels
## Solid things on the floor: (x, z, radius).
var obstacles: Array[Vector3] = []
## Named world positions: "spawn", "gate", "tunnel", "lab", "hidden_chest_<id>" (the scene adds the postgame "station" and "rescuer").
var anchors: Dictionary = {}
var root: Node3D
var clouds: Array[Node3D] = []
## Part H: true once the postgame has revealed the lab entrance (set before `build`).
var lab_open: bool = false
## id -> the chest's Node3D (the scene opens its lid and keeps it open once looted).
var chest_nodes: Dictionary = {}


func _init() -> void:
	layout = OpeningForestLayout.new()


func build(parent: Node3D) -> void:
	layout = OpeningForestLayout.new(lab_open)
	root = Node3D.new()
	root.name = "StartingArea"
	parent.add_child(root)
	anchors = layout.anchors()
	obstacles.append_array(layout.blockers())
	models = OpeningForestModels.build(root, layout)
	for obstacle: Vector3 in models.obstacles:
		if layout.floor_sdf(Vector2(obstacle.x, obstacle.y)) < obstacle.z + 0.5:
			obstacles.append(obstacle)
	_build_hidden_chests()
	_build_kit_pieces()
	if lab_open:
		_build_lab_hatch(Vector3(OpeningForestLayout.LAB_POCKET.x, 0.0, OpeningForestLayout.LAB_POCKET.y))
	else:
		_build_brambles()


## Fix pass Nov 4 (B), Part 3.4: until the Lab is revealed a low bramble thicket fills the gap in the clearing's south rim where its path will run: thorny
## dark lumps and arching canes, knee to waist high (the camera looks over it), solid. The forest blocks the way, not an invisible wall.
func _build_brambles() -> void:
	var center: Vector3 = Vector3(OpeningForestLayout.BRAMBLES.x, 0.0, OpeningForestLayout.BRAMBLES.y)
	var radius: float = OpeningForestLayout.BRAMBLES.z
	var mesh: KitMesh = KitMesh.new()
	var leaf: StandardMaterial3D = StandardMaterial3D.new()
	leaf.vertex_color_use_as_albedo = true
	leaf.roughness = 0.95
	mesh.set_material("bramble", leaf)
	var cane: StandardMaterial3D = StandardMaterial3D.new()
	cane.albedo_color = Color(0.3, 0.18, 0.16)
	mesh.set_material("cane", cane)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 41
	for k: int in range(14):
		var angle: float = rng.randf() * TAU
		var at: Vector3 = center + Vector3(cos(angle), 0.0, sin(angle)) * radius * sqrt(rng.randf())
		var size: float = rng.randf_range(0.6, 1.0)
		mesh.blob("bramble", at + Vector3(0.0, 0.32 * size, 0.0), Vector3(0.8, 0.55, 0.75) * size, 4, 8, 0.6, Color(0.24, 0.27, 0.2).lerp(Color(0.33, 0.2, 0.22), rng.randf()))
	for k: int in range(16):
		var angle: float = rng.randf() * TAU
		var root_at: Vector3 = center + Vector3(cos(angle), 0.0, sin(angle)) * radius * rng.randf_range(0.2, 0.9)
		var tip: Vector3 = root_at + Vector3(rng.randf_range(-0.9, 0.9), rng.randf_range(0.7, 1.1), rng.randf_range(-0.9, 0.9))
		mesh.tube("cane", root_at, tip, 0.04, 5, false)
	var body: MeshInstance3D = mesh.instance("Brambles")
	body.position = Vector3.ZERO
	root.add_child(body)
	for k: int in range(5):
		var t: float = float(k) / 4.0
		obstacles.append(Vector3(center.x - radius + t * radius * 2.0, center.z + (0.4 if k % 2 == 0 else -0.4), 0.9))


func _build_hidden_chests() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 3
	for id: String in HIDDEN_CHESTS.keys():
		var pos: Vector3 = (HIDDEN_CHESTS[id] as Dictionary)["pos"] as Vector3
		var chest: Node3D = ModelKit.dungeon_prop("chest_gold")
		ModelKit.place(root, chest, pos, rng.randf() * 360.0, ChestKit.SCALE)
		obstacles.append(Vector3(pos.x, pos.z, ChestKit.FOOTPRINT))
		chest_nodes[id] = chest


## Art import Oct 29: the painted cave mouth in front of the rock arch (the Forgotten Cave's mossy Old Kingdom gate, the first landmark of
## the game) and three giant mossy trees at the clearing's edge. Both stand outside the floor (the mouth's blocker already stops the hero).
const CAVE_MOUTH_HEIGHT: float = 6.6
const CAVE_MOUTH_FORWARD: float = 0.9
## The mouth reads as the destination in the dusk: lifted out of the teal mood a little (the trees keep it).
const CAVE_MOUTH_BRIGHTEN: float = 1.7
## (x, z, height): the giant trees, beyond the treeline on the west and east, none on the camera side.
const GIANT_TREES: Array[Vector3] = [Vector3(-7.0, -5.0, 15.0), Vector3(-5.8, -13.2, 17.0), Vector3(15.6, -9.6, 16.0)]
const GIANT_TREE_BRIGHTEN: float = 1.3
const GIANT_TREE_IDS: Array[String] = ["OF-TREE-GIANT-01", "OF-TREE-GIANT-02", "OF-TREE-GIANT-03"]


func _build_kit_pieces() -> void:
	var mouth: Vector3 = layout.mark("cave_mouth")
	KitPieces.stand(root, "OF-HERO-CAVE-MOUTH", mouth + Vector3(0.0, -0.05, CAVE_MOUTH_FORWARD), CAVE_MOUTH_HEIGHT, false, CAVE_MOUTH_BRIGHTEN)
	for index: int in range(GIANT_TREES.size()):
		var spot: Vector3 = GIANT_TREES[index]
		var p: Vector2 = Vector2(spot.x, spot.y)
		if layout.floor_sdf(p) < 1.6 or layout.camera_side(p):
			continue
		KitPieces.stand(root, GIANT_TREE_IDS[index], Vector3(spot.x, -0.1, spot.y), spot.z, true, GIANT_TREE_BRIGHTEN)


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
	# Art import Oct 29: the painted hatch (OF-PROP-LAB-HATCH: steel, roots, a sickly seam of light) replaces the steel disc, its glow ring and handle (the light stays).
	var painted: bool = KitPieces.ground(hatch, "OF-PROP-LAB-HATCH", Vector3(0.0, 0.03, 0.0), 0.0, 2.1) != null
	if not painted:
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
	if not painted:
		hatch.add_child(ring)
	var handle: MeshInstance3D = MeshInstance3D.new()
	var bar: BoxMesh = BoxMesh.new()
	bar.size = Vector3(0.5, 0.08, 0.1)
	handle.mesh = bar
	handle.material_override = steel
	handle.position = Vector3(0.0, 0.14, 0.0)
	if painted:
		disc.free()
		ring.free()
		handle.free()
	else:
		hatch.add_child(handle)
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color("74e8ff")
	light.light_energy = 1.2
	light.omni_range = 4.0
	light.position = Vector3(0.0, 0.8, 0.0)
	hatch.add_child(light)


func is_walkable(pos: Vector3, body_radius: float = StorybookScale.BODY_RADIUS) -> bool:
	if layout.floor_sdf(Vector2(pos.x, pos.z)) > -EDGE_MARGIN:
		return false
	for obstacle: Vector3 in obstacles:
		var dx: float = pos.x - obstacle.x
		var dz: float = pos.z - obstacle.y
		var reach: float = obstacle.z + body_radius
		if dx * dx + dz * dz < reach * reach:
			return false
	return true


func is_floor_at(pos: Vector3) -> bool:
	return layout.is_floor(Vector2(pos.x, pos.z))


## Dirt on the worn path and the camp, the forest floor's grass and moss elsewhere.
func surface_at(pos: Vector3) -> StringName:
	var p: Vector2 = Vector2(pos.x, pos.z)
	if layout.path_distance(p) < OpeningForestLayout.PATH_HALF * 0.8 or p.distance_to(Vector2(OpeningForestLayout.SPAWN.x, OpeningForestLayout.SPAWN.z)) < 2.6:
		return &"dirt"
	return &"grass"


func map_bounds() -> Rect2:
	return layout.bounds()
