extends SceneTree
func _initialize() -> void:
	var node: Node = (load("res://assets/KayKit-Character-Pack-Adventures-1.0/Characters/Rogue.glb") as PackedScene).instantiate()
	var skeleton: Skeleton3D = node.find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
	for i: int in range(skeleton.get_bone_count()):
		var rest: Transform3D = skeleton.get_bone_global_rest(i)
		print("bone ", i, " ", skeleton.get_bone_name(i), " parent ", skeleton.get_bone_parent(i), " pos ", rest.origin)
	for child: Node in skeleton.get_children():
		if child is MeshInstance3D:
			var aabb: AABB = (child as MeshInstance3D).mesh.get_aabb()
			print("mesh ", child.name, " aabb pos ", aabb.position, " size ", aabb.size)
	var anim: AnimationPlayer = node.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	print(anim.get_animation_list())
	node.free()
	quit()
