extends CardTestBase
## Brief 14, Part C/D: the rules of the designed card set, card by card and mechanic by mechanic (resources spent by cards, Tools,
## Wonders, Traps, Plate, Brawl, Processing, Shred, Reinstate, keywords, static effects, costs...).


# ---- Basic Infrastructure and resource creation by cards ---------------------------------------------------


func test_basic_infrastructure_cards_create_their_resource_and_special_ones_do_not() -> void:
	var expected: Dictionary = {"BAS-B": KIND.IRON, "BAS-N": KIND.RED_TAPE, "BAS-G": KIND.INGREDIENT, "BAS-R": KIND.GARBAGE}
	for id: Variant in expected.keys():
		var game: GameState = _game()
		var card: CardInstance = GameFactory.add_to_hand(game, 0, CardSet.card(str(id)))
		assert_true(game.play_infrastructure(0, card.uid))
		assert_eq(_count(game, 0, int(expected[id]) as ResourceKind.Kind), 1, "%s creates its resource" % id)
		assert_eq(game.players[0].resources.size(), 1)
	var game2: GameState = _game()
	var special: CardInstance = GameFactory.add_to_hand(game2, 0, CardSet.card("INF-05"))
	assert_true(game2.play_infrastructure(0, special.uid))
	assert_eq(game2.players[0].resources.size(), 0, "dual-Path infrastructure never creates a resource")
	var special2: CardInstance = GameFactory.add_to_hand(game2, 1, CardSet.card("INF-01"))
	game2.active = 1
	assert_true(game2.play_infrastructure(1, special2.uid))
	assert_eq(game2.players[1].resources.size(), 0, "special infrastructure never creates a resource")


func test_dual_and_any_infrastructure_produce_their_paths() -> void:
	var dual: CardData = CardSet.card("INF-05")
	assert_eq(dual.produced_paths().size(), 2)
	assert_true(dual.paths().has(Affinity.Type.NECROCRAT) and dual.paths().has(Affinity.Type.BEEFCAKE))
	var any: CardData = CardSet.card("INF-11")
	assert_true(any.produces_any)
	assert_eq(any.produced_paths().size(), 4)
	assert_eq(CardSet.card("BAS-G").produced_paths(), [Affinity.Type.GOURMAND] as Array[Affinity.Type])


func test_unit_that_creates_resources_when_it_enters() -> void:
	var game: GameState = _game()
	_energy(game)
	_play(game, "B-05")
	assert_eq(_count(game, 0, KIND.IRON), 1)
	_play(game, "N-02")
	assert_eq(_count(game, 0, KIND.RED_TAPE), 1)
	_play(game, "R-06")
	assert_eq(_count(game, 0, KIND.GARBAGE), 1)
	_play(game, "G-01")
	assert_eq(_count(game, 0, KIND.INGREDIENT), 1)


func test_activated_ability_costs_pay_exhaust_and_energy_then_create() -> void:
	var game: GameState = _game()
	_energy(game)
	var diver: CardInstance = _field(game, 0, "R-02")
	assert_true(_activate(game, diver))
	assert_eq(_count(game, 0, KIND.GARBAGE), 1)
	assert_true(diver.exhausted, "Exhaust is a real cost")
	assert_false(_activate(game, diver), "an exhausted unit cannot activate again")


func test_a_summoning_sick_unit_cannot_pay_exhaust_costs_unless_it_has_hustle() -> void:
	var game: GameState = _game()
	_energy(game)
	var sick: CardInstance = GameFactory.add_to_field(game, 0, CardSet.card("R-02"), false)
	assert_false(_activate(game, sick), "summoning sick")
	assert_true(sick.summoning_sick)


func test_energy_abilities_add_floating_energy_that_pays_costs() -> void:
	var game: GameState = _game()
	var mole: CardInstance = _field(game, 0, "R-01")
	assert_true(_activate(game, mole))
	assert_eq(game.players[0].pool, [int(Affinity.Type.REFUSEMANCER)] as Array[int])
	var rat: CardInstance = GameFactory.add_to_hand(game, 0, CardSet.card("R-06"))
	assert_true(game.play_card(0, rat.uid), "the floating (R) paid for the Curbside Rat")
	assert_eq(game.players[0].pool.size(), 0)


