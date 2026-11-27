extends SceneTree
## Nov 26 night (Part D): the postgame solution hunt (see tools/postgame_hunt_tool.gd).
##   Godot --headless --path . -s res://tools/postgame_hunt.gd -- --mode=fights --dungeon=S-BEEF --fights=1,2,3 --games=2


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var tool_script: GDScript = load("res://tools/postgame_hunt_tool.gd") as GDScript
	var ok: bool = bool((tool_script.new() as RefCounted).call("run"))
	quit(0 if ok else 1)
