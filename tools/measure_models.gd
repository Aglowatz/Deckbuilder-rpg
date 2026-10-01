extends SceneTree
## Dev helper: prints the bounding box (and animations) of every model in the given folders.
## Godot --headless --path . -s res://tools/measure_models.gd -- res://assets/kenney-furniture-kit/models


func _init() -> void:
	for dir_path: String in OS.get_cmdline_user_args():
		var dir: DirAccess = DirAccess.open(dir_path)
		if dir == null:
			continue
		var files: PackedStringArray = dir.get_files()
		files.sort()
		for file_name: String in files:
			if not (file_name.ends_with(".glb") or file_name.ends_with(".gltf")):
				continue
			var packed: PackedScene = load(dir_path.path_join(file_name)) as PackedScene
			if packed == null:
				continue
			var node: Node3D = packed.instantiate() as Node3D
			var box: AABB = _aabb(node, Transform3D.IDENTITY)
			var anims: String = ""
			for player: Node in node.find_children("*", "AnimationPlayer", true, false):
				anims = ",".join((player as AnimationPlayer).get_animation_list())
			print("%s size=(%.2f %.2f %.2f) min=(%.2f %.2f %.2f) %s" % [file_name, box.size.x, box.size.y, box.size.z, box.position.x, box.position.y, box.position.z, anims])
			node.free()
	quit(0)


func _aabb(node: Node, xform: Transform3D) -> AABB:
	var result: AABB = AABB()
	var first: bool = true
	for child: Node in node.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = child as MeshInstance3D
		var local: Transform3D = Transform3D.IDENTITY
		var walker: Node = mesh_instance
		while walker != node and walker != null:
			if walker is Node3D:
				local = (walker as Node3D).transform * local
			walker = walker.get_parent()
		var box: AABB = local * mesh_instance.get_aabb()
		if first:
			result = box
			first = false
		else:
			result = result.merge(box)
	return result
