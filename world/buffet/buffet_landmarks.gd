class_name BuffetLandmarks
extends RefCounted
## The Endless Buffet's hero landmarks modelled after the approved concepts (docs/art/zone_kits/buffet/concepts/*.jpg) with the zone kit's painted surfaces
## (data/art/zone_kits/buffet.json): the Test Kitchen (the main dungeon, a castle-sized gingerbread house beyond the north rim), the Cake Cathedral (the bakery
## square), Potato Peak (a view beyond the west rim where the Gravy River leaves the table), the Broccoli Giant (the forest's west edge) and the Omakase Pavilion
## (the Walk-In Freezer door into the side dungeon). `HeroLandmarks.build` dispatches "BUFF-HERO-" ids here. Same contract as the stand-ins (`LandmarkKit`):
## origin on the ground at the centre of the footprint, the front +z, `size` = w, h, d in metres, meta "circles" (local x, z, radius), "footprint", "height",
## "lights" and, for the Test Kitchen and Potato Peak, "steam" (local points the builder puts steam on). Nothing here carries readable text (Art Bible G-03).

const IDS: Array[String] = ["BUFF-HERO-TEST-KITCHEN", "BUFF-HERO-CAKE-CATHEDRAL", "BUFF-HERO-POTATO-PEAK", "BUFF-HERO-BROCCOLI-GIANT", "BUFF-HERO-OMAKASE-PAVILION"]
const CREAM: Color = Color("f4d8b0")
const TOMATO: Color = Color("e07a5f")
const CRUST: Color = Color("c98b3a")
const PINK: Color = Color("f6b8c4")
const HERB: Color = Color("6b8e3d")
const CHOCOLATE: Color = Color("7a4a2a")
const BUTTER: Color = Color("ffe066")
const GRAVY: Color = Color("8a4a1c")
const WHITE: Color = Color("fff6ea")
const STEEL: Color = Color("c8d0d8")
const COPPER: Color = Color("c8743a")
const WOOD: Color = Color("8a5a30")
const ROOF_RED: Color = Color("c8402e")
const BROCCOLI: Color = Color("4e7a2c")
const BROCCOLI_LIGHT: Color = Color("7aa842")
const STALK: Color = Color("c8d88a")
const STONE: Color = Color("f2ece0")
const ROCK: Color = Color("b89a90")
const GLOW: Color = Color("ffb860")
const CARD_UVS: Array[Vector2] = [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)]

static var _gravy_material: StandardMaterial3D
static var _glass_material: StandardMaterial3D


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
	var steam: Array[Vector3] = []
	var root: Node3D = Node3D.new()
	root.name = "Landmark_%s" % id
	match id:
		"BUFF-HERO-TEST-KITCHEN":
			_test_kitchen(root, mesh, size, circles, lights, steam)
		"BUFF-HERO-CAKE-CATHEDRAL":
			_cathedral(root, mesh, size, circles, lights)
		"BUFF-HERO-POTATO-PEAK":
			_potato_peak(root, mesh, size, circles, steam)
		"BUFF-HERO-BROCCOLI-GIANT":
			_broccoli_giant(root, mesh, size, circles)
		"BUFF-HERO-OMAKASE-PAVILION":
			_pavilion(root, mesh, size, circles, lights)
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
	root.set_meta("steam", steam)
	root.set_meta("triangles", mesh.triangle_count())
	return root


# ---- materials ----------------------------------------------------------------------------------------------------------------------------


## A kit surface when the zone has it, else the flat palette colour (the model still reads before the art is imported).
static func _surface(id: String, fallback: Color, mul: Color = Color.WHITE) -> Material:
	if EnvKit.has(id) and EnvKit.texture(id) != null:
		return EnvKit.material(id, false, mul)
	return EnvKit.flat(fallback * mul, "buff_hero")


static func gravy_material() -> StandardMaterial3D:
	if _gravy_material == null:
		_gravy_material = StandardMaterial3D.new()
		_gravy_material.albedo_color = GRAVY
		_gravy_material.roughness = 0.14
		_gravy_material.metallic = 0.1
		_gravy_material.metallic_specular = 0.9
		_gravy_material.emission_enabled = true
		_gravy_material.emission = GRAVY
		_gravy_material.emission_energy_multiplier = 0.22
		_gravy_material.vertex_color_use_as_albedo = true
		_gravy_material.set_meta(PaintedClasses.META_NO_PAINT, true)
		_gravy_material.set_meta(StyleToon.META_GLOSS, 0.5)
	return _gravy_material


static func glass_material() -> StandardMaterial3D:
	if _glass_material == null:
		_glass_material = StandardMaterial3D.new()
		_glass_material.albedo_color = Color(0.78, 0.95, 0.86, 0.42)
		_glass_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_glass_material.roughness = 0.1
		_glass_material.emission_enabled = true
		_glass_material.emission = Color(0.6, 0.9, 0.7)
		_glass_material.emission_energy_multiplier = 0.35
		_glass_material.cull_mode = BaseMaterial3D.CULL_DISABLED
		_glass_material.vertex_color_use_as_albedo = true
		_glass_material.set_meta(PaintedClasses.META_NO_PAINT, true)
		_glass_material.set_meta(StyleToon.META_NO_TOON, true)
	return _glass_material


static func _materials(mesh: KitMesh) -> void:
	mesh.set_material("biscuit", _surface("BUFF-WALL-BISCUIT", CRUST))
	mesh.set_material("biscuit_dark", _surface("BUFF-WALL-BISCUIT", CRUST, Color(0.78, 0.7, 0.6)))
	mesh.set_material("oven", _surface("BUFF-WALL-OVEN", TOMATO.darkened(0.25)))
	mesh.set_material("copper", _surface("BUFF-ROOF-COPPER", COPPER))
	mesh.set_material("crust", _surface("BUFF-ROOF-CRUST", CRUST))
	mesh.set_material("noodle", _surface("BUFF-PATH-NOODLE", CREAM))
	mesh.set_material("cloth", _surface("BUFF-TRIM-CLOTH", TOMATO))
	mesh.set_material("mashed", _surface("TEX-BUFF-MASHED", CREAM))
	mesh.set_material("mashed_warm", _surface("TEX-BUFF-MASHED", CREAM, Color(1.0, 0.94, 0.8)))
	mesh.set_material("frosting", _surface("TEX-BUFF-FROSTING", PINK))
	mesh.set_material("frosting_pink", _surface("TEX-BUFF-FROSTING", PINK, Color(1.0, 0.78, 0.84)))
	mesh.set_material("cheese", _surface("TEX-BUFF-CHEESE", BUTTER))
	mesh.set_material("gravy", gravy_material())
	mesh.set_material("glass", glass_material())
	# vertex colours are linear in Godot: the palette colours go in through srgb_to_linear so what shows is the palette, not a paler version of it
	mesh.set_material("flat", EnvKit.flat(Color.WHITE, "buff_hero"))
	mesh.alias("cream", "flat", CREAM.srgb_to_linear())
	mesh.alias("tomato", "flat", TOMATO.srgb_to_linear())
	mesh.alias("crust_flat", "flat", CRUST.srgb_to_linear())
	mesh.alias("pink", "flat", PINK.srgb_to_linear())
	mesh.alias("mint", "flat", Color("a8e6cf").srgb_to_linear())  # Fable Nov 16c: the gingerbread house's candy colours
	mesh.alias("lilac", "flat", Color("c9b3f0").srgb_to_linear())
	mesh.alias("herb", "flat", HERB.srgb_to_linear())
	mesh.alias("chocolate", "flat", CHOCOLATE.srgb_to_linear())
	mesh.alias("butter", "flat", BUTTER.srgb_to_linear())
	mesh.alias("white", "flat", WHITE.srgb_to_linear())
	mesh.alias("steel", "flat", STEEL.srgb_to_linear())
	mesh.alias("copper_flat", "flat", COPPER.srgb_to_linear())
	mesh.alias("wood", "flat", WOOD.srgb_to_linear())
	mesh.alias("wood_dark", "flat", WOOD.darkened(0.35).srgb_to_linear())
	mesh.alias("roof_red", "flat", ROOF_RED.srgb_to_linear())
	mesh.alias("broccoli", "flat", BROCCOLI.srgb_to_linear())
	mesh.alias("broccoli_light", "flat", BROCCOLI_LIGHT.srgb_to_linear())
	mesh.alias("stalk", "flat", STALK.srgb_to_linear())
	mesh.alias("stone", "flat", STONE.srgb_to_linear())
	mesh.alias("rock", "flat", ROCK.srgb_to_linear())
	mesh.alias("rice", "flat", Color("fbf6ea").srgb_to_linear())
	mesh.set_material("glow", EnvKit.glow(GLOW, 1.4))
	mesh.set_material("candle", EnvKit.glow(Color("ffd070"), 2.0))
	mesh.set_material("lantern", EnvKit.glow(Color("ffdca8"), 1.5))
	mesh.set_material("frost", EnvKit.glow(Color("bfe8ff"), 1.1))
	mesh.set_material("butter_glow", EnvKit.glow(Color("ffe88a"), 0.7))


## A painted cut-out standing upright in the mesh: pivot at `pivot_pos`, `height` metres tall, facing `normal` (horizontal unit vector).
## Batch 11: the salt-shaker pillar of the entrance bridge, and the height of the posts along its sides (the gate's pair is the gate's height).
const SALT_SHAKER: String = "BUF-PROP-SALT-SHAKER"
const SHAKER_POST_HEIGHT: float = 1.7


## A salt shaker standing at `base`, `height` metres: two crossed cards (it is round, so it reads from every side).
static func _shaker(mesh: KitMesh, base: Vector3, height: float) -> void:
	_card(mesh, SALT_SHAKER, base, height, Vector3(0, 0, 1))
	_card(mesh, SALT_SHAKER, base, height, Vector3(1, 0, 0))


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


## A strawberry: a red blob with a leaf cap.
static func _strawberry(mesh: KitMesh, base: Vector3, size: float) -> void:
	mesh.blob("tomato", base + Vector3(0, size * 0.55, 0), Vector3(size * 0.5, size * 0.62, size * 0.5), 4, 8, 1.0)
	mesh.blob("herb", base + Vector3(0, size * 1.08, 0), Vector3(size * 0.34, size * 0.14, size * 0.34), 3, 6, 1.0)


## A cream piping ring (a bulge of frosting) round a tier's top edge.
static func _piping(mesh: KitMesh, center: Vector3, radius: float, thickness: float, segments: int = 18) -> void:
	mesh.lathe("white", center, [Vector2(radius - thickness * 0.3, 0.0), Vector2(radius + thickness * 0.5, thickness * 0.5), Vector2(radius + thickness * 0.3, thickness * 1.0), Vector2(radius - thickness * 0.6, thickness * 1.15)], segments, 1.0, false, true)


## A candle: a cream column with a flame on top.
static func _candle(mesh: KitMesh, base: Vector3, height: float, radius: float) -> void:
	mesh.tube("white", base, base + Vector3(0, height, 0), radius, 7, true)
	mesh.blob("candle", base + Vector3(0, height + radius * 1.6, 0), Vector3(radius * 1.1, radius * 2.2, radius * 1.1), 4, 7, 1.0)


## A copper chimney stack with a cream cap; returns the local top for steam.
static func _chimney(mesh: KitMesh, base: Vector3, height: float, radius: float) -> Vector3:
	mesh.lathe("copper", base, [Vector2(radius * 1.25, 0.0), Vector2(radius * 1.25, 0.6), Vector2(radius, 0.9), Vector2(radius, height - 0.8), Vector2(radius * 1.2, height - 0.6), Vector2(radius * 1.2, height)], 10, 0.9, false, true)
	mesh.lathe("white", base + Vector3(0, height, 0), [Vector2(radius * 1.35, 0.0), Vector2(radius * 1.4, 0.5), Vector2(radius * 1.1, 0.9), Vector2(0.0, 1.0)], 10, 1.0, false, true)
	return base + Vector3(0, height + 1.0, 0)


