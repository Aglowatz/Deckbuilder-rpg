class_name CapitalSides
extends RefCounted
## The Capital sides pass (Nov 2, docs/art/capital_rebuild_nov1.md "The sides pass"): the inner districts either side of the boulevard axis built to
## the same grandeur as the centre. The districts' houses are CapitalGrand townhouses on their footprints (wide fronts, three or four storeys)
## with each district's SERVICE LAYER at the foot: the broken state's clutter in the Capital's own finish (perfect even when broken: white enamel
## bins with gold lids behind a painted screen in the Reek, grey paste on marble shelves under a drooping awning in the Hungry Quarter, empty
## gold urns and dead lanterns on Grave Row) and the restored state's life (compost bins and a raised bed, real food and warm ovens, green
## lanterns and topiary). The plaza corners' pylons are gate piers (a plinth, a pilaster, a gilded urn). The inner faces of the city's walls wear a
## blind arcade (pilasters, gold arches, banners in rhythm) with engaged towers rising from the wall at regular intervals, so no long blank wall
## shows and the skyline is spires from every angle. Front of every piece = its local +z face.

const G = preload("res://world/capital/capital_grand.gd")
const K = preload("res://world/capital/capital_kit.gd")
const L = preload("res://world/capital/capital_landmarks.gd")

const GREEN_LANTERN: Color = Color("8af0b0")
## The arcade's rhythm along the walls' inner faces: a pilaster every PILASTER_STEP, a banner in every second bay, a tower every TOWER_STEP.
const PILASTER_STEP: float = 4.0
const TOWER_STEP: float = 14.0
const ARCADE_HEIGHT: float = 7.6
## The engaged towers stand on the wall's top (the wall is 9 m) and rise TOWER_HEIGHT to their eaves (the spire above).
const WALL_TOP: float = 9.0
const TOWER_HEIGHT: float = 13.0


# ---- the districts' grand houses ---------------------------------------------------------------------------------------------------------------


## A district's house: a townhouse on `size` (w, h, d; the storeys from h) with the district's service layer. `district` is "refusemancer",
## "necrocrat" or "gourmand"; `restored` once its Path is free; `final_state` once Primm has fallen.
static func district_house(district: String, size: Vector3, restored: bool, final_state: bool, seed_value: int = 0) -> Node3D:
	var w: float = size.x
	var d: float = size.z
	var storeys: int = clampi(int(roundf(size.y / G.STOREY)), 3, 5)
	var bays: int = clampi(int(roundf(w / 2.4)), 2, 5)
	var spec: Dictionary = {"w": w, "d": d, "storeys": storeys, "bays": bays, "final": final_state, "banner": "", "balcony": true, "pediment": true}
	match district:
		"refusemancer":
			spec["accent"] = "sage"
			spec["roof"] = "hip"
			spec["door"] = "CAP-SHEET-DOORS-02"
		"necrocrat":
			spec["accent"] = "lavender"
			spec["roof"] = "gable"
			spec["pediment"] = false
			spec["balcony"] = false
			spec["door"] = "CAP-SHEET-DOORS-05"
		_:
			spec["accent"] = "pink"
			spec["roof"] = "mansard"
			spec["door"] = "CAP-SHEET-DOORS-03"
	var lights: Array = []
	# the service layer goes into the townhouse's own detail mesh (perf: no extra draw call per house)
	spec["service"] = func(service: KitMesh, house: Node3D) -> void:
		service.set_material("lamp_off", EnvKit.flat(Color("dcd8d0"), "cap_lamp_off"))
		service.set_material("green_glow", EnvKit.glow(GREEN_LANTERN, 2.0))
		service.alias("loam", "flat", Color("8a6a48").srgb_to_linear())
		match district:
			"refusemancer":
				_reek_service(house, service, w, d, restored)
			"necrocrat":
				lights.append_array(_grave_service(house, service, w, d, restored))
			_:
				lights.append_array(_hungry_service(house, service, w, d, restored, seed_value))
	var root: Node3D = G.townhouse(spec)
	root.name = "DistrictHouse_" + district
	if not lights.is_empty():
		var all: Array = root.get_meta("lights", []) as Array
		all.append_array(lights)
		root.set_meta("lights", all)
	root.set_meta("district", district)
	return root


