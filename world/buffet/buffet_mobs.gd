class_name BuffetMobs
extends RefCounted
## Procedural food-golem models of the Endless Buffet, built from Kenney Food Kit pieces and primitives in the
## shared palette: the three roaming enemies (Meatloaf Golem, Gelatin Sentinel, Runaway Meatball) and the three
## gate guardians (Brisket, Sir Loin, Colonel Casserole). All face +z and stand on the ground.

const M = preload("res://world/buffet/buffet_materials.gd")
const P = preload("res://world/buffet/buffet_props.gd")


static func build(model: String) -> Node3D:
	match model:
		"buffet:loaf":
			return meatloaf_golem()
		"buffet:jelly":
			return gelatin_sentinel()
		"buffet:meatball":
			return runaway_meatball()
		"buffet:casserole":
			return gate_golem("casserole")
	return Node3D.new()


## Two big googly eyes on the front, with pupils and optional angry brows.
static func face(parent: Node3D, y: float, z: float, spread: float, size: float, angry: bool = true) -> void:
	for side: float in [-1.0, 1.0]:
		P.ball(parent, size, M.flat(Color(1, 1, 1)), Vector3(side * spread, y, z))
		P.ball(parent, size * 0.5, M.flat(Color(0.06, 0.04, 0.05)), Vector3(side * spread, y - size * 0.05, z + size * 0.75))
		if angry:
			var brow: MeshInstance3D = P.box(parent, Vector3(size * 1.9, size * 0.35, size * 0.5), M.flat(Color(0.18, 0.08, 0.05)), Vector3(side * spread, y + size * 1.2, z + size * 0.4), Vector3(0, 0, side * 22.0))
			brow.name = "Brow"


## The Meatloaf Golem: a lumbering loaf with a ketchup glaze, sausage arms and strong opinions.
static func meatloaf_golem() -> Node3D:
	var root: Node3D = Node3D.new()
	var body: Node3D = BuffetModels.food("loaf")
	root.add_child(body)
	body.scale = Vector3(1.9, 2.5, 2.2)
	body.position = Vector3(0, 0.0, 0)
	ModelKit.tint(body, Color(1.0, 0.7, 0.55))
	# The ketchup glaze across the top.
	P.box(root, Vector3(0.95, 0.07, 0.5), M.flat(Color(0.86, 0.12, 0.14)), Vector3(0, 1.12, 0), Vector3(0, 0, 0))
	for index: int in range(4):
		P.ball(root, 0.07, M.flat(Color(0.86, 0.12, 0.14)), Vector3(-0.34 + float(index) * 0.22, 1.02, 0.28), Vector3(1, 2.4, 1))
	face(root, 0.82, 0.38, 0.22, 0.12)
	# A grumpy mouth.
	P.box(root, Vector3(0.36, 0.06, 0.06), M.flat(Color(0.2, 0.06, 0.05)), Vector3(0, 0.5, 0.46))
	# Sausage arms and stubby bun-heel feet.
	for side: float in [-1.0, 1.0]:
		var arm: Node3D = BuffetModels.food("sausage")
		root.add_child(arm)
		arm.scale = Vector3.ONE * 2.2
		arm.position = Vector3(side * 0.66, 0.55, 0.2)
		arm.rotation_degrees = Vector3(0, 90, side * 70.0)
		P.ball(root, 0.2, M.flat(Color(0.88, 0.58, 0.28)), Vector3(side * 0.28, 0.12, 0.1), Vector3(1, 0.7, 1.4))
	return root