## A paper lantern hanging from `hook`, a light entry with it.
static func _lantern(mesh: KitMesh, hook: Vector3, lights: Array[Dictionary], size: float = 0.5) -> void:
	mesh.tube("wood_dark", hook, hook - Vector3(0, size * 0.5, 0), 0.03, 4, false)
	var center: Vector3 = hook - Vector3(0, size * 0.5 + size * 0.6, 0)
	mesh.blob("lantern", center, Vector3(size * 0.5, size * 0.62, size * 0.5), 4, 8, 1.0)
	mesh.tube("wood_dark", center + Vector3(0, size * 0.62, 0), center + Vector3(0, size * 0.72, 0), size * 0.22, 6, true)
	mesh.tube("wood_dark", center - Vector3(0, size * 0.62, 0), center - Vector3(0, size * 0.72, 0), size * 0.22, 6, true)
	lights.append({"pos": center, "color": Color("ffd9a0"), "range": 6.0, "energy": 1.1, "kind": "lantern"})


## Fable Nov 12 (art critic #8: "windows are flat colour cut-outs"): the glazing bars of a lit pane facing +z - a dark frame, one upright and
## two rails - so a glowing rectangle reads as a window.
static func _pane_bars(mesh: KitMesh, center: Vector3, size: Vector2) -> void:
	var bar: float = 0.07
	mesh.box("wood_dark", center, Vector3(bar, size.y, 0.05), Basis.IDENTITY, 0.0)
	for rail: float in [-0.2, 0.22]:
		mesh.box("wood_dark", center + Vector3(0.0, size.y * rail, 0.0), Vector3(size.x, bar, 0.05), Basis.IDENTITY, 0.0)
	for side: float in [-1.0, 1.0]:
		mesh.box("wood_dark", center + Vector3(side * (size.x * 0.5 - bar * 0.5), 0.0, 0.0), Vector3(bar, size.y, 0.06), Basis.IDENTITY, 0.0)
		mesh.box("wood_dark", center + Vector3(0.0, side * (size.y * 0.5 - bar * 0.5), 0.0), Vector3(size.x, bar, 0.06), Basis.IDENTITY, 0.0)


## A gothic window: a glowing pane in a frame with a pointed top.
static func _gothic_window(mesh: KitMesh, slot: String, center: Vector3, width: float, height: float, normal: Vector3) -> void:
	var right: Vector3 = Vector3.UP.cross(normal).normalized() * -1.0
	var basis: Basis = Basis.looking_at(normal, Vector3.UP)
	mesh.box(slot, center + normal * 0.02, Vector3(width + 0.3, height + 0.3, 0.2), basis, 0.02)
	mesh.box("glow", center + normal * 0.14, Vector3(width, height, 0.1), basis, 0.0)
	var peak: Vector3 = center + Vector3(0, height * 0.5 + width * 0.45, 0) + normal * 0.14
	mesh.tri("glow", [center + Vector3(0, height * 0.5, 0) - right * width * 0.5 + normal * 0.14, center + Vector3(0, height * 0.5, 0) + right * width * 0.5 + normal * 0.14, peak], normal)
	mesh.tri(slot, [center + Vector3(0, height * 0.5, 0) - right * (width * 0.5 + 0.15) + normal * 0.02, center + Vector3(0, height * 0.5, 0) + right * (width * 0.5 + 0.15) + normal * 0.02, peak + Vector3(0, 0.2, 0) - normal * 0.12], normal)


# ---- The Test Kitchen ---------------------------------------------------------------------------------------------------------------------------


