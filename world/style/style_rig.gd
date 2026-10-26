class_name StyleRig
extends Node
## Installs a `ZonePreset` into a 3D scene: WorldEnvironment (sky, ambient = coloured shadow, fog, volumetrics, bloom, SSAO, grading, tonemap), a key light, the shader
## globals for the toon material, the screen-space outline pass, optional depth of field, ambient particles, and converts every mesh (including ones added later)
## to the toon material. Reacts to `Settings.graphics_changed`. One rig per scene: `StyleRig.install(self, StylePresets.TOWN, camera, player)`.

const OUTLINE_SHADER: String = "res://assets/shaders/style_outline.gdshader"
## Medium: depth edges only (no normal buffer, about 1.4 ms less on the development iGPU); High adds the normal creases.
const OUTLINE_SHADER_DEPTH: String = "res://assets/shaders/style_outline_depth.gdshader"
const SKY_SHADER: String = "res://assets/shaders/style_sky.gdshader"
## Tier 2: a preset whose sun is this dim or dimmer is a night scene (the forest camp's moon is 0.42; every daylight zone is 0.66 or more), where the
## nearest lanterns may cast shadows.
const NIGHT_SUN_ENERGY: float = 0.5
## Fixes Oct 26, Part 1: the farthest view depth (m) of each walkable area's game camera - Far zoom (Settings.ZOOM_MAX), every angle preset, ten hero
## spots - from `tools/shadow_reach_probe.gd` (docs/perf/runs/shadow_reach_*.txt), plus 8 m. The sun's shadow reaches this far on Medium and High so
## the top of the screen keeps its shadows. Keys are style preset ids; "capital" covers every Capital state.
const SHADOW_REACH: Dictionary = {
	&"town": 131.0, &"start": 64.0, &"gainlands": 161.0, &"buffet": 122.0, &"dna": 103.0, &"heap": 176.0, &"capital": 190.0,
}
## Where the near cascade ends (m): the hero, the people round them and the ground to mid-screen stay as crisp as the old 26 m single map.
const SHADOW_NEAR_SPLIT: float = 34.0

## Emitted at the end of every `apply()` (a fresh Environment exists): the world look rig re-applies its sky, bloom and fog on top.
signal applied

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
## A hand-tuned preset used instead of the one named by `preset_id` (the dungeon stages build theirs from their own colours).
var preset_override: ZonePreset
## The painted-texture preset (data/art/texture_presets.json) when it differs from the style preset (the dungeon stages share one style preset; only the castle is painted).
var painted_id: StringName = &""

var _scene_root: Node
var _pending: Array[Node] = []
var _flush_queued: bool = false


static func install(scene: Node, id: StringName, camera_node: Camera3D, follow_target: Node3D = null, cull: float = 0.0, preset_override: ZonePreset = null, painted_id: StringName = &"") -> StyleRig:
	if OS.get_environment("NO_STYLE") != "":
		return null
	# Overnight Oct 23 (memory): the previous scene's toon and clump materials are gone by now; drop their dead cache entries.
	StyleToon.prune()
	KitFoliage.prune()
	ZoneStyles.use_preset(id)
	var rig: StyleRig = StyleRig.new()
	rig.name = "StyleRig"
	rig.preset_id = id
	rig.camera = camera_node
	rig.follow = follow_target
	rig.cull_distance = cull
	rig.preset_override = preset_override
	rig.painted_id = painted_id
	scene.add_child(rig)
	return rig


func quality() -> int:
	var forced: String = OS.get_environment("STYLE_QUALITY")
	if forced != "":
		return clampi(int(forced), 0, 2)
	return quality_override if quality_override >= 0 else Settings.graphics_quality


