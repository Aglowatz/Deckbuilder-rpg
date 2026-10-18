extends GutTest
## Overnight Oct 17, Part 1: copy caps by rarity and level (`CopyCaps`), enforced in the collection (`Session.add_cards`,
## packs), the shop (`CardPricing.is_for_sale`), the deck builder (`DeckEditor`), deck validation and the save migration.

const A: Affinity.Type = Affinity.Type.BEEFCAKE
const C: CardEnums.Rarity = CardEnums.Rarity.COMMON
const U: CardEnums.Rarity = CardEnums.Rarity.UNCOMMON
const E: CardEnums.Rarity = CardEnums.Rarity.EPIC
const L: CardEnums.Rarity = CardEnums.Rarity.LEGENDARY


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(A)
	Session.profile.owned_cards.clear()
	Session.profile.essence.clear()
	Session.profile.level = 1


func _card(id: String, rarity: CardEnums.Rarity) -> CardData:
	var card: CardData = CardBuilder.unit(id, id.capitalize(), A, 1, [] as Array[Affinity.Type], 1, 1)
	card.rarity = rarity
	return card


func test_starting_caps_by_rarity() -> void:
	assert_eq(CopyCaps.cap_for(C, 1), 3)
	assert_eq(CopyCaps.cap_for(U, 1), 2)
	assert_eq(CopyCaps.cap_for(E, 1), 1)
	assert_eq(CopyCaps.cap_for(L, 1), 1)


func test_caps_never_exceed_three_and_reach_three_by_level_30() -> void:
	for level: int in range(1, 31):
		for rarity: int in range(CardEnums.Rarity.size()):
			assert_lte(CopyCaps.cap_for(rarity as CardEnums.Rarity, level), 3)
	for rarity: int in range(CardEnums.Rarity.size()):
		assert_eq(CopyCaps.cap_for(rarity as CardEnums.Rarity, 30), 3, "rarity %d reaches 3 by level 30" % rarity)


func test_caps_only_rise_with_level() -> void:
	for rarity: int in range(CardEnums.Rarity.size()):
		for level: int in range(2, 31):
			assert_gte(CopyCaps.cap_for(rarity as CardEnums.Rarity, level), CopyCaps.cap_for(rarity as CardEnums.Rarity, level - 1))


func test_infrastructure_is_unlimited() -> void:
	var infra: CardData = Session.content.infrastructure[int(A)] as CardData
	assert_eq(CopyCaps.for_card(infra, 1), CopyCaps.UNLIMITED)


func test_reason_names_the_rarity_and_the_next_raise() -> void:
	var epic: CardData = _card("epic_x", E)
	var text: String = CopyCaps.reason(epic, 1)
	assert_true(text.begins_with("Epic cards: 1 copy"), text)
	var next: Dictionary = CopyCaps.next_raise(E, 1)
	assert_false(next.is_empty())
	assert_true(text.contains("level %d" % int(next["level"])), text)
	assert_eq(CopyCaps.ratio_text(1, epic, 1), "1/1")


func test_collection_keeps_up_to_the_cap_and_converts_the_rest() -> void:
	var epic: CardData = _card("epic_y", E)
	Session.add_cards([epic, epic] as Array[CardData])
	assert_eq(Session.owned_count(epic.id), 1, "an Epic is capped at 1 at level 1")
	assert_eq(Session.profile.essence_of(A), Essence.value_for(E), "the second copy became essence")
	var common: CardData = _card("common_y", C)
	Session.add_cards([common, common, common, common] as Array[CardData])
	assert_eq(Session.owned_count(common.id), 3, "never more than 3")


func test_cap_rises_with_level_for_new_copies() -> void:
	var epic: CardData = _card("epic_z", E)
	Session.add_cards([epic] as Array[CardData])
	assert_true(Session.at_copy_cap(epic))
	var raise: Dictionary = CopyCaps.next_raise(E, 1)
	Session.profile.level = int(raise["level"])
	assert_false(Session.at_copy_cap(epic))
	Session.add_cards([epic] as Array[CardData])
	assert_eq(Session.owned_count(epic.id), 2)


