class_name WorldLookTest
extends TownScene
## World Look Test (docs/art/world_look_test.md): a polished slice of the real main town in the chosen style - painted 2.5D character sprites, a low cinematic camera with
## tilt-shift and bloom, painted textures, a real sky, distant scenery rings and landmarks, painted water, foliage and ambient life. It IS the real town
## (`TownScene`, painted textures and all); nothing in the real game scenes changes and the save is never written.
##   F1 - F4 : the old character-test cameras   F5 : Recommended   F6 : My Preset (saved from the panel)
##   Tab     : live tuning panel      [ and ] : turn the camera view 30 degrees (to look towards each landmark)      mouse wheel : zoom
##   WASD / arrows walk, E talks to the nearest character.
## Launch: Godot --path . res://tests/world/world_look_test.tscn   (see tools/world_shots.sh for the automated screenshot and fps runs)

const SHOT_DIR: String = "res://docs/art/world_look/"
const SHOT_SIZE: Vector2i = Vector2i(1280, 720)
## Standing spots used by the screenshot set.
const SPOT_SQUARE: Vector3 = Vector3(26.8, 0.0, 15.2)
## NPC id (TownScene._npcs) -> sprite character.
const NPC_SPRITES: Dictionary = {"elder": "ELDER", "guard": "GATEKEEPER", "vendor": "SABLE", "item_vendor": "TONIC", "pack_vendor": "FENWICK"}
## An NPC turns to face the hero when closer than this (metres).
const NPC_NOTICE_RANGE: float = 4.2

var _args: Dictionary = {}
var _shot_mode: bool = false
var _params: Dictionary = {}
var _current: Dictionary = {}
var _preset_index: int = 5
var _yaw_steps: int = 0
var _yaw: float = 0.0
var _player_sprite: WorldSprite
var _npc_sprites: Dictionary = {}
var _talking_id: String = ""
var _villager: VillagerWalker
var _sun_direction: Vector3 = Vector3(0.42, -0.62, -0.67)
var _env: Environment
var _post_material: ShaderMaterial
var _post_rect: ColorRect
var _panel: TuningPanel
var _caption: Label
var _sky: WorldSky
var _scenery: WorldScenery
var _foliage: WorldFoliage
var _ambient: WorldAmbient
var _hold_dir: StringName = &""
var _look_hash: int = 0


func screenshot_prepare(args: Dictionary) -> void:
	_args = args
	super.screenshot_prepare(args)


func _ready() -> void:
	# Never touch the real save (the town saves at the end of _ready).
	Session.save_enabled = false
	Settings.camera_zoom = Settings.ZOOM_DEFAULT
	if _args.is_empty():
		for arg: String in OS.get_cmdline_user_args():
			if arg.begins_with("--"):
				var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
				_args[parts[0]] = parts[1] if parts.size() > 1 else "true"
		if _args.is_empty():
			_args = {"fresh": "true"}
	_args["nocull"] = "true"
	_screenshot_args = _args
	_shot_mode = _args.has("run")
	super._ready()
	player.model.visible = false
	_find_sun()
	_build_sprites()
	_build_world()
	for hidden_name: String in str(_args.get("hide", "")).split(",", false):
		var piece: Node = _scenery.get_node_or_null(hidden_name)
		if piece != null:
			(piece as Node3D).visible = false
	_build_post_and_ui()
	for token: String in str(_args.get("off", "")).split(",", false):
		match token:
			"post":
				_post_rect.visible = false
			"foliage":
				_foliage.visible = false
			"ambient":
				_ambient.visible = false
			"scenery":
				_scenery.visible = false
			"sky":
				_sky.visible = false
			"sprites":
				_player_sprite.visible = false
	player.position = _spot_from_args()
	_camera.position = player.position + camera_offset * Settings.camera_zoom
	_yaw_steps = int(_args.get("yaw", 0)) / 30
	_yaw = deg_to_rad(float(_yaw_steps) * 30.0)
	player.move_yaw = _yaw
	apply_preset(int(_args.get("preset", 5)), true)
	for slider: Dictionary in LookParams.SLIDERS:
		var key: String = str(slider["key"])
		if _args.has(key):
			_params[key] = float(_args[key])
			_current[key] = float(_args[key])
	if _args.has("zoom"):
		Settings.camera_zoom = float(_args["zoom"])
	if _shot_mode:
		_hide_hud()
		match str(_args["run"]):
			"shots":
				_run_shots.call_deferred()
			"one":
				_run_one.call_deferred()
			"perf":
				_run_perf.call_deferred()
			"roundtrip":
				_run_roundtrip.call_deferred()
			"perfab":
				_run_perfab.call_deferred()
			"probe":
				_run_probe.call_deferred()
			"probe2":
				_run_probe2.call_deferred()
			"walk":
				_run_walk.call_deferred()


