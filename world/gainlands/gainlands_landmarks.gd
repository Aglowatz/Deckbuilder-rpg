class_name GainlandsLandmarks
extends RefCounted
## The six hero landmarks of the Gainlands, modelled after their approved concepts (docs/art/zone_kits/gainlands/concepts/) and textured with the zone kit
## (data/art/zone_kits/gainlands.json): the Wheel (Mill Fields, turns slowly), the Champions Arch (Proving Grounds), Mount Swolympus and the Trailhead Gate
## (Swolympus Trailhead), the Sky Tree (Sky Garden) and the Swole Station platform (the hub). Sizes come from the caller (`spec.size` = w, h, d in metres);
## every model is built to fill that box. Origin on the ground at the centre, front +z. Same contract as `LandmarkKit` (meta circles / footprint / height); the Wheel
## also carries meta "spinner".

const IDS: Array[String] = ["GAIN-HERO-WHEEL", "GAIN-HERO-CHAMPIONS-ARCH", "GAIN-HERO-SWOLYMPUS", "GAIN-HERO-TRAILHEAD-GATE", "GAIN-HERO-SKY-TREE", "GAIN-HERO-SWOLE-STATION", "GAIN-HERO-HOUSE-OF-GAINS"]
const RED: Color = Color("d9483b")
const GOLD: Color = Color("f2c14e")
const CREAM: Color = Color("f7ebd3")
const DARK: Color = Color("4a3324")
const ROPE: Color = Color("c9a46a")
const FLAME: Color = Color("ffb347")
const CARD_UVS: Array[Vector2] = [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)]


static func has_model(id: String) -> bool:
	return id in IDS


static func build(spec: Dictionary) -> Node3D:
	var id: String = str(spec.get("id", ""))
	if not has_model(id):
		return null
	var size_array: Array = spec.get("size", [10.0, 8.0, 6.0]) as Array
	var size: Vector3 = Vector3(float(size_array[0]), float(size_array[1]), float(size_array[2]))
	var mesh: KitMesh = KitMesh.new()
	_materials(mesh)
	var circles: Array[Vector3] = []
	var root: Node3D = Node3D.new()
	root.name = "Landmark_%s" % id
	var lights: Array[Dictionary] = []
	match id:
		"GAIN-HERO-WHEEL":
			_wheel(root, mesh, size, circles)
		"GAIN-HERO-CHAMPIONS-ARCH":
			_champions_arch(mesh, size, circles)
		"GAIN-HERO-SWOLYMPUS":
			_swolympus(root, mesh, size, circles, lights)
		"GAIN-HERO-TRAILHEAD-GATE":
			_trailhead_gate(mesh, size, circles, lights)
		"GAIN-HERO-SKY-TREE":
			_sky_tree(root, mesh, size, circles)
		"GAIN-HERO-SWOLE-STATION":
			_swole_station(root, mesh, size, circles, lights)
		"GAIN-HERO-HOUSE-OF-GAINS":
			GainlandsFortress.build(root, mesh, size, circles, lights, bool(spec.get("causeway", true)))  # GC-10, world/gainlands/gainlands_fortress.gd
	var body: MeshInstance3D = mesh.instance("Body")
	body.set_meta(PaintedClasses.META_NO_PAINT, true)
	body.set_meta("occlusion_near", 2.0)
	root.set_meta(&"no_wind", true)
	root.add_child(body)
	root.move_child(body, 0)
	root.set_meta("circles", circles)
	root.set_meta("footprint", Vector2(size.x, size.z))
	root.set_meta("height", size.y)
	root.set_meta("kind", "hero")
	root.set_meta("hero_id", id)
	root.set_meta("lights", lights)
	root.set_meta("triangles", mesh.triangle_count())
	return root


# ---- materials ----------------------------------------------------------------------------------------------------------------------------


static func _materials(mesh: KitMesh) -> void:
	mesh.set_material("bleach", EnvKit.material("GAIN-WALL-BLEACH"))
	mesh.set_material("bleach_dark", EnvKit.material("GAIN-WALL-BLEACH", false, Color(0.72, 0.6, 0.5)))
	mesh.set_material("brick", EnvKit.material("GAIN-WALL-BRICK"))
	mesh.set_material("iron", EnvKit.material("GAIN-WALL-IRON"))
	mesh.set_material("roof", EnvKit.material("GAIN-ROOF-RED"))
	mesh.set_material("canvas", EnvKit.material("GAIN-ROOF-CANVAS"))
	mesh.set_material("brass", EnvKit.material("GAIN-TRIM-BRASS"))
	mesh.set_material("stone", EnvKit.material("ENV-WALL-FOUNDATION"))
	mesh.set_material("cream_stone", EnvKit.material("ENV-WALL-FOUNDATION", false, Color(1.0, 0.95, 0.84)))
	mesh.set_material("rock", EnvKit.material("TEX-GAIN-ISLANDROCK"))
	mesh.set_material("grass", EnvKit.material("TEX-GAIN-GRASS"))
	mesh.set_material("leaves", EnvKit.material("ENV-HEDGE"))
	mesh.set_material("bark", EnvKit.material("TEX-MAT-BARK"))
	mesh.set_material("flat", EnvKit.flat(Color.WHITE, "hero"))
	mesh.alias("gold", "flat", GOLD)
	mesh.alias("red", "flat", RED)
	mesh.alias("cream", "flat", CREAM)
	mesh.alias("dark", "flat", DARK)
	mesh.alias("rope", "flat", ROPE)
	mesh.set_material("glow", EnvKit.glow(FLAME, 2.2))
	mesh.set_material("gold_glow", EnvKit.glow(Color("ffd25a"), 1.2))
	for index: int in range(1, 7):
		var banner: String = "GAIN-SHEET-BANNERS-%02d" % index
		mesh.set_material("card_%s" % banner, EnvKit.material(banner, true))
	for index: int in range(1, 7):
		var sign: String = "GAIN-SHEET-SIGNS-%02d" % index
		mesh.set_material("card_%s" % sign, EnvKit.material(sign, true))
	for door: String in ["GAIN-SHEET-DOORS-02", "GAIN-SHEET-DOORS-03", "GAIN-SHEET-DOORS-06"]:
		mesh.set_material("card_%s" % door, EnvKit.material(door, true))
	for window: String in ["GAIN-SHEET-WINDOWS-01", "GAIN-SHEET-WINDOWS-02", "GAIN-SHEET-WINDOWS-04"]:
		mesh.set_material("card_%s" % window, EnvKit.material(window, true))


