extends Node
## Main scene for the FINAL end-to-end flow: starts the FinalFlowSmoke driver on the root (so it
## survives every scene change - starting area -> town -> battle -> town) and switches to the
## starting area. Mirrors tools/e2e_launcher.gd's pattern exactly.


func _ready() -> void:
	var smoke: FinalFlowSmoke = FinalFlowSmoke.new()
	smoke.name = "FinalFlowSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
	get_tree().change_scene_to_file.call_deferred("res://scenes/starting_area.tscn")
