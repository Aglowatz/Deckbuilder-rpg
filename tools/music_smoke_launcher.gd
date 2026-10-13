extends Node
## Main scene of the music smoke (tools/music_smoke.gd): starts the driver on the root (it survives every scene change) and opens the starting forest.


func _ready() -> void:
	var smoke: MusicSmoke = MusicSmoke.new()
	smoke.name = "MusicSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
	get_tree().change_scene_to_file.call_deferred("res://scenes/starting_area.tscn")