## The Reek: the garbage behind the facade. BROKEN: a painted screen of white-and-gold panels (painted topiaries, Primm's face) stands across the
## front; behind it, between the screen and the house, white enamel bins with gold lids in an exact row either side of the door and cream sacks
## in a row, flies over them. RESTORED: the screen gone; white compost bins with gold slats, a raised white bed of blooms in a row, moss squares
## in a row, a gold watering can.
static func _reek_service(root: Node3D, mesh: KitMesh, w: float, d: float, restored: bool) -> void:
	var front: float = d * 0.5
	var hw: float = w * 0.5
	if not restored:
		var screen_z: float = front + 1.7
		_perfect_screen(mesh, -hw + 0.2, hw - 0.2, screen_z, 2.3)
		var bins: int = maxi(1, int((hw - 1.3) / 1.1))
		for side: float in [-1.0, 1.0]:
			for index: int in range(bins):
				var x: float = side * (1.3 + 0.5 + float(index) * 1.1)
				G.gilded_bin(mesh, Vector3(x, 0.0, front + 0.55), 0.0, index % 2 == 0)
			for index: int in range(bins):
				G.sack(mesh, Vector3(side * (1.5 + float(index) * 1.1), 0.24, front + 1.25), Vector3(0.3, 0.24, 0.28))
		var flies: CPUParticles3D = CPUParticles3D.new()
		flies.name = "Flies"
		flies.amount = 12
		flies.lifetime = 2.0
		flies.preprocess = 2.0
		flies.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
		flies.emission_box_extents = Vector3(hw - 1.0, 0.3, 0.5)
		flies.direction = Vector3.UP
		flies.spread = 180.0
		flies.initial_velocity_min = 0.3
		flies.initial_velocity_max = 0.8
		flies.gravity = Vector3.ZERO
		var fly: SphereMesh = SphereMesh.new()
		fly.radius = 0.025
		fly.height = 0.05
		fly.radial_segments = 4
		fly.rings = 2
		flies.mesh = fly
		flies.material_override = EnvKit.flat(Color("4a4a52"), "cap_fly")
		flies.position = Vector3(0, 1.5, front + 0.9)
		root.add_child(flies)
	else:
		for side: float in [-1.0, 1.0]:
			var bx: float = side * (hw * 0.55)
			mesh.box("marble", Vector3(bx, 0.45, front + 0.65), Vector3(1.1, 0.9, 0.9), Basis.IDENTITY, 0.03, 0.85)
			mesh.box("loam", Vector3(bx, 0.88, front + 0.65), Vector3(0.95, 0.06, 0.75))
			for slat: float in [0.2, 0.45, 0.7]:
				mesh.box("gold", Vector3(bx, slat, front + 1.11), Vector3(1.12, 0.05, 0.03))
		var bed_z: float = front + 1.75
		mesh.box("marble", Vector3(0, 0.25, bed_z), Vector3(w * 0.8, 0.5, 0.9), Basis.IDENTITY, 0.03, 0.88)
		mesh.box("gold", Vector3(0, 0.51, bed_z), Vector3(w * 0.84, 0.04, 0.94))
		mesh.box("loam", Vector3(0, 0.52, bed_z), Vector3(w * 0.76, 0.03, 0.8))
		var blooms: int = maxi(3, int(w * 1.6))
		for index: int in range(blooms):
			var fx: float = -w * 0.36 + float(index) * (w * 0.72) / maxf(float(blooms - 1), 1.0)
			var bloom: String = ["wildflower", "rose", "lavender", "leaf"][index % 4]
			mesh.tube("leaf", Vector3(fx, 0.52, bed_z), Vector3(fx, 0.85, bed_z), 0.02, 4)
			mesh.blob(bloom, Vector3(fx, 0.9, bed_z), Vector3(0.1, 0.08, 0.1), 3, 6)
		for patch: int in range(3):
			var p: Vector3 = Vector3(-w * 0.3 + float(patch) * w * 0.3, 0.02, front + 1.1)
			mesh.quad("moss", [p + Vector3(-0.35, 0, -0.25), p + Vector3(0.35, 0, -0.25), p + Vector3(0.35, 0, 0.25), p + Vector3(-0.35, 0, 0.25)], Vector3.UP)
		mesh.lathe("gold", Vector3(hw - 0.5, 0, front + 1.2), [Vector2(0.14, 0.0), Vector2(0.14, 0.25), Vector2(0.08, 0.3)], 8, 1.0, false, true)