## The main dungeon: the Test Kitchen, a castle-sized **gingerbread house** on a biscuit plinth beyond the north rim (Fable Nov 16c, Part 4.1:
## rebuilt from the kit's own pieces as one solid house; it was a kitchen-laboratory with copper tanks, greenhouses, two cranes, seven
## chimney stacks, four cake towers and a chef's-hat dome). One silhouette: a tall biscuit house under one steep pie-crust gable roof, its
## gable to the front; thick white frosting along the eaves (with drips), the gable's edges (scalloped) and the ridge, gumdrops on it;
## frosted and candy-cane windows from the kit's window sheet; a low biscuit forecourt wall with a frosting cap and candy-cane posts at
## its corners; and the gate - two biscuit towers with frosting cone roofs (the only two towers), a frosted arch, candy-cane posts and
## the kit's big frosted gingerbread door. One frosted chimney stands in the roof (meta "steam"). The plinth, the threshold, the gate's
## place and size, the two tower circles and the footprint circle are unchanged: the door, the spot and the walk grid stay where they were.
static func _test_kitchen(root: Node3D, mesh: KitMesh, size: Vector3, circles: Array[Vector3], lights: Array[Dictionary], steam: Array[Vector3]) -> void:
	var hw: float = size.x * 0.5
	var hd: float = size.z * 0.5
	var height: float = size.y
	# the biscuit plinth and the terrace floor
	mesh.box("biscuit_dark", Vector3(0, -4.8, -1.0), Vector3(size.x + 4.0, 9.2, size.z + 2.0), Basis.IDENTITY, 0.8, 0.78)
	mesh.box("noodle", Vector3(0, -0.1, -1.0), Vector3(size.x + 2.0, 0.3, size.z), Basis.IDENTITY, 0.05)
	# the threshold slab reaching south over the table rim to the forecourt (walkable ground is the table's own)
	mesh.box("noodle", Vector3(0, -0.08, hd + 2.6), Vector3(9.0, 0.26, 6.0), Basis.IDENTITY, 0.04)
	mesh.box("cloth", Vector3(0, 0.05, hd + 2.6), Vector3(4.0, 0.06, 6.0), Basis.IDENTITY, 0.0)
	# the forecourt wall: biscuit, a thick frosting cap with drips, a gumdrop every few metres, a frosted window in each half
	var wall_h: float = height * 0.2
	var gate_w: float = 7.0
	var front_z: float = hd - 1.2
	var candies: Array[String] = ["pink", "mint", "butter", "tomato", "lilac"]
	for side: float in [-1.0, 1.0]:
		var span: float = hw - gate_w * 0.5 - 2.6
		var cx: float = side * (gate_w * 0.5 + 2.6 + span * 0.5)
		mesh.box("biscuit", Vector3(cx, wall_h * 0.5 - 0.3, front_z), Vector3(span, wall_h + 0.6, 2.4), Basis.IDENTITY, 0.08, 0.86)
		_frosting_run(mesh, Vector3(cx - span * 0.5, wall_h + 0.35, front_z), Vector3(cx + span * 0.5, wall_h + 0.35, front_z), 0.9, 2.9, Vector3(0, 0, 1), candies, 1.5)
		var windows: int = maxi(2, int(span / 7.5))
		for index: int in range(windows):
			var wx: float = cx - span * 0.5 + span * (float(index) + 0.5) / float(windows)
			_house_window(mesh, "BUFF-SHEET-WINDOWS-01" if index % 2 == 0 else "BUFF-SHEET-WINDOWS-02", Vector3(wx, wall_h * 0.5, front_z + 1.22), 3.4, lights, index == 0)
	for side: float in [-1.0, 1.0]:
		mesh.box("biscuit", Vector3(side * (hw - 1.2), wall_h * 0.5 - 0.3, -1.0), Vector3(2.4, wall_h + 0.6, size.z - 2.0), Basis.IDENTITY, 0.08, 0.86)
		_frosting_run(mesh, Vector3(side * (hw - 1.2), wall_h + 0.35, -hd + 1.0), Vector3(side * (hw - 1.2), wall_h + 0.35, hd - 3.0), 0.9, 2.9, Vector3(side, 0, 0), candies, 1.5)
	mesh.box("biscuit", Vector3(0, wall_h * 0.5 - 0.3, -hd + 1.2), Vector3(size.x, wall_h + 0.6, 2.4), Basis.IDENTITY, 0.08, 0.86)
	# a candy-cane post at each front corner of the wall (the corner cake towers are gone: the gate's two towers are the only towers)
	for side: float in [-1.0, 1.0]:
		_candy_cane(mesh, Vector3(side * (hw - 1.2), wall_h + 0.6, front_z), height * 0.2, 0.55, -side)
	# the gate: two biscuit towers under frosting cone roofs, a frosted arch, candy-cane posts, the big frosted door, icon signs
	var tower_w: float = 4.0
	var gate_h: float = height * 0.34
	for side: float in [-1.0, 1.0]:
		var tx: float = side * (gate_w * 0.5 + tower_w * 0.5 + 0.2)
		var tower: Vector3 = Vector3(tx, 0.0, front_z + 0.6)
		mesh.box("biscuit", tower + Vector3(0, gate_h * 0.5 - 0.3, 0), Vector3(tower_w, gate_h + 0.6, tower_w + 1.2), Basis.IDENTITY, 0.1, 0.86)
		# a thick frosting collar with drips, then a pie-crust cone iced white at the top with a cherry
		mesh.box("white", tower + Vector3(0, gate_h + 0.45, 0), Vector3(tower_w + 0.9, 0.9, tower_w + 2.1), Basis.IDENTITY, 0.3)
		for corner_x: float in [-1.0, 1.0]:
			for corner_z: float in [-1.0, 1.0]:
				mesh.blob("white", tower + Vector3(corner_x * (tower_w * 0.5 + 0.3), gate_h - 0.25, corner_z * (tower_w * 0.5 + 0.9)), Vector3(0.42, 0.85, 0.42), 4, 7, 1.0)
		mesh.lathe("crust", tower + Vector3(0, gate_h + 0.85, 0), [Vector2(tower_w * 0.74, 0.0), Vector2(tower_w * 0.56, 1.9), Vector2(tower_w * 0.3, 3.9), Vector2(0.0, 5.6)], 12, 0.95, false, true)
		mesh.lathe("white", tower + Vector3(0, gate_h + 4.5, 0), [Vector2(tower_w * 0.32, 0.0), Vector2(tower_w * 0.2, 1.0), Vector2(0.0, 2.2)], 12, 1.0, false, true)
		mesh.blob("tomato", tower + Vector3(0, gate_h + 6.9, 0), Vector3(0.6, 0.6, 0.6), 4, 8, 1.0)
		_card(mesh, "BUFF-SHEET-SIGNS-01" if side < 0.0 else "BUFF-SHEET-SIGNS-03", Vector3(tx - side * 0.9, gate_h * 0.62, front_z + 0.6 + tower_w * 0.5 + 0.7), 2.4, Vector3(0, 0, 1))
		_house_window(mesh, "BUFF-SHEET-WINDOWS-03", Vector3(tx, gate_h * 0.82, front_z + 0.6 + tower_w * 0.5 + 0.64), 2.0, lights, false)
		circles.append(Vector3(tx, front_z + 0.6, tower_w * 0.75))
	var arch_r: float = gate_w * 0.5 + 0.3
	for step: int in range(10):
		var a0: float = PI * float(step) / 10.0
		var a1: float = PI * float(step + 1) / 10.0
		var p0: Vector3 = Vector3(cos(a0) * arch_r, gate_h * 0.5 + sin(a0) * arch_r, front_z + 0.6)
		var p1: Vector3 = Vector3(cos(a1) * arch_r, gate_h * 0.5 + sin(a1) * arch_r, front_z + 0.6)
		var along: Vector3 = p1 - p0
		mesh.box("crust", (p0 + p1) * 0.5, Vector3(along.length() + 0.3, 1.4, tower_w + 1.0), Basis(Vector3(0, 0, 1), atan2(along.y, along.x)), 0.03)
		# piped frosting along the arch's front edge, a gumdrop on every other bead
		var bead: Vector3 = Vector3(cos((a0 + a1) * 0.5) * (arch_r + 0.5), gate_h * 0.5 + sin((a0 + a1) * 0.5) * (arch_r + 0.5), front_z + 0.6 + tower_w * 0.5 + 0.55)
		mesh.blob("white", bead, Vector3(0.62, 0.62, 0.5), 4, 8, 1.0)
		if step % 2 == 1:
			mesh.blob(candies[(step / 2) % candies.size()], bead + Vector3(0, 0, 0.42), Vector3(0.3, 0.3, 0.26), 3, 6, 1.0)
	mesh.box("biscuit", Vector3(0, gate_h * 0.5 + arch_r + 1.0, front_z + 0.6), Vector3(gate_w + 2.0, 2.0, tower_w + 1.0), Basis.IDENTITY, 0.05)
	_frosting_run(mesh, Vector3(-gate_w * 0.5 - 1.0, gate_h * 0.5 + arch_r + 2.2, front_z + 0.6), Vector3(gate_w * 0.5 + 1.0, gate_h * 0.5 + arch_r + 2.2, front_z + 0.6), 0.8, tower_w + 1.5, Vector3(0, 0, 1), candies, 1.3)
	# the doorway: a lit opening with cream steps up to it from the threshold slab, the kit's frosted gingerbread double door in it
	mesh.box("glow", Vector3(0, gate_h * 0.25, front_z - 0.4), Vector3(gate_w - 0.6, gate_h * 0.5 + 0.2, 0.3), Basis.IDENTITY, 0.0)
	var door_w: float = gate_w - 0.6
	var door_h: float = gate_h * 0.5 + 0.2
	var door_y: float = gate_h * 0.25
	var door_id: String = "BUFF-SHEET-DOORS-05" if EnvKit.has("BUFF-SHEET-DOORS-05") else "BUFF-SHEET-DOORS-04"
	var painted_door: bool = EnvKit.has(door_id)
	if painted_door:
		var card_h: float = minf(door_h * 1.22, door_w / maxf(EnvKit.aspect(door_id), 0.1))
		_card(mesh, door_id, Vector3(0, 0.6, front_z - 0.2), card_h, Vector3(0, 0, 1))
	for side: float in ([] as Array[float] if painted_door else [-1.0, 1.0] as Array[float]):
		var leaf_w: float = door_w * 0.36
		var leaf_x: float = side * (door_w * 0.5 - leaf_w * 0.5)
		mesh.box("wood_dark", Vector3(leaf_x, door_y, front_z - 0.18), Vector3(leaf_w, door_h, 0.14), Basis(Vector3.UP, side * 0.22), 0.02)
		mesh.box("white", Vector3(leaf_x, door_y + door_h * 0.28, front_z - 0.08), Vector3(leaf_w * 0.9, 0.16, 0.05), Basis(Vector3.UP, side * 0.22), 0.0)
		mesh.box("white", Vector3(leaf_x, door_y - door_h * 0.28, front_z - 0.08), Vector3(leaf_w * 0.9, 0.16, 0.05), Basis(Vector3.UP, side * 0.22), 0.0)
		mesh.blob("butter", Vector3(side * door_w * 0.17, door_y - 0.1, front_z - 0.02), Vector3(0.12, 0.12, 0.08), 3, 6, 1.0)
	for side: float in [-1.0, 1.0]:
		_candy_cane(mesh, Vector3(side * (gate_w * 0.5 - 0.15), 0.3, front_z + 0.6 + tower_w * 0.5 + 0.75), gate_h * 0.5, 0.3, -side)
	for step: int in range(3):
		mesh.box("white", Vector3(0, 0.1 + float(step) * 0.22, front_z + 3.4 - float(step) * 0.5), Vector3(gate_w + 1.0 - float(step) * 0.4, 0.22, 0.5), Basis.IDENTITY, 0.02)
	lights.append({"pos": Vector3(0, 2.4, front_z + 1.6), "color": GLOW, "range": 10.0, "energy": 1.4, "kind": "gate"})
	# the house: one biscuit body under one steep pie-crust gable roof, the gable to the front
	var house_w: float = size.x * 0.66
	var house_d: float = size.z * 0.6
	var house_h: float = height * 0.4
	var house_z: float = -2.6
	var face_z: float = house_z + house_d * 0.5
	mesh.box("biscuit", Vector3(0, house_h * 0.5 - 0.3, house_z), Vector3(house_w, house_h + 0.6, house_d), Basis.IDENTITY, 0.12, 0.86)
	var pitch: float = deg_to_rad(40.0)
	var overhang: float = 2.4
	var verge: float = 1.6
	var run: float = house_w * 0.5 + overhang
	var peak_y: float = house_h + house_w * 0.5 * tan(pitch)
	# the two gables (the body's walls carried up to the ridge)
	for face: float in [1.0, -1.0]:
		var z: float = house_z + face * house_d * 0.5
		var corners: Array[Vector3] = [Vector3(-house_w * 0.5, house_h, z), Vector3(house_w * 0.5, house_h, z), Vector3(0.0, peak_y, z)]
		if face < 0.0:
			corners = [corners[1], corners[0], corners[2]]
		mesh.tri("biscuit", corners, Vector3(0, 0, face))
	# the roof: two thick crust slabs, frosting on the eaves (with drips), on both verges (scalloped) and along the ridge, gumdrops on it
	var slab_len: float = run / cos(pitch)
	var eave_y: float = house_h - overhang * tan(pitch)
	for side: float in [-1.0, 1.0]:
		var slope: Basis = Basis(Vector3(0, 0, 1), -side * pitch)
		var middle: Vector3 = Vector3(side * run * 0.5, (peak_y + eave_y) * 0.5 + 0.55, house_z)
		mesh.box("crust", middle, Vector3(slab_len + 0.3, 1.1, house_d + verge * 2.0), slope, 0.06, 0.95)
		# the eave: a fat roll of frosting along the lower edge, a drip every two metres (long, short, long...)
		var eave: Vector3 = Vector3(side * run, eave_y + 0.5, house_z)
		_frosting_run(mesh, eave + Vector3(0, 0, -house_d * 0.5 - verge), eave + Vector3(0, 0, house_d * 0.5 + verge), 1.5, 2.2, Vector3(side, 0, 0), candies, 2.1, slope)
		# the verges: frosting scallops down the gable's edge at the front (and a plain band at the back)
		var scallops: int = int(slab_len / 2.3)
		for index: int in range(scallops + 1):
			var t: float = float(index) / float(scallops)
			var on_edge: Vector3 = Vector3(side * run * t, lerpf(peak_y, eave_y, t) + 0.75, face_z + verge + 0.1)
			mesh.blob("white", on_edge, Vector3(1.25, 1.05, 0.95), 4, 8, 1.0)
			if index % 2 == 1:
				mesh.blob(candies[index % candies.size()], on_edge + Vector3(0, 0.1, 0.85), Vector3(0.5, 0.5, 0.42), 4, 7, 1.0)
		mesh.box("white", middle + Vector3(0, 0.1, -house_d * 0.5 - verge), Vector3(slab_len + 0.5, 1.5, 1.0), slope, 0.3)
		# a row of round crust shingles' worth of frosting dots half-way up the slope (piped rosettes), front half of the roof only
		for index: int in range(6):
			var along: float = house_z - house_d * 0.5 + (float(index) + 0.5) * house_d / 6.0
			var half_way: Vector3 = Vector3(side * run * 0.5, (peak_y + eave_y) * 0.5 + 1.2, along)
			mesh.blob("white" if index % 2 == 0 else "pink", half_way, Vector3(0.75, 0.42, 0.75), 3, 7, 1.0)
	mesh.box("white", Vector3(0, peak_y + 0.75, house_z), Vector3(2.6, 1.5, house_d + verge * 2.0 + 0.6), Basis.IDENTITY, 0.5)
	var drops: int = int((house_d + verge * 2.0) / 2.6)
	for index: int in range(drops + 1):
		var ridge: Vector3 = Vector3(0, peak_y + 1.75, house_z - house_d * 0.5 - verge + (house_d + verge * 2.0) * float(index) / float(drops))
		mesh.blob(candies[index % candies.size()], ridge, Vector3(0.72, 0.7, 0.72), 4, 8, 1.0)
	# the gable's finial: one big frosting swirl with a cherry over the front peak
	mesh.lathe("white", Vector3(0, peak_y + 1.2, face_z + verge), [Vector2(1.7, 0.0), Vector2(1.5, 0.8), Vector2(0.9, 1.7), Vector2(0.0, 2.6)], 12, 1.0, true, true)
	mesh.blob("tomato", Vector3(0, peak_y + 4.2, face_z + verge), Vector3(0.75, 0.75, 0.75), 4, 8, 1.0)
	# the front: a round candy-cane window high in the gable, a row of frosted windows over the gate, a frosting band at the eaves' height
	_house_window(mesh, "BUFF-SHEET-WINDOWS-03", Vector3(0, house_h + (peak_y - house_h) * 0.36, face_z + 0.12), 6.4, lights, true)
	_frosting_run(mesh, Vector3(-house_w * 0.5, house_h + 0.1, face_z + 0.3), Vector3(house_w * 0.5, house_h + 0.1, face_z + 0.3), 0.8, 0.9, Vector3(0, 0, 1), candies, 2.0)
	for index: int in range(5):
		var wx: float = (float(index) - 2.0) * house_w * 0.19
		_house_window(mesh, "BUFF-SHEET-WINDOWS-01" if index % 2 == 0 else "BUFF-SHEET-WINDOWS-02", Vector3(wx, house_h * 0.7, face_z + 0.12), 3.8, lights, index % 2 == 0)
	# piped icing on the gable: a scalloped line under the round window and three gumdrops either side of it
	var icing_y: float = house_h + (peak_y - house_h) * 0.12
	var icing_half: float = house_w * 0.5 * (1.0 - 0.12) - 2.6
	for index: int in range(15):
		var t: float = float(index) / 14.0
		mesh.blob("white", Vector3(lerpf(-icing_half, icing_half, t), icing_y + 0.5 * absf(sin(t * PI * 7.0)), face_z + 0.2), Vector3(0.95, 0.5, 0.4), 3, 7, 1.0)
	for side: float in [-1.0, 1.0]:
		for index: int in range(3):
			mesh.blob(candies[(index + (1 if side < 0.0 else 3)) % candies.size()], Vector3(side * (5.6 + float(index) * 2.3), house_h + (peak_y - house_h) * (0.36 - 0.06 * float(index)), face_z + 0.3), Vector3(0.7, 0.7, 0.45), 4, 8, 1.0)
	# frosting down the four corners of the house, a gumdrop stud line beside each
	for side: float in [-1.0, 1.0]:
		for face: float in [1.0, -1.0]:
			var corner: Vector3 = Vector3(side * house_w * 0.5, 0.0, house_z + face * house_d * 0.5)
			mesh.tube("white", corner + Vector3(0, 0.2, 0), corner + Vector3(0, house_h + 0.2, 0), 0.6, 8, true)
		for index: int in range(4):
			var stud: Vector3 = Vector3(side * (house_w * 0.5 - 1.5), house_h * (0.2 + 0.2 * float(index)), face_z + 0.25)
			mesh.blob(candies[(index + (0 if side < 0.0 else 2)) % candies.size()], stud, Vector3(0.45, 0.45, 0.3), 4, 7, 1.0)
	# one frosted gingerbread chimney in the right slope, well inside the roof (the only thing that stands in it), steam from its top
	var chimney_x: float = house_w * 0.24
	var chimney_foot: float = peak_y - chimney_x * tan(pitch)
	var chimney_top: float = peak_y + 2.6
	mesh.box("biscuit", Vector3(chimney_x, (chimney_foot + chimney_top) * 0.5, house_z - house_d * 0.18), Vector3(3.4, chimney_top - chimney_foot + 1.0, 3.4), Basis.IDENTITY, 0.1, 0.9)
	mesh.box("white", Vector3(chimney_x, chimney_top + 0.75, house_z - house_d * 0.18), Vector3(4.3, 1.1, 4.3), Basis.IDENTITY, 0.4)
	for corner_x: float in [-1.0, 1.0]:
		mesh.blob("white", Vector3(chimney_x + corner_x * 1.9, chimney_top, house_z - house_d * 0.18 + 1.9), Vector3(0.4, 0.8, 0.4), 4, 7, 1.0)
	steam.append(Vector3(chimney_x, chimney_top + 1.4, house_z - house_d * 0.18))
	# bunting between the gate towers and the corner candy canes
	for side: float in [-1.0, 1.0]:
		var from: Vector3 = Vector3(side * (gate_w * 0.5 + tower_w + 0.2), gate_h + 0.3, front_z + 1.4)
		var to: Vector3 = Vector3(side * (hw - 1.2), wall_h + 0.6 + height * 0.17, front_z)
		mesh.tube("wood_dark", from, to, 0.05, 4, false)
		for index: int in range(1, 7):
			var p: Vector3 = from.lerp(to, float(index) / 7.0) - Vector3(0, 0.3 * sin(PI * float(index) / 7.0) * 3.0, 0)
			mesh.tri("pink" if index % 2 == 0 else "mint", [p + Vector3(-0.45, 0.0, 0), p + Vector3(0.45, 0.0, 0), p + Vector3(0, -0.8, 0)], Vector3(0, 0, 1))
	# the footprint circles (the model stands beyond the rim: only the gate towers ever meet the hero)
	circles.append(Vector3(0.0, -2.0, hw))


