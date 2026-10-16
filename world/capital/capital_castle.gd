class_name CapitalCastle
extends RefCounted
## Primm's Castle (CAP-HERO-PRIMMS-CASTLE, docs/art/zone_kits/final/concepts/CAP-HERO-PRIMMS-CASTLE.jpg, PAINTOVER-CAP-PALACE-APPROACH): the face of
## the finale, an immense, gleaming white-and-gold palace on its hill at the city's heart, perfectly symmetrical about the grand avenue (x 60). Built
## in world coordinates (the hill's front tongue fills `CapitalLayout.HILL`, the grand stair climbs it from the castle door at its foot, the palace
## stands on the hill top). Everything the camera must read is placed in the band it sees (docs/art/zone_rollout_playbook.md section 10): the
## doors, the colossal smiling emblem and the cracks between 7 and 21 m, so they frame the avenue and the plaza; the cone roofs of the towers between
## 20 and 40 m, so the castle shows over the great wall from every outside region; the central spire above them for the far views. Hairline cracks
## leak a slowly pulsing rift light (the "cracks" material in meta, pulsed by `CapitalBuilder.animate`). When Primm has fallen (`final`) the cracks
## go dark, the gold dims, the emblem is broken and covered, and the mirrored windows become honest warm light.

const K = preload("res://world/capital/capital_kit.gd")

## The palace's axis and the hill top (the stand-in's numbers: `CapitalLayout.CASTLE`, `HILL_HEIGHT`).
const AXIS: float = 60.0
const TOP: float = 7.0
## The keep's front face (world z): the doors and the emblem; the terrace between it and the stair holds the Primm statue.
const KEEP_FRONT: float = -2.0
## The stair's channel through the hill's front tongue (x) and its run (z, from the door at its foot to the landing).
const STAIR_X0: float = 56.0
const STAIR_X1: float = 64.0
const STAIR_FOOT: float = 12.0
const STAIR_TOP: float = 4.0
## The towers (dx from the axis, z, radius, height above the hill top, cone): mirrored either side. The front ones frame the doors in the near
## views; the cones of the middle row sit in the band seen over the great wall from outside; the back row and the spire rise for the far views.
const TOWERS: Array[Array] = [
	[10.6, -2.6, 1.8, 22.0, 8.0], [18.0, -3.6, 2.2, 17.0, 7.0], [28.5, -5.0, 3.8, 16.0, 9.0], [36.5, -8.0, 2.2, 11.0, 6.0],
	[6.0, -17.0, 2.4, 30.0, 10.0], [17.0, -13.0, 2.8, 24.0, 9.0], [25.0, -18.0, 2.4, 20.0, 8.0], [33.0, -15.0, 2.0, 15.0, 7.0],
]


