class_name PantryGate
extends RefCounted
## Crosspath pass, Part D: the Endless Buffet's great pantry door, rebuilt at storybook scale as a real door in a real wall (it was two flat slabs in a
## free-standing frame). Two carved oak leaves (raised panels, rails and stiles, studs), long iron strap hinges with their knuckles on the jambs,
## a ring pull on each leaf and a huge iron lock box with a keyhole the size of a dinner plate across the meeting stiles, in a stone gatehouse:
## block-coursed jambs, a lintel with a keystone, a pediment carrying the fork-and-spoon crest; wing walls run from the jambs into the orchard wall.
## Local frame: the door faces -Z (the town), +Z runs down the road; the leaves hinge on the jambs and swing away from the town when it opens.

const HALF_WIDTH: float = 2.6
const HEIGHT: float = 6.4
const JAMB: float = 1.5
const DEPTH: float = 2.0
## Where the door plane stands (local z).
const AT: float = -0.7
const WALL_HEIGHT: float = 2.5
const WALL_THICK: float = 0.8


## Builds the gate under `root`; `wings` are the local points (x, z) where the left and right wing walls meet the orchard wall. Returns
## {"leaves": Node3D (its children are the two hinges, meta "side"), "solid": Array[Vector3] (local x, z, radius: always solid),
## "door": Array[Vector3] (solid while the door is shut)}.
static func build(root: Node3D, is_cleared: bool, wings: Array[Vector2]) -> Dictionary:
	var frame: KitMesh = _mesh()
	var solid: Array[Vector3] = []
	var outer: float = HALF_WIDTH + JAMB
	# the jambs: coursed blocks, a little wider at the foot
	for side: float in [-1.0, 1.0]:
		var x: float = side * (HALF_WIDTH + JAMB * 0.5)
		var y: float = 0.0
		var course: int = 0
		while y < HEIGHT + 0.6:
			var h: float = 0.62 if course % 2 == 0 else 0.48
			var inset: float = 0.0 if course % 2 == 0 else 0.08
			frame.box("stone", Vector3(x, y + h * 0.5, AT), Vector3(JAMB - inset, h - 0.03, DEPTH - inset), Basis.IDENTITY, 0.05, 0.75 if course == 0 else 0.9)
			y += h
			course += 1
		frame.box("stone", Vector3(x, 0.2, AT), Vector3(JAMB + 0.3, 0.4, DEPTH + 0.3), Basis.IDENTITY, 0.05, 0.7)
		solid.append(Vector3(x, AT, JAMB * 0.5 + 0.35))
		solid.append(Vector3(x, AT - 0.6, JAMB * 0.5))
		solid.append(Vector3(x, AT + 0.6, JAMB * 0.5))
	# the lintel, the keystone and the pediment with the crest
	var top: float = HEIGHT + 0.6
	frame.box("stone", Vector3(0, top + 0.55, AT), Vector3(outer * 2.0 + 0.3, 1.1, DEPTH + 0.2), Basis.IDENTITY, 0.06, 0.85)
	frame.box("stone_light", Vector3(0, top + 0.5, AT - 0.15), Vector3(1.0, 1.5, DEPTH + 0.5), Basis.IDENTITY, 0.06)
	var peak: float = top + 2.6
	for face: float in [-1.0, 1.0]:
		var z: float = AT + face * (DEPTH * 0.5)
		frame.tri("stone", [Vector3(-outer, top + 1.1, z), Vector3(outer, top + 1.1, z), Vector3(0, peak, z)], Vector3(0, 0, face))
	for side: float in [-1.0, 1.0]:
		var a: Vector3 = Vector3(side * (outer + 0.2), top + 1.1, AT)
		var b: Vector3 = Vector3(0, peak + 0.12, AT)
		var along: Vector3 = b - a
		var x_axis: Vector3 = along.normalized()
		var basis: Basis = Basis(x_axis, Vector3(0, 0, 1).cross(x_axis).normalized(), Vector3(0, 0, 1))
		frame.box("stone_light", (a + b) * 0.5, Vector3(along.length() + 0.3, 0.32, DEPTH + 0.3), basis, 0.04)
	# the threshold
	frame.box("stone_light", Vector3(0, 0.08, AT), Vector3(HALF_WIDTH * 2.0, 0.16, DEPTH * 0.9), Basis.IDENTITY, 0.03)
	# the wing walls: from each jamb into the orchard wall, with a coping
	for index: int in range(mini(wings.size(), 2)):
		var side: float = -1.0 if index == 0 else 1.0
		var from: Vector2 = Vector2(side * outer, AT)
		var to: Vector2 = wings[index]
		var length: float = from.distance_to(to)
		if length < 0.2:
			continue
		var dir: Vector2 = (to - from) / length
		var basis: Basis = Basis(Vector3(dir.x, 0, dir.y), Vector3.UP, Vector3(dir.x, 0, dir.y).cross(Vector3.UP))
		var mid: Vector2 = (from + to) * 0.5
		frame.box("stone", Vector3(mid.x, WALL_HEIGHT * 0.5, mid.y), Vector3(length + WALL_THICK, WALL_HEIGHT, WALL_THICK), basis, 0.06, 0.72)
		frame.box("stone_light", Vector3(mid.x, WALL_HEIGHT + 0.08, mid.y), Vector3(length + WALL_THICK + 0.12, 0.18, WALL_THICK + 0.2), basis, 0.04)
		var steps: int = maxi(1, int(ceil(length / 0.7)))
		for i: int in range(steps + 1):
			var p: Vector2 = from.lerp(to, float(i) / float(steps))
			solid.append(Vector3(p.x, p.y, WALL_THICK * 0.5 + 0.1))
	var frame_node: MeshInstance3D = frame.instance("PantryGateStone")
	frame_node.set_meta(&"no_wind", true)
	# the gatehouse stands beside the road the hero walks, never between the lens and the hero: it must not dissolve
	frame_node.set_meta(&"no_occlusion_fade", true)
	root.add_child(frame_node)
	IconSign.attach(root, "ICON-RES-INGREDIENT", Vector3(0.0, top + 1.75, AT - DEPTH * 0.5 - 0.06), 1.1)
	# the two leaves on their hinges
	var leaves: Node3D = Node3D.new()
	leaves.name = "DoorWings"
	leaves.position = Vector3(0.0, 0.0, AT)
	root.add_child(leaves)
	var door: Array[Vector3] = []
	for side: float in [-1.0, 1.0]:
		var hinge: Node3D = Node3D.new()
		hinge.name = "Hinge"
		hinge.set_meta(&"side", side)
		hinge.position = Vector3(side * HALF_WIDTH, 0.0, 0.0)
		leaves.add_child(hinge)
		var leaf: MeshInstance3D = _leaf(side).instance("DoorWing")
		leaf.set_meta(&"no_wind", true)
		leaf.set_meta(&"no_occlusion_fade", true)
		hinge.add_child(leaf)
		# it swings away from the town, down the road
		hinge.set_meta(&"open_yaw", deg_to_rad(105.0 * side))
		hinge.rotation.y = deg_to_rad(105.0 * side) if is_cleared else 0.0
	var x: float = -HALF_WIDTH + 0.3
	while x < HALF_WIDTH:
		door.append(Vector3(x, AT, 0.5))
		x += 0.7
	return {"leaves": leaves, "solid": solid, "door": door}