func test_landfill_ox_eats_garbage_twice_to_add_four_energy() -> void:
	var game: GameState = _game()
	_energy(game)
	var ox: CardInstance = _field(game, 0, "R-03")
	_give(game, 0, KIND.GARBAGE, 2)
	var hp: int = game.players[0].hp
	assert_true(_activate(game, ox))
	assert_eq(game.players[0].pool.size(), 4)
	assert_eq(game.players[0].hp, hp - 2, "eating costs 1 HP each time")
	assert_eq(_count(game, 0, KIND.GARBAGE), 0)
	assert_eq(game.players[0].ready_infrastructure().size(), 10, "two energy paid for the two eats")


func test_the_raccoon_makes_eating_garbage_free() -> void:
	var game: GameState = _game()
	_energy(game)
	_field(game, 0, "R-27")
	var prowler: CardInstance = _field(game, 0, "R-08")
	_give(game, 0, KIND.GARBAGE, 1)
	var hp: int = game.players[0].hp
	var ready_before: int = game.players[0].ready_infrastructure().size()
	assert_true(_activate(game, prowler))
	assert_eq(game.players[0].hp, hp, "no HP lost")
	assert_eq(game.players[0].ready_infrastructure().size(), ready_before, "no energy paid")
	assert_eq(game.get_attack(prowler), 3, "Possum Prowler +2/+2 until end of turn")
	assert_eq(game.get_defense(prowler), 4)
	GameFactory.pass_turn(game)
	assert_eq(game.get_attack(prowler), 1, "until end of turn")


# ---- Cooking golems from Ingredients ------------------------------------------------------------------------


func test_pastry_artificer_cooks_a_cake_golem_from_two_ingredients() -> void:
	var game: GameState = _game()
	_energy(game)
	var chef: CardInstance = _field(game, 0, "G-08")
	_give(game, 0, KIND.INGREDIENT, 2)
	assert_true(_activate(game, chef))
	var golems: Array[CardInstance] = _on_field(game, 0, "T-06")
	assert_eq(golems.size(), 1)
	assert_eq(game.get_attack(golems[0]), 4)
	assert_true(golems[0].is_token())
	assert_eq(_count(game, 0, KIND.INGREDIENT), 0)


func test_meatloaf_mold_works_once_per_turn() -> void:
	var game: GameState = _game()
	var mold: CardInstance = _field(game, 0, "G-12")
	_give(game, 0, KIND.INGREDIENT, 4)
	assert_true(_activate(game, mold))
	assert_false(_activate(game, mold), "Do this only once per turn")
	assert_eq(_on_field(game, 0, "T-05").size(), 1)
	GameFactory.pass_turn(game)
	GameFactory.pass_turn(game)
	assert_true(_activate(game, mold), "available again on your next turn")
	assert_eq(_on_field(game, 0, "T-05").size(), 2)


func test_seasoning_station_and_chef_de_golem_pump_golem_tokens() -> void:
	var game: GameState = _game()
	var golem: CardInstance = game.create_token(0, CardSet.card("T-05"))
	var plain: CardInstance = _unit(game, 0, 3, 3)
	assert_eq(game.get_attack(golem), 3)
	_field(game, 0, "G-14")
	assert_eq(game.get_attack(golem), 4, "Seasoning Station: Golem tokens +1/+1")
	assert_eq(game.get_defense(golem), 4)
	assert_eq(game.get_attack(plain), 3, "only Golems")
	_field(game, 0, "G-28")
	assert_eq(game.get_attack(golem), 5)
	assert_true(game.unit_has_keyword(golem, CardEnums.Keyword.SWAT), "Chef de Golem gives Swat")
	assert_false(game.unit_has_keyword(plain, CardEnums.Keyword.SWAT))
	var foe_golem: CardInstance = game.create_token(1, CardSet.card("T-05"))
	assert_eq(game.get_attack(foe_golem), 3, "only your own Golems")


