extends GutTest
## The dungeon list's buffs and debuffs run through the Modifier pipeline: every rule is active and each one changes the game the way the sheet says.

const NO_PIPS: Array[Affinity.Type] = []


## A started game (empty hands) where both players carry the shared rules of the dungeon `key`.
func _game_in(key: String, node_number: int = 0) -> GameState:
	var options: GameOptions = GameOptions.new()
	options.rng_seed = 3
	var game: GameState = GameState.new(options)
	var extra: Array[ModifierSource] = [] as Array[ModifierSource]
	var source: ModifierSource = DungeonRules.shared_source(key, node_number)
	if source != null:
		extra.append(source)
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, extra, "P0"))
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, extra, "P1"))
	game.start()
	while game.stage == GameState.Stage.MULLIGAN:
		game.keep_hand(game.awaiting_player())
	for player: PlayerState in game.players:
		player.hand.clear()
	return game


func _unit(game: GameState, owner: int, attack: int, defense: int, keywords: Array[CardEnums.Keyword] = []) -> CardInstance:
	return GameFactory.add_to_field(game, owner, GameFactory.vanilla(attack, defense, 1, Affinity.Type.BEEFCAKE, keywords), true)


func test_every_rule_in_the_dungeon_list_is_enforced() -> void:
	var names: Array[String] = []
	for plan: DungeonCatalog.Blueprint in DungeonCatalog.all():
		for rule: Dictionary in DungeonRules.rules(plan.zone_id if not plan.is_side() else plan.id):
			names.append(str(rule["name"]))
			assert_true(bool(rule["active"]), "%s: %s is enforced" % [plan.id, rule["name"]])
	assert_gte(names.size(), 16, "all the sheet's rules were listed")


func test_rot_destroys_units_with_one_defense_at_end_of_turn() -> void:
	var game: GameState = _game_in("refusemancer")
	var frail: CardInstance = _unit(game, 0, 3, 1)
	var sturdy: CardInstance = _unit(game, 0, 1, 3)
	var enemy_frail: CardInstance = _unit(game, 1, 1, 1)
	GameFactory.pass_turn(game)
	assert_null(game.find_permanent(frail.uid), "a 1-defense unit rots away")
	assert_null(game.find_permanent(enemy_frail.uid), "on both sides")
	assert_not_null(game.find_permanent(sturdy.uid), "a 3-defense unit stays")


func test_overgrowth_buffs_every_unit_at_the_start_of_each_turn() -> void:
	var game: GameState = _game_in("refusemancer")
	var mine: CardInstance = _unit(game, 0, 2, 4)
	var theirs: CardInstance = _unit(game, 1, 2, 4)
	var before: int = game.get_attack(mine)
	GameFactory.pass_turn(game)
	assert_eq(game.get_attack(mine), before + 1, "turn start: your unit grew")
	assert_eq(game.get_attack(theirs), before + 1, "the enemy's unit grew too")


func test_perfect_order_caps_a_unit_at_two_keywords() -> void:
	var game: GameState = _game_in("final")
	var busy: CardInstance = _unit(game, 0, 2, 2, [CardEnums.Keyword.FLYING, CardEnums.Keyword.SWAT, CardEnums.Keyword.HUSTLE] as Array[CardEnums.Keyword])
	assert_true(game.unit_has_keyword(busy, CardEnums.Keyword.FLYING))
	assert_true(game.unit_has_keyword(busy, CardEnums.Keyword.SWAT))
	assert_false(game.unit_has_keyword(busy, CardEnums.Keyword.HUSTLE), "the third keyword does not count")
	var plain: CardInstance = _unit(game, 0, 2, 2, [CardEnums.Keyword.FLYING, CardEnums.Keyword.SWAT] as Array[CardEnums.Keyword])
	game.grant_keyword(plain, CardEnums.Keyword.ELUSIVE, false)
	assert_false(game.unit_has_keyword(plain, CardEnums.Keyword.ELUSIVE), "a granted keyword is refused at the cap")
	var open: CardInstance = _unit(game, 0, 2, 2, [CardEnums.Keyword.FLYING] as Array[CardEnums.Keyword])
	game.grant_keyword(open, CardEnums.Keyword.ELUSIVE, false)
	assert_true(game.unit_has_keyword(open, CardEnums.Keyword.ELUSIVE), "below the cap a keyword can still be granted")


func test_mirrors_copies_only_the_first_card_each_player_plays() -> void:
	var game: GameState = _game_in("final")
	GameFactory.add_infrastructure_cards(game, 0, 4)
	var first: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(1, 1, 1))
	var second: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(2, 2, 1))
	var before: int = game.players[1].hand.size()
	assert_true(game.play_card(0, first.uid))
	assert_eq(game.players[1].hand.size(), before + 1, "the opponent gets a copy of the first card")
	assert_eq(game.players[1].hand[game.players[1].hand.size() - 1].data.id, first.data.id)
	assert_true(game.play_card(0, second.uid))
	assert_eq(game.players[1].hand.size(), before + 1, "but not of the second")