## A thick roll of white frosting from `from` to `to` (a straight run), `thick` metres high and `deep` across, with a drip hanging
## from its `outward` side every `gap` metres (alternately long and short) and a gumdrop on top between the drips. `turn` tilts the
## roll (a roof slope's basis).
static func _frosting_run(mesh: KitMesh, from: Vector3, to: Vector3, thick: float, deep: float, outward: Vector3, candies: Array[String], gap: float, turn: Basis = Basis.IDENTITY) -> void:
	var along: Vector3 = to - from
	var length: float = along.length()
	if length < 0.1:
		return
	var across_x: bool = absf(along.x) >= absf(along.z)
	var box_size: Vector3 = Vector3(length + 0.3, thick, deep) if across_x else Vector3(deep, thick, length + 0.3)
	mesh.box("white", (from + to) * 0.5, box_size, turn, minf(thick, deep) * 0.4)
	var count: int = maxi(1, int(length / gap))
	var half: float = deep * 0.5
	for index: int in range(count + 1):
		var at: Vector3 = from.lerp(to, float(index) / float(count))
		var drop: float = thick * (1.3 if index % 2 == 0 else 0.75)
		mesh.blob("white", at + outward * (half - 0.05) - Vector3(0, thick * 0.35 + drop * 0.45, 0), Vector3(thick * 0.42, drop, thick * 0.42), 4, 7, 1.0)
		if index < count and not candies.is_empty():
			var between: Vector3 = from.lerp(to, (float(index) + 0.5) / float(count))
			mesh.blob(candies[index % candies.size()], between + Vector3(0, thick * 0.55, 0) + outward * (half * 0.35), Vector3(thick * 0.4, thick * 0.38, thick * 0.4), 4, 7, 1.0)


## A candy cane standing at `base`: a white post `height` tall with red stripes and a hook at the top bending toward `hook` (-1 or 1 on x).
static func _candy_cane(mesh: KitMesh, base: Vector3, height: float, radius: float, hook: float) -> void:
	var bands: int = maxi(4, int(height / (radius * 2.6)))
	var band: float = height / float(bands)
	for index: int in range(bands):
		var low: Vector3 = base + Vector3(0, band * float(index), 0)
		mesh.tube("tomato" if index % 2 == 1 else "white", low, low + Vector3(0, band, 0), radius, 8, index == 0)
	var bend: float = radius * 3.2
	var centre: Vector3 = base + Vector3(hook * bend, height, 0)
	var last: Vector3 = base + Vector3(0, height, 0)
	for step: int in range(1, 7):
		var angle: float = PI * 0.92 * float(step) / 6.0
		var next: Vector3 = centre + Vector3(-hook * cos(angle) * bend, sin(angle) * bend, 0)
		mesh.tube("tomato" if step % 2 == 1 else "white", last, next, radius, 8, step == 6)
		last = next


## A window of the kit's window sheet standing on a wall that faces +z, `height` metres tall, centred at `center`; `lit` adds a warm
## light in front of it. Without the art: a glowing pane with glazing bars in a frosting frame.
static func _house_window(mesh: KitMesh, id: String, center: Vector3, height: float, lights: Array[Dictionary], lit: bool) -> void:
	if EnvKit.has(id):
		_card(mesh, id, center - Vector3(0, height * 0.5, 0), height, Vector3(0, 0, 1))
	else:
		var pane: Vector2 = Vector2(height * 0.6, height * 0.8)
		mesh.box("white", center, Vector3(pane.x + 0.6, pane.y + 0.6, 0.2), Basis.IDENTITY, 0.1)
		mesh.box("glow", center + Vector3(0, 0, 0.12), Vector3(pane.x, pane.y, 0.1), Basis.IDENTITY, 0.0)
		_pane_bars(mesh, center + Vector3(0, 0, 0.2), pane)
	if lit:
		lights.append({"pos": center + Vector3(0, 0, 1.6), "color": GLOW, "range": 7.0, "energy": 0.8, "kind": "oven"})


# ---- The Cake Cathedral ----------------------------------------------------------------------------------------------------------------------------


## The bakery square's landmark: three pink frosting tiers with cream piping, cream columns, gothic sugar-glass windows, strawberries, candle spires, a gold dome
## with a strawberry finial, a biscuit plinth with a stair, and topiary cones with roses round the foot.
static func _cathedral(root: Node3D, mesh: KitMesh, size: Vector3, circles: Array[Vector3], lights: Array[Dictionary]) -> void:
	var hw: float = size.x * 0.5
	var height: float = size.y
	var radii: Array[float] = [hw, hw * 0.72, hw * 0.47]
	var heights: Array[float] = [height * 0.3, height * 0.27, height * 0.22]
	# the biscuit plinth and the front stair
	mesh.box("biscuit", Vector3(0, 0.3, 0), Vector3(size.x + 1.4, 0.9, size.z + 1.4), Basis.IDENTITY, 0.12, 0.84)
	mesh.box("cloth", Vector3(0, 0.78, 0), Vector3(size.x + 1.5, 0.08, size.z + 1.5), Basis.IDENTITY, 0.0)
	for step: int in range(3):
		mesh.box("white", Vector3(0, 0.12 + float(step) * 0.25, hw + 1.6 - float(step) * 0.45), Vector3(3.0 - float(step) * 0.3, 0.25, 0.5), Basis.IDENTITY, 0.02)
	var base_y: float = 0.75
	for tier: int in range(3):
		var r: float = radii[tier]
		var h: float = heights[tier]
		var center: Vector3 = Vector3(0, base_y, 0)
		mesh.lathe("frosting_pink", center, [Vector2(r, 0.0), Vector2(r, h)], 20, 0.9, false, true)
		_piping(mesh, center + Vector3(0, h - 0.1, 0), r, 0.55 + 0.15 * float(2 - tier), 20)
		var columns: int = 8 - tier
		for index: int in range(columns):
			var angle: float = TAU * float(index) / float(columns) + PI * 0.5
			var at: Vector3 = center + Vector3(cos(angle) * (r + 0.12), 0.0, sin(angle) * (r + 0.12))
			mesh.tube("white", at, at + Vector3(0, h + 0.1, 0), 0.26 + 0.05 * float(2 - tier), 8, true)
			mesh.blob("white", at + Vector3(0, h + 0.25, 0), Vector3(0.42, 0.3, 0.42), 3, 8, 1.0)
			if index % 2 == 0:
				_candle(mesh, at + Vector3(0, h + 0.45, 0), 1.0 + 0.3 * float(2 - tier), 0.2)
			else:
				_strawberry(mesh, at + Vector3(0, h + 0.4, 0), 0.9)
			# a gothic window between this column and the next, on the front and sides
			var mid: float = angle + PI / float(columns)
			var normal: Vector3 = Vector3(cos(mid), 0.0, sin(mid))
			if normal.z > -0.2:
				_gothic_window(mesh, "pink", center + normal * r + Vector3(0, h * 0.5, 0), 0.9 - 0.15 * float(tier), h * 0.5, normal)
		base_y += h
	# the gold dome and the strawberry on top, candle spires at the dome's foot
	var dome_r: float = radii[2] * 0.8
	mesh.lathe("butter", Vector3(0, base_y, 0), [Vector2(dome_r, 0.0), Vector2(dome_r * 0.92, dome_r * 0.5), Vector2(dome_r * 0.55, dome_r * 0.9), Vector2(0.0, dome_r * 1.05)], 16, 0.95, false, true)
	_piping(mesh, Vector3(0, base_y + dome_r * 1.0, 0), dome_r * 0.3, 0.35, 10)
	_strawberry(mesh, Vector3(0, base_y + dome_r * 1.2, 0), 1.6)
	for index: int in range(4):
		var angle: float = TAU * float(index) / 4.0 + PI * 0.25
		_candle(mesh, Vector3(cos(angle) * dome_r * 1.05, base_y, sin(angle) * dome_r * 1.05), 1.8, 0.22)
	# the door: a lit gothic opening at the front of the first tier
	_gothic_window(mesh, "white", Vector3(0, 0.75 + 1.6, radii[0]), 1.5, 2.8, Vector3(0, 0, 1))
	lights.append({"pos": Vector3(0, 2.0, radii[0] + 1.5), "color": GLOW, "range": 7.0, "energy": 1.1, "kind": "door"})
	# topiary cones with roses round the plinth
	for index: int in range(6):
		var angle: float = TAU * float(index) / 6.0 + PI / 12.0
		var at: Vector3 = Vector3(cos(angle) * (hw + 1.9), 0.0, sin(angle) * (hw + 1.9))
		if at.z > hw * 0.5 and absf(at.x) < 2.2:
			continue
		mesh.lathe("herb", at, [Vector2(0.75, 0.0), Vector2(0.62, 0.9), Vector2(0.4, 1.7), Vector2(0.0, 2.3)], 8, 0.85, true, true)
		mesh.blob("pink", at + Vector3(0.3, 0.9, 0.42), Vector3(0.14, 0.14, 0.14), 3, 5, 1.0)
		mesh.blob("tomato", at + Vector3(-0.36, 1.3, 0.3), Vector3(0.12, 0.12, 0.12), 3, 5, 1.0)
	circles.append(Vector3(0.0, 0.0, hw + 1.0))
	circles.append(Vector3(0.0, hw + 1.6, 1.6))
	root.set_meta("plinth_radius", hw + 1.0)


# ---- Potato Peak ----------------------------------------------------------------------------------------------------------------------------------


