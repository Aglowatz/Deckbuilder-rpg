class_name DungeonBackdrop
extends Node3D
## The 3D diorama behind a zone dungeon's node map (Part E): each of the four final dungeons has its own
## stage, built from the packs already in the project (KayKit Restaurant Bits, Kenney Furniture /
## Nature / Survival kits) plus simple primitives:
##   "kitchen"  - the Test Kitchen: steel checker floor, counters, ovens, glowing flasks, an enormous
##                unfinished cannon, cold green-white light.
##   "house"    - the House of Gains: dark iron-less steel, red floodlights, banners, a row of bone-pale prison
##                bars, boulders and logs (the only gym equipment left).
##   "hall"     - the Hall of Final Approvals: endless desks, cabinets, a queue of rope posts, fluorescent
##                strips, a NOW SERVING board.
##   "castle"   - Primm's Castle: marble, gold, endless portraits of its owner, mirrors, a scale model of the kingdom on a table.
##   "rotheart" - the Rotheart: dark purple-green, giant mutant mushrooms, writhing roots and a pulsing
##                glowing heart in the middle.
## A slowly swaying camera looks down on it, like `ArenaBackdrop`; the map screen dims it.

const FURNITURE: String = "res://assets/kenney-furniture-kit/models/"
const NATURE: String = "res://assets/kenney-nature-kit/models/"
const RESTAURANT: String = "res://assets/KayKit-Restaurant-Bits-1.0/gltf/"
const SURVIVAL: String = "res://assets/kenney-survival-kit/models/"

var theme: String = "kitchen"
var _camera: Camera3D
var _time: float = 0.0
var _pulse: Node3D
var _preset: ZonePreset
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


static func make(theme_name: String) -> DungeonBackdrop:
	var backdrop: DungeonBackdrop = DungeonBackdrop.new()
	backdrop.name = "DungeonBackdrop"
	backdrop.theme = theme_name
	return backdrop


func _ready() -> void:
	_rng.seed = 7
	match theme:
		"house":
			_build_house()
		"hall":
			_build_hall()
		"castle":
			_build_castle()
		"rotheart":
			_build_rotheart()
		_:
			_build_kitchen()
	_camera = Camera3D.new()
	_camera.fov = 45.0
	add_child(_camera)
	_camera.current = true
	_install_style()
	_update_camera()


func _process(delta: float) -> void:
	_time += delta
	_update_camera()
	if _pulse != null:
		var beat: float = 1.0 + 0.08 * sin(_time * 2.2) + 0.04 * sin(_time * 4.4)
		_pulse.scale = Vector3.ONE * beat


func _update_camera() -> void:
	_camera.position = Vector3(sin(_time * 0.08) * 2.5, 11.0, 10.5)
	_camera.look_at(Vector3(0, 0.2, 0.5), Vector3.UP)


# ---- Shared helpers -----------------------------------------------------------------------


## Collects this stage's mood into a `ZonePreset`; `StyleRig` turns it into the environment once the stage is built (`_install_style`).
func _environment(sky_top: Color, sky_horizon: Color, ambient: Color, fog: Color, fog_density: float, exposure: float) -> void:
	_preset = StylePresets.get_preset(StylePresets.DUNGEON)
	_preset.sky_top = sky_top
	_preset.sky_horizon = sky_horizon
	_preset.ground_horizon = sky_horizon
	_preset.ground_bottom = sky_top.darkened(0.3)
	_preset.ambient_color = ambient.darkened(0.25)
	_preset.ambient_energy = 0.9
	_preset.fog_color = fog
	_preset.fog_density = fog_density
	_preset.exposure = exposure * 0.85
	_preset.volumetric_density = 0.0


func _sun(color: Color, energy: float, rotation_deg: Vector3) -> void:
	if _preset == null:
		return
	_preset.sun_color = color
	_preset.sun_energy = energy
	_preset.sun_pitch = rotation_deg.x
	_preset.sun_yaw = rotation_deg.y


func _install_style() -> void:
	var rig: StyleRig = StyleRig.install(self, StylePresets.DUNGEON, _camera, null, 0.0, _preset)
	rig.name = "StyleRig"


