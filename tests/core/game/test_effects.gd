extends GutTest

const Trig := CardEnums.Trigger
const Tgt := CardEnums.TargetKind
const Op := CardEnums.EffectOp
const KW := CardEnums.Keyword
const NO_PIPS: Array[Affinity.Type] = []


func _fx(trigger: CardEnums.Trigger, target: CardEnums.TargetKind, op: CardEnums.EffectOp, amount: int = 0, amount2: int = 0, duration: CardEnums.Duration = CardEnums.Duration.PERMANENT) -> EffectData:
	return CardBuilder.effect(trigger, target, op, amount, amount2, duration)


func _spell(effects: Array[EffectData]) -> CardData:
	var card: CardData = CardBuilder.spell("test_spell", "Test Spell", Affinity.Type.A, 0, NO_PIPS)
	for effect: EffectData in effects:
		CardBuilder.with_effect(card, effect)
	return card


func _spell1(effect: EffectData) -> CardData:
	return _spell([effect] as Array[EffectData])


func _creature(power: int, toughness: int, effects: Array[EffectData] = [], keywords: Array[CardEnums.Keyword] = []) -> CardData:
	var card: CardData = CardBuilder.creature("test_creature", "Test Creature", Affinity.Type.A, 0, NO_PIPS, power, toughness, keywords)
	for effect: EffectData in effects:
		CardBuilder.with_effect(card, effect)
	return card


func _game() -> GameState:
	var game: GameState = GameFactory.blank_game()
	GameFactory.add_infrastructure_cards(game, 0, 6)
	GameFactory.add_infrastructure_cards(game, 1, 6)
	return game


func _cast(game: GameState, data: CardData, target: int = 0, player: int = 0) -> bool:
	var card: CardInstance = GameFactory.add_to_hand(game, player, data)
	return game.cast(player, card.uid, target)


# ---- Operations --------------------------------------------------------------------


func test_damage_chosen_enemy_creature_kills_it() -> void:
	var game: GameState = _game()
	var victim: CardInstance = GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(2, 2))
	assert_true(_cast(game, _spell1(_fx(Trig.ON_ENTER, Tgt.CHOSEN_CREATURE_ENEMY, Op.DEAL_DAMAGE, 2)), victim.uid))
	assert_eq(game.players[1].battlefield.size(), 0)
	assert_eq(game.players[0].graveyard.size(), 1, "spell went to the graveyard")


func test_damage_chosen_player() -> void:
	var game: GameState = _game()
	assert_true(_cast(game, _spell1(_fx(Trig.ON_ENTER, Tgt.CHOSEN_PLAYER, Op.DEAL_DAMAGE, 3)), Targets.player(1)))
	assert_eq(game.players[1].life, 7)
	assert_eq(game.players[0].life, 10)


func test_illegal_target_rejects_cast_and_keeps_card_in_hand() -> void:
	var game: GameState = _game()
	var mine: CardInstance = GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(2, 2))
	GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(2, 2))
	var data: CardData = _spell1(_fx(Trig.ON_ENTER, Tgt.CHOSEN_CREATURE_ENEMY, Op.DEAL_DAMAGE, 2))
	var card: CardInstance = GameFactory.add_to_hand(game, 0, data)
	assert_false(game.cast(0, card.uid, mine.uid), "own creature is not an enemy creature")
	assert_eq(game.players[0].hand.size(), 1)
	assert_eq(game.players[0].ready_infrastructure().size(), 6)


func test_spell_needing_a_target_cannot_be_cast_without_one() -> void:
	var game: GameState = _game()
	var card: CardInstance = GameFactory.add_to_hand(game, 0, _spell1(_fx(Trig.ON_ENTER, Tgt.CHOSEN_CREATURE_ENEMY, Op.DEAL_DAMAGE, 2)))
	assert_false(game.can_cast(0, card.uid))
	GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(1, 1))
	assert_true(game.can_cast(0, card.uid))


func test_ally_and_any_creature_targeting() -> void:
	var game: GameState = _game()
	var mine: CardInstance = GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(1, 1))
	var theirs: CardInstance = GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(1, 1))
	var ally_fx: EffectData = _fx(Trig.ON_ENTER, Tgt.CHOSEN_CREATURE_ALLY, Op.BUFF, 1, 1)
	var any_fx: EffectData = _fx(Trig.ON_ENTER, Tgt.CHOSEN_CREATURE_ANY, Op.BUFF, 1, 1)
	assert_eq(game.legal_targets(0, ally_fx, 0), [mine.uid] as Array[int])
	assert_eq(game.legal_targets(0, any_fx, 0).size(), 2)
	assert_true(game.legal_targets(0, any_fx, 0).has(theirs.uid))


