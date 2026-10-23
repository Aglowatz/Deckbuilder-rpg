class_name HeapLandmarks
extends RefCounted
## The Verdant Dump's hero landmarks modelled after the approved concepts (docs/art/zone_kits/heap/concepts/*.jpg) with the zone kit's painted surfaces
## (data/art/zone_kits/heap.json): the Rotheart (the main dungeon, a castle-scale knot of roots and swallowed scrap beyond the north rim with a pulsing
## violet heart), Junk Mountain (a view beyond the north-east corner), the farm rows' windmill (sails turning), the Trash Panda Throne (the side
## dungeon's door, beyond the north-west rim, its steps on the land) and the Commons greenhouse (the hub centrepiece, lit warm inside). `HeroLandmarks`
## dispatches "DUMP-HERO-" ids here. Same contract as the stand-ins (`LandmarkKit`): origin on the ground at the centre of the footprint, the front +z
## (south, toward the player), `size` = w, h, d in metres, meta "circles" (local x, z, radius), "footprint", "height", "lights", and optionally "spinner"
## (a child the builder turns about its local z) and "corruption" (the Rotheart's violet materials, `set_freed` turns them warm green). The Rotheart's
## root gate on the land and the entrance bridge are static builders here too. Nothing carries readable text (Art Bible G-03).

const H = preload("res://world/heap/heap_materials.gd")

const IDS: Array[String] = ["DUMP-HERO-ROTHEART", "DUMP-HERO-JUNK-MOUNTAIN", "DUMP-HERO-WINDMILL", "DUMP-HERO-TRASH-PANDA-THRONE", "DUMP-HERO-COMMONS-GREENHOUSE"]
const MOSS: Color = Color("7c8f45")
const RUST: Color = Color("b5552d")
const GOLD: Color = Color("e3a857")
const SLATE: Color = Color("5c6b5e")
const BARK: Color = Color("8b6d4c")
const CREAM: Color = Color("e9d8a6")
## The Rotheart's bark (the concept's warm mauve-brown), its shadow side and its sickly violet.
const ROT_BARK: Color = Color("7e5848")
const ROT_BARK_DARK: Color = Color("4c3036")
const ROT_VIOLET: Color = Color("6e4468")
const LEAF: Color = Color("7c8f45")
const LEAF_LIGHT: Color = Color("b4b84c")
const LEAF_DARK: Color = Color("4e6232")
const HANGING_MOSS: Color = Color("b8a83e")
const STONE: Color = Color("8f8676")
const VIOLET: Color = Color("b060f0")
const VIOLET_DEEP: Color = Color("5a1c80")
const FREED_GREEN: Color = Color("9ee070")
const WARM: Color = Color("ffc070")
const CARD_UVS: Array[Vector2] = [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)]
## The Rotheart trunk's radius profile (radius, height) in metres at 46 m tall; the hollow, the strands and the veins sit on it.
const TRUNK: Array[Vector2] = [Vector2(11.0, 0.0), Vector2(9.0, 3.0), Vector2(7.6, 7.0), Vector2(7.0, 11.0), Vector2(6.6, 14.5), Vector2(7.6, 17.0), Vector2(5.4, 20.0)]


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
		"DUMP-HERO-ROTHEART":
			_rotheart(root, mesh, size, circles, lights)
		"DUMP-HERO-JUNK-MOUNTAIN":
			_junk_mountain(root, mesh, size, circles, lights)
		"DUMP-HERO-WINDMILL":
			_windmill(root, mesh, size, circles, lights)
		"DUMP-HERO-TRASH-PANDA-THRONE":
			_throne(root, mesh, size, circles, lights)
		"DUMP-HERO-COMMONS-GREENHOUSE":
			_greenhouse(root, mesh, size, circles, lights)
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
	return EnvKit.flat(fallback * mul, "dump_hero")


## A glow of its own (not the shared cache): the Rotheart's heart, veins and fungi change colour when the zone is freed and the heart pulses.
static func own_glow(color: Color, energy: float, alpha: float = 1.0) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(color.r, color.g, color.b, alpha)
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = energy
	material.roughness = 0.5
	if alpha < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.set_meta(PaintedClasses.META_NO_PAINT, true)
	material.set_meta(StyleToon.META_NO_TOON, true)
	return material


static func _warm_glass() -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.86, 0.55, 0.32)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.roughness = 0.12
	material.emission_enabled = true
	material.emission = Color(1.0, 0.72, 0.36)
	material.emission_energy_multiplier = 0.55
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.vertex_color_use_as_albedo = true
	material.set_meta(PaintedClasses.META_NO_PAINT, true)
	material.set_meta(StyleToon.META_NO_TOON, true)
	return material


static func _materials(mesh: KitMesh) -> void:
	mesh.set_material("doors", _surface("DUMP-WALL-DOORS", RUST))
	mesh.set_material("mosswood", _surface("DUMP-WALL-MOSSWOOD", SLATE))
	mesh.set_material("tin", _surface("DUMP-ROOF-TIN", RUST))
	mesh.set_material("reed", _surface("DUMP-ROOF-REED", GOLD))
	mesh.set_material("plank", _surface("DUMP-PATH-PLANK", BARK))
	mesh.set_material("rope", _surface("DUMP-TRIM-ROPE", CREAM))
	mesh.set_material("corrupt_ground", _surface("DUMP-GROUND-CORRUPT", ROT_VIOLET))
	mesh.set_material("clover", _surface("DUMP-GROUND-CLOVER", MOSS))
	mesh.set_material("glass", _warm_glass())
	# vertex colours are linear in Godot: the palette colours go in through srgb_to_linear so what shows is the palette, not a paler version of it
	mesh.set_material("flat", EnvKit.flat(Color.WHITE, "dump_hero"))
	var flats: Dictionary = {
		"bark": ROT_BARK, "bark_dark": ROT_BARK_DARK, "bark_violet": ROT_VIOLET, "leaf": LEAF, "leaf_light": LEAF_LIGHT, "leaf_dark": LEAF_DARK,
		"hanging_moss": HANGING_MOSS, "stem": Color("e8d8c8"), "wood": Color("8a5a30"), "wood_dark": Color("5a3a20"), "rust": RUST, "rust_dark": Color("7a3a1e"),
		"metal": Color("9aa0a0"), "metal_dark": Color("5a6262"), "stone": STONE, "stone_dark": Color("615a50"), "soil": Color("5a4630"), "gold": Color("e8b840"),
		"cloth_cream": CREAM, "cloth_rust": Color("c8643a"), "cloth_green": Color("7a9a5a"), "cloth_red": Color("b8402e"), "cloth_teal": Color("4a8a8a"),
		"sunflower": Color("f2c230"), "petal_violet": Color("8a6ad0"), "mask": Color("3a3236"), "fur_light": Color("d8d0c4"),
		"tyre": Color("2a2a2e"), "straw": Color("e6c260"), "cap_red": Color("cc4030"), "cap_yellow": Color("e6b830"), "cap_blue": Color("4060c0"),
	}
	for slot: String in flats.keys():
		mesh.alias(slot, "flat", (flats[slot] as Color).srgb_to_linear())
	mesh.set_material("lantern", EnvKit.glow(Color("ffd890"), 1.8))
	mesh.set_material("window_glow", EnvKit.glow(Color("ffc070"), 1.3))
	mesh.set_material("fungus", own_glow(Color("c080f0"), 0.55))
	mesh.set_material("veins", own_glow(VIOLET, 1.6))
	mesh.set_material("heart", heart_glow(Color(1.15, 0.55, 1.55)))
	mesh.set_material("hollow", own_glow(VIOLET_DEEP, 0.9))
	mesh.set_material("wisteria", own_glow(Color("a070e0"), 0.45))


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


## A painted leaf mass (a DUMP-TREE-CANOPY cell) in the mesh, centred on `centre`, `width` metres across, facing +z (every camera looks north at the
## crown); nothing while the cell has no art.
static func _canopy_card(mesh: KitMesh, id: String, centre: Vector3, width: float) -> void:
	if not EnvKit.has_art(id):
		return
	var slot: String = "card_%s" % id
	if not mesh.has_slot(slot):
		mesh.set_material(slot, EnvKit.material(id, true))
	var half: Vector2 = Vector2(width, width / maxf(EnvKit.aspect(id), 0.1)) * 0.5
	mesh.quad(slot, [centre + Vector3(-half.x, -half.y, 0), centre + Vector3(half.x, -half.y, 0), centre + Vector3(half.x, half.y, 0), centre + Vector3(-half.x, half.y, 0)], Vector3(0, 0, 1), [], CARD_UVS)


## A camera-facing painted card (tree, plant, prop) as a child of `root`, base at `pos`.
static func _tree_card(root: Node3D, id: String, pos: Vector3, height: float) -> void:
	if not EnvKit.has(id):
		return
	var card: MeshInstance3D = KitFoliage.card(id, Vector2(height * EnvKit.aspect(id), height), false)
	card.name = "Card_%s_%d" % [id, root.get_child_count()]
	root.add_child(card)
	card.position = pos


# ---- shared pieces --------------------------------------------------------------------------------------------------------------------------


## A tapering limb through `points` (root, branch, strand): tubes between the points, a blob at every joint so the bends read round.
static func _limb(mesh: KitMesh, slot: String, points: Array[Vector3], r0: float, r1: float, segments: int = 8) -> void:
	var count: int = points.size()
	for index: int in range(count - 1):
		var t0: float = float(index) / float(count - 1)
		var t1: float = float(index + 1) / float(count - 1)
		var radius: float = lerpf(r0, r1, (t0 + t1) * 0.5)
		mesh.tube(slot, points[index], points[index + 1], radius, segments, false)
		if index > 0:
			var joint: float = lerpf(r0, r1, t0) * 1.04
			mesh.blob(slot, points[index], Vector3(joint, joint, joint), 3, segments, 0.95)
	var tip: float = r1 * 1.0
	mesh.blob(slot, points[count - 1], Vector3(tip, tip, tip), 3, segments, 0.95)


## A true ellipsoid (`KitMesh.blob` is circular in plan: it ignores radii.z), as lat/long quads; `bottom` cuts it flat below that fraction (-1 whole).
static func _ellipsoid(mesh: KitMesh, slot: String, center: Vector3, radii: Vector3, rings: int = 6, segments: int = 16, bottom: float = -1.0) -> void:
	var start: float = asin(clampf(bottom, -1.0, 1.0))
	for ring: int in range(rings):
		var a0: float = lerpf(start, PI * 0.5, float(ring) / float(rings))
		var a1: float = lerpf(start, PI * 0.5, float(ring + 1) / float(rings))
		for seg: int in range(segments):
			var b0: float = TAU * float(seg) / float(segments)
			var b1: float = TAU * float(seg + 1) / float(segments)
			var corners: Array[Vector3] = []
			for pair: Vector2 in [Vector2(a0, b0), Vector2(a0, b1), Vector2(a1, b1), Vector2(a1, b0)]:
				corners.append(center + Vector3(cos(pair.x) * cos(pair.y) * radii.x, sin(pair.x) * radii.y, cos(pair.x) * sin(pair.y) * radii.z))
			var mid_a: float = (a0 + a1) * 0.5
			var mid_b: float = (b0 + b1) * 0.5
			var outward: Vector3 = Vector3(cos(mid_a) * cos(mid_b) / radii.x, sin(mid_a) / radii.y, cos(mid_a) * sin(mid_b) / radii.z).normalized()
			if ring == rings - 1:
				mesh.tri(slot, [corners[0], corners[1], corners[2]], outward)
			else:
				mesh.quad(slot, corners, outward)


## A drape of hanging moss: two crossed strips tapering from `width` at the top to a point `length` below (both faces), turned by `yaw`.
static func _drape(mesh: KitMesh, slot: String, top: Vector3, length: float, width: float, yaw: float) -> void:
	for turn: float in [0.0, PI * 0.5]:
		var across: Vector3 = Vector3(cos(yaw + turn), 0, sin(yaw + turn)) * width * 0.5
		var normal: Vector3 = Vector3.UP.cross(across).normalized()
		var tip: Vector3 = top - Vector3(0, length, 0) + across * 0.3
		mesh.tri(slot, [top - across, top + across, tip], normal)
		mesh.tri(slot, [top + across, top - across, tip], -normal)


