class_name SimulationRunner
extends RefCounted
## Headless AI-vs-AI simulation: plays many games between decks and aggregates the results.

const MAX_STEPS_PER_GAME: int = 5000

var ai_a: AIPlayer = AIPlayer.new(AIPersonality.balanced())
var ai_b: AIPlayer = AIPlayer.new(AIPersonality.balanced())
var turn_limit: int = 60


## Plays one game. Seat 0 plays `deck_a`, seat 1 plays `deck_b`.
func play_game(deck_a: Deck, deck_b: Deck, seed_value: int, first_player: int) -> GameRecord:
	var options: GameOptions = GameOptions.new()
	options.rng_seed = seed_value
	options.first_player = first_player
	options.turn_limit = turn_limit
	options.record_events = false
	var game: GameState = GameState.new(options)
	game.add_player(PlayerSetup.create(deck_a, null, [] as Array[ModifierSource], deck_a.deck_name))
	game.add_player(PlayerSetup.create(deck_b, null, [] as Array[ModifierSource], deck_b.deck_name))
	game.start()
	var record: GameRecord = GameRecord.new()
	record.first_player = first_player
	var ais: Array[AIPlayer] = [ai_a, ai_b]
	var steps: int = 0
	while not game.is_over() and steps < MAX_STEPS_PER_GAME:
		steps += 1
		var who: int = game.awaiting_player()
		var action: GameAction = ais[who].choose_action(game)
		if action.type == GameAction.Type.CAST:
			var card: CardInstance = game.find_card(action.card_uid)
			if card != null:
				var counts: Dictionary = record.casts[who]
				counts[card.data.id] = int(counts.get(card.data.id, 0)) + 1
		if not game.apply_action(action):
			record.illegal_actions += 1
			if not game.apply_action(GameAction.pass_phase(who)):
				break
	record.finished = game.is_over()
	record.turns = game.turn
	record.winner = game.winner
	return record


## Plays `games` games, alternating who goes first.
func run_matchup(deck_a: Deck, deck_b: Deck, games: int, base_seed: int = 1000) -> MatchupStats:
	var stats: MatchupStats = MatchupStats.new()
	stats.deck_a = deck_a.deck_name
	stats.deck_b = deck_b.deck_name
	for i: int in range(games):
		stats.add(play_game(deck_a, deck_b, base_seed + i, i % 2))
	return stats


## Every unordered pair of decks; mirror matches are optional.
func round_robin(decks: Array[Deck], games_per_matchup: int, base_seed: int = 1000, include_mirrors: bool = false) -> Array[MatchupStats]:
	var results: Array[MatchupStats] = []
	for i: int in range(decks.size()):
		for j: int in range(i, decks.size()):
			if i == j and not include_mirrors:
				continue
			results.append(run_matchup(decks[i], decks[j], games_per_matchup, base_seed + (i * 10 + j) * 100000))
	return results
