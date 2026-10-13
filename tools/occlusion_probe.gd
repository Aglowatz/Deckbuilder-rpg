extends SceneTree
## Prints which meshes the OcclusionFader is dissolving in a scene at its start (a screen full of dither means something large blocks the hero).
##   Godot --path . -s res://tools/occlusion_probe.gd -- --scene=res://scenes/town.tscn


func _initialize() -> void:
	var scene_path: String = "res://scenes/town.tscn"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--scene="):
			scene_path = arg.substr(8)
	var session: Node = root.get_node_or_null("Session")
	if session != null:
		session.set("save_enabled", false)
	var scene: Node = (load(scene_path) as PackedScene).instantiate()
	root.add_child(scene)
	for _frame: int in range(240):
		await process_frame
	for node: Node in root.find_children("*", "", true, false):
		if node.get_script() != null and str(node.get_script().resource_path).ends_with("occlusion_fader.gd"):
			print("occlusion_probe: ", node.call("debug_summary"))
			for line: String in node.call("debug_blockers") as PackedStringArray:
				print("occlusion_probe:   ", line)
	quit(0)
