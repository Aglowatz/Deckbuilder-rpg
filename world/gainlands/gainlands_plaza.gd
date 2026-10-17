class_name GainlandsPlaza
extends RefCounted
## Gainlands v2, Part C: the entrance and the plaza's centrepiece (docs/art/gainlands_v2.md).
##  - `gateway(width)`: the stone gateway at the bridge head: two dressed sandstone pillars with gold orbs, iron arms with hanging kit banners, a low parapet
##    running off each side along the rim. Meta "circles" (local x, z, radius) are the pillars.
##  - `gym_hall(size)`: the gym hall that replaces the round Swole Station platform: brick side and back walls, an open front of four cream-stone pillars
##    (half-height parapets between the outer pairs), a red gable roof, a gold dumbbell emblem in the gable (an icon, no lettering), and inside, in full view
##    of the plaza: a two-tier dumbbell rack, a barbell rack, plate trees, a squat rack with its bar and a bench on a rubber floor. The layout's GYM_HALL
##    rectangle makes the whole footprint solid (`GainlandsBuilder.add_rect_blocker`); nothing inside is walkable.
## Origin on the ground at the centre, front +z (the plaza side); built from the zone kit through `GainlandsLandmarks` materials, one KitMesh each.

const PLATE_COLOURS: Array[String] = ["red", "iron", "blue_plate", "iron", "gold"]


static func gateway(width: float) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	GainlandsLandmarks._materials(mesh)
	mesh.set_material("sandstone", EnvKit.flat(Color("dcc19a"), "gl2_sandstone_block"))
	mesh.set_material("sandstone_cap", EnvKit.flat(Color("ecd8b4"), "gl2_sandstone_cap"))
	var circles: Array[Vector3] = []
	var pillar_h: float = 4.2
	var half: float = width * 0.5 + 0.9
	for side: float in [-1.0, 1.0]:
		var x: float = side * half
		mesh.box("sandstone", Vector3(x, 0.25, 0), Vector3(1.6, 0.5, 1.6), Basis.IDENTITY, 0.06, 0.88)
		mesh.box("sandstone", Vector3(x, pillar_h * 0.5 + 0.3, 0), Vector3(1.25, pillar_h - 0.2, 1.25), Basis.IDENTITY, 0.05, 0.9)
		mesh.box("sandstone_cap", Vector3(x, pillar_h + 0.35, 0), Vector3(1.55, 0.3, 1.55), Basis.IDENTITY, 0.05)
		mesh.box("brass", Vector3(x, pillar_h + 0.58, 0), Vector3(0.7, 0.18, 0.7), Basis.IDENTITY, 0.02)
		mesh.blob("gold", Vector3(x, pillar_h + 1.12, 0), Vector3(0.5, 0.5, 0.5), 6, 12, 1.0)
		# an iron arm off the pillar's road side, a kit banner hanging from it (its top fixed to the arm)
		var arm_y: float = pillar_h - 0.55
		mesh.tube("iron", Vector3(x - side * 0.6, arm_y, 0.45), Vector3(x - side * 1.35, arm_y, 0.45), 0.06, 6, true)
		mesh.box("iron", Vector3(x - side * 1.0, arm_y - 0.05, 0.45), Vector3(0.9, 0.08, 0.12), Basis.IDENTITY, 0.0)
		GainlandsLandmarks._card(mesh, "GAIN-SHEET-BANNERS-03" if side < 0.0 else "GAIN-SHEET-BANNERS-06", Vector3(x - side * 1.0, arm_y - 0.08, 0.5), 2.0, Vector3(0, 0, 1))
		GainlandsLandmarks._torch(mesh, Vector3(x, pillar_h * 0.62, 0.68), [] as Array[Dictionary], 0.7)
		# a low parapet off along the rim, outward
		mesh.box("sandstone", Vector3(x + side * 2.4, 0.5, -0.1), Vector3(3.6, 1.0, 0.7), Basis.IDENTITY, 0.05, 0.9)
		mesh.box("sandstone_cap", Vector3(x + side * 2.4, 1.05, -0.1), Vector3(3.8, 0.14, 0.85), Basis.IDENTITY, 0.03)
		circles.append(Vector3(x, 0.0, 0.85))
		circles.append(Vector3(x + side * 2.4, 0.0, 0.5))
		circles.append(Vector3(x + side * 3.8, 0.0, 0.5))
	return _finish(mesh, "StoneGateway", circles, Vector2(width + 10.0, 1.6), pillar_h + 1.6)