func test_grand_chef_escoffina_uses_x_ingredients_for_an_x_by_x_golem() -> void:
	var game: GameState = _game()
	var chef: CardInstance = _field(game, 0, "G-33")
	_give(game, 0, KIND.INGREDIENT, 5)
	assert_false(_activate(game, chef, 1, [] as Array[int], 0), "X must be at least 1")
	assert_true(_activate(game, chef, 1, [] as Array[int], 4))
	var golems: Array[CardInstance] = _on_field(game, 0, "T-08")
	assert_eq(golems.size(), 1)
	assert_eq(game.get_attack(golems[0]), 4)
	assert_eq(game.get_defense(golems[0]), 4)
	assert_eq(_count(game, 0, KIND.INGREDIENT), 1)


func test_legal_actions_offer_x_choices() -> void:
	var game: GameState = _game()
	_field(game, 0, "G-33")
	_give(game, 0, KIND.INGREDIENT, 3)
	var xs: Array[int] = []
	for action: GameAction in game.legal_actions():
		if action.type == GameAction.Type.ACTIVATE_ABILITY:
			xs.append(action.x)
	assert_true(xs.has(1) and xs.has(3), "X=1 and X=max are offered")


func test_infinite_pantry_and_harvest_festival_double_resources() -> void:
	var game: GameState = _game()
	_give(game, 0, KIND.INGREDIENT, 2)
	assert_eq(_count(game, 0, KIND.INGREDIENT), 2)
	_field(game, 0, "G-30")
	_give(game, 0, KIND.INGREDIENT, 2)
	assert_eq(_count(game, 0, KIND.INGREDIENT), 6, "Infinite Pantry doubles Ingredients you create")
	_give(game, 0, KIND.IRON, 1)
	assert_eq(_count(game, 0, KIND.IRON), 1, "only Ingredients")
	_give(game, 1, KIND.INGREDIENT, 1)
	assert_eq(_count(game, 1, KIND.INGREDIENT), 1, "only for you")
	_field(game, 1, "GRB-07")
	_give(game, 0, KIND.IRON, 1)
	assert_eq(_count(game, 0, KIND.IRON), 3, "Harvest Festival doubles every resource created for every player")
	_give(game, 0, KIND.INGREDIENT, 1)
	assert_eq(_count(game, 0, KIND.INGREDIENT), 10, "both effects stack: x4")


# ---- Tools -------------------------------------------------------------------------------------------------


func test_a_tool_attaches_by_exhausting_and_gives_its_bonus_to_the_unit() -> void:
	var game: GameState = _game()
	_energy(game)
	var unit: CardInstance = _unit(game, 0, 2, 2)
	var pin: CardInstance = _play(game, "G-18")
	assert_true(_activate(game, pin, 0, [unit.uid] as Array[int]))
	assert_eq(pin.attached_to, unit.uid)
	assert_true(pin.exhausted, "Exhaust: attach")
	assert_eq(game.get_attack(unit), 3)
	assert_eq(game.get_defense(unit), 4)
	assert_eq(game.get_attack(_unit(game, 0, 2, 2)), 2, "only the attached unit")


func test_a_tool_can_only_attach_to_a_unit_you_control() -> void:
	var game: GameState = _game()
	_energy(game)
	var foe_unit: CardInstance = _unit(game, 1, 2, 2)
	var pin: CardInstance = _play(game, "G-18")
	assert_false(_activate(game, pin, 0, [foe_unit.uid] as Array[int]))


func test_attached_keywords_and_conditional_keywords_from_tools() -> void:
	var game: GameState = _game()
	_energy(game)
	var unit: CardInstance = _unit(game, 0, 2, 2)
	var harpoon: CardInstance = _play(game, "R-17")
	assert_true(_activate(game, harpoon, 0, [unit.uid] as Array[int]))
	assert_true(game.unit_has_keyword(unit, CardEnums.Keyword.SWAT))
	var other: CardInstance = _unit(game, 0, 1, 1)
	var ribbon: CardInstance = _play(game, "GRB-02")
	assert_true(_activate(game, ribbon, 0, [other.uid] as Array[int]))
	assert_false(game.unit_has_keyword(other, CardEnums.Keyword.BULLDOZE), "Blue Ribbon: Bulldoze only with a buff on it")
	game.buff_unit(other, 1)
	assert_true(game.unit_has_keyword(other, CardEnums.Keyword.BULLDOZE))
	assert_eq(game.get_attack(other), 1 + 2 + 1)


