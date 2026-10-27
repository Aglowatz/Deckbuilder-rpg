extends CardTestBase
## Cards Oct 27, Part 1: the 14 new cards of the card review and every changed card's new rules, card by card.

const KW := CardEnums.Keyword


func _ready_unit(game: GameState, owner: int, attack: int, defense: int, path: Affinity.Type = Affinity.Type.BEEFCAKE) -> CardInstance:
	return GameFactory.add_to_field(game, owner, GameFactory.vanilla(attack, defense, 1, path))


# ---- The three new hate cards and Let Them Eat Cake ------------------------------------------------------------


func test_let_them_eat_cake_deals_3_or_destroys_a_gourmand_unit_and_makes_garbage() -> void:
	var game: GameState = _game()
	_energy(game)
	var big: CardInstance = _ready_unit(game, 1, 2, 5)
	_play(game, "R-21", [big.uid] as Array[int])
	assert_eq(big.damage, 3, "3 damage to a non-Gourmand unit")
	assert_eq(_count(game, 0, KIND.GARBAGE), 0, "no Garbage unless it was a Gourmand")
	var sentry: CardInstance = _field(game, 1, "G-04")
	_play(game, "R-21", [sentry.uid] as Array[int])
	assert_true(_on_field(game, 1, "G-04").is_empty(), "a Gourmand unit is destroyed outright (1/6 Sourdough Sentry)")
	assert_eq(_count(game, 0, KIND.GARBAGE), 1)


func test_desk_flip_deals_2_or_4_to_a_necrocrat_unit() -> void:
	var game: GameState = _game()
	_energy(game)
	var wall: CardInstance = _ready_unit(game, 1, 1, 3)
	_play(game, "B-36", [wall.uid] as Array[int])
	assert_eq(wall.damage, 2)
	assert_false(_on_field(game, 1, wall.data.id).is_empty(), "2 damage does not kill a 3-defense unit")
	var accountant: CardInstance = _field(game, 1, "N-05")  # 2/3 Necrocrat
	_play(game, "B-36", [accountant.uid] as Array[int])
	assert_true(_on_field(game, 1, "N-05").is_empty(), "4 damage kills the Necrocrat 2/3")


func test_pest_control_bounces_or_plates_a_refusemancer_unit() -> void:
	var game: GameState = _game()
	_energy(game)
	var brute: CardInstance = _ready_unit(game, 1, 3, 3)
	var hand_before: int = game.players[1].hand.size()
	_play(game, "G-35", [brute.uid] as Array[int])
	assert_eq(game.players[1].hand.size(), hand_before + 1, "sent back to its owner's hand")
	var tortoise: CardInstance = _field(game, 1, "R-09")
	_play(game, "G-35", [tortoise.uid] as Array[int])
	assert_true(_on_field(game, 1, "R-09").is_empty(), "the Refusemancer unit is Plated")
	assert_eq(_on_field(game, 1, "T-09").size(), 1, "a 1/1 Snack stands in its place")


func test_compliance_review_shrinks_until_your_next_turn_or_destroys_a_beefcake_unit() -> void:
	var game: GameState = _game()
	_energy(game)
	var ogre: CardInstance = _ready_unit(game, 1, 4, 4, Affinity.Type.GOURMAND)
	_play(game, "N-37", [ogre.uid] as Array[int])
	assert_eq(game.get_attack(ogre), 2, "-2/-0")
	_until_turn_of(game, 1)
	assert_eq(game.get_attack(ogre), 2, "still shrunk through the opponent's turn")
	_until_turn_of(game, 0)
	assert_eq(game.get_attack(ogre), 4, "back to normal at the start of your next turn")
	var bouncer: CardInstance = _field(game, 1, "B-11")
	_play(game, "N-37", [bouncer.uid] as Array[int])
	assert_true(_on_field(game, 1, "B-11").is_empty(), "a Beefcake unit is destroyed instead")


# ---- Necrocrat ------------------------------------------------------------------------------------------------------


func test_final_notice_destroys_any_unit_and_creates_a_red_tape() -> void:
	var game: GameState = _game()
	_energy(game)
	var giant: CardInstance = _ready_unit(game, 1, 8, 8, Affinity.Type.GOURMAND)
	_play(game, "N-34", [giant.uid] as Array[int])
	assert_true(_on_field(game, 1, giant.data.id).is_empty())
	assert_eq(_count(game, 0, KIND.RED_TAPE), 1)