func _ready() -> void:
	_scene_root = get_parent()
	GroundLight.clear_globals()  # a new scene starts open; its WorldLookRig bakes a map when the scene has loaded
	preset = preset_override if preset_override != null else StylePresets.get_preset(preset_id)
	PaintedClasses.begin_zone(painted_id if painted_id != &"" else preset_id)
	_remove_old_environment()
	world_env = WorldEnvironment.new()
	world_env.name = "StyleEnvironment"
	add_child(world_env)
	sun = DirectionalLight3D.new()
	sun.name = "StyleSun"
	sun.add_to_group(&"style_sun")
	add_child(sun)
	fill = DirectionalLight3D.new()
	fill.name = "StyleFill"
	add_child(fill)
	_build_outline()
	_build_ambience()
	LoadTiming.detail("style: outline + ambience")
	apply()
	LoadTiming.detail("style: apply")
	StyleToon.apply(_scene_root, preset.wind)
	LoadTiming.detail("style: toon conversion")
	for node: Node in _scene_root.find_children("*", "MeshInstance3D", true, false):
		if cull_distance > 0.0:
			_limit_range(node as MeshInstance3D)
		_track_small_caster(node as MeshInstance3D)
	LoadTiming.detail("style: ranges")
	if camera != null and follow != null:
		var occlusion: OcclusionFader = OcclusionFader.new()
		occlusion.name = "OcclusionFader"
		occlusion.camera = camera
		occlusion.hero = follow
		occlusion.root = _scene_root
		add_child(occlusion)
	if OS.is_debug_build():
		var watcher: ZoneStyleWatcher = ZoneStyleWatcher.new()
		watcher.name = "ZoneStyleWatcher"
		watcher.style_rig = self
		add_child(watcher)
	var label_fader: StyleLabelFader = StyleLabelFader.new()
	label_fader.name = "StyleLabelFader"
	label_fader.root = _scene_root
	label_fader.hero = follow
	add_child(label_fader)
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
	RenderingServer.directional_shadow_atlas_set_size(GraphicsQuality.sun_shadow_atlas(level), true)
	RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_LOW if level < GraphicsQuality.Level.HIGH else RenderingServer.ENV_SSAO_QUALITY_MEDIUM, true, 0.5, 2, 50, 300)
	RenderingServer.directional_soft_shadow_filter_set_quality(GraphicsQuality.shadow_filter(level) as RenderingServer.ShadowQuality)
	if OS.get_environment("STYLE_DEBUG") != "":
		print("style_rig: level %d msaa %d scale %.2f aa %d" % [level, get_viewport().msaa_3d, get_viewport().scaling_3d_scale, get_viewport().screen_space_aa])
	_apply_environment(level)
	_apply_lights(level)
	if outline != null:
		outline.visible = GraphicsQuality.outlines(level)
		var material: ShaderMaterial = outline.material_override as ShaderMaterial
		var wanted: Shader = load(OUTLINE_SHADER if GraphicsQuality.outline_normals(level) else OUTLINE_SHADER_DEPTH) as Shader
		if material.shader != wanted:
			material.shader = wanted
		material.set_shader_parameter("line_color", preset.outline_color)
		material.set_shader_parameter("strength", preset.outline_strength)
	_apply_dof(level)
	if ambience != null:
		ambience.configure(preset, level)
	applied.emit()


func _apply_globals() -> void:
	RenderingServer.global_shader_parameter_set("style_rim_color", preset.rim_color)
	RenderingServer.global_shader_parameter_set("style_highlight", preset.highlight)
	RenderingServer.global_shader_parameter_set("style_desaturate", preset.desaturate)
	RenderingServer.global_shader_parameter_set("style_accent", preset.accent)
	RenderingServer.global_shader_parameter_set("style_wind", preset.wind)
	RenderingServer.global_shader_parameter_set("style_ground_sat", preset.ground_sat)
	# Tier 1: the ground light map's shade leans towards the zone's ambient (the coloured shadow), never black.
	RenderingServer.global_shader_parameter_set("style_ground_light_tint", preset.ambient_color.lerp(Color.WHITE, 0.3))
	# Tier 2: the map's bounce-colour channel (zone style `light.bounce`).
	RenderingServer.global_shader_parameter_set("style_ground_bounce", preset.ground_bounce)


