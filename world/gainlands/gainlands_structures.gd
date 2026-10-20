class_name GainlandsStructures
extends RefCounted
## Gainlands v2, Part D: the zone's tall things at believable storybook scale (docs/art/gainlands_v2.md).
##  - `windmill()`: a four-storey tower mill (STANDIN until painted): a tapered sandstone-and-brick tower on a plinth, a gallery, a red cap, four lattice sails
##    11 m across on a hub (meta "spinner": the sails' node, turned round its local z by the builder). About 13 m to the cap: the KayKit mill was 4.4 m.
##  - `cypress()` and `windbent()`: the few hardy trees (meshes for MultiMesh fields): a narrow dark column 6-7 m tall, a dry-land tree leaning away from the wind.
##  - `pylons(points)` and `cables(...)`: the power lines: lattice towers PYLON_H tall with a crossarm of three insulators, and three sagging cables per span
##    (catenaries) between consecutive towers. One mesh for all the towers, one for all the cables.

const PYLON_H: float = 16.0
const ARM_Y: float = 14.2
const ARM_HALF: float = 2.6
## How far a cable sags at mid-span per metre of span.
const SAG_PER_M: float = 0.055


static func _kit() -> KitMesh:
	var mesh: KitMesh = KitMesh.new()
	GainlandsLandmarks._materials(mesh)
	mesh.set_material("sandstone", EnvKit.flat(Color("dcc19a"), "gl2_sandstone_block"))
	mesh.set_material("plaster", EnvKit.flat(Color("d9b88a"), "gl2_mill_plaster"))
	mesh.set_material("sail", EnvKit.flat(Color("f4ead8"), "gl2_sail_cloth"))
	return mesh


