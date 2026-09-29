extends Node
## Main scene for the fourth brief's FINAL smoke test: starts FourthBriefFinalSmoke on the root
## (so it survives the town <-> battle scene changes it's testing) and switches to town.

func _ready() -> void:
	var smoke: FourthBriefFinalSmoke = FourthBriefFinalSmoke.new()
	smoke.name = "FourthBriefFinalSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
	get_tree().change_scene_to_file.call_deferred("res://scenes/town.tscn")
