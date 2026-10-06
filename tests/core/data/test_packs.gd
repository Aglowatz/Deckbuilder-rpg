extends GutTest
## Pack system: data, pools, seeded rolls (weights, guarantees, not_in_packs), opening into the collection, the essence
## summary, the shops' stock rules and the save round trip. Everything is deterministic: rolls use a seeded RNG.

const A: Affinity.Type = Affinity.Type.BEEFCAKE
const B: Affinity.Type = Affinity.Type.GOURMAND
const C: Affinity.Type = Affinity.Type.REFUSEMANCER
const D: Affinity.Type = Affinity.Type.NECROCRAT

var content: ContentSet


func before_all() -> void:
	content = ContentLibrary.load_all()


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(A)
	Session.profile.owned_cards.clear()
	Session.profile.essence.clear()
	Session.profile.packs.clear()


func _rng(seed_value: int) -> RandomNumberGenerator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func _pack(pack_id: String) -> PackData:
	var pack: PackData = PackCatalog.find(pack_id)
	assert_not_null(pack, "pack %s exists" % pack_id)
	return pack


func _rarity_count(cards: Array[CardData], rarity: CardEnums.Rarity) -> int:
	var count: int = 0
	for card: CardData in cards:
		if card.rarity == rarity:
			count += 1
	return count


# ---- Data --------------------------------------------------------------------------------------------


func test_every_pack_type_exists_as_data() -> void:
	for path: Affinity.Type in Affinity.colored_types():
		assert_not_null(PackCatalog.path_pack(path), "path pack %s" % Affinity.display_name(path))
		assert_not_null(PackCatalog.gilded_pack(path), "gilded pack %s" % Affinity.display_name(path))
	for pack_id: String in [PackRules.PRISMATIC_ID, PackRules.GENERAL_1_ID, PackRules.GENERAL_2_ID]:
		_pack(pack_id)
	assert_eq(PackCatalog.all().size(), 11)
	assert_eq(_pack(PackRules.GENERAL_1_ID).card_count, 3, "default pack size is 3")


func test_not_in_packs_flag_is_on_the_unique_cards() -> void:
	for id: String in PackRules.NOT_IN_PACKS_IDS:
		var card: CardData = content.card(id)
		assert_not_null(card, "%s exists" % id)
		if card != null:
			assert_true(card.not_in_packs, "%s is flagged" % id)
	for id: String in CapitalContent.QUEST_REWARD_IDS + DungeonContent.REWARD_IDS:
		assert_true(content.card(id).not_in_packs, "%s (quest/dungeon reward) never appears in packs" % id)
	for id: String in [ZoneCards.MINI_DUNGEON_REWARD_ID, ZoneCards.GAINLANDS_MINI_REWARD_ID, ZoneCards.BUFFET_MINI_REWARD_ID, ZoneCards.HEAP_MINI_REWARD_ID]:
		assert_true(content.card(id).not_in_packs, "%s (mini dungeon reward) never appears in packs" % id)


# ---- Pools ---------------------------------------------------------------------------------------------


func test_no_pack_pool_ever_contains_a_flagged_card() -> void:
	for pack: PackData in PackCatalog.all():
		for card: CardData in PackRoller.pool(pack, content):
			assert_false(card.not_in_packs, "%s is not in the %s pool" % [card.id, pack.id])
			assert_false(card.is_token or card.is_infrastructure(), "%s is a real card" % card.id)


func test_path_pack_pool_is_its_path_plus_neutral() -> void:
	for path: Affinity.Type in Affinity.colored_types():
		var pool: Array[CardData] = PackRoller.pool(PackCatalog.path_pack(path), content)
		var has_path: bool = false
		var has_neutral: bool = false
		for card: CardData in pool:
			assert_false(card.is_multipath(), "%s: no multi-Path cards in a Path pack" % card.id)
			assert_true(card.color == path or card.color == Affinity.Type.NEUTRAL, "%s belongs to the pool of %s" % [card.id, Affinity.display_name(path)])
			has_path = has_path or card.color == path
			has_neutral = has_neutral or card.color == Affinity.Type.NEUTRAL
		assert_true(has_path and has_neutral, "%s pack has Path and neutral cards" % Affinity.display_name(path))
		assert_gte(_rarity_count(pool, CardEnums.Rarity.EPIC) + _rarity_count(pool, CardEnums.Rarity.LEGENDARY), 1, "%s has an Epic/Legendary for its Gilded guarantee" % Affinity.display_name(path))


