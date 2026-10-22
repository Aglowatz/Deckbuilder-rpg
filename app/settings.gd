extends Node
## Player settings, persisted to user://settings.cfg and applied the moment they change: display (window mode, resolution, VSync, frame cap, quality, UI scale), text sizes
## and dialogue speed, accessibility (Path symbols, reduced shake and flashing), key bindings (`Keybinds`) and audio (master, music, effects, UI, ambience and dialogue-voice volumes, mute when unfocused).

const PATH: String = "user://settings.cfg"
const BUS_MUSIC: StringName = &"Music"
const BUS_SFX: StringName = &"SFX"
const BUS_UI: StringName = &"UI"
## Sound pass, Part A: the rest of the bus tree (`AudioMix.ensure_layout`): Master > Music, SFX (World, Battle, UI), Ambience, Voice.
const BUS_WORLD: StringName = &"World"
const BUS_BATTLE: StringName = &"Battle"
const BUS_AMBIENCE: StringName = &"Ambience"
const BUS_VOICE: StringName = &"Voice"

## Emitted when the minimap setting changes (a live HUD hides or shows its minimap at once).
signal minimap_toggled(visible_now: bool)
## Emitted when the graphics quality or depth-of-field setting changes (live `StyleRig`s re-apply at once).
signal graphics_changed
## Emitted when the UI scale changes (`UiScale` re-fits the screens and the HUD).
signal ui_scale_changed
## Emitted when a text size or the dialogue speed changes (open cards, tooltips and the dialogue box re-draw).
signal text_changed
## Emitted when Path symbols, reduced shake or reduced flashing change.
signal accessibility_changed

enum WindowMode { WINDOWED, FULLSCREEN, BORDERLESS }

const TEXT_SCALES: Array[float] = [0.85, 1.0, 1.2, 1.4]
const TEXT_SCALE_NAMES: Array[String] = ["Small", "Normal", "Large", "Extra large"]
## Characters per second of the dialogue typewriter (0 = the whole line at once).
const DIALOGUE_SPEEDS: Array[float] = [24.0, 55.0, 110.0, 0.0]
const DIALOGUE_SPEED_NAMES: Array[String] = ["Slow", "Normal", "Fast", "Instant"]
## Battle feel, Part B: how fast AI turns and battle animations play (a multiplier on every battle wait and tween).
## Overnight Oct 18, Part 7: 1x / 1.5x / 2x (animations only; the rules never wait on them).
const BATTLE_SPEEDS: Array[float] = [1.0, 1.5, 2.0]
const BATTLE_SPEED_NAMES: Array[String] = ["1x", "1.5x", "2x"]
const UI_SCALE_MIN: float = 0.9
const UI_SCALE_MAX: float = 1.5
## Windowed sizes offered by the resolution list (the ones that do not fit the screen are left out).
const RESOLUTIONS: Array[Vector2i] = [Vector2i(1280, 720), Vector2i(1366, 768), Vector2i(1600, 900), Vector2i(1920, 1080), Vector2i(2560, 1440), Vector2i(3840, 2160)]
## Frame caps offered by the list (0 = unlimited).
const FRAME_CAPS: Array[int] = [0, 30, 60, 90, 120, 144, 165, 240]

