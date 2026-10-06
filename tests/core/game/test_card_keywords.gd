extends CardTestBase
## Brief 14: keywords in combat, targeting restrictions, costs and static rules of the designed card set.

const KW := CardEnums.Keyword


func _kw(list: Array) -> Array[CardEnums.Keyword]:
	var result: Array[CardEnums.Keyword] = []
	for keyword: Variant in list:
		result.append(int(keyword) as CardEnums.Keyword)
	return result


func _attack(game: GameState, attacker: CardInstance, blocker: CardInstance = null) -> void:
	_until_turn_of(game, attacker.owner)
	game.advance_phase()
	assert_true(game.declare_attackers([attacker.uid] as Array[int]))
	if game.combat_step == GameState.CombatStep.DECLARE_BLOCKERS:
		if blocker != null:
			assert_true(game.declare_blockers({attacker.uid: blocker.uid}), "the block is legal")
		else:
			game.declare_blockers({})


func test_elusive_units_cannot_be_blocked() -> void:
	var game: GameState = _game()
	var runner: CardInstance = _unit(game, 0, 2, 2, _kw([KW.ELUSIVE]))
	var guard: CardInstance = _unit(game, 1, 1, 5)
	game.advance_phase()
	assert_true(game.declare_attackers([runner.uid] as Array[int]))
	assert_false(CombatResolver.can_block(game, runner, guard))
	assert_false(game.declare_blockers({runner.uid: guard.uid}))
	assert_true(game.declare_blockers({}))
	assert_eq(game.players[1].hp, 8)


func test_flying_needs_flying_or_swat_to_block() -> void:
	var game: GameState = _game()
	var flyer: CardInstance = _unit(game, 0, 2, 2, _kw([KW.FLYING]))
	var ground: CardInstance = _unit(game, 1, 1, 5)
	var swatter: CardInstance = _unit(game, 1, 1, 5, _kw([KW.SWAT]))
	assert_false(CombatResolver.can_block(game, flyer, ground))
	assert_true(CombatResolver.can_block(game, flyer, swatter))
	assert_true(CombatResolver.can_block(game, ground, swatter), "Swat units block ground units too")


func test_hustle_overtime_and_wallflower() -> void:
	var game: GameState = _game()
	var fresh: CardInstance = GameFactory.add_to_field(game, 0, GameFactory.vanilla(2, 2, 1, Affinity.Type.BEEFCAKE, _kw([KW.HUSTLE])), false)
	var sick: CardInstance = GameFactory.add_to_field(game, 0, GameFactory.vanilla(2, 2), false)
	var wall: CardInstance = _unit(game, 0, 0, 4, _kw([KW.WALLFLOWER]))
	var steady: CardInstance = _unit(game, 0, 2, 2, _kw([KW.OVERTIME]))
	var possible: Array[CardInstance] = game.possible_attackers(0)
	assert_true(possible.has(fresh), "Hustle: can attack the turn it enters")
	assert_false(possible.has(sick))
	assert_false(possible.has(wall), "Wallflower can't attack")
	game.advance_phase()
	game.declare_attackers([steady.uid, fresh.uid] as Array[int])
	assert_false(steady.exhausted, "Overtime: attacking doesn't exhaust it")
	assert_true(fresh.exhausted)


func test_sucker_punch_hits_first_and_one_two_punch_hits_twice() -> void:
	var game: GameState = _game()
	var puncher: CardInstance = _unit(game, 0, 3, 3, _kw([KW.SUCKER_PUNCH]))
	var blocker: CardInstance = _unit(game, 1, 5, 3)
	_attack(game, puncher, blocker)
	assert_false(game.players[1].field.has(blocker), "the blocker died before it could hit back")
	assert_eq(puncher.damage, 0)
	var game2: GameState = _game()
	var double: CardInstance = _unit(game2, 0, 2, 4, _kw([KW.ONE_TWO_PUNCH]))
	var wall: CardInstance = _unit(game2, 1, 1, 4)
	_attack(game2, double, wall)
	assert_false(game2.players[1].field.has(wall), "2 + 2 = 4 damage across both steps")
	var game3: GameState = _game()
	var unblocked: CardInstance = _unit(game3, 0, 2, 4, _kw([KW.ONE_TWO_PUNCH]))
	_attack(game3, unblocked)
	assert_eq(game3.players[1].hp, 6, "an unblocked One-Two Punch unit hits the player twice")


