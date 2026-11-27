extends SceneTree
## Nov 26 night (Part C): equipment and items against the zone bosses and Primm (see tools/equipment_lift_tool.gd).
##   Godot --headless --path . -s res://tools/equipment_lift.gd -- --from=0 --to=40 --games=2


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var tool_script: GDScript = load("res://tools/equipment_lift_tool.gd") as GDScript
	var ok: bool = bool((tool_script.new() as RefCounted).call("run"))
	quit(0 if ok else 1)
