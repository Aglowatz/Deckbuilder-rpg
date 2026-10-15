class_name DnaLandmarks
extends RefCounted
## The four hero landmarks of the D.N.A., modelled after their approved concepts (docs/art/zone_kits/dna/concepts/) and textured with the zone kit
## (data/art/zone_kits/dna.json): the Hall of Final Approvals (the main dungeon, the goal seen from the whole zone and the Executive Approach facade),
## the Filing-cabinet Tower (Cubicle Fields), the Endless Queue (The Queue) and the Records Basement stair. Sizes come from the caller (`spec.size` = w, h, d in
## metres); every model is built to fill that box. Origin on the ground at the centre, front +z. Same contract as `LandmarkKit` / `GainlandsLandmarks`
## (meta circles / footprint / height / lights); `HeroLandmarks` dispatches the DNA-HERO- prefix here.

const IDS: Array[String] = ["DNA-HERO-FINAL-APPROVALS", "DNA-HERO-FILING-TOWER", "DNA-HERO-ENDLESS-QUEUE", "DNA-HERO-RECORDS-STAIR"]
const GREY: Color = Color("6e7470")
const SAGE: Color = Color("9bb59a")
const SLATE: Color = Color("3d4a44")
const PARCHMENT: Color = Color("c9c6b8")
const GHOST: Color = Color("4fbf7a")
const RED: Color = Color("8a2e2e")
const BRASS: Color = Color("b8945a")
const IRON: Color = Color("3a4144")
const CABINET: Color = Color("6b7572")
const CABINET_DARK: Color = Color("4e5856")
const WARM: Color = Color("ffd98a")
const CARD_UVS: Array[Vector2] = [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)]

static var _ghost_material: StandardMaterial3D


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
	var lights: Array[Dictionary] = []
	var root: Node3D = Node3D.new()
	root.name = "Landmark_%s" % id
	match id:
		"DNA-HERO-FINAL-APPROVALS":
			_hall(root, mesh, size, circles, lights)
		"DNA-HERO-FILING-TOWER":
			_filing_tower(root, mesh, size, circles, lights)
		"DNA-HERO-ENDLESS-QUEUE":
			_queue(root, mesh, size, circles, lights)
		"DNA-HERO-RECORDS-STAIR":
			_records_stair(root, mesh, size, circles, lights)
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


## A kit surface when the zone has it, else the flat palette colour (the model still reads before the art is imported).
static func _surface(id: String, fallback: Color, mul: Color = Color.WHITE) -> Material:
	if EnvKit.has(id) and EnvKit.texture(id) != null:
		return EnvKit.material(id, false, mul)
	return EnvKit.flat(fallback * mul, "dna_hero")


static func _materials(mesh: KitMesh) -> void:
	mesh.set_material("grey", _surface("DNA-WALL-GREY", GREY))
	mesh.set_material("grey_dark", _surface("DNA-WALL-GREY", GREY, Color(0.74, 0.76, 0.76)))
	mesh.set_material("grey_light", _surface("DNA-WALL-GREY", GREY, Color(1.12, 1.12, 1.1)))
	mesh.set_material("slate", _surface("DNA-ROOF-SLATE", SLATE))
	mesh.set_material("brass", _surface("DNA-TRIM-BRASS", BRASS))
	mesh.set_material("queue", _surface("DNA-PATH-QUEUE", GREY.lightened(0.1)))
	mesh.set_material("marble", _surface("TEX-DNA-MARBLE", PARCHMENT.darkened(0.15)))
	mesh.set_material("paneling", _surface("TEX-DNA-PANELING", SLATE.lightened(0.1)))
	mesh.set_material("stone", _surface("ENV-WALL-FOUNDATION", GREY.darkened(0.2)))
	mesh.set_material("flat", EnvKit.flat(Color.WHITE, "dna_hero"))
	mesh.alias("dark", "flat", SLATE)
	mesh.alias("iron", "flat", IRON)
	mesh.alias("red", "flat", RED)
	mesh.alias("parchment", "flat", PARCHMENT)
	mesh.alias("gold", "flat", BRASS)
	mesh.alias("cabinet", "flat", CABINET)
	mesh.alias("cabinet_dark", "flat", CABINET_DARK)
	mesh.alias("sage", "flat", SAGE)
	mesh.set_material("glow", EnvKit.glow(GHOST, 2.2))
	mesh.set_material("window_glow", EnvKit.glow(Color("a8ecb0"), 1.25))
	mesh.set_material("warm_glow", EnvKit.glow(WARM, 1.4))
	mesh.set_material("ghost", ghost_material())


## Translucent green ghost citizens (unshaded so the toon pass leaves the alpha alone).
static func ghost_material() -> StandardMaterial3D:
	if _ghost_material == null:
		_ghost_material = StandardMaterial3D.new()
		_ghost_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_ghost_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_ghost_material.albedo_color = Color(0.62, 0.96, 0.74, 0.55)
		_ghost_material.emission_enabled = true
		_ghost_material.emission = Color(0.3, 0.8, 0.5)
		_ghost_material.emission_energy_multiplier = 0.9
		_ghost_material.vertex_color_use_as_albedo = true
		_ghost_material.set_meta(PaintedClasses.META_NO_PAINT, true)
		_ghost_material.set_meta(StyleToon.META_NO_TOON, true)
	return _ghost_material


## A painted cut-out standing upright in the mesh: pivot at `pivot_pos`, `height` metres tall, facing `normal` (horizontal unit vector).
static func _card(mesh: KitMesh, id: String, pivot_pos: Vector3, height: float, normal: Vector3) -> void:
	if not EnvKit.has(id):
		return
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
	if not EnvKit.has(id):
		return
	var card: MeshInstance3D = KitFoliage.card(id, Vector2(height * EnvKit.aspect(id), height), true)
	card.name = "Card_%s" % id
	root.add_child(card)
	card.position = pos


# ---- shared pieces --------------------------------------------------------------------------------------------------------------------------


## An iron street lamp burning a green ghost flame: a post, a lantern cage, the flame, and a light entry.
static func _ghost_lamp(mesh: KitMesh, base: Vector3, lights: Array[Dictionary], height: float = 2.2, scale_value: float = 1.0) -> void:
	var r: float = 0.07 * scale_value
	mesh.lathe("iron", base, [Vector2(r * 2.6, 0.0), Vector2(r * 2.2, 0.12 * scale_value), Vector2(r, 0.16 * scale_value)], 8, 1.0, true, true)
	mesh.tube("iron", base + Vector3(0, 0.15 * scale_value, 0), base + Vector3(0, height, 0), r, 6, true)
	var cage: Vector3 = base + Vector3(0, height + 0.3 * scale_value, 0)
	mesh.box("iron", cage, Vector3(0.44, 0.6, 0.44) * scale_value, Basis.IDENTITY, 0.03)
	mesh.box("glow", cage, Vector3(0.36, 0.46, 0.36) * scale_value, Basis.IDENTITY, 0.0)
	mesh.blob("gold", cage + Vector3(0, 0.42 * scale_value, 0), Vector3(0.12, 0.16, 0.12) * scale_value, 3, 6, 1.0)
	lights.append({"pos": cage, "color": GHOST, "range": 6.0 * scale_value, "energy": 1.3, "kind": "lantern"})