func test_prismatic_pool_has_every_path_and_multipath_cards() -> void:
	var pool: Array[CardData] = PackRoller.pool(_pack(PackRules.PRISMATIC_ID), content)
	var paths: Dictionary = {}
	var multipath: int = 0
	for card: CardData in pool:
		if card.is_multipath():
			multipath += 1
		elif card.color != Affinity.Type.NEUTRAL:
			paths[int(card.color)] = true
	assert_eq(paths.size(), 4)
	assert_eq(multipath, 24, "all 24 multi-Path cards")


func test_general_pool_is_the_vendor_selection_by_tier() -> void:
	var tier1: Array[CardData] = PackRoller.pool(_pack(PackRules.GENERAL_1_ID), content)
	var tier2: Array[CardData] = PackRoller.pool(_pack(PackRules.GENERAL_2_ID), content)
	assert_gt(tier2.size(), tier1.size(), "the expanded selection is bigger")
	var paths: Dictionary = {}
	for card: CardData in tier1:
		assert_true(content.cards.has(card.id), "%s is in the vendor's base card set" % card.id)
		assert_true(card.rarity == CardEnums.Rarity.COMMON or card.rarity == CardEnums.Rarity.UNCOMMON, "tier 1 is commons and uncommons")
		paths[int(card.color)] = true
	assert_eq(paths.size(), 5, "any Path (and neutral)")
	assert_gt(_rarity_count(tier2, CardEnums.Rarity.EPIC), 0)
	for card: CardData in tier2:
		assert_true(content.cards.has(card.id), "%s is in the vendor's base card set" % card.id)
		assert_false(card.is_multipath())


# ---- Rolling -------------------------------------------------------------------------------------------


func test_rolls_are_deterministic_for_a_seed() -> void:
	var pack: PackData = PackCatalog.path_pack(A)
	var first: Array[CardData] = PackRoller.roll(pack, content, _rng(42))
	var second: Array[CardData] = PackRoller.roll(pack, content, _rng(42))
	assert_eq(first.size(), 3)
	for i: int in range(first.size()):
		assert_eq(first[i].id, second[i].id)


func test_rolled_cards_always_come_from_the_pool_and_never_repeat() -> void:
	for pack: PackData in PackCatalog.all():
		var pool: Array[CardData] = PackRoller.pool(pack, content)
		for seed_value: int in range(60):
			var cards: Array[CardData] = PackRoller.roll(pack, content, _rng(seed_value))
			assert_eq(cards.size(), pack.card_count, "%s holds %d cards" % [pack.id, pack.card_count])
			for card: CardData in cards:
				assert_true(pool.has(card), "%s rolled from the %s pool" % [card.id, pack.id])
				assert_false(card.not_in_packs)
			var ids: Dictionary = {}
			for card: CardData in cards:
				ids[card.id] = true
			assert_eq(ids.size(), cards.size(), "no repeats in one pack (%s seed %d)" % [pack.id, seed_value])


func test_rarity_weights_are_respected() -> void:
	var pack: PackData = PackCatalog.path_pack(D)
	var counts: Array[int] = [0, 0, 0, 0]
	var total: int = 0
	for seed_value: int in range(1500):
		for card: CardData in PackRoller.roll(pack, content, _rng(seed_value)):
			counts[int(card.rarity)] += 1
			total += 1
	assert_gt(counts[0], counts[1], "Common is the most likely")
	assert_gt(counts[1], counts[2], "then Uncommon")
	assert_gt(counts[2], counts[3], "then Epic, then Legendary")
	assert_gt(counts[3], 0, "Legendary does show up")
	assert_gt(float(counts[0]) / float(total), 0.4, "Common is a big share")
	assert_lt(float(counts[3]) / float(total), 0.1, "Legendary is rare")


