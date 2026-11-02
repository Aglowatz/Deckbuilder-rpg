class_name CapitalGrand
extends RefCounted
## The Capital inner-city rebuild (Nov 1-2, docs/art/capital_rebuild_nov1.md): the grand pieces inside the great wall, built in code from the kit's
## textures and painted cards (CapitalKit's slots and cards; nothing new is imported). The target is PAINTOVER-CAP-INNER-CITY: a tyrant's dream
## of perfection - tall ornate townhouses in mirrored rows (cream plaster, pastel panels, gold trim, arched mirrored windows, balustraded balconies,
## flower boxes, pediments with the sun medallion, pastel slate roofs, pinnacles), slender towers with pointed pastel spires, gilded Primm statues
## on tall laurel plinths in pairs, the tiered fountain, formal planters, paving borders, balustrades. Every piece is one `KitMesh` (a handful of
## surfaces) finished by `CapitalLandmarks.finish` (no wind, triangle count in meta). Coordinates are local: the front of a piece is its +z face
## (the camera looks north, so a front facing south faces the player); `final` is the fallen state (dim gold, honest warm windows, crooked banners).

const K = preload("res://world/capital/capital_kit.gd")
const L = preload("res://world/capital/capital_landmarks.gd")

## One storey of a townhouse (the hero is 1.7 m: a storey is a hero and a half).
const STOREY: float = 2.6
## The painted gold Primm on his laurel plinth (CAPI-PROP-PRIMM-STATUE, the target's statue) and his toppled self.
const STATUE_ART: String = "CAPI-PROP-PRIMM-STATUE"
const FALLEN_ART: String = "CAPI-PROP-STATUE-FALLEN"
## The sun-face banners of the sheet used on the townhouses, the lamps and the towers (one id per use, so every set is identical).
const BANNER_HOUSE: String = "CAP-SHEET-BANNERS-02"
const BANNER_TOWER: String = "CAP-SHEET-BANNERS-01"
const BANNER_LAMP: String = "CAP-SHEET-BANNERS-05"
## The pastel accents (the target's pink, sage and lavender panels), as vertex tints on the flat surface so every house batches the same.
const ACCENTS: Dictionary = {"pink": Color("f3c4d2"), "sage": Color("c6dcc4"), "lavender": Color("d4c8ec"), "blue": Color("bcd4ee"), "cream": Color("f6ecd4")}
## The fallen state's gold (CapitalKit.materials' gold_mul everywhere in the Capital).
const FALLEN_GOLD: Color = Color(0.62, 0.57, 0.5)


## A fresh kit mesh with the Capital's slots and the rebuild's accent tints.
static func mesh_for(final_state: bool) -> KitMesh:
	var mesh: KitMesh = KitMesh.new()
	K.materials(mesh, FALLEN_GOLD if final_state else Color.WHITE)
	for accent: String in ACCENTS.keys():
		mesh.alias("accent_" + accent, "flat", (ACCENTS[accent] as Color).srgb_to_linear())
		mesh.set_material("plaster_" + accent, K.surface("CAP-WALL-PLASTER", K.PORCELAIN, ACCENTS[accent] as Color))
	mesh.alias("lamp_pink", "flat", Color("f0a8c0").srgb_to_linear())
	mesh.alias("water_deep", "flat", Color("6fb4e8").srgb_to_linear())
	mesh.alias("window_free", "flat", Color("ffd27a").srgb_to_linear())
	mesh.set_material("window_free_glow", EnvKit.glow(Color("ffd9a0"), 1.2))
	return mesh


## A painted card standing upright, rolled `roll_deg` about its facing axis (a banner hung a degree off; the fallen state's crooked ones): pivot at
## `pivot_pos`, `height` tall, facing `normal`.
static func card_rolled(mesh: KitMesh, id: String, pivot_pos: Vector3, height: float, normal: Vector3, roll_deg: float, mul: Color = Color.WHITE) -> void:
	if not EnvKit.has(id):
		return
	if absf(roll_deg) < 0.01:
		K.card(mesh, id, pivot_pos, height, normal, false, mul)
		return
	var slot: String = ("card_%s" % id) if mul == Color.WHITE else ("card_%s_%s" % [id, mul.to_html()])
	if mesh.material_of(slot) == null:
		mesh.set_material(slot, EnvKit.material(id, true, mul))
	var width: float = height * EnvKit.aspect(id)
	var pivot: Vector2 = EnvKit.pivot(id)
	var roll: Basis = Basis(normal.normalized(), deg_to_rad(roll_deg))
	var right: Vector3 = roll * (Vector3.UP.cross(normal).normalized() * -1.0)
	var up: Vector3 = roll * Vector3.UP
	var top_left: Vector3 = pivot_pos - right * (pivot.x * width) + up * (pivot.y * height)
	var bottom_left: Vector3 = top_left - up * height
	var uvs: Array[Vector2] = K.CARD_UVS.duplicate()
	mesh.quad(slot, [bottom_left, bottom_left + right * width, top_left + right * width, top_left], normal, [], uvs)


# ---- the grand townhouse -------------------------------------------------------------------------------------------------------------------


