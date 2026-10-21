class_name BootGuard
extends RefCounted
## Overnight Oct 20 (playtest stability): crash-safe start. user://boot_state.cfg keeps how far the last launch got:
##   starting -> title -> loading <scene> -> playing <scene> ... -> exit        (stalled (<step>) while the main thread is stuck)
## A launch that ended while "starting", "loading ..." or "stalled ..." did not get to a playable picture (a crash, a hang the tester
## closed): the next launch starts in Safe Mode (Settings drops to Low with the risky effects off and says so on the title screen).
## Two bad launches in a row also try the other rendering driver (D3D12 <-> Vulkan; Settings restarts the game with it).
## `GameLog` drives the stages; `-s` tool runs leave the file alone (`active`).

## Off until GameLog switches it on in a real launch (GUT, tools and the editor never touch the player's boot stage).
static var active: bool = false
static var path: String = "user://boot_state.cfg"
static var _stage: String = ""
static var _stage_before_stall: String = ""
static var _launch: int = 0
static var _bad_in_a_row: int = 0
static var _mutex: Mutex = Mutex.new()

## The user argument the "Start (Safe Mode).bat" launcher passes (after `--`).
const SAFE_MODE_ARG: String = "--safe-mode"


## Reads the last launch, writes "starting" for this one. Returns {previous_stage, launch, bad_in_a_row, safe_mode_reason, other_driver}.
static func begin_launch(user_args: PackedStringArray) -> Dictionary:
	var config: ConfigFile = ConfigFile.new()
	config.load(path)
	var previous: String = str(config.get_value("boot", "stage", ""))
	var last_driver: String = str(config.get_value("boot", "driver", ""))
	_launch = int(config.get_value("boot", "launches", 0)) + 1
	var bad: bool = is_bad_end(previous)
	_bad_in_a_row = int(config.get_value("boot", "bad_in_a_row", 0)) + 1 if bad else 0
	var reason: String = ""
	if user_args.has(SAFE_MODE_ARG):
		reason = "started from the Safe Mode launcher"
	elif bad and active:
		reason = "the last launch stopped before the game was playable (it ended while %s)" % previous
	var other_driver: String = ""
	if _bad_in_a_row >= 2 and not last_driver.is_empty() and active:
		other_driver = "vulkan" if last_driver == "d3d12" else "d3d12"
	_stage = ""
	if active:
		config.set_value("boot", "launches", _launch)
		config.set_value("boot", "bad_in_a_row", _bad_in_a_row)
		config.set_value("boot", "previous_stage", previous)
		config.set_value("boot", "driver", RenderingServer.get_current_rendering_driver_name())
		config.set_value("boot", "safe_mode", not reason.is_empty())
		config.save(path)
	set_stage("starting")
	return {"previous_stage": previous, "launch": _launch, "bad_in_a_row": _bad_in_a_row, "safe_mode_reason": reason, "other_driver": other_driver}


## True for a stage a healthy launch never ends in.
static func is_bad_end(stage: String) -> bool:
	return stage == "starting" or stage.begins_with("loading") or stage.begins_with("stalled")


static func stage() -> String:
	return _stage


## Safe to call from the watchdog thread.
static func set_stage(value: String) -> void:
	_mutex.lock()
	if value.begins_with("stalled") and not _stage.begins_with("stalled"):
		_stage_before_stall = _stage
	_stage = value
	if active:
		var config: ConfigFile = ConfigFile.new()
		config.load(path)
		config.set_value("boot", "stage", value)
		if value.begins_with("playing") or value == "title" or value == "exit":
			config.set_value("boot", "bad_in_a_row", 0)
		config.save(path)
	_mutex.unlock()


## The main thread came back after a stall: the stage it was in before.
static func restore_stage() -> void:
	if _stage.begins_with("stalled"):
		set_stage(_stage_before_stall if not _stage_before_stall.is_empty() else "starting")
