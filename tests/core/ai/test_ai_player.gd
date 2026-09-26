extends GutTest

const NO_PIPS: Array[Affinity.Type] = []


func _ai(personality: AIPersonality = null) -> AIPlayer:
	return AIPlayer.new(personality)


func _game_with_lands(p0_lands: int = 6, p1_lands: int = 6) -> GameState:
	var game: GameState = GameFactory.blank_game()
	GameFactory.add_lands(game, 0, p0_lands)
	GameFactory.add_lands(game, 1, p1_lands)
	return game


func _burn(amount: int, target_kind: CardEnums.TargetKind = CardEnums.TargetKind.CHOSEN_CREATURE_ENEMY, cost: int = 1) -> CardData:
	var card: CardData = CardBuilder.spell("burn_%d" % amount, "Burn", Affinity.Type.A, cost, NO_PIPS)
	return CardBuilder.with_effect(card, CardBuilder.effect(CardEnums.Trigger.ON_ENTER, target_kind, CardEnums.EffectOp.DEAL_DAMAGE, amount))


# ---- Evaluation --------------------------------------------------------------------


func test_evaluate_prefers_winning_more_life_and_bigger_board() -> void:
	var game: GameState = _game_with_lands()
	var ai: AIPlayer = _ai()
	var base: float = ai.evaluate(game, 0)
	game.players[1].life = 5
	assert_gt(ai.evaluate(game, 0), base, "opponent at lower life is better for me")
	game.players[1].life = 10
	GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(3, 3))
	assert_gt(ai.evaluate(game, 0), base, "a creature is worth something")
	game.players[1].life = 0
	game.check_state()
	assert_eq(ai.evaluate(game, 0), AIPlayer.WIN_SCORE)
	assert_eq(ai.evaluate(game, 1), -AIPlayer.WIN_SCORE)


func test_evaluate_penalizes_lethal_threat() -> void:
	var game: GameState = _game_with_lands()
	var ai: AIPlayer = _ai()
	GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(3, 3))
	var safe: float = ai.evaluate(game, 0)
	GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(3, 3))
	GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(4, 4))
	assert_lt(ai.evaluate(game, 0), safe - 10.0, "10 power on board threatens lethal")


func test_untapped_creature_reduces_threat() -> void:
	var game: GameState = _game_with_lands()
	var ai: AIPlayer = _ai(AIPersonality.balanced())
	GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(10, 10))
	var open: float = ai.evaluate(game, 0)
	var guard: CardInstance = GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(1, 1))
	var covered: float = ai.evaluate(game, 0)
	guard.tapped = true
	var exposed: float = ai.evaluate(game, 0)
	assert_gt(covered, open)
	assert_gt(covered, exposed, "a tapped creature cannot block next turn")


# ---- Main phase decisions ----------------------------------------------------------


func test_ai_plays_a_land_first() -> void:
	var game: GameState = GameFactory.blank_game()
	var land: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.land())
	var action: GameAction = _ai().choose_action(game)
	assert_eq(action.type, GameAction.Type.PLAY_LAND)
	assert_eq(action.card_uid, land.uid)


func test_ai_plays_the_land_type_its_hand_needs() -> void:
	var game: GameState = GameFactory.blank_game()
	var pips: Array[Affinity.Type] = [Affinity.Type.B, Affinity.Type.B]
	GameFactory.add_to_hand(game, 0, CardBuilder.creature("bb", "BB", Affinity.Type.B, 0, pips, 3, 3))
	GameFactory.add_to_hand(game, 0, GameFactory.land(Affinity.Type.A))
	var wanted: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.land(Affinity.Type.B))
	assert_eq(_ai().choose_action(game).card_uid, wanted.uid)


func test_ai_casts_a_creature_instead_of_passing() -> void:
	var game: GameState = _game_with_lands()
	var bear: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(2, 2, 2))
	var action: GameAction = _ai().choose_action(game)
	assert_eq(action.type, GameAction.Type.CAST)
	assert_eq(action.card_uid, bear.uid)


