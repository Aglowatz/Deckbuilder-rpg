extends RefCounted
## Rebalance Part E: the encounter replay (run by `tools/replay_encounter.gd`): plays balance-sim games of one catalog encounter
## and prints the action log of the lost ones (or every game with --all). Flags: --id, --path, --games, --show, --level, --all, --nogear,
## --verbose (Battle AI upgrade, Oct 23: card names, targets, attackers with stats, blocks, a board line at every turn start and the
## think time of each seat's decisions), --enemy_ai=<personality name> (override the encounter's AI name).

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
	if args.has("verbose"):
		for who: int in range(2):
			print("P%d think time: %d decisions, avg %.1f ms, max %.0f ms, over 1 s: %d" % [who, _think_count[who], _think_total[who] / maxf(1.0, float(_think_count[who])), _think_max[who], _think_slow[who]])
	return true


var _think_count: Array[int] = [0, 0]
var _think_total: Array[float] = [0.0, 0.0]
var _think_max: Array[float] = [0.0, 0.0]
var _think_slow: Array[int] = [0, 0]


func _name(game: GameState, ref: int) -> String:
	if ref == 0:
		return ""
	if Targets.is_player(ref):
		return "P%d" % Targets.player_index(ref)
	var card: CardInstance = game.find_card(ref)
	if card == null:
		return "#%d" % ref
	if card.data.is_unit():
		return "%s %d/%d" % [card.data.display_name, game.get_attack(card), game.get_defense(card) - card.damage]
	return card.data.display_name


func _board(game: GameState) -> String:
	var parts: PackedStringArray = []
	for player: PlayerState in game.players:
		var units: PackedStringArray = []
		for unit: CardInstance in player.units():
			var flags: String = ""
			if unit.exhausted:
				flags += "x"
			if unit.summoning_sick:
				flags += "s"
			units.append("%s %d/%d%s" % [unit.data.display_name, game.get_attack(unit), game.get_defense(unit) - unit.damage, (" (" + flags + ")") if not flags.is_empty() else ""])
		var others: PackedStringArray = []
		for card: CardInstance in player.field:
			if not card.data.is_unit():
				others.append(card.data.display_name)
		var res: PackedStringArray = []
		for kind: ResourceKind.Kind in ResourceKind.all_with_tokens():
			var n: int = player.count_resource(kind)
			if n > 0:
				res.append("%s x%d" % [ResourceKind.display_name(kind), n])
		parts.append("P%d hp%d hand%d infra%d traps%d [%s]%s%s" % [player.index, player.hp, player.hand.size(), player.infrastructure.size(), player.traps.size(), ", ".join(units), (" {" + ", ".join(others) + "}") if not others.is_empty() else "", (" res: " + ", ".join(res)) if not res.is_empty() else ""])
	return " || ".join(parts)


func _describe(game: GameState, action: GameAction) -> String:
	var card: CardInstance = game.find_card(action.card_uid)
	var name: String = card.data.display_name if card != null else ""
	match action.type:
		GameAction.Type.PLAY:
			var targets: PackedStringArray = []
			for ref: int in action.targets:
				targets.append(_name(game, ref))
			return "PLAY %s%s" % [name, (" -> " + ", ".join(targets)) if not targets.is_empty() else ""]
		GameAction.Type.PLAY_INFRASTRUCTURE:
			return "INFRA %s" % name
		GameAction.Type.ACTIVATE_ABILITY, GameAction.Type.ACTIVATE:
			var targets: PackedStringArray = []
			for ref: int in action.targets:
				targets.append(_name(game, ref))
			if action.type == GameAction.Type.ACTIVATE and action.target != 0:
				targets.append(_name(game, action.target))
			return "ABILITY %s[%d]%s%s" % [name, action.effect_index, (" -> " + ", ".join(targets)) if not targets.is_empty() else "", (" X=%d" % action.x) if action.x > 0 else ""]
		GameAction.Type.USE_RESOURCE:
			return "USE %s -> %s" % [ResourceKind.display_name(action.effect_index as ResourceKind.Kind), _name(game, action.target)]
		GameAction.Type.DECLARE_ATTACKERS:
			var names: PackedStringArray = []
			for uid: int in action.uids:
				names.append(_name(game, uid))
			var blockers: PackedStringArray = []
			for unit: CardInstance in game.possible_blockers(1 - action.player):
				blockers.append(_name(game, unit.uid))
			return "ATTACK %s (foe could block with: %s)" % [", ".join(names), ", ".join(blockers) if not blockers.is_empty() else "nothing"]
		GameAction.Type.DECLARE_BLOCKERS:
			var pairs: PackedStringArray = []
			for key: Variant in action.blocks.keys():
				pairs.append("%s blocks %s" % [_name(game, int(action.blocks[key])), _name(game, int(key))])
			var unblocked: PackedStringArray = []
			for uid: int in game.attackers:
				if not action.blocks.has(uid):
					unblocked.append(_name(game, uid))
			return "BLOCK %s%s" % [", ".join(pairs), ("; unblocked: " + ", ".join(unblocked)) if not unblocked.is_empty() else ""]
		GameAction.Type.PASS:
			if game.phase == GameState.Phase.COMBAT and game.combat_step == GameState.CombatStep.DECLARE_BLOCKERS:
				var unblocked: PackedStringArray = []
				for uid: int in game.attackers:
					unblocked.append(_name(game, uid))
				return "NO BLOCK (attackers: %s; blockers available: %d)" % [", ".join(unblocked), game.possible_blockers(action.player).size()]
			if game.phase == GameState.Phase.COMBAT and game.combat_step == GameState.CombatStep.DECLARE_ATTACKERS and not game.possible_attackers(action.player).is_empty():
				return "NO ATTACK (could attack with %d)" % game.possible_attackers(action.player).size()
			return ""
		GameAction.Type.TOSS:
			var names: PackedStringArray = []
			for uid: int in action.uids:
				names.append(_name(game, uid))
			return "TOSS %s" % ", ".join(names)
		GameAction.Type.MULLIGAN:
			return "MULLIGAN"
	return ""


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
	var enemy_ai: AIPlayer = AIPlayer.new(ZoneDecks.personality(content, str(args.get("enemy_ai", encounter.enemy_ai_name))))
	ai.deterministic = true
	enemy_ai.deterministic = true
	var ais: Array[AIPlayer] = [ai, enemy_ai]
	var verbose: bool = args.has("verbose")
	var last_turn: int = -1
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
		if verbose and game.turn != last_turn and game.stage == GameState.Stage.PLAYING:
			last_turn = game.turn
			log.append("== turn %d (P%d) %s" % [game.turn, game.active, _board(game)])
		var started: int = Time.get_ticks_usec()
		var action: GameAction = ais[who].choose_action(game)
		var spent: float = float(Time.get_ticks_usec() - started) / 1000.0
		_think_count[who] += 1
		_think_total[who] += spent
		_think_max[who] = maxf(_think_max[who], spent)
		if spent > 1000.0:
			_think_slow[who] += 1
		if verbose:
			var text: String = _describe(game, action)
			if not text.is_empty():
				log.append("P%d t%d %s hp%d/%d%s" % [who, game.turn, text, game.players[0].hp, game.players[1].hp, (" [%.0f ms]" % spent) if spent >= 100.0 else ""])
		elif action.type != GameAction.Type.PASS and action.type != GameAction.Type.KEEP_HAND:
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