## A grand townhouse on a `w` x `d` footprint: `storeys` (3..5) of STOREY each, `bays` windows across the front, pastel `accent` panels between the
## upper windows, a `roof` ("hip" blue slate, "mansard" pink, "gable" blue with a pediment), a balustraded balcony across the first floor (`balcony`),
## a pediment with the sun medallion over the roofline (`pediment`), gold trim at every floor line and the corners, arched mirrored windows with
## flower boxes, the painted door (`door`, a doors-sheet id) in the middle of the ground floor, pinnacles at the parapet's corners, one sun banner
## hung from the first floor (`banner`, rolled `banner_roll` degrees: the one wrong detail). `final`: dim gold, warm honest windows, the banner
## crooked, colour in the windows. Front = +z.
static func townhouse(spec: Dictionary) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "Townhouse"
	var final_state: bool = bool(spec.get("final", false))
	var mesh: KitMesh = mesh_for(final_state)
	var w: float = float(spec.get("w", 4.0))
	var d: float = float(spec.get("d", 4.0))
	var storeys: int = clampi(int(spec.get("storeys", 3)), 2, 6)
	var bays: int = clampi(int(spec.get("bays", 3)), 1, 5)
	var accent: String = "accent_" + str(spec.get("accent", "pink"))
	var roof: String = str(spec.get("roof", "hip"))
	var balcony: bool = bool(spec.get("balcony", true))
	var pediment: bool = bool(spec.get("pediment", true))
	var door: String = str(spec.get("door", "CAP-SHEET-DOORS-01"))
	var banner: String = str(spec.get("banner", BANNER_HOUSE))
	var banner_roll: float = float(spec.get("banner_roll", 0.0)) + (7.0 if final_state else 0.0)
	var glass: String = "window_warm" if final_state else "mirror"
	var h: float = STOREY * float(storeys)
	var front: float = d * 0.5
	var hw: float = w * 0.5
	# the body: cream plaster, a rusticated ground storey a shade warmer, gold trim at every floor line, corner pilasters with gold caps
	var wall: String = "plaster_" + str(spec.get("accent", "pink")) if bool(spec.get("tinted", true)) else "plaster"
	mesh.box("plaster", Vector3(0, STOREY * 0.5, 0), Vector3(w, STOREY, d), Basis.IDENTITY, 0.03, 0.84)
	mesh.box(wall, Vector3(0, STOREY + (h - STOREY) * 0.5, 0), Vector3(w, h - STOREY, d), Basis.IDENTITY, 0.03, 0.9)
	mesh.box("accent_cream", Vector3(0, STOREY * 0.5 - 0.02, 0), Vector3(w + 0.05, STOREY - 0.3, d + 0.05), Basis.IDENTITY, 0.0, 0.9)
	for storey: int in range(storeys + 1):
		var y: float = STOREY * float(storey) - (0.08 if storey == 0 else 0.0)
		mesh.box("trim", Vector3(0, y + (0.18 if storey == 0 else 0.0), 0), Vector3(w + 0.14, 0.22, d + 0.14))
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			mesh.box("plaster", Vector3(sx * (hw - 0.22), h * 0.5, sz * (front - 0.22)), Vector3(0.5, h + 0.1, 0.5), Basis.IDENTITY, 0.03, 0.9)
			mesh.box("gold", Vector3(sx * (hw - 0.22), h + 0.08, sz * (front - 0.22)), Vector3(0.6, 0.14, 0.6))
	# the faces: windows in every bay on every storey (the front and the sides; the back one bay less), pastel panels between the upper windows
	var faces: Array = [[Vector3(0, 0, 1), w, front, bays], [Vector3(1, 0, 0), d, hw, maxi(1, bays - 1)], [Vector3(-1, 0, 0), d, hw, maxi(1, bays - 1)], [Vector3(0, 0, -1), w, front, maxi(1, bays - 1)]]
	for face: Array in faces:
		var normal: Vector3 = face[0] as Vector3
		var length: float = float(face[1])
		var out: float = float(face[2])
		var count: int = int(face[3])
		var right: Vector3 = Vector3.UP.cross(normal).normalized() * -1.0
		var inner: float = length - 1.0
		var win_w: float = minf(0.95, inner / float(count) * 0.55)
		for storey: int in range(storeys):
			var base_y: float = STOREY * float(storey)
			for bay: int in range(count):
				var t: float = (float(bay) + 0.5) / float(count) - 0.5
				var at: Vector3 = normal * out + right * t * inner
				var is_door: bool = storey == 0 and normal.z > 0.5 and bay == count / 2
				if is_door:
					continue
				if storey == 0:
					K.arched_window(mesh, at + Vector3(0, 0.55, 0), win_w, STOREY * 0.62, normal, glass)
				else:
					K.arched_window(mesh, at + Vector3(0, base_y + 0.5, 0), win_w, STOREY * 0.66, normal, glass)
					# the flower box on the sill: a white box with a gold lip and a rose card (brighter once Primm has fallen)
					mesh.box("plaster", at + Vector3(0, base_y + 0.38, 0) + normal * 0.16, Vector3(win_w + 0.3, 0.22, 0.3), Basis(Vector3.UP, atan2(normal.x, normal.z)))
					mesh.box("gold", at + Vector3(0, base_y + 0.5, 0) + normal * 0.16, Vector3(win_w + 0.34, 0.04, 0.34), Basis(Vector3.UP, atan2(normal.x, normal.z)))
					K.card(mesh, "CAP-PLANT-ROSE", at + Vector3(0, base_y + 0.44, 0) + normal * 0.2, 0.42, normal, false, Color(1.1, 1.0, 1.0) if final_state else Color.WHITE)
				# the pastel panel between this bay and the next (upper storeys), a gold frame line round it
				if storey > 0 and bay < count - 1:
					var panel: Vector3 = normal * (out + 0.015) + right * ((float(bay) + 1.0) / float(count) - 0.5) * inner + Vector3(0, base_y + STOREY * 0.52, 0)
					var pw: float = maxf(inner / float(count) - win_w - 0.3, 0.12)
					var ph: float = STOREY * 0.62
					mesh.quad("marble", [panel - right * pw * 0.5 - Vector3(0, ph * 0.5, 0), panel + right * pw * 0.5 - Vector3(0, ph * 0.5, 0), panel + right * pw * 0.5 + Vector3(0, ph * 0.5, 0), panel - right * pw * 0.5 + Vector3(0, ph * 0.5, 0)], normal)
					mesh.box("gold", panel + normal * 0.01 + Vector3(0, ph * 0.5, 0), Vector3(pw + 0.06, 0.05, 0.03) if absf(normal.z) > 0.5 else Vector3(0.03, 0.05, pw + 0.06))
					mesh.box("gold", panel + normal * 0.01 - Vector3(0, ph * 0.5, 0), Vector3(pw + 0.06, 0.05, 0.03) if absf(normal.z) > 0.5 else Vector3(0.03, 0.05, pw + 0.06))
	# the door in the middle of the front, under a small gold-edged pediment with the emblem, two lanterns beside it
	var door_at: Vector3 = Vector3(0, 0.02, front + 0.03)
	K.card(mesh, door, door_at, 2.4, Vector3(0, 0, 1))
	mesh.box("gold", Vector3(0, 2.52, front + 0.06), Vector3(1.9, 0.1, 0.12))
	mesh.tri("plaster", [Vector3(-1.0, 2.6, front + 0.04), Vector3(1.0, 2.6, front + 0.04), Vector3(0, 3.35, front + 0.04)], Vector3(0, 0, 1))
	L.band(mesh, "gold", Vector3(-1.0, 2.62, front + 0.07), Vector3(0, 3.37, front + 0.07), 0.08, Vector3(0, 0, 1))
	L.band(mesh, "gold", Vector3(0, 3.37, front + 0.07), Vector3(1.0, 2.62, front + 0.07), 0.08, Vector3(0, 0, 1))
	K.emblem(mesh, Vector3(0, 2.92, front + 0.06), 0.2, Vector3(0, 0, 1), final_state, false)
	for side: float in [-1.0, 1.0]:
		mesh.blob("lamp", Vector3(side * 0.95, 2.1, front + 0.2), Vector3(0.1, 0.13, 0.1), 3, 8)
		mesh.box("gold", Vector3(side * 0.95, 1.95, front + 0.1), Vector3(0.06, 0.2, 0.2))
	# the balcony across the first floor's front: a slab on gold brackets, a small balustrade, pots at its ends
	if balcony and storeys >= 2:
		var y: float = STOREY
		var depth: float = 0.75
		mesh.box("plaster", Vector3(0, y + 0.08, front + depth * 0.5), Vector3(w - 0.7, 0.16, depth), Basis.IDENTITY, 0.02)
		mesh.box("gold", Vector3(0, y - 0.02, front + depth * 0.5), Vector3(w - 0.64, 0.05, depth + 0.04))
		for bx: float in [-(hw - 0.75), 0.0, hw - 0.75]:
			mesh.tri("gold", [Vector3(bx, y - 0.02, front + 0.02), Vector3(bx, y - 0.02, front + depth - 0.05), Vector3(bx, y - 0.55, front + 0.02)], Vector3(1, 0, 0))
			mesh.tri("gold", [Vector3(bx, y - 0.02, front + 0.02), Vector3(bx, y - 0.55, front + 0.02), Vector3(bx, y - 0.02, front + depth - 0.05)], Vector3(-1, 0, 0))
		balustrade(mesh, Vector3(-(hw - 0.4), y + 0.16, front + depth - 0.1), Vector3(hw - 0.4, y + 0.16, front + depth - 0.1), 0.62)
		for side: float in [-1.0, 1.0]:
			balustrade(mesh, Vector3(side * (hw - 0.4), y + 0.16, front + 0.1), Vector3(side * (hw - 0.4), y + 0.16, front + depth - 0.1), 0.62)
	# the parapet: a balustrade along the front and the sides over the top trim, pinnacles at the corners, then the roof
	var parapet_y: float = h + 0.15
	balustrade(mesh, Vector3(-(hw - 0.55), parapet_y, front - 0.25), Vector3(hw - 0.55, parapet_y, front - 0.25), 0.8)
	for side: float in [-1.0, 1.0]:
		balustrade(mesh, Vector3(side * (hw - 0.25), parapet_y, front - 0.55), Vector3(side * (hw - 0.25), parapet_y, -(front - 0.55)), 0.8)
		for sz: float in [-1.0, 1.0]:
			L.pinnacle(mesh, Vector3(side * (hw - 0.22), parapet_y, sz * (front - 0.22)), 0.42, 1.9)
	match roof:
		"mansard":
			# a steep pink slate mansard with a flat gold-edged top and a row of dormer finials
			var rise: float = 1.9
			var inset: float = 0.9
			var c: Vector3 = Vector3(0, parapet_y, 0)
			var lo: Array[Vector3] = [c + Vector3(-hw + 0.3, 0, -front + 0.3), c + Vector3(hw - 0.3, 0, -front + 0.3), c + Vector3(hw - 0.3, 0, front - 0.3), c + Vector3(-hw + 0.3, 0, front - 0.3)]
			var hi: Array[Vector3] = [c + Vector3(-hw + inset, rise, -front + inset), c + Vector3(hw - inset, rise, -front + inset), c + Vector3(hw - inset, rise, front - inset), c + Vector3(-hw + inset, rise, front - inset)]
			var normals: Array[Vector3] = [Vector3(0, 0.4, -1), Vector3(1, 0.4, 0), Vector3(0, 0.4, 1), Vector3(-1, 0.4, 0)]
			for index: int in range(4):
				var j: int = (index + 1) % 4
				mesh.quad("roof_pink", [lo[index], lo[j], hi[j], hi[index]], normals[index])
			mesh.quad("roof_pink", [hi[0], hi[1], hi[2], hi[3]], Vector3.UP)
			mesh.box("gold", c + Vector3(0, rise + 0.04, 0), Vector3(w - inset * 2.0 + 0.2, 0.1, d - inset * 2.0 + 0.2))
			K.finial(mesh, c + Vector3(0, rise + 0.08, 0), 1.0)
		"gable":
			# a blue gable across the front with a pediment and the sun medallion in it
			var rise: float = 2.2
			var ridge_a: Vector3 = Vector3(-hw - 0.2, parapet_y + rise, 0)
			var ridge_b: Vector3 = Vector3(hw + 0.2, parapet_y + rise, 0)
			for sz: float in [-1.0, 1.0]:
				var eave: float = sz * (front + 0.3)
				mesh.quad("roof_blue", [Vector3(-hw - 0.2, parapet_y, eave), Vector3(hw + 0.2, parapet_y, eave), ridge_b, ridge_a], Vector3(0, 0.8, sz))
			for sx: float in [-1.0, 1.0]:
				mesh.tri("plaster", [Vector3(sx * hw, parapet_y, -front), Vector3(sx * hw, parapet_y, front), Vector3(sx * hw, parapet_y + rise - 0.05, 0)], Vector3(sx, 0, 0))
			mesh.box("gold", Vector3(0, parapet_y + rise + 0.1, 0), Vector3(w + 0.6, 0.2, 0.3))
			K.finial(mesh, Vector3(0, parapet_y + rise + 0.15, 0), 1.1)
		_:
			CapitalCastle._hip_roof(mesh, Vector3(0, parapet_y, 0), Vector2(w - 0.4, d - 0.4), 2.1, "roof_blue")
			K.finial(mesh, Vector3(0, parapet_y + 2.25, 0), 1.0)
	# the pediment over the front's middle at the roofline: a white triangle with gold edges and the sun medallion
	if pediment:
		var pw: float = minf(w * 0.6, 3.2)
		var py: float = parapet_y - 0.05
		var apex: Vector3 = Vector3(0, py + pw * 0.42, front + 0.02)
		mesh.tri("plaster", [Vector3(-pw * 0.5, py, front + 0.02), Vector3(pw * 0.5, py, front + 0.02), apex], Vector3(0, 0, 1))
		mesh.tri("plaster", [Vector3(pw * 0.5, py, front - 0.3), Vector3(-pw * 0.5, py, front - 0.3), apex - Vector3(0, 0, 0.32)], Vector3(0, 0, -1))
		mesh.box("plaster", Vector3(0, py + pw * 0.21, front - 0.14), Vector3(pw, pw * 0.42, 0.28), Basis.IDENTITY, 0.0, 1.0)
		L.band(mesh, "gold", Vector3(-pw * 0.5, py + 0.02, front + 0.05), apex + Vector3(0, 0.02, 0.03), 0.1, Vector3(0, 0, 1))
		L.band(mesh, "gold", apex + Vector3(0, 0.02, 0.03), Vector3(pw * 0.5, py + 0.02, front + 0.05), 0.1, Vector3(0, 0, 1))
		mesh.box("gold", Vector3(0, py, front + 0.04), Vector3(pw + 0.2, 0.1, 0.1))
		K.sun_emblem(mesh, Vector3(0, py + pw * 0.15, front + 0.05), pw * 0.09, Vector3(0, 0, 1))
	# the sun banner hung from the first floor's trim, centred over the door
	if banner != "":
		card_rolled(mesh, banner, Vector3(0, STOREY * 2.0 - 0.1, front + 0.22), 1.9, Vector3(0, 0, 1), banner_roll)
	L.finish(root, mesh, [], h + 3.0)
	root.set_meta("storeys", storeys)
	if final_state:
		# colour in the windows: a warm light behind each
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = Color("ffc890")
		light.light_energy = 0.5
		light.omni_range = 5.0
		light.position = Vector3(0, 2.2, front + 1.0)
		root.add_child(light)
		root.set_meta("lights", [light])
	return root


