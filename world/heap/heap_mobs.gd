class_name HeapMobs
extends RefCounted
## Procedural models of the Verdant Heap's three roaming enemies (a moss-covered trash golem, a possessed scarecrow
## druid and a flock of junk gulls) and helpers for the animated Cube Pets animals (mounts and escaped livestock).
## Built from primitives in the shared palette and Kenney Car/Survival Kit pieces; all face +z and stand on the ground.

const H = preload("res://world/heap/heap_materials.gd")
const P = preload("res://world/heap/heap_props.gd")
const B = preload("res://world/buffet/buffet_props.gd")


static func build(model: String) -> Node3D:
	match model:
		"heap:golem":
			return trash_golem()
		"heap:scarecrow":
			return scarecrow_druid()
		"heap:gulls":
			return gull_flock()
	return Node3D.new()


static func eyes(parent: Node3D, y: float, z: float, spread: float, size: float, color: Color) -> void:
	for side: float in [-1.0, 1.0]:
		B.ball(parent, size, H.glow(color, 2.0), Vector3(side * spread, y, z))
		B.ball(parent, size * 0.4, H.flat(Color(0.05, 0.04, 0.03)), Vector3(side * spread, y, z + size * 0.7))


## The Mossy Trash Golem: a fridge for a body, tyre arms and fists, an oven-door chest, headlights for eyes and moss
## and flowers growing out of it.
static func trash_golem() -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(1.1, 1.3, 0.8), H.flat(Color(0.84, 0.82, 0.74)), Vector3(0, 1.0, 0))
	B.box(root, Vector3(0.9, 0.5, 0.05), H.flat(H.METAL_DARK), Vector3(0, 0.95, 0.42))
	B.box(root, Vector3(0.7, 0.25, 0.06), H.flat(Color(0.15, 0.12, 0.1)), Vector3(0, 0.95, 0.45))
	# A washing-machine head with a round window face.
	B.box(root, Vector3(0.75, 0.7, 0.65), H.flat(Color(0.9, 0.9, 0.88)), Vector3(0, 1.95, 0))
	B.cylinder(root, 0.22, 0.22, 0.08, H.shiny(Color(0.4, 0.55, 0.6)), Vector3(0, 1.95, 0.35), 12).rotation_degrees.x = 90.0
	eyes(root, 2.15, 0.34, 0.2, 0.09, Color(1.0, 0.85, 0.3))
	# Tyre arms and fists.
	for side: float in [-1.0, 1.0]:
		for index: int in range(3):
			B.cylinder(root, 0.34, 0.34, 0.26, H.flat(H.TIRE), Vector3(side * 0.85, 1.4 - 0.3 * float(index), 0.15), 12).rotation_degrees.z = 90.0
		B.ball(root, 0.36, H.flat(H.RUST), Vector3(side * 0.9, 0.5, 0.2))
	for side: float in [-0.3, 0.3]:
		B.cylinder(root, 0.2, 0.22, 0.4, H.flat(H.METAL_DARK), Vector3(side, 0.2, 0.0), 8)
	P.moss_patches(root, 14, 0.8, 2.2, 2)
	P.flowers_on(root, 8, 0.7, 2.3)
	var sprig: Node3D = HeapModels.nature("plant_bushSmall")
	root.add_child(sprig)
	sprig.scale = Vector3.ONE * 2.0
	sprig.position = Vector3(0.1, 2.35, 0)
	return root


