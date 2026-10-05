class_name StyleRig
extends Node
## Installs a `ZonePreset` into a 3D scene: WorldEnvironment (sky, ambient = coloured shadow, fog, volumetrics, bloom, SSAO, grading, tonemap), a key light, the shader
## globals for the toon material, the screen-space outline pass, optional depth of field, ambient particles, and converts every mesh (including ones added later)
## to the toon material. Reacts to `Settings.graphics_changed`. One rig per scene: `StyleRig.install(self, StylePresets.TOWN, camera, player)`.

const OUTLINE_SHADER: String = "res://assets/shaders/style_outline.gdshader"

var preset: ZonePreset
var preset_id: StringName = &"town"
var camera: Camera3D
var follow: Node3D
var world_env: WorldEnvironment
var sun: DirectionalLight3D
var fill: DirectionalLight3D
var outline: MeshInstance3D
var ambience: StyleAmbience
## Quality override for tests/screenshots (-1 = use Settings).
var quality_override: int = -1
## Meshes farther than this from the camera are not drawn (0 = no limit): trims geometry the diorama camera cannot see anyway.
var cull_distance: float = 0.0

var _scene_root: Node
var _pending: Array[Node] = []
var _flush_queued: bool = false


static func install(scene: Node, id: StringName, camera_node: Camera3D, follow_target: Node3D = null, cull: float = 0.0) -> StyleRig:
	if OS.get_environment("NO_STYLE") != "":
		return null
	var rig: StyleRig = StyleRig.new()
	rig.name = "StyleRig"
	rig.preset_id = id
	rig.camera = camera_node
	rig.follow = follow_target
	rig.cull_distance = cull
	scene.add_child(rig)
	return rig


func quality() -> int:
	return quality_override if quality_override >= 0 else Settings.graphics_quality


func _ready() -> void:
	_scene_root = get_parent()
	preset = StylePresets.get_preset(preset_id)
	_remove_old_environment()
	world_env = WorldEnvironment.new()
	world_env.name = "StyleEnvironment"
	add_child(world_env)
	sun = DirectionalLight3D.new()
	sun.name = "StyleSun"
	add_child(sun)
	fill = DirectionalLight3D.new()
	fill.name = "StyleFill"
	add_child(fill)
	_build_outline()
	_build_ambience()
	apply()
	StyleToon.apply(_scene_root, preset.wind)
	if cull_distance > 0.0:
		for node: Node in _scene_root.find_children("*", "MeshInstance3D", true, false):
			_limit_range(node as MeshInstance3D)
	get_tree().node_added.connect(_on_node_added)
	Settings.graphics_changed.connect(apply)


func _exit_tree() -> void:
	if get_tree() != null and get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.disconnect(_on_node_added)
	if Settings.graphics_changed.is_connected(apply):
		Settings.graphics_changed.disconnect(apply)


## Switches to another preset (the Capital changing state, a zone variant).
func set_preset(id: StringName) -> void:
	preset_id = id
	preset = StylePresets.get_preset(id)
	apply()
	if ambience != null:
		ambience.configure(preset, quality())


func _remove_old_environment() -> void:
	for child: Node in _scene_root.get_children():
		if child is WorldEnvironment:
			child.queue_free()
		elif child is DirectionalLight3D:
			if sun_cull_mask_hint == 0:
				sun_cull_mask_hint = (child as DirectionalLight3D).light_cull_mask
			child.queue_free()


var sun_cull_mask_hint: int = 0


func apply() -> void:
	var level: int = quality()
	_apply_globals()
	GraphicsQuality.apply_to_viewport(get_viewport(), level)
	RenderingServer.directional_shadow_atlas_set_size(1536 if level < GraphicsQuality.Level.HIGH else 4096, true)
	RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_LOW if level < GraphicsQuality.Level.HIGH else RenderingServer.ENV_SSAO_QUALITY_MEDIUM, true, 0.5, 2, 50, 300)
	RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW if level < GraphicsQuality.Level.HIGH else RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
	if OS.get_environment("STYLE_DEBUG") != "":
		print("style_rig: level %d msaa %d scale %.2f aa %d" % [level, get_viewport().msaa_3d, get_viewport().scaling_3d_scale, get_viewport().screen_space_aa])
	_apply_environment(level)
	_apply_lights(level)
	if outline != null:
		outline.visible = GraphicsQuality.outlines(level)
		var material: ShaderMaterial = outline.material_override as ShaderMaterial
		material.set_shader_parameter("line_color", preset.outline_color)
		material.set_shader_parameter("strength", preset.outline_strength)
	_apply_dof(level)
	if ambience != null:
		ambience.configure(preset, level)


func _apply_globals() -> void:
	RenderingServer.global_shader_parameter_set("style_rim_color", preset.rim_color)
	RenderingServer.global_shader_parameter_set("style_highlight", preset.highlight)
	RenderingServer.global_shader_parameter_set("style_desaturate", preset.desaturate)
	RenderingServer.global_shader_parameter_set("style_accent", preset.accent)
	RenderingServer.global_shader_parameter_set("style_wind", preset.wind)


