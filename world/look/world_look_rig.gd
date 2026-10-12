class_name WorldLookRig
extends Node
## The game's world look (docs/art/world_look_test.md, docs/art/world_rollout.md): the approved low cinematic camera, the tilt-shift / grade / vignette post pass, bloom and fog,
## and (from the zone's mood in data/art/zone_looks.json) the painted sky, distant scenery, water, foliage and ambient life. One rig per overworld scene:
## `WorldLookRig.install(self, _camera, player, style_rig, walkable_area)` after the `StyleRig` exists.
##
## The camera: scenes keep computing `camera.position = hero + camera_offset * zoom` as before (their `camera_offset` is `WorldLookRig.base_offset()` now); this rig runs after the
## scene each frame and aims the camera with the look's height offset (the hero stands in the lower third). Buildings and tall props between the camera and the hero (or round
## the camera) are cut away by the style rig's `OcclusionFader`.
## Values: `data/art/world_look_my_preset.json` when it exists (the tuning panel of the World Look Test writes it), else the approved F5 values (`LookParams`).

const MOODS_PATH: String = "res://data/art/zone_looks.json"
const POST_SHADER: String = "res://world/look/world_post.gdshader"
const FALLBACK_MOOD: StringName = &"town"

static var _moods: Dictionary = {}
static var _base: Dictionary = {}

var camera: Camera3D
var follow: Node3D
var style_rig: StyleRig
var area: WalkableArea
var scene: Node3D
var mood_id: StringName = FALLBACK_MOOD
var mood: Dictionary = {}
var values: Dictionary = {}
## Built pieces (null when a mood leaves them out).
var sky: WorldSky
var scenery: WorldScenery
var foliage: WorldFoliage
var ambient: WorldAmbient
var post_rect: ColorRect

var _post_material: ShaderMaterial
var _layer: CanvasLayer
var _env: Environment
var _sun_travel: Vector3 = Vector3(0.42, -0.62, -0.67)
var _pieces: Node3D
var _look_hash: int = 0
var _blend: Dictionary = {}


# ---- Data --------------------------------------------------------------------------------------------------------------------------


## The look values every area shares: the saved "My Preset" when there is one, else the approved F5 numbers.
static func game_values() -> Dictionary:
	if _base.is_empty():
		var mine: Dictionary = LookParams.load_my_preset()
		_base = mine if not mine.is_empty() else LookParams.recommended()
	return _base


static func clear_cache() -> void:
	_moods = {}
	_base = {}


## The camera offset from the hero before the zoom: the look's pitch and distance.
static func base_offset() -> Vector3:
	var p: Dictionary = game_values()
	var pitch: float = deg_to_rad(float(p["pitch"]))
	return Vector3(0.0, sin(pitch), cos(pitch)) * float(p["distance"])


## A pulled-back offset for story moments (a bounce, a flight): a steeper view from farther away, so more of the ground shows.
static func wide_offset(distance_scale: float, extra_pitch_degrees: float = 14.0) -> Vector3:
	var p: Dictionary = game_values()
	var pitch: float = deg_to_rad(float(p["pitch"]) + extra_pitch_degrees)
	return Vector3(0.0, sin(pitch), cos(pitch)) * float(p["distance"]) * distance_scale


static func all_moods() -> Dictionary:
	if _moods.is_empty():
		var file: FileAccess = FileAccess.open(MOODS_PATH, FileAccess.READ)
		if file != null:
			var parsed: Variant = JSON.parse_string(file.get_as_text())
			if parsed is Dictionary:
				_moods = parsed as Dictionary
	return _moods


## The mood of a style preset id (StylePresets): the town's entries with the zone's own on top; an unknown id gets the town's.
static func mood_for(id: StringName) -> Dictionary:
	var moods: Dictionary = all_moods()
	var result: Dictionary
	if id == FALLBACK_MOOD or not moods.has(str(id)):
		return (moods.get(str(FALLBACK_MOOD), {}) as Dictionary).duplicate(true)
	var entry: Dictionary = moods[str(id)] as Dictionary
	# "extends": another mood this one is a variant of (capital_dark is capital_outskirts with its own numbers on top).
	result = mood_for(StringName(str(entry["extends"]))) if entry.has("extends") else (moods.get(str(FALLBACK_MOOD), {}) as Dictionary).duplicate(true)
	_merge(result, entry)
	return result