static func windmill() -> Node3D:
	var mesh: KitMesh = _kit()
	var root: Node3D = Node3D.new()
	root.name = "TowerMill"
	# the plinth and the tapered tower: a sandstone ground storey, three plastered storeys above it, brass bands between
	mesh.lathe("sandstone", Vector3.ZERO, [Vector2(3.1, 0.0), Vector2(3.1, 0.6), Vector2(2.8, 0.6)], 8, 0.85, false, true)
	mesh.lathe("sandstone", Vector3(0, 0.6, 0), [Vector2(2.75, 0.0), Vector2(2.6, 2.6)], 8, 0.9, false, false)
	# the upper storeys: brick below, warm plaster above (a sandstone-country tower mill, not a lighthouse)
	mesh.lathe("brick", Vector3(0, 3.2, 0), [Vector2(2.6, 0.0), Vector2(2.4, 3.0)], 8, 0.9, false, false)
	mesh.lathe("plaster", Vector3(0, 6.2, 0), [Vector2(2.4, 0.0), Vector2(2.1, 4.4)], 8, 0.92, false, false)
	for k: int in range(8):
		var a: float = TAU * (float(k) + 0.5) / 8.0
		mesh.tube("bleach_dark", Vector3(cos(a) * 2.42, 6.2, sin(a) * 2.42), Vector3(cos(a) * 2.13, 10.5, sin(a) * 2.13), 0.09, 4, false)
	for y: float in [3.2, 5.7, 8.2]:
		mesh.lathe("brass", Vector3(0, y, 0), [Vector2(2.68 - (y - 3.2) * 0.068, 0.0), Vector2(2.68 - (y - 3.2) * 0.068, 0.18)], 8, 1.0, false, false)
	# the gallery round the top storey, the cap
	mesh.lathe("bleach_dark", Vector3(0, 10.4, 0), [Vector2(3.0, 0.0), Vector2(3.0, 0.2), Vector2(2.1, 0.2)], 8, 0.9, true, true)
	for k: int in range(16):
		var a: float = TAU * float(k) / 16.0
		mesh.box("bleach_dark", Vector3(cos(a) * 2.9, 11.0, sin(a) * 2.9), Vector3(0.08, 1.0, 0.08), Basis.IDENTITY, 0.0)
	mesh.lathe("bleach_dark", Vector3(0, 11.45, 0), [Vector2(2.95, 0.0), Vector2(2.95, 0.08)], 16, 1.0, false, false)
	mesh.lathe("roof", Vector3(0, 10.6, 0), [Vector2(2.4, 0.0), Vector2(2.2, 1.0), Vector2(1.2, 2.4), Vector2(0.0, 2.9)], 10, 0.95, true, true)
	mesh.blob("gold", Vector3(0, 13.65, 0), Vector3(0.3, 0.3, 0.3), 4, 8, 1.0)
	# a door, windows up the tower (kit cards), the sails' axle housing at the front
	GainlandsLandmarks._card(mesh, "GAIN-SHEET-DOORS-02", Vector3(0, 0.6, 2.72), StorybookScale.DOOR_H, Vector3(0, 0, 1))
	for y: float in [4.4, 7.0]:
		GainlandsLandmarks._card(mesh, "GAIN-SHEET-WINDOWS-01", Vector3(0, y, 2.62 - (y - 3.2) * 0.068), 1.1, Vector3(0, 0, 1))
	mesh.tube("iron", Vector3(0, 11.6, 1.6), Vector3(0, 11.6, 3.0), 0.35, 8, true)
	# Art import Oct 20 (the painted concept GAIN-PROP-TOWER-MILL): red-and-gold pennants hung from the gallery rail, round the front half
	for k: int in range(5):
		var a: float = PI * 0.5 + (float(k) - 2.0) * 0.55
		var out: Vector3 = Vector3(cos(a), 0.0, sin(a))
		GainlandsLandmarks._card(mesh, "GAIN-SHEET-BANNERS-0%d" % (1 + k % 3), out * 3.04 + Vector3(0, 11.4, 0), 1.0, out)
	var body: MeshInstance3D = mesh.instance("Body")
	body.set_meta(PaintedClasses.META_NO_PAINT, true)
	root.add_child(body)
	# the sails: four lattice arms on a hub, their own node so they turn
	var sails: KitMesh = _kit()
	sails.blob("iron", Vector3.ZERO, Vector3(0.55, 0.55, 0.55), 4, 8, 1.0)
	for k: int in range(4):
		var a: float = TAU * float(k) / 4.0 + 0.4
		var dir: Vector3 = Vector3(cos(a), sin(a), 0)
		var side: Vector3 = Vector3(-sin(a), cos(a), 0)
		sails.tube("bleach_dark", dir * 0.4, dir * 5.6, 0.12, 5, true)
		var basis: Basis = Basis(side, dir, Vector3(0, 0, 1))
		sails.box("sail", dir * 3.4 + side * 0.55, Vector3(0.95, 4.2, 0.05), basis, 0.0)
		for r: float in [1.6, 2.6, 3.6, 4.6, 5.4]:
			sails.box("bleach_dark", dir * r + side * 0.55, Vector3(1.05, 0.06, 0.08), basis, 0.0)
		sails.box("bleach_dark", dir * 3.4 + side * 1.05, Vector3(0.06, 4.2, 0.08), basis, 0.0)
	var spinner: Node3D = Node3D.new()
	spinner.name = "Sails"
	spinner.position = Vector3(0, 11.6, 3.1)
	spinner.add_child(sails.instance("SailsBody"))
	root.add_child(spinner)
	root.set_meta("spinner", spinner)
	root.set_meta(&"no_wind", true)
	root.set_meta("concept", "GAIN-PROP-TOWER-MILL")  # modelled after the painted concept (art import Oct 20; was a STANDIN)
	root.set_meta("height", 13.9)
	return root