## A small white balustrade from `a` to `b` (same y): a rail on turned posts, every fourth capped gold; `height` metres.
static func balustrade(mesh: KitMesh, a: Vector3, b: Vector3, height: float = 0.8) -> void:
	var length: float = a.distance_to(b)
	if length < 0.2:
		return
	var along_x: bool = absf(b.x - a.x) >= absf(b.z - a.z)
	var post: float = height * 0.28
	mesh.box("plaster", (a + b) * 0.5 + Vector3(0, height, 0), Vector3(length + post, post * 0.7, post * 1.4) if along_x else Vector3(post * 1.4, post * 0.7, length + post))
	mesh.box("plaster", (a + b) * 0.5 + Vector3(0, post * 0.25, 0), Vector3(length + post, post * 0.5, post * 1.2) if along_x else Vector3(post * 1.2, post * 0.5, length + post))
	var count: int = maxi(2, int(length / (height * 0.5)))
	for index: int in range(count + 1):
		var p: Vector3 = a.lerp(b, float(index) / float(count))
		if index % 4 == 0:
			mesh.box("plaster", p + Vector3(0, height * 0.5, 0), Vector3(post * 1.1, height, post * 1.1))
			mesh.box("gold", p + Vector3(0, height + post * 0.4, 0), Vector3(post * 1.3, post * 0.3, post * 1.3))
		else:
			mesh.lathe("plaster", p + Vector3(0, post * 0.5, 0), [Vector2(post * 0.42, 0.0), Vector2(post * 0.28, height * 0.25), Vector2(post * 0.45, height * 0.5), Vector2(post * 0.3, height * 0.75), Vector2(post * 0.42, height - post * 0.6)], 6, 1.0, false, false)


