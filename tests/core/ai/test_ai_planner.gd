extends CardTestBase
## Battle AI upgrade (Oct 23): the planning core's habits - the ones the audit (docs/design/ai_audit.md) found broken in the old
## one-step AI: turtling, zero-attack attackers, harmful effects on its own units, Iron without an attack, missed two-step lethal,
## bad chump decisions, Rot-blind unit choice, and the think-time cap.


func _ai(skill: int = 1) -> AIPlayer:
	var personality: AIPersonality = AIPersonality.balanced()
	personality.skill = skill
	var ai: AIPlayer = AIPlayer.new(personality)
	ai.deterministic = true
	return ai


func _vanilla_hand(game: GameState, owner: int, attack: int, defense: int, cost: int = 1) -> CardInstance:
	return GameFactory.add_to_hand(game, owner, GameFactory.vanilla(attack, defense, cost))


func _to_attack_step(game: GameState) -> void:
	game.advance_phase()
	assert_eq(game.combat_step, GameState.CombatStep.DECLARE_ATTACKERS)


# ---- Attacking ----------------------------------------------------------------------------------------------------------------------


func test_attacks_into_an_empty_board_with_everything() -> void:
	var game: GameState = _game()
	_energy(game)
	_unit(game, 0, 4, 2)
	_unit(game, 0, 2, 2)
	_unit(game, 0, 1, 1)
	_to_attack_step(game)
	var action: GameAction = _ai().choose_action(game)
	assert_eq(action.type, GameAction.Type.DECLARE_ATTACKERS)
	assert_eq(action.uids.size(), 3, "nothing can block: everyone attacks")


func test_attacks_when_far_ahead_even_into_a_blocker() -> void:
	var game: GameState = _game()
	_energy(game)
	_energy(game, 1)
	game.players[1].hp = 8
	_unit(game, 0, 4, 2)
	_unit(game, 0, 2, 2)
	_unit(game, 0, 1, 1)
	_unit(game, 1, 2, 2)
	_to_attack_step(game)
	var action: GameAction = _ai().choose_action(game)
	assert_eq(action.type, GameAction.Type.DECLARE_ATTACKERS, "ahead on board and in the race: it presses")
	assert_gte(action.uids.size(), 2)


func test_zero_attack_units_stay_home() -> void:
	var game: GameState = _game()
	_energy(game)
	var wall: CardInstance = _unit(game, 0, 0, 2)
	var hitter: CardInstance = _unit(game, 0, 3, 3)
	_to_attack_step(game)
	var action: GameAction = _ai().choose_action(game)
	assert_eq(action.type, GameAction.Type.DECLARE_ATTACKERS)
	assert_true(action.uids.has(hitter.uid))
	assert_false(action.uids.has(wall.uid), "a 0-attack unit gains nothing by attacking and loses its block")


func test_finds_lethal_through_a_contract_on_the_only_blocker() -> void:
	var game: GameState = _game()
	_energy(game)
	game.players[1].hp = 3
	_unit(game, 0, 3, 3)
	_unit(game, 1, 2, 2)
	ResourceRules.create(game, 0, ResourceKind.Kind.CONTRACT, 1)
	var ai: AIPlayer = _ai()
	var first: GameAction = ai.choose_action(game)
	assert_eq(first.type, GameAction.Type.USE_RESOURCE, "exhaust the blocker first")
	assert_eq(first.effect_index, int(ResourceKind.Kind.CONTRACT))
	assert_true(game.apply_action(first))
	var second: GameAction = ai.choose_action(game)
	assert_eq(second.type, GameAction.Type.PASS, "then straight to combat")
	assert_true(game.apply_action(second))
	var third: GameAction = ai.choose_action(game)
	assert_eq(third.type, GameAction.Type.DECLARE_ATTACKERS)
	assert_true(game.apply_action(third))
	assert_eq(game.awaiting_player(), 1, "the defender has nothing ready, and still gets its (empty) block step")
	assert_true(game.apply_action(GameAction.pass_phase(1)))
	assert_true(game.is_over() and game.winner == 0, "lethal")


# ---- Resources and targets --------------------------------------------------------------------------------------------------------------


func test_iron_is_not_wasted_when_no_attack_follows() -> void:
	var game: GameState = _game()
	_energy(game)
	_energy(game, 1)
	_unit(game, 0, 2, 2)
	_unit(game, 1, 5, 5)
	ResourceRules.create(game, 0, ResourceKind.Kind.IRON, 1)
	var ai: AIPlayer = _ai()
	var action: GameAction = ai.choose_action(game)
	assert_ne(action.type, GameAction.Type.USE_RESOURCE, "+1/+1 until end of turn is worthless without an attack into that 5/5")


func test_iron_is_used_before_an_open_attack() -> void:
	var game: GameState = _game()
	_energy(game)
	_unit(game, 0, 2, 2)
	ResourceRules.create(game, 0, ResourceKind.Kind.IRON, 1)
	var ai: AIPlayer = _ai()
	var action: GameAction = ai.choose_action(game)
	assert_eq(action.type, GameAction.Type.USE_RESOURCE, "nothing blocks: pump, then hit for 3")
	assert_true(game.apply_action(action))
	assert_true(game.apply_action(ai.choose_action(game)), "the pass to combat")
	var attack: GameAction = ai.choose_action(game)
	assert_eq(attack.type, GameAction.Type.DECLARE_ATTACKERS)