## A mushroom: a pale stem and a glowing cap (the Rot's mutated fungi). `up` tilts it off the surface it grows from.
static func _mushroom(mesh: KitMesh, base: Vector3, size: float, up: Vector3 = Vector3.UP) -> void:
	var top: Vector3 = base + up.normalized() * size * 0.75
	mesh.tube("stem", base, top, size * 0.16, 6, false)
	mesh.lathe("fungus", top - Vector3(0, size * 0.08, 0), [Vector2(size * 0.62, 0.0), Vector2(size * 0.56, size * 0.16), Vector2(size * 0.32, size * 0.32), Vector2(0.0, size * 0.36)], 10, 0.9, true, true)


## A heart shape (the classic curve) as a fan of triangles facing `normal` in the plane through `center`; `w` x `h` metres.
static func _heart(mesh: KitMesh, slot: String, center: Vector3, w: float, h: float, normal: Vector3) -> void:
	var right: Vector3 = Vector3.UP.cross(normal).normalized() * -1.0
	var steps: int = 28
	var middle: Vector3 = center + Vector3(0, -h * 0.05, 0)
	var previous: Vector3 = Vector3.ZERO
	for index: int in range(steps + 1):
		var t: float = TAU * float(index) / float(steps)
		var sx: float = 16.0 * pow(sin(t), 3.0)
		var sy: float = 13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t)
		var point: Vector3 = center + right * (sx / 32.0 * w) + Vector3(0, (sy + 2.5) / 29.0 * h, 0)
		if index > 0:
			mesh.tri(slot, [middle, previous, point], normal)
		previous = point


## The light inside a heart-shaped hollow: a heart fan whose vertex colour runs from bright at a core low in the middle to dark at the rim, on an unshaded
## glow (`heart_glow`), so it reads as light deep in a hollow rather than a flat icon; the material's colour sets the hue and pulses.
static func _glow_heart(mesh: KitMesh, slot: String, center: Vector3, w: float, h: float, normal: Vector3) -> void:
	var right: Vector3 = Vector3.UP.cross(normal).normalized() * -1.0
	var steps: int = 32
	var core: Vector3 = center + Vector3(0, -h * 0.12, 0) + normal * 0.02
	var bright: Color = Color(1.0, 1.0, 1.0)
	var dark: Color = Color(0.04, 0.02, 0.06)
	var mid_ring: Array[Vector3] = []
	var rim_ring: Array[Vector3] = []
	for index: int in range(steps + 1):
		var t: float = TAU * float(index) / float(steps)
		var sx: float = 16.0 * pow(sin(t), 3.0)
		var sy: float = 13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t)
		var point: Vector3 = center + right * (sx / 32.0 * w) + Vector3(0, (sy + 2.5) / 29.0 * h, 0)
		rim_ring.append(point)
		mid_ring.append(core.lerp(point, 0.45))
	var middle: Color = Color(0.42, 0.3, 0.48)
	for index: int in range(1, steps + 1):
		mesh.tri(slot, [core, mid_ring[index - 1], mid_ring[index]], normal, [bright, middle, middle])
		mesh.quad(slot, [mid_ring[index - 1], mid_ring[index], rim_ring[index], rim_ring[index - 1]], normal, [middle, middle, dark, dark])


