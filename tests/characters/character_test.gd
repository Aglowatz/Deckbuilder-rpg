class_name CharacterTest
extends TownScene
## Player character look + camera angle test bench (docs/art/character_test.md). It IS the real town (TownScene, painted textures and all); it only swaps how the hero is drawn
## and how the camera sits. Nothing in the real game scenes changes, and the save is never written.
##   Keys 1 / 2 / 3: character = current 3D model / HD-2D pixel sprite / painted 2.5D sprite.
##   Keys F1 - F4  : camera = Current / Classic RPG / HD-2D (tilt-shift + bloom) / Low and cinematic. The mouse wheel zooms within each preset.
## Launch: Godot --path . res://tests/characters/character_test.tscn   (or open the scene and press F6)
## Automation (via tools/character_shots.sh): `--run=matrix` photographs everything, `--run=perf` measures frame time per combination.

enum Look { MODEL_3D, HD2D, PAINTED }

## Camera presets. `dist` is the camera-to-hero distance at zoom 1.0 (the town multiplies it by Settings.camera_zoom, default 1.5), `pitch` the downward angle of the
## camera's offset, `look_up` tilts the view back up (a lower horizon), `fov` in degrees. Tuned by eye, see docs/art/character_test.md.
const PRESETS: Array[Dictionary] = [
	{"name": "F1 Current", "pitch": 53.27, "dist": 13.72, "fov": 38.0, "look_up": 0.0, "tilt": 0.0, "bloom": 0.0},
	{"name": "F2 Classic RPG", "pitch": 45.0, "dist": 10.0, "fov": 38.0, "look_up": 0.0, "tilt": 0.0, "bloom": 0.0},
	{"name": "F3 HD-2D", "pitch": 30.0, "dist": 7.4, "fov": 30.0, "look_up": 2.0, "tilt": 1.0, "bloom": 1.0},
	{"name": "F4 Low and cinematic", "pitch": 20.0, "dist": 7.0, "fov": 44.0, "look_up": 4.5, "tilt": 0.0, "bloom": 0.0},
]
const LOOK_NAMES: Array[String] = ["3D model", "HD-2D pixel sprite", "Painted 2.5D sprite"]
const SHOT_DIR: String = "res://docs/art/character_test/"
const SHOT_SIZE: Vector2i = Vector2i(1280, 720)
## Where the "same spot" shots are taken: just south of the plaza fountain.
const SPOT: Vector3 = Vector3(26.8, 0.0, 15.2)

var look: int = Look.MODEL_3D
var preset_index: int = 0
var _args: Dictionary = {}
var _sprites: Array[CharSprite] = [null, null, null]
var _pitch: float = 53.27
var _dist: float = 13.72
var _fov: float = 38.0
var _look_up: float = 0.0
var _tilt: float = 0.0
var _bloom: float = 0.0
var _caption: Label
var _tilt_rect: ColorRect
var _tilt_material: ShaderMaterial
var _env: Environment
var _env_glow: Dictionary = {}
var _saved_attributes: CameraAttributes
var _hold_dir: StringName = &""
var _shot_mode: bool = false


func screenshot_prepare(args: Dictionary) -> void:
	_args = args
	super.screenshot_prepare(args)


func _ready() -> void:
	# Never touch the real save (the town saves at the end of _ready).
	Session.save_enabled = false
	Settings.camera_zoom = Settings.ZOOM_DEFAULT
	if _args.is_empty():
		# Launched directly (editor or `godot res://tests/characters/character_test.tscn -- --run=matrix`): read the same --key=value arguments here.
		for arg: String in OS.get_cmdline_user_args():
			if arg.begins_with("--"):
				var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
				_args[parts[0]] = parts[1] if parts.size() > 1 else "true"
		if _args.is_empty():
			_args = {"fresh": "true"}
		_screenshot_args = _args
	_shot_mode = _args.has("run")
	super._ready()
	_build_test_rig()
	player.position = SPOT
	_camera.position = player.position + camera_offset * Settings.camera_zoom
	apply_look(int(_args.get("look", Look.MODEL_3D)))
	apply_preset(int(_args.get("preset", 0)) , true)
	if _shot_mode:
		_hide_hud()
		match str(_args["run"]):
			"matrix":
				_run_matrix.call_deferred()
			"probes":
				_run_probes_only.call_deferred()
			"perf":
				_run_perf.call_deferred()