var master_volume: float = 0.8
var music_volume: float = 0.6
var sfx_volume: float = 0.8
var ui_volume: float = 0.8
## The ambience beds and their one-shots (birds, hum, wind) and the dialogue voice blips.
var ambience_volume: float = 0.8
var voice_volume: float = 0.8
## Silences the game while its window is not the focused one.
var mute_unfocused: bool = false
var window_mode: int = WindowMode.WINDOWED
## The chosen windowed size; (0, 0) = never chosen, the window keeps the size it opened with.
var window_size: Vector2i = Vector2i.ZERO
var vsync: bool = true
var max_fps: int = 0
## UI scale, 0.9 to 1.5: menus, popups and the HUD panels grow or shrink (`UiScale`).
var ui_scale: float = 1.0
var text_dialogue: int = 1
var text_cards: int = 1
var text_tooltips: int = 1
var dialogue_speed: int = 1
var battle_speed: int = 0
## Ask before ending a turn while cards or abilities could still be used (the prompt's "don't ask again" turns it off).
var confirm_end_turn: bool = true
## Overnight Oct 18, Part 7: end the turn by itself when nothing is left to play or attack with (off by default).
var auto_end_turn: bool = false
## Adds a Path symbol wherever a Path is shown only by its colour.
var colorblind_symbols: bool = false
var reduce_shake: bool = false
var reduce_flashing: bool = false
## Whether the HUD minimap is drawn (the M full map always works).
var show_minimap: bool = true
## Low / Medium / High (`GraphicsQuality.Level`): outlines, volumetrics, SSAO, shadows, DOF, foliage density.
var graphics_quality: int = GraphicsQuality.Level.MEDIUM
## Depth of field: the tilt-shift blur pass of the world look (WorldLookRig). Not on Low.
var depth_of_field: bool = true
## The bloom (glow) of the world look; the quality level still decides whether it is affordable.
var bloom: bool = true
## Fog quality: 0 off, 1 light, 2 full (the distance haze and, on High, the sparse volumetric shafts).
var fog_quality: int = 2
## Graphics Tier 1: the upscaler (`GraphicsQuality.Upscaler`, 0 = Auto per level), the render scale as a percentage (0 = the level's own value,
## else 50..100) and the FSR sharpness slider (0 soft .. 1 crisp).
var upscaling_mode: int = GraphicsQuality.Upscaler.AUTO
var render_scale_pct: int = 0
var sharpness: float = 0.8
## How far the 3D camera sits from the hero, as a multiple of each area's base offset (mouse wheel changes it; remembered).
const ZOOM_MIN: float = 1.0
const ZOOM_MAX: float = 2.0
const ZOOM_DEFAULT: float = 1.5
var camera_zoom: float = ZOOM_DEFAULT
## Camera angle preset (CameraRig.ANGLE_NAMES): 0 Cinematic, 1 Classic, 2 Overview. Remembered in settings.cfg, never per save.
var camera_angle: int = 0
signal camera_changed
## Overnight Oct 20 (playtest stability): the rendering driver - "auto" (the project default, D3D12 on Windows), "d3d12" or "vulkan".
## A choice other than the running driver restarts an exported game once with `--rendering-driver` (`_switch_driver_if_needed`).
var renderer: String = "auto"
const RENDERERS: Array[String] = ["auto", "d3d12", "vulkan"]
## This launch runs in Safe Mode (BootGuard: the last launch did not get to a playable picture, or the Safe Mode launcher): Low, no fog,
## bloom or depth of field. The title screen says so; the player can raise the settings again.
var safe_mode: bool = false
## settings.cfg layout version: 2 = written by v0.4.3+ (older files may hold High chosen for an iGPU by the D3D12 misreport).
const SETTINGS_VERSION: int = 2
var _loaded_version: int = 0

var _focused: bool = true
## Screenshot and test runs keep their own window (set by `_ready`).
var _window_locked: bool = false
var _window_size_saved: bool = false
var _zoom_dirty: float = 0.0


## Old code and saves read "fullscreen"; it is the window mode now.
var fullscreen: bool:
	get:
		return window_mode == WindowMode.FULLSCREEN
	set(value):
		window_mode = WindowMode.FULLSCREEN if value else WindowMode.WINDOWED


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	AudioMix.ensure_layout()
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--scene=") or arg.begins_with("--no-save"):
			_window_locked = true
	GraphicsQuality.heavy_passes_allowed = not GpuInfo.is_intel_integrated(RenderingServer.get_video_adapter_name(),
		RenderingServer.get_video_adapter_vendor(), RenderingServer.get_video_adapter_type())
	if not GraphicsQuality.heavy_passes_allowed:
		GameLog.info("settings", "Intel integrated GPU: volumetric fog, SSAO and MSAA stay off even on High")
	load_settings()
	_apply_boot_guard()
	apply()
	GameLog.info("settings", summary())
	_switch_driver_if_needed()


## Applies everything: audio, window, VSync, frame cap, UI scale.
func apply() -> void:
	apply_audio()
	apply_window()
	apply_performance()
	apply_tooltip_theme()
	ui_scale_changed.emit()


func apply_audio() -> void:
	_set_bus(&"Master", master_volume)
	_set_bus(BUS_MUSIC, music_volume)
	_set_bus(BUS_SFX, sfx_volume)
	_set_bus(BUS_UI, ui_volume)
	_set_bus(BUS_AMBIENCE, ambience_volume)
	_set_bus(BUS_VOICE, voice_volume)
	var master: int = AudioServer.get_bus_index(&"Master")
	if master >= 0 and is_muted_by_focus():
		AudioServer.set_bus_mute(master, true)


## True when the game is silenced right now because its window lost focus.
func is_muted_by_focus() -> bool:
	return mute_unfocused and not _focused


