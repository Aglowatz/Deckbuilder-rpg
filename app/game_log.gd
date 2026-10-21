extends Node
## Overnight Oct 20 (playtest stability): the game's own log, so a tester's log says what the game was doing when it went wrong.
## The engine's godot.log only flushes on errors, and v0.4.0 testers' logs held the engine line and nothing else. This one:
## - writes user://logs/wayward.log, flushed after every line, the last LOGS_KEPT runs kept as wayward.1.log .. wayward.4.log;
## - starts with the version, OS, renderer, driver, GPU and (from Settings) the graphics settings in use;
## - takes one line per scene change step (`LoadTiming`), threaded load / warm-up, modal UI open and close, hero lock change;
## - writes a heartbeat every HEARTBEAT seconds (scene, SceneManager.busy and its step, lock, open modals, fps);
## - runs a watchdog thread that notes when the main thread has not finished a frame for STALL_SECONDS (a hang leaves its last
##   step in the log, which nothing on the main thread could write);
## - keeps the boot stage in user://boot_state.cfg: a launch that ended while starting, loading a scene or stalled makes the next
##   launch start in Safe Mode (`BootGuard`, read by Settings).
## Autoload order: first, before Settings, so everything after it can log.

const DIR: String = "user://logs"
const FILE_NAME: String = "wayward"
const LOGS_KEPT: int = 4
## A file stops taking routine lines (heartbeats, events) past this size; warnings still go in.
const MAX_BYTES: int = 1_500_000
const HEARTBEAT: float = 5.0
const STALL_SECONDS: float = 8.0
## Seconds after a scene is revealed before the boot stage counts it as playing (a crash in the first seconds is a bad start).
const PLAYING_AFTER: float = 5.0

var path: String = ""
var enabled: bool = true
## Safe Mode for this launch: "" = normal, otherwise why (shown on the title screen, see BootGuard).
var safe_mode_reason: String = ""
var previous_stage: String = ""
var launch_number: int = 0
## After two bad launches in a row: the driver to try next ("" = keep), see BootGuard / Settings.
var other_driver: String = ""
## Open modal UI by name (a count: the same screen can open twice) - the heartbeat lists it.
var open_modals: Dictionary = {}

var _file: FileAccess
var _mutex: Mutex = Mutex.new()
var _bytes: int = 0
var _capped: bool = false
var _started_msec: int = 0
var _beat_left: float = HEARTBEAT
var _frames_since_beat: int = 0
var _playing_left: float = -1.0
var _playing_scene: String = ""
## Written by the main thread every frame, read by the watchdog thread (an int read is safe enough for a watchdog).
var _tick_msec: int = 0
var _last_step: String = "starting"
var _watchdog: Thread
var _watchdog_running: bool = false
var _stall_reported: bool = false
var _stall_started_msec: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_started_msec = Time.get_ticks_msec()
	_tick_msec = _started_msec
	enabled = not _is_unit_test_run()
	if not enabled:
		return
	_open()
	# Exported games only (an editor Play stopped mid-load must not put the developer in Safe Mode); WAYWARD_BOOT_GUARD=1 for tests of it.
	BootGuard.active = (OS.has_feature("template") and not _is_tool_run()) or OS.get_environment("WAYWARD_BOOT_GUARD") != ""
	var boot: Dictionary = BootGuard.begin_launch(OS.get_cmdline_user_args())
	previous_stage = str(boot.get("previous_stage", ""))
	safe_mode_reason = str(boot.get("safe_mode_reason", ""))
	launch_number = int(boot.get("launch", 0))
	other_driver = str(boot.get("other_driver", ""))
	_write_header()
	if not safe_mode_reason.is_empty():
		warn("boot", "SAFE MODE: %s" % safe_mode_reason)
	_watchdog_running = true
	_watchdog = Thread.new()
	_watchdog.start(_watch_main_thread)


## GUT and headless runs write no log (they start and stop the game constantly).
func _is_unit_test_run() -> bool:
	if DisplayServer.get_name() == "headless":
		return true
	for arg: String in OS.get_cmdline_args():
		if arg.contains("gut_cmdln"):
			return true
	return OS.get_environment("WAYWARD_NO_GAME_LOG") != ""


