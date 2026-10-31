extends RefCounted
## The work of `tools/starter_infra_study.gd` (loaded after the autoloads exist). See that file's header.

const DEFAULT_INFRA: Array[int] = [19, 17, 15]
const MAX_STEPS: int = 5000
const CAP: int = 3


class Tally:
	extends RefCounted
	var games: int = 0
	var wins: int = 0
	var draws: int = 0
	var first_play_total: int = 0
	var first_play_games: int = 0
	var never_played: int = 0
	var dead_turns: int = 0
	var player_turns: int = 0
	var flood_turns: int = 0

	func win_rate() -> float:
		return (float(wins) + 0.5 * float(draws)) / float(maxi(1, games))

	func first_play() -> float:
		return float(first_play_total) / float(maxi(1, first_play_games))

	func dead_per_game() -> float:
		return float(dead_turns) / float(maxi(1, games))

	func flood_per_game() -> float:
		return float(flood_turns) / float(maxi(1, games))

	func merge(other: Tally) -> void:
		games += other.games
		wins += other.wins
		draws += other.draws
		first_play_total += other.first_play_total
		first_play_games += other.first_play_games
		never_played += other.never_played
		dead_turns += other.dead_turns
		player_turns += other.player_turns
		flood_turns += other.flood_turns


func run(args: Dictionary) -> bool:
	var games: int = int(args.get("games", "20"))
	var seeds: Array[int] = []
	for part: String in str(args.get("seeds", "7000,8100")).split(",", false):
		seeds.append(int(part))
	var counts: Array[int] = []
	for part: String in str(args.get("infra", "19,17,15")).split(",", false):
		counts.append(int(part))
	var out_path: String = str(args.get("out", "res://docs/design/sim/starter_infra_oct31.md"))
	var only_path: String = str(args.get("path", ""))
	var content: ContentSet = ContentLibrary.load_all()
	var started: int = Time.get_ticks_msec()
	var lines: PackedStringArray = []
	lines.append("# Starter deck Infrastructure study (Oct 31, fresh eyes round 2)")
	lines.append("")
	lines.append("Sim only (`tools/starter_infra_study.gd`): each Path's 45-card starter rebuilt with %s Infrastructure (the removed basics become extra copies of the deck's own cheapest cards, 3-copy cap), played by the sim's Elite AI with `deterministic` on, %d games per fight per seed, seeds %s. The cave is the tutorial's three fights at level 1; the first zone is the Path's own zone (its roamers and elites) at the zone's expected level with the model's gear and items. \"First real play\" is the player's turn on which the first non-Infrastructure card was played; \"dead turns\" are the player's turns on which nothing was played; \"flood turns\" are player turns that ended with 3 or more Infrastructure still in hand." % [", ".join(PackedStringArray(counts.map(func(c: int) -> String: return str(c)))), games, str(args.get("seeds", "7000,8100"))])
	lines.append("")
	var summary: Dictionary = {}
	for path: Affinity.Type in Affinity.colored_types():
		var path_name: String = Affinity.display_name(path)
		if not only_path.is_empty() and path_name.to_lower() != only_path.to_lower():
			continue
		lines.append("## %s" % path_name)
		lines.append("")
		lines.append("| Infra | Deck fill | Cave win % | Cave first play | Cave dead / game | Cave flood / game | Zone win % | Zone first play | Zone dead / game | Zone flood / game |")
		lines.append("|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|")
		for count: int in counts:
			var fill: Array[String] = []
			var deck: Deck = _deck_with_infra(content, path, count, fill)
			var cave: Tally = Tally.new()
			var zone: Tally = Tally.new()
			for spec: EncounterSpec in EncounterCatalog.filtered(content, "tutorial"):
				if spec.group != "tutorial":
					continue
				for seed_value: int in seeds:
					cave.merge(_play_many(content, _player(content, deck, spec, path), spec, games, seed_value))
			var zone_specs: Array[EncounterSpec] = []
			for spec: EncounterSpec in EncounterCatalog.filtered(content, "zone:%s" % _zone_id(path)):
				if spec.group == "zone:%s" % _zone_id(path):
					zone_specs.append(spec)
			for spec: EncounterSpec in zone_specs:
				for seed_value: int in seeds:
					zone.merge(_play_many(content, _player(content, deck, spec, path), spec, games, seed_value))
			summary["%s:%d" % [path_name, count]] = {"cave": cave, "zone": zone}
			lines.append("| %d | %s | %s | %.1f | %.2f | %.2f | %s | %.1f | %.2f | %.2f |" % [count, "as shipped" if fill.is_empty() else "+" + ", ".join(fill), BalanceSim.percent(cave.win_rate()), cave.first_play(), cave.dead_per_game(), cave.flood_per_game(), BalanceSim.percent(zone.win_rate()), zone.first_play(), zone.dead_per_game(), zone.flood_per_game()])
			print("starter_infra_study: %s infra %d: cave %s (first play %.1f, dead %.2f, flood %.2f) zone %s (first play %.1f, dead %.2f, flood %.2f) [%d zone fights]" % [path_name, count, BalanceSim.percent(cave.win_rate()), cave.first_play(), cave.dead_per_game(), cave.flood_per_game(), BalanceSim.percent(zone.win_rate()), zone.first_play(), zone.dead_per_game(), zone.flood_per_game(), zone_specs.size()])
		lines.append("")
	lines.append("## Reading")
	lines.append("")
	lines.append(_reading(summary, counts))
	lines.append("")
	lines.append("Wall clock: %.0f s." % (float(Time.get_ticks_msec() - started) / 1000.0))
	var file: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	if file == null:
		push_error("starter_infra_study: cannot write %s" % out_path)
		return false
	file.store_string("\n".join(lines) + "\n")
	file.close()
	print("starter_infra_study: wrote %s" % out_path)
	return true


