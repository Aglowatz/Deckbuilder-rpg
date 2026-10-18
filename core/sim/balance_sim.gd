class_name BalanceSim
extends RefCounted
## Rebalance Part B: the headless balance simulator. The AI plays full battles (a `PlayerSpec` against an `EncounterSpec`) many times
## and reports the win rate, the average length in player turns, the HP left, and which cards mattered (win rate when the card was
## played vs overall). Supports the player's level, equipment, consumables (spent by `SimItemPolicy`) and the encounter's one-sided
## rules, zone effects and dungeon rules. `run_sequence` carries HP across a list of fights (a zone's roamers, a side dungeon).
## Quick mode is for iteration, full mode for the report: `QUICK_GAMES` / `FULL_GAMES` per (player, encounter).

const MAX_STEPS_PER_GAME: int = 5000
const TURN_LIMIT: int = 60
const QUICK_GAMES: int = 12
const FULL_GAMES: int = 100
## A card needs this many games played to appear in the impact lists.
const IMPACT_MIN_GAMES: int = 5


## The outcome of many games of one player against one encounter.
class Result:
	extends RefCounted
	var encounter: EncounterSpec
	var player_label: String = ""
	var games: int = 0
	var wins: int = 0
	var draws: int = 0
	var illegal_actions: int = 0
	var player_turns_total: int = 0
	var hp_left_on_win: int = 0
	var enemy_hp_left_on_loss: int = 0
	var first_player_games: int = 0
	var first_player_wins: int = 0
	var items_used: int = 0
	## card id -> {"games": games it was played in, "wins": of those, won, "plays": total plays}
	var cards: Dictionary = {}

	func win_rate() -> float:
		return (float(wins) + 0.5 * float(draws)) / float(maxi(1, games))

	func avg_player_turns() -> float:
		return float(player_turns_total) / float(maxi(1, games))

	func avg_hp_left_on_win() -> float:
		return float(hp_left_on_win) / float(maxi(1, wins))

	func avg_enemy_hp_left_on_loss() -> float:
		return float(enemy_hp_left_on_loss) / float(maxi(1, games - wins - draws))

	func first_player_win_rate() -> float:
		return float(first_player_wins) / float(maxi(1, first_player_games))

	## Cards sorted by lift (win rate when played minus overall), most helpful first; only cards played in enough games.
	func impact() -> Array[Dictionary]:
		var rows: Array[Dictionary] = []
		var overall: float = win_rate()
		for id: Variant in cards.keys():
			var entry: Dictionary = cards[id] as Dictionary
			var played: int = int(entry["games"])
			if played < IMPACT_MIN_GAMES:
				continue
			var when_played: float = float(entry["wins"]) / float(played)
			rows.append({"id": str(id), "games": played, "plays": int(entry["plays"]), "win_rate": when_played, "lift": when_played - overall, "per_game": float(entry["plays"]) / float(maxi(1, games))})
		rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["lift"]) > float(b["lift"]))
		return rows

	func merge(other: Result) -> void:
		games += other.games
		wins += other.wins
		draws += other.draws
		illegal_actions += other.illegal_actions
		player_turns_total += other.player_turns_total
		hp_left_on_win += other.hp_left_on_win
		enemy_hp_left_on_loss += other.enemy_hp_left_on_loss
		first_player_games += other.first_player_games
		first_player_wins += other.first_player_wins
		items_used += other.items_used
		for id: Variant in other.cards.keys():
			var mine: Dictionary = cards.get(id, {"games": 0, "wins": 0, "plays": 0}) as Dictionary
			var theirs: Dictionary = other.cards[id] as Dictionary
			cards[id] = {"games": int(mine["games"]) + int(theirs["games"]), "wins": int(mine["wins"]) + int(theirs["wins"]), "plays": int(mine["plays"]) + int(theirs["plays"])}


## The outcome of many runs through a sequence of fights with one HP pool.
class SequenceResult:
	extends RefCounted
	var key: String = ""
	var runs: int = 0
	var cleared: int = 0
	var hp_left_total: int = 0
	## fight index -> runs lost there
	var lost_at: Dictionary = {}

	func clear_rate() -> float:
		return float(cleared) / float(maxi(1, runs))

	func avg_hp_left() -> float:
		return float(hp_left_total) / float(maxi(1, cleared))


# ---- One game --------------------------------------------------------------------------------------------------------------------


