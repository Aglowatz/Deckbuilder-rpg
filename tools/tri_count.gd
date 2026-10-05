extends SceneTree
## Triangle budget per model name for a scene: Godot --headless --path . -s res://tools/tri_count.gd -- --scene=res://scenes/town.tscn
var _scene: Node
var _frames: int = 0


func _process(_delta: float) -> bool:
	_frames += 1
	if _frames == 1:
		var path: String = "res://scenes/town.tscn"
		for arg: String in OS.get_cmdline_user_args():
			if arg.begins_with("--scene="):
				path = arg.substr(8)
		root.get_node("Session").set("save_enabled", false)
		_scene = (load(path) as PackedScene).instantiate()
		if _scene.has_method("screenshot_prepare"):
			_scene.call("screenshot_prepare", {"fresh": "false"})
		root.add_child(_scene)
		return false
	if _frames < 10:
		return false
	var totals: Dictionary = {}
	var counts: Dictionary = {}
	for node: Node in _scene.find_children("*", "GeometryInstance3D", true, false):
		var tris: int = 0
		var instances: int = 1
		var key: String = String(node.name)
		if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
			var mesh: Mesh = (node as MeshInstance3D).mesh
			for s: int in range(mesh.get_surface_count()):
				var arrays: Array = mesh.surface_get_arrays(s)
				var indices: Variant = arrays[Mesh.ARRAY_INDEX]
				tris += (indices as PackedInt32Array).size() / 3 if indices != null else (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() / 3
			key = mesh.resource_name if mesh.resource_name != "" else key
		elif node is MultiMeshInstance3D:
			var mm: MultiMesh = (node as MultiMeshInstance3D).multimesh
			instances = mm.instance_count
			var arrays2: Array = mm.mesh.surface_get_arrays(0)
			var idx: Variant = arrays2[Mesh.ARRAY_INDEX]
			tris = (idx as PackedInt32Array).size() / 3 if idx != null else 0
			key = "MM " + str(mm.mesh.resource_name)
		totals[key] = int(totals.get(key, 0)) + tris * instances
		counts[key] = int(counts.get(key, 0)) + instances
	var keys: Array = totals.keys()
	keys.sort_custom(func(a: String, b: String) -> bool: return int(totals[a]) > int(totals[b]))
	var sum: int = 0
	for k: String in keys:
		sum += int(totals[k])
	print("tri_count: total triangles in scene ", sum)
	for k: String in keys.slice(0, 18):
		print("tri_count:  %8d tris  x%d  %s" % [int(totals[k]), int(counts[k]), k])
	quit(0)
	return true
