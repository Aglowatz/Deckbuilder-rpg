extends CardTestBase
## Fable Nov 25 (Part 6): the owner's card and dungeon changes (items 1 to 7 and 12).
##   First Pick peeks at 1. The Haunted Buffet costs 1 less and uses one Ingredient. Final Meal Request costs 1 less.
##   "Ratatouille, Rodent de Cuisine" is "Rodent De Cuisine". Vigor Mortis costs 1 more. Circle of Life Insurance costs 1 less.
##   Global Gains Platinum Membership: the keywords from the moment it is attached, only the buff at the start of each turn.
##   The Test Kitchen's Corrupted Pantry: the stew costs 5 HP.


func _card(id: String) -> CardData:
	var card: CardData = CardSet.card(id)
	assert_not_null(card, id)
	return card


func _sheet_row(id: String) -> PackedStringArray:
	var file: FileAccess = FileAccess.open("res://data/source/card_list.csv", FileAccess.READ)
	while file != null and not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() > 14 and row[14] == id:
			return row
	return PackedStringArray()


func test_first_pick_peeks_at_one_card() -> void:
	var card: CardData = _card("C-37")
	assert_eq(card.rules_text, "Peek 1, then draw a card.")
	assert_true(card.script_text.contains("peek(1)"))
	var game: GameState = _game()
	_energy(game)
	for i: int in range(5):
		game.players[0].deck.append(game.create_instance(GameFactory.vanilla(1, 1), 0))
	game.interactive_peek[0] = true  # the Peek waits for the player, so what it shows can be counted
	_play(game, "C-37")
	assert_eq(game.peek_cards().size(), 1, "one card is looked at (it was three)")


func test_the_haunted_buffet_is_cheaper_and_needs_one_ingredient() -> void:
	var card: CardData = _card("GN-07")
	assert_eq(card.energy_value(), 3, "1, a Gourmand and a Necrocrat energy (it was 2 and both)")
	assert_eq(_sheet_row("GN-07")[3], "1(G)(N)")
	assert_string_contains(card.rules_text, "Use an Ingredient:")
	var game: GameState = _game()
	_energy(game)
	var buffet: CardInstance = _field(game, 0, "GN-07")
	_give(game, 0, KIND.INGREDIENT, 1)
	assert_true(_activate(game, buffet), "one Ingredient is enough")
	assert_eq(_count(game, 0, KIND.INGREDIENT), 0, "it used one")
	assert_eq(_on_field(game, 0, "T-19").size(), 1, "a Hungry Ghost")


func test_three_costs_move() -> void:
	assert_eq(_card("GN-10").energy_value(), 2, "Final Meal Request: a Gourmand and a Necrocrat energy (it was 1 and both)")
	assert_eq(_sheet_row("GN-10")[3], "(G)(N)")
	assert_eq(_card("NB-03").energy_value(), 5, "Vigor Mortis: 3 and both (it was 2 and both)")
	assert_eq(_sheet_row("NB-03")[3], "3(N)(B)")
	assert_eq(_card("GRN-03").energy_value(), 4, "Circle of Life Insurance: 1 and three Paths (it was 2)")
	assert_eq(_sheet_row("GRN-03")[3], "1(G)(R)(N)")


func test_rodent_de_cuisine_is_renamed_everywhere() -> void:
	assert_eq(_card("GR-16").display_name, "Rodent De Cuisine")
	assert_eq(_sheet_row("GR-16")[2], "Rodent De Cuisine")
	# same id, so a save that owns it (by id) still loads it under the new name
	assert_eq(_card("GR-16").id, "GR-16")
	for path: String in ["res://data/source/card_list.csv", "res://data/scripts/cards_dual.txt", "res://data/cards/GR-16.tres",
			"res://data/glossary/glossary.json", "res://data/bestiary/bestiary.json", "res://data/quests/quests.json"]:
		if FileAccess.file_exists(path):
			assert_false(FileAccess.get_file_as_string(path).contains("Ratatouille"), "%s no longer says Ratatouille" % path)


func test_platinum_membership_gives_the_keywords_on_attach_and_buffs_each_turn() -> void:
	var card: CardData = _card("B-33")
	assert_string_contains(card.rules_text, "Attached unit has Hustle, Overtime and Bulldoze.")
	var game: GameState = _game()
	_energy(game)
	var unit: CardInstance = _unit(game, 0, 2, 2)
	unit.just_arrived = true  # it came down this turn
	var membership: CardInstance = _field(game, 0, "B-33")
	assert_true(_activate(game, membership, 0, [unit.uid] as Array[int]), "attach")
	for keyword: CardEnums.Keyword in [CardEnums.Keyword.HUSTLE, CardEnums.Keyword.OVERTIME, CardEnums.Keyword.BULLDOZE]:
		assert_true(game.unit_has_keyword(unit, keyword), "the keyword at once (%d)" % keyword)
	assert_eq(game.get_attack(unit), 2, "no buff yet: that comes at the start of the turn")
	game.advance_phase()
	assert_true(game.possible_attackers(0).has(unit), "with Hustle it can attack the turn it is attached")
	game.finish_combat()
	_until_turn_of(game, 0)
	assert_eq(game.get_attack(unit), 3, "the buff at the start of the next turn")
	assert_true(game.unit_has_keyword(unit, CardEnums.Keyword.BULLDOZE), "the keywords stay")
	# moved off the unit, the keywords go with the tool
	var other: CardInstance = _unit(game, 0, 1, 1)
	assert_true(_activate(game, membership, 0, [other.uid] as Array[int]), "attached again (pay 1)")
	assert_true(game.unit_has_keyword(other, CardEnums.Keyword.HUSTLE))
	assert_false(game.unit_has_keyword(unit, CardEnums.Keyword.HUSTLE), "the old unit loses them")


func test_the_corrupted_pantry_costs_five_hp() -> void:
	var event: Dictionary = (DungeonCatalog.content_for("D-TTK").get("events", {}) as Dictionary).get("7", {}) as Dictionary
	assert_eq(str(event.get("title", "")), "The Corrupted Pantry")
	var stew: Array = (event["choices"] as Array)[0] as Array
	assert_true(stew.has("damage:5"), "the stew: -5 HP (it was 2)")
	assert_false(stew.has("damage:2"))
	var outcome: DungeonEvent.Outcome = DungeonBuilder.event_outcome("damage:5", null)
	assert_not_null(outcome)