func test_a_tier_one_general_pack_never_has_epics() -> void:
	var pack: PackData = _pack(PackRules.GENERAL_1_ID)
	for seed_value: int in range(300):
		for card: CardData in PackRoller.roll(pack, content, _rng(seed_value)):
			assert_true(card.rarity == CardEnums.Rarity.COMMON or card.rarity == CardEnums.Rarity.UNCOMMON)


func test_gilded_packs_always_hold_an_epic_or_legendary() -> void:
	for path: Affinity.Type in Affinity.colored_types():
		var pack: PackData = PackCatalog.gilded_pack(path)
		assert_true(pack.guarantee_epic_or_legendary)
		for seed_value: int in range(400):
			var cards: Array[CardData] = PackRoller.roll(pack, content, _rng(seed_value))
			assert_gte(_rarity_count(cards, CardEnums.Rarity.EPIC) + _rarity_count(cards, CardEnums.Rarity.LEGENDARY), 1, "%s seed %d" % [pack.id, seed_value])
			for card: CardData in cards:
				assert_true(card.color == path or card.color == Affinity.Type.NEUTRAL)


func test_prismatic_packs_always_hold_a_multipath_card() -> void:
	var pack: PackData = _pack(PackRules.PRISMATIC_ID)
	var saw_other_path: bool = false
	for seed_value: int in range(400):
		var cards: Array[CardData] = PackRoller.roll(pack, content, _rng(seed_value))
		var multipath: int = 0
		for card: CardData in cards:
			if card.is_multipath():
				multipath += 1
			elif card.color != Affinity.Type.NEUTRAL and card.color != A:
				saw_other_path = true
		assert_gte(multipath, 1, "seed %d has a multi-Path card" % seed_value)
	assert_true(saw_other_path, "cards of any Path show up")


func test_both_guarantees_are_met_together_even_in_a_one_card_pack() -> void:
	var pack: PackData = PackData.new()
	pack.card_count = 1
	pack.include_multipath = true
	pack.guarantee_multipath = true
	pack.guarantee_epic_or_legendary = true
	for seed_value: int in range(100):
		var cards: Array[CardData] = PackRoller.roll(pack, content, _rng(seed_value))
		assert_true(cards[0].is_multipath())
		assert_true(cards[0].rarity == CardEnums.Rarity.EPIC or cards[0].rarity == CardEnums.Rarity.LEGENDARY)
	pack.card_count = 3
	for seed_value: int in range(100):
		var cards: Array[CardData] = PackRoller.roll(pack, content, _rng(seed_value))
		var multipath: bool = false
		var strong: bool = false
		for card: CardData in cards:
			multipath = multipath or card.is_multipath()
			strong = strong or card.rarity == CardEnums.Rarity.EPIC or card.rarity == CardEnums.Rarity.LEGENDARY
		assert_true(multipath and strong, "both guarantees at seed %d" % seed_value)


func test_pool_rules_can_be_changed_in_data() -> void:
	var pack: PackData = PackData.new()
	pack.pool_paths = [B] as Array[Affinity.Type]
	pack.include_neutral = false
	pack.min_rarity = CardEnums.Rarity.UNCOMMON
	pack.max_rarity = CardEnums.Rarity.UNCOMMON
	for card: CardData in PackRoller.pool(pack, content):
		assert_eq(card.color, B)
		assert_eq(card.rarity, CardEnums.Rarity.UNCOMMON)


# ---- Inventory and opening ------------------------------------------------------------------------------


func test_packs_live_in_the_inventory_and_are_consumed_when_opened() -> void:
	assert_eq(Session.pack_count("path_beefcake"), 0)
	assert_null(Session.open_pack("path_beefcake"), "nothing to open")
	assert_true(Session.add_pack("path_beefcake", 2))
	assert_false(Session.add_pack("not_a_pack"))
	assert_eq(Session.pack_count("path_beefcake"), 2)
	var opening: PackOpening = Session.open_pack("path_beefcake", _rng(7))
	assert_eq(opening.entries.size(), 3)
	assert_eq(Session.pack_count("path_beefcake"), 1)
	assert_eq(Session.profile.owned_cards.size(), 3, "the cards joined the collection")
	assert_eq(opening.new_count(), 3, "all new on an empty collection")


