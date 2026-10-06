extends CardTestBase
## Brief 14: Wonders, Traps, Plate, Brawl, Processing, Shred, Reinstate, control changes, Clauses, keywords and static effects.


# ---- Wonders --------------------------------------------------------------------------------------------


func test_raised_bed_spends_a_garbage_for_a_buff_once_per_turn() -> void:
	var game: GameState = _game()
	var bed: CardInstance = _field(game, 0, "R-11")
	var unit: CardInstance = _unit(game, 0, 1, 1)
	_give(game, 0, KIND.GARBAGE, 3)
	assert_true(_activate(game, bed, 0, [unit.uid] as Array[int]))
	assert_eq(game.get_attack(unit), 2)
	assert_eq(game.get_defense(unit), 2)
	assert_eq(unit.buffs, 1)
	assert_false(_activate(game, bed, 0, [unit.uid] as Array[int]), "once per turn")
	assert_eq(_count(game, 0, KIND.GARBAGE), 2)


func test_start_of_turn_wonders() -> void:
	var game: GameState = _game()
	_field(game, 0, "G-15")
	_field(game, 0, "C-19")
	_field(game, 0, "R-10")
	game.players[0].hp = 5
	_until_turn_of(game, 0)
	assert_eq(_count(game, 0, KIND.INGREDIENT), 1, "Windowsill Herb Garden")
	assert_eq(game.players[0].hp, 6, "Village Well")
	assert_eq(_count(game, 0, KIND.GARBAGE), 1, "Community Compost Bin makes one when you have none")
	_until_turn_of(game, 0)
	assert_eq(_count(game, 0, KIND.GARBAGE), 1, "...and none when you already have one")
	assert_eq(_count(game, 0, KIND.INGREDIENT), 2)


func test_the_mother_heap_makes_a_rat_for_each_garbage() -> void:
	var game: GameState = _game()
	_field(game, 0, "R-30")
	_give(game, 0, KIND.GARBAGE, 2)
	assert_eq(_on_field(game, 0, "T-02").size(), 2)
	_give(game, 1, KIND.GARBAGE, 1)
	assert_eq(_on_field(game, 0, "T-02").size(), 2, "only Garbage entering under your control")


func test_waiting_room_makes_the_opponents_units_enter_exhausted() -> void:
	var game: GameState = _game()
	_field(game, 0, "N-13")
	var entering: CardInstance = game.create_token(1, CardSet.card("T-16"))
	assert_true(entering.exhausted)
	var mine: CardInstance = game.create_token(0, CardSet.card("T-16"))
	assert_false(mine.exhausted)


func test_department_of_final_approvals_taxes_the_opponents_spells() -> void:
	var game: GameState = _game()
	_energy(game, 1)
	game.active = 1
	var spell: CardInstance = GameFactory.add_to_hand(game, 1, CardSet.card("C-14"))
	assert_eq(game.generic_cost_for(1, spell.data, spell), 3)
	_field(game, 0, "N-31")
	assert_eq(game.generic_cost_for(1, spell.data, spell), 4, "Spells your opponent plays cost 1 more")
	var unit_data: CardData = CardSet.card("C-02")
	assert_eq(game.generic_cost_for(1, unit_data), 2, "only spells")
	assert_eq(game.generic_cost_for(0, spell.data, spell), 3, "not your own")
	_until_turn_of(game, 0)
	assert_eq(_count(game, 0, KIND.RED_TAPE), 1, "and a Red Tape at the start of your turn")


func test_unstable_rift_and_banner() -> void:
	var game: GameState = _game()
	var banner: CardInstance = _field(game, 0, "C-21")
	var unit: CardInstance = _unit(game, 0, 2, 5)
	assert_eq(game.get_attack(unit), 3, "Old Kingdom Banner")
	game.destroy_unit(banner)
	assert_eq(game.get_attack(unit), 2, "the bonus goes when the Wonder leaves")
	_field(game, 0, "C-33")
	_until_turn_of(game, 0)
	assert_eq(unit.damage, 2, "Unstable Rift deals 2 damage to a random unit")


