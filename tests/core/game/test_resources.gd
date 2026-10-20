extends GutTest
## Brief 14, Part B: the Resource system (Iron, Red Tape, Ingredient, Garbage; the Contract is a token), basic Infrastructure creating
## resources, the three "pay 1, use one" abilities, Eat Garbage, floating energy and the AI's use of resources.

const KIND := ResourceKind.Kind


func _game() -> GameState:
	var game: GameState = GameFactory.blank_game()
	return game


func _unit(game: GameState, owner: int, attack: int = 2, defense: int = 3) -> CardInstance:
	return GameFactory.add_to_field(game, owner, GameFactory.vanilla(attack, defense))


func _give(game: GameState, owner: int, kind: ResourceKind.Kind, count: int = 1) -> void:
	ResourceRules.create(game, owner, kind, count)


# ---- Basic Infrastructure create resources ------------------------------------------------------


func test_each_basic_infrastructure_creates_its_paths_resource_when_it_enters() -> void:
	var expected: Dictionary = {
		Affinity.Type.BEEFCAKE: KIND.IRON,
		Affinity.Type.NECROCRAT: KIND.RED_TAPE,
		Affinity.Type.GOURMAND: KIND.INGREDIENT,
		Affinity.Type.REFUSEMANCER: KIND.GARBAGE,
	}
	for path: Variant in expected.keys():
		var game: GameState = _game()
		var infra: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.infra(int(path) as Affinity.Type))
		assert_true(game.play_infrastructure(0, infra.uid), "play the basic infrastructure")
		var kind: ResourceKind.Kind = int(expected[path]) as ResourceKind.Kind
		assert_eq(game.resource_count(0, kind), 1, "%s creates a %s" % [Affinity.display_name(int(path) as Affinity.Type), ResourceKind.display_name(kind)])
		var total: int = game.players[0].resources.size()
		assert_eq(total, 1, "and nothing else")


func test_special_and_dual_infrastructure_never_create_resources() -> void:
	var game: GameState = _game()
	var special: CardData = CardBuilder.infra(Affinity.Type.BEEFCAKE, false)
	var card: CardInstance = GameFactory.add_to_hand(game, 0, special)
	assert_true(game.play_infrastructure(0, card.uid))
	assert_eq(game.players[0].resources.size(), 0, "a non-basic infrastructure creates no resource")


func test_the_resource_zone_is_separate_and_holds_token_permanents() -> void:
	var game: GameState = _game()
	_give(game, 0, KIND.IRON, 3)
	assert_eq(game.players[0].resources.size(), 3)
	assert_eq(game.players[0].field.size(), 0, "resources are not on the field")
	var resource: CardInstance = game.players[0].resources[0]
	assert_true(resource.is_token())
	assert_eq(resource.data.type, CardEnums.CardType.RESOURCE)
	assert_eq(resource.data.resource_kind, int(KIND.IRON))
	assert_eq(game.find_card(resource.uid), resource, "find_card also looks in the resource zone")


func test_resource_kinds_belong_to_their_paths_and_ids_match_the_sheet() -> void:
	assert_eq(ResourceKind.path_of(KIND.IRON), Affinity.Type.BEEFCAKE)
	assert_eq(ResourceKind.path_of(KIND.RED_TAPE), Affinity.Type.NECROCRAT)
	assert_eq(ResourceKind.path_of(KIND.CONTRACT), Affinity.Type.NECROCRAT)
	assert_eq(ResourceKind.path_of(KIND.INGREDIENT), Affinity.Type.GOURMAND)
	assert_eq(ResourceKind.path_of(KIND.GARBAGE), Affinity.Type.REFUSEMANCER)
	assert_eq(ResourceKind.card_id(KIND.CONTRACT), "T-13")
	assert_eq(ResourceKind.card_id(KIND.RED_TAPE), "T-14")


# ---- Iron, Red Tape, Contract ------------------------------------------------------------------


func test_iron_pays_one_energy_and_gives_plus_one_plus_one_until_end_of_turn() -> void:
	var game: GameState = _game()
	GameFactory.add_infrastructure_cards(game, 0, 3)
	var unit: CardInstance = _unit(game, 0, 2, 3)
	_give(game, 0, KIND.IRON, 3)
	assert_true(game.use_resource(0, KIND.IRON, unit.uid))
	assert_eq(game.get_attack(unit), 3, "+1 attack")
	assert_eq(game.get_defense(unit), 4, "+1 defense")
	assert_eq(game.resource_count(0, KIND.IRON), 2, "one Iron used")
	assert_eq(game.players[0].ready_infrastructure().size(), 2, "1 energy paid")
	assert_true(game.use_resource(0, KIND.IRON, unit.uid))
	assert_eq(game.get_attack(unit), 4, "stacks within the turn")
	assert_eq(game.get_defense(unit), 5)
	GameFactory.pass_turn(game)
	assert_eq(game.get_attack(unit), 2, "temporary: it ends with the turn")
	assert_eq(game.get_defense(unit), 3)
	assert_eq(unit.attack_bonus, 0, "no permanent change was recorded")