func test_all_creatures_damage_hits_both_sides() -> void:
	var game: GameState = _game()
	GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(1, 1))
	GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(1, 1))
	var tough: CardInstance = GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(1, 3))
	_cast(game, _spell1(_fx(Trig.ON_ENTER, Tgt.ALL_CREATURES, Op.DEAL_DAMAGE, 1)))
	assert_eq(game.players[0].battlefield.size(), 0)
	assert_eq(game.players[1].battlefield.size(), 1)
	assert_eq(tough.damage, 1)


func test_all_enemy_and_all_ally_creature_targets() -> void:
	var game: GameState = _game()
	var mine: CardInstance = GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(1, 3))
	var theirs: CardInstance = GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(1, 3))
	_cast(game, _spell1(_fx(Trig.ON_ENTER, Tgt.ALL_ENEMY_CREATURES, Op.DEAL_DAMAGE, 1)))
	assert_eq(theirs.damage, 1)
	assert_eq(mine.damage, 0)
	_cast(game, _spell1(_fx(Trig.ON_ENTER, Tgt.ALL_ALLY_CREATURES, Op.BUFF, 2, 0)))
	assert_eq(game.get_power(mine), 3)
	assert_eq(game.get_power(theirs), 1)


func test_heal_creature_and_player() -> void:
	var game: GameState = _game()
	var ally: CardInstance = GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(1, 5))
	ally.damage = 3
	game.players[0].life = 4
	_cast(game, _spell1(_fx(Trig.ON_ENTER, Tgt.CHOSEN_CREATURE_ALLY, Op.HEAL, 2)), ally.uid)
	assert_eq(ally.damage, 1)
	_cast(game, _spell1(_fx(Trig.ON_ENTER, Tgt.CONTROLLER, Op.HEAL, 3)))
	assert_eq(game.players[0].life, 7)
	_cast(game, _spell1(_fx(Trig.ON_ENTER, Tgt.CONTROLLER, Op.HEAL, 99)))
	assert_eq(game.players[0].life, 10, "capped at max life")


func test_draw_and_discard() -> void:
	var game: GameState = _game()
	_cast(game, _spell1(_fx(Trig.ON_ENTER, Tgt.CONTROLLER, Op.DRAW, 2)))
	assert_eq(game.players[0].hand.size(), 2)
	for i: int in range(3):
		GameFactory.add_to_hand(game, 1, GameFactory.vanilla(1, 1))
	_cast(game, _spell1(_fx(Trig.ON_ENTER, Tgt.OPPONENT, Op.DISCARD, 2)))
	assert_eq(game.players[1].hand.size(), 1)
	assert_eq(game.players[1].graveyard.size(), 2)
	assert_eq(GameFactory.count_events(game, GameEvent.Type.CARD_DISCARDED), 2)
	_cast(game, _spell1(_fx(Trig.ON_ENTER, Tgt.OPPONENT, Op.DISCARD, 5)))
	assert_eq(game.players[1].hand.size(), 0, "discarding more than the hand is fine")


func test_destroy() -> void:
	var game: GameState = _game()
	var big: CardInstance = GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(9, 9))
	_cast(game, _spell1(_fx(Trig.ON_ENTER, Tgt.CHOSEN_CREATURE_ENEMY, Op.DESTROY)), big.uid)
	assert_eq(game.players[1].battlefield.size(), 0)
	assert_eq(game.players[1].graveyard.size(), 1)


func test_temporary_buff_expires_at_end_of_turn_permanent_stays() -> void:
	var game: GameState = _game()
	var ally: CardInstance = GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(1, 1))
	_cast(game, _spell1(_fx(Trig.ON_ENTER, Tgt.CHOSEN_CREATURE_ALLY, Op.BUFF, 2, 2, CardEnums.Duration.END_OF_TURN)), ally.uid)
	_cast(game, _spell1(_fx(Trig.ON_ENTER, Tgt.CHOSEN_CREATURE_ALLY, Op.BUFF, 1, 1)), ally.uid)
	assert_eq(game.get_power(ally), 4)
	assert_eq(game.get_toughness(ally), 4)
	GameFactory.pass_turn(game)
	assert_eq(game.get_power(ally), 2)
	assert_eq(game.get_toughness(ally), 2)
	assert_eq(GameFactory.count_events(game, GameEvent.Type.STATS_CHANGED), 2)


