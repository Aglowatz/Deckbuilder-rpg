extends SceneTree
## Overnight Nov 4-5, Part 1.7: launcher of the pre-fight rules audit (the work: tools/rules_audit_tool.gd). Headless:
##   Godot --headless --path . -s res://tools/rules_audit.gd   -> _logs/rules_audit.json (every fight's rule badges, in brief order)


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var tool_script: GDScript = load("res://tools/rules_audit_tool.gd") as GDScript
	await (tool_script.new() as RefCounted).call("run", self)
	quit(0)