func test_extra_copies_convert_to_essence_in_the_summary() -> void:
	var pack: PackData = PackCatalog.path_pack(A)
	# Learn which cards this seed rolls, then own four copies of each so every card converts.
	var preview: Array[CardData] = PackRoller.roll(pack, content, _rng(11))
	for card: CardData in preview:
		for i: int in range(DeckValidator.MAX_COPIES):
			Session.add_cards([card] as Array[CardData])
	Session.profile.essence.clear()
	Session.add_pack(pack.id)
	var opening: PackOpening = Session.open_pack(pack.id, _rng(11))
	assert_eq(opening.converted_count(), 3)
	assert_eq(opening.new_count(), 0)
	var essence_expected: Dictionary = {}
	var gold_expected: int = 0
	for card: CardData in preview:
		var conversion: Dictionary = Essence.conversion(card)
		for path: Variant in (conversion["essence"] as Dictionary).keys():
			essence_expected[int(path)] = int(essence_expected.get(int(path), 0)) + int((conversion["essence"] as Dictionary)[path])
		gold_expected += int(conversion["gold"])
	assert_eq(opening.essence_totals(), essence_expected)
	assert_eq(opening.gold_total(), gold_expected)
	for entry: PackOpening.Entry in opening.entries:
		assert_true(entry.converted)
		assert_false(entry.notice.is_empty())
	assert_eq(Session.profile.total_essence() + opening.gold_total() * 0, Session.profile.total_essence())
	assert_eq(Session.owned_count(preview[0].id), DeckValidator.MAX_COPIES, "still four copies")
	var total_essence: int = 0
	for path: Variant in essence_expected.keys():
		total_essence += int(essence_expected[path])
		assert_eq(Session.profile.essence_of(int(path) as Affinity.Type), int(essence_expected[path]))
	assert_eq(Session.profile.total_essence(), total_essence)


func test_new_badge_only_for_first_copies() -> void:
	var pack: PackData = PackCatalog.path_pack(B)
	var preview: Array[CardData] = PackRoller.roll(pack, content, _rng(5))
	Session.add_cards([preview[0]] as Array[CardData])
	Session.add_pack(pack.id)
	var opening: PackOpening = Session.open_pack(pack.id, _rng(5))
	assert_false(opening.entries[0].is_new, "owned already")
	assert_true(opening.entries[1].is_new)


func test_buying_a_pack_charges_the_price() -> void:
	Session.gold = 1000
	var pack: PackData = PackCatalog.path_pack(C)
	assert_true(Session.buy_pack(pack))
	assert_eq(Session.gold, 1000 - pack.price)
	assert_eq(Session.pack_count(pack.id), 1)
	Session.gold = pack.price - 1
	assert_false(Session.buy_pack(pack))
	assert_eq(Session.pack_count(pack.id), 1)


func test_packs_survive_a_save_round_trip() -> void:
	Session.add_pack("gilded_necrocrat", 2)
	Session.add_pack("prismatic")
	var data: Dictionary = Session.to_dict()
	Session.profile.packs.clear()
	assert_true(Session.from_dict(JSON.parse_string(JSON.stringify(data)) as Dictionary))
	assert_eq(Session.pack_count("gilded_necrocrat"), 2)
	assert_eq(Session.pack_count("prismatic"), 1)


# ---- Shops ----------------------------------------------------------------------------------------------


func test_path_packs_are_stocked_only_after_that_zones_first_clear() -> void:
	var state: UnlockState = Session.unlock_state()
	assert_true(PackShop.stocked(PackData.VENDOR_PACK, state).is_empty(), "nothing before any dungeon is cleared")
	assert_eq(PackShop.listing(PackData.VENDOR_PACK).size(), 5, "four Path packs plus the Prismatic Pack")
	Session.flags[str(ZoneCompletion.flag_name(GainlandsZone.ID))] = true
	var stocked: Array[PackData] = PackShop.stocked(PackData.VENDOR_PACK, Session.unlock_state())
	assert_eq(stocked.size(), 1)
	assert_eq(stocked[0].id, "path_beefcake")