# ---- the tower -----------------------------------------------------------------------------------------------------------------------------


## A slender white tower, `height` metres to the eaves, `radius` at the shaft: a square gold-capped plinth, a banded round shaft, a gold balcony
## ring with its balustrade and corner pinnacles under the lantern, a lantern of mirrored lancet windows, a pointed `roof` cone ("roof_blue",
## "roof_pink" or "gold") taller than the lantern, a finial, and a sun banner hung from the balcony facing the street (+z).
static func tower(height: float, radius: float, roof: String, final_state: bool, banner: bool = true) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "Tower"
	var mesh: KitMesh = mesh_for(final_state)
	var plinth: float = radius * 2.0 + 0.9
	mesh.box("plaster", Vector3(0, 0.7, 0), Vector3(plinth, 1.4, plinth), Basis.IDENTITY, 0.04, 0.85)
	mesh.box("trim", Vector3(0, 1.45, 0), Vector3(plinth + 0.16, 0.24, plinth + 0.16))
	mesh.box("plaster", Vector3(0, 2.0, 0), Vector3(plinth - 0.5, 0.9, plinth - 0.5), Basis.IDENTITY, 0.03, 0.9)
	var shaft_top: float = height * 0.72
	mesh.lathe("plaster", Vector3(0, 2.4, 0), [Vector2(radius * 1.12, 0.0), Vector2(radius, 1.2), Vector2(radius, shaft_top - 2.4)], 14, 0.85, false, false)
	var band: float = 4.4
	while band < shaft_top - 2.0:
		mesh.lathe("gold", Vector3(0, band, 0), [Vector2(radius * 1.05, 0.0), Vector2(radius * 1.05, 0.28)], 14, 1.0, false, false)
		# a slot window above every band on the street side and the back
		for side: Vector3 in [Vector3(0, 0, 1), Vector3(0, 0, -1)]:
			K.arched_window(mesh, side * (radius + 0.01) + Vector3(0, band + 0.8, 0), radius * 0.36, radius * 1.1, side, "window_warm" if final_state else "mirror")
		band += 4.4
	# the balcony ring: a gold-rimmed white disc, a ring of balustrade posts, pinnacles at four points
	var ring_r: float = radius * 1.75
	mesh.lathe("plaster", Vector3(0, shaft_top - 0.5, 0), [Vector2(radius * 0.9, 0.0), Vector2(ring_r, 0.4), Vector2(ring_r, 0.62)], 14, 0.9, false, true)
	mesh.lathe("gold", Vector3(0, shaft_top + 0.1, 0), [Vector2(ring_r + 0.05, 0.0), Vector2(ring_r + 0.05, 0.1)], 14, 1.0, false, false)
	var posts: int = 14
	for index: int in range(posts):
		var angle: float = TAU * float(index) / float(posts)
		var p: Vector3 = Vector3(cos(angle), 0, sin(angle)) * (ring_r - 0.18)
		mesh.box("plaster", p + Vector3(0, shaft_top + 0.5, 0), Vector3(0.14, 0.7, 0.14))
	mesh.lathe("plaster", Vector3(0, shaft_top + 0.85, 0), [Vector2(ring_r - 0.05, 0.0), Vector2(ring_r - 0.05, 0.12)], 14, 1.0, false, true)
	for index: int in range(4):
		var angle: float = PI * 0.25 + PI * 0.5 * float(index)
		L.pinnacle(mesh, Vector3(cos(angle), 0, sin(angle)) * (ring_r - 0.3) + Vector3(0, shaft_top + 0.2, 0), 0.34, 1.6)
	# the lantern: a narrower drum with four tall mirrored lancets, a gold cornice
	var lantern_r: float = radius * 0.92
	var lantern_h: float = height - shaft_top - 0.2
	mesh.lathe("plaster", Vector3(0, shaft_top + 0.2, 0), [Vector2(lantern_r, 0.0), Vector2(lantern_r, lantern_h)], 14, 0.9, false, false)
	for side: Vector3 in [Vector3(0, 0, 1), Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 0, -1)]:
		K.lancet_window(mesh, side * (lantern_r + 0.01) + Vector3(0, shaft_top + 1.0, 0), lantern_r * 0.75, lantern_h * 0.7, side, "window_warm" if final_state else "mirror")
	mesh.lathe("gold", Vector3(0, height - 0.3, 0), [Vector2(lantern_r * 1.16, 0.0), Vector2(lantern_r * 1.16, 0.34)], 14, 1.0, false, true)
	# the spire: a tall pointed cone, a gold collar, a finial
	var cone: float = maxf(height * 0.38, 4.0)
	mesh.lathe(roof, Vector3(0, height, 0), [Vector2(lantern_r * 1.3, 0.0), Vector2(lantern_r * 1.0, cone * 0.22), Vector2(lantern_r * 0.5, cone * 0.6), Vector2(0.0, cone)], 14, 1.0, true, false)
	mesh.lathe("gold", Vector3(0, height + cone * 0.22, 0), [Vector2(lantern_r * 1.05, 0.0), Vector2(lantern_r * 0.98, 0.2)], 14, 1.0, false, false)
	K.finial(mesh, Vector3(0, height + cone - 0.1, 0), maxf(radius * 0.8, 0.8))
	if banner:
		card_rolled(mesh, BANNER_TOWER, Vector3(0, shaft_top - 0.7, radius + 0.08), 3.2, Vector3(0, 0, 1), 6.0 if final_state else 0.0)
	L.finish(root, mesh, [Vector3(0, 0, plinth * 0.5 + 0.2)], height + cone)
	return root