static func _merge(into: Dictionary, over: Dictionary) -> void:
	for key: Variant in over.keys():
		if over[key] is Dictionary and into.get(key) is Dictionary:
			_merge(into[key] as Dictionary, over[key] as Dictionary)
		else:
			into[key] = over[key]


## The look parameters (camera + post + bloom + fog) of a mood: the shared base with the mood's `look` block on top.
static func values_for(mood_dict: Dictionary) -> Dictionary:
	var result: Dictionary = game_values().duplicate()
	var over: Dictionary = mood_dict.get("look", {}) as Dictionary
	for key: Variant in over.keys():
		result[key] = over[key]
	return result


# ---- Install -----------------------------------------------------------------------------------------------------------------------


static func install(owner_scene: Node3D, cam: Camera3D, hero: Node3D, rig: StyleRig, walkable: WalkableArea, build_world: bool = true) -> WorldLookRig:
	var look: WorldLookRig = WorldLookRig.new()
	look.name = "WorldLookRig"
	look.scene = owner_scene
	look.camera = cam
	look.follow = hero
	look.style_rig = rig
	look.area = walkable
	look.mood_id = rig.preset_id if rig != null else FALLBACK_MOOD
	look._build_world = build_world
	owner_scene.add_child(look)
	return look


var _build_world: bool = true


func _ready() -> void:
	mood = mood_for(mood_id)
	values = values_for(mood)
	_blend = values.duplicate()
	if style_rig != null and style_rig.sun != null:
		_sun_travel = -style_rig.sun.global_basis.z
	_build_post()
	if _build_world and bool(mood.get("world", true)):
		_build_pieces()
	if style_rig != null:
		style_rig.applied.connect(_on_style_applied)
		_env = style_rig.world_env.environment if style_rig.world_env != null else null
	Settings.graphics_changed.connect(_on_settings_changed)
	_apply(true)
	# Tools: LOOK_OFF=post,sky,scenery,foliage,ambient switches pieces off (frame-time A/B runs, screenshots).
	for token: String in OS.get_environment("LOOK_OFF").split(",", false):
		set_feature(token, false)


func _exit_tree() -> void:
	if Settings.graphics_changed.is_connected(_on_settings_changed):
		Settings.graphics_changed.disconnect(_on_settings_changed)


## Another style preset (the Capital changing state): the mood changes with it, blending over a moment.
func set_mood(id: StringName) -> void:
	if id == mood_id:
		return
	mood_id = id
	mood = mood_for(id)
	values = values_for(mood)
	if sky != null:
		sky.set_palette(mood.get("sky", {}) as Dictionary)
	if scenery != null:
		scenery.set_mood(mood.get("scenery", {}) as Dictionary)
	if foliage != null:
		foliage.visible = float((mood.get("foliage", {}) as Dictionary).get("density", 1.0)) > 0.0
	_apply(false)


func _on_style_applied() -> void:
	_env = style_rig.world_env.environment if style_rig != null and style_rig.world_env != null else null
	if _env != null and sky != null and bool((mood.get("sky", {}) as Dictionary).get("enabled", true)):
		sky.attach(_env)
	_look_hash = 0
	_apply(true)


func _on_settings_changed() -> void:
	_look_hash = 0
	_apply(true)


# ---- Pieces ------------------------------------------------------------------------------------------------------------------------


func _build_post() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = -5
	_layer.name = "LookPost"
	add_child(_layer)
	post_rect = ColorRect.new()
	post_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	post_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_post_material = ShaderMaterial.new()
	_post_material.shader = load(POST_SHADER) as Shader
	post_rect.material = _post_material
	_layer.add_child(post_rect)