func test_ai_passes_with_nothing_castable() -> void:
	var game: GameState = _game_with_lands(1, 1)
	GameFactory.add_to_hand(game, 0, GameFactory.vanilla(5, 5, 5))
	assert_eq(_ai().choose_action(game).type, GameAction.Type.PASS)


func test_ai_prefers_the_bigger_creature_when_it_can_only_afford_one() -> void:
	var game: GameState = _game_with_lands(3, 3)
	GameFactory.add_to_hand(game, 0, GameFactory.vanilla(1, 1, 1))
	var big: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(4, 4, 3))
	assert_eq(_ai().choose_action(game).card_uid, big.uid)


func test_ai_uses_removal_on_the_best_enemy_creature() -> void:
	var game: GameState = _game_with_lands()
	GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(1, 1))
	var bomb: CardInstance = GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(3, 2))
	GameFactory.add_to_hand(game, 0, _burn(2))
	var action: GameAction = _ai().choose_action(game)
	assert_eq(action.type, GameAction.Type.CAST)
	assert_eq(action.target, bomb.uid, "kills the more valuable creature it can actually kill")


func test_ai_does_not_waste_removal_on_nothing() -> void:
	var game: GameState = _game_with_lands()
	GameFactory.add_to_hand(game, 0, _burn(2))
	assert_eq(_ai().choose_action(game).type, GameAction.Type.PASS, "no legal target, so it cannot even be cast")


func test_ai_aims_face_burn_at_the_opponent() -> void:
	var game: GameState = _game_with_lands()
	GameFactory.add_to_hand(game, 0, _burn(3, CardEnums.TargetKind.CHOSEN_PLAYER))
	var action: GameAction = _ai().choose_action(game)
	assert_eq(action.type, GameAction.Type.CAST)
	assert_eq(action.target, Targets.player(1))


func test_ai_look_ahead_does_not_change_the_real_game() -> void:
	var game: GameState = _game_with_lands()
	GameFactory.add_to_hand(game, 0, GameFactory.vanilla(2, 2, 2))
	GameFactory.add_to_hand(game, 0, _burn(2, CardEnums.TargetKind.CHOSEN_PLAYER))
	var hand_before: int = game.players[0].hand.size()
	var lands_before: int = game.players[0].untapped_lands().size()
	var rng_before: int = game.rng.state
	_ai().choose_action(game)
	assert_eq(game.players[0].hand.size(), hand_before)
	assert_eq(game.players[0].untapped_lands().size(), lands_before)
	assert_eq(game.players[0].battlefield.size(), 0)
	assert_eq(game.players[1].life, 10)
	assert_eq(game.rng.state, rng_before)


# ---- Attacking ---------------------------------------------------------------------


func _combat_game() -> GameState:
	var game: GameState = _game_with_lands()
	return game


func test_ai_attacks_when_the_opponent_has_no_blockers() -> void:
	var game: GameState = _combat_game()
	var attacker: CardInstance = GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(3, 3))
	game.advance_phase()
	var action: GameAction = _ai().choose_action(game)
	assert_eq(action.type, GameAction.Type.DECLARE_ATTACKERS)
	assert_eq(action.uids, [attacker.uid] as Array[int])


func test_ai_does_not_attack_a_small_creature_into_a_big_blocker() -> void:
	var game: GameState = _combat_game()
	GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(1, 1))
	GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(4, 4))
	game.advance_phase()
	assert_eq(_ai().choose_action(game).type, GameAction.Type.PASS)


func test_ai_goes_for_lethal() -> void:
	var game: GameState = _combat_game()
	game.players[1].life = 3
	var big: CardInstance = GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(3, 3))
	GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(1, 1))
	GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(2, 2))
	game.advance_phase()
	var action: GameAction = _ai().choose_action(game)
	assert_eq(action.type, GameAction.Type.DECLARE_ATTACKERS)
	assert_eq(action.uids.size(), 2, "attacking with both means one gets through for lethal")
	assert_true(action.uids.has(big.uid))


