extends SceneTree
## Performance pass Oct 25, Part 5 (docs/perf/budgets.md): the headless half of the performance budget check. Builds each area once (no window,
## no GPU) and counts what costs frame time on every PC - nodes, mesh instances, MultiMesh instances, lights, particle emitters, 3D labels and
## the nodes that run a script every frame - against `docs/perf/budgets.json` ("structure"). Exit code 1 when any area is over a budget.
## Godot --headless --path . -s res://tools/perf_budget.gd [-- --areas=crosspath,gainlands] [--quality=1]
## The windowed half (frame time, draw calls, memory on this PC) is tools/perf_budget.sh.

const BUDGETS: String = "res://docs/perf/budgets.json"
const AREAS: Dictionary = {
	"crosspath": ["res://scenes/town.tscn", {"quiet": "true", "pos": "25.2,19.5"}],
	"forest": ["res://scenes/starting_area.tscn", {"quiet": "true"}],
	"gainlands": ["res://scenes/gainlands_zone.tscn", {}],
	"buffet": ["res://scenes/buffet_zone.tscn", {}],
	"dna": ["res://scenes/dna_zone.tscn", {}],
	"heap": ["res://scenes/heap_zone.tscn", {}],
	"capital": ["res://scenes/capital_zone.tscn", {}],
}

var _args: Dictionary = {}
var _queue: Array[String] = []
var _scene: Node
var _frames: int = 0
var _budgets: Dictionary = {}
var _failures: PackedStringArray = []
var _rows: PackedStringArray = []


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			_args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(BUDGETS))
	_budgets = (parsed as Dictionary).get("structure", {}) as Dictionary if parsed is Dictionary else {}
	for area: String in str(_args.get("areas", ",".join(AREAS.keys()))).split(",", false):
		if AREAS.has(area):
			_queue.append(area)
	_rows.append("| Area | nodes | meshes | multimesh instances | lights | particles | labels | per-frame scripts |")
	_rows.append("|---|---|---|---|---|---|---|---|")


func _process(_delta: float) -> bool:
	if _scene != null:
		_frames += 1
		if _frames < 4:
			return false
		_measure(str(_scene.get_meta(&"budget_area")))
		_scene.queue_free()
		_scene = null
		return false
	if _queue.is_empty():
		print("\n".join(_rows))
		if _failures.is_empty():
			print("perf_budget: structure OK")
			quit(0)
		else:
			for line: String in _failures:
				print("perf_budget: OVER ", line)
			quit(1)
		return true
	var area: String = _queue.pop_front()
	var entry: Array = AREAS[area]
	root.get_node("Session").set("save_enabled", false)
	root.get_node("Settings").set("graphics_quality", int(_args.get("quality", 1)))
	_scene = (load(str(entry[0])) as PackedScene).instantiate()
	_scene.set_meta(&"budget_area", area)
	if _scene.has_method("screenshot_prepare"):
		_scene.call("screenshot_prepare", (entry[1] as Dictionary).duplicate())
	root.add_child(_scene)
	_frames = 0
	return false


## The counts for one built area (the whole tree under the root, autoloads included for the per-frame scripts).
static func count(tree_root: Node) -> Dictionary:
	var result: Dictionary = {"nodes": 0, "meshes": 0, "multimesh_instances": 0, "lights": 0, "particles": 0, "labels": 0, "scripts": 0}
	var stack: Array[Node] = [tree_root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		for child: Node in node.get_children():
			stack.append(child)
		result["nodes"] = int(result["nodes"]) + 1
		if node.get_script() != null and (node.is_processing() or node.is_physics_processing()):
			result["scripts"] = int(result["scripts"]) + 1
		if node is Node3D and not (node as Node3D).visible:
			continue
		if node is MeshInstance3D:
			result["meshes"] = int(result["meshes"]) + 1
		elif node is MultiMeshInstance3D:
			var mm: MultiMesh = (node as MultiMeshInstance3D).multimesh
			if mm != null:
				result["multimesh_instances"] = int(result["multimesh_instances"]) + (mm.visible_instance_count if mm.visible_instance_count >= 0 else mm.instance_count)
		elif node is Light3D:
			result["lights"] = int(result["lights"]) + 1
		elif node is GPUParticles3D or node is CPUParticles3D:
			result["particles"] = int(result["particles"]) + 1
		elif node is Label3D:
			result["labels"] = int(result["labels"]) + 1
	return result


func _measure(area: String) -> void:
	var counts: Dictionary = count(root)
	_rows.append("| %s | %d | %d | %d | %d | %d | %d | %d |" % [area, counts["nodes"], counts["meshes"], counts["multimesh_instances"], counts["lights"], counts["particles"], counts["labels"], counts["scripts"]])
	var budget: Dictionary = _budgets.get(area, {}) as Dictionary
	for key: String in budget.keys():
		if counts.has(key) and int(counts[key]) > int(budget[key]):
			_failures.append("%s %s %d > budget %d" % [area, key, counts[key], budget[key]])
