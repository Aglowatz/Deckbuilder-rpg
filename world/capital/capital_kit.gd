class_name CapitalKit
extends RefCounted
## The Capital's kit pieces (zone kit "final", data/art/zone_kits/final.json, docs/art/zone_kits/final/concepts/): the material slots every Capital model
## shares and the small parts the concepts repeat (white-and-gold spires with blue cone roofs, gold finials, Primm's smiling emblem, the marble Primm
## statue, painted cards inside a mesh). One `KitMesh` per model, so a landmark is a handful of surfaces. The sheet's two palettes: OUTSIDE ash
## #8C8A86, charcoal #5E5B57, bone #B9B2A4, dust #D8D0C0, rift purple #9B59D0 (accents only); INSIDE porcelain #F7F3EA, gold #E6C35C, pink #F5C6D0,
## mint #BFE3D0, sky blue #A7C7E7, lawn #7FC97F. Nothing carries readable text (Art Bible G-03): the emblem is a face, never a word.

const PORCELAIN: Color = Color("f7f3ea")
const GOLD: Color = Color("e6c35c")
const GOLD_DEEP: Color = Color("b8902e")
const PINK: Color = Color("f5c6d0")
const MINT: Color = Color("bfe3d0")
const SKY: Color = Color("a7c7e7")
const LAWN: Color = Color("7fc97f")
const HEDGE: Color = Color("4f9a4c")
const ASH: Color = Color("8c8a86")
const CHARCOAL: Color = Color("5e5b57")
const BONE: Color = Color("b9b2a4")
const DUST: Color = Color("d8d0c0")
const RIFT: Color = Color("9b59d0")
const RIFT_HOT: Color = Color("c890ff")
const WOOD: Color = Color("6a4a30")
const WOOD_DARK: Color = Color("3e2a1c")
const IRON: Color = Color("4a4a50")
const WARM: Color = Color("ffc070")
const CARD_UVS: Array[Vector2] = [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)]

## The shared materials made here (gold, mirror, water), one per look, so repeated models batch (`KitBatch` merges by material).
static var _cache: Dictionary = {}


## A kit surface when the zone has its art, else the flat palette colour (the model still reads before the art is imported).
static func surface(id: String, fallback: Color, mul: Color = Color.WHITE) -> Material:
	if EnvKit.has(id) and EnvKit.texture(id) != null:
		return EnvKit.material(id, false, mul)
	return EnvKit.flat(fallback * mul, "cap_kit")


## A glow of its own (not the shared cache), so a model can pulse it (the castle's rift cracks, a rift's tear) or swap it for a freed state.
static func own_glow(color: Color, energy: float, alpha: float = 1.0, unshaded: bool = false) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(color.r, color.g, color.b, alpha)
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = energy
	material.roughness = 0.5
	material.vertex_color_use_as_albedo = true
	if unshaded:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if alpha < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.set_meta(PaintedClasses.META_NO_PAINT, true)
	material.set_meta(StyleToon.META_NO_TOON, true)
	return material


## Mirrored glass: pale sky-blue, glossy and metallic so it throws back the sky (the castle's and the Ward's "mirrored windows").
static func mirror(tint: Color = Color("8cb2e2")) -> StandardMaterial3D:
	var key: String = "mirror|%s" % tint.to_html()
	if _cache.has(key):
		return _cache[key] as StandardMaterial3D
	var material: StandardMaterial3D = StandardMaterial3D.new()
	_cache[key] = material
	material.albedo_color = tint
	material.metallic = 0.85
	material.metallic_specular = 0.9
	material.roughness = 0.12
	material.emission_enabled = true
	material.emission = tint.darkened(0.45)
	material.emission_energy_multiplier = 0.3
	material.vertex_color_use_as_albedo = true
	material.set_meta(PaintedClasses.META_NO_PAINT, true)
	return material