func _apply_environment(level: int) -> void:
	var env: Environment = Environment.new()
	if preset.use_sky:
		var sky_material: ShaderMaterial = ShaderMaterial.new()
		sky_material.shader = load(SKY_SHADER) as Shader
		var cloud: Color = preset.cloud_color if preset.cloud_color.a > 0.0 else preset.sky_horizon.lerp(Color.WHITE, 0.6)
		sky_material.set_shader_parameter("top_color", preset.sky_top)
		sky_material.set_shader_parameter("horizon_color", preset.sky_horizon)
		sky_material.set_shader_parameter("bottom_color", preset.ground_bottom.lerp(preset.sky_top, 0.35))
		sky_material.set_shader_parameter("cloud_color", cloud)
		sky_material.set_shader_parameter("cloud_shade", preset.ambient_color.lerp(preset.sky_top, 0.4))
		sky_material.set_shader_parameter("cloud_cover", preset.cloud_cover)
		sky_material.set_shader_parameter("haze", preset.sky_haze)
		sky_material.set_shader_parameter("star_amount", preset.star_amount)
		sky_material.set_shader_parameter("sun_color", preset.sun_color)
		var sky: Sky = Sky.new()
		sky.sky_material = sky_material
		sky.radiance_size = Sky.RADIANCE_SIZE_32
		sky.process_mode = Sky.PROCESS_MODE_INCREMENTAL
		env.background_mode = Environment.BG_SKY
		env.sky = sky
	else:
		env.background_mode = Environment.BG_COLOR
		env.background_color = preset.background_color
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = preset.ambient_color
	env.ambient_light_energy = preset.ambient_energy
	env.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	# `STYLE_TONEMAP=agx|aces|filmic` overrides every zone for A/B shots (tools only).
	var tonemap: String = OS.get_environment("STYLE_TONEMAP") if OS.get_environment("STYLE_TONEMAP") != "" else preset.tonemap
	match tonemap:
		"agx":
			env.tonemap_mode = Environment.TONE_MAPPER_AGX
		"filmic":
			env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
		"aces":
			env.tonemap_mode = Environment.TONE_MAPPER_ACES
		_:
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
	env.fog_sky_affect = preset.fog_sky_affect * (0.25 if preset.use_sky else 1.0)  # the sky shader paints its own haze
	if GraphicsQuality.volumetric_fog(level) and preset.volumetric_density > 0.0:
		env.volumetric_fog_enabled = true
		env.volumetric_fog_density = preset.volumetric_density * 0.5  # sparse shafts, never a broad haze
		env.volumetric_fog_anisotropy = 0.3
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
	# Soft, tinted shadows: translucent so the coloured ambient shows through (never a black cut-out), blurred edges.
	sun.shadow_blur = GraphicsQuality.shadow_blur(level)
	sun.shadow_opacity = preset.shadow_opacity
	sun.shadow_normal_bias = 1.6
	sun.shadow_bias = 0.06
	var reach: float = GraphicsQuality.sun_shadow_reach(level, area_shadow_reach())
	var splits: int = GraphicsQuality.sun_shadow_splits(level, reach)
	# A/B knob for frame-time work (tools/fps.sh): SHADOW_AB=reach:120,splits:1,atlas:1024 overrides the computed values.
	for pair: String in OS.get_environment("SHADOW_AB").split(",", false):
		var kv: PackedStringArray = pair.split(":")
		if kv.size() == 2 and kv[0] == "reach":
			reach = float(kv[1])
		elif kv.size() == 2 and kv[0] == "splits":
			splits = int(kv[1])
		elif kv.size() == 2 and kv[0] == "atlas":
			RenderingServer.directional_shadow_atlas_set_size(int(kv[1]), true)
	sun.directional_shadow_max_distance = reach
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL if splits == 1 else (DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS if splits == 2 else DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS)
	if splits == 2:
		sun.directional_shadow_split_1 = clampf(SHADOW_NEAR_SPLIT / reach, 0.1, 0.6)
	elif splits == 4:
		sun.directional_shadow_split_1 = clampf(SHADOW_NEAR_SPLIT * 0.5 / reach, 0.05, 0.3)
		sun.directional_shadow_split_2 = clampf(SHADOW_NEAR_SPLIT / reach, sun.directional_shadow_split_1 + 0.02, 0.5)
		sun.directional_shadow_split_3 = clampf(0.45, sun.directional_shadow_split_2 + 0.02, 0.8)
	# The long reach fades over its last few percent only (the default 0.8 would fade the top of the screen again).
	sun.directional_shadow_fade_start = 0.94 if reach > 48.0 else 0.8
	if sun_cull_mask_hint != 0:
		sun.light_cull_mask = sun_cull_mask_hint
	# A faint cool fill from the opposite side keeps the shadow side coloured, never flat.
	fill.light_color = preset.ambient_color.lerp(Color.WHITE, 0.25)
	fill.light_energy = 0.18
	fill.rotation_degrees = Vector3(-28.0, preset.sun_yaw + 150.0, 0.0)
	fill.shadow_enabled = false
	fill.light_cull_mask = sun.light_cull_mask


## This scene's measured shadow reach (`SHADOW_REACH`), 0 when it has none (battle and dungeon backdrops keep the old reach).
func area_shadow_reach() -> float:
	if SHADOW_REACH.has(preset_id):
		return float(SHADOW_REACH[preset_id])
	if str(preset_id).begins_with("capital"):
		return float(SHADOW_REACH[&"capital"])
	return 0.0


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
	# Phase 2 (stability): the depth-only outline unless the normals one is wanted - it only compiles on Forward+ (the Compatibility renderer
	# logged a shader error on every area build).
	material.shader = load(OUTLINE_SHADER if GraphicsQuality.outline_normals(quality()) else OUTLINE_SHADER_DEPTH) as Shader
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
	if false and Settings.depth_of_field and GraphicsQuality.dof_allowed(level):  # replaced by the tilt-shift pass (WorldLookRig)
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
			_track_small_caster(node as MeshInstance3D)
	_pending.clear()


