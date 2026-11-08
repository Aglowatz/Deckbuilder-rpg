extends SceneTree
## Overnight Nov 7-8, Part 2: the friendlier economy study (gold_study_nov8_tool.gd). Headless, foreground:
##   Godot --headless --path . -s res://tools/gold_study.gd [-- --out=res://docs/balance/gold_economy_nov3.md]
## The work is in `tools/economy_model_tool.gd`, loaded once the autoloads exist (the quest and zone tables read the Session).


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var tool_script: GDScript = load("res://tools/gold_study_nov8_tool.gd") as GDScript
	var ok: bool = bool((tool_script.new() as RefCounted).call("run"))
	quit(0 if ok else 1)