static func gym_hall(size: Vector3) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	GainlandsLandmarks._materials(mesh)
	mesh.alias("blue_plate", "flat", Color("3d6fd0"))
	mesh.alias("rubber", "flat", Color("3a3436"))
	mesh.set_material("sandstone", EnvKit.flat(Color("dcc19a"), "gl2_sandstone_block"))
	var w: float = size.x
	var d: float = size.z
	var h: float = size.y
	var hw: float = w * 0.5
	var hd: float = d * 0.5
	# plinth and the rubber floor
	mesh.box("sandstone", Vector3(0, 0.18, 0), Vector3(w + 0.6, 0.36, d + 0.6), Basis.IDENTITY, 0.05, 0.85)
	mesh.box("rubber", Vector3(0, 0.38, 0), Vector3(w - 1.0, 0.05, d - 1.0), Basis.IDENTITY, 0.0)
	# back and side walls of brick with a brass string course; tall windows in the sides
	mesh.box("brick", Vector3(0, h * 0.5 + 0.3, -hd + 0.3), Vector3(w, h, 0.6), Basis.IDENTITY, 0.04, 0.85)
	for side: float in [-1.0, 1.0]:
		mesh.box("brick", Vector3(side * (hw - 0.3), h * 0.5 + 0.3, 0), Vector3(0.6, h, d), Basis.IDENTITY, 0.04, 0.85)
		for z: float in [-d * 0.18, d * 0.18]:
			mesh.box("gold_glow", Vector3(side * (hw + 0.02), h * 0.55, z), Vector3(0.1, 1.9, 1.2), Basis.IDENTITY, 0.0)
			mesh.box("iron", Vector3(side * (hw + 0.06), h * 0.55 + 1.05, z), Vector3(0.14, 0.18, 1.5), Basis.IDENTITY, 0.0)
	mesh.box("brass", Vector3(0, h * 0.72, -hd + 0.3), Vector3(w + 0.2, 0.22, 0.7), Basis.IDENTITY, 0.0)
	# the open front: four cream-stone pillars, half-height parapets between the outer pairs, an iron lintel
	var pillars: Array[float] = [-hw + 0.45, -w / 6.0, w / 6.0, hw - 0.45]
	for x: float in pillars:
		mesh.box("cream_stone", Vector3(x, h * 0.5 + 0.3, hd - 0.4), Vector3(0.85, h, 0.85), Basis.IDENTITY, 0.05, 0.9)
		mesh.box("brass", Vector3(x, 0.62, hd - 0.4), Vector3(1.0, 0.18, 1.0), Basis.IDENTITY, 0.02)
	for pair: Array in [[pillars[0], pillars[1]], [pillars[2], pillars[3]]]:
		var mid: float = (float(pair[0]) + float(pair[1])) * 0.5
		var span: float = absf(float(pair[1]) - float(pair[0])) - 0.8
		mesh.box("brick", Vector3(mid, 0.9, hd - 0.4), Vector3(span, 1.1, 0.5), Basis.IDENTITY, 0.03, 0.85)
		mesh.box("cream_stone", Vector3(mid, 1.5, hd - 0.4), Vector3(span + 0.1, 0.12, 0.62), Basis.IDENTITY, 0.02)
	mesh.box("iron", Vector3(0, h + 0.1, hd - 0.4), Vector3(w + 0.3, 0.6, 0.9), Basis.IDENTITY, 0.03)
	# the gable roof (ridge front to back), deep overhangs, the brick gable over the front with the dumbbell emblem
	var pitch: float = deg_to_rad(28.0)
	var slab: float = hw / cos(pitch) + 0.9
	for side: float in [-1.0, 1.0]:
		var centre: Vector3 = Vector3(side * hw * 0.5, h + 0.4 + tan(pitch) * hw * 0.5, 0)
		mesh.box("roof", centre, Vector3(slab, 0.4, d + 1.6), Basis(Vector3(0, 0, 1), -side * pitch), 0.03, 0.95)
	var ridge: float = h + 0.4 + tan(pitch) * hw
	mesh.box("iron", Vector3(0, ridge + 0.15, 0), Vector3(0.6, 0.5, d + 1.8), Basis.IDENTITY, 0.02)
	for z: float in [hd - 0.2, -hd + 0.2]:
		var facing: Vector3 = Vector3(0, 0, 1) if z > 0.0 else Vector3(0, 0, -1)
		mesh.tri("brick", [Vector3(-hw, h + 0.4, z), Vector3(hw, h + 0.4, z), Vector3(0, ridge - 0.1, z)], facing)
	var emblem: Vector3 = Vector3(0, h + 0.4 + (ridge - h - 0.4) * 0.42, hd + 0.02)
	mesh.tube("gold", emblem, emblem + Vector3(0, 0, 0.12), 1.15, 18, true)
	mesh.box("dark", emblem + Vector3(0, 0, 0.14), Vector3(1.3, 0.2, 0.08), Basis.IDENTITY, 0.0)
	for side: float in [-1.0, 1.0]:
		mesh.box("dark", emblem + Vector3(side * 0.62, 0, 0.14), Vector3(0.22, 0.86, 0.1), Basis.IDENTITY, 0.02)
		mesh.box("dark", emblem + Vector3(side * 0.86, 0, 0.14), Vector3(0.16, 0.58, 0.1), Basis.IDENTITY, 0.02)
	# kit banners on the outer pillars
	GainlandsLandmarks._card(mesh, "GAIN-SHEET-BANNERS-02", Vector3(pillars[0], h - 0.2, hd + 0.08), 2.4, Vector3(0, 0, 1))
	GainlandsLandmarks._card(mesh, "GAIN-SHEET-BANNERS-05", Vector3(pillars[3], h - 0.2, hd + 0.08), 2.4, Vector3(0, 0, 1))
	_equipment(mesh, w, d)
	var node: Node3D = _finish(mesh, "GymHall", [] as Array[Vector3], Vector2(w, d), ridge + 0.4)
	node.set_meta("emblem", emblem)
	return node