## Translucent water (the fountain): sky blue, glossy, lit a little from within so it reads at noon.
static func water(alpha: float = 0.7) -> StandardMaterial3D:
	var key: String = "water|%s" % alpha
	if _cache.has(key):
		return _cache[key] as StandardMaterial3D
	var material: StandardMaterial3D = StandardMaterial3D.new()
	_cache[key] = material
	material.albedo_color = Color(0.62, 0.86, 1.0, alpha)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.roughness = 0.05
	material.metallic_specular = 0.9
	material.emission_enabled = true
	material.emission = Color(0.55, 0.85, 1.0)
	material.emission_energy_multiplier = 0.45
	material.vertex_color_use_as_albedo = true
	material.set_meta(PaintedClasses.META_NO_PAINT, true)
	material.set_meta(StyleToon.META_NO_TOON, true)
	return material


## Registers the shared slots on `mesh`. `gold_mul` dims the gold (Primm has fallen); the flat palette colours fold into one "flat" surface.
static func materials(mesh: KitMesh, gold_mul: Color = Color.WHITE) -> void:
	mesh.set_material("plaster", surface("CAP-WALL-PLASTER", PORCELAIN))
	mesh.set_material("pastel_pink", surface("CAP-WALL-PASTEL-PINK", PINK))
	mesh.set_material("pastel_mint", surface("CAP-WALL-PASTEL-MINT", MINT))
	mesh.set_material("pastel_blue", surface("CAP-WALL-PASTEL-BLUE", SKY))
	mesh.set_material("roof_blue", surface("CAP-ROOF-PASTEL", SKY))
	mesh.set_material("roof_pink", surface("CAP-ROOF-PASTEL-PINK", PINK))
	mesh.set_material("trim", surface("CAP-TRIM-GOLD", GOLD, gold_mul))
	mesh.set_material("ash", surface("CAP-WALL-ASH", ASH))
	mesh.set_material("ruin", surface("CAP-WALL-RUIN", BONE))
	mesh.set_material("roof_broken", surface("CAP-ROOF-BROKEN", CHARCOAL))
	mesh.set_material("rift_ground", surface("CAP-GROUND-RIFT", CHARCOAL))
	mesh.set_material("road_white", surface("CAP-PATH-WHITE", PORCELAIN))
	mesh.set_material("gold", _gold(gold_mul))
	mesh.set_material("flat", EnvKit.flat(Color.WHITE, "cap_kit"))
	# vertex colours are linear: the palette goes in through srgb_to_linear so what shows is the palette, not a paler version of it
	var flats: Dictionary = {
		"marble": PORCELAIN, "marble_shade": Color("dcd6ca"), "lawn": LAWN, "hedge": HEDGE, "hedge_dark": Color("356f36"), "rose": Color("f08aa8"),
		"rose_white": Color("fff4f0"), "soil": Color("6a5440"), "wood": WOOD, "wood_dark": WOOD_DARK, "iron": IRON, "iron_dark": Color("2a2a30"),
		"stone": BONE, "stone_dark": CHARCOAL, "ash_flat": ASH, "dust": DUST, "dark": Color("141018"), "door_pink": Color("f2b8c8"),
		"door_mint": Color("a8dcc4"), "door_blue": Color("9cc0e4"), "canvas_red": Color("a8402e"), "canvas_copper": Color("c07a3e"),
		"canvas_teal": Color("3e6e70"), "canvas_green": Color("5e7e42"), "canvas_navy": Color("39405a"), "canvas_tan": Color("a8875a"),
		"rope": Color("8a7050"), "crate": Color("8a6440"), "paper": Color("f2ead8"), "food_grey": Color("9a9890"), "bin": Color("5a6a58"),
		"bin_dark": Color("33402f"), "bag": Color("2c2c34"), "slime": Color("7a8a40"), "compost": Color("5a4028"), "copper": Color("c47a3a"),
		"cream": Color("f2e2c0"), "bread": Color("d89a50"), "cake_pink": Color("f4a8bc"), "berry": Color("c03050"), "leaf": Color("6aa84f"),
		"wildflower": Color("e8d050"), "lavender": Color("a890e0"), "moss": Color("6e8a3a"), "red_gold": Color("c8402a"),
	}
	for slot: String in flats.keys():
		mesh.alias(slot, "flat", (flats[slot] as Color).srgb_to_linear())
	mesh.set_material("window_warm", EnvKit.glow(Color("ffd890"), 1.5))
	mesh.set_material("lamp", EnvKit.glow(Color("fff2c8"), 2.0))
	mesh.set_material("mirror", mirror())
	mesh.set_material("water", water())


