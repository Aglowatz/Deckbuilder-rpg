extends SceneTree
## Fresh eyes round 2 (Oct 31), Part 3: the starter-deck Infrastructure study. Sim only; changes nothing in the game.
##   Godot --headless --path . -s res://tools/starter_infra_study.gd -- --games=30 --seeds=7000,8100 --infra=19,17,15 --out=res://docs/design/sim/starter_infra_oct31.md
## For every Path and every Infrastructure count the 45-card starter is rebuilt (the removed basics are replaced by extra copies of the deck's
## own cheapest cards, under the 3-copy cap) and played by the sim's Elite AI through the tutorial cave (3 fights) and the Path's own first
## zone (its roamers and elites, at the zone's expected level with its gear and items). Measured per game: the win, the player's turn on
## which the first card that is not an Infrastructure was played ("first real play"), and the player's turns on which nothing was played
## ("dead turns"). The game's starter stays at 19 unless the report says every Path improves and the cave stays in the 80 %+ band.

var _args: Dictionary = {}


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if not arg.begins_with("--"):
			continue
		var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
		_args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var tool_script: GDScript = load("res://tools/starter_infra_study_tool.gd") as GDScript
	var ok: bool = bool((tool_script.new() as RefCounted).call("run", _args))
	quit(0 if ok else 1)
