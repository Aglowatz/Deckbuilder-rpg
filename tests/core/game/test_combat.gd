extends GutTest

const KW := CardEnums.Keyword


func _vanilla(power: int, toughness: int, keywords: Array[CardEnums.Keyword] = []) -> CardData:
	var id: String = "c_%d_%d_%s" % [power, toughness, str(keywords)]
	return CardBuilder.creature(id, id, Affinity.Type.A, 1, [] as Array[Affinity.Type], power, toughness, keywords)


## P0 has `attacker_data` ready to attack; P1 has `blocker_data` (or nothing). Enters P0's combat.
func _setup(attacker_data: CardData, blocker_data: CardData = null) -> Dictionary:
	var game: GameState = GameFactory.blank_game()
	var attacker: CardInstance = GameFactory.add_to_battlefield(game, 0, attacker_data)
	var blocker: CardInstance = null
	if blocker_data != null:
		blocker = GameFactory.add_to_battlefield(game, 1, blocker_data)
	game.advance_phase()
	return {"game": game, "attacker": attacker, "blocker": blocker}


func _attack(game: GameState, attacker: CardInstance) -> bool:
	return game.declare_attackers([attacker.uid] as Array[int])


# ---- Attacking ---------------------------------------------------------------------


func test_entering_combat_awaits_attackers() -> void:
	var ctx: Dictionary = _setup(_vanilla(2, 2))
	var game: GameState = ctx["game"]
	assert_eq(game.phase, GameState.Phase.COMBAT)
	assert_eq(game.combat_step, GameState.CombatStep.DECLARE_ATTACKERS)
	assert_eq(game.awaiting_player(), 0)


func test_unblocked_attacker_damages_player_and_taps() -> void:
	var ctx: Dictionary = _setup(_vanilla(3, 3))
	var game: GameState = ctx["game"]
	var attacker: CardInstance = ctx["attacker"]
	assert_true(_attack(game, attacker))
	assert_true(attacker.tapped)
	assert_eq(game.combat_step, GameState.CombatStep.DECLARE_BLOCKERS)
	assert_eq(game.awaiting_player(), 1, "defender decides blocks")
	assert_true(game.declare_blockers({}))
	assert_eq(game.players[1].life, 7)
	assert_eq(game.phase, GameState.Phase.MAIN2)
	assert_eq(game.combat_step, GameState.CombatStep.NONE)
	assert_eq(game.attackers.size(), 0)


func test_no_attackers_skips_to_main2() -> void:
	var ctx: Dictionary = _setup(_vanilla(3, 3))
	var game: GameState = ctx["game"]
	assert_true(game.declare_attackers([] as Array[int]))
	assert_eq(game.phase, GameState.Phase.MAIN2)
	assert_eq(game.players[1].life, 10)


func test_passing_in_combat_means_no_attack_then_no_block() -> void:
	var ctx: Dictionary = _setup(_vanilla(3, 3))
	var game: GameState = ctx["game"]
	assert_true(game.advance_phase())
	assert_eq(game.phase, GameState.Phase.MAIN2)
	var ctx2: Dictionary = _setup(_vanilla(3, 3))
	var game2: GameState = ctx2["game"]
	_attack(game2, ctx2["attacker"])
	assert_true(game2.advance_phase(), "defender passing = no blockers")
	assert_eq(game2.players[1].life, 7)


func test_summoning_sick_creature_cannot_attack_but_haste_can() -> void:
	var game: GameState = GameFactory.blank_game()
	var sick: CardInstance = GameFactory.add_to_battlefield(game, 0, _vanilla(2, 2), false)
	var fast_kws: Array[CardEnums.Keyword] = [KW.HASTE]
	var hasty: CardInstance = GameFactory.add_to_battlefield(game, 0, _vanilla(2, 2, fast_kws), false)
	game.advance_phase()
	assert_false(game.declare_attackers([sick.uid] as Array[int]))
	assert_true(game.declare_attackers([hasty.uid] as Array[int]))


func test_defender_cannot_attack() -> void:
	var kws: Array[CardEnums.Keyword] = [KW.DEFENDER]
	var ctx: Dictionary = _setup(_vanilla(0, 4, kws))
	assert_false(_attack(ctx["game"], ctx["attacker"]))