func _spot_from_args() -> Vector3:
	if _args.has("pos"):
		var parts: PackedStringArray = str(_args["pos"]).split(",")
		return Vector3(float(parts[0]), 0.0, float(parts[1]))
	return SPOT_SQUARE


func _find_sun() -> void:
	if style_rig != null and style_rig.sun != null:
		_sun_direction = -style_rig.sun.global_basis.z
	if style_rig != null and style_rig.world_env != null:
		_env = style_rig.world_env.environment
	# The town's own ambient particles (fireflies, motes) become big white balls under the low camera and the bloom; WorldAmbient makes the pollen, leaves and birds instead.
	if style_rig != null and style_rig.ambience != null:
		for child: Node in style_rig.ambience.get_children():
			if child is GPUParticles3D:
				(child as GPUParticles3D).emitting = false
				(child as GPUParticles3D).visible = false


# ---- Characters --------------------------------------------------------------------------------------------------------------------


func _build_sprites() -> void:
	_player_sprite = WorldSprite.new()
	add_child(_player_sprite)
	_player_sprite.setup("PLAYER", _camera, _sun_direction)
	_player_sprite.snap_heading(Vector3(0.0, 0.0, 1.0))
	for id: String in NPC_SPRITES.keys():
		var npc: Node3D = _npcs.get(id) as Node3D
		if npc == null:
			continue
		npc.visible = false
		var sprite: WorldSprite = WorldSprite.new()
		add_child(sprite)
		sprite.setup(str(NPC_SPRITES[id]), _camera, _sun_direction)
		sprite.position = npc.position
		var heading: Vector3 = Vector3(sin(npc.rotation.y), 0.0, cos(npc.rotation.y))
		sprite.snap_heading(heading)
		sprite.set_meta("home_heading", heading)
		_npc_sprites[id] = sprite
	_villager = VillagerWalker.new()
	add_child(_villager)
	_villager.setup(town, square.center, _camera, _sun_direction)


func _face_npc(id: String) -> void:
	_talking_id = id
	super._face_npc(id)


func _update_sprites(delta: float) -> void:
	_player_sprite.follow(player.position, delta)
	# A direct press on a movement key turns the body at once (the 8-direction frame follows the camera-relative heading).
	for id: String in _npc_sprites.keys():
		var sprite: WorldSprite = _npc_sprites[id] as WorldSprite
		var npc: Node3D = _npcs[id] as Node3D
		var to_player: Vector3 = player.position - npc.position
		to_player.y = 0.0
		if id == _talking_id and dialogue.active:
			sprite.talking = true
			sprite.look_toward(to_player)
		else:
			sprite.talking = false
			if to_player.length() < NPC_NOTICE_RANGE:
				sprite.look_toward(to_player)
			else:
				sprite.look_toward(sprite.get_meta("home_heading") as Vector3)
		sprite.turn_rate_degrees = 260.0
		sprite.follow(npc.position, delta)
	if not dialogue.active:
		_talking_id = ""


# ---- World pieces ------------------------------------------------------------------------------------------------------------------


func _build_world() -> void:
	_sky = WorldSky.new()
	add_child(_sky)
	_sky.setup(_camera, _env, _sun_direction)
	_scenery = WorldScenery.new()
	add_child(_scenery)
	_scenery.setup(self, town, _camera)
	_foliage = WorldFoliage.new()
	add_child(_foliage)
	_foliage.setup(town, square, _camera, _sun_direction)
	if style_rig != null and style_rig.preset != null:
		_foliage.set_light(style_rig.preset.sun_color, style_rig.preset.ambient_color)
	_ambient = WorldAmbient.new()
	_ambient.shafts_enabled = _args.has("shafts")
	add_child(_ambient)
	_ambient.setup(self, town, _camera, player, _sun_direction)


