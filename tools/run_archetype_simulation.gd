extends SceneTree
## AI-vs-AI round robin of the enemy deck archetypes (EnemyDecks) so lopsided Paths show up. Prints a win-rate table.
##   Godot --headless --path . -s res://tools/run_archetype_simulation.gd -- --games=20 [--keys=a,b,c]

func _init() -> void:
	var games: int = 20
	var keys: Array[String] = []
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--games="):
			games = int(arg.trim_prefix("--games="))
		elif arg.begins_with("--keys="):
			for key: String in arg.trim_prefix("--keys=").split(","):
				keys.append(key)
	var content: ContentSet = ContentLibrary.load_all()
	if keys.is_empty():
		for key: Variant in EnemyDecks.ARCHETYPES.keys():
			if (EnemyDecks.ARCHETYPES[key] as Dictionary)["paths"].size() <= 1:
				keys.append(str(key))
	var decks: Array[Deck] = []
	for key: String in keys:
		decks.append(ZoneDecks.from_recipe(content, key, EnemyDecks.trimmed(key, 45, 17)))
	var runner: SimulationRunner = SimulationRunner.new()
	var wins: Array[int] = []
	var played: Array[int] = []
	for i: int in range(keys.size()):
		wins.append(0)
		played.append(0)
	for i: int in range(keys.size()):
		for j: int in range(i + 1, keys.size()):
			var stats: MatchupStats = runner.run_matchup(decks[i], decks[j], games, 7000 + i * 100 + j)
			wins[i] += stats.wins_a
			wins[j] += stats.wins_b
			played[i] += stats.wins_a + stats.wins_b + stats.draws
			played[j] += stats.wins_a + stats.wins_b + stats.draws
			print("%s vs %s: %d-%d-%d, %.1f turns" % [keys[i], keys[j], stats.wins_a, stats.wins_b, stats.draws, stats.average_turns()])
	print("---- win rates ----")
	for i: int in range(keys.size()):
		print("%-22s %3d%% (%d/%d)" % [keys[i], int(100.0 * float(wins[i]) / float(maxi(played[i], 1))), wins[i], played[i]])
	quit(0)
