extends SceneTree
## Overnight Oct 29, Part 1: the economy timeline model. Headless, foreground:
##   Godot --headless --path . -s res://tools/economy_model.gd -- --out=res://docs/design/sim/economy_model.md [--profile=expected]
## The work is in `tools/economy_model_tool.gd`, loaded once the autoloads exist (the quest and zone tables read the Session).


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var tool_script: GDScript = load("res://tools/economy_model_tool.gd") as GDScript
	var ok: bool = bool((tool_script.new() as RefCounted).call("run"))
	quit(0 if ok else 1)
