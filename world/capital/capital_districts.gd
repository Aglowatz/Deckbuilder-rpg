class_name CapitalDistricts
extends RefCounted
## The four service districts' hero models and the Correction Ward (docs/art/zone_kits/final/concepts/CAP-HERO-TRAM-SHED, -IDENTICAL-ROW,
## -GRAVE-ROW, -THE-REEK, -CORRECTION-WARD). Each district concept shows the district BROKEN (left half) and RESTORED (right half); the model takes
## `state` ("broken" until its Path's zone is freed, then "restored") and builds that half on the same footprint, so no route changes. The
## restored state brings back the Path's warmth: red-gold and lit trams (the Beefcakes), copper, cream, warm ovens and real food (the Gourmands),
## calm green lanterns and flowers (the Necrocrats), clean compost and a little garden (the Refusemancers). Called through
## `CapitalLandmarks.build`; `size` is the layout building's footprint (w along local x, h, d along local z), origin at its centre, the front +z.

const K = preload("res://world/capital/capital_kit.gd")
const L = preload("res://world/capital/capital_landmarks.gd")

const GREEN_LANTERN: Color = Color("8af0b0")
const BROKEN_GREY: Color = Color(0.72, 0.72, 0.76)


static func build(spec: Dictionary) -> Node3D:
	var id: String = str(spec.get("id", ""))
	var size_array: Array = spec.get("size", [4.0, 4.0, 4.0]) as Array
	var size: Vector3 = Vector3(float(size_array[0]), float(size_array[1]), float(size_array[2]))
	var restored: bool = str(spec.get("state", "broken")) == "restored"
	match id:
		"CAP-HERO-TRAM-SHED":
			return tram_shed(size, restored)
		"CAP-HERO-IDENTICAL-ROW":
			return row_house(size, restored)
		"CAP-HERO-GRAVE-ROW":
			return mausoleum(size, restored)
		"CAP-HERO-THE-REEK":
			return reek_yard(size, restored, int(spec.get("seed", 0)))
		"CAP-HERO-CORRECTION-WARD":
			return ward_piece(size, str(spec.get("piece", "side")), bool(spec.get("final", false)))
	return null


static func _mesh(restored: bool) -> KitMesh:
	var mesh: KitMesh = KitMesh.new()
	K.materials(mesh)
	mesh.set_material("lamp_off", EnvKit.flat(Color("3c3a40"), "cap_lamp_off"))
	mesh.set_material("green_glow", EnvKit.glow(GREEN_LANTERN, 2.0))
	if not restored:
		# the broken half of each concept is the same city with the colour drained out of its signs of life
		mesh.set_material("window_warm", EnvKit.flat(Color("2e2c34"), "cap_window_dead"))
	return mesh


## A painted card, greyed while the district is broken (stalled trams, dead flowers read flat and still).
static func _card(mesh: KitMesh, id: String, pivot: Vector3, height: float, normal: Vector3, restored: bool, flip: bool = false) -> void:
	K.card(mesh, id, pivot, height, normal, flip, Color.WHITE if restored else BROKEN_GREY)


## A street lamp in the mesh: a white pole, a gold cap, a round globe lit (`lit`) or dead.
static func _lamp(mesh: KitMesh, base: Vector3, height: float, lit: bool) -> void:
	mesh.tube("plaster", base, base + Vector3(0, height, 0), 0.07, 6)
	mesh.lathe("gold", base, [Vector2(0.2, 0.0), Vector2(0.14, 0.3)], 8, 1.0, false, true)
	mesh.blob("lamp" if lit else "lamp_off", base + Vector3(0, height + 0.22, 0), Vector3(0.24, 0.24, 0.24), 4, 10)
	K.finial(mesh, base + Vector3(0, height + 0.42, 0), 0.35)


# ---- the Transit Yards: the tram shed (CAP-HERO-TRAM-SHED) -----------------------------------------------------------------------------------