func test_bulldoze_and_nourish() -> void:
	var game: GameState = _game()
	var tank: CardInstance = _unit(game, 0, 5, 5, _kw([KW.BULLDOZE, KW.NOURISH]))
	var blocker: CardInstance = _unit(game, 1, 1, 2)
	game.players[0].hp = 5
	_attack(game, tank, blocker)
	assert_eq(game.players[1].hp, 7, "3 excess damage tramples over the 2-defense blocker")
	assert_eq(game.players[0].hp, 10, "Nourish heals you for all the damage it deals (5 + 5, capped at max)")


func test_untouchable_cannot_be_targeted_by_the_opponents_cards() -> void:
	var game: GameState = _game()
	_energy(game)
	var shy: CardInstance = _unit(game, 1, 2, 2, _kw([KW.UNTOUCHABLE]))
	var plain: CardInstance = _unit(game, 1, 2, 2)
	var pink_slip: CardInstance = GameFactory.add_to_hand(game, 0, CardSet.card("N-15"))
	assert_true(game.legal_play_targets(0, pink_slip.uid, 0).has(plain.uid))
	assert_false(game.legal_play_targets(0, pink_slip.uid, 0).has(shy.uid), "Untouchable")
	var mine: CardInstance = _unit(game, 0, 2, 2, _kw([KW.UNTOUCHABLE]))
	assert_true(game.legal_play_targets(0, pink_slip.uid, 0).has(mine.uid), "you can still target your own")


func test_working_in_your_own_casket_protects_until_your_next_turn() -> void:
	var game: GameState = _game()
	_energy(game)
	var unit: CardInstance = _unit(game, 0, 2, 2)
	_play(game, "N-22", [unit.uid] as Array[int])
	assert_eq(game.deal_damage_to_unit(0, unit, 5), 0, "can't be damaged")
	assert_false(game.can_be_targeted_by(unit, 1), "can't be targeted")
	assert_false(game.can_be_targeted_by(unit, 0))
	_until_turn_of(game, 1)
	assert_eq(game.deal_damage_to_unit(0, unit, 1), 0, "still protected on the opponent's turn")
	_until_turn_of(game, 0)
	assert_eq(game.deal_damage_to_unit(0, unit, 1), 1, "until the start of your next turn")


func test_cant_block_and_cant_block_this_turn() -> void:
	var game: GameState = _game()
	_energy(game)
	var courier: CardInstance = _field(game, 1, "B-07")
	var guard: CardInstance = _unit(game, 1, 1, 4)
	var attacker: CardInstance = _unit(game, 0, 3, 3)
	assert_false(CombatResolver.can_block(game, attacker, courier), "Late-ish Courier can't block")
	var ripper: CardInstance = GameFactory.add_to_hand(game, 0, CardSet.card("B-06"))
	assert_true(game.play_card(0, ripper.uid, guard.uid))
	assert_false(CombatResolver.can_block(game, attacker, guard), "Portal Ripper: target unit can't block this turn")
	_until_turn_of(game, 1)
	assert_false(guard.temp_cannot_block, "only this turn")


# ---- Costs and static rules ---------------------------------------------------------------------------------


func test_the_big_unit_costs_only_one_b_with_five_different_attack_values() -> void:
	var game: GameState = _game()
	var big: CardInstance = GameFactory.add_to_hand(game, 0, CardSet.card("B-32"))
	assert_eq(game.generic_cost_for(0, big.data, big), 5)
	for attack: int in [1, 2, 3, 4]:
		_unit(game, 0, attack, 1)
	assert_eq(game.generic_cost_for(0, big.data, big), 5, "only four different attack values")
	_unit(game, 0, 4, 1)
	assert_eq(game.generic_cost_for(0, big.data, big), 5, "five units but a repeated value")
	_unit(game, 0, 7, 1)
	assert_eq(game.generic_cost_for(0, big.data, big), 0, "Team Leader: five units, five different attack values")
	assert_eq(game.pips_for(0, big.data, big), [Affinity.Type.BEEFCAKE] as Array[Affinity.Type])
	GameFactory.add_infrastructure_cards(game, 0, 1, Affinity.Type.BEEFCAKE)
	assert_true(game.can_play_card(0, big.uid), "it can be played with a single (B)")