## Plays one game. `start_hp` > 0 overrides the player's starting HP (HP carried over). `items` is spent in place.
static func play_game(content: ContentSet, player: PlayerSpec, encounter: EncounterSpec, seed_value: int, first_player: int, start_hp: int, items: Dictionary, result: Result) -> GameState:
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
	if start_hp > 0:
		setup.starting_hp = start_hp
	elif encounter.player_hp > 0:
		setup.starting_hp = encounter.player_hp
	var enemy: PlayerSetup = encounter.build_enemy(content, deck)
	if shared != null:
		enemy.modifiers.add_source(shared)
	var options: GameOptions = GameOptions.new()
	options.rng_seed = seed_value
	options.first_player = first_player
	options.turn_limit = TURN_LIMIT
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
	var ai: AIPlayer = AIPlayer.new(ZoneDecks.personality(content, player.ai_name))
	ai.use_resources = player.use_resources
	var enemy_ai: AIPlayer = AIPlayer.new(ZoneDecks.personality(content, encounter.enemy_ai_name))
	var ais: Array[AIPlayer] = [ai, enemy_ai]
	var played: Dictionary = {}
	var steps: int = 0
	var item_turn: int = -1
	var used_this_turn: Dictionary = {}
	while not game.is_over() and steps < MAX_STEPS_PER_GAME:
		steps += 1
		var who: int = game.awaiting_player()
		if who == 0 and not items.is_empty() and game.stage == GameState.Stage.PLAYING and game.in_main_phase():
			if item_turn != game.turn:
				item_turn = game.turn
				used_this_turn.clear()
			if SimItemPolicy.act(game, 0, items, content, used_this_turn):
				result.items_used += 1
				continue
		var action: GameAction = ais[who].choose_action(game)
		if who == 0 and (action.type == GameAction.Type.PLAY or action.type == GameAction.Type.ACTIVATE_ABILITY):
			var card: CardInstance = game.find_card(action.card_uid)
			if card != null and action.type == GameAction.Type.PLAY:
				played[card.data.id] = int(played.get(card.data.id, 0)) + 1
		if not game.apply_action(action):
			result.illegal_actions += 1
			if not game.apply_action(GameAction.pass_phase(who)):
				break
	# Bookkeeping.
	result.games += 1
	var won: bool = game.winner == 0
	if won:
		result.wins += 1
		result.hp_left_on_win += game.players[0].hp
	elif game.winner < 0:
		result.draws += 1
	else:
		result.enemy_hp_left_on_loss += game.players[1].hp
	var player_went_first: bool = _went_first(game, 0)
	result.player_turns_total += (game.turn + 1) / 2 if player_went_first else game.turn / 2
	if player_went_first:
		result.first_player_games += 1
		if won:
			result.first_player_wins += 1
	for id: Variant in played.keys():
		var entry: Dictionary = result.cards.get(id, {"games": 0, "wins": 0, "plays": 0}) as Dictionary
		entry["games"] = int(entry["games"]) + 1
		entry["plays"] = int(entry["plays"]) + int(played[id])
		if won:
			entry["wins"] = int(entry["wins"]) + 1
		result.cards[id] = entry
	return game


static func _went_first(game: GameState, player_index: int) -> bool:
	# Turn 1 belongs to the first player; the active seat alternates every turn.
	return (game.active == player_index) == (game.turn % 2 == 1)


# ---- Many games ------------------------------------------------------------------------------------------------------------------


static func run(content: ContentSet, player: PlayerSpec, encounter: EncounterSpec, games: int, base_seed: int = 7000) -> Result:
	var result: Result = Result.new()
	result.encounter = encounter
	result.player_label = player.label
	for i: int in range(games):
		var first: int = encounter.first_player if encounter.first_player >= 0 else i % 2
		var items: Dictionary = player.items.duplicate()
		play_game(content, player, encounter, base_seed + i, first, 0, items, result)
	return result


## The same encounter against each Path's expected player (`ProgressionModel.player_for`); merged into one Result plus one per Path.
static func run_all_paths(content: ContentSet, encounter: EncounterSpec, games_per_path: int, base_seed: int = 7000, level_override: int = 0) -> Dictionary:
	var per_path: Dictionary = {}
	var merged: Result = Result.new()
	merged.encounter = encounter
	merged.player_label = "all Paths"
	for path: Affinity.Type in Affinity.colored_types():
		var player: PlayerSpec = ProgressionModel.player_for(content, encounter, path)
		if level_override > 0:
			player.level = level_override
			player.deck = ProgressionModel.reference_deck(content, path, level_override)
			player.equipment_ids = ProgressionModel.equipment_for(level_override)
			player.items = ProgressionModel.items_for(level_override)
		var result: Result = run(content, player, encounter, games_per_path, base_seed + int(path) * 100000)
		per_path[path] = result
		merged.merge(result)
	return {"all": merged, "paths": per_path}


