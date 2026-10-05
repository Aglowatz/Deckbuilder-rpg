class_name CapitalMobs
extends RefCounted
## Procedural models of the Capital's own roaming enemies: the spotless Tidy-Bot, the glass-bright Shard Swarm and the
## person-shaped Rift Wretch. Built from primitives; all face +z and stand on the ground. (Compliance Officers and
## Perfection Inspectors are tinted KayKit characters with little accessories, see `CapitalEnemies`.)

const M = preload("res://world/capital/capital_materials.gd")
const B = preload("res://world/buffet/buffet_props.gd")


static func build(model: String) -> Node3D:
	match model:
		"capital:tidybot":
			return tidy_bot()
		"capital:swarm":
			return shard_swarm()
		"capital:wretch":
			return rift_wretch()
	return Node3D.new()


## A spotless little cleaning automaton: a white barrel on treads with a dome head, a scrub brush and a polite blue light.
static func tidy_bot() -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(0.7, 0.16, 0.5), M.flat(Color(0.2, 0.2, 0.24)), Vector3(0, 0.1, 0))
	B.cylinder(root, 0.3, 0.34, 0.6, M.shiny(M.WHITE, 0.2), Vector3(0, 0.46, 0), 14)
	B.ball(root, 0.28, M.shiny(M.WHITE, 0.2), Vector3(0, 0.84, 0), Vector3.ONE, true)
	B.box(root, Vector3(0.36, 0.09, 0.05), M.glow(Color(0.4, 0.8, 1.0), 2.4), Vector3(0, 0.82, 0.25))
	B.cylinder(root, 0.015, 0.015, 0.3, M.flat(M.STONE_GRAY), Vector3(0.1, 1.1, 0), 5)
	B.ball(root, 0.04, M.glow(Color(1.0, 0.2, 0.2), 2.6), Vector3(0.1, 1.26, 0))
	for side: float in [-1.0, 1.0]:
		B.box(root, Vector3(0.06, 0.06, 0.4), M.flat(M.STONE_GRAY), Vector3(side * 0.38, 0.5, 0.2))
		B.box(root, Vector3(0.22, 0.08, 0.12), M.flat(Color(0.9, 0.7, 0.2)), Vector3(side * 0.38, 0.4, 0.42))
	return root


## Seven glass shards that hang in the air around an invisible centre.
static func shard_swarm() -> Node3D:
	var root: Node3D = Node3D.new()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 77
	for index: int in range(9):
		var shard: MeshInstance3D = MeshInstance3D.new()
		var prism: PrismMesh = PrismMesh.new()
		prism.size = Vector3(0.16, rng.randf_range(0.4, 0.8), 0.08)
		shard.mesh = prism
		shard.material_override = M.glow(M.RIFT_CYAN if index % 2 == 0 else M.RIFT_VIOLET, 1.8)
		shard.position = Vector3(rng.randf_range(-0.5, 0.5), 0.9 + rng.randf_range(-0.4, 0.5), rng.randf_range(-0.5, 0.5))
		shard.rotation_degrees = Vector3(rng.randf_range(0.0, 360.0), rng.randf_range(0.0, 360.0), rng.randf_range(0.0, 360.0))
		root.add_child(shard)
	B.ball(root, 0.18, M.glow(Color(1.0, 1.0, 1.0), 3.0), Vector3(0, 0.9, 0))
	return root


## A person-shaped tear in reality: a dark violet figure with a glowing seam down the chest, hungry eyes and drifting shards.
static func rift_wretch() -> Node3D:
	var root: Node3D = Node3D.new()
	B.cylinder(root, 0.22, 0.4, 1.0, M.translucent(Color(0.2, 0.08, 0.3), 0.92, 0.2), Vector3(0, 0.7, 0), 10)
	B.ball(root, 0.26, M.translucent(Color(0.24, 0.1, 0.34), 0.92, 0.2), Vector3(0, 1.45, 0))
	B.box(root, Vector3(0.07, 0.95, 0.06), M.glow(M.RIFT_VIOLET, 3.0), Vector3(0, 0.95, 0.3))
	for side: float in [-1.0, 1.0]:
		B.ball(root, 0.055, M.glow(M.RIFT_CYAN, 3.0), Vector3(side * 0.1, 1.5, 0.22))
		B.cylinder(root, 0.06, 0.04, 1.0, M.translucent(Color(0.2, 0.08, 0.3), 0.9, 0.2), Vector3(side * 0.45, 0.75, 0.15))
		B.ball(root, 0.09, M.glow(M.RIFT_VIOLET, 2.0), Vector3(side * 0.5, 0.25, 0.2))
	for index: int in range(4):
		var shard: MeshInstance3D = MeshInstance3D.new()
		var prism: PrismMesh = PrismMesh.new()
		prism.size = Vector3(0.1, 0.34, 0.06)
		shard.mesh = prism
		shard.material_override = M.glow(M.RIFT_CYAN, 1.8)
		var angle: float = TAU * float(index) / 4.0
		shard.position = Vector3(cos(angle) * 0.7, 0.4 + 0.5 * float(index % 2), sin(angle) * 0.7)
		shard.rotation_degrees = Vector3(20.0 * float(index), 40.0 * float(index), 15.0)
		root.add_child(shard)
	return root
