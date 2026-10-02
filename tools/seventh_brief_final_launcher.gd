extends Node
## Main scene for the seventh brief's FINAL smoke test: starts SeventhBriefFinalSmoke on the root (so it
## survives the town <-> zone <-> battle scene changes it is testing) and switches to town.

func _ready() -> void:
	var smoke: SeventhBriefFinalSmoke = SeventhBriefFinalSmoke.new()
	smoke.name = "SeventhBriefFinalSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
	get_tree().change_scene_to_file.call_deferred("res://scenes/town.tscn")