func _build_post_and_ui() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = -5
	add_child(layer)
	_post_rect = ColorRect.new()
	_post_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_post_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_post_material = ShaderMaterial.new()
	_post_material.shader = load("res://tests/world/world_post.gdshader") as Shader
	_post_rect.material = _post_material
	layer.add_child(_post_rect)
	var info_layer: CanvasLayer = CanvasLayer.new()
	info_layer.layer = 9
	add_child(info_layer)
	_caption = Label.new()
	_caption.position = Vector2(14, 8)
	_caption.add_theme_font_size_override("font_size", 13)
	_caption.add_theme_color_override("font_color", Color(1, 1, 0.9))
	_caption.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_caption.add_theme_constant_override("outline_size", 5)
	_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_caption.visible = not _shot_mode
	info_layer.add_child(_caption)
	_panel = TuningPanel.new()
	_panel.position = Vector2(1160, 40)
	_panel.visible = false
	_panel.changed.connect(_on_panel_changed)
	_panel.save_pressed.connect(_save_my_preset)
	_panel.reset_pressed.connect(func() -> void: apply_preset(5))
	info_layer.add_child(_panel)
	_panel.visible = _args.has("panel")
	_place_panel.call_deferred()


func _place_panel() -> void:
	var viewport: Vector2 = get_viewport().get_visible_rect().size
	_panel.position = Vector2(viewport.x - _panel.size.x - 12.0, 36.0)


func _hide_hud() -> void:
	hud.visible = false
	minimap.visible = false


# ---- Presets and live values -------------------------------------------------------------------------------------------------------


## Switches to preset `index` (1-4 old cameras, 5 Recommended, 6 My Preset); `snap` jumps instead of blending.
func apply_preset(index: int, snap: bool = false) -> void:
	var values: Dictionary
	if index >= 1 and index <= 4:
		values = LookParams.old_preset(index - 1)
	elif index == 6:
		values = LookParams.load_my_preset()
		if values.is_empty():
			_panel.set_status("No saved My Preset yet: press Save as My Preset in the panel (Tab).")
			return
	else:
		values = LookParams.recommended()
	_preset_index = index
	_params = values
	_panel.bind(_params)
	if snap or _current.is_empty():
		_current = _params.duplicate()
	_apply_current()


func _on_panel_changed() -> void:
	_params["name"] = "Custom (from %s)" % str(_params.get("name", "")).trim_prefix("Custom (from ").trim_suffix(")")


func _save_my_preset() -> void:
	var error: Error = LookParams.save_my_preset(_params)
	_panel.set_status("Saved to %s (F6 loads it)." % LookParams.MY_PRESET_PATH if error == OK else "Could not save: %s" % error_string(error))
	print("world_look: saved my preset: " + LookParams.describe(_params))


func _blend_current(delta: float) -> void:
	var k: float = 1.0 - exp(-6.0 * delta)
	for key: Variant in _params.keys():
		var target: Variant = _params[key]
		if target is float or target is int:
			var now: float = lerpf(float(_current.get(key, target)), float(target), k)
			_current[key] = float(target) if absf(now - float(target)) < 0.0004 else now
		elif key == "fog_color":
			_current[key] = Color.html(str(_current.get(key, target))).lerp(Color.html(str(target)), k).to_html(false)
		else:
			_current[key] = target


func _apply_current() -> void:
	var p: Dictionary = _current
	var pitch_rad: float = deg_to_rad(float(p["pitch"]))
	var dist: float = float(p["distance"])
	var yawed: Vector3 = Vector3(0.0, sin(pitch_rad), cos(pitch_rad)) * dist
	camera_offset = yawed.rotated(Vector3.UP, _yaw)
	_camera.fov = float(p["fov"])
	# The look (post pass, bloom, fog, sky, haze) is only pushed when a value really changed: touching the sky material every frame would redraw the sky cubemap every frame.
	var look_hash: int = _current.hash()
	if look_hash == _look_hash:
		return
	_look_hash = look_hash
	if _post_material != null:
		_post_material.set_shader_parameter("focus_y", float(p["focus"]))
		_post_material.set_shader_parameter("band", float(p["band"]))
		_post_material.set_shader_parameter("blur_far", float(p["blur_far"]))
		_post_material.set_shader_parameter("blur_near", float(p["blur_near"]))
		_post_material.set_shader_parameter("warmth", float(p["warmth"]))
		_post_material.set_shader_parameter("saturation", float(p["saturation"]))
		_post_material.set_shader_parameter("vignette", float(p["vignette"]))
	if _env != null:
		var bloom: float = float(p["bloom"])
		_env.glow_enabled = bloom > 0.01
		_env.glow_intensity = bloom
		_env.glow_strength = 1.0
		_env.glow_bloom = 0.0
		_env.glow_hdr_threshold = float(p["bloom_threshold"])
		_env.glow_hdr_scale = 1.6
		# Very bright small things (lamp glows, motes) would bloom into big white balls: cap how bright the glow source may be.
		_env.glow_hdr_luminance_cap = 2.0
		_env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SCREEN
		var spread: float = float(p["glow_spread"])
		for level: int in range(0, 7):
			var centre: float = spread * 5.0 + 0.5
			_env.set_glow_level(level, clampf(1.0 - absf(float(level) - centre) * 0.5, 0.0, 1.0))
		_env.fog_enabled = true
		_env.fog_density = float(p["fog_density"])
		_env.fog_light_color = Color.html(str(p["fog_color"]))
		_env.fog_sky_affect = 0.0
	if _sky != null:
		_sky.set_cloud_speed(float(p["cloud_speed"]))
		_sky.set_haze_color(Color.html(str(p["fog_color"])))
	if _scenery != null:
		_scenery.set_haze_color(Color.html(str(p["fog_color"])))


