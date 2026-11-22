extends SceneTree
## Fable Nov 21 castle (Part 6): whole runs through the new castle along named routes. Headless:
##   Godot --headless --path . -s res://tools/castle_runs_nov21.gd -- [--runs=6] [--only=A] [--path=beefcake] [--seed=7000] [--out=res://...]
## The work is in `tools/castle_runs_nov21_tool.gd`, loaded once the autoloads exist (as tools/run_balance_sim.gd does).


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var tool_script: GDScript = load("res://tools/castle_runs_nov21_tool.gd") as GDScript
	var ok: bool = bool((tool_script.new() as RefCounted).call("run"))
	quit(0 if ok else 1)
