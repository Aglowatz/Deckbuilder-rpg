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
	if lab_open:
		_build_lab_hatch(Vector3(OpeningForestLayout.LAB_POCKET.x, 0.0, OpeningForestLayout.LAB_POCKET.y))


func _build_hidden_chests() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 3
	for id: String in HIDDEN_CHESTS.keys():
		var pos: Vector3 = (HIDDEN_CHESTS[id] as Dictionary)["pos"] as Vector3
		var chest: Node3D = ModelKit.dungeon_prop("chest_gold")
		ModelKit.place(root, chest, pos, rng.randf() * 360.0, 0.225)
		obstacles.append(Vector3(pos.x, pos.z, 0.18))
		chest_nodes[id] = chest


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