func test_red_tape_goes_on_the_biggest_attacker_not_a_one_one() -> void:
	var game: GameState = _game()
	_energy(game)
	_energy(game, 1)
	_unit(game, 1, 1, 1)
	var big: CardInstance = _unit(game, 1, 4, 4)
	ResourceRules.create(game, 0, ResourceKind.Kind.RED_TAPE, 1)
	var action: GameAction = _ai().choose_action(game)
	if action.type == GameAction.Type.USE_RESOURCE:
		assert_eq(action.target, big.uid, "the shrink blunts the 4/4, not the 1/1")
	else:
		pass_test("holding the Red Tape is also fine")


func test_harmful_enter_effect_is_not_aimed_at_its_own_unit() -> void:
	var game: GameState = _game()
	_energy(game)
	_energy(game, 1)
	var friend: CardInstance = _unit(game, 0, 2, 2)
	var enemy: CardInstance = _unit(game, 1, 2, 2)
	GameFactory.add_to_hand(game, 0, CardSet.card("B-06"))  # Portal Ripper: "target unit can't block this turn"
	var ai: AIPlayer = _ai()
	var action: GameAction = ai.choose_action(game)
	assert_eq(action.type, GameAction.Type.PLAY)
	assert_ne(action.target, friend.uid, "never its own Militia")
	assert_eq(action.target, enemy.uid)


func test_under_rot_it_plays_the_unit_that_survives() -> void:
	var game: GameState = _game()
	GameFactory.add_infrastructure_cards(game, 0, 2)
	for player: PlayerState in game.players:
		player.modifiers.add(CardBuilder.modifier(Modifier.Kind.ROT, 1))
	_vanilla_hand(game, 0, 3, 1, 2)
	var sturdy: CardInstance = _vanilla_hand(game, 0, 2, 2, 2)
	var action: GameAction = _ai().choose_action(game)
	assert_eq(action.type, GameAction.Type.PLAY)
	assert_eq(action.card_uid, sturdy.uid, "a 1-defense unit dies at the end of the turn under Rot")


# ---- Blocking ------------------------------------------------------------------------------------------------------------------------------


func test_chump_blocks_when_the_crack_back_would_be_lethal() -> void:
	var game: GameState = _game()
	_energy(game)
	_energy(game, 1)
	game.players[1].hp = 7
	var attacker: CardInstance = _unit(game, 0, 5, 5)
	_unit(game, 0, 3, 3)
	_unit(game, 0, 2, 2)
	var chump: CardInstance = _unit(game, 1, 1, 1)
	game.advance_phase()
	game.declare_attackers([attacker.uid] as Array[int])
	var action: GameAction = _ai().choose_action(game)
	assert_eq(action.type, GameAction.Type.DECLARE_BLOCKERS, "taking 5 leaves 2 HP against 10 attack next turn: chump now")
	assert_eq(int(action.blocks[attacker.uid]), chump.uid)


func test_does_not_chump_when_healthy() -> void:
	var game: GameState = _game()
	_energy(game)
	_energy(game, 1)
	game.players[1].hp = 20
	var attacker: CardInstance = _unit(game, 0, 4, 4)
	_unit(game, 1, 1, 1)
	game.advance_phase()
	game.declare_attackers([attacker.uid] as Array[int])
	assert_eq(_ai().choose_action(game).type, GameAction.Type.PASS, "at 20 HP a 1/1 is worth more than 4 HP")


# ---- Planning and timing -----------------------------------------------------------------------------------------------------------------


func test_a_whole_turn_of_planned_actions_is_legal() -> void:
	var game: GameState = _game()
	_energy(game, 0, 4)
	_energy(game, 1, 2)
	for id: String in ["N-02", "N-15", "C-02", "B-05", "G-13", "R-06", "C-11"]:
		GameFactory.add_to_hand(game, 0, CardSet.card(id))
	_unit(game, 1, 2, 2)
	_unit(game, 1, 1, 3)
	var ai: AIPlayer = _ai(2)
	var steps: int = 0
	var plays: int = 0
	while game.active == 0 and not game.is_over() and steps < 40:
		steps += 1
		var action: GameAction = ai.choose_action(game)
		assert_true(game.apply_action(action), "planned action %s must be legal" % action.describe())
		if action.type == GameAction.Type.PLAY:
			plays += 1
	assert_gte(plays, 3, "with 12 energy it develops the board")


func test_decisions_finish_well_under_a_second_on_a_busy_board() -> void:
	var game: GameState = _game()
	_energy(game, 0, 4)
	_energy(game, 1, 4)
	for i: int in range(6):
		_unit(game, 0, 1 + i % 4, 2 + i % 3)
		_unit(game, 1, 2 + i % 3, 1 + i % 4)
	for id: String in ["N-02", "N-15", "C-02", "B-05", "G-13", "R-06", "C-11", "B-03"]:
		GameFactory.add_to_hand(game, 0, CardSet.card(id))
	ResourceRules.create(game, 0, ResourceKind.Kind.IRON, 2)
	ResourceRules.create(game, 0, ResourceKind.Kind.RED_TAPE, 2)
	var ai: AIPlayer = _ai(2)
	var worst: float = 0.0
	var steps: int = 0
	while game.active == 0 and not game.is_over() and steps < 40:
		steps += 1
		var action: GameAction = ai.choose_action(game)
		worst = maxf(worst, ai.last_think_ms)
		assert_true(game.apply_action(action))
	assert_lt(worst, 1000.0, "boss-level search on a 6 v 6 board with 8 cards in hand stays under a second per decision (%.0f ms)" % worst)