func _build_pieces() -> void:
	_pieces = Node3D.new()
	_pieces.name = "LookPieces"
	scene.add_child(_pieces)
	var bounds: Rect2 = area.map_bounds() if area != null else Rect2(-20.0, -20.0, 40.0, 40.0)
	var middle: Vector3 = Vector3(bounds.get_center().x, 0.0, bounds.get_center().y)
	var sky_mood: Dictionary = mood.get("sky", {}) as Dictionary
	if bool(sky_mood.get("enabled", true)):
		sky = WorldSky.new()
		sky.name = "WorldSky"
		sky.center = middle
		_pieces.add_child(sky)
		sky.setup(camera, _env_or_null(), _sun_travel)
		sky.set_palette(sky_mood)
	var scenery_mood: Dictionary = mood.get("scenery", {}) as Dictionary
	if bool(scenery_mood.get("enabled", true)):
		scenery = WorldScenery.new()
		scenery.name = "WorldScenery"
		_pieces.add_child(scenery)
		if scene is TownScene:
			scenery.setup(scene as TownScene, (scene as TownScene).town, camera)
		else:
			scenery.setup_generic(middle, bounds, camera, scenery_mood)
		scenery.set_mood(scenery_mood)
	var foliage_mood: Dictionary = mood.get("foliage", {}) as Dictionary
	if float(foliage_mood.get("density", 1.0)) > 0.0 and area != null:
		foliage = WorldFoliage.new()
		foliage.name = "WorldFoliage"
		_pieces.add_child(foliage)
		if scene is TownScene:
			var town_scene: TownScene = scene as TownScene
			foliage.setup(town_scene.town, town_scene.square, camera, _sun_travel)
		else:
			foliage.setup_area(area, scene, foliage_mood)
		foliage.set_tint(Color.html(str(foliage_mood.get("tint", "ffffff"))))
		if style_rig != null and style_rig.preset != null:
			foliage.set_light(style_rig.preset.sun_color, style_rig.preset.ambient_color)
	var ambient_mood: Dictionary = mood.get("ambient", {}) as Dictionary
	if bool(ambient_mood.get("enabled", true)):
		ambient = WorldAmbient.new()
		ambient.name = "WorldAmbient"
		_pieces.add_child(ambient)
		ambient.setup_area(camera, follow, _sun_travel, ambient_mood)
		_silence_old_ambience()
	_mark_no_cull(_pieces)


func _env_or_null() -> Environment:
	if style_rig != null and style_rig.world_env != null:
		return style_rig.world_env.environment
	return null


## The style rig's own particles (fireflies, big motes) turn into big white balls under the low camera and the bloom: the ambient life of the look replaces them.
func _silence_old_ambience() -> void:
	if style_rig == null or style_rig.ambience == null:
		return
	for child: Node in style_rig.ambience.get_children():
		if child is GPUParticles3D:
			(child as GPUParticles3D).visible = false
			(child as GPUParticles3D).emitting = false


func _mark_no_cull(root: Node) -> void:
	for node: Node in root.find_children("*", "MeshInstance3D", true, false):
		node.set_meta(&"no_range_cull", true)
		node.set_meta(&"no_occlusion_fade", true)


# ---- Per frame ---------------------------------------------------------------------------------------------------------------------


func _process(delta: float) -> void:
	if camera == null or follow == null:
		return
	_blend_values(delta)
	_apply(false)
	var offset: Vector3 = camera.global_position - follow.global_position
	if offset.length() > 0.01:
		var look_basis: Basis = Basis.looking_at(-offset.normalized(), Vector3.UP)
		var tilt: float = atan2(float(_blend["height"]), float(_blend["distance"]))
		camera.global_basis = look_basis.rotated(look_basis.x, tilt)
	camera.fov = float(_blend["fov"])
	if sky != null:
		sky.tick(delta)
	if ambient != null:
		ambient.tick(delta)