## A view beyond the west rim: a huge soft hill of mashed potato with a butter pat on the summit, gravy streams running down into a gravy pool,
## broccoli and cauliflower cards on the slopes, cheese cubes, and steam (meta "steam").
static func _potato_peak(root: Node3D, mesh: KitMesh, size: Vector3, circles: Array[Vector3], steam: Array[Vector3]) -> void:
	var r: float = size.x * 0.5
	var height: float = size.y
	var profile: Array[Vector2] = [Vector2(r, -0.6), Vector2(r * 0.98, 1.2), Vector2(r * 0.9, 3.2), Vector2(r * 0.84, 4.4), Vector2(r * 0.7, height * 0.3), Vector2(r * 0.64, height * 0.42), Vector2(r * 0.5, height * 0.52), Vector2(r * 0.46, height * 0.64), Vector2(r * 0.32, height * 0.78), Vector2(r * 0.26, height * 0.9), Vector2(r * 0.1, height * 0.99), Vector2(0.0, height)]
	mesh.lathe("mashed", Vector3.ZERO, profile, 18, 0.92, true, true)
	# lumps on the slopes so the silhouette is soft and uneven
	for entry: Array in [[0.3, 0.4, 0.5, 0.9], [-0.55, 0.3, 0.45, 0.7], [0.1, -0.6, 0.6, 0.8], [-0.2, 0.75, 0.3, 0.6], [0.7, -0.1, 0.42, 0.55], [-0.75, -0.45, 0.35, 0.5]]:
		var at: Vector3 = Vector3(float(entry[0]) * r, 0.0, float(entry[1]) * r)
		var y: float = _peak_height(profile, at.length()) * 0.9
		mesh.blob("mashed_warm", Vector3(at.x, y, at.z), Vector3(r * float(entry[2]), height * 0.14 * float(entry[3]), r * float(entry[2]) * 0.9), 5, 10, 0.9)
	# the butter pat on the summit, melting
	mesh.box("butter", Vector3(0, height + 0.9, 0), Vector3(r * 0.36, r * 0.14, r * 0.28), Basis(Vector3(0, 0, 1), 0.12), 0.25, 0.95)
	mesh.lathe("butter_glow", Vector3(0, height + 0.3, 0), [Vector2(r * 0.3, 0.0), Vector2(r * 0.34, 0.25), Vector2(r * 0.2, 0.5), Vector2(0.0, 0.55)], 12, 1.0, false, true)
	# gravy streams winding down two slopes into the pool
	for stream: Array in [[0.9, 1.0], [-2.2, 0.8], [2.9, 0.6]]:
		var angle: float = float(stream[0])
		var width: float = 1.4 * float(stream[1])
		var steps: int = 14
		var previous: Vector3 = Vector3(cos(angle) * r * 0.1, height * 0.98, sin(angle) * r * 0.1)
		for step: int in range(1, steps + 1):
			var t: float = float(step) / float(steps)
			var wobble: float = angle + sin(t * 7.0 + angle) * 0.22
			var radius: float = r * (0.1 + 0.92 * t)
			var at: Vector3 = Vector3(cos(wobble) * radius, _peak_height(profile, radius) + 0.25, sin(wobble) * radius)
			var along: Vector3 = at - previous
			var basis: Basis = Basis.looking_at(along.normalized(), Vector3.UP)
			mesh.box("gravy", (at + previous) * 0.5, Vector3(width * (0.6 + 0.6 * t), 0.3, along.length() + 0.4), basis, 0.05)
			previous = at
		steam.append(Vector3(cos(angle) * r * 0.55, _peak_height(profile, r * 0.55) + 0.6, sin(angle) * r * 0.55))
	# the gravy pool round the foot, cheese cubes and cauliflower on the shore. Fix pass Nov 4 (Part 4.4): the three little pie-crust "biscuit
	# bridges" over the pool are gone - pure decoration with no script or collision, and the north one sat on the playable table by the
	# Cheddar Cliffs, where it read as a stair to nowhere (docs/ui/ref/nov4/buffet_topleft_stairs.png).
	mesh.lathe("gravy", Vector3(0, -0.4, 0), [Vector2(r * 1.12, 0.0), Vector2(r * 1.1, 0.35), Vector2(0.0, 0.4)], 20, 1.0, false, true)
	for cube: Array in [[0.4, 1.12, 1.6], [-1.3, 1.15, 1.3], [2.3, 0.95, 1.9], [3.7, 1.18, 1.4]]:
		var angle: float = float(cube[0])
		var at: Vector3 = Vector3(cos(angle) * r * float(cube[1]), 0.0, sin(angle) * r * float(cube[1]))
		mesh.box("cheese", at + Vector3(0, float(cube[2]) * 0.45, 0), Vector3.ONE * float(cube[2]), Basis(Vector3.UP, angle * 0.7), 0.12, 0.9)
	# broccoli and cauliflower cards on the slopes and the shore
	for card: Array in [["BUFF-TREE-BROCCOLI", 0.2, 0.62, 4.6], ["BUFF-TREE-CAULI", 1.6, 0.7, 3.8], ["BUFF-TREE-BROCCOLI", 2.6, 0.5, 4.0], ["BUFF-TREE-CAULI", 3.6, 0.62, 3.6], ["BUFF-TREE-BROCCOLI", 4.6, 0.72, 4.8], ["BUFF-TREE-CAULI", 5.4, 0.58, 3.4], ["BUFF-TREE-BROCCOLI", 0.9, 1.22, 5.2], ["BUFF-TREE-CAULI", 2.2, 1.24, 4.2], ["BUFF-TREE-BROCCOLI", 4.0, 1.2, 5.0], ["BUFF-TREE-CAULI", 5.2, 1.22, 4.0], ["BUFF-TREE-BROCCOLI", -0.6, 0.3, 3.4]]:
		var angle: float = float(card[1])
		var radius: float = r * float(card[2])
		var at: Vector3 = Vector3(cos(angle) * radius, _peak_height(profile, radius) if radius < r else 0.0, sin(angle) * radius)
		_tree_card(root, str(card[0]), at, float(card[3]))
	circles.append(Vector3(0.0, 0.0, r * 1.12))


## The mound's height at `radius` from the centre, read off the lathe profile.
static func _peak_height(profile: Array[Vector2], radius: float) -> float:
	for index: int in range(profile.size() - 1):
		var low: Vector2 = profile[index]
		var high: Vector2 = profile[index + 1]
		if radius <= low.x and radius >= high.x:
			var t: float = (low.x - radius) / maxf(low.x - high.x, 0.001)
			return lerpf(low.y, high.y, t)
	return profile[-1].y if radius < profile[-1].x else 0.0


# ---- The Broccoli Giant ------------------------------------------------------------------------------------------------------------------------------


## The forest's landmark: an ancient broccoli tree with a thick pale stalk, four limbs and a vast canopy of round florets, rocks and herbs round its foot.
static func _broccoli_giant(root: Node3D, mesh: KitMesh, size: Vector3, circles: Array[Vector3]) -> void:
	var hw: float = size.x * 0.5
	var height: float = size.y
	var trunk_r: float = hw * 0.24
	mesh.lathe("stalk", Vector3(0, -0.4, 0), [Vector2(trunk_r * 1.5, 0.0), Vector2(trunk_r * 1.25, 1.2), Vector2(trunk_r, 3.0), Vector2(trunk_r * 0.9, height * 0.42), Vector2(trunk_r * 0.7, height * 0.56), Vector2(trunk_r * 0.4, height * 0.62)], 12, 0.8, true, true)
	for index: int in range(5):
		var angle: float = TAU * float(index) / 5.0 + 0.4
		var foot: Vector3 = Vector3(cos(angle) * trunk_r * 1.3, 0.0, sin(angle) * trunk_r * 1.3)
		mesh.tube("stalk", foot + Vector3(0, -0.3, 0), foot * 0.4 + Vector3(0, 2.6, 0), trunk_r * 0.36, 7, true)
	var limbs: Array[Array] = [[0.3, 0.52, 0.5], [1.7, 0.48, 0.56], [3.0, 0.5, 0.48], [4.4, 0.46, 0.54], [5.5, 0.4, 0.6]]
	var crown: Vector3 = Vector3(0, height * 0.52, 0)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 7
	for limb: Array in limbs:
		var angle: float = float(limb[0])
		var tip: Vector3 = crown + Vector3(cos(angle) * hw * float(limb[1]), height * float(limb[2]) - height * 0.52 + height * 0.2, sin(angle) * hw * float(limb[1]))
		mesh.tube("stalk", crown - Vector3(0, 1.0, 0), tip, trunk_r * 0.46, 8, true)
		mesh.tube("stalk", crown.lerp(tip, 0.6), tip + Vector3(cos(angle + 1.2) * 2.0, 1.4, sin(angle + 1.2) * 2.0), trunk_r * 0.3, 7, true)
		_florets(mesh, tip, hw * 0.3, rng)
		_florets(mesh, tip + Vector3(cos(angle + 1.2) * 2.0, 1.6, sin(angle + 1.2) * 2.0), hw * 0.2, rng)
	_florets(mesh, crown + Vector3(0, height * 0.3, 0), hw * 0.4, rng)
	_florets(mesh, crown + Vector3(0, height * 0.42, 0), hw * 0.26, rng)
	# rocks, herbs and little white flowers round the foot
	for index: int in range(9):
		var angle: float = TAU * float(index) / 9.0 + 0.2
		var radius: float = trunk_r * 1.5 + 0.6 + 0.5 * float(index % 3)
		var at: Vector3 = Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
		mesh.blob("rock", at + Vector3(0, 0.25, 0), Vector3(0.7 + 0.2 * float(index % 3), 0.5 + 0.15 * float(index % 2), 0.6), 4, 7, 0.8)
		if index % 3 == 0:
			mesh.blob("white", at + Vector3(0.5, 0.65, 0.3), Vector3(0.14, 0.1, 0.14), 3, 5, 1.0)
	for index: int in range(4):
		var angle: float = TAU * float(index) / 4.0 + 0.9
		_tree_card(root, "BUFF-PLANT-HERB", Vector3(cos(angle) * (trunk_r * 1.5 + 1.6), 0.0, sin(angle) * (trunk_r * 1.5 + 1.6)), 1.3)
	circles.append(Vector3(0.0, 0.0, trunk_r * 1.5))


## A cluster of round florets (dark green blobs with lighter ones on top) round `center`.
static func _florets(mesh: KitMesh, center: Vector3, radius: float, rng: RandomNumberGenerator) -> void:
	mesh.blob("broccoli", center, Vector3(radius, radius * 0.8, radius), 5, 10, 0.86)
	for index: int in range(6):
		var angle: float = TAU * float(index) / 6.0 + rng.randf() * 0.5
		var at: Vector3 = center + Vector3(cos(angle) * radius * 0.75, radius * 0.25 + rng.randf() * radius * 0.2, sin(angle) * radius * 0.75)
		var s: float = radius * (0.42 + rng.randf() * 0.2)
		mesh.blob("broccoli_light" if index % 2 == 0 else "broccoli", at, Vector3(s, s * 0.85, s), 4, 8, 0.9)
	mesh.blob("broccoli_light", center + Vector3(0, radius * 0.55, 0), Vector3(radius * 0.55, radius * 0.45, radius * 0.55), 4, 8, 1.0)


# ---- The Omakase Pavilion ------------------------------------------------------------------------------------------------------------------------------