# ---- the gilded statue on its plinth -----------------------------------------------------------------------------------------------------


## A gilded Primm (the painted statue card, gold on his own laurel plinth) raised on a tall white plinth: a stepped base, a chamfered shaft with
## gold bands top and bottom, a gold laurel wreath relief with the sun medallion on the front, rosettes at the corners. `height` is the plinth's;
## the statue stands `statue_height` tall on it, facing +z. `toppled` (Primm has fallen): the fallen card lies at the plinth's foot and the top is
## empty but for a broken stump. The statue never fades (the brief): the card is in the plinth's own mesh.
static func statue_plinth(height: float, statue_height: float, final_state: bool, toppled: bool = false) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "GildedStatue"
	var mesh: KitMesh = mesh_for(final_state)
	var base: float = 2.8
	mesh.box("marble_shade", Vector3(0, 0.15, 0), Vector3(base, 0.3, base), Basis.IDENTITY, 0.03, 0.85)
	mesh.box("plaster", Vector3(0, 0.45, 0), Vector3(base - 0.5, 0.3, base - 0.5), Basis.IDENTITY, 0.03, 0.9)
	var shaft: float = base - 1.0
	mesh.box("plaster", Vector3(0, 0.6 + (height - 0.6) * 0.5, 0), Vector3(shaft, height - 0.6, shaft), Basis.IDENTITY, 0.12, 0.86)
	mesh.box("trim", Vector3(0, 0.72, 0), Vector3(shaft + 0.16, 0.24, shaft + 0.16))
	mesh.box("trim", Vector3(0, height - 0.12, 0), Vector3(shaft + 0.24, 0.24, shaft + 0.24))
	mesh.box("plaster", Vector3(0, height + 0.08, 0), Vector3(shaft + 0.4, 0.16, shaft + 0.4), Basis.IDENTITY, 0.02)
	# the laurel: two arcs of gold leaves meeting under the medallion, on the front and the back
	for normal: Vector3 in [Vector3(0, 0, 1), Vector3(0, 0, -1)]:
		var centre: Vector3 = normal * (shaft * 0.5 + 0.02) + Vector3(0, height * 0.55, 0)
		var right: Vector3 = Vector3.UP.cross(normal).normalized() * -1.0
		var r: float = shaft * 0.3
		for side: float in [-1.0, 1.0]:
			for index: int in range(7):
				var angle: float = lerpf(PI * 1.35, PI * 2.35, float(index) / 6.0) if side < 0.0 else lerpf(PI * 0.65, PI * -0.35, float(index) / 6.0)
				var p: Vector3 = centre + (right * cos(angle) * side + Vector3.UP * sin(angle)) * r
				var leaf: Vector3 = Vector3(0.1, 0.05, 0.03) if absf(normal.z) > 0.5 else Vector3(0.03, 0.05, 0.1)
				mesh.blob("gold", p + normal * 0.03, leaf * (1.0 + 0.3 * sin(float(index))), 3, 6)
		K.sun_emblem(mesh, centre, r * 0.42, normal)
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			mesh.blob("gold", Vector3(sx * shaft * 0.5, height - 0.12, sz * shaft * 0.5), Vector3(0.14, 0.14, 0.14), 3, 6)
	if toppled:
		mesh.box("marble_shade", Vector3(0.3, height + 0.35, 0.2), Vector3(0.6, 0.5, 0.5), Basis(Vector3.UP, 0.4), 0.05)
		K.card(mesh, FALLEN_ART, Vector3(0.2, 0.02, base * 0.5 + 1.4), statue_height * 0.6, Vector3(0, 0, 1), false, FALLEN_GOLD)
	else:
		K.card(mesh, STATUE_ART, Vector3(0, height + 0.16, 0), statue_height, Vector3(0, 0, 1))
	L.finish(root, mesh, [Vector3(0, 0, base * 0.5)], height + statue_height)
	root.set_meta("statue", true)
	L.mark_view(root)
	return root