func test_tapped_creature_cannot_attack_and_no_double_declaration() -> void:
	var ctx: Dictionary = _setup(_vanilla(2, 2))
	var game: GameState = ctx["game"]
	var attacker: CardInstance = ctx["attacker"]
	assert_false(game.declare_attackers([attacker.uid, attacker.uid] as Array[int]))
	attacker.tapped = true
	assert_false(_attack(game, attacker))


func test_cannot_declare_attackers_outside_combat_or_for_opponents_cards() -> void:
	var game: GameState = GameFactory.blank_game()
	var mine: CardInstance = GameFactory.add_to_battlefield(game, 0, _vanilla(2, 2))
	var theirs: CardInstance = GameFactory.add_to_battlefield(game, 1, _vanilla(2, 2))
	assert_false(game.declare_attackers([mine.uid] as Array[int]), "main phase")
	game.advance_phase()
	assert_false(game.declare_attackers([theirs.uid] as Array[int]), "not your creature")


func test_attackers_stay_tapped_through_opponents_turn() -> void:
	var ctx: Dictionary = _setup(_vanilla(1, 1))
	var game: GameState = ctx["game"]
	var attacker: CardInstance = ctx["attacker"]
	_attack(game, attacker)
	game.declare_blockers({})
	GameFactory.pass_turn(game)
	assert_eq(game.active, 1)
	assert_true(attacker.tapped)
	assert_eq(game.possible_blockers(0).size(), 0)
	GameFactory.pass_turn(game)
	assert_false(attacker.tapped, "untaps on its controller's turn")


# ---- Blocking ----------------------------------------------------------------------


func test_blocked_creatures_trade_damage() -> void:
	var ctx: Dictionary = _setup(_vanilla(3, 3), _vanilla(2, 2))
	var game: GameState = ctx["game"]
	var attacker: CardInstance = ctx["attacker"]
	var blocker: CardInstance = ctx["blocker"]
	_attack(game, attacker)
	assert_true(game.declare_blockers({attacker.uid: blocker.uid}))
	assert_eq(game.players[1].life, 10, "blocked damage does not hit the player")
	assert_eq(game.players[1].battlefield.size(), 0, "blocker died")
	assert_eq(attacker.damage, 2)
	assert_eq(game.players[0].battlefield.size(), 1, "attacker survived")
	assert_eq(game.players[1].graveyard.size(), 1)


func test_both_die_when_lethal_both_ways() -> void:
	var ctx: Dictionary = _setup(_vanilla(2, 2), _vanilla(2, 2))
	var game: GameState = ctx["game"]
	_attack(game, ctx["attacker"])
	game.declare_blockers({ctx["attacker"].uid: ctx["blocker"].uid})
	assert_eq(game.players[0].battlefield.size(), 0)
	assert_eq(game.players[1].battlefield.size(), 0)
	assert_eq(GameFactory.count_events(game, GameEvent.Type.CREATURE_DIED), 2)


func test_damage_on_survivors_clears_at_end_of_turn() -> void:
	var ctx: Dictionary = _setup(_vanilla(1, 5), _vanilla(1, 5))
	var game: GameState = ctx["game"]
	_attack(game, ctx["attacker"])
	game.declare_blockers({ctx["attacker"].uid: ctx["blocker"].uid})
	assert_eq(ctx["blocker"].damage, 1)
	GameFactory.pass_turn(game)
	assert_eq(ctx["blocker"].damage, 0)
	assert_eq(ctx["attacker"].damage, 0)


func test_one_blocker_per_attacker_and_one_attacker_per_blocker() -> void:
	var game: GameState = GameFactory.blank_game()
	var a1: CardInstance = GameFactory.add_to_battlefield(game, 0, _vanilla(1, 1))
	var a2: CardInstance = GameFactory.add_to_battlefield(game, 0, _vanilla(2, 2))
	var b1: CardInstance = GameFactory.add_to_battlefield(game, 1, _vanilla(1, 4))
	game.advance_phase()
	game.declare_attackers([a1.uid, a2.uid] as Array[int])
	assert_false(game.declare_blockers({a1.uid: b1.uid, a2.uid: b1.uid}), "same blocker twice")
	assert_eq(game.combat_step, GameState.CombatStep.DECLARE_BLOCKERS, "invalid declaration changes nothing")
	assert_true(game.declare_blockers({a1.uid: b1.uid}))
	assert_eq(game.players[1].life, 8, "the other attacker got through")