## The focus state the game believes it has (the notifications below set it; tests set it directly).
func set_focused(focused: bool) -> void:
	_focused = focused
	apply_audio()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		set_focused(false)
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		set_focused(true)


func _set_bus(bus_name: StringName, linear: float) -> void:
	var index: int = AudioServer.get_bus_index(bus_name)
	if index < 0:
		return
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(linear, 0.0001)))
	AudioServer.set_bus_mute(index, linear <= 0.001)


## The windowed sizes that fit the screen (the current choice is always in the list).
func available_resolutions() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var screen: Vector2i = Vector2i(99999, 99999)
	if DisplayServer.get_name() != "headless":
		screen = DisplayServer.screen_get_size(DisplayServer.window_get_current_screen())
	for size: Vector2i in RESOLUTIONS:
		if size.x <= screen.x and size.y <= screen.y:
			result.append(size)
	if window_size != Vector2i.ZERO and not result.has(window_size):
		result.append(window_size)
		result.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.x < b.x)
	return result


## Window mode and size. Screenshot and test runs (and the headless server) keep the window they have.
func apply_window() -> void:
	if DisplayServer.get_name() == "headless":
		return
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED)
	if _window_locked:
		return
	match window_mode:
		WindowMode.FULLSCREEN:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		WindowMode.BORDERLESS:
			if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			var screen: int = DisplayServer.window_get_current_screen()
			DisplayServer.window_set_size(DisplayServer.screen_get_size(screen))
			DisplayServer.window_set_position(DisplayServer.screen_get_position(screen))
		_:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			if _window_size_saved and window_size != Vector2i.ZERO:
				DisplayServer.window_set_size(window_size)
				var screen_id: int = DisplayServer.window_get_current_screen()
				var area: Rect2i = DisplayServer.screen_get_usable_rect(screen_id)
				DisplayServer.window_set_position(area.position + (area.size - window_size) / 2)


## Chooses a windowed size (applied now when the window is windowed).
func set_window_size(size: Vector2i) -> void:
	window_size = size
	_window_size_saved = true
	apply_window()


func set_window_mode(mode: int) -> void:
	window_mode = mode
	if mode == WindowMode.WINDOWED and window_size == Vector2i.ZERO and DisplayServer.get_name() != "headless":
		window_size = DisplayServer.window_get_size()
	apply_window()


## The engine tooltips (the plain hover text of buttons and icons) follow the tooltip text size.
func apply_tooltip_theme() -> void:
	var theme: Theme = ThemeDB.get_project_theme()
	if theme != null:
		theme.set_font_size("font_size", "TooltipLabel", tooltip_font(18))


func apply_performance() -> void:
	Engine.max_fps = max_fps


func set_ui_scale(value: float) -> void:
	ui_scale = clampf(snappedf(value, 0.05), UI_SCALE_MIN, UI_SCALE_MAX)
	ui_scale_changed.emit()


# ---- Derived values -------------------------------------------------------------------------


func dialogue_text_scale() -> float:
	return TEXT_SCALES[clampi(text_dialogue, 0, TEXT_SCALES.size() - 1)]


func card_text_scale() -> float:
	return TEXT_SCALES[clampi(text_cards, 0, TEXT_SCALES.size() - 1)]


func tooltip_text_scale() -> float:
	return TEXT_SCALES[clampi(text_tooltips, 0, TEXT_SCALES.size() - 1)]


## `base` font size scaled by the tooltip text option (never below 10).
func tooltip_font(base: int) -> int:
	return maxi(10, int(round(float(base) * tooltip_text_scale())))


## Characters per second of the dialogue typewriter; 0 means instant.
func dialogue_chars_per_second() -> float:
	return DIALOGUE_SPEEDS[clampi(dialogue_speed, 0, DIALOGUE_SPEEDS.size() - 1)]


## The battle speed multiplier (1 = Normal).
func battle_speed_scale() -> float:
	return BATTLE_SPEEDS[clampi(battle_speed, 0, BATTLE_SPEEDS.size() - 1)]


## A typewriter duration written for the Normal speed, converted to the chosen dialogue speed (0.0 = instant).
func typewriter_time(normal_seconds: float) -> float:
	var cps: float = dialogue_chars_per_second()
	return 0.0 if cps <= 0.0 else normal_seconds * 55.0 / cps


## 1.0 for a normal screen shake, 0.0 when reduced. Multiply a shake strength by it.
func shake_scale() -> float:
	return 0.0 if reduce_shake else 1.0


