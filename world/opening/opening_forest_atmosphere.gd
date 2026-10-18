class_name OpeningForestAtmosphere
extends Node3D
## The Opening Forest's light and air (docs/art/opening_forest.md, Part C), on top of the START preset's cool teal dusk:
##   - the camp lantern: a warm amber pool of real light (soft falloff, a gentle flicker), its glass glowing for the bloom, a warm glow on the ground;
##   - a faint cool glow in the cave mouth and glowing mushrooms along the path's edges that lead the eye to it;
##   - layered ground mist drifting over the forest floor and fog banks between the trunks (`opening_mist.gdshader`);
##   - a few pale moonlight rays through the canopy;
##   - a subtle light that follows the hero (and a rim from the preset) so the characters stay the clearest thing on screen;
##   - dark silhouette foliage at the bottom corners of the screen (camera-attached, `OpeningForestFrame`), blurred by the tilt-shift.
## Fireflies, motes and falling leaves are the preset's particles and `StartingForest`'s fireflies. Scaled by graphics quality.

const MIST_SHADER: String = "res://assets/shaders/opening_mist.gdshader"
const SHAFT_SHADER: String = "res://assets/shaders/style_lightshaft.gdshader"
const LANTERN_COLOR: Color = Color("ffa850")
const LANTERN_ENERGY: float = 3.0
const CAVE_COLOR: Color = Color("5fd8d0")
const SHROOM_COLOR: Color = Color("6ff0e0")
const MIST_COLOR: Color = Color("7fa8b4")

var layout: OpeningForestLayout
var quality: int = GraphicsQuality.Level.MEDIUM
var lantern_light: OmniLight3D
var cave_light: OmniLight3D
var hero_light: OmniLight3D
var shroom_count: int = 0
var mist_count: int = 0
var ray_count: int = 0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _time: float = 0.0
var _glass: StandardMaterial3D
var _shrooms: KitMesh = KitMesh.new()


static func build(parent: Node3D, forest_layout: OpeningForestLayout, hero: Node3D, quality_level: int) -> OpeningForestAtmosphere:
	var atmosphere: OpeningForestAtmosphere = OpeningForestAtmosphere.new()
	atmosphere.name = "OpeningForestAtmosphere"
	atmosphere.layout = forest_layout
	atmosphere.quality = quality_level
	atmosphere._rng.seed = 4242
	parent.add_child(atmosphere)
	atmosphere._lantern()
	atmosphere._cave_glow()
	atmosphere._mushrooms()
	atmosphere._mist()
	atmosphere._rays()
	atmosphere._hero_light(hero)
	return atmosphere


func _process(delta: float) -> void:
	_time += delta
	if lantern_light != null:
		# a gentle flame flicker: two slow waves and a faint quick one, never a strobe
		var flicker: float = 0.9 + 0.06 * sin(_time * 2.3) + 0.04 * sin(_time * 5.7 + 1.3) + 0.025 * sin(_time * 13.1 + 0.4)
		lantern_light.light_energy = LANTERN_ENERGY * flicker
		_glass.emission_energy_multiplier = 2.4 * flicker
	if cave_light != null:
		cave_light.light_energy = 0.9 + 0.12 * sin(_time * 0.7)


# ---- the lantern ------------------------------------------------------------------------------------------------------------------------------


func _lantern() -> void:
	var at: Vector3 = layout.mark("lantern")
	_glass = StandardMaterial3D.new()
	_glass.albedo_color = Color(1.0, 0.78, 0.45)
	_glass.emission_enabled = true
	_glass.emission = LANTERN_COLOR
	_glass.emission_energy_multiplier = 2.4
	_glass.set_meta(StyleToon.META_NO_TOON, true)
	_glass.set_meta(PaintedClasses.META_NO_PAINT, true)
	var glass: MeshInstance3D = MeshInstance3D.new()
	glass.name = "LanternGlass"
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(0.15, 0.24, 0.15)
	glass.mesh = box
	glass.material_override = _glass
	glass.position = at + Vector3(0.0, 0.19, 0.0)
	glass.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(glass)
	lantern_light = OmniLight3D.new()
	lantern_light.name = "LanternLight"
	lantern_light.light_color = LANTERN_COLOR
	lantern_light.light_energy = LANTERN_ENERGY
	lantern_light.omni_range = 8.5
	lantern_light.omni_attenuation = 1.6
	lantern_light.light_volumetric_fog_energy = 1.5
	lantern_light.shadow_enabled = quality >= GraphicsQuality.Level.HIGH
	lantern_light.position = at + Vector3(0.0, 0.55, 0.0)
	add_child(lantern_light)
	# the warm pool on the ground (reads even where the light's falloff is soft)
	GroundDecals.glow(self, at + Vector3(0.5, 0.02, -0.5), 4.6, Color(1.0, 0.62, 0.3), 0.14)


# ---- the cave's glow and the mushrooms that lead to it -------------------------------------------------------------------------------------------