## Polished gold: the trim texture's colour on a smooth metallic surface (spires, finials, frames). `mul` below white dims it (the fallen state).
static func _gold(mul: Color) -> StandardMaterial3D:
	var key: String = "cap_gold_%s" % mul.to_html()
	if _cache.has(key):
		return _cache[key] as StandardMaterial3D
	var material: StandardMaterial3D = StandardMaterial3D.new()
	_cache[key] = material
	material.resource_name = key
	# a richer gold than the trim's pale band, so the frames, finials and the emblem read against the white plaster at noon
	material.albedo_color = Color("dcac3c") * mul
	material.metallic = 0.55 if mul == Color.WHITE else 0.2
	material.metallic_specular = 0.7
	material.roughness = 0.32 if mul == Color.WHITE else 0.7
	material.vertex_color_use_as_albedo = true
	material.set_meta(PaintedClasses.META_NO_PAINT, true)
	return material


## A painted cut-out standing upright in the mesh (a banner on a wall, a door, a window, a sign): pivot at `pivot_pos`, `height` metres tall, its
## face toward `normal` (horizontal unit vector). `flip` mirrors it; `mul` tints it (in its own slot, so one mesh can hold both).
static func card(mesh: KitMesh, id: String, pivot_pos: Vector3, height: float, normal: Vector3, flip: bool = false, mul: Color = Color.WHITE) -> void:
	if not EnvKit.has(id):
		return
	var slot: String = ("card_%s" % id) if mul == Color.WHITE else ("card_%s_%s" % [id, mul.to_html()])
	if mesh.material_of(slot) == null:
		mesh.set_material(slot, EnvKit.material(id, true, mul))
	var width: float = height * EnvKit.aspect(id)
	var pivot: Vector2 = EnvKit.pivot(id)
	var right: Vector3 = Vector3.UP.cross(normal).normalized() * -1.0
	var top: float = pivot_pos.y + pivot.y * height
	var left: Vector3 = pivot_pos - right * (pivot.x * width)
	var bottom_left: Vector3 = Vector3(left.x, top - height, left.z)
	var bottom_right: Vector3 = bottom_left + right * width
	var uvs: Array[Vector2] = CARD_UVS.duplicate()
	if flip:
		uvs = [Vector2(1, 1), Vector2(0, 1), Vector2(0, 0), Vector2(1, 0)]
	mesh.quad(slot, [bottom_left, bottom_right, bottom_right + Vector3(0, height, 0), bottom_left + Vector3(0, height, 0)], normal, [], uvs)


## A painted card lying flat on the ground (a decal: ash drifts, the polish shine), `size` metres across, turned by `yaw` (radians).
static func ground_card(mesh: KitMesh, id: String, center: Vector3, size: float, yaw: float) -> void:
	if not EnvKit.has(id):
		return
	var slot: String = "decal_%s" % id
	if mesh.material_of(slot) == null:
		var material: StandardMaterial3D = EnvKit.material(id, true).duplicate() as StandardMaterial3D
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.render_priority = -1
		material.set_meta(PaintedClasses.META_NO_PAINT, true)
		mesh.set_material(slot, material)
	var aspect: float = EnvKit.aspect(id)
	var along: Vector3 = Vector3(cos(yaw), 0, sin(yaw)) * size * 0.5
	var across: Vector3 = Vector3(-sin(yaw), 0, cos(yaw)) * size * 0.5 / maxf(aspect, 0.1)
	mesh.quad(slot, [center - along - across, center + along - across, center + along + across, center - along + across], Vector3.UP, [], CARD_UVS)