## The perfect painted screen the Reek hides behind: white panels in gold frames from `x0` to `x1` at `z`, `h` tall, painted topiaries and
## Primm's face by turns, gold posts between.
static func _perfect_screen(mesh: KitMesh, x0: float, x1: float, z: float, h: float) -> void:
	var span: float = x1 - x0
	var panels: int = maxi(2, int(span / 1.7))
	for index: int in range(panels):
		var p0: float = x0 + span * float(index) / float(panels)
		var p1: float = x0 + span * float(index + 1) / float(panels)
		var cx: float = (p0 + p1) * 0.5
		mesh.box("plaster", Vector3(cx, h * 0.5, z), Vector3(p1 - p0 - 0.06, h, 0.12))
		for y: float in [0.25, h - 0.3]:
			mesh.quad("gold", [Vector3(p0 + 0.08, y, z + 0.07), Vector3(p1 - 0.08, y, z + 0.07), Vector3(p1 - 0.08, y + 0.07, z + 0.07), Vector3(p0 + 0.08, y + 0.07, z + 0.07)], Vector3(0, 0, 1))
		if index % 2 == 0:
			mesh.tri("hedge", [Vector3(cx - 0.3, 0.4, z + 0.075), Vector3(cx + 0.3, 0.4, z + 0.075), Vector3(cx, h - 0.5, z + 0.075)], Vector3(0, 0, 1))
		else:
			K.emblem(mesh, Vector3(cx, h * 0.5, z + 0.08), 0.42, Vector3(0, 0, 1))
		K.post(mesh, Vector3(p0 + 0.05, 0, z), Vector3(0.18, h + 0.1, 0.18), true)
	K.post(mesh, Vector3(x1 - 0.05, 0, z), Vector3(0.18, h + 0.1, 0.18), true)


## Grave Row: the permit-locked chapel row. BROKEN: dead lanterns on posts either side of the door, empty gold urns in a row along the front,
## unfiled paper on the step. RESTORED: the lanterns calm green (a light), topiary cones in the urns, roses at the door. Returns the lights.
static func _grave_service(root: Node3D, mesh: KitMesh, w: float, d: float, restored: bool) -> Array:
	var front: float = d * 0.5
	var hw: float = w * 0.5
	var lights: Array = []
	mesh.box("marble_shade", Vector3(0, 0.08, front + 0.5), Vector3(w + 0.4, 0.16, 1.0), Basis.IDENTITY, 0.02, 0.9)
	for side: float in [-1.0, 1.0]:
		var lantern: Vector3 = Vector3(side * 1.5, 0.16, front + 0.6)
		K.post(mesh, lantern, Vector3(0.36, 1.3, 0.36), false)
		mesh.blob("green_glow" if restored else "lamp_off", lantern + Vector3(0, 1.62, 0), Vector3(0.17, 0.22, 0.17), 4, 8)
		K.finial(mesh, lantern + Vector3(0, 1.8, 0), 0.3)
	var urns: int = maxi(1, int((hw - 2.2) / 1.6))
	for side: float in [-1.0, 1.0]:
		for index: int in range(urns):
			var at: Vector3 = Vector3(side * (2.6 + float(index) * 1.6), 0.16, front + 0.6)
			G.gold_urn(mesh, at, 0.36)
			if restored:
				K.card(mesh, "CAP-TREE-TOPIARY", at + Vector3(0, 0.66, 0.02), 1.3, Vector3(0, 0, 1))
	if not restored:
		for paper: Vector3 in [Vector3(-0.6, 0.17, front + 0.7), Vector3(0.55, 0.17, front + 0.85), Vector3(0.1, 0.02, front + 1.25)]:
			mesh.quad("paper", [paper + Vector3(-0.15, 0.01, -0.1), paper + Vector3(0.15, 0.01, -0.12), paper + Vector3(0.16, 0.02, 0.1), paper + Vector3(-0.14, 0.01, 0.12)], Vector3.UP)
	else:
		for side: float in [-1.0, 1.0]:
			K.card(mesh, "CAP-PLANT-ROSE", Vector3(side * 0.9, 0.17, front + 0.95), 0.55, Vector3(0, 0, 1))
		var calm: OmniLight3D = OmniLight3D.new()
		calm.light_color = GREEN_LANTERN
		calm.light_energy = 0.8
		calm.omni_range = 5.0
		calm.position = Vector3(0, 1.7, front + 0.9)
		root.add_child(calm)
		lights.append(calm)
	return lights


