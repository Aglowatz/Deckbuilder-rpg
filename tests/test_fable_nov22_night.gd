extends GutTest
## Fable Nov 22 night, Part 2: the owner's answers - nine item lines (six changes, three "no change"), Grand Bellows without "The Crowd
## Roars", Grandmaster Flex a 3/5 without Unbreakable wherever he is a unit, the Archivists' Kettle (the all-allies route's "heal 6 for a
## cost" stop) and the starting camera.

const A: Affinity.Type = Affinity.Type.BEEFCAKE


func _piece(id: String) -> EquipmentData:
	return Session.content.equipment_piece(id)


func _source(mods: Array[Modifier]) -> ModifierSource:
	return CardBuilder.modifier_source("Test Gear", ModifierSource.SourceKind.EQUIPMENT, mods)


func _game(p0_gear: Array[ModifierSource], p1_gear: Array[ModifierSource] = []) -> GameState:
	var options: GameOptions = GameOptions.new()
	options.rng_seed = 5
	var game: GameState = GameState.new(options)
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, p0_gear, "P0"))
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, p1_gear, "P1"))
	game.start()
	while game.stage == GameState.Stage.MULLIGAN:
		game.keep_hand(game.awaiting_player())
	for player: PlayerState in game.players:
		player.hand.clear()
	return game


func _mod_of(piece: EquipmentData, kind: Modifier.Kind) -> Modifier:
	for modifier: Modifier in piece.modifiers:
		if modifier.kind == kind:
			return modifier
	return null


# ---- Gladiator's Net -----------------------------------------------------------------------------------------------------------------


func test_the_gladiators_net_catches_only_the_first_enemy_unit_each_turn() -> void:
	var game: GameState = _game([_piece("gladiators_net")] as Array[ModifierSource])
	assert_true(_piece("gladiators_net").description.contains("first enemy unit"))
	GameFactory.add_infrastructure_cards(game, 1, 6, A)
	game.active = 1
	game.phase = GameState.Phase.MAIN1
	var first: CardInstance = GameFactory.add_to_hand(game, 1, GameFactory.vanilla(2, 2, 1))
	var second: CardInstance = GameFactory.add_to_hand(game, 1, GameFactory.vanilla(2, 2, 1))
	assert_true(game.play_card(1, first.uid))
	assert_true(game.play_card(1, second.uid))
	assert_eq([game.get_attack(first), game.get_defense(first)], [1, 1], "the first enemy unit of the turn gets -1/-1")
	assert_eq([game.get_attack(second), game.get_defense(second)], [2, 2], "the second one that turn is left alone")
	# a token that arrives later the same turn is left alone too (Primm's Militia, the Mimic's copies)
	var token: CardInstance = game.create_token(1, GameFactory.vanilla(1, 1, 0))
	assert_eq(game.get_defense(token), 1, "a 1-toughness token after the first unit survives")
	# the next turn (the net owner's own) it is ready again
	GameFactory.pass_turn(game)
	assert_false(game.players[0].enemy_enter_effect_done_this_turn, "ready again at the start of every turn")
	var late: CardInstance = game.create_token(1, GameFactory.vanilla(3, 3, 0))
	assert_eq([game.get_attack(late), game.get_defense(late)], [2, 2], "the first enemy unit of the next turn is caught again")


# ---- Siphon's Lens, Glass Jaw Gauntlets, Velvet Rope ------------------------------------------------------------------------------------


func test_siphons_lens_costs_two_max_hp() -> void:
	var lens: EquipmentData = _piece("siphons_lens")
	assert_eq(_mod_of(lens, Modifier.Kind.MAX_HP).value, -2, "max HP -2 (was +2)")
	assert_eq(_mod_of(lens, Modifier.Kind.EXTRA_DRAWS).value, 1, "the extra card stays")
	assert_true(lens.description.contains("Max HP -2"))
	assert_false(lens.description.contains("+2"))