func test_pending_approval_resolves_at_the_start_of_your_next_turn() -> void:
	var game: GameState = _game()
	_energy(game)
	_play(game, "N-35")
	assert_eq(_on_field(game, 0, "T-10").size(), 0, "nothing yet: Processing 1")
	assert_eq(_count(game, 0, KIND.RED_TAPE), 0)
	_until_turn_of(game, 0)
	assert_eq(_on_field(game, 0, "T-10").size(), 2, "two Zombie Temps")
	assert_eq(_count(game, 0, KIND.RED_TAPE), 1, "and a Red Tape")


func test_service_charge_fires_on_the_opponents_second_card_of_a_turn() -> void:
	var game: GameState = _game()
	_energy(game)
	_energy(game, 1)
	_play(game, "N-36")
	assert_eq(game.players[0].traps.size(), 1, "set face down")
	_until_turn_of(game, 1)
	var hp: int = game.players[1].hp
	_play(game, "C-01", [] as Array[int], 1)
	assert_eq(game.players[1].hp, hp, "the first card is free")
	assert_eq(game.players[0].traps.size(), 1)
	_play(game, "C-01", [] as Array[int], 1)
	assert_eq(game.players[1].hp, hp - 2, "the second card costs 2 HP")
	assert_eq(_count(game, 0, KIND.RED_TAPE), 1, "and makes you a Red Tape")
	assert_eq(game.players[0].traps.size(), 0, "the trap is spent")


func test_push_broom_is_an_attached_tool_that_sweeps_two_enemy_resources() -> void:
	var game: GameState = _game()
	_energy(game)
	var clerk: CardInstance = _field(game, 0, "N-01")
	var broom: CardInstance = _play(game, "N-10")
	assert_true(_activate(game, broom, 0, [clerk.uid] as Array[int]), "Exhaust: attach")
	assert_eq(broom.attached_to, clerk.uid)
	assert_eq(game.get_defense(clerk), 3, "+0/+1")
	_give(game, 1, KIND.GARBAGE, 2)
	_give(game, 1, KIND.IRON, 1)
	game.advance_phase()
	assert_true(game.declare_attackers([clerk.uid] as Array[int]))
	var left: int = _count(game, 1, KIND.GARBAGE) + _count(game, 1, KIND.IRON)
	assert_eq(left, 1, "two of the opponent's three resources are destroyed when the attached unit attacks")


# ---- Beefcake ---------------------------------------------------------------------------------------------------------


func test_hammer_thrower_overexerts_to_throw_its_attack() -> void:
	var game: GameState = _game()
	_energy(game)
	var thrower: CardInstance = _field(game, 0, "B-34")
	var target: CardInstance = _ready_unit(game, 1, 2, 3, Affinity.Type.GOURMAND)
	assert_true(_activate(game, thrower, 0, [target.uid] as Array[int]))
	assert_true(_on_field(game, 1, target.data.id).is_empty(), "3 damage kills the 2/3")
	assert_true(thrower.exhausted)
	_until_turn_of(game, 0)
	assert_true(thrower.exhausted, "Overexert: it does not refresh during your next turn")


func test_protein_shake_pumps_until_end_of_turn_and_makes_an_iron() -> void:
	var game: GameState = _game()
	_energy(game)
	var bro: CardInstance = _field(game, 0, "B-01")
	_play(game, "B-35", [bro.uid] as Array[int])
	assert_eq(game.get_attack(bro), 3)
	assert_eq(game.get_defense(bro), 3)
	assert_eq(_count(game, 0, KIND.IRON), 1)
	_until_turn_of(game, 0)
	assert_eq(game.get_attack(bro), 1, "the pump ends with the turn")


func test_dry_scoop_now_also_gives_plus_one_attack() -> void:
	var game: GameState = _game()
	_energy(game)
	var sick: CardInstance = GameFactory.add_to_field(game, 0, GameFactory.vanilla(2, 2), false)
	_play(game, "B-20", [sick.uid] as Array[int])
	assert_eq(game.get_attack(sick), 3)
	assert_true(game.unit_has_keyword(sick, KW.HUSTLE))


