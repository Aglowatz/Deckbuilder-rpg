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
## The quest update banner layer (`QuestNoticeLayer`).
var quest_notices: QuestNoticeLayer
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
## Overnight Oct 20 (playtest stability): a slow integrated GPU compiling the town's first shader pipelines draws seconds-long frames for
## much longer than the dev PC's 4 s - the cover now stays up to SETTLE_MAX while frames are still spiking. A machine that is merely slow
## (every frame 60-90 ms) settles too: a frame counts as quick under max(SETTLE_FRAME_MS, SETTLE_STEADY x the quickest frame seen).
const SETTLE_MAX: float = 30.0
const SETTLE_STEADY: float = 1.6
## After the fade-in the worst frame of the next REVEAL_WATCH seconds goes to the game log with the load time.
const REVEAL_WATCH: float = 5.0
var _reveal_watch_left: float = 0.0
var _reveal_worst_ms: float = 0.0
var _reveal_worst_at: float = 0.0
var _reveal_last_usec: int = 0
var _reveal_what: String = ""
## The last reveal's numbers (tests, the release smoke): {"scene", "load_ms", "worst_ms"}.
var last_load: Dictionary = {}

## Overnight Oct 20 (playtest stability): the transition watchdog. A transition that makes no progress (no LoadTiming step, no change in
## the scene's load_progress) for STUCK_SECONDS - BUILD_STUCK_SECONDS while a scene builds - or stays busy past MAX_BUSY_SECONDS is
## ended by force: the cover goes, input comes back, `revealed` is emitted and the game log gets a warning. The old coroutine sees a
## newer `_transition_id` when it wakes and stops.
const STUCK_SECONDS: float = 8.0
const BUILD_STUCK_SECONDS: float = 30.0
const MAX_BUSY_SECONDS: float = BUILD_TIMEOUT + 30.0
## The step the running transition is in ("" when not busy): fade out, loading screen, change scene, build, settle, fade in.
var phase: String = ""
var _target: String = ""
var _transition_id: int = 0
var _busy_since_usec: int = 0
var _progress_usec: int = 0
var _progress_seen: float = -1.0
var _screen: LoadingScreen
var _tweens: Array[Tween] = []
## Times the watchdog had to end a transition (tests, the release smoke).
var watchdog_trips: int = 0
## Esc pressed while a transition was running: the pause menu opens once the scene is revealed.
var _pause_wanted: bool = false


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
	# Fixes Oct 25, Part 7: the quest update banner, in every scene
	quest_notices = QuestNoticeLayer.install(get_tree())


## Overnight Oct 20: F8 is taken before the GUI (a focused control or a full-screen blocker can never swallow it); Esc during a
## transition is remembered and opens the pause menu at the reveal.
func _input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key != null and key.pressed and not key.echo and key.keycode == KEY_F8:
		open_feedback()
		get_viewport().set_input_as_handled()
		return
	if busy and event.is_action_pressed(&"pause") and get_tree().root.get_node_or_null(^"FeedbackForm") == null:
		_pause_wanted = true
		GameLog.info("input", "Esc during the %s transition (%s): the pause menu opens when it ends" % [_target, phase])
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause") and pause_allowed and not busy:
		_pause_menu.toggle()
		get_viewport().set_input_as_handled()


