extends SceneTree
## Fix pass Nov 4 (B), Part F: launcher of the Deck Station layout guide (the work: tools/deck_station_guide_tool.gd). Windowed:
##   Godot --path . --resolution 1600x900 -s res://tools/deck_station_guide.gd


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var tool_script: GDScript = load("res://tools/deck_station_guide_tool.gd") as GDScript
	await (tool_script.new() as RefCounted).call("run", self)
	quit(0)