func test_debuff_that_drops_toughness_to_zero_kills() -> void:
	var game: GameState = _game()
	var foe: CardInstance = GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(3, 2))
	_cast(game, _spell1(_fx(Trig.ON_ENTER, Tgt.CHOSEN_CREATURE_ENEMY, Op.BUFF, -1, -2)), foe.uid)
	assert_eq(game.players[1].battlefield.size(), 0)


func test_summon_tokens() -> void:
	var game: GameState = _game()
	var summon: EffectData = _fx(Trig.ON_ENTER, Tgt.CONTROLLER, Op.SUMMON_TOKEN, 2)
	summon.token = CardBuilder.token("goblin", "Goblin", 1, 1)
	_cast(game, _spell1(summon))
	assert_eq(game.players[0].battlefield.size(), 2)
	var token: CardInstance = game.players[0].battlefield[0]
	assert_true(token.summoning_sick)
	assert_eq(game.get_power(token), 1)
	assert_eq(GameFactory.count_events(game, GameEvent.Type.TOKEN_CREATED), 2)
	game.kill_creature(token)
	assert_eq(game.players[0].graveyard.size(), 1, "only the spell; the token vanished")


func test_return_to_hand_resets_card_and_tokens_vanish() -> void:
	var game: GameState = _game()
	var ally: CardInstance = GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(1, 3))
	ally.damage = 2
	ally.power_bonus = 4
	_cast(game, _spell1(_fx(Trig.ON_ENTER, Tgt.CHOSEN_CREATURE_ALLY, Op.RETURN_TO_HAND)), ally.uid)
	assert_eq(game.players[0].battlefield.size(), 0)
	assert_true(game.players[0].hand.has(ally))
	assert_eq(ally.damage, 0)
	assert_eq(ally.power_bonus, 0)
	var token: CardInstance = game.create_token(1, CardBuilder.token("t", "T", 1, 1))
	_cast(game, _spell1(_fx(Trig.ON_ENTER, Tgt.CHOSEN_CREATURE_ENEMY, Op.RETURN_TO_HAND)), token.uid)
	assert_eq(game.players[1].hand.size(), 0)
	assert_eq(game.players[1].battlefield.size(), 0)


func test_mill_and_life_gain_loss() -> void:
	var game: GameState = _game()
	_cast(game, _spell1(_fx(Trig.ON_ENTER, Tgt.OPPONENT, Op.MILL, 3)))
	assert_eq(game.players[1].library.size(), 37)
	assert_eq(game.players[1].graveyard.size(), 3)
	game.players[0].life = 5
	_cast(game, _spell1(_fx(Trig.ON_ENTER, Tgt.CONTROLLER, Op.GAIN_LIFE, 3)))
	assert_eq(game.players[0].life, 8)
	_cast(game, _spell1(_fx(Trig.ON_ENTER, Tgt.OPPONENT, Op.LOSE_LIFE, 4)))
	assert_eq(game.players[1].life, 6)
	_cast(game, _spell1(_fx(Trig.ON_ENTER, Tgt.OPPONENT, Op.LOSE_LIFE, 6)))
	assert_true(game.is_over())
	assert_eq(game.winner, 0)


func test_mill_does_not_lose_on_empty_library() -> void:
	var game: GameState = _game()
	game.players[1].library.clear()
	_cast(game, _spell1(_fx(Trig.ON_ENTER, Tgt.OPPONENT, Op.MILL, 3)))
	assert_false(game.is_over())


func test_grant_keyword_temporary_and_permanent() -> void:
	var game: GameState = _game()
	var ally: CardInstance = GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(1, 1))
	var temp: EffectData = _fx(Trig.ON_ENTER, Tgt.CHOSEN_CREATURE_ALLY, Op.GRANT_KEYWORD, 0, 0, CardEnums.Duration.END_OF_TURN)
	temp.keyword = KW.FLYING
	var perm: EffectData = _fx(Trig.ON_ENTER, Tgt.CHOSEN_CREATURE_ALLY, Op.GRANT_KEYWORD)
	perm.keyword = KW.LIFESTEAL
	_cast(game, _spell1(temp), ally.uid)
	_cast(game, _spell1(perm), ally.uid)
	assert_true(ally.has_keyword(KW.FLYING))
	assert_true(ally.has_keyword(KW.LIFESTEAL))
	GameFactory.pass_turn(game)
	assert_false(ally.has_keyword(KW.FLYING))
	assert_true(ally.has_keyword(KW.LIFESTEAL))


