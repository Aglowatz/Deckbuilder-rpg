extends Node
## Main scene for the hidden-tunnel skip smoke test: starts the PrologueSmoke driver on
## the root (so it survives the scene change from the starting area to town) and switches to the
## starting area. Mirrors tools/e2e_launcher.gd's pattern exactly.


func _ready() -> void:
	var smoke: PrologueSmoke = PrologueSmoke.new()
	smoke.name = "PrologueSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
	get_tree().change_scene_to_file.call_deferred("res://scenes/starting_area.tscn")
