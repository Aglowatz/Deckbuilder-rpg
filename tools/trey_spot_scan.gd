extends SceneTree
## Fable big pass Nov 23 (Part 5.5): the launcher of `tools/trey_spot_scan_tool.gd` (the work waits for the autoloads).
##   Godot --headless --path . -s res://tools/trey_spot_scan.gd [-- --zone=refusemancer --near=5 --far=13 --show=40]


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var tool_script: GDScript = load("res://tools/trey_spot_scan_tool.gd") as GDScript
	var ok: bool = bool((tool_script.new() as RefCounted).call("run", root))
	quit(0 if ok else 1)
