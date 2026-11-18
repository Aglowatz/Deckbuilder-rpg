extends GutTest
## Nov 18 evening, Part 2 (the owner's rule): players can OWN and buy three copies of every card at all times; what they can put in a DECK
## stays limited by rarity and level. Packs, rewards and shops give real copies up to 3; a 4th converts. Buying a copy the player can't use
## yet asks first, with the real levels; the Deck Station says how many become usable and when.

var epic: CardData
var uncommon: CardData


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.choose_starting_path(Affinity.Type.NECROCRAT)
	epic = _first(CardEnums.Rarity.EPIC)
	uncommon = _first(CardEnums.Rarity.UNCOMMON)


func _first(rarity: CardEnums.Rarity) -> CardData:
	var ids: Array = Session.content.cards.keys()
	ids.sort()
	for id: Variant in ids:
		var card: CardData = Session.content.cards[id] as CardData
		var own_path: bool = card.paths().all(func(path: Affinity.Type) -> bool: return path == Affinity.Type.NECROCRAT or path == Affinity.Type.NEUTRAL)
		if card.rarity == rarity and own_path and not card.is_token and not card.is_unlimited() and Session.owned_count(card.id) == 0:
			return card
	return null


func test_own_three_of_every_card_at_level_one() -> void:
	assert_eq(Session.profile.level, 1)
	assert_not_null(epic)
	assert_eq(CopyCaps.own_cap(epic), 3, "own 3 of an Epic from the start")
	assert_eq(Session.deck_cap(epic), CopyCaps.cap_for(CardEnums.Rarity.EPIC, 1), "the deck limit is the rarity's, as before")
	assert_lt(Session.deck_cap(epic), 3)
	for copy: int in range(3):
		var notices: Array[String] = Session.add_cards([epic] as Array[CardData])
		assert_true(notices.is_empty(), "copy %d is a real copy, not essence" % (copy + 1))
	assert_eq(Session.owned_count(epic.id), 3)
	assert_true(Session.at_copy_cap(epic), "the 4th would convert")
	var essence_before: int = Session.profile.essence_of(epic.paths()[0]) if not epic.paths().is_empty() else 0
	var fourth: Array[String] = Session.add_cards([epic] as Array[CardData])
	assert_eq(fourth.size(), 1, "a 4th copy converts as duplicates do")
	assert_eq(Session.owned_count(epic.id), 3)
	if not epic.paths().is_empty():
		assert_gt(Session.profile.essence_of(epic.paths()[0]), essence_before)


func test_the_shop_sells_the_second_and_third_copy() -> void:
	assert_true(CardPricing.is_for_sale(epic, 1, Session.copy_cap(epic)), "a 2nd copy is for sale at level 1")
	assert_true(CardPricing.is_for_sale(epic, 2, Session.copy_cap(epic)), "and a 3rd")
	assert_false(CardPricing.is_for_sale(epic, 3, Session.copy_cap(epic)), "never a 4th")
	assert_true(CardPricing.is_for_sale(uncommon, 2, Session.copy_cap(uncommon)))


func test_the_notice_names_the_card_and_the_real_levels() -> void:
	var limit: int = CopyCaps.for_card(epic, 1)
	assert_eq(CopyCaps.buy_notice(epic, 1, limit), "", "a copy that fits the deck limit asks nothing extra")
	var raises: Array[Dictionary] = CopyCaps.raises_after(epic.rarity, 1)
	assert_gt(raises.size(), 0, "Epic deck limits rise with levels")
	var later: PackedStringArray = []
	for row: Dictionary in raises:
		later.append("%d at level %d" % [int(row["cap"]), int(row["level"])])
	var expected: String = "You can only use %d %s of %s in a deck right now. You'll be able to use %s. Buy anyway?" % [limit, "copy" if limit == 1 else "copies", epic.display_name, " and ".join(later)]
	assert_eq(CopyCaps.buy_notice(epic, 1, limit + 1), expected)
	# the levels are the level track's
	for row: Dictionary in raises:
		assert_eq(CopyCaps.cap_for(epic.rarity, int(row["level"])), int(row["cap"]), "at level %d the deck limit is %d" % [int(row["level"]), int(row["cap"])])
		assert_lt(CopyCaps.cap_for(epic.rarity, int(row["level"]) - 1), int(row["cap"]), "and not a level earlier")
	# at the highest deck limit nothing is said
	assert_eq(CopyCaps.buy_notice(epic, 30, 3), "")
	var source: String = FileAccess.get_file_as_string("res://ui/town/vendor_screen.gd")
	assert_true(source.contains("CopyCaps.buy_notice(card, Session.profile.level, owned + 1)"), "the vendor asks with it before a purchase")
	assert_true(source.contains("\"Buy\", \"Cancel\""), "Buy / Cancel")


