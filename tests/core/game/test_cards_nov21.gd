extends CardTestBase
## Fable Nov 21, Part 2: the owner's card changes. The sacrifice-for-damage cards on the rules engine and in the AI's hands (the battle
## screen's half is tests/ui/test_sacrifice_damage_targets_nov21.gd), Overdue Library Book, four cheaper cards and To Die For.


func _ai() -> AIPlayer:
	var personality: AIPersonality = AIPersonality.balanced()
	personality.skill = 1
	var ai: AIPlayer = AIPlayer.new(personality)
	ai.deterministic = true
	return ai


func _piece(id: String) -> EquipmentData:
	return ProgressionContent.zone_equipment()[id] as EquipmentData


# ---- 2.1 sacrifice a unit to deal damage ------------------------------------------------------------------------------------------


func test_dead_weight_can_target_and_damage_the_opponent() -> void:
	var game: GameState = _game()
	_energy(game)
	var mine: CardInstance = _unit(game, 0, 5, 2)
	var card: CardInstance = GameFactory.add_to_hand(game, 0, CardSet.card("NB-04"))
	assert_has(game.legal_play_targets(0, card.uid, 0), Targets.player(1), "the opponent is a legal target")
	var hp: int = game.players[1].hp
	assert_true(game.play_card(0, card.uid, Targets.player(1)))
	assert_eq(game.players[1].hp, hp - 5, "the destroyed unit's attack")
	assert_false(game.players[0].field.has(mine))


func test_dead_weight_can_target_a_unit_too() -> void:
	var game: GameState = _game()
	_energy(game)
	_unit(game, 0, 3, 3)
	var victim: CardInstance = _unit(game, 1, 2, 6)
	_play(game, "NB-04", [victim.uid] as Array[int])
	assert_eq(victim.damage, 3)


func test_dead_weight_destroys_the_picked_unit_not_the_cheapest() -> void:
	var game: GameState = _game()
	_energy(game)
	var big: CardInstance = _unit(game, 0, 6, 6)
	var small: CardInstance = _unit(game, 0, 1, 1)
	var card: CardInstance = GameFactory.add_to_hand(game, 0, CardSet.card("NB-04"))
	var hp: int = game.players[1].hp
	assert_true(game.play_card(0, card.uid, Targets.player(1), [] as Array[int], [] as Array[int], [big.uid] as Array[int]))
	assert_eq(game.players[1].hp, hp - 6)
	assert_true(game.players[0].field.has(small))


func test_yeet_can_target_and_damage_the_opponent() -> void:
	var game: GameState = _game()
	_energy(game)
	var thrown: CardInstance = _unit(game, 0, 4, 4)
	var card: CardInstance = GameFactory.add_to_hand(game, 0, CardSet.card("B-25"))
	assert_has(game.legal_play_targets(0, card.uid, 1), Targets.player(1), "the opponent is a legal second target")
	var hp: int = game.players[1].hp
	assert_true(game.play_card(0, card.uid, thrown.uid, [] as Array[int], [Targets.player(1)] as Array[int]))
	assert_eq(game.players[1].hp, hp - 4)
	assert_false(game.players[0].field.has(thrown))


func test_hammer_thrower_can_target_and_damage_the_opponent() -> void:
	var game: GameState = _game()
	_energy(game)
	var thrower: CardInstance = _field(game, 0, "B-34")
	thrower.exhausted = false
	var hp: int = game.players[1].hp
	var attack: int = game.get_attack(thrower)
	assert_gt(attack, 0)
	assert_true(_activate(game, thrower, 0, [Targets.player(1)] as Array[int]))
	assert_eq(game.players[1].hp, hp - attack)


func test_sir_loin_can_aim_his_entrance_at_the_opponent() -> void:
	var game: GameState = _game()
	_energy(game)
	_give(game, 0, KIND.INGREDIENT, 2)
	var hp: int = game.players[1].hp
	_play(game, "GB-13", [Targets.player(1)] as Array[int])
	assert_lt(game.players[1].hp, hp, "2 damage for each Ingredient used")


func test_the_ai_finishes_the_opponent_with_dead_weight() -> void:
	var game: GameState = _game()
	_energy(game)
	_unit(game, 0, 4, 4).exhausted = true
	_unit(game, 1, 0, 9)
	game.players[1].hp = 4
	GameFactory.add_to_hand(game, 0, CardSet.card("NB-04"))
	var action: GameAction = _ai().choose_action(game)
	assert_eq(action.type, GameAction.Type.PLAY, "it plays Dead Weight")
	assert_has(action.targets, Targets.player(1), "at the opponent")
	assert_true(game.apply_action(action))
	assert_true(game.is_over())
	assert_eq(game.winner, 0)