func test_random_enemy_creature_hits_exactly_one_deterministically() -> void:
	var survivors: Array[int] = []
	for run: int in range(2):
		var game: GameState = _game()
		for i: int in range(3):
			GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(1, 1))
		_cast(game, _spell1(_fx(Trig.ON_ENTER, Tgt.RANDOM_ENEMY_CREATURE, Op.DESTROY)))
		assert_eq(game.players[1].battlefield.size(), 2)
		var uids: int = 0
		for card: CardInstance in game.players[1].battlefield:
			uids = uids * 1000 + card.uid
		survivors.append(uids)
	assert_eq(survivors[0], survivors[1], "same seed, same random pick")


func test_random_targets_with_empty_pool_do_nothing() -> void:
	var game: GameState = _game()
	assert_true(_cast(game, _spell1(_fx(Trig.ON_ENTER, Tgt.RANDOM_ENEMY_CREATURE, Op.DESTROY))))
	assert_false(game.is_over())


func test_chosen_target_that_died_before_resolution_fizzles() -> void:
	var game: GameState = _game()
	var foe: CardInstance = GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(1, 1))
	var other: CardInstance = GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(5, 5))
	var effect: EffectData = _fx(Trig.ON_ENTER, Tgt.CHOSEN_CREATURE_ENEMY, Op.DESTROY)
	game.kill_creature(foe)
	EffectResolver.resolve(game, effect, EffectContext.make(0, 0, 0, foe.uid))
	assert_eq(game.players[1].battlefield.size(), 1, "the dead target is not swapped for another creature")
	assert_eq(other.damage, 0)


func test_spell_with_several_effects() -> void:
	var game: GameState = _game()
	var effects: Array[EffectData] = [
		_fx(Trig.ON_ENTER, Tgt.OPPONENT, Op.DEAL_DAMAGE, 2),
		_fx(Trig.ON_ENTER, Tgt.CONTROLLER, Op.DRAW, 1),
	]
	_cast(game, _spell(effects))
	assert_eq(game.players[1].life, 8)
	assert_eq(game.players[0].hand.size(), 1)


# ---- Triggers ----------------------------------------------------------------------


func test_on_enter_trigger_fires_when_creature_is_cast() -> void:
	var game: GameState = _game()
	_cast(game, _creature(1, 1, [_fx(Trig.ON_ENTER, Tgt.CONTROLLER, Op.DRAW, 1)] as Array[EffectData]))
	assert_eq(game.players[0].hand.size(), 1)
	assert_eq(GameFactory.count_events(game, GameEvent.Type.EFFECT_TRIGGERED), 1)


func test_on_enter_with_explicit_chosen_target() -> void:
	var game: GameState = _game()
	var weak: CardInstance = GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(1, 1))
	var strong: CardInstance = GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(4, 4))
	_cast(game, _creature(1, 1, [_fx(Trig.ON_ENTER, Tgt.CHOSEN_CREATURE_ENEMY, Op.DEAL_DAMAGE, 1)] as Array[EffectData]), weak.uid)
	assert_eq(game.players[1].battlefield.size(), 1)
	assert_eq(strong.damage, 0)


func test_triggered_chosen_effect_auto_targets_strongest_enemy() -> void:
	var game: GameState = _game()
	var weak: CardInstance = GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(1, 1))
	var strong: CardInstance = GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(4, 4))
	_cast(game, _creature(1, 1, [_fx(Trig.ON_ENTER, Tgt.CHOSEN_CREATURE_ENEMY, Op.DEAL_DAMAGE, 2)] as Array[EffectData]))
	assert_eq(strong.damage, 2)
	assert_eq(weak.damage, 0)