func test_snack_bar_pumps_each_unit_only_once_per_turn() -> void:
	var game: GameState = _game()
	_energy(game)
	var bar: CardInstance = _field(game, 0, "B-23")
	var a: CardInstance = _unit(game, 0, 2, 2)
	var b: CardInstance = _unit(game, 0, 2, 2)
	assert_true(_activate(game, bar, 0, [a.uid] as Array[int]))
	assert_eq(game.get_attack(a), 3)
	assert_false(_activate(game, bar, 0, [a.uid] as Array[int]), "each unit can be targeted only once per turn")
	assert_true(_activate(game, bar, 0, [b.uid] as Array[int]))


func test_ultimate_cardio_machine_gives_hustle_to_entering_units() -> void:
	var game: GameState = _game()
	_energy(game)
	_field(game, 0, "B-31")
	var plain: CardInstance = game.create_token(0, CardSet.card("T-16"))
	assert_true(game.unit_has_keyword(plain, CardEnums.Keyword.HUSTLE), "a unit entering without Hustle gains it")
	assert_eq(game.get_attack(plain), 1, "...but not the +2/+1, which is for units that entered WITH Hustle")
	var fast: CardInstance = _play(game, "B-01")
	assert_eq(game.get_attack(fast), 4, "Gym Bro entered with Hustle: +2/+1 until end of turn")
	assert_eq(game.get_defense(fast), 2)


# ---- Traps -----------------------------------------------------------------------------------------------


func _opponent_attacks_with(game: GameState, unit: CardInstance) -> void:
	_until_turn_of(game, 1)
	game.advance_phase()
	assert_eq(game.phase, GameState.Phase.COMBAT)
	assert_true(game.declare_attackers([unit.uid] as Array[int]))


func test_a_trap_is_set_face_down_and_springs_once_on_the_opponents_turn() -> void:
	var game: GameState = _game()
	_energy(game)
	var trap: CardInstance = _play(game, "R-14")
	assert_true(trap.face_down)
	assert_true(game.players[0].traps.has(trap))
	var attacker: CardInstance = _unit(game, 1, 2, 5)
	_opponent_attacks_with(game, attacker)
	assert_eq(attacker.damage, 2, "Rusty Spring Trap: 2 damage to the attacker")
	assert_false(game.players[0].traps.has(trap))
	assert_true(_refuse_ids(game, 0).has("R-14"), "a sprung Trap goes to the Refuse Pile")


func test_traps_do_not_spring_on_your_own_attacks() -> void:
	var game: GameState = _game()
	_energy(game)
	_play(game, "R-14")
	var mine: CardInstance = _unit(game, 0, 2, 5)
	var foe_unit: CardInstance = _unit(game, 1, 1, 5)
	game.advance_phase()
	game.declare_attackers([mine.uid] as Array[int])
	assert_eq(mine.damage, 0)
	assert_eq(foe_unit.damage, 0)


func test_dinner_is_served_plates_small_attackers_only() -> void:
	var game: GameState = _game()
	_energy(game)
	_play(game, "G-16")
	var small: CardInstance = _unit(game, 1, 3, 3, [CardEnums.Keyword.FLYING] as Array[CardEnums.Keyword])
	_opponent_attacks_with(game, small)
	assert_eq(small.data.id, "T-09", "it became a Snack")
	assert_true(small.is_token())
	assert_eq(game.get_attack(small), 1)
	assert_eq(game.get_defense(small), 1)
	assert_false(game.unit_has_keyword(small, CardEnums.Keyword.FLYING), "a Snack has no abilities")
	var game2: GameState = _game()
	_energy(game2)
	_play(game2, "G-16")
	var big: CardInstance = _unit(game2, 1, 4, 4)
	_opponent_attacks_with(game2, big)
	assert_ne(big.data.id, "T-09", "attack 4 is too big for Dinner Is Served")