## The Gelatin Sentinel: a quivering lime block with fruit floating inside, a whipped-cream hat and a spoon spear.
static func gelatin_sentinel() -> Node3D:
	var root: Node3D = Node3D.new()
	var jelly: MeshInstance3D = P.box(root, Vector3(0.95, 1.05, 0.95), M.translucent(Color(0.5, 1.0, 0.45), 0.72, 0.5, 0.05), Vector3(0, 0.62, 0))
	jelly.name = "Jelly"
	P.box(root, Vector3(1.05, 0.12, 1.05), M.flat(Color(0.97, 0.94, 0.88)), Vector3(0, 0.05, 0))
	# Fruit suspended in the jelly.
	P.ball(root, 0.12, M.flat(Color(0.95, 0.2, 0.25)), Vector3(-0.22, 0.38, -0.1))
	P.ball(root, 0.1, M.flat(Color(1.0, 0.7, 0.15)), Vector3(0.25, 0.55, -0.15))
	P.ball(root, 0.09, M.flat(Color(0.7, 0.2, 0.7)), Vector3(0.05, 0.3, -0.2))
	face(root, 0.7, 0.45, 0.2, 0.1, false)
	P.box(root, Vector3(0.22, 0.05, 0.05), M.flat(Color(0.2, 0.08, 0.1)), Vector3(0, 0.42, 0.49))
	# Whipped cream hat with a cherry.
	P.ball(root, 0.36, M.flat(Color(1, 1, 1)), Vector3(0, 1.1, 0), Vector3(1.0, 0.6, 1.0))
	P.ball(root, 0.22, M.flat(Color(1, 1, 1)), Vector3(0, 1.32, 0), Vector3(1.0, 0.7, 1.0))
	P.ball(root, 0.1, M.glow(Color(0.9, 0.1, 0.2), 0.6), Vector3(0, 1.5, 0))
	# The spoon spear.
	var spoon: Node3D = BuffetModels.food("cooking-spoon")
	root.add_child(spoon)
	spoon.scale = Vector3.ONE * 2.2
	spoon.position = Vector3(0.62, 0.78, 0.15)
	spoon.rotation_degrees = Vector3(0, 0, 90)
	return root


## The Runaway Meatball: a brown ball with sauce streaks and angry eyes. The "roller" node spins as it moves.
static func runaway_meatball() -> Node3D:
	var root: Node3D = Node3D.new()
	var roller: Node3D = Node3D.new()
	roller.name = "Roller"
	root.add_child(roller)
	roller.position = Vector3(0, 0.45, 0)
	P.ball(roller, 0.45, M.flat(Color(0.52, 0.28, 0.16)), Vector3.ZERO)
	for index: int in range(6):
		var angle: float = TAU * float(index) / 6.0
		P.ball(roller, 0.1, M.flat(Color(0.82, 0.12, 0.12)), Vector3(cos(angle) * 0.4, sin(angle * 2.0) * 0.25, sin(angle) * 0.4), Vector3(1.2, 0.5, 1.0))
	root.set_meta("roller", roller)
	# The face stays on the front (it does not roll).
	face(root, 0.58, 0.38, 0.17, 0.09)
	# A trailing strand of spaghetti.
	for index: int in range(3):
		P.box(root, Vector3(0.05, 0.03, 0.6), M.flat(Color(1.0, 0.88, 0.5)), Vector3(-0.15 + float(index) * 0.15, 0.2, -0.7), Vector3(0, float(index) * 12.0 - 12.0, 0))
	return root


