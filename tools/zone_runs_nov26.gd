extends SceneTree
## Nov 26 day (Part C): whole runs through the zone dungeons. Headless:
##   Godot --headless --path . -s res://tools/zone_runs_nov26.gd -- --dungeon=D-HOG [--route=A] [--runs=4] [--label=before]
## The work is in `tools/zone_runs_nov26_tool.gd`, loaded once the autoloads exist (as tools/castle_runs_nov21.gd does).


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var tool_script: GDScript = load("res://tools/zone_runs_nov26_tool.gd") as GDScript
	var ok: bool = bool((tool_script.new() as RefCounted).call("run"))
	quit(0 if ok else 1)