func _cave_glow() -> void:
	var mouth: Vector3 = layout.mark("cave_mouth")
	cave_light = OmniLight3D.new()
	cave_light.name = "CaveGlow"
	cave_light.light_color = CAVE_COLOR
	cave_light.light_energy = 0.9
	cave_light.omni_range = 5.5
	cave_light.omni_attenuation = 1.4
	cave_light.position = mouth + Vector3(0.0, 1.3, 0.4)
	add_child(cave_light)
	GroundDecals.glow(self, mouth + Vector3(0.0, 0.02, 1.6), 2.6, CAVE_COLOR, 0.28)


## Clusters of small glowing mushrooms at the path's edges, more of them nearer the cave, so a line of cool light leads the eye up the path.
func _mushrooms() -> void:
	var cap: StandardMaterial3D = StandardMaterial3D.new()
	cap.albedo_color = SHROOM_COLOR
	cap.emission_enabled = true
	cap.emission = SHROOM_COLOR
	cap.emission_energy_multiplier = 1.8
	cap.vertex_color_use_as_albedo = true
	cap.set_meta(StyleToon.META_NO_TOON, true)
	cap.set_meta(PaintedClasses.META_NO_PAINT, true)
	_shrooms.set_material("cap", cap)
	_shrooms.set_material("stem", EnvKit.flat(Color("c8d8d0").srgb_to_linear(), "opening_stem"))
	var line: Array[Vector2] = OpeningForestLayout.PATH
	var clusters: int = [8, 12, 16][clampi(quality, 0, 2)]
	var lights_left: int = 2
	for index: int in range(clusters):
		var t: float = pow(float(index + 1) / float(clusters + 1), 0.8) * float(line.size() - 1)
		var seg: int = mini(int(t), line.size() - 2)
		var a: Vector2 = line[seg]
		var b: Vector2 = line[seg + 1]
		var c: Vector2 = a.lerp(b, t - float(seg))
		var dir: Vector2 = (b - a).normalized()
		var side: float = -1.0 if index % 2 == 0 else 1.0
		var p: Vector2 = c + Vector2(-dir.y, dir.x) * side * (OpeningForestLayout.PATH_HALF + _rng.randf_range(0.2, 0.7))
		if layout.floor_sdf(p) < 0.1:
			continue
		for k: int in range(3 + _rng.randi() % 3):
			var q: Vector3 = Vector3(p.x + _rng.randf_range(-0.35, 0.35), -0.02, p.y + _rng.randf_range(-0.35, 0.35))
			var size: float = _rng.randf_range(0.12, 0.26)
			var top: Vector3 = q + Vector3(0, size * 0.8, 0)
			_shrooms.tube("stem", q, top, size * 0.14, 5, false)
			_shrooms.lathe("cap", top - Vector3(0, size * 0.06, 0), [Vector2(size * 0.5, 0.0), Vector2(size * 0.42, size * 0.14), Vector2(size * 0.22, size * 0.26), Vector2(0.0, size * 0.3)], 8, 1.0, true, true)
		shroom_count += 1
		GroundDecals.glow(self, Vector3(p.x, 0.02, p.y), 1.0, SHROOM_COLOR, 0.2)
		if lights_left > 0 and index >= clusters - 5 and index % 2 == 1:
			var glow: OmniLight3D = OmniLight3D.new()
			glow.name = "ShroomGlow%d" % lights_left
			glow.light_color = SHROOM_COLOR
			glow.light_energy = 0.55
			glow.omni_range = 2.6
			glow.position = Vector3(p.x, 0.5, p.y)
			add_child(glow)
			lights_left -= 1
	var mesh: MeshInstance3D = _shrooms.instance("GlowMushrooms")
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh.set_meta(&"no_occlusion_fade", true)
	mesh.set_meta(&"no_wind", true)
	add_child(mesh)


# ---- mist and rays ----------------------------------------------------------------------------------------------------------------------------


func _mist_material(strength: float, scale_value: float, seed_value: float) -> ShaderMaterial:
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = load(MIST_SHADER) as Shader
	material.set_shader_parameter("tint", MIST_COLOR)
	material.set_shader_parameter("strength", strength)
	material.set_shader_parameter("scale", scale_value)
	material.set_shader_parameter("seed", seed_value)
	material.set_meta(StyleToon.META_NO_TOON, true)
	material.set_meta(PaintedClasses.META_NO_PAINT, true)
	return material


func _mist_quad(size: Vector2, pos: Vector3, upright: bool, material: ShaderMaterial, yaw: float = 0.0) -> void:
	var quad: PlaneMesh = PlaneMesh.new()
	quad.size = size
	quad.orientation = PlaneMesh.FACE_Z if upright else PlaneMesh.FACE_Y
	var node: MeshInstance3D = MeshInstance3D.new()
	node.name = "Mist%d" % mist_count
	node.mesh = quad
	node.material_override = material
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	node.position = pos
	node.rotation.y = yaw
	node.set_meta(StyleToon.META_NO_TOON, true)
	node.set_meta(&"no_occlusion_fade", true)
	add_child(node)
	mist_count += 1