## The gate guardians (about twice the height of the player): `kind` is "ingredient" (Brisket), "quest" (Sir Loin)
## or "casserole"/"battle" (Colonel Casserole).
static func gate_golem(kind: String) -> Node3D:
	var root: Node3D = Node3D.new()
	match kind:
		"ingredient":
			# Brisket: a big smoked slab with grill marks, a doorman's cap and a clipboard.
			P.box(root, Vector3(1.7, 2.1, 1.0), M.flat(Color(0.55, 0.28, 0.17)), Vector3(0, 1.15, 0))
			P.box(root, Vector3(1.78, 0.2, 1.08), M.flat(Color(0.95, 0.9, 0.8)), Vector3(0, 0.15, 0))
			for index: int in range(5):
				P.box(root, Vector3(1.72, 0.07, 0.04), M.flat(Color(0.22, 0.1, 0.07)), Vector3(0, 0.5 + float(index) * 0.34, 0.52), Vector3(0, 0, 8.0))
			face(root, 1.75, 0.5, 0.36, 0.17)
			P.box(root, Vector3(1.1, 0.22, 0.9), M.flat(Color(0.12, 0.2, 0.45)), Vector3(0, 2.45, 0.05))
			P.box(root, Vector3(1.1, 0.07, 0.5), M.flat(Color(0.06, 0.1, 0.25)), Vector3(0, 2.33, 0.62))
			P.ball(root, 0.09, M.glow(Color(1.0, 0.85, 0.2), 1.0), Vector3(0, 2.47, 0.55))
			for side: float in [-1.0, 1.0]:
				P.cylinder(root, 0.2, 0.22, 1.3, M.flat(Color(0.5, 0.25, 0.15)), Vector3(side * 1.05, 1.05, 0.1), 8)
				P.ball(root, 0.28, M.flat(Color(0.5, 0.25, 0.15)), Vector3(side * 1.05, 0.4, 0.1))
			P.box(root, Vector3(0.6, 0.8, 0.06), M.flat(Color(0.95, 0.93, 0.85)), Vector3(-1.05, 1.0, 0.55), Vector3(-15, 0, 12))
		"quest":
			# Sir Loin: a T-bone steak knight with a bucket helm, a fork-lance and a plate shield.
			P.box(root, Vector3(1.7, 2.0, 0.6), M.flat(Color(0.82, 0.3, 0.32)), Vector3(0, 1.1, 0))
			P.box(root, Vector3(1.8, 2.1, 0.5), M.flat(Color(0.97, 0.9, 0.8)), Vector3(0, 1.1, -0.04))
			P.box(root, Vector3(1.6, 1.9, 0.62), M.flat(Color(0.82, 0.3, 0.32)), Vector3(0, 1.1, 0.0))
			P.box(root, Vector3(0.22, 1.5, 0.66), M.flat(Color(0.98, 0.96, 0.9)), Vector3(0.2, 1.0, 0.0))
			P.box(root, Vector3(1.1, 0.2, 0.66), M.flat(Color(0.98, 0.96, 0.9)), Vector3(-0.2, 1.65, 0.0))
			P.cylinder(root, 0.5, 0.56, 0.7, M.shiny(M.STEEL, 0.2), Vector3(0, 2.4, 0.0), 12)
			P.box(root, Vector3(0.7, 0.1, 0.1), M.flat(Color(0.08, 0.06, 0.06)), Vector3(0, 2.42, 0.5))
			for index: int in range(3):
				P.ball(root, 0.2, M.flat(M.LETTUCE.lightened(0.1 * float(index))), Vector3(-0.15 + float(index) * 0.15, 2.9 + 0.07 * float(index % 2), -0.05), Vector3(0.7, 1.5, 0.7))
			face(root, 1.55, 0.36, 0.3, 0.13, false)
			var lance: Node3D = BuffetModels.food("cooking-fork")
			root.add_child(lance)
			lance.scale = Vector3.ONE * 4.0
			lance.position = Vector3(1.25, 2.0, 0.1)
			lance.rotation_degrees = Vector3(0, 90, 82)
			var shield: Node3D = BuffetModels.food("plate")
			root.add_child(shield)
			shield.scale = Vector3.ONE * 1.9
			shield.position = Vector3(-1.1, 1.2, 0.35)
			shield.rotation_degrees = Vector3(80, 0, 0)
		_:
			# Colonel Casserole: a pot-bellied casserole dish with a lid for a hat, a gold star and a ladle.
			var pot: Node3D = BuffetModels.food("pot-stew")
			root.add_child(pot)
			pot.scale = Vector3.ONE * 3.3
			pot.position = Vector3(0, 0.1, 0)
			P.cylinder(root, 0.85, 0.85, 0.12, M.soup(Color(0.55, 0.78, 0.22)), Vector3(0, 1.05, 0.0), 14)
			P.cylinder(root, 0.8, 0.8, 0.3, M.flat(Color(0.2, 0.32, 0.18)), Vector3(0, 1.75, -0.1), 12)
			P.box(root, Vector3(1.3, 0.1, 0.9), M.flat(Color(0.14, 0.24, 0.13)), Vector3(0, 1.58, 0.3))
			P.ball(root, 0.14, M.glow(Color(1.0, 0.85, 0.2), 1.2), Vector3(0, 1.85, 0.5), Vector3(1, 1, 0.4))
			face(root, 1.28, 0.78, 0.3, 0.14)
			P.box(root, Vector3(0.5, 0.1, 0.1), M.flat(Color(0.18, 0.1, 0.06)), Vector3(0, 0.98, 0.9), Vector3(0, 0, 0))
			var ladle: Node3D = BuffetModels.food("cooking-spoon")
			root.add_child(ladle)
			ladle.scale = Vector3.ONE * 4.0
			ladle.position = Vector3(1.4, 1.3, 0.2)
			ladle.rotation_degrees = Vector3(0, 90, 78)
			for side: float in [-1.0, 1.0]:
				P.ball(root, 0.3, M.flat(Color(0.28, 0.28, 0.32)), Vector3(side * 0.5, 0.2, 0.3), Vector3(1, 0.7, 1.2))
	return root