func _update_caption() -> void:
	if _caption == null:
		return
	var p: Dictionary = _params
	_caption.text = "%s    pitch %.1f  dist %.1f x zoom %.1f  fov %.0f  height %.1f   focus %.2f band %.2f blur %.1f/%.1f   bloom %.2f thr %.2f spread %.2f   fog %.4f   warm %.2f sat %.2f vig %.2f   clouds %.1f    [F1-F6 presets, Tab panel, [ ] turn view]" % [
		str(p.get("name", "")), float(p["pitch"]), float(p["distance"]), Settings.camera_zoom, float(p["fov"]), float(p["height"]), float(p["focus"]), float(p["band"]),
		float(p["blur_far"]), float(p["blur_near"]), float(p["bloom"]), float(p["bloom_threshold"]), float(p["glow_spread"]), float(p["fog_density"]), float(p["warmth"]),
		float(p["saturation"]), float(p["vignette"]), float(p["cloud_speed"])]


# ---- Frame -------------------------------------------------------------------------------------------------------------------------


func _process(delta: float) -> void:
	_yaw = lerp_angle(_yaw, deg_to_rad(float(_yaw_steps) * 30.0), 1.0 - exp(-7.0 * delta))
	player.move_yaw = deg_to_rad(float(_yaw_steps) * 30.0)
	_blend_current(delta)
	_apply_current()
	super._process(delta)
	var pitch_tilt: float = atan2(float(_current["height"]), float(_current["distance"]))
	var basis: Basis = Basis.looking_at(-camera_offset, Vector3.UP)
	_camera.basis = basis.rotated(basis.x, pitch_tilt)
	_update_sprites(delta)
	if _villager != null:
		_villager.tick(delta, player.position)
	if _sky != null:
		_sky.tick(delta)
	if _ambient != null:
		_ambient.tick(delta)
		# Light shafts only read from a low camera; from the high presets they would be big flat strips.
		_ambient.set_shaft_strength(0.1 * clampf((38.0 - float(_current["pitch"])) / 10.0, 0.0, 1.0))
	if _hold_dir != &"":
		Input.action_press(_hold_dir)
	_update_caption()


func _input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	var handled: bool = true
	match key.keycode:
		KEY_TAB:
			_panel.visible = not _panel.visible
		KEY_F1, KEY_F2, KEY_F3, KEY_F4, KEY_F5, KEY_F6:
			if not _locked and not dialogue.active:
				apply_preset(key.keycode - KEY_F1 + 1)
		KEY_BRACKETLEFT:
			_yaw_steps -= 1
		KEY_BRACKETRIGHT:
			_yaw_steps += 1
		_:
			handled = false
	if handled:
		get_viewport().set_input_as_handled()


# ---- Automation --------------------------------------------------------------------------------------------------------------------


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func _settle_at(spot: Vector3, yaw_degrees: int = 0) -> void:
	player.position = spot
	_yaw_steps = yaw_degrees / 30
	_yaw = deg_to_rad(float(_yaw_steps) * 30.0)
	player.move_yaw = _yaw
	_apply_current()
	_camera.position = player.position + camera_offset * Settings.camera_zoom
	_player_sprite.snap_heading(Vector3(0.0, 0.0, 1.0))


