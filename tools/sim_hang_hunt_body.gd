extends RefCounted
## The work of tools/sim_hang_hunt.gd, loaded once the autoloads exist.


func run() -> bool:
	var args: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	var content: ContentSet = ContentLibrary.load_all()
	var specs: Array[EncounterSpec] = EncounterCatalog.filtered(content, str(args.get("filter", "D-PC:19")))
	var level: int = int(args.get("level", 21))
	var games: int = int(args.get("games", 6))
	var seed_value: int = int(args.get("seed", 7000))
	var gear: Array[String] = []
	for id: String in str(args.get("gear", "")).split(",", false):
		gear.append(id)
	var items: Dictionary = {}
	for id: String in str(args.get("items", "")).split(",", false):
		items[id] = 1
	var trace: String = str(args.get("trace", ""))
	for path: Affinity.Type in Affinity.colored_types():
		for spec: EncounterSpec in specs:
			var player: PlayerSpec = ProgressionModel.player_for(content, spec, path)
			player.level = level
			player.deck = ProgressionModel.reference_deck(content, path, level)
			player.equipment_ids = gear
			player.items = items.duplicate()
			var base: int = seed_value + int(path) * 100000
			for i: int in range(games):
				var key: String = "%d:%s:%d" % [int(path), spec.id, i]
				if not trace.is_empty() and key != trace:
					continue
				BalanceSim.trace = key == trace
				var first: int = spec.first_player if spec.first_player >= 0 else i % 2
				print("GAME %s (%s) seed %d first %d ..." % [key, Affinity.display_name(path), base + i, first])
				var result: BalanceSim.Result = BalanceSim.Result.new()
				var started: int = Time.get_ticks_msec()
				var game: GameState = BalanceSim.play_game(content, player, spec, base + i, first, 0, items.duplicate(), result)
				print("  done in %d ms, winner %d, turn %d" % [Time.get_ticks_msec() - started, game.winner, game.turn])
	return true
