extends SceneTree
## Prints the node tree of models: Godot --headless --path . -s res://tools/node_dump.gd -- res://...glb
func _dump(node: Node, depth: int) -> void:
	var extra: String = ""
	if node is MeshInstance3D:
		extra = " [mesh %s tris]" % str((node as MeshInstance3D).mesh.get_surface_count())
	if node is Skeleton3D:
		extra = " [skeleton %d bones]" % (node as Skeleton3D).get_bone_count()
	print("  ".repeat(depth), node.name, " (", node.get_class(), ")", extra)
	for child: Node in node.get_children():
		_dump(child, depth + 1)


func _initialize() -> void:
	for path: String in OS.get_cmdline_user_args():
		print("== ", path)
		var node: Node = (load(path) as PackedScene).instantiate()
		_dump(node, 0)
		node.free()
	quit()