func _apply_environment(level: int) -> void:
	var env: Environment = Environment.new()
	if preset.use_sky:
		var sky_material: ProceduralSkyMaterial = ProceduralSkyMaterial.new()
		sky_material.sky_top_color = preset.sky_top
		sky_material.sky_horizon_color = preset.sky_horizon
		sky_material.ground_horizon_color = preset.ground_horizon
		sky_material.ground_bottom_color = preset.ground_bottom
		sky_material.sun_angle_max = 25.0
		sky_material.sky_curve = 0.2
		var sky: Sky = Sky.new()
		sky.sky_material = sky_material
		env.background_mode = Environment.BG_SKY
		env.sky = sky
	else:
		env.background_mode = Environment.BG_COLOR
		env.background_color = preset.background_color
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = preset.ambient_color
	env.ambient_light_energy = preset.ambient_energy
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC if preset.filmic else Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = preset.exposure
	env.glow_enabled = GraphicsQuality.glow(level)
	env.glow_intensity = preset.glow_intensity
	env.glow_strength = 0.9
	env.glow_bloom = 0.08
	env.glow_hdr_threshold = preset.glow_threshold
	env.adjustment_enabled = true
	env.adjustment_saturation = preset.saturation
	env.adjustment_contrast = preset.contrast
	env.adjustment_brightness = preset.brightness
	env.ssao_enabled = GraphicsQuality.ssao(level)
	env.ssao_radius = preset.ssao_radius
	env.ssao_intensity = preset.ssao_intensity
	env.fog_enabled = true
	env.fog_light_color = preset.fog_color
	env.fog_density = preset.fog_density
	env.fog_sky_affect = preset.fog_sky_affect
	if GraphicsQuality.volumetric_fog(level) and preset.volumetric_density > 0.0:
		env.volumetric_fog_enabled = true
		env.volumetric_fog_density = preset.volumetric_density
		env.volumetric_fog_albedo = preset.volumetric_color
		env.volumetric_fog_length = 48.0
	world_env.environment = env


func _apply_lights(level: int) -> void:
	sun.light_color = preset.sun_color
	sun.light_energy = preset.sun_energy
	sun.rotation_degrees = Vector3(preset.sun_pitch, preset.sun_yaw, 0.0)
	sun.light_angular_distance = 1.5
	var detail: int = GraphicsQuality.shadow_detail(level)
	sun.shadow_enabled = detail > 0
	sun.shadow_blur = 1.6
	sun.directional_shadow_max_distance = 20.0 if detail < 2 else 48.0
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL if detail < 2 else DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	if sun_cull_mask_hint != 0:
		sun.light_cull_mask = sun_cull_mask_hint
	# A faint cool fill from the opposite side keeps the shadow side coloured, never flat.
	fill.light_color = preset.ambient_color.lerp(Color.WHITE, 0.25)
	fill.light_energy = 0.18
	fill.rotation_degrees = Vector3(-28.0, preset.sun_yaw + 150.0, 0.0)
	fill.shadow_enabled = false
	fill.light_cull_mask = sun.light_cull_mask


func _build_outline() -> void:
	if camera == null:
		return
	outline = MeshInstance3D.new()
	outline.name = "StyleOutline"
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(2.0, 2.0)
	outline.mesh = quad
	outline.extra_cull_margin = 16384.0
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = load(OUTLINE_SHADER) as Shader
	outline.material_override = material
	outline.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	outline.set_meta(StyleToon.META_NO_TOON, true)
	camera.add_child(outline)


func _build_ambience() -> void:
	ambience = StyleAmbience.new()
	ambience.name = "StyleAmbience"
	ambience.follow = follow if follow != null else camera
	add_child(ambience)
	ambience.configure(preset, quality())


func _apply_dof(level: int) -> void:
	if camera == null:
		return
	if Settings.depth_of_field and GraphicsQuality.dof_allowed(level):
		var attributes: CameraAttributesPractical = CameraAttributesPractical.new()
		attributes.dof_blur_far_enabled = true
		attributes.dof_blur_far_distance = preset.dof_distance
		attributes.dof_blur_far_transition = 14.0
		attributes.dof_blur_amount = preset.dof_amount
		attributes.dof_blur_near_enabled = true
		attributes.dof_blur_near_distance = 6.0
		attributes.dof_blur_near_transition = 4.0
		camera.attributes = attributes
	else:
		camera.attributes = null


# ---- Converting meshes added after the rig (characters, enemies, spawned props) ------------------------------------------------


func _on_node_added(node: Node) -> void:
	if not node is MeshInstance3D or _scene_root == null or not _scene_root.is_ancestor_of(node):
		return
	_pending.append(node)
	if not _flush_queued:
		_flush_queued = true
		_flush.call_deferred()


func _flush() -> void:
	_flush_queued = false
	for node: Node in _pending:
		if is_instance_valid(node) and node.is_inside_tree():
			StyleToon.apply_mesh(node as MeshInstance3D, preset.wind)
			_limit_range(node as MeshInstance3D)
	_pending.clear()


func _limit_range(mesh_instance: MeshInstance3D) -> void:
	if cull_distance > 0.0 and mesh_instance.get_parent() != camera:
		mesh_instance.visibility_range_end = cull_distance
		mesh_instance.visibility_range_end_margin = 3.0
		mesh_instance.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED


# ---- Light budget: only the nearest dressing lights stay on (the glow decals keep the pools visible) ---------------------------------


var _budget_lights: Array[OmniLight3D] = []
var _budget_timer: float = 0.0


func register_lights(lights: Array[OmniLight3D]) -> void:
	_budget_lights.append_array(lights)
	_update_light_budget()


func _process(delta: float) -> void:
	_budget_timer -= delta
	if _budget_timer <= 0.0:
		_budget_timer = 0.3
		_update_light_budget()


func _update_light_budget() -> void:
	if _budget_lights.is_empty():
		return
	var origin: Vector3 = follow.global_position if follow != null else Vector3.ZERO
	var live: Array[OmniLight3D] = []
	for light: OmniLight3D in _budget_lights:
		if is_instance_valid(light):
			live.append(light)
	live.sort_custom(func(a: OmniLight3D, b: OmniLight3D) -> bool: return a.global_position.distance_squared_to(origin) < b.global_position.distance_squared_to(origin))
	var budget: int = GraphicsQuality.light_budget(quality())
	for index: int in range(live.size()):
		live[index].visible = index < budget