## The Possessed Scarecrow Druid: a pole and crossbar, a ragged robe, a straw hat with a wreath, glowing eyes and a
## staff topped with an unhappy orb of compost.
static func scarecrow_druid() -> Node3D:
	var root: Node3D = Node3D.new()
	B.cylinder(root, 0.07, 0.1, 2.2, H.flat(H.WOOD_DARK), Vector3(0, 1.1, 0), 6)
	B.box(root, Vector3(1.7, 0.1, 0.1), H.flat(H.WOOD_DARK), Vector3(0, 1.6, 0))
	var robe: MeshInstance3D = B.cylinder(root, 0.25, 0.7, 1.3, H.flat(Color(0.32, 0.45, 0.28)), Vector3(0, 0.95, 0), 10)
	robe.name = "Robe"
	for index: int in range(6):
		var angle: float = TAU * float(index) / 6.0
		B.box(root, Vector3(0.12, 0.35, 0.03), H.flat(H.STRAW), Vector3(cos(angle) * 0.62, 0.38, sin(angle) * 0.62), Vector3(0, -rad_to_deg(angle), 0))
	B.ball(root, 0.34, H.flat(H.STRAW), Vector3(0, 2.0, 0))
	B.cylinder(root, 0.62, 0.62, 0.05, H.flat(H.STRAW.darkened(0.25)), Vector3(0, 2.25, 0), 12)
	B.cylinder(root, 0.28, 0.34, 0.38, H.flat(H.STRAW.darkened(0.25)), Vector3(0, 2.45, 0), 12)
	for index: int in range(8):
		var angle: float = TAU * float(index) / 8.0
		B.ball(root, 0.09, H.flat(H.MOSS if index % 2 == 0 else H.BLOOM), Vector3(cos(angle) * 0.3, 2.3, sin(angle) * 0.3))
	eyes(root, 2.05, 0.3, 0.14, 0.07, Color(0.6, 1.0, 0.3))
	B.cylinder(root, 0.05, 0.05, 2.4, H.flat(H.WOOD), Vector3(0.95, 1.2, 0.2), 6)
	B.ball(root, 0.24, H.glow(Color(0.5, 0.8, 0.2), 1.6), Vector3(0.95, 2.5, 0.2))
	return root


## The Junk Gull Flock: four angry gulls clutching bits of rubbish. `HeapFlock` flaps their wings.
static func gull_flock() -> Node3D:
	var root: Node3D = HeapFlock.new()
	var offsets: Array[Vector3] = [Vector3(0.0, 0.45, 0.0), Vector3(-0.55, 0.7, -0.3), Vector3(0.6, 0.6, -0.35), Vector3(0.1, 0.95, -0.7)]
	for index: int in range(offsets.size()):
		var gull: Node3D = Node3D.new()
		gull.position = offsets[index]
		gull.name = "Gull%d" % index
		root.add_child(gull)
		B.ball(gull, 0.2, H.flat(Color(0.95, 0.95, 0.96)), Vector3.ZERO, Vector3(0.8, 0.7, 1.4))
		B.ball(gull, 0.12, H.flat(Color(0.95, 0.95, 0.96)), Vector3(0, 0.1, 0.28))
		B.box(gull, Vector3(0.05, 0.04, 0.16), H.flat(Color(1.0, 0.7, 0.2)), Vector3(0, 0.08, 0.42))
		B.ball(gull, 0.03, H.flat(Color(0.05, 0.05, 0.05)), Vector3(0.06, 0.14, 0.36))
		B.ball(gull, 0.03, H.flat(Color(0.05, 0.05, 0.05)), Vector3(-0.06, 0.14, 0.36))
		for side: float in [-1.0, 1.0]:
			var wing: Node3D = Node3D.new()
			wing.name = "Wing%s" % ("L" if side < 0.0 else "R")
			wing.position = Vector3(side * 0.12, 0.05, 0.0)
			gull.add_child(wing)
			B.box(wing, Vector3(0.55, 0.03, 0.26), H.flat(Color(0.88, 0.89, 0.92)), Vector3(side * 0.27, 0.0, 0.0))
			B.box(wing, Vector3(0.18, 0.031, 0.24), H.flat(Color(0.3, 0.3, 0.34)), Vector3(side * 0.5, 0.0, 0.0))
		# Each gull has stolen something.
		var loot: MeshInstance3D = B.cylinder(gull, 0.06, 0.06, 0.12, H.flat([Color(0.8, 0.2, 0.2), Color(0.5, 0.65, 0.8), Color(0.9, 0.8, 0.2), Color(0.5, 0.8, 0.4)][index]), Vector3(0, -0.2, 0.1), 8)
		loot.name = "Loot"
	return root


## An animated Cube Pets animal as a mount or an escaped animal: ("boar" | "goat" | "pig" | "raccoon").
static func animal(kind: String) -> Node3D:
	var model: String = "animal-pig"
	match kind:
		"boar":
			model = "animal-hog"
		"goat":
			model = "animal-deer"
		"raccoon":
			model = "animal-cat"
	var node: Node3D = HeapModels.pet(model)
	match kind:
		"goat":
			ModelKit.tint(node, Color(1.2, 1.15, 1.0))
		"raccoon":
			ModelKit.tint(node, Color(0.62, 0.62, 0.68))
	return node
