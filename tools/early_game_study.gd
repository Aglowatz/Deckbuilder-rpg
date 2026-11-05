extends SceneTree
## Overnight Nov 4-5, Part 3: launcher of the early-game fun check (the work: tools/early_game_study_tool.gd). Headless:
##   Godot --headless --path . -s res://tools/early_game_study.gd [-- --runs=60]


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var tool_script: GDScript = load("res://tools/early_game_study_tool.gd") as GDScript
	(tool_script.new() as RefCounted).call("run")
	quit(0)
