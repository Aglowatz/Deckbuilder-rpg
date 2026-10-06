extends GutTest
## Part A: lands -> infrastructure, energy -> energy, tap/untap -> activate/ready (units:
## exhausted), the flat 4-copy limit, and the save format version.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()


func test_basic_infrastructure_is_named_and_worded_with_the_new_terms() -> void:
	var infra: CardData = CardBuilder.infra(Affinity.Type.BEEFCAKE)
	assert_true(infra.is_infrastructure())
	assert_true(infra.is_unlimited())
	assert_eq(infra.id, "infrastructure_beefcake")
	assert_true(infra.display_name.ends_with("Infrastructure"))
	for content_infra: Variant in Session.content.infrastructure.values():
		var card: CardData = content_infra as CardData
		if card.color == Affinity.Type.NEUTRAL:
			continue
		assert_true(card.rules_text.begins_with("Activate:"), "%s tells the player to activate it" % card.id)
		assert_true(card.rules_text.contains("energy"), "%s makes energy" % card.id)
		assert_false(card.rules_text.to_lower().contains("mana"))


func test_casting_activates_infrastructure_and_attacking_exhausts_units() -> void:
	var game: GameState = GameFactory.new_game()
	GameFactory.add_infrastructure_cards(game, 0, 2)
	var spell: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(1, 1, 2))
	assert_eq(game.players[0].ready_infrastructure().size(), 2)
	assert_true(game.play_card(0, spell.uid))
	assert_eq(game.players[0].ready_infrastructure().size(), 0, "paying activated both infrastructure")
	assert_true(game.players[0].infrastructure[0].exhausted)


func test_keyword_text_uses_exhausted_not_tapped() -> void:
	var text: String = str(KeywordInfo.KEYWORD_TEXT[CardEnums.Keyword.OVERTIME])
	assert_false(text.to_lower().contains("tapped"))
	assert_true(text.contains("exhaust"))


func test_every_non_infrastructure_card_allows_four_copies_at_level_one() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	for rarity: CardEnums.Rarity in [CardEnums.Rarity.COMMON, CardEnums.Rarity.UNCOMMON, CardEnums.Rarity.EPIC, CardEnums.Rarity.LEGENDARY]:
		var card: CardData = CardBuilder.unit("c_%d" % int(rarity), "C", Affinity.Type.BEEFCAKE, 1, [] as Array[Affinity.Type], 1, 1)
		card.rarity = rarity
		var deck: Deck = Deck.new()
		for i: int in range(4):
			deck.cards.append(card)
		assert_false(DeckValidator.has_problem(DeckValidator.validate(deck, profile), DeckValidator.Problem.TOO_MANY_COPIES), "4 copies of rarity %d" % int(rarity))
		deck.cards.append(card)
		assert_true(DeckValidator.has_problem(DeckValidator.validate(deck, profile), DeckValidator.Problem.TOO_MANY_COPIES), "5 copies of rarity %d" % int(rarity))


func test_infrastructure_is_unlimited() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	var deck: Deck = Deck.new()
	var infra: CardData = CardBuilder.infra(Affinity.Type.BEEFCAKE)
	for i: int in range(40):
		deck.cards.append(infra)
	assert_false(DeckValidator.has_problem(DeckValidator.validate(deck, profile), DeckValidator.Problem.TOO_MANY_COPIES))


func test_the_level_table_no_longer_has_rarity_copy_limits() -> void:
	for row: LevelData in ProgressionTable.build():
		assert_false("copy_limits" in row, "LevelData has no copy_limits property any more")
		assert_false(row.summary.to_lower().contains("copy limit"))


# ---- Save format ------------------------------------------------------------------------


func test_an_old_format_save_is_reset_with_a_message() -> void:
	var path: String = "user://test_old_save.json"
	var old: Dictionary = {"primary": 1, "gold": 99, "version": 1}
	assert_true(SaveSystem.write(old, path))
	Session.save_path = path
	assert_true(Session.has_save())
	assert_false(Session.save_is_compatible())
	assert_true(Session.discard_incompatible_save())
	assert_false(Session.has_save(), "the incompatible save is gone")
	assert_false(Session.save_reset_message.is_empty(), "the player is told what happened")
	assert_true(FileAccess.file_exists(path + ".old"), "the old file is kept as a backup")
	DirAccess.remove_absolute(path + ".old")
	Session.save_path = SaveSystem.PATH
	Session.save_reset_message = ""


func test_a_current_format_save_loads_and_is_not_discarded() -> void:
	var path: String = "user://test_current_save.json"
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	var data: Dictionary = Session.to_dict()
	assert_eq(int(data["save_format"]), Session.SAVE_FORMAT)
	SaveSystem.write(data, path)
	Session.save_path = path
	assert_true(Session.save_is_compatible())
	assert_false(Session.discard_incompatible_save())
	assert_true(Session.load_game())
	SaveSystem.delete(path)
	Session.save_path = SaveSystem.PATH


func test_from_dict_rejects_a_dictionary_without_the_current_format() -> void:
	assert_false(Session.from_dict({"primary": 1}))
