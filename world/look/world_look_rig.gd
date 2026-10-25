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
## Tier 1: the zone's baked-look ground light map and its fog / god-ray cards (docs/art/graphics_tier1.md).
var ground_light: GroundLight
var haze: HazeCards

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
	var mood: Dictionary = _mood_base(id)
	var style_look: Dictionary = ZoneStyles.look_overrides(id)
	if not style_look.is_empty():
		var look_block: Dictionary = (mood.get("look", {}) as Dictionary)
		mood["look"] = look_block
		_merge(look_block, style_look)
	return mood


static func _mood_base(id: StringName) -> Dictionary:
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
	CameraRig.active_rigs += 1
	CameraRig.reset_swivel()
	mood = mood_for(mood_id)
	values = values_for(mood)
	_blend = values.duplicate()
	_blend.merge(CameraRig.adjust(values), true)
	if style_rig != null and style_rig.sun != null:
		_sun_travel = -style_rig.sun.global_basis.z
	_build_post()
	LoadTiming.detail("look: post")
	ground_light = GroundLight.install(scene, _piece_bounds(), style_rig)
	LoadTiming.detail("look: ground light")
	if style_rig != null and style_rig.preset != null:
		KitFoliage.set_light(style_rig.preset.sun_color, style_rig.preset.ambient_color)
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
	CameraRig.active_rigs = maxi(0, CameraRig.active_rigs - 1)
	CameraRig.reset_swivel()
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
	_rebuild_haze()
	if ground_light != null:
		ground_light.rebake()


## A style file changed on disk (debug hot reload): re-read the mood and let the blend carry the new numbers in.
func refresh_style() -> void:
	mood = mood_for(mood_id)
	values = values_for(mood)
	if style_rig != null and style_rig.preset != null:
		KitFoliage.set_light(style_rig.preset.sun_color, style_rig.preset.ambient_color)
	_look_hash = 0
	_apply(true)


func _on_style_applied() -> void:
	_env = style_rig.world_env.environment if style_rig != null and style_rig.world_env != null else null
	if _env != null and sky != null and bool((mood.get("sky", {}) as Dictionary).get("enabled", true)):
		sky.attach(_env)
	_look_hash = 0
	_apply(true)


func _on_settings_changed() -> void:
	_look_hash = 0
	_apply(true)
	_rebuild_haze()


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
	for step: Callable in _piece_steps():
		step.call()
		LoadTiming.detail("look: %s" % step.get_method())
	_mark_no_cull(_pieces)


## v0.4.2 hotfix: the same pieces (sky, scenery, foliage, ambient), one per frame - `stage` (a coroutine taking a label) is awaited after each -
## for a scene built in stages behind the loading screen. Install with `build_world = false`, then await this.
func build_pieces_staged(stage: Callable) -> void:
	if not bool(mood.get("world", true)):
		return
	var labels: Array[String] = ["sky", "scenery", "foliage", "ambient", "haze"]
	var index: int = 0
	for step: Callable in _piece_steps():
		step.call()
		await stage.call("look rig: %s" % labels[mini(index, labels.size() - 1)])
		index += 1
	_mark_no_cull(_pieces)
	_apply(true)


func _piece_steps() -> Array[Callable]:
	_pieces = Node3D.new()
	_pieces.name = "LookPieces"
	scene.add_child(_pieces)
	return [_build_sky, _build_scenery, _build_foliage, _build_ambient, _build_haze] as Array[Callable]


## Graphics Tier 1: low fog cards and god-ray cards from the mood's `haze` block (HazeCards; none on Low).
func _build_haze() -> void:
	var spec: Dictionary = mood.get("haze", {}) as Dictionary
	if spec.is_empty():
		return
	var level: int = style_rig.quality() if style_rig != null else Settings.graphics_quality
	var fog_color: Color = Color.html(str(values.get("fog_color", "f2cfa4")))
	var sun_color: Color = style_rig.preset.sun_color if style_rig != null and style_rig.preset != null else Color.WHITE
	haze = HazeCards.install(_pieces, spec, _sun_travel, fog_color, sun_color, level, _anchor_lookup)


