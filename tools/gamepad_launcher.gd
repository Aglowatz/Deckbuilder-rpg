extends Node
## Main scene for the controller smoke (Oct 26): starts the GamepadSmoke driver on the root (so it survives every scene change) and
## switches to the starting area. Mirrors tools/playtest_launcher.gd.


func _ready() -> void:
	var smoke: GamepadSmoke = GamepadSmoke.new()
	smoke.name = "GamepadSmoke"
	smoke.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
	get_tree().change_scene_to_file.call_deferred("res://scenes/starting_area.tscn")
