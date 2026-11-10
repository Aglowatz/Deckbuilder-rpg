extends GutTest
## Overnight Nov 9-10 (RC1 critic #2): the Forgotten Cave's flood guard - once the hero holds FirstDuel.CAVE_FLOOD_GUARD infrastructure
## (in play + in hand), an infrastructure draw is swapped for the next non-infrastructure card down the deck. Off everywhere else.


func _game_with_deck(guard: int, held: int) -> GameState:
	CardSet.load_all()
	var game: GameState = GameFactory.blank_game(7)
	game.options.flood_guard = guard
	game.options.flood_guard_seat = 0
	var player: PlayerState = game.players[0]
	player.deck.clear()
	GameFactory.add_infrastructure_cards(game, 0, held)
	# deck top = end: [unit, infra, infra] -> the next draw is an infrastructure
	player.deck.append(game.create_instance(GameFactory.vanilla(2, 2), 0))
	player.deck.append(game.create_instance(GameFactory.infra(), 0))
	player.deck.append(game.create_instance(GameFactory.infra(), 0))
	return game


func test_the_guard_swaps_an_infrastructure_draw_once_enough_is_held() -> void:
	var game: GameState = _game_with_deck(FirstDuel.CAVE_FLOOD_GUARD, FirstDuel.CAVE_FLOOD_GUARD)
	game.draw_cards(0, 1)
	var drawn: CardInstance = game.players[0].hand.back()
	assert_true(drawn.data.is_unit(), "the unit came up instead of a sixth infrastructure")
	assert_eq(game.players[0].deck.size(), 2, "the infrastructure went back into the deck")
	for card: CardInstance in game.players[0].deck:
		assert_true(card.data.is_infrastructure())


func test_the_guard_lets_infrastructure_through_below_the_cap() -> void:
	var game: GameState = _game_with_deck(FirstDuel.CAVE_FLOOD_GUARD, 2)
	game.draw_cards(0, 1)
	assert_true(game.players[0].hand.back().data.is_infrastructure())


func test_off_by_default_and_never_for_the_other_seat() -> void:
	var off: GameState = _game_with_deck(0, 8)
	off.draw_cards(0, 1)
	assert_true(off.players[0].hand.back().data.is_infrastructure(), "no guard outside the cave")
	assert_eq(GameOptions.new().flood_guard, 0)
	var other: GameState = _game_with_deck(FirstDuel.CAVE_FLOOD_GUARD, 8)
	other.options.flood_guard_seat = 1
	other.draw_cards(0, 1)
	assert_true(other.players[0].hand.back().data.is_infrastructure(), "the enemy seat is never guarded")


func test_clone_keeps_the_guard() -> void:
	var options: GameOptions = GameOptions.new()
	FirstDuel.apply_flood_guard(options)
	assert_eq(options.clone().flood_guard, FirstDuel.CAVE_FLOOD_GUARD)
