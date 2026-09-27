extends Node
## Main scene of the end-to-end run: starts the E2EDemo driver on the root (so it survives
## scene changes) and switches to the title screen.


func _ready() -> void:
	var demo: E2EDemo = E2EDemo.new()
	demo.name = "E2EDemo"
	get_tree().root.add_child.call_deferred(demo)
	demo.run.call_deferred()
	get_tree().change_scene_to_file.call_deferred("res://scenes/title.tscn")