func test_cannot_block_with_tapped_or_foreign_creature() -> void:
	var game: GameState = GameFactory.blank_game()
	var attacker: CardInstance = GameFactory.add_to_battlefield(game, 0, _vanilla(1, 1))
	var mine: CardInstance = GameFactory.add_to_battlefield(game, 0, _vanilla(1, 1))
	var tapped: CardInstance = GameFactory.add_to_battlefield(game, 1, _vanilla(1, 1))
	tapped.tapped = true
	game.advance_phase()
	_attack(game, attacker)
	assert_false(game.declare_blockers({attacker.uid: tapped.uid}))
	assert_false(game.declare_blockers({attacker.uid: mine.uid}))
	assert_false(game.declare_blockers({999: tapped.uid}), "unknown attacker")


func test_summoning_sick_creatures_can_block() -> void:
	var game: GameState = GameFactory.blank_game()
	var attacker: CardInstance = GameFactory.add_to_battlefield(game, 0, _vanilla(1, 1))
	var fresh: CardInstance = GameFactory.add_to_battlefield(game, 1, _vanilla(1, 3), false)
	game.advance_phase()
	_attack(game, attacker)
	assert_true(game.declare_blockers({attacker.uid: fresh.uid}))


func test_flying_can_only_be_blocked_by_flying_or_reach() -> void:
	var fly: Array[CardEnums.Keyword] = [KW.FLYING]
	var reach: Array[CardEnums.Keyword] = [KW.REACH]
	var game: GameState = GameFactory.blank_game()
	var flyer: CardInstance = GameFactory.add_to_battlefield(game, 0, _vanilla(2, 2, fly))
	var ground: CardInstance = GameFactory.add_to_battlefield(game, 1, _vanilla(1, 1))
	var archer: CardInstance = GameFactory.add_to_battlefield(game, 1, _vanilla(1, 3, reach))
	game.advance_phase()
	_attack(game, flyer)
	assert_false(game.declare_blockers({flyer.uid: ground.uid}))
	assert_true(game.declare_blockers({flyer.uid: archer.uid}))


func test_ground_creature_can_be_blocked_by_flyer() -> void:
	var fly: Array[CardEnums.Keyword] = [KW.FLYING]
	var ctx: Dictionary = _setup(_vanilla(1, 1), _vanilla(1, 1, fly))
	_attack(ctx["game"], ctx["attacker"])
	assert_true(ctx["game"].declare_blockers({ctx["attacker"].uid: ctx["blocker"].uid}))


# ---- Keywords in damage ------------------------------------------------------------


func test_first_strike_kills_blocker_without_taking_damage() -> void:
	var fs: Array[CardEnums.Keyword] = [KW.FIRST_STRIKE]
	var ctx: Dictionary = _setup(_vanilla(2, 2, fs), _vanilla(3, 2))
	var game: GameState = ctx["game"]
	_attack(game, ctx["attacker"])
	game.declare_blockers({ctx["attacker"].uid: ctx["blocker"].uid})
	assert_eq(game.players[1].battlefield.size(), 0)
	assert_eq(ctx["attacker"].damage, 0, "blocker died before dealing damage")


func test_first_strike_on_blocker_protects_it() -> void:
	var fs: Array[CardEnums.Keyword] = [KW.FIRST_STRIKE]
	var ctx: Dictionary = _setup(_vanilla(2, 2), _vanilla(2, 3, fs))
	var game: GameState = ctx["game"]
	_attack(game, ctx["attacker"])
	game.declare_blockers({ctx["attacker"].uid: ctx["blocker"].uid})
	assert_eq(game.players[0].battlefield.size(), 0)
	assert_eq(ctx["blocker"].damage, 0)


func test_two_first_strikers_trade_simultaneously() -> void:
	var fs: Array[CardEnums.Keyword] = [KW.FIRST_STRIKE]
	var ctx: Dictionary = _setup(_vanilla(2, 2, fs), _vanilla(2, 2, fs))
	var game: GameState = ctx["game"]
	_attack(game, ctx["attacker"])
	game.declare_blockers({ctx["attacker"].uid: ctx["blocker"].uid})
	assert_eq(game.players[0].battlefield.size(), 0)
	assert_eq(game.players[1].battlefield.size(), 0)


