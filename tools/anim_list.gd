extends SceneTree
func _initialize() -> void:
	for path: String in OS.get_cmdline_user_args():
		var node: Node = (load(path) as PackedScene).instantiate()
		var players: Array[Node] = node.find_children("*", "AnimationPlayer", true, false)
		print(path.get_file(), " players=", players.size())
		if not players.is_empty():
			print("  ", (players[0] as AnimationPlayer).get_animation_list())
		node.free()
	quit()