## The Hungry Quarter: the identical shop fronts. The striped awning runs the whole front over the ground floor; under every window a marble
## shelf. BROKEN: bowls of grey uniform paste on the shelves, the awning's cream stripes faded and one in three drooping, the lanterns dead.
## RESTORED: real colourful food, copper pots, a bright awning, the lanterns lit and a warm oven light. Returns the lights.
static func _hungry_service(root: Node3D, mesh: KitMesh, w: float, d: float, restored: bool, seed_value: int) -> Array:
	var front: float = d * 0.5
	var hw: float = w * 0.5
	var lights: Array = []
	var bays: int = clampi(int(roundf(w / 2.4)), 2, 5)
	var inner: float = w - 1.0
	for bay: int in range(bays):
		if bay == bays / 2:
			continue  # the door
		var wx: float = ((float(bay) + 0.5) / float(bays) - 0.5) * inner
		for shelf: float in [0.95, 1.35]:
			mesh.box("marble", Vector3(wx, shelf, front + 0.07), Vector3(0.8, 0.04, 0.08))
			for item: int in range(3):
				var ix: float = wx - 0.26 + 0.26 * float(item)
				if restored:
					var food: String = ["cake_pink", "bread", "berry"][(item + int(shelf * 10.0) + seed_value) % 3]
					mesh.blob(food, Vector3(ix, shelf + 0.09, front + 0.1), Vector3(0.09, 0.08, 0.05), 3, 8)
				else:
					mesh.lathe("food_grey", Vector3(ix, shelf + 0.02, front + 0.1), [Vector2(0.06, 0.0), Vector2(0.09, 0.08)], 8, 1.0, false, true)
		if restored:
			mesh.tube("copper", Vector3(wx - 0.2, 1.85, front + 0.1), Vector3(wx + 0.2, 1.85, front + 0.1), 0.03, 5)
			mesh.lathe("copper", Vector3(wx, 1.6, front + 0.12), [Vector2(0.07, 0.0), Vector2(0.11, 0.12), Vector2(0.1, 0.2)], 8, 1.0, true, false)
	for side: float in [-1.0, 1.0]:
		mesh.blob("lamp" if restored else "lamp_off", Vector3(side * 1.25, 2.0, front + 0.2), Vector3(0.1, 0.13, 0.1), 3, 8)
	var stripes: int = maxi(6, int(w * 1.6))
	for index: int in range(stripes):
		var x0: float = -hw + w * float(index) / float(stripes)
		var x1: float = -hw + w * float(index + 1) / float(stripes)
		var colour: String = "rose" if index % 2 == 0 else ("cream" if restored else "paper")
		var droop: float = 0.0 if restored else (0.18 if index % 3 == 1 else 0.0)
		mesh.quad(colour, [Vector3(x0, 2.35, front + 0.05), Vector3(x1, 2.35, front + 0.05), Vector3(x1, 2.0 - droop, front + 0.8), Vector3(x0, 2.0, front + 0.8)], Vector3(0, 0.8, 1))
		mesh.quad(colour, [Vector3(x0, 2.0, front + 0.8), Vector3(x1, 2.0 - droop, front + 0.8), Vector3(x1, 1.8 - droop, front + 0.82), Vector3(x0, 1.8, front + 0.82)], Vector3(0, 0, 1))
	if restored:
		var oven: OmniLight3D = OmniLight3D.new()
		oven.light_color = Color("ffb070")
		oven.light_energy = 0.7
		oven.omni_range = 5.0
		oven.position = Vector3(0, 1.3, front + 1.0)
		root.add_child(oven)
		lights.append(oven)
	return lights