## A red cloth banner with a gold roundel hanging from `top` (facing `normal`), `height` tall.
static func _banner(mesh: KitMesh, top: Vector3, height: float, normal: Vector3, width: float = -1.0) -> void:
	var w: float = width if width > 0.0 else height * 0.42
	var right: Vector3 = Vector3.UP.cross(normal).normalized() * -1.0
	var a: Vector3 = top - right * w * 0.5
	var b: Vector3 = top + right * w * 0.5
	var drop: Vector3 = Vector3(0, -height, 0)
	mesh.quad("red", [a + drop, b + drop, b, a], normal)
	mesh.quad("red", [a + drop, b + drop, b, a], -normal)
	mesh.tri("red", [a + drop, b + drop, top + drop + Vector3(0, -w * 0.3, 0)], normal)
	mesh.tri("red", [a + drop, b + drop, top + drop + Vector3(0, -w * 0.3, 0)], -normal)
	mesh.tube("brass", a + Vector3(0, 0.03, 0) - right * 0.08, b + Vector3(0, 0.03, 0) + right * 0.08, 0.035, 5, true)
	mesh.blob("gold", top + Vector3(0, -height * 0.45, 0) + normal * 0.02, Vector3(w * 0.24, w * 0.24, 0.03), 3, 10, 1.0)


## A hooded stone figure (the civic statues of the concept) on no pedestal: base at `base`, `height` tall.
static func _hooded_figure(mesh: KitMesh, base: Vector3, height: float, slot: String = "dark") -> void:
	var s: float = height / 3.0
	mesh.lathe(slot, base, [Vector2(0.55 * s, 0.0), Vector2(0.6 * s, 1.1 * s), Vector2(0.36 * s, 2.3 * s), Vector2(0.42 * s, 2.55 * s), Vector2(0.12 * s, 3.0 * s)], 9, 0.9, true, true)
	mesh.blob(slot, base + Vector3(0, 2.45 * s, 0.12 * s), Vector3(0.3, 0.32, 0.3) * s, 4, 8, 1.0)


## A patient citizen of the queue: a ghost (translucent green) or a skeleton clerk (dark robe, bone head, a clipboard). `yaw` turns it; base at `base`.
static func _citizen(mesh: KitMesh, base: Vector3, ghost: bool, yaw: float) -> void:
	var slot: String = "ghost" if ghost else "dark"
	mesh.lathe(slot, base, [Vector2(0.24, 0.0), Vector2(0.26, 0.5), Vector2(0.2, 0.78), Vector2(0.1, 0.84)], 8, 0.95, true, true)
	mesh.blob("ghost" if ghost else "parchment", base + Vector3(0, 0.95, 0), Vector3(0.13, 0.15, 0.13), 4, 8, 1.0)
	var forward: Vector3 = Vector3(sin(yaw), 0.0, cos(yaw))
	mesh.box("parchment", base + Vector3(0, 0.6, 0) + forward * 0.26, Vector3(0.22, 0.26, 0.03), Basis(Vector3.UP, yaw), 0.0)


## A stone balustrade from `a` to `b` on the ground level `a.y`: posts, a rail and balusters.
static func _balustrade(mesh: KitMesh, a: Vector3, b: Vector3, post_spacing: float = 2.4) -> void:
	var length: float = a.distance_to(b)
	if length < 0.3:
		return
	var dir: Vector3 = (b - a) / length
	var basis: Basis = Basis(Vector3.UP, atan2(dir.x, dir.z))
	mesh.box("grey_light", (a + b) * 0.5 + Vector3(0, 0.95, 0), Vector3(0.28, 0.12, length + 0.3), basis, 0.02)
	mesh.box("grey_dark", (a + b) * 0.5 + Vector3(0, 0.1, 0), Vector3(0.3, 0.2, length + 0.3), basis, 0.02)
	var posts: int = maxi(1, int(roundf(length / post_spacing)))
	for index: int in range(posts + 1):
		var p: Vector3 = a + dir * (length * float(index) / float(posts))
		mesh.box("grey", p + Vector3(0, 0.55, 0), Vector3(0.4, 1.1, 0.4), basis, 0.03)
		mesh.blob("gold", p + Vector3(0, 1.18, 0), Vector3(0.14, 0.14, 0.14), 3, 6, 1.0)
	var balusters: int = int(length / 0.55)
	for index: int in range(balusters):
		var p: Vector3 = a + dir * (length * (float(index) + 0.5) / float(balusters))
		mesh.tube("grey_light", p + Vector3(0, 0.2, 0), p + Vector3(0, 0.9, 0), 0.06, 5, false)


## A flight of steps from the ground at `foot` (z the outer edge) rising toward -z to `height` over `run`, `width` wide.
static func _stair(mesh: KitMesh, slot: String, foot: Vector3, width: float, height: float, run: float) -> void:
	var steps: int = maxi(2, int(ceilf(height / 0.3)))
	var rise: float = height / float(steps)
	var tread: float = run / float(steps)
	for index: int in range(steps):
		var z: float = foot.z - (float(index) + 0.5) * tread
		mesh.box(slot, Vector3(foot.x, foot.y + (float(index) + 1.0) * rise * 0.5, z), Vector3(width, (float(index) + 1.0) * rise, tread + 0.02), Basis.IDENTITY, 0.0, 0.92)


static func _arch_ring(mesh: KitMesh, slot: String, center: Vector3, radius: float, thickness: float, depth: float, segments: int = 12, full: bool = false) -> void:
	var count: int = segments * (2 if full else 1)
	for step: int in range(count):
		var a0: float = PI * float(step) / float(segments)
		var a1: float = PI * float(step + 1) / float(segments)
		var p0: Vector3 = center + Vector3(cos(a0) * radius, sin(a0) * radius, 0.0)
		var p1: Vector3 = center + Vector3(cos(a1) * radius, sin(a1) * radius, 0.0)
		var mid: Vector3 = (p0 + p1) * 0.5
		var along: Vector3 = (p1 - p0)
		var basis: Basis = Basis(Vector3(0, 0, 1), atan2(along.y, along.x))
		mesh.box(slot, mid, Vector3(along.length() + thickness * 0.3, thickness, depth), basis, 0.02)


## A giant rubber stamp standing upright (the civic emblem): base disc, neck, knob.
static func _stamp(mesh: KitMesh, slot: String, base: Vector3, height: float) -> void:
	var s: float = height / 2.0
	mesh.lathe(slot, base, [Vector2(1.1 * s, 0.0), Vector2(1.1 * s, 0.32 * s), Vector2(0.5 * s, 0.45 * s), Vector2(0.4 * s, 1.15 * s), Vector2(0.72 * s, 1.5 * s), Vector2(0.62 * s, 1.9 * s), Vector2(0.0, 2.0 * s)], 12, 0.9, true, true)


# ---- The Hall of Final Approvals: the main dungeon, an enormous gray civic hall (clock at 4:59, stamp relief, columns, wings of green windows, a dome) --------