func test_mr_tiggle_raises_costs_and_allows_an_extra_infrastructure() -> void:
	var game: GameState = _game()
	_field(game, 0, "P4-03")
	_energy(game, 1)
	game.active = 1
	var spell: CardInstance = GameFactory.add_to_hand(game, 1, CardSet.card("C-14"))
	assert_eq(game.generic_cost_for(1, spell.data, spell), 3)
	game.players[1].cards_played_this_turn = 2
	assert_eq(game.generic_cost_for(1, spell.data, spell), 5, "1 more for each other card they've played this turn")
	game.active = 0
	var first: CardInstance = GameFactory.add_to_hand(game, 0, CardSet.card("BAS-B"))
	var second: CardInstance = GameFactory.add_to_hand(game, 0, CardSet.card("BAS-R"))
	var third: CardInstance = GameFactory.add_to_hand(game, 0, CardSet.card("BAS-G"))
	assert_true(game.play_infrastructure(0, first.uid))
	assert_true(game.play_infrastructure(0, second.uid), "You may play an additional Infrastructure each turn")
	assert_false(game.play_infrastructure(0, third.uid))


func test_additional_costs_destroy_a_unit_or_use_resources() -> void:
	var game: GameState = _game()
	_energy(game)
	var hand_before: int = game.players[0].hand.size()
	var mistake: CardInstance = GameFactory.add_to_hand(game, 0, CardSet.card("N-20"))
	assert_false(game.can_play_card(0, mistake.uid), "needs a unit to destroy")
	var victim: CardInstance = _unit(game, 0, 2, 3)
	assert_true(game.can_play_card(0, mistake.uid))
	assert_true(game.play_card(0, mistake.uid))
	assert_false(game.players[0].field.has(victim), "Destroy a unit you control")
	assert_eq(game.players[0].hand.size(), hand_before + 2, "Draw 2 cards")
	assert_eq(_count(game, 0, KIND.RED_TAPE), 1)
	var game2: GameState = _game()
	_energy(game2)
	var toro: CardInstance = GameFactory.add_to_hand(game2, 0, CardSet.card("G-27"))
	assert_false(game2.can_play_card(0, toro.uid), "Toro Toro needs three Ingredients")
	_give(game2, 0, KIND.INGREDIENT, 3)
	assert_true(game2.play_card(0, toro.uid))
	assert_eq(_count(game2, 0, KIND.INGREDIENT), 0)
	var game3: GameState = _game()
	_energy(game3)
	var become: CardInstance = GameFactory.add_to_hand(game3, 0, CardSet.card("N-21"))
	_unit(game3, 0, 1, 4)
	assert_true(game3.play_card(0, become.uid))
	assert_eq(_on_field(game3, 0, "T-10").size(), 4, "1/1 Zombie Temp tokens equal to the destroyed unit's defense")


func test_path_tagging_multi_path_cards_count_as_each_path() -> void:
	var game: GameState = _game()
	_energy(game)
	var gourmand_unit: CardInstance = _field(game, 1, "G-01")
	var dual_unit: CardInstance = _field(game, 1, "GR-01")
	var necro_unit: CardInstance = _field(game, 1, "N-01")
	var cake: CardInstance = GameFactory.add_to_hand(game, 0, CardSet.card("R-21"))
	var options: Array[int] = game.legal_play_targets(0, cake.uid, 0)
	assert_true(options.has(gourmand_unit.uid))
	assert_true(options.has(dual_unit.uid), "a Gourmand/Refusemancer unit is a Gourmand unit")
	assert_false(options.has(necro_unit.uid))
	assert_true(CardSet.card("GRB-01").is_on_path(Affinity.Type.BEEFCAKE))
	assert_eq(CardSet.card("P4-01").paths().size(), 4)
	assert_eq(CardSet.card("GN-01").paths().size(), 2, "paths come from the sheet section, even if the cost has one pip")


