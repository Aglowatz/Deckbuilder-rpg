extends CanvasLayer
## Scene switching with a fade to black, plus the global pause menu.

const FADE_TIME: float = 0.3

var busy: bool = false
## Scenes that may be paused set this true in _ready and false when they leave.
var pause_allowed: bool = false

var _fade: ColorRect
var _pause_menu: PauseMenu
## The Dev Menu (debug builds only; null in a release build).
var dev_menu: DevMenu
## The area scene the player is in (`Areas` key; "" on the title): loading screens and zone title cards show when the destination is a different area.
var current_area: String = ""
## The area before the current one (the title counts as ""): a scene shows its zone title card when this differs from its own area.
var previous_area: String = ""
## Loading screens (LOAD-*) on entering an area; tools and tests can switch them off.
var show_loading_screens: bool = true
## Playtest v0.4.0 Part C: the next change skips the loading screen and uses a short fade (the walk out of the Forgotten Cave into Crosspath).
var skip_loading_once: bool = false

## Emitted when a scene change has finished (the fade or loading screen is gone), so something that belongs to the new scene can start.
signal revealed

## v0.4.2 hotfix: a scene that builds over several frames (the town) answers `is_load_finished()` false until it is built and warmed up; the
## loading screen (or the black fade) stays up until then, at most BUILD_TIMEOUT seconds.
const BUILD_TIMEOUT: float = 90.0
## Then frames are drawn behind the cover until SETTLE_FRAMES in a row take under SETTLE_FRAME_MS (first-time shader pipelines, textures
## uploading), at most SETTLE_MAX seconds, so the picture never stalls once it shows.
const SETTLE_FRAMES: int = 4
const SETTLE_FRAME_MS: float = 50.0
const SETTLE_MAX: float = 4.0
## After the fade-in the worst frame of the next REVEAL_WATCH seconds goes to the game log with the load time.
const REVEAL_WATCH: float = 5.0
var _reveal_watch_left: float = 0.0
var _reveal_worst_ms: float = 0.0
var _reveal_last_usec: int = 0
var _reveal_what: String = ""
## The last reveal's numbers (tests, the release smoke): {"scene", "load_ms", "worst_ms"}.
var last_load: Dictionary = {}


