extends GutTest
## Overnight Oct 31 - Nov 1 (the designer's answer 7, boss stalls): while a duel stalls (turn 9+, the AI has no unit on the field or
## nobody has lost HP), a 4th+ Tool is worth little to the AI, so it deploys a unit instead. Not a clock: nothing changes for the player.


func _tool() -> CardData:
	var data: CardData = GameFactory.vanilla(0, 0, 1)
	data.type = CardEnums.CardType.TOOL
	return data


func _stalled_game(turn: int) -> GameState:
	var game: GameState = GameFactory.blank_game(3)
	game.turn = turn
	for i: int in range(3):
		GameFactory.add_to_field(game, 1, _tool())
	return game


func test_stalling_needs_a_late_turn_and_an_empty_or_untouched_board() -> void:
	assert_false(AIEvaluator.is_stalling(_stalled_game(4), _stalled_game(4).players[1]), "early turns never stall")
	var game: GameState = _stalled_game(10)
	assert_true(AIEvaluator.is_stalling(game, game.players[1]), "no unit of its own at turn 10")
	GameFactory.add_to_field(game, 1, GameFactory.vanilla(2, 2))
	game.players[0].hp = game.players[0].max_hp
	game.players[1].hp = game.players[1].max_hp
	assert_true(AIEvaluator.is_stalling(game, game.players[1]), "a unit, but nobody has lost any HP")
	game.players[0].hp -= 3
	assert_false(AIEvaluator.is_stalling(game, game.players[1]), "a unit and damage dealt: not a stall")


func test_a_fourth_tool_is_worth_less_than_a_unit_while_stalling() -> void:
	var evaluator: AIEvaluator = AIEvaluator.new(AIPersonality.balanced())
	var game: GameState = _stalled_game(10)
	var base: float = evaluator.board_value(game, game.players[1])
	var with_tool: GameState = _stalled_game(10)
	GameFactory.add_to_field(with_tool, 1, _tool())
	var tool_gain: float = evaluator.board_value(with_tool, with_tool.players[1]) - base
	var with_unit: GameState = _stalled_game(10)
	GameFactory.add_to_field(with_unit, 1, GameFactory.vanilla(2, 2))
	var unit_gain: float = evaluator.board_value(with_unit, with_unit.players[1]) - base
	assert_lt(tool_gain, unit_gain, "a unit beats a 4th Tool in a stall")
	assert_lt(tool_gain, 0.5, "the 4th Tool counts for little")
	var early: GameState = _stalled_game(4)
	var early_base: float = evaluator.board_value(early, early.players[1])
	GameFactory.add_to_field(early, 1, _tool())
	assert_gt(evaluator.board_value(early, early.players[1]) - early_base, 1.0, "outside a stall a Tool keeps its worth")


func test_the_rule_can_be_switched_off_for_sims() -> void:
	var game: GameState = _stalled_game(10)
	AIEvaluator.stall_rule = false
	assert_false(AIEvaluator.is_stalling(game, game.players[1]))
	AIEvaluator.stall_rule = true
	assert_true(AIEvaluator.is_stalling(game, game.players[1]))
