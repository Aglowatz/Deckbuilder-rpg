class_name GainlandsFortress
extends RefCounted
## The House of Gains (GC-10): a castle-sized fortress-gym of red brick and iron beyond the north rim of the Gainlands, the goal the player can always see.
## Built from the zone kit until GAIN-HERO-HOUSE-OF-GAINS concept art arrives: a rock plinth with a grass skirt, a great brick hall with an iron-banded red-gold
## roof, four round corner towers with conical roofs and gold finials, a gatehouse with an iron portcullis between two square towers, an enormous dumbbell along
## the ridge and another over the gate, flexing brass arms on the gatehouse, red-gold kit banners, glowing windows, three foundry chimneys (meta "chimneys": the
## local tops; GainlandsBuilder adds the smoke) and a stone causeway with lantern posts reaching back onto the plateau (the layout's CAUSEWAY surface).
## Same contract as the other hero landmarks (`GainlandsLandmarks.build` dispatches here): origin on the ground at the centre, front +z, `size` = w, h, d.


## `causeway` false (Gainlands v2): the fortress stands on its rock behind the mesa top, its gate opening straight onto the mesa (no causeway).
static func build(root: Node3D, mesh: KitMesh, size: Vector3, circles: Array[Vector3], lights: Array[Dictionary], causeway: bool = true) -> void:
	var half_w: float = size.x * 0.5
	var half_d: float = size.z * 0.5
	var hall_w: float = size.x * 0.72
	var hall_d: float = size.z * 0.7
	var hall_h: float = size.y * 0.5
	var tower_r: float = size.x * 0.095
	var tower_h: float = size.y * 0.76
	# the rock the fortress stands on, with a grass skirt: both top out just under the causeway slab (-0.14) so the slab, not the grass, is the floor at the gate
	mesh.lathe("rock", Vector3(0, -16.0, 0), [Vector2(0.0, 0.0), Vector2(half_w * 0.5, 1.0), Vector2(half_w * 1.02, 10.0), Vector2(half_w * 1.1, 15.4), Vector2(half_w * 1.06, 15.86)], 14, 0.85, true, false)
	mesh.lathe("rock", Vector3(0, -0.26, 0), [Vector2(half_w * 1.06, 0.0), Vector2(half_w * 1.0, 0.12), Vector2(0.0, 0.12)], 14, 1.0, false, true)
	# the great hall: brick, an iron band, a brass string course, a pitched red-gold roof on an iron ridge (walls start below the grass: no gap at the foot)
	mesh.box("brick", Vector3(0, hall_h * 0.5 - 0.3, -1.0), Vector3(hall_w, hall_h + 0.6, hall_d), Basis.IDENTITY, 0.08, 0.86)
	mesh.box("iron", Vector3(0, hall_h + 0.5, -1.0), Vector3(hall_w + 0.9, 1.0, hall_d + 0.9), Basis.IDENTITY, 0.04)
	mesh.box("brass", Vector3(0, hall_h * 0.52, -1.0), Vector3(hall_w + 0.3, 0.5, hall_d + 0.3), Basis.IDENTITY, 0.0)
	var pitch: float = deg_to_rad(34.0)
	var slab_w: float = hall_w * 0.56
	for side: float in [-1.0, 1.0]:
		var centre: Vector3 = Vector3(side * slab_w * 0.5 * cos(pitch) * 0.98, hall_h + 1.0 + sin(pitch) * slab_w * 0.5, -1.0)
		mesh.box("roof", centre, Vector3(slab_w, 0.7, hall_d + 2.2), Basis(Vector3(0, 0, 1), -side * pitch), 0.02, 0.95)
	var ridge_y: float = hall_h + 1.0 + sin(pitch) * slab_w
	mesh.box("iron", Vector3(0, ridge_y + 0.1, -1.0), Vector3(1.2, 1.1, hall_d + 2.6), Basis.IDENTITY, 0.03)
	# the enormous dumbbell along the ridge
	mesh.tube("iron", Vector3(-hall_w * 0.3, ridge_y + 2.4, -1.0), Vector3(hall_w * 0.3, ridge_y + 2.4, -1.0), 0.6, 10, true)
	for side: float in [-1.0, 1.0]:
		mesh.blob("iron", Vector3(side * hall_w * 0.3, ridge_y + 2.4, -1.0), Vector3(3.2, 3.2, 3.2), 6, 12, 0.95)
		mesh.blob("iron", Vector3(side * (hall_w * 0.3 + 3.6), ridge_y + 2.4, -1.0), Vector3(2.5, 2.5, 2.5), 6, 12, 0.95)
		mesh.blob("red", Vector3(side * hall_w * 0.3, ridge_y + 2.4, -1.0), Vector3(3.35, 1.0, 3.35), 3, 12, 1.0)
	# glowing windows on the front and the sides of the hall, iron lintels
	for index: int in range(5):
		var x: float = -hall_w * 0.36 + hall_w * 0.18 * float(index)
		mesh.box("gold_glow", Vector3(x, hall_h * 0.58, hall_d * 0.5 - 1.0 + 0.12), Vector3(2.0, 3.2, 0.2), Basis.IDENTITY, 0.0)
		mesh.box("iron", Vector3(x, hall_h * 0.58 + 1.9, hall_d * 0.5 - 1.0 + 0.1), Vector3(2.6, 0.5, 0.3), Basis.IDENTITY, 0.0)
	for index: int in range(4):
		var z: float = -hall_d * 0.35 + hall_d * 0.23 * float(index) - 1.0
		for side: float in [-1.0, 1.0]:
			mesh.box("gold_glow", Vector3(side * (hall_w * 0.5 + 0.12), hall_h * 0.6, z), Vector3(0.2, 3.0, 1.8), Basis.IDENTITY, 0.0)
	# four round corner towers: brick, an iron collar, brick crenels, a conical red-gold roof, a gold finial, a banner on the front pair
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			var centre: Vector3 = Vector3(sx * (half_w - tower_r - 0.5), 0.0, sz * (half_d - tower_r - 0.8) - 1.0)
			mesh.lathe("brick", centre - Vector3(0, 0.6, 0), [Vector2(tower_r * 1.15, 0.0), Vector2(tower_r * 1.15, 1.8), Vector2(tower_r, 2.6), Vector2(tower_r, tower_h + 0.6)], 12, 0.88, true, false)
			mesh.lathe("iron", centre + Vector3(0, tower_h, 0), [Vector2(tower_r * 1.12, 0.0), Vector2(tower_r * 1.12, 1.1), Vector2(tower_r * 0.9, 1.1)], 12, 1.0, false, true)
			for crenel: int in range(8):
				var angle: float = TAU * float(crenel) / 8.0
				mesh.box("brick", centre + Vector3(cos(angle) * tower_r * 0.95, tower_h + 1.75, sin(angle) * tower_r * 0.95), Vector3(1.4, 1.3, 1.4), Basis(Vector3.UP, -angle), 0.02)
			mesh.lathe("roof", centre + Vector3(0, tower_h + 2.2, 0), [Vector2(tower_r * 1.2, 0.0), Vector2(tower_r * 0.5, size.y * 0.13), Vector2(0.0, size.y * 0.2)], 12, 0.95, true, true)
			mesh.blob("gold", centre + Vector3(0, tower_h + 2.2 + size.y * 0.2 + 0.5, 0), Vector3(0.9, 0.9, 0.9), 4, 8, 1.0)
			if sz > 0.0:
				GainlandsLandmarks._card(mesh, "GAIN-SHEET-BANNERS-02" if sx < 0.0 else "GAIN-SHEET-BANNERS-05", centre + Vector3(0, tower_h * 0.78, tower_r + 0.15), tower_h * 0.42, Vector3(0, 0, 1))
	# the gatehouse: two square towers, the gate wall with an iron arch, the portcullis, brass studs, lanterns, a banner on each tower
	var gate_z: float = half_d - 2.0
	var gt_w: float = size.x * 0.13
	var gt_h: float = size.y * 0.62
	for side: float in [-1.0, 1.0]:
		var x: float = side * (gt_w * 0.5 + 4.6)
		mesh.box("brick", Vector3(x, gt_h * 0.5 - 0.3, gate_z), Vector3(gt_w, gt_h + 0.6, gt_w), Basis.IDENTITY, 0.06, 0.86)
		mesh.box("iron", Vector3(x, gt_h + 0.4, gate_z), Vector3(gt_w + 0.8, 0.8, gt_w + 0.8), Basis.IDENTITY, 0.03)
		for crenel: int in range(3):
			mesh.box("brick", Vector3(x - gt_w * 0.38 + gt_w * 0.38 * float(crenel), gt_h + 1.5, gate_z + gt_w * 0.38), Vector3(gt_w * 0.22, 1.4, gt_w * 0.22), Basis.IDENTITY, 0.02)
		GainlandsLandmarks._card(mesh, "GAIN-SHEET-BANNERS-03" if side < 0.0 else "GAIN-SHEET-BANNERS-06", Vector3(x, gt_h * 0.7, gate_z + gt_w * 0.5 + 0.12), gt_h * 0.4, Vector3(0, 0, 1))
		# a flexing brass arm on each gatehouse tower
		var shoulder: Vector3 = Vector3(x + side * gt_w * 0.3, gt_h + 1.6, gate_z + gt_w * 0.5 + 0.6)
		var elbow: Vector3 = shoulder + Vector3(side * 2.4, 2.2, 0.0)
		var fist: Vector3 = elbow + Vector3(-side * 1.6, 3.0, 0.0)
		mesh.tube("gold", shoulder, elbow, 0.9, 8, true)
		mesh.blob("gold", shoulder + Vector3(side * 0.9, 1.5, 0.0), Vector3(1.5, 1.3, 1.3), 5, 10, 1.0)
		mesh.tube("gold", elbow, fist, 0.75, 8, true)
		mesh.blob("gold", fist + Vector3(0, 0.5, 0), Vector3(1.15, 1.15, 1.15), 5, 10, 1.0)
		GainlandsLandmarks._torch(mesh, Vector3(side * 3.9, 5.2, gate_z + 2.3), lights, 1.2)
		circles.append(Vector3(x, gate_z, gt_w * 0.5 + 0.4))
	var wall_h: float = size.y * 0.42
	mesh.box("brick", Vector3(0, wall_h * 0.5 - 0.3, gate_z - 0.4), Vector3(9.4, wall_h + 0.6, 3.6), Basis.IDENTITY, 0.05, 0.86)
	mesh.box("iron", Vector3(0, wall_h + 0.35, gate_z - 0.4), Vector3(10.2, 0.7, 4.2), Basis.IDENTITY, 0.03)
	GainlandsLandmarks._arch_ring(mesh, "iron", Vector3(0, 8.2, gate_z + 1.3), 3.9, 0.8, 1.2, 10)
	mesh.box("dark", Vector3(0, 4.1, gate_z + 1.0), Vector3(6.6, 8.2, 0.5), Basis.IDENTITY, 0.0)
	for bar: int in range(6):
		mesh.tube("iron", Vector3(-2.75 + 1.1 * float(bar), 0.3, gate_z + 1.45), Vector3(-2.75 + 1.1 * float(bar), 9.2, gate_z + 1.45), 0.12, 5, true)
	for bar: int in range(3):
		mesh.tube("iron", Vector3(-3.3, 2.0 + 2.6 * float(bar), gate_z + 1.5), Vector3(3.3, 2.0 + 2.6 * float(bar), gate_z + 1.5), 0.1, 5, true)
	for stud: int in range(8):
		mesh.blob("brass", Vector3(-3.2 + 0.9 * float(stud), 9.9, gate_z + 1.4), Vector3(0.28, 0.28, 0.28), 3, 6, 1.0)
	# the dumbbell over the gate
	mesh.tube("brass", Vector3(-4.2, wall_h + 2.4, gate_z + 0.6), Vector3(4.2, wall_h + 2.4, gate_z + 0.6), 0.42, 8, true)
	for side: float in [-1.0, 1.0]:
		mesh.blob("iron", Vector3(side * 4.2, wall_h + 2.4, gate_z + 0.6), Vector3(1.9, 1.9, 1.9), 5, 10, 0.95)
		mesh.blob("red", Vector3(side * 4.2, wall_h + 2.4, gate_z + 0.6), Vector3(2.0, 0.7, 2.0), 3, 10, 1.0)
	# three foundry chimneys at the back of the hall
	var chimneys: Array[Vector3] = []
	for index: int in range(3):
		var x: float = (float(index) - 1.0) * hall_w * 0.3
		var top: float = ridge_y + 6.0 + float(index % 2) * 1.5
		mesh.lathe("brick", Vector3(x, hall_h - 1.0, -hall_d * 0.3), [Vector2(1.9, 0.0), Vector2(1.6, top - hall_h + 1.0)], 10, 0.9, true, true)
		mesh.lathe("iron", Vector3(x, top, -hall_d * 0.3), [Vector2(2.1, 0.0), Vector2(2.1, 0.8), Vector2(1.5, 0.8)], 10, 1.0, false, true)
		chimneys.append(Vector3(x, top + 0.9, -hall_d * 0.3))
	root.set_meta("chimneys", chimneys)
	if not causeway:
		return
	# the causeway from the gate back onto the plateau: a stone slab, brass edges, parapets, lantern posts at both ends
	var cause_len: float = 10.0
	var cause_z: float = gate_z + 2.0 + cause_len * 0.5
	# (the slab tops out at -0.1, the walking height of the layout CAUSEWAY)
	mesh.box("stone", Vector3(0, -0.45, cause_z), Vector3(5.4, 0.7, cause_len), Basis.IDENTITY, 0.03, 0.9)
	mesh.box("brass", Vector3(0, -0.09, cause_z), Vector3(5.5, 0.06, cause_len), Basis.IDENTITY, 0.0)
	for side: float in [-1.0, 1.0]:
		mesh.box("stone", Vector3(side * 2.85, 0.1, cause_z), Vector3(0.36, 0.5, cause_len), Basis.IDENTITY, 0.02, 0.9)
		for z: float in [gate_z + 3.0, gate_z + 2.0 + cause_len - 1.0]:
			var post: Vector3 = Vector3(side * 3.0, 0.2, z)
			GainlandsLandmarks._post(mesh, post, 2.4, 0.14, "iron", false)
			GainlandsLandmarks._torch(mesh, post + Vector3(0, 2.4, 0), lights, 0.7)
