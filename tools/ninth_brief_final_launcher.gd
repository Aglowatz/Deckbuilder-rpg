extends Node
## Main scene for the ninth brief's FINAL smoke test: starts NinthBriefFinalSmoke on the root (so it
## survives the town <-> zone <-> battle scene changes it is testing) and switches to town.

func _ready() -> void:
	var smoke: NinthBriefFinalSmoke = NinthBriefFinalSmoke.new()
	smoke.name = "NinthBriefFinalSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
	get_tree().change_scene_to_file.call_deferred("res://scenes/town.tscn")
