extends GutTest
## Nov 26 day (Part E): the simulated player's item sense (core/sim/sim_item_policy.gd). Sim only: the game itself is untouched.

var content: ContentSet


func before_all() -> void:
	content = ContentLibrary.load_all()


func _my_main_phase() -> GameState:
	var game: GameState = GameFactory.blank_game(3)
	var guard: int = 0
	while (game.active != 0 or not game.in_main_phase()) and guard < 20:
		guard += 1
		GameFactory.pass_turn(game)
	for player: PlayerState in game.players:
		player.hand.clear()
	assert_eq(game.active, 0)
	assert_true(game.in_main_phase())
	return game


func test_a_heal_is_drunk_when_none_of_it_is_wasted() -> void:
	var game: GameState = _my_main_phase()
	var hero: PlayerState = game.players[0]
	hero.hp = hero.max_hp - 5  # above half health: the old rule held the salve back
	var items: Dictionary = {"healing_salve": 1}
	assert_true(SimItemPolicy.act(game, 0, items, content, {}), "4 of 5 missing HP: the salve is used")
	assert_eq(hero.hp, hero.max_hp - 1)
	assert_eq(int(items["healing_salve"]), 0)


func test_a_heal_is_kept_when_most_of_it_would_be_wasted() -> void:
	var game: GameState = _my_main_phase()
	game.players[0].hp = game.players[0].max_hp - 2
	var items: Dictionary = {"healing_salve": 1}
	assert_false(SimItemPolicy.act(game, 0, items, content, {}), "2 missing, heals 4: kept")


func test_the_energy_draught_buys_a_card_one_short() -> void:
	var game: GameState = _my_main_phase()
	for i: int in range(2):
		GameFactory.add_infrastructure(game, 0)
	var card: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(3, 3, 3))
	assert_false(game.can_play_card(0, card.uid), "two infrastructure: the 3-cost unit is one short")
	var items: Dictionary = {"energy_draught": 1}
	assert_true(SimItemPolicy.act(game, 0, items, content, {}), "the Draught is used")
	assert_true(game.can_play_card(0, card.uid), "and the unit can be played")


func test_the_energy_draught_waits_when_it_buys_nothing() -> void:
	var game: GameState = _my_main_phase()
	GameFactory.add_infrastructure(game, 0)
	GameFactory.add_to_hand(game, 0, GameFactory.vanilla(5, 5, 5))
	var items: Dictionary = {"energy_draught": 1}
	assert_false(SimItemPolicy.act(game, 0, items, content, {}), "still four short: kept")
	assert_eq(game.players[0].pool.size(), 0, "the trial energy is taken back")
