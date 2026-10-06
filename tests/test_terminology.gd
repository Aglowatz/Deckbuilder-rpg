extends GutTest
## Brief 14, Part A: the Design Guidance terms are what the engine and the UI actually use.


func test_keyword_names_match_the_design_guidance() -> void:
	var expected: Dictionary = {
		CardEnums.Keyword.FLYING: "Flying",
		CardEnums.Keyword.SWAT: "Swat",
		CardEnums.Keyword.HUSTLE: "Hustle",
		CardEnums.Keyword.BULLDOZE: "Bulldoze",
		CardEnums.Keyword.SUCKER_PUNCH: "Sucker Punch",
		CardEnums.Keyword.ONE_TWO_PUNCH: "One-Two Punch",
		CardEnums.Keyword.TOXIC: "Toxic",
		CardEnums.Keyword.NOURISH: "Nourish",
		CardEnums.Keyword.OVERTIME: "Overtime",
		CardEnums.Keyword.WALLFLOWER: "Wallflower",
		CardEnums.Keyword.ELUSIVE: "Elusive",
		CardEnums.Keyword.UNTOUCHABLE: "Untouchable",
		CardEnums.Keyword.UNBREAKABLE: "Unbreakable",
	}
	for keyword: Variant in expected.keys():
		assert_eq(KeywordInfo.keyword_name(int(keyword) as CardEnums.Keyword), str(expected[keyword]))
	assert_eq(CardEnums.Keyword.size(), expected.size(), "no keyword outside the Design Guidance list (and no Guard)")


func test_old_keyword_names_are_gone() -> void:
	for old_name: String in ["GUARD", "VIGILANCE", "HASTE", "TRAMPLE", "FIRST_STRIKE", "LIFESTEAL", "REACH", "DEFENDER"]:
		assert_false(CardEnums.Keyword.keys().has(old_name), "%s was renamed or removed" % old_name)


func test_card_types_match_the_design_guidance() -> void:
	for type_name: String in ["INFRASTRUCTURE", "UNIT", "SPELL", "TRAP", "TOOL", "WONDER", "RESOURCE", "TOKEN"]:
		assert_true(CardEnums.CardType.keys().has(type_name), "card type %s exists" % type_name)
	assert_false(CardEnums.CardType.keys().has("CREATURE"))
	assert_false(CardEnums.CardType.keys().has("ARTIFACT"))


func test_path_names_and_energy_symbols() -> void:
	assert_eq(Affinity.display_name(Affinity.Type.BEEFCAKE), "Beefcake")
	assert_eq(Affinity.display_name(Affinity.Type.NECROCRAT), "Necrocrat")
	assert_eq(Affinity.display_name(Affinity.Type.GOURMAND), "Gourmand")
	assert_eq(Affinity.display_name(Affinity.Type.REFUSEMANCER), "Refusemancer")
	assert_eq(Affinity.symbol(Affinity.Type.BEEFCAKE), "B")
	assert_eq(Affinity.symbol(Affinity.Type.NECROCRAT), "N")
	assert_eq(Affinity.symbol(Affinity.Type.GOURMAND), "G")
	assert_eq(Affinity.symbol(Affinity.Type.REFUSEMANCER), "R")
	assert_eq(Affinity.from_symbol("g"), Affinity.Type.GOURMAND)
	assert_eq(Affinity.from_symbol(""), Affinity.Type.NEUTRAL)


func test_attackers_always_attack_the_player() -> void:
	var game: GameState = GameFactory.blank_game()
	var attacker: CardInstance = GameFactory.add_to_field(game, 0, GameFactory.vanilla(2, 2))
	GameFactory.add_to_field(game, 1, GameFactory.vanilla(0, 5, 1))
	game.advance_phase()
	assert_true(game.declare_attackers([attacker.uid] as Array[int]))
	game.declare_blockers({})
	assert_eq(game.players[1].hp, 8, "an unblocked attacker hits the player, whatever else is on the field")


func test_player_state_uses_the_new_zone_names() -> void:
	var player: PlayerState = PlayerState.new()
	assert_true("deck" in player and "field" in player and "refuse_pile" in player and "hp" in player)
	assert_false("library" in player)
	assert_false("graveyard" in player)
	assert_false("battlefield" in player)