func test_first_strike_survivor_does_not_deal_damage_twice() -> void:
	var fs: Array[CardEnums.Keyword] = [KW.FIRST_STRIKE]
	var ctx: Dictionary = _setup(_vanilla(2, 5, fs), _vanilla(1, 5))
	var game: GameState = ctx["game"]
	_attack(game, ctx["attacker"])
	game.declare_blockers({ctx["attacker"].uid: ctx["blocker"].uid})
	assert_eq(ctx["blocker"].damage, 2)
	assert_eq(ctx["attacker"].damage, 1)


func test_trample_assigns_lethal_then_excess_to_player() -> void:
	var tr: Array[CardEnums.Keyword] = [KW.TRAMPLE]
	var ctx: Dictionary = _setup(_vanilla(5, 5, tr), _vanilla(1, 2))
	var game: GameState = ctx["game"]
	_attack(game, ctx["attacker"])
	game.declare_blockers({ctx["attacker"].uid: ctx["blocker"].uid})
	assert_eq(game.players[1].life, 7, "5 power - 2 lethal = 3 tramples over")
	assert_eq(game.players[1].battlefield.size(), 0)


func test_trample_against_first_strike_blocker() -> void:
	var both: Array[CardEnums.Keyword] = [KW.TRAMPLE]
	var fs: Array[CardEnums.Keyword] = [KW.FIRST_STRIKE]
	var ctx: Dictionary = _setup(_vanilla(3, 3, both), _vanilla(1, 1, fs))
	var game: GameState = ctx["game"]
	_attack(game, ctx["attacker"])
	game.declare_blockers({ctx["attacker"].uid: ctx["blocker"].uid})
	# Blocker (first strike) deals 1 first; attacker then tramples: lethal 1 to blocker, 2 to player.
	assert_eq(game.players[1].life, 8)


func test_non_trampler_blocked_by_dead_blocker_deals_no_damage() -> void:
	var fs: Array[CardEnums.Keyword] = [KW.FIRST_STRIKE]
	var ctx: Dictionary = _setup(_vanilla(3, 3), _vanilla(3, 1, fs))
	var game: GameState = ctx["game"]
	_attack(game, ctx["attacker"])
	game.declare_blockers({ctx["attacker"].uid: ctx["blocker"].uid})
	# 3 first-strike damage kills the 3/3 attacker before it can deal damage.
	assert_eq(game.players[0].battlefield.size(), 0)
	assert_eq(game.players[1].life, 10)
	assert_eq(ctx["blocker"].damage, 0)


func test_lifesteal_on_unblocked_attacker() -> void:
	var ls: Array[CardEnums.Keyword] = [KW.LIFESTEAL]
	var ctx: Dictionary = _setup(_vanilla(3, 3, ls))
	var game: GameState = ctx["game"]
	game.players[0].life = 5
	_attack(game, ctx["attacker"])
	game.declare_blockers({})
	assert_eq(game.players[0].life, 8)
	assert_eq(game.players[1].life, 7)


func test_lifesteal_on_blocker_and_capped_at_max_life() -> void:
	var ls: Array[CardEnums.Keyword] = [KW.LIFESTEAL]
	var ctx: Dictionary = _setup(_vanilla(1, 9), _vanilla(4, 4, ls))
	var game: GameState = ctx["game"]
	game.players[1].life = 8
	_attack(game, ctx["attacker"])
	game.declare_blockers({ctx["attacker"].uid: ctx["blocker"].uid})
	assert_eq(game.players[1].life, 10, "8 + 4 capped at max life 10")


# ---- Guard -------------------------------------------------------------------------


func test_guard_forces_attackers_to_attack_the_guard() -> void:
	var guard: Array[CardEnums.Keyword] = [KW.GUARD]
	var ctx: Dictionary = _setup(_vanilla(2, 2), _vanilla(0, 5, guard))
	var game: GameState = ctx["game"]
	var attacker: CardInstance = ctx["attacker"]
	var guard_card: CardInstance = ctx["blocker"]
	assert_true(_attack(game, attacker))
	assert_eq(int(game.attack_targets[attacker.uid]), guard_card.uid)
	game.declare_blockers({})
	assert_eq(game.players[1].life, 10, "damage went to the guard, not the player")
	assert_eq(guard_card.damage, 2)