func test_plate_it_turns_a_unit_into_a_snack_that_never_reaches_a_refuse_pile() -> void:
	var game: GameState = _game()
	_energy(game)
	var target: CardInstance = _field(game, 1, "N-28")
	game.buff_unit(target, 2)
	_play(game, "G-20", [target.uid] as Array[int])
	assert_eq(target.data.id, "T-09")
	assert_eq(game.get_attack(target), 1)
	assert_eq(game.get_defense(target), 1)
	assert_eq(target.buffs, 0)
	game.destroy_unit(target)
	assert_eq(game.players[1].refuse_pile.size(), 0, "a Snack token leaves no card behind")


func test_garbage_pit_destroys_an_entering_unit_for_garbage_equal_to_its_defense() -> void:
	var game: GameState = _game()
	_energy(game)
	_play(game, "R-12")
	_until_turn_of(game, 1)
	_energy(game, 1)
	var big: CardInstance = GameFactory.add_to_hand(game, 1, CardSet.card("C-09"))
	assert_true(game.play_card(1, big.uid))
	assert_false(game.players[1].field.has(big), "destroyed")
	assert_eq(_count(game, 0, KIND.GARBAGE), 5, "Old Kingdom Automaton has defense 5")
	assert_true(_refuse_ids(game, 1).has("C-09"))


func test_turf_war_brawls_the_attacker_with_your_strongest_unit() -> void:
	var game: GameState = _game()
	_energy(game)
	var weak: CardInstance = _unit(game, 0, 1, 3)
	var strong: CardInstance = _unit(game, 0, 4, 6)
	_play(game, "R-15")
	var attacker: CardInstance = _unit(game, 1, 3, 3)
	_opponent_attacks_with(game, attacker)
	assert_false(game.players[1].field.has(attacker), "Brawl: the 4-attack unit kills the attacker")
	assert_eq(strong.damage, 3)
	assert_eq(weak.damage, 0)


func test_late_fee_and_mirrored_hall_and_tripwire() -> void:
	var game: GameState = _game()
	_energy(game)
	_play(game, "N-11")
	_until_turn_of(game, 1)
	_energy(game, 1)
	var expensive: CardInstance = GameFactory.add_to_hand(game, 1, CardSet.card("C-09"))
	var hp: int = game.players[1].hp
	assert_true(game.play_card(1, expensive.uid))
	assert_eq(game.players[1].hp, hp - 2, "Late Fee: the opponent played a card that costs 5")
	var game2: GameState = _game()
	_energy(game2)
	_play(game2, "C-32")
	var attacker: CardInstance = _unit(game2, 1, 3, 3)
	_opponent_attacks_with(game2, attacker)
	var copies: Array[CardInstance] = []
	for unit: CardInstance in game2.players[0].units():
		if unit.is_token():
			copies.append(unit)
	assert_eq(copies.size(), 1, "Mirrored Hall: a token copy under your control")
	assert_eq(game2.get_attack(copies[0]), 3)


func test_hp_threshold_traps() -> void:
	var game: GameState = _game()
	_energy(game)
	_play(game, "C-18")
	game.players[0].hp = 6
	game.deal_damage_to_player(0, 0, 2)
	assert_eq(game.players[0].hp, 8, "Emergency Rations: HP dropped to 4, gain 4")
	var game2: GameState = _game()
	_energy(game2)
	_bury(game2, 0, "N-01")
	_play(game2, "R-32")
	game2.players[0].hp = 7
	game2.deal_damage_to_player(0, 0, 1)
	assert_eq(game2.players[0].hp, 6, "still above 5: not sprung")
	game2.deal_damage_to_player(0, 0, 2)
	assert_eq(game2.players[0].hp, 9, "Back From the Heap: gain 5 (4 + 5)")
	assert_eq(_count(game2, 0, KIND.GARBAGE), 5)
	assert_eq(game2.players[0].refuse_pile.size(), 1, "the sprung Trap itself lands in the Refuse Pile after the shuffle")