func test_the_deck_limit_is_still_enforced() -> void:
	Session.add_cards([epic, epic, epic] as Array[CardData])
	var editor: DeckEditor = DeckEditor.from(Session.profile, Session.deck, [] as Array[CardData])
	var limit: int = editor.cap(epic)
	for i: int in range(limit):
		assert_eq(editor.why_not_add(epic), "", "copy %d fits" % (i + 1))
		editor.add(epic)
	assert_ne(editor.why_not_add(epic), "", "one more than the deck limit is refused although 3 are owned")
	assert_eq(editor.count(epic), limit)
	assert_eq(editor.owned(epic), 3)
	# a saved deck over the limit is trimmed on load; the owned copies stay
	var ids: Array[String] = [epic.id, epic.id, epic.id]
	assert_eq(CopyCaps.trim_ids(ids, Session.deck_lookup(), 1).size(), limit)
	assert_eq(CopyCaps.excess([epic, epic, epic] as Array[CardData], 1).size(), 0, "owning 3 is never excess")
	assert_eq(CopyCaps.excess([epic, epic, epic, epic] as Array[CardData], 1).size(), 1, "a 4th is")


func test_the_deck_station_says_when_more_become_usable() -> void:
	var limit: int = CopyCaps.for_card(epic, 1)
	var note: String = CopyCaps.more_usable_note(epic, 1, 3)
	var first: Dictionary = CopyCaps.raises_after(epic.rarity, 1)[0]
	assert_true(note.begins_with("%d more usable at level %d" % [mini(int(first["cap"]), 3) - limit, int(first["level"])]), note)
	assert_eq(CopyCaps.more_usable_note(epic, 1, limit), "", "nothing to say when every copy is usable")
	var source: String = FileAccess.get_file_as_string("res://ui/town/deckbuilder_screen.gd")
	assert_true(source.contains("\"Deck %s · Own %d\""), "Deck 1/1 · Own 3")
	assert_true(source.contains("CopyCaps.more_usable_note("), "the hover note")


func test_rewards_and_packs_give_real_copies_up_to_three() -> void:
	Session.add_cards([epic, epic] as Array[CardData])
	assert_false(Session.at_copy_cap(epic), "a reward or pack card with 2 owned is a real copy")
	var caps: Dictionary = {epic.id: Session.copy_cap(epic)}
	assert_eq(int(caps[epic.id]), 3, "the reward picks offer cards until 3 are owned")


func test_the_rule_reads_the_new_way_everywhere() -> void:
	assert_true(CopyCaps.RULE.contains("own up to 3 copies"), CopyCaps.RULE)
	assert_true(CopyCaps.rule_text(1).contains("Deck limits at level 1"))
	var tips: String = FileAccess.get_file_as_string("res://data/loading/loading_tips.txt")
	assert_false(tips.contains("You can have up to 3 copies of any one card, depending on your level"), "the loading tip says the new rule")
	assert_true(tips.contains(CopyCaps.RULE), "the loading tip says the rule as written")
	assert_true(ProgressionTable.reward_lines(ProgressionTable.row(12), ProgressionTable.row(11)).any(func(line: String) -> bool: return line.contains("copies in a deck")), "the level-up line says it is the deck limit")
