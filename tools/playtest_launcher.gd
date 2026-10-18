extends Node
## Main scene for the Playtest v0.4.0 smoke: starts the PlaytestSmoke driver on the root (so it survives every scene change from
## the forest to the cave, Crosspath, a battle and back) and switches to the starting area. Mirrors tools/prologue_launcher.gd.


func _ready() -> void:
	var smoke: PlaytestSmoke = PlaytestSmoke.new()
	smoke.name = "PlaytestSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
	get_tree().change_scene_to_file.call_deferred("res://scenes/starting_area.tscn")