## A cypress: a narrow dark-green column on a short trunk, about 6.5 m (one mesh, drawn many times).
static func cypress_mesh() -> ArrayMesh:
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("bark", EnvKit.material("TEX-MAT-BARK") if EnvKit.has("TEX-MAT-BARK") else EnvKit.flat(Color("6a4a32"), "bark"))
	mesh.set_material("leaves", EnvKit.flat(Color("3f6a3a"), "gl2_cypress"))
	mesh.tube("bark", Vector3.ZERO, Vector3(0, 0.9, 0), 0.16, 6, true)
	mesh.lathe("leaves", Vector3(0, 0.6, 0), [Vector2(0.35, 0.0), Vector2(0.95, 1.2), Vector2(1.05, 2.6), Vector2(0.85, 4.2), Vector2(0.45, 5.4), Vector2(0.0, 6.0)], 9, 0.9, true, true)
	return mesh.build()


## A wind-bent dry-land tree: a trunk leaning away from the wind (the zone's wind blows towards +x) and a flattened, swept crown, about 5 m.
static func windbent_mesh() -> ArrayMesh:
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("bark", EnvKit.material("TEX-MAT-BARK") if EnvKit.has("TEX-MAT-BARK") else EnvKit.flat(Color("6a4a32"), "bark"))
	mesh.set_material("leaves", EnvKit.flat(Color("7d8a4c"), "gl2_dry_leaves"))
	mesh.alias("leaves_dark", "leaves", Color(0.82, 0.86, 0.78))
	var points: Array[Vector3] = [Vector3(0, 0, 0), Vector3(0.25, 1.4, 0.05), Vector3(0.9, 2.6, 0.0), Vector3(1.8, 3.4, -0.1)]
	for k: int in range(points.size() - 1):
		mesh.tube("bark", points[k], points[k + 1], 0.24 - 0.05 * float(k), 7, true)
	mesh.tube("bark", points[2], Vector3(0.2, 3.5, 0.5), 0.09, 5, true)
	mesh.blob("leaves", Vector3(2.2, 3.9, 0.0), Vector3(1.9, 0.75, 1.9), 4, 9, 0.9)
	mesh.blob("leaves_dark", Vector3(1.0, 3.75, 0.3), Vector3(1.3, 0.6, 1.3), 4, 8, 0.85)
	mesh.blob("leaves", Vector3(3.2, 3.6, -0.2), Vector3(1.1, 0.5, 1.1), 4, 8, 0.9)
	return mesh.build()


## Every tower of the power lines in one mesh: `points` (x, y base, z) in the order the cables run; each tower turns to bisect its two spans.
static func pylons(points: Array[Vector3]) -> MeshInstance3D:
	var mesh: KitMesh = _kit()
	mesh.alias("insulator", "flat", Color("e8e4dc"))
	for index: int in range(points.size()):
		var base: Vector3 = points[index]
		var heading: Vector3 = _heading(points, index)
		var across: Vector3 = Vector3(-heading.z, 0, heading.x)
		var foot: float = 1.4
		var waist: float = 0.45
		# four legs tapering to the waist, braced in X panels, the crossarm and the peak
		var corners: Array[Vector2] = [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]
		var levels: Array[float] = [0.0, 4.0, 8.0, 11.5, ARM_Y]
		for k: int in range(levels.size() - 1):
			var w0: float = lerpf(foot, waist, levels[k] / ARM_Y)
			var w1: float = lerpf(foot, waist, levels[k + 1] / ARM_Y)
			for c: int in range(4):
				var a0: Vector3 = base + across * corners[c].x * w0 + heading * corners[c].y * w0 + Vector3(0, levels[k], 0)
				var a1: Vector3 = base + across * corners[c].x * w1 + heading * corners[c].y * w1 + Vector3(0, levels[k + 1], 0)
				var n: int = (c + 1) % 4
				var b0: Vector3 = base + across * corners[n].x * w0 + heading * corners[n].y * w0 + Vector3(0, levels[k], 0)
				var b1: Vector3 = base + across * corners[n].x * w1 + heading * corners[n].y * w1 + Vector3(0, levels[k + 1], 0)
				mesh.tube("iron", a0, a1, 0.075, 4, false)
				mesh.tube("iron", a0, b1, 0.032, 3, false)
				mesh.tube("iron", b0, a1, 0.032, 3, false)
				mesh.tube("iron", a1, b1, 0.04, 3, false)
		var arm_centre: Vector3 = base + Vector3(0, ARM_Y, 0)
		mesh.box("iron", arm_centre, Vector3(ARM_HALF * 2.0 + 0.3, 0.3, 0.3), Basis(Vector3.UP, atan2(heading.x, heading.z) + PI * 0.5), 0.0)
		mesh.tube("iron", arm_centre, arm_centre + Vector3(0, 1.8, 0), 0.08, 4, true)
		for tip: Vector3 in arm_tips(points, index):
			mesh.tube("insulator", tip + Vector3(0, 0.75, 0), tip, 0.09, 6, true)
		mesh.box("sandstone", base + Vector3(0, 0.15, 0), Vector3(3.4, 0.3, 3.4), Basis(Vector3.UP, atan2(heading.x, heading.z)), 0.05)
	var instance: MeshInstance3D = mesh.instance("Pylons")
	instance.set_meta(PaintedClasses.META_NO_PAINT, true)
	instance.set_meta(&"no_occlusion_fade", true)
	instance.set_meta(&"no_range_cull", true)
	return instance