func test_second_hand_life_and_permission_to_die_denied() -> void:
	var game: GameState = _game()
	_energy(game)
	_play(game, "R-24")
	var unit: CardInstance = _field(game, 0, "C-03")
	game.destroy_unit(unit)
	assert_true(game.players[0].hand.has(unit), "returned to your hand")
	assert_eq(_count(game, 0, KIND.GARBAGE), 1)
	var game2: GameState = _game()
	_energy(game2)
	_play(game2, "N-25")
	var unit2: CardInstance = _field(game2, 0, "C-03")
	game2.destroy_unit(unit2)
	assert_true(game2.players[0].field.has(unit2), "Reinstated at once")
	assert_true(unit2.summoning_sick)


func test_trap_limit_is_three() -> void:
	var game: GameState = _game()
	_energy(game, 0, 6)
	for id: String in ["R-14", "R-15", "C-16"]:
		_play(game, id)
	var fourth: CardInstance = GameFactory.add_to_hand(game, 0, CardSet.card("B-19"))
	assert_false(game.can_play_card(0, fourth.uid), "a fourth Trap cannot be set")


# ---- Brawl, damage, Toxic and friends -------------------------------------------------------------------


func test_brawl_deals_damage_both_ways() -> void:
	var game: GameState = _game()
	_energy(game)
	var mine: CardInstance = _unit(game, 0, 3, 3)
	var theirs: CardInstance = _unit(game, 1, 2, 4)
	_play(game, "R-19", [mine.uid, theirs.uid] as Array[int])
	assert_eq(mine.damage, 2)
	assert_eq(theirs.damage, 3)
	var weaker: CardInstance = _unit(game, 1, 1, 3)
	_play(game, "R-19", [mine.uid, weaker.uid] as Array[int])
	assert_false(game.players[1].field.has(weaker), "3 damage kills a 1/3")
	assert_false(game.players[0].field.has(mine), "2 + 1 damage taken in total kills the 3-defense unit")


func test_yeet_deals_damage_equal_to_attack() -> void:
	var game: GameState = _game()
	_energy(game)
	var thrower: CardInstance = _unit(game, 0, 4, 4)
	var victim: CardInstance = _unit(game, 1, 1, 6)
	_play(game, "B-25", [thrower.uid, victim.uid] as Array[int])
	assert_eq(victim.damage, 4)
	assert_eq(thrower.damage, 0)
	var hp: int = game.players[1].hp
	_play(game, "B-25", [thrower.uid, Targets.player(1)] as Array[int])
	assert_eq(game.players[1].hp, hp - 4, "or the opponent")


func test_divided_damage_spreads_over_the_chosen_units() -> void:
	var game: GameState = _game()
	_energy(game)
	var a: CardInstance = _unit(game, 1, 1, 2)
	var b: CardInstance = _unit(game, 1, 1, 2)
	var tool_card: CardInstance = _play(game, "GB-09")
	_give(game, 0, KIND.INGREDIENT, 2)
	assert_true(_activate(game, tool_card, 0, [a.uid, b.uid] as Array[int]))
	assert_false(game.players[1].field.has(a))
	assert_false(game.players[1].field.has(b), "4 damage divided between two 2-defense units kills both")
	assert_eq(_count(game, 0, KIND.INGREDIENT), 0)


func test_mass_damage_spells() -> void:
	var game: GameState = _game()
	_energy(game)
	var mine: CardInstance = _unit(game, 0, 2, 5)
	var theirs: CardInstance = _unit(game, 1, 2, 4)
	_play(game, "B-27")
	assert_eq(mine.damage, 4)
	assert_false(game.players[1].field.has(theirs))