## `-s` tools (smokes, bots, screenshots) log, but leave the boot stage alone: a killed bot must not put the next real launch in Safe Mode.
func _is_tool_run() -> bool:
	for arg: String in OS.get_cmdline_args():
		if arg == "-s" or arg == "--script":
			return true
	return false


func _open() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DIR))
	_rotate()
	path = "%s/%s.log" % [DIR, FILE_NAME]
	_file = FileAccess.open(path, FileAccess.WRITE)
	if _file == null:
		enabled = false


func _rotate() -> void:
	var dir_path: String = ProjectSettings.globalize_path(DIR)
	for index: int in range(LOGS_KEPT, 0, -1):
		var older: String = "%s/%s.%d.log" % [dir_path, FILE_NAME, index]
		var newer: String = "%s/%s.%d.log" % [dir_path, FILE_NAME, index - 1] if index > 1 else "%s/%s.log" % [dir_path, FILE_NAME]
		if FileAccess.file_exists(newer):
			if FileAccess.file_exists(older):
				DirAccess.remove_absolute(older)
			DirAccess.rename_absolute(newer, older)


func _write_header() -> void:
	var stamp: Dictionary = Time.get_datetime_dict_from_system()
	info("boot", "The Wayward Path v%s, launch %d, %04d-%02d-%02d %02d:%02d:%02d, %s build" % [
		str(ProjectSettings.get_setting("application/config/version", "?")), launch_number, stamp.year, stamp.month, stamp.day,
		stamp.hour, stamp.minute, stamp.second, "debug" if OS.is_debug_build() else "release"])
	info("boot", "previous launch ended at: %s" % (previous_stage if not previous_stage.is_empty() else "(first launch)"))
	info("boot", "OS: %s %s, %s, %d CPU threads, RAM %s" % [OS.get_name(), OS.get_version(), OS.get_processor_name(),
		OS.get_processor_count(), _ram_text()])
	for line: String in GpuInfo.describe_lines():
		info("boot", line)
	info("boot", "command line: %s" % " ".join(OS.get_cmdline_args()))


func _ram_text() -> String:
	var memory: Dictionary = OS.get_memory_info()
	var physical: int = int(memory.get("physical", -1))
	return "%.1f GB" % (float(physical) / 1073741824.0) if physical > 0 else "unknown"


## A routine line ("category: message"), flushed at once.
func info(category: String, message: String) -> void:
	_write("%s %s: %s" % [_clock(), category, message], false)


## A warning: always written (even past the size cap) and also sent to the engine log.
func warn(category: String, message: String) -> void:
	_write("%s WARNING %s: %s" % [_clock(), category, message], true)
	push_warning("%s: %s" % [category, message])


## The last step the main thread reported (the watchdog thread names it when the main thread stops).
func step(category: String, message: String) -> void:
	_last_step = "%s: %s" % [category, message]
	info(category, message)


func modal_opened(what: String) -> void:
	open_modals[what] = int(open_modals.get(what, 0)) + 1
	info("ui", "open %s" % what)


func modal_closed(what: String) -> void:
	var count: int = int(open_modals.get(what, 0)) - 1
	if count <= 0:
		open_modals.erase(what)
	else:
		open_modals[what] = count
	info("ui", "close %s" % what)


## SceneManager reports a revealed scene: after PLAYING_AFTER seconds of frames the boot stage says the game is playable.
func scene_revealed(scene: String) -> void:
	info("memory", "after %s: %s" % [scene, memory_text()])
	_playing_scene = scene
	_playing_left = PLAYING_AFTER


## A scene change began: a crash from here until it is playing makes the next launch start in Safe Mode.
func scene_loading(scene: String) -> void:
	_playing_left = -1.0
	BootGuard.set_stage("loading %s" % scene)


func title_reached() -> void:
	info("boot", "title screen shown")
	BootGuard.set_stage("title")


func clean_exit() -> void:
	info("boot", "quit")
	BootGuard.set_stage("exit")