## A camera-facing painted card (tree, plant, prop) as a child of `parent`, base at `pos`.
static func tree_card(parent: Node3D, id: String, pos: Vector3, height: float) -> MeshInstance3D:
	if not EnvKit.has(id):
		return null
	var node: MeshInstance3D = KitFoliage.card(id, Vector2(height * EnvKit.aspect(id), height), false)
	node.name = "Card_%s_%d" % [id, parent.get_child_count()]
	node.set_meta(&"no_wind", true)
	parent.add_child(node)
	node.position = pos
	return node


## A gold finial: a ball on a short stem and a spike, `size` metres tall, standing on `base`.
static func finial(mesh: KitMesh, base: Vector3, size: float) -> void:
	mesh.lathe("gold", base, [Vector2(size * 0.16, 0.0), Vector2(size * 0.1, size * 0.22), Vector2(size * 0.22, size * 0.36), Vector2(size * 0.2, size * 0.48), Vector2(size * 0.06, size * 0.6), Vector2(0.0, size)], 8, 1.0, false, false)


## A round white tower with gold bands and a blue (or `roof`) cone roof and a gold finial: the castle's, the Ward's and the gate's spires. `base` at
## its foot, `radius`, `height` to the eaves, `cone` the roof's height.
static func spire(mesh: KitMesh, base: Vector3, radius: float, height: float, cone: float, roof: String = "roof_blue", windows: bool = true) -> void:
	mesh.lathe("plaster", base, [Vector2(radius * 1.08, 0.0), Vector2(radius, height * 0.12), Vector2(radius, height)], 14, 0.8, false, false)
	mesh.lathe("gold", base + Vector3(0, height * 0.12 - 0.15, 0), [Vector2(radius * 1.06, 0.0), Vector2(radius * 1.06, 0.3)], 14, 1.0, false, false)
	mesh.lathe("gold", base + Vector3(0, height - 0.35, 0), [Vector2(radius * 1.14, 0.0), Vector2(radius * 1.14, 0.45)], 14, 1.0, false, true)
	mesh.lathe(roof, base + Vector3(0, height + 0.1, 0), [Vector2(radius * 1.2, 0.0), Vector2(radius * 0.9, cone * 0.3), Vector2(radius * 0.45, cone * 0.7), Vector2(0.0, cone)], 14, 1.0, true, false)
	finial(mesh, base + Vector3(0, height + cone - 0.1, 0), maxf(radius * 0.9, 0.6))
	if windows and height > radius * 3.0:
		for side: Vector3 in [Vector3(0, 0, 1), Vector3(1, 0, 0), Vector3(-1, 0, 0)]:
			arched_window(mesh, base + side * (radius + 0.02) + Vector3(0, height * 0.62, 0), radius * 0.5, radius * 0.95, side, "mirror")


