extends Node
## Main scene for the Old Well smoke (overnight Oct 19-20, Part 6): starts OldWellSmoke on the root and opens Crosspath.


func _ready() -> void:
	var smoke: OldWellSmoke = OldWellSmoke.new()
	smoke.name = "OldWellSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
	get_tree().change_scene_to_file.call_deferred("res://scenes/town.tscn")
