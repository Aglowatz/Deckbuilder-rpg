extends Node
## Main scene for the brief 10b travel smoke test: starts TravelSmoke on the root (so it survives the town <-> zone scene changes it
## is testing) and switches to town.

func _ready() -> void:
	var smoke: TravelSmoke = TravelSmoke.new()
	smoke.name = "TravelSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
	get_tree().change_scene_to_file.call_deferred("res://scenes/town.tscn")