func test_iron_needs_energy_and_an_iron() -> void:
	var game: GameState = _game()
	var unit: CardInstance = _unit(game, 0)
	_give(game, 0, KIND.IRON)
	assert_false(game.use_resource(0, KIND.IRON, unit.uid), "no energy")
	GameFactory.add_infrastructure_cards(game, 0, 1)
	assert_false(game.use_resource(0, KIND.RED_TAPE, unit.uid), "no Red Tape")
	assert_true(game.use_resource(0, KIND.IRON, unit.uid))
	assert_false(game.use_resource(0, KIND.IRON, unit.uid), "no second Iron")


func test_red_tape_gives_minus_two_attack_until_the_start_of_the_users_next_turn() -> void:
	var game: GameState = _game()
	GameFactory.add_infrastructure_cards(game, 0, 3, Affinity.Type.NECROCRAT)
	var foe_unit: CardInstance = _unit(game, 1, 5, 3)
	_give(game, 0, KIND.RED_TAPE, 3)
	assert_true(game.use_resource(0, KIND.RED_TAPE, foe_unit.uid))
	assert_eq(game.get_attack(foe_unit), 3, "-2 attack")
	assert_eq(game.get_defense(foe_unit), 3, "defense untouched")
	assert_true(game.use_resource(0, KIND.RED_TAPE, foe_unit.uid))
	assert_eq(game.get_attack(foe_unit), 1, "stacks")
	assert_true(game.use_resource(0, KIND.RED_TAPE, foe_unit.uid))
	assert_eq(game.get_attack(foe_unit), 0, "attack never goes below 0")
	assert_eq(foe_unit.attack_bonus, 0, "not a permanent change")
	game.advance_phase()
	game.advance_phase()
	assert_eq(game.phase, GameState.Phase.MAIN2)
	assert_eq(game.get_attack(foe_unit), 0, "still shrunk in my second main phase")
	GameFactory.pass_turn(game)
	assert_eq(game.active, 1, "the controller's turn began")
	assert_eq(game.get_attack(foe_unit), 0, "still shrunk through the opponent's whole turn (Oct 19 timing)")
	assert_eq(foe_unit.lingering_turns_left(game.active), 1, "the badge counts one turn start to go")
	game.advance_phase()
	game.advance_phase()
	assert_eq(game.get_attack(foe_unit), 0, "still shrunk in the opponent's second main phase")
	GameFactory.pass_turn(game)
	assert_eq(game.active, 0, "my next turn began")
	assert_eq(game.get_attack(foe_unit), 5, "the shrink ended at the start of the user's next turn")
	assert_true(foe_unit.lingering.is_empty())
	assert_eq(foe_unit.lingering_turns_left(game.active), 0)


func test_an_enemy_red_tape_on_my_unit_lasts_through_my_turn() -> void:
	var game: GameState = _game()
	GameFactory.add_infrastructure_cards(game, 1, 2, Affinity.Type.NECROCRAT)
	var mine: CardInstance = _unit(game, 0, 4, 4)
	_give(game, 1, KIND.RED_TAPE, 1)
	GameFactory.pass_turn(game)
	assert_eq(game.active, 1)
	assert_true(game.use_resource(1, KIND.RED_TAPE, mine.uid), "the enemy shrinks my unit on its turn")
	assert_eq(game.get_attack(mine), 2)
	assert_eq(mine.lingering_turns_left(game.active), 2, "the rest of the enemy turn and my whole turn")
	GameFactory.pass_turn(game)
	assert_eq(game.active, 0, "my turn began")
	assert_eq(game.get_attack(mine), 2, "my unit attacks with -2 on my turn")
	assert_eq(mine.lingering_turns_left(game.active), 1)
	GameFactory.pass_turn(game)
	assert_eq(game.active, 1, "the enemy's next turn began")
	assert_eq(game.get_attack(mine), 4, "the shrink ended at the start of the user's (enemy's) next turn")