func test_glass_jaw_gauntlets_cost_six_max_hp() -> void:
	var gauntlets: EquipmentData = _piece("glass_jaw_gauntlets")
	assert_eq(_mod_of(gauntlets, Modifier.Kind.MAX_HP).value, -6, "max HP -6 (was -3)")
	assert_eq(_mod_of(gauntlets, Modifier.Kind.STAT_CHANGE).value, 2, "+2 attack stays")
	var words: String = "%s %s" % [gauntlets.description, gauntlets.drawback]
	assert_true(words.contains("Max HP -6"), words)


func test_the_velvet_rope_gives_gourmand_units_one_two() -> void:
	var rope: EquipmentData = _piece("velvet_rope")
	var stat: Modifier = _mod_of(rope, Modifier.Kind.STAT_CHANGE)
	assert_eq([stat.value, stat.value2], [1, 2], "+1/+2 (was +0/+3)")
	assert_eq(stat.color, int(Affinity.Type.GOURMAND))
	assert_true(rope.description.contains("+1/+2"))


func test_the_three_no_change_lines_stay_as_they_were() -> void:
	# Clipwell's Golden Shears stay at 2, the Bloodsand Boots still draw on every hit, the Elastic Waistband is untouched
	assert_true(_piece("bloodsand_boots").description.contains("Whenever you are dealt damage, draw a card"))
	var shears: EquipmentData = _piece("clipwells_shears")
	var waistband: EquipmentData = _piece("elastic_waistband")
	assert_not_null(shears)
	assert_not_null(waistband)
	assert_true(shears.description.contains("2 damage"), shears.description)
	assert_true(waistband.description.contains("+1/+1"), waistband.description)


# ---- Dex's Matching Pair ---------------------------------------------------------------------------------------------------------------


func _pair_player(game: GameState) -> PlayerState:
	var player: PlayerState = PlayerState.new()
	game.players = [player, PlayerState.new()]
	player.modifiers.add_source(_piece(CardMatchCircuit.PRIZE_ID))
	return player


func test_the_matching_pair_copies_only_a_card_that_costs_three_or_less() -> void:
	var pair: EquipmentData = _piece(CardMatchCircuit.PRIZE_ID)
	assert_eq(_mod_of(pair, Modifier.Kind.DRAW_COPY_FIRST_PLAY).value2, 3)
	assert_true(pair.description.contains("costs 3 or less"), pair.description)
	var cheap: CardData = GameFactory.vanilla(2, 2, 3)
	var dear: CardData = GameFactory.vanilla(5, 5, 4)
	var game: GameState = GameState.new()
	var player: PlayerState = _pair_player(game)
	player.deck.append(game.create_instance(cheap, 0))
	game._echo_first_play(0, game.create_instance(cheap, 0))
	assert_eq(player.hand.size(), 1, "a 3-cost first card draws its copy")
	var game2: GameState = GameState.new()
	var player2: PlayerState = _pair_player(game2)
	player2.deck.append(game2.create_instance(dear, 0))
	player2.deck.append(game2.create_instance(cheap, 0))
	game2._echo_first_play(0, game2.create_instance(dear, 0))
	assert_eq(player2.hand.size(), 0, "a 4-cost first card is not copied")
	game2._echo_first_play(0, game2.create_instance(cheap, 0))
	assert_eq(player2.hand.size(), 0, "and it used the turn's chance up: only the FIRST card counts")


# ---- Hover Boots --------------------------------------------------------------------------------------------------------------------------