## A painted cut-out standing upright in the mesh: its pivot at `pivot_pos`, `height` metres tall, facing `normal` (a horizontal unit vector; the card lies in the plane
## through pivot_pos perpendicular to it). Banners hang from their pivot (top), signs from their bracket (left plate), doors and windows stand on it (bottom centre).
static func _card(mesh: KitMesh, id: String, pivot_pos: Vector3, height: float, normal: Vector3) -> void:
	var slot: String = "card_%s" % id
	if not mesh.has_slot(slot):
		mesh.set_material(slot, EnvKit.material(id, true))
	var width: float = height * EnvKit.aspect(id)
	var pivot: Vector2 = EnvKit.pivot(id)
	var right: Vector3 = Vector3.UP.cross(normal).normalized() * -1.0
	var top: float = pivot_pos.y + pivot.y * height
	var left: Vector3 = pivot_pos - right * (pivot.x * width)
	var bottom_left: Vector3 = Vector3(left.x, top - height, left.z)
	var bottom_right: Vector3 = bottom_left + right * width
	mesh.quad(slot, [bottom_left, bottom_right, bottom_right + Vector3(0, height, 0), bottom_left + Vector3(0, height, 0)], normal, [], CARD_UVS)


## A camera-facing painted card (tree, plant, prop) as a child of `root`, base at `pos`.
static func _tree_card(root: Node3D, id: String, pos: Vector3, height: float) -> void:
	var card: MeshInstance3D = KitFoliage.card(id, Vector2(height * EnvKit.aspect(id), height), true)
	card.name = "Card_%s" % id
	root.add_child(card)
	card.position = pos


static func _post(mesh: KitMesh, base: Vector3, height: float, radius: float = 0.16, slot: String = "bleach_dark", finial: bool = true) -> void:
	mesh.tube(slot, base, base + Vector3(0, height, 0), radius, 7, true)
	if finial:
		mesh.blob("gold", base + Vector3(0, height + radius * 1.2, 0), Vector3.ONE * radius * 1.8, 4, 8, 1.0)


static func _rope(mesh: KitMesh, a: Vector3, b: Vector3, sag: float = 0.35) -> void:
	var segments: int = 6
	var previous: Vector3 = a
	for step: int in range(1, segments + 1):
		var t: float = float(step) / float(segments)
		var p: Vector3 = a.lerp(b, t) - Vector3(0, sag * 4.0 * t * (1.0 - t), 0)
		mesh.tube("rope", previous, p, 0.045, 5, false)
		previous = p


static func _torch(mesh: KitMesh, pos: Vector3, lights: Array[Dictionary], scale_value: float = 1.0) -> void:
	mesh.lathe("brass", pos, [Vector2(0.16 * scale_value, 0.0), Vector2(0.3 * scale_value, 0.26 * scale_value), Vector2(0.26 * scale_value, 0.36 * scale_value)], 8, 1.0, true, false)
	mesh.blob("glow", pos + Vector3(0, 0.62 * scale_value, 0), Vector3(0.22, 0.42, 0.22) * scale_value, 4, 7, 1.0)
	lights.append({"pos": pos + Vector3(0, 0.7 * scale_value, 0), "color": FLAME, "range": 7.0 * scale_value, "energy": 1.6, "kind": "lantern"})


static func _arch_ring(mesh: KitMesh, slot: String, center: Vector3, radius: float, thickness: float, depth: float, segments: int = 12) -> void:
	for step: int in range(segments):
		var a0: float = PI * float(step) / float(segments)
		var a1: float = PI * float(step + 1) / float(segments)
		var p0: Vector3 = center + Vector3(cos(a0) * radius, sin(a0) * radius, 0.0)
		var p1: Vector3 = center + Vector3(cos(a1) * radius, sin(a1) * radius, 0.0)
		var mid: Vector3 = (p0 + p1) * 0.5
		var along: Vector3 = (p1 - p0)
		var basis: Basis = Basis(Vector3(0, 0, 1), atan2(along.y, along.x))
		mesh.box(slot, mid, Vector3(along.length() + thickness * 0.3, thickness, depth), basis, 0.03)


# ---- The Wheel (Mill Fields): a colossal timber wheel between stone piers, a brass axle, banner posts and a little brick mill house ------------------------