## One carved leaf, built round its hinge (local x = 0 at the hinge, the leaf runs towards the middle).
static func _leaf(side: float) -> KitMesh:
	var mesh: KitMesh = _mesh()
	var w: float = HALF_WIDTH
	var cx: float = -side * w * 0.5
	var thick: float = 0.34
	# the boards and the frame of rails and stiles, proud on the town side
	mesh.box("wood", Vector3(cx, HEIGHT * 0.5, 0.0), Vector3(w - 0.04, HEIGHT, thick), Basis.IDENTITY, 0.03, 0.85)
	var face: float = -thick * 0.5 - 0.03
	for stile_x: float in [0.12, w - 0.12]:
		mesh.box("wood_dark", Vector3(-side * stile_x, HEIGHT * 0.5, face), Vector3(0.24, HEIGHT - 0.1, 0.08), Basis.IDENTITY, 0.02)
	for rail_y: float in [0.25, 2.25, 4.25, HEIGHT - 0.2]:
		mesh.box("wood_dark", Vector3(cx, rail_y, face), Vector3(w - 0.2, 0.26, 0.08), Basis.IDENTITY, 0.02)
	# raised panels between the rails: a bevelled block with a lighter field
	for panel: Vector2 in [Vector2(1.25, 1.6), Vector2(3.25, 1.6), Vector2(5.3, 1.3)]:
		mesh.box("wood_dark", Vector3(cx, panel.x, face + 0.01), Vector3(w - 0.66, panel.y, 0.06), Basis.IDENTITY, 0.06, 0.8)
		mesh.box("wood", Vector3(cx, panel.x, face - 0.04), Vector3(w - 0.98, panel.y - 0.34, 0.06), Basis.IDENTITY, 0.08)
	# iron strap hinges: long straps from the hinge side with a round end, knuckles on the jamb, studs
	for strap_y: float in [1.0, 3.25, 5.45]:
		var strap_len: float = w - 0.45
		mesh.box("iron", Vector3(-side * strap_len * 0.5, strap_y, face - 0.08), Vector3(strap_len, 0.22, 0.05), Basis.IDENTITY, 0.01)
		mesh.lathe("iron", Vector3(-side * strap_len, strap_y, face - 0.08), [Vector2(0.2, -0.03), Vector2(0.2, 0.03)], 10, 1.0, true, true)
		mesh.tube("iron", Vector3(0.0, strap_y - 0.3, 0.0), Vector3(0.0, strap_y + 0.3, 0.0), 0.11, 8, true)
		for stud: int in range(4):
			mesh.box("iron", Vector3(-side * (0.35 + float(stud) * strap_len / 4.0), strap_y, face - 0.12), Vector3(0.08, 0.08, 0.05), Basis.IDENTITY, 0.01)
	# a ring pull
	var ring_c: Vector3 = Vector3(-side * (w - 0.55), 2.35, face - 0.14)
	mesh.box("iron", ring_c + Vector3(0, 0.22, 0.04), Vector3(0.16, 0.16, 0.06), Basis.IDENTITY, 0.01)
	for k: int in range(10):
		var a0: float = TAU * float(k) / 10.0
		var a1: float = TAU * float(k + 1) / 10.0
		mesh.tube("iron", ring_c + Vector3(cos(a0) * 0.22, sin(a0) * 0.22, 0), ring_c + Vector3(cos(a1) * 0.22, sin(a1) * 0.22, 0), 0.035, 5, false)
	# the lock: a great iron box on the left leaf, over the meeting stiles, with a dinner-plate keyhole; a hasp staple on the right leaf
	if side < 0.0:
		var lock_c: Vector3 = Vector3(w - 0.05, 2.95, face - 0.16)
		mesh.box("iron", lock_c, Vector3(1.15, 1.4, 0.26), Basis.IDENTITY, 0.06, 0.8)
		mesh.box("iron_light", lock_c + Vector3(0, 0, -0.14), Vector3(0.95, 1.2, 0.04), Basis.IDENTITY, 0.03)
		mesh.lathe("keyhole", lock_c + Vector3(0, 0.18, -0.165), [Vector2(0.17, 0.0), Vector2(0.17, 0.02)], 12, 1.0, false, true)
		mesh.box("keyhole", lock_c + Vector3(0, -0.12, -0.17), Vector3(0.14, 0.42, 0.02), Basis.IDENTITY, 0.0)
		for corner: Vector2 in [Vector2(-0.42, 0.55), Vector2(0.42, 0.55), Vector2(-0.42, -0.55), Vector2(0.42, -0.55)]:
			mesh.box("iron", lock_c + Vector3(corner.x, corner.y, -0.18), Vector3(0.1, 0.1, 0.06), Basis.IDENTITY, 0.02)
	else:
		mesh.box("iron", Vector3(-w + 0.25, 2.95, face - 0.1), Vector3(0.36, 0.5, 0.12), Basis.IDENTITY, 0.02)
	return mesh


static func _mesh() -> KitMesh:
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("stone", EnvKit.material("ENV-WALL-FOUNDATION"))
	mesh.set_material("stone_light", EnvKit.material("ENV-WALL-FOUNDATION", false, Color(0.9, 0.87, 0.8)))
	mesh.set_material("wood", EnvKit.material("ENV-WALL-PLANK", false, Color(0.86, 0.6, 0.4)))
	mesh.set_material("wood_dark", EnvKit.material("ENV-WALL-PLANK", false, Color(0.62, 0.4, 0.26)))
	mesh.set_material("iron", EnvKit.flat(Color("34302d"), "iron"))
	mesh.set_material("iron_light", EnvKit.flat(Color("4a4440"), "iron_light"))
	mesh.set_material("keyhole", EnvKit.flat(Color("0d0b0a"), "keyhole"))
	return mesh