func test_hover_boots_units_can_still_block_units_with_flying() -> void:
	assert_true(_piece("hover_boots").description.contains("can block only units with Flying"))
	var flying: Array[CardEnums.Keyword] = [CardEnums.Keyword.FLYING]
	var game: GameState = _game([] as Array[ModifierSource], [_piece("hover_boots")] as Array[ModifierSource])
	var walker: CardInstance = GameFactory.add_to_field(game, 0, GameFactory.vanilla(2, 2))
	var flyer: CardInstance = GameFactory.add_to_field(game, 0, GameFactory.vanilla(2, 2, 1, A, flying))
	GameFactory.add_infrastructure_cards(game, 1, 2, A)
	var booted_card: CardInstance = GameFactory.add_to_hand(game, 1, GameFactory.vanilla(3, 3))
	GameFactory.pass_turn(game)
	assert_true(game.play_card(1, booted_card.uid))
	var booted: CardInstance = game.players[1].find_field(booted_card.uid)
	assert_true(booted.has_keyword(CardEnums.Keyword.FLYING), "the boots still give Flying")
	assert_true(CombatResolver.can_block(game, flyer, booted), "it can block a unit with Flying")
	assert_false(CombatResolver.can_block(game, walker, booted), "it still cannot block a unit on the ground")
	GameFactory.pass_turn(game)
	walker.just_arrived = false
	flyer.just_arrived = false
	game.advance_phase()
	assert_true(game.declare_attackers([walker.uid, flyer.uid] as Array[int]))
	assert_true(CombatResolver.possible_blockers(game, 1).has(booted), "a flyer attacks: it is offered as a blocker")
	assert_false(game.declare_blockers({walker.uid: booted.uid}), "not against the walker")
	assert_true(game.declare_blockers({flyer.uid: booted.uid}), "against the flyer")


func test_hover_boots_units_are_no_blockers_when_nothing_flies() -> void:
	var game: GameState = _game([] as Array[ModifierSource], [_piece("hover_boots")] as Array[ModifierSource])
	var walker: CardInstance = GameFactory.add_to_field(game, 0, GameFactory.vanilla(2, 2))
	GameFactory.add_infrastructure_cards(game, 1, 2, A)
	var booted_card: CardInstance = GameFactory.add_to_hand(game, 1, GameFactory.vanilla(3, 3))
	GameFactory.pass_turn(game)
	assert_true(game.play_card(1, booted_card.uid))
	GameFactory.pass_turn(game)
	walker.just_arrived = false
	game.advance_phase()
	assert_true(game.declare_attackers([walker.uid] as Array[int]))
	assert_true(CombatResolver.possible_blockers(game, 1).is_empty(), "only walkers attack: no blocker is offered")


# ---- Grand Bellows -----------------------------------------------------------------------------------------------------------------------


func test_grand_bellows_keeps_64_hp_and_loses_the_crowd_roars() -> void:
	assert_eq(ArenaDefs.find("arena_marshal").enemy_hp, 64)
	var names: Array[String] = []
	for rule: EncounterModifiers.Rule in EncounterModifiers.rules("arena:arena_marshal"):
		names.append(rule.name)
	assert_true(names.has("Crowd Favourite"), "his +2/+1 stays")
	assert_false(names.has("The Crowd Roars"), "the extra +1/+1 is off again")


# ---- Grandmaster Flex --------------------------------------------------------------------------------------------------------------------


func test_flex_is_a_three_five_without_unbreakable_wherever_he_is_a_unit() -> void:
	# his two appearances as a unit: the House of Gains ally (T-15) and the castle ally on turn 2 (the same token, re-dressed)
	var house: CardData = TokenRegistry.data(HouseOfGainsDungeon.ALLY_TOKEN_ID)
	var castle: CardData = CastleAllies.flex_token()
	for flex: CardData in [house, castle]:
		assert_eq([flex.attack, flex.defense], [3, 5], flex.display_name)
		assert_false(flex.keywords.has(CardEnums.Keyword.UNBREAKABLE), "no Unbreakable (Indestructible)")
	assert_eq(HouseOfGainsDungeon.ALLY_TOKEN_ID, CastleAllies.FLEX_TOKEN, "one Flex token in the game")
	# no card, token or foe deck puts another Flex on the board
	for token_id: Variant in Session.content.tokens.keys():
		var token: CardData = Session.content.tokens[token_id] as CardData
		if token.display_name.contains("Grandmaster Flex"):
			assert_eq(str(token_id), CastleAllies.FLEX_TOKEN)
	for card: CardData in Session.content.cards.values():
		assert_false(card.display_name.contains("Grandmaster Flex"), card.display_name)
	# in a fight he can be destroyed like any unit
	var game: GameState = _game([] as Array[ModifierSource])
	var ally: CardInstance = game.create_token(0, castle)
	assert_false(game.unit_has_keyword(ally, CardEnums.Keyword.UNBREAKABLE))