static func _wheel(root: Node3D, mesh: KitMesh, size: Vector3, circles: Array[Vector3]) -> void:
	var radius: float = size.y * 0.5 - 0.9
	var axle_y: float = radius + 0.8
	var half_d: float = size.z * 0.5
	var rim_z: float = half_d * 0.52
	# stone piers under the axle ends and the timber A-frames on them
	for side: float in [-1.0, 1.0]:
		var z: float = side * (half_d * 0.72)
		mesh.box("stone", Vector3(0, 1.6, z), Vector3(3.0, 3.2, 2.2), Basis.IDENTITY, 0.08, 0.7)
		mesh.box("cream_stone", Vector3(0, 3.35, z), Vector3(3.3, 0.3, 2.5), Basis.IDENTITY, 0.04)
		for lean: float in [-1.0, 1.0]:
			mesh.tube("bleach_dark", Vector3(lean * 1.2, 3.4, z), Vector3(lean * 0.45, axle_y, z), 0.24, 7, true)
		mesh.tube("bleach_dark", Vector3(-1.3, 3.5, z), Vector3(1.3, 3.5, z), 0.16, 6, true)
		circles.append(Vector3(0.0, z, 1.7))
	mesh.tube("brass", Vector3(0, axle_y, -half_d * 0.95), Vector3(0, axle_y, half_d * 0.95), 0.42, 10, true)
	# the spinner: two rims, slats between them, spokes, a brass hub
	var spinner: Node3D = Node3D.new()
	spinner.name = "Spinner"
	spinner.position = Vector3(0, axle_y, 0)
	var wheel: KitMesh = KitMesh.new()
	_materials(wheel)
	var segments: int = 30
	for side: float in [-1.0, 1.0]:
		var z: float = side * rim_z
		var previous: Vector3 = Vector3(radius, 0.0, z)
		for step: int in range(1, segments + 1):
			var a: float = TAU * float(step) / float(segments)
			var point: Vector3 = Vector3(cos(a) * radius, sin(a) * radius, z)
			var mid: Vector3 = (previous + point) * 0.5
			var along: Vector3 = point - previous
			wheel.box("bleach", mid, Vector3(along.length() + 0.1, 0.55, 0.34), Basis(Vector3(0, 0, 1), atan2(along.y, along.x)), 0.03)
			if step % 5 == 0:
				wheel.box("gold", mid + mid.normalized() * 0.0, Vector3(0.22, 0.6, 0.4), Basis(Vector3(0, 0, 1), atan2(along.y, along.x)), 0.02)
			previous = point
		for spoke: int in range(8):
			var a: float = TAU * float(spoke) / 8.0 + 0.2
			wheel.tube("bleach_dark", Vector3(0, 0, z), Vector3(cos(a) * (radius - 0.2), sin(a) * (radius - 0.2), z), 0.17, 6, true)
	for slat: int in range(segments):
		var a: float = TAU * float(slat) / float(segments) + 0.1
		var at: Vector3 = Vector3(cos(a) * (radius - 0.05), sin(a) * (radius - 0.05), 0)
		wheel.box("bleach_dark" if slat % 2 == 0 else "bleach", at, Vector3(0.5, 0.14, rim_z * 2.0 + 0.3), Basis(Vector3(0, 0, 1), a), 0.02)
	wheel.tube("brass", Vector3(0, 0, -rim_z - 0.5), Vector3(0, 0, rim_z + 0.5), 0.9, 12, true)
	wheel.blob("gold", Vector3(0, 0, rim_z + 0.6), Vector3(0.55, 0.55, 0.3), 4, 10, 1.0)
	var wheel_body: MeshInstance3D = wheel.instance("Wheel")
	wheel_body.set_meta(PaintedClasses.META_NO_PAINT, true)
	wheel_body.set_meta("no_occlusion_fade", true)
	spinner.add_child(wheel_body)
	root.add_child(spinner)
	root.set_meta("spinner", spinner)
	root.set_meta("spin_speed", 0.28)
	# banner posts flanking the wheel, red pennants on top
	for side: float in [-1.0, 1.0]:
		var base: Vector3 = Vector3(side * (size.x * 0.5 - 0.5), 0.0, half_d * 0.6)
		_post(mesh, base, size.y * 0.72, 0.2)
		_card(mesh, "GAIN-SHEET-BANNERS-06" if side < 0.0 else "GAIN-SHEET-BANNERS-02", base + Vector3(side * -0.1, size.y * 0.68, 0.22), 2.8, Vector3(0, 0, 1))
		mesh.tri("red", [base + Vector3(0, size.y * 0.72, 0), base + Vector3(side * -1.6, size.y * 0.72 - 0.25, 0.1), base + Vector3(0, size.y * 0.72 - 0.5, 0)], Vector3(0, 0, 1))
		circles.append(Vector3(base.x, base.z, 0.35))
	# the little brick mill house at the side, its gears peeking out
	var house_x: float = size.x * 0.5 - 2.0
	var house_z: float = -half_d * 0.5 - 2.2
	mesh.box("stone", Vector3(house_x, 0.3, house_z), Vector3(4.6, 0.6, 4.6), Basis.IDENTITY, 0.05, 0.7)
	mesh.box("brick", Vector3(house_x, 2.4, house_z), Vector3(4.2, 3.6, 4.2), Basis.IDENTITY, 0.04, 0.75)
	mesh.box("bleach_dark", Vector3(house_x, 4.3, house_z), Vector3(4.6, 0.26, 4.6), Basis.IDENTITY, 0.02)
	for step: int in range(5):
		var t: float = float(step) / 5.0
		mesh.box("roof", Vector3(house_x, 4.45 + t * 2.4, house_z), Vector3(4.8 - t * 4.2, 0.5, 4.9), Basis.IDENTITY, 0.03)
	_card(mesh, "GAIN-SHEET-DOORS-03", Vector3(house_x, 0.6, house_z + 2.16), 2.4, Vector3(0, 0, 1))
	_card(mesh, "GAIN-SHEET-WINDOWS-02", Vector3(house_x + 2.14, 1.8, house_z), 1.5, Vector3(1, 0, 0))
	mesh.tube("brass", Vector3(house_x - 2.1, 1.9, house_z), Vector3(house_x - 0.3, 1.9, house_z), 0.35, 8, true)
	circles.append(Vector3(house_x, house_z, 2.4))


# ---- The Champions Arch (Proving Grounds): brick pillars in timber frames, a brick span with a laurel shield, a golden barbell on top ----------------------------


static func _champions_arch(mesh: KitMesh, size: Vector3, circles: Array[Vector3]) -> void:
	var pillar_w: float = size.x * 0.19
	var pillar_h: float = size.y * 0.68
	var span_top: float = size.y * 0.84
	var depth: float = size.z
	for side: float in [-1.0, 1.0]:
		var x: float = side * (size.x * 0.5 - pillar_w * 0.5)
		mesh.box("stone", Vector3(x, 0.45, 0), Vector3(pillar_w + 0.9, 0.9, depth + 0.9), Basis.IDENTITY, 0.08, 0.7)
		mesh.box("brick", Vector3(x, pillar_h * 0.5 + 0.9, 0), Vector3(pillar_w, pillar_h, depth), Basis.IDENTITY, 0.04, 0.75)
		for cx: float in [-1.0, 1.0]:
			for cz: float in [-1.0, 1.0]:
				mesh.tube("bleach_dark", Vector3(x + cx * pillar_w * 0.5, 0.9, cz * depth * 0.5), Vector3(x + cx * pillar_w * 0.5, pillar_h + 1.0, cz * depth * 0.5), 0.16, 6, true)
		mesh.box("bleach_dark", Vector3(x, pillar_h * 0.5 + 0.9, depth * 0.5 + 0.05), Vector3(pillar_w + 0.1, 0.18, 0.1), Basis(Vector3(0, 0, 1), 0.6), 0.0)
		mesh.box("bleach_dark", Vector3(x, pillar_h * 0.5 + 0.9, depth * 0.5 + 0.05), Vector3(pillar_w + 0.1, 0.18, 0.1), Basis(Vector3(0, 0, 1), -0.6), 0.0)
		mesh.box("brass", Vector3(x, pillar_h + 1.05, 0), Vector3(pillar_w + 0.4, 0.3, depth + 0.4), Basis.IDENTITY, 0.03)
		mesh.lathe("gold", Vector3(x, pillar_h + 1.2, 0), [Vector2(0.4, 0.0), Vector2(0.0, 1.3)], 6, 1.0, true, false)
		mesh.tube("bleach_dark", Vector3(x + side * (pillar_w * 0.5 + 1.4), 0.5, 0), Vector3(x + side * 0.2, pillar_h * 0.55, 0), 0.14, 6, true)
		_card(mesh, "GAIN-SHEET-BANNERS-02", Vector3(x, pillar_h + 0.5, depth * 0.5 + 0.12), pillar_h * 0.62, Vector3(0, 0, 1))
		circles.append(Vector3(x, 0.0, maxf(pillar_w, depth) * 0.5 + 0.3))
	var span_y0: float = pillar_h * 0.78 + 0.9
	mesh.box("brick", Vector3(0, (span_y0 + span_top) * 0.5, 0), Vector3(size.x - pillar_w * 2.0 + 0.2, span_top - span_y0, depth), Basis.IDENTITY, 0.04, 0.9)
	mesh.box("bleach_dark", Vector3(0, span_top + 0.15, 0), Vector3(size.x + 0.3, 0.3, depth + 0.3), Basis.IDENTITY, 0.03)
	mesh.box("bleach_dark", Vector3(0, span_y0 - 0.1, 0), Vector3(size.x - pillar_w * 2.0 + 0.3, 0.26, depth + 0.3), Basis.IDENTITY, 0.03)
	var arch_r: float = (size.x - pillar_w * 2.0) * 0.5 + 0.1
	_arch_ring(mesh, "cream_stone", Vector3(0, span_y0 - arch_r * 0.42, 0), arch_r * 0.98, 0.5, depth + 0.2, 10)
	# the shield with laurels on the span front
	mesh.box("gold", Vector3(0, (span_y0 + span_top) * 0.5, depth * 0.5 + 0.06), Vector3(1.9, 1.7, 0.08), Basis.IDENTITY, 0.0)
	mesh.box("red", Vector3(0, (span_y0 + span_top) * 0.5, depth * 0.5 + 0.1), Vector3(1.5, 1.3, 0.06), Basis.IDENTITY, 0.0)
	for side: float in [-1.0, 1.0]:
		mesh.blob("gold", Vector3(side * 1.5, (span_y0 + span_top) * 0.5, depth * 0.5 + 0.08), Vector3(0.35, 0.6, 0.06), 3, 6, 1.0)
	# the golden barbell on the top beam
	var bar_y: float = span_top + 0.3 + size.y * 0.09
	mesh.tube("gold", Vector3(-size.x * 0.4, bar_y, 0), Vector3(size.x * 0.4, bar_y, 0), 0.16, 8, true)
	for side: float in [-1.0, 1.0]:
		for plate: int in range(2):
			var x: float = side * (size.x * 0.4 - 0.55 - float(plate) * 0.5)
			var r: float = size.y * (0.1 - float(plate) * 0.02)
			mesh.tube("gold", Vector3(x - 0.2, bar_y, 0), Vector3(x + 0.2, bar_y, 0), r, 12, true)
	for side: float in [-1.0, 1.0]:
		mesh.box("gold", Vector3(side * size.x * 0.15, span_top + 0.3 + size.y * 0.045, 0), Vector3(0.3, size.y * 0.09, 0.3), Basis.IDENTITY, 0.02)
	_rope(mesh, Vector3(-size.x * 0.5 + pillar_w * 0.5, pillar_h + 1.3, depth * 0.5 + 0.2), Vector3(size.x * 0.5 - pillar_w * 0.5, pillar_h + 1.3, depth * 0.5 + 0.2), 0.6)