## A tall arched window on a wall facing `normal`: a gold frame, `slot` glass (mirror, warm light or dark), its bottom centre at `bottom`.
static func arched_window(mesh: KitMesh, bottom: Vector3, width: float, height: float, normal: Vector3, slot: String) -> void:
	var right: Vector3 = Vector3.UP.cross(normal).normalized() * -1.0
	var half: float = width * 0.5
	var spring: float = height - half
	var out: Vector3 = normal * 0.03
	# the glass: a rectangle and a half-round head
	mesh.quad(slot, [bottom - right * half + out, bottom + right * half + out, bottom + right * half + Vector3(0, spring, 0) + out, bottom - right * half + Vector3(0, spring, 0) + out], normal)
	var steps: int = 6
	for index: int in range(steps):
		var a0: float = PI * float(index) / float(steps)
		var a1: float = PI * float(index + 1) / float(steps)
		var center: Vector3 = bottom + Vector3(0, spring, 0) + out
		mesh.tri(slot, [center, center + right * cos(a0) * half + Vector3(0, sin(a0) * half, 0), center + right * cos(a1) * half + Vector3(0, sin(a1) * half, 0)], normal)
	# the frame: two jambs, a sill and the mullion in gold
	var frame: float = maxf(width * 0.08, 0.06)
	for side: float in [-1.0, 1.0]:
		mesh.box("gold", bottom + right * side * (half + frame * 0.5) + Vector3(0, spring * 0.5, 0) + normal * 0.04, Vector3(frame, spring, frame), Basis(Vector3.UP, atan2(normal.x, normal.z)))
	mesh.box("gold", bottom + normal * 0.06 - Vector3(0, frame * 0.5, 0), Vector3(width + frame * 3.0, frame, frame * 2.0), Basis(Vector3.UP, atan2(normal.x, normal.z)))
	mesh.box("gold", bottom + Vector3(0, spring * 0.55, 0) + normal * 0.045, Vector3(frame * 0.6, spring * 1.1, frame * 0.6), Basis(Vector3.UP, atan2(normal.x, normal.z)))


## Primm's smiling emblem, the face on every banner (no letters): a gold ring, a cream disc, two eyes and a smile in gold, facing `normal`.
## `broken` cracks it in two (one half slipped down), `covered` hangs a dark cloth over it (the fallen state).
static func emblem(mesh: KitMesh, center: Vector3, radius: float, normal: Vector3, broken: bool = false, covered: bool = false) -> void:
	var right: Vector3 = Vector3.UP.cross(normal).normalized() * -1.0
	var up: Vector3 = Vector3.UP
	var steps: int = 28
	var face: String = "cream" if not covered else "dark"
	for index: int in range(steps):
		var a0: float = TAU * float(index) / float(steps)
		var a1: float = TAU * float(index + 1) / float(steps)
		var shift: Vector3 = Vector3.ZERO
		if broken and cos((a0 + a1) * 0.5) > 0.0:
			shift = -up * radius * 0.12 + right * radius * 0.05
		var d0: Vector3 = right * cos(a0) + up * sin(a0)
		var d1: Vector3 = right * cos(a1) + up * sin(a1)
		mesh.tri(face, [center + shift + normal * 0.02, center + shift + d0 * radius * 0.86 + normal * 0.02, center + shift + d1 * radius * 0.86 + normal * 0.02], normal)
		mesh.quad("gold", [center + shift + d0 * radius * 0.86 + normal * 0.06, center + shift + d1 * radius * 0.86 + normal * 0.06, center + shift + d1 * radius + normal * 0.06, center + shift + d0 * radius + normal * 0.06], normal)
	if covered:
		# a dark cloth hung over the face, its hem ragged below the ring
		var top: Vector3 = center + up * radius * 1.05 + normal * 0.12
		for index: int in range(5):
			var x0: float = -1.1 + 2.2 * float(index) / 5.0
			var x1: float = -1.1 + 2.2 * float(index + 1) / 5.0
			var drop: float = radius * (2.0 + 0.25 * sin(float(index) * 2.3))
			mesh.quad("canvas_navy", [top + right * x0 * radius, top + right * x1 * radius, top + right * x1 * radius - up * drop + normal * 0.05, top + right * x0 * radius - up * drop + normal * 0.05], normal)
		return
	var feature: Vector3 = normal * 0.05
	for side: float in [-1.0, 1.0]:
		var eye_shift: Vector3 = (-up * radius * 0.12 + right * radius * 0.05) if broken and side > 0.0 else Vector3.ZERO
		_disc(mesh, "gold", center + eye_shift + right * side * radius * 0.3 + up * radius * 0.16 + feature, radius * 0.09, normal)
	# the smile: a thick gold arc
	var arc_steps: int = 10
	for index: int in range(arc_steps):
		var a0: float = lerpf(PI * 1.18, PI * 1.82, float(index) / float(arc_steps))
		var a1: float = lerpf(PI * 1.18, PI * 1.82, float(index + 1) / float(arc_steps))
		var shift0: Vector3 = (-up * radius * 0.12 + right * radius * 0.05) if broken and cos(a0) > 0.0 else Vector3.ZERO
		var c: Vector3 = center + up * radius * 0.12 + feature
		var r_in: float = radius * 0.46
		var r_out: float = radius * 0.56
		var p0: Vector3 = right * cos(a0) + up * sin(a0)
		var p1: Vector3 = right * cos(a1) + up * sin(a1)
		mesh.quad("gold", [c + shift0 + p0 * r_in, c + shift0 + p1 * r_in, c + shift0 + p1 * r_out, c + shift0 + p0 * r_out], normal)