func test_red_tape_on_your_own_unit_lasts_until_your_own_next_turn() -> void:
	var game: GameState = _game()
	GameFactory.add_infrastructure_cards(game, 0, 2, Affinity.Type.NECROCRAT)
	var mine: CardInstance = _unit(game, 0, 4, 4)
	_give(game, 0, KIND.RED_TAPE, 1)
	assert_true(game.use_resource(0, KIND.RED_TAPE, mine.uid))
	assert_eq(game.get_attack(mine), 2)
	GameFactory.pass_turn(game)
	assert_eq(game.active, 1)
	assert_eq(game.get_attack(mine), 2, "the opponent's turn starting does not end it")
	GameFactory.pass_turn(game)
	assert_eq(game.active, 0)
	assert_eq(game.get_attack(mine), 4, "it ends when my own next turn starts")


func test_the_ai_threat_estimate_ignores_only_red_tape_that_ends_before_the_foe_attacks() -> void:
	var game: GameState = _game()
	var foe_unit: CardInstance = _unit(game, 1, 5, 3)
	game.change_stats_until_turn_of(foe_unit, -2, 0, 1)
	assert_eq(game.get_attack(foe_unit), 3)
	assert_eq(game.get_attack(foe_unit, 1), 5, "a shrink the foe made itself ends when its turn starts: it attacks with 5")
	game.change_stats_until_turn_of(foe_unit, -2, 0, 0)
	assert_eq(game.get_attack(foe_unit, 1), 3, "my Red Tape holds through the foe turn (Oct 19): it attacks with 3")
	game.change_stats(foe_unit, 1, 0, true)
	assert_eq(game.get_attack(foe_unit, 1), 4, "until-end-of-turn pumps still count (the caller is reasoning about this turn)")


func test_contract_exhausts_the_target_and_it_does_not_refresh_during_its_controllers_next_turn() -> void:
	var game: GameState = _game()
	GameFactory.add_infrastructure_cards(game, 0, 1, Affinity.Type.NECROCRAT)
	var foe_unit: CardInstance = _unit(game, 1)
	_give(game, 0, KIND.CONTRACT)
	assert_true(game.use_resource(0, KIND.CONTRACT, foe_unit.uid))
	assert_true(foe_unit.exhausted)
	GameFactory.pass_turn(game)
	assert_eq(game.active, 1)
	assert_true(foe_unit.exhausted, "still exhausted during its controller's next turn")
	GameFactory.pass_turn(game)
	GameFactory.pass_turn(game)
	assert_false(foe_unit.exhausted, "it refreshes on the turn after that")


func test_resource_abilities_are_your_turn_only_and_ingredient_and_garbage_do_nothing() -> void:
	var game: GameState = _game()
	GameFactory.add_infrastructure_cards(game, 1, 2)
	var mine: CardInstance = _unit(game, 0)
	_give(game, 1, KIND.IRON)
	assert_eq(game.active, 0)
	assert_false(game.use_resource(1, KIND.IRON, mine.uid), "the opponent cannot use resources on my turn")
	_give(game, 0, KIND.INGREDIENT)
	_give(game, 0, KIND.GARBAGE)
	assert_false(ResourceKind.has_use_ability(KIND.INGREDIENT))
	assert_false(ResourceKind.has_use_ability(KIND.GARBAGE))
	GameFactory.add_infrastructure_cards(game, 0, 1)
	assert_false(game.use_resource(0, KIND.INGREDIENT, mine.uid))
	assert_false(game.use_resource(0, KIND.GARBAGE, mine.uid))


func test_resource_use_is_not_allowed_outside_main_phases() -> void:
	var game: GameState = _game()
	GameFactory.add_infrastructure_cards(game, 0, 1)
	var unit: CardInstance = _unit(game, 0)
	_give(game, 0, KIND.IRON)
	game.advance_phase()
	assert_eq(game.phase, GameState.Phase.COMBAT)
	assert_false(game.use_resource(0, KIND.IRON, unit.uid), "not during combat")


func test_untouchable_units_cannot_be_targeted_by_the_opponents_resources() -> void:
	var game: GameState = _game()
	GameFactory.add_infrastructure_cards(game, 0, 2, Affinity.Type.NECROCRAT)
	var kw: Array[CardEnums.Keyword] = [CardEnums.Keyword.UNTOUCHABLE]
	var shy: CardInstance = GameFactory.add_to_field(game, 1, GameFactory.vanilla(2, 2, 1, Affinity.Type.BEEFCAKE, kw))
	_give(game, 0, KIND.RED_TAPE)
	assert_false(game.use_resource(0, KIND.RED_TAPE, shy.uid))
	assert_false(ResourceRules.use_targets(game, 0, KIND.RED_TAPE).has(shy.uid))
	var mine: CardInstance = _unit(game, 0)
	_give(game, 1, KIND.IRON)
	assert_true(ResourceRules.use_targets(game, 0, KIND.RED_TAPE).has(mine.uid))