# ---- Mount Swolympus (Trailhead): a rock mountain with grassy ledges, pines, a switchback stair with banner posts and a cloud-crowned temple ---------------------


static func _swolympus(root: Node3D, mesh: KitMesh, size: Vector3, circles: Array[Vector3], lights: Array[Dictionary]) -> void:
	var rx: float = size.x * 0.5
	var squash: float = size.z / size.x
	var profile: Array[Vector2] = []
	var rows: Array[Vector2] = [Vector2(1.0, 0.0), Vector2(0.93, 0.1), Vector2(0.8, 0.24), Vector2(0.66, 0.4), Vector2(0.5, 0.56), Vector2(0.36, 0.72), Vector2(0.24, 0.86), Vector2(0.13, 0.95), Vector2(0.0, 1.0)]
	for row: Vector2 in rows:
		profile.append(Vector2(row.x * rx, row.y * size.y * 0.82))
	var mountain: KitMesh = KitMesh.new()
	_materials(mountain)
	# pale limestone like the concept: the kit fieldstone at a mountain-sized tile (one stone course per 7 m), cream in the sun, cool in the hollows
	mountain.set_material("rock", _big_stone(Color(1.0, 0.97, 0.9), 12.0))
	mountain.set_material("rock_dark", _big_stone(Color(0.72, 0.74, 0.84), 10.0))
	mountain.set_material("rock_light", _big_stone(Color(1.0, 1.0, 0.98), 13.0))
	mountain.lathe("rock", Vector3.ZERO, profile, 18, 0.8, true, true)
	# big outcrops and shoulders break the cone; grassy ledges sit in the hollows between them; a grass skirt melts the foot into the meadow
	for index: int in range(11):
		var a: float = float(index) * 1.9 + 0.7
		var t: float = 0.05 + 0.085 * float(index % 7)
		var r: float = rx * (1.0 - t * 1.05)
		var y: float = size.y * 0.82 * t + 0.6
		var lump: Vector3 = Vector3(rx * (0.2 + 0.06 * float(index % 3)), rx * (0.16 + 0.05 * float(index % 2)), rx * 0.19)
		mountain.blob("rock_light" if index % 3 == 0 else ("rock_dark" if index % 3 == 1 else "rock"), Vector3(cos(a) * r, y, sin(a) * r), lump, 4, 9, 0.85)
	for index: int in range(8):
		var a: float = float(index) * 2.3 + 0.4
		var t: float = 0.12 + 0.09 * float(index % 5)
		var r: float = rx * (1.0 - t * 1.1)
		var y: float = size.y * 0.82 * t + 0.9
		mountain.blob("grass", Vector3(cos(a) * r, y, sin(a) * r), Vector3(rx * 0.26, 1.3, rx * 0.24), 3, 8, 1.0)
	mountain.lathe("grass", Vector3(0, -0.1, 0), [Vector2(rx * 1.12, 0.0), Vector2(rx * 1.0, 0.9), Vector2(rx * 0.9, 1.4)], 18, 1.0, false, false)
	var mountain_body: MeshInstance3D = mountain.instance("Mountain")
	mountain_body.set_meta(PaintedClasses.META_NO_PAINT, true)
	mountain_body.set_meta("no_occlusion_fade", true)
	mountain_body.scale = Vector3(1.0, 1.0, squash)
	root.add_child(mountain_body)
	# the switchback stair up the front: four legs of cream stone steps, a banner post at every turn
	var legs: Array[Vector3] = [Vector3(-rx * 0.55, 0.3, rx * 0.86 * squash), Vector3(rx * 0.3, size.y * 0.2, rx * 0.68 * squash), Vector3(-rx * 0.22, size.y * 0.42, rx * 0.46 * squash), Vector3(rx * 0.12, size.y * 0.62, rx * 0.28 * squash), Vector3(0.0, size.y * 0.8, rx * 0.1 * squash)]
	for leg: int in range(legs.size() - 1):
		var a: Vector3 = legs[leg]
		var b: Vector3 = legs[leg + 1]
		var steps: int = 9
		for step: int in range(steps):
			var p: Vector3 = a.lerp(b, float(step) / float(steps - 1))
			mesh.box("cream_stone", p, Vector3(2.6, 0.5, 1.6), Basis(Vector3.UP, atan2(b.x - a.x, b.z - a.z)), 0.04)
		_post(mesh, b + Vector3(1.3, 0.2, 0.5), 3.2, 0.14, "cream_stone", false)
		_torch(mesh, b + Vector3(1.3, 3.4, 0.5), lights, 0.8)
		_card(mesh, "GAIN-SHEET-BANNERS-%02d" % [2 + leg % 2 * 3], b + Vector3(1.3, 2.9, 0.65), 1.9, Vector3(0, 0, 1))
	# the temple on the summit: columns, a slab and a golden barbell, wreathed in cloud
	var top: float = size.y * 0.82
	mesh.lathe("cream_stone", Vector3(0, top - 0.4, 0), [Vector2(rx * 0.16, 0.0), Vector2(rx * 0.16, 1.0)], 10, 1.0, false, true)
	for column: int in range(4):
		var a: float = float(column) * PI * 0.5 + PI * 0.25
		var p: Vector3 = Vector3(cos(a) * rx * 0.11, top + 0.6, sin(a) * rx * 0.11)
		mesh.tube("cream_stone", p, p + Vector3(0, size.y * 0.1, 0), 0.3, 8, true)
	mesh.box("cream_stone", Vector3(0, top + 0.6 + size.y * 0.1, 0), Vector3(rx * 0.3, 0.4, rx * 0.3), Basis.IDENTITY, 0.04)
	var bar_y: float = top + 1.0 + size.y * 0.1 + 1.0
	mesh.tube("gold", Vector3(-rx * 0.1, bar_y, 0), Vector3(rx * 0.1, bar_y, 0), 0.14, 8, true)
	for side: float in [-1.0, 1.0]:
		mesh.tube("gold", Vector3(side * rx * 0.1 - 0.25, bar_y, 0), Vector3(side * rx * 0.1 + 0.25, bar_y, 0), 0.9, 10, true)
	var clouds: Node3D = Node3D.new()
	clouds.name = "SummitClouds"
	root.add_child(clouds)
	for puff: int in range(7):
		var a: float = float(puff) * 0.9
		var cloud: MeshInstance3D = MeshInstance3D.new()
		var sphere: SphereMesh = SphereMesh.new()
		sphere.radius = rx * 0.11 + float(puff % 3) * 0.6
		sphere.height = sphere.radius * 1.4
		sphere.radial_segments = 8
		sphere.rings = 4
		cloud.mesh = sphere
		cloud.material_override = GainlandsMaterials.translucent(Color(1, 1, 1), 0.82, 0.25)
		cloud.position = Vector3(cos(a) * rx * 0.26, top - 0.2 + float(puff % 2) * 1.2, sin(a) * rx * 0.26 * squash)
		cloud.set_meta("no_occlusion_fade", true)
		clouds.add_child(cloud)
	# pines round the foot and on the ledges
	for index: int in range(10):
		var a: float = float(index) * 0.63 + 0.3
		var r: float = rx * (0.9 + 0.12 * float(index % 3))
		_tree_card(root, "GAIN-TREE-PINE", Vector3(cos(a) * r, 0.0, sin(a) * r * squash), 5.5 + float(index % 3) * 0.8)
	for index: int in range(5):
		var a: float = float(index) * 1.25 + 0.9
		var t: float = 0.3 + 0.1 * float(index)
		_tree_card(root, "GAIN-TREE-PINE", Vector3(cos(a) * rx * (1.0 - t), size.y * 0.82 * t * 0.92, sin(a) * rx * (1.0 - t) * squash), 3.4)
	circles.append(Vector3(0.0, 0.0, rx * 0.48))
	for side: float in [-1.0, 1.0]:
		circles.append(Vector3(side * rx * 0.42, 0.0, rx * 0.3))
	circles.append(Vector3(0.0, -rx * 0.3 * squash, rx * 0.4))