func _build_test_rig() -> void:
	for index: int in [Look.HD2D, Look.PAINTED]:
		var sprite: CharSprite = CharSprite.new()
		add_child(sprite)
		sprite.setup(index == Look.HD2D, _camera)
		sprite.visible = false
		_sprites[index] = sprite
	# Tilt-shift pass under the HUD (HUD canvas layers are 5 and 8).
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = -5
	add_child(layer)
	_tilt_rect = ColorRect.new()
	_tilt_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_tilt_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tilt_material = ShaderMaterial.new()
	_tilt_material.shader = load("res://tests/characters/tilt_shift.gdshader") as Shader
	_tilt_rect.material = _tilt_material
	_tilt_rect.visible = false
	layer.add_child(_tilt_rect)
	var info_layer: CanvasLayer = CanvasLayer.new()
	info_layer.layer = 9
	add_child(info_layer)
	_caption = Label.new()
	_caption.position = Vector2(14, 10)
	_caption.add_theme_font_size_override("font_size", 15)
	_caption.add_theme_color_override("font_color", Color(1, 1, 0.9))
	_caption.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_caption.add_theme_constant_override("outline_size", 6)
	_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_caption.visible = not _shot_mode
	info_layer.add_child(_caption)
	if style_rig != null and style_rig.world_env != null:
		_env = style_rig.world_env.environment
		_env_glow = {"enabled": _env.glow_enabled, "intensity": _env.glow_intensity, "strength": _env.glow_strength, "bloom": _env.glow_bloom, "threshold": _env.glow_hdr_threshold}
	_saved_attributes = _camera.attributes


func _hide_hud() -> void:
	hud.visible = false
	minimap.visible = false


# ---- Character look ----------------------------------------------------------------------------------------------------------------


func apply_look(index: int) -> void:
	look = clampi(index, 0, 2)
	player.model.visible = look == Look.MODEL_3D
	for i: int in [Look.HD2D, Look.PAINTED]:
		_sprites[i].visible = i == look
	_update_caption()


# ---- Camera presets ----------------------------------------------------------------------------------------------------------------


## Switches to preset `index`; `snap` jumps instead of blending (the camera glides over ~0.8 s otherwise).
func apply_preset(index: int, snap: bool = false) -> void:
	preset_index = clampi(index, 0, PRESETS.size() - 1)
	if snap:
		var p: Dictionary = PRESETS[preset_index]
		_pitch = float(p["pitch"])
		_dist = float(p["dist"])
		_fov = float(p["fov"])
		_look_up = float(p["look_up"])
		_tilt = float(p["tilt"])
		_bloom = float(p["bloom"])
		_drive_camera(0.0, true)
	_update_caption()


func _drive_camera(delta: float, snap: bool = false) -> void:
	var p: Dictionary = PRESETS[preset_index]
	var k: float = 1.0 if snap else 1.0 - exp(-4.5 * delta)
	_pitch = lerpf(_pitch, float(p["pitch"]), k)
	_dist = lerpf(_dist, float(p["dist"]), k)
	_fov = lerpf(_fov, float(p["fov"]), k)
	_look_up = lerpf(_look_up, float(p["look_up"]), k)
	_tilt = lerpf(_tilt, float(p["tilt"]), k)
	_bloom = lerpf(_bloom, float(p["bloom"]), k)
	var pitch_rad: float = deg_to_rad(_pitch)
	camera_offset = Vector3(0.0, sin(pitch_rad), cos(pitch_rad)) * _dist
	if snap:
		_camera.position = player.position + camera_offset * Settings.camera_zoom
	_camera.fov = _fov
	_apply_grade()