func test_betty_bones_and_mortimer_react_to_units() -> void:
	var game: GameState = _game()
	_field(game, 0, "N-30")
	_unit(game, 0, 1, 1)
	game.create_token(0, CardSet.card("T-16"))
	assert_eq(_count(game, 0, KIND.CONTRACT), 1, "whenever a unit enters under your control (the token; the vanilla was placed directly)")
	var foe: CardInstance = _unit(game, 1, 2, 2)
	_until_turn_of(game, 1)
	game.advance_phase()
	game.declare_attackers([foe.uid] as Array[int])
	assert_eq(_count(game, 0, KIND.RED_TAPE), 1, "whenever a unit attacks you")
	var game2: GameState = _game()
	_field(game2, 0, "N-33")
	var other: CardInstance = _unit(game2, 0, 1, 1)
	var hp: int = game2.players[1].hp
	game2.destroy_unit(other)
	assert_eq(_count(game2, 0, KIND.RED_TAPE), 1)
	assert_eq(game2.players[1].hp, hp - 1)


func test_mortimer_reinstates_for_three_red_tape_once_per_turn() -> void:
	var game: GameState = _game()
	var mortimer: CardInstance = _field(game, 0, "N-33")
	var dead: CardInstance = _bury(game, 0, "N-01")
	var dead2: CardInstance = _bury(game, 0, "N-02")
	_give(game, 0, KIND.RED_TAPE, 6)
	assert_true(_activate(game, mortimer, 1, [dead.uid] as Array[int]))
	assert_true(game.players[0].field.has(dead))
	assert_false(_activate(game, mortimer, 1, [dead2.uid] as Array[int]), "only once per turn")
	assert_eq(_count(game, 0, KIND.RED_TAPE), 3)


func test_the_wanderer_grows_with_the_paths_of_your_infrastructure() -> void:
	var game: GameState = _game()
	var wanderer: CardInstance = _field(game, 0, "C-29")
	assert_eq(game.get_attack(wanderer), 3)
	GameFactory.add_infrastructure(game, 0, CardSet.card("BAS-B"))
	GameFactory.add_infrastructure(game, 0, CardSet.card("BAS-B"))
	assert_eq(game.get_attack(wanderer), 4, "+1/+1 for each different Path (not each Infrastructure)")
	GameFactory.add_infrastructure(game, 0, CardSet.card("INF-07"))
	assert_eq(game.get_attack(wanderer), 6, "a Necrocrat/Refusemancer dual adds two new Paths")
	var before: int = game.players[0].hand.size()
	var dual: CardInstance = GameFactory.add_to_hand(game, 0, CardSet.card("INF-06"))
	before = game.players[0].hand.size() - 1
	assert_true(game.play_infrastructure(0, dual.uid))
	assert_eq(game.players[0].hand.size(), before + 1, "Whenever you play a multi-path card, draw a card")


func test_overexert_burst_now_exhaustion_later() -> void:
	var game: GameState = _game()
	_energy(game)
	var pusher: CardInstance = _field(game, 0, "B-04")
	assert_true(_activate(game, pusher, 1))
	assert_eq(game.players[0].pool, [int(Affinity.Type.BEEFCAKE), int(Affinity.Type.BEEFCAKE)] as Array[int])
	_until_turn_of(game, 0)
	assert_true(pusher.exhausted, "it doesn't refresh during your next turn")
	_until_turn_of(game, 0)
	assert_false(pusher.exhausted)


func test_the_hamster_wheel_power_plant_overexerts_for_two_energy() -> void:
	var game: GameState = _game()
	var plant: CardInstance = GameFactory.add_infrastructure(game, 0, CardSet.card("INF-01"))
	assert_true(game.activate_ability(0, plant.uid, 0))
	assert_eq(game.players[0].pool.size(), 2)
	assert_true(plant.exhausted)


func test_special_infrastructure_abilities_cannot_pay_for_themselves() -> void:
	var game: GameState = _game()
	var records: CardInstance = GameFactory.add_infrastructure(game, 0, CardSet.card("INF-02"))
	GameFactory.add_infrastructure_cards(game, 0, 2, Affinity.Type.NECROCRAT)
	assert_false(game.activate_ability(0, records.uid, 0), "Hall of Records needs 3 energy from OTHER infrastructure")
	GameFactory.add_infrastructure_cards(game, 0, 1, Affinity.Type.NECROCRAT)
	assert_true(game.activate_ability(0, records.uid, 0))
	assert_eq(_count(game, 0, KIND.RED_TAPE), 1)


