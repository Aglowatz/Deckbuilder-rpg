extends GutTest
## Fix pass Nov 7 (owner decision D6): the player's opening hand always holds at least two infrastructure cards
## (a hidden soft mulligan). Since Fable Nov 21 the foe's hand has the same floor.


func test_player_hand_has_two_infrastructure_in_every_seed() -> void:
	# 8 infrastructure in 45 cards: a plain 5-card hand misses two infrastructure about a third of the time.
	for seed_value: int in range(1, 121):
		var deck: Deck = GameFactory.make_deck(null, 8, 45)
		var game: GameState = GameFactory.new_game(seed_value, deck, GameFactory.make_deck(null, 8, 45))
		assert_gte(HandSmoother.count_infrastructure(game.players[0].hand), 2, "seed %d" % seed_value)
		assert_eq(game.players[0].hand.size() + game.players[0].deck.size(), 45, "no card created or lost")


## Fable Nov 21 (Part 2.6): the foe's hand gets the same floor now (it was never touched before); with its own switch off it keeps
## its natural draw. The full rule and its exceptions: tests/core/game/test_foe_opening_hand_nov21.gd.
func test_foe_hand_is_floored_too_since_nov21() -> void:
	var below_floor: int = 0
	var below_when_off: int = 0
	for seed_value: int in range(1, 121):
		var game: GameState = GameFactory.new_game(seed_value, GameFactory.make_deck(null, 8, 45), GameFactory.make_deck(null, 8, 45))
		if HandSmoother.count_infrastructure(game.players[1].hand) < 2:
			below_floor += 1
		var opts: GameOptions = GameOptions.new()
		opts.foe_opening_infrastructure_floor = 0
		var plain: GameState = GameFactory.new_game(seed_value, GameFactory.make_deck(null, 8, 45), GameFactory.make_deck(null, 8, 45), opts)
		if HandSmoother.count_infrastructure(plain.players[1].hand) < 2:
			below_when_off += 1
	assert_eq(below_floor, 0, "the foe's opening hand holds two infrastructure in every seed")
	assert_gt(below_when_off, 0, "and keeps its natural draw when the foe's floor is off")


func test_floor_can_be_turned_off() -> void:
	var below_floor: int = 0
	for seed_value: int in range(1, 121):
		var opts: GameOptions = GameOptions.new()
		opts.opening_infrastructure_floor = 0
		opts.hand_smoother = false
		var game: GameState = GameFactory.new_game(seed_value, GameFactory.make_deck(null, 8, 45), GameFactory.make_deck(null, 8, 45), opts)
		if HandSmoother.count_infrastructure(game.players[0].hand) < 2:
			below_floor += 1
	assert_gt(below_floor, 0)


func test_floor_holds_after_a_mulligan() -> void:
	for seed_value: int in range(1, 41):
		var opts: GameOptions = GameOptions.new()
		opts.rng_seed = seed_value
		var game: GameState = GameState.new(opts)
		game.add_player(PlayerSetup.create(GameFactory.make_deck(null, 8, 45), null, [], "P0"))
		game.add_player(PlayerSetup.create(GameFactory.make_deck(null, 8, 45), null, [], "P1"))
		game.start()
		assert_eq(game.stage, GameState.Stage.MULLIGAN)
		assert_true(game.mulligan(0))
		assert_gte(HandSmoother.count_infrastructure(game.players[0].hand), 2)


func test_ensure_infrastructure_stops_when_the_deck_has_none() -> void:
	var game: GameState = GameState.new()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 3
	var hand: Array[CardInstance] = []
	var deck: Array[CardInstance] = []
	for i: int in range(5):
		hand.append(game.create_instance(GameFactory.vanilla(1, 1), 0))
	deck.append(game.create_instance(GameFactory.infra(), 0))
	for i: int in range(10):
		deck.append(game.create_instance(GameFactory.vanilla(2, 2), 0))
	var swaps: int = HandSmoother.ensure_infrastructure(hand, deck, 2, rng)
	assert_eq(swaps, 1)
	assert_eq(HandSmoother.count_infrastructure(hand), 1)
	assert_eq(hand.size(), 5)
	assert_eq(deck.size(), 11)