## An anchor of the walkable area for the haze cards (`["spawn", dx, dz, ...]`): a zone builder's `anchor()`, a town's `anchors` dictionary.
func _anchor_lookup(anchor_name: String) -> Vector3:
	if area == null:
		return Vector3.ZERO
	if area.has_method("anchor"):
		return area.call("anchor", anchor_name) as Vector3
	var anchors: Variant = area.get("anchors")
	if anchors is Dictionary and (anchors as Dictionary).has(anchor_name):
		return (anchors as Dictionary)[anchor_name] as Vector3
	return Vector3.ZERO


func _rebuild_haze() -> void:
	if haze == null:
		return
	var level: int = style_rig.quality() if style_rig != null else Settings.graphics_quality
	var fog_color: Color = Color.html(str(values.get("fog_color", "f2cfa4")))
	var sun_color: Color = style_rig.preset.sun_color if style_rig != null and style_rig.preset != null else Color.WHITE
	haze.build(mood.get("haze", {}) as Dictionary, _sun_travel, fog_color, sun_color, GraphicsQuality.haze_cards(level))


func _piece_bounds() -> Rect2:
	return area.map_bounds() if area != null else Rect2(-20.0, -20.0, 40.0, 40.0)


func _build_sky() -> void:
	var bounds: Rect2 = _piece_bounds()
	var middle: Vector3 = Vector3(bounds.get_center().x, 0.0, bounds.get_center().y)
	var sky_mood: Dictionary = mood.get("sky", {}) as Dictionary
	if bool(sky_mood.get("enabled", true)):
		sky = WorldSky.new()
		sky.name = "WorldSky"
		sky.center = middle
		_pieces.add_child(sky)
		sky.setup(camera, _env_or_null(), _sun_travel)
		sky.set_palette(sky_mood)


func _build_scenery() -> void:
	var bounds: Rect2 = _piece_bounds()
	var middle: Vector3 = Vector3(bounds.get_center().x, 0.0, bounds.get_center().y)
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


func _build_foliage() -> void:
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


func _build_ambient() -> void:
	var ambient_mood: Dictionary = mood.get("ambient", {}) as Dictionary
	if bool(ambient_mood.get("enabled", true)):
		ambient = WorldAmbient.new()
		ambient.name = "WorldAmbient"
		_pieces.add_child(ambient)
		ambient.setup_area(camera, follow, _sun_travel, ambient_mood)
		_silence_old_ambience()


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
	CameraRig.read_input()
	CameraRig.tick(delta)
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
	var targets: Dictionary = values.duplicate()
	targets.merge(CameraRig.adjust(values), true)
	for key: Variant in targets.keys():
		var target: Variant = targets[key]
		if target is float or target is int:
			var now: float = lerpf(float(_blend.get(key, target)), float(target), k)
			_blend[key] = float(target) if absf(now - float(target)) < 0.0004 else now
		elif str(key) == "fog_color" or str(key).ends_with("_tint"):
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
		_post_material.set_shader_parameter("green_calm", float(p.get("green_calm", 0.0)))
		_post_material.set_shader_parameter("red_calm", float(p.get("red_calm", 0.0)))
		# Graphics Tier 1: the split tint and gamma of the zone's grade (zone style `grade.shadow_tint / highlight_tint / gamma / post_contrast`).
		_post_material.set_shader_parameter("shadow_tint", Color.html(str(p.get("shadow_tint", "ffffff"))))
		_post_material.set_shader_parameter("highlight_tint", Color.html(str(p.get("highlight_tint", "ffffff"))))
		_post_material.set_shader_parameter("gamma", float(p.get("gamma", 1.0)))
		_post_material.set_shader_parameter("contrast", float(p.get("contrast", 1.04)))
	if sky != null:
		sky.set_cloud_shadows(GraphicsQuality.cloud_shadows(level))
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