func _blend_values(delta: float) -> void:
	var k: float = 1.0 - exp(-4.0 * delta)
	for key: Variant in values.keys():
		var target: Variant = values[key]
		if target is float or target is int:
			var now: float = lerpf(float(_blend.get(key, target)), float(target), k)
			_blend[key] = float(target) if absf(now - float(target)) < 0.0004 else now
		elif str(key) == "fog_color":
			_blend[key] = Color.html(str(_blend.get(key, target))).lerp(Color.html(str(target)), k).to_html(false)
		else:
			_blend[key] = target


## Pushes the blended look to the post pass, the environment, the sky and the scenery; only when something changed (touching the sky material every frame would redraw
## the sky's reflection cube every frame).
func _apply(force: bool) -> void:
	var p: Dictionary = _blend
	if p.is_empty():
		return
	var level: int = style_rig.quality() if style_rig != null else Settings.graphics_quality
	var blur_on: bool = Settings.depth_of_field and GraphicsQuality.dof_allowed(level)
	var bloom_on: bool = Settings.bloom and GraphicsQuality.glow(level)
	var fog_scale: float = [0.0, 0.5, 1.0][clampi(Settings.fog_quality, 0, 2)]
	var look_hash: int = hash([p.hash(), blur_on, bloom_on, fog_scale, level])
	if look_hash == _look_hash and not force:
		return
	_look_hash = look_hash
	if _post_material != null:
		_post_material.set_shader_parameter("focus_y", float(p["focus"]))
		_post_material.set_shader_parameter("band", float(p["band"]))
		_post_material.set_shader_parameter("blur_far", float(p["blur_far"]) if blur_on else 0.0)
		_post_material.set_shader_parameter("blur_near", float(p["blur_near"]) if blur_on else 0.0)
		_post_material.set_shader_parameter("warmth", float(p["warmth"]))
		_post_material.set_shader_parameter("saturation", float(p["saturation"]))
		_post_material.set_shader_parameter("vignette", float(p["vignette"]))
	if _env != null:
		var bloom: float = float(p["bloom"])
		_env.glow_enabled = bloom_on and bloom > 0.01
		if _env.glow_enabled:
			_env.glow_intensity = bloom
			_env.glow_strength = 1.0
			_env.glow_bloom = 0.0
			_env.glow_hdr_threshold = float(p["bloom_threshold"])
			_env.glow_hdr_scale = 1.6
			# Very bright small things (lamp glows, motes) would bloom into big white balls: cap how bright the glow source may be.
			_env.glow_hdr_luminance_cap = 2.0
			_env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SCREEN
			var centre: float = float(p["glow_spread"]) * 5.0 + 0.5
			for glow_level: int in range(0, 7):
				_env.set_glow_level(glow_level, clampf(1.0 - absf(float(glow_level) - centre) * 0.5, 0.0, 1.0))
		_env.fog_enabled = fog_scale > 0.0
		_env.fog_density = float(p["fog_density"]) * fog_scale
		_env.fog_light_color = Color.html(str(p["fog_color"]))
		_env.fog_sky_affect = 0.0
		if _env.background_mode == Environment.BG_COLOR:
			_env.background_color = Color.html(str(p["fog_color"]))
		if fog_scale <= 0.0 or Settings.fog_quality < 2:
			_env.volumetric_fog_enabled = false
	var fog_color: Color = Color.html(str(p["fog_color"]))
	if sky != null:
		sky.set_cloud_speed(float(p["cloud_speed"]))
		sky.set_haze_color(fog_color)
	if scenery != null:
		scenery.set_haze_color(fog_color)


## Everything the rig owns is switched on or off (screenshot and perf tools, tests).
func set_feature(token: String, enabled: bool) -> void:
	match token:
		"post":
			post_rect.visible = enabled
		"sky":
			if sky != null:
				sky.visible = enabled
		"scenery":
			if scenery != null:
				scenery.visible = enabled
		"foliage":
			if foliage != null:
				foliage.visible = enabled
		"ambient":
			if ambient != null:
				ambient.visible = enabled