static func _hall(root: Node3D, mesh: KitMesh, size: Vector3, circles: Array[Vector3], lights: Array[Dictionary]) -> void:
	var w: float = size.x
	var h: float = size.y
	var d: float = size.z
	var half_w: float = w * 0.5
	var half_d: float = d * 0.5
	var terrace_h: float = clampf(h * 0.12, 1.2, 4.5)
	var body_front: float = half_d * 0.3
	var body_depth: float = half_d + body_front
	var body_z: float = (-half_d + body_front) * 0.5
	var wing_w: float = w * 0.3
	var wing_h: float = h * 0.56
	var centre_w: float = w * 0.4
	var centre_h: float = h * 0.8
	var stair_w: float = clampf(w * 0.2, 3.0, 12.0)
	var run: float = terrace_h * 1.7
	var k: float = clampf(h / 36.0, 0.25, 1.6)  # detail scale: statues, lamps, banners follow the building's size
	# the plinth and its marble forecourt
	mesh.box("grey_dark", Vector3(0, terrace_h * 0.5 - 0.3, 0), Vector3(w, terrace_h + 0.6, d), Basis.IDENTITY, 0.08, 0.86)
	mesh.box("marble", Vector3(0, terrace_h + 0.03, (body_front + half_d) * 0.5), Vector3(w - 0.4, 0.06, half_d - body_front), Basis.IDENTITY, 0.0)
	# the balustrade round the forecourt, open at the stair
	var front_z: float = half_d - 0.3
	var top: float = terrace_h + 0.06
	_balustrade(mesh, Vector3(-half_w + 0.3, top, front_z), Vector3(-stair_w * 0.5 - 0.4, top, front_z), 2.4 * k)
	_balustrade(mesh, Vector3(stair_w * 0.5 + 0.4, top, front_z), Vector3(half_w - 0.3, top, front_z), 2.4 * k)
	for side: float in [-1.0, 1.0]:
		_balustrade(mesh, Vector3(side * (half_w - 0.3), top, body_front + 0.3), Vector3(side * (half_w - 0.3), top, front_z), 2.4 * k)
	# the grand stair with its side walls, statues on the walls' heads and ghost lamps down the flight
	_stair(mesh, "marble", Vector3(0, 0, half_d + run), stair_w, terrace_h, run)
	for side: float in [-1.0, 1.0]:
		var wall_x: float = side * (stair_w * 0.5 + 0.45)
		mesh.box("grey_dark", Vector3(wall_x, terrace_h * 0.5 - 0.3, half_d + run * 0.5), Vector3(0.9, terrace_h + 0.6, run), Basis.IDENTITY, 0.03, 0.9)
		mesh.box("grey", Vector3(wall_x, terrace_h + 0.9 * k, half_d - 0.2), Vector3(1.4 * k, 1.8 * k, 1.4 * k), Basis.IDENTITY, 0.04)
		_hooded_figure(mesh, Vector3(wall_x, terrace_h + 1.8 * k, half_d - 0.2), 3.6 * k)
		_ghost_lamp(mesh, Vector3(wall_x, terrace_h * 0.35, half_d + run * 0.72), lights, 1.3 * k, 0.9 * k)
		_ghost_lamp(mesh, Vector3(wall_x, 0.0, half_d + run + 0.5), lights, 1.6 * k, 0.9 * k)
	# the wings: gray stone, pilasters, tall windows (kit cards: green-lit and dark), banners, a brass cornice, a low slate roof and corner cupolas
	for side: float in [-1.0, 1.0]:
		var wx: float = side * (half_w - wing_w * 0.5)
		mesh.box("grey", Vector3(wx, terrace_h + wing_h * 0.5, body_z), Vector3(wing_w, wing_h, body_depth), Basis.IDENTITY, 0.1, 0.88)
		mesh.box("brass", Vector3(wx, terrace_h + wing_h + 0.25, body_z), Vector3(wing_w + 0.6, 0.5, body_depth + 0.6), Basis.IDENTITY, 0.0)
		mesh.box("grey_light", Vector3(wx, terrace_h + wing_h + 0.85, body_z), Vector3(wing_w + 0.2, 0.7, body_depth + 0.2), Basis.IDENTITY, 0.03)
		mesh.box("slate", Vector3(wx, terrace_h + wing_h + 1.2 + wing_h * 0.04, body_z), Vector3(wing_w * 0.92, wing_h * 0.08, body_depth * 0.9), Basis.IDENTITY, 0.0)
		var columns: int = maxi(3, int(wing_w / 3.6))
		for index: int in range(columns + 1):
			var x: float = wx - wing_w * 0.5 + wing_w * float(index) / float(columns)
			mesh.box("grey_light", Vector3(x, terrace_h + wing_h * 0.5, body_front + 0.2), Vector3(0.7, wing_h, 0.5), Basis.IDENTITY, 0.03)
		for index: int in range(columns):
			var x: float = wx - wing_w * 0.5 + wing_w * (float(index) + 0.5) / float(columns)
			var lit: bool = index % 3 != 1
			var window_id: String = "DNA-SHEET-WINDOWS-02" if lit else "DNA-SHEET-WINDOWS-03"
			if EnvKit.has(window_id):
				_card(mesh, window_id, Vector3(x, terrace_h + wing_h * 0.18, body_front + 0.12), wing_h * 0.55, Vector3(0, 0, 1))
			else:
				mesh.box("window_glow" if lit else "dark", Vector3(x, terrace_h + wing_h * 0.46, body_front + 0.08), Vector3(wing_w / float(columns) * 0.42, wing_h * 0.55, 0.16), Basis.IDENTITY, 0.0)
			if index % 2 == 0:
				_banner(mesh, Vector3(x + wing_w / float(columns) * 0.5, terrace_h + wing_h * 0.9, body_front + 0.3), wing_h * 0.36, Vector3(0, 0, 1), 1.4 * k)
		# the outer corner cupola
		var cx: float = side * (half_w - wing_w * 0.18)
		var cupola_r: float = wing_w * 0.1
		mesh.lathe("grey", Vector3(cx, terrace_h + wing_h + 1.5, body_front - wing_w * 0.2), [Vector2(cupola_r, 0.0), Vector2(cupola_r, cupola_r * 1.6)], 8, 0.95, false, true)
		mesh.lathe("slate", Vector3(cx, terrace_h + wing_h + 1.5 + cupola_r * 1.6, body_front - wing_w * 0.2), [Vector2(cupola_r * 1.15, 0.0), Vector2(cupola_r * 0.5, cupola_r * 1.0), Vector2(0.0, cupola_r * 1.6)], 8, 0.95, false, true)
		mesh.blob("gold", Vector3(cx, terrace_h + wing_h + 1.5 + cupola_r * 3.3, body_front - wing_w * 0.2), Vector3.ONE * cupola_r * 0.3, 3, 6, 1.0)
		mesh.box("window_glow", Vector3(cx, terrace_h + wing_h + 1.5 + cupola_r * 0.8, body_front - wing_w * 0.2 + cupola_r), Vector3(cupola_r * 0.7, cupola_r * 0.8, 0.1), Basis.IDENTITY, 0.0)
	# the central block: columns, entablature, pediment with a laurel, the frozen clock, the stamp relief over the doors
	var cz: float = body_z + 0.4
	mesh.box("grey", Vector3(0, terrace_h + centre_h * 0.5, cz), Vector3(centre_w, centre_h, body_depth + 0.8), Basis.IDENTITY, 0.12, 0.88)
	mesh.box("brass", Vector3(0, terrace_h + centre_h + 0.3, cz), Vector3(centre_w + 0.8, 0.6, body_depth + 1.6), Basis.IDENTITY, 0.0)
	mesh.box("grey_light", Vector3(0, terrace_h + centre_h + 1.0, cz), Vector3(centre_w + 0.4, 0.8, body_depth + 1.2), Basis.IDENTITY, 0.03)
	var col_front: float = body_front + 0.6 + 1.6 * k
	var col_h: float = centre_h * 0.74
	var col_r: float = clampf(centre_w * 0.03, 0.25, 1.2)
	var col_count: int = 6
	for index: int in range(col_count):
		var x: float = -centre_w * 0.42 + centre_w * 0.84 * float(index) / float(col_count - 1)
		if absf(x) < stair_w * 0.3:
			continue
		mesh.tube("grey_light", Vector3(x, terrace_h, col_front), Vector3(x, terrace_h + col_h, col_front), col_r, 10, true)
		mesh.box("brass", Vector3(x, terrace_h + col_h + 0.25, col_front), Vector3(col_r * 3.0, 0.5, col_r * 3.0), Basis.IDENTITY, 0.03)
		mesh.box("grey_dark", Vector3(x, terrace_h + 0.2, col_front), Vector3(col_r * 3.2, 0.4, col_r * 3.2), Basis.IDENTITY, 0.03)
	mesh.box("grey_light", Vector3(0, terrace_h + col_h + 1.0, (col_front + body_front) * 0.5), Vector3(centre_w * 0.96, 1.0, col_front - body_front + col_r * 3.0), Basis.IDENTITY, 0.04)
	mesh.box("brass", Vector3(0, terrace_h + col_h + 0.55, (col_front + body_front) * 0.5), Vector3(centre_w * 0.98, 0.14, col_front - body_front + col_r * 3.2), Basis.IDENTITY, 0.0)
	var ped_y: float = terrace_h + col_h + 1.5
	var ped_h: float = centre_w * 0.14
	mesh.tri("grey", [Vector3(-centre_w * 0.5, ped_y, col_front + col_r), Vector3(centre_w * 0.5, ped_y, col_front + col_r), Vector3(0, ped_y + ped_h, col_front + col_r)], Vector3(0, 0, 1))
	mesh.tri("grey_dark", [Vector3(-centre_w * 0.5, ped_y, col_front + col_r - 0.8), Vector3(0, ped_y + ped_h, col_front + col_r - 0.8), Vector3(centre_w * 0.5, ped_y, col_front + col_r - 0.8)], Vector3(0, 0, 1))
	_arch_ring(mesh, "gold", Vector3(0, ped_y + ped_h * 0.35, col_front + col_r + 0.05), ped_h * 0.26, 0.12 * k, 0.08, 10, true)
	# the clock, stopped at 4:59
	var clock_r: float = centre_w * 0.17
	var clock_y: float = terrace_h + centre_h * 0.58
	var clock_z: float = body_front + 0.42
	mesh.blob("dark", Vector3(0, clock_y, clock_z), Vector3(clock_r, clock_r, 0.25), 6, 18, 1.0)
	_arch_ring(mesh, "gold", Vector3(0, clock_y, clock_z + 0.05), clock_r + 0.2 * k, 0.4 * k, 0.5, 12, true)
	for tick: int in range(12):
		var a: float = TAU * float(tick) / 12.0
		mesh.box("gold", Vector3(sin(a) * clock_r * 0.86, clock_y + cos(a) * clock_r * 0.86, clock_z + 0.28), Vector3(0.12 * k, 0.3 * k, 0.06), Basis(Vector3(0, 0, 1), -a), 0.0)
	var hour: float = -TAU * (4.98 / 12.0)
	var minute: float = TAU * (1.0 / 60.0)
	mesh.box("gold", Vector3(0, clock_y, clock_z + 0.32) + Basis(Vector3(0, 0, 1), hour) * Vector3(0, clock_r * 0.28, 0), Vector3(0.2 * k, clock_r * 0.56, 0.06), Basis(Vector3(0, 0, 1), hour), 0.0)
	mesh.box("gold", Vector3(0, clock_y, clock_z + 0.36) + Basis(Vector3(0, 0, 1), minute) * Vector3(0, clock_r * 0.4, 0), Vector3(0.14 * k, clock_r * 0.8, 0.06), Basis(Vector3(0, 0, 1), minute), 0.0)
	mesh.blob("gold", Vector3(0, clock_y, clock_z + 0.38), Vector3(0.2, 0.2, 0.1) * k, 3, 6, 1.0)
	# the stamp relief over the doors, in its laurel
	var stamp_h: float = centre_h * 0.16
	var stamp_y: float = terrace_h + centre_h * 0.3
	_stamp(mesh, "gold", Vector3(0, stamp_y, body_front + 0.6), stamp_h)
	_arch_ring(mesh, "gold", Vector3(0, stamp_y + stamp_h * 0.5, body_front + 0.3), stamp_h * 0.75, 0.2 * k, 0.2, 10, true)
	# the doors: a dark portal with a brass frame and the kit double doors, warm lamps either side
	var door_h: float = centre_h * 0.24
	var door_w: float = door_h * 0.7
	mesh.box("brass", Vector3(0, terrace_h + door_h * 0.5 + 0.2, body_front + 0.2), Vector3(door_w + 0.6, door_h + 0.5, 0.3), Basis.IDENTITY, 0.02)
	mesh.box("dark", Vector3(0, terrace_h + door_h * 0.5, body_front + 0.3), Vector3(door_w, door_h, 0.2), Basis.IDENTITY, 0.0)
	if EnvKit.has("DNA-SHEET-DOORS-02"):
		_card(mesh, "DNA-SHEET-DOORS-02", Vector3(0, terrace_h, body_front + 0.42), door_h, Vector3(0, 0, 1))
	for side: float in [-1.0, 1.0]:
		var lamp: Vector3 = Vector3(side * (door_w * 0.5 + 1.0 * k), terrace_h + door_h * 0.55, body_front + 0.5)
		mesh.box("iron", lamp, Vector3(0.3, 0.45, 0.3) * k, Basis.IDENTITY, 0.02)
		mesh.box("warm_glow", lamp, Vector3(0.22, 0.34, 0.32) * k, Basis.IDENTITY, 0.0)
		lights.append({"pos": lamp, "color": WARM, "range": 7.0 * k, "energy": 1.4, "kind": "lantern"})
	# the dome on its drum, the lantern on top, corner turrets
	var dome_r: float = centre_w * 0.26
	var drum_y: float = terrace_h + centre_h + 1.4
	mesh.lathe("grey", Vector3(0, drum_y, cz), [Vector2(dome_r * 1.1, 0.0), Vector2(dome_r * 1.1, dome_r * 0.5), Vector2(dome_r, dome_r * 0.5), Vector2(dome_r, dome_r * 0.95)], 14, 0.95, false, true)
	for index: int in range(8):
		var a: float = TAU * float(index) / 8.0
		mesh.box("window_glow", Vector3(sin(a) * dome_r * 1.0, drum_y + dome_r * 0.72, cz + cos(a) * dome_r * 1.0), Vector3(dome_r * 0.22, dome_r * 0.36, dome_r * 0.22), Basis(Vector3.UP, a), 0.0)
	mesh.lathe("slate", Vector3(0, drum_y + dome_r * 0.95, cz), [Vector2(dome_r * 1.12, 0.0), Vector2(dome_r * 1.02, dome_r * 0.35), Vector2(dome_r * 0.78, dome_r * 0.72), Vector2(dome_r * 0.4, dome_r * 0.98), Vector2(0.0, dome_r * 1.08)], 14, 0.95, false, true)
	var lantern_y: float = drum_y + dome_r * 2.0
	mesh.lathe("grey_light", Vector3(0, lantern_y, cz), [Vector2(dome_r * 0.26, 0.0), Vector2(dome_r * 0.26, dome_r * 0.5)], 8, 1.0, false, true)
	mesh.box("window_glow", Vector3(0, lantern_y + dome_r * 0.25, cz), Vector3(dome_r * 0.5, dome_r * 0.3, dome_r * 0.5), Basis.IDENTITY, 0.0)
	mesh.lathe("slate", Vector3(0, lantern_y + dome_r * 0.5, cz), [Vector2(dome_r * 0.34, 0.0), Vector2(0.0, dome_r * 0.5)], 8, 1.0, false, true)
	mesh.blob("gold", Vector3(0, lantern_y + dome_r * 1.1, cz), Vector3.ONE * dome_r * 0.12, 3, 6, 1.0)
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			var tx: float = sx * (centre_w * 0.5 - dome_r * 0.3)
			var tz: float = cz + sz * (body_depth * 0.5 - dome_r * 0.3)
			var tr: float = dome_r * 0.22
			mesh.lathe("grey", Vector3(tx, terrace_h + centre_h + 1.4, tz), [Vector2(tr, 0.0), Vector2(tr, tr * 1.8)], 8, 0.95, false, true)
			mesh.lathe("slate", Vector3(tx, terrace_h + centre_h + 1.4 + tr * 1.8, tz), [Vector2(tr * 1.15, 0.0), Vector2(0.0, tr * 1.7)], 8, 1.0, false, true)
			mesh.blob("gold", Vector3(tx, terrace_h + centre_h + 1.4 + tr * 3.7, tz), Vector3.ONE * tr * 0.3, 3, 6, 1.0)
	# dead topiary and ghost lilies along the forecourt
	var pots: int = maxi(2, int(w / 7.0))
	for index: int in range(pots):
		var x: float = -half_w + 1.4 + (w - 2.8) * float(index) / float(pots - 1)
		if absf(x) < stair_w * 0.5 + 1.8:
			continue
		_tree_card(root, "DNA-TREE-DEAD", Vector3(x, terrace_h + 0.06, body_front + 1.2), 2.0 * k)
	_tree_card(root, "DNA-PLANT-LILY", Vector3(-door_w * 0.5 - 2.2 * k, terrace_h + 0.06, body_front + 1.0), 1.4 * k)
	_tree_card(root, "DNA-PLANT-LILY", Vector3(door_w * 0.5 + 2.2 * k, terrace_h + 0.06, body_front + 1.0), 1.4 * k)
	# blockers: the plinth, the stair walls and the stair itself (a vista, not a climb)
	var radius: float = minf(half_d, 5.0)
	var rows: Array[float] = [0.0]
	if d > 9.0:
		rows = [-half_d * 0.5, half_d * 0.5]
	for row_z: float in rows:
		var count: int = maxi(1, int(ceilf(w / (radius * 1.5))))
		for index: int in range(count + 1):
			circles.append(Vector3(-half_w + w * float(index) / float(count), row_z, radius))
	var stair_cols: int = maxi(1, int(ceilf(stair_w / run)))
	for index: int in range(stair_cols + 1):
		circles.append(Vector3(-stair_w * 0.5 + stair_w * float(index) / float(stair_cols), half_d + run * 0.5, maxf(run * 0.5, 0.8)))
	for side: float in [-1.0, 1.0]:
		circles.append(Vector3(side * (stair_w * 0.5 + 0.45), half_d + run * 0.5, maxf(run * 0.5, 0.8)))


