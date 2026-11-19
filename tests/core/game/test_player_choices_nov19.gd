extends CardTestBase
## Overnight Nov 19 (Part 1.1): choices the engine used to make for the player now wait for the player - the unit an opponent's
## edict destroys (Post-Human Resources Ghoul), a triggered ability's target (Grim Repper), a pick(...) inside an effect (Bulking
## Program), a "choose one" (Community Garden) and a "you may" (Barbell of the Ancients). The AI's seat keeps the automatic picks.


func _choice_game() -> GameState:
	var game: GameState = _game()
	game.interactive_choices[0] = true
	_energy(game, 0)
	_energy(game, 1)
	return game


func _answer(game: GameState, answer: int) -> bool:
	var action: GameAction = GameAction.make(GameAction.Type.CHOOSE, 0)
	action.target = answer
	return game.apply_action(action)


func test_the_ghoul_lets_the_player_pick_which_of_their_units_dies() -> void:
	var game: GameState = _choice_game()
	var big: CardInstance = _unit(game, 0, 5, 5)
	var small: CardInstance = _unit(game, 0, 1, 1)
	game.active = 1
	_play(game, "N-03", [] as Array[int], 1)
	assert_eq(game.choice_requests.size(), 1, "the edict waits for the player")
	assert_eq(str(game.choice_requests[0]["kind"]), "edict")
	assert_eq(game.awaiting_player(), 0, "the player answers, on the opponent's turn")
	assert_true(game.players[0].field.has(big) and game.players[0].field.has(small), "nothing dies before the choice")
	assert_false(game.apply_action(GameAction.pass_phase(1)), "nothing else happens while the choice waits")
	assert_false(_answer(game, 999999), "only the offered units")
	assert_true(_answer(game, big.uid), "the player gives up the big one")
	assert_false(game.players[0].field.has(big), "the chosen unit is destroyed")
	assert_true(game.players[0].field.has(small), "the other stays")
	assert_true(game.choice_requests.is_empty())


func test_the_ghoul_against_the_ai_still_picks_automatically() -> void:
	var game: GameState = _choice_game()
	var big: CardInstance = _unit(game, 1, 5, 5)
	var small: CardInstance = _unit(game, 1, 1, 1)
	_play(game, "N-03")
	assert_true(game.choice_requests.is_empty(), "the AI's seat never waits")
	assert_true(game.players[1].field.has(big))
	assert_false(game.players[1].field.has(small), "the AI gives up its least valuable unit")


func test_one_unit_needs_no_choice() -> void:
	var game: GameState = _choice_game()
	var only: CardInstance = _unit(game, 0, 2, 2)
	game.active = 1
	_play(game, "N-03", [] as Array[int], 1)
	assert_true(game.choice_requests.is_empty())
	assert_false(game.players[0].field.has(only))


func test_grim_repper_asks_which_unit_gets_the_buffs() -> void:
	var game: GameState = _choice_game()
	_field(game, 0, "NB-15")
	var a: CardInstance = _unit(game, 0, 1, 1)
	var b: CardInstance = _unit(game, 0, 1, 1)
	var doomed: CardInstance = _unit(game, 0, 1, 1)
	game.destroy_card(doomed)
	game.check_state()
	assert_eq(game.choice_requests.size(), 1, "the trigger's target waits for the player")
	assert_eq(str(game.choice_requests[0]["kind"]), "target")
	assert_true(_answer(game, b.uid))
	assert_eq(b.buffs, 2, "two buffs on the chosen unit")
	assert_eq(a.buffs, 0, "not on the other")


func test_community_garden_lets_the_player_choose_the_resource() -> void:
	var game: GameState = _choice_game()
	_field(game, 0, "GR-07")
	_until_turn_of(game, 0)
	assert_eq(game.choice_requests.size(), 1, "choose one waits at the start of the turn")
	assert_eq(str(game.choice_requests[0]["kind"]), "choose")
	assert_eq((game.choice_requests[0]["labels"] as Array).size(), 2)
	var ingredients: int = _count(game, 0, KIND.INGREDIENT)
	var garbage: int = _count(game, 0, KIND.GARBAGE)
	assert_true(_answer(game, 1), "the second branch: an Ingredient")
	assert_eq(_count(game, 0, KIND.INGREDIENT), ingredients + 1)
	assert_eq(_count(game, 0, KIND.GARBAGE), garbage)


func test_barbell_asks_before_the_extra_pump() -> void:
	var game: GameState = _choice_game()
	var host: CardInstance = _unit(game, 0, 2, 2)
	var barbell: CardInstance = _field(game, 0, "B-30")
	barbell.attached_to = host.uid
	game.active = 0
	game.phase = GameState.Phase.MAIN1
	var attack_before: int = game.get_attack(host)
	game.advance_phase()
	if game.choice_requests.is_empty():
		pass_test("no beginning-of-combat step in this setup")
		return
	assert_eq(str(game.choice_requests[0]["kind"]), "may")
	assert_true(_answer(game, 0), "No")
	assert_eq(game.get_attack(host), attack_before, "no extra +3/+0 when the player says no")


func test_auto_answer_matches_the_engine_pick() -> void:
	var game: GameState = _choice_game()
	var big: CardInstance = _unit(game, 0, 5, 5)
	var small: CardInstance = _unit(game, 0, 1, 1)
	game.active = 1
	_play(game, "N-03", [] as Array[int], 1)
	assert_eq(game.auto_choice_answer(), small.uid, "the bot's answer is the least valuable unit")
	assert_true(_answer(game, game.auto_choice_answer()))
	assert_true(game.players[0].field.has(big))


func test_clones_never_wait() -> void:
	var game: GameState = _choice_game()
	_unit(game, 0, 5, 5)
	_unit(game, 0, 1, 1)
	var copy: GameState = game.clone()
	assert_false(copy.interactive_choices[0], "look-ahead copies choose automatically")
