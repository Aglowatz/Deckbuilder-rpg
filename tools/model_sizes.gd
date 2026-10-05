extends SceneTree
## Prints the AABB size of kit models: Godot --headless --path . -s res://tools/model_sizes.gd -- path1 path2 ...
func _initialize() -> void:
	for path: String in OS.get_cmdline_user_args():
		var packed: PackedScene = load(path) as PackedScene
		if packed == null:
			print("missing ", path)
			continue
		var node: Node3D = packed.instantiate() as Node3D
		var box: AABB = AABB()
		var first: bool = true
		for child: Node in node.find_children("*", "MeshInstance3D", true, false):
			var mesh_instance: MeshInstance3D = child as MeshInstance3D
			var local: AABB = mesh_instance.mesh.get_aabb()
			var xform: Transform3D = Transform3D.IDENTITY
			var current: Node = mesh_instance
			while current != node and current != null:
				xform = (current as Node3D).transform * xform
				current = current.get_parent()
			local = xform * local
			box = local if first else box.merge(local)
			first = false
		print("%s  size=(%.2f, %.2f, %.2f) min_y=%.2f" % [path.get_file(), box.size.x, box.size.y, box.size.z, box.position.y])
		node.free()
	quit()