func _save_shot(shot_name: String) -> void:
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	image.resize(SHOT_SIZE.x, SHOT_SIZE.y, Image.INTERPOLATE_LANCZOS)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHOT_DIR))
	var path: String = ProjectSettings.globalize_path(SHOT_DIR + shot_name + ".jpg")
	var error: Error = image.save_jpg(path, 0.9)
	print("world_look: saved %s (%s)" % [shot_name, error_string(error)])


func _run_one() -> void:
	await _wait(1.0)
	if _args.has("birds"):
		_ambient.spawn_flock(5, true)
	await _wait(float(_args.get("wait", 2.5)))
	await _save_shot(str(_args.get("name", "one")))
	get_tree().quit(0)


## Where the documented shots stand: id -> [position, yaw degrees]. Yaw is how far the view is turned (0 looks north; 90 looks west; -90 looks east; 180 looks south).
const SHOT_SPOTS: Dictionary = {
	"square": [Vector3(26.8, 0.0, 15.2), 0],
	"water": [Vector3(-18.0, 0.0, 12.5), 90],
	"lm_capital": [Vector3(16.2, 0.0, -12.0), 0],
	"lm_buffet": [Vector3(68.0, 0.0, 12.5), -90],
	"lm_dump": [Vector3(-17.0, 0.0, 12.5), 90],
	"lm_dna": [Vector3(-15.0, 0.0, 34.3), 90],
	"lm_gainlands": [Vector3(25.2, 0.0, 64.0), 180],
	"edge_north": [Vector3(25.2, 0.0, -16.0), 0],
	"edge_west": [Vector3(-22.0, 0.0, 25.0), 90],
	"edge_east": [Vector3(74.0, 0.0, 25.0), -90],
	"edge_south": [Vector3(27.0, 0.0, 70.0), 180],
}
const PERF_PRESETS: Array[int] = [1, 2, 3, 4, 5]


func _only(label: String) -> bool:
	var filter: String = str(_args.get("only", ""))
	if filter.is_empty():
		return true
	for part: String in filter.split(","):
		if label.contains(part):
			return true
	return false


func _go(spot_id: String, preset: int) -> void:
	apply_preset(preset, true)
	var spot: Array = SHOT_SPOTS[spot_id] as Array
	_settle_at(spot[0] as Vector3, int(spot[1]))
	await _wait(1.7)


func _close_dialogue() -> void:
	var guard: int = 0
	while dialogue.active and guard < 80:
		dialogue.press()
		await get_tree().process_frame
		guard += 1
	_talking_id = ""


func _run_shots() -> void:
	print("world_look: recommended values: " + LookParams.describe(LookParams.recommended()))
	await _wait(1.5)
	_panel.visible = false
	# The same spots at F1 - F5.
	for spot_id: String in ["square", "water", "lm_capital", "lm_buffet", "lm_dump", "lm_dna", "lm_gainlands", "edge_north"]:
		for preset: int in range(1, 6):
			var label: String = "%s_f%d" % [spot_id, preset]
			if not _only(label):
				continue
			await _go(spot_id, preset)
			await _save_shot(label)
	# The other edges at F4 and F5 (what the old test found at the low angles).
	for spot_id: String in ["edge_west", "edge_east", "edge_south"]:
		for preset: int in [4, 5]:
			var label: String = "%s_f%d" % [spot_id, preset]
			if not _only(label):
				continue
			await _go(spot_id, preset)
			await _save_shot(label)
	# Walking: towards the camera, away from it, and sideways, at F5 (mid-stride frames).
	if _only("walk"):
		await _walk_shots()
	# Talking to each sprite NPC with the portrait open.
	if _only("talk"):
		await _talk_shots()
	# The wandering villager.
	if _only("villager"):
		await _villager_shots()
	# The hero in the sun and in a building's shadow (the card is lit by the same sun and shadow map as the buildings).
	if _only("shade"):
		await _shade_shots()
	if _only("panel"):
		apply_preset(5, true)
		_settle_at(SHOT_SPOTS["square"][0] as Vector3, 0)
		_panel.visible = true
		await _wait(1.5)
		await _save_shot("panel_f5")
	get_tree().quit(0)


