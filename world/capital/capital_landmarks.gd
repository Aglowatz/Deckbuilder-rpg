class_name CapitalLandmarks
extends RefCounted
## The Capital's stand-in landmarks for the layout pass (docs/art/capital_slice.md): simple `KitMesh`-free primitive models of the right size and
## silhouette, placed by `CapitalBuilder` from the layout's constants, each to be replaced in place when its concept art arrives. Primm's Castle on its
## hill at the city's heart (immense, seen from every inside region and over the great wall from outside), the broken
## watchtower of the ruined outpost, the Old Service Tunnels' mouth in the wall and the tram shed of the Transit Yards. The views never cull or fade.

const M = preload("res://world/capital/capital_materials.gd")
const P = preload("res://world/capital/capital_props.gd")
const B = preload("res://world/buffet/buffet_props.gd")


## Marks every mesh under `node` as a far view: never range-culled, and (with `fade` false) never faded by the occlusion fader.
static func mark_view(node: Node, fade: bool = false) -> void:
	if node is GeometryInstance3D:
		node.set_meta(&"no_range_cull", true)
		if not fade:
			node.set_meta(&"no_occlusion_fade", true)
	for child: Node in node.get_children():
		mark_view(child, fade)


## Primm's Castle on its hill (CAPI-HERO-PALACE-FACADE's stand-in): the hill's front tongue fills the void cells of `CapitalLayout.HILL` and
## widens beyond the map's north edge; a grand stair climbs from the forecourt (the castle door spot at its foot) to the gatehouse; on top a white
## and gold palace about 78 m wide and 60 m tall: a long body, a central keep with four spires, two great round towers, glowing window rows and
## Primm's portrait over the door. `final` (Primm has fallen) dims the gold and darkens the windows.
static func castle(final_state: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "PrimmsCastle"
	var h: float = CapitalLayout.HILL_HEIGHT
	var hill_mat: StandardMaterial3D = M.flat(Color(0.48, 0.62, 0.42))
	var terrace_mat: StandardMaterial3D = M.shiny(M.WHITE, 0.35)
	var gold: StandardMaterial3D = M.shiny(M.GOLD if not final_state else M.GOLD.darkened(0.35), 0.3)
	var stone: StandardMaterial3D = M.shiny(Color(0.93, 0.91, 0.88), 0.35)
	var stone_shade: StandardMaterial3D = M.shiny(Color(0.82, 0.8, 0.8), 0.4)
	var window: StandardMaterial3D = M.glow(Color(1.0, 0.82, 0.48), 1.6) if not final_state else M.flat(Color(0.3, 0.28, 0.3))
	# The hill: two grassy terraces with white retaining walls, the front tongue inside the map, the wide body beyond it.
	var hill: Node3D = Node3D.new()
	hill.name = "Hill"
	root.add_child(hill)
	var front: Rect2 = Rect2(CapitalLayout.HILL.position.x, 0.0, CapitalLayout.HILL.size.x, CapitalLayout.HILL.size.y)
	# the front tongue in two halves either side of the stair's channel (x 56..64), so the steps are not buried in the terraces
	var stair_x0: float = 56.0
	var stair_x1: float = 64.0
	for half: Vector2 in [Vector2(front.position.x, stair_x0), Vector2(stair_x1, front.end.x)]:
		var mid: float = (half.x + half.y) * 0.5
		var width: float = half.y - half.x
		B.box(hill, Vector3(width, h * 0.5, front.size.y), hill_mat, Vector3(mid, h * 0.25, front.get_center().y))
		B.box(hill, Vector3(width + 0.2, 0.5, 0.6), terrace_mat, Vector3(mid, h * 0.5, front.end.y - 0.2))
		var upper: Vector2 = Vector2(maxf(half.x, front.position.x + 3.0), minf(half.y, front.end.x - 3.0))
		B.box(hill, Vector3(upper.y - upper.x, h * 0.5, 9.0), hill_mat, Vector3((upper.x + upper.y) * 0.5, h * 0.75, 4.5))
		B.box(hill, Vector3(upper.y - upper.x + 0.2, 0.5, 0.6), terrace_mat, Vector3((upper.x + upper.y) * 0.5, h, 8.8))
	B.box(hill, Vector3(stair_x1 - stair_x0, h, 4.0), terrace_mat, Vector3(60.0, h * 0.5, 2.0))
	B.box(hill, Vector3(96.0, h * 0.5, 54.0), hill_mat, Vector3(60.0, h * 0.25, -27.0))
	B.box(hill, Vector3(84.0, h * 0.5, 50.0), hill_mat, Vector3(60.0, h * 0.75, -25.0))
	# The grand stair, the forecourt door's way up: eight white steps between gold-capped balustrades.
	var steps: int = 8
	for index: int in range(steps):
		var top: float = h * float(index + 1) / float(steps)
		var z0: float = front.end.y - float(index) * 1.0
		B.box(hill, Vector3(8.0, top, 1.0), terrace_mat, Vector3(60.0, top * 0.5, z0 - 0.5))
	for side: float in [-1.0, 1.0]:
		B.box(hill, Vector3(0.6, 1.2, 9.0), stone_shade, Vector3(60.0 + side * 4.3, h * 0.5 + 0.2, front.end.y - 4.5), Vector3(-37.0, 0.0, 0.0))
		var statue: Node3D = P.statue(2.2, final_state)
		hill.add_child(statue)
		statue.position = Vector3(60.0 + side * 9.5, h * 0.5, 10.0)
		statue.rotation_degrees.y = 0.0
	# The palace on top.
	var palace: Node3D = Node3D.new()
	palace.name = "Palace"
	root.add_child(palace)
	palace.position = Vector3(CapitalLayout.CASTLE.x, h, CapitalLayout.CASTLE.z)
	var size: Vector3 = CapitalLayout.CASTLE_SIZE
	# The silhouette sits low and wide (VD-14): the Cinematic camera sees only a few degrees above the horizon, so from outside the wall the
	# castle shows in a band about 10 to 25 m up. The crenellated body, the cone roofs of the round towers and the gatehouse live in that band;
	# the keep and its spires rise above it for the closer views inside the city.
	var body_h: float = 13.0
	B.box(palace, Vector3(size.x * 0.82, body_h, 22.0), stone, Vector3(0, body_h * 0.5, -2.0))
	B.box(palace, Vector3(size.x * 0.84, 0.7, 22.6), gold, Vector3(0, body_h + 0.1, -2.0))
	_crenels(palace, size.x * 0.82, Vector3(0, body_h + 0.45, 9.0), stone_shade)
	B.mesh_at(palace, P._prism(size.x * 0.7, 5.0, 16.0), M.shiny(Color(0.55, 0.62, 0.86), 0.35), Vector3(0, body_h + 2.9, -4.0))
	B.box(palace, Vector3(24.0, 30.0, 18.0), stone, Vector3(0, 15.0, -4.0))
	B.box(palace, Vector3(24.8, 0.9, 18.8), gold, Vector3(0, 30.4, -4.0))
	_crenels(palace, 24.0, Vector3(0, 31.2, 5.0), stone_shade)
	B.mesh_at(palace, P._prism(24.0, 9.0, 18.0), gold, Vector3(0, 35.4, -4.0))
	for corner: Vector2 in [Vector2(-11.0, 4.5), Vector2(11.0, 4.5), Vector2(-11.0, -12.5), Vector2(11.0, -12.5)]:
		B.cylinder(palace, 1.6, 1.8, 36.0, stone_shade, Vector3(corner.x, 18.0, corner.y), 10)
		B.cylinder(palace, 0.05, 2.1, 10.0, gold, Vector3(corner.x, 41.0, corner.y), 10)
	for side: float in [-1.0, 1.0]:
		for tower: Vector3 in [Vector3(size.x * 0.43, 21.0, 4.0), Vector3(size.x * 0.27, 17.0, 9.0)]:
			var radius: float = 5.2 if tower.x > size.x * 0.3 else 3.4
			B.cylinder(palace, radius, radius * 1.08, tower.y, stone, Vector3(side * tower.x, tower.y * 0.5, tower.z), 16)
			B.cylinder(palace, radius * 1.1, radius * 1.1, 0.8, gold, Vector3(side * tower.x, tower.y + 0.2, tower.z), 16)
			B.cylinder(palace, 0.1, radius * 1.15, radius * 1.9, M.shiny(Color(0.5, 0.58, 0.86), 0.35), Vector3(side * tower.x, tower.y + 0.6 + radius * 0.95, tower.z), 16)
			B.ball(palace, 0.5, gold, Vector3(side * tower.x, tower.y + 0.8 + radius * 1.9, tower.z))
	# The gatehouse and its door, facing the stair; two banners of Primm's face either side of it.
	B.box(palace, Vector3(16.0, 12.0, 7.0), stone, Vector3(0, 6.0, 12.5))
	B.box(palace, Vector3(16.6, 0.8, 7.6), gold, Vector3(0, 12.2, 12.5))
	_crenels(palace, 16.0, Vector3(0, 12.9, 16.0), stone_shade)
	B.box(palace, Vector3(6.0, 8.0, 0.4), M.shiny(Color(0.18, 0.14, 0.22), 0.3), Vector3(0, 4.0, 16.1))
	B.box(palace, Vector3(6.8, 0.5, 0.5), gold, Vector3(0, 8.2, 16.2))
	B.box(palace, Vector3(0.25, 7.4, 0.45), gold, Vector3(0, 3.8, 16.25))
	for side: float in [-1.0, 1.0]:
		var banner: MeshInstance3D = MeshInstance3D.new()
		var quad: QuadMesh = QuadMesh.new()
		quad.size = Vector2(4.0, 6.0)
		banner.mesh = quad
		banner.material_override = M.textured(P.portrait_texture(1))
		banner.position = Vector3(side * 13.0, 8.0, 9.05)
		palace.add_child(banner)
	# Window rows on the body and the keep, one MultiMesh.
	var windows: Array[Transform3D] = []
	for row: int in range(2):
		for column: int in range(22):
			var x: float = -size.x * 0.39 + float(column) * size.x * 0.78 / 21.0
			if absf(x) < 12.5 or absf(absf(x) - 13.0) < 2.6:
				continue
			windows.append(Transform3D(Basis.IDENTITY.scaled(Vector3(1.0, 2.0, 0.1)), Vector3(x, 4.0 + float(row) * 5.0, 9.05)))
	for row: int in range(4):
		for column: int in range(5):
			windows.append(Transform3D(Basis.IDENTITY.scaled(Vector3(1.1, 2.4, 0.1)), Vector3(-7.0 + float(column) * 3.5, 16.0 + float(row) * 3.6, 5.05)))
	var multimesh: MultiMesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = BoxMesh.new()
	multimesh.instance_count = windows.size()
	for index: int in range(windows.size()):
		multimesh.set_instance_transform(index, windows[index])
	var holder: MultiMeshInstance3D = MultiMeshInstance3D.new()
	holder.multimesh = multimesh
	holder.material_override = window
	holder.name = "CastleWindows"
	palace.add_child(holder)
	mark_view(root)
	return root


## The broken watchtower of the ruined outpost (CAPO-HERO-BROKEN-WATCHTOWER): a square stone tower that tapers to about 14 m, its top bitten off,
## a fallen chunk of its crown on the ground beside it, a dead lamp and a ladder.
static func watchtower() -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "Watchtower"
	var stone: StandardMaterial3D = M.flat(Color(0.42, 0.4, 0.44))
	var dark: StandardMaterial3D = M.flat(Color(0.3, 0.28, 0.32))
	B.box(root, Vector3(5.6, 1.2, 5.6), dark, Vector3(0, 0.6, 0))
	B.box(root, Vector3(4.6, 10.0, 4.6), stone, Vector3(0, 6.0, 0), Vector3(0, 0, 2.5))
	B.box(root, Vector3(4.2, 2.4, 2.2), stone, Vector3(-0.6, 12.0, 1.0), Vector3(0, 0, 6.0))
	B.box(root, Vector3(1.6, 3.4, 1.6), stone, Vector3(1.6, 12.4, -1.2), Vector3(0, 0, -8.0))
	B.box(root, Vector3(5.4, 0.5, 5.4), dark, Vector3(0.3, 10.6, 0.0), Vector3(4.0, 0, 6.0))
	B.box(root, Vector3(3.6, 2.2, 3.0), stone, Vector3(-4.2, 1.0, 2.6), Vector3(18.0, 35.0, 24.0))
	B.box(root, Vector3(1.2, 0.8, 1.6), dark, Vector3(3.2, 0.4, 3.3), Vector3(0, 20.0, 12.0))
	for index: int in range(4):
		B.box(root, Vector3(0.8, 1.4, 0.1), M.flat(M.SOOT), Vector3(-1.2 + float(index) * 0.8, 7.5, 2.36))
	for rail: float in [-0.35, 0.35]:
		B.box(root, Vector3(0.1, 8.0, 0.1), M.flat(M.WOOD_DARK), Vector3(2.45, 4.0, rail), Vector3(0, 0, 8.0))
	for rung: int in range(9):
		B.box(root, Vector3(0.08, 0.08, 0.8), M.flat(M.WOOD_DARK), Vector3(2.55 - float(rung) * 0.06, 0.8 + float(rung) * 0.85, 0.0))
	mark_view(root, true)
	return root


## The Old Service Tunnels' mouth (CAPO-HERO-SERVICE-TUNNEL): a great round culvert arch in the outer face of the wall, a dark throat, a rusted
## grate half raised, two big pipes running along the wall into it.
static func tunnel_mouth() -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "TunnelMouth"
	var rust: StandardMaterial3D = M.flat(Color(0.48, 0.3, 0.22))
	var concrete: StandardMaterial3D = M.flat(Color(0.5, 0.48, 0.46))
	for side: float in [-1.0, 1.0]:
		B.box(root, Vector3(1.4, 6.0, 1.6), concrete, Vector3(side * 3.8, 3.0, 0.6))
	B.box(root, Vector3(9.0, 1.6, 1.6), concrete, Vector3(0, 6.4, 0.6))
	var throat: MeshInstance3D = B.cylinder(root, 3.0, 3.0, 0.2, M.flat(Color(0.03, 0.03, 0.05)), Vector3(0, 3.0, 0.15), 24)
	throat.rotation_degrees.x = 90.0
	B.box(root, Vector3(6.2, 3.0, 0.2), M.flat(Color(0.03, 0.03, 0.05)), Vector3(0, 1.5, 0.15))
	for index: int in range(7):
		B.box(root, Vector3(0.14, 2.6, 0.14), rust, Vector3(-2.7 + float(index) * 0.9, 4.4, 0.4))
	B.box(root, Vector3(6.4, 0.2, 0.2), rust, Vector3(0, 3.2, 0.4))
	for pipe: Vector2 in [Vector2(-1.0, 7.4), Vector2(1.0, 8.2)]:
		var tube: MeshInstance3D = B.cylinder(root, 0.45, 0.45, 18.0, rust, Vector3(pipe.x * 12.0, pipe.y, 0.5), 10)
		tube.rotation_degrees.z = 90.0
	mark_view(root, true)
	return root


## The tram shed of the Transit Yards (CAPI-HERO-TRAM-SHED): an open shed on iron posts under a sawtooth roof, the dead tram inside on its rails,
## the sign-less clock in the gable. `lit` (the Beefcakes are free) lights the tram and the clock.
static func tram_shed(w: float, d: float, h: float, lit: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	var iron: StandardMaterial3D = M.flat(Color(0.3, 0.32, 0.38))
	var roof: StandardMaterial3D = M.flat(Color(0.42, 0.46, 0.54))
	for x: float in [-w * 0.5 + 0.3, -w * 0.17, w * 0.17, w * 0.5 - 0.3]:
		for z: float in [-d * 0.5 + 0.3, d * 0.5 - 0.3]:
			B.box(root, Vector3(0.35, h, 0.35), iron, Vector3(x, h * 0.5, z))
	for index: int in range(4):
		var x: float = -w * 0.5 + (float(index) + 0.5) * w / 4.0
		B.mesh_at(root, P._prism(w / 4.0, 1.8, d + 0.6), roof, Vector3(x, h + 0.9, 0.0))
	B.box(root, Vector3(w + 0.4, 0.4, d + 0.4), iron, Vector3(0, h, 0))
	B.box(root, Vector3(w * 0.8, 2.8, 2.4), M.flat(Color(0.55, 0.28, 0.2)), Vector3(0, 1.7, 0.4))
	for index: int in range(5):
		B.box(root, Vector3(1.3, 0.8, 0.06), M.glow(Color(1.0, 0.85, 0.5), 1.4) if lit else M.flat(Color(0.2, 0.22, 0.26)), Vector3(-w * 0.32 + float(index) * w * 0.16, 2.2, 1.62))
	for rail: float in [-0.6, 0.6]:
		B.box(root, Vector3(w + 2.0, 0.08, 0.12), iron, Vector3(0, 0.05, 0.4 + rail))
	var clock: MeshInstance3D = B.cylinder(root, 0.9, 0.9, 0.15, M.glow(Color(0.95, 0.95, 0.85), 1.2) if lit else M.flat(Color(0.75, 0.75, 0.7)), Vector3(0, h + 1.1, d * 0.5 + 0.35), 18)
	clock.rotation_degrees.x = 90.0
	return root


## A row of merlons along the front (+z) edge of a wall top: `center` is the row's middle.
static func _crenels(parent: Node3D, width: float, center: Vector3, material: Material) -> void:
	var count: int = maxi(2, int(width / 2.4))
	for index: int in range(count):
		if index % 2 == 1:
			continue
		var x: float = center.x - width * 0.5 + (float(index) + 0.5) * width / float(count)
		B.box(parent, Vector3(width / float(count), 1.2, 0.9), material, Vector3(x, center.y + 0.6, center.z))


## The resistance camp (the outside's small warm refuge): two patched A-frame tents either side of the fire, a lean-to of salvaged planks with
## bedrolls, a rope of warm lanterns between the tent poles and a rag flag of the Wrinkles. Positions are the layout's (`CapitalLayout.CAMP_TENTS`,
## `CAMP_LEAN_TO`); the fire itself is the `campfire` prop with the camp's one real light.
static func camp() -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "ResistanceCamp"
	var canvas: Array[Color] = [Color(0.62, 0.5, 0.36), Color(0.48, 0.52, 0.42)]
	var wood: StandardMaterial3D = M.flat(M.WOOD_DARK)
	var lantern: StandardMaterial3D = M.glow(M.LANTERN, 2.6)
	for index: int in range(CapitalLayout.CAMP_TENTS.size()):
		var at: Vector2 = CapitalLayout.CAMP_TENTS[index]
		var tent: Node3D = Node3D.new()
		root.add_child(tent)
		tent.position = Vector3(at.x, 0.0, at.y)
		tent.rotation_degrees.y = 90.0 if index == 0 else -90.0
		for side: float in [-1.0, 1.0]:
			B.box(tent, Vector3(2.0, 0.06, 3.0), M.flat(canvas[index]), Vector3(side * 0.7, 1.0, 0.0), Vector3(0, 0, side * -55.0))
		B.box(tent, Vector3(0.6, 0.07, 0.8), M.flat(Color(0.72, 0.3, 0.26)), Vector3(0.75, 1.05, 0.6), Vector3(0, 0, -55.0))
		for end: float in [-1.5, 1.5]:
			B.box(tent, Vector3(0.1, 2.2, 0.1), wood, Vector3(0, 1.1, end))
		B.box(tent, Vector3(1.2, 1.2, 0.04), M.flat(Color(0.1, 0.08, 0.07)), Vector3(0, 0.6, 1.52))
	# the lean-to
	var lean: Node3D = Node3D.new()
	root.add_child(lean)
	lean.position = Vector3(CapitalLayout.CAMP_LEAN_TO.x, 0.0, CapitalLayout.CAMP_LEAN_TO.y)
	lean.rotation_degrees.y = 90.0
	for side: float in [-1.0, 1.0]:
		B.box(lean, Vector3(0.12, 2.1, 0.12), wood, Vector3(side * 1.5, 1.05, -0.7))
	B.box(lean, Vector3(3.4, 0.08, 2.0), M.flat(M.WOOD), Vector3(0, 1.45, -0.1), Vector3(-34.0, 0, 0))
	for x: float in [-0.8, 0.7]:
		B.box(lean, Vector3(0.8, 0.18, 1.8), M.flat(Color(0.45, 0.4, 0.5)), Vector3(x, 0.09, 0.0))
	# the lantern rope between the tents' front poles, and the flag
	var a: Vector3 = Vector3(CapitalLayout.CAMP_TENTS[0].x + 1.5, 2.2, CapitalLayout.CAMP_TENTS[0].y)
	var b: Vector3 = Vector3(CapitalLayout.CAMP_TENTS[1].x - 1.5, 2.2, CapitalLayout.CAMP_TENTS[1].y)
	var rope: MeshInstance3D = B.box(root, Vector3(a.distance_to(b), 0.03, 0.03), M.flat(Color(0.3, 0.24, 0.18)), (a + b) * 0.5)
	rope.rotation_degrees.y = 0.0
	for index: int in range(7):
		var t: float = (float(index) + 0.5) / 7.0
		var sag: float = 0.5 * sin(t * PI)
		B.ball(root, 0.13, lantern, a.lerp(b, t) - Vector3(0, sag + 0.18, 0))
	B.box(root, Vector3(0.1, 4.0, 0.1), wood, Vector3(CapitalLayout.CAMP_LEAN_TO.x, 2.0, CapitalLayout.CAMP_LEAN_TO.y - 1.6))
	B.box(root, Vector3(1.2, 0.8, 0.04), M.flat(Color(0.7, 0.32, 0.25)), Vector3(CapitalLayout.CAMP_LEAN_TO.x + 0.65, 3.5, CapitalLayout.CAMP_LEAN_TO.y - 1.6), Vector3(0, 0, -6.0))
	return root