func test_bronzer_costs_one_pip_and_the_mill_worker_and_clock_cost_less() -> void:
	assert_eq(CardSet.card("B-02").energy_value(), 1, "Bronzer: (B)")
	assert_eq(CardSet.card("B-24").energy_value(), 3, "Overclocked Mill Worker: 2(B)")
	assert_eq(CardSet.card("B-22").colored_pips, [Affinity.Type.BEEFCAKE] as Array[Affinity.Type], "Alarm-ish Clock has a Beefcake pip now")
	assert_eq(CardSet.card("G-22").energy_value(), 6, "The Cullinator: 4(G)(G)")
	assert_eq(CardSet.card("N-19").rarity, CardEnums.Rarity.UNCOMMON, "Resting In Peace Clause is Uncommon")
	assert_eq(CardSet.card("C-01").attack, 2, "Cannon Fodder 2/1")
	assert_eq(CardSet.card("C-09").defense, 6, "Old Kingdom Automaton 4/6")
	assert_eq(CardSet.card("NB-13").display_name, "Wobble Weights")
	assert_eq(CardSet.card("R-21").display_name, "Let Them Eat Cake")


# ---- Gourmand ---------------------------------------------------------------------------------------------------------


func test_amuse_bouche_makes_an_ingredient_peeks_and_draws() -> void:
	var game: GameState = _game()
	_energy(game)
	for id: String in ["G-01", "G-04"]:
		game.players[0].deck.append(game.create_instance(CardSet.card(id), 0))
	var hand: int = game.players[0].hand.size()
	_play(game, "G-34")
	assert_eq(_count(game, 0, KIND.INGREDIENT), 1)
	assert_eq(game.players[0].hand.size(), hand + 1, "then draw a card")


func test_bulking_program_buffs_once_per_turn_when_an_ingredient_is_used() -> void:
	var game: GameState = _game()
	_energy(game)
	_field(game, 0, "GB-07")
	var cook: CardInstance = _field(game, 0, "G-01")
	var mold: CardInstance = _field(game, 0, "G-12")
	var second_mold: CardInstance = _field(game, 0, "G-12")
	_give(game, 0, KIND.INGREDIENT, 4)
	assert_true(_activate(game, mold, 0), "cook two Ingredients into a Golem")
	assert_eq(_buffs_total(game), 1, "one buff for the turn, not one per Ingredient")
	assert_true(_activate(game, second_mold, 0))
	assert_eq(_buffs_total(game), 1, "Do this only once per turn")
	_until_turn_of(game, 0)
	_give(game, 0, KIND.INGREDIENT, 2)
	assert_true(_activate(game, mold, 0))
	assert_eq(_buffs_total(game), 2, "a new turn, a new buff")
	assert_true(cook.buffs <= 1)


func _buffs_total(game: GameState) -> int:
	var total: int = 0
	for card: CardInstance in game.players[0].field:
		total += card.buffs
	return total


# ---- Refusemancer -----------------------------------------------------------------------------------------------------


func test_curb_alert_regrows_a_unit_card_and_makes_garbage() -> void:
	var game: GameState = _game()
	_energy(game)
	var dead: CardInstance = _bury(game, 0, "R-06")
	_play(game, "R-34", [dead.uid] as Array[int])
	assert_true(game.players[0].hand.has(dead), "the unit card is back in hand")
	assert_eq(_count(game, 0, KIND.GARBAGE), 1)


func test_sewer_choir_brings_two_rats() -> void:
	var game: GameState = _game()
	_energy(game)
	_play(game, "R-35")
	assert_eq(_on_field(game, 0, "T-02").size(), 2)


func test_landfill_leviathan_enters_with_garbage_and_eats_for_bulldoze() -> void:
	var game: GameState = _game()
	_energy(game, 0, 4)
	var leviathan: CardInstance = _play(game, "R-36")
	assert_eq(_count(game, 0, KIND.GARBAGE), 2)
	assert_false(game.unit_has_keyword(leviathan, KW.BULLDOZE))
	assert_true(_activate(game, leviathan, 1), "the eat ability (index 1; the enter trigger is index 0)")
	assert_true(game.unit_has_keyword(leviathan, KW.BULLDOZE))
	assert_eq(_count(game, 0, KIND.GARBAGE), 1, "eat garbage")
	_until_turn_of(game, 0)
	assert_false(game.unit_has_keyword(leviathan, KW.BULLDOZE), "until end of turn")


func test_landfill_ox_ramps_three_for_one_eat_and_no_hp() -> void:
	var game: GameState = _game()
	_energy(game)
	var ox: CardInstance = _field(game, 0, "R-03")
	_give(game, 0, KIND.GARBAGE, 1)
	var hp: int = game.players[0].hp
	assert_true(_activate(game, ox, 0))
	assert_eq(game.players[0].pool.size(), 3, "add (R)(R)(R)")
	assert_eq(game.players[0].hp, hp, "no HP cost any more")