static func build(final_state: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "PrimmsCastle"
	var mesh: KitMesh = KitMesh.new()
	K.materials(mesh, Color(0.62, 0.57, 0.5) if final_state else Color.WHITE)
	var cracks: StandardMaterial3D = K.own_glow(K.RIFT_HOT, 2.4, 1.0, true) if not final_state else EnvKit.flat(Color("4a4650"), "cap_crack_dark")
	mesh.set_material("cracks", cracks)
	if final_state:
		# honest light: the mirrored panes are warm lit windows now
		mesh.set_material("mirror", EnvKit.glow(Color("ffcf88"), 1.1))
	_hill(mesh)
	_stair(mesh, final_state)
	_keep(mesh, final_state)
	_wings(mesh)
	for tower: Array in TOWERS:
		for side: float in [-1.0, 1.0]:
			K.spire(mesh, Vector3(AXIS + side * float(tower[0]), TOP, float(tower[1])), float(tower[2]), float(tower[3]), float(tower[4]))
	_cracks(mesh)
	_gardens(mesh)
	var body: MeshInstance3D = mesh.instance("Body")
	body.set_meta(PaintedClasses.META_NO_PAINT, true)
	# the castle reads over the great wall through the outside's thick fog: its own materials take a lighter haze of their own (`StyleToon.META_FAR_HAZE`,
	# set per half by `CapitalBuilder.set_castle_haze` from the zone styles' "far_haze"); the glowing cracks skip the fog altogether
	for surface: int in range(body.mesh.get_surface_count()):
		var source: StandardMaterial3D = body.mesh.surface_get_material(surface) as StandardMaterial3D
		if source == null:
			continue
		if source == cracks:
			cracks.disable_fog = true
			continue
		var own: StandardMaterial3D = source.duplicate() as StandardMaterial3D
		own.set_meta(StyleToon.META_FAR_HAZE, true)
		own.disable_fog = true
		body.mesh.surface_set_material(surface, own)
	root.add_child(body)
	if not final_state:
		root.set_meta("cracks", cracks)
	root.set_meta("triangles", mesh.triangle_count())
	root.set_meta(&"no_wind", true)
	CapitalLandmarks.mark_view(root)
	return root


# ---- the hill and its terraces ---------------------------------------------------------------------------------------------------------------


## The hill's front tongue (in `CapitalLayout.HILL`, x 47..74, z 0..12) in two halves either side of the stair's channel: a lower terrace 3.5 m up
## behind a white retaining wall at z 12, the upper terrace (the hill top, 7 m) behind a second wall at z 9; the hill body beyond the map widens to
## both sides behind a 7 m white wall at z 0. Lawn tops, gold copings.
static func _hill(mesh: KitMesh) -> void:
	var hill: Rect2i = CapitalLayout.HILL
	var half_h: float = TOP * 0.5
	for span: Vector2 in [Vector2(float(hill.position.x), STAIR_X0), Vector2(STAIR_X1, float(hill.end.x))]:
		var mid: float = (span.x + span.y) * 0.5
		var width: float = span.y - span.x
		# lower terrace: its wall face, lawn top, coping
		mesh.box("plaster", Vector3(mid, half_h * 0.5, 10.5), Vector3(width, half_h, 3.0), Basis.IDENTITY, 0.0, 0.85)
		mesh.box("lawn", Vector3(mid, half_h + 0.02, 10.5), Vector3(width - 0.1, 0.04, 2.9))
		mesh.box("trim", Vector3(mid, half_h + 0.12, STAIR_FOOT - 0.12), Vector3(width + 0.1, 0.24, 0.3))
		# upper terrace
		mesh.box("plaster", Vector3(mid, TOP * 0.5, 4.5), Vector3(width, TOP, 9.0), Basis.IDENTITY, 0.0, 0.85)
		mesh.box("lawn", Vector3(mid, TOP + 0.02, 4.5), Vector3(width - 0.1, 0.04, 8.9))
		mesh.box("trim", Vector3(mid, TOP + 0.12, 8.88), Vector3(width + 0.1, 0.24, 0.3))
		# a gold band and pilasters on the lower wall's face, so it reads as a civic terrace and not a slab
		mesh.box("gold", Vector3(mid, half_h - 0.55, STAIR_FOOT + 0.01), Vector3(width, 0.12, 0.04))
		var count: int = int(width / 3.2)
		for index: int in range(count + 1):
			var x: float = span.x + width * float(index) / float(count)
			mesh.box("marble_shade", Vector3(x, half_h * 0.5, STAIR_FOOT + 0.08), Vector3(0.5, half_h, 0.16))
			mesh.box("marble_shade", Vector3(x, TOP * 0.75, 9.08), Vector3(0.5, half_h, 0.16))
	# the stair's landing under the keep's terrace
	mesh.box("plaster", Vector3(AXIS, TOP * 0.5, STAIR_TOP * 0.5), Vector3(STAIR_X1 - STAIR_X0, TOP, STAIR_TOP), Basis.IDENTITY, 0.0, 0.85)
	# the hill body beyond the map: a 7 m white terrace wall at z 0 and the lawn on top, back to the palace
	mesh.box("plaster", Vector3(AXIS, TOP * 0.5, -27.0), Vector3(100.0, TOP, 54.0), Basis.IDENTITY, 0.0, 0.85)
	mesh.box("lawn", Vector3(AXIS, TOP + 0.02, -24.0), Vector3(99.8, 0.04, 48.0))
	mesh.box("trim", Vector3(AXIS, TOP + 0.12, -0.12), Vector3(100.2, 0.24, 0.3))


## The grand stair: eight white steps from the castle door at its foot to the landing, between balustrades of gold-capped posts, two painted
## lamps at the foot and two at the top, Primm's banners at the foot.
static func _stair(mesh: KitMesh, final_state: bool) -> void:
	var steps: int = 10
	var run: float = (STAIR_FOOT - STAIR_TOP) / float(steps)
	for index: int in range(steps):
		var top: float = TOP * float(index + 1) / float(steps)
		var z0: float = STAIR_FOOT - float(index) * run
		mesh.box("plaster", Vector3(AXIS, top * 0.5, z0 - run * 0.5), Vector3(STAIR_X1 - STAIR_X0 - 0.2, top, run), Basis.IDENTITY, 0.0, 0.9)
		mesh.box("marble_shade", Vector3(AXIS, top - 0.03, z0 - 0.02), Vector3(STAIR_X1 - STAIR_X0 - 0.2, 0.06, 0.06))
	for side: float in [-1.0, 1.0]:
		var x: float = AXIS + side * ((STAIR_X1 - STAIR_X0) * 0.5 + 0.25)
		# the balustrade: a sloping rail on posts
		for index: int in range(steps + 1):
			var z: float = STAIR_FOOT - float(index) * run
			var y: float = TOP * float(index) / float(steps)
			K.post(mesh, Vector3(x, y, z), Vector3(0.3, 1.0, 0.3), index % 3 == 0)
		mesh.quad("gold", [Vector3(x - 0.18, 1.12, STAIR_FOOT), Vector3(x + 0.18, 1.12, STAIR_FOOT), Vector3(x + 0.18, TOP + 1.12, STAIR_TOP), Vector3(x - 0.18, TOP + 1.12, STAIR_TOP)], Vector3.UP)
		# the big gold-capped plinths at the foot, a lamp on each, a banner hung between it and the door
		K.post(mesh, Vector3(AXIS + side * 5.4, 0.0, STAIR_FOOT + 0.6), Vector3(1.0, 1.6, 1.0), true)
		K.card(mesh, "CAP-PROP-LAMP", Vector3(AXIS + side * 5.4, 1.75, STAIR_FOOT + 0.6), 3.2, Vector3(0, 0, 1))
		K.card(mesh, "CAP-PROP-LAMP", Vector3(AXIS + side * 4.6, TOP, STAIR_TOP - 0.4), 3.0, Vector3(0, 0, 1))
		if not final_state:
			K.card(mesh, "CAP-SHEET-BANNERS-02", Vector3(AXIS + side * 6.6, 4.6, STAIR_FOOT + 0.25), 3.4, Vector3(0, 0, 1))
	# the Primm statue on the landing in front of the doors (the concept's and the paint-over's centrepiece), on a gold-banded plinth
	K.post(mesh, Vector3(AXIS, TOP, 1.4), Vector3(2.0, 1.2, 2.0), false)
	K.primm_statue(mesh, Vector3(AXIS, TOP + 1.3, 1.4), 3.8, Vector3(0, 0, 1), final_state)


# ---- the palace ---------------------------------------------------------------------------------------------------------------------------


## The keep: the central block whose front holds the grand portal (great arched doors of mirrored glass in a gold frame) and, over it, the colossal
## smiling emblem under a gold-edged gable; a row of tall windows, a balustrade, a blue hipped roof and the central spire above.
static func _keep(mesh: KitMesh, final_state: bool) -> void:
	var front: float = KEEP_FRONT
	var back: float = -16.0
	var half_w: float = 10.0
	var eave: float = TOP + 24.0
	var center: Vector3 = Vector3(AXIS, (TOP + eave) * 0.5, (front + back) * 0.5)
	mesh.box("plaster", center, Vector3(half_w * 2.0, eave - TOP, front - back), Basis.IDENTITY, 0.08, 0.8)
	for y: float in [TOP + 0.2, TOP + 13.4, eave - 0.3]:
		mesh.box("trim", Vector3(AXIS, y, front + 0.04), Vector3(half_w * 2.0 + 0.1, 0.5, 0.1))
	# the portal: a projecting frame with pilasters and a pointed gable, the doors inside it
	var portal_front: float = front + 1.3
	mesh.box("plaster", Vector3(AXIS, TOP + 5.6, front + 0.65), Vector3(11.0, 11.2, 1.3), Basis.IDENTITY, 0.06, 0.85)
	for side: float in [-1.0, 1.0]:
		mesh.box("plaster", Vector3(AXIS + side * 4.9, TOP + 6.5, portal_front + 0.15), Vector3(1.0, 13.0, 0.5), Basis.IDENTITY, 0.04)
		mesh.box("gold", Vector3(AXIS + side * 4.9, TOP + 13.1, portal_front + 0.15), Vector3(1.2, 0.3, 0.7))
		K.finial(mesh, Vector3(AXIS + side * 4.9, TOP + 13.25, portal_front + 0.15), 1.4)
	var gable_base: float = TOP + 10.6
	var g0: Vector3 = Vector3(AXIS - 5.6, gable_base, portal_front + 0.02)
	var g1: Vector3 = Vector3(AXIS + 5.6, gable_base, portal_front + 0.02)
	var apex: Vector3 = Vector3(AXIS, gable_base + 5.2, portal_front + 0.02)
	mesh.tri("plaster", [g0, g1, apex], Vector3(0, 0, 1))
	mesh.quad("gold", [g0 + Vector3(0, -0.2, 0.03), apex + Vector3(0, -0.2, 0.03), apex + Vector3(0, 0.25, 0.03), g0 + Vector3(0, 0.25, 0.03)], Vector3(0, 0, 1))
	mesh.quad("gold", [apex + Vector3(0, -0.2, 0.03), g1 + Vector3(0, -0.2, 0.03), g1 + Vector3(0, 0.25, 0.03), apex + Vector3(0, 0.25, 0.03)], Vector3(0, 0, 1))
	K.finial(mesh, apex, 1.8)
	# the great doors: one tall arched opening of mirrored panes (warm light once Primm has fallen) in gold, divided into two leaves
	K.arched_window(mesh, Vector3(AXIS, TOP + 0.1, portal_front), 6.2, 7.6, Vector3(0, 0, 1), "mirror")
	mesh.box("gold", Vector3(AXIS, TOP + 0.05, portal_front + 0.1), Vector3(7.4, 0.15, 0.3))
	for row: float in [2.6, 5.2]:
		mesh.box("gold", Vector3(AXIS, TOP + row, portal_front + 0.07), Vector3(6.2, 0.1, 0.08))
	for column: float in [-1.55, 1.55]:
		mesh.box("gold", Vector3(AXIS + column, TOP + 3.6, portal_front + 0.07), Vector3(0.08, 7.0, 0.08))
	# the colossal smiling emblem over the doors (broken and covered once Primm has fallen)
	K.emblem(mesh, Vector3(AXIS, TOP + 10.2, portal_front + 0.05), 2.25, Vector3(0, 0, 1), final_state, final_state)
	# the keep's upper storey: three tall mirrored windows either side of the gable, the balustrade and the hipped roof
	for column: float in [-7.4, 7.4]:
		K.arched_window(mesh, Vector3(AXIS + column, TOP + 4.0, front + 0.01), 2.2, 6.0, Vector3(0, 0, 1), "mirror")
		K.arched_window(mesh, Vector3(AXIS + column, TOP + 15.0, front + 0.01), 2.0, 5.0, Vector3(0, 0, 1), "mirror")
	for column: float in [-3.4, 0.0, 3.4]:
		K.arched_window(mesh, Vector3(AXIS + column, TOP + 18.0, front + 0.01), 1.6, 4.0, Vector3(0, 0, 1), "mirror")
	_balustrade(mesh, Vector3(AXIS - half_w, eave, front - 0.2), Vector3(AXIS + half_w, eave, front - 0.2))
	_hip_roof(mesh, Vector3(AXIS, eave, (front + back) * 0.5), Vector2(half_w * 2.0 - 1.0, front - back - 1.0), 7.0, "roof_blue")
	# the central spire on the roof ridge
	K.spire(mesh, Vector3(AXIS, eave + 2.0, (front + back) * 0.5), 2.6, 12.0, 11.0)


## The two long wings either side of the keep: two rows of tall mirrored windows between gold bands, a balustrade with finials, blue hipped roofs.
static func _wings(mesh: KitMesh) -> void:
	for side: float in [-1.0, 1.0]:
		var x0: float = AXIS + side * 10.0
		var x1: float = AXIS + side * 27.0
		var front: float = -4.0
		var back: float = -14.0
		var eave: float = TOP + 13.0
		var mid: float = (x0 + x1) * 0.5
		mesh.box("plaster", Vector3(mid, (TOP + eave) * 0.5, (front + back) * 0.5), Vector3(absf(x1 - x0), eave - TOP, front - back), Basis.IDENTITY, 0.06, 0.8)
		for y: float in [TOP + 0.2, TOP + 6.4, eave - 0.3]:
			mesh.box("trim", Vector3(mid, y, front + 0.04), Vector3(absf(x1 - x0) + 0.1, 0.45, 0.1))
		for index: int in range(5):
			var x: float = x0 + side * (2.2 + float(index) * 3.4)
			K.arched_window(mesh, Vector3(x, TOP + 1.4, front + 0.01), 1.5, 4.0, Vector3(0, 0, 1), "mirror")
			K.arched_window(mesh, Vector3(x, TOP + 7.4, front + 0.01), 1.4, 4.0, Vector3(0, 0, 1), "mirror")
			K.finial(mesh, Vector3(x, eave + 1.1, front - 0.2), 1.0)
		_balustrade(mesh, Vector3(minf(x0, x1), eave, front - 0.2), Vector3(maxf(x0, x1), eave, front - 0.2))
		_hip_roof(mesh, Vector3(mid, eave, (front + back) * 0.5), Vector2(absf(x1 - x0) - 0.6, front - back - 0.6), 5.0, "roof_blue")
		# a low curtain wall out to the outer towers, its balustrade on top
		var cx0: float = AXIS + side * 27.0
		var cx1: float = AXIS + side * 38.0
		mesh.box("plaster", Vector3((cx0 + cx1) * 0.5, TOP + 3.0, -7.5), Vector3(absf(cx1 - cx0), 6.0, 3.0), Basis.IDENTITY, 0.04, 0.85)
		mesh.box("trim", Vector3((cx0 + cx1) * 0.5, TOP + 5.7, -5.96), Vector3(absf(cx1 - cx0), 0.4, 0.08))
		_balustrade(mesh, Vector3(minf(cx0, cx1), TOP + 6.0, -6.2), Vector3(maxf(cx0, cx1), TOP + 6.0, -6.2))


## A balustrade along a wall top from `a` to `b` (same y and z): a white rail on small gold-capped posts.
static func _balustrade(mesh: KitMesh, a: Vector3, b: Vector3) -> void:
	var length: float = a.distance_to(b)
	mesh.box("plaster", (a + b) * 0.5 + Vector3(0, 0.95, 0), Vector3(length, 0.18, 0.4))
	var count: int = maxi(2, int(length / 1.1))
	for index: int in range(count + 1):
		var p: Vector3 = a.lerp(b, float(index) / float(count))
		mesh.box("plaster", p + Vector3(0, 0.45, 0), Vector3(0.22, 0.9, 0.22))
		if index % 4 == 0:
			mesh.box("gold", p + Vector3(0, 1.1, 0), Vector3(0.3, 0.12, 0.3))


## A hipped roof over a `size` (x, z) rectangle on `center` (its eave height), rising `rise` metres to a ridge, its ridge capped in gold.
static func _hip_roof(mesh: KitMesh, center: Vector3, size: Vector2, rise: float, slot: String) -> void:
	var hx: float = size.x * 0.5
	var hz: float = absf(size.y) * 0.5
	var inset: float = minf(hx, hz) * 0.9
	var ridge_a: Vector3 = center + Vector3(-maxf(hx - inset, 0.05), rise, 0)
	var ridge_b: Vector3 = center + Vector3(maxf(hx - inset, 0.05), rise, 0)
	var c00: Vector3 = center + Vector3(-hx, 0, -hz)
	var c10: Vector3 = center + Vector3(hx, 0, -hz)
	var c11: Vector3 = center + Vector3(hx, 0, hz)
	var c01: Vector3 = center + Vector3(-hx, 0, hz)
	mesh.quad(slot, [c01, c11, ridge_b, ridge_a], Vector3(0, 0.6, 1))
	mesh.quad(slot, [c10, c00, ridge_a, ridge_b], Vector3(0, 0.6, -1))
	mesh.tri(slot, [c00, c01, ridge_a], Vector3(-1, 0.6, 0))
	mesh.tri(slot, [c11, c10, ridge_b], Vector3(1, 0.6, 0))
	mesh.box("gold", (ridge_a + ridge_b) * 0.5 + Vector3(0, 0.1, 0), Vector3(ridge_a.distance_to(ridge_b) + 0.4, 0.25, 0.3))


# ---- the cracks and the gardens ----------------------------------------------------------------------------------------------------------


## Hairline cracks that leak rift light: jagged lines up the portal past the emblem, across a wing and up the tall front towers. Thin quads a hair in
## front of the faces in the "cracks" material (pulsed slowly by the builder; dark once Primm has fallen).
static func _cracks(mesh: KitMesh) -> void:
	var lines: Array = [
		# up from the door's left jamb, round the emblem, into the gable
		[Vector3(AXIS - 3.0, TOP + 8.6, -0.58), Vector3(AXIS - 3.6, TOP + 9.6, -0.58), Vector3(AXIS - 3.1, TOP + 10.4, -0.58), Vector3(AXIS - 2.5, TOP + 11.6, -0.58), Vector3(AXIS - 1.2, TOP + 13.6, -0.58), Vector3(AXIS - 1.6, TOP + 14.6, -0.58)],
		# down the keep's right from the upper windows
		[Vector3(AXIS + 6.2, TOP + 21.0, -1.94), Vector3(AXIS + 6.8, TOP + 19.4, -1.94), Vector3(AXIS + 6.3, TOP + 17.8, -1.94), Vector3(AXIS + 7.1, TOP + 15.6, -1.94), Vector3(AXIS + 6.6, TOP + 13.2, -1.94)],
		# across the left wing under the cornice
		[Vector3(AXIS - 12.0, TOP + 12.0, -3.94), Vector3(AXIS - 14.5, TOP + 11.2, -3.94), Vector3(AXIS - 16.0, TOP + 11.8, -3.94), Vector3(AXIS - 18.6, TOP + 10.6, -3.94), Vector3(AXIS - 20.0, TOP + 11.0, -3.94)],
		# the right wing's base
		[Vector3(AXIS + 21.0, TOP + 0.4, -3.94), Vector3(AXIS + 21.6, TOP + 2.0, -3.94), Vector3(AXIS + 21.1, TOP + 3.4, -3.94), Vector3(AXIS + 22.0, TOP + 5.0, -3.94)],
	]
	for line: Array in lines:
		for index: int in range(line.size() - 1):
			var a: Vector3 = line[index] as Vector3
			var b: Vector3 = line[index + 1] as Vector3
			var across: Vector3 = (b - a).cross(Vector3(0, 0, 1)).normalized() * (0.09 if index % 2 == 0 else 0.06)
			mesh.quad("cracks", [a - across, b - across, b + across, a + across], Vector3(0, 0, 1))
	# up the two front towers' faces
	for side: float in [-1.0, 1.0]:
		var tower: Array = TOWERS[0]
		var base: Vector3 = Vector3(AXIS + side * float(tower[0]), TOP + 6.0, float(tower[1]) + float(tower[2]) + 0.04)
		var points: Array[Vector3] = [base, base + Vector3(side * 0.3, 2.2, 0), base + Vector3(-side * 0.2, 4.0, 0), base + Vector3(side * 0.25, 6.4, 0)]
		for index: int in range(points.size() - 1):
			var across: Vector3 = Vector3(0.07, 0, 0)
			mesh.quad("cracks", [points[index] - across, points[index + 1] - across, points[index + 1] + across, points[index] + across], Vector3(0, 0, 1))


## The terraces' gardens (the concept's and the paint-over's): clipped hedges along the terrace edges, topiary cones in gold pots and rose beds
## in white planters in perfect rows, all painted cards facing the avenue.
static func _gardens(mesh: KitMesh) -> void:
	for side: float in [-1.0, 1.0]:
		for edge: Vector2 in [Vector2(STAIR_FOOT - 1.6, CapitalLayout.HILL_HEIGHT * 0.5), Vector2(8.3, TOP)]:
			var x0: float = AXIS + side * 4.8
			var x1: float = AXIS + side * 13.0
			mesh.box("hedge", Vector3((x0 + x1) * 0.5, edge.y + 0.45, edge.x), Vector3(absf(x1 - x0), 0.9, 0.9), Basis.IDENTITY, 0.2, 0.7)
			for index: int in range(4):
				var x: float = AXIS + side * (5.6 + float(index) * 2.4)
				K.card(mesh, "CAP-TREE-TOPIARY" if index % 2 == 0 else "CAP-PLANT-ROSE", Vector3(x, edge.y, edge.x + 0.7), 2.0 if index % 2 == 0 else 1.1, Vector3(0, 0, 1))
		# the keep's terrace: two rows of topiaries between the stair head and the wings
		for index: int in range(3):
			K.card(mesh, "CAP-TREE-TOPIARY", Vector3(AXIS + side * (6.2 + float(index) * 3.0), TOP, 1.0), 2.6, Vector3(0, 0, 1))