# ---- The Filing-cabinet Tower: a teetering stack of gray cabinets, drawers half open, papers, a brass ladder, banners, ghost lamps at the foot ----------------


static func _filing_tower(root: Node3D, mesh: KitMesh, size: Vector3, circles: Array[Vector3], lights: Array[Dictionary]) -> void:
	var w: float = size.x
	var h: float = size.y
	var d: float = size.z
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 459
	mesh.box("grey_dark", Vector3(0, 0.25, 0), Vector3(w * 0.95, 0.5, d * 0.95), Basis.IDENTITY, 0.05, 0.9)
	mesh.box("brass", Vector3(0, 0.52, 0), Vector3(w * 0.9, 0.06, d * 0.9), Basis.IDENTITY, 0.0)
	var count: int = 9
	var y: float = 0.55
	var ladder_side: float = 1.0
	for index: int in range(count):
		var t: float = float(index) / float(count - 1)
		var box_h: float = (h - 0.55) / float(count) * rng.randf_range(0.85, 1.15)
		var box_w: float = lerpf(w * 0.82, w * 0.34, t) * rng.randf_range(0.9, 1.08)
		var box_d: float = lerpf(d * 0.85, d * 0.42, t) * rng.randf_range(0.9, 1.08)
		var centre: Vector3 = Vector3(sin(float(index) * 1.9) * w * 0.06 * t, y + box_h * 0.5, cos(float(index) * 1.3) * d * 0.05 * t)
		mesh.box("cabinet", centre, Vector3(box_w, box_h, box_d), Basis(Vector3.UP, rng.randf_range(-0.06, 0.06)), 0.04, 0.9)
		mesh.box("cabinet_dark", centre + Vector3(0, box_h * 0.5 - 0.03, 0), Vector3(box_w + 0.08, 0.06, box_d + 0.08), Basis.IDENTITY, 0.0)
		# drawers on the front and the sides
		var rows: int = maxi(1, int(box_h / 0.8))
		var cols: int = maxi(1, int(box_w / 1.5))
		for row: int in range(rows):
			var dy: float = centre.y - box_h * 0.5 + box_h * (float(row) + 0.5) / float(rows)
			for col: int in range(cols):
				var dx: float = centre.x - box_w * 0.5 + box_w * (float(col) + 0.5) / float(cols)
				var open: bool = rng.randf() < 0.22
				var depth: float = 0.55 if open else 0.0
				mesh.box("cabinet_dark", Vector3(dx, dy, centre.z + box_d * 0.5 + 0.02 + depth * 0.5), Vector3(box_w / float(cols) * 0.8, box_h / float(rows) * 0.62, 0.06 + depth), Basis.IDENTITY, 0.01)
				mesh.box("brass", Vector3(dx, dy, centre.z + box_d * 0.5 + 0.06 + depth), Vector3(0.34, 0.06, 0.05), Basis.IDENTITY, 0.0)
				if open:
					mesh.box("parchment", Vector3(dx, dy + box_h / float(rows) * 0.31 + 0.1, centre.z + box_d * 0.5 + 0.3), Vector3(box_w / float(cols) * 0.6, 0.2, 0.5), Basis(Vector3.UP, rng.randf_range(-0.2, 0.2)), 0.0)
			var side_cols: int = maxi(1, int(box_d / 1.5))
			for col: int in range(side_cols):
				var dz: float = centre.z - box_d * 0.5 + box_d * (float(col) + 0.5) / float(side_cols)
				for side: float in [-1.0, 1.0]:
					mesh.box("cabinet_dark", Vector3(centre.x + side * (box_w * 0.5 + 0.03), dy, dz), Vector3(0.06, box_h / float(rows) * 0.62, box_d / float(side_cols) * 0.8), Basis.IDENTITY, 0.01)
					mesh.box("brass", Vector3(centre.x + side * (box_w * 0.5 + 0.07), dy, dz), Vector3(0.05, 0.06, 0.34), Basis.IDENTITY, 0.0)
		# a banner on every third box, on alternating sides
		if index % 3 == 1:
			var bside: float = -1.0 if (index / 3) % 2 == 0 else 1.0
			_banner(mesh, centre + Vector3(bside * (box_w * 0.5 + 0.12), box_h * 0.45, 0), box_h * 0.9, Vector3(bside, 0, 0), 1.3)
		# the brass ladder winds up the front, swapping sides
		if index < count - 1:
			var lx: float = centre.x + ladder_side * box_w * 0.3
			var lz: float = centre.z + box_d * 0.5 + 0.35
			for rail: float in [-0.3, 0.3]:
				mesh.tube("brass", Vector3(lx + rail, y - 0.1, lz), Vector3(lx + rail, y + box_h + 0.2, lz), 0.05, 5, true)
			var rungs: int = maxi(2, int(box_h / 0.45))
			for rung: int in range(rungs):
				var ry: float = y + box_h * (float(rung) + 0.5) / float(rungs)
				mesh.tube("brass", Vector3(lx - 0.3, ry, lz), Vector3(lx + 0.3, ry, lz), 0.035, 4, false)
			ladder_side *= -1.0
		y += box_h
	# a cabinet on its side as the cap, a brass finial
	mesh.blob("gold", Vector3(0, y + 0.25, 0), Vector3(0.25, 0.3, 0.25), 4, 8, 1.0)
	# papers fluttering round the stack
	for index: int in range(22):
		var a: float = rng.randf() * TAU
		var py: float = rng.randf_range(h * 0.25, h * 1.05)
		var t: float = py / h
		var reach: float = lerpf(w * 0.6, w * 0.4, t) + rng.randf_range(0.4, 1.8)
		var p: Vector3 = Vector3(cos(a) * reach, py, sin(a) * reach * (d / w))
		var basis: Basis = Basis(Vector3(rng.randf(), rng.randf(), rng.randf()).normalized(), rng.randf() * TAU)
		mesh.box("parchment", p, Vector3(0.42, 0.56, 0.02), basis, 0.0)
	# the foot: ghost lamps on brass-capped pedestals, paper stacks, a stamp and a sad office plant
	for sx: float in [-1.0, 1.0]:
		var corner: Vector3 = Vector3(sx * (w * 0.5 + 0.6), 0.0, d * 0.5 + 0.4)
		mesh.box("grey", corner + Vector3(0, 0.45, 0), Vector3(0.9, 0.9, 0.9), Basis.IDENTITY, 0.04, 0.9)
		mesh.box("brass", corner + Vector3(0, 0.92, 0), Vector3(1.0, 0.06, 1.0), Basis.IDENTITY, 0.0)
		_ghost_lamp(mesh, corner + Vector3(0, 0.95, 0), lights, 1.3, 0.9)
		circles.append(Vector3(corner.x, corner.z, 0.7))
	_tree_card(root, "DNA-PROP-PAPER", Vector3(-w * 0.28, 0.55, d * 0.5 + 0.9), 1.5)
	_tree_card(root, "DNA-PROP-PAPER", Vector3(w * 0.3, 0.55, d * 0.5 + 1.2), 1.1)
	_tree_card(root, "DNA-PROP-STAMP", Vector3(w * 0.05, 0.55, d * 0.5 + 1.1), 1.0)
	_tree_card(root, "DNA-PLANT-OFFICE", Vector3(-w * 0.45, 0.0, -d * 0.5 - 0.6), 1.9)
	var radius: float = minf(w, d) * 0.5
	var steps: int = maxi(1, int(ceilf(w / radius)))
	for index: int in range(steps + 1):
		circles.append(Vector3(-w * 0.5 + radius * 0.5 + (w - radius) * float(index) / float(steps), 0.0, radius))
	circles.append(Vector3(0.0, d * 0.5 + 0.9, 1.1))


