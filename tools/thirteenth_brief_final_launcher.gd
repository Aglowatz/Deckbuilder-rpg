extends Node
## Main scene for the brief 13 final smoke test: starts ThirteenthBriefSmoke on the root (so it survives the scene changes it tests) and switches to town.

func _ready() -> void:
	Session.save_enabled = false
	var smoke: ThirteenthBriefSmoke = ThirteenthBriefSmoke.new()
	smoke.name = "ThirteenthBriefSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
	get_tree().change_scene_to_file.call_deferred("res://scenes/town.tscn")
