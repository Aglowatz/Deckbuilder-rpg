extends SceneTree
## Fable Nov 15 (Part 3): is anyone in this area a 3D or placeholder figure instead of a painted sprite? Loads one area (windowed, like a
## play session), waits for it to finish building, then walks the whole scene tree for
##   - rigged 3D characters: any Skeleton3D (the KayKit adventurers, the 3D hero model), reported by the top node that owns it;
##   - capsule figures: a visible CapsuleMesh a metre or more tall (the old stand-in bodies).
## Lines "npc_3d: <label> <kind> <node path> at (x, z) [key=<_npcs key>]", then "npc_3d_summary: <label> found=<n> allowed=<n>".
## `--allow=a,b` lists node-name fragments that are known and accepted; those lines end "(allowed)". tools/run_npc_3d_scan.sh fails on any other line.
##   Godot --path . -s res://tools/npc_3d_scan.gd -- --scene=res://scenes/town.tscn [--label=town] [--freed=true] [--flags=a,b] [--allow=GoldenFigure]

var _args: Dictionary = {}
var _scene: Node
var _wait: int = 360
var _started: bool = false


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			_args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	root.size = Vector2i(960, 540)


func _process(_delta: float) -> bool:
	if not _started:
		_started = true
		root.get_node("Session").set("save_enabled", false)
		_scene = (load(str(_args.get("scene", "res://scenes/town.tscn"))) as PackedScene).instantiate()
		if _scene.has_method("screenshot_prepare"):
			_scene.call("screenshot_prepare", _args)
		root.add_child(_scene)
		return false
	_wait -= 1
	if _wait > 0:
		return false
	if _scene.has_method("screenshot_ready") and not bool(_scene.call("screenshot_ready")) and _wait > -1200:
		return false
	_check()
	# (a windowed run can hang on the way out with the scene's resources: the report is printed, so end the process; the runner reads
	# the lines, not the exit code)
	OS.kill(OS.get_process_id())
	return true


## The node that stands for the whole figure: the highest ancestor below the scene that is not a plain grouping node of the scene itself.
func _figure_root(node: Node) -> Node:
	var current: Node = node
	while current.get_parent() != null and current.get_parent() != _scene and not current.get_parent().has_meta(&"figure_stop"):
		var parent: Node = current.get_parent()
		# stop at the placed model: its parent holds many unrelated things (the scene, a zone root, a chunk)
		if parent.get_child_count() > 6 and not (parent is Skeleton3D):
			break
		current = parent
	return current


func _npc_key(figure: Node) -> String:
	var npcs: Variant = _scene.get("_npcs")
	if npcs is Dictionary:
		for key: Variant in (npcs as Dictionary).keys():
			var value: Variant = (npcs as Dictionary)[key]
			if value is Node and is_instance_valid(value) and (value == figure or (value as Node).is_ancestor_of(figure) or figure.is_ancestor_of(value as Node)):
				return str(key)
	return ""


func _check() -> int:
	var label: String = str(_args.get("label", _args.get("scene")))
	var allow: PackedStringArray = str(_args.get("allow", "")).split(",", false)
	var seen: Dictionary = {}
	var found: Array[Array] = []
	for node: Node in _scene.find_children("*", "Skeleton3D", true, false):
		if not (node as Node3D).is_visible_in_tree():
			continue
		var figure: Node = _figure_root(node)
		if seen.has(figure):
			continue
		seen[figure] = true
		found.append(["rigged", figure])
	for node: Node in _scene.find_children("*", "MeshInstance3D", true, false):
		var body: MeshInstance3D = node as MeshInstance3D
		if not (body.mesh is CapsuleMesh) or not body.is_visible_in_tree():
			continue
		var height: float = (body.mesh as CapsuleMesh).height * body.global_transform.basis.get_scale().y
		if height < 1.0:
			continue  # small (a pipe end, a roll): not a figure
		var figure: Node = _figure_root(node)
		if seen.has(figure):
			continue
		seen[figure] = true
		found.append(["capsule", figure])
	var bad: int = 0
	var allowed: int = 0
	for entry: Array in found:
		var figure: Node3D = entry[1] as Node3D
		var path: String = str(_scene.get_path_to(figure))
		var key: String = _npc_key(figure)
		var ok: bool = false
		for fragment: String in allow:
			if path.contains(fragment) or (key != "" and key == fragment):
				ok = true
		if ok:
			allowed += 1
		else:
			bad += 1
		var at: Vector3 = figure.global_position if figure is Node3D else Vector3.ZERO
		print("npc_3d: %s %s %s at (%.1f, %.1f)%s%s" % [label, str(entry[0]), path, at.x, at.z, (" key=%s" % key) if key != "" else "", " (allowed)" if ok else ""])
	print("npc_3d_summary: %s found=%d allowed=%d" % [label, bad + allowed, allowed])
	return bad