# ---- the tiered fountain -------------------------------------------------------------------------------------------------------------------


## The Primm fountain as the plaza's centrepiece: three tiers of white marble with gold rims (`outer` across the lowest basin), eight rose planters
## round the lowest rim, water in every tier, eight spouts from the middle tier and four from the upper, Primm's emblems on the middle drum, and the
## painted gold Primm on the top. Dry and toppled once he has fallen (the fallen card lies in the basin). The hazard circle is `outer`.
static func fountain(outer: float, final_state: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "PrimmFountain"
	var mesh: KitMesh = mesh_for(final_state)
	var water: String = "water" if not final_state else "dust"
	# a gold-bordered step round the whole fountain
	mesh.lathe("marble_shade", Vector3(0, 0.0, 0), [Vector2(outer + 0.7, 0.0), Vector2(outer + 0.7, 0.16), Vector2(outer + 0.1, 0.16)], 36, 1.0, false, false)
	mesh.lathe("gold", Vector3(0, 0.16, 0), [Vector2(outer + 0.72, 0.0), Vector2(outer + 0.72, 0.05), Vector2(outer + 0.45, 0.05)], 36, 1.0, false, false)
	# tier 1
	mesh.lathe("marble", Vector3(0, 0.16, 0), [Vector2(outer, 0.0), Vector2(outer, 0.7), Vector2(outer - 0.4, 0.7), Vector2(outer - 0.4, 0.3)], 36, 0.85, false, false)
	mesh.lathe("gold", Vector3(0, 0.84, 0), [Vector2(outer + 0.04, 0.0), Vector2(outer + 0.04, 0.1), Vector2(outer - 0.44, 0.1)], 36, 1.0, false, false)
	mesh.lathe(water, Vector3(0, 0.62 if not final_state else 0.4, 0), [Vector2(outer - 0.4, 0.0), Vector2(0.0, 0.0)], 36, 1.0, false, false)
	for index: int in range(8):
		var angle: float = TAU * float(index) / 8.0 + PI / 8.0
		var p: Vector3 = Vector3(cos(angle), 0, sin(angle)) * (outer - 0.05)
		K.post(mesh, p + Vector3(0, 0.16, 0), Vector3(0.8, 0.95, 0.8), false)
		K.card(mesh, "CAP-PLANT-ROSE", p + Vector3(0, 1.2, 0), 0.8, Vector3(0, 0, 1))
	# tier 2: a drum with four emblems, a wide gold-rimmed bowl, eight spouts pouring into tier 1
	var r2: float = outer * 0.55
	mesh.lathe("marble", Vector3(0, 0.3, 0), [Vector2(r2 * 0.75, 0.0), Vector2(r2 * 0.75, 1.5), Vector2(r2, 1.6), Vector2(r2 + 0.1, 1.95), Vector2(r2 - 0.35, 1.95), Vector2(r2 - 0.35, 1.7)], 28, 0.85, false, false)
	mesh.lathe("gold", Vector3(0, 2.2, 0), [Vector2(r2 + 0.14, 0.0), Vector2(r2 + 0.14, 0.1), Vector2(r2 - 0.38, 0.1)], 28, 1.0, false, false)
	if not final_state:
		mesh.lathe("water", Vector3(0, 2.12, 0), [Vector2(r2 - 0.35, 0.0), Vector2(0.0, 0.0)], 28, 1.0, false, false)
	for index: int in range(4):
		var angle: float = TAU * float(index) / 4.0 + PI * 0.25
		var dir: Vector3 = Vector3(cos(angle), 0, sin(angle))
		K.emblem(mesh, dir * (r2 * 0.75 + 0.02) + Vector3(0, 1.1, 0), r2 * 0.22, dir, final_state, false)
	for index: int in range(8):
		var angle: float = TAU * float(index) / 8.0
		var spout: Vector3 = Vector3(cos(angle), 0, sin(angle))
		mesh.blob("gold", spout * (r2 + 0.12) + Vector3(0, 1.85, 0), Vector3(0.18, 0.16, 0.18), 4, 8)
		if not final_state:
			_jet(mesh, spout * (r2 + 0.25), 1.85, outer - 0.9, 0.62, 0.14)
	# tier 3: a slender stem, a small bowl, four spouts into tier 2, the statue's gold-banded pedestal
	var r3: float = outer * 0.27
	mesh.lathe("marble", Vector3(0, 2.1, 0), [Vector2(r3 * 0.55, 0.0), Vector2(r3 * 0.45, 0.8), Vector2(r3 * 0.9, 1.1), Vector2(r3 + 0.05, 1.4), Vector2(r3 - 0.25, 1.4), Vector2(r3 - 0.25, 1.25)], 20, 0.9, false, false)
	mesh.lathe("gold", Vector3(0, 3.45, 0), [Vector2(r3 + 0.08, 0.0), Vector2(r3 + 0.08, 0.08), Vector2(r3 - 0.28, 0.08)], 20, 1.0, false, false)
	if not final_state:
		mesh.lathe("water", Vector3(0, 3.4, 0), [Vector2(r3 - 0.25, 0.0), Vector2(0.0, 0.0)], 20, 1.0, false, false)
	for index: int in range(4):
		var angle: float = TAU * float(index) / 4.0 + PI * 0.25
		var spout: Vector3 = Vector3(cos(angle), 0, sin(angle))
		mesh.blob("gold", spout * (r3 + 0.05) + Vector3(0, 3.3, 0), Vector3(0.12, 0.1, 0.12), 4, 8)
		if not final_state:
			_jet(mesh, spout * (r3 + 0.15), 3.3, r2 - 0.6, 2.12, 0.1)
	mesh.lathe("marble", Vector3(0, 3.4, 0), [Vector2(r3 * 0.6, 0.0), Vector2(r3 * 0.5, 0.5), Vector2(r3 * 0.7, 0.75)], 16, 0.9, false, true)
	mesh.lathe("gold", Vector3(0, 4.1, 0), [Vector2(r3 * 0.72, 0.0), Vector2(r3 * 0.72, 0.1)], 16, 1.0, false, true)
	var statue_h: float = outer * 0.95
	if final_state:
		K.card(mesh, FALLEN_ART, Vector3(0.0, 0.42, r2 + 1.0), 2.4, Vector3(0, 0, 1), false, FALLEN_GOLD)
	else:
		K.card(mesh, STATUE_ART, Vector3(0, 4.2, 0), statue_h, Vector3(0, 0, 1))
	L.finish(root, mesh, [Vector3(0, 0, outer + 0.7)], 4.2 + statue_h)
	root.set_meta("statue", true)
	L.mark_view(root)
	if not final_state:
		var mist: CPUParticles3D = CPUParticles3D.new()
		mist.name = "Mist"
		mist.amount = 32
		mist.lifetime = 1.5
		mist.preprocess = 1.5
		mist.emission_shape = CPUParticles3D.EMISSION_SHAPE_RING
		mist.emission_ring_axis = Vector3.UP
		mist.emission_ring_radius = r2 + 0.3
		mist.emission_ring_inner_radius = r2 - 0.2
		mist.emission_ring_height = 0.1
		mist.direction = Vector3.UP
		mist.spread = 25.0
		mist.initial_velocity_min = 0.3
		mist.initial_velocity_max = 0.8
		mist.gravity = Vector3(0, -0.7, 0)
		var drop: SphereMesh = SphereMesh.new()
		drop.radius = 0.04
		drop.height = 0.08
		drop.radial_segments = 4
		drop.rings = 2
		mist.mesh = drop
		mist.material_override = K.water(0.55)
		mist.position = Vector3(0, 2.0, 0)
		root.add_child(mist)
	return root


## A water jet: an arc from `from` (at `y0`) out to radius `to_r` falling to `y1`, as a strip of `width`.
static func _jet(mesh: KitMesh, from: Vector3, y0: float, to_r: float, y1: float, width: float) -> void:
	var dir: Vector3 = Vector3(from.x, 0, from.z).normalized()
	var r0: float = Vector3(from.x, 0, from.z).length()
	var points: Array[Vector3] = []
	for step: int in range(7):
		var t: float = float(step) / 6.0
		points.append(dir * lerpf(r0, to_r, t) + Vector3(0, lerpf(y0, y0 + 0.25, minf(t * 3.0, 1.0)) - (y0 + 0.25 - y1) * t * t, 0))
	var across: Vector3 = Vector3(-dir.z, 0, dir.x) * width
	for step: int in range(6):
		mesh.quad("water", [points[step] - across, points[step + 1] - across, points[step + 1] + across, points[step] + across], dir + Vector3.UP)


# ---- planters, borders, lamps -----------------------------------------------------------------------------------------------------------------


## A straight white planter from `a` to `b` (ground level, same y), `width` across, a gold lip: the rose cards stand in it (returned as row
## positions, `step` apart, for the dressing's rose field). Low enough to walk past; never a blocker.
static func planter_run(mesh: KitMesh, a: Vector3, b: Vector3, width: float, step: float = 0.9, height: float = 0.42) -> Array[Vector3]:
	var length: float = a.distance_to(b)
	var mid: Vector3 = (a + b) * 0.5
	var along_x: bool = absf(b.x - a.x) >= absf(b.z - a.z)
	var size: Vector3 = Vector3(length, height, width) if along_x else Vector3(width, height, length)
	mesh.box("plaster", mid + Vector3(0, height * 0.5, 0), size, Basis.IDENTITY, 0.02, 0.88)
	mesh.box("gold", mid + Vector3(0, height + 0.02, 0), Vector3(size.x + 0.08, 0.06, size.z + 0.08))
	mesh.box("soil", mid + Vector3(0, height - 0.02, 0), Vector3(size.x - 0.2, 0.08, size.z - 0.2))
	var positions: Array[Vector3] = []
	var count: int = maxi(1, int(length / step))
	for index: int in range(count):
		var t: float = (float(index) + 0.5) / float(count)
		positions.append(a.lerp(b, t) + Vector3(0, height - 0.04, 0))
	return positions


## A square white planter box with a gold lip at `center` (for a topiary urn to stand in, or a rose bed), `size` across.
static func planter_box(mesh: KitMesh, center: Vector3, size: float, height: float = 0.5) -> void:
	mesh.box("plaster", center + Vector3(0, height * 0.5, 0), Vector3(size, height, size), Basis.IDENTITY, 0.02, 0.88)
	mesh.box("gold", center + Vector3(0, height + 0.02, 0), Vector3(size + 0.08, 0.06, size + 0.08))
	mesh.box("hedge", center + Vector3(0, height - 0.02, 0), Vector3(size - 0.2, 0.06, size - 0.2))


## A paving border on the ground from `a` to `b`: a white strip `width` wide with a gold line down its middle, a hair above the paving.
static func border(mesh: KitMesh, a: Vector3, b: Vector3, width: float, lift: float = 0.03) -> void:
	var along: Vector3 = (b - a).normalized()
	var across: Vector3 = Vector3(-along.z, 0, along.x) * width * 0.5
	var a2: Vector3 = Vector3(a.x, lift, a.z)
	var b2: Vector3 = Vector3(b.x, lift, b.z)
	mesh.quad("road_white", [a2 - across, b2 - across, b2 + across, a2 + across], Vector3.UP)
	var gold: Vector3 = across * 0.16
	mesh.quad("gold", [a2 - gold + Vector3(0, 0.004, 0), b2 - gold + Vector3(0, 0.004, 0), b2 + gold + Vector3(0, 0.004, 0), a2 + gold + Vector3(0, 0.004, 0)], Vector3.UP)


## A ring border round `center` between radii `r0` and `r1` (the walk round the fountain): white with a gold line on each edge.
static func ring_border(mesh: KitMesh, center: Vector3, r0: float, r1: float, lift: float = 0.03) -> void:
	var steps: int = 40
	for index: int in range(steps):
		var a0: float = TAU * float(index) / float(steps)
		var a1: float = TAU * float(index + 1) / float(steps)
		var d0: Vector3 = Vector3(cos(a0), 0, sin(a0))
		var d1: Vector3 = Vector3(cos(a1), 0, sin(a1))
		var c: Vector3 = Vector3(center.x, lift, center.z)
		mesh.quad("road_white", [c + d0 * r0, c + d1 * r0, c + d1 * r1, c + d0 * r1], Vector3.UP)
		for edge: Vector2 in [Vector2(r0, r0 + 0.14), Vector2(r1 - 0.14, r1)]:
			mesh.quad("gold", [c + d0 * edge.x + Vector3(0, 0.004, 0), c + d1 * edge.x + Vector3(0, 0.004, 0), c + d1 * edge.y + Vector3(0, 0.004, 0), c + d0 * edge.y + Vector3(0, 0.004, 0)], Vector3.UP)


## A 3D pink lamp post (the kit lamp's shape: a white-and-gold base, a fluted pink post with gold collars, a glowing globe in a gold cup), as a
## mesh the lamp field instances (`CapitalBuilder` makes one MultiMesh of it). `height` to the globe's centre.
static func lamp_mesh(height: float, lit: bool) -> ArrayMesh:
	var mesh: KitMesh = mesh_for(false)
	mesh.lathe("plaster", Vector3.ZERO, [Vector2(0.42, 0.0), Vector2(0.42, 0.1), Vector2(0.34, 0.18)], 10, 1.0, false, false)
	mesh.lathe("gold", Vector3(0, 0.18, 0), [Vector2(0.34, 0.0), Vector2(0.3, 0.08)], 10, 1.0, false, false)
	mesh.lathe("lamp_pink", Vector3(0, 0.26, 0), [Vector2(0.28, 0.0), Vector2(0.2, 0.7), Vector2(0.14, 0.9)], 10, 0.9, false, false)
	mesh.lathe("gold", Vector3(0, 1.16, 0), [Vector2(0.17, 0.0), Vector2(0.17, 0.12)], 10, 1.0, false, false)
	mesh.lathe("lamp_pink", Vector3(0, 1.28, 0), [Vector2(0.11, 0.0), Vector2(0.09, height - 1.6), Vector2(0.09, height - 1.5)], 10, 1.0, false, false)
	mesh.lathe("gold", Vector3(0, (height - 1.5) * 0.55 + 1.0, 0), [Vector2(0.13, 0.0), Vector2(0.13, 0.1)], 10, 1.0, false, false)
	mesh.lathe("gold", Vector3(0, height - 0.6, 0), [Vector2(0.1, 0.0), Vector2(0.16, 0.12), Vector2(0.1, 0.2), Vector2(0.22, 0.3), Vector2(0.24, 0.34)], 10, 1.0, false, true)
	mesh.blob("lamp" if lit else "paper", Vector3(0, height, 0), Vector3(0.36, 0.36, 0.36), 6, 12)
	return mesh.build()


## A hanging sun banner for the lamps: two banners back to back on a short gold arm under the globe, as a mesh for a MultiMesh.
static func lamp_banner_mesh(height: float, roll_deg: float = 0.0) -> ArrayMesh:
	var mesh: KitMesh = mesh_for(false)
	mesh.tube("gold", Vector3(0, height - 0.9, -0.55), Vector3(0, height - 0.9, 0.55), 0.03, 6)
	card_rolled(mesh, BANNER_LAMP, Vector3(0, height - 0.95, 0.03), 1.15, Vector3(0, 0, 1), roll_deg)
	card_rolled(mesh, BANNER_LAMP, Vector3(0, height - 0.95, -0.03), 1.15, Vector3(0, 0, -1), -roll_deg)
	return mesh.build()
