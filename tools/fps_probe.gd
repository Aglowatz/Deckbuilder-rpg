extends SceneTree
## Frame-time probe (run NOT headless): Godot --path . -s res://tools/fps_probe.gd -- --scene=res://scenes/town.tscn --quality=1 [--at=anchor] [--seconds=6]
## Vsync is turned off so the numbers show the real headroom. Prints "fps_probe: <scene> quality=<n> avg_fps=<x> avg_ms=<y> p95_ms=<z> min_fps=<w>".

var _args: Dictionary = {}
var _started: bool = false
var _elapsed: float = 0.0
var _scene: Node
var _frames: PackedFloat32Array = []
var _warm: float = 3.0
var _seconds: float = 6.0


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			_args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	_seconds = float(_args.get("seconds", 6.0))
	root.size = Vector2i(1600, 900)
	DisplayServer.window_set_size(Vector2i(1600, 900))
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0


func _process(delta: float) -> bool:
	if not _started:
		_started = true
		root.get_node("Session").set("save_enabled", false)
		root.get_node("Settings").set("graphics_quality", int(_args.get("quality", 1)))
		root.get_node("Settings").set("depth_of_field", _args.has("dof"))
		var packed: PackedScene = load(str(_args.get("scene", "res://scenes/town.tscn"))) as PackedScene
		_scene = packed.instantiate()
		if _scene.has_method("screenshot_prepare"):
			_scene.call("screenshot_prepare", _args)
		root.add_child(_scene)
		return false
	_elapsed += delta
	if _elapsed < _warm:
		return false
	_frames.append(delta)
	if _elapsed < _warm + _seconds:
		return false
	var sorted: Array = Array(_frames)
	sorted.sort()
	var total: float = 0.0
	for value: float in _frames:
		total += value
	var avg: float = total / float(_frames.size())
	var p95: float = float(sorted[int(float(sorted.size()) * 0.95)])
	print("fps_probe_stats: draw_calls=%d objects=%d primitives=%d process_ms=%.2f" % [Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME), Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME), Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME), Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0])
	print("fps_probe: %s quality=%s avg_fps=%.1f avg_ms=%.2f p95_ms=%.2f min_fps=%.1f" % [str(_args.get("scene")), str(_args.get("quality", 1)), 1.0 / avg, avg * 1000.0, p95 * 1000.0, 1.0 / float(sorted[sorted.size() - 1])])
	quit(0)
	return true
