extends GutTest
## UI + economy fixes Oct 22, Part 5: Sable sells a small sample that grows a little and rotates; each Path zone's vendor sells that
## Path, with the Uncommons and Epics opening once the zone's boss is beaten and Legendaries only in the postgame (docs/design/vendors.md).

var content: ContentSet


func before_all() -> void:
	content = ContentLibrary.load_all()


func _state(level: int, zones: int = 0, flags: Dictionary = {}, postgame: bool = false) -> UnlockState:
	var state: UnlockState = UnlockState.new()
	state.player_level = level
	state.zones_completed = zones
	state.flags = flags
	state.postgame = postgame
	state.cleared_dungeons = [TrialOfTheHollow.DUNGEON_NAME] as Array[String]
	return state


func _gate() -> Condition:
	return Condition.dungeon_cleared(TrialOfTheHollow.DUNGEON_NAME)


func _for_sale(data: VendorData, state: UnlockState) -> Array[CardData]:
	var result: Array[CardData] = []
	for id: String in data.available_card_ids(state):
		result.append(content.card(id))
	return result


func test_sable_sells_a_small_mostly_colorless_sample_at_first() -> void:
	var state: UnlockState = _state(1)
	var cards: Array[CardData] = _for_sale(VendorStocks.sable_sample(content, state, _gate()), state)
	assert_between(cards.size(), 8, 12, "about 8-12 cards")
	var colorless: int = 0
	var per_path: Dictionary = {}
	for card: CardData in cards:
		assert_lt(int(card.rarity), int(CardEnums.Rarity.EPIC), "no Epic or Legendary early: %s" % card.id)
		if card.paths().is_empty():
			colorless += 1
		else:
			per_path[card.paths()[0]] = int(per_path.get(card.paths()[0], 0)) + 1
	assert_gt(colorless, cards.size() / 2, "mostly Colorless")
	assert_eq(per_path.size(), 4, "a taste of every Path")
	for path: Variant in per_path.keys():
		assert_lte(int(per_path[path]), 2, "never more than a couple from one Path")


func test_sable_grows_a_little_with_progress_and_rotates() -> void:
	var early: UnlockState = _state(1)
	var later: UnlockState = _state(6, 1)
	var early_ids: Array[String] = VendorStocks.sable_sample(content, early, _gate()).available_card_ids(early)
	var later_ids: Array[String] = VendorStocks.sable_sample(content, later, _gate()).available_card_ids(later)
	assert_gt(later_ids.size(), early_ids.size(), "the selection grows")
	assert_lte(later_ids.size(), 12)
	assert_ne(later_ids, early_ids, "and it rotates")
	var again: Array[String] = VendorStocks.sable_sample(content, early, _gate()).available_card_ids(early)
	assert_eq(again, early_ids, "the same level and zones give the same shelf (it only rotates on progress)")


func test_sable_never_sells_a_path_epic_or_any_legendary() -> void:
	for zones: int in range(0, 5):
		var state: UnlockState = _state(30, zones, {}, zones == 4)
		for card: CardData in _for_sale(VendorStocks.sable_sample(content, state, _gate()), state):
			assert_ne(card.rarity, CardEnums.Rarity.LEGENDARY, card.id)
			if card.rarity == CardEnums.Rarity.EPIC:
				assert_true(card.paths().is_empty(), "only a Colorless Epic, late: %s" % card.id)


func test_sable_sells_nothing_before_the_cave_is_cleared() -> void:
	var state: UnlockState = _state(1)
	state.cleared_dungeons = [] as Array[String]
	assert_eq(VendorStocks.sable_sample(content, state, _gate()).available_card_ids(state).size(), 0)


func test_a_zone_vendor_sells_its_path_commons_and_two_uncommons_at_first() -> void:
	var data: VendorData = VendorStocks.zone_shelf(content, Affinity.Type.BEEFCAKE, "beefcake", ZoneCards.GAINLANDS_VENDOR_IDS, "Swole Station")
	var state: UnlockState = _state(5)
	var uncommons: int = 0
	for card: CardData in _for_sale(data, state):
		assert_eq(card.paths(), [Affinity.Type.BEEFCAKE] as Array[Affinity.Type], "only Beefcake cards: %s" % card.id)
		assert_lte(int(card.rarity), int(CardEnums.Rarity.UNCOMMON), "Commons and Uncommons first: %s" % card.id)
		if card.rarity == CardEnums.Rarity.UNCOMMON:
			uncommons += 1
	assert_eq(uncommons, 2)


func test_beating_the_zone_boss_opens_more_uncommons_and_the_epics() -> void:
	# Cards Oct 27: every Gourmand Epic is a prize now (Toro Toro, Chef de Golem, the Pantry, the Recipe) or the Black Market's, so the
	# shelf's Epic tier holds what the player has earned - here Chef de Golem, the Doppelganger's card pick.
	var before: UnlockState = _state(12)
	var after: UnlockState = _state(14, 1, {str(ZoneCompletion.flag_name("gourmand")): true})
	after.earned_cards = {"G-28": true}
	var data: VendorData = VendorStocks.zone_shelf(content, Affinity.Type.GOURMAND, "gourmand", ZoneCards.BUFFET_VENDOR_IDS, "Grand Pantry", after)
	var epics_before: int = 0
	var epics_after: int = 0
	for card: CardData in _for_sale(data, before):
		epics_before += 1 if card.rarity == CardEnums.Rarity.EPIC else 0
	for card: CardData in _for_sale(data, after):
		epics_after += 1 if card.rarity == CardEnums.Rarity.EPIC else 0
		assert_ne(card.rarity, CardEnums.Rarity.LEGENDARY, "Legendaries wait for the postgame")
	assert_eq(epics_before, 0)
	assert_gt(epics_after, 0)
	assert_gt(data.available_card_ids(after).size(), data.available_card_ids(before).size())
	assert_gt(data.locked_card_ids(before).size(), 0, "the locked ones show as teasers")


func test_unique_prizes_are_never_on_a_shelf() -> void:
	var prizes: Array[String] = [ZoneCards.GAINLANDS_MINI_REWARD_ID, ZoneCards.BUFFET_MINI_REWARD_ID, ZoneCards.HEAP_MINI_REWARD_ID, ZoneCards.MINI_DUNGEON_REWARD_ID]
	prizes.append_array(ZoneCards.MAIN_DUNGEON_REWARD_IDS)
	prizes.append_array(CapitalContent.BLACK_MARKET_CARD_IDS)
	var postgame: UnlockState = _state(30, 4, {}, true)
	for path: Affinity.Type in Affinity.colored_types():
		var shelf: VendorData = VendorStocks.zone_shelf(content, path, "x", [] as Array[String], "x")
		for entry: VendorStockEntry in shelf.entries:
			assert_false(prizes.has(entry.card_id), "%s is a prize" % entry.card_id)
	for entry: VendorStockEntry in VendorStocks.sable_sample(content, postgame, _gate()).entries:
		assert_false(prizes.has(entry.card_id), "%s is a prize" % entry.card_id)