func test_the_ai_finishes_the_opponent_with_yeet() -> void:
	var game: GameState = _game()
	_energy(game)
	_unit(game, 0, 4, 4).exhausted = true
	_unit(game, 1, 0, 9)
	game.players[1].hp = 4
	GameFactory.add_to_hand(game, 0, CardSet.card("B-25"))
	var action: GameAction = _ai().choose_action(game)
	assert_eq(action.type, GameAction.Type.PLAY, "it plays Yeet")
	assert_has(action.targets, Targets.player(1), "at the opponent")
	assert_true(game.apply_action(action))
	assert_true(game.is_over())


# ---- 2.2 Overdue Library Book -----------------------------------------------------------------------------------------------------


func test_overdue_library_book_draws_one_extra_card_and_discards_one_at_random() -> void:
	var book: EquipmentData = _piece("overdue_library_book")
	assert_eq(book.description, "Draw 1 extra card each turn. Then discard 1 card at random.")
	var draws: int = 0
	var tosses: int = 0
	for modifier: Modifier in book.modifiers:
		if modifier.kind == Modifier.Kind.EXTRA_DRAWS:
			draws += modifier.value
		if modifier.kind == Modifier.Kind.START_OF_TURN_EFFECT and modifier.effect != null and modifier.effect.op == CardEnums.EffectOp.TOSS:
			tosses += modifier.effect.amount
	assert_eq(draws, 1, "one extra card (was two)")
	assert_eq(tosses, 1, "one card discarded")


func test_overdue_library_book_nets_the_normal_hand_each_turn() -> void:
	CardSet.load_all()
	var setup: PlayerSetup = PlayerSetup.create(GameFactory.make_deck(), PlayerProfile.new(), [_piece("overdue_library_book")] as Array[ModifierSource], "Player")
	var game: GameState = GameState.new()
	game.options.rng_seed = 5
	game.options.free_mulligan = false
	game.options.first_player = 1
	game.add_player(setup)
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [] as Array[ModifierSource], "Foe"))
	game.start()
	while game.awaiting_player() != 0 or not game.in_main_phase():
		if game.is_over():
			break
		GameFactory.pass_turn(game)
	var hand: int = game.players[0].hand.size()
	var refuse: int = game.players[0].refuse_pile.size()
	_until_turn_of(game, 0)
	assert_eq(game.players[0].hand.size(), hand + 1, "two cards drawn, one discarded: one more card than before")
	assert_eq(game.players[0].refuse_pile.size(), refuse + 1, "the discarded card is in the Refuse Pile")


# ---- 2.3 costs ---------------------------------------------------------------------------------------------------------------------


func _cost(id: String) -> Array:
	var card: CardData = CardSet.card(id)
	var pips: Array = []
	for pip: Affinity.Type in card.colored_pips:
		pips.append(pip)
	pips.sort()
	return [card.generic_cost, pips]


func test_soul_food_kitchen_costs_two_one_necrocrat_one_gourmand() -> void:
	CardSet.load_all()
	var want: Array = [Affinity.Type.GOURMAND, Affinity.Type.NECROCRAT]
	want.sort()
	assert_eq(_cost("GN-06"), [0, want])
	assert_eq(CardSet.card("GN-06").energy_value(), 2)


func test_food_fight_costs_two_one_gourmand_one_refusemancer() -> void:
	CardSet.load_all()
	var want: Array = [Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER]
	want.sort()
	assert_eq(_cost("GR-04"), [0, want])
	assert_eq(CardSet.card("GR-04").energy_value(), 2)


func test_community_garden_costs_one_pathless_less() -> void:
	CardSet.load_all()
	assert_eq(CardSet.card("GR-07").generic_cost, 1, "was 2")
	assert_eq(CardSet.card("GR-07").energy_value(), 3)


func test_un_deadlifter_costs_one_pathless_less() -> void:
	CardSet.load_all()
	assert_eq(CardSet.card("NB-02").generic_cost, 1, "was 2")
	assert_eq(CardSet.card("NB-02").energy_value(), 3)
	assert_eq([CardSet.card("NB-02").attack, CardSet.card("NB-02").defense], [3, 2], "the body is unchanged")


# ---- 2.4 To Die For ----------------------------------------------------------------------------------------------------------------


func test_to_die_for_destroys_any_unit() -> void:
	var game: GameState = _game()
	_energy(game)
	var big: CardInstance = _unit(game, 1, 7, 9)
	assert_eq(CardSet.card("GN-09").rules_text, "Destroy target unit. Create two Ingredients.")
	_play(game, "GN-09", [big.uid] as Array[int])
	assert_false(game.players[1].field.has(big), "defense 9: no limit any more")
	assert_eq(_count(game, 0, KIND.INGREDIENT), 2)