func _clock() -> String:
	return "[%8.1f]" % (float(Time.get_ticks_msec() - _started_msec) / 1000.0)


func _write(line: String, important: bool) -> void:
	if not enabled or _file == null:
		return
	_mutex.lock()
	if _bytes < MAX_BYTES or important:
		_file.store_line(line)
		_file.flush()
		_bytes += line.length() + 1
	elif not _capped:
		_capped = true
		_file.store_line("%s log: size cap reached, routine lines stop here (warnings still come)" % _clock())
		_file.flush()
	_mutex.unlock()


func _process(delta: float) -> void:
	_tick_msec = Time.get_ticks_msec()
	if not enabled:
		return
	_frames_since_beat += 1
	if _playing_left > 0.0:
		_playing_left -= delta
		if _playing_left <= 0.0:
			BootGuard.set_stage("playing %s" % _playing_scene)
	_beat_left -= delta
	if _beat_left <= 0.0:
		var seconds: float = HEARTBEAT - _beat_left
		_beat_left = HEARTBEAT
		info("beat", heartbeat_text(float(_frames_since_beat) / maxf(seconds, 0.001)))
		_frames_since_beat = 0


## Objects, resources and video memory now (a leak across area changes shows as numbers that only grow).
func memory_text() -> String:
	return "objects %d, resources %d, nodes %d, video memory %d MB (textures %d MB, buffers %d MB), RAM %d MB" % [
		int(Performance.get_monitor(Performance.OBJECT_COUNT)), int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)),
		int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)), int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0),
		int(Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / 1048576.0), int(Performance.get_monitor(Performance.RENDER_BUFFER_MEM_USED) / 1048576.0),
		int(OS.get_static_memory_usage() / 1048576)]


## One heartbeat line (also used by tests): scene, transition state, lock, modals, fps.
func heartbeat_text(fps: float) -> String:
	var tree: SceneTree = get_tree()
	var scene: Node = tree.current_scene if tree != null else null
	var scene_name: String = str(scene.name) if scene != null else "(none)"
	var lock_text: String = "-"
	if scene != null and "_locked" in scene:
		lock_text = "locked" if bool(scene.get("_locked")) else "free"
	var modals: PackedStringArray = []
	for key: Variant in open_modals.keys():
		modals.append(str(key))
	var manager: Node = tree.root.get_node_or_null("SceneManager") if tree != null else null
	var busy_text: String = "no"
	if manager != null and bool(manager.get("busy")):
		busy_text = "yes (%s, %.0f s)" % [str(manager.get("phase")), float(manager.call("busy_seconds"))]
	return "scene=%s busy=%s hero=%s modals=[%s] paused=%s fps=%.0f mem=%d MB" % [scene_name, busy_text, lock_text,
		", ".join(modals), str(tree.paused) if tree != null else "?", fps, int(OS.get_static_memory_usage() / 1048576)]


## Runs on the watchdog thread: writes (only) when the main thread stops finishing frames, and when it comes back.
func _watch_main_thread() -> void:
	while _watchdog_running:
		OS.delay_msec(500)
		var now: int = Time.get_ticks_msec()
		var quiet: int = now - _tick_msec
		if not _stall_reported and quiet > int(STALL_SECONDS * 1000.0):
			_stall_reported = true
			_stall_started_msec = _tick_msec
			_write("%s WARNING stall: the main thread has not finished a frame for %.0f s (last step: %s)" % [_clock(),
				float(quiet) / 1000.0, _last_step], true)
			BootGuard.set_stage("stalled (%s)" % _last_step)
		elif _stall_reported and quiet < 1000:
			_stall_reported = false
			_write("%s stall: the main thread is back after %.1f s" % [_clock(), float(_tick_msec - _stall_started_msec) / 1000.0], true)
			BootGuard.restore_stage()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and enabled:
		clean_exit()
	elif what == NOTIFICATION_PREDELETE:
		_stop_watchdog()


func _exit_tree() -> void:
	_stop_watchdog()


func _stop_watchdog() -> void:
	if _watchdog != null and _watchdog.is_started():
		_watchdog_running = false
		_watchdog.wait_to_finish()
	_watchdog = null
