extends Node
## Overnight Oct 28-29, Part 5 (docs/perf/report.md, "Memory leak"): fails when memory grows across Crosspath round trips. One warm-up lap
## first (every zone and the Forgotten Cave once: first-visit caches fill legitimately), then `--trips` (default 10) measured round trips
## Crosspath -> a zone or the cave -> Crosspath. In town after each trip: static memory, video memory, objects. Fails when the last town
## reading is more than LIMIT_MB above the first measured one (static or video), or OBJECT_LIMIT objects more.
## Windowed, alone: bash tools/run_memory_roundtrip_smoke.sh   (or Godot --path . --resolution 1280x720 res://tools/memory_roundtrip_smoke.tscn)

const ROUTE: Array[String] = ["beefcake", "necrocrat", "gourmand", "refusemancer", "final", "cave"]
const LIMIT_MB: float = 5.0
const OBJECT_LIMIT: int = 200

var _trips: int = 10
var _failures: int = 0
var worker: bool = false


func _ready() -> void:
	# The launcher scene is freed by the first scene change: run from a copy under the root (as tools/memory_probe.gd does).
	if not worker:
		var copy: Node = (get_script() as GDScript).new()
		copy.set("worker", true)
		get_tree().root.add_child.call_deferred(copy)
		return
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--trips="):
			_trips = arg.get_slice("=", 1).to_int()
	_run.call_deferred()


func _run() -> void:
	Session.save_enabled = false
	SceneManager.show_loading_screens = false
	Session.ensure_game()
	await _go("town", func() -> void: SceneManager.change_scene("res://scenes/town.tscn"))
	print("memory_roundtrip: warm-up lap (%s)" % ", ".join(ROUTE))
	for place: String in ROUTE:
		await _trip(place)
	var first: Dictionary = _reading()
	_print("start", first)
	var last: Dictionary = first
	for index: int in range(_trips):
		var place: String = ROUTE[index % ROUTE.size()]
		await _trip(place)
		last = _reading()
		_print("trip %2d (%s)" % [index + 1, place], last)
	var grow_static: float = float(last["static"]) - float(first["static"])
	var grow_video: float = float(last["video"]) - float(first["video"])
	var grow_objects: int = int(last["objects"]) - int(first["objects"])
	_check(grow_static <= LIMIT_MB, "static memory flat over %d trips (%+.1f MB)" % [_trips, grow_static])
	_check(grow_video <= LIMIT_MB, "video memory flat over %d trips (%+.1f MB)" % [_trips, grow_video])
	_check(grow_objects <= OBJECT_LIMIT, "objects flat over %d trips (%+d)" % [_trips, grow_objects])
	print("memory_roundtrip: %s - %d round trips, static %+.1f MB, video %+.1f MB, objects %+d" % ["OK" if _failures == 0 else "FAILED", _trips, grow_static, grow_video, grow_objects])
	get_tree().quit(0 if _failures == 0 else 1)


func _trip(place: String) -> void:
	if place == "cave":
		await _go("cave", func() -> void: Session.begin_trial())
	else:
		await _go(place, func() -> void: Session.enter_zone(place))
	await _go("town", func() -> void: SceneManager.change_scene("res://scenes/town.tscn"))


## Waits for the scene manager to be idle, changes scene, waits until a different scene is current and the manager is idle again, then settles.
func _go(label: String, change: Callable) -> void:
	var waited: float = 0.0
	while SceneManager.busy and waited < 30.0:
		await get_tree().create_timer(0.25).timeout
		waited += 0.25
	var before: Node = get_tree().current_scene
	change.call()
	waited = 0.0
	while waited < 45.0:
		var scene: Node = get_tree().current_scene
		if scene != null and scene != before and not SceneManager.busy:
			break
		await get_tree().create_timer(0.25).timeout
		waited += 0.25
	if get_tree().current_scene == before:
		_check(false, "reached %s" % label)
	await get_tree().create_timer(2.5).timeout


func _reading() -> Dictionary:
	return {
		"static": OS.get_static_memory_usage() / 1048576.0,
		"video": Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0,
		"textures": Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / 1048576.0,
		"objects": int(Performance.get_monitor(Performance.OBJECT_COUNT)),
		"nodes": int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),
	}


func _print(label: String, reading: Dictionary) -> void:
	print("memory_roundtrip: %-22s static %6.1f MB, video %6.1f MB, textures %6.1f MB, objects %d, nodes %d" % [label, float(reading["static"]),
		float(reading["video"]), float(reading["textures"]), int(reading["objects"]), int(reading["nodes"])])


func _check(ok: bool, what: String) -> void:
	print("memory_roundtrip: %s  %s" % ["ok  " if ok else "FAIL", what])
	if not ok:
		_failures += 1
