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
	if _args.has("far"):
		_far_report(float(_args["far"]))
	if _args.has("drawlist"):
		_draw_report()
	if _args.has("meshlist"):
		_mesh_report()
	if _args.has("batchable"):
		_batch_report()
	if _args.has("lights"):
		# `--lights=true`: every light with its shadow switch (a stray shadowed light is a whole extra shadow pass)
		for node: Node in root.find_children("*", "Light3D", true, false):
			var light: Light3D = node as Light3D
			print("perf_probe_light: %s %s visible=%s shadow=%s energy=%.2f" % [light.get_path(), light.get_class(), str(light.is_visible_in_tree()), str(light.shadow_enabled), light.light_energy])
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


## `--far=60`: the visible meshes whose box centre is farther than that from the camera, by triangle count (MultiMesh: per instance x instances),
## with whether the mesh has LODs - where the far primitives come from.
func _far_report(distance: float) -> void:
	var cam: Camera3D = root.get_viewport().get_camera_3d()
	if cam == null:
		return
	var rows: Array = []
	var total: int = 0
	for node: Node in root.find_children("*", "GeometryInstance3D", true, false):
		var geo: GeometryInstance3D = node as GeometryInstance3D
		if not geo.is_visible_in_tree():
			continue
		var mesh: Mesh = null
		var count: int = 1
		if geo is MeshInstance3D:
			mesh = (geo as MeshInstance3D).mesh
		elif geo is MultiMeshInstance3D and (geo as MultiMeshInstance3D).multimesh != null:
			mesh = (geo as MultiMeshInstance3D).multimesh.mesh
			count = (geo as MultiMeshInstance3D).multimesh.instance_count
		if mesh == null:
			continue
		var box: AABB = geo.global_transform * geo.get_aabb()
		var d: float = cam.global_position.distance_to(box.get_center())
		if d < distance:
			continue
		var tris: int = 0
		var lods: int = 0
		for i: int in range(mesh.get_surface_count()):
			var arrays: Array = mesh.surface_get_arrays(i) if mesh is ArrayMesh else []
			if arrays.is_empty():
				continue
			var idx: Variant = arrays[Mesh.ARRAY_INDEX]
			tris += (idx as PackedInt32Array).size() / 3 if idx != null and (idx as PackedInt32Array).size() > 0 else (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() / 3
		if mesh is ArrayMesh and mesh.get_surface_count() > 0:
			lods = RenderingServer.mesh_surface_get_arrays(mesh.get_rid(), 0).size()  # (presence only)
		total += tris * count
		rows.append([tris * count, "%s tris=%d x%d d=%.0f size=%.0f %s" % [geo.get_path(), tris, count, d, box.get_longest_axis_size(), mesh.resource_path]])
	rows.sort_custom(func(a: Array, b: Array) -> bool: return int(a[0]) > int(b[0]))
	print("perf_probe_far: %d triangles in meshes farther than %.0f m" % [total, distance])
	for index: int in range(mini(30, rows.size())):
		print("perf_probe_far:   %7d  %s" % [rows[index][0], rows[index][1]])


## `--drawlist=true`: visible geometry grouped by node name (digits and @ ids stripped): instances, surfaces (about one draw call each per pass),
## and how many cast shadows - where the draw calls come from.
func _draw_report() -> void:
	var groups: Dictionary = {}
	var regex: RegEx = RegEx.create_from_string("[0-9@_()., -]+")
	for node: Node in root.find_children("*", "GeometryInstance3D", true, false):
		var geo: GeometryInstance3D = node as GeometryInstance3D
		if not geo.is_visible_in_tree():
			continue
		var mesh: Mesh = null
		if geo is MeshInstance3D:
			mesh = (geo as MeshInstance3D).mesh
		elif geo is MultiMeshInstance3D and (geo as MultiMeshInstance3D).multimesh != null:
			mesh = (geo as MultiMeshInstance3D).multimesh.mesh
		var surfaces: int = mesh.get_surface_count() if mesh != null else 1
		var key: String = "%s/%s" % [regex.sub(str(geo.get_parent().name), "", true), regex.sub(str(geo.name), "", true)]
		var row: Array = groups.get(key, [0, 0, 0])
		row[0] += 1
		row[1] += surfaces
		row[2] += surfaces if geo.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF else 0
		groups[key] = row
	var keys: Array = groups.keys()
	keys.sort_custom(func(a: Variant, b: Variant) -> bool: return int(groups[a][1]) > int(groups[b][1]))
	for index: int in range(mini(30, keys.size())):
		var row: Array = groups[keys[index]]
		print("perf_probe_draw: %5d surfaces %4d nodes %4d shadowed  %s" % [row[1], row[0], row[2], keys[index]])


## `--meshlist=true`: visible MeshInstance3D nodes grouped by the mesh they draw (repeats of one mesh could be one MultiMesh draw).
func _mesh_report() -> void:
	var groups: Dictionary = {}
	for node: Node in root.find_children("*", "MeshInstance3D", true, false):
		var mi: MeshInstance3D = node as MeshInstance3D
		if not mi.is_visible_in_tree() or mi.mesh == null:
			continue
		var key: String = mi.mesh.resource_path if not mi.mesh.resource_path.is_empty() else "(runtime %s)" % mi.mesh.get_class()
		var row: Array = groups.get(key, [0, 0, 0, str(mi.get_path())])
		row[0] += 1
		row[1] += mi.mesh.get_surface_count()
		row[2] += 1 if mi.material_override != null else 0
		groups[key] = row
	var keys: Array = groups.keys()
	keys.sort_custom(func(a: Variant, b: Variant) -> bool: return int(groups[a][1]) > int(groups[b][1]))
	for index: int in range(mini(25, keys.size())):
		var row: Array = groups[keys[index]]
		print("perf_probe_mesh: %4d nodes %4d surfaces %4d overrides  %s  e.g. %s" % [row[0], row[1], row[2], keys[index], row[3]])


## `--batchable=true`: how many plain MeshInstance3D nodes share mesh + material + shadow mode + direct parent (could be one MultiMesh each).
func _batch_report() -> void:
	var groups: Dictionary = {}
	var plain: int = 0
	for node: Node in root.find_children("*", "MeshInstance3D", true, false):
		var mi: MeshInstance3D = node as MeshInstance3D
		if not mi.is_visible_in_tree() or mi.mesh == null or mi.get_script() != null or mi.get_child_count() > 0:
			continue
		plain += 1
		var key: String = "%d|%d|%d|%d" % [mi.mesh.get_rid().get_id(), mi.material_override.get_instance_id() if mi.material_override != null else 0, mi.cast_shadow, mi.get_parent().get_instance_id()]
		groups[key] = int(groups.get(key, 0)) + 1
	var merged: int = 0
	var groups_of_two: int = 0
	for key: String in groups.keys():
		if int(groups[key]) >= 2:
			merged += int(groups[key])
			groups_of_two += 1
	print("perf_probe_batch: %d plain meshes; %d of them share mesh+material+shadow+parent with another, in %d groups" % [plain, merged, groups_of_two])