func test_recycling_center_regrows_on_your_turn_once_per_turn() -> void:
	var game: GameState = _game()
	_energy(game)
	var center: CardInstance = _field(game, 0, "R-26")
	var a: CardInstance = _bury(game, 0, "R-06")
	var b: CardInstance = _bury(game, 0, "R-08")
	_give(game, 0, KIND.GARBAGE, 4)
	assert_true(_activate(game, center, 0, [a.uid] as Array[int]))
	assert_true(game.players[0].hand.has(a), "returned at once, during your turn")
	assert_false(_activate(game, center, 0, [b.uid] as Array[int]), "only once per turn")
	_until_turn_of(game, 0)
	assert_true(_activate(game, center, 0, [b.uid] as Array[int]))


func test_rusty_can_opener_also_leaves_a_garbage() -> void:
	var game: GameState = _game()
	_energy(game)
	var opener: CardInstance = _field(game, 0, "R-18")
	_give(game, 1, KIND.IRON, 1)
	var iron: CardInstance = game.players[1].zone_for_kind(KIND.IRON)[0]
	assert_true(_activate(game, opener, 0, [iron.uid] as Array[int]))
	assert_eq(_count(game, 1, KIND.IRON), 0)
	assert_eq(_count(game, 0, KIND.GARBAGE), 1)


func test_reclaimed_land_fetches_one_infrastructure_whenever_the_opponent_plays_one() -> void:
	var game: GameState = _game()
	_energy(game)
	game.players[0].deck.append(game.create_instance(CardSet.card("BAS-R"), 0))
	_play(game, "R-13")
	_until_turn_of(game, 1)
	var infra_before: int = game.players[0].infrastructure.size()
	var theirs: CardInstance = GameFactory.add_to_hand(game, 1, CardSet.card("BAS-G"))
	assert_true(game.play_infrastructure(1, theirs.uid))
	assert_eq(game.players[0].infrastructure.size(), infra_before + 1, "no count comparison any more")


# ---- Dual Path and Colorless -----------------------------------------------------------------------------------------


func test_iron_filing_clerk_converts_each_resource_into_the_other() -> void:
	var game: GameState = _game()
	_energy(game)
	_field(game, 0, "NB-17")
	var bro: CardInstance = _field(game, 0, "B-01")
	var foe: CardInstance = _ready_unit(game, 1, 3, 3)
	_give(game, 0, KIND.IRON, 1)
	assert_true(game.use_resource(0, KIND.IRON, bro.uid))
	assert_eq(_count(game, 0, KIND.RED_TAPE), 1, "using an Iron makes a Red Tape")
	assert_true(game.use_resource(0, KIND.RED_TAPE, foe.uid))
	assert_eq(_count(game, 0, KIND.IRON), 1, "using a Red Tape makes an Iron")


func test_shredded_spectre_grows_and_slips_past_blockers_when_you_use_a_resource() -> void:
	var game: GameState = _game()
	_energy(game)
	var spectre: CardInstance = _field(game, 0, "NB-01")
	var foe: CardInstance = _ready_unit(game, 1, 3, 3)
	_give(game, 0, KIND.RED_TAPE, 1)
	assert_true(game.use_resource(0, KIND.RED_TAPE, foe.uid))
	assert_eq(game.get_attack(spectre), 6, "+1/+0")
	assert_true(game.unit_has_keyword(spectre, KW.ELUSIVE))


func test_hamster_ball_makes_garbage_when_the_attached_unit_hits_the_opponent() -> void:
	var game: GameState = _game()
	_energy(game)
	var bro: CardInstance = _field(game, 0, "B-01")
	var ball: CardInstance = _play(game, "BR-06")
	assert_true(_activate(game, ball, 0, [bro.uid] as Array[int]))
	game.advance_phase()
	assert_true(game.declare_attackers([bro.uid] as Array[int]))
	if game.combat_step == GameState.CombatStep.DECLARE_BLOCKERS:
		game.declare_blockers({})
	assert_eq(_count(game, 0, KIND.GARBAGE), 1)


func test_hand_me_down_shield_gives_two_defense() -> void:
	var game: GameState = _game()
	_energy(game)
	var fodder: CardInstance = _field(game, 0, "C-01")
	var shield: CardInstance = _play(game, "C-35")
	assert_true(_activate(game, shield, 0, [fodder.uid] as Array[int]))
	assert_eq(game.get_defense(fodder), 3, "1 + 2")
	assert_eq(game.get_attack(fodder), 2, "Cannon Fodder is 2/1 now")