func _zone_id(path: Affinity.Type) -> String:
	return Affinity.display_name(path).to_lower()


func _player(content: ContentSet, deck: Deck, spec: EncounterSpec, path: Affinity.Type) -> PlayerSpec:
	var base: PlayerSpec = ProgressionModel.player_for(content, spec, path)
	var player: PlayerSpec = PlayerSpec.make(deck, base.level, "%s starter" % Affinity.display_name(path))
	player.equipment_ids = base.equipment_ids
	player.items = base.items
	return player


## The 45-card starter with `count` Infrastructure: basics removed from 19 are replaced by extra copies of the deck's own cheapest
## non-Infrastructure cards (energy cost, then id), one copy per card per pass, never above `CAP` copies. `fill` lists what was added.
func _deck_with_infra(content: ContentSet, path: Affinity.Type, count: int, fill: Array[String]) -> Deck:
	var deck: Deck = CampaignStart.starter_deck(content, path)
	var remove: int = CampaignStart.INFRASTRUCTURE_COUNT - count
	if remove <= 0:
		return deck
	var removed: int = 0
	var kept: Array[CardData] = []
	for card: CardData in deck.cards:
		if card.is_infrastructure() and removed < remove:
			removed += 1
			continue
		kept.append(card)
	deck.cards = kept
	var distinct: Array[CardData] = []
	var seen: Dictionary = {}
	for card: CardData in deck.cards:
		if card.is_infrastructure() or seen.has(card.id):
			continue
		seen[card.id] = true
		distinct.append(card)
	distinct.sort_custom(func(a: CardData, b: CardData) -> bool:
		if a.energy_value() != b.energy_value():
			return a.energy_value() < b.energy_value()
		return a.id < b.id)
	var to_add: int = removed
	var guard: int = 0
	while to_add > 0 and guard < 10:
		guard += 1
		for card: CardData in distinct:
			if to_add <= 0:
				break
			if deck.count_of(card.id) >= CAP:
				continue
			deck.cards.append(card)
			fill.append(card.display_name)
			to_add -= 1
	return deck


func _play_many(content: ContentSet, player: PlayerSpec, spec: EncounterSpec, games: int, base_seed: int) -> Tally:
	var tally: Tally = Tally.new()
	for i: int in range(games):
		var first: int = spec.first_player if spec.first_player >= 0 else i % 2
		_play_one(content, player, spec, base_seed + i, first, tally)
	return tally