func _lamp(color: Color, energy: float, pos: Vector3, light_range: float = 9.0) -> OmniLight3D:
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = color
	light.light_energy = energy
	light.omni_range = light_range
	light.position = pos
	add_child(light)
	return light


func _material(color: Color, rough: float = 0.8, emission: float = 0.0) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = rough
	if emission > 0.0:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = emission
	return material


func _box(size: Vector3, material: Material, pos: Vector3, yaw: float = 0.0) -> MeshInstance3D:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = pos
	instance.rotation_degrees.y = yaw
	add_child(instance)
	return instance


func _cylinder(radius: float, height: float, material: Material, pos: Vector3, rot_deg: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = pos
	instance.rotation_degrees = rot_deg
	add_child(instance)
	return instance


func _ball(radius: float, material: Material, pos: Vector3) -> MeshInstance3D:
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = pos
	add_child(instance)
	return instance


## A model from one of the packs (a path under `res://assets/...`), or an empty node when it is missing.
func _model(path: String, pos: Vector3, yaw: float = 0.0, uniform_scale: float = 1.0, tint: Color = Color(0, 0, 0, 0)) -> Node3D:
	var packed: PackedScene = ModelKit.scene(path)
	if packed == null:
		return Node3D.new()
	var node: Node3D = packed.instantiate() as Node3D
	add_child(node)
	node.position = pos
	node.rotation_degrees.y = yaw
	node.scale = Vector3.ONE * uniform_scale
	if tint.a > 0.0:
		ModelKit.tint(node, tint)
	return node


func _floor(width: int, depth: int, size: float, color_a: Color, color_b: Color, y: float = -0.1) -> void:
	var material_a: StandardMaterial3D = _material(color_a, 0.6)
	var material_b: StandardMaterial3D = _material(color_b, 0.6)
	for row: int in range(depth):
		for col: int in range(width):
			var pos: Vector3 = Vector3((float(col) - float(width - 1) * 0.5) * size, y, (float(row) - float(depth - 1) * 0.5) * size)
			_box(Vector3(size * 0.98, 0.2, size * 0.98), material_a if (row + col) % 2 == 0 else material_b, pos)


func _steam(pos: Vector3, color: Color) -> void:
	var particles: CPUParticles3D = CPUParticles3D.new()
	particles.position = pos
	particles.amount = 24
	particles.lifetime = 3.0
	particles.preprocess = 3.0
	particles.direction = Vector3.UP
	particles.spread = 12.0
	particles.initial_velocity_min = 0.6
	particles.initial_velocity_max = 1.2
	particles.gravity = Vector3.ZERO
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.12
	mesh.height = 0.24
	particles.mesh = mesh
	particles.material_override = _material(Color(color, 0.5), 1.0, 0.8)
	add_child(particles)


func _label(text: String, pos: Vector3, color: Color, pixel_size: float = 0.012) -> void:
	var label: Label3D = Label3D.new()
	label.text = text
	label.font = UIStyle.font_title()
	label.font_size = 48
	label.pixel_size = pixel_size
	label.modulate = color
	label.outline_size = 8
	label.outline_modulate = Color(0, 0, 0, 0.8)
	label.position = pos
	label.rotation_degrees.x = -50.0
	add_child(label)


# ---- The Test Kitchen -------------------------------------------------------------------------


func _build_kitchen() -> void:
	_environment(Color("0f1f14"), Color("2f5a3a"), Color("c8f0d4"), Color("4a8a5a"), 0.008, 1.25)
	_sun(Color("e6fff0"), 1.0, Vector3(-55, -30, 0))
	_floor(16, 11, 1.4, Color("dfe8e4"), Color("b9cfc4"))
	for index: int in range(7):
		var x: float = -9.0 + float(index) * 3.0
		_model(RESTAURANT + "kitchencounter_straight_A.gltf", Vector3(x, 0, -7.2), 0.0, 1.5)
	_model(RESTAURANT + "oven.gltf", Vector3(-6.0, 0, -5.8), 0.0, 1.4)
	_model(RESTAURANT + "oven.gltf", Vector3(5.0, 0, -5.8), 0.0, 1.4)
	_model(RESTAURANT + "fridge_A_decorated.gltf", Vector3(10.5, 0, -5.0), -90.0, 1.4)
	_model(RESTAURANT + "pot_large.gltf", Vector3(-1.5, 0, -5.4), 0.0, 1.6)
	_model(RESTAURANT + "kitchentable_A_large.gltf", Vector3(7.5, 0, 3.0), 0.0, 1.3)
	_model(RESTAURANT + "kitchentable_A_large.gltf", Vector3(-8.5, 0, 3.5), 0.0, 1.3)
	# The enormous, unfinished war machine: a cannon on scaffolding in the back-left.
	var steel: StandardMaterial3D = _material(Color("8a96a0"), 0.35)
	_cylinder(1.1, 7.0, steel, Vector3(-4.0, 3.0, -2.0), Vector3(0, 0, 70))
	_cylinder(1.45, 1.2, _material(Color("5d6770"), 0.4), Vector3(-0.8, 4.3, -2.0), Vector3(0, 0, 70))
	for scaffold: int in range(4):
		_box(Vector3(0.25, 4.0 + float(scaffold % 2), 0.25), _material(Color("c9a15a"), 0.8), Vector3(-7.0 + float(scaffold) * 1.6, 2.0, -3.0 + float(scaffold % 2) * 2.0))
	_box(Vector3(6.5, 0.2, 0.25), _material(Color("c9a15a"), 0.8), Vector3(-4.0, 3.9, -3.0))
	# Corrupted ingredient flasks (they glow).
	for flask: int in range(6):
		var flask_pos: Vector3 = Vector3(-7.0 + float(flask) * 2.6, 1.3, 1.5 + float(flask % 3) * 1.4)
		_ball(0.45, _material(Color("66ff99"), 0.2, 2.0), flask_pos)
		_cylinder(0.12, 0.5, _material(Color("dfe8e4"), 0.2), flask_pos + Vector3(0, 0.5, 0))
	_lamp(Color("88ffb0"), 2.2, Vector3(-2, 4.0, 2), 10.0)
	_lamp(Color("ffffff"), 1.5, Vector3(6, 4.0, -2), 9.0)
	_steam(Vector3(-1.5, 2.2, -5.4), Color("e8fff0"))
	_steam(Vector3(5.0, 2.4, -6.0), Color("e8fff0"))


# ---- The House of Gains -------------------------------------------------------------------------


func _build_house() -> void:
	_environment(Color("1a0a0c"), Color("5a1f22"), Color("e0a0a0"), Color("40181c"), 0.01, 1.2)
	_sun(Color("ffb0a0"), 0.7, Vector3(-60, 25, 0))
	_floor(16, 11, 1.4, Color("3b3b42"), Color("2f2f36"))
	var steel: StandardMaterial3D = _material(Color("55555f"), 0.3)
	for index: int in range(6):
		var x: float = -8.5 + float(index) * 3.4
		_cylinder(0.5, 6.0, steel, Vector3(x, 3.0, -7.0))
		var banner: MeshInstance3D = _box(Vector3(1.4, 3.0, 0.1), _material(Color("8a1f1f"), 0.9), Vector3(x, 3.6, -6.3))
		banner.rotation_degrees.y = 0.0
		_box(Vector3(1.4, 0.4, 0.12), _material(Color("0d0d10"), 0.9), Vector3(x, 3.6, -6.25))
	# The Iron-less Prison: pale, bone-coloured bars (not a scrap of iron) in a row on the left.
	var bone: StandardMaterial3D = _material(Color("d9cfb8"), 0.7)
	for bar: int in range(9):
		_cylinder(0.09, 3.2, bone, Vector3(-9.5 + float(bar) * 0.5, 1.6, 1.0))
	_box(Vector3(5.0, 0.15, 0.2), bone, Vector3(-7.5, 3.2, 1.0))
	_box(Vector3(5.0, 3.2, 3.0), _material(Color("141418"), 0.9), Vector3(-7.5, 1.6, 2.7))
	_model(NATURE + "bed_floor.glb", Vector3(-8.0, 0.0, 3.0), 90.0, 1.4)
	# The only "gym equipment" left: boulders and logs.
	for rock: int in range(5):
		_model(NATURE + "rock_largeA.glb", Vector3(2.0 + float(rock) * 1.9, 0, 3.5 + float(rock % 2) * 1.2), _rng.randf() * 360.0, 1.5, Color(0.7, 0.62, 0.62))
	_model(NATURE + "log_large.glb", Vector3(-1.0, 0, 5.0), 20.0, 1.8)
	_model(NATURE + "log_stackLarge.glb", Vector3(8.5, 0, -2.5), 0.0, 1.8)
	# The regime's throne: one barbell-shaped bench (the single barbell in the House).
	_box(Vector3(2.4, 0.5, 1.0), _material(Color("a31616"), 0.5), Vector3(4.0, 0.5, -3.5))
	_cylinder(0.12, 3.2, steel, Vector3(4.0, 1.7, -3.5), Vector3(0, 0, 90))
	_ball(0.5, steel, Vector3(2.4, 1.7, -3.5))
	_ball(0.5, steel, Vector3(5.6, 1.7, -3.5))
	for index: int in range(3):
		var spot: SpotLight3D = SpotLight3D.new()
		spot.light_color = Color("ff5040")
		spot.light_energy = 6.0
		spot.spot_range = 14.0
		spot.spot_angle = 40.0
		spot.position = Vector3(-6.0 + float(index) * 6.0, 7.0, -1.0)
		spot.rotation_degrees = Vector3(-90, 0, 0)
		add_child(spot)
	_lamp(Color("ff8060"), 1.6, Vector3(0, 4, 3), 10.0)


# ---- The Hall of Final Approvals -----------------------------------------------------------------


func _build_hall() -> void:
	_environment(Color("0d1614"), Color("3a5048"), Color("d6ece2"), Color("52695f"), 0.008, 1.2)
	_sun(Color("dfffee"), 0.8, Vector3(-70, 15, 0))
	_floor(16, 11, 1.4, Color("6d7f78"), Color("5f716a"))
	for row: int in range(3):
		for col: int in range(5):
			var pos: Vector3 = Vector3(-8.0 + float(col) * 4.0, 0, -4.5 + float(row) * 3.4)
			_model(FURNITURE + "desk.glb", pos, 0.0, 2.2)
			_model(FURNITURE + "chairDesk.glb", pos + Vector3(0, 0, 1.4), 180.0, 2.2)
			_model(FURNITURE + "computerScreen.glb", pos + Vector3(0, 1.6, -0.2), 0.0, 2.2)
	for index: int in range(6):
		_model(FURNITURE + "bookcaseClosedWide.glb", Vector3(-10.5 + float(index) * 4.2, 0, -8.0), 0.0, 2.6)
	# A serpentine queue of rope posts leading to the counter.
	var post: StandardMaterial3D = _material(Color("c9a95a"), 0.3)
	for index: int in range(14):
		var x: float = -9.0 + float(index) * 1.4
		var z: float = 6.0 + 0.9 * sin(float(index) * 0.8)
		_cylinder(0.08, 1.2, post, Vector3(x, 0.6, z))
		_ball(0.15, post, Vector3(x, 1.25, z))
	# Stacks of paperwork.
	var paper: StandardMaterial3D = _material(Color("f2f0e6"), 0.9)
	for stack: int in range(9):
		_box(Vector3(0.7, 0.4 + float(stack % 3) * 0.4, 0.5), paper, Vector3(-7.5 + float(stack) * 1.9, 1.2, -4.0 + float(stack % 3) * 3.4), float(stack) * 13.0)
	_label("NOW SERVING: 3", Vector3(0, 4.2, -6.5), Color("ffcf70"))
	_label("TAKE A NUMBER", Vector3(-6.5, 3.0, 5.0), Color("e8f4ee"), 0.008)
	for index: int in range(4):
		var strip: MeshInstance3D = _box(Vector3(5.0, 0.12, 0.4), _material(Color("e8fff4"), 0.2, 2.5), Vector3(-7.5 + float(index) * 5.0, 5.5, 0.0))
		strip.rotation_degrees.y = 0.0
		_lamp(Color("d8fff0"), 1.4, Vector3(-7.5 + float(index) * 5.0, 5.0, 0.0), 9.0)


# ---- The Rotheart ---------------------------------------------------------------------------------


func _build_rotheart() -> void:
	_environment(Color("0a0612"), Color("2a1838"), Color("b8e8a0"), Color("2f1f3f"), 0.012, 1.2)
	_sun(Color("c8a0ff"), 0.45, Vector3(-60, -20, 0))
	_floor(16, 11, 1.4, Color("1f2a18"), Color("2a3320"))
	# Mutant mushrooms, trees and roots crowd the stage; the closer to the heart, the stranger.
	for index: int in range(26):
		var angle: float = _rng.randf() * TAU
		var radius: float = _rng.randf_range(4.5, 11.0)
		var pos: Vector3 = Vector3(cos(angle) * radius * 1.4, 0, sin(angle) * radius * 0.85)
		var pick: String = ["mushroom_redTall.glb", "mushroom_tanGroup.glb", "mushroom_redGroup.glb", "tree_default_dark.glb"][index % 4]
		var scale_amount: float = _rng.randf_range(2.4, 4.8) if index % 4 != 3 else _rng.randf_range(1.8, 2.8)
		_model(NATURE + pick, pos, _rng.randf() * 360.0, scale_amount, Color(0.85, 0.7, 1.0) if index % 3 == 0 else Color(0, 0, 0, 0))
	var root_material: StandardMaterial3D = _material(Color("3a2a1f"), 0.9)
	for root: int in range(14):
		var root_angle: float = float(root) * TAU / 14.0
		var from_center: Vector3 = Vector3(cos(root_angle) * 3.4, 0.25, sin(root_angle) * 2.3)
		_cylinder(0.22, 4.2, root_material, from_center, Vector3(0, -rad_to_deg(root_angle), 90))
	# The heart: a huge pulsing glowing core.
	var heart: Node3D = Node3D.new()
	heart.position = Vector3(0, 1.6, 0)
	add_child(heart)
	var glow: MeshInstance3D = _ball(1.7, _material(Color("7fe04a"), 0.3, 1.6), Vector3.ZERO)
	glow.set_meta(StyleToon.META_NO_TOON, true)
	remove_child(glow)
	heart.add_child(glow)
	var shell: MeshInstance3D = _ball(2.1, _material(Color(0.7, 0.2, 0.9, 0.18), 0.2, 0.8), Vector3.ZERO)
	(shell.material_override as StandardMaterial3D).transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shell.set_meta(StyleToon.META_NO_TOON, true)
	remove_child(shell)
	heart.add_child(shell)
	_pulse = heart
	_lamp(Color("b4ff6a"), 3.2, Vector3(0, 2.5, 0), 12.0)
	_lamp(Color("b46cff"), 2.0, Vector3(-6, 3, 3), 10.0)
	_lamp(Color("b46cff"), 2.0, Vector3(6, 3, -3), 10.0)
	var spores: CPUParticles3D = CPUParticles3D.new()
	spores.position = Vector3(0, 0.5, 0)
	spores.amount = 70
	spores.lifetime = 6.0
	spores.preprocess = 6.0
	spores.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	spores.emission_box_extents = Vector3(11, 0.5, 7)
	spores.direction = Vector3.UP
	spores.spread = 25.0
	spores.initial_velocity_min = 0.3
	spores.initial_velocity_max = 0.9
	spores.gravity = Vector3(0, 0.05, 0)
	var spore_mesh: SphereMesh = SphereMesh.new()
	spore_mesh.radius = 0.06
	spore_mesh.height = 0.12
	spores.mesh = spore_mesh
	spores.material_override = _material(Color("b4ff6a"), 0.3, 3.0)
	add_child(spores)


## Primm's Castle: a palace of polished marble and gold, endless portraits of its owner, mirrors that show only him and, at the
## centre, a round table with a scale model of the whole kingdom that he rearranges by hand.
func _build_castle() -> void:
	_environment(Color("1a1426"), Color("6a5a78"), Color("e8d8ff"), Color("3a2f48"), 0.006, 1.05)
	_sun(Color("ffe0b0"), 0.7, Vector3(-55, -30, 0))
	_floor(16, 11, 1.4, Color("e8dfc8"), Color("b8a888"))
	var gold: StandardMaterial3D = _material(Color("e8c040"), 0.3, 0.25)
	var marble: StandardMaterial3D = _material(Color("efe8d8"), 0.4)
	# A red carpet runs down the middle of the hall.
	_box(Vector3(20, 0.03, 2.4), _material(Color("8a1f2a"), 0.9), Vector3(0, 0.0, 3.0))
	# Pillars and portraits down both long walls.
	for index: int in range(7):
		var x: float = -9.0 + float(index) * 3.0
		for side: float in [-1.0, 1.0]:
			_cylinder(0.45, 5.0, marble, Vector3(x, 2.5, side * 6.4))
			_box(Vector3(1.0, 0.25, 1.0), gold, Vector3(x, 5.0, side * 6.4))
		var portrait: MeshInstance3D = MeshInstance3D.new()
		var quad: QuadMesh = QuadMesh.new()
		quad.size = Vector2(1.7, 2.1)
		portrait.mesh = quad
		var portrait_material: StandardMaterial3D = StandardMaterial3D.new()
		portrait_material.albedo_texture = CapitalProps.portrait_texture(index % 2)
		portrait_material.cull_mode = BaseMaterial3D.CULL_DISABLED
		portrait.material_override = portrait_material
		portrait.position = Vector3(x + 1.5, 2.8, -6.9)
		add_child(portrait)
		_box(Vector3(2.0, 2.4, 0.1), gold, Vector3(x + 1.5, 2.8, -6.95))
		# A mirror opposite: it reflects only him (a cold glass panel).
		_box(Vector3(1.7, 2.6, 0.08), _material(Color(0.7, 0.9, 1.0, 0.85), 0.05, 0.4), Vector3(x + 1.5, 2.8, 6.95))
	# Chandeliers.
	for index: int in range(3):
		var cx: float = -6.0 + float(index) * 6.0
		_ball(0.45, _material(Color("ffd890"), 0.3, 2.4), Vector3(cx, 4.6, 0.0))
		_lamp(Color("ffd890"), 1.8, Vector3(cx, 4.4, 0.0), 10.0)
	# The scale model of the kingdom on a round table: four districts around a tiny castle.
	_cylinder(2.4, 0.9, _material(Color("5a3a22"), 0.7), Vector3(0, 0.45, -1.0))
	_cylinder(2.2, 0.12, _material(Color("2a5a3a"), 0.9), Vector3(0, 0.95, -1.0))
	var district_colors: Array[Color] = [Color("e2553f"), Color("f2c14e"), Color("a870d8"), Color("7bc86c")]
	for district: int in range(4):
		var angle: float = TAU * float(district) / 4.0 + 0.4
		for house: int in range(5):
			var offset: Vector3 = Vector3(cos(angle) * (0.8 + 0.2 * float(house)) + _rng.randf_range(-0.2, 0.2), 1.1, sin(angle) * (0.8 + 0.2 * float(house)) - 1.0 + _rng.randf_range(-0.2, 0.2))
			_box(Vector3(0.28, 0.3, 0.28), _material(district_colors[district], 0.6, 0.25), offset)
	_box(Vector3(0.5, 0.8, 0.5), _material(Color("e8c040"), 0.3, 0.8), Vector3(0, 1.4, -1.0))
	_pulse = Node3D.new()
	_pulse.position = Vector3(0, 2.2, -1.0)
	add_child(_pulse)
	var glow_ball: MeshInstance3D = _ball(0.25, _material(Color("ffe090"), 0.3, 3.0), Vector3.ZERO)
	remove_child(glow_ball)
	_pulse.add_child(glow_ball)
	_lamp(Color("ffe090"), 2.2, Vector3(0, 2.6, -1.0), 9.0)
	var motes: CPUParticles3D = CPUParticles3D.new()
	motes.position = Vector3(0, 0.5, 0)
	motes.amount = 50
	motes.lifetime = 8.0
	motes.preprocess = 8.0
	motes.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	motes.emission_box_extents = Vector3(11, 0.5, 7)
	motes.direction = Vector3.UP
	motes.spread = 20.0
	motes.initial_velocity_min = 0.1
	motes.initial_velocity_max = 0.4
	motes.gravity = Vector3.ZERO
	var mote_mesh: SphereMesh = SphereMesh.new()
	mote_mesh.radius = 0.04
	mote_mesh.height = 0.08
	motes.mesh = mote_mesh
	motes.material_override = _material(Color("ffe8b0"), 0.3, 2.0)
	add_child(motes)
