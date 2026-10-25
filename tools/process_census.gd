extends SceneTree
## Performance pass Oct 25: which scripts cost frame time. Run NOT headless, alone:
## Godot --path . -s res://tools/process_census.gd -- --scene=res://scenes/town.tscn --quality=0 [--pos=x,z] [--top=12]
## Counts the nodes that run `_process` / `_physics_process` per script (or class), then switches each of the `--top` biggest groups off for a
## few seconds between two baseline spans (A/B) and prints the average frame time without it (vsync off), plus every script paused. A big drop = a cost worth cutting.
## Also tries a tiny render scale: if the frame time barely moves the area is CPU-bound there.

const WARM: float = 9.0
const SPAN: float = 2.0

var _args: Dictionary = {}
var _scene: Node
var _timer: float = 0.0
var _frames: PackedFloat32Array = []
var _stage: int = -2
var _groups: Array[Dictionary] = []
var _undo: Array[Callable] = []
var _base_ms: float = 0.0


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			_args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	root.size = Vector2i(1600, 900)
	DisplayServer.window_set_size(Vector2i(1600, 900))
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0


func _key(node: Node) -> String:
	var script: Script = node.get_script() as Script
	if script != null:
		var name_text: String = str(script.get_global_name())
		return name_text if not name_text.is_empty() else script.resource_path.get_file()
	return node.get_class()


func _collect() -> void:
	var by_key: Dictionary = {}
	var stack: Array[Node] = [_scene]
	for child: Node in root.get_children():
		if child != _scene:
			stack.append(child)
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		for child: Node in node.get_children():
			stack.append(child)
		var proc: bool = node.is_processing()
		var phys: bool = node.is_physics_processing()
		if not proc and not phys:
			continue
		var key: String = _key(node)
		if not by_key.has(key):
			by_key[key] = {"key": key, "nodes": [] as Array[Node], "proc": 0, "phys": 0}
		var group: Dictionary = by_key[key]
		(group["nodes"] as Array[Node]).append(node)
		group["proc"] = int(group["proc"]) + (1 if proc else 0)
		group["phys"] = int(group["phys"]) + (1 if phys else 0)
	for key: String in by_key:
		_groups.append(by_key[key])
	_groups.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return (a["nodes"] as Array).size() > (b["nodes"] as Array).size())
	print("process_census: %d script groups run per frame" % _groups.size())
	for group: Dictionary in _groups:
		print("process_census:   %-28s nodes %4d  process %4d  physics %4d" % [group["key"], (group["nodes"] as Array).size(), group["proc"], group["phys"]])


func _pause(group: Dictionary) -> void:
	for node: Node in group["nodes"] as Array[Node]:
		if not is_instance_valid(node):
			continue
		var proc: bool = node.is_processing()
		var phys: bool = node.is_physics_processing()
		node.set_process(false)
		node.set_physics_process(false)
		_undo.append(func() -> void:
			if is_instance_valid(node):
				node.set_process(proc)
				node.set_physics_process(phys))


func _process(delta: float) -> bool:
	if _stage == -2:
		_stage = -1
		root.get_node("Session").set("save_enabled", false)
		var settings: Node = root.get_node("Settings")
		settings.set("graphics_quality", int(_args.get("quality", 0)))
		settings.set("vsync", false)
		settings.set("max_fps", 0)
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		Engine.max_fps = 0
		_scene = (load(str(_args.get("scene", "res://scenes/town.tscn"))) as PackedScene).instantiate()
		if _scene.has_method("screenshot_prepare"):
			_scene.call("screenshot_prepare", _args)
		root.add_child(_scene)
		return false
	_timer += delta
	if _stage == -1:
		if _timer < WARM:
			return false
		_collect()
		_make_plan()
		_stage = 0
		_timer = 0.0
		_frames.clear()
		_start_step()
		return false
	if _timer < 0.4:
		return false  # let the change settle
	_frames.append(delta)
	if _timer < 0.4 + SPAN:
		return false
	var total: float = 0.0
	for value: float in _frames:
		total += value
	var ms: float = total / float(_frames.size()) * 1000.0
	var step: Dictionary = _plan[_stage]
	if str(step["label"]) == "base":
		_last_base = ms
	else:
		# Each "without" step sits between two baseline steps: compare with the one before it (A/B, so slow drifts cancel out).
		print("process_census: without %-28s %.2f ms (%+.2f vs %.2f)" % [step["label"], ms, ms - _last_base, _last_base])
	for undo: Callable in _undo:
		undo.call()
	_undo.clear()
	_stage += 1
	_timer = 0.0
	_frames.clear()
	if _stage >= _plan.size():
		quit(0)
		return true
	_start_step()
	return false


var _plan: Array[Dictionary] = []
var _last_base: float = 0.0


func _make_plan() -> void:
	var top: int = mini(int(_args.get("top", 12)), _groups.size())
	for index: int in range(mini(int(_args.get("skip", 0)), top), top):
		var group: Dictionary = _groups[index]
		_plan.append({"label": "base", "run": Callable()})
		_plan.append({"label": str(group["key"]), "run": _pause.bind(group)})
	_plan.append({"label": "base", "run": Callable()})
	_plan.append({"label": "every script", "run": func() -> void:
		for group: Dictionary in _groups:
			_pause(group)})
	_plan.append({"label": "base", "run": Callable()})
	_plan.append({"label": "render scale 0.25", "run": func() -> void:
		var before: float = root.scaling_3d_scale
		root.scaling_3d_scale = 0.25
		_undo.append(func() -> void: root.scaling_3d_scale = before)})


func _start_step() -> void:
	var run: Callable = _plan[_stage]["run"] as Callable
	if run.is_valid():
		run.call()