static func _big_stone(tint: Color, tile: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = EnvKit.material("ENV-WALL-FOUNDATION", false, tint).duplicate() as StandardMaterial3D
	material.uv1_scale = Vector3(1.0 / tile, 1.0 / (tile * 0.5), 1.0)
	material.normal_scale = 0.4
	return material


# ---- The Trailhead Gate: cream stone towers with torches and bells, a stone arch, banners and rope posts ---------------------------------------------------------


static func _trailhead_gate(mesh: KitMesh, size: Vector3, circles: Array[Vector3], lights: Array[Dictionary]) -> void:
	var tower_w: float = size.x * 0.2
	var tower_h: float = size.y * 0.8
	var depth: float = size.z
	for side: float in [-1.0, 1.0]:
		var x: float = side * (size.x * 0.5 - tower_w * 0.5)
		mesh.box("cream_stone", Vector3(x, 0.3, 0), Vector3(tower_w + 0.8, 0.6, depth + 0.8), Basis.IDENTITY, 0.06, 0.7)
		mesh.box("cream_stone", Vector3(x, tower_h * 0.5 + 0.6, 0), Vector3(tower_w, tower_h, depth), Basis.IDENTITY, 0.05, 0.78)
		mesh.box("cream_stone", Vector3(x, tower_h + 0.75, 0), Vector3(tower_w + 0.4, 0.3, depth + 0.4), Basis.IDENTITY, 0.03)
		for crenel: int in range(3):
			mesh.box("cream_stone", Vector3(x - tower_w * 0.35 + tower_w * 0.35 * float(crenel), tower_h + 1.15, 0), Vector3(tower_w * 0.22, 0.5, depth * 0.8), Basis.IDENTITY, 0.02)
		_torch(mesh, Vector3(x, tower_h + 1.4, 0), lights, 1.1)
		mesh.tube("brass", Vector3(x - 0.3, tower_h * 0.62, depth * 0.5 + 0.1), Vector3(x + 0.3, tower_h * 0.62, depth * 0.5 + 0.1), 0.06, 5, true)
		_card(mesh, "GAIN-SHEET-BANNERS-05" if side < 0.0 else "GAIN-SHEET-BANNERS-02", Vector3(x, tower_h * 0.62 - 0.05, depth * 0.5 + 0.12), tower_h * 0.52, Vector3(0, 0, 1))
		# a side bracket with a small torch and a hanging banner / bell
		var out: Vector3 = Vector3(x + side * (tower_w * 0.5 + 0.9), tower_h * 0.62, 0)
		mesh.box("bleach_dark", Vector3(x + side * (tower_w * 0.5 + 0.5), tower_h * 0.62, 0), Vector3(1.1, 0.3, 0.3), Basis.IDENTITY, 0.02)
		_torch(mesh, out + Vector3(0, 0.15, 0), lights, 0.6)
		if side > 0.0:
			mesh.tube("rope", out, out - Vector3(0, 0.9, 0), 0.03, 4, false)
			mesh.lathe("gold", out - Vector3(0, 1.9, 0), [Vector2(0.42, 0.0), Vector2(0.36, 0.3), Vector2(0.22, 0.8), Vector2(0.12, 1.0)], 10, 1.0, true, true)
		else:
			_card(mesh, "GAIN-SHEET-BANNERS-04", out - Vector3(0, 0.15, 0), 1.6, Vector3(0, 0, 1))
		circles.append(Vector3(x, 0.0, maxf(tower_w, depth) * 0.5 + 0.3))
		# rope posts at the foot
		for post: int in range(3):
			var p: Vector3 = Vector3(x + side * (tower_w * 0.5 + 1.0 + float(post) * 1.3), 0.0, depth * 0.5 + 0.5)
			mesh.tube("bleach_dark", p, p + Vector3(0, 1.0, 0), 0.12, 6, true)
			if post > 0:
				_rope(mesh, p + Vector3(0, 0.85, 0), p + Vector3(side * -1.3, 0.85, 0), 0.25)
	var span_y0: float = tower_h * 0.74 + 0.6
	var span_top: float = size.y * 0.92
	mesh.box("cream_stone", Vector3(0, (span_y0 + span_top) * 0.5, 0), Vector3(size.x - tower_w * 2.0 + 0.2, span_top - span_y0, depth * 0.9), Basis.IDENTITY, 0.05, 0.9)
	var arch_r: float = (size.x - tower_w * 2.0) * 0.5 + 0.1
	_arch_ring(mesh, "cream_stone", Vector3(0, span_y0 - arch_r * 0.5, 0), arch_r * 0.96, 0.55, depth + 0.1, 10)
	mesh.box("cream_stone", Vector3(0, span_top + 0.35, 0), Vector3(size.x * 0.46, 0.7, depth * 0.8), Basis.IDENTITY, 0.08)
	mesh.box("brass", Vector3(0, (span_y0 + span_top) * 0.5, depth * 0.45 + 0.03), Vector3(size.x * 0.3, (span_top - span_y0) * 0.6, 0.06), Basis.IDENTITY, 0.0)
	mesh.box("gold", Vector3(0, span_top + 0.35, depth * 0.4 + 0.04), Vector3(0.4, 0.4, 0.06), Basis(Vector3(0, 0, 1), PI * 0.25), 0.0)


# ---- The Sky Tree (Sky Garden): a rock plinth with a grass top, a gnarled trunk and roots, the painted canopy card, hanging vines ----------------------------------


static func _sky_tree(root: Node3D, mesh: KitMesh, size: Vector3, circles: Array[Vector3]) -> void:
	var plinth_r: float = minf(size.x, size.z) * 0.32
	mesh.lathe("rock", Vector3(0, -0.2, 0), [Vector2(plinth_r * 0.8, 0.0), Vector2(plinth_r * 1.02, 0.7), Vector2(plinth_r, 1.1)], 14, 0.8, true, false)
	mesh.lathe("grass", Vector3(0, 1.1, 0), [Vector2(plinth_r + 0.1, -0.1), Vector2(plinth_r * 0.9, 0.3), Vector2(0.0, 0.45)], 14, 1.0, false, true)
	for index: int in range(6):
		var a: float = float(index) * 1.05 + 0.3
		mesh.blob("rock", Vector3(cos(a) * plinth_r * 0.9, 0.4, sin(a) * plinth_r * 0.9), Vector3(1.0, 0.7, 0.9), 3, 7, 0.9)
		mesh.blob("leaves", Vector3(cos(a + 0.5) * plinth_r * 0.72, 1.6, sin(a + 0.5) * plinth_r * 0.72), Vector3(1.0, 0.6, 1.0), 3, 7, 1.0)
	var trunk_h: float = size.y * 0.42
	mesh.lathe("bark", Vector3(0, 1.3, 0), [Vector2(size.x * 0.11, 0.0), Vector2(size.x * 0.075, trunk_h * 0.45), Vector2(size.x * 0.06, trunk_h)], 10, 0.85, false, true)
	for index: int in range(5):
		var a: float = float(index) * 1.26 + 0.6
		var foot: Vector3 = Vector3(cos(a) * size.x * 0.2, 1.35, sin(a) * size.z * 0.2)
		mesh.tube("bark", Vector3(cos(a) * size.x * 0.07, 2.4, sin(a) * size.z * 0.07), foot, 0.42, 6, true)
		mesh.tube("bark", Vector3(cos(a) * size.x * 0.04, 1.3 + trunk_h * 0.92, sin(a) * size.z * 0.04), Vector3(cos(a) * size.x * 0.13, 1.3 + trunk_h * 1.2, sin(a) * size.z * 0.13), 0.24, 6, true)
	# the painted canopy card carries the golden fruit and is the whole crown
	var card_h: float = size.y - 1.4
	_tree_card(root, "GAIN-TREE-SKY", Vector3(0, 1.3, 0), card_h)
	# (no painted-leaf blobs round the card: they fought the painted canopy; the card alone reads as the tree from every camera)
	for index: int in range(8):
		var a: float = float(index) * 0.78
		var from: Vector3 = Vector3(cos(a) * plinth_r * 0.95, 1.0, sin(a) * plinth_r * 0.95)
		mesh.tube("leaves", from, from - Vector3(0, 1.0 + float(index % 3) * 0.5, 0), 0.08, 4, true)
	circles.append(Vector3(0.0, 0.0, size.x * 0.17))
	root.set_meta("plinth_radius", plinth_r)


# ---- The Swole Station (the hub): a stone platform ringed in brass, banner posts with lanterns, a protein stall under a canvas roof, a punching bag ----------------


static func _swole_station(root: Node3D, mesh: KitMesh, size: Vector3, circles: Array[Vector3], lights: Array[Dictionary]) -> void:
	var platform_r: float = size.z * 0.42
	mesh.lathe("cream_stone", Vector3(0, 0, -0.4), [Vector2(platform_r + 0.3, 0.0), Vector2(platform_r, 0.3)], 18, 0.9, false, true)
	mesh.lathe("brass", Vector3(0, 0.3, -0.4), [Vector2(platform_r * 0.62, 0.0), Vector2(platform_r * 0.62, 0.04)], 18, 1.0, false, true)
	mesh.lathe("gold_glow", Vector3(0, 0.33, -0.4), [Vector2(platform_r * 0.3, 0.0), Vector2(platform_r * 0.3, 0.02)], 14, 1.0, false, true)
	for step: int in range(2):
		mesh.box("cream_stone", Vector3(0, 0.1 + 0.1 * float(step), platform_r - 0.4 + 0.9 - 0.45 * float(step)), Vector3(3.2, 0.2, 0.9), Basis.IDENTITY, 0.03)
	var post_h: float = size.y * 0.9
	var posts: Array[Vector3] = [Vector3(-platform_r * 0.95, 0, -platform_r * 0.95 - 0.4), Vector3(platform_r * 0.95, 0, -platform_r * 0.95 - 0.4), Vector3(-platform_r * 1.0, 0, platform_r * 0.5 - 0.4), Vector3(platform_r * 1.0, 0, platform_r * 0.5 - 0.4)]
	for index: int in range(posts.size()):
		var p: Vector3 = posts[index]
		mesh.box("bleach_dark", p + Vector3(0, post_h * 0.5, 0), Vector3(0.42, post_h, 0.42), Basis.IDENTITY, 0.04, 0.8)
		mesh.box("brass", p + Vector3(0, 0.6, 0), Vector3(0.52, 0.2, 0.52), Basis.IDENTITY, 0.02)
		mesh.box("brass", p + Vector3(0, post_h - 0.6, 0), Vector3(0.52, 0.2, 0.52), Basis.IDENTITY, 0.02)
		mesh.blob("gold", p + Vector3(0, post_h + 0.3, 0), Vector3(0.36, 0.36, 0.36), 4, 8, 1.0)
		if index < 2:
			_card(mesh, "GAIN-SHEET-BANNERS-02" if index == 0 else "GAIN-SHEET-BANNERS-06", p + Vector3(0, post_h - 0.5, 0.26), post_h * 0.5, Vector3(0, 0, 1))
		else:
			var lantern: Vector3 = p + Vector3(0, post_h * 0.7, 0.5)
			mesh.box("dark", p + Vector3(0, post_h * 0.7 + 0.2, 0.3), Vector3(0.08, 0.08, 0.6), Basis.IDENTITY, 0.0)
			mesh.box("glow", lantern, Vector3(0.3, 0.42, 0.3), Basis.IDENTITY, 0.03)
			lights.append({"pos": lantern + Vector3(0, 0, 0.3), "color": FLAME, "range": 7.0, "energy": 1.4, "kind": "lantern"})
		circles.append(Vector3(p.x, p.z, 0.4))
	_rope(mesh, posts[0] + Vector3(0, post_h - 0.3, 0), posts[1] + Vector3(0, post_h - 0.3, 0), 0.5)
	for flag: int in range(7):
		var t: float = (float(flag) + 0.5) / 7.0
		var at: Vector3 = posts[0].lerp(posts[1], t) + Vector3(0, post_h - 0.3 - 0.5 * 4.0 * t * (1.0 - t), 0)
		mesh.tri("red" if flag % 2 == 0 else "gold", [at + Vector3(-0.25, 0, 0), at + Vector3(0.25, 0, 0), at + Vector3(0, -0.5, 0)], Vector3(0, 0, 1))
	# the protein stall on the right: a plank counter, shakers, a striped canvas roof on two posts
	var stall_x: float = size.x * 0.5 - 1.6
	mesh.box("bleach", Vector3(stall_x, 0.55, 0.2), Vector3(2.8, 1.1, 1.2), Basis.IDENTITY, 0.04, 0.8)
	mesh.box("bleach_dark", Vector3(stall_x, 1.14, 0.2), Vector3(3.0, 0.1, 1.4), Basis.IDENTITY, 0.02)
	mesh.box("red", Vector3(stall_x, 0.9, 0.82), Vector3(2.4, 0.5, 0.04), Basis.IDENTITY, 0.0)
	for shaker: int in range(4):
		var color: Color = [Color("4fa2e8"), GOLD, Color("e85fa0"), Color("5fcf6a")][shaker]
		mesh.lathe("flat", Vector3(stall_x - 1.0 + 0.65 * float(shaker), 1.2, 0.1), [Vector2(0.14, 0.0), Vector2(0.16, 0.3), Vector2(0.1, 0.42)], 7, 1.0, false, true, color)
	for side: float in [-1.0, 1.0]:
		mesh.tube("bleach_dark", Vector3(stall_x + side * 1.45, 0, -0.4), Vector3(stall_x + side * 1.45, 2.7, -0.4), 0.1, 6, true)
	mesh.box("canvas", Vector3(stall_x, 2.75, 0.1), Vector3(3.4, 0.14, 2.2), Basis(Vector3(1, 0, 0), -0.25), 0.02)
	circles.append(Vector3(stall_x, 0.2, 1.4))
	# the punching bag on the left and the gym gear at its foot
	var bag_x: float = -size.x * 0.5 + 1.2
	mesh.tube("bleach_dark", Vector3(bag_x, 0, -0.6), Vector3(bag_x, 3.0, -0.6), 0.12, 6, true)
	mesh.box("bleach_dark", Vector3(bag_x + 0.5, 3.0, -0.6), Vector3(1.1, 0.1, 0.1), Basis.IDENTITY, 0.0)
	mesh.tube("dark", Vector3(bag_x + 0.95, 3.0, -0.6), Vector3(bag_x + 0.95, 2.5, -0.6), 0.03, 4, false)
	mesh.lathe("red", Vector3(bag_x + 0.95, 0.9, -0.6), [Vector2(0.3, 0.0), Vector2(0.34, 0.9), Vector2(0.3, 1.6)], 10, 1.0, true, true)
	mesh.lathe("gold", Vector3(bag_x + 0.95, 1.1, -0.6), [Vector2(0.35, 0.0), Vector2(0.35, 0.25)], 10, 1.0, false, false)
	circles.append(Vector3(bag_x + 0.6, -0.6, 0.7))
	_tree_card(root, "GAIN-PROP-KETTLEBELL", Vector3(bag_x + 0.4, 0.0, 1.2), 0.9)
	_tree_card(root, "GAIN-PLANT-SUNFLOWER", Vector3(stall_x + 1.9, 0.0, 1.0), 1.9)
	_tree_card(root, "GAIN-PLANT-SUNFLOWER", Vector3(bag_x - 0.6, 0.0, -1.6), 1.7)


# ---- The bridge to town (GC-8): a sturdy timber-and-rope bridge at storybook scale, built from the kit's bleached plank, brass and rope ----------------------------


## A walkable bridge `length` metres long and `width` wide, origin at the near end on the ground, running along +z, its deck arching `rise` metres in the middle from a
## base height of `base_y`. Chunky planks on two beams, rope rails on posts with gold finials, timber pillars down into the water every few metres, a tall gate with a
## cross beam, lanterns and a hanging kit banner at the near end, and a landing with two banner posts at the far end. Meta "circles" (local x, z, radius) are the posts
## that block; the deck itself is the layout's walkable surface. Shared with the town side (TownConnectors) so both halves match.
static func rope_bridge(length: float, width: float, rise: float = 0.5, base_y: float = 0.0) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	_materials(mesh)
	var circles: Array[Vector3] = []
	var root: Node3D = Node3D.new()
	root.name = "Bridge"
	var half: float = width * 0.5
	var deck_y: Callable = func(z: float) -> float: return base_y + rise * sin(PI * clampf(z / length, 0.0, 1.0))
	# planks
	var step: float = 0.56
	var count: int = int(length / step)
	for index: int in range(count):
		var z: float = step * (float(index) + 0.5)
		var slot: String = "bleach_dark" if index % 5 == 2 else "bleach"
		mesh.box(slot, Vector3(0.0, float(deck_y.call(z)) + 0.08, z), Vector3(width, 0.16, step - 0.08), Basis.IDENTITY, 0.02, 0.9)
	# the two beams under the planks and the cross ties
	var segments: int = maxi(4, int(length / 2.5))
	for index: int in range(segments):
		var z0: float = length * float(index) / float(segments)
		var z1: float = length * float(index + 1) / float(segments)
		var mid: float = (z0 + z1) * 0.5
		var y: float = float(deck_y.call(mid)) - 0.18
		var slope: float = float(deck_y.call(z1)) - float(deck_y.call(z0))
		var basis: Basis = Basis(Vector3(1, 0, 0), -atan2(slope, z1 - z0))
		for side: float in [-1.0, 1.0]:
			mesh.box("bleach_dark", Vector3(side * (half - 0.35), y, mid), Vector3(0.34, 0.34, z1 - z0 + 0.1), basis, 0.02)
		mesh.box("bleach_dark", Vector3(0.0, y - 0.05, z0 + 0.3), Vector3(width + 0.5, 0.24, 0.26), Basis.IDENTITY, 0.02)
	# rope rails on posts
	var post_step: float = 2.6
	var posts: int = maxi(2, int(round(length / post_step)))
	var previous: Array[Vector3] = [Vector3.ZERO, Vector3.ZERO]
	for index: int in range(posts + 1):
		var z: float = length * float(index) / float(posts)
		var y: float = float(deck_y.call(z)) + 0.16
		for side_index: int in range(2):
			var side: float = -1.0 if side_index == 0 else 1.0
			var base: Vector3 = Vector3(side * (half - 0.14), y, z)
			_post(mesh, base, 1.3, 0.11, "bleach_dark", true)
			var top: Vector3 = base + Vector3(0, 1.22, 0)
			var low: Vector3 = base + Vector3(0, 0.62, 0)
			if index > 0:
				_rope(mesh, previous[side_index], top, 0.16)
				_rope(mesh, previous[side_index] - Vector3(0, 0.6, 0), low, 0.1)
			previous[side_index] = top
	# pillars down into the water every few metres, braced
	var pillar_step: float = 6.0
	var z_pillar: float = pillar_step * 0.5
	while z_pillar < length - 1.0:
		var top_y: float = float(deck_y.call(z_pillar)) - 0.3
		for side: float in [-1.0, 1.0]:
			mesh.tube("bleach_dark", Vector3(side * (half - 0.4), -2.6, z_pillar), Vector3(side * (half - 0.4), top_y, z_pillar), 0.2, 7, true)
		mesh.box("bleach_dark", Vector3(0.0, top_y - 1.2, z_pillar), Vector3(width - 0.6, 0.18, 0.18), Basis(Vector3(0, 0, 1), 0.0), 0.0)
		z_pillar += pillar_step
	# the gate at the near end: two tall timbers, a cross beam, lanterns, a hanging banner
	var gate_h: float = 4.6
	for side: float in [-1.0, 1.0]:
		var foot: Vector3 = Vector3(side * (half + 0.45), base_y, 0.3)
		mesh.tube("bleach_dark", foot, foot + Vector3(0, gate_h, 0), 0.24, 8, true)
		mesh.box("brass", foot + Vector3(0, 0.25, 0), Vector3(0.7, 0.5, 0.7), Basis.IDENTITY, 0.03)
		mesh.blob("gold", foot + Vector3(0, gate_h + 0.3, 0), Vector3(0.36, 0.36, 0.36), 4, 8, 1.0)
		_torch(mesh, foot + Vector3(side * 0.0, gate_h * 0.7, 0.42), [] as Array[Dictionary], 0.8)
		circles.append(Vector3(foot.x, foot.z, 0.42))
	mesh.box("bleach_dark", Vector3(0.0, base_y + gate_h - 0.3, 0.3), Vector3(width + 1.5, 0.42, 0.42), Basis.IDENTITY, 0.03)
	mesh.box("brass", Vector3(0.0, base_y + gate_h - 0.05, 0.3), Vector3(width * 0.4, 0.18, 0.5), Basis.IDENTITY, 0.0)
	_card(mesh, "GAIN-SHEET-BANNERS-01", Vector3(0.0, base_y + gate_h - 0.52, 0.56), 2.2, Vector3(0, 0, 1))
	# the far landing: a square deck with two banner posts, where the way to town begins
	var landing_y: float = base_y + 0.08
	mesh.box("bleach", Vector3(0.0, landing_y, length + 1.6), Vector3(width + 1.2, 0.18, 3.6), Basis.IDENTITY, 0.02, 0.9)
	mesh.box("bleach_dark", Vector3(0.0, landing_y - 0.2, length + 1.6), Vector3(width + 1.4, 0.26, 3.8), Basis.IDENTITY, 0.02)
	for side: float in [-1.0, 1.0]:
		var foot: Vector3 = Vector3(side * (half + 0.4), landing_y, length + 3.1)
		mesh.tube("bleach_dark", foot, foot + Vector3(0, 3.2, 0), 0.16, 7, true)
		mesh.blob("gold", foot + Vector3(0, 3.4, 0), Vector3(0.26, 0.26, 0.26), 4, 8, 1.0)
		mesh.tube("brass", foot + Vector3(0, 2.9, 0), foot + Vector3(side * -0.9, 2.9, 0), 0.05, 5, true)
		_card(mesh, "GAIN-SHEET-BANNERS-03" if side < 0.0 else "GAIN-SHEET-BANNERS-05", foot + Vector3(side * -0.5, 2.85, 0.08), 1.7, Vector3(0, 0, -1))
		circles.append(Vector3(foot.x, foot.z, 0.3))
		mesh.tube("bleach_dark", Vector3(side * (half + 0.2), -2.6, length + 1.6), Vector3(side * (half + 0.2), landing_y - 0.3, length + 1.6), 0.22, 7, true)
	var body: MeshInstance3D = mesh.instance("Body")
	body.set_meta(PaintedClasses.META_NO_PAINT, true)
	body.set_meta(&"no_occlusion_fade", true)  # the hero walks on it: it must never dissolve under the feet
	body.set_meta(&"no_range_cull", true)
	root.set_meta(&"no_wind", true)
	root.add_child(body)
	root.set_meta("circles", circles)
	root.set_meta("footprint", Vector2(width + 1.5, length + 3.6))
	root.set_meta("height", gate_h + 0.5)
	root.set_meta("kind", "bridge")
	root.set_meta("triangles", mesh.triangle_count())
	return root
