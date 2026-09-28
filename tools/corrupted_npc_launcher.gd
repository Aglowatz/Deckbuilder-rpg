extends Node
## Main scene for the corrupted-NPC smoke test: starts CorruptedNpcSmoke on the root (so it
## survives the town <-> battle scene changes it's testing) and switches to town.

func _ready() -> void:
	var smoke: CorruptedNpcSmoke = CorruptedNpcSmoke.new()
	smoke.name = "CorruptedNpcSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
	get_tree().change_scene_to_file.call_deferred("res://scenes/town.tscn")
