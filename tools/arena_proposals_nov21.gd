extends SceneTree
## Fable Nov 21 review (Part 3.2): the Arena battles as they are and each proposed change, simulated. Headless:
##   Godot --headless --path . -s res://tools/arena_proposals_nov21.gd -- [--games=12] [--only=arena_marshal] [--out=res://...]
## The work is in `tools/arena_proposals_nov21_tool.gd`, loaded once the autoloads exist (as tools/run_balance_sim.gd does).


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var tool_script: GDScript = load("res://tools/arena_proposals_nov21_tool.gd") as GDScript
	var ok: bool = bool((tool_script.new() as RefCounted).call("run"))
	quit(0 if ok else 1)