## Walks the hero in four screen directions and saves a frame mid-stride for each.
func _walk_shots() -> void:
	apply_preset(5, true)
	_settle_at(Vector3(25.0, 0.0, 16.0), 0)
	var runs: Array[Array] = [
		["walk_toward", &"move_down", _clear_start(Vector3(24.0, 0.0, 14.0), Vector3(0, 0, 1), 5.5)],
		["walk_away", &"move_up", _clear_start(Vector3(24.0, 0.0, 21.0), Vector3(0, 0, -1), 5.5)],
		["walk_left", &"move_left", _clear_start(Vector3(31.0, 0.0, 16.5), Vector3(-1, 0, 0), 5.5)],
		["walk_right", &"move_right", _clear_start(Vector3(19.0, 0.0, 16.5), Vector3(1, 0, 0), 5.5)],
	]
	for run: Array in runs:
		_settle_at(run[2] as Vector3, 0)
		await _wait(1.3)
		_hold_dir = run[1] as StringName
		await _wait(0.7)
		var guard: int = 0
		while not _player_sprite.walking and guard < 90:
			await get_tree().process_frame
			guard += 1
		print("world_look: %s frame=%s dir=%s flip=%s pos=%s" % [str(run[0]), _player_sprite.current_key, _player_sprite.current_dir, str(_player_sprite.current_flip), str(player.position)])
		await _save_shot(str(run[0]))
		Input.action_release(_hold_dir)
		_hold_dir = &""
		await _wait(0.3)
	# A strip of eight frames of the walk towards the camera, taken on consecutive frames, for the doc's drift check.
	_settle_at(Vector3(25.2, 0.0, 6.0), 0)
	await _wait(1.0)


## A start point near `around` from which the hero can walk `length` metres along `dir` (a unit ground vector) without meeting anything.
func _clear_start(around: Vector3, dir: Vector3, length: float) -> Vector3:
	for ring: int in range(0, 14):
		for step: int in range(0, 12):
			var angle: float = float(step) / 12.0 * TAU
			var start: Vector3 = around + Vector3(cos(angle), 0.0, sin(angle)) * float(ring) * 0.7
			var clear: bool = true
			for i: int in range(0, int(length / 0.4) + 1):
				var along: Vector3 = start + dir * 0.4 * float(i)
				if not town.is_walkable(along, 0.4) or not _in_view(along):
					clear = false
					break
			if clear:
				return start
	return around


## True when no prop stands between the camera (at the current preset, view turned by the current yaw) and the ground point `p`.
func _in_view(p: Vector3) -> bool:
	var camera_ground: Vector3 = p + camera_offset * Settings.camera_zoom
	camera_ground.y = 0.0
	var flat_p: Vector2 = Vector2(p.x, p.z)
	var flat_c: Vector2 = Vector2(camera_ground.x, camera_ground.z)
	for obstacle: Vector3 in town.obstacles:
		if obstacle.z < 0.14:
			continue
		var closest: Vector2 = Geometry2D.get_closest_point_to_segment(Vector2(obstacle.x, obstacle.y), flat_p, flat_c)
		if closest.distance_to(Vector2(obstacle.x, obstacle.y)) < obstacle.z + 0.55 and flat_p.distance_to(Vector2(obstacle.x, obstacle.y)) > 0.1:
			return false
	return true


func _talk_shots() -> void:
	apply_preset(5, true)
	var lines: Dictionary = {"elder": "Elder Maren", "guard": "Gatekeeper Brannoch", "vendor": "Sable", "item_vendor": "Tilly Tonic", "pack_vendor": "Foil Fenwick"}
	for id: String in ["elder", "guard", "vendor", "item_vendor", "pack_vendor"]:
		if not _only("talk_" + id):
			continue
		var npc: Node3D = _npcs[id] as Node3D
		_settle_at(npc.position + Vector3(0.0, 0.0, 2.0), 0)
		await _wait(1.6)
		var before: String = (_npc_sprites[id] as WorldSprite).current_key
		var chat: Array[String] = _elder_lines() if id == "elder" else _chat_lines()
		_talk_npc(id, str(lines[id]), chat)
		await _wait(1.5)
		print("world_look: talk %s before=%s during=%s" % [id, before, (_npc_sprites[id] as WorldSprite).current_key])
		await _save_shot("talk_" + id)
		await _close_dialogue()
		await _wait(0.3)