## The unshaded vertex-coloured glow of a heart hollow (its colour is the hue; the builder pulses it, `set_freed` turns it green).
static func heart_glow(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true
	material.albedo_color = color
	material.set_meta("base_color", color)
	material.set_meta(PaintedClasses.META_NO_PAINT, true)
	material.set_meta(StyleToon.META_NO_TOON, true)
	return material


## The Rotheart trunk's radius at height `y` (metres, the 46 m profile scaled by `s`).
static func _trunk_r(y: float, s: float) -> float:
	var local: float = y / s
	for index: int in range(TRUNK.size() - 1):
		var a: Vector2 = TRUNK[index]
		var b: Vector2 = TRUNK[index + 1]
		if local <= b.y:
			return lerpf(a.x, b.x, clampf((local - a.y) / maxf(b.y - a.y, 0.01), 0.0, 1.0)) * s
	return TRUNK[TRUNK.size() - 1].x * s


## A point on the trunk's surface at compass angle `angle` (radians, 0 = +x, PI/2 = +z the front) and height `y`, `out` metres proud of it.
static func _on_trunk(angle: float, y: float, s: float, out: float = 0.0) -> Vector3:
	var r: float = _trunk_r(y, s) + out
	return Vector3(cos(angle) * r, y, sin(angle) * r)


# ---- the Rotheart -----------------------------------------------------------------------------------------------------------------------


## The main dungeon's goal (DUMP-HERO-ROTHEART), after the concept and the WETLANDS paint-over: a colossal knot of root strands twisting round a broad
## trunk; a heart-shaped hollow in its front, layered dark rim to deep violet to a bright heart, with violet motes drifting out and a slow pulse (meta
## "heart": its glow material, the builder animates it and its real light); violet veins cracking out across the bark; mutated fungi climbing the strands,
## the arms and the roots; a wide umbrella canopy of green and gold clumps on long twisting arms with hanging moss and a little wisteria; swallowed
## scrap (doors, a wagon wheel, pipes, a treehouse lookout in the crown); arching roots and long approach roots spilling outward over a corrupted mound
## toward the player's approach (meta "approach": the local point the longest ones reach, where the root gate stands). Awe and sadness, not menace: the
## canopy is still green and gold, the violet is the sickness in it. A view beyond the north rim (nothing blocks).
static func _rotheart(root: Node3D, mesh: KitMesh, size: Vector3, circles: Array[Vector3], lights: Array[Dictionary]) -> void:
	var s: float = size.y / 46.0
	var wide: float = size.x / 44.0 * 0.75
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 1201
	var front: float = PI * 0.5
	# the mound it grows from: corrupted soil sinking under the land's north rim, moss and violet lumps on it
	_ellipsoid(mesh, "corrupt_ground", Vector3(0, -6.0 * s, 4.0 * s), Vector3(size.x * 0.66, 6.8 * s, size.z * 0.7), 5, 22, 0.0)
	for index: int in range(14):
		var a: float = rng.randf() * TAU
		var r: float = rng.randf_range(11.0, 24.0) * s
		_ellipsoid(mesh, ["leaf_dark", "bark_violet", "leaf"][index % 3], Vector3(cos(a) * r, -0.2 * s, sin(a) * r + 4.0 * s), Vector3(3.0, 1.0, 2.4) * s * rng.randf_range(0.7, 1.3), 3, 9, 0.0)
	# the trunk core and the strands twisting round it (none across the hollow in front)
	mesh.lathe("bark", Vector3.ZERO, _scaled(TRUNK, s), 18, 0.75, false, true)
	for index: int in range(11):
		var a0: float = front + deg_to_rad(44.0 + 27.0 * float(index))
		var twist: float = 1.0 if a0 - front < PI else -1.0
		var points: Array[Vector3] = []
		for step: int in range(7):
			var t: float = float(step) / 6.0
			var y: float = t * 19.5 * s
			var a: float = a0 + twist * t * t * 1.1
			points.append(_on_trunk(a, y, s, (1.5 - t * 0.6) * s))
		points[0] = Vector3(cos(a0) * 10.5 * s, 0.3 * s, sin(a0) * 10.5 * s)
		_limb(mesh, ["bark", "bark_dark", "bark", "bark_violet"][index % 4], points, 2.6 * s, 1.5 * s, 9)
	# moss on the bark: flat green patches on the strands
	for index: int in range(16):
		var a: float = front + deg_to_rad(rng.randf_range(40.0, 320.0))
		var y: float = rng.randf_range(2.0, 18.0) * s
		_ellipsoid(mesh, "leaf" if index % 2 == 0 else "leaf_dark", _on_trunk(a, y, s, 1.6 * s), Vector3(1.8, 1.1, 1.8) * s, 3, 8, 0.0)
	# the heart-shaped hollow: two great strands parting round it and meeting over it like lips; the rim, the deep violet, the bright heart, motes
	var heart_y: float = 9.8 * s
	var heart_z: float = _trunk_r(heart_y, s)
	for side: float in [-1.0, 1.0]:
		var lip: Array[Vector3] = [
			Vector3(side * 6.6 * s, 0.3 * s, 7.6 * s), Vector3(side * 6.4 * s, 4.0 * s, heart_z + 0.9 * s), Vector3(side * 6.2 * s, 9.0 * s, heart_z + 1.3 * s),
			Vector3(side * 4.6 * s, 14.0 * s, heart_z + 1.1 * s), Vector3(side * 1.2 * s, 16.5 * s, heart_z + 0.2 * s), Vector3(-side * 2.0 * s, 19.0 * s, heart_z - 1.4 * s),
		]
		_limb(mesh, "bark", lip, 2.3 * s, 1.5 * s, 10)
		# a root strand crossing the bottom of the hollow, as in the concept
		_limb(mesh, "bark_dark", [Vector3(side * 5.4 * s, 4.0 * s, heart_z + 1.0 * s), Vector3(side * 2.0 * s, 6.2 * s, heart_z + 1.2 * s), Vector3(-side * 1.0 * s, 5.0 * s, heart_z + 1.4 * s)], 0.9 * s, 0.5 * s, 7)
	_heart(mesh, "bark_dark", Vector3(0, heart_y, heart_z + 0.4 * s), 11.5 * s, 13.0 * s, Vector3(0, 0, 1))
	_glow_heart(mesh, "heart", Vector3(0, heart_y + 0.2 * s, heart_z + 0.55 * s), 9.8 * s, 11.2 * s, Vector3(0, 0, 1))
	var motes: CPUParticles3D = CPUParticles3D.new()
	motes.name = "HeartMotes"
	motes.amount = 18
	motes.lifetime = 7.0
	motes.preprocess = 7.0
	motes.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	motes.emission_box_extents = Vector3(3.0, 3.5, 0.5) * s
	motes.direction = Vector3(0.0, 0.6, 1.0)
	motes.spread = 35.0
	motes.initial_velocity_min = 0.4
	motes.initial_velocity_max = 1.2
	motes.gravity = Vector3(0, 0.05, 0)
	motes.scale_amount_min = 0.6
	motes.scale_amount_max = 1.4
	var mote_mesh: SphereMesh = SphereMesh.new()
	mote_mesh.radius = 0.14 * s
	mote_mesh.height = 0.28 * s
	mote_mesh.radial_segments = 6
	mote_mesh.rings = 3
	motes.mesh = mote_mesh
	motes.material_override = mesh_material(mesh, "veins")
	motes.position = Vector3(0, heart_y, heart_z + 1.2 * s)
	root.add_child(motes)
	# violet veins cracking out from the hollow across the bark
	for index: int in range(14):
		var a: float = front + deg_to_rad(rng.randf_range(-80.0, 80.0))
		var y0: float = heart_y + rng.randf_range(-4.0, 4.0) * s
		var points: Array[Vector3] = []
		for step: int in range(5):
			var t: float = float(step) / 4.0
			var aa: float = lerpf(front + (a - front) * 0.3, a, t)
			points.append(_on_trunk(aa, y0 + (rng.randf_range(-1.0, 1.0) + (t * 7.0 if index % 2 == 0 else -t * 6.0)) * s, s, 0.3 * s))
		_limb(mesh, "veins", points, 0.2 * s, 0.07 * s, 4)
	# swallowed scrap: doors half sunk in the bark, a wagon wheel, pipes threading the strands (none across the hollow)
	for index: int in range(6):
		var a: float = front + deg_to_rad([-100.0, 95.0, 150.0, -150.0, 125.0, -125.0][index])
		var y: float = [6.0, 13.0, 4.0, 11.0, 17.0, 15.5][index] * s
		var at: Vector3 = _on_trunk(a, y, s, 0.4 * s)
		var basis: Basis = Basis.looking_at(Vector3(cos(a), 0, sin(a)), Vector3.UP).rotated(Vector3(cos(a), 0, sin(a)), rng.randf_range(-0.5, 0.5))
		mesh.box("doors", at, Vector3(2.0, 3.6, 0.35) * s, basis, 0.03, 0.9)
	var wheel_a: float = front + deg_to_rad(-62.0)
	var wheel_axis: Vector3 = Vector3(cos(wheel_a), 0.0, sin(wheel_a))
	var wheel_at: Vector3 = _on_trunk(wheel_a, 4.5 * s, s, 0.8 * s)
	mesh.tube("rust", wheel_at, wheel_at + wheel_axis * 0.4 * s, 1.9 * s, 16, true)
	mesh.tube("wood_dark", wheel_at + wheel_axis * 0.2 * s, wheel_at + wheel_axis * 0.7 * s, 0.45 * s, 8, true)
	for spoke: int in range(6):
		var a: float = TAU * float(spoke) / 6.0
		var out: Vector3 = (Vector3.UP.cross(wheel_axis).normalized() * cos(a) + Vector3.UP * sin(a)) * 1.7 * s
		mesh.tube("wood_dark", wheel_at + wheel_axis * 0.45 * s, wheel_at + wheel_axis * 0.45 * s + out, 0.12 * s, 4, false)
	for index: int in range(3):
		var a: float = front + deg_to_rad(-150.0 + 110.0 * float(index))
		var p0: Vector3 = _on_trunk(a, (3.0 + 7.0 * float(index)) * s, s, 1.6 * s)
		var p1: Vector3 = _on_trunk(a + 0.45, (8.0 + 7.0 * float(index)) * s, s, 2.2 * s)
		mesh.tube("rust_dark", p0, p1, 0.5 * s, 8, true)
	# the crown: a central leader and seven long twisting arms, sub-branches, the canopy clumps at their ends
	var crown_base: float = 16.0 * s
	var tips: Array[Vector3] = []
	var arms: Array[Vector3] = [Vector3(-6.0, 27.0, 0.2), Vector3(186.0, 27.0, 0.2), Vector3(28.0, 26.0, 0.24), Vector3(152.0, 26.0, 0.24), Vector3(60.0, 18.0, 0.3), Vector3(120.0, 18.0, 0.3), Vector3(228.0, 22.0, 0.28), Vector3(312.0, 22.0, 0.28), Vector3(270.0, 15.0, 0.4)]
	for arm: Vector3 in arms:
		var a: float = deg_to_rad(arm.x)
		var direction: Vector3 = Vector3(cos(a), 0, sin(a))
		var side: Vector3 = Vector3(-direction.z, 0, direction.x)
		var length: float = arm.y * s * wide
		var start: Vector3 = Vector3(direction.x * 3.5 * s, crown_base, direction.z * 3.5 * s)
		var bend: float = rng.randf_range(-2.5, 2.5) * s
		var p1: Vector3 = start + direction * length * 0.25 + Vector3(0, length * arm.z * 0.8, 0) + side * bend
		var p2: Vector3 = start + direction * length * 0.55 + Vector3(0, length * arm.z * 0.95, 0) - side * bend
		var end: Vector3 = start + direction * length + Vector3(0, length * arm.z * 0.45, 0)
		_limb(mesh, "bark", [start, p1, p2, end], 2.6 * s, 0.8 * s, 9)
		var sub_side: Vector3 = side * (1.0 if int(arm.x) % 2 == 0 else -1.0)
		var sub_end: Vector3 = p2 + (direction * 0.35 + sub_side * 0.65).normalized() * 8.0 * s + Vector3(0, 5.0 * s, 0)
		_limb(mesh, "bark_dark", [p2, p2 + (sub_end - p2) * 0.5 + Vector3(0, 1.2 * s, 0), sub_end], 1.1 * s, 0.5 * s, 7)
		tips.append(end)
		tips.append(sub_end)
		tips.append(p1 + Vector3(0, 3.0 * s, 0) - side * 2.0 * s)
	var leader_top: Vector3 = Vector3(0.5 * s, 30.0 * s, -2.0 * s)
	_limb(mesh, "bark", [Vector3(0, crown_base, -0.5 * s), Vector3(-1.4 * s, 22.0 * s, -1.0 * s), Vector3(1.2 * s, 26.5 * s, -1.5 * s), leader_top], 2.8 * s, 1.1 * s, 9)
	tips.append(leader_top)
	tips.append(Vector3(-9.0 * s, 28.0 * s, 2.0 * s))
	tips.append(Vector3(9.5 * s, 27.0 * s, -3.0 * s))
	tips.append(Vector3(0.0 * s, 25.0 * s, 9.0 * s))
	tips.append(Vector3(-3.0 * s, 33.0 * s, -6.0 * s))
	tips.append(Vector3(14.0 * s, 24.0 * s, 8.0 * s))
	tips.append(Vector3(-14.0 * s, 24.0 * s, 8.0 * s))
	for index: int in range(tips.size()):
		var tip: Vector3 = tips[index]
		var big: float = (7.6 if tip.y > 26.0 * s else 6.2) * s * rng.randf_range(0.85, 1.15)
		# a clump: a dark underside, a body of four to six overlapping lobes, light lobes on top where the low sun catches it
		_ellipsoid(mesh, "leaf_dark", tip + Vector3(0, -0.6 * s, 0), Vector3(big * 1.0, big * 0.5, big * 0.95), 3, 10, -0.3)
		var lobes: int = 5 + index % 2
		for lobe: int in range(lobes):
			var a: float = TAU * float(lobe) / float(lobes) + rng.randf() * 0.5
			var r: float = big * rng.randf_range(0.35, 0.7)
			var lift: float = big * rng.randf_range(0.0, 0.3)
			_ellipsoid(mesh, "leaf", tip + Vector3(cos(a) * r, lift, sin(a) * r * 0.9), Vector3(big * 0.6, big * 0.55, big * 0.56), 4, 9, -0.5)
		for lobe: int in range(3):
			var a: float = TAU * float(lobe) / 3.0 + float(index)
			_ellipsoid(mesh, "leaf_light", tip + Vector3(cos(a) * big * 0.3 - 0.8 * s, big * 0.42, sin(a) * big * 0.3 + 0.6 * s), Vector3(big * 0.42, big * 0.4, big * 0.4), 3, 8, -0.3)
		# hanging moss under each clump, a little wisteria
		for strand: int in range(9):
			var a: float = rng.randf() * TAU
			var r: float = rng.randf_range(0.3, 1.0) * big
			var length: float = rng.randf_range(2.0, 7.0) * s
			var top_point: Vector3 = tip + Vector3(cos(a) * r, -big * 0.3, sin(a) * r)
			_drape(mesh, "hanging_moss" if strand % 5 != 0 else "wisteria", top_point, length, rng.randf_range(0.5, 1.1) * s, rng.randf() * PI)
		# art import Oct 22: a painted leaf mass (DUMP-TREE-CANOPY-01..06, cycled) on the clump's front, about twice its size, so the crown reads as
		# the concept's layered painted canopy; the lobes stay behind it as the body (and are the whole crown while the sheet has no art). No rng: the
		# fungi and roots after this keep their draws
		_canopy_card(mesh, "DUMP-TREE-CANOPY-%02d" % (1 + index % 6), tip + Vector3(0, big * 0.1, big * 0.85), big * 2.1)
	# the fungi climbing it: on the strands, the lips of the hollow, the arms and the roots
	var shrooms: Array[Vector4] = [
		Vector4(-78.0, 3.0, 1.4, 3.0), Vector4(72.0, 7.0, 1.3, 2.3), Vector4(-42.0, 15.0, 1.4, 2.1), Vector4(44.0, 16.0, 1.4, 2.5), Vector4(118.0, 13.0, 1.6, 1.8),
		Vector4(-118.0, 9.0, 1.6, 2.1), Vector4(28.0, 1.4, 2.6, 1.7), Vector4(-26.0, 1.2, 2.8, 1.4), Vector4(170.0, 17.0, 1.6, 2.6), Vector4(-62.0, 18.5, 2.4, 3.2),
		Vector4(62.0, 19.0, 2.4, 2.8), Vector4(98.0, 5.0, 1.4, 1.6), Vector4(-95.0, 15.0, 1.6, 1.5),
	]
	for shroom: Vector4 in shrooms:
		var a: float = front + deg_to_rad(shroom.x)
		var base: Vector3 = _on_trunk(a, shroom.y * s, s, shroom.z * s)
		_mushroom(mesh, base, shroom.w * s, Vector3(cos(a) * 0.5, 1.0, sin(a) * 0.5))
		if int(shroom.x) % 3 == 0:
			_mushroom(mesh, base + Vector3(cos(a + 0.3), 0.2, sin(a + 0.3)) * shroom.w * 0.6 * s, shroom.w * 0.55 * s, Vector3(cos(a) * 0.8, 1.0, sin(a) * 0.8))
	# the treehouse lookout in the crown: a mossy plank shack on a platform with a tin roof, a lit window and a rag flag
	var house: Vector3 = Vector3(7.0 * s, 22.5 * s, -4.5 * s)
	mesh.box("plank", house + Vector3(0, -0.2 * s, 0), Vector3(5.6, 0.4, 5.0) * s, Basis.IDENTITY, 0.03)
	mesh.box("mosswood", house + Vector3(0, 1.7 * s, 0), Vector3(3.6, 3.4, 3.2) * s, Basis.IDENTITY, 0.03, 0.85)
	for sz: float in [-1.0, 1.0]:
		mesh.box("tin", house + Vector3(0, 4.0 * s, sz * 0.95 * s), Vector3(4.2 * s, 0.15 * s, 2.3 * s), Basis(Vector3.RIGHT, sz * 0.5), 0.0)
	mesh.box("window_glow", house + Vector3(0, 1.9 * s, 1.62 * s), Vector3(1.1, 1.0, 0.06) * s, Basis.IDENTITY, 0.0)
	mesh.tube("wood_dark", house + Vector3(2.2 * s, 0, 2.2 * s), house + Vector3(2.2 * s, 6.5 * s, 2.2 * s), 0.13 * s, 5, true)
	mesh.box("cloth_cream", house + Vector3(2.9 * s, 5.8 * s, 2.2 * s), Vector3(1.4, 0.9, 0.05) * s, Basis.IDENTITY, 0.0)
	# the roots: arching loops at the sides like the concept, short ones behind, and the long approach roots running south over the mound toward the gate
	var roots: Array[Vector4] = [
		Vector4(22.0, 21.0, 5.5, 2.4), Vector4(158.0, 21.0, 5.5, 2.4), Vector4(48.0, 18.0, 3.0, 2.0), Vector4(132.0, 18.0, 3.0, 2.0),
		Vector4(-6.0, 22.0, 0.0, 2.2), Vector4(186.0, 22.0, 0.0, 2.2), Vector4(-58.0, 15.0, 0.0, 1.9), Vector4(238.0, 15.0, 0.0, 1.9),
		Vector4(-90.0, 13.0, 0.0, 1.8), Vector4(10.0, 26.0, 0.0, 1.6), Vector4(170.0, 26.0, 0.0, 1.6),
	]
	for spec: Vector4 in roots:
		var a: float = deg_to_rad(spec.x)
		var direction: Vector3 = Vector3(cos(a), 0, sin(a))
		var side: Vector3 = Vector3(-direction.z, 0, direction.x)
		var length: float = spec.y * s * wide
		var wiggle: float = rng.randf_range(-1.8, 1.8) * s
		var points: Array[Vector3] = [
			direction * 7.5 * s + Vector3(0, 3.6 * s, 0), direction * 11.5 * s + Vector3(0, 1.4 * s, 0),
			direction * length * 0.55 + side * wiggle + Vector3(0, 0.4 * s + spec.z * s, 0),
			direction * length * 0.8 - side * wiggle * 0.6 + Vector3(0, 0.6 * s + spec.z * 0.35 * s, 0), direction * length + Vector3(0, -0.8 * s, 0),
		]
		_limb(mesh, "bark" if int(spec.x) % 2 == 0 else "bark_violet", points, spec.w * s, 0.5 * s, 9)
	var approach: Vector3 = Vector3(0, 0, size.z * 0.5 + 4.5 * s)
	root.set_meta("approach", approach)
	for index: int in range(4):
		var side: float = -1.0 if index % 2 == 0 else 1.0
		var spread: float = (2.2 if index < 2 else 7.5) * side * s
		var start: Vector3 = Vector3(side * (4.0 + float(index >> 1) * 3.0) * s, 2.6 * s, 8.5 * s)
		var points: Array[Vector3] = [start]
		for step: int in range(1, 6):
			var t: float = float(step) / 5.0
			var z: float = lerpf(start.z, approach.z + (2.0 if index < 2 else -1.0) * s, t)
			var x: float = lerpf(start.x, spread, t) + sin(t * PI * 2.0 + float(index)) * 1.4 * s
			var hump: float = (sin(t * PI * 2.5 + float(index) * 0.7) * 0.9 + 0.3) * s
			points.append(Vector3(x, maxf(hump, -0.2 * s) + (1.0 - t) * 1.0 * s, z))
		_limb(mesh, "bark" if index < 2 else "bark_dark", points, (2.0 if index < 2 else 1.5) * s, 0.7 * s, 9)
		var vein: Array[Vector3] = []
		for point: Vector3 in points.slice(1):
			vein.append(point + Vector3(0, (1.4 if index < 2 else 1.0) * s, 0))
		_limb(mesh, "veins", vein, 0.15 * s, 0.07 * s, 4)
		_mushroom(mesh, points[2] + Vector3(0, 1.4 * s, 0), 1.4 * s)
		_mushroom(mesh, points[4] + Vector3(side * 0.6 * s, 1.0 * s, 0), 0.9 * s)
	# the heart's light (made real by the scene, pulsed by the builder) and a softer fill under the canopy
	lights.append({"pos": Vector3(0, heart_y, heart_z + 6.0 * s), "color": VIOLET, "range": 30.0 * s, "energy": 2.4, "kind": "heart"})
	root.set_meta("heart", mesh_material(mesh, "heart"))
	root.set_meta("corruption", {"heart": mesh_material(mesh, "heart"), "veins": mesh_material(mesh, "veins"), "fungus": mesh_material(mesh, "fungus"), "hollow": mesh_material(mesh, "hollow"), "wisteria": mesh_material(mesh, "wisteria")})
	circles.clear()


static func _scaled(profile: Array[Vector2], s: float) -> Array[Vector2]:
	var result: Array[Vector2] = []
	for point: Vector2 in profile:
		result.append(point * s)
	return result


## The material registered for a KitMesh slot (the glows the builder animates).
static func mesh_material(mesh: KitMesh, slot: String) -> StandardMaterial3D:
	return mesh.material_of(slot) as StandardMaterial3D


## The Rotheart freed (`freed` true): the heart, veins and fungi turn a soft warm green and dim, the hollow loses its violet; false restores the Rot.
static func set_freed(node: Node3D, freed: bool) -> void:
	if node == null or not node.has_meta("corruption"):
		return
	var glows: Dictionary = node.get_meta("corruption") as Dictionary
	var colors: Dictionary = {
		"veins": [FREED_GREEN.darkened(0.2), 0.5] if freed else [VIOLET, 1.6],
		"fungus": [Color("d8e8a0"), 0.25] if freed else [Color("c080f0"), 0.55], "hollow": [Color("3a5a2a"), 0.5] if freed else [VIOLET_DEEP, 0.9],
		"wisteria": [Color("f0d8f0"), 0.2] if freed else [Color("a070e0"), 0.45],
	}
	for key: String in colors.keys():
		var material: StandardMaterial3D = glows.get(key) as StandardMaterial3D
		if material == null:
			continue
		var pair: Array = colors[key] as Array
		material.albedo_color = pair[0] as Color
		material.emission = pair[0] as Color
		material.emission_energy_multiplier = float(pair[1])
		material.set_meta("base_energy", float(pair[1]))
	var heart: StandardMaterial3D = glows.get("heart") as StandardMaterial3D
	if heart != null:
		var hue: Color = Color(0.75, 1.5, 0.6) if freed else Color(1.15, 0.55, 1.55)
		heart.albedo_color = hue
		heart.set_meta("base_color", hue)
	node.set_meta("freed", freed)


# ---- Junk Mountain ------------------------------------------------------------------------------------------------------------------------


## The junk peaks' landmark (DUMP-HERO-JUNK-MOUNTAIN), a view beyond the north-east corner: a towering mound of doors, tin, wheels, crates and barrels
## grown over with green, a plank stair zig-zagging up the front with rope rails and lanterns, a lantern-lit shack with a little windmill (meta "spinner")
## and a rag flag on the summit, trees and flower crates on its shoulders.
static func _junk_mountain(root: Node3D, mesh: KitMesh, size: Vector3, circles: Array[Vector3], lights: Array[Dictionary]) -> void:
	var rx: float = size.x * 0.5
	var ry: float = size.y * 0.8
	var rz: float = size.z * 0.5
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 2202
	_cone(mesh, "soil", rx, ry, rz, 8, 24)
	# junk on its skin: rings of pieces from the foot up, thinning toward the summit
	for ring: int in range(8):
		var v: float = (float(ring) + 0.5) / 8.0
		var y: float = v * ry * 0.96
		var shrink: float = _cone_k(v)
		var count: int = int(lerpf(30.0, 8.0, v))
		for index: int in range(count):
			var a: float = TAU * (float(index) + rng.randf() * 0.6) / float(count) + float(ring) * 0.37
			var point: Vector3 = Vector3(cos(a) * rx * shrink, y, sin(a) * rz * shrink)
			var normal: Vector3 = (Vector3(point.x / (rx * rx), 0.0, point.z / (rz * rz)).normalized() + Vector3(0, 0.55, 0)).normalized()
			var basis: Basis = Basis.looking_at(normal, Vector3.UP if absf(normal.y) < 0.95 else Vector3.FORWARD).rotated(normal, rng.randf_range(-0.6, 0.6))
			var kind: int = (index + ring * 3) % 7
			match kind:
				0, 4:
					mesh.box("doors", point + normal * 0.3, Vector3(3.4, 5.0, 0.4), basis, 0.03, 0.85)
				1:
					mesh.box("tin", point + normal * 0.2, Vector3(4.4, 3.0, 0.25), basis, 0.0, 0.85)
				2:
					mesh.box("plank", point + normal * 0.8, Vector3(2.4, 2.2, 2.4), basis, 0.05, 0.85)
				3:
					mesh.tube("rust", point, point + normal * 0.5, rng.randf_range(1.4, 2.4), 12, true)
				5:
					mesh.blob("leaf" if ring % 2 == 0 else "leaf_light", point + normal * 0.6, Vector3(3.0, 2.0, 3.0), 3, 8, 0.95)
				6:
					mesh.lathe("metal", point - normal * 0.2, [Vector2(0.8, 0.0), Vector2(0.85, 1.0), Vector2(0.8, 2.0)], 10, 0.9, false, true)
	# the stair: switchbacks up the front, each flight a run of planks with rope rails on posts and a lantern at its turn
	var flights: Array[Vector2] = [Vector2(-0.55, 0.0), Vector2(0.35, 0.18), Vector2(-0.3, 0.38), Vector2(0.2, 0.56), Vector2(-0.12, 0.74), Vector2(0.0, 0.9)]
	for index: int in range(flights.size() - 1):
		var a: Vector2 = flights[index]
		var b: Vector2 = flights[index + 1]
		var start: Vector3 = _mound_front(a.x * rx, a.y * ry, rx, ry, rz, 0.5)
		var finish: Vector3 = _mound_front(b.x * rx, b.y * ry, rx, ry, rz, 0.5)
		var run: Vector3 = finish - start
		var steps: int = int(run.length() / 1.1)
		for step: int in range(steps):
			var t: float = (float(step) + 0.5) / float(steps)
			var at: Vector3 = start + run * t
			at = _mound_front(at.x, at.y, rx, ry, rz, 0.55)
			var heading: Basis = Basis(Vector3.UP, atan2(run.x, run.z))
			mesh.box("plank", at, Vector3(2.4, 0.25, 1.0), heading, 0.02, 0.92)
			if step % 3 == 0:
				var post: Vector3 = at + heading * Vector3(1.3, 0, 0)
				mesh.tube("wood_dark", post, post + Vector3(0, 1.2, 0), 0.08, 5, true)
		mesh.tube("rope", start + Vector3(0, 1.1, 0) + Vector3(0, 0, 0.6), finish + Vector3(0, 1.1, 0.6), 0.06, 4, false)
		mesh.box("lantern", finish + Vector3(1.4, 1.8, 0.3), Vector3(0.45, 0.6, 0.45), Basis.IDENTITY, 0.05)
		mesh.tube("wood_dark", finish + Vector3(1.4, 0, 0.3), finish + Vector3(1.4, 1.5, 0.3), 0.08, 5, true)
	# the summit shack, its lit windows, the little windmill and the rag flag
	var top: Vector3 = Vector3(0, ry * 0.97, 0)
	mesh.box("plank", top + Vector3(0, 0.1, 0), Vector3(8.0, 0.4, 6.0), Basis.IDENTITY, 0.03)
	mesh.box("mosswood", top + Vector3(0, 2.0, -0.5), Vector3(5.2, 3.6, 4.0), Basis.IDENTITY, 0.03, 0.85)
	for sz: float in [-1.0, 1.0]:
		mesh.box("tin", top + Vector3(0, 4.2, -0.5 + sz * 1.15), Vector3(6.0, 0.18, 2.7), Basis(Vector3.RIGHT, sz * 0.5), 0.0)
	for wx: float in [-1.4, 1.4]:
		mesh.box("window_glow", top + Vector3(wx, 2.2, 1.52), Vector3(1.0, 1.0, 0.06), Basis.IDENTITY, 0.0)
	for corner: float in [-1.0, 1.0]:
		mesh.tube("wood_dark", top + Vector3(corner * 3.8, 0.2, 2.8), top + Vector3(corner * 3.8, 1.4, 2.8), 0.1, 5, true)
	mesh.tube("rope", top + Vector3(-3.8, 1.2, 2.8), top + Vector3(3.8, 1.2, 2.8), 0.06, 4, false)
	var mast: Vector3 = top + Vector3(2.0, 4.0, -1.2)
	mesh.tube("wood_dark", mast, mast + Vector3(0, 3.6, 0), 0.14, 6, true)
	var flag_pole: Vector3 = top + Vector3(-3.2, 0.2, -1.5)
	mesh.tube("wood_dark", flag_pole, flag_pole + Vector3(0, 6.5, 0), 0.1, 5, true)
	mesh.box("cloth_cream", flag_pole + Vector3(1.2, 5.6, 0), Vector3(2.4, 1.4, 0.05), Basis(Vector3.FORWARD, -0.08), 0.0)
	lights.append({"pos": top + Vector3(0, 2.2, 2.2), "color": WARM, "range": 7.0, "energy": 1.2, "kind": "lantern"})
	# trees and flower crates on its shoulders (painted cards)
	var cards: Array[Vector4] = [Vector4(-0.62, 0.3, 0.0, 6.0), Vector4(0.6, 0.25, 1.0, 5.5), Vector4(-0.4, 0.62, 1.0, 4.6), Vector4(0.42, 0.55, 0.0, 5.0), Vector4(-0.8, 0.08, 2.0, 1.6), Vector4(0.75, 0.1, 2.0, 1.6), Vector4(-0.2, 0.2, 2.0, 1.4), Vector4(0.15, 0.45, 2.0, 1.4)]
	for card: Vector4 in cards:
		var at: Vector3 = _mound_front(card.x * rx, card.y * ry, rx, ry, rz, 0.2)
		var id: String = ["DUMP-TREE-OAK", "DUMP-TREE-BIRCH", "DUMP-PLANT-WILD"][int(card.z)]
		_tree_card(root, id, at, card.w)
	var sails: KitMesh = KitMesh.new()
	_materials(sails)
	for blade: int in range(6):
		var a: float = float(blade) * TAU / 6.0
		var tip: Vector3 = Vector3(cos(a), sin(a), 0.0) * 1.8
		sails.tube("wood_dark", Vector3.ZERO, tip, 0.05, 4, true)
		sails.box("rust" if blade % 2 == 0 else "cloth_cream", tip * 0.6 + Vector3(0, 0, 0.05), Vector3(1.0, 0.45, 0.04), Basis(Vector3(0, 0, 1), a), 0.0)
	var spinner: MeshInstance3D = sails.instance("Sails")
	spinner.set_meta(PaintedClasses.META_NO_PAINT, true)
	spinner.position = mast + Vector3(0, 3.6, 0.3)
	root.add_child(spinner)
	root.set_meta("spinner", spinner)
	circles.clear()


## How far out the junk cone reaches at height fraction `v` (0 foot, 1 summit): steep, concave sides like the concept's pyramid of junk.
static func _cone_k(v: float) -> float:
	return pow(clampf(1.0 - v, 0.0, 1.0), 0.85) * 0.94 + 0.06


## The junk cone's skin as quads (elliptical in plan, `_cone_k` in profile), flat-topped where the summit shack stands.
static func _cone(mesh: KitMesh, slot: String, rx: float, ry: float, rz: float, rings: int, segments: int) -> void:
	for ring: int in range(rings):
		var v0: float = float(ring) / float(rings)
		var v1: float = float(ring + 1) / float(rings)
		for seg: int in range(segments):
			var b0: float = TAU * float(seg) / float(segments)
			var b1: float = TAU * float(seg + 1) / float(segments)
			var corners: Array[Vector3] = []
			for pair: Vector2 in [Vector2(v0, b0), Vector2(v0, b1), Vector2(v1, b1), Vector2(v1, b0)]:
				var k: float = _cone_k(pair.x)
				# the foot ring sinks 1.6 m so the cone meets the ground beyond the rim (the far ground lies just under the land)
				corners.append(Vector3(cos(pair.y) * rx * k, pair.x * ry if pair.x > 0.0 else -1.6, sin(pair.y) * rz * k))
			var mid: float = (b0 + b1) * 0.5
			mesh.quad(slot, corners, Vector3(cos(mid) / rx, 0.35 / ry * rx * 0.1, sin(mid) / rz).normalized())
	var top: float = _cone_k(1.0)
	for seg: int in range(segments):
		var b0: float = TAU * float(seg) / float(segments)
		var b1: float = TAU * float(seg + 1) / float(segments)
		mesh.tri(slot, [Vector3(0, ry, 0), Vector3(cos(b0) * rx * top, ry, sin(b0) * rz * top), Vector3(cos(b1) * rx * top, ry, sin(b1) * rz * top)], Vector3.UP)


## A point on the front (+z) of the junk cone at (x, y), `out` metres proud.
static func _mound_front(x: float, y: float, rx: float, ry: float, rz: float, out: float) -> Vector3:
	var k: float = _cone_k(y / ry)
	var inside: float = maxf(0.0, 1.0 - (x * x) / (rx * rx * k * k))
	return Vector3(x, y, rz * k * sqrt(inside) + out)


# ---- the windmill ---------------------------------------------------------------------------------------------------------------------------


## The farm rows' windmill (DUMP-HERO-WINDMILL): a patched eight-sided tower of mossy planks and tin, a tin cap, a sliced door and window, a round lit
## window, a porch with an awning and flower crates, a lantern, a violet root creeping up one side, and four patchwork cloth sails on a separate
## "Sails" child (meta "spinner") that the builder turns slowly.
static func _windmill(root: Node3D, mesh: KitMesh, size: Vector3, circles: Array[Vector3], lights: Array[Dictionary]) -> void:
	var r: float = size.x * 0.46
	var h: float = size.y
	var cap: float = h * 0.72
	mesh.box("stone_dark", Vector3(0, 0.15, 0), Vector3(r * 2.3, 0.3, r * 2.3), Basis.IDENTITY, 0.05, 0.85)
	mesh.lathe("mosswood", Vector3(0, 0.3, 0), [Vector2(r, 0.0), Vector2(r * 0.9, cap * 0.5), Vector2(r * 0.74, cap - 0.3)], 8, 0.85, false, false)
	# tin and door patches on the planks
	for index: int in range(7):
		var a: float = float(index) * 1.1 + 0.3
		var y: float = 1.4 + float(index) * (cap - 2.4) / 7.0
		var rr: float = lerpf(r, r * 0.74, y / cap) + 0.06
		var basis: Basis = Basis(Vector3.UP, -a + PI * 0.5)
		mesh.box("tin" if index % 3 != 1 else "doors", Vector3(cos(a) * rr, y, sin(a) * rr), Vector3(1.0, 1.2, 0.08), basis, 0.0)
	mesh.lathe("tin", Vector3(0, cap, 0), [Vector2(r * 0.95, 0.0), Vector2(r * 0.9, 0.4), Vector2(0.15, h - cap)], 8, 0.9, true, false)
	mesh.lathe("rust_dark", Vector3(0, cap - 0.2, 0), [Vector2(r * 0.82, 0.0), Vector2(r * 0.82, 0.3)], 8, 0.9, false, false)
	# the front: a sliced door, a window, a round lit window above
	_card(mesh, "DUMP-SHEET-DOORS-04", Vector3(0, 0.3, r + 0.08), 2.1, Vector3(0, 0, 1))
	_card(mesh, "DUMP-SHEET-WINDOWS-06", Vector3(0, cap * 0.55 + 0.8, r * 0.86 + 0.12), 1.1, Vector3(0, 0, 1))
	mesh.tube("window_glow", Vector3(0, cap - 1.0, r * 0.76 + 0.05), Vector3(0, cap - 1.0, r * 0.76 + 0.12), 0.45, 10, true)
	mesh.tube("rust", Vector3(0, cap - 1.0, r * 0.76 + 0.0), Vector3(0, cap - 1.0, r * 0.76 + 0.1), 0.58, 10, true)
	# the porch: a plank deck on posts with an awning, flower crates at its ends, a lantern on a bracket
	var porch_z: float = r + 0.9
	mesh.box("plank", Vector3(0, 0.45, porch_z), Vector3(r * 2.6, 0.25, 1.6), Basis.IDENTITY, 0.02, 0.9)
	for px: float in [-1.0, 1.0]:
		mesh.tube("wood_dark", Vector3(px * r * 1.2, 0.0, porch_z + 0.7), Vector3(px * r * 1.2, 2.5, porch_z + 0.7), 0.09, 5, true)
	mesh.quad("cloth_cream", [Vector3(-r * 1.35, 2.6, porch_z + 0.95), Vector3(0.0, 2.6, porch_z + 0.95), Vector3(0.0, 3.1, r * 0.7), Vector3(-r * 1.35, 3.1, r * 0.7)], Vector3(0, 0.8, 0.6).normalized())
	mesh.quad("cloth_rust", [Vector3(0.0, 2.6, porch_z + 0.95), Vector3(r * 1.35, 2.6, porch_z + 0.95), Vector3(r * 1.35, 3.1, r * 0.7), Vector3(0.0, 3.1, r * 0.7)], Vector3(0, 0.8, 0.6).normalized())
	_card(mesh, "DUMP-PLANT-WILD", Vector3(-r * 1.15, 0.55, porch_z + 0.3), 0.95, Vector3(0, 0, 1))
	_card(mesh, "DUMP-PLANT-WILD", Vector3(r * 1.15, 0.55, porch_z + 0.3), 0.95, Vector3(0, 0, 1))
	mesh.tube("wood_dark", Vector3(r * 1.05, 2.4, 0.4), Vector3(r * 1.7, 2.4, 0.4), 0.06, 4, true)
	mesh.box("lantern", Vector3(r * 1.7, 2.0, 0.4), Vector3(0.3, 0.45, 0.3), Basis.IDENTITY, 0.04)
	lights.append({"pos": Vector3(r * 1.7, 2.0, 0.6), "color": WARM, "range": 5.0, "energy": 0.9, "kind": "lantern"})
	# the violet root creeping up its east side (the Rot reaching even here)
	var creep: Array[Vector3] = [Vector3(r * 1.6, 0.0, -0.6), Vector3(r * 1.05, 1.2, -0.2), Vector3(r * 0.98, 2.8, 0.35), Vector3(r * 0.86, 4.4, 0.1), Vector3(r * 0.78, 5.6, -0.4)]
	_limb(mesh, "bark_violet", creep, 0.28, 0.1, 6)
	var vein: Array[Vector3] = []
	for point: Vector3 in creep:
		vein.append(point + Vector3(0.12, 0.1, 0.12))
	_limb(mesh, "veins", vein, 0.06, 0.03, 4)
	_mushroom(mesh, Vector3(r * 1.5, 0.0, 0.2), 0.6)
	_mushroom(mesh, Vector3(r * 1.25, 0.0, 0.7), 0.4)
	circles.append(Vector3(0.0, 0.0, r + 0.2))
	# the sails: a hub, four arms, patchwork cloth on lattice frames
	var sails: KitMesh = KitMesh.new()
	_materials(sails)
	var reach: float = h * 0.47
	sails.lathe("rust", Vector3(0, 0, -0.3), [Vector2(0.38, 0.0), Vector2(0.38, 0.6)], 10, 0.9, true, true)
	var cloths: Array[String] = ["cloth_cream", "cloth_rust", "cloth_green", "cloth_teal"]
	for blade: int in range(4):
		var a: float = float(blade) * PI * 0.5 + 0.35
		var axis: Vector3 = Vector3(cos(a), sin(a), 0.0)
		var across: Vector3 = Vector3(-sin(a), cos(a), 0.0)
		sails.tube("wood_dark", Vector3.ZERO, axis * reach, 0.09, 5, true)
		var inner: float = reach * 0.22
		var corners: Array[Vector3] = [axis * inner, axis * reach, axis * reach + across * 1.5, axis * inner + across * 1.5]
		for index: int in range(4):
			corners[index] += Vector3(0, 0, 0.1)
		sails.quad(cloths[blade], corners, Vector3(0, 0, 1))
		sails.quad(cloths[(blade + 1) % 4], [corners[0] - Vector3(0, 0, 0.02), corners[1] - Vector3(0, 0, 0.02), corners[2] - Vector3(0, 0, 0.02), corners[3] - Vector3(0, 0, 0.02)], Vector3(0, 0, -1))
		for rung: int in range(4):
			var t: float = lerpf(inner, reach, float(rung) / 3.0)
			sails.tube("wood", axis * t + Vector3(0, 0, 0.14), axis * t + across * 1.5 + Vector3(0, 0, 0.14), 0.04, 4, false)
		sails.tube("wood", axis * inner + across * 1.5 + Vector3(0, 0, 0.14), axis * reach + across * 1.5 + Vector3(0, 0, 0.14), 0.05, 4, false)
	var sail_node: MeshInstance3D = sails.instance("Sails")
	sail_node.set_meta(PaintedClasses.META_NO_PAINT, true)
	sail_node.position = Vector3(0.0, cap + 0.2, r * 0.8 + 0.5)
	root.add_child(sail_node)
	root.set_meta("spinner", sail_node)


# ---- the Trash Panda Throne -------------------------------------------------------------------------------------------------------------------


## The side dungeon's landmark (DUMP-HERO-TRASH-PANDA-THRONE), beyond the north-west rim with its stair on the land: three stepped tiers of crates, bins
## and barrels, a broad stair up the middle flanked by raccoon guard statues with lollipop staves, the crowned raccoon king on a bin throne at the top
## with a scepter and a rag cape, rag pennants on poles and rope, lanterns, two little windmills, greenery and flowers, a lit doorway at the base.
static func _throne(root: Node3D, mesh: KitMesh, size: Vector3, circles: Array[Vector3], lights: Array[Dictionary]) -> void:
	var w: float = size.x
	var d: float = size.z
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 3303
	var tiers: Array[Vector3] = [Vector3(w, 2.2, d), Vector3(w * 0.72, 2.2, d * 0.72), Vector3(w * 0.46, 2.0, d * 0.46)]
	# a plinth of packed soil to the ground beyond the rim
	mesh.box("stone_dark", Vector3(0, -1.0, 0), Vector3(w + 0.6, 2.0, d + 0.6), Basis.IDENTITY, 0.05, 0.85)
	var y: float = 0.0
	var back: float = -d * 0.5
	for index: int in range(tiers.size()):
		var tier: Vector3 = tiers[index]
		var center_z: float = back + tier.z * 0.5
		mesh.box("mosswood", Vector3(0, y + tier.y * 0.5, center_z), Vector3(tier.x - 0.4, tier.y, tier.z - 0.4), Basis.IDENTITY, 0.05, 0.85)
		# the tier's face: crates, bins and barrels side by side, the stair gap in the middle
		var front_z: float = center_z + tier.z * 0.5 - 0.6
		var x: float = -tier.x * 0.5 + 0.8
		var slot_index: int = 0
		while x < tier.x * 0.5 - 0.6:
			if absf(x) < 2.6:
				x += 1.2
				continue
			match (slot_index + index) % 3:
				0:
					mesh.box("plank", Vector3(x, y + 0.85, front_z), Vector3(1.6, 1.7, 1.4), Basis(Vector3.UP, rng.randf_range(-0.1, 0.1)), 0.05, 0.85)
				1:
					mesh.lathe("metal", Vector3(x, y, front_z), [Vector2(0.72, 0.0), Vector2(0.78, 1.6), Vector2(0.82, 1.7)], 12, 0.85, false, true)
					mesh.lathe("metal_dark", Vector3(x, y + 1.7, front_z), [Vector2(0.86, 0.0), Vector2(0.5, 0.25), Vector2(0.12, 0.35)], 12, 0.9, false, true)
				2:
					mesh.lathe("wood", Vector3(x, y, front_z), [Vector2(0.6, 0.0), Vector2(0.72, 0.85), Vector2(0.6, 1.7)], 10, 0.85, false, true)
					mesh.lathe("rust_dark", Vector3(x, y + 0.4, front_z), [Vector2(0.68, 0.0), Vector2(0.68, 0.12)], 10, 0.9, false, false)
			if slot_index % 3 == 1:
				mesh.blob("leaf" if slot_index % 2 == 0 else "leaf_light", Vector3(x + 0.4, y + tier.y, front_z - 0.3), Vector3(0.9, 0.5, 0.7), 3, 8, 0.95)
			x += 1.75
			slot_index += 1
		y += tier.y
	# the stair up the middle, from the landing on the land to the top tier
	var stair_foot: float = d * 0.5 + 4.6
	var top_y: float = y
	var rises: int = int(top_y / 0.4)
	var run: float = (stair_foot - (back + tiers[2].z)) / float(rises)
	for step: int in range(rises):
		var z: float = stair_foot - run * (float(step) + 0.5)
		mesh.box("wood" if step % 2 == 0 else "wood_dark", Vector3(0, 0.4 * float(step) + 0.2, z), Vector3(4.4, 0.4, run + 0.04), Basis.IDENTITY, 0.02, 0.92)
		mesh.box("stone_dark", Vector3(0, 0.2 * float(step), z), Vector3(4.4, 0.4 * float(step) + 0.01, run), Basis.IDENTITY, 0.0, 0.85)
	mesh.box("plank", Vector3(0, 0.1, stair_foot + 0.6), Vector3(5.2, 0.2, 1.4), Basis.IDENTITY, 0.02)
	# lantern posts down the stair and the guard statues on the first tier
	for side: float in [-1.0, 1.0]:
		for step: int in [2, 8, 14]:
			var z: float = stair_foot - run * float(step)
			var foot: Vector3 = Vector3(side * 2.6, 0.4 * float(step), z)
			mesh.tube("wood_dark", foot, foot + Vector3(0, 1.6, 0), 0.08, 5, true)
			mesh.box("lantern", foot + Vector3(0, 1.85, 0), Vector3(0.4, 0.5, 0.4), Basis.IDENTITY, 0.04)
		_raccoon(mesh, Vector3(side * 3.9, tiers[0].y, back + tiers[0].z - 1.6), 1.5, side)
	lights.append({"pos": Vector3(0, 1.8, stair_foot - 0.6), "color": WARM, "range": 6.0, "energy": 1.0, "kind": "lantern"})
	# the king on his bin throne at the top
	var throne_z: float = back + 2.4
	mesh.lathe("metal", Vector3(0, top_y, throne_z), [Vector2(1.6, 0.0), Vector2(1.7, 1.4), Vector2(1.75, 1.5)], 14, 0.85, false, true)
	for side: float in [-1.0, 1.0]:
		mesh.lathe("metal_dark", Vector3(side * 2.2, top_y, throne_z + 0.4), [Vector2(0.7, 0.0), Vector2(0.75, 2.0), Vector2(0.8, 2.1)], 12, 0.85, false, true)
	_raccoon(mesh, Vector3(0, top_y + 1.4, throne_z), 4.6, 0.0, true)
	# rag pennants on poles and rope across the tiers, the little windmills on the shoulders
	var poles: Array[Vector3] = [Vector3(-w * 0.48, 0.0, d * 0.42), Vector3(-w * 0.3, tiers[0].y, back + tiers[0].z - 0.8), Vector3(w * 0.3, tiers[0].y, back + tiers[0].z - 0.8), Vector3(w * 0.48, 0.0, d * 0.42)]
	for index: int in range(poles.size()):
		mesh.tube("wood_dark", poles[index], poles[index] + Vector3(0, 4.6, 0), 0.1, 5, true)
		mesh.box("lantern", poles[index] + Vector3(0, 3.2, 0.2), Vector3(0.36, 0.46, 0.36), Basis.IDENTITY, 0.04)
		if index > 0:
			var a: Vector3 = poles[index - 1] + Vector3(0, 4.4, 0)
			var b: Vector3 = poles[index] + Vector3(0, 4.4, 0)
			mesh.tube("rope", a, b, 0.05, 4, false)
			for flag: int in range(4):
				var t: float = (float(flag) + 0.5) / 4.0
				var at: Vector3 = a.lerp(b, t) + Vector3(0, -0.12, 0.05)
				var tint: String = ["cloth_red", "cloth_cream", "cloth_rust", "cloth_green"][(flag + index) % 4]
				mesh.tri(tint, [at + Vector3(-0.35, 0, 0), at + Vector3(0.35, 0, 0), at + Vector3(0, -0.9, 0)], Vector3(0, 0, 1))
	for side: float in [-1.0, 1.0]:
		var hub: Vector3 = Vector3(side * w * 0.36, tiers[0].y + 3.4, back + tiers[1].z * 0.5)
		mesh.tube("wood_dark", hub - Vector3(0, 3.4, 0), hub, 0.1, 5, true)
		for blade: int in range(6):
			var a: float = float(blade) * TAU / 6.0 + side
			mesh.box("rust" if blade % 2 == 0 else "cloth_cream", hub + Vector3(cos(a), sin(a), 0) * 0.7 + Vector3(0, 0, 0.12), Vector3(0.9, 0.36, 0.04), Basis(Vector3(0, 0, 1), a), 0.0)
	# the doorway at the base (east of the stair): a dark arch, a sliced door, a lantern
	var door: Vector3 = Vector3(w * 0.3, 0.0, d * 0.5 + 0.02)
	mesh.box("wood_dark", door + Vector3(0, 1.3, -0.15), Vector3(2.2, 2.6, 0.3), Basis.IDENTITY, 0.03)
	_card(mesh, "DUMP-SHEET-DOORS-06", door + Vector3(0, 0.0, 0.08), 2.3, Vector3(0, 0, 1))
	mesh.box("lantern", door + Vector3(1.3, 2.2, 0.3), Vector3(0.36, 0.46, 0.36), Basis.IDENTITY, 0.04)
	# flowers along the tiers (cards)
	for index: int in range(6):
		var at: Vector3 = Vector3(-w * 0.42 + float(index) * w * 0.17, tiers[0].y, back + tiers[0].z - 0.4)
		if absf(at.x) < 3.0:
			continue
		_card(mesh, "DUMP-PLANT-WILD", at, 1.0, Vector3(0, 0, 1))
	# blocking: the stand-in's circles (the stair foot on the land, the front corners)
	circles.append(Vector3(-w * 0.25, d * 0.5, 0.0))
	circles.append(Vector3(w * 0.25, d * 0.5, 0.0))
	circles.append(Vector3(0.0, d * 0.5 + 2.7, 2.4))


## A raccoon statue `height` metres tall sitting at `base` (body, belly, head, ears, the bandit mask, a snout), facing +z; `side` tilts the guards'
## lollipop staves outward; the king gets a crown, a rag cape and a scepter.
static func _raccoon(mesh: KitMesh, base: Vector3, height: float, side: float, king: bool = false) -> void:
	var s: float = height / 3.2
	mesh.blob("stone", base + Vector3(0, 1.0 * s, 0), Vector3(1.1, 1.05, 0.95) * s, 4, 10, 0.85)
	mesh.blob("fur_light", base + Vector3(0, 0.9 * s, 0.45 * s), Vector3(0.7, 0.75, 0.55) * s, 4, 10, 0.9)
	var head: Vector3 = base + Vector3(0, 2.35 * s, 0.1 * s)
	mesh.blob("stone", head, Vector3(0.95, 0.78, 0.82) * s, 4, 10, 0.9)
	mesh.blob("mask", head + Vector3(0, 0.05 * s, 0.5 * s), Vector3(0.75, 0.24, 0.36) * s, 3, 10, 1.0)
	mesh.blob("fur_light", head + Vector3(0, -0.28 * s, 0.68 * s), Vector3(0.36, 0.26, 0.3) * s, 3, 8, 1.0)
	mesh.blob("mask", head + Vector3(0, -0.2 * s, 0.98 * s), Vector3(0.1, 0.08, 0.08) * s, 2, 6, 1.0)
	for ear: float in [-1.0, 1.0]:
		var e: Vector3 = head + Vector3(ear * 0.55 * s, 0.6 * s, 0.0)
		mesh.tri("stone_dark", [e + Vector3(-0.28 * s, 0, 0.1 * s), e + Vector3(0.28 * s, 0, 0.1 * s), e + Vector3(ear * 0.08 * s, 0.6 * s, 0.1 * s)], Vector3(0, 0, 1))
		mesh.tri("stone_dark", [e + Vector3(0.28 * s, 0, -0.1 * s), e + Vector3(-0.28 * s, 0, -0.1 * s), e + Vector3(ear * 0.08 * s, 0.6 * s, -0.1 * s)], Vector3(0, 0, -1))
	# the ringed tail curling round the front
	for ring: int in range(5):
		var t: float = float(ring) / 4.0
		var at: Vector3 = base + Vector3(lerpf(0.9, 1.3, t) * s, 0.3 * s + t * 0.4 * s, lerpf(-0.6, 0.6, t) * s)
		mesh.blob("mask" if ring % 2 == 0 else "stone", at, Vector3(0.32, 0.3, 0.32) * s, 3, 8, 0.95)
	if king:
		mesh.lathe("gold", head + Vector3(0, 0.62 * s, 0), [Vector2(0.62 * s, 0.0), Vector2(0.66 * s, 0.38 * s)], 12, 1.0, false, false)
		for spike: int in range(8):
			var a: float = TAU * float(spike) / 8.0
			var p: Vector3 = head + Vector3(cos(a) * 0.62 * s, 1.0 * s, sin(a) * 0.62 * s)
			mesh.tube("gold", p, p + Vector3(0, 0.35 * s, 0), 0.05 * s, 4, true)
			mesh.blob("gold", p + Vector3(0, 0.4 * s, 0), Vector3(0.09, 0.09, 0.09) * s, 2, 6, 1.0)
		mesh.quad("cloth_red", [base + Vector3(-1.2 * s, 2.0 * s, -0.7 * s), base + Vector3(1.2 * s, 2.0 * s, -0.7 * s), base + Vector3(1.5 * s, 0.0, -1.1 * s), base + Vector3(-1.5 * s, 0.0, -1.1 * s)], Vector3(0, 0.2, -1).normalized())
		var hand: Vector3 = base + Vector3(-1.1 * s, 1.3 * s, 0.6 * s)
		mesh.tube("wood_dark", hand + Vector3(0, -1.2 * s, 0), hand + Vector3(0, 1.4 * s, 0), 0.07 * s, 5, true)
		mesh.tube("rust", hand + Vector3(0, 1.7 * s, -0.05 * s), hand + Vector3(0, 1.7 * s, 0.05 * s), 0.42 * s, 12, true)
	else:
		var hand: Vector3 = base + Vector3(side * 0.95 * s, 1.0 * s, 0.4 * s)
		mesh.tube("wood_dark", hand + Vector3(0, -1.0 * s, 0), hand + Vector3(0, 1.6 * s, 0), 0.07 * s, 5, true)
		mesh.tube("rust", hand + Vector3(0, 1.9 * s, -0.05 * s), hand + Vector3(0, 1.9 * s, 0.05 * s), 0.38 * s, 12, true)


# ---- the Commons greenhouse ----------------------------------------------------------------------------------------------------------------


## The hub centrepiece (DUMP-HERO-COMMONS-GREENHOUSE): a salvaged glass-and-timber greenhouse on a plank plinth, glass warm with lantern light inside
## (meta "lights": the warm light the scene makes real), a gable front with a round rose window and a green arched door, a glass ridge roof on rafters with
## a little windmill on the ridge (meta "spinner"), a canvas awning, a rusty water tank and a compost crib at the east end, sunflowers and planters.
static func _greenhouse(root: Node3D, mesh: KitMesh, size: Vector3, circles: Array[Vector3], lights: Array[Dictionary]) -> void:
	# the glass is its own mesh that never fades (it is see-through already): fading it with the frame cost about 3.5 ms of GPU when a camera stood in
	# its reach (VD-22)
	var glass: KitMesh = KitMesh.new()
	_materials(glass)
	var w: float = size.x
	var h: float = size.y
	var d: float = size.z
	var plinth: float = 0.7
	var eave: float = h * 0.56
	mesh.box("mosswood", Vector3(0, plinth * 0.5, 0), Vector3(w + 0.3, plinth, d + 0.3), Basis.IDENTITY, 0.04, 0.85)
	mesh.box("plank", Vector3(0, plinth + 0.02, 0), Vector3(w + 0.2, 0.06, d + 0.2), Basis.IDENTITY, 0.0)
	# what grows inside, seen through the glass
	for row: float in [-1.0, 1.0]:
		for index: int in range(5):
			var x: float = -w * 0.38 + w * 0.19 * float(index)
			mesh.blob("leaf" if index % 2 == 0 else "leaf_light", Vector3(x, plinth + 0.6, row * d * 0.22), Vector3(0.6, 0.55, 0.5), 3, 8, 0.95)
			if index % 2 == 1:
				mesh.blob("sunflower", Vector3(x + 0.2, plinth + 1.3, row * d * 0.22 + 0.2), Vector3(0.28, 0.28, 0.12), 3, 8, 1.0)
	# the glass: side walls, the back, the gable front round the door, the two roof slopes
	var top_y: float = plinth
	glass.quad("glass", [Vector3(-w * 0.5, top_y, d * 0.5), Vector3(-w * 0.5, top_y, -d * 0.5), Vector3(-w * 0.5, eave, -d * 0.5), Vector3(-w * 0.5, eave, d * 0.5)], Vector3(-1, 0, 0))
	glass.quad("glass", [Vector3(w * 0.5, top_y, -d * 0.5), Vector3(w * 0.5, top_y, d * 0.5), Vector3(w * 0.5, eave, d * 0.5), Vector3(w * 0.5, eave, -d * 0.5)], Vector3(1, 0, 0))
	glass.quad("glass", [Vector3(w * 0.5, top_y, -d * 0.5), Vector3(-w * 0.5, top_y, -d * 0.5), Vector3(-w * 0.5, eave, -d * 0.5), Vector3(w * 0.5, eave, -d * 0.5)], Vector3(0, 0, -1))
	glass.quad("glass", [Vector3(-w * 0.5, top_y, d * 0.5), Vector3(-0.8, top_y, d * 0.5), Vector3(-0.8, eave, d * 0.5), Vector3(-w * 0.5, eave, d * 0.5)], Vector3(0, 0, 1))
	glass.quad("glass", [Vector3(0.8, top_y, d * 0.5), Vector3(w * 0.5, top_y, d * 0.5), Vector3(w * 0.5, eave, d * 0.5), Vector3(0.8, eave, d * 0.5)], Vector3(0, 0, 1))
	for gz: float in [-1.0, 1.0]:
		glass.tri("glass", [Vector3(-w * 0.5, eave, gz * d * 0.5), Vector3(w * 0.5, eave, gz * d * 0.5), Vector3(0, h, gz * d * 0.5)], Vector3(0, 0, gz))
	# the roof runs east-west: two slopes from the eaves (north and south) to the ridge
	glass.quad("glass", [Vector3(-w * 0.5 - 0.2, eave, d * 0.5 + 0.2), Vector3(w * 0.5 + 0.2, eave, d * 0.5 + 0.2), Vector3(w * 0.5 + 0.2, h, 0.0), Vector3(-w * 0.5 - 0.2, h, 0.0)], Vector3(0, 0.6, 0.8).normalized())
	glass.quad("glass", [Vector3(w * 0.5 + 0.2, eave, -d * 0.5 - 0.2), Vector3(-w * 0.5 - 0.2, eave, -d * 0.5 - 0.2), Vector3(-w * 0.5 - 0.2, h, 0.0), Vector3(w * 0.5 + 0.2, h, 0.0)], Vector3(0, 0.6, -0.8).normalized())
	# the timber frame: corner posts, mullions, the eave beams, rafters and the ridge
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			mesh.box("wood", Vector3(sx * w * 0.5, (plinth + eave) * 0.5, sz * d * 0.5), Vector3(0.22, eave - plinth, 0.22), Basis.IDENTITY, 0.02)
		mesh.box("wood", Vector3(0, eave, sx * d * 0.5), Vector3(w + 0.3, 0.2, 0.22), Basis.IDENTITY, 0.02)
	var bays: int = 5
	for index: int in range(bays + 1):
		var x: float = -w * 0.5 + w * float(index) / float(bays)
		for sz: float in [-1.0, 1.0]:
			if index > 0 and index < bays:
				mesh.box("wood_dark", Vector3(x, (plinth + eave) * 0.5, sz * d * 0.5), Vector3(0.1, eave - plinth, 0.12), Basis.IDENTITY, 0.0)
			mesh.tube("wood_dark", Vector3(x, eave, sz * (d * 0.5 + 0.1)), Vector3(x, h + 0.02, 0.0), 0.07, 5, true)
	mesh.tube("wood", Vector3(-w * 0.5 - 0.3, h + 0.05, 0.0), Vector3(w * 0.5 + 0.3, h + 0.05, 0.0), 0.12, 6, true)
	mesh.box("wood_dark", Vector3(0, plinth + (eave - plinth) * 0.5, -d * 0.5), Vector3(w, 0.1, 0.1), Basis.IDENTITY, 0.0)
	# the rose window over the door: a lit disc, a rusty ring and spokes
	var rose: Vector3 = Vector3(0, eave + (h - eave) * 0.42, d * 0.5 + 0.06)
	var rose_r: float = minf(1.05, (h - eave) * 0.42)
	glass.tube("glass", rose - Vector3(0, 0, 0.03), rose + Vector3(0, 0, 0.0), rose_r, 16, true)
	for spoke: int in range(8):
		var a: float = TAU * float(spoke) / 8.0
		mesh.tube("wood", rose + Vector3(0, 0, 0.05), rose + Vector3(cos(a), sin(a), 0) * rose_r + Vector3(0, 0, 0.05), 0.045, 4, false)
	var previous: Vector3 = Vector3.ZERO
	for step: int in range(17):
		var a: float = TAU * float(step) / 16.0
		var point: Vector3 = rose + Vector3(cos(a), sin(a), 0) * rose_r + Vector3(0, 0, 0.06)
		if step > 0:
			mesh.tube("rust", previous, point, 0.08, 5, false)
		previous = point
	# the door, the step, the lanterns either side, the awning over the east bays
	_card(mesh, "DUMP-SHEET-DOORS-01", Vector3(0, plinth, d * 0.5 + 0.08), 2.3, Vector3(0, 0, 1))
	mesh.box("plank", Vector3(0, plinth * 0.5, d * 0.5 + 0.7), Vector3(2.2, plinth, 1.0), Basis.IDENTITY, 0.03, 0.9)
	mesh.box("plank", Vector3(0, plinth * 0.25, d * 0.5 + 1.4), Vector3(2.4, plinth * 0.5, 0.6), Basis.IDENTITY, 0.03, 0.9)
	for side: float in [-1.0, 1.0]:
		mesh.box("lantern", Vector3(side * 1.25, plinth + 2.1, d * 0.5 + 0.25), Vector3(0.34, 0.46, 0.34), Basis.IDENTITY, 0.04)
		mesh.tube("wood_dark", Vector3(side * 1.25, plinth + 2.35, d * 0.5 + 0.25), Vector3(side * 1.25, plinth + 2.6, d * 0.12), 0.04, 4, false)
	mesh.quad("cloth_cream", [Vector3(w * 0.12, eave - 0.15, d * 0.5 + 1.5), Vector3(w * 0.48, eave - 0.15, d * 0.5 + 1.5), Vector3(w * 0.48, eave + 0.35, d * 0.5 + 0.05), Vector3(w * 0.12, eave + 0.35, d * 0.5 + 0.05)], Vector3(0, 0.9, 0.4).normalized())
	for ax: float in [0.13, 0.47]:
		mesh.tube("wood_dark", Vector3(w * ax, plinth, d * 0.5 + 1.45), Vector3(w * ax, eave - 0.15, d * 0.5 + 1.45), 0.06, 5, true)
	# the east end: the rusty water tank on its stand and the compost crib
	var tank: Vector3 = Vector3(w * 0.5 + 0.9, 0.0, -d * 0.18)
	mesh.lathe("rust", tank + Vector3(0, 0.5, 0), [Vector2(0.95, 0.0), Vector2(1.0, 1.4), Vector2(0.95, 2.6), Vector2(0.4, 2.9)], 12, 0.85, true, true)
	mesh.box("wood_dark", tank + Vector3(0, 0.25, 0), Vector3(1.9, 0.5, 1.9), Basis.IDENTITY, 0.03)
	mesh.tube("rust_dark", tank + Vector3(0, 3.0, 0), Vector3(w * 0.5, eave + 0.2, -d * 0.18), 0.14, 6, true)
	mesh.box("plank", Vector3(w * 0.5 + 0.8, 0.45, d * 0.28), Vector3(1.4, 0.9, 1.6), Basis.IDENTITY, 0.03, 0.85)
	mesh.blob("soil", Vector3(w * 0.5 + 0.8, 0.9, d * 0.28), Vector3(0.6, 0.3, 0.7), 3, 8, 0.9)
	# sunflowers and planters along the front (cards), vines up the corner posts
	_card(mesh, "DUMP-PLANT-WILD", Vector3(-w * 0.32, 0.0, d * 0.5 + 0.55), 1.15, Vector3(0, 0, 1))
	_card(mesh, "DUMP-PLANT-WILD", Vector3(w * 0.3, 0.0, d * 0.5 + 0.6), 1.1, Vector3(0, 0, 1))
	_card(mesh, "DUMP-PROP-TYRE", Vector3(-w * 0.5 - 0.3, 0.0, d * 0.5 + 0.2), 1.0, Vector3(0, 0, 1))
	for sx: float in [-1.0, 1.0]:
		for index: int in range(4):
			mesh.blob("leaf" if index % 2 == 0 else "leaf_dark", Vector3(sx * w * 0.5, plinth + 0.6 + float(index) * 0.7, d * 0.5 + 0.12), Vector3(0.35, 0.4, 0.2), 3, 6, 0.95)
	# vines trailing along the front eave beam
	for index: int in range(9):
		var x: float = -w * 0.46 + float(index) * w * 0.115
		var length: float = 0.4 + 0.5 * float((index * 7) % 3)
		mesh.box("leaf" if index % 2 == 0 else "leaf_dark", Vector3(x, eave - length * 0.5, d * 0.5 + 0.14), Vector3(0.16, length, 0.08), Basis.IDENTITY, 0.0)
	lights.append({"pos": Vector3(0, plinth + 1.8, 0.0), "color": WARM, "range": 9.0, "energy": 1.6, "kind": "lantern"})
	# the little windmill on the ridge
	var hub: Vector3 = Vector3(w * 0.32, h + 1.4, 0.0)
	mesh.tube("wood_dark", Vector3(w * 0.32, h, 0.0), hub, 0.07, 5, true)
	var sails: KitMesh = KitMesh.new()
	_materials(sails)
	for blade: int in range(6):
		var a: float = float(blade) * TAU / 6.0
		sails.box("rust" if blade % 2 == 0 else "cloth_cream", Vector3(cos(a), sin(a), 0) * 0.45 + Vector3(0, 0, 0.06), Vector3(0.6, 0.24, 0.03), Basis(Vector3(0, 0, 1), a), 0.0)
	var spinner: MeshInstance3D = sails.instance("Sails")
	spinner.set_meta(PaintedClasses.META_NO_PAINT, true)
	spinner.position = hub + Vector3(0, 0, 0.15)
	root.add_child(spinner)
	root.set_meta("spinner", spinner)
	var panes: MeshInstance3D = glass.instance("Glass")
	panes.set_meta(PaintedClasses.META_NO_PAINT, true)
	panes.set_meta(&"no_occlusion_fade", true)
	panes.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(panes)
	# blocking: the stand-in's three circles along the footprint
	var step: float = w / 3.0
	for index: int in range(3):
		circles.append(Vector3(-w * 0.5 + step * (float(index) + 0.5), 0.0, 2.6))


# ---- the Rotheart's root gate and the entrance bridge (static builders the zone builder places) -------------------------------------------------


static func _finish(mesh: KitMesh, root_name: String, circles: Array[Vector3], size: Vector3, never_fade: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = root_name
	var body: MeshInstance3D = mesh.instance("Body")
	body.set_meta(PaintedClasses.META_NO_PAINT, true)
	if never_fade:
		body.set_meta(&"no_occlusion_fade", true)
	root.add_child(body)
	root.set_meta("circles", circles)
	root.set_meta("footprint", Vector2(size.x, size.z))
	root.set_meta("height", size.y)
	root.set_meta("triangles", mesh.triangle_count())
	return root


## The Rotheart's root gate on the land at the end of its approach roots (the main dungeon's door): two great roots rising from the ground and arching
## over a heart-shaped doorway lit violet from within (its glow pulses with the heart, meta "heart"), a bark lintel, side roots spreading back to the
## rim, fungi and moss on them; in front an inviting way in: a plank walk from the wetlands road to the threshold between two warm lanterns. The
## main_dungeon spot stands on the walk in front of the doorway (south); nothing here carries lettering (the icon board stands beside it).
static func root_gate(size: Vector3) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	_materials(mesh)
	var circles: Array[Vector3] = []
	var w: float = size.x
	var h: float = size.y
	var span: float = w * 0.35
	var arch_top: float = h + 0.8
	# the back mass the doorway is cut into: a low knot of bark sinking toward the rim
	_ellipsoid(mesh, "bark_dark", Vector3(0, -0.4, -1.8), Vector3(span + 1.6, h * 0.82, 2.4), 5, 14, 0.0)
	# the doorway: dark rim, deep violet, the soft glow low in it
	_heart(mesh, "bark_dark", Vector3(0, h * 0.4, 0.62), span * 1.55, h * 0.86, Vector3(0, 0, 1))
	_glow_heart(mesh, "heart", Vector3(0, h * 0.42, 0.72), span * 1.32, h * 0.74, Vector3(0, 0, 1))
	# the two great roots: up from the ground either side of the door and over it, meeting at the top
	for side: float in [-1.0, 1.0]:
		var foot: Vector3 = Vector3(side * (span + 0.4), 0.0, 0.9)
		_limb(mesh, "bark", [foot + Vector3(side * 1.4, -0.2, -1.6), foot + Vector3(side * 0.3, 0.3, 0.2), foot + Vector3(0, h * 0.45, 0.4), foot + Vector3(-side * 0.5, h * 0.8, 0.2), foot + Vector3(-side * (span * 0.55), h * 1.04, 0.1), Vector3(side * 0.3, arch_top, 0.0)], 1.25, 0.75, 10)
		# a thinner strand twisting round the big one
		_limb(mesh, "bark_violet", [foot + Vector3(side * 0.9, 0.0, 1.0), foot + Vector3(-side * 0.5, h * 0.3, 1.0), foot + Vector3(side * 0.4, h * 0.6, 0.9), foot + Vector3(-side * 0.6, h * 0.92, 0.6)], 0.4, 0.22, 7)
		# side roots spreading back to the rim (never south, where the hero walks)
		for index: int in range(3):
			var a: float = PI * (0.12 + 0.3 * float(index))
			var direction: Vector3 = Vector3(side * cos(a), 0.0, -sin(a))
			_limb(mesh, "bark" if index % 2 == 0 else "bark_dark", [foot + Vector3(0, 0.5, -0.4), foot + direction * 2.4 + Vector3(0, 0.6, -0.4), foot + direction * (4.2 + float(index % 2) * 1.2) + Vector3(0, -0.2, -0.4)], 0.6, 0.25, 7)
		_mushroom(mesh, foot + Vector3(side * 0.9, h * 0.5, 1.3), 1.0, Vector3(side * 0.7, 1.0, 0.5))
		_mushroom(mesh, foot + Vector3(side * 2.2, 0.0, 0.4), 0.8)
		_mushroom(mesh, foot + Vector3(side * 2.8, 0.0, -0.4), 0.55)
		_ellipsoid(mesh, "leaf", foot + Vector3(-side * 0.5, h * 0.7, 1.0), Vector3(0.9, 0.5, 0.6), 3, 8, 0.0)
		# a warm lantern on a post either side of the walk: the way in should invite
		var post: Vector3 = Vector3(side * 2.6, 0.0, 3.4)
		mesh.tube("wood_dark", post, post + Vector3(0, 2.0, 0), 0.09, 5, true)
		mesh.tube("wood_dark", post + Vector3(0, 2.0, 0), post + Vector3(-side * 0.45, 2.0, 0), 0.05, 4, false)
		mesh.box("lantern", post + Vector3(-side * 0.45, 1.72, 0), Vector3(0.32, 0.42, 0.32), Basis.IDENTITY, 0.04)
	# veins of violet from the doorway along the great roots
	for side: float in [-1.0, 1.0]:
		_limb(mesh, "veins", [Vector3(side * span * 0.9, h * 0.25, 1.15), Vector3(side * (span + 0.4), h * 0.55, 1.55), Vector3(side * span * 0.6, h * 0.95, 1.1)], 0.08, 0.04, 4)
	# the plank walk in: from the wetlands road to the threshold (flat, walked on, never fades)
	var walk: KitMesh = KitMesh.new()
	_materials(walk)
	for index: int in range(7):
		var z: float = 1.4 + float(index) * 0.75
		walk.box("plank", Vector3(0, 0.1, z), Vector3(3.2 - float(index % 2) * 0.2, 0.14, 0.66), Basis(Vector3.UP, 0.04 * float(index % 3 - 1)), 0.01, 0.95)
	circles.append(Vector3(-span, 0.0, 1.8))
	circles.append(Vector3(0.0, -1.5, 2.0))
	circles.append(Vector3(span, 0.0, 1.8))
	var root: Node3D = _finish(mesh, "RootGate", circles, size, false)
	var walk_node: MeshInstance3D = walk.instance("Walk")
	walk_node.set_meta(PaintedClasses.META_NO_PAINT, true)
	walk_node.set_meta(&"no_occlusion_fade", true)
	walk_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(walk_node)
	root.set_meta("heart", mesh_material(mesh, "heart"))
	root.set_meta("corruption", {"heart": mesh_material(mesh, "heart"), "veins": mesh_material(mesh, "veins"), "fungus": mesh_material(mesh, "fungus"), "hollow": mesh_material(mesh, "hollow")})
	return root


## The way in from town: a plank bridge on rusty girders out over the overflow pool, tyre kerbs, rope rails on scrap posts, a gate of stacked tyres with
## a rusty beam (the zone's icon on it) at the land end and a landing with two rag-flag posts at the town end. Along +z from the origin.
static func entrance_bridge(length: float, width: float) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	_materials(mesh)
	var circles: Array[Vector3] = []
	var half: float = width * 0.5
	for side: float in [-1.0, 1.0]:
		mesh.box("rust", Vector3(side * (half - 0.35), -0.36, length * 0.5), Vector3(0.4, 0.5, length), Basis.IDENTITY, 0.03, 0.85)
	var plank: float = 1.0
	var count: int = int(ceilf(length / plank))
	for index: int in range(count):
		var z: float = plank * (float(index) + 0.5)
		mesh.box("plank" if index % 3 != 1 else "wood_dark", Vector3(0.0, -0.08, minf(z, length - plank * 0.5)), Vector3(width, 0.16, plank - 0.1), Basis.IDENTITY, 0.02, 0.92)
	for side: float in [-1.0, 1.0]:
		mesh.box("tyre", Vector3(side * (half - 0.15), 0.12, length * 0.5), Vector3(0.3, 0.3, length), Basis.IDENTITY, 0.04)
	# posts with rope between them, girder pillars down into the pool
	var post_step: float = 3.6
	var posts: int = maxi(2, int(round(length / post_step)))
	var previous: Dictionary = {}
	for index: int in range(1, posts):
		var z: float = length * float(index) / float(posts)
		for side: float in [-1.0, 1.0]:
			var base: Vector3 = Vector3(side * (half + 0.3), 0.0, z)
			mesh.tube("wood_dark", base, base + Vector3(0.0, 1.3, 0.0), 0.11, 6, true)
			mesh.lathe("rust", base + Vector3(0.0, 1.3, 0.0), [Vector2(0.16, 0.0), Vector2(0.0, 0.2)], 6, 0.9, false, false)
			if previous.has(side):
				mesh.tube("straw", (previous[side] as Vector3) + Vector3(0.0, 1.15, 0.0), base + Vector3(0.0, 1.15, 0.0), 0.04, 4, false)
			previous[side] = base
		mesh.tube("rust_dark", Vector3(0.0, -4.0, z), Vector3(0.0, -0.3, z), 0.32, 8, true)
		mesh.box("rust_dark", Vector3(0.0, -0.75, z), Vector3(width + 0.2, 0.22, 0.4), Basis.IDENTITY, 0.0)
	# the gate at the land end (the art pass: open, so the Commons shows through it): two mossy plank posts on a pair of tyres, vines up them, a sagging
	# rope of rag bunting between their tops
	var gate_h: float = 3.4
	for side: float in [-1.0, 1.0]:
		var foot: Vector3 = Vector3(side * (half + 0.55), 0.0, 0.4)
		for index: int in range(2):
			mesh.lathe("tyre", foot + Vector3(0.0, float(index) * 0.32, 0.0), [Vector2(0.62, 0.0), Vector2(0.66, 0.16), Vector2(0.62, 0.32)], 12, 0.9, true, true)
		mesh.box("mosswood", foot + Vector3(0.0, gate_h * 0.5, 0.0), Vector3(0.42, gate_h, 0.42), Basis(Vector3.UP, 0.2 * side), 0.03, 0.85)
		mesh.lathe("tin", foot + Vector3(0.0, gate_h, 0.0), [Vector2(0.36, 0.0), Vector2(0.0, 0.4)], 6, 0.9, true, false)
		for leaf: int in range(4):
			mesh.blob("leaf" if leaf % 2 == 0 else "leaf_dark", foot + Vector3(0.18 * side, 0.9 + 0.65 * float(leaf), 0.22), Vector3(0.26, 0.32, 0.18), 4, 10, 0.95)
		circles.append(Vector3(foot.x, foot.z, 0.75))
	var sag: int = 10
	var previous_point: Vector3 = Vector3.ZERO
	# overnight Oct 19: the bunting is its own mesh that fades on its own when it crosses the view of the hero (OcclusionFader, occlusion_overhead)
	var line: KitMesh = KitMesh.new()
	_materials(line)
	for index: int in range(sag + 1):
		var t: float = float(index) / float(sag)
		var point: Vector3 = Vector3(lerpf(-(half + 0.55), half + 0.55, t), gate_h - 0.15 - sin(t * PI) * 0.7, 0.5)
		if index > 0:
			line.tube("rope", previous_point, point, 0.04, 4, false)
			var at: Vector3 = (previous_point + point) * 0.5
			var tint: String = ["cloth_red", "cloth_cream", "cloth_teal", "cloth_green", "cloth_rust"][index % 5]
			line.tri(tint, [at + Vector3(-0.2, 0, 0), at + Vector3(0.2, 0, 0), at + Vector3(0, -0.5, 0)], Vector3(0, 0, 1))
			line.tri(tint, [at + Vector3(0.2, 0, 0), at + Vector3(-0.2, 0, 0), at + Vector3(0, -0.5, 0)], Vector3(0, 0, -1))
		previous_point = point
	# the far landing: a plank square with two rag-flag posts, where the way to town begins
	var landing_z: float = length + 1.6
	mesh.box("rust", Vector3(0.0, -0.36, landing_z), Vector3(width + 1.6, 0.42, 3.6), Basis.IDENTITY, 0.03, 0.85)
	mesh.box("wood", Vector3(0.0, -0.08, landing_z), Vector3(width + 1.2, 0.16, 3.4), Basis.IDENTITY, 0.03, 0.92)
	for side: float in [-1.0, 1.0]:
		var foot: Vector3 = Vector3(side * (half + 0.4), 0.0, landing_z + 1.5)
		mesh.tube("wood_dark", foot, foot + Vector3(0.0, 2.9, 0.0), 0.14, 6, true)
		mesh.tri("cap_blue", [foot + Vector3(0.0, 2.9, 0.0), foot + Vector3(0.0, 2.0, 0.0), foot + Vector3(side * 1.1, 2.45, 0.0)], Vector3(0.0, 0.0, 1.0))
		mesh.tri("cap_blue", [foot + Vector3(0.0, 2.9, 0.0), foot + Vector3(side * 1.1, 2.45, 0.0), foot + Vector3(0.0, 2.0, 0.0)], Vector3(0.0, 0.0, -1.0))
		circles.append(Vector3(foot.x, foot.z, 0.5))
		mesh.tube("rust_dark", Vector3(side * (half + 0.2), -4.0, landing_z), Vector3(side * (half + 0.2), -0.3, landing_z), 0.3, 8, true)
	var root: Node3D = _finish(mesh, "Bridge", circles, Vector3(width, gate_h, length), true)
	(root.get_child(0) as MeshInstance3D).set_meta(&"no_range_cull", true)
	var bunting: MeshInstance3D = line.instance("Bunting")
	bunting.set_meta(PaintedClasses.META_NO_PAINT, true)
	bunting.set_meta(&"occlusion_overhead", true)
	root.add_child(bunting)
	IconSign.attach(root, "ICON-ENERGY-R", Vector3(-(half + 0.55), 2.3, 0.66), 0.8)
	return root
