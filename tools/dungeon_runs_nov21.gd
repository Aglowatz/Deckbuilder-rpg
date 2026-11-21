extends SceneTree
## Fable Nov 21 review (Part 3.1): whole dungeon runs with the heal rooms of Nov 21 (the four ways through each room). Headless:
##   Godot --headless --path . -s res://tools/dungeon_runs_nov21.gd -- [--only=D-HOG] [--path=beefcake] [--runs=12] [--starter_runs=8] [--out=res://...]
## The work is in `tools/dungeon_runs_nov21_tool.gd`, loaded once the autoloads exist (as tools/run_balance_sim.gd does).


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var tool_script: GDScript = load("res://tools/dungeon_runs_nov21_tool.gd") as GDScript
	var ok: bool = bool((tool_script.new() as RefCounted).call("run"))
	quit(0 if ok else 1)