func test_toxic_destroys_anything_it_damages_unless_unbreakable() -> void:
	var game: GameState = _game()
	var toxic: CardInstance = _unit(game, 0, 1, 1, [CardEnums.Keyword.TOXIC] as Array[CardEnums.Keyword])
	var big: CardInstance = _unit(game, 1, 1, 9)
	var solid: CardInstance = _unit(game, 1, 1, 9, [CardEnums.Keyword.UNBREAKABLE] as Array[CardEnums.Keyword])
	game.deal_damage_to_unit(toxic.uid, big, 1)
	game.deal_damage_to_unit(toxic.uid, solid, 1)
	game.check_state()
	assert_false(game.players[1].field.has(big), "any damage from a Toxic source destroys it")
	assert_true(game.players[1].field.has(solid), "Unbreakable survives Toxic")


func test_unbreakable_survives_damage_and_destroy_effects_but_not_zero_defense() -> void:
	var game: GameState = _game()
	_energy(game)
	var rock: CardInstance = _unit(game, 1, 2, 3, [CardEnums.Keyword.UNBREAKABLE] as Array[CardEnums.Keyword])
	game.deal_damage_to_unit(0, rock, 10)
	game.check_state()
	assert_true(game.players[1].field.has(rock), "lethal damage does not destroy it")
	assert_false(game.destroy_card(rock), "destroy effects fail")
	game.change_stats(rock, 0, -3, false)
	game.check_state()
	assert_false(game.players[1].field.has(rock), "reduced to 0 defense it dies")


func test_shred_removes_a_card_from_the_game() -> void:
	var game: GameState = _game()
	_energy(game, 0, 4)
	var victim: CardInstance = _unit(game, 1, 2, 2)
	_play(game, "C-30", [victim.uid] as Array[int])
	assert_false(game.players[1].field.has(victim))
	assert_eq(game.players[1].refuse_pile.size(), 0, "Shredded: not in the Refuse Pile")
	var a: CardInstance = _bury(game, 1, "N-01")
	var b: CardInstance = _bury(game, 1, "R-01")
	var hand_before: int = game.players[0].hand.size()
	_play(game, "C-25", [a.uid, b.uid] as Array[int])
	assert_eq(game.players[1].refuse_pile.size(), 0, "Shred the Evidence")
	assert_eq(game.players[0].hand.size(), hand_before + 1, "and draw a card")


func test_shred_can_remove_resources() -> void:
	var game: GameState = _game()
	_give(game, 1, KIND.GARBAGE, 2)
	_give(game, 1, KIND.IRON, 1)
	_give(game, 1, KIND.CONTRACT, 1)
	var broom: CardInstance = _field(game, 0, "N-10")
	var unit: CardInstance = _unit(game, 0, 2, 2)
	game.advance_phase()
	game.declare_attackers([unit.uid] as Array[int])
	assert_eq(_count(game, 1, KIND.GARBAGE), 0, "Push Broom of Undeath shreds Garbage, Iron and Ingredients")
	assert_eq(_count(game, 1, KIND.IRON), 0)
	assert_eq(_count(game, 1, KIND.CONTRACT), 1, "but not Contracts")
	assert_not_null(broom)


# ---- Reinstate, Regrow, Bury -----------------------------------------------------------------------------------


func test_reinstate_puts_a_unit_from_your_refuse_pile_onto_the_field() -> void:
	var game: GameState = _game()
	_energy(game)
	var dead: CardInstance = _bury(game, 0, "N-01")
	_play(game, "N-07", [dead.uid] as Array[int])
	assert_true(game.players[0].field.has(dead))
	assert_false(game.players[0].refuse_pile.has(dead))
	assert_true(dead.summoning_sick, "it enters like any unit")
	var too_big: CardInstance = _bury(game, 0, "C-09")
	var worker: CardInstance = GameFactory.add_to_hand(game, 0, CardSet.card("N-07"))
	assert_true(game.legal_play_targets(0, worker.uid, 0).has(dead.uid) == false, "already on the field")
	assert_false(game.legal_play_targets(0, worker.uid, 0).has(too_big.uid), "cost 2 or less only")


