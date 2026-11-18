extends CardTestBase
## Nov 18 day, Part 1.1: "gain control" cards. Unconscionable Contract moves the target to the caster's side for the rest of the battle
## (it attacks, blocks and dies for its new controller; a dead one goes to its owner's Refuse Pile) and creates three Contracts. The owner
## saw the stolen unit stay in the enemy's row: the rules moved it, the battle board did not (the view kept the owner it was made with).
## Every other control effect (Squatter's Rights, Hostile Takeover) goes through the same `steal_card`, so the board fix covers them too.


func _board(game: GameState) -> BattleBoard:
	var fx: BattleFX = BattleFX.new()
	add_child_autofree(fx)
	var board: BattleBoard = BattleBoard.new()
	add_child_autofree(board)
	board.setup(game, fx)
	board.speed = 50.0
	board.sync_state(false)
	return board


func test_contract_moves_the_unit_to_the_players_side_for_the_rest_of_the_battle() -> void:
	var game: GameState = _game()
	_energy(game, 0, 6)
	var prize: CardInstance = _unit(game, 1, 5, 5)
	_play(game, "N-32", [prize.uid] as Array[int])
	assert_true(game.players[0].field.has(prize), "on the player's board")
	assert_false(game.players[1].field.has(prize), "gone from the enemy's")
	assert_eq(prize.owner, 0)
	assert_eq(_count(game, 0, KIND.CONTRACT), 3, "three Contracts")
	_until_turn_of(game, 0)
	assert_true(game.possible_attackers(0).has(prize), "it attacks for the player next turn")
	for i: int in range(4):
		_until_turn_of(game, 0)
	assert_true(game.players[0].field.has(prize), "still the player's many turns later")
	assert_eq(prize.owner, 0)


func test_a_stolen_unit_that_dies_goes_to_its_owners_refuse_pile() -> void:
	var game: GameState = _game()
	_energy(game, 0, 6)
	var prize: CardInstance = _unit(game, 1, 2, 2)
	_play(game, "N-32", [prize.uid] as Array[int])
	game.destroy_card(prize)
	assert_true(game.players[1].refuse_pile.has(prize), "back to its owner's Refuse Pile")
	assert_false(game.players[0].refuse_pile.has(prize))


func test_the_ai_casts_the_contract_on_the_players_best_unit() -> void:
	var game: GameState = _game()
	_until_turn_of(game, 1)
	_energy(game, 1, 6)
	var small: CardInstance = _unit(game, 0, 1, 1)
	var prize: CardInstance = _unit(game, 0, 6, 6)
	var contract: CardInstance = GameFactory.add_to_hand(game, 1, CardSet.card("N-32"))
	var ai: AIPlayer = AIPlayer.new()
	var cast: GameAction = null
	for step: int in range(12):
		var action: GameAction = ai.choose_action(game)
		if action == null or action.type == GameAction.Type.PASS or game.active != 1:
			break
		if action.type == GameAction.Type.PLAY and action.card_uid == contract.uid:
			cast = action
		assert_true(game.apply_action(action))
		if cast != null:
			break
	assert_not_null(cast, "the AI plays the Contract")
	if cast == null:
		return
	assert_eq(cast.target, prize.uid, "on the best unit")
	assert_true(game.players[1].field.has(prize), "the AI's now")
	assert_eq(prize.owner, 1)
	assert_true(game.players[0].field.has(small))
	assert_eq(_count(game, 1, KIND.CONTRACT), 3)


func test_the_board_moves_a_stolen_unit_into_the_players_row() -> void:
	var game: GameState = _game()
	_energy(game, 0, 6)
	var prize: CardInstance = _unit(game, 1, 5, 5)
	var board: BattleBoard = _board(game)
	assert_true(board._cards_in(1, BattleBoard.Zone.FIELD).has(prize.uid))
	_play(game, "N-32", [prize.uid] as Array[int])
	board.sync_state(false)
	assert_true(board._cards_in(0, BattleBoard.Zone.FIELD).has(prize.uid), "in the player's field row")
	assert_false(board._cards_in(1, BattleBoard.Zone.FIELD).has(prize.uid), "not left in the enemy's")
	assert_eq(board.owner_of(prize.uid), 0, "clicks treat it as the player's")
	var view: CardView = board.view_for(prize.uid)
	assert_gt(board.center_of(prize.uid).y, 540.0, "drawn on the player's half")
	assert_false(bool(view.get_meta("opponent_back", true)))


func test_the_control_event_moves_the_view_during_playback() -> void:
	var game: GameState = _game()
	var prize: CardInstance = _unit(game, 1, 3, 3)
	var board: BattleBoard = _board(game)
	var event: GameEvent = GameEvent.new()
	event.type = GameEvent.Type.CONTROL_CHANGED
	event.player = 0
	event.card = prize.uid
	event.other = 1
	await board.present(event)
	assert_eq(board.owner_of(prize.uid), 0)
	assert_true(board._cards_in(0, BattleBoard.Zone.FIELD).has(prize.uid))


func test_squatters_rights_moves_the_infrastructure_view() -> void:
	var game: GameState = _game()
	_energy(game, 0, 6)
	var infra: CardInstance = GameFactory.add_infrastructure(game, 1, GameFactory.infra(Affinity.Type.GOURMAND))
	var board: BattleBoard = _board(game)
	_play(game, "NB-05", [infra.uid] as Array[int])
	board.sync_state(false)
	assert_true(board._cards_in(0, BattleBoard.Zone.INFRASTRUCTURE).has(infra.uid))
	assert_false(board._cards_in(1, BattleBoard.Zone.INFRASTRUCTURE).has(infra.uid))


func test_hostile_takeover_moves_the_resource_views() -> void:
	var game: GameState = _game()
	_energy(game, 0, 6)
	_give(game, 1, KIND.GARBAGE, 2)
	var board: BattleBoard = _board(game)
	_play(game, "NB-12")
	board.sync_state(false)
	assert_eq(board._cards_in(0, BattleBoard.Zone.RESOURCES).size(), 2, "both Garbage on the player's side")
	assert_eq(board._cards_in(1, BattleBoard.Zone.RESOURCES).size(), 0)


func test_the_log_records_the_control_change() -> void:
	var game: GameState = _game()
	var prize: CardInstance = _unit(game, 1, 3, 3)
	var log_view: BattleLog = BattleLog.new()
	add_child_autofree(log_view)
	log_view.game = game
	var event: GameEvent = GameEvent.new()
	event.type = GameEvent.Type.CONTROL_CHANGED
	event.player = 0
	event.card = prize.uid
	event.other = 1
	assert_string_contains(log_view.describe(event), "took control")