static func _heading(points: Array[Vector3], index: int) -> Vector3:
	var prev: Vector3 = points[maxi(index - 1, 0)]
	var next: Vector3 = points[mini(index + 1, points.size() - 1)]
	var dir: Vector3 = Vector3(next.x - prev.x, 0, next.z - prev.z)
	return dir.normalized() if dir.length() > 0.01 else Vector3(0, 0, 1)


## Where the three cables hang from tower `index`: the two crossarm ends and the peak's middle, just under the insulators.
static func arm_tips(points: Array[Vector3], index: int) -> Array[Vector3]:
	var heading: Vector3 = _heading(points, index)
	var across: Vector3 = Vector3(-heading.z, 0, heading.x)
	var base: Vector3 = points[index]
	return [base + across * -ARM_HALF + Vector3(0, ARM_Y - 0.75, 0), base + Vector3(0, ARM_Y - 0.75, 0), base + across * ARM_HALF + Vector3(0, ARM_Y - 0.75, 0)] as Array[Vector3]


## The cables between consecutive towers of one line: three catenaries per span, each sagging SAG_PER_M of its length at mid-span; meta "sag" lists every
## span's mid-span drop (for the tests).
static func cables(points: Array[Vector3]) -> MeshInstance3D:
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("cable", EnvKit.flat(Color("2c2a30"), "gl2_cable"))
	var sags: Array[float] = []
	for index: int in range(points.size() - 1):
		var from: Array[Vector3] = arm_tips(points, index)
		var to: Array[Vector3] = arm_tips(points, index + 1)
		for wire: int in range(3):
			var a: Vector3 = from[wire]
			var b: Vector3 = to[wire]
			var span: float = Vector2(b.x - a.x, b.z - a.z).length()
			var sag: float = span * SAG_PER_M
			if wire == 0:
				sags.append(sag)
			var steps: int = maxi(6, int(span / 2.5))
			var previous: Vector3 = a
			for step: int in range(1, steps + 1):
				var t: float = float(step) / float(steps)
				var point: Vector3 = a.lerp(b, t) - Vector3(0, sag * 4.0 * t * (1.0 - t), 0)
				mesh.tube("cable", previous, point, 0.06, 4, false)
				previous = point
	var instance: MeshInstance3D = mesh.instance("Cables")
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.set_meta(PaintedClasses.META_NO_PAINT, true)
	instance.set_meta(&"no_occlusion_fade", true)
	instance.set_meta(&"no_range_cull", true)
	instance.set_meta("sag", sags)
	return instance