func test_lich_reinstates_from_any_refuse_pile_under_your_control() -> void:
	var game: GameState = _game()
	_energy(game, 0, 5)
	var enemy_dead: CardInstance = _bury(game, 1, "C-09")
	_play(game, "N-28", [enemy_dead.uid] as Array[int])
	assert_true(game.players[0].field.has(enemy_dead), "under your control")
	assert_eq(enemy_dead.owner, 0)
	assert_eq(enemy_dead.real_owner, 1)
	game.destroy_unit(enemy_dead)
	assert_true(game.players[1].refuse_pile.has(enemy_dead), "it dies back into its owner's Refuse Pile")


func test_mandatory_optional_team_meeting_reinstates_all_necrocrat_units() -> void:
	var game: GameState = _game()
	_energy(game, 0, 6)
	var a: CardInstance = _bury(game, 0, "N-01")
	var b: CardInstance = _bury(game, 0, "N-23")
	var other: CardInstance = _bury(game, 0, "R-01")
	_play(game, "N-27")
	assert_true(game.players[0].field.has(a))
	assert_true(game.players[0].field.has(b))
	assert_false(game.players[0].field.has(other), "only Necrocrat units")


func test_regrow_returns_cards_from_the_refuse_pile_to_hand() -> void:
	var game: GameState = _game()
	_energy(game)
	var dead: CardInstance = _bury(game, 0, "N-01")
	var compostella: CardInstance = _field(game, 0, "R-33")
	_give(game, 0, KIND.GARBAGE, 1)
	assert_true(_activate(game, compostella, 1, [dead.uid] as Array[int]))
	assert_true(game.players[0].hand.has(dead))


func test_bury_moves_the_top_cards_of_the_deck_to_the_refuse_pile() -> void:
	var game: GameState = _game()
	_energy(game)
	var deck_before: int = game.players[0].deck.size()
	var buried: Array[CardInstance] = game.bury_deck(0, 4)
	assert_eq(buried.size(), 4)
	assert_eq(game.players[0].deck.size(), deck_before - 4)
	assert_eq(game.players[0].refuse_pile.size(), 4)


func test_gross_margin_counts_the_unit_cards_it_buries() -> void:
	var game: GameState = _game()
	_energy(game)
	game.players[0].deck.clear()
	for id: String in ["N-01", "N-01", "BAS-N", "N-15", "R-01"]:
		game.players[0].deck.append(game.create_instance(CardSet.card(id), 0))
	var hp: int = game.players[1].hp
	_play(game, "NR-11")
	assert_eq(_count(game, 0, KIND.GARBAGE), 3, "three unit cards were buried")
	assert_eq(game.players[1].hp, hp - 3)


# ---- Processing and delayed effects ----------------------------------------------------------------------------


func test_processing_resolves_two_of_your_turns_from_now() -> void:
	var game: GameState = _game()
	_energy(game)
	var victim: CardInstance = _unit(game, 1, 2, 2)
	_play(game, "N-16", [victim.uid] as Array[int])
	assert_true(game.players[1].field.has(victim), "not yet")
	_until_turn_of(game, 0)
	assert_true(game.players[1].field.has(victim), "one turn from now: still alive")
	_until_turn_of(game, 0)
	assert_false(game.players[1].field.has(victim), "two turns from now: destroyed at the start of your turn")


func test_bone_afide_strongman_comes_back_after_processing_one() -> void:
	var game: GameState = _game()
	var strongman: CardInstance = _field(game, 0, "NB-14")
	game.destroy_unit(strongman)
	assert_true(game.players[0].refuse_pile.has(strongman))
	_until_turn_of(game, 0)
	assert_true(game.players[0].field.has(strongman), "Reinstated at the start of your next turn")