## Fades out, loads `path`, fades back in.
func change_scene(path: String, fade_time: float = FADE_TIME) -> void:
	if busy:
		GameLog.info("scene", "change to %s ignored: the %s transition is still running (%s)" % [path.get_file(), _target, phase])
		return
	busy = true
	_transition_id += 1
	var id: int = _transition_id
	_target = path.get_file().get_basename()
	_busy_since_usec = Time.get_ticks_usec()
	_progress_usec = _busy_since_usec
	_progress_seen = -1.0
	_pause_wanted = false
	_reveal_watch_left = 0.0  # the last scene's after-the-fade-in watch ends with it
	LoadTiming.begin(_target)
	GameLog.scene_loading(_target)
	_set_phase("fade out")
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
	_screen = screen
	# Sound pass: a gust carries the hero into another area; the old place's ambience fades with the picture (the new scene sets its own).
	if not area.is_empty() and area != current_area and not current_area.is_empty():
		Audio.sfx(&"zone_transition")
	Audio.set_ambience("none", fade_time + 0.3)
	var out: Tween = _track(create_tween())
	out.tween_property(_fade, "modulate:a", 1.0, fade_time)
	await out.finished
	if id != _transition_id:
		return
	LoadTiming.mark("fade out")
	pause_allowed = false
	var shown_at: int = Time.get_ticks_msec()
	if screen != null:
		screen.modulate.a = 0.0
		add_child(screen)
		_set_phase("loading screen")
		var appear: Tween = _track(create_tween().set_parallel(true))
		appear.tween_property(screen, "modulate:a", 1.0, LoadingScreen.FADE_IN)
		appear.tween_method(screen.set_progress, 0.0, 0.7, LoadingScreen.MIN_SECONDS)
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		if id != _transition_id:
			return
	LoadTiming.mark("loading screen up")
	_set_phase("change scene")
	var error: Error = get_tree().change_scene_to_file(path)
	LoadTiming.mark("change_scene_to_file")
	if error != OK:
		push_error("SceneManager: cannot load %s" % path)
	# Phase 2 (stability): leaving an area for another (or for the title) frees its world-art caches with its scene (AreaCaches).
	if (not area.is_empty() or path == "res://scenes/title.tscn") and area != current_area and not current_area.is_empty():
		GameLog.info("memory", "left %s: released %d cached world-art entries" % [current_area, AreaCaches.release()])
	if path == "res://scenes/title.tscn":
		previous_area = ""
		current_area = ""
	elif not area.is_empty():
		previous_area = current_area
		current_area = area
	await get_tree().process_frame
	if id != _transition_id:
		return
	LoadTiming.mark("scene ready + frame 1")
	_set_phase("build")
	await _wait_until_built(screen, path)
	await get_tree().process_frame
	if id != _transition_id:
		return
	LoadTiming.mark("frame 2")
	# Phase 2 (stability): every change settles behind the cover (a quick scene settles in 4 frames); before, only a staged build or a
	# loading screen did, and a change without one showed its first-draw shader spikes after the fade-in.
	_set_phase("settle")
	await _settle()
	if id != _transition_id:
		return
	_set_phase("fade in")
	if screen != null:
		screen.set_progress(1.0)
		# The loading screen stays a moment even when the scene was quick, so it never flashes.
		var remaining: float = LoadingScreen.MIN_SECONDS - float(Time.get_ticks_msec() - shown_at) / 1000.0
		if remaining > 0.0:
			await get_tree().create_timer(remaining).timeout
			if id != _transition_id:
				return
		_fade.modulate.a = 0.0
		var vanish: Tween = _track(create_tween())
		vanish.tween_property(screen, "modulate:a", 0.0, LoadingScreen.FADE_OUT)
		await vanish.finished
		if id != _transition_id:
			return
		screen.queue_free()
	else:
		var back: Tween = _track(create_tween())
		back.tween_property(_fade, "modulate:a", 0.0, fade_time)
		await back.finished
		if id != _transition_id:
			return
	LoadTiming.mark("fade in")
	_end_transition()


## The cover is gone: input back, `revealed` emitted, a remembered Esc opens the pause menu.
func _end_transition() -> void:
	_watch_reveal(_target)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_screen = null
	_tweens.clear()
	busy = false
	_set_phase("")
	GameLog.step("scene", "%s revealed" % _target)
	GameLog.scene_revealed(_target)
	revealed.emit()
	if _pause_wanted:
		_pause_wanted = false
		if pause_allowed and _pause_menu != null and not _pause_menu.visible:
			_pause_menu.toggle()


func _track(tween: Tween) -> Tween:
	_tweens.append(tween)
	return tween


func _set_phase(value: String) -> void:
	phase = value
	_progress_usec = Time.get_ticks_usec()


## Seconds the running transition has taken (0 when not busy).
func busy_seconds() -> float:
	return float(Time.get_ticks_usec() - _busy_since_usec) / 1000000.0 if busy else 0.0


## The watchdog (see STUCK_SECONDS): called every frame while busy.
func _watch_transition() -> void:
	var now: int = Time.get_ticks_usec()
	if get_tree().paused:
		_progress_usec = now  # the report form or a pause menu is open: waiting for the player is not a stuck load
		return
	if LoadTiming.last_mark_usec() > _progress_usec:
		_progress_usec = LoadTiming.last_mark_usec()
	var scene: Node = get_tree().current_scene
	if scene != null and scene.has_method(&"load_progress"):
		var progress: float = float(scene.call(&"load_progress"))
		if not is_equal_approx(progress, _progress_seen):
			_progress_seen = progress
			_progress_usec = now
	var quiet: float = float(now - _progress_usec) / 1000000.0
	var limit: float = BUILD_STUCK_SECONDS if phase == "build" or phase == "change scene" else STUCK_SECONDS
	if quiet > limit:
		force_reveal("no progress for %.0f s in '%s'" % [quiet, phase])
	elif busy_seconds() > MAX_BUSY_SECONDS:
		force_reveal("busy for %.0f s" % busy_seconds())