func test_legal_actions_offer_each_affordable_resource_use_and_apply_works() -> void:
	var game: GameState = _game()
	GameFactory.add_infrastructure_cards(game, 0, 1)
	var a: CardInstance = _unit(game, 0)
	var b: CardInstance = _unit(game, 1)
	_give(game, 0, KIND.IRON, 3)
	var uses: Array[GameAction] = []
	for action: GameAction in game.legal_actions():
		if action.type == GameAction.Type.USE_RESOURCE:
			uses.append(action)
	assert_eq(uses.size(), 2, "one per unit target, not one per Iron")
	assert_true(game.apply_action(GameAction.use_resource(0, KIND.IRON, a.uid)))
	assert_eq(game.get_attack(a), 3)
	assert_eq(game.get_attack(b), 2)


# ---- Eat garbage -----------------------------------------------------------------------------


func test_eat_garbage_costs_one_energy_and_a_garbage_but_no_hp() -> void:
	var game: GameState = _game()
	GameFactory.add_infrastructure_cards(game, 0, 2)
	_give(game, 0, KIND.GARBAGE, 2)
	var hp: int = game.players[0].hp
	assert_true(ResourceRules.eat(game, 0))
	assert_eq(game.players[0].hp, hp, "no HP cost any more (Oct 18 rebalance)")
	assert_eq(game.resource_count(0, KIND.GARBAGE), 1)
	assert_eq(game.players[0].ready_infrastructure().size(), 1)
	assert_eq(GameFactory.count_events(game, GameEvent.Type.GARBAGE_EATEN), 1)


func test_eat_garbage_fails_without_garbage_or_energy_but_hp_does_not_matter() -> void:
	var game: GameState = _game()
	assert_false(ResourceRules.can_eat(game, 0), "no garbage")
	_give(game, 0, KIND.GARBAGE, 2)
	assert_false(ResourceRules.can_eat(game, 0), "no energy")
	GameFactory.add_infrastructure_cards(game, 0, 2)
	assert_true(ResourceRules.can_eat(game, 0))
	game.players[0].hp = 1
	assert_true(ResourceRules.can_eat(game, 0), "eating costs no HP, so 1 HP is fine")


func test_a_written_lose_hp_cost_is_paid_on_top_of_eating_and_never_kills_you() -> void:
	var game: GameState = _game()
	GameFactory.add_infrastructure_cards(game, 0, 3, Affinity.Type.REFUSEMANCER)
	_give(game, 0, KIND.GARBAGE, 3)
	var data: CardData = CardBuilder.unit("t_hurts", "Hurts", Affinity.Type.REFUSEMANCER, 1, [] as Array[Affinity.Type], 1, 3)
	data.script_text = "act | eat, lose(2) => damage(opp,2)"
	var unit: CardInstance = GameFactory.add_to_field(game, 0, data)
	var hp: int = game.players[0].hp
	var foe_hp: int = game.players[1].hp
	assert_true(game.activate_ability(0, unit.uid, 0, [] as Array[int]))
	assert_eq(game.players[0].hp, hp - 2, "the written cost is paid")
	assert_eq(game.players[1].hp, foe_hp - 2)
	assert_eq(game.resource_count(0, KIND.GARBAGE), 2, "and the Garbage was eaten")
	game.players[0].hp = 2
	assert_false(game.can_activate_ability(0, unit.uid, 0), "a lose-HP cost cannot reduce you to 0 HP")
	game.players[0].hp = 3
	assert_true(game.can_activate_ability(0, unit.uid, 0))
	assert_true(AbilityDescriber.describe(data.abilities()[0]).begins_with("Eat garbage, Lose 2 HP:"), "the written cost is described")


func test_eating_twice_costs_double_energy_and_garbage() -> void:
	var game: GameState = _game()
	GameFactory.add_infrastructure_cards(game, 0, 2)
	_give(game, 0, KIND.GARBAGE, 2)
	var hp: int = game.players[0].hp
	assert_true(ResourceRules.eat(game, 0, 2))
	assert_eq(game.players[0].hp, hp, "no HP cost")
	assert_eq(game.resource_count(0, KIND.GARBAGE), 0)
	assert_eq(game.players[0].ready_infrastructure().size(), 0)


