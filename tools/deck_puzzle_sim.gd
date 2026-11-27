extends SceneTree
## Nov 26 night (Part A2): Octavia's deck-building puzzles, simulated. Headless:
##   Godot --headless --path . -s res://tools/deck_puzzle_sim.gd -- [--only=deckpuzzle_tea_garden] [--games=12] [--decks=exploit,late,reference]
##        [--out=res://docs/design/sim/nov26n/puzzles.md] [--record=1] [--seed=8100]
## Every deck of the puzzle's `sim_decks` (data/arena/deck_puzzles.json) and the four Path reference decks at the puzzle's level play the
## puzzle exactly as the game builds it (`ArenaScenario.build_game`, the opponent at Boss skill and deterministic). --record=1 keeps the
## first win of the first exploit deck that wins (its seed and its moves) in data/arena/deck_puzzle_lines.json for the test and the doc.
## The work is in `tools/deck_puzzle_sim_tool.gd`, loaded once the autoloads exist.


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var tool_script: GDScript = load("res://tools/deck_puzzle_sim_tool.gd") as GDScript
	var ok: bool = bool((tool_script.new() as RefCounted).call("run"))
	quit(0 if ok else 1)