func test_attack_bias_changes_willingness_to_attack() -> void:
	var timid: AIPersonality = AIPersonality.new()
	timid.attack_bias = -100.0
	var reckless: AIPersonality = AIPersonality.new()
	reckless.attack_bias = 100.0
	var game: GameState = _combat_game()
	GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(3, 3))
	game.advance_phase()
	assert_eq(_ai(timid).choose_action(game).type, GameAction.Type.PASS, "even a free attack is refused")
	assert_eq(_ai(reckless).choose_action(game).type, GameAction.Type.DECLARE_ATTACKERS)
	var bad_game: GameState = _combat_game()
	GameFactory.add_to_battlefield(bad_game, 0, GameFactory.vanilla(1, 1))
	GameFactory.add_to_battlefield(bad_game, 1, GameFactory.vanilla(4, 4))
	bad_game.advance_phase()
	assert_eq(_ai(reckless).choose_action(bad_game).type, GameAction.Type.DECLARE_ATTACKERS, "reckless AI suicides")


func test_ai_respects_guard() -> void:
	var guard: Array[CardEnums.Keyword] = [CardEnums.Keyword.GUARD]
	var game: GameState = _combat_game()
	GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(3, 3))
	GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(0, 6, 1, Affinity.Type.A, guard))
	game.advance_phase()
	var action: GameAction = _ai().choose_action(game)
	assert_true(game.apply_action(action), "whatever it picks must be legal")


# ---- Blocking ----------------------------------------------------------------------


func _declare_attack(game: GameState, attacker: CardInstance) -> void:
	game.advance_phase()
	game.declare_attackers([attacker.uid] as Array[int])


func test_ai_blocks_when_it_kills_the_attacker_and_survives() -> void:
	var game: GameState = _combat_game()
	var attacker: CardInstance = GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(2, 2))
	var wall: CardInstance = GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(3, 3))
	_declare_attack(game, attacker)
	var action: GameAction = _ai().choose_action(game)
	assert_eq(action.type, GameAction.Type.DECLARE_BLOCKERS)
	assert_eq(int(action.blocks[attacker.uid]), wall.uid)


func test_ai_does_not_chump_block_when_not_in_danger() -> void:
	var game: GameState = _combat_game()
	var attacker: CardInstance = GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(5, 5))
	GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(2, 2))
	_declare_attack(game, attacker)
	assert_eq(_ai().choose_action(game).type, GameAction.Type.PASS, "take 5 at 10 life rather than lose a creature for nothing")


func test_ai_chump_blocks_to_survive_lethal() -> void:
	var game: GameState = _combat_game()
	game.players[1].life = 4
	var attacker: CardInstance = GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(5, 5))
	var chump: CardInstance = GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(1, 1))
	_declare_attack(game, attacker)
	var action: GameAction = _ai().choose_action(game)
	assert_eq(action.type, GameAction.Type.DECLARE_BLOCKERS)
	assert_eq(int(action.blocks[attacker.uid]), chump.uid)


func test_ai_blocks_are_always_legal() -> void:
	var fly: Array[CardEnums.Keyword] = [CardEnums.Keyword.FLYING]
	var game: GameState = _combat_game()
	var flyer: CardInstance = GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(3, 3, 1, Affinity.Type.A, fly))
	GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(5, 5))
	_declare_attack(game, flyer)
	var action: GameAction = _ai().choose_action(game)
	assert_true(game.apply_action(action), "a ground creature cannot block a flyer, so the AI passes")


# ---- Mulligan and discard ----------------------------------------------------------


