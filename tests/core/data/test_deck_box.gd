extends GutTest
## Brief 16, Group E: saved decks - build, name, save, rename, duplicate, delete, switch; 5 slots growing to 10 at level 3; warnings for cards no longer owned; save/load.

var _content: ContentSet


func before_all() -> void:
	_content = ContentLibrary.load_all()


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.profile = CampaignStart.new_profile(_content, Affinity.Type.BEEFCAKE)
	Session.deck = CampaignStart.starter_deck(_content, Affinity.Type.BEEFCAKE)


func _ids(count: int, id: String = "BAS-B") -> Array[String]:
	var result: Array[String] = []
	for i: int in range(count):
		result.append(id)
	return result


func test_a_new_game_has_one_deck_matching_the_active_deck() -> void:
	assert_eq(Session.deck_box.size(), 1)
	assert_eq(Session.deck_box.active, 0)
	assert_eq(Session.deck_box.decks[0].card_count(), Session.deck.size())


func test_the_box_starts_with_five_slots_and_grows_to_ten_at_level_three() -> void:
	assert_eq(Session.deck_capacity(), 5)
	for i: int in range(4):
		assert_gte(Session.new_saved_deck("Deck %d" % i), 0)
	assert_eq(Session.deck_box.size(), 5)
	assert_eq(Session.new_saved_deck("One too many"), -1, "the box is full at 5")
	Session.add_xp(ProgressionTable.xp_to_reach(ProgressionTable.DECK_BOX_EXPANSION_LEVEL))
	assert_eq(Session.deck_capacity(), 10)
	for i: int in range(5):
		assert_gte(Session.new_saved_deck("More %d" % i), 0)
	assert_eq(Session.deck_box.size(), 10)
	assert_eq(Session.new_saved_deck("Eleven"), -1)


func test_rename_duplicate_delete_and_switch() -> void:
	var second: int = Session.new_saved_deck("Second", _ids(3))
	assert_eq(second, 1)
	assert_true(Session.rename_saved_deck(second, "  Spicy Deck  "))
	assert_eq(Session.deck_box.decks[second].name, "Spicy Deck")
	var copy: int = Session.duplicate_saved_deck(second)
	assert_eq(Session.deck_box.decks[copy].name, "Spicy Deck (copy)")
	assert_eq(Session.deck_box.decks[copy].card_ids, Session.deck_box.decks[second].card_ids)
	assert_true(Session.use_deck(second))
	assert_eq(Session.deck.size(), 3, "the active deck is what battles use")
	assert_eq(Session.deck.deck_name, "Spicy Deck")
	assert_true(Session.delete_saved_deck(copy))
	assert_eq(Session.deck_box.size(), 2)
	assert_true(Session.delete_saved_deck(0))
	assert_eq(Session.deck_box.size(), 1)
	assert_eq(Session.deck_box.active, 0, "the active index follows the shift")
	assert_eq(Session.deck.size(), 3)
	assert_false(Session.delete_saved_deck(0), "the last deck can never be deleted")


func test_deleting_the_active_deck_activates_another() -> void:
	Session.new_saved_deck("B", _ids(5))
	assert_true(Session.delete_saved_deck(0))
	assert_eq(Session.deck_box.size(), 1)
	assert_eq(Session.deck.size(), 5)


func test_storing_an_edited_deck_updates_the_battle_deck_only_when_it_is_active() -> void:
	var other: int = Session.new_saved_deck("Other", _ids(2))
	var active_size: int = Session.deck.size()
	var edited: Deck = Deck.new()
	edited.cards.append(_content.infrastructure[int(Affinity.Type.BEEFCAKE)] as CardData)
	assert_true(Session.store_deck(other, edited))
	assert_eq(Session.deck.size(), active_size, "editing an inactive deck leaves the battle deck alone")
	assert_eq(Session.deck_box.decks[other].card_count(), 1)
	assert_true(Session.store_deck(0, edited))
	assert_eq(Session.deck.size(), 1, "editing the active deck changes the battle deck")


func test_names_are_trimmed_and_never_empty() -> void:
	assert_eq(DeckBox.clean_name("   "), DeckBox.DEFAULT_NAME)
	assert_eq(DeckBox.clean_name("x".repeat(60)).length(), DeckBox.MAX_NAME_LENGTH)