static func _disc(mesh: KitMesh, slot: String, center: Vector3, radius: float, normal: Vector3) -> void:
	var right: Vector3 = Vector3.UP.cross(normal).normalized() * -1.0
	for index: int in range(10):
		var a0: float = TAU * float(index) / 10.0
		var a1: float = TAU * float(index + 1) / 10.0
		mesh.tri(slot, [center, center + (right * cos(a0) + Vector3.UP * sin(a0)) * radius, center + (right * cos(a1) + Vector3.UP * sin(a1)) * radius], normal)


## The radiant sun-face over the great gate (the wall concept): the emblem in a ring of gold rays.
static func sun_emblem(mesh: KitMesh, center: Vector3, radius: float, normal: Vector3) -> void:
	var right: Vector3 = Vector3.UP.cross(normal).normalized() * -1.0
	for index: int in range(16):
		var angle: float = TAU * float(index) / 16.0
		var length: float = radius * (1.75 if index % 2 == 0 else 1.4)
		var dir: Vector3 = right * cos(angle) + Vector3.UP * sin(angle)
		var side: Vector3 = right * -sin(angle) + Vector3.UP * cos(angle)
		var root_pos: Vector3 = center + dir * radius * 0.9 + normal * 0.04
		mesh.tri("gold", [root_pos - side * radius * 0.16, root_pos + side * radius * 0.16, center + dir * length + normal * 0.04], normal)
	emblem(mesh, center + normal * 0.02, radius, normal)


## A gold-capped white plinth or balustrade post (`size` w x h x d), a ball on top.
static func post(mesh: KitMesh, base: Vector3, size: Vector3, ball: bool = true) -> void:
	mesh.box("plaster", base + Vector3(0, size.y * 0.5, 0), size, Basis.IDENTITY, 0.03, 0.85)
	mesh.box("gold", base + Vector3(0, size.y + 0.05, 0), Vector3(size.x * 1.15, 0.1, size.z * 1.15))
	if ball:
		finial(mesh, base + Vector3(0, size.y + 0.1, 0), size.x * 1.2)


