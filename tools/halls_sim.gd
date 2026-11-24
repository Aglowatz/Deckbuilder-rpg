extends SceneTree
## Fable Nov 24 (Part 4): the Shuffled Halls sim's command line. Headless, foreground, one Godot process:
##   Godot --headless --path . -s res://tools/halls_sim.gd -- --what=rooms --rooms=2,3,5 --out=res://docs/design/sim/nov24/halls_rooms_a.md
## The work is in `tools/halls_sim_tool.gd`, loaded once the autoloads exist (the dungeon builder reads the Session's story
## text, which a script started with -s cannot compile against before the first frame). Flags: see that file.
## In batches of at most 30 variants, each a fresh process with a 20-minute limit: `bash tools/run_halls_sims.sh`.


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var tool_script: GDScript = load("res://tools/halls_sim_tool.gd") as GDScript
	var ok: bool = bool((tool_script.new() as RefCounted).call("run"))
	quit(0 if ok else 1)
