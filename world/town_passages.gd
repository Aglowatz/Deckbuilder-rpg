class_name TownPassages
extends RefCounted
## The zone passageways at the edge of the main town (Brief 13, Part E), replacing the old tower portals. Each is a short natural gateway built in local space with
## "out" along -Z (the hero walks from +Z towards -Z), then rotated to face the map edge: a themed arch or gate between rocks and trees, a worn path, a carved wooden
## signpost with the zone's name, and a soft light at the far end. `build` returns the node; `Info.sign_text` is also what the town shows as the approach label.

const WOOD: Color = Color("8a5a38")
const WOOD_DARK: Color = Color("5e3d26")
const WOOD_LIGHT: Color = Color("b98458")
const ROCK: Color = Color("8c8798")
const ROCK_DARK: Color = Color("5e5a6c")
const CREAM: Color = Color("f1e6cf")

## Half width of the opening (metres): walls start here.
const OPENING: float = 1.55
const DEPTH: float = 3.0


## Rotation (degrees about Y) that turns local -Z towards the world direction `out` (a unit vector on the ground).
static func yaw_for(out: Vector3) -> float:
	return rad_to_deg(atan2(-out.x, -out.z))


static func build(zone_id: String, title: String, tint: Color, locked: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "Passage_%s" % zone_id
	var dressing: Node3D = Node3D.new()
	dressing.name = "Dressing"
	root.add_child(dressing)
	match zone_id:
		"beefcake":
			_barbell_arch(dressing)
		"necrocrat":
			_office_gate(dressing)
		"gourmand":
			_awning_arch(dressing)
		"refusemancer":
			_overgrown_junk(dressing)
		_:
			_rock_arch(dressing)
	_path(dressing, tint)
	_sign(root, title, tint)
	_far_glow(root, tint, locked)
	return root


# ---- shared pieces ----------------------------------------------------------------------------------------------------------------------


static func _holder(mesh: ProcMesh, node_name: String) -> MeshInstance3D:
	return mesh.build(node_name)


static func _kit(parent: Node3D, folder: String, model: String, pos: Vector3, yaw: float, scale_value: float) -> void:
	var node: Node3D = ModelKit.kit_model(folder, model)
	parent.add_child(node)
	node.position = pos
	node.rotation_degrees.y = yaw
	node.scale = Vector3.ONE * scale_value


static func _path(parent: Node3D, tint: Color) -> void:
	var mesh: ProcMesh = ProcMesh.new()
	var base: Color = Color("a89868").lerp(tint, 0.12)
	mesh.facing(Vector3(0, 1, 0))
	# a worn-grass path, a little wider than the opening, with stepping stones through the gate
	mesh.quad(Vector3(-1.25, 0.03, DEPTH + 1.8), Vector3(-1.1, 0.03, -DEPTH + 0.6), Vector3(1.1, 0.03, -DEPTH + 0.6), Vector3(1.25, 0.03, DEPTH + 1.8), base)
	for i: int in range(6):
		var z: float = DEPTH + 1.0 - float(i) * 1.0
		mesh.box(Vector3(sin(float(i) * 1.7) * 0.28, 0.05, z), Vector3(0.7, 0.07, 0.5), Color("c8bca0"))
	parent.add_child(_holder(mesh, "Path"))


static func _sign(root: Node3D, title: String, tint: Color) -> void:
	var sign_root: Node3D = Node3D.new()
	sign_root.name = "Signpost"
	sign_root.position = Vector3(-OPENING - 0.85, 0.0, DEPTH + 0.6)
	sign_root.rotation_degrees.y = -22.0
	root.add_child(sign_root)
	var mesh: ProcMesh = ProcMesh.new()
	mesh.frustum(0.0, 2.0, 0.09, 0.08, 6, WOOD_DARK)
	mesh.frustum(1.95, 2.05, 0.13, 0.13, 6, WOOD_LIGHT)
	# the carved board: a rounded plank with a lighter frame and a tinted pennant corner
	mesh.box(Vector3(0, 1.62, 0.1), Vector3(1.55, 0.58, 0.09), WOOD)
	mesh.box(Vector3(0, 1.62, 0.14), Vector3(1.43, 0.46, 0.03), WOOD_LIGHT)
	mesh.box(Vector3(0.68, 1.95, 0.1), Vector3(0.16, 0.22, 0.05), tint)
	mesh.box(Vector3(0, 1.28, 0.08), Vector3(0.9, 0.1, 0.05), WOOD_DARK)
	sign_root.add_child(_holder(mesh, "Board"))
	var label: Label3D = Label3D.new()
	label.name = "SignText"
	label.text = title
	label.font = UIStyle.font_title()
	label.font_size = 40
	label.pixel_size = 0.0058
	label.modulate = Color("3a2412")
	label.outline_size = 0
	label.width = 380.0
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector3(0, 1.62, 0.172)
	label.set_meta(StyleToon.META_NO_TOON, true)
	sign_root.add_child(label)


static func _far_glow(root: Node3D, tint: Color, locked: bool) -> void:
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(OPENING * 2.0, 2.6)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.albedo_texture = StyleAmbience.soft_texture()
	material.albedo_color = Color(tint.r, tint.g, tint.b, 0.14 if locked else 0.4)
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	var glow: MeshInstance3D = MeshInstance3D.new()
	glow.name = "FarGlow"
	glow.mesh = quad
	glow.material_override = material
	glow.position = Vector3(0, 1.2, -DEPTH + 0.3)
	glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	glow.set_meta(StyleToon.META_NO_TOON, true)
	root.add_child(glow)


static func _flank(parent: Node3D, models: Array[String], folder: String) -> void:
	for side: float in [-1.0, 1.0]:
		for i: int in range(models.size()):
			var z: float = DEPTH - float(i) * 1.6 + 0.4
			_kit(parent, folder, models[i], Vector3(side * (OPENING + 0.9 + 0.2 * float(i % 2)), 0.0, z), float(i) * 70.0 + side * 20.0, 2.2 - 0.2 * float(i % 2))


# ---- the five themes ----------------------------------------------------------------------------------------------------------------------


## The Capital: an archway of rocks between two stacked cliffs, golden pennants on top.
static func _rock_arch(parent: Node3D) -> void:
	var mesh: ProcMesh = ProcMesh.new()
	for side: float in [-1.0, 1.0]:
		var x: float = side * (OPENING + 0.35)
		mesh.box(Vector3(x, 1.0, -0.2), Vector3(1.1, 2.0, 1.6), ROCK)
		mesh.box(Vector3(x + side * 0.1, 2.4, -0.3), Vector3(0.9, 1.0, 1.3), ROCK_DARK)
		mesh.box(Vector3(x, 0.35, 0.8), Vector3(0.8, 0.7, 0.7), ROCK_DARK)
	mesh.box(Vector3(0, 3.05, -0.25), Vector3(OPENING * 2.0 + 1.9, 0.7, 1.4), ROCK)
	mesh.box(Vector3(0.3, 3.55, -0.3), Vector3(1.2, 0.5, 1.0), ROCK_DARK)
	mesh.box(Vector3(0, 2.68, 0.45), Vector3(OPENING * 2.0 + 0.6, 0.12, 0.3), Color("f2c13c"))
	for side: float in [-1.0, 1.0]:
		mesh.frustum(3.6, 5.0, 0.04, 0.035, 5, WOOD_DARK, Transform3D(Basis.IDENTITY, Vector3(side * (OPENING + 0.35), 0, 0.0)))
		mesh.facing(Vector3(0, 0, 1))
		mesh.quad(Vector3(side * (OPENING + 0.35), 4.95, 0), Vector3(side * (OPENING + 0.35) + 0.8, 4.8, 0), Vector3(side * (OPENING + 0.35) + 0.8, 4.35, 0), Vector3(side * (OPENING + 0.35), 4.4, 0), Color("f2c13c"))
		mesh.facing(Vector3(0, 0, -1))
		mesh.quad(Vector3(side * (OPENING + 0.35), 4.95, 0), Vector3(side * (OPENING + 0.35) + 0.8, 4.8, 0), Vector3(side * (OPENING + 0.35) + 0.8, 4.35, 0), Vector3(side * (OPENING + 0.35), 4.4, 0), Color("c89a20"))
	parent.add_child(_holder(mesh, "RockArch"))
	var models: Array[String] = ["rock_largeA", "tree_pineTallA", "rock_largeC"]
	_flank(parent, models, ModelKit.KENNEY_NATURE)


## The Gainlands: a colossal barbell for an arch, red and gold plate stacks, pennants.
static func _barbell_arch(parent: Node3D) -> void:
	var mesh: ProcMesh = ProcMesh.new()
	var steel: Color = Color("aeb4c4")
	for side: float in [-1.0, 1.0]:
		var x: float = side * (OPENING + 0.5)
		var height: float = 0.0
		for i: int in range(6):
			var thickness: float = 0.3
			mesh.frustum(height, height + thickness, 0.62 - 0.02 * float(i), 0.62 - 0.02 * float(i), 12, [Color("e2493f"), Color("f6c23c"), Color("3d9be0")][i % 3], Transform3D(Basis.IDENTITY, Vector3(x, 0, 0)))
			height += thickness
		mesh.frustum(0.0, 3.3, 0.14, 0.14, 8, steel, Transform3D(Basis.IDENTITY, Vector3(x, 0, 0)))
		mesh.frustum(3.0, 3.5, 0.34, 0.34, 10, Color("e2493f"), Transform3D(Basis.IDENTITY, Vector3(x, 0, 0)))
	mesh.frustum(-OPENING - 0.9, OPENING + 0.9, 0.11, 0.11, 8, steel, Transform3D(Basis(Vector3(0, 0, 1), PI * 0.5), Vector3(0, 3.25, 0)), true, true)
	for side: float in [-1.0, 1.0]:
		mesh.frustum(0.0, 0.55, 0.45, 0.45, 12, Color("2c2840"), Transform3D(Basis(Vector3(0, 0, 1), PI * 0.5), Vector3(side * (OPENING + 0.35), 3.25, 0)), true, true)
	mesh.frustum(0.0, 3.8, 0.04, 0.04, 5, WOOD_DARK, Transform3D(Basis.IDENTITY, Vector3(-OPENING - 1.4, 0, 0.4)))
	mesh.facing(Vector3(0, 0, 1))
	mesh.quad(Vector3(-OPENING - 1.4, 3.75, 0.4), Vector3(-OPENING - 0.4, 3.6, 0.4), Vector3(-OPENING - 0.4, 3.1, 0.4), Vector3(-OPENING - 1.4, 3.2, 0.4), Color("e2493f"))
	mesh.facing(Vector3(0, 0, -1))
	mesh.quad(Vector3(-OPENING - 1.4, 3.75, 0.4), Vector3(-OPENING - 0.4, 3.6, 0.4), Vector3(-OPENING - 0.4, 3.1, 0.4), Vector3(-OPENING - 1.4, 3.2, 0.4), Color("b8342c"))
	parent.add_child(_holder(mesh, "BarbellArch"))
	_flank(parent, ["rock_largeB", "tree_oak", "plant_bushLarge"] as Array[String], ModelKit.KENNEY_NATURE)


## The D.N.A.: a grey steel office gate flanked by filing-cabinet walls, with a sickly lamp and a red "approved" stamp light.
static func _office_gate(parent: Node3D) -> void:
	var mesh: ProcMesh = ProcMesh.new()
	var steel: Color = Color("6e7480")
	var dark: Color = Color("3a3e48")
	for side: float in [-1.0, 1.0]:
		var x: float = side * (OPENING + 0.55)
		mesh.box(Vector3(x, 1.5, 0), Vector3(1.0, 3.0, 1.3), steel)
		for drawer: int in range(5):
			mesh.box(Vector3(x, 0.35 + float(drawer) * 0.58, 0.67), Vector3(0.84, 0.46, 0.04), dark)
			mesh.box(Vector3(x, 0.4 + float(drawer) * 0.58, 0.7), Vector3(0.3, 0.05, 0.03), Color("c8ccd4"))
	mesh.box(Vector3(0, 3.15, 0), Vector3(OPENING * 2.0 + 2.1, 0.5, 1.3), dark)
	mesh.box(Vector3(0, 3.15, 0.68), Vector3(OPENING * 2.0 + 0.8, 0.3, 0.04), Color("e0221a"))
	mesh.box(Vector3(0, 3.8, 0), Vector3(1.6, 0.6, 0.4), steel)
	mesh.box(Vector3(0, 3.8, 0.22), Vector3(1.3, 0.35, 0.03), Color("c8ccd4"))
	# a turnstile in the opening (never blocks: it is only the look of bureaucracy)
	mesh.frustum(0.0, 1.0, 0.07, 0.07, 6, dark, Transform3D(Basis.IDENTITY, Vector3(0, 0, -0.9)))
	mesh.box(Vector3(0, 0.9, -0.9), Vector3(0.9, 0.05, 0.05), Color("e0221a"))
	parent.add_child(_holder(mesh, "OfficeGate"))
	_flank(parent, ["rock_largeD", "tree_default_dark", "rock_largeE"] as Array[String], ModelKit.KENNEY_NATURE)


## The Endless Buffet: a wooden arch with a red-and-cream awning and bread, cheese and sausages hanging from it.
static func _awning_arch(parent: Node3D) -> void:
	var mesh: ProcMesh = ProcMesh.new()
	for side: float in [-1.0, 1.0]:
		var x: float = side * (OPENING + 0.35)
		mesh.frustum(0.0, 3.2, 0.2, 0.17, 8, WOOD, Transform3D(Basis.IDENTITY, Vector3(x, 0, 0)))
		mesh.box(Vector3(x, 0.15, 0), Vector3(0.7, 0.3, 0.7), WOOD_DARK)
	mesh.box(Vector3(0, 3.3, 0), Vector3(OPENING * 2.0 + 1.1, 0.3, 0.45), WOOD_LIGHT)
	for i: int in range(8):
		var width: float = (OPENING * 2.0 + 1.3) / 8.0
		var x0: float = -(OPENING + 0.65) + float(i) * width
		var tone: Color = Color("e2493f") if i % 2 == 0 else CREAM
		mesh.facing(Vector3(0, 1, 0))
		mesh.quad(Vector3(x0, 3.2, 0.9), Vector3(x0 + width, 3.2, 0.9), Vector3(x0 + width, 3.6, -0.45), Vector3(x0, 3.6, -0.45), tone)
		mesh.facing(Vector3(0, -1, 0))
		mesh.quad(Vector3(x0, 3.2, 0.9), Vector3(x0 + width, 3.2, 0.9), Vector3(x0 + width, 3.6, -0.45), Vector3(x0, 3.6, -0.45), tone.darkened(0.15))
		mesh.facing(Vector3(0, 0, 1))
		mesh.quad(Vector3(x0, 3.2, 0.9), Vector3(x0 + width, 3.2, 0.9), Vector3(x0 + width * 0.5, 2.95, 0.9), Vector3(x0 + width * 0.5, 2.95, 0.9), tone)
	for i: int in range(4):
		mesh.frustum(2.2, 3.2, 0.012, 0.012, 3, WOOD_DARK, Transform3D(Basis.IDENTITY, Vector3(-1.2 + float(i) * 0.8, 0, 0.1)))
		mesh.sphere(Vector3(-1.2 + float(i) * 0.8, 2.1, 0.1), 0.22, 3, 7, [Color("c0603a"), Color("e8c050"), Color("c0603a"), Color("e8c050")][i], Transform3D.IDENTITY, 1.5)
	parent.add_child(_holder(mesh, "AwningArch"))
	_kit(parent, ModelKit.KENNEY_FOOD, "cheese", Vector3(-OPENING - 0.9, 0.0, 1.4), 20.0, 1.6)
	_kit(parent, ModelKit.KENNEY_FOOD, "pie", Vector3(OPENING + 0.9, 0.0, 1.3), -20.0, 1.4)
	_flank(parent, ["tree_oak", "plant_bushLarge", "tree_default"] as Array[String], ModelKit.KENNEY_NATURE)


## The Verdant Dump: a path winding between mossy log piles, junk heaps and mushrooms, under a crooked log arch.
static func _overgrown_junk(parent: Node3D) -> void:
	var mesh: ProcMesh = ProcMesh.new()
	var moss: Color = Color("5f9a4a")
	for side: float in [-1.0, 1.0]:
		var x: float = side * (OPENING + 0.4)
		mesh.frustum(0.0, 3.0, 0.2, 0.16, 7, WOOD_DARK, Transform3D(Basis(Vector3(0, 0, 1), -side * 0.08), Vector3(x, 0, 0)))
		mesh.sphere(Vector3(x, 0.4, 0.4), 0.7, 4, 8, moss, Transform3D.IDENTITY, 0.6)
		for i: int in range(3):
			mesh.box(Vector3(x + side * (0.3 + 0.25 * float(i)), 0.25 + 0.4 * float(i), -0.6 + 0.6 * float(i)), Vector3(0.5, 0.35, 0.5), [Color("8a6a4a"), Color("6a7a58"), Color("a07a50")][i], Transform3D(Basis(Vector3.UP, float(i) * 0.6), Vector3.ZERO))
	mesh.frustum(-OPENING - 0.7, OPENING + 0.7, 0.16, 0.14, 7, WOOD, Transform3D(Basis(Vector3(0, 0, 1), PI * 0.5 + 0.06), Vector3(0, 3.05, 0)), true, true)
	for i: int in range(6):
		mesh.sphere(Vector3(-OPENING + float(i) * 0.6, 2.85 + sin(float(i)) * 0.1, 0.1), 0.2, 3, 6, moss.lightened(0.1 * float(i % 3)), Transform3D.IDENTITY, 0.7)
	for i: int in range(4):
		var x2: float = (OPENING + 0.7) * (1.0 if i % 2 == 0 else -1.0)
		mesh.frustum(0.0, 0.25, 0.04, 0.035, 5, CREAM, Transform3D(Basis.IDENTITY, Vector3(x2, 0, 1.4 - float(i) * 0.5)))
		mesh.sphere(Vector3(x2, 0.28, 1.4 - float(i) * 0.5), 0.15, 3, 6, Color("d8453a"), Transform3D.IDENTITY, 0.6)
	parent.add_child(_holder(mesh, "JunkArch"))
	_kit(parent, ModelKit.KENNEY_SURVIVAL, "barrel", Vector3(-OPENING - 1.0, 0.0, 1.6), 30.0, 2.0)
	_kit(parent, ModelKit.KENNEY_SURVIVAL, "box-large", Vector3(OPENING + 1.0, 0.0, 1.2), 15.0, 1.8)
	_flank(parent, ["tree_oak_fall", "stump_roundDetailed", "tree_default_fall"] as Array[String], ModelKit.KENNEY_NATURE)
