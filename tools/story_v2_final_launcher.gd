extends Node
## Main scene for the hidden-tunnel skip smoke test: starts the StoryV2FinalSmoke driver on
## the root (so it survives the scene change from the starting area to town) and switches to the
## starting area. Mirrors tools/e2e_launcher.gd's pattern exactly.


func _ready() -> void:
	var smoke: StoryV2FinalSmoke = StoryV2FinalSmoke.new()
	smoke.name = "StoryV2FinalSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
	get_tree().change_scene_to_file.call_deferred("res://scenes/town.tscn")