func _apply_grade() -> void:
	var tilt_on: bool = _tilt > 0.02
	_tilt_rect.visible = tilt_on
	if tilt_on:
		var focus: Vector2 = _camera.unproject_position(player.position + Vector3(0.0, 0.5, 0.0))
		var screen_h: float = get_viewport().get_visible_rect().size.y
		_tilt_material.set_shader_parameter("focus_y", clampf(focus.y / screen_h, 0.2, 0.8))
		_tilt_material.set_shader_parameter("amount", _tilt)
		# The depth-based far blur of the town camera would stack with the tilt-shift: swap it out while the tilt-shift is on.
		_camera.attributes = null
	else:
		_camera.attributes = _saved_attributes
	if _env != null:
		_env.glow_enabled = bool(_env_glow["enabled"]) or _bloom > 0.02
		_env.glow_intensity = lerpf(float(_env_glow["intensity"]), 0.85, _bloom)
		_env.glow_strength = lerpf(float(_env_glow["strength"]), 1.05, _bloom)
		_env.glow_bloom = lerpf(float(_env_glow["bloom"]), 0.18, _bloom)
		_env.glow_hdr_threshold = lerpf(float(_env_glow["threshold"]), 0.75, _bloom)


func _update_caption() -> void:
	if _caption == null:
		return
	var p: Dictionary = PRESETS[preset_index]
	_caption.text = "Look [1/2/3]: %s     Camera [F1-F4]: %s  (pitch %.0f, dist %.1f x zoom %.1f, fov %.0f)" % [LOOK_NAMES[look], p["name"], float(p["pitch"]), float(p["dist"]), Settings.camera_zoom, float(p["fov"])]


# ---- Frame -------------------------------------------------------------------------------------------------------------------------


func _process(delta: float) -> void:
	_drive_camera(delta)
	super._process(delta)
	# The town aims straight down the offset; the look-up tilt shows more sky for the low presets.
	_camera.basis = Basis(Vector3.RIGHT, deg_to_rad(_look_up)) * Basis.looking_at(-camera_offset, Vector3.UP)
	if look != Look.MODEL_3D:
		_sprites[look].follow(player.position, delta)
	if _hold_dir != &"":
		Input.action_press(_hold_dir)
	_update_caption()


func _unhandled_input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key != null and key.pressed and not key.echo and not _locked and not dialogue.active:
		var handled: bool = true
		match key.keycode:
			KEY_1:
				apply_look(Look.MODEL_3D)
			KEY_2:
				apply_look(Look.HD2D)
			KEY_3:
				apply_look(Look.PAINTED)
			KEY_F1:
				apply_preset(0)
			KEY_F2:
				apply_preset(1)
			KEY_F3:
				apply_preset(2)
			KEY_F4:
				apply_preset(3)
			_:
				handled = false
		if handled:
			get_viewport().set_input_as_handled()
			return
	super._unhandled_input(event)


## The final numbers per preset, for the log and the doc.
func describe_presets() -> PackedStringArray:
	var lines: PackedStringArray = []
	for p: Dictionary in PRESETS:
		lines.append("%s: pitch %.1f deg, distance %.2f (x zoom %.1f = %.2f), fov %.0f deg, look-up %.1f deg, tilt-shift %s, bloom %s" % [p["name"], float(p["pitch"]), float(p["dist"]), Settings.camera_zoom, float(p["dist"]) * Settings.camera_zoom, float(p["fov"]), float(p["look_up"]), "on" if float(p["tilt"]) > 0.0 else "off", "boosted" if float(p["bloom"]) > 0.0 else "town default"])
	return lines


# ---- Automation --------------------------------------------------------------------------------------------------------------------


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func _settle_at(spot: Vector3) -> void:
	player.position = spot
	_camera.position = player.position + camera_offset * Settings.camera_zoom
	for sprite: CharSprite in _sprites:
		if sprite != null:
			sprite._have_last = false


func _save_shot(shot_name: String) -> void:
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	image.resize(SHOT_SIZE.x, SHOT_SIZE.y, Image.INTERPOLATE_LANCZOS)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHOT_DIR))
	var path: String = ProjectSettings.globalize_path(SHOT_DIR + shot_name + ".jpg")
	var error: Error = image.save_jpg(path, 0.88)
	print("character_test: saved %s (%s)" % [shot_name, error_string(error)])


func _close_dialogue() -> void:
	var guard: int = 0
	while dialogue.active and guard < 80:
		dialogue.press()
		await get_tree().process_frame
		guard += 1


