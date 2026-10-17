class_name Hitch
extends RefCounted
## Overnight Oct 16 (Block 5b): a tiny hitch logger. With the environment variable HITCH_LOG set, `start`/`stop` round a piece of per-frame
## work and print it when it took more than 8 ms - the way the Capital's load hitches were found. Free when HITCH_LOG is unset.

static var enabled: bool = OS.get_environment("HITCH_LOG") != ""
static var _started: Dictionary = {}


static func start(label: String) -> void:
	if enabled:
		_started[label] = Time.get_ticks_usec()


static func stop(label: String) -> void:
	if not enabled or not _started.has(label):
		return
	var spent: float = float(Time.get_ticks_usec() - int(_started[label])) / 1000.0
	if spent > 8.0:
		print("hitch: %s %.1f ms" % [label, spent])