## 1.0 for a normal full-screen flash or strobe, 0.2 when reduced. Multiply a flash peak by it.
func flash_scale() -> float:
	return 0.2 if reduce_flashing else 1.0


# ---- Persistence ----------------------------------------------------------------------------


func save_settings(path: String = PATH) -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("audio", "master", master_volume)
	config.set_value("audio", "music", music_volume)
	config.set_value("audio", "sfx", sfx_volume)
	config.set_value("audio", "ui", ui_volume)
	config.set_value("audio", "ambience", ambience_volume)
	config.set_value("audio", "voice", voice_volume)
	config.set_value("audio", "mute_unfocused", mute_unfocused)
	config.set_value("video", "window_mode", window_mode)
	config.set_value("video", "fullscreen", window_mode == WindowMode.FULLSCREEN)
	if _window_size_saved:
		config.set_value("video", "window_size", window_size)
	config.set_value("video", "vsync", vsync)
	config.set_value("video", "max_fps", max_fps)
	config.set_value("video", "ui_scale", ui_scale)
	config.set_value("video", "minimap", show_minimap)
	config.set_value("video", "quality", graphics_quality)
	config.set_value("video", "tilt_shift", depth_of_field)
	config.set_value("video", "bloom", bloom)
	config.set_value("video", "fog_quality", fog_quality)
	config.set_value("video", "upscaling", upscaling_mode)
	config.set_value("video", "render_scale", render_scale_pct)
	config.set_value("video", "sharpness", sharpness)
	config.set_value("video", "zoom", camera_zoom)
	config.set_value("video", "camera_angle", camera_angle)
	config.set_value("video", "renderer", renderer)
	config.set_value("meta", "version", SETTINGS_VERSION)
	config.set_value("text", "dialogue", text_dialogue)
	config.set_value("text", "cards", text_cards)
	config.set_value("text", "tooltips", text_tooltips)
	config.set_value("text", "dialogue_speed", dialogue_speed)
	config.set_value("battle", "speed", battle_speed)
	config.set_value("battle", "confirm_end_turn", confirm_end_turn)
	config.set_value("battle", "auto_end_turn", auto_end_turn)
	config.set_value("access", "colorblind_symbols", colorblind_symbols)
	config.set_value("access", "reduce_shake", reduce_shake)
	config.set_value("access", "reduce_flashing", reduce_flashing)
	Keybinds.save_to(config)
	config.save(path)


