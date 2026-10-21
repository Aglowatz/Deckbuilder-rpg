class_name LoadTiming
extends RefCounted
## v0.4.2 hotfix: where a scene change spends its time. `begin` starts a load (SceneManager.change_scene), `mark` notes a step (the town's
## build steps), `summary` prints one line to the game log when the new scene is revealed. With the environment variable LOAD_TIMING set
## every step is printed too, the way the first-arrival freeze in Crosspath was found.

static var verbose: bool = OS.get_environment("LOAD_TIMING") != ""
static var _what: String = ""
static var _started_usec: int = 0
static var _last_usec: int = 0
static var _steps: Array[String] = []
static var _slowest_label: String = ""
static var _slowest_ms: float = 0.0
## The load's length when the scene was revealed (-1 while it is still loading).
static var _finished_ms: float = -1.0
static var _last_label: String = ""


static func begin(what: String) -> void:
	_what = what
	_started_usec = Time.get_ticks_usec()
	_last_usec = _started_usec
	_steps.clear()
	_slowest_label = ""
	_slowest_ms = 0.0
	_finished_ms = -1.0
	_last_label = ""


## Notes the time since the previous mark under `label`. Overnight Oct 20: every step also goes to the game log (GameLog), so a
## tester's log shows the last step a load reached.
static func mark(label: String) -> void:
	if _started_usec == 0:
		begin("(no load)")
	var now: int = Time.get_ticks_usec()
	var spent: float = float(now - _last_usec) / 1000.0
	_last_usec = now
	_last_label = label
	_steps.append("%s %.0f" % [label, spent])
	_log_step("%s +%.0f ms  %s" % [_what, spent, label])
	if spent > _slowest_ms:
		_slowest_ms = spent
		_slowest_label = label
	if verbose:
		print("load_timing: %s +%.0f ms  %s  (%.0f ms in)" % [_what, spent, label, elapsed_ms()])


static func _log_step(text: String) -> void:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var game_log: Node = tree.root.get_node_or_null("GameLog") if tree != null else null
	if game_log != null:
		game_log.call(&"step", "load", text)


## When the last step was marked (Time.get_ticks_usec; the SceneManager watchdog reads it as progress).
static func last_mark_usec() -> int:
	return _last_usec


static func last_step() -> String:
	return "%s: %s" % [_what, _last_label] if not _last_label.is_empty() else _what


static func elapsed_ms() -> float:
	return float(Time.get_ticks_usec() - _started_usec) / 1000.0 if _started_usec > 0 else 0.0


## The scene is revealed: the load's length is kept for the summary.
static func finish() -> float:
	_finished_ms = elapsed_ms()
	return _finished_ms


## The slowest step so far ("label", ms).
static func slowest() -> Array:
	return [_slowest_label, _slowest_ms]


static func steps() -> Array[String]:
	return _steps.duplicate()


static func summary_line() -> String:
	return "load_timing: %s %.0f ms (slowest step: %s %.0f ms)" % [_what, _finished_ms if _finished_ms >= 0.0 else elapsed_ms(), _slowest_label, _slowest_ms]