func test_reclamation_order_takes_the_attacker_next_turn() -> void:
	var game: GameState = _game()
	_energy(game)
	_play(game, "NR-13")
	var attacker: CardInstance = _unit(game, 1, 3, 3)
	var real: CardInstance = game.create_instance(CardSet.card("C-09"), 1)
	game.players[1].field.append(real)
	real.summoning_sick = false
	game.players[1].field.erase(attacker)
	_opponent_attacks_with(game, real)
	assert_false(game.players[1].field.has(real), "destroyed when it attacked")
	_until_turn_of(game, 0)
	assert_true(game.players[0].field.has(real), "and reinstated under your control at the start of your next turn")


# ---- Control, Clauses and copies ------------------------------------------------------------------------------


func test_unconscionable_contract_steals_a_unit_for_good() -> void:
	var game: GameState = _game()
	_energy(game, 0, 6)
	var prize: CardInstance = _unit(game, 1, 5, 5)
	_play(game, "N-32", [prize.uid] as Array[int])
	assert_true(game.players[0].field.has(prize))
	assert_eq(prize.owner, 0)
	assert_eq(_count(game, 0, KIND.CONTRACT), 3)
	assert_true(prize.summoning_sick)
	_until_turn_of(game, 1)
	assert_true(game.players[0].field.has(prize), "permanent")


func test_squatters_rights_and_hostile_takeover() -> void:
	var game: GameState = _game()
	_energy(game, 0, 6)
	var infra: CardInstance = GameFactory.add_infrastructure(game, 1, GameFactory.infra(Affinity.Type.GOURMAND))
	_play(game, "NB-05", [infra.uid] as Array[int])
	assert_true(game.players[0].infrastructure.has(infra))
	assert_eq(_count(game, 0, KIND.IRON), 1)
	_give(game, 1, KIND.GARBAGE, 2)
	_give(game, 1, KIND.CONTRACT, 1)
	_play(game, "NB-12")
	assert_eq(_count(game, 1, KIND.GARBAGE), 0)
	assert_eq(_count(game, 0, KIND.GARBAGE), 2, "Hostile Takeover: all the opponent's resources are yours")
	assert_eq(_count(game, 0, KIND.CONTRACT), 0, "a Contract is a token, not a resource: Hostile Takeover leaves it")
	assert_eq(_count(game, 1, KIND.CONTRACT), 1)


func test_resting_in_peace_clause_springs_when_the_opponent_draws_it() -> void:
	var game: GameState = _game()
	_energy(game)
	_play(game, "N-19")
	var clauses: int = 0
	for card: CardInstance in game.players[1].deck:
		if card.data.id == "T-12":
			clauses += 1
			assert_eq(card.creator, 0, "remembers who made it")
	assert_eq(clauses, 2)
	game.players[1].deck.append(game.players[1].deck.pop_at(game.players[1].deck.find(_first_clause(game))))
	var hand_before: int = game.players[1].hand.size()
	game.draw_cards(1, 1)
	assert_eq(game.players[1].hand.size(), hand_before, "the Clause never reaches the hand")
	assert_eq(_on_field(game, 0, "T-11").size(), 1, "its creator gets a 2/2 Zombie Rat")


func _first_clause(game: GameState) -> CardInstance:
	for card: CardInstance in game.players[1].deck:
		if card.data.id == "T-12":
			return card
	return null


func test_token_copies_and_somethinb_out_of_nothing() -> void:
	var game: GameState = _game()
	_energy(game, 0, 6)
	var rat: CardInstance = game.create_token(0, CardSet.card("T-02"))
	var golem: CardInstance = game.create_token(0, CardSet.card("T-06"))
	_give(game, 0, KIND.GARBAGE, 2)
	_play(game, "GRN-08")
	assert_eq(_on_field(game, 0, "T-06").size() + _on_field(game, 0, "T-02").size(), 4, "each unit token was copied, then every token became a copy of the best")
	assert_eq(_count(game, 0, KIND.GARBAGE), 4, "resource tokens are copied too")
	assert_not_null(rat)
	assert_not_null(golem)
