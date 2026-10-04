extends GutTest
## Part A (bug fix): BattleBoard must never show an opponent's set trap face-up - not even for
## the brief moment between the CARD_CAST event (casting is always announced) and the TRAP_SET
## event that moves the card into the (hidden) trap row. core/ already fully hides trap identity
## from the rules engine and from AI look-ahead (see tests/core/game/test_traps.gd's
## test_ai_clone_can_hide_traps and test_game_loop.gd's test_clone_can_hide_traps) - this bug
## lived purely in presentation: `_on_cast` unconditionally revealed the cast card face-up in the
## center of the table for 0.55s before `_on_trap_set` flipped it back down.

const Trig := CardEnums.Trigger
const Tgt := CardEnums.TargetKind
const Op := CardEnums.EffectOp
const NO_PIPS: Array[Affinity.Type] = []


func _attack_trap() -> CardData:
	var card: CardData = CardBuilder.trap("test_trap", "Test Trap", Affinity.Type.A, 1, NO_PIPS)
	CardBuilder.with_effect(card, CardBuilder.effect(Trig.TRAP_OPPONENT_ATTACKS, Tgt.TRIGGERING_CARD, Op.DESTROY))
	return card


func _new_board(game: GameState) -> BattleBoard:
	var fx: BattleFX = BattleFX.new()
	add_child_autofree(fx)
	var board: BattleBoard = BattleBoard.new()
	add_child_autofree(board)
	board.setup(game, fx)
	board.speed = 50.0 # fast-forward the presentation waits; only the modes matter here
	return board


func test_opponent_trap_never_shows_face_up_during_the_cast_animation() -> void:
	var game: GameState = GameFactory.blank_game()
	GameFactory.pass_turn(game)
	assert_eq(game.active, 1, "setup: it should now be player 1's (the AI/opponent's) turn")
	GameFactory.add_infrastructure_cards(game, 1, 1)
	var trap: CardInstance = GameFactory.add_to_hand(game, 1, _attack_trap())
	assert_true(game.cast(1, trap.uid))
	assert_eq(GameFactory.count_events(game, GameEvent.Type.CARD_CAST), 1)
	assert_eq(GameFactory.count_events(game, GameEvent.Type.TRAP_SET), 1)

	var board: BattleBoard = _new_board(game)
	# BattleBoard.human is always 0, so player 1 is "the opponent" from the human's point of view.
	for event: GameEvent in game.events:
		if event.card != trap.uid:
			continue
		await board.present(event)
		var view: CardView = board.view_for(trap.uid)
		assert_not_null(view, "the trap should have a view by now")
		assert_eq(view.mode, CardView.Mode.BACK, "opponent trap must stay face-down after %s" % GameEvent.Type.keys()[event.type])


func test_own_trap_is_still_shown_face_up_to_its_owner() -> void:
	var game: GameState = GameFactory.blank_game()
	GameFactory.add_infrastructure_cards(game, 0, 1)
	var trap: CardInstance = GameFactory.add_to_hand(game, 0, _attack_trap())
	assert_true(game.cast(0, trap.uid))

	var board: BattleBoard = _new_board(game)
	for event: GameEvent in game.events:
		if event.card != trap.uid:
			continue
		await board.present(event)
	var view: CardView = board.view_for(trap.uid)
	assert_not_null(view)
	assert_ne(view.mode, CardView.Mode.BACK, "the player's own trap is visible to the player who set it")


func test_opponent_trap_flips_face_up_only_once_it_actually_triggers() -> void:
	var game: GameState = GameFactory.blank_game()
	GameFactory.pass_turn(game)
	GameFactory.add_infrastructure_cards(game, 1, 1)
	var trap: CardInstance = GameFactory.add_to_hand(game, 1, _attack_trap())
	assert_true(game.cast(1, trap.uid))
	GameFactory.pass_turn(game)
	assert_eq(game.active, 0, "setup: it should now be the human's turn to attack into the trap")
	var attacker: CardInstance = GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(2, 2))
	game.advance_phase() # MAIN1 -> COMBAT
	assert_true(game.declare_attackers([attacker.uid]))
	assert_eq(GameFactory.count_events(game, GameEvent.Type.TRAP_TRIGGERED), 1, "the attack trap should have fired")

	var board: BattleBoard = _new_board(game)
	for event: GameEvent in game.events:
		if event.card != trap.uid:
			continue
		if event.type == GameEvent.Type.TRAP_TRIGGERED:
			# Still hidden right up to the trigger.
			assert_eq(board.view_for(trap.uid).mode, CardView.Mode.BACK, "must still be face-down right before it triggers")
		await board.present(event)
	var view: CardView = board.view_for(trap.uid)
	assert_not_null(view)
	assert_eq(view.mode, CardView.Mode.FULL, "a triggered trap must flip face-up and reveal")