func test_guard_attack_target_must_be_a_guard() -> void:
	var guard: Array[CardEnums.Keyword] = [KW.GUARD]
	var game: GameState = GameFactory.blank_game()
	var attacker: CardInstance = GameFactory.add_to_battlefield(game, 0, _vanilla(2, 2))
	var guard_a: CardInstance = GameFactory.add_to_battlefield(game, 1, _vanilla(0, 5, guard))
	var plain: CardInstance = GameFactory.add_to_battlefield(game, 1, _vanilla(1, 1))
	game.advance_phase()
	assert_false(game.declare_attackers([attacker.uid] as Array[int], {attacker.uid: plain.uid}))
	assert_true(game.declare_attackers([attacker.uid] as Array[int], {attacker.uid: guard_a.uid}))


func test_attack_target_without_guard_is_rejected() -> void:
	var ctx: Dictionary = _setup(_vanilla(2, 2), _vanilla(1, 1))
	assert_false(ctx["game"].declare_attackers([ctx["attacker"].uid] as Array[int], {ctx["attacker"].uid: ctx["blocker"].uid}))


func test_tapped_guard_does_not_force_attacks() -> void:
	var guard: Array[CardEnums.Keyword] = [KW.GUARD]
	var game: GameState = GameFactory.blank_game()
	var attacker: CardInstance = GameFactory.add_to_battlefield(game, 0, _vanilla(2, 2))
	var guard_card: CardInstance = GameFactory.add_to_battlefield(game, 1, _vanilla(0, 5, guard))
	guard_card.tapped = true
	game.advance_phase()
	assert_true(CombatResolver.guard_creatures(game, 1).is_empty(), "tapped Guard is not a Guard for attack-forcing purposes")
	assert_true(game.declare_attackers([attacker.uid] as Array[int]), "attacker may go past a tapped Guard")
	assert_false(game.attack_targets.has(attacker.uid), "no forced target when the only Guard is tapped")


func test_guard_can_still_block_and_trample_excess_lands_on_guard() -> void:
	var guard: Array[CardEnums.Keyword] = [KW.GUARD]
	var tr: Array[CardEnums.Keyword] = [KW.TRAMPLE]
	var game: GameState = GameFactory.blank_game()
	var attacker: CardInstance = GameFactory.add_to_battlefield(game, 0, _vanilla(5, 5, tr))
	var guard_card: CardInstance = GameFactory.add_to_battlefield(game, 1, _vanilla(0, 6, guard))
	var chump: CardInstance = GameFactory.add_to_battlefield(game, 1, _vanilla(1, 1))
	game.advance_phase()
	game.declare_attackers([attacker.uid] as Array[int])
	game.declare_blockers({attacker.uid: chump.uid})
	assert_eq(guard_card.damage, 4, "excess trample damage goes to the attacked Guard")
	assert_eq(game.players[1].life, 10)


# ---- Game end, events, actions -----------------------------------------------------


func test_lethal_combat_damage_ends_the_game() -> void:
	var ctx: Dictionary = _setup(_vanilla(10, 1))
	var game: GameState = ctx["game"]
	_attack(game, ctx["attacker"])
	game.declare_blockers({})
	assert_true(game.is_over())
	assert_eq(game.winner, 0)


func test_combat_events() -> void:
	var ctx: Dictionary = _setup(_vanilla(2, 2), _vanilla(1, 1))
	var game: GameState = ctx["game"]
	_attack(game, ctx["attacker"])
	game.declare_blockers({ctx["attacker"].uid: ctx["blocker"].uid})
	assert_eq(GameFactory.count_events(game, GameEvent.Type.ATTACKERS_DECLARED), 1)
	assert_eq(GameFactory.count_events(game, GameEvent.Type.BLOCKER_ASSIGNED), 1)
	assert_eq(GameFactory.count_events(game, GameEvent.Type.DAMAGE_DEALT), 2)
	assert_eq(GameFactory.count_events(game, GameEvent.Type.CREATURE_DIED), 1)


func test_temp_and_permanent_buffs_change_combat_power() -> void:
	var ctx: Dictionary = _setup(_vanilla(1, 1))
	var game: GameState = ctx["game"]
	ctx["attacker"].power_bonus = 2
	ctx["attacker"].temp_power = 1
	_attack(game, ctx["attacker"])
	game.declare_blockers({})
	assert_eq(game.players[1].life, 6)


