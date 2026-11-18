extends GutTest
## Nov 18 day, Part 1.3: only basic Infrastructure is unlimited. Every other Infrastructure card (INF-01..11) is collected and capped like
## a unit or spell of its rarity: it appears in packs, rewards and shops, the Deck Station counts it ("Deck 0/2  Own 1"), and an old save
## keeps the copies its decks use (up to the cap) instead of the old "Own 9999".

const SPECIAL: Array[String] = ["INF-01", "INF-02", "INF-03", "INF-04", "INF-05", "INF-06", "INF-07", "INF-08", "INF-09", "INF-10", "INF-11"]


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_basic_infrastructure_stays_unlimited() -> void:
	for value: Variant in Session.content.infrastructure.values():
		var basic: CardData = value as CardData
		assert_true(basic.is_unlimited(), basic.id)
		assert_eq(CopyCaps.for_card(basic, 1), CopyCaps.UNLIMITED)


func test_every_special_infrastructure_is_capped_by_its_rarity() -> void:
	for id: String in SPECIAL:
		var card: CardData = Session.card_by_id(id)
		assert_not_null(card, id)
		assert_false(card.is_unlimited(), "%s is not unlimited" % id)
		assert_eq(CopyCaps.for_card(card, 1), CopyCaps.cap_for(card.rarity, 1), id)
		assert_lte(CopyCaps.for_card(card, 99), 3, "never more than 3")
	assert_eq(CopyCaps.for_card(Session.card_by_id("INF-01"), 1), 2, "Uncommon: 2 at the start")
	assert_eq(CopyCaps.for_card(Session.card_by_id("INF-05"), 1), 1, "Epic: 1 at the start")
	assert_eq(CopyCaps.for_card(Session.card_by_id("INF-05"), 30), 3, "level-ups raise it to 3")


func test_the_deck_station_counts_owned_copies() -> void:
	var card: CardData = Session.card_by_id("INF-01")
	Session.profile.owned_cards.append(card)
	var editor: DeckEditor = DeckEditor.from(Session.profile, Session.deck, [] as Array[CardData])
	assert_eq(editor.owned(card), 1, "Own 1, not 9999")
	assert_eq(editor.cap_text(card), "0/2")
	assert_eq(editor.why_not_add(card), "")
	assert_true(editor.add(card))
	assert_ne(editor.why_not_add(card), "", "no second copy without owning one")
	var basic: CardData = Session.content.infrastructure[int(Affinity.Type.BEEFCAKE)] as CardData
	assert_eq(editor.cap_text(basic), "", "basics show no cap")


func test_special_infrastructure_is_in_packs_rewards_and_shops() -> void:
	var general: PackData = PackDefinitions.general(1, 60)
	var pool_ids: Array[String] = []
	for card: CardData in PackRoller.pool(general, Session.content):
		pool_ids.append(card.id)
	for id: String in ["INF-01", "INF-02", "INF-03", "INF-04"]:
		assert_has(pool_ids, id, "Uncommon %s in the General pack" % id)
	var tier2: Array[String] = []
	for card: CardData in PackRoller.pool(PackDefinitions.general(2, 61), Session.content):
		tier2.append(card.id)
	assert_has(tier2, "INF-11", "the Epic colourless one in the Tier II pack")
	assert_true(VendorStocks.sellable(Session.card_by_id("INF-01")), "shops sell it")
	assert_false(VendorStocks.sellable(Session.content.infrastructure[int(Affinity.Type.BEEFCAKE)] as CardData), "never a basic")
	var found: bool = false
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	for seed: int in range(400):
		rng.seed = seed
		for card: CardData in RewardGenerator.card_choices_for_color(Session.content, Affinity.Type.BEEFCAKE, rng, 3):
			if card.id == "INF-01":
				found = true
		if found:
			break
	assert_true(found, "a Beefcake reward can be the Beefcake Infrastructure")


func test_general_packs_do_not_favour_the_starting_path() -> void:
	var general: PackData = PackDefinitions.general(1, 60)
	var by_path: Dictionary = {}
	for card: CardData in PackRoller.pool(general, Session.content):
		if card.is_infrastructure() and card.paths().size() == 1:
			by_path[int(card.paths()[0])] = int(by_path.get(int(card.paths()[0]), 0)) + 1
	assert_eq(by_path.size(), 4, "one special Infrastructure per Path in the pool")
	for path: Variant in by_path.keys():
		assert_eq(int(by_path[path]), 1)
	assert_true(general.pool_paths.is_empty(), "no Path filter")


func test_an_old_save_keeps_the_copies_its_decks_use() -> void:
	var inf: CardData = Session.card_by_id("INF-01")
	var dual: CardData = Session.card_by_id("INF-05")
	Session.profile.owned_cards = Session.profile.owned_cards.filter(func(c: CardData) -> bool: return not c.is_infrastructure())
	var ids: Array[String] = DeckBox.ids_of(Session.deck)
	for i: int in range(5):
		ids.append("INF-01")
	ids.append("INF-05")
	ids.append("INF-05")
	Session.deck_box.set_cards(Session.deck_box.active, ids)
	var notice: String = Session.migrate_infrastructure_caps()
	assert_ne(notice, "", "the town says what happened")
	assert_eq(Session.profile.owned_copies("INF-01"), 3, "kept up to the ownership cap of 3 (Nov 18 evening)")
	assert_eq(Session.profile.owned_copies("INF-05"), 2, "the two its deck uses")
	Session.enforce_copy_caps()
	var counts: Dictionary = {}
	for id: String in Session.deck_box.decks[Session.deck_box.active].card_ids:
		counts[id] = int(counts.get(id, 0)) + 1
	assert_eq(int(counts.get("INF-01", 0)), 2, "the deck trimmed to the Uncommon deck limit")
	assert_eq(int(counts.get("INF-05", 0)), 1)
	assert_eq(Session.migrate_infrastructure_caps(), "", "runs once: a second load changes nothing")
	assert_eq(Session.profile.owned_copies("INF-01"), 3)
	assert_true(inf != null and dual != null)


func test_owned_copies_beyond_the_cap_convert_on_load() -> void:
	for i: int in range(4):
		Session.profile.owned_cards.append(Session.card_by_id("INF-02"))
	Session.enforce_copy_caps()
	assert_eq(Session.profile.owned_copies("INF-02"), 3, "a 4th converts; 3 are kept (Nov 18 evening)")


func test_starting_decks_and_the_suggester_build_legal_decks() -> void:
	for path: Affinity.Type in Affinity.colored_types():
		var deck: Deck = CampaignStart.starter_deck(Session.content, path)
		var profile: PlayerProfile = CampaignStart.new_profile(Session.content, path)
		assert_true(DeckValidator.is_valid(deck, profile, null, true), "starter of %s" % Affinity.display_name(path))
		var basics: Array[CardData] = []
		for color: Affinity.Type in Affinity.colored_types():
			basics.append(Session.content.infrastructure[int(color)] as CardData)
		var owned: Array[CardData] = profile.owned_cards.duplicate()
		owned.append(Session.card_by_id("INF-01"))
		var suggested: Deck = DeckInsights.suggest(owned, [path] as Array[Affinity.Type], 1, basics, DeckValidator.MIN_DECK_SIZE)
		profile.owned_cards = owned
		assert_true(DeckValidator.is_valid(suggested, profile, null, true), "suggested deck of %s" % Affinity.display_name(path))
