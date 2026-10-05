extends SceneTree
func _initialize() -> void:
	for path: String in OS.get_cmdline_user_args():
		var node: Node = (load(path) as PackedScene).instantiate()
		var tris: int = 0
		for child: Node in node.find_children("*", "MeshInstance3D", true, false):
			var mesh: Mesh = (child as MeshInstance3D).mesh
			for s: int in range(mesh.get_surface_count()):
				var idx: Variant = mesh.surface_get_arrays(s)[Mesh.ARRAY_INDEX]
				tris += (idx as PackedInt32Array).size() / 3 if idx != null else 0
		print("mesh_tris: ", path.get_file(), " ", tris)
		node.free()
	quit()
