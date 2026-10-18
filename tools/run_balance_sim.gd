extends SceneTree
## Rebalance Part B: the balance simulator's command line. Headless, foreground, one Godot process:
##   Godot --headless --path . -s res://tools/run_balance_sim.gd -- --what=encounters --mode=quick --filter=zone:beefcake --out=res://docs/design/sim/zone_beefcake.md
## The work is in `tools/balance_sim_tool.gd`, loaded once the autoloads exist (the dungeon builder reads the Session's story
## text, which a script started with -s cannot compile against before the first frame). Flags: see that file.


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var tool_script: GDScript = load("res://tools/balance_sim_tool.gd") as GDScript
	var ok: bool = bool((tool_script.new() as RefCounted).call("run"))
	quit(0 if ok else 1)