func test_when_the_attached_unit_dies_the_tool_stays_unattached() -> void:
	var game: GameState = _game()
	_energy(game)
	var unit: CardInstance = _unit(game, 0, 2, 2)
	var sword: CardInstance = _play(game, "C-11")
	assert_true(_activate(game, sword, 0, [unit.uid] as Array[int]))
	game.destroy_unit(unit)
	assert_eq(sword.attached_to, 0)
	assert_true(game.players[0].field.has(sword), "the Tool stays on the field")
	assert_eq(game.attached_tools(unit).size(), 0)


func test_a_one_shot_tool_destroys_itself_for_its_effect() -> void:
	var game: GameState = _game()
	_energy(game)
	var victim: CardInstance = _unit(game, 1, 1, 5)
	var kettlebell: CardInstance = _play(game, "B-15")
	assert_true(_activate(game, kettlebell, 0, [victim.uid] as Array[int]))
	assert_eq(victim.damage, 3)
	assert_false(game.players[0].field.has(kettlebell), "Destroy this Tool")
	assert_true(_refuse_ids(game, 0).has("B-15"))


func test_lunchbox_and_healing_potion() -> void:
	var game: GameState = _game()
	_energy(game)
	game.players[0].hp = 4
	var potion: CardInstance = _play(game, "C-12")
	assert_true(_activate(game, potion))
	assert_eq(game.players[0].hp, 8)
	var box: CardInstance = _play(game, "G-19")
	assert_true(_activate(game, box))
	assert_eq(_count(game, 0, KIND.INGREDIENT), 2)
	assert_eq(game.players[0].hp, 10, "HP is capped at max")


func test_tool_triggers_for_the_attached_unit() -> void:
	var game: GameState = _game()
	_energy(game)
	var unit: CardInstance = _unit(game, 0, 2, 2)
	var cap: CardInstance = _play(game, "C-26")
	assert_true(_activate(game, cap, 0, [unit.uid] as Array[int]))
	var hand_before: int = game.players[0].hand.size()
	game.destroy_unit(unit)
	assert_eq(game.players[0].hand.size(), hand_before + 1, "Adventurer's Pack: when the attached unit dies, draw a card")


func test_global_gains_returns_to_hand_when_the_attached_unit_dies() -> void:
	var game: GameState = _game()
	_energy(game)
	var unit: CardInstance = _unit(game, 0, 2, 2)
	var membership: CardInstance = _play(game, "B-33")
	assert_true(_activate(game, membership, 0, [unit.uid] as Array[int]))
	game.destroy_unit(unit)
	assert_true(game.players[0].hand.has(membership), "returned to your hand")
	assert_false(game.players[0].field.has(membership))


func test_attached_unit_events_attack_and_damage() -> void:
	var game: GameState = _game()
	_energy(game)
	var unit: CardInstance = _unit(game, 0, 2, 5)
	var belt: CardInstance = _play(game, "NB-09")
	assert_true(_activate(game, belt, 0, [unit.uid] as Array[int]))
	var spork_unit: CardInstance = _unit(game, 0, 3, 3)
	var spork: CardInstance = _play(game, "GR-10")
	assert_true(_activate(game, spork, 0, [spork_unit.uid] as Array[int]))
	var resources_before: int = game.players[0].resources.size()
	game.advance_phase()
	assert_true(game.declare_attackers([unit.uid] as Array[int]))
	assert_eq(game.players[0].resources.size(), resources_before + 1, "Spirit-Lifting Belt: whenever attached unit attacks, create an Iron or a Red Tape")
	game.deal_damage_to_player(spork_unit.uid, 1, 1)
	assert_eq(_count(game, 0, KIND.GARBAGE), 1, "Spork of Unity: damage to an opponent creates a Garbage")
	assert_eq(_count(game, 0, KIND.INGREDIENT), 1)
