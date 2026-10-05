extends Node
## Main scene for the tenth brief's FINAL smoke test: starts TenthBriefFinalSmoke on the root (so it survives the town <-> Capital <->
## battle <-> castle <-> ending scene changes it is testing) and switches to town.

func _ready() -> void:
	var smoke: TenthBriefFinalSmoke = TenthBriefFinalSmoke.new()
	smoke.name = "TenthBriefFinalSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
	get_tree().change_scene_to_file.call_deferred("res://scenes/town.tscn")