## Ground mist in two thin layers over the forest floor round the playable area (thicker in the treeline than on the path), and upright banks of
## fog between the far trunks behind the clearing, the nook and the cliff's foot.
func _mist() -> void:
	var bounds: Rect2 = layout.bounds().grow(6.0)
	var low: ShaderMaterial = _mist_material(0.28, 0.16, 1.0)
	var high: ShaderMaterial = _mist_material(0.11, 0.09, 7.0)
	_mist_quad(bounds.size, Vector3(bounds.get_center().x, 0.28, bounds.get_center().y), false, low)
	_mist_quad(bounds.size * 1.2, Vector3(bounds.get_center().x, 0.85, bounds.get_center().y), false, high)
	var banks: Array[Vector4] = [Vector4(-9.0, -10.0, 14.0, 0.5), Vector4(1.5, -20.5, 12.0, 0.0), Vector4(19.0, -15.0, 12.0, -0.9), Vector4(-11.0, -2.0, 10.0, 1.2), Vector4(14.0, -6.0, 10.0, -0.6)]
	var count: int = [3, 4, 5][clampi(quality, 0, 2)]
	for index: int in range(mini(count, banks.size())):
		var bank: Vector4 = banks[index]
		_mist_quad(Vector2(bank.z, 4.5), Vector3(bank.x, 2.0, bank.y), true, _mist_material(0.42, 0.12, float(index) * 3.7 + 2.0), bank.w)


## Pale moonlight rays slanting through the canopy: over the back of the clearing, over the path's bend and beside the cave.
func _rays() -> void:
	var shader: Shader = load(SHAFT_SHADER) as Shader
	if shader == null:
		return
	var spots: Array[Vector3] = [Vector3(1.5, -6.5, 0.9), Vector3(8.2, -12.0, 1.1), Vector3(13.0, -16.5, 0.8), Vector3(-4.0, -9.5, 0.7)]
	var count: int = [2, 3, 4][clampi(quality, 0, 2)]
	for index: int in range(mini(count, spots.size())):
		var spot: Vector3 = spots[index]
		var mesh: CylinderMesh = CylinderMesh.new()
		mesh.top_radius = 0.35 * spot.z
		mesh.bottom_radius = 1.3 * spot.z
		mesh.height = 14.0
		mesh.radial_segments = 14
		mesh.rings = 1
		var material: ShaderMaterial = ShaderMaterial.new()
		material.shader = shader
		material.set_shader_parameter("tint", Color(0.62, 0.86, 0.92))
		material.set_shader_parameter("strength", 0.05)
		material.set_shader_parameter("phase", float(index) * 1.9)
		material.set_shader_parameter("half_height", 7.0)
		var ray: MeshInstance3D = MeshInstance3D.new()
		ray.name = "MoonRay%d" % index
		ray.mesh = mesh
		ray.material_override = material
		ray.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		ray.set_meta(StyleToon.META_NO_TOON, true)
		ray.set_meta(&"no_occlusion_fade", true)
		ray.position = Vector3(spot.x, 6.2, spot.y)
		ray.rotation_degrees = Vector3(0.0, 0.0, -20.0)
		ray.rotate_y(0.3 * float(index % 2) - 0.15)
		add_child(ray)
		ray_count += 1


# ---- readability ------------------------------------------------------------------------------------------------------------------------------


## The same soft light on an NPC (the hooded figure, Elder Maren), so they read as clearly as the hero in the dusk. Returns the light.
static func npc_light(npc: Node3D) -> OmniLight3D:
	var light: OmniLight3D = OmniLight3D.new()
	light.name = "NpcLight"
	light.light_color = Color("ffe2c0")
	light.light_energy = 0.55
	light.omni_range = 2.4
	light.omni_attenuation = 1.8
	light.light_volumetric_fog_energy = 0.0
	npc.add_child(light)
	# the NPC node is scaled down to the character size: undo it so the light keeps its reach in metres
	var s: float = maxf(npc.scale.x, 0.01)
	light.position = Vector3(0.0, 1.5, 0.9) / s
	light.omni_range = 2.4 / s
	return light


## A soft neutral-warm light riding with the hero (no shadow), so the hero reads in the dark stretches of the path as clearly as in the lantern pool.
func _hero_light(hero: Node3D) -> void:
	if hero == null:
		return
	hero_light = OmniLight3D.new()
	hero_light.name = "HeroLight"
	hero_light.light_color = Color("ffe2c0")
	hero_light.light_energy = 0.7
	hero_light.omni_range = 2.8
	hero_light.omni_attenuation = 1.8
	hero_light.light_volumetric_fog_energy = 0.0
	hero_light.position = Vector3(0.0, 1.5, 0.9)
	hero.add_child(hero_light)
