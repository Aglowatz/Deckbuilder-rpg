extends SceneTree
## Performance pass Oct 25 (docs/perf/perf_state.md): one area's full numbers in a real window (run NOT headless, one Godot at a time).
## Godot --path . -s res://tools/perf_probe.gd -- --scene=res://scenes/town.tscn --quality=1 [--pos=x,z] [--open=deck] [--seconds=6] [--warm=3]
## Prints one "perf_probe:" line of key=value pairs: load_ms (load + instantiate + _ready), first_ms (first frame after the build),
## worst_ms (worst frame in the first 3 s after entering), avg/p1 fps (1% low = the 99th percentile frame), cpu/gpu ms of the viewport,
## process/physics ms (scripts), draw calls, objects, primitives, nodes, objects alive, Godot static memory, process working set (tasklist),
## texture / buffer / video memory. Vsync is off so the numbers show the real headroom (as tools/fps_probe.gd).

var _args: Dictionary = {}
var _started: bool = false
var _elapsed: float = 0.0
var _scene: Node
var _frames: PackedFloat32Array = []
var _warm: float = 3.0
var _seconds: float = 6.0
var _load_ms: float = 0.0
var _first_ms: float = -1.0
var _worst_ms: float = 0.0
var _entered_usec: int = 0
var _gpu: PackedFloat32Array = []
var _cpu: PackedFloat32Array = []
var _proc: PackedFloat32Array = []
var _phys: PackedFloat32Array = []


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			_args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	_seconds = float(_args.get("seconds", 6.0))
	_warm = float(_args.get("warm", 3.0))
	root.size = Vector2i(1600, 900)
	DisplayServer.window_set_size(Vector2i(1600, 900))
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0


func _process(delta: float) -> bool:
	if not _started:
		_started = true
		root.get_node("Session").set("save_enabled", false)
		var settings: Node = root.get_node("Settings")
		settings.set("graphics_quality", int(_args.get("quality", 1)))
		settings.set("depth_of_field", not _args.has("nodof"))
		settings.set("vsync", false)
		settings.set("max_fps", 0)
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		Engine.max_fps = 0
		for pair: String in str(_args.get("set", "")).split(",", false):
			var kv: PackedStringArray = pair.split(":")
			if kv.size() != 2:
				continue
			var current: Variant = settings.get(kv[0])
			if typeof(current) == TYPE_BOOL:
				settings.set(kv[0], kv[1] == "true")
			elif typeof(current) == TYPE_INT:
				settings.set(kv[0], int(kv[1]))
			elif typeof(current) == TYPE_FLOAT:
				settings.set(kv[0], float(kv[1]))
		var t0: int = Time.get_ticks_usec()
		var packed: PackedScene = load(str(_args.get("scene", "res://scenes/town.tscn"))) as PackedScene
		_scene = packed.instantiate()
		if _scene.has_method("screenshot_prepare"):
			_scene.call("screenshot_prepare", _args)
		root.add_child(_scene)
		_load_ms = float(Time.get_ticks_usec() - t0) / 1000.0
		_entered_usec = Time.get_ticks_usec()
		RenderingServer.viewport_set_measure_render_time(root.get_viewport_rid(), true)
		return false
	if _first_ms < 0.0:
		_first_ms = delta * 1000.0
	_elapsed += delta
	if _elapsed < 3.0:
		_worst_ms = maxf(_worst_ms, delta * 1000.0)
	if _elapsed < _warm:
		return false
	_frames.append(delta)
	var vp: RID = root.get_viewport_rid()
	_cpu.append(RenderingServer.viewport_get_measured_render_time_cpu(vp))
	_gpu.append(RenderingServer.viewport_get_measured_render_time_gpu(vp))
	_proc.append(Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0)
	_phys.append(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0)
	if _elapsed < _warm + _seconds:
		return false
	var sorted: Array = Array(_frames)
	sorted.sort()
	var avg: float = _mean(_frames)
	var p99: float = float(sorted[mini(sorted.size() - 1, int(float(sorted.size()) * 0.99))])
	var p95: float = float(sorted[int(float(sorted.size()) * 0.95)])
	var parts: PackedStringArray = []
	parts.append("area=%s" % str(_args.get("area", _args.get("scene"))))
	parts.append("quality=%s" % str(_args.get("quality", 1)))
	parts.append("avg_fps=%.1f" % (1.0 / avg))
	parts.append("avg_ms=%.2f" % (avg * 1000.0))
	parts.append("p95_ms=%.2f" % (p95 * 1000.0))
	parts.append("low1_fps=%.1f" % (1.0 / p99))
	parts.append("cpu_ms=%.2f" % _mean(_cpu))
	parts.append("gpu_ms=%.2f" % _mean(_gpu))
	parts.append("process_ms=%.2f" % _mean(_proc))
	parts.append("physics_ms=%.2f" % _mean(_phys))
	parts.append("draw_calls=%d" % int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)))
	parts.append("objects=%d" % int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)))
	parts.append("primitives=%d" % int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)))
	parts.append("nodes=%d" % int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)))
	parts.append("alive=%d" % int(Performance.get_monitor(Performance.OBJECT_COUNT)))
	parts.append("load_ms=%.0f" % _load_ms)
	parts.append("first_ms=%.0f" % _first_ms)
	parts.append("worst_ms=%.0f" % _worst_ms)
	parts.append("static_mb=%.0f" % (float(OS.get_static_memory_usage()) / 1048576.0))
	parts.append("tex_mb=%.0f" % (Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / 1048576.0))
	parts.append("buf_mb=%.0f" % (Performance.get_monitor(Performance.RENDER_BUFFER_MEM_USED) / 1048576.0))
	parts.append("vram_mb=%.0f" % (Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0))
	parts.append("ram_mb=%.0f" % _working_set_mb())
	print("perf_probe: " + " ".join(parts))
	quit(0)
	return true


func _mean(values: PackedFloat32Array) -> float:
	if values.is_empty():
		return 0.0
	var total: float = 0.0
	for value: float in values:
		total += value
	return total / float(values.size())


## The process working set from tasklist (Windows): "Image","PID","Session","#","123,456 K".
func _working_set_mb() -> float:
	var output: Array = []
	OS.execute("tasklist", ["/FI", "PID eq %d" % OS.get_process_id(), "/FO", "CSV", "/NH"], output)
	if output.is_empty():
		return -1.0
	var fields: PackedStringArray = str(output[0]).strip_edges().split("\",\"")
	if fields.size() < 5:
		return -1.0
	var kb: String = fields[4].replace("\"", "").replace(" K", "").replace(",", "").replace(".", "").strip_edges()
	return float(kb) / 1024.0