func load_settings(path: String = PATH) -> void:
	var config: ConfigFile = ConfigFile.new()
	if config.load(path) != OK:
		graphics_quality = GraphicsQuality.recommended()
		Keybinds.reset_all()
		return
	master_volume = float(config.get_value("audio", "master", master_volume))
	music_volume = float(config.get_value("audio", "music", music_volume))
	sfx_volume = float(config.get_value("audio", "sfx", sfx_volume))
	ui_volume = float(config.get_value("audio", "ui", ui_volume))
	ambience_volume = float(config.get_value("audio", "ambience", ambience_volume))
	voice_volume = float(config.get_value("audio", "voice", voice_volume))
	mute_unfocused = bool(config.get_value("audio", "mute_unfocused", mute_unfocused))
	var old_fullscreen: bool = bool(config.get_value("video", "fullscreen", false))
	window_mode = clampi(int(config.get_value("video", "window_mode", WindowMode.FULLSCREEN if old_fullscreen else WindowMode.WINDOWED)), 0, 2)
	if config.has_section_key("video", "window_size"):
		window_size = config.get_value("video", "window_size", Vector2i.ZERO) as Vector2i
		_window_size_saved = window_size != Vector2i.ZERO
	vsync = bool(config.get_value("video", "vsync", vsync))
	max_fps = maxi(0, int(config.get_value("video", "max_fps", max_fps)))
	ui_scale = clampf(float(config.get_value("video", "ui_scale", ui_scale)), UI_SCALE_MIN, UI_SCALE_MAX)
	show_minimap = bool(config.get_value("video", "minimap", show_minimap))
	graphics_quality = clampi(int(config.get_value("video", "quality", GraphicsQuality.recommended())), 0, 2)
	depth_of_field = bool(config.get_value("video", "tilt_shift", depth_of_field))
	bloom = bool(config.get_value("video", "bloom", bloom))
	fog_quality = clampi(int(config.get_value("video", "fog_quality", fog_quality)), 0, 2)
	upscaling_mode = clampi(int(config.get_value("video", "upscaling", GraphicsQuality.Upscaler.AUTO)), 0, GraphicsQuality.UPSCALER_NAMES.size() - 1)
	render_scale_pct = int(config.get_value("video", "render_scale", 0))
	if render_scale_pct != 0:
		render_scale_pct = clampi(render_scale_pct, 50, 100)
	sharpness = clampf(float(config.get_value("video", "sharpness", 0.8)), 0.0, 1.0)
	camera_zoom = clampf(float(config.get_value("video", "zoom", camera_zoom)), ZOOM_MIN, ZOOM_MAX)
	camera_angle = clampi(int(config.get_value("video", "camera_angle", camera_angle)), 0, 2)
	renderer = str(config.get_value("video", "renderer", renderer))
	if not RENDERERS.has(renderer):
		renderer = "auto"
	_loaded_version = int(config.get_value("meta", "version", 1))
	_migrate_quality()
	text_dialogue = clampi(int(config.get_value("text", "dialogue", text_dialogue)), 0, TEXT_SCALES.size() - 1)
	text_cards = clampi(int(config.get_value("text", "cards", text_cards)), 0, TEXT_SCALES.size() - 1)
	text_tooltips = clampi(int(config.get_value("text", "tooltips", text_tooltips)), 0, TEXT_SCALES.size() - 1)
	dialogue_speed = clampi(int(config.get_value("text", "dialogue_speed", dialogue_speed)), 0, DIALOGUE_SPEEDS.size() - 1)
	battle_speed = clampi(int(config.get_value("battle", "speed", battle_speed)), 0, BATTLE_SPEEDS.size() - 1)
	confirm_end_turn = bool(config.get_value("battle", "confirm_end_turn", confirm_end_turn))
	auto_end_turn = bool(config.get_value("battle", "auto_end_turn", auto_end_turn))
	colorblind_symbols = bool(config.get_value("access", "colorblind_symbols", colorblind_symbols))
	reduce_shake = bool(config.get_value("access", "reduce_shake", reduce_shake))
	reduce_flashing = bool(config.get_value("access", "reduce_flashing", reduce_flashing))
	Keybinds.load_from(config)


## A settings.cfg from v0.4.2 or older that holds High on an integrated GPU got High from the D3D12 misreport (GpuInfo), not from the
## player: it drops to the level recommended now, once (the file is saved with SETTINGS_VERSION on the next save).
func _migrate_quality() -> void:
	var kind: GpuInfo.Kind = GpuInfo.current_kind()
	var level: int = migrated_quality(graphics_quality, _loaded_version, kind)
	if level == graphics_quality:
		return
	graphics_quality = level
	GameLog.info("settings", "High from an older version on an integrated GPU -> %s" % GraphicsQuality.display_name(graphics_quality))
	save_settings.call_deferred()


## The quality an older settings.cfg (`version`) keeps on a GPU of `kind` (see `_migrate_quality`).
static func migrated_quality(level: int, version: int, kind: GpuInfo.Kind) -> int:
	if version >= SETTINGS_VERSION or level != GraphicsQuality.Level.HIGH or not GpuInfo.is_integrated(kind):
		return level
	return GpuInfo.recommended_level(kind)


## Safe Mode (BootGuard via GameLog): the lightest look, saved so it stays until the player raises it. Two bad launches in a row also
## switch the rendering driver.
func _apply_boot_guard() -> void:
	if GameLog.safe_mode_reason.is_empty() or _window_locked:
		return
	safe_mode = true
	apply_safe_mode()
	if not GameLog.other_driver.is_empty():
		renderer = GameLog.other_driver
		GameLog.warn("settings", "two launches in a row did not start properly: trying the %s driver" % renderer)
	save_settings()


## The Safe Mode look: Low, no fog, bloom or depth of field (also the settings screen's "Safe settings" choice).
func apply_safe_mode() -> void:
	graphics_quality = GraphicsQuality.Level.LOW
	fog_quality = 0
	bloom = false
	depth_of_field = false