# ---- Removing and spending ------------------------------------------------------------------


func test_use_and_remove_take_resources_out_of_the_zone() -> void:
	var game: GameState = _game()
	_give(game, 0, KIND.INGREDIENT, 3)
	assert_false(ResourceRules.use(game, 0, KIND.INGREDIENT, 4), "cannot use more than you have")
	assert_eq(game.resource_count(0, KIND.INGREDIENT), 3, "a failed use changes nothing")
	assert_true(ResourceRules.use(game, 0, KIND.INGREDIENT, 2))
	assert_eq(game.resource_count(0, KIND.INGREDIENT), 1)
	var last: CardInstance = game.players[0].resources[0]
	assert_true(ResourceRules.remove(game, last, true))
	assert_eq(game.resource_count(0, KIND.INGREDIENT), 0)
	assert_false(ResourceRules.remove(game, last, true), "already gone")


func test_use_any_of_spends_across_kinds() -> void:
	var game: GameState = _game()
	_give(game, 0, KIND.RED_TAPE, 1)
	_give(game, 0, KIND.CONTRACT, 1)
	var kinds: Array[ResourceKind.Kind] = [KIND.RED_TAPE, KIND.CONTRACT]
	assert_false(ResourceRules.use_any_of(game, 0, kinds, 3))
	assert_true(ResourceRules.use_any_of(game, 0, kinds, 2))
	assert_eq(game.players[0].resources.size(), 0)


# ---- Floating energy and flexible infrastructure ----------------------------------------------


func test_floating_energy_pays_costs_before_infrastructure_and_empties_at_end_of_turn() -> void:
	var game: GameState = _game()
	GameFactory.add_infrastructure_cards(game, 0, 1)
	game.players[0].pool.append(int(Affinity.Type.BEEFCAKE))
	var card: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(1, 1, 1))
	assert_true(game.play_card(0, card.uid))
	assert_eq(game.players[0].pool.size(), 0, "the floating energy was spent first")
	assert_eq(game.players[0].ready_infrastructure().size(), 1, "the infrastructure was not needed")
	game.players[0].pool.append(PlayerState.POOL_ANY)
	GameFactory.pass_turn(game)
	assert_eq(game.players[0].pool.size(), 0, "floating energy empties at end of turn")


func test_any_path_floating_energy_pays_a_colored_pip() -> void:
	var game: GameState = _game()
	game.players[0].pool.append(PlayerState.POOL_ANY)
	var spell: CardData = CardBuilder.spell("t_pip", "Pip", Affinity.Type.GOURMAND, 0, [Affinity.Type.GOURMAND] as Array[Affinity.Type])
	var card: CardInstance = GameFactory.add_to_hand(game, 0, spell)
	assert_true(game.can_play_card(0, card.uid))


func test_dual_and_any_path_infrastructure_pay_for_either_path() -> void:
	var dual: CardData = GameFactory.infra(Affinity.Type.NECROCRAT)
	dual.is_basic = false
	dual.paths_all = [Affinity.Type.NECROCRAT, Affinity.Type.BEEFCAKE] as Array[Affinity.Type]
	dual.color2 = Affinity.Type.BEEFCAKE
	var game: GameState = _game()
	var infra: CardInstance = GameFactory.add_infrastructure(game, 0, dual)
	assert_true(PathEnergy.can_pay([infra] as Array[CardInstance], 0, [Affinity.Type.BEEFCAKE] as Array[Affinity.Type]))
	assert_true(PathEnergy.can_pay([infra] as Array[CardInstance], 0, [Affinity.Type.NECROCRAT] as Array[Affinity.Type]))
	assert_false(PathEnergy.can_pay([infra] as Array[CardInstance], 0, [Affinity.Type.GOURMAND] as Array[Affinity.Type]))
	assert_false(PathEnergy.can_pay([infra] as Array[CardInstance], 0, [Affinity.Type.BEEFCAKE, Affinity.Type.NECROCRAT] as Array[Affinity.Type]), "one infrastructure pays one pip")
	var any_infra_data: CardData = GameFactory.infra(Affinity.Type.NEUTRAL)
	any_infra_data.produces_any = true
	var any_infra: CardInstance = GameFactory.add_infrastructure(game, 0, any_infra_data)
	assert_true(PathEnergy.can_pay([infra, any_infra] as Array[CardInstance], 0, [Affinity.Type.BEEFCAKE, Affinity.Type.NECROCRAT] as Array[Affinity.Type]), "matching assigns the two infrastructure to the two pips")
	assert_true(PathEnergy.can_pay([any_infra] as Array[CardInstance], 0, [Affinity.Type.REFUSEMANCER] as Array[Affinity.Type]))