func test_ai_mulligans_a_land_light_hand_but_keeps_a_good_one() -> void:
	var game: GameState = GameState.new()
	game.options.rng_seed = 1
	game.add_player(PlayerSetup.create(GameFactory.make_deck()))
	game.add_player(PlayerSetup.create(GameFactory.make_deck()))
	game.start()
	game.players[0].hand.clear()
	for i: int in range(5):
		GameFactory.add_to_hand(game, 0, GameFactory.vanilla(1, 1))
	assert_eq(_ai().choose_action(game).type, GameAction.Type.MULLIGAN)
	game.players[0].hand.clear()
	for i: int in range(2):
		GameFactory.add_to_hand(game, 0, GameFactory.land())
	for i: int in range(3):
		GameFactory.add_to_hand(game, 0, GameFactory.vanilla(1, 1))
	assert_eq(_ai().choose_action(game).type, GameAction.Type.KEEP_HAND)


func test_ai_discards_surplus_lands_before_spells() -> void:
	var game: GameState = _game_with_lands(7, 7)
	for i: int in range(2):
		GameFactory.add_to_hand(game, 0, GameFactory.land())
	for i: int in range(9):
		GameFactory.add_to_hand(game, 0, GameFactory.vanilla(2, 2, 2))
	game.advance_phase()
	game.advance_phase()
	game.advance_phase()
	assert_eq(game.pending_discard, 1)
	var action: GameAction = _ai().choose_action(game)
	assert_eq(action.type, GameAction.Type.DISCARD)
	assert_true(game.find_card(action.uids[0]).data.is_land())
	assert_true(game.apply_action(action))


# ---- Personalities and full games --------------------------------------------------


func test_personality_presets_differ_and_round_trip() -> void:
	var aggressive: AIPersonality = AIPersonality.aggressive()
	var defensive: AIPersonality = AIPersonality.defensive()
	assert_gt(aggressive.enemy_life_weight, defensive.enemy_life_weight)
	assert_gt(aggressive.attack_bias, defensive.attack_bias)
	assert_gt(defensive.threat_weight, aggressive.threat_weight)
	var path: String = "user://test_personality.tres"
	assert_eq(ResourceSaver.save(aggressive, path), OK)
	var loaded: AIPersonality = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as AIPersonality
	assert_eq(loaded.personality_name, "Aggressive")
	assert_eq(loaded.attack_bias, aggressive.attack_bias)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _play_out(game: GameState, ais: Array[AIPlayer]) -> int:
	var steps: int = 0
	var illegal: int = 0
	while not game.is_over() and steps < 3000:
		steps += 1
		var who: int = game.awaiting_player()
		if not game.apply_action(ais[who].choose_action(game)):
			illegal += 1
			if not game.apply_action(GameAction.pass_phase(who)):
				break
	return illegal


func test_ai_vs_ai_games_finish_without_illegal_moves() -> void:
	var spell: CardData = _burn(2, CardEnums.TargetKind.CHOSEN_CREATURE_ENEMY, 2)
	var creature: CardData = GameFactory.vanilla(2, 2, 2)
	var deck: Deck = GameFactory.make_deck(creature, 18)
	for i: int in range(6):
		deck.cards[deck.cards.size() - 1 - i] = spell
	for seed_value: int in range(1, 6):
		var game: GameState = GameFactory.new_game(seed_value, deck, deck)
		var ais: Array[AIPlayer] = [_ai(AIPersonality.aggressive()), _ai(AIPersonality.defensive())]
		var illegal: int = _play_out(game, ais)
		assert_eq(illegal, 0, "seed %d produced illegal AI actions" % seed_value)
		assert_true(game.is_over(), "seed %d finished" % seed_value)


func test_ai_games_are_deterministic_for_a_seed() -> void:
	var deck: Deck = GameFactory.make_deck(GameFactory.vanilla(2, 2, 2), 18)
	var results: Array[int] = []
	for run: int in range(2):
		var game: GameState = GameFactory.new_game(11, deck, deck)
		_play_out(game, [_ai(), _ai()] as Array[AIPlayer])
		results.append(game.turn * 10 + game.winner + 1)
	assert_eq(results[0], results[1])
