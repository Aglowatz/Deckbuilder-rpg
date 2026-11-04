extends SceneTree
## Fix pass Nov 4 (Part 1.5): plays an encounter many times (the balance sim's seats) and watches every attack decision of the FOE.
## Flags the declarations where attacking was clearly right and the AI held back or under-attacked:
##   - lethal on board: the ready attackers' total power reaches the player's HP and the player has no ready blocker;
##   - free damage: the player has no ready blocker at all, yet the AI attacked with nothing.
## Usage: Godot --headless --path . -s res://tools/attack_when_ahead_probe.gd -- [--spec=zone:gourmand:casserole] [--games=6]
## Prints a summary line per spec and up to 6 examples (the board, the HP, what the AI chose).


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var args: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		var parts: PackedStringArray = arg.trim_prefix("--").split("=", true, 1)
		args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	var content: ContentSet = ContentLibrary.load_all()
	var filter: String = str(args.get("spec", "zone:gourmand:casserole"))
	var games: int = int(args.get("games", 6))
	var total_bad: int = 0
	args_live = args.has("live")
	for spec: EncounterSpec in EncounterCatalog.filtered(content, filter):
		total_bad += _probe(content, spec, games)
	print("attack decisions (think ms, candidates scored): ", ", ".join(slow.slice(0, 60)))
	print("PROBE DONE: %d clear misses" % total_bad)
	quit(0)


var args_live: bool = false
var attack_ms: float = 0.0
var slow: Array[String] = []


func _probe(content: ContentSet, spec: EncounterSpec, games: int) -> int:
	var decisions: int = 0
	var lethal_seen: int = 0
	var lethal_missed: int = 0
	var free_seen: int = 0
	var free_missed: int = 0
	var examples: PackedStringArray = []
	var seed_value: int = 4400
	for path: Affinity.Type in Affinity.colored_types():
		var player: PlayerSpec = ProgressionModel.player_for(content, spec, path)
		for i: int in range(games):
			seed_value += 1
			var game: GameState = _build(content, player, spec, seed_value, i % 2)
			var ai: AIPlayer = AIPlayer.for_foe(ZoneDecks.personality(content, player.ai_name), AIPlayer.Skill.ELITE)
			var foe_ai: AIPlayer = AIPlayer.for_foe(ZoneDecks.personality(content, spec.enemy_ai_name), EncounterSpec.skill_for(spec.kind), spec.enemy_name)
			ai.deterministic = true
			foe_ai.deterministic = not args_live
			attack_ms = 0.0
			var steps: int = 0
			while not game.is_over() and steps < 600:
				steps += 1
				var who: int = game.awaiting_player()
				var action: GameAction = (ai if who == 0 else foe_ai).choose_action(game)
				if who == 1 and game.phase == GameState.Phase.COMBAT and game.combat_step == GameState.CombatStep.DECLARE_ATTACKERS:
					decisions += 1
					var power: int = 0
					var ready: Array[CardInstance] = []
					for card: CardInstance in game.possible_attackers(1):
						if game.get_attack(card) > 0:
							ready.append(card)
							power += game.get_attack(card)
					var blockers: int = game.possible_blockers(0).size()
					var sent: int = 0
					if action.type == GameAction.Type.DECLARE_ATTACKERS:
						for uid: int in action.uids:
							var card: CardInstance = game.find_permanent(uid)
							if card != null:
								sent += game.get_attack(card)
					var hp: int = game.players[0].hp
					var miss: String = ""
					if not ready.is_empty() and blockers == 0:
						free_seen += 1
						if power >= hp:
							lethal_seen += 1
							if sent < hp:
								lethal_missed += 1
								miss = "LETHAL MISSED"
						elif sent == 0:
							free_missed += 1
							miss = "FREE DAMAGE MISSED"
					if not miss.is_empty() and examples.size() < 6:
						examples.append("  %s (path %s, seed %d, turn %d): you %d HP, foe %d HP, ready %s = %d power, sent %d\n    you: %s\n    foe: %s" % [miss, Affinity.display_name(path), seed_value, game.turn, hp, game.players[1].hp, _names(game, ready), power, sent, _board(game, 0), _board(game, 1)])
				if who == 1 and action.type != GameAction.Type.PASS or game.combat_step == GameState.CombatStep.DECLARE_ATTACKERS and who == 1:
					if game.combat_step == GameState.CombatStep.DECLARE_ATTACKERS and slow.size() < 400:
						slow.append("%.0f ms, %d candidates" % [foe_ai.last_think_ms, foe_ai._combat.last_ranked.size()])
				if not game.apply_action(action):
					if not game.apply_action(GameAction.pass_phase(who)):
						break
	print("%s: %d foe attack steps, lethal %d (missed %d), free damage %d (held back %d)" % [spec.id, decisions, lethal_seen, lethal_missed, free_seen - lethal_seen, free_missed])
	for line: String in examples:
		print(line)
	return lethal_missed + free_missed


func _build(content: ContentSet, player: PlayerSpec, spec: EncounterSpec, seed_value: int, first: int) -> GameState:
	var sources: Array[ModifierSource] = player.extra_sources.duplicate()
	var shared: ModifierSource = spec.shared_source()
	if shared != null:
		sources.append(shared)
	var player_rules: ModifierSource = spec.player_rules_source()
	if player_rules != null:
		sources.append(player_rules)
	sources.append_array(spec.player_sources)
	var setup: PlayerSetup = PlayerSetup.create(player.deck, player.profile(content), sources, player.label)
	var enemy: PlayerSetup = spec.build_enemy(content, player.deck)
	if shared != null:
		enemy.modifiers.add_source(shared)
	var options: GameOptions = GameOptions.new()
	options.rng_seed = seed_value
	options.first_player = first
	options.record_events = false
	var game: GameState = GameState.new(options)
	game.add_player(setup)
	game.add_player(enemy)
	game.start()
	return game


func _names(game: GameState, cards: Array[CardInstance]) -> String:
	var names: PackedStringArray = []
	for card: CardInstance in cards:
		names.append("%s %d/%d" % [card.data.display_name, game.get_attack(card), game.get_defense(card) - card.damage])
	return ", ".join(names)


func _board(game: GameState, index: int) -> String:
	var parts: PackedStringArray = []
	for card: CardInstance in game.players[index].field:
		if card.data.is_unit():
			parts.append("%s %d/%d%s%s" % [card.data.display_name, game.get_attack(card), game.get_defense(card) - card.damage, " x" if card.exhausted else "", " fresh" if card.just_arrived else ""])
	var traps: int = game.players[index].traps.size() if "traps" in game.players[index] else 0
	return "%s | traps %d | hand %d" % [", ".join(parts), traps, game.players[index].hand.size()]