# ---- The Endless Queue: brass posts and red rope snaking between planters and ghost lamps toward one tiny service window --------------------------


static func _queue(root: Node3D, mesh: KitMesh, size: Vector3, circles: Array[Vector3], lights: Array[Dictionary]) -> void:
	var w: float = size.x
	var wiggle: float = maxf(size.z, 3.0) * 0.5
	var half_w: float = w * 0.5
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 212
	# the worn stone lane under the line
	mesh.box("queue", Vector3(0, 0.05, 0), Vector3(w + 1.0, 0.1, wiggle * 2.0 + 2.4), Basis.IDENTITY, 0.02, 0.95)
	mesh.box("grey_dark", Vector3(0, 0.02, 0), Vector3(w + 1.6, 0.06, wiggle * 2.0 + 3.0), Basis.IDENTITY, 0.0)
	# the serpentine of stanchions
	var spacing: float = 2.0
	var count: int = maxi(3, int(w / spacing))
	var points: Array[Vector3] = []
	for index: int in range(count + 1):
		var x: float = -half_w + 1.0 + (w - 2.0) * float(index) / float(count)
		var z: float = sin(float(index) * 0.75) * wiggle * 0.8
		points.append(Vector3(x, 0.1, z))
	for index: int in range(points.size()):
		var p: Vector3 = points[index]
		mesh.lathe("brass", p, [Vector2(0.24, 0.0), Vector2(0.2, 0.06), Vector2(0.07, 0.1)], 8, 1.0, true, true)
		mesh.tube("brass", p + Vector3(0, 0.08, 0), p + Vector3(0, 0.95, 0), 0.05, 6, true)
		mesh.blob("gold", p + Vector3(0, 1.02, 0), Vector3(0.1, 0.11, 0.1), 3, 7, 1.0)
		if index > 0:
			var q: Vector3 = points[index - 1]
			var segments: int = 5
			var previous: Vector3 = q + Vector3(0, 0.88, 0)
			for step: int in range(1, segments + 1):
				var t: float = float(step) / float(segments)
				var r: Vector3 = q.lerp(p, t) + Vector3(0, 0.88 - 0.16 * 4.0 * t * (1.0 - t), 0)
				mesh.tube("red", previous, r, 0.035, 5, false)
				previous = r
		if index % 2 == 0:
			circles.append(Vector3(p.x, p.z, 1.3))
	# the citizens, in line between the posts, facing the window
	for index: int in range(points.size() - 1):
		if index % 7 == 5:
			continue
		var p: Vector3 = points[index].lerp(points[index + 1], rng.randf_range(0.3, 0.7))
		var yaw: float = PI * 0.5 + rng.randf_range(-0.35, 0.35)
		_citizen(mesh, Vector3(p.x, 0.1, p.z - 0.05), index % 3 != 1, yaw)
	# planters, ghost lamps and banner posts along the back of the line
	var back: float = -wiggle - 1.1
	var spots: int = maxi(2, int(w / 7.0))
	for index: int in range(spots + 1):
		var x: float = -half_w + 1.5 + (w - 3.0) * float(index) / float(spots)
		var base: Vector3 = Vector3(x, 0.1, back)
		match index % 3:
			0:
				mesh.box("grey", base + Vector3(0, 0.4, 0), Vector3(1.6, 0.8, 1.0), Basis.IDENTITY, 0.04, 0.9)
				mesh.box("brass", base + Vector3(0, 0.82, 0), Vector3(1.7, 0.05, 1.1), Basis.IDENTITY, 0.0)
				_tree_card(root, "DNA-TREE-DEAD" if index % 2 == 0 else "DNA-PLANT-LILY", base + Vector3(0, 0.84, 0), 1.3)
			1:
				mesh.box("grey", base + Vector3(0, 0.5, 0), Vector3(0.9, 1.0, 0.9), Basis.IDENTITY, 0.04, 0.9)
				mesh.box("brass", base + Vector3(0, 1.02, 0), Vector3(1.0, 0.05, 1.0), Basis.IDENTITY, 0.0)
				_ghost_lamp(mesh, base + Vector3(0, 1.05, 0), lights, 1.4, 0.9)
			_:
				mesh.box("grey_dark", base + Vector3(0, 0.3, 0), Vector3(0.7, 0.6, 0.7), Basis.IDENTITY, 0.03)
				mesh.tube("brass", base + Vector3(0, 0.6, 0), base + Vector3(0, 3.4, 0), 0.07, 6, true)
				mesh.tube("brass", base + Vector3(-0.8, 3.3, 0), base + Vector3(0.8, 3.3, 0), 0.05, 5, true)
				_banner(mesh, base + Vector3(0, 3.25, 0.1), 2.0, Vector3(0, 0, 1), 1.3)
		circles.append(Vector3(x, back, 0.8))
	# the service window at the end of the line: a tiny booth with a slate roof, a warm-lit counter and a skeleton clerk
	var booth: Vector3 = Vector3(half_w - 1.0, 0.1, points[points.size() - 1].z - 1.6)
	mesh.box("grey", booth + Vector3(0, 1.4, 0), Vector3(2.6, 2.8, 2.0), Basis.IDENTITY, 0.05, 0.9)
	mesh.box("brass", booth + Vector3(0, 2.85, 0), Vector3(2.9, 0.1, 2.3), Basis.IDENTITY, 0.0)
	mesh.box("slate", booth + Vector3(0, 3.1, 0), Vector3(3.2, 0.4, 2.6), Basis.IDENTITY, 0.02)
	mesh.lathe("slate", booth + Vector3(0, 3.3, 0), [Vector2(1.5, 0.0), Vector2(0.0, 0.9)], 4, 1.0, false, true)
	mesh.blob("gold", booth + Vector3(0, 4.3, 0), Vector3(0.14, 0.18, 0.14), 3, 6, 1.0)
	mesh.box("dark", booth + Vector3(0, 1.45, 1.02), Vector3(1.3, 1.1, 0.08), Basis.IDENTITY, 0.0)
	mesh.box("warm_glow", booth + Vector3(0, 1.5, 1.04), Vector3(1.1, 0.8, 0.06), Basis.IDENTITY, 0.0)
	mesh.box("brass", booth + Vector3(0, 0.95, 1.2), Vector3(1.6, 0.1, 0.4), Basis.IDENTITY, 0.0)
	lights.append({"pos": booth + Vector3(0, 1.6, 1.5), "color": WARM, "range": 5.0, "energy": 1.2, "kind": "lantern"})
	_citizen(mesh, booth + Vector3(0, 0.0, 0.45), false, PI)
	_banner(mesh, booth + Vector3(0, 2.75, 1.06), 0.9, Vector3(0, 0, 1), 0.9)
	if EnvKit.has("DNA-SHEET-SIGNS-01"):
		_card(mesh, "DNA-SHEET-SIGNS-01", booth + Vector3(-0.9, 2.1, 1.05), 0.6, Vector3(0, 0, 1))
	mesh.box("parchment", booth + Vector3(0.9, 1.2, 1.2), Vector3(0.5, 0.5, 0.4), Basis(Vector3.UP, 0.2), 0.0)
	circles.append(Vector3(booth.x, booth.z, 1.7))
	# the "take a number" post at the start of the line, with a folder plaque
	var start: Vector3 = Vector3(-half_w + 0.6, 0.1, points[0].z + 1.2)
	mesh.box("grey", start + Vector3(0, 0.6, 0), Vector3(0.8, 1.2, 0.8), Basis.IDENTITY, 0.04, 0.9)
	mesh.box("brass", start + Vector3(0, 1.22, 0), Vector3(0.9, 0.06, 0.9), Basis.IDENTITY, 0.0)
	mesh.box("parchment", start + Vector3(0, 1.32, 0), Vector3(0.3, 0.14, 0.4), Basis.IDENTITY, 0.0)
	if EnvKit.has("DNA-SHEET-SIGNS-04"):
		_card(mesh, "DNA-SHEET-SIGNS-04", start + Vector3(-0.3, 0.5, 0.42), 0.55, Vector3(0, 0, 1))
	circles.append(Vector3(start.x, start.z, 0.6))


