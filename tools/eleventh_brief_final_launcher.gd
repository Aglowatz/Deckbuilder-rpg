extends Node
## Main scene for the brief 11 final smoke test: starts EleventhBriefSmoke on the root (so it survives the scene changes it tests) and
## switches to town.

func _ready() -> void:
	var smoke: EleventhBriefSmoke = EleventhBriefSmoke.new()
	smoke.name = "EleventhBriefSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
	get_tree().change_scene_to_file.call_deferred("res://scenes/town.tscn")
