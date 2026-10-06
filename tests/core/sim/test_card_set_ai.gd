extends CardTestBase
## Brief 14: the AI plays the designed card set (resources, Tools, Wonders, Traps, activated abilities) to the end of a game without
## ever choosing an illegal action or looping forever.


func _deck_for(paths: Array[Affinity.Type], rng: RandomNumberGenerator) -> Deck:
	var deck: Deck = Deck.new()
	var basics: Dictionary = {Affinity.Type.BEEFCAKE: "BAS-B", Affinity.Type.NECROCRAT: "BAS-N", Affinity.Type.GOURMAND: "BAS-G", Affinity.Type.REFUSEMANCER: "BAS-R"}
	for i: int in range(18):
		deck.cards.append(CardSet.card(str(basics[paths[i % paths.size()]])))
	var pool: Array[CardData] = []
	for card: CardData in CardSet.all_cards():
		if card.is_infrastructure():
			continue
		var fits: bool = true
		for path: Affinity.Type in card.paths():
			if not paths.has(path):
				fits = false
		if fits:
			pool.append(card)
	var copies: Dictionary = {}
	var guard: int = 0
	while deck.cards.size() < 45 and guard < 2000 and not pool.is_empty():
		guard += 1
		var pick: CardData = pool[rng.randi_range(0, pool.size() - 1)]
		if int(copies.get(pick.id, 0)) >= 4:
			continue
		copies[pick.id] = int(copies.get(pick.id, 0)) + 1
		deck.cards.append(pick)
	return deck


func _play_game(seed_value: int, paths_a: Array[Affinity.Type], paths_b: Array[Affinity.Type]) -> GameState:
	CardSet.load_all()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	var options: GameOptions = GameOptions.new()
	options.rng_seed = seed_value
	options.turn_limit = 70
	var game: GameState = GameState.new(options)
	game.add_player(PlayerSetup.create(_deck_for(paths_a, rng), null, [], "A"))
	game.add_player(PlayerSetup.create(_deck_for(paths_b, rng), null, [], "B"))
	game.start()
	var ais: Array[AIPlayer] = [AIPlayer.new(AIPersonality.balanced()), AIPlayer.new(AIPersonality.aggressive())]
	var steps: int = 0
	while not game.is_over() and steps < 4000:
		steps += 1
		var who: int = game.awaiting_player()
		var action: GameAction = ais[who].choose_action(game)
		if not game.apply_action(action):
			fail_test("the AI chose an illegal action: %s (seed %d, turn %d)" % [action.describe(), seed_value, game.turn])
			return game
	assert_true(game.is_over(), "the game finished (seed %d)" % seed_value)
	return game


func test_ai_plays_complete_games_with_the_designed_cards() -> void:
	var matchups: Array[Array] = [
		[[Affinity.Type.BEEFCAKE, Affinity.Type.GOURMAND], [Affinity.Type.NECROCRAT, Affinity.Type.REFUSEMANCER]],
		[[Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER], [Affinity.Type.BEEFCAKE, Affinity.Type.NECROCRAT]],
		[[Affinity.Type.NECROCRAT, Affinity.Type.GOURMAND], [Affinity.Type.BEEFCAKE, Affinity.Type.REFUSEMANCER]],
	]
	var seed_value: int = 100
	for matchup: Array in matchups:
		seed_value += 1
		var paths_a: Array[Affinity.Type] = []
		var paths_b: Array[Affinity.Type] = []
		for path: Variant in matchup[0]:
			paths_a.append(int(path) as Affinity.Type)
		for path: Variant in matchup[1]:
			paths_b.append(int(path) as Affinity.Type)
		_play_game(seed_value, paths_a, paths_b)