## A long white-and-gold tram shed open to the yard: three arched bays between gold-capped piers, a slate-blue glass roof, a pastel tram stalled in
## every bay on its rails under a Primm banner. BROKEN: the lights dead, the trams grey and still, holes in the roof, dead shrubs, grime down the
## piers. RESTORED (the Beefcakes are free): the globes and the bay lanterns lit, red-and-gold bunting across the arches, flowers, the trams bright.
static func tram_shed(size: Vector3, restored: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "TramShed"
	var mesh: KitMesh = _mesh(restored)
	var w: float = size.x
	var d: float = size.z
	var h: float = size.y
	mesh.box("plaster", Vector3(0, 0.08, 0), Vector3(w + 0.6, 0.16, d + 0.6), Basis.IDENTITY, 0.03)
	mesh.box("plaster", Vector3(0, h * 0.5, -d * 0.5 + 0.2), Vector3(w, h, 0.4), Basis.IDENTITY, 0.0, 0.8)
	for side: float in [-1.0, 1.0]:
		mesh.box("plaster", Vector3(side * (w * 0.5 - 0.2), h * 0.5, 0), Vector3(0.4, h, d), Basis.IDENTITY, 0.0, 0.8)
		K.arched_window(mesh, Vector3(side * (w * 0.5 + 0.01), 1.6, 0), 1.4, 3.0, Vector3(side, 0, 0), "mirror")
	# the arcade: four piers, three arches, the spandrel and the cornice
	var bays: int = 3
	var bay_w: float = w / float(bays)
	var spring: float = h * 0.62
	for index: int in range(bays + 1):
		var x: float = -w * 0.5 + bay_w * float(index)
		x = clampf(x, -w * 0.5 + 0.35, w * 0.5 - 0.35)
		mesh.box("plaster", Vector3(x, h * 0.5, d * 0.5 - 0.35), Vector3(0.7, h, 0.7), Basis.IDENTITY, 0.04, 0.85)
		mesh.box("gold", Vector3(x, spring, d * 0.5 - 0.35), Vector3(0.85, 0.22, 0.85))
		K.finial(mesh, Vector3(x, h + 0.55, d * 0.5 - 0.35), 1.2)
		if not restored:
			L.band(mesh, "stone_dark", Vector3(x - 0.15, 0.3, d * 0.5 + 0.02), Vector3(x + 0.05, spring - 0.4, d * 0.5 + 0.02), 0.12, Vector3(0, 0, 1))
	mesh.box("plaster", Vector3(0, (spring + h) * 0.5 + 0.4, d * 0.5 - 0.35), Vector3(w, h - spring - 0.8, 0.6))
	mesh.box("trim", Vector3(0, h - 0.25, d * 0.5 - 0.02), Vector3(w + 0.2, 0.5, 0.1))
	for index: int in range(bays):
		var cx: float = -w * 0.5 + bay_w * (float(index) + 0.5)
		var half: float = bay_w * 0.5 - 0.35
		var previous: Vector3 = Vector3(cx - half, spring, d * 0.5 - 0.02)
		for step: int in range(1, 9):
			var t: float = PI * float(step) / 8.0
			var point: Vector3 = Vector3(cx - cos(t) * half, spring + sin(t) * half * 0.8, d * 0.5 - 0.02)
			L.band(mesh, "gold", previous, point, 0.16, Vector3(0, 0, 1))
			mesh.quad("plaster", [previous, point, Vector3(point.x, spring + half * 0.8 + 0.4, point.z), Vector3(previous.x, spring + half * 0.8 + 0.4, previous.z)], Vector3(0, 0, 1))
			previous = point
		# the stalled (or running) tram on its rails, the banner hanging in the arch, the bay's lantern
		for rail: float in [-0.55, 0.55]:
			mesh.box("iron", Vector3(cx + rail, 0.2, 0.4), Vector3(0.1, 0.08, d + 1.2))
		_card(mesh, "CAP-PROP-TRAM", Vector3(cx, 0.18, -0.3), 2.1, Vector3(0, 0, 1), restored)
		K.card(mesh, "CAP-SHEET-BANNERS-04", Vector3(cx, spring + half * 0.75, d * 0.5 - 0.6), 1.7, Vector3(0, 0, 1))
		mesh.blob("lamp" if restored else "lamp_off", Vector3(cx, spring - 0.6, d * 0.5 - 1.2), Vector3(0.22, 0.28, 0.22), 4, 8)
		if restored:
			# red-and-gold bunting across the arch
			for flag: int in range(5):
				var fx: float = cx - half + (float(flag) + 0.5) * half * 2.0 / 5.0
				var sag: float = 0.3 * sin(PI * (float(flag) + 0.5) / 5.0)
				mesh.tri("red_gold" if flag % 2 == 0 else "gold", [Vector3(fx - 0.2, spring - 0.2 - sag, d * 0.5 + 0.05), Vector3(fx + 0.2, spring - 0.2 - sag, d * 0.5 + 0.05), Vector3(fx, spring - 0.65 - sag, d * 0.5 + 0.05)], Vector3(0, 0, 1))
	# the hipped glass roof: slate-blue, holed while broken, skylights lit once restored
	CapitalCastle._hip_roof(mesh, Vector3(0, h, 0), Vector2(w + 0.4, d + 0.4), 2.2, "roof_blue")
	for index: int in range(3):
		var x: float = -w * 0.3 + float(index) * w * 0.3
		var c: Vector3 = Vector3(x, h + 1.15, d * 0.18)
		var slot: String = "dark" if not restored else "window_warm"
		mesh.quad(slot, [c + Vector3(-0.6, -0.3, 0.55), c + Vector3(0.6, -0.3, 0.55), c + Vector3(0.6, 0.3, -0.05), c + Vector3(-0.6, 0.3, -0.05)], Vector3(0, 1, 0.5))
	# lamp posts and planters at the front corners
	for side: float in [-1.0, 1.0]:
		_lamp(mesh, Vector3(side * (w * 0.5 + 0.7), 0, d * 0.5 + 0.6), 3.2, restored)
		K.post(mesh, Vector3(side * (w * 0.5 - 1.2), 0, d * 0.5 + 0.9), Vector3(0.9, 0.6, 0.6), false)
		if restored:
			K.card(mesh, "CAP-PLANT-ROSE", Vector3(side * (w * 0.5 - 1.2), 0.62, d * 0.5 + 0.95), 0.8, Vector3(0, 0, 1))
		else:
			K.card(mesh, "CAP-TREE-DEAD", Vector3(side * (w * 0.5 - 1.2), 0.62, d * 0.5 + 0.95), 1.1, Vector3(0, 0, 1))
	L.finish(root, mesh, [], h + 2.4)
	if restored:
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = Color("ffd29a")
		light.light_energy = 1.1
		light.omni_range = 9.0
		light.position = Vector3(0, spring - 0.8, d * 0.5)
		root.add_child(light)
		root.set_meta("lights", [light])
	return root


# ---- the Hungry Quarter: the identical row (CAP-HERO-IDENTICAL-ROW) -------------------------------------------------------------------------


## One house of the identical row (all six alike, only tiny differences): white plaster in a gold half-timber frame, a pink tiled roof with a
## gold-capped chimney, a pink-and-cream striped awning over two display windows and a pink door with Primm's face. BROKEN: cold ovens, empty
## shelves with bowls of grey uniform paste, a torn awning, dead shrubs in the planters, the lamps dark. RESTORED (the Gourmands are free): warm
## ovens glowing through the windows, real colourful food on the shelves, copper pots and a cream awning, flowers, the lamps lit.
static func row_house(size: Vector3, restored: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "RowHouse"
	var mesh: KitMesh = _mesh(restored)
	var w: float = size.x
	var d: float = size.z
	var h: float = size.y
	var front: float = d * 0.5
	mesh.box("plaster", Vector3(0, h * 0.5, 0), Vector3(w, h, d), Basis.IDENTITY, 0.03, 0.82)
	# the gold half-timber frame on the front and the sides
	for y: float in [0.12, h * 0.48, h - 0.1]:
		mesh.box("gold", Vector3(0, y, front + 0.03), Vector3(w + 0.06, 0.14, 0.06))
		for side: float in [-1.0, 1.0]:
			mesh.box("gold", Vector3(side * (w * 0.5 + 0.03), y, 0), Vector3(0.06, 0.14, d + 0.06))
	for x: float in [-w * 0.5, -w * 0.17, w * 0.17, w * 0.5]:
		mesh.box("gold", Vector3(x, h * 0.5, front + 0.03), Vector3(0.14, h, 0.06))
	for x: float in [-w * 0.33, w * 0.33]:
		L.band(mesh, "gold", Vector3(x - w * 0.15, h * 0.5, front + 0.04), Vector3(x + w * 0.15, h - 0.1, front + 0.04), 0.12, Vector3(0, 0, 1))
	# the pink roof: a gable along the front, its gable ends plastered and gold-edged
	var rise: float = 1.8
	var ridge_a: Vector3 = Vector3(-w * 0.5 - 0.25, h + rise, 0)
	var ridge_b: Vector3 = Vector3(w * 0.5 + 0.25, h + rise, 0)
	for side: float in [-1.0, 1.0]:
		var eave: float = side * (d * 0.5 + 0.35)
		mesh.quad("roof_pink", [Vector3(-w * 0.5 - 0.25, h - 0.1, eave), Vector3(w * 0.5 + 0.25, h - 0.1, eave), ridge_b, ridge_a], Vector3(0, 0.8, side))
		mesh.tri("plaster", [Vector3(side * w * 0.5, h, -d * 0.5), Vector3(side * w * 0.5, h, d * 0.5), Vector3(side * w * 0.5, h + rise - 0.05, 0)], Vector3(side, 0, 0))
		L.band(mesh, "gold", Vector3(side * (w * 0.5 + 0.27), h - 0.1, d * 0.5 + 0.35), Vector3(side * (w * 0.5 + 0.27), h + rise, 0), 0.12, Vector3(side, 0, 0))
		L.band(mesh, "gold", Vector3(side * (w * 0.5 + 0.27), h - 0.1, -d * 0.5 - 0.35), Vector3(side * (w * 0.5 + 0.27), h + rise, 0), 0.12, Vector3(side, 0, 0))
	if not restored:
		# missing tiles: dark holes in the front slope
		for hole: Vector2 in [Vector2(-w * 0.25, 0.4), Vector2(w * 0.3, 0.7)]:
			var c: Vector3 = Vector3(hole.x, h - 0.1 + rise * hole.y, (d * 0.5 + 0.35) * (1.0 - hole.y) + 0.03)
			mesh.quad("dark", [c + Vector3(-0.3, -0.15, 0.1), c + Vector3(0.3, -0.15, 0.1), c + Vector3(0.3, 0.15, -0.1), c + Vector3(-0.3, 0.15, -0.1)], Vector3(0, 0.8, 1))
	mesh.box("plaster", Vector3(w * 0.28, h + rise + 0.2, -d * 0.18), Vector3(0.55, 1.4, 0.55))
	mesh.box("gold", Vector3(w * 0.28, h + rise + 0.95, -d * 0.18), Vector3(0.7, 0.14, 0.7))
	K.finial(mesh, Vector3(w * 0.28, h + rise + 1.02, -d * 0.18), 0.5)
	# the shop front: the pink door with the face, two display windows with shelves, the striped awning
	mesh.box("door_pink", Vector3(0, 1.0, front + 0.04), Vector3(0.8, 2.0, 0.08))
	mesh.box("gold", Vector3(0, 2.05, front + 0.06), Vector3(1.0, 0.1, 0.1))
	K.emblem(mesh, Vector3(0, 1.5, front + 0.09), 0.17, Vector3(0, 0, 1))
	for side: float in [-1.0, 1.0]:
		var wx: float = side * w * 0.33
		var bottom: Vector3 = Vector3(wx, 0.55, front + 0.02)
		K.arched_window(mesh, bottom, 0.9, 1.35, Vector3(0, 0, 1), "window_warm")
		for shelf: float in [0.95, 1.35]:
			mesh.box("wood", Vector3(wx, shelf, front + 0.05), Vector3(0.8, 0.04, 0.06))
			for item: int in range(3):
				var ix: float = wx - 0.26 + 0.26 * float(item)
				if restored:
					var food: String = ["cake_pink", "bread", "berry"][(item + int(shelf * 10.0)) % 3]
					mesh.blob(food, Vector3(ix, shelf + 0.09, front + 0.08), Vector3(0.09, 0.08, 0.05), 3, 8)
				else:
					mesh.lathe("food_grey", Vector3(ix, shelf + 0.02, front + 0.08), [Vector2(0.06, 0.0), Vector2(0.09, 0.08)], 8, 1.0, false, true)
		if restored:
			mesh.tube("copper", Vector3(wx - 0.2, 1.85, front + 0.08), Vector3(wx + 0.2, 1.85, front + 0.08), 0.03, 5)
			mesh.lathe("copper", Vector3(wx, 1.6, front + 0.1), [Vector2(0.07, 0.0), Vector2(0.11, 0.12), Vector2(0.1, 0.2)], 8, 1.0, true, false)
		# lanterns either side of the door
		mesh.blob("lamp" if restored else "lamp_off", Vector3(side * 0.62, 1.9, front + 0.18), Vector3(0.1, 0.13, 0.1), 3, 8)
		# planters
		K.post(mesh, Vector3(side * (w * 0.5 - 0.35), 0, front + 0.35), Vector3(0.55, 0.45, 0.45), false)
		if restored:
			K.card(mesh, "CAP-TREE-TOPIARY" if side < 0.0 else "CAP-PLANT-ROSE", Vector3(side * (w * 0.5 - 0.35), 0.46, front + 0.4), 1.2 if side < 0.0 else 0.6, Vector3(0, 0, 1))
		else:
			K.card(mesh, "CAP-TREE-DEAD", Vector3(side * (w * 0.5 - 0.35), 0.46, front + 0.4), 0.8, Vector3(0, 0, 1))
	var stripes: int = 8
	for index: int in range(stripes):
		var x0: float = -w * 0.5 + w * float(index) / float(stripes)
		var x1: float = -w * 0.5 + w * float(index + 1) / float(stripes)
		var colour: String = "rose" if index % 2 == 0 else ("cream" if restored else "paper")
		var droop: float = 0.0 if restored else (0.18 if index % 3 == 1 else 0.0)
		mesh.quad(colour, [Vector3(x0, 2.3, front + 0.05), Vector3(x1, 2.3, front + 0.05), Vector3(x1, 1.95 - droop, front + 0.75), Vector3(x0, 1.95, front + 0.75)], Vector3(0, 0.8, 1))
		mesh.quad(colour, [Vector3(x0, 1.95, front + 0.75), Vector3(x1, 1.95 - droop, front + 0.75), Vector3(x1, 1.75 - droop, front + 0.77), Vector3(x0, 1.75, front + 0.77)], Vector3(0, 0, 1))
	L.finish(root, mesh, [], h + rise + 1.2)
	if restored:
		var oven: OmniLight3D = OmniLight3D.new()
		oven.light_color = Color("ffb070")
		oven.light_energy = 0.7
		oven.omni_range = 4.0
		oven.position = Vector3(0, 1.3, front + 0.9)
		root.add_child(oven)
		root.set_meta("lights", [oven])
	return root


# ---- Grave Row: the mausoleum (CAP-HERO-GRAVE-ROW) -----------------------------------------------------------------------------------------


## A white-and-gold mausoleum of Grave Row (its chapel in the concept): plaster walls on a stepped plinth, gold corner pilasters, a blue hipped
## roof, a gabled front with Primm's face in a gold ring, an arched gold door. BROKEN: the door ajar on darkness, a crack, unfiled paper blowing on
## the steps, dead shrubs. RESTORED (the Necrocrats are free): calm green lanterns either side of the door, flowers and topiaries, the door shut.
static func mausoleum(size: Vector3, restored: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "Mausoleum"
	var mesh: KitMesh = _mesh(restored)
	var w: float = size.x
	var d: float = size.z
	var h: float = size.y - 1.2
	var front: float = d * 0.5
	mesh.box("marble_shade", Vector3(0, 0.15, 0.2), Vector3(w + 0.6, 0.3, d + 0.8), Basis.IDENTITY, 0.03)
	mesh.box("marble_shade", Vector3(0, 0.38, 0.1), Vector3(w + 0.3, 0.16, d + 0.4), Basis.IDENTITY, 0.02)
	mesh.box("plaster", Vector3(0, 0.46 + h * 0.5, 0), Vector3(w, h, d), Basis.IDENTITY, 0.03, 0.82)
	mesh.box("trim", Vector3(0, 0.46 + h - 0.2, front + 0.03), Vector3(w + 0.06, 0.4, 0.06))
	for side: float in [-1.0, 1.0]:
		mesh.box("gold", Vector3(side * (w * 0.5 - 0.1), 0.46 + h * 0.5, front + 0.05), Vector3(0.28, h, 0.12))
		K.finial(mesh, Vector3(side * (w * 0.5 - 0.1), 0.46 + h + 0.05, front + 0.05), 0.8)
	var top: float = 0.46 + h
	CapitalCastle._hip_roof(mesh, Vector3(0, top, 0), Vector2(w + 0.4, d + 0.4), 1.6, "roof_blue")
	var g0: Vector3 = Vector3(-w * 0.32, top, front + 0.06)
	var g1: Vector3 = Vector3(w * 0.32, top, front + 0.06)
	var apex: Vector3 = Vector3(0, top + 1.3, front + 0.06)
	mesh.tri("plaster", [g0, g1, apex], Vector3(0, 0, 1))
	L.band(mesh, "gold", g0, apex, 0.1, Vector3(0, 0, 1))
	L.band(mesh, "gold", apex, g1, 0.1, Vector3(0, 0, 1))
	K.finial(mesh, apex, 0.9)
	K.emblem(mesh, Vector3(0, top + 0.45, front + 0.09), 0.36, Vector3(0, 0, 1))
	# the arched door: shut and gold once restored, ajar on darkness while broken
	K.arched_window(mesh, Vector3(0, 0.46, front + 0.02), 1.3, 2.3, Vector3(0, 0, 1), "gold" if restored else "dark")
	if not restored:
		mesh.box("wood_dark", Vector3(0.5, 0.46 + 0.9, front + 0.35), Vector3(0.08, 1.8, 0.62), Basis(Vector3.UP, 0.7))
		L.band(mesh, "stone_dark", Vector3(-w * 0.32, 0.6, front + 0.04), Vector3(-w * 0.26, h * 0.7, front + 0.04), 0.06, Vector3(0, 0, 1))
		for paper: Vector3 in [Vector3(-0.6, 0.32, front + 0.55), Vector3(0.7, 0.32, front + 0.75), Vector3(0.2, 0.05, front + 1.1)]:
			mesh.quad("paper", [paper + Vector3(-0.15, 0.01, -0.1), paper + Vector3(0.15, 0.01, -0.12), paper + Vector3(0.16, 0.02, 0.1), paper + Vector3(-0.14, 0.01, 0.12)], Vector3.UP)
	for side: float in [-1.0, 1.0]:
		var lantern: Vector3 = Vector3(side * (w * 0.5 + 0.35), 0, front + 0.3)
		K.post(mesh, lantern, Vector3(0.36, 1.3, 0.36), false)
		mesh.blob("green_glow" if restored else "lamp_off", lantern + Vector3(0, 1.62, 0), Vector3(0.17, 0.22, 0.17), 4, 8)
		K.finial(mesh, lantern + Vector3(0, 1.8, 0), 0.3)
		if restored:
			K.card(mesh, "CAP-PLANT-ROSE", Vector3(side * (w * 0.5 - 0.5), 0.3, front + 0.75), 0.6, Vector3(0, 0, 1))
			K.card(mesh, "CAP-TREE-TOPIARY", Vector3(side * (w * 0.5 + 1.0), 0.0, front - 0.6), 2.2, Vector3(0, 0, 1))
		else:
			K.card(mesh, "CAP-TREE-DEAD", Vector3(side * (w * 0.5 + 1.0), 0.0, front - 0.6), 1.8, Vector3(0, 0, 1))
	L.finish(root, mesh, [], top + 1.6)
	if restored:
		var calm: OmniLight3D = OmniLight3D.new()
		calm.light_color = GREEN_LANTERN
		calm.light_energy = 0.8
		calm.omni_range = 5.0
		calm.position = Vector3(0, 1.6, front + 0.8)
		root.add_child(calm)
		root.set_meta("lights", [calm])
	return root


# ---- the Reek: the back yards (CAP-HERO-THE-REEK) ---------------------------------------------------------------------------------------------


## A back yard of the Reek: the rear wall of a perfect house (plaster, a pink parapet, a blue awning) on the footprint's back half, the yard in
## front of it toward the lane. BROKEN: a perfect painted screen of white-and-gold panels (painted topiaries, Primm's face) standing at the yard's
## front hides the overflowing bins, the black bags, the grime and the stink behind it, flies over the heap. RESTORED (the Refusemancers are free):
## the screen is gone; clean compost bins, a raised bed of flowers and greens, moss and wildflowers, vines down the wall, a watering can.
static func reek_yard(size: Vector3, restored: bool, seed_value: int) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "ReekYard"
	var mesh: KitMesh = _mesh(restored)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 5150 + seed_value
	var w: float = size.x
	var d: float = size.z
	var h: float = size.y
	var back: float = -d * 0.5
	# the rear wall of the house and its parapet
	mesh.box("plaster", Vector3(0, h * 0.5, back + 0.6), Vector3(w, h, 1.2), Basis.IDENTITY, 0.02, 0.8)
	mesh.box("roof_pink", Vector3(0, h + 0.25, back + 0.6), Vector3(w + 0.2, 0.5, 1.4))
	mesh.box("trim", Vector3(0, h - 0.2, back + 1.22), Vector3(w, 0.3, 0.05))
	K.arched_window(mesh, Vector3(-w * 0.25, h * 0.45, back + 1.21), 0.8, 1.4, Vector3(0, 0, 1), "mirror")
	K.arched_window(mesh, Vector3(w * 0.25, h * 0.45, back + 1.21), 0.8, 1.4, Vector3(0, 0, 1), "mirror")
	var yard: float = back + 1.2
	if not restored:
		# grime down the back wall, the overflowing bins and bags, a slick of stink
		for streak: int in range(3):
			var x: float = rng.randf_range(-w * 0.4, w * 0.4)
			L.band(mesh, "stone_dark", Vector3(x, h * 0.9, back + 1.22), Vector3(x + rng.randf_range(-0.2, 0.2), 0.2, back + 1.22), 0.25, Vector3(0, 0, 1))
		for index: int in range(3):
			var bx: float = -w * 0.32 + float(index) * w * 0.32
			mesh.box("bin", Vector3(bx, 0.5, yard + 0.6), Vector3(1.0, 1.0, 0.8), Basis(Vector3.UP, rng.randf_range(-0.1, 0.1)), 0.04, 0.6)
			mesh.box("bin_dark", Vector3(bx, 1.05, yard + 0.45), Vector3(1.05, 0.08, 0.85), Basis(Vector3.RIGHT, -0.35), 0.02)
			mesh.blob("bag", Vector3(bx + 0.1, 1.15, yard + 0.6), Vector3(0.35, 0.3, 0.3), 3, 8)
		for index: int in range(5):
			mesh.blob("bag", Vector3(rng.randf_range(-w * 0.45, w * 0.45), 0.25, yard + rng.randf_range(1.2, 1.8)), Vector3(0.32, 0.28, 0.32), 3, 8)
		mesh.quad("slime", [Vector3(-w * 0.35, 0.03, yard + 1.0), Vector3(w * 0.3, 0.03, yard + 1.1), Vector3(w * 0.25, 0.03, yard + 1.9), Vector3(-w * 0.3, 0.03, yard + 1.8)], Vector3.UP)
		mesh.box("crate", Vector3(w * 0.38, 0.3, yard + 1.5), Vector3(0.6, 0.6, 0.6), Basis(Vector3.UP, 0.4), 0.03, 0.8)
		# the perfect painted screen at the yard's front: white panels in gold frames, painted topiaries and Primm's face
		var screen_z: float = d * 0.5 - 0.15
		var panels: int = maxi(2, int(w / 1.6))
		for index: int in range(panels):
			var x0: float = -w * 0.5 + w * float(index) / float(panels)
			var x1: float = -w * 0.5 + w * float(index + 1) / float(panels)
			var cx: float = (x0 + x1) * 0.5
			mesh.box("plaster", Vector3(cx, 1.15, screen_z), Vector3(x1 - x0 - 0.06, 2.3, 0.12))
			mesh.quad("gold", [Vector3(x0 + 0.08, 0.25, screen_z + 0.07), Vector3(x1 - 0.08, 0.25, screen_z + 0.07), Vector3(x1 - 0.08, 0.32, screen_z + 0.07), Vector3(x0 + 0.08, 0.32, screen_z + 0.07)], Vector3(0, 0, 1))
			mesh.quad("gold", [Vector3(x0 + 0.08, 2.0, screen_z + 0.07), Vector3(x1 - 0.08, 2.0, screen_z + 0.07), Vector3(x1 - 0.08, 2.07, screen_z + 0.07), Vector3(x0 + 0.08, 2.07, screen_z + 0.07)], Vector3(0, 0, 1))
			if index % 2 == 0:
				mesh.tri("hedge", [Vector3(cx - 0.3, 0.4, screen_z + 0.075), Vector3(cx + 0.3, 0.4, screen_z + 0.075), Vector3(cx, 1.8, screen_z + 0.075)], Vector3(0, 0, 1))
			else:
				K.emblem(mesh, Vector3(cx, 1.15, screen_z + 0.08), 0.42, Vector3(0, 0, 1))
			K.post(mesh, Vector3(x0 + 0.05, 0, screen_z), Vector3(0.18, 2.4, 0.18), true)
		K.post(mesh, Vector3(w * 0.5 - 0.05, 0, screen_z), Vector3(0.18, 2.4, 0.18), true)
	else:
		# vines and flower boxes down the clean wall, compost bins, the raised bed, moss and wildflowers, a watering can
		for vine: int in range(4):
			var x: float = -w * 0.4 + float(vine) * w * 0.27
			L.band(mesh, "moss", Vector3(x, h, back + 1.23), Vector3(x + rng.randf_range(-0.3, 0.3), h * 0.3, back + 1.23), 0.3, Vector3(0, 0, 1))
			mesh.blob("rose", Vector3(x, h * 0.55, back + 1.3), Vector3(0.12, 0.1, 0.06), 3, 6)
		for index: int in range(2):
			var bx: float = -w * 0.28 + float(index) * w * 0.4
			mesh.box("wood", Vector3(bx, 0.45, yard + 0.6), Vector3(1.1, 0.9, 0.9), Basis.IDENTITY, 0.03, 0.75)
			mesh.box("compost", Vector3(bx, 0.88, yard + 0.6), Vector3(0.95, 0.06, 0.75))
			for slat: float in [0.2, 0.45, 0.7]:
				mesh.box("wood_dark", Vector3(bx, slat, yard + 1.06), Vector3(1.12, 0.05, 0.03))
		mesh.box("wood", Vector3(0, 0.25, d * 0.5 - 0.7), Vector3(w * 0.8, 0.5, 1.0), Basis.IDENTITY, 0.03, 0.8)
		mesh.box("soil", Vector3(0, 0.51, d * 0.5 - 0.7), Vector3(w * 0.76, 0.03, 0.9))
		for index: int in range(int(w * 2.0)):
			var fx: float = -w * 0.36 + float(index) * (w * 0.72) / maxf(float(int(w * 2.0)) - 1.0, 1.0)
			var bloom: String = ["wildflower", "rose", "lavender", "leaf"][index % 4]
			mesh.tube("leaf", Vector3(fx, 0.52, d * 0.5 - 0.7 + rng.randf_range(-0.3, 0.3)), Vector3(fx, 0.85, d * 0.5 - 0.7), 0.02, 4)
			mesh.blob(bloom, Vector3(fx, 0.9, d * 0.5 - 0.7), Vector3(0.1, 0.08, 0.1), 3, 6)
		for patch: int in range(4):
			var p: Vector3 = Vector3(rng.randf_range(-w * 0.45, w * 0.45), 0.02, yard + rng.randf_range(1.4, 2.0))
			mesh.quad("moss", [p + Vector3(-0.4, 0, -0.3), p + Vector3(0.4, 0, -0.3), p + Vector3(0.4, 0, 0.3), p + Vector3(-0.4, 0, 0.3)], Vector3.UP)
		mesh.lathe("iron", Vector3(w * 0.4, 0, yard + 1.6), [Vector2(0.14, 0.0), Vector2(0.14, 0.25), Vector2(0.08, 0.3)], 8, 1.0, false, true)
	L.finish(root, mesh, [], h + 0.5)
	if not restored:
		var flies: CPUParticles3D = CPUParticles3D.new()
		flies.name = "Flies"
		flies.amount = 10
		flies.lifetime = 2.0
		flies.preprocess = 2.0
		flies.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
		flies.emission_sphere_radius = 0.6
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
		flies.material_override = EnvKit.flat(Color("181818"), "cap_fly")
		flies.position = Vector3(0, 1.6, yard + 0.6)
		root.add_child(flies)
	return root


# ---- the Correction Ward (CAP-HERO-CORRECTION-WARD) ------------------------------------------------------------------------------------------


## A piece of the Correction Ward's walled compound (the layout's five "ward" walls, world-aligned: `size` x along x, z along z): gleaming white
## plaster with a gold band and a balustrade, barred mirrored windows on the outer faces, blue-capped turrets at the corners. The north piece is the
## Ward itself (the concept): a cheerful white palace front facing the yard with a blue dome, gold spires, tall barred mirrored windows and Primm's
## smiling sign over a gold door, standing on the compound's north edge. `piece` is "north", "south_w", "south_e", "side_w" or "side_e". Cheerful outside,
## sinister in detail: the bars, the mirrored glass you cannot see into, the lawn with no one on it.
static func ward_piece(size: Vector3, piece: String, final_state: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "Ward_%s" % piece
	var mesh: KitMesh = KitMesh.new()
	K.materials(mesh, Color(0.62, 0.57, 0.5) if final_state else Color.WHITE)
	var w: float = size.x
	var d: float = size.z
	var h: float = size.y
	mesh.box("plaster", Vector3(0, h * 0.5, 0), Vector3(w, h, d), Basis.IDENTITY, 0.02, 0.82)
	mesh.box("trim", Vector3(0, h - 0.3, 0), Vector3(w + 0.08, 0.35, d + 0.08))
	var along_x: bool = w >= d
	var length: float = w if along_x else d
	CapitalCastle._balustrade(mesh, Vector3(-w * 0.5, h, 0) if along_x else Vector3(0, h, -d * 0.5), Vector3(w * 0.5, h, 0) if along_x else Vector3(0, h, d * 0.5))
	# barred mirrored windows along the outer face(s)
	var faces: Array[Vector3] = []
	match piece:
		"south_w", "south_e":
			faces = [Vector3(0, 0, 1)]
		"side_w":
			faces = [Vector3(-1, 0, 0)]
		"side_e":
			faces = [Vector3(1, 0, 0)]
	for normal: Vector3 in faces:
		var count: int = int(length / 3.0)
		for index: int in range(count):
			var t: float = -length * 0.5 + (float(index) + 0.5) * length / float(count)
			var center: Vector3 = (Vector3(t, 0, 0) if along_x else Vector3(0, 0, t)) + normal * ((d if along_x else w) * 0.5 + 0.01)
			_barred_window(mesh, center + Vector3(0, 1.5, 0), normal)
	if piece == "north":
		_ward_front(mesh, w, h, d, final_state)
	if piece in ["south_w", "south_e"]:
		# the turret on the outer corner and the gold gate post at the door's side
		var outer_x: float = -w * 0.5 if piece == "south_w" else w * 0.5
		K.spire(mesh, Vector3(outer_x, 0, 0), 1.3, h + 2.5, 3.0, "roof_blue", false)
		var gate_x: float = -outer_x
		K.post(mesh, Vector3(gate_x, 0, 0.2), Vector3(0.7, h + 0.6, 0.7), true)
		_lamp_on_post(mesh, Vector3(gate_x, 0, 0.9))
	L.finish(root, mesh, [], h + 6.0)
	return root


static func _lamp_on_post(mesh: KitMesh, base: Vector3) -> void:
	_lamp(mesh, base, 3.0, true)


## A tall mirrored window with iron bars across it, on a wall facing `normal`, its middle at `center`.
static func _barred_window(mesh: KitMesh, center: Vector3, normal: Vector3) -> void:
	K.arched_window(mesh, center - Vector3(0, 0.9, 0), 1.1, 2.0, normal, "mirror")
	var right: Vector3 = Vector3.UP.cross(normal).normalized()
	for bar: int in range(4):
		var x: float = -0.42 + 0.28 * float(bar)
		mesh.box("iron_dark", center + right * x + normal * 0.08 - Vector3(0, 0.05, 0), Vector3(0.05, 1.9, 0.05) if absf(normal.z) > 0.5 else Vector3(0.05, 1.9, 0.05))
	mesh.box("iron_dark", center + normal * 0.08 + Vector3(0, 0.2, 0), Vector3(1.0, 0.05, 0.05) if absf(normal.z) > 0.5 else Vector3(0.05, 0.05, 1.0))


## The Ward's palace front on the compound's north piece, facing the yard (+z): a raised central pavilion with a blue dome and a gold spire, Primm's
## smiling sign in gold over a tall gold door of mirrored glass, wings of tall barred mirrored windows, blue-capped turrets at its ends.
static func _ward_front(mesh: KitMesh, w: float, h: float, d: float, final_state: bool) -> void:
	var front: float = d * 0.5
	var body_h: float = 9.0
	# the building rises behind the compound wall (north, beyond the yard) and shows its front over it
	mesh.box("plaster", Vector3(0, body_h * 0.5, -1.2), Vector3(w - 2.0, body_h, 2.6), Basis.IDENTITY, 0.04, 0.8)
	for y: float in [h + 0.2, body_h - 0.3]:
		mesh.box("trim", Vector3(0, y, front - 1.0 + 0.04), Vector3(w - 2.0, 0.4, 0.08))
	CapitalCastle._balustrade(mesh, Vector3(-w * 0.5 + 1.0, body_h, front - 1.1), Vector3(w * 0.5 - 1.0, body_h, front - 1.1))
	for index: int in range(8):
		var x: float = -w * 0.5 + 2.4 + float(index) * (w - 4.8) / 7.0
		if absf(x) < 3.5:
			continue
		K.arched_window(mesh, Vector3(x, h + 0.9, front - 0.96), 1.2, 2.6, Vector3(0, 0, 1), "mirror")
		for bar: int in range(3):
			mesh.box("iron_dark", Vector3(x - 0.3 + 0.3 * float(bar), h + 2.1, front - 0.9), Vector3(0.05, 2.4, 0.05))
	# the central pavilion, its dome, the door and the smiling sign
	mesh.box("plaster", Vector3(0, (body_h + 3.0) * 0.5, front - 1.6), Vector3(7.0, body_h + 3.0, 3.6), Basis.IDENTITY, 0.04, 0.82)
	mesh.box("trim", Vector3(0, body_h + 2.7, front + 0.21), Vector3(7.1, 0.4, 0.08))
	mesh.lathe("roof_blue", Vector3(0, body_h + 3.0, front - 1.6), [Vector2(3.2, 0.0), Vector2(3.0, 1.4), Vector2(2.2, 3.0), Vector2(1.0, 4.0), Vector2(0.0, 4.3)], 18, 1.0, false, false)
	for index: int in range(6):
		var angle: float = TAU * float(index) / 6.0
		L.band(mesh, "gold", Vector3(0, body_h + 3.0, front - 1.6) + Vector3(cos(angle) * 3.15, 0.1, sin(angle) * 3.15), Vector3(0, body_h + 7.25, front - 1.6), 0.14, Vector3(cos(angle), 0.6, sin(angle)).normalized())
	K.finial(mesh, Vector3(0, body_h + 7.2, front - 1.6), 2.0)
	K.arched_window(mesh, Vector3(0, h + 0.1, front + 0.21), 2.4, 4.6, Vector3(0, 0, 1), "mirror")
	K.emblem(mesh, Vector3(0, body_h + 0.4, front + 0.24), 1.3, Vector3(0, 0, 1), final_state, final_state)
	for side: float in [-1.0, 1.0]:
		K.spire(mesh, Vector3(side * 4.2, 0, front - 0.6), 1.0, body_h + 4.0, 3.2, "roof_blue", false)
		K.spire(mesh, Vector3(side * (w * 0.5 - 0.6), 0, 0), 1.4, body_h + 1.0, 3.6)