## Ends the running transition at once (the watchdog; tests). The scene is shown as it is; a scene that can finish itself
## (`recover_after_timeout`) is asked to.
func force_reveal(reason: String) -> void:
	if not busy:
		return
	watchdog_trips += 1
	GameLog.warn("scene", "transition to %s forced to end: %s (last step: %s)" % [_target, reason, LoadTiming.last_step()])
	_transition_id += 1
	for tween: Tween in _tweens:
		if tween != null and tween.is_valid():
			tween.kill()
	if _screen != null and is_instance_valid(_screen):
		_screen.queue_free()
	_fade.modulate.a = 0.0
	var scene: Node = get_tree().current_scene
	if scene != null and scene.has_method(&"recover_after_timeout"):
		scene.call(&"recover_after_timeout")
	LoadTiming.mark("forced reveal")
	_end_transition()


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
		GameLog.warn("scene", "%s was still building after %.0f s; showing it anyway" % [scene.name, BUILD_TIMEOUT])
		if is_instance_valid(scene) and scene.has_method(&"recover_after_timeout"):
			scene.call(&"recover_after_timeout")
	LoadTiming.mark("scene built")
	return true


## Draws frames behind the cover until they are quick (see SETTLE_FRAMES).
func _settle() -> void:
	var quick: int = 0
	var started: int = Time.get_ticks_usec()
	var last: int = started
	var quickest: float = 1000000.0
	var frames: int = 0
	var worst: float = 0.0
	while quick < SETTLE_FRAMES and float(Time.get_ticks_usec() - started) / 1000000.0 < SETTLE_MAX:
		await get_tree().process_frame
		var now: int = Time.get_ticks_usec()
		var ms: float = float(now - last) / 1000.0
		last = now
		frames += 1
		worst = maxf(worst, ms)
		quickest = minf(quickest, ms)
		quick = quick + 1 if settle_frame_quick(ms, quickest) else 0
		_progress_usec = now  # frames are being drawn: the watchdog sees progress
	if quick < SETTLE_FRAMES:
		GameLog.warn("scene", "frames still slow after %.0f s behind the cover (worst %.0f ms, quickest %.0f ms): showing the scene" % [SETTLE_MAX, worst, quickest])
	LoadTiming.mark("settled (%d frames, worst %.0f ms)" % [frames, worst])


## Whether a settling frame of `ms` counts as quick, given the quickest one so far (see SETTLE_STEADY).
static func settle_frame_quick(ms: float, quickest: float) -> bool:
	return ms < maxf(SETTLE_FRAME_MS, quickest * SETTLE_STEADY)


func _watch_reveal(what: String) -> void:
	_reveal_what = what
	_reveal_worst_ms = 0.0
	_reveal_watch_left = REVEAL_WATCH
	_reveal_last_usec = Time.get_ticks_usec()
	last_load = {"scene": what, "load_ms": LoadTiming.finish(), "worst_ms": 0.0}


func _process(_delta: float) -> void:
	if busy:
		_watch_transition()
	if _reveal_watch_left <= 0.0:
		return
	var now: int = Time.get_ticks_usec()
	var ms: float = float(now - _reveal_last_usec) / 1000.0
	_reveal_last_usec = now
	if get_tree().paused:
		return  # a menu the player opened (pause, report form): its build is not the scene's stall
	if ms > _reveal_worst_ms:
		_reveal_worst_ms = ms
		_reveal_worst_at = REVEAL_WATCH - _reveal_watch_left
	_reveal_watch_left -= ms / 1000.0
	if _reveal_watch_left <= 0.0:
		last_load["worst_ms"] = _reveal_worst_ms
		var line: String = "%s; worst frame in the first %.0f s after the fade-in: %.0f ms (at %.1f s)" % [LoadTiming.summary_line(), REVEAL_WATCH, _reveal_worst_ms, _reveal_worst_at]
		print(line)
		GameLog.info("scene", line)


## The playtest feedback form (F8, or the pause menu button).
func open_feedback() -> void:
	FeedbackForm.open(self)


func _close_pause() -> void:
	if _pause_menu != null and _pause_menu.visible:
		_pause_menu.toggle()


func quit_game() -> void:
	Settings.save_settings()
	GameLog.clean_exit()
	get_tree().quit()


func go_to_title() -> void:
	change_scene("res://scenes/title.tscn")


func go_to_town() -> void:
	change_scene("res://scenes/town.tscn")


func go_to_start_area() -> void:
	change_scene("res://scenes/starting_area.tscn")