func _ready() -> void:
	layer = 100
	UiSkin.apply()
	process_mode = Node.PROCESS_MODE_ALWAYS
	_fade = ColorRect.new()
	_fade.color = Color(0.03, 0.02, 0.05, 1.0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.modulate.a = 0.0
	add_child(_fade)
	_pause_menu = PauseMenu.new()
	_pause_menu.layer = 90
	get_tree().root.add_child.call_deferred(_pause_menu)
	# Oct 20: the Dev Menu (F10) exists in debug builds only (`DevTools.menu_enabled`); a release export never builds one.
	dev_menu = DevMenu.install(get_tree())


func _unhandled_input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key != null and key.pressed and not key.echo and key.keycode == KEY_F8:
		open_feedback()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(&"pause") and pause_allowed and not busy:
		_pause_menu.toggle()
		get_viewport().set_input_as_handled()


## Fades out, loads `path`, fades back in.
func change_scene(path: String, fade_time: float = FADE_TIME) -> void:
	if busy:
		return
	busy = true
	_reveal_watch_left = 0.0  # the last scene's after-the-fade-in watch ends with it
	LoadTiming.begin(path.get_file().get_basename())
	_close_pause()
	_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	var area: String = Areas.key_for_scene(path)
	# Overnight Oct 18, Part 3: autosave on every area change (a crash-safe write, see SaveSystem).
	if area != current_area and Session.has_profile():
		Session.save_game()
	var screen: LoadingScreen = null
	var quick: bool = skip_loading_once
	skip_loading_once = false
	if quick:
		fade_time = minf(fade_time, 0.2)
	if show_loading_screens and not quick and not area.is_empty() and area != current_area and DisplayServer.get_name() != "headless":
		screen = LoadingScreen.make(area, Session.dungeon_key)
	# Sound pass: a gust carries the hero into another area; the old place's ambience fades with the picture (the new scene sets its own).
	if not area.is_empty() and area != current_area and not current_area.is_empty():
		Audio.sfx(&"zone_transition")
	Audio.set_ambience("none", fade_time + 0.3)
	var out: Tween = create_tween()
	out.tween_property(_fade, "modulate:a", 1.0, fade_time)
	await out.finished
	LoadTiming.mark("fade out")
	pause_allowed = false
	var shown_at: int = Time.get_ticks_msec()
	if screen != null:
		screen.modulate.a = 0.0
		add_child(screen)
		var appear: Tween = create_tween().set_parallel(true)
		appear.tween_property(screen, "modulate:a", 1.0, LoadingScreen.FADE_IN)
		appear.tween_method(screen.set_progress, 0.0, 0.7, LoadingScreen.MIN_SECONDS)
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
	LoadTiming.mark("loading screen up")
	var error: Error = get_tree().change_scene_to_file(path)
	LoadTiming.mark("change_scene_to_file")
	if error != OK:
		push_error("SceneManager: cannot load %s" % path)
	if path == "res://scenes/title.tscn":
		previous_area = ""
		current_area = ""
	elif not area.is_empty():
		previous_area = current_area
		current_area = area
	await get_tree().process_frame
	LoadTiming.mark("scene ready + frame 1")
	var staged: bool = await _wait_until_built(screen, path)
	await get_tree().process_frame
	LoadTiming.mark("frame 2")
	if staged or screen != null:
		await _settle()
	if screen != null:
		screen.set_progress(1.0)
		# The loading screen stays a moment even when the scene was quick, so it never flashes.
		var remaining: float = LoadingScreen.MIN_SECONDS - float(Time.get_ticks_msec() - shown_at) / 1000.0
		if remaining > 0.0:
			await get_tree().create_timer(remaining).timeout
		_fade.modulate.a = 0.0
		var vanish: Tween = create_tween()
		vanish.tween_property(screen, "modulate:a", 0.0, LoadingScreen.FADE_OUT)
		await vanish.finished
		screen.queue_free()
	else:
		var back: Tween = create_tween()
		back.tween_property(_fade, "modulate:a", 0.0, fade_time)
		await back.finished
	LoadTiming.mark("fade in")
	_watch_reveal(path.get_file().get_basename())
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	busy = false
	revealed.emit()


## Waits (the cover still up) for a scene that builds over several frames. Returns true when the scene had such a build.
func _wait_until_built(screen: LoadingScreen, path: String) -> bool:
	# The new scene becomes current at the end of a frame - not always the first one after change_scene_to_file.
	var frames: int = 0
	while frames < 30 and (get_tree().current_scene == null or get_tree().current_scene.scene_file_path != path):
		await get_tree().process_frame
		frames += 1
	var scene: Node = get_tree().current_scene
	if scene == null or not scene.has_method(&"is_load_finished"):
		return false
	var waited: float = 0.0
	while is_instance_valid(scene) and not bool(scene.call(&"is_load_finished")) and waited < BUILD_TIMEOUT:
		var started: int = Time.get_ticks_usec()
		await get_tree().process_frame
		waited += float(Time.get_ticks_usec() - started) / 1000000.0
		if screen != null and scene.has_method(&"load_progress"):
			screen.set_progress(maxf(screen.progress(), lerpf(0.2, 0.95, float(scene.call(&"load_progress")))))
	if waited >= BUILD_TIMEOUT:
		push_warning("SceneManager: %s was still building after %.0f s; showing it anyway" % [scene.name, BUILD_TIMEOUT])
	LoadTiming.mark("scene built")
	return true


## Draws frames behind the cover until they are quick (see SETTLE_FRAMES).
func _settle() -> void:
	var quick: int = 0
	var started: int = Time.get_ticks_usec()
	var last: int = started
	while quick < SETTLE_FRAMES and float(Time.get_ticks_usec() - started) / 1000000.0 < SETTLE_MAX:
		await get_tree().process_frame
		var now: int = Time.get_ticks_usec()
		quick = quick + 1 if float(now - last) / 1000.0 < SETTLE_FRAME_MS else 0
		last = now
	LoadTiming.mark("settled")


func _watch_reveal(what: String) -> void:
	_reveal_what = what
	_reveal_worst_ms = 0.0
	_reveal_watch_left = REVEAL_WATCH
	_reveal_last_usec = Time.get_ticks_usec()
	last_load = {"scene": what, "load_ms": LoadTiming.finish(), "worst_ms": 0.0}


func _process(_delta: float) -> void:
	if _reveal_watch_left <= 0.0:
		return
	var now: int = Time.get_ticks_usec()
	var ms: float = float(now - _reveal_last_usec) / 1000.0
	_reveal_last_usec = now
	_reveal_worst_ms = maxf(_reveal_worst_ms, ms)
	_reveal_watch_left -= ms / 1000.0
	if _reveal_watch_left <= 0.0:
		last_load["worst_ms"] = _reveal_worst_ms
		print("%s; worst frame in the first %.0f s after the fade-in: %.0f ms" % [LoadTiming.summary_line(), REVEAL_WATCH, _reveal_worst_ms])


## The playtest feedback form (F8, or the pause menu button).
func open_feedback() -> void:
	FeedbackForm.open(self)


func _close_pause() -> void:
	if _pause_menu != null and _pause_menu.visible:
		_pause_menu.toggle()


func quit_game() -> void:
	Settings.save_settings()
	get_tree().quit()


func go_to_title() -> void:
	change_scene("res://scenes/title.tscn")


func go_to_town() -> void:
	change_scene("res://scenes/town.tscn")


func go_to_start_area() -> void:
	change_scene("res://scenes/starting_area.tscn")