# ---- The AI uses resources ---------------------------------------------------------------------


func test_the_ai_spends_leftover_energy_on_iron_to_grow_its_units() -> void:
	var game: GameState = _game()
	game.active = 0
	GameFactory.add_infrastructure_cards(game, 0, 2)
	var unit: CardInstance = _unit(game, 0, 2, 3)
	_give(game, 0, KIND.IRON, 2)
	var ai: AIPlayer = AIPlayer.new(AIPersonality.balanced())
	var guard: int = 0
	while game.phase == GameState.Phase.MAIN1 and guard < 10:
		guard += 1
		var action: GameAction = ai.choose_action(game)
		if action.type == GameAction.Type.PASS:
			break
		assert_true(game.apply_action(action))
	assert_gt(game.get_attack(unit), 2, "the AI used an Iron")


func test_the_ai_never_wastes_iron_after_combat_or_on_a_unit_that_cannot_attack() -> void:
	var game: GameState = _game()
	game.active = 0
	GameFactory.add_infrastructure_cards(game, 0, 2)
	var sick: CardInstance = _unit(game, 0, 2, 3)
	sick.summoning_sick = true
	_give(game, 0, KIND.IRON, 2)
	var ai: AIPlayer = AIPlayer.new(AIPersonality.balanced())
	var action: GameAction = ai.choose_action(game)
	assert_ne(action.type, GameAction.Type.USE_RESOURCE, "no Iron on a unit that cannot attack this turn")
	sick.summoning_sick = false
	game.advance_phase()
	game.advance_phase()
	assert_eq(game.phase, GameState.Phase.MAIN2)
	action = ai.choose_action(game)
	assert_ne(action.type, GameAction.Type.USE_RESOURCE, "no Iron after combat: it would end with the turn unused")


func test_the_ai_uses_red_tape_on_the_players_best_attacker_and_contract_on_a_blocker() -> void:
	var game: GameState = _game()
	GameFactory.add_infrastructure_cards(game, 0, 2, Affinity.Type.NECROCRAT)
	var mine: CardInstance = _unit(game, 0, 1, 1)
	var foe_unit: CardInstance = _unit(game, 1, 5, 5)
	_give(game, 0, KIND.RED_TAPE, 1)
	_give(game, 0, KIND.CONTRACT, 1)
	var ai: AIPlayer = AIPlayer.new(AIPersonality.balanced())
	var guard: int = 0
	while game.phase == GameState.Phase.MAIN1 and guard < 10:
		guard += 1
		var action: GameAction = ai.choose_action(game)
		if action.type == GameAction.Type.PASS:
			break
		game.apply_action(action)
	assert_true(game.get_attack(foe_unit) < 5 or foe_unit.exhausted, "the AI used a resource on the big enemy unit")
	assert_true(game.get_attack(mine) >= 1)


# ---- Contract is a token, not a resource ----------------------------------------------------------


func test_there_are_exactly_four_resources_and_contract_is_not_one() -> void:
	assert_eq(ResourceKind.all().size(), 4)
	assert_false(ResourceKind.all().has(KIND.CONTRACT))
	assert_false(ResourceKind.is_resource(KIND.CONTRACT))
	for kind: ResourceKind.Kind in ResourceKind.all():
		assert_true(ResourceKind.is_resource(kind))


func test_a_contract_lives_in_the_token_zone_and_is_a_non_unit_token() -> void:
	var game: GameState = _game()
	_give(game, 0, KIND.CONTRACT, 2)
	_give(game, 0, KIND.IRON, 1)
	assert_eq(game.players[0].tokens.size(), 2)
	assert_eq(game.players[0].resources.size(), 1, "Contracts are not in the resource zone")
	var contract: CardInstance = game.players[0].tokens[0]
	assert_eq(contract.data.type, CardEnums.CardType.TOKEN)
	assert_false(contract.data.is_resource())
	assert_true(contract.data.is_table_token())
	assert_true(contract.is_token())
	assert_eq(game.find_card(contract.uid), contract)
	assert_eq(game.resource_count(0, KIND.CONTRACT), 2)
	assert_eq(ResourceRules.of_player(game, 0).size(), 1, "of_player lists resources only")