func test_auto_target_for_beneficial_effect_prefers_ally() -> void:
	var game: GameState = _game()
	var foe: CardInstance = GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(9, 9))
	var ally: CardInstance = GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(1, 1))
	_cast(game, _creature(1, 1, [_fx(Trig.ON_ENTER, Tgt.CHOSEN_CREATURE_ANY, Op.BUFF, 1, 1)] as Array[EffectData]))
	assert_eq(game.get_power(ally), 2)
	assert_eq(game.get_power(foe), 9)


func test_on_death_trigger_damages_opponent() -> void:
	var game: GameState = _game()
	var martyr: CardInstance = GameFactory.add_to_battlefield(game, 0, _creature(1, 1, [_fx(Trig.ON_DEATH, Tgt.OPPONENT, Op.DEAL_DAMAGE, 3)] as Array[EffectData]))
	game.deal_damage_to_creature(0, martyr, 1)
	game.check_state()
	assert_eq(game.players[1].life, 7)
	assert_eq(game.players[0].graveyard.size(), 1)


func test_on_death_trigger_can_summon_a_token_for_its_controller() -> void:
	var game: GameState = _game()
	var summon: EffectData = _fx(Trig.ON_DEATH, Tgt.CONTROLLER, Op.SUMMON_TOKEN, 1)
	summon.token = CardBuilder.token("spirit", "Spirit", 1, 1)
	var host: CardInstance = GameFactory.add_to_battlefield(game, 0, _creature(1, 1, [summon] as Array[EffectData]))
	game.kill_creature(host)
	assert_eq(game.players[0].battlefield.size(), 1)
	assert_eq(game.players[0].battlefield[0].data.id, "spirit")


func test_on_attack_trigger_buffs_self_until_end_of_turn() -> void:
	var game: GameState = _game()
	var attacker: CardInstance = GameFactory.add_to_battlefield(game, 0, _creature(1, 2, [_fx(Trig.ON_ATTACK, Tgt.SELF, Op.BUFF, 2, 0, CardEnums.Duration.END_OF_TURN)] as Array[EffectData]))
	game.advance_phase()
	game.declare_attackers([attacker.uid] as Array[int])
	game.declare_blockers({})
	assert_eq(game.players[1].life, 7, "1 + 2 attack bonus")


func test_on_block_trigger_receives_the_blocked_attacker() -> void:
	var game: GameState = _game()
	var attacker: CardInstance = GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(1, 5))
	var blocker: CardInstance = GameFactory.add_to_battlefield(game, 1, _creature(1, 5, [_fx(Trig.ON_BLOCK, Tgt.TRIGGERING_CARD, Op.DEAL_DAMAGE, 2)] as Array[EffectData]))
	game.advance_phase()
	game.declare_attackers([attacker.uid] as Array[int])
	game.declare_blockers({attacker.uid: blocker.uid})
	assert_eq(attacker.damage, 3, "2 from the trigger + 1 combat damage")


func test_start_and_end_of_turn_triggers_only_for_the_active_players_permanents() -> void:
	var game: GameState = _game()
	var start_fx: EffectData = _fx(Trig.START_OF_TURN, Tgt.SELF, Op.BUFF, 1, 0)
	var end_fx: EffectData = _fx(Trig.END_OF_TURN, Tgt.CONTROLLER, Op.GAIN_LIFE, 1)
	var mine: CardInstance = GameFactory.add_to_battlefield(game, 0, _creature(1, 1, [start_fx, end_fx] as Array[EffectData]))
	var theirs: CardInstance = GameFactory.add_to_battlefield(game, 1, _creature(1, 1, [start_fx] as Array[EffectData]))
	game.players[0].life = 5
	GameFactory.pass_turn(game)
	assert_eq(game.players[0].life, 6, "end of turn fired for P0")
	assert_eq(mine.power_bonus, 0, "P0's start of turn has not come again yet")
	assert_eq(theirs.power_bonus, 1, "P1's start of turn fired")
	GameFactory.pass_turn(game)
	assert_eq(mine.power_bonus, 1)


func test_on_damage_taken_trigger_hits_back_at_the_source() -> void:
	var game: GameState = _game()
	var thorny: CardInstance = GameFactory.add_to_battlefield(game, 1, _creature(1, 9, [_fx(Trig.ON_DAMAGE_TAKEN, Tgt.TRIGGERING_CARD, Op.DEAL_DAMAGE, 2)] as Array[EffectData]))
	var attacker: CardInstance = GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(1, 3))
	game.advance_phase()
	game.declare_attackers([attacker.uid] as Array[int])
	game.declare_blockers({attacker.uid: thorny.uid})
	assert_eq(game.players[0].battlefield.size(), 0, "1 combat + 2 thorns = dead 1/3")