## The Walk-In Freezer's building: an elegant wooden sushi pavilion on white stone with a red tile roof, a long counter with stools and plates, paper lanterns,
## green noren, a stair at the front-left, bonsai in pots, and the steel freezer door in the stone base at the front-right where the spot stands.
static func _pavilion(root: Node3D, mesh: KitMesh, size: Vector3, circles: Array[Vector3], lights: Array[Dictionary]) -> void:
	var hw: float = size.x * 0.5
	var hd: float = size.z * 0.5
	var height: float = size.y
	var base_h: float = 1.3
	var stair_x: float = hw * 0.5
	var door_x: float = -hw + 1.2
	# the white stone base with rocks along its foot
	mesh.box("stone", Vector3(0, base_h * 0.5 - 0.2, 0), Vector3(size.x, base_h + 0.4, size.z), Basis.IDENTITY, 0.3, 0.82)
	mesh.box("tomato", Vector3(0, base_h - 0.05, 0), Vector3(size.x + 0.2, 0.1, size.z + 0.2), Basis.IDENTITY, 0.0)
	for index: int in range(9):
		var t: float = float(index) / 8.0
		var at: Vector3 = Vector3(-hw + size.x * t, 0.0, hd + 0.3 + 0.4 * float(index % 2))
		if absf(at.x - stair_x) < 1.6 or absf(at.x - door_x) < 1.4:
			continue
		mesh.blob("stone", at + Vector3(0, 0.35, 0), Vector3(0.8 + 0.3 * float(index % 3), 0.55 + 0.2 * float(index % 2), 0.7), 4, 7, 0.82)
		if index % 2 == 0:
			mesh.blob("pink", at + Vector3(0.3, 0.75, 0.2), Vector3(0.18, 0.12, 0.18), 3, 5, 1.0)
	for side: float in [-1.0, 1.0]:
		for index: int in range(3):
			mesh.blob("stone", Vector3(side * (hw + 0.4), 0.3, -hd + 1.2 + float(index) * 2.4), Vector3(0.8, 0.5, 0.9), 4, 7, 0.82)
	# the wooden deck, the posts, the rails
	mesh.box("wood", Vector3(0, base_h + 0.08, 0), Vector3(size.x - 0.5, 0.16, size.z - 0.5), Basis.IDENTITY, 0.02)
	var post_h: float = height * 0.52
	var posts: Array[Vector3] = []
	for sx: float in [-1.0, 0.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			posts.append(Vector3(sx * (hw - 0.8), base_h, sz * (hd - 0.8)))
	for post: Vector3 in posts:
		mesh.tube("wood", post, post + Vector3(0, post_h, 0), 0.17, 7, true)
	for side: float in [-1.0, 1.0]:
		mesh.box("wood", Vector3(0, base_h + post_h, side * (hd - 0.8)), Vector3(size.x - 1.2, 0.3, 0.3), Basis.IDENTITY, 0.02)
	for side: float in [-1.0, 1.0]:
		mesh.box("wood", Vector3(side * (hw - 0.8), base_h + post_h, 0), Vector3(0.3, 0.3, size.z - 1.3), Basis.IDENTITY, 0.02)
	# rails along the front (open at the stair) and the sides
	var rail_y: float = base_h + 0.95
	for side: float in [-1.0, 1.0]:
		mesh.tube("wood", Vector3(side * (hw - 0.3), base_h, -hd + 0.3), Vector3(side * (hw - 0.3), rail_y, -hd + 0.3), 0.1, 6, true)
		mesh.tube("wood", Vector3(side * (hw - 0.3), rail_y, -hd + 0.3), Vector3(side * (hw - 0.3), rail_y, hd - 0.3), 0.07, 5, true)
	for section: Array in [[-hw + 0.3, stair_x - 1.1], [stair_x + 1.1, hw - 0.3]]:
		var a: Vector3 = Vector3(float(section[0]), rail_y, hd - 0.3)
		var b: Vector3 = Vector3(float(section[1]), rail_y, hd - 0.3)
		mesh.tube("wood", a, b, 0.07, 5, true)
		mesh.tube("wood", Vector3(a.x, base_h, a.z), a, 0.1, 6, true)
		mesh.tube("wood", Vector3(b.x, base_h, b.z), b, 0.1, 6, true)
		mesh.tube("wood", Vector3((a.x + b.x) * 0.5, base_h, a.z), Vector3((a.x + b.x) * 0.5, rail_y, a.z), 0.08, 5, true)
	# the stair at the front-left down to the ground
	for step: int in range(5):
		var y: float = base_h - float(step + 1) * base_h / 5.0
		mesh.box("stone", Vector3(stair_x, y + 0.1, hd + 0.3 + float(step) * 0.42), Vector3(2.0, 0.2 + 0.02, 0.5), Basis.IDENTITY, 0.02)
	mesh.tube("wood", Vector3(stair_x - 1.1, 0.0, hd + 2.3), Vector3(stair_x - 1.1, 1.0, hd + 2.3), 0.1, 6, true)
	mesh.tube("wood", Vector3(stair_x - 1.1, 1.0, hd + 2.3), Vector3(stair_x - 1.1, rail_y, hd - 0.3), 0.07, 5, true)
	_lantern(mesh, Vector3(stair_x - 1.1, 1.3, hd + 2.3), lights, 0.42)
	# the roof: two red tile slabs with a wooden ridge, curled eaves, a smaller upper roof
	var roof_y: float = base_h + post_h + 0.2
	var pitch: float = deg_to_rad(26.0)
	var slab: float = hd + 1.3
	for side: float in [-1.0, 1.0]:
		var centre: Vector3 = Vector3(0, roof_y + sin(pitch) * slab * 0.5, side * slab * 0.5 * cos(pitch))
		mesh.box("roof_red", centre, Vector3(size.x + 2.2, 0.28, slab), Basis(Vector3(1, 0, 0), side * pitch), 0.02, 0.95)
		mesh.box("wood_dark", centre - Vector3(0, 0.2, 0), Vector3(size.x + 2.0, 0.12, slab - 0.3), Basis(Vector3(1, 0, 0), side * pitch), 0.0)
	var ridge_y: float = roof_y + sin(pitch) * slab
	mesh.box("wood", Vector3(0, ridge_y, 0), Vector3(size.x + 2.6, 0.4, 0.5), Basis.IDENTITY, 0.04)
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			var eave: Vector3 = Vector3(sx * (hw + 1.1), roof_y + 0.1, sz * (slab * 0.5 * cos(pitch) + 0.2))
			mesh.box("roof_red", eave, Vector3(1.6, 0.26, 1.2), Basis(Vector3(sz * -1.0, 0, sx * 1.0).normalized(), 0.5), 0.02)
			mesh.blob("butter", eave + Vector3(sx * 0.5, 0.3, sz * 0.4), Vector3(0.25, 0.25, 0.25), 3, 6, 1.0)
	mesh.box("roof_red", Vector3(0, ridge_y + 0.9, 0), Vector3(size.x * 0.46, 0.25, size.z * 0.5), Basis.IDENTITY, 0.02)
	mesh.box("wood", Vector3(0, ridge_y + 0.5, 0), Vector3(size.x * 0.4, 0.6, size.z * 0.3), Basis.IDENTITY, 0.02)
	mesh.box("wood", Vector3(0, ridge_y + 1.1, 0), Vector3(size.x * 0.5, 0.3, 0.4), Basis.IDENTITY, 0.02)
	# the counter with stools, plates and a shelf of jars behind it; the back wall is paper panels
	mesh.box("wood", Vector3(0, base_h + 0.62, -hd * 0.2), Vector3(size.x * 0.64, 0.95, 0.9), Basis.IDENTITY, 0.03, 0.88)
	mesh.box("wood_dark", Vector3(0, base_h + 1.12, -hd * 0.2), Vector3(size.x * 0.66, 0.08, 1.0), Basis.IDENTITY, 0.0)
	for index: int in range(5):
		var x: float = -size.x * 0.26 + size.x * 0.13 * float(index)
		mesh.lathe("tomato", Vector3(x, base_h + 0.16, -hd * 0.2 + 1.0), [Vector2(0.28, 0.0), Vector2(0.28, 0.42)], 8, 0.9, false, true)
		mesh.tube("wood_dark", Vector3(x, base_h + 0.16, -hd * 0.2 + 1.0), Vector3(x, base_h + 0.5, -hd * 0.2 + 1.0), 0.06, 5, true)
		mesh.blob("white", Vector3(x, base_h + 1.2, -hd * 0.2), Vector3(0.22, 0.03, 0.22), 2, 8, 1.0)
		mesh.blob("tomato" if index % 2 == 0 else "pink", Vector3(x, base_h + 1.26, -hd * 0.2), Vector3(0.1, 0.06, 0.14), 3, 6, 1.0)
	mesh.box("cream", Vector3(0, base_h + post_h * 0.5, -hd + 0.6), Vector3(size.x - 1.6, post_h - 0.2, 0.12), Basis.IDENTITY, 0.0)
	mesh.box("glow", Vector3(0, base_h + post_h * 0.5, -hd + 0.54), Vector3(size.x - 2.2, post_h - 0.8, 0.06), Basis.IDENTITY, 0.0)
	for index: int in range(4):
		var x: float = -size.x * 0.3 + size.x * 0.2 * float(index)
		mesh.tube("wood", Vector3(x, base_h, -hd + 0.5), Vector3(x, base_h + post_h, -hd + 0.5), 0.06, 5, true)
	mesh.box("wood", Vector3(0, base_h + post_h * 0.68, -hd + 0.75), Vector3(size.x * 0.6, 0.08, 0.35), Basis.IDENTITY, 0.0)
	for index: int in range(6):
		mesh.lathe("white" if index % 3 == 0 else ("tomato" if index % 3 == 1 else "herb"), Vector3(-size.x * 0.26 + size.x * 0.105 * float(index), base_h + post_h * 0.68 + 0.04, -hd + 0.75), [Vector2(0.12, 0.0), Vector2(0.14, 0.24), Vector2(0.08, 0.34)], 7, 1.0, false, true)
	# noren and lanterns along the front eave
	for index: int in range(3):
		var x: float = -size.x * 0.24 + size.x * 0.24 * float(index)
		mesh.box("herb", Vector3(x, base_h + post_h - 0.55, hd - 0.9), Vector3(1.3, 0.9, 0.04), Basis.IDENTITY, 0.0)
		mesh.box("white", Vector3(x, base_h + post_h - 0.55, hd - 0.88), Vector3(0.26, 0.26, 0.02), Basis.IDENTITY, 0.0)
	for index: int in range(4):
		var x: float = -size.x * 0.36 + size.x * 0.24 * float(index)
		_lantern(mesh, Vector3(x, base_h + post_h - 0.05, hd - 0.4), lights, 0.5)
	_lantern(mesh, Vector3(hw - 0.6, base_h + post_h - 0.05, -hd + 1.0), lights, 0.45)
	# the Walk-In Freezer door in the stone base at the front-left (the spot stands before it): steel, a frosted window, a cold glow
	var door: Vector3 = Vector3(door_x, 0.0, hd)
	mesh.box("steel", door + Vector3(0, 0.95, 0.05), Vector3(2.0, 1.9, 0.3), Basis.IDENTITY, 0.04)
	mesh.box("wood_dark", door + Vector3(0, 0.95, 0.12), Vector3(2.2, 2.1, 0.12), Basis.IDENTITY, 0.0)
	mesh.box("steel", door + Vector3(0, 0.95, 0.24), Vector3(1.7, 1.7, 0.1), Basis.IDENTITY, 0.02)
	mesh.box("frost", door + Vector3(0, 1.3, 0.3), Vector3(0.7, 0.45, 0.04), Basis.IDENTITY, 0.0)
	mesh.box("steel", door + Vector3(0.6, 0.8, 0.34), Vector3(0.12, 0.5, 0.1), Basis.IDENTITY, 0.0)
	mesh.box("steel", door + Vector3(0, 0.03, 0.4), Vector3(2.2, 0.06, 0.6), Basis.IDENTITY, 0.0)
	lights.append({"pos": door + Vector3(0, 1.0, 1.0), "color": Color("bfe8ff"), "range": 4.0, "energy": 0.6, "kind": "frost"})
	# bonsai in pots on the deck's front corners
	for side: float in [-1.0, 1.0]:
		var pot: Vector3 = Vector3(side * (hw - 1.0), base_h + 0.16, hd - 1.4)
		mesh.lathe("tomato", pot, [Vector2(0.55, 0.0), Vector2(0.62, 0.5), Vector2(0.5, 0.6)], 8, 0.85, true, true)
		mesh.tube("wood_dark", pot + Vector3(0, 0.5, 0), pot + Vector3(side * 0.5, 1.6, 0.2), 0.14, 6, true)
		mesh.tube("wood_dark", pot + Vector3(side * 0.5, 1.6, 0.2), pot + Vector3(side * -0.2, 2.5, -0.1), 0.1, 5, true)
		mesh.blob("broccoli_light", pot + Vector3(side * 0.7, 1.9, 0.3), Vector3(0.8, 0.45, 0.7), 4, 8, 0.9)
		mesh.blob("herb", pot + Vector3(side * -0.2, 2.7, -0.1), Vector3(0.75, 0.42, 0.65), 4, 8, 0.9)
		mesh.blob("broccoli_light", pot + Vector3(side * 0.2, 2.3, -0.5), Vector3(0.5, 0.3, 0.45), 3, 6, 1.0)
	circles.append(Vector3(-hw * 0.5, 0.0, hd * 0.86))
	circles.append(Vector3(0.0, 0.0, hd * 0.9))
	circles.append(Vector3(hw * 0.5, 0.0, hd * 0.86))
	circles.append(Vector3(stair_x, hd + 1.3, 1.3))


# ---- The way in: the biscuit bridge over the gravy moat (Part B) ------------------------------------------------------------------------------------


## The bridge from the table's south edge out over the gravy moat to its far landing: biscuit slabs on a crust deck with a tablecloth runner down the middle,
## low biscuit kerbs (the walkable edge), cream meringue posts with strawberries along the sides, copper pillars down into the gravy, a gate of two meringue
## posts with lanterns and a whisk sign at the near end, and a square landing with two posts at the far end where the way to town begins. Origin at the near
## end on the rim, the deck toward +z. Meta circles (the posts), "lights" (the lanterns).
static func entrance_bridge(length: float, width: float) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	_materials(mesh)
	var circles: Array[Vector3] = []
	var lights: Array[Dictionary] = []
	var root: Node3D = Node3D.new()
	root.name = "Bridge"
	var half: float = width * 0.5
	# the deck: crust beams, biscuit slabs, the runner
	mesh.box("crust", Vector3(0.0, -0.36, length * 0.5), Vector3(width + 0.4, 0.42, length), Basis.IDENTITY, 0.03, 0.85)
	var slab: float = 2.0
	var count: int = int(ceilf(length / slab))
	for index: int in range(count):
		var z: float = slab * (float(index) + 0.5)
		mesh.box("biscuit" if index % 3 != 1 else "biscuit_dark", Vector3(0.0, -0.08, minf(z, length - slab * 0.5)), Vector3(width, 0.16, slab - 0.12), Basis.IDENTITY, 0.03, 0.92)
	mesh.box("cloth", Vector3(0.0, 0.012, length * 0.5), Vector3(width * 0.42, 0.024, length - 0.6), Basis.IDENTITY, 0.0)
	# the kerbs: low biscuit lips the hero cannot step over (the layout's BRIDGE_RAIL)
	for side: float in [-1.0, 1.0]:
		mesh.box("biscuit_dark", Vector3(side * (half - 0.15), 0.12, length * 0.5), Vector3(0.3, 0.28, length), Basis.IDENTITY, 0.03)
	# meringue posts with strawberries every few metres, copper pillars down into the gravy. Batch 11 (Nov 2): the posts are the painted salt
	# shakers (BUF-PROP-SALT-SHAKER, two crossed cards) when the art is in; the white meringue cones stay the fallback.
	var shakers: bool = EnvKit.has(SALT_SHAKER) and EnvKit.has_art(SALT_SHAKER)
	var post_step: float = 3.6
	var posts: int = maxi(2, int(round(length / post_step)))
	for index: int in range(1, posts):
		var z: float = length * float(index) / float(posts)
		for side: float in [-1.0, 1.0]:
			var base: Vector3 = Vector3(side * (half + 0.3), 0.0, z)
			if shakers:
				_shaker(mesh, base, SHAKER_POST_HEIGHT)
				continue
			mesh.lathe("white", base, [Vector2(0.34, 0.0), Vector2(0.4, 0.3), Vector2(0.3, 0.7), Vector2(0.36, 1.0), Vector2(0.2, 1.3), Vector2(0.0, 1.45)], 10, 0.9, true, true)
			_strawberry(mesh, base + Vector3(0, 1.35, 0), 0.5)
		mesh.tube("copper_flat", Vector3(0.0, -3.2, z), Vector3(0.0, -0.3, z), 0.35, 8, true)
		mesh.box("copper_flat", Vector3(0.0, -0.75, z), Vector3(width + 0.2, 0.22, 0.4), Basis.IDENTITY, 0.0)
	# the gate at the near end: two tall meringue posts with lanterns, a whisk sign on the left one, bunting across
	var gate_h: float = 3.8
	for side: float in [-1.0, 1.0]:
		var foot: Vector3 = Vector3(side * (half + 0.55), 0.0, 0.4)
		if shakers:
			_shaker(mesh, foot, gate_h)
		else:
			mesh.lathe("white", foot, [Vector2(0.62, 0.0), Vector2(0.7, 0.5), Vector2(0.52, 1.4), Vector2(0.6, 2.4), Vector2(0.42, gate_h - 0.4), Vector2(0.0, gate_h)], 12, 0.88, true, true)
			_strawberry(mesh, foot + Vector3(0, gate_h - 0.1, 0), 0.9)
		mesh.box("cloth", foot + Vector3(0, 0.1, 0), Vector3(1.5, 0.2, 1.5), Basis.IDENTITY, 0.02)
		_lantern(mesh, foot + Vector3(side * 0.9, gate_h * 0.62, 0.0), lights, 0.52)
		mesh.tube("wood_dark", foot + Vector3(0, gate_h * 0.62 + 0.1, 0), foot + Vector3(side * 0.9, gate_h * 0.62 + 0.1, 0), 0.05, 5, true)
		circles.append(Vector3(foot.x, foot.z, 0.75))
	_card(mesh, "BUFF-SHEET-SIGNS-01", Vector3(-(half + 0.55) + 0.55, gate_h * 0.42, 0.95), 1.6, Vector3(0, 0, 1))
	var from: Vector3 = Vector3(-(half + 0.55), gate_h - 0.3, 0.4)
	var to: Vector3 = Vector3(half + 0.55, gate_h - 0.3, 0.4)
	# overnight Oct 19: the bunting is its own mesh that fades on its own when it crosses the view of the hero (OcclusionFader, occlusion_overhead)
	var line: KitMesh = KitMesh.new()
	_materials(line)
	line.tube("wood_dark", from, to, 0.04, 4, false)
	for index: int in range(1, 8):
		var p: Vector3 = from.lerp(to, float(index) / 8.0) - Vector3(0, 0.25 * sin(PI * float(index) / 8.0), 0)
		line.tri("tomato" if index % 2 == 0 else "herb", [p + Vector3(-0.3, 0.0, 0), p + Vector3(0.3, 0.0, 0), p + Vector3(0, -0.55, 0)], Vector3(0, 0, 1))
	# the far landing: a biscuit square with two posts, where the way to town begins
	var landing_z: float = length + 1.6
	mesh.box("crust", Vector3(0.0, -0.36, landing_z), Vector3(width + 1.6, 0.42, 3.6), Basis.IDENTITY, 0.03, 0.85)
	mesh.box("biscuit", Vector3(0.0, -0.08, landing_z), Vector3(width + 1.2, 0.16, 3.4), Basis.IDENTITY, 0.03, 0.92)
	for side: float in [-1.0, 1.0]:
		var foot: Vector3 = Vector3(side * (half + 0.4), 0.0, landing_z + 1.5)
		if shakers:
			_shaker(mesh, foot, 2.9)
		else:
			mesh.lathe("white", foot, [Vector2(0.4, 0.0), Vector2(0.46, 0.4), Vector2(0.34, 1.6), Vector2(0.4, 2.4), Vector2(0.0, 2.9)], 10, 0.9, true, true)
			_strawberry(mesh, foot + Vector3(0, 2.8, 0), 0.7)
		circles.append(Vector3(foot.x, foot.z, 0.5))
		mesh.tube("copper_flat", Vector3(side * (half + 0.2), -3.2, landing_z), Vector3(side * (half + 0.2), -0.3, landing_z), 0.3, 8, true)
	var body: MeshInstance3D = mesh.instance("Body")
	body.set_meta(PaintedClasses.META_NO_PAINT, true)
	body.set_meta(&"no_occlusion_fade", true)  # the hero walks on it: it must never dissolve under the feet
	body.set_meta(&"no_range_cull", true)
	root.set_meta(&"no_wind", true)
	root.add_child(body)
	var bunting: MeshInstance3D = line.instance("Bunting")
	bunting.set_meta(PaintedClasses.META_NO_PAINT, true)
	bunting.set_meta(&"occlusion_overhead", true)
	root.add_child(bunting)
	root.set_meta("circles", circles)
	root.set_meta("lights", lights)
	root.set_meta("footprint", Vector2(width + 1.6, length + 3.6))
	root.set_meta("height", gate_h + 0.5)
	root.set_meta("kind", "bridge")
	root.set_meta("triangles", mesh.triangle_count())
	return root


# ---- The Grand Dining Hall's kitchen wings (Part B) ------------------------------------------------------------------------------------------------------


## One wing of the Dining Hall north of the plaza: an oven-brick kitchen wall `width` long with glowing oven arches, a biscuit upper storey with sweet windows,
## a tablecloth trim, a copper dome on the end nearest the road (variant 0 = the west wing, its dome at +x; 1 = the east wing, its dome at -x), a chimney
## with steam (meta "steam") and a long banquet table under an awning along its front. Origin on the ground at the wall's centre, the front +z. Blocks
## along its length (meta circles).
static func hall_wing(width: float, variant: int) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	_materials(mesh)
	var circles: Array[Vector3] = []
	var lights: Array[Dictionary] = []
	var steam: Array[Vector3] = []
	var root: Node3D = Node3D.new()
	root.name = "HallWing"
	var half: float = width * 0.5
	var depth: float = 3.2
	var wall_h: float = 3.0
	var upper_h: float = 2.2
	var dome_side: float = 1.0 if variant == 0 else -1.0
	# the oven-brick ground floor with three glowing arches, the biscuit upper floor with the sliced windows, the trim and a pie-crust roof
	mesh.box("oven", Vector3(0, wall_h * 0.5 - 0.2, 0), Vector3(width, wall_h + 0.4, depth), Basis.IDENTITY, 0.05, 0.86)
	mesh.box("cloth", Vector3(0, wall_h + 0.2, 0), Vector3(width + 0.3, 0.4, depth + 0.3), Basis.IDENTITY, 0.0)
	mesh.box("biscuit", Vector3(0, wall_h + 0.4 + upper_h * 0.5, 0), Vector3(width - 0.4, upper_h, depth - 0.3), Basis.IDENTITY, 0.05, 0.9)
	mesh.box("crust", Vector3(0, wall_h + 0.4 + upper_h + 0.3, 0), Vector3(width + 0.4, 0.6, depth + 0.6), Basis.IDENTITY, 0.04)
	mesh.box("cloth", Vector3(0, wall_h + 0.4 + upper_h + 0.72, 0), Vector3(width + 0.5, 0.24, depth + 0.7), Basis.IDENTITY, 0.0)
	var arches: int = maxi(2, int(width / 5.0))
	for index: int in range(arches):
		var x: float = -half + width * (float(index) + 0.5) / float(arches)
		mesh.box("oven", Vector3(x, 1.4, depth * 0.5 + 0.12), Vector3(2.4, 2.6, 0.26), Basis.IDENTITY, 0.02)
		mesh.box("glow", Vector3(x, 1.2, depth * 0.5 + 0.28), Vector3(1.6, 1.6, 0.08), Basis.IDENTITY, 0.0)
		_pane_bars(mesh, Vector3(x, 1.2, depth * 0.5 + 0.34), Vector2(1.6, 1.6))  # the oven's grate
		mesh.lathe("glow", Vector3(x, 2.0, depth * 0.5 + 0.28), [Vector2(0.8, 0.0), Vector2(0.0, 0.5)], 8, 1.0, false, true)
		lights.append({"pos": Vector3(x, 1.3, depth * 0.5 + 1.0), "color": GLOW, "range": 5.0, "energy": 0.8, "kind": "oven"})
		var window: String = "BUFF-SHEET-WINDOWS-%02d" % ((index + variant * 2) % 6 + 1)
		_card(mesh, window, Vector3(x, wall_h + 0.6, depth * 0.5 - 0.1), 1.5, Vector3(0, 0, 1))
	# the copper dome on a drum at the road end, the chimney at the far end
	var dome_x: float = dome_side * (half - 2.6)
	mesh.lathe("biscuit", Vector3(dome_x, wall_h + 0.4 + upper_h + 0.6, 0), [Vector2(2.4, 0.0), Vector2(2.4, 1.2)], 14, 0.9, false, true)
	mesh.lathe("copper", Vector3(dome_x, wall_h + 0.4 + upper_h + 1.8, 0), [Vector2(2.7, 0.0), Vector2(2.7, 0.5), Vector2(2.4, 1.2), Vector2(1.5, 2.3), Vector2(0.0, 2.8)], 14, 0.92, false, true)
	mesh.blob("butter", Vector3(dome_x, wall_h + 0.4 + upper_h + 4.9, 0), Vector3(0.4, 0.4, 0.4), 4, 8, 1.0)
	var chimney_x: float = -dome_side * (half - 2.0)
	steam.append(_chimney(mesh, Vector3(chimney_x, wall_h + 0.4 + upper_h + 0.6, -0.4), 3.2, 0.5))
	# the banquet table along the front under a tablecloth awning on cream posts; cloches, cake stands and candles on it (the east wing only: the road runs past the west one)
	var table_z: float = depth * 0.5 + 2.6
	var table_w: float = width - 3.0
	if variant == 1:
		_banquet_table(mesh, table_z, table_w, circles)
	# the wall blocks along its length
	var steps: int = maxi(2, int(width / 2.4))
	for index: int in range(steps + 1):
		var x: float = -half + width * float(index) / float(steps)
		circles.append(Vector3(x, 0.0, 1.9))
	var body: MeshInstance3D = mesh.instance("Body")
	body.set_meta(PaintedClasses.META_NO_PAINT, true)
	body.set_meta("occlusion_near", 2.0)
	root.add_child(body)
	root.set_meta(&"no_wind", true)
	root.set_meta("circles", circles)
	root.set_meta("lights", lights)
	root.set_meta("steam", steam)
	root.set_meta("height", wall_h + upper_h + 5.0)
	root.set_meta("triangles", mesh.triangle_count())
	return root


static func _banquet_table(mesh: KitMesh, table_z: float, table_w: float, circles: Array[Vector3]) -> void:
	mesh.box("cloth", Vector3(0, 0.86, table_z), Vector3(table_w, 0.1, 1.6), Basis.IDENTITY, 0.0)
	mesh.box("white", Vector3(0, 0.5, table_z), Vector3(table_w - 0.2, 0.62, 1.4), Basis.IDENTITY, 0.02, 0.85)
	for index: int in range(3):
		var x: float = -table_w * 0.35 + table_w * 0.35 * float(index)
		_candle(mesh, Vector3(x, 0.92, table_z), 0.5, 0.06)
		mesh.lathe("white", Vector3(x + 1.2, 0.9, table_z + 0.2), [Vector2(0.3, 0.0), Vector2(0.32, 0.05), Vector2(0.0, 0.08)], 8, 1.0, false, true)
		mesh.blob("tomato" if index % 2 == 0 else "pink", Vector3(x + 1.2, 1.02, table_z + 0.2), Vector3(0.2, 0.1, 0.2), 3, 6, 1.0)
	for side: float in [-1.0, 1.0]:
		var post: Vector3 = Vector3(side * (table_w * 0.5 + 0.4), 0.0, table_z + 1.1)
		mesh.tube("white", post, post + Vector3(0, 2.6, 0), 0.1, 6, true)
		circles.append(Vector3(post.x, post.z, 0.25))
	_card(mesh, "BUFF-SHEET-AWNINGS-04", Vector3(-table_w * 0.5 - 0.4, 2.55, table_z + 1.15), 1.5, Vector3(0, 0, 1))
	_card(mesh, "BUFF-SHEET-AWNINGS-05", Vector3(-table_w * 0.5 - 0.4 + 2.6, 2.55, table_z + 1.15), 1.5, Vector3(0, 0, 1))
	# the table blocks along its length
	var pieces: int = maxi(2, int(table_w / 2.2))
	for index: int in range(pieces + 1):
		circles.append(Vector3(-table_w * 0.5 + table_w * float(index) / float(pieces), table_z, 1.1))


# ---- The district walls (Part B) ---------------------------------------------------------------------------------------------------------------------------


## The picket fence of giant forks and the baguette dividers as ONE low biscuit wall with a herb hedge on top (knee-high: it never hides the hero), built
## from the layout's post positions: each post becomes a 1 m length of wall, so the blockers are unchanged and the gates' gaps stay open. `posts` are world
## positions (x, 0, z); runs are broken where posts are more than 1.6 m apart.
static func district_walls(posts: Array[Vector3]) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	_materials(mesh)
	var root: Node3D = Node3D.new()
	root.name = "DistrictWalls"
	var sorted: Array[Vector3] = posts.duplicate()
	sorted.sort_custom(func(a: Vector3, b: Vector3) -> bool: return a.x < b.x if absf(a.z - b.z) < 0.5 else a.z < b.z)
	var index: int = 0
	var hedge: int = 0
	var veg_art: bool = EnvKit.has_art("BUFF-PROP-VEG-01")
	var cabbages: Dictionary = {"buff_veg_1": [] as Array[Dictionary], "buff_veg_2": [] as Array[Dictionary], "buff_veg_3": [] as Array[Dictionary]}
	while index < sorted.size():
		var run_start: int = index
		while index + 1 < sorted.size() and sorted[index].distance_to(sorted[index + 1]) <= 1.6:
			index += 1
		var a: Vector3 = sorted[run_start]
		var b: Vector3 = sorted[index]
		var along: Vector3 = b - a
		var length: float = along.length() + 1.0
		var mid: Vector3 = (a + b) * 0.5
		var basis: Basis = Basis.IDENTITY if along.length() < 0.01 else Basis.looking_at(along.normalized(), Vector3.UP)
		mesh.box("biscuit", mid + Vector3(0, 0.25, 0), Vector3(0.7, 0.5, length), basis, 0.04, 0.86)
		mesh.box("crust", mid + Vector3(0, 0.53, 0), Vector3(0.85, 0.08, length + 0.1), basis, 0.0)
		var pieces: int = maxi(1, int(length / 1.4))
		for piece: int in range(pieces):
			var t: float = (float(piece) + 0.5) / float(pieces)
			var at: Vector3 = a.lerp(b, t) if along.length() > 0.01 else a
			hedge += 1
			var s: float = 0.42 + 0.1 * float(hedge % 3)
			if veg_art:
				# Batch 17 (Nov 18): painted cabbages (BUFF-PROP-VEG-01..03) grow along the bed, where untextured green balls sat
				(cabbages["buff_veg_%d" % (hedge % 3 + 1)] as Array[Dictionary]).append({"pos": at + Vector3(0, 0.5, 0), "scale": 1.3 + 0.25 * float(hedge % 2)})
				continue
			mesh.blob("herb" if hedge % 4 != 0 else "broccoli_light", at + Vector3(0, 0.57 + s * 0.6, 0), Vector3(s * 1.1, s * 0.9, s * 1.1), 4, 7, 0.88)
		index += 1
	var body: MeshInstance3D = mesh.instance("Body")
	body.set_meta(PaintedClasses.META_NO_PAINT, true)
	body.set_meta(&"no_occlusion_fade", true)  # knee-high: nothing to hide
	root.add_child(body)
	root.set_meta(&"no_wind", true)
	for kind: String in cabbages.keys():
		var field: MultiMeshInstance3D = KitFoliage.tree_field(root, kind, cabbages[kind] as Array[Dictionary], false)
		if field != null:
			field.name = "Cabbages_%s" % kind
			field.set_meta(&"no_range_cull", true)
	root.set_meta("triangles", mesh.triangle_count())
	return root


# ---- The river crossings (Part B) ---------------------------------------------------------------------------------------------------------------------------


## A biscuit landing stage at a crossing: a slab from the bank down to the gravy's edge with two meringue posts and lanterns at its land end, so the raft lane
## (or the lazy susan) reads as the way across. Origin on the bank at the slab's land end, the slab toward +z (the water side); `length` to the water.
static func landing_stage(length: float, width: float) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	_materials(mesh)
	var circles: Array[Vector3] = []
	var lights: Array[Dictionary] = []
	var root: Node3D = Node3D.new()
	root.name = "LandingStage"
	var half: float = width * 0.5
	mesh.box("biscuit", Vector3(0, -0.1, length * 0.5), Vector3(width, 0.22, length), Basis.IDENTITY, 0.03, 0.9)
	mesh.box("crust", Vector3(0, -0.3, length * 0.5), Vector3(width + 0.3, 0.2, length + 0.2), Basis.IDENTITY, 0.02)
	mesh.box("cloth", Vector3(0, 0.012, length * 0.5), Vector3(width * 0.4, 0.024, length - 0.4), Basis.IDENTITY, 0.0)
	for side: float in [-1.0, 1.0]:
		var foot: Vector3 = Vector3(side * (half + 0.3), 0.0, 0.3)
		mesh.lathe("white", foot, [Vector2(0.36, 0.0), Vector2(0.42, 0.3), Vector2(0.3, 1.2), Vector2(0.34, 2.0), Vector2(0.0, 2.4)], 10, 0.9, true, true)
		_strawberry(mesh, foot + Vector3(0, 2.3, 0), 0.6)
		_lantern(mesh, foot + Vector3(side * 0.7, 1.9, 0), lights, 0.42)
		mesh.tube("wood_dark", foot + Vector3(0, 2.0, 0), foot + Vector3(side * 0.7, 2.0, 0), 0.04, 5, true)
		circles.append(Vector3(foot.x, foot.z, 0.5))
		mesh.tube("copper_flat", Vector3(side * (half - 0.3), -1.6, length - 0.4), Vector3(side * (half - 0.3), -0.2, length - 0.4), 0.2, 7, true)
	var body: MeshInstance3D = mesh.instance("Body")
	body.set_meta(PaintedClasses.META_NO_PAINT, true)
	body.set_meta(&"no_occlusion_fade", true)
	root.add_child(body)
	root.set_meta(&"no_wind", true)
	root.set_meta("circles", circles)
	root.set_meta("lights", lights)
	root.set_meta("triangles", mesh.triangle_count())
	return root
