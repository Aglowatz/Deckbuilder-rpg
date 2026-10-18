extends GutTest
## Overnight Oct 17, Part 4: the Deck Station's ten slots (4 open, +2 at levels 7, 14 and 21), save-to-slot with overwrite,
## cover cards (rarest by default, ties to the first added; the player can choose) and the slot migration of old saves.

var _content: ContentSet


func before_all() -> void:
	_content = ContentLibrary.load_all()


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func _lookup() -> Callable:
	return Session.deck_lookup()


func test_unlock_schedule() -> void:
	assert_eq(DeckSlots.unlocked_at(1), 4)
	assert_eq(DeckSlots.unlocked_at(6), 4)
	assert_eq(DeckSlots.unlocked_at(7), 6)
	assert_eq(DeckSlots.unlocked_at(14), 8)
	assert_eq(DeckSlots.unlocked_at(21), 10)
	assert_eq(DeckSlots.unlocked_at(30), 10)
	assert_eq(DeckSlots.level_for_slot(3), 1)
	assert_eq(DeckSlots.level_for_slot(4), 7)
	assert_eq(DeckSlots.level_for_slot(5), 7)
	assert_eq(DeckSlots.level_for_slot(6), 14)
	assert_eq(DeckSlots.level_for_slot(9), 21)
	assert_eq(DeckSlots.SLOT_COUNT, 10)
	assert_eq(DeckSlots.COLUMNS, 5, "five across the top, five across the bottom")


func test_locked_slots_refuse_saves() -> void:
	assert_false(Session.slot_open(4))
	assert_eq(Session.save_deck_to_slot(4, Session.deck, "Nope"), -1)
	assert_true(Session.slot_open(3))
	assert_gte(Session.save_deck_to_slot(3, Session.deck, "Fourth"), 0)
	assert_eq(Session.deck_box.index_in_slot(3), Session.deck_box.size() - 1)


func test_saving_to_an_occupied_slot_overwrites_it() -> void:
	var edited: Deck = Deck.new()
	edited.cards.append(_content.infrastructure[int(Affinity.Type.BEEFCAKE)] as CardData)
	var index: int = Session.save_deck_to_slot(2, edited, "Tiny")
	assert_eq(Session.deck_box.size(), 2)
	var bigger: Deck = Deck.new()
	for i: int in range(3):
		bigger.cards.append(_content.infrastructure[int(Affinity.Type.BEEFCAKE)] as CardData)
	assert_eq(Session.save_deck_to_slot(2, bigger, "Tiny"), index, "same slot, same deck")
	assert_eq(Session.deck_box.size(), 2, "no new deck")
	assert_eq(Session.deck_box.decks[index].card_count(), 3)


func test_saving_the_active_slot_updates_the_battle_deck() -> void:
	var edited: Deck = Session.deck_box.build(0, _lookup())
	edited.cards.append(_content.infrastructure[int(Affinity.Type.BEEFCAKE)] as CardData)
	var size: int = edited.size()
	Session.save_deck_to_slot(Session.deck_box.decks[0].slot, edited, "Main")
	assert_eq(Session.deck.size(), size)


func test_cover_is_the_rarest_card_first_added_on_ties() -> void:
	var common: CardData = null
	var epic_a: CardData = null
	var epic_b: CardData = null
	for card: CardData in _content.cards.values():
		if card.is_unlimited() or card.is_token:
			continue
		if card.rarity == CardEnums.Rarity.COMMON and common == null:
			common = card
		elif card.rarity == CardEnums.Rarity.EPIC:
			if epic_a == null:
				epic_a = card
			elif epic_b == null:
				epic_b = card
	var ids: Array[String] = ["BAS-B", common.id, epic_b.id, epic_a.id]
	assert_eq(DeckSlots.cover_id(ids, _lookup()), epic_b.id, "the first Epic added wins the tie")
	assert_eq(DeckSlots.cover_id(ids, _lookup(), common.id), common.id, "a chosen cover wins")
	assert_eq(DeckSlots.cover_id(ids, _lookup(), "GONE"), epic_b.id, "a chosen cover no longer in the deck falls back")
	assert_eq(DeckSlots.cover_id([] as Array[String], _lookup()), "")


func test_set_cover_is_saved() -> void:
	var ids: Array[String] = Session.deck_box.decks[0].card_ids
	var pick: String = ""
	for id: String in ids:
		var card: CardData = Session.card_by_id(id)
		if card != null and not card.is_unlimited():
			pick = id
	assert_true(Session.set_deck_cover(0, pick))
	var data: Dictionary = JSON.parse_string(JSON.stringify(Session.to_dict())) as Dictionary
	Session.new_game()
	assert_true(Session.from_dict(data))
	assert_eq(Session.deck_box.decks[0].cover_id, pick)


func test_paths_of_a_deck_for_the_slot_icons() -> void:
	var paths: Array[Affinity.Type] = DeckSlots.paths_of(Session.deck_box.decks[0].card_ids, _lookup())
	assert_true(paths.has(Affinity.Type.BEEFCAKE))


func test_old_saves_get_slots_in_order() -> void:
	var rows: Array = [{"name": "A", "cards": []}, {"name": "B", "cards": []}, {"name": "C", "cards": [], "slot": 0}]
	var box: DeckBox = DeckBox.from_array(rows, 1)
	assert_eq(box.decks[2].slot, 0, "a saved slot is kept")
	assert_eq(box.decks[0].slot, 1)
	assert_eq(box.decks[1].slot, 2)
	assert_eq(box.active, 1)


func test_an_old_deck_in_a_now_locked_slot_stays_usable() -> void:
	for i: int in range(5):
		Session.deck_box.decks.append(DeckBox.SavedDeck.from_dict({"name": "Old %d" % i, "cards": []}))
	Session.deck_box.assign_missing_slots()
	assert_eq(Session.deck_box.index_in_slot(5), 5)
	assert_true(Session.slot_open(5), "slot 6 is locked at level 1 but holds an old deck")
	assert_false(Session.slot_open(6) and Session.deck_box.index_in_slot(6) < 0)