## The equipment inside, seen through the open front: a two-tier dumbbell rack along the back wall, a barbell rack and plate trees at the sides, a squat rack
## with a loaded bar and a bench in the middle. Storybook scale (slightly oversized): dumbbells 0.55 m, plates up to 0.6 m across, the bar at 1.4 m.
static func _equipment(mesh: KitMesh, w: float, d: float) -> void:
	var back: float = -d * 0.5 + 1.0
	var floor_y: float = 0.4
	# the dumbbell rack: two sloped tiers on iron legs, twelve pairs
	var rack_w: float = w * 0.6
	for tier: int in range(2):
		var y: float = floor_y + 0.55 + 0.42 * float(tier)
		var z: float = back + 0.15 * float(1 - tier)
		mesh.box("iron", Vector3(0, y, z), Vector3(rack_w, 0.08, 0.5), Basis(Vector3(1, 0, 0), -0.25), 0.0)
		for k: int in range(6):
			var x: float = -rack_w * 0.5 + rack_w * (float(k) + 0.5) / 6.0
			var bell_r: float = 0.13 + 0.025 * float(k)
			for pair: float in [-0.18, 0.18]:
				var c: Vector3 = Vector3(x + pair, y + bell_r + 0.04, z)
				mesh.tube("iron", c + Vector3(0, 0, -0.16), c + Vector3(0, 0, 0.16), 0.035, 5, false)
				mesh.tube("dark", c + Vector3(0, 0, -0.27), c + Vector3(0, 0, -0.15), bell_r, 8, true)
				mesh.tube("dark", c + Vector3(0, 0, 0.15), c + Vector3(0, 0, 0.27), bell_r, 8, true)
	for x: float in [-rack_w * 0.5, rack_w * 0.5]:
		mesh.box("iron", Vector3(x, floor_y + 0.55, back), Vector3(0.1, 1.1, 0.6), Basis.IDENTITY, 0.0)
	# a barbell rack against the east wall: four bars standing in a frame
	var east: float = w * 0.5 - 1.1
	mesh.box("iron", Vector3(east, floor_y + 0.1, -0.6), Vector3(0.7, 0.2, 2.2), Basis.IDENTITY, 0.02)
	for k: int in range(4):
		var z: float = -1.4 + 0.52 * float(k)
		mesh.tube("iron", Vector3(east, floor_y + 0.2, z), Vector3(east - 0.15, floor_y + 2.3, z), 0.04, 5, true)
	# plate trees against the west wall: stacks of plates on a post
	for k: int in range(2):
		var base: Vector3 = Vector3(-w * 0.5 + 1.2, floor_y, -1.6 + 1.8 * float(k))
		mesh.tube("iron", base, base + Vector3(0, 1.2, 0), 0.05, 5, true)
		var y: float = 0.1
		for plate: int in range(5):
			var radius: float = 0.3 - 0.035 * float(plate)
			mesh.lathe(PLATE_COLOURS[(plate + k) % PLATE_COLOURS.size()], base + Vector3(0, y, 0), [Vector2(radius, 0.0), Vector2(radius, 0.07), Vector2(0.05, 0.07)], 14, 1.0, true, true)
			y += 0.08
	# the squat rack: two uprights, safety arms, a loaded bar on its hooks
	var rack: Vector3 = Vector3(-w * 0.12, floor_y, 0.2)
	for side: float in [-1.0, 1.0]:
		for z: float in [-0.45, 0.45]:
			mesh.box("iron", rack + Vector3(side * 0.75, 1.15, z), Vector3(0.1, 2.3, 0.1), Basis.IDENTITY, 0.0)
		mesh.box("iron", rack + Vector3(side * 0.75, 2.28, 0), Vector3(0.12, 0.08, 1.0), Basis.IDENTITY, 0.0)
		mesh.box("iron", rack + Vector3(side * 0.75, 0.8, 0.2), Vector3(0.1, 0.08, 0.7), Basis.IDENTITY, 0.0)
	mesh.tube("iron", rack + Vector3(-1.3, 1.45, -0.05), rack + Vector3(1.3, 1.45, -0.05), 0.035, 6, true)
	for side: float in [-1.0, 1.0]:
		for k: int in range(2):
			var x: float = side * (1.0 + 0.09 * float(k))
			mesh.tube("red" if k == 0 else "iron", rack + Vector3(x - 0.04, 1.45, -0.05), rack + Vector3(x + 0.04, 1.45, -0.05), 0.3 - 0.06 * float(k), 14, true)
	# a flat bench beside it
	var bench: Vector3 = Vector3(w * 0.14, floor_y, 0.6)
	mesh.box("red", bench + Vector3(0, 0.48, 0), Vector3(0.45, 0.14, 1.3), Basis.IDENTITY, 0.04)
	for z: float in [-0.5, 0.5]:
		mesh.box("iron", bench + Vector3(0, 0.22, z), Vector3(0.36, 0.44, 0.08), Basis.IDENTITY, 0.0)


static func _finish(mesh: KitMesh, node_name: String, circles: Array[Vector3], footprint: Vector2, height: float) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = node_name
	var body: MeshInstance3D = mesh.instance("Body")
	body.set_meta(PaintedClasses.META_NO_PAINT, true)
	body.set_meta(&"no_range_cull", true)
	root.add_child(body)
	root.set_meta(&"no_wind", true)
	root.set_meta("circles", circles)
	root.set_meta("footprint", footprint)
	root.set_meta("height", height)
	root.set_meta("triangles", mesh.triangle_count())
	return root
