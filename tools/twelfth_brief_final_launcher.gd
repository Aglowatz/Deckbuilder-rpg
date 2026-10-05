extends Node
## Main scene for the brief 12 final smoke test: starts TwelfthBriefSmoke on the root (so it survives the scene changes it tests) and goes to the starting area.

func _ready() -> void:
	Session.save_enabled = false
	Session.new_game()
	var smoke: TwelfthBriefSmoke = TwelfthBriefSmoke.new()
	smoke.name = "TwelfthBriefSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
	get_tree().change_scene_to_file.call_deferred("res://scenes/starting_area.tscn")