func test_processing_time_taxes_only_the_first_spell_each_turn() -> void:
	var game: GameState = _game_in("necrocrat")
	GameFactory.add_infrastructure_cards(game, 0, 6)
	var spell: CardData = CardBuilder.spell("tax_spell", "Tax Spell", Affinity.Type.BEEFCAKE, 1, NO_PIPS)
	assert_eq(game.generic_cost_for(0, spell), 2, "first spell: 1 more")
	var first: CardInstance = GameFactory.add_to_hand(game, 0, spell)
	assert_true(game.play_card(0, first.uid))
	assert_eq(game.generic_cost_for(0, spell), 1, "second spell: normal cost")
	var unit_card: CardData = GameFactory.vanilla(1, 1, 1)
	assert_eq(game.generic_cost_for(0, unit_card), 1, "units are never taxed")
	GameFactory.pass_turn(game)
	GameFactory.pass_turn(game)
	assert_eq(game.generic_cost_for(0, spell), 2, "the tax is back next turn")


func test_thin_air_gives_hustle_units_plus_one_attack() -> void:
	var game: GameState = _game_in("S-BEEF")
	var hasty: CardInstance = _unit(game, 0, 2, 2, [CardEnums.Keyword.HUSTLE] as Array[CardEnums.Keyword])
	var slow: CardInstance = _unit(game, 0, 2, 2)
	assert_eq(game.get_attack(hasty), 3)
	assert_eq(game.get_attack(slow), 2)


func test_fresh_fish_tokens_enter_bigger() -> void:
	var game: GameState = _game_in("S-GOUR")
	var token: CardInstance = game.create_token(0, CardBuilder.token("fish", "Fish", 1, 1))
	assert_eq(game.get_attack(token), 2)
	assert_eq(game.get_defense(token), 2)
	var plain: CardInstance = _unit(game, 0, 1, 1)
	assert_eq(game.get_attack(plain), 1, "only tokens")


func test_midnight_snack_pays_back_the_hp_of_eating_garbage() -> void:
	var with_rule: GameState = _game_in("S-REF")
	var without: GameState = GameFactory.blank_game(3)
	for game: GameState in [with_rule, without]:
		GameFactory.add_infrastructure_cards(game, 0, 2)
		ResourceRules.create(game, 0, ResourceKind.Kind.GARBAGE, 1)
		game.players[0].hp = 5
	var hp_with: int = with_rule.players[0].hp
	var hp_without: int = without.players[0].hp
	assert_true(ResourceRules.eat(with_rule, 0))
	assert_true(ResourceRules.eat(without, 0))
	assert_eq(without.players[0].hp, hp_without, "eating costs no HP since the Oct 18 rebalance")
	assert_eq(with_rule.players[0].hp, hp_with + 1, "in the raccoon kingdom the snack still heals 1")


func test_forgotten_harmony_makes_multipath_cards_cheaper() -> void:
	var game: GameState = _game_in("S-CAP")
	var multi: CardData = GameFactory.vanilla(2, 2, 3)
	multi.color2 = Affinity.Type.GOURMAND
	assert_true(multi.is_multipath())
	assert_eq(game.generic_cost_for(0, multi), 2)
	var mono: CardData = GameFactory.vanilla(2, 2, 3)
	assert_eq(game.generic_cost_for(0, mono), 3)
	var cheap: CardData = GameFactory.vanilla(1, 1, 0)
	cheap.color2 = Affinity.Type.GOURMAND
	assert_eq(game.generic_cost_for(0, cheap), 0, "never below 0")


func test_the_prison_blocks_iron_only_on_nodes_8_and_9() -> void:
	for node_number: int in [8, 9]:
		var game: GameState = _game_in("beefcake", node_number)
		GameFactory.add_infrastructure_cards(game, 0, 3)
		var unit: CardInstance = _unit(game, 0, 2, 2)
		ResourceRules.create(game, 0, ResourceKind.Kind.IRON, 1)
		assert_false(ResourceRules.can_use_ability(game, 0, ResourceKind.Kind.IRON, unit.uid), "node %d: Iron cannot be used" % node_number)
		assert_false(ResourceRules.use(game, 0, ResourceKind.Kind.IRON, 1), "node %d: Iron cannot be spent" % node_number)
	var elsewhere: GameState = _game_in("beefcake", 7)
	GameFactory.add_infrastructure_cards(elsewhere, 0, 3)
	var other: CardInstance = _unit(elsewhere, 0, 2, 2)
	ResourceRules.create(elsewhere, 0, ResourceKind.Kind.IRON, 1)
	assert_true(ResourceRules.can_use_ability(elsewhere, 0, ResourceKind.Kind.IRON, other.uid), "node 7: Iron works")


func test_experimental_gives_each_side_a_random_keyword_on_its_first_unit() -> void:
	var game: GameState = _game_in("gourmand")
	var mine: CardInstance = game.create_token(0, CardBuilder.token("exp_a", "A", 1, 1))
	var theirs: CardInstance = game.create_token(1, CardBuilder.token("exp_b", "B", 1, 1))
	assert_eq(mine.granted_keywords.size(), 1, "your first unit gained a keyword")
	assert_eq(theirs.granted_keywords.size(), 1, "so did theirs")
	var later: CardInstance = game.create_token(0, CardBuilder.token("exp_c", "C", 1, 1))
	assert_eq(later.granted_keywords.size(), 0, "only the first")


func test_corrupted_food_still_heals_one_less() -> void:
	var game: GameState = _game_in("gourmand")
	game.players[0].hp = 5
	game.gain_hp(0, 3)
	assert_eq(game.players[0].hp, 7, "3 healing heals 2: Corrupted Food")


func test_a_dungeon_without_extra_rules_changes_nothing() -> void:
	assert_null(DungeonRules.shared_source("hollow"))