## An exported game whose chosen driver is not the running one restarts once with it (never in the editor, tools or tests; never twice).
func _switch_driver_if_needed() -> void:
	var running: String = RenderingServer.get_current_rendering_driver_name()
	if renderer == "auto" or renderer == running or not OS.has_feature("template") or DisplayServer.get_name() == "headless":
		return
	for arg: String in OS.get_cmdline_args():
		if arg.begins_with("--rendering-driver") or arg.begins_with("--rendering-method"):
			return  # a launcher (.bat) or the player chose on the command line: that wins
	var user_args: PackedStringArray = OS.get_cmdline_user_args()
	if user_args.has("--driver-restarted"):
		GameLog.warn("settings", "asked for the %s driver but the engine started %s (not available?)" % [renderer, running])
		return
	var args: PackedStringArray = OS.get_cmdline_args()
	args.append_array(["--rendering-driver", renderer, "--"])
	args.append_array(user_args)
	args.append("--driver-restarted")
	GameLog.info("settings", "restarting with the %s driver (running %s)" % [renderer, running])
	BootGuard.set_stage("restarting for %s" % renderer)
	OS.set_restart_on_exit(true, args)
	get_tree().quit.call_deferred()


## One line for the game log and reports: the graphics settings in use.
func summary() -> String:
	return "quality %s (recommended %s for this GPU), render scale %.2f, upscaler %d, sharpness %.2f, fog %d, bloom %s, depth of field %s, vsync %s, max fps %d, window mode %d, renderer %s%s" % [
		GraphicsQuality.display_name(graphics_quality), GraphicsQuality.display_name(GraphicsQuality.recommended()), GraphicsQuality.effective_render_scale(graphics_quality),
		upscaling_mode, sharpness, fog_quality, str(bloom), str(depth_of_field), str(vsync), max_fps, window_mode, renderer, ", SAFE MODE" if safe_mode else ""]


## Back to the defaults of the display, text, accessibility and audio options (key bindings have their own reset).
func reset_to_defaults() -> void:
	master_volume = 0.8
	music_volume = 0.6
	sfx_volume = 0.8
	ui_volume = 0.8
	ambience_volume = 0.8
	voice_volume = 0.8
	mute_unfocused = false
	window_mode = WindowMode.WINDOWED
	vsync = true
	max_fps = 0
	ui_scale = 1.0
	text_dialogue = 1
	text_cards = 1
	text_tooltips = 1
	dialogue_speed = 1
	colorblind_symbols = false
	reduce_shake = false
	battle_speed = 0
	confirm_end_turn = true
	auto_end_turn = false
	reduce_flashing = false
	graphics_quality = GraphicsQuality.recommended()
	depth_of_field = true
	bloom = true
	fog_quality = 2
	upscaling_mode = GraphicsQuality.Upscaler.AUTO
	render_scale_pct = 0
	sharpness = 0.8
	apply()
	text_changed.emit()
	accessibility_changed.emit()
	graphics_changed.emit()


## Mouse wheel zoom in every 3D scene (UI that scrolls swallows the wheel first, so lists still scroll).
func _unhandled_input(event: InputEvent) -> void:
	if CameraRig.active_rigs > 0 and event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo:
		if InputMap.has_action(&"camera_angle") and event.is_action_pressed(&"camera_angle"):
			cycle_camera_angle()
			return
		if InputMap.has_action(&"camera_zoom") and event.is_action_pressed(&"camera_zoom"):
			cycle_camera_zoom()
			return
	var wheel: InputEventMouseButton = event as InputEventMouseButton
	if wheel == null or not wheel.pressed:
		return
	if wheel.button_index == MOUSE_BUTTON_WHEEL_UP:
		set_camera_zoom(camera_zoom - 0.1)
	elif wheel.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		set_camera_zoom(camera_zoom + 0.1)


func set_camera_zoom(value: float) -> void:
	var clamped: float = clampf(value, ZOOM_MIN, ZOOM_MAX)
	if is_equal_approx(clamped, camera_zoom):
		return
	camera_zoom = clamped
	_zoom_dirty = 0.6
	camera_changed.emit()


func set_camera_angle(index: int) -> void:
	var clamped: int = clampi(index, 0, 2)
	if clamped == camera_angle:
		return
	camera_angle = clamped
	_zoom_dirty = 0.6
	camera_changed.emit()


## Cycles Cinematic -> Classic -> Overview.
func cycle_camera_angle() -> void:
	set_camera_angle((camera_angle + 1) % 3)


## Cycles Close -> Normal -> Far (from the nearest preset).
func cycle_camera_zoom() -> void:
	var next: int = (CameraRig.zoom_index() + 1) % CameraRig.ZOOM_VALUES.size()
	set_camera_zoom(CameraRig.ZOOM_VALUES[next])


func _process(delta: float) -> void:
	if _zoom_dirty > 0.0:
		_zoom_dirty -= delta
		if _zoom_dirty <= 0.0:
			save_settings()