func test_cards_no_longer_owned_give_a_warning_not_a_crash() -> void:
	var lich: CardData = _content.card("N-28")
	var index: int = Session.new_saved_deck("Lich deck", _ids(2, "N-28"))
	assert_false(Session.profile.owned_cards.has(lich))
	var warnings: Array[String] = Session.deck_warnings(index)
	assert_eq(warnings.size(), 1)
	assert_true(warnings[0].contains("2 x Lich of Accounts Payable"), warnings[0])
	assert_true(Session.use_deck(index), "the deck still loads")
	assert_eq(Session.deck.size(), 2)
	assert_true(Session.deck_warnings(0).is_empty() or Session.deck_box.active == index)


func test_unknown_card_ids_are_skipped_with_a_warning() -> void:
	var index: int = Session.new_saved_deck("Old deck", ["BAS-B", "NOT-A-CARD", "BAS-B"] as Array[String])
	assert_eq(Session.deck_box.build(index, Session.deck_lookup()).size(), 2)
	var warnings: Array[String] = Session.deck_warnings(index)
	assert_eq(warnings.size(), 1)
	assert_true(warnings[0].contains("NOT-A-CARD"))


func test_decks_survive_a_save_round_trip_with_the_active_one() -> void:
	var second: int = Session.new_saved_deck("Second", _ids(7))
	Session.rename_saved_deck(0, "Main")
	Session.use_deck(second)
	var data: Dictionary = JSON.parse_string(JSON.stringify(Session.to_dict())) as Dictionary
	Session.new_game()
	assert_true(Session.from_dict(data))
	assert_eq(Session.deck_box.size(), 2)
	assert_eq(Session.deck_box.decks[0].name, "Main")
	assert_eq(Session.deck_box.decks[1].name, "Second")
	assert_eq(Session.deck_box.active, 1)
	assert_eq(Session.deck.size(), 7)
	assert_eq(Session.deck_box.decks[1].card_ids, _ids(7))


func test_an_older_save_with_one_deck_becomes_a_box_with_one_deck() -> void:
	var data: Dictionary = Session.to_dict()
	data.erase("decks")
	data.erase("active_deck")
	Session.new_game()
	assert_true(Session.from_dict(data))
	assert_eq(Session.deck_box.size(), 1)
	assert_eq(Session.deck_box.decks[0].name, Session.DECK_NAME)
	assert_gt(Session.deck.size(), 0)


func test_loading_restores_the_levelled_stats() -> void:
	Session.add_xp(ProgressionTable.xp_to_reach(8))
	var level: int = Session.profile.level
	var hp: int = Session.profile.max_hp
	var data: Dictionary = JSON.parse_string(JSON.stringify(Session.to_dict())) as Dictionary
	Session.new_game()
	Session.profile = CampaignStart.new_profile(_content, Affinity.Type.BEEFCAKE)
	assert_true(Session.from_dict(data))
	assert_eq(Session.profile.level, level)
	assert_eq(Session.profile.max_hp, hp, "max HP follows the level after loading")
	assert_eq(Session.profile.deck_slots, 10)
	assert_eq(Session.profile.opening_hand_size, 6)


func test_the_deck_picker_does_not_interrupt_with_a_single_deck() -> void:
	var layer: Control = Control.new()
	add_child_autofree(layer)
	var ran: Array[bool] = [false]
	var picker: DeckPicker = DeckPicker.guard(layer, func() -> void: ran[0] = true)
	assert_null(picker)
	assert_true(ran[0], "one deck: just go")
	Session.new_saved_deck("Another", _ids(4))
	ran[0] = false
	picker = DeckPicker.guard(layer, func() -> void: ran[0] = true)
	assert_not_null(picker, "two decks: ask first")
	assert_false(ran[0])
	await get_tree().process_frame
	assert_not_null(layer.find_child("UseButton0", true, false))
	assert_not_null(layer.find_child("UseButton1", true, false))
	picker.cancelled.emit()
	assert_false(ran[0], "cancelling does not start the fight")