## `BalanceSim.play_game`'s loop with the two extra measurements (it cannot be reused: it records nothing per turn).
func _play_one(content: ContentSet, player: PlayerSpec, encounter: EncounterSpec, seed_value: int, first_player: int, tally: Tally) -> void:
	var deck: Deck = player.deck
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
	for token_id: String in encounter.ally_token_ids:
		var data: CardData = TokenRegistry.data(token_id)
		if data != null:
			var ally: CardInstance = game.create_token(0, data)
			ally.summoning_sick = false
	var ai: AIPlayer = AIPlayer.for_foe(ZoneDecks.personality(content, player.ai_name), AIPlayer.Skill.ELITE)
	ai.use_resources = player.use_resources
	var enemy_ai: AIPlayer = AIPlayer.for_foe(ZoneDecks.personality(content, encounter.enemy_ai_name), EncounterSpec.skill_for(encounter.kind), encounter.enemy_name)
	ai.deterministic = true
	enemy_ai.deterministic = true
	var ais: Array[AIPlayer] = [ai, enemy_ai]
	var items: Dictionary = player.items.duplicate()
	var steps: int = 0
	var item_turn: int = -1
	var used_this_turn: Dictionary = {}
	var current_turn: int = -1
	var played_this_turn: bool = false
	var player_turn_index: int = 0
	var first_real_play: int = 0
	while not game.is_over() and steps < MAX_STEPS:
		steps += 1
		var who: int = game.awaiting_player()
		if who == 0 and game.turn != current_turn:
			if current_turn >= 0:
				_close_turn(game, played_this_turn, tally)
			current_turn = game.turn
			player_turn_index += 1
			played_this_turn = false
		if who == 0 and not items.is_empty() and game.stage == GameState.Stage.PLAYING and game.in_main_phase():
			if item_turn != game.turn:
				item_turn = game.turn
				used_this_turn.clear()
			if SimItemPolicy.act(game, 0, items, content, used_this_turn):
				continue
		var action: GameAction = ais[who].choose_action(game)
		if who == 0 and (action.type == GameAction.Type.PLAY or action.type == GameAction.Type.PLAY_INFRASTRUCTURE):
			played_this_turn = true
			if action.type == GameAction.Type.PLAY and first_real_play == 0:
				first_real_play = player_turn_index
		if not game.apply_action(action):
			if not game.apply_action(GameAction.pass_phase(who)):
				break
	if current_turn >= 0:
		_close_turn(game, played_this_turn, tally)
	tally.games += 1
	if game.winner == 0:
		tally.wins += 1
	elif game.winner < 0:
		tally.draws += 1
	tally.player_turns += player_turn_index
	if first_real_play > 0:
		tally.first_play_total += first_real_play
		tally.first_play_games += 1
	else:
		tally.never_played += 1


func _close_turn(game: GameState, played: bool, tally: Tally) -> void:
	if not played:
		tally.dead_turns += 1
	var infra_in_hand: int = 0
	for card: CardInstance in game.players[0].hand:
		if card.data.is_infrastructure():
			infra_in_hand += 1
	if infra_in_hand >= 3:
		tally.flood_turns += 1


func _reading(summary: Dictionary, counts: Array[int]) -> String:
	var lines: PackedStringArray = []
	var all_improve: bool = true
	var any_measured: bool = false
	for path: Affinity.Type in Affinity.colored_types():
		var path_name: String = Affinity.display_name(path)
		var base_key: String = "%s:%d" % [path_name, CampaignStart.INFRASTRUCTURE_COUNT]
		if not summary.has(base_key):
			continue
		any_measured = true
		var base: Dictionary = summary[base_key] as Dictionary
		var base_cave: Tally = base["cave"] as Tally
		var base_zone: Tally = base["zone"] as Tally
		var best: String = "as shipped (%d)" % CampaignStart.INFRASTRUCTURE_COUNT
		var improved: bool = false
		for count: int in counts:
			if count == CampaignStart.INFRASTRUCTURE_COUNT:
				continue
			var key: String = "%s:%d" % [path_name, count]
			if not summary.has(key):
				continue
			var cave: Tally = (summary[key] as Dictionary)["cave"] as Tally
			var zone: Tally = (summary[key] as Dictionary)["zone"] as Tally
			var better: bool = cave.win_rate() >= base_cave.win_rate() - 0.005 and zone.win_rate() >= base_zone.win_rate() - 0.005 and cave.win_rate() >= 0.80 and (cave.win_rate() > base_cave.win_rate() + 0.005 or zone.win_rate() > base_zone.win_rate() + 0.005)
			lines.append("- %s at %d: cave %s -> %s, zone %s -> %s, first play %.1f -> %.1f, dead turns %.2f -> %.2f, flood %.2f -> %.2f: %s." % [path_name, count, BalanceSim.percent(base_cave.win_rate()), BalanceSim.percent(cave.win_rate()), BalanceSim.percent(base_zone.win_rate()), BalanceSim.percent(zone.win_rate()), base_cave.first_play(), cave.first_play(), base_cave.dead_per_game(), cave.dead_per_game(), base_cave.flood_per_game(), cave.flood_per_game(), "better on both fronts" if better else ("worse somewhere" if (cave.win_rate() < base_cave.win_rate() - 0.005 or zone.win_rate() < base_zone.win_rate() - 0.005) else "a wash")])
			if better:
				improved = true
				best = "%d" % count
		if not improved:
			all_improve = false
		lines.append("  - %s: %s." % [path_name, "keep 19" if not improved else "a lower count (%s) reads better" % best])
	if not any_measured:
		return "Nothing measured."
	lines.append("")
	lines.append("**Verdict**: %s" % ("every Path improves with fewer Infrastructure and the cave stays at 80 %+: the change qualifies under the brief's rule (apply only if every Path improves)." if all_improve else "not every Path improves (or the cave leaves the 80 %+ band): the starter stays at 19 Infrastructure; the table is the designer's to read."))
	return "\n".join(lines)