func _shade_shots() -> void:
	apply_preset(5, true)
	var travel: Vector3 = Vector3(_sun_direction.x, 0.0, _sun_direction.z).normalized()
	var spot: Vector3 = Vector3(26.0, 0.0, 19.0)
	# The view is turned to look south so the wall that casts the shadow (on the sun side of the hero) does not stand between the camera and the hero.
	_settle_at(spot, 180)
	await _wait(1.8)
	await _save_shot("shade_in_sun")
	var wall: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(4.2, 6.0, 0.4)
	wall.mesh = box
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color("c9b8a0")
	wall.material_override = material
	wall.set_meta(StyleToon.META_NO_TOON, true)
	add_child(wall)
	wall.position = spot - travel * 2.0 + Vector3(0.0, 3.0, 0.0)
	wall.rotation.y = atan2(travel.x, travel.z)
	await _wait(1.8)
	await _save_shot("shade_in_shadow")
	wall.queue_free()


func _chat_lines() -> Array[String]:
	var result: Array[String] = ["Welcome to the Crosspath, traveller. Take a look around.", "The cards are fresh and the road is open."]
	return result


func _villager_shots() -> void:
	apply_preset(5, true)
	_settle_at(Vector3(27.8, 0.0, 14.6), 0)
	var taken: int = 0
	var seconds: float = 0.0
	# Waits for the baker to be walking inside the picture a few times and saves a frame each.
	while taken < 3 and seconds < 90.0:
		await _wait(0.5)
		seconds += 0.5
		var sprite: WorldSprite = _villager.sprite
		var on_screen: bool = not _camera.is_position_behind(sprite.position) and _camera.get_viewport().get_visible_rect().grow(-120.0).has_point(_camera.unproject_position(sprite.position))
		if sprite.walking and on_screen and seconds > 1.0 + float(taken) * 6.0:
			print("world_look: villager walking dir=%s key=%s pos=%s" % [sprite.current_dir, sprite.current_key, str(sprite.position)])
			await _save_shot("villager_%d" % (taken + 1))
			taken += 1


func _run_perf() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	await _wait(2.5)
	_panel.visible = false
	var presets: Array[int] = PERF_PRESETS.duplicate()
	if _args.has("presets"):
		presets = []
		for part: String in str(_args["presets"]).split(","):
			presets.append(int(part))
	for spot_id: String in str(_args.get("spots", "square")).split(","):
		for preset: int in presets:
			apply_preset(preset, true)
			var spot: Array = SHOT_SPOTS[spot_id] as Array
			_settle_at(spot[0] as Vector3, int(spot[1]))
			await _wait(1.5)
			var frames: PackedFloat32Array = []
			var elapsed: float = 0.0
			while elapsed < 4.0:
				await get_tree().process_frame
				var dt: float = get_process_delta_time()
				frames.append(dt)
				elapsed += dt
			var sorted: Array = Array(frames)
			sorted.sort()
			var total: float = 0.0
			for value: float in frames:
				total += value
			var avg: float = total / float(frames.size())
			var p95: float = float(sorted[int(float(sorted.size()) * 0.95)])
			print("world_look: perf|%s|F%d|%.1f fps|%.2f ms avg|%.2f ms p95|%d draw calls|quality %d" % [spot_id, preset, 1.0 / avg, avg * 1000.0, p95 * 1000.0, int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)), Settings.graphics_quality])
	get_tree().quit(0)


func _run_walk() -> void:
	await _wait(1.5)
	await _walk_shots()
	get_tree().quit(0)


func _run_probe() -> void:
	await _wait(1.0)
	print("world_look: map bounds %s" % str(town.map_bounds()))
	var shared: ShaderMaterial = StyleWater.material()
	var count: int = 0
	var lowest: float = 1e9
	var highest: float = -1e9
	for node: Node in town.root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		if mesh_instance.material_override == shared:
			count += 1
			var box: AABB = mesh_instance.global_transform * mesh_instance.get_aabb()
			lowest = minf(lowest, box.position.y)
			highest = maxf(highest, box.end.y)
			if count == 1:
				print("world_look: first water tile aabb %s" % str(box))
	print("world_look: water tiles %d, y %.3f .. %.3f" % [count, lowest, highest])
	for zone_id: String in TownBuilder.PORTAL_CELLS.keys():
		var cell: Vector2i = TownBuilder.PORTAL_CELLS[zone_id] as Vector2i
		var mouth: Vector3 = town.cell_center(cell.x, cell.y)
		var plan: Dictionary = TownConnectors.plan(mouth, TownBuilder.PORTAL_OUT[zone_id] as Vector3)
		print("world_look: portal %s mouth %s island %s" % [zone_id, str(mouth), str(plan["center"])])
	print("world_look: plaza %s camera far %.0f" % [str(TownLayout.PLAZA), _camera.far])
	get_tree().quit(0)