func test_trigger_loops_are_cut_off() -> void:
	var game: GameState = _game()
	var ouch: CardInstance = GameFactory.add_to_battlefield(game, 0, _creature(1, 999, [_fx(Trig.ON_DAMAGE_TAKEN, Tgt.SELF, Op.DEAL_DAMAGE, 1)] as Array[EffectData]))
	game.deal_damage_to_creature(0, ouch, 1)
	assert_lt(ouch.damage, 30, "recursion terminated")
	assert_gt(ouch.damage, 1)
	assert_eq(game.trigger_depth, 0)


func test_simultaneous_combat_damage_is_not_cut_short_by_death_triggers() -> void:
	var game: GameState = _game()
	var boom: EffectData = _fx(Trig.ON_DEATH, Tgt.OPPONENT, Op.DEAL_DAMAGE, 1)
	var attacker: CardInstance = GameFactory.add_to_battlefield(game, 0, _creature(2, 2, [boom] as Array[EffectData]))
	var blocker: CardInstance = GameFactory.add_to_battlefield(game, 1, _creature(2, 2, [boom] as Array[EffectData]))
	game.advance_phase()
	game.declare_attackers([attacker.uid] as Array[int])
	game.declare_blockers({attacker.uid: blocker.uid})
	assert_eq(game.players[0].life, 9)
	assert_eq(game.players[1].life, 9)


# ---- Activated abilities -----------------------------------------------------------


func _pinger() -> CardData:
	var ping: EffectData = _fx(Trig.ACTIVATED, Tgt.CHOSEN_PLAYER, Op.DEAL_DAMAGE, 1)
	ping.activation_cost = 2
	return _creature(1, 1, [ping] as Array[EffectData])


func test_activated_ability_costs_energy_and_works_once_per_turn() -> void:
	var game: GameState = _game()
	var card: CardInstance = GameFactory.add_to_battlefield(game, 0, _pinger())
	assert_true(game.activate(0, card.uid, 0, Targets.player(1)))
	assert_eq(game.players[1].life, 9)
	assert_eq(game.players[0].ready_infrastructure().size(), 4)
	assert_false(game.activate(0, card.uid, 0, Targets.player(1)), "once per turn")
	GameFactory.pass_turn(game)
	GameFactory.pass_turn(game)
	assert_true(game.activate(0, card.uid, 0, Targets.player(1)), "available again next turn")


func test_activated_ability_needs_energy_and_main_phase() -> void:
	var game: GameState = GameFactory.blank_game()
	var card: CardInstance = GameFactory.add_to_battlefield(game, 0, _pinger())
	GameFactory.add_infrastructure_cards(game, 0, 1)
	assert_false(game.can_activate(0, card.uid, 0), "cost is 2, only 1 infrastructure")
	GameFactory.add_infrastructure_cards(game, 0, 1)
	game.advance_phase()
	assert_false(game.can_activate(0, card.uid, 0), "not in combat")
	game.advance_phase()
	assert_true(game.can_activate(0, card.uid, 0))


func test_activated_ability_appears_in_legal_actions_and_applies() -> void:
	var game: GameState = _game()
	var card: CardInstance = GameFactory.add_to_battlefield(game, 0, _pinger())
	var found: Array[GameAction] = []
	for action: GameAction in game.legal_actions():
		if action.type == GameAction.Type.ACTIVATE:
			found.append(action)
	assert_eq(found.size(), 2, "one per legal target (both players)")
	assert_true(game.apply_action(found[0]))
	assert_eq(GameFactory.count_events(game, GameEvent.Type.ABILITY_ACTIVATED), 1)
	assert_true(card.activated_this_turn)


# ---- Data-driven from .tres --------------------------------------------------------


func test_effects_survive_tres_roundtrip_and_still_work() -> void:
	var data: CardData = _spell1(_fx(Trig.ON_ENTER, Tgt.OPPONENT, Op.DEAL_DAMAGE, 4))
	var path: String = "user://test_effect_card.tres"
	assert_eq(ResourceSaver.save(data, path), OK)
	var loaded: CardData = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as CardData
	var game: GameState = _game()
	assert_true(_cast(game, loaded))
	assert_eq(game.players[1].life, 6)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