# ---- The Records Basement stair: a vault door frame on a landing, a grand stair with ghost lamps, canyons of shelving behind ------------------------


static func _records_stair(root: Node3D, mesh: KitMesh, size: Vector3, circles: Array[Vector3], lights: Array[Dictionary]) -> void:
	var w: float = size.x
	var h: float = size.y
	var d: float = size.z
	var half_w: float = w * 0.5
	var half_d: float = d * 0.5
	var plat_h: float = h * 0.4
	var plat_d: float = d * 0.34
	var plat_z: float = -half_d + plat_d * 0.5
	var stair_w: float = w * 0.6
	var run: float = d - plat_d - 0.2
	# the landing and the vault frame
	mesh.box("grey_dark", Vector3(0, plat_h * 0.5, plat_z), Vector3(w, plat_h, plat_d), Basis.IDENTITY, 0.06, 0.86)
	mesh.box("marble", Vector3(0, plat_h + 0.03, plat_z), Vector3(w - 0.3, 0.06, plat_d - 0.3), Basis.IDENTITY, 0.0)
	var pillar_x: float = w * 0.26
	var frame_h: float = h - plat_h
	for side: float in [-1.0, 1.0]:
		mesh.box("grey", Vector3(side * pillar_x, plat_h + frame_h * 0.5, plat_z), Vector3(w * 0.16, frame_h, plat_d * 0.9), Basis.IDENTITY, 0.06, 0.9)
		mesh.box("brass", Vector3(side * pillar_x, plat_h + frame_h - 0.1, plat_z), Vector3(w * 0.18, 0.2, plat_d * 0.95), Basis.IDENTITY, 0.0)
		_banner(mesh, Vector3(side * pillar_x, plat_h + frame_h * 0.88, plat_z + plat_d * 0.45 + 0.1), frame_h * 0.5, Vector3(0, 0, 1), w * 0.08)
	mesh.box("grey", Vector3(0, plat_h + frame_h - 0.45, plat_z), Vector3(pillar_x * 2.0, 0.9, plat_d * 0.9), Basis.IDENTITY, 0.04)
	mesh.box("brass", Vector3(0, plat_h + frame_h + 0.05, plat_z), Vector3(pillar_x * 2.0 + w * 0.18, 0.1, plat_d * 0.95), Basis.IDENTITY, 0.0)
	# the vault door: an iron disc in a brass ring with a wheel lock
	var door_r: float = minf(pillar_x - w * 0.09, (frame_h - 0.9) * 0.5)
	var door_c: Vector3 = Vector3(0, plat_h + door_r + 0.05, plat_z + plat_d * 0.45)
	mesh.box("dark", Vector3(0, plat_h + (frame_h - 0.9) * 0.5, plat_z), Vector3(pillar_x * 2.0 - w * 0.16, frame_h - 0.9, plat_d * 0.8), Basis.IDENTITY, 0.0)
	mesh.blob("iron", door_c, Vector3(door_r, door_r, 0.2), 6, 16, 1.0)
	_arch_ring(mesh, "brass", door_c + Vector3(0, 0, 0.08), door_r, 0.18, 0.22, 12, true)
	mesh.blob("brass", door_c + Vector3(0, 0, 0.22), Vector3(door_r * 0.12, door_r * 0.12, 0.08), 3, 8, 1.0)
	for spoke: int in range(4):
		var a: float = PI * float(spoke) / 4.0
		mesh.box("brass", door_c + Vector3(0, 0, 0.24), Vector3(door_r * 0.9, 0.08, 0.06), Basis(Vector3(0, 0, 1), a), 0.0)
	_arch_ring(mesh, "brass", door_c + Vector3(0, 0, 0.24), door_r * 0.42, 0.08, 0.06, 8, true)
	if EnvKit.has("DNA-SHEET-SIGNS-04"):
		_card(mesh, "DNA-SHEET-SIGNS-04", Vector3(-0.35, plat_h + frame_h - 0.75, plat_z + plat_d * 0.45 + 0.06), 0.5, Vector3(0, 0, 1))
	# the grand stair down to the floor, balustrades and ghost lamps alongside
	_stair(mesh, "grey_light", Vector3(0, 0, half_d), stair_w, plat_h, run)
	for side: float in [-1.0, 1.0]:
		var x: float = side * (stair_w * 0.5 + 0.3)
		var top: Vector3 = Vector3(x, plat_h, half_d - run)
		var bottom: Vector3 = Vector3(x, 0.0, half_d)
		var slope: Vector3 = bottom - top
		var basis: Basis = Basis(Vector3(1, 0, 0), -atan2(slope.y, slope.z))
		mesh.box("grey_light", (top + bottom) * 0.5 + Vector3(0, 0.9, 0), Vector3(0.26, 0.12, slope.length() + 0.2), basis, 0.02)
		var balusters: int = maxi(2, int(slope.length() / 0.55))
		for index: int in range(balusters):
			var p: Vector3 = top.lerp(bottom, (float(index) + 0.5) / float(balusters))
			mesh.tube("grey_light", p + Vector3(0, 0.1, 0), p + Vector3(0, 0.84, 0), 0.05, 5, false)
		for t: float in [0.0, 0.5, 1.0]:
			var p: Vector3 = top.lerp(bottom, t)
			mesh.box("grey", p + Vector3(0, 0.55, 0), Vector3(0.5, 1.1, 0.5), Basis.IDENTITY, 0.03)
			mesh.box("brass", p + Vector3(0, 1.12, 0), Vector3(0.56, 0.06, 0.56), Basis.IDENTITY, 0.0)
			_ghost_lamp(mesh, p + Vector3(0, 1.15, 0), lights, 0.9, 0.75)
	# shelving canyons either side of the landing: paneling towers with rows of files, brass trim, lilies at their feet
	for side: float in [-1.0, 1.0]:
		var sx: float = side * (half_w - w * 0.11)
		var shelf_w: float = w * 0.22
		var shelf_h: float = h * 1.05
		var shelf_z: float = plat_z + plat_d * 0.2
		mesh.box("paneling", Vector3(sx, shelf_h * 0.5, shelf_z), Vector3(shelf_w, shelf_h, plat_d * 0.8), Basis.IDENTITY, 0.04, 0.88)
		mesh.box("brass", Vector3(sx, shelf_h + 0.05, shelf_z), Vector3(shelf_w + 0.1, 0.1, plat_d * 0.85), Basis.IDENTITY, 0.0)
		var rows: int = maxi(2, int(shelf_h / 0.9))
		for row: int in range(rows):
			var ry: float = shelf_h * (float(row) + 0.5) / float(rows)
			mesh.box("grey_dark", Vector3(sx, ry - shelf_h / float(rows) * 0.42, shelf_z + plat_d * 0.4 + 0.04), Vector3(shelf_w * 0.92, 0.06, 0.1), Basis.IDENTITY, 0.0)
			var files: int = maxi(2, int(shelf_w / 0.45))
			for file_index: int in range(files):
				var fx: float = sx - shelf_w * 0.44 + shelf_w * 0.88 * (float(file_index) + 0.5) / float(files)
				var slot: String = "parchment" if (file_index + row) % 4 != 2 else "cabinet"
				mesh.box(slot, Vector3(fx, ry - shelf_h / float(rows) * 0.1, shelf_z + plat_d * 0.4 + 0.08), Vector3(shelf_w * 0.88 / float(files) * 0.78, shelf_h / float(rows) * 0.5, 0.1), Basis(Vector3.UP, 0.0), 0.0)
		_tree_card(root, "DNA-PLANT-LILY", Vector3(sx + side * 0.2, 0.0, shelf_z + plat_d * 0.4 + 0.8), 1.2)
		circles.append(Vector3(sx, shelf_z, shelf_w * 0.55))
	# blockers: the landing and the stair (a vista, not a climb)
	var count: int = maxi(1, int(ceilf(w / (plat_d * 0.8))))
	for index: int in range(count + 1):
		circles.append(Vector3(-half_w + w * float(index) / float(count), plat_z, plat_d * 0.5))
	var stair_cols: int = maxi(1, int(ceilf(stair_w / run)))
	for index: int in range(stair_cols + 1):
		circles.append(Vector3(-stair_w * 0.5 + stair_w * float(index) / float(stair_cols), half_d - run * 0.5, maxf(run * 0.5, 0.8)))