func _run_probe2() -> void:
	await _wait(1.0)
	for zone_id: String in ["final", "beefcake"]:
		var root: Node3D = town.root.get_node_or_null("Connector_%s" % zone_id) as Node3D
		if root == null:
			print("world_look: no connector %s" % zone_id)
			continue
		var kinds: Dictionary = {}
		for child: Node in root.get_children():
			var node: Node3D = child as Node3D
			var label: String = "%s|%s" % [child.name.rstrip("0123456789@"), child.get_class()]
			kinds[label] = int(kinds.get(label, 0)) + 1
		print("world_look: connector %s children: %s" % [zone_id, str(kinds)])
	get_tree().quit(0)


## Switches one feature on or off for the A/B frame-time run.
func _set_feature(token: String, enabled: bool) -> void:
	match token:
		"post":
			_post_rect.visible = enabled
		"foliage":
			_foliage.visible = enabled
		"ambient":
			_ambient.visible = enabled
		"scenery":
			_scenery.visible = enabled
		"sky":
			_sky.visible = enabled
		"sprites":
			_player_sprite.visible = enabled
		"bloom":
			_env.glow_enabled = enabled
		"outline":
			style_rig.outline.visible = enabled
		"fxaa":
			get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA if enabled else Viewport.SCREEN_SPACE_AA_DISABLED
		"shadows":
			style_rig.sun.shadow_enabled = enabled
		"fog":
			_env.fog_enabled = enabled
		"scale":
			get_viewport().scaling_3d_scale = 0.62 if enabled else 0.5
		"cloudshadow":
			_sky._shadow_plane.visible = enabled
		"water":
			(_scenery.get_node("WaterPlane") as Node3D).visible = enabled
		"rings":
			for ring_name: String in ["Ring_near_treeline", "Ring_mid_hills", "Ring_far_mountains"]:
				(_scenery.get_node(ring_name) as Node3D).visible = enabled


func _measure(seconds: float) -> Array[float]:
	var frames: PackedFloat32Array = []
	var elapsed: float = 0.0
	while elapsed < seconds:
		await get_tree().process_frame
		var dt: float = get_process_delta_time()
		frames.append(dt)
		elapsed += dt
	var total: float = 0.0
	for value: float in frames:
		total += value
	return [1000.0 * total / float(frames.size())]


## Frame time with each feature switched off in turn (same process, same minute, so thermal drift matters less); `--run=perfab`.
func _run_perfab() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	await _wait(2.5)
	_panel.visible = false
	apply_preset(int(_args.get("preset", 5)), true)
	_settle_at(SHOT_SPOTS[str(_args.get("spot", "square"))][0] as Vector3, int(SHOT_SPOTS[str(_args.get("spot", "square"))][1]))
	await _wait(6.0)
	var rows: PackedStringArray = []
	for token: String in str(_args.get("features", "post,bloom,foliage,ambient,sky,cloudshadow,water,rings,scenery,sprites")).split(","):
		var before: Array[float] = await _measure(2.5)
		_set_feature(token, false)
		await _wait(0.4)
		var result: Array[float] = await _measure(2.5)
		_set_feature(token, true)
		await _wait(0.4)
		var line: String = "perfab|without %s|%.2f ms -> %.2f ms|saves %.2f ms" % [token, before[0], result[0], before[0] - result[0]]
		rows.append(line)
		print("world_look: " + line)
	get_tree().quit(0)


## `--run=roundtrip`: tweaks a value, saves My Preset, loads it with F6 and checks it came back (then removes the file again).
func _run_roundtrip() -> void:
	await _wait(1.0)
	apply_preset(5, true)
	_params["pitch"] = 27.5
	_params["fog_color"] = "aabbcc"
	_save_my_preset()
	apply_preset(5, true)
	apply_preset(6, true)
	var ok: bool = is_equal_approx(float(_params["pitch"]), 27.5) and str(_params["fog_color"]) == "aabbcc" and str(_params["name"]) == "F6 My Preset"
	print("world_look: roundtrip %s (pitch %.1f, fog %s)" % ["OK" if ok else "FAILED", float(_params["pitch"]), str(_params["fog_color"])])
	DirAccess.remove_absolute(ProjectSettings.globalize_path(LookParams.MY_PRESET_PATH))
	get_tree().quit(0 if ok else 1)