# ---- Small shadow casters beyond the near cascade (Fixes Oct 26, Part 1) ---------------------------------------------------------
# With the long shadow reach the far cascade re-drew every small piece in view (the Capital inside: 130 small kit pieces and ~40 rigged
# knights and mages, ten meshes each: +300 draw calls). Beyond the near cascade a crate, a lamp or a person is a few pixels tall: small
# casters (rigged characters and anything under SMALL_CASTER m across) stop casting the sun's shadow there (characters keep their contact
# shadow) while the ground, buildings, walls and trees keep theirs to the top of the screen. Checked a slice per frame, round robin.

const SMALL_CASTER: float = 2.5
const SHADOW_SWITCH_PER_FRAME: int = 300
const FLAT_GROUND_THICKNESS: float = 0.05
const FLAT_GROUND_TOP: float = 0.2

var _far_casters: Array[MeshInstance3D] = []
var _far_cursor: int = 0


## A rigged character's mesh (skinned, or held by a bone) or a small mesh that casts a normal shadow joins the distance switch. A flat ground
## plane (no thickness, at or below the ground line, wider than 8 m: the Capital's wasteland and meadow, the Dump's far ground) never casts:
## it cannot shade anything above it, and with the long reach it filled the whole far cascade (~0.5 ms on Medium in the Capital).
func _track_small_caster(mesh: MeshInstance3D) -> void:
	if mesh == null or mesh.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_ON or mesh.has_meta(&"shadow_far_off") or mesh.mesh == null:
		return
	var box: AABB = mesh.global_transform * mesh.get_aabb()
	if box.size.y < FLAT_GROUND_THICKNESS and box.end.y <= FLAT_GROUND_TOP and maxf(box.size.x, box.size.z) > 8.0:
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		return
	var parent: Node = mesh.get_parent()
	var rigged: bool = mesh.skin != null or parent is Skeleton3D or parent is BoneAttachment3D
	if not rigged and box.size.length() >= SMALL_CASTER:
		return
	mesh.set_meta(&"shadow_far_off", true)
	_far_casters.append(mesh)


func _update_small_casters() -> void:
	if camera == null or _far_casters.is_empty():
		return
	var limit: float = SHADOW_NEAR_SPLIT + 6.0 if sun != null and sun.directional_shadow_max_distance > 48.0 else INF
	var eye: Vector3 = camera.global_position
	var count: int = mini(SHADOW_SWITCH_PER_FRAME, _far_casters.size())
	var index: int = 0
	while index < count and not _far_casters.is_empty():
		if _far_cursor >= _far_casters.size():
			_far_cursor = 0
		var mesh: MeshInstance3D = _far_casters[_far_cursor]
		if not is_instance_valid(mesh):
			_far_casters.remove_at(_far_cursor)
			continue
		var wanted: GeometryInstance3D.ShadowCastingSetting = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if mesh.global_position.distance_to(eye) <= limit else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		if mesh.cast_shadow != wanted:
			mesh.cast_shadow = wanted
		_far_cursor += 1
		index += 1


func _limit_range(mesh_instance: MeshInstance3D) -> void:
	if cull_distance > 0.0 and mesh_instance.get_parent() != camera and not mesh_instance.has_meta(&"no_range_cull"):
		mesh_instance.visibility_range_end = cull_distance * GraphicsQuality.cull_scale(quality())
		# The far edge dissolves instead of popping (a dithered fade over the last few metres).
		mesh_instance.visibility_range_end_margin = 6.0
		mesh_instance.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF


# ---- Light budget: only the nearest dressing lights stay on (the glow decals keep the pools visible) ---------------------------------


var _budget_lights: Array[OmniLight3D] = []
var _budget_timer: float = 0.0


func register_lights(lights: Array[OmniLight3D]) -> void:
	_budget_lights.append_array(lights)
	_update_light_budget()


func _process(delta: float) -> void:
	RenderingServer.global_shader_parameter_set("style_player_pos", follow.global_position if follow != null else Vector3(0.0, -1000.0, 0.0))
	_budget_timer -= delta
	if _budget_timer <= 0.0:
		_budget_timer = 0.3
		_update_light_budget()
	_update_small_casters()


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
	# Tier 2: in a night scene (a dim sun: the forest camp's moon) the nearest lantern or two cast real shadows; by day the sun's shadows own the scene.
	var shadows: int = GraphicsQuality.lantern_shadows(quality()) if preset != null and preset.sun_energy <= NIGHT_SUN_ENERGY else 0
	for index: int in range(live.size()):
		live[index].visible = index < budget
		var casts: bool = index < shadows
		if live[index].shadow_enabled != casts:
			live[index].shadow_enabled = casts
			if casts:
				live[index].shadow_blur = 1.5
				live[index].shadow_bias = 0.08
				live[index].shadow_normal_bias = 1.4