# ---- The Archivists' Kettle (the all-allies route's heal) ------------------------------------------------------------------------------


func test_the_all_allies_route_has_one_heal_six_for_a_cost_stop_in_its_fourth_row() -> void:
	MainDungeons.reset()
	var def: MainDungeonDef = MainDungeons.def(PrimmsCastleDungeon.ZONE_ID)
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.find("D-PC")
	# the fourth row of the castle is rooms 11 to 13; the all-allies route passes through 11 (Agnes), which is where the kettle is
	assert_eq(CastleAllies.REST_ROOM, 11)
	assert_eq(CastleAllies.zone_of_room(CastleAllies.DUNGEON_KEY, CastleAllies.REST_ROOM), "necrocrat")
	# all four in one run is still possible: 2 -> 4 or 5 -> 8 -> 11 -> 14
	assert_true(plan.node(2).next.has(5) and plan.node(5).next.has(8) and plan.node(8).next.has(11) and plan.node(11).next.has(14))
	var kettle: DungeonEvent = def.event(CastleAllies.REST_EVENT)
	assert_not_null(kettle)
	assert_eq(kettle.choices.size(), 3, "pay, take the drawback, or walk on (the Garden's rules)")
	var garden: DungeonEvent = def.event(DungeonBuilder.event_id_of(plan, 7))
	assert_not_null(garden)
	for index: int in range(3):
		var kinds: Array[int] = []
		var garden_kinds: Array[int] = []
		for outcome: DungeonEvent.Outcome in kettle.choices[index].outcomes:
			kinds.append(int(outcome.kind))
			if outcome.kind == DungeonEvent.OutcomeKind.HEAL:
				assert_eq(outcome.amount, 6, "heal 6")
			if outcome.kind == DungeonEvent.OutcomeKind.PAY_GOLD:
				assert_eq(outcome.amount, 60, "the Garden's price")
		for outcome: DungeonEvent.Outcome in garden.choices[index].outcomes:
			garden_kinds.append(int(outcome.kind))
		assert_eq(kinds, garden_kinds, "choice %d works like the Garden's" % index)
	# the route still has no other heal and one treasure room
	var heals: int = 0
	for number: int in [2, 5, 8, 11, 14, 18]:
		if plan.node(number).type == "heal":
			heals += 1
	assert_eq(heals, 0, "no heal ROOM on the route: it still skips the heals and most treasure")
	# the map says so before the fight
	assert_true(CastleAllies.room_lines({}, null, CastleAllies.DUNGEON_KEY, CastleAllies.REST_ROOM).has(CastleAllies.REST_LINE))
	assert_false(CastleAllies.room_lines({}, null, CastleAllies.DUNGEON_KEY, 8).has(CastleAllies.REST_LINE))


# ---- The camera ---------------------------------------------------------------------------------------------------------------------------


func test_a_new_game_starts_on_the_plus_six_camera() -> void:
	var sheet: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/camera/zone_camera.json")) as Dictionary
	assert_true(str(sheet["_about"]).contains("Fable Nov 22 night"), "the owner's answer is recorded in the sheet")
	var places: Dictionary = sheet["places"] as Dictionary
	assert_gt(places.size(), 0)
	for key: Variant in places.keys():
		assert_eq(float((places[key] as Dictionary)["pitch_bonus"]), 6.0, "%s starts at +6" % str(key))
