extends SceneTree
## Rebalance Part E: replays balance-sim games of one encounter and prints the action log of the lost ones (or all with --all), so a
## bad number can be understood instead of guessed at. Foreground, one Godot process:
##   Godot --headless --path . -s res://tools/replay_encounter.gd -- --id=zone:beefcake:golem --path=gourmand --games=20 --show=2 [--level=5] [--all] [--nogear]
## The work is in `tools/replay_encounter_tool.gd`, loaded once the autoloads exist (same reason as run_balance_sim.gd).


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var tool_script: GDScript = load("res://tools/replay_encounter_tool.gd") as GDScript
	var ok: bool = bool((tool_script.new() as RefCounted).call("run"))
	quit(0 if ok else 1)