func test_coin_flip_either_pumps_or_exhausts() -> void:
	var seen_heads: bool = false
	var seen_tails: bool = false
	for trial: int in range(12):
		var game: GameState = _game()
		_energy(game)
		var unit: CardInstance = _unit(game, 0, 2, 2)
		var clock: CardInstance = _play(game, "B-22")
		assert_true(_activate(game, clock, 0, [unit.uid] as Array[int]))
		_until_turn_of(game, 0)
		game.advance_phase()
		if unit.exhausted:
			seen_tails = true
		elif game.get_attack(unit) == 4 and game.unit_has_keyword(unit, KW.SUCKER_PUNCH):
			seen_heads = true
	assert_true(seen_heads and seen_tails, "both outcomes of the coin flip happen")


func test_mount_trashmore_and_sir_loin_spend_any_number_of_resources() -> void:
	var game: GameState = _game()
	_energy(game, 0, 5)
	_give(game, 0, KIND.GARBAGE, 3)
	var mount: CardInstance = _play(game, "R-29")
	assert_eq(_count(game, 0, KIND.GARBAGE), 0)
	assert_eq(mount.buffs, 3)
	assert_eq(game.get_attack(mount), 9)
	var game2: GameState = _game()
	_energy(game2, 0, 5)
	_give(game2, 0, KIND.INGREDIENT, 2)
	var foe_unit: CardInstance = _unit(game2, 1, 1, 9)
	_play(game2, "GB-13", [foe_unit.uid] as Array[int])
	assert_eq(foe_unit.damage, 4, "2 damage for each Ingredient used")
	assert_eq(_count(game2, 0, KIND.INGREDIENT), 0)


func test_death_and_enter_triggers_for_resources_and_tokens() -> void:
	var game: GameState = _game()
	_energy(game)
	var porter: CardInstance = _field(game, 0, "G-09")
	game.destroy_unit(porter)
	assert_eq(_count(game, 0, KIND.INGREDIENT), 2, "Kitchen Porter: when it dies, two Ingredients")
	_play(game, "R-05")
	assert_eq(_on_field(game, 0, "T-04").size(), 1, "Kidding Around: a Goat token")
	var ring: CardInstance = _field(game, 0, "GRN-01")
	var victim: CardInstance = _unit(game, 0, 1, 1)
	var hp: int = game.players[0].hp
	game.players[0].hp = hp - 3
	game.destroy_unit(victim)
	assert_eq(game.players[0].hp, hp - 2, "Mushroom Ring: gain 1 HP")
	assert_eq(_count(game, 0, KIND.GARBAGE), 1)
	assert_not_null(ring)


func test_scrapheap_lich_and_big_wreck_ronnie_destroy_tools_and_wonders() -> void:
	var game: GameState = _game()
	_energy(game, 0, 6)
	_field(game, 1, "C-19")
	_field(game, 1, "C-12")
	_field(game, 0, "C-21")
	_play(game, "NBR-08")
	assert_eq(_count(game, 0, KIND.GARBAGE), 3, "a Garbage for each Tool and Wonder destroyed")
	assert_eq(game.players[1].wonders().size() + game.players[1].tools().size(), 0)


func test_total_teardown_and_mass_layoffs() -> void:
	var game: GameState = _game()
	_energy(game, 0, 6)
	_field(game, 1, "C-19")
	var cheap: CardInstance = _field(game, 1, "C-03")
	var pricey: CardInstance = _field(game, 1, "C-09")
	_play(game, "NBR-04")
	assert_false(game.players[1].field.has(cheap), "units with cost 3 or less")
	assert_true(game.players[1].field.has(pricey), "cost 5 survives")
	assert_eq(game.players[1].wonders().size(), 0)
	_play(game, "N-29")
	assert_eq(game.all_units().size(), 0, "Mass Layoffs destroys all units")
	assert_eq(_count(game, 0, KIND.RED_TAPE), 1, "a Red Tape for each unit destroyed")
