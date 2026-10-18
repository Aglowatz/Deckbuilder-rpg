extends Node
## Main scene for the Opening Forest smoke (tools/opening_forest_smoke.gd): starts the driver on the root (so it survives the scene changes) and opens
## the title screen, where the smoke clicks New Game like a player.


func _ready() -> void:
	var smoke: OpeningForestSmoke = OpeningForestSmoke.new()
	smoke.name = "OpeningForestSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
	get_tree().change_scene_to_file.call_deferred("res://scenes/title.tscn")