## Plays `encounters` in order with one HP pool (no healing between fights), `runs` times; a run is cleared when every fight is won.
static func run_sequence(content: ContentSet, player: PlayerSpec, encounters: Array[EncounterSpec], runs: int, base_seed: int = 9000, heal_before: Dictionary = {}) -> SequenceResult:
	var result: SequenceResult = SequenceResult.new()
	result.key = encounters[0].sequence if not encounters.is_empty() else ""
	result.runs = runs
	for run_index: int in range(runs):
		var hp: int = 0
		var items: Dictionary = player.items.duplicate()
		var alive: bool = true
		for index: int in range(encounters.size()):
			var encounter: EncounterSpec = encounters[index]
			if heal_before.get(index, false):
				hp = 0
			var scratch: Result = Result.new()
			scratch.encounter = encounter
			var first: int = encounter.first_player if encounter.first_player >= 0 else (run_index + index) % 2
			var game: GameState = play_game(content, player, encounter, base_seed + run_index * 31 + index, first, hp, items, scratch)
			if game.winner != 0:
				alive = false
				result.lost_at[index] = int(result.lost_at.get(index, 0)) + 1
				break
			hp = game.players[0].hp
		if alive:
			result.cleared += 1
			result.hp_left_total += hp
	return result


## Deck against deck (both seats the AI, no gear): for Part C's card balance checks. Returns a Result whose "encounter" is a stand-in.
static func run_matchup(content: ContentSet, deck_a: Deck, deck_b: Deck, games: int, base_seed: int = 3000, level: int = 1) -> Result:
	var encounter: EncounterSpec = EncounterSpec.new()
	encounter.id = "deck:%s" % deck_b.deck_name
	encounter.title = deck_b.deck_name
	encounter.group = "decks"
	encounter.kind = EncounterSpec.Kind.ELITE
	encounter.enemy_name = deck_b.deck_name
	encounter.enemy_hp = ProgressionTable.row(clampi(level, 1, ProgressionTable.MAX_LEVEL)).max_hp
	encounter.enemy_recipe = deck_b.copy_counts()
	encounter.expected_level = level
	var player: PlayerSpec = PlayerSpec.make(deck_a, level)
	return run(content, player, encounter, games, base_seed)


# ---- Reports ---------------------------------------------------------------------------------------------------------------------


static func percent(value: float) -> String:
	return "%d%%" % roundi(value * 100.0)


## One markdown table row per Result; `paths` (optional) adds a column per Path from `run_all_paths`.
static func table(rows: Array[Dictionary]) -> String:
	var lines: PackedStringArray = []
	lines.append("| Encounter | Kind | L | Target | Beefcake | Necrocrat | Gourmand | Refusemancer | All | Turns | HP left (wins) | Verdict |")
	lines.append("|---|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---|")
	for row: Dictionary in rows:
		var all: Result = row["all"] as Result
		var paths: Dictionary = row.get("paths", {}) as Dictionary
		var spec: EncounterSpec = all.encounter
		var cells: PackedStringArray = []
		for path: Affinity.Type in [Affinity.Type.BEEFCAKE, Affinity.Type.NECROCRAT, Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER]:
			cells.append(percent((paths[path] as Result).win_rate()) if paths.has(path) else "-")
		lines.append("| %s | %s | %d | %s | %s | %s | %s | %s | **%s** | %.1f | %.1f | %s |" % [
			spec.title.replace("|", "/"), EncounterSpec.kind_name(spec.kind), spec.expected_level, spec.target_text(),
			cells[0], cells[1], cells[2], cells[3], percent(all.win_rate()), all.avg_player_turns(), all.avg_hp_left_on_win(), verdict(all),
		])
	return "\n".join(lines)


static func verdict(result: Result) -> String:
	var spec: EncounterSpec = result.encounter
	var rate: float = result.win_rate()
	var band: Array = spec.target()
	var text: String = "ok"
	if rate < float(band[0]) - 0.0001:
		text = "TOO HARD (-%d)" % roundi((float(band[0]) - rate) * 100.0)
	elif rate > float(band[1]) + 0.0001:
		text = "too easy (+%d)" % roundi((rate - float(band[1])) * 100.0)
	var turns: float = result.avg_player_turns()
	if turns < float(EncounterSpec.TURNS_TARGET[0]):
		text += ", fast"
	elif turns > float(EncounterSpec.TURNS_TARGET[1]):
		text += ", slow"
	return text


## The most and least helpful cards of a Result.
static func impact_lines(result: Result, count: int = 5) -> String:
	var rows: Array[Dictionary] = result.impact()
	if rows.is_empty():
		return "(no card played in %d or more games)" % IMPACT_MIN_GAMES
	var parts: PackedStringArray = []
	var top: Array[Dictionary] = rows.slice(0, mini(count, rows.size()))
	var bottom: Array[Dictionary] = rows.slice(maxi(0, rows.size() - count), rows.size())
	var best: PackedStringArray = []
	for row: Dictionary in top:
		best.append("%s %+d (%d games)" % [str(row["id"]), roundi(float(row["lift"]) * 100.0), int(row["games"])])
	var worst: PackedStringArray = []
	for row: Dictionary in bottom:
		worst.append("%s %+d (%d games)" % [str(row["id"]), roundi(float(row["lift"]) * 100.0), int(row["games"])])
	parts.append("most helpful: " + ", ".join(best))
	parts.append("least helpful: " + ", ".join(worst))
	return "; ".join(parts)