## The marble Primm statue of the concepts (the fountain, the castle stair): a smiling round head, a cape, arms spread in welcome, gold accents.
## `height` metres from its feet at `base`, facing `normal`. `toppled` lays it on its back (the fallen state).
static func primm_statue(mesh: KitMesh, base: Vector3, height: float, normal: Vector3, toppled: bool = false, slot: String = "marble") -> void:
	var s: float = height / 3.0
	var right: Vector3 = Vector3.UP.cross(normal).normalized() * -1.0
	var up: Vector3 = Vector3.UP
	var fwd: Vector3 = normal
	if toppled:
		# lying on its back across the basin: the figure's up becomes -normal... rotate the frame
		up = -normal
		fwd = Vector3.UP
		base += Vector3(0, 0.35 * s, 0)
	var at: Callable = func(x: float, y: float, z: float) -> Vector3: return base + right * x * s + up * y * s + fwd * z * s
	# legs and boots, the robe, the cape, the chest
	for side: float in [-1.0, 1.0]:
		mesh.tube(slot, at.call(side * 0.16, 0.0, 0.0), at.call(side * 0.16, 0.9, 0.0), 0.13 * s, 8)
	mesh.tube("gold", at.call(0.0, 1.0, 0.0), at.call(0.0, 1.07, 0.0), 0.3 * s, 10)
	mesh.tube(slot, at.call(0.0, 0.7, 0.0), at.call(0.0, 1.0, 0.0), 0.3 * s, 10)
	mesh.tube(slot, at.call(0.0, 1.0, 0.0), at.call(0.0, 1.75, 0.0), 0.32 * s, 10)
	# the cape: a flared fan behind the shoulders down to the knees
	var cape_top_l: Vector3 = at.call(-0.36, 1.7, -0.12)
	var cape_top_r: Vector3 = at.call(0.36, 1.7, -0.12)
	mesh.quad(slot, [cape_top_l, cape_top_r, at.call(0.62, 0.35, -0.42), at.call(-0.62, 0.35, -0.42)], -fwd)
	mesh.quad(slot, [cape_top_l, cape_top_r, at.call(0.62, 0.35, -0.42), at.call(-0.62, 0.35, -0.42)], fwd)
	for side: float in [-1.0, 1.0]:
		mesh.tri(slot, [at.call(side * 0.36, 1.7, -0.12), at.call(side * 0.62, 0.35, -0.42), at.call(side * 0.42, 0.35, -0.1)], right * side)
	# the gold belt, the medallion and the collar
	_disc(mesh, "gold", at.call(0.0, 1.45, 0.33), 0.1 * s, fwd)
	mesh.lathe("gold", at.call(0.0, 1.72, 0.0), [Vector2(0.3 * s, 0.0), Vector2(0.2 * s, 0.12 * s)], 10, 1.0, false, false)
	# arms spread wide, open hands
	for side: float in [-1.0, 1.0]:
		var shoulder: Vector3 = at.call(side * 0.32, 1.66, 0.0)
		var elbow: Vector3 = at.call(side * 0.75, 1.8, 0.1)
		var hand: Vector3 = at.call(side * 1.1, 2.0, 0.18)
		mesh.tube(slot, shoulder, elbow, 0.1 * s, 8)
		mesh.tube(slot, elbow, hand, 0.085 * s, 8)
		mesh.tube("gold", elbow.lerp(hand, 0.7), elbow.lerp(hand, 0.82), 0.1 * s, 8)
		mesh.blob(slot, hand, Vector3(0.12, 0.08, 0.12) * s, 3, 8)
	# the head: a round smiling face and a swept fringe
	var head: Vector3 = at.call(0.0, 2.25, 0.02)
	mesh.blob(slot, head, Vector3(0.36, 0.38, 0.36) * s, 6, 14)
	mesh.blob(slot, head + up * 0.16 * s - fwd * 0.04 * s + right * 0.05 * s, Vector3(0.36, 0.22, 0.36) * s, 4, 12)
	var face_n: Vector3 = fwd
	for side: float in [-1.0, 1.0]:
		_disc(mesh, "stone_dark", head + right * side * 0.12 * s + up * 0.05 * s + face_n * 0.345 * s, 0.035 * s, face_n)
	for index: int in range(6):
		var a0: float = lerpf(PI * 1.2, PI * 1.8, float(index) / 6.0)
		var a1: float = lerpf(PI * 1.2, PI * 1.8, float(index + 1) / 6.0)
		var c: Vector3 = head + up * 0.02 * s + face_n * 0.35 * s
		mesh.quad("stone_dark", [c + (right * cos(a0) + up * sin(a0)) * 0.13 * s, c + (right * cos(a1) + up * sin(a1)) * 0.13 * s, c + (right * cos(a1) + up * sin(a1)) * 0.16 * s, c + (right * cos(a0) + up * sin(a0)) * 0.16 * s], face_n)