func test_shop_stops_selling_at_the_cap() -> void:
	var uncommon: CardData = _card("unc_s", U)
	assert_true(CardPricing.is_for_sale(uncommon, 1, Session.copy_cap(uncommon)))
	assert_false(CardPricing.is_for_sale(uncommon, 2, Session.copy_cap(uncommon)), "an Uncommon stops at 2 at level 1")
	assert_false(CardPricing.is_for_sale(_card("com_s", C), 3, 3))


func test_pack_entries_convert_at_the_cap() -> void:
	var pack: PackData = PackCatalog.path_pack(A)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 5
	var preview: Array[CardData] = PackRoller.roll(pack, Session.content, rng)
	for card: CardData in preview:
		for i: int in range(Session.copy_cap(card)):
			Session.add_cards([card] as Array[CardData])
	Session.add_pack(pack.id)
	rng.seed = 5
	var opening: PackOpening = Session.open_pack(pack.id, rng)
	for entry: PackOpening.Entry in opening.entries:
		assert_true(entry.converted, "%s was at its cap" % entry.card.id)
		assert_eq(Session.owned_count(entry.card.id), Session.copy_cap(entry.card))


func test_deck_editor_blocks_copies_over_the_cap_with_a_reason() -> void:
	var epic: CardData = _card("epic_d", E)
	Session.profile.owned_cards.append(epic)
	Session.profile.owned_cards.append(epic)  # an old save could hold 2 at level 1
	var editor: DeckEditor = DeckEditor.from(Session.profile, Deck.new(), [] as Array[CardData])
	assert_true(editor.add(epic))
	assert_false(editor.add(epic), "the cap, not ownership, stops the second Epic")
	assert_true(editor.why_not_add(epic).begins_with("Epic cards"), editor.why_not_add(epic))
	assert_eq(editor.cap_text(epic), "1/1")


func test_validator_flags_copies_over_the_cap() -> void:
	var uncommon: CardData = _card("unc_v", U)
	var deck: Deck = Deck.new()
	for i: int in range(3):
		deck.cards.append(uncommon)
	var issues: Array[DeckValidator.Issue] = DeckValidator.validate(deck, Session.profile)
	assert_true(DeckValidator.has_problem(issues, DeckValidator.Problem.TOO_MANY_COPIES))
	Session.profile.level = 30
	issues = DeckValidator.validate(deck, Session.profile)
	assert_false(DeckValidator.has_problem(issues, DeckValidator.Problem.TOO_MANY_COPIES), "3 Uncommons are fine at level 30")


func test_save_migration_converts_owned_extras_and_trims_saved_decks() -> void:
	var real: CardData = null
	for card: CardData in Session.content.cards.values():
		if card.rarity == E and not card.is_token and card.paths().size() == 1 and not card.is_unlimited():
			real = card
			break
	assert_not_null(real, "an Epic card exists")
	for i: int in range(4):
		Session.profile.owned_cards.append(real)
	var ids: Array[String] = DeckBox.ids_of(Session.deck)
	for i: int in range(4):
		ids.append(real.id)
	Session.deck_box.set_cards(Session.deck_box.active, ids)
	Session.deck.cards.clear()
	for id: String in ids:
		Session.deck.cards.append(Session.card_by_id(id))
	var data: Dictionary = Session.to_dict()
	assert_true(Session.from_dict(data))
	assert_eq(Session.owned_count(real.id), 1, "4 old copies of an Epic become 1 owned")
	assert_eq(Session.profile.essence_of(real.paths()[0]), 3 * Essence.value_for(E))
	assert_eq(Session.deck.count_of(real.id), 1, "the active deck was trimmed")
	assert_gte(Session.deck.size(), DeckValidator.MIN_DECK_SIZE, "and topped back up with infrastructure")
	assert_true(Session.town_notice.contains("Copy caps"), Session.town_notice)
	# A second load changes nothing.
	var essence_before: int = Session.profile.total_essence()
	assert_true(Session.from_dict(Session.to_dict()))
	assert_eq(Session.profile.total_essence(), essence_before)