func _run_matrix() -> void:
	print("character_test: presets")
	for line: String in describe_presets():
		print("character_test:   " + line)
	await _wait(1.5)
	var only_preset: int = int(_args.get("only_preset", -1))
	for pi: int in range(PRESETS.size()):
		if only_preset >= 0 and pi != only_preset:
			continue
		for li: int in range(3):
			apply_look(li)
			apply_preset(pi)
			_settle_at(SPOT)
			await _wait(1.6)
			await _save_shot("matrix_%d_%d" % [li + 1, pi + 1])
		for li: int in range(3):
			# Walking towards the camera: hold "down" (south, towards the camera) from the plaza's north side.
			apply_look(li)
			apply_preset(pi)
			_settle_at(SPOT + Vector3(0.0, 0.0, -0.5))
			await _wait(1.2)
			_hold_dir = &"move_down"
			await _wait(0.28)
			var guard: int = 0
			while look != Look.MODEL_3D and not _sprites[look].current_frame.contains("WALK") and guard < 60:
				await get_tree().process_frame
				guard += 1
			print("character_test: walk look=%d preset=%d pos=%s frame=%s" % [li + 1, pi + 1, str(player.position), _sprites[li].current_frame if _sprites[li] != null else "3D"])
			await _save_shot("walk_%d_%d" % [li + 1, pi + 1])
			_hold_dir = &""
			Input.action_release(&"move_down")
			await _wait(0.2)
		for li: int in range(3):
			apply_look(li)
			apply_preset(pi)
			var elder: Node3D = _npcs["elder"] as Node3D
			_settle_at(elder.position + Vector3(0.0, 0.0, 1.8))
			await _wait(1.3)
			_talk_npc("elder", "Elder Maren", _elder_lines())
			await _wait(1.6)
			await _save_shot("dialogue_%d_%d" % [li + 1, pi + 1])
			await _close_dialogue()
			await _wait(0.2)
	# Extra world probes (step 5): edges, horizon, backs of buildings, sky.
	if _args.has("probes"):
		await _run_probes()
	get_tree().quit(0)


## Edge / horizon probes: each preset at a few places the camera could reveal the end of the world.
func _run_probes() -> void:
	apply_look(Look.PAINTED)
	var bounds: Rect2 = town.map_bounds()
	print("character_test: map bounds %s" % str(bounds))
	var mid_x: float = 25.2
	var spots: Dictionary = {
		"north": Vector3(mid_x, 0.0, bounds.position.y + 3.0),
		"west": Vector3(bounds.position.x + 3.0, 0.0, 12.47),
		"east": Vector3(bounds.end.x - 3.0, 0.0, 12.47),
		"south": Vector3(mid_x, 0.0, bounds.end.y - 3.0),
	}
	for key: String in str(_args.get("probe_spots", "north,west,east,south")).split(","):
		if not spots.has(key):
			continue
		print("character_test: probe spot %s = %s" % [key, str(spots[key])])
		for pi: int in range(PRESETS.size()):
			apply_preset(pi)
			_settle_at(spots[key])
			await _wait(1.4)
			await _save_shot("probe_%s_%d" % [key, pi + 1])


func _run_perf() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	var results: PackedStringArray = []
	await _wait(2.0)
	for pi: int in range(PRESETS.size()):
		for li: int in range(3):
			apply_look(li)
			apply_preset(pi, true)
			_settle_at(SPOT)
			await _wait(1.5)
			var frames: PackedFloat32Array = []
			var elapsed: float = 0.0
			while elapsed < 3.0:
				await get_tree().process_frame
				var dt: float = get_process_delta_time()
				frames.append(dt)
				elapsed += dt
			var sorted: Array = Array(frames)
			sorted.sort()
			var total: float = 0.0
			for v: float in frames:
				total += v
			var avg: float = total / float(frames.size())
			var p95: float = float(sorted[int(float(sorted.size()) * 0.95)])
			var line: String = "perf|%d|%d|%.1f|%.2f|%.2f|%d" % [li + 1, pi + 1, 1.0 / avg, avg * 1000.0, p95 * 1000.0, int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))]
			print("character_test: " + line)
			results.append(line)
	get_tree().quit(0)


func _run_probes_only() -> void:
	await _wait(1.5)
	await _run_probes()
	get_tree().quit(0)
