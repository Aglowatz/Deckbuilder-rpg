extends RefCounted
## Rebalance Part E: the encounter replay (run by `tools/replay_encounter.gd`): plays balance-sim games of one catalog encounter
## and prints the action log of the lost ones (or every game with --all). Flags: --id, --path, --games, --show, --level, --all, --nogear.

var args: Dictionary = {}


func run() -> bool:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	var content: ContentSet = ContentLibrary.load_all()
	var spec: EncounterSpec = EncounterCatalog.find(content, str(args.get("id", "tutorial:2")))
	if spec == null:
		print("unknown encounter id")
		return false
	var path: Affinity.Type = Affinity.Type.BEEFCAKE
	for candidate: Affinity.Type in Affinity.colored_types():
		if Affinity.display_name(candidate).to_lower() == str(args.get("path", "beefcake")).to_lower():
			path = candidate
	var player: PlayerSpec = ProgressionModel.player_for(content, spec, path)
	if args.has("level"):
		player.level = int(args["level"])
		player.deck = ProgressionModel.reference_deck(content, path, player.level)
		player.equipment_ids = ProgressionModel.equipment_for(player.level)
		player.items = ProgressionModel.items_for(player.level)
	if args.has("nogear"):
		player.equipment_ids = []
		player.items = {}
	var games: int = int(args.get("games", 20))
	var show: int = int(args.get("show", 2))
	var shown: int = 0
	print("%s vs %s (%s, HP %d, %s AI); player %s" % [spec.id, spec.enemy_name, spec.title, spec.enemy_hp, spec.enemy_ai_name, player.describe()])
	var counts: Dictionary = player.deck.copy_counts()
	var ids: Array = counts.keys()
	ids.sort()
	var deck_parts: PackedStringArray = []
	for id: Variant in ids:
		deck_parts.append("%s x%d" % [str(id), int(counts[id])])
	print("deck: " + ", ".join(deck_parts))
	var wins: int = 0
	for i: int in range(games):
		var log: Array[String] = []
		var first: int = spec.first_player if spec.first_player >= 0 else i % 2
		var game: GameState = _play_logged(content, player, spec, 7000 + int(path) * 100000 + i, first, log)
		if game.winner == 0:
			wins += 1
		if (game.winner != 0 or args.has("all")) and shown < show:
			shown += 1
			print("--- game %d: %s, turns %d, hp %d / %d, first player %d" % [i, "WON" if game.winner == 0 else "LOST", game.turn, game.players[0].hp, game.players[1].hp, first])
			for line: String in log:
				print("   " + line)
	print("%d / %d won" % [wins, games])
	return true


## BalanceSim.play_game with a log of both seats' non-pass actions.
func _play_logged(content: ContentSet, player: PlayerSpec, encounter: EncounterSpec, seed_value: int, first_player: int, log: Array[String]) -> GameState:
	var deck: Deck = player.deck
	if not encounter.player_recipe.is_empty():
		deck = ZoneDecks.from_recipe(content, "Arena kit", encounter.player_recipe)
	var profile: PlayerProfile = player.profile(content)
	var sources: Array[ModifierSource] = player.extra_sources.duplicate()
	var shared: ModifierSource = encounter.shared_source()
	if shared != null:
		sources.append(shared)
	var player_rules: ModifierSource = encounter.player_rules_source()
	if player_rules != null:
		sources.append(player_rules)
	sources.append_array(encounter.player_sources)
	var setup: PlayerSetup = PlayerSetup.create(deck, profile, sources, player.label)
	if encounter.player_hp > 0:
		setup.starting_hp = encounter.player_hp
	var enemy: PlayerSetup = encounter.build_enemy(content, deck)
	if shared != null:
		enemy.modifiers.add_source(shared)
	var options: GameOptions = GameOptions.new()
	options.rng_seed = seed_value
	options.first_player = first_player
	options.turn_limit = BalanceSim.TURN_LIMIT
	options.record_events = false
	var game: GameState = GameState.new(options)
	game.add_player(setup)
	game.add_player(enemy)
	game.start()
	var ai: AIPlayer = AIPlayer.new(ZoneDecks.personality(content, player.ai_name))
	var enemy_ai: AIPlayer = AIPlayer.new(ZoneDecks.personality(content, encounter.enemy_ai_name))
	var ais: Array[AIPlayer] = [ai, enemy_ai]
	var items: Dictionary = player.items.duplicate()
	var used_this_turn: Dictionary = {}
	var item_turn: int = -1
	var steps: int = 0
	while not game.is_over() and steps < BalanceSim.MAX_STEPS_PER_GAME:
		steps += 1
		var who: int = game.awaiting_player()
		if who == 0 and not items.is_empty() and game.stage == GameState.Stage.PLAYING and game.in_main_phase():
			if item_turn != game.turn:
				item_turn = game.turn
				used_this_turn.clear()
			if SimItemPolicy.act(game, 0, items, content, used_this_turn):
				log.append("P0 t%d ITEM hp%d/%d" % [game.turn, game.players[0].hp, game.players[1].hp])
				continue
		var action: GameAction = ais[who].choose_action(game)
		if action.type != GameAction.Type.PASS and action.type != GameAction.Type.KEEP_HAND:
			var card: CardInstance = game.find_card(action.card_uid)
			var extra: String = ""
			match action.type:
				GameAction.Type.DECLARE_ATTACKERS:
					extra = " x%d" % action.uids.size()
				GameAction.Type.DECLARE_BLOCKERS:
					extra = " x%d" % action.blocks.size()
				GameAction.Type.USE_RESOURCE:
					extra = " " + ResourceKind.display_name(action.effect_index as ResourceKind.Kind)
				GameAction.Type.PLAY_INFRASTRUCTURE:
					extra = " infra"
			log.append("P%d t%d %s %s%s hp%d/%d" % [who, game.turn, GameAction.Type.keys()[action.type], card.data.id if card != null and not card.data.is_infrastructure() else "", extra, game.players[0].hp, game.players[1].hp])
		if not game.apply_action(action):
			if not game.apply_action(GameAction.pass_phase(who)):
				break
	return game
