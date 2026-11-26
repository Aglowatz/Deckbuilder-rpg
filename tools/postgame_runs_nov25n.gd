extends SceneTree
## Nov 25 night: whole runs through the postgame dungeons. Headless:
##   Godot --headless --path . -s res://tools/postgame_runs_nov25n.gd -- --dungeon=S-GALLERY [--route=A] [--boon=thick] [--decks=ref|draft] [--runs=4] [--out=res://...]
## The work is in `tools/postgame_runs_nov25n_tool.gd`, loaded once the autoloads exist (as tools/castle_runs_nov21.gd does).


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var tool_script: GDScript = load("res://tools/postgame_runs_nov25n_tool.gd") as GDScript
	var ok: bool = bool((tool_script.new() as RefCounted).call("run"))
	quit(0 if ok else 1)