# ---- the gate piers --------------------------------------------------------------------------------------------------------------------------


## A gate pier for the plaza's corners (the rebuild's 2 x 2 pylons read as skinny towers): a stepped plinth, a square pilaster with gold bands
## and the sun emblem on every face, a cornice, a gilded urn with a flame finial on top. About 6.5 m; never a tower.
static func gate_pier(final_state: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "GatePier"
	var mesh: KitMesh = G.mesh_for(final_state)
	mesh.box("marble_shade", Vector3(0, 0.15, 0), Vector3(2.0, 0.3, 2.0), Basis.IDENTITY, 0.03, 0.85)
	mesh.box("plaster", Vector3(0, 0.45, 0), Vector3(1.7, 0.3, 1.7), Basis.IDENTITY, 0.03, 0.9)
	mesh.box("plaster", Vector3(0, 0.6 + 1.9, 0), Vector3(1.3, 3.8, 1.3), Basis.IDENTITY, 0.08, 0.86)
	mesh.box("trim", Vector3(0, 0.72, 0), Vector3(1.46, 0.24, 1.46))
	mesh.box("trim", Vector3(0, 4.28, 0), Vector3(1.54, 0.24, 1.54))
	mesh.box("plaster", Vector3(0, 4.5, 0), Vector3(1.7, 0.2, 1.7), Basis.IDENTITY, 0.02)
	for normal: Vector3 in [Vector3(0, 0, 1), Vector3(0, 0, -1), Vector3(1, 0, 0), Vector3(-1, 0, 0)]:
		K.sun_emblem(mesh, normal * 0.66 + Vector3(0, 2.6, 0), 0.3, normal)
		var right: Vector3 = Vector3.UP.cross(normal).normalized()
		for side: float in [-1.0, 1.0]:
			mesh.box("gold", normal * 0.66 + right * side * 0.5 + Vector3(0, 2.5, 0), Vector3(0.05, 3.2, 0.03) if absf(normal.z) > 0.5 else Vector3(0.03, 3.2, 0.05))
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			mesh.blob("gold", Vector3(sx * 0.65, 4.28, sz * 0.65), Vector3(0.12, 0.12, 0.12), 3, 6)
	G.gold_urn(mesh, Vector3(0, 4.6, 0), 0.62)
	K.finial(mesh, Vector3(0, 5.3, 0), 1.4)
	L.finish(root, mesh, [Vector3(0, 0, 1.0)], 6.7)
	return root


# ---- the walls' inner faces ---------------------------------------------------------------------------------------------------------------


## The blind arcade along the inner faces of the west, east and north walls, with the engaged towers: one merged piece, never culled or faded
## (it lies on the city's edge, never between the trailing camera and the hero).
static func wall_dressing(parent: Node3D, final_state: bool) -> Node3D:
	# Import Nov 8 (Part 3): the finished, merged arcade and towers are one stored subtree per story state (about 0.4 s a visit); it merges into
	# its own batches before it is stored, so the copy draws exactly as the live build.
	var stored: Node3D = BuildCache.fetch_node("capital_wall_dressing_%d" % (1 if final_state else 0), func() -> Node: return _make_wall_dressing(parent, final_state)) as Node3D
	if stored != null and stored.get_parent() == null:
		parent.add_child(stored)
	return stored


static func _make_wall_dressing(parent: Node3D, final_state: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "WallDressing"
	parent.add_child(root)
	var mesh: KitMesh = G.mesh_for(final_state)
	var hill: Rect2i = CapitalLayout.HILL
	var top: float = float(CapitalLayout.WALL_Z0)
	# [face point a, face point b, outward-into-the-city normal]
	var runs: Array = [
		[Vector3(1.25, 0, 3.0), Vector3(1.25, 0, top - 1.0), Vector3(1, 0, 0)],
		[Vector3(117.75, 0, 3.0), Vector3(117.75, 0, top - 1.0), Vector3(-1, 0, 0)],
		[Vector3(3.0, 0, 2.0), Vector3(float(hill.position.x) - 1.0, 0, 2.0), Vector3(0, 0, 1)],
		[Vector3(float(hill.end.x) + 1.0, 0, 2.0), Vector3(117.0, 0, 2.0), Vector3(0, 0, 1)],
	]
	var tower_index: int = 0
	for run: Array in runs:
		var a: Vector3 = run[0] as Vector3
		var b: Vector3 = run[1] as Vector3
		var normal: Vector3 = run[2] as Vector3
		var along: Vector3 = (b - a).normalized()
		var length: float = a.distance_to(b)
		_arcade(mesh, a, along, length, normal)
		# the engaged towers on the wall's top, TOWER_STEP apart, centred on the run
		var towers: int = int(length / TOWER_STEP)
		var start: float = (length - float(towers - 1) * TOWER_STEP) * 0.5
		for index: int in range(towers):
			var at: Vector3 = a + along * (start + float(index) * TOWER_STEP) - normal * 1.25
			var roof: String = ["roof_pink", "roof_blue", "gold"][tower_index % 3]
			var tower: Node3D = G.tower(TOWER_HEIGHT, 1.25, roof, final_state, true)
			tower.position = Vector3(at.x, WALL_TOP, at.z)
			tower.rotation_degrees.y = rad_to_deg(atan2(normal.x, normal.z))
			root.add_child(tower)
			tower_index += 1
	var node: MeshInstance3D = mesh.instance("Arcade")
	node.set_meta(PaintedClasses.META_NO_PAINT, true)
	node.set_meta(&"no_wind", true)
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(node)
	for child: Node in root.find_children("*", "MeshInstance3D", true, false):
		child.set_meta(&"kit_static", true)
	L.mark_view(root)
	KitBatch.merge_static(root, 4096.0)
	parent.remove_child(root)
	return root


## The arcade along one run: pilasters every PILASTER_STEP (gold caps and bases), a gold semicircular arch between each pair over a cream blind
## panel, a gold string course along the top, a painted sun banner hung in every second bay.
static func _arcade(mesh: KitMesh, a: Vector3, along: Vector3, length: float, normal: Vector3) -> void:
	var bays: int = maxi(1, int(length / PILASTER_STEP))
	var step: float = length / float(bays)
	var depth: float = 0.7
	var across: Vector3 = normal * depth * 0.5
	var pil: Vector3 = Vector3(0.5, ARCADE_HEIGHT, depth) if absf(normal.x) > 0.5 else Vector3(depth, ARCADE_HEIGHT, 0.5)
	if absf(normal.x) > 0.5:
		pil = Vector3(depth, ARCADE_HEIGHT, 0.5)
	for index: int in range(bays + 1):
		var p: Vector3 = a + along * (step * float(index)) + across
		mesh.box("plaster", p + Vector3(0, ARCADE_HEIGHT * 0.5, 0), pil, Basis.IDENTITY, 0.03, 0.88)
		mesh.box("gold", p + Vector3(0, ARCADE_HEIGHT + 0.08, 0), Vector3(pil.x + 0.16, 0.16, pil.z + 0.16))
		mesh.box("gold", p + Vector3(0, 0.3, 0), Vector3(pil.x + 0.1, 0.1, pil.z + 0.1))
	# the string course along the whole run at the arcade's top, and the cornice band
	var mid: Vector3 = a + along * (length * 0.5) + normal * 0.08
	var course: Vector3 = Vector3(length, 0.2, 0.16) if absf(normal.z) > 0.5 else Vector3(0.16, 0.2, length)
	mesh.box("trim", mid + Vector3(0, ARCADE_HEIGHT + 0.3, 0), course)
	for index: int in range(bays):
		var c: Vector3 = a + along * (step * (float(index) + 0.5)) + normal * 0.04
		var half: float = step * 0.5 - 0.35
		var spring: float = ARCADE_HEIGHT - 0.6 - half
		# the blind panel (a cream recess) and the gold arch over it
		mesh.quad("accent_cream", [c - along * half + Vector3(0, 0.5, 0), c + along * half + Vector3(0, 0.5, 0), c + along * half + Vector3(0, spring, 0), c - along * half + Vector3(0, spring, 0)], normal)
		var previous: Vector3 = c - along * half + Vector3(0, spring, 0)
		for s: int in range(1, 9):
			var t: float = PI * float(s) / 8.0
			var point: Vector3 = c - along * cos(t) * half + Vector3(0, spring + sin(t) * half, 0)
			mesh.tri("accent_cream", [previous, point, c + Vector3(0, spring, 0)], normal)
			L.band(mesh, "gold", previous, point, 0.14, normal)
			previous = point
		if index % 2 == 1:
			G.card_rolled(mesh, G.BANNER_TOWER, c + normal * 0.2 + Vector3(0, spring - 0.3, 0), 3.0, normal, 0.0)
		else:
			K.sun_emblem(mesh, c + normal * 0.06 + Vector3(0, spring + half * 0.45, 0), half * 0.3, normal)
		match index % 4:
			0:
				# a niche with a small gilded Primm on a gold bracket (the second rhythm of statues)
				var bracket: Vector3 = c + normal * 0.25 + Vector3(0, 2.4, 0)
				mesh.box("gold", bracket, Vector3(0.9, 0.12, 0.5) if absf(normal.z) > 0.5 else Vector3(0.5, 0.12, 0.9))
				mesh.box("plaster", bracket - Vector3(0, 0.3, 0) - normal * 0.1, Vector3(0.6, 0.5, 0.3) if absf(normal.z) > 0.5 else Vector3(0.3, 0.5, 0.6), Basis.IDENTITY, 0.03)
				K.card(mesh, G.STATUE_ART, bracket + Vector3(0, 0.07, 0) + normal * 0.05, 1.7, normal)
			2:
				# a wall basin: a half-round marble bowl against the wall with a gold spout, water in it
				var bowl: Vector3 = c + normal * 0.1
				mesh.lathe("marble", bowl, [Vector2(0.55, 0.0), Vector2(0.75, 0.5), Vector2(0.8, 0.75), Vector2(0.58, 0.75), Vector2(0.58, 0.55)], 12, 0.9, false, false)
				mesh.lathe("gold", bowl + Vector3(0, 0.75, 0), [Vector2(0.84, 0.0), Vector2(0.84, 0.06), Vector2(0.55, 0.06)], 12, 1.0, false, false)
				mesh.lathe("water", bowl + Vector3(0, 0.68, 0), [Vector2(0.57, 0.0), Vector2(0.0, 0.0)], 12, 1.0, false, false)
				K.sun_emblem(mesh, c + normal * 0.06 + Vector3(0, 1.5, 0), 0.22, normal)
				mesh.blob("gold", c + normal * 0.2 + Vector3(0, 1.3, 0), Vector3(0.1, 0.1, 0.16), 3, 6)
				mesh.box("water", c + normal * 0.3 + Vector3(0, 1.0, 0), Vector3(0.06, 0.6, 0.06))