func test_combat_legal_actions_and_apply() -> void:
	var game: GameState = GameFactory.blank_game()
	var a1: CardInstance = GameFactory.add_to_battlefield(game, 0, _vanilla(1, 1))
	GameFactory.add_to_battlefield(game, 0, _vanilla(2, 2))
	var b1: CardInstance = GameFactory.add_to_battlefield(game, 1, _vanilla(1, 1))
	game.advance_phase()
	var kinds: Array[GameAction.Type] = []
	for action: GameAction in game.legal_actions():
		kinds.append(action.type)
	assert_eq(kinds.count(GameAction.Type.DECLARE_ATTACKERS), 3, "each alone + all")
	var attack: GameAction = GameAction.make(GameAction.Type.DECLARE_ATTACKERS, 0)
	attack.uids = [a1.uid] as Array[int]
	assert_true(game.apply_action(attack))
	var block_actions: Array[GameAction] = []
	for action: GameAction in game.legal_actions():
		if action.type == GameAction.Type.DECLARE_BLOCKERS:
			block_actions.append(action)
	assert_eq(block_actions.size(), 1)
	assert_true(game.apply_action(block_actions[0]))
	assert_eq(game.phase, GameState.Phase.MAIN2)
	assert_eq(game.players[1].graveyard.size(), 1, "the 1/1 blocker traded with the 1/1 attacker")
	assert_eq(b1.damage, 0, "dead cards are reset")


func test_opponent_cannot_act_during_attackers_step() -> void:
	var ctx: Dictionary = _setup(_vanilla(1, 1))
	var game: GameState = ctx["game"]
	assert_false(game.apply_action(GameAction.pass_phase(1)))
	var block: GameAction = GameAction.make(GameAction.Type.DECLARE_BLOCKERS, 1)
	assert_false(game.apply_action(block))


# ---- Vigilance ---------------------------------------------------------------------


func test_vigilance_attacker_does_not_tap_and_can_block_next_turn() -> void:
	var vig: Array[CardEnums.Keyword] = [KW.VIGILANCE]
	var ctx: Dictionary = _setup(_vanilla(2, 2, vig))
	var game: GameState = ctx["game"]
	var attacker: CardInstance = ctx["attacker"]
	assert_true(_attack(game, attacker))
	assert_false(attacker.tapped, "vigilance: attacking does not tap")
	game.declare_blockers({})
	assert_eq(game.players[1].life, 8)
	assert_true(game.possible_blockers(0).has(attacker), "still available to block on the opponent's turn")


func test_non_vigilance_attacker_still_taps() -> void:
	var ctx: Dictionary = _setup(_vanilla(2, 2))
	_attack(ctx["game"], ctx["attacker"])
	assert_true(ctx["attacker"].tapped)


func test_vigilance_creature_can_attack_every_turn() -> void:
	var vig: Array[CardEnums.Keyword] = [KW.VIGILANCE]
	var ctx: Dictionary = _setup(_vanilla(1, 1, vig))
	var game: GameState = ctx["game"]
	_attack(game, ctx["attacker"])
	game.declare_blockers({})
	GameFactory.pass_turn(game)
	GameFactory.pass_turn(game)
	game.advance_phase()
	assert_true(_attack(game, ctx["attacker"]))


func test_vigilance_can_be_granted_by_an_effect() -> void:
	var game: GameState = GameFactory.blank_game()
	var creature: CardInstance = GameFactory.add_to_battlefield(game, 0, _vanilla(1, 1))
	var grant: EffectData = CardBuilder.effect(CardEnums.Trigger.ON_ENTER, CardEnums.TargetKind.CHOSEN_CREATURE_ALLY, CardEnums.EffectOp.GRANT_KEYWORD, 0, 0, CardEnums.Duration.END_OF_TURN)
	grant.keyword = KW.VIGILANCE
	var spell: CardData = CardBuilder.spell("vig", "Vig", Affinity.Type.A, 0, [] as Array[Affinity.Type])
	CardBuilder.with_effect(spell, grant)
	var hand: CardInstance = GameFactory.add_to_hand(game, 0, spell)
	game.cast(0, hand.uid, creature.uid)
	game.advance_phase()
	_attack(game, creature)
	assert_false(creature.tapped)