func test_gilded_packs_need_the_zone_and_prismatic_needs_the_postgame() -> void:
	assert_true(PackShop.stocked(PackData.VENDOR_BLACK_MARKET, Session.unlock_state()).is_empty())
	Session.flags[str(ZoneCompletion.flag_name(DnaZone.ID))] = true
	var gilded: Array[PackData] = PackShop.stocked(PackData.VENDOR_BLACK_MARKET, Session.unlock_state())
	assert_eq(gilded.size(), 1)
	assert_eq(gilded[0].id, "gilded_necrocrat")
	var prismatic: PackData = _pack(PackRules.PRISMATIC_ID)
	assert_false(PackShop.is_visible(prismatic, Session.unlock_state()), "hidden before the postgame")
	Session.profile.postgame_unlocked = true
	assert_true(PackShop.is_unlocked(prismatic, Session.unlock_state()))


func test_general_tier_two_unlocks_by_level_or_two_zones() -> void:
	var tier2: PackData = _pack(PackRules.GENERAL_2_ID)
	var tier1: PackData = _pack(PackRules.GENERAL_1_ID)
	assert_true(PackShop.is_unlocked(tier1, Session.unlock_state()), "tier 1 from the start")
	assert_false(PackShop.is_unlocked(tier2, Session.unlock_state()))
	Session.flags[str(ZoneCompletion.flag_name(DnaZone.ID))] = true
	assert_false(PackShop.is_unlocked(tier2, Session.unlock_state()), "one zone is not enough")
	Session.flags[str(ZoneCompletion.flag_name(HeapZone.ID))] = true
	assert_true(PackShop.is_unlocked(tier2, Session.unlock_state()), "two zones unlock it")
	Session.flags.clear()
	Session.profile.level = PackCatalog.config().tier2_level
	assert_true(PackShop.is_unlocked(tier2, Session.unlock_state()), "or the set level")


func test_the_vendors_expanded_selection_unlocks_with_tier_two() -> void:
	var vendor: VendorData = VendorData.graduated(content, [A] as Array[Affinity.Type], null)
	var before: int = vendor.available_card_ids(Session.unlock_state()).size()
	Session.flags[str(ZoneCompletion.flag_name(DnaZone.ID))] = true
	Session.flags[str(ZoneCompletion.flag_name(HeapZone.ID))] = true
	var after: int = vendor.available_card_ids(Session.unlock_state()).size()
	assert_gt(after, before)
	assert_eq(after, vendor.entries.size(), "the whole selection is open")


func test_zone_path_mapping_and_unlock_flags_match_the_zone_classes() -> void:
	assert_eq(PackRules.zone_for_path(A), GainlandsZone.ID)
	assert_eq(PackRules.zone_for_path(B), BuffetZone.ID)
	assert_eq(PackRules.zone_for_path(C), HeapZone.ID)
	assert_eq(PackRules.zone_for_path(D), DnaZone.ID)
	for zone_id: String in ZoneDefs.ids():
		assert_eq(PackRules.zone_for_path(PackRules.path_for_zone(zone_id)), zone_id)
	for path: Affinity.Type in Affinity.colored_types():
		var unlock: Condition = PackCatalog.path_pack(path).unlock
		assert_eq(unlock.key, str(ZoneCompletion.flag_name(PackRules.zone_for_path(path))))
		assert_eq(PackCatalog.gilded_pack(path).unlock.key, unlock.key)


func test_every_path_has_a_pack_eligible_epic_and_legendary() -> void:
	for path: Affinity.Type in Affinity.colored_types():
		var pool: Array[CardData] = PackRoller.pool(PackCatalog.path_pack(path), content)
		assert_gte(_rarity_count(pool, CardEnums.Rarity.EPIC), 1, "%s Epic" % Affinity.display_name(path))
		assert_gte(_rarity_count(pool, CardEnums.Rarity.LEGENDARY), 1, "%s Legendary" % Affinity.display_name(path))
