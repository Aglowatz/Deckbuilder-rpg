class_name Hitch
extends RefCounted
## Overnight Oct 16 (Block 5b): a tiny hitch logger. With the environment variable HITCH_LOG set, `start`/`stop` round a piece of per-frame
## work and print it when it took more than 8 ms - the way the Capital's load hitches were found. Free when HITCH_LOG is unset.

static var enabled: bool = OS.get_environment("HITCH_LOG") != "" or OS.get_environment("HITCH_PROFILE") != ""
## Performance pass Oct 25: with HITCH_PROFILE set every start/stop pair is summed instead, and the average per frame of each label is printed
## every 5 s ("hitch_profile:") - which piece of a scene's `_process` costs what.
static var profile: bool = OS.get_environment("HITCH_PROFILE") != ""
static var _started: Dictionary = {}
static var _totals: Dictionary = {}
static var _profile_frame: int = -1
static var _profile_frames: int = 0
static var _profile_usec: int = 0


static func start(label: String) -> void:
	if enabled:
		_started[label] = Time.get_ticks_usec()


static func stop(label: String) -> void:
	if not enabled or not _started.has(label):
		return
	var spent: float = float(Time.get_ticks_usec() - int(_started[label])) / 1000.0
	if profile:
		_add(label, spent)
		return
	if spent > 8.0:
		print("hitch: %s %.1f ms" % [label, spent])


static func _add(label: String, spent_ms: float) -> void:
	_totals[label] = float(_totals.get(label, 0.0)) + spent_ms
	var frame: int = Engine.get_process_frames()
	if frame != _profile_frame:
		_profile_frame = frame
		_profile_frames += 1
	var now: int = Time.get_ticks_usec()
	if _profile_usec == 0:
		_profile_usec = now
	if now - _profile_usec < 5000000:
		return
	var parts: PackedStringArray = []
	var labels: Array = _totals.keys()
	labels.sort_custom(func(a: Variant, b: Variant) -> bool: return float(_totals[a]) > float(_totals[b]))
	for key: Variant in labels:
		parts.append("%s %.3f" % [key, float(_totals[key]) / float(maxi(1, _profile_frames))])
	print("hitch_profile: ms per frame over %d frames: %s" % [_profile_frames, ", ".join(parts)])
	_totals.clear()
	_profile_frames = 0
	_profile_usec = now
