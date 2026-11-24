extends GutTest
## Fable Nov 21 (Part 3): cards of three or four Paths wait for Primm. Before his defeat no source produces one (packs, reward picks,
## the reward generator, shops, Auntie Alembic, chests, quests, dungeon prizes, boss picks, the Arena) and none can be added to a deck;
## after it every source may. Owned copies stay owned. The unlock notice fires once.

var _content: ContentSet
var _before: Dictionary = {}
var _after: Dictionary = {MultiPathLock.UNLOCK_KEY: true}


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	_content = Session.content


func _multi_ids() -> Array[String]:
	var ids: Array[String] = []
	for source: Dictionary in [_content.cards, _content.multipath_cards]:
		for id: Variant in source.keys():
			if MultiPathLock.is_multi(source[id] as CardData):
				ids.append(str(id))
	ids.sort()
	return ids


func _count_multi(cards: Array) -> int:
	var total: int = 0
	for card: Variant in cards:
		if MultiPathLock.is_multi(card as CardData):
			total += 1
	return total


func _rng(seed_value: int) -> RandomNumberGenerator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


# ---- what counts ----------------------------------------------------------------------------------------------------------------------


func test_which_cards_are_locked() -> void:
	var ids: Array[String] = _multi_ids()
	assert_gte(ids.size(), 30, "the 32 three-Path cards and the four-Path cards: %d" % ids.size())
	assert_true(MultiPathLock.is_multi(_content.card("GRN-01")), "a three-Path card")
	assert_true(MultiPathLock.is_multi(_content.card("P4-02")), "a four-Path card")
	assert_false(MultiPathLock.is_multi(_content.card("NB-04")), "a two-Path card is free")
	assert_false(MultiPathLock.is_multi(_content.card("B-25")), "a one-Path card")
	assert_false(MultiPathLock.is_multi(_content.card("C-01")), "a Pathless card")
	for color: Affinity.Type in Affinity.colored_types():
		assert_false(MultiPathLock.is_multi(_content.infrastructure[int(color)] as CardData), "basic Infrastructure")
	assert_eq(MultiPathLock.kind_name(_content.card("P4-02")), "Four-Path")
	assert_eq(MultiPathLock.kind_name(_content.card("GRN-01")), "Three-Path")


func test_the_one_filter_refuses_them_until_the_unlock() -> void:
	for id: String in _multi_ids():
		var card: CardData = _content.card(id)
		assert_false(CardAvailability.allowed(card, _before), "%s before Primm" % id)
		if CardAvailability.kind_of(card) == CardAvailability.Kind.GENERAL:
			assert_true(CardAvailability.allowed(card, _after), "%s after Primm" % id)
	assert_true(CardAvailability.allowed(_content.card("NB-04"), _before), "two-Path cards are never held back")


func test_the_session_unlocks_them_with_primms_defeat() -> void:
	assert_false(Session.earned_cards_map().has(MultiPathLock.UNLOCK_KEY))
	assert_false(Session.card_available(_content.card("GRN-01")))
	Session.unlock_postgame()
	assert_true(Session.earned_cards_map().has(MultiPathLock.UNLOCK_KEY))
	assert_true(Session.unlock_state().earned_cards.has(MultiPathLock.UNLOCK_KEY), "the shops' state carries it too")
	var general: CardData = null
	for id: String in _multi_ids():
		if CardAvailability.kind_of(_content.card(id)) == CardAvailability.Kind.GENERAL:
			general = _content.card(id)
			break
	assert_not_null(general)
	assert_true(Session.card_available(general), "an ordinary three-Path card is available again")


# ---- every source, before and after ---------------------------------------------------------------------------------------------------


func test_packs_before_and_after() -> void:
	var found_after: int = 0
	for pack: PackData in PackCatalog.all():
		assert_eq(_count_multi(PackRoller.pool(pack, _content, _before)), 0, "%s: its pool before Primm" % pack.id)
		found_after += _count_multi(PackRoller.pool(pack, _content, _after))
		for seed_value: int in range(1, 41):
			assert_eq(_count_multi(PackRoller.roll(pack, _content, _rng(seed_value), _before)), 0, "%s, seed %d: a rolled pack before Primm" % [pack.id, seed_value])
	assert_gt(found_after, 0, "after Primm the packs' pools hold them again")


func test_reward_picks_before_and_after() -> void:
	var paths: Array[Affinity.Type] = [Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER, Affinity.Type.NECROCRAT]
	var seen_after: int = 0
	for seed_value: int in range(1, 121):
		for boss: bool in [false, true]:
			var before: Array[CardData] = RewardPicks.choose(_content, _rng(seed_value), paths, Affinity.Type.GOURMAND, 20, boss, false, {})
			assert_eq(_count_multi(before), 0, "seed %d: a reward pick before Primm" % seed_value)
			seen_after += _count_multi(RewardPicks.choose(_content, _rng(seed_value), paths, Affinity.Type.GOURMAND, 20, boss, false, {MultiPathLock.UNLOCK_KEY: 1}))
	assert_gt(seen_after, 0, "after Primm a three-Path foe's reward pick can hold a three-Path card")


func test_the_reward_generator_before_primm() -> void:
	for seed_value: int in range(1, 81):
		assert_eq(_count_multi(RewardGenerator.card_choices(_content, Session.profile, _rng(seed_value), 3, true, _before)), 0)
		assert_eq(_count_multi(RewardGenerator.card_choices_for_color(_content, Affinity.Type.NECROCRAT, _rng(seed_value), 3, true, _before)), 0)
		var cards: Array[CardData] = []
		RewardGenerator.with_rarity_floor(cards, _content, Session.profile, _rng(seed_value), CardEnums.Rarity.EPIC, true, _before)
		assert_eq(_count_multi(cards), 0)


func test_shops_before_primm() -> void:
	Session.set_flag(&"trial_cleared")
	Session.profile.level = 30
	for zone_id: String in ZoneDefs.ids():
		Session.complete_zone(zone_id)
	var state: UnlockState = Session.unlock_state()
	assert_false(state.earned_cards.has(MultiPathLock.UNLOCK_KEY))
	var sable: VendorData = VendorStocks.sable_sample(_content, state, Condition.dungeon_cleared(TrialOfTheHollow.DUNGEON_NAME))
	assert_gt(sable.entries.size(), 5)
	for entry: VendorStockEntry in sable.entries:
		assert_false(MultiPathLock.is_multi(_content.card(entry.card_id)), "Sable sells %s" % entry.card_id)
	var zone_paths: Dictionary = {"beefcake": Affinity.Type.BEEFCAKE, "gourmand": Affinity.Type.GOURMAND, "refusemancer": Affinity.Type.REFUSEMANCER, "necrocrat": Affinity.Type.NECROCRAT}
	for zone_id: Variant in zone_paths.keys():
		var def: ZoneDef = ZoneDefs.get_def(str(zone_id))
		var shelf: VendorData = VendorStocks.zone_shelf(_content, zone_paths[zone_id] as Affinity.Type, def.id, def.vendor_ids, def.vendor_name, state)
		assert_gt(shelf.entries.size(), 5, def.vendor_name)
		for entry: VendorStockEntry in shelf.entries:
			assert_false(MultiPathLock.is_multi(_content.card(entry.card_id)), "%s sells %s" % [def.vendor_name, entry.card_id])
		for reward: Variant in def.chest_rewards.values():
			var chest_card: String = str((reward as Dictionary).get("card", "")) if reward is Dictionary else ""
			if not chest_card.is_empty():
				assert_false(MultiPathLock.is_multi(_content.card(chest_card)), "a chest of %s holds %s" % [def.id, chest_card])
	for id: String in CapitalContent.BLACK_MARKET_CARD_IDS:
		assert_false(MultiPathLock.is_multi(_content.card(id)), "Fig Sly's black market sells %s before Primm" % id)
	for id: String in _multi_ids():
		assert_false(VendorStocks.sellable(_content.card(id), state.earned_cards), "%s is on no shelf before Primm" % id)


func test_auntie_alembic_before_and_after() -> void:
	var three: Array[Affinity.Type] = [Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER, Affinity.Type.NECROCRAT]
	assert_false(Alchemy.tri_path_unlocked(Session.profile), "the three-essence brew is shut before Primm")
	assert_false(Alchemy.tri_problem(Session.profile, 9999, three).is_empty(), "and it cannot be brewed")
	for first: Affinity.Type in Affinity.colored_types():
		for second: Affinity.Type in Affinity.colored_types():
			if int(first) < int(second):
				assert_eq(_count_multi(Alchemy.possible_cards(_content, first, second, _before)), 0, "a two-essence brew")
	Session.unlock_postgame()
	assert_true(Alchemy.tri_path_unlocked(Session.profile))
	assert_gt(Alchemy.tri_path_pool(_content, three, Session.earned_cards_map()).size(), 0, "after Primm the three-essence brew has cards")


func test_no_fixed_prize_before_primm_is_a_three_or_four_path_card() -> void:
	var fixed: Dictionary = {}
	for quest: QuestData in QuestCatalog.all():
		if DraftArenaQuests.PRIZES_AFTER_PRIMM.has(quest.id):
			# Fable big pass Nov 23: Octavia's four-Path card is a quest prize whose quest ends with "Defeat Primm"
			assert_string_contains(quest.objectives[quest.objectives.size() - 1].text, "Primm", "%s hands its prize over after Primm" % quest.id)
			continue
		for id: String in quest.reward_card_ids:
			fixed[id] = "quest %s" % quest.id
	for id: String in DungeonSignatures.all_ids():
		fixed[id] = "a boss pick"
	for id: String in ZoneCards.MAIN_DUNGEON_REWARD_IDS + [ZoneCards.MINI_DUNGEON_REWARD_ID, ZoneCards.GAINLANDS_MINI_REWARD_ID, ZoneCards.BUFFET_MINI_REWARD_ID, ZoneCards.HEAP_MINI_REWARD_ID]:
		fixed[id] = "a dungeon prize"
	for id: String in CapitalContent.QUEST_REWARD_IDS:
		fixed[id] = "a Capital quest"
	for dungeon_id: Variant in SignatureCards.TABLE.keys():
		fixed[SignatureCards.card_for(str(dungeon_id))] = "a signature card"
	for bout: ArenaEncounter in ArenaDefs.all():
		var card_id: String = str(bout.reward.get("card", "")) if bout.reward is Dictionary else ""
		if not card_id.is_empty():
			fixed[card_id] = "the Arena"
	assert_gt(fixed.size(), 12)
	for id: Variant in fixed.keys():
		if str(id).is_empty():
			continue
		assert_false(MultiPathLock.is_multi(_content.card(str(id))), "%s (%s) is given before Primm" % [id, fixed[id]])
	# the one four-Path prize is Primm's own: it is paid by his defeat
	assert_true(MultiPathLock.is_multi(_content.card(CapitalContent.FINAL_REWARD_ID)), "Reunion of the Paths is a four-Path card")
	assert_eq(PrimmsCastleDungeon.REWARD_CARD_ID, CapitalContent.FINAL_REWARD_ID)


func test_dungeon_chests_and_events_hold_none() -> void:
	var text: String = FileAccess.get_file_as_string("res://data/dungeons/dungeon_content.json")
	var regex: RegEx = RegEx.new()
	regex.compile("\"card(?::|\": \")([A-Z0-9]+-[0-9]+)")
	var checked: int = 0
	for found: RegExMatch in regex.search_all(text):
		checked += 1
		var card: CardData = _content.card(found.get_string(1))
		assert_not_null(card, found.get_string(1))
		assert_false(MultiPathLock.is_multi(card), "a dungeon chest or choice gives %s" % found.get_string(1))
	assert_gt(checked, 5, "the dungeons' card prizes were read")


func test_nothing_leaks_through_the_one_door() -> void:
	# every pack type opened three times, as the game opens them: nothing locked reaches the collection
	for pack: PackData in PackCatalog.all():
		for copy: int in range(3):
			Session.add_pack(pack.id)
	for pack: PackData in PackCatalog.all():
		while Session.pack_count(pack.id) > 0:
			assert_not_null(Session.open_pack(pack.id))
	assert_eq(Session.locked_multi_path_grants, [] as Array[String], "no pack handed over a locked card")
	Session.add_cards([_content.card("GRN-01")] as Array[CardData])
	assert_eq(Session.locked_multi_path_grants, ["GRN-01"] as Array[String], "the counter does see one when it arrives")


# ---- the deck ---------------------------------------------------------------------------------------------------------------------------


func _editor() -> DeckEditor:
	var basics: Array[CardData] = []
	for color: Affinity.Type in Affinity.colored_types():
		basics.append(_content.infrastructure[int(color)] as CardData)
	return DeckEditor.from(Session.profile, Session.deck, basics)


func test_an_owned_locked_card_stays_owned_but_cannot_be_added() -> void:
	var card: CardData = _content.card("GRN-01")
	Session.profile.owned_cards.append(card)
	assert_eq(Session.profile.owned_copies("GRN-01"), 1, "it stays in the collection")
	var editor: DeckEditor = _editor()
	assert_eq(editor.why_not_kind(card), DeckEditor.REFUSED_LOCKED)
	assert_string_contains(editor.why_not_add(card), card.display_name, "the reason names the card")
	assert_string_contains(editor.why_not_add(card), "three or four Paths")
	assert_false(editor.add(card))
	assert_eq(editor.count(card), 0)


func test_a_deck_holding_one_is_not_legal_before_primm() -> void:
	var deck: Deck = Deck.new()
	deck.cards = Session.deck.cards.duplicate()
	deck.cards.append(_content.card("GRN-01"))
	var issues: Array[DeckValidator.Issue] = DeckValidator.validate(deck, Session.profile)
	assert_true(DeckValidator.has_problem(issues, DeckValidator.Problem.LOCKED_MULTI_PATH))


func test_after_primm_it_can_be_added() -> void:
	var card: CardData = _content.card("GRN-01")
	Session.profile.owned_cards.append(card)
	Session.unlock_postgame()
	var editor: DeckEditor = _editor()
	assert_eq(editor.why_not_kind(card), "", "four Paths are allowed in the postgame, and the card is no longer sealed")
	assert_true(editor.add(card))
	var deck: Deck = Deck.new()
	deck.cards = editor.deck.cards.duplicate()
	assert_false(DeckValidator.has_problem(DeckValidator.validate(deck, Session.profile), DeckValidator.Problem.LOCKED_MULTI_PATH))


func test_a_path_over_the_limit_is_its_own_kind_of_refusal() -> void:
	var off_path: CardData = _content.card("N-01")
	Session.profile.owned_cards.append(off_path)
	var editor: DeckEditor = _editor()
	assert_eq(editor.why_not_kind(off_path), DeckEditor.REFUSED_PATHS, "one Path at the start: a second Path's card is refused for its Path")
	assert_true(DeckEditor.needs_popup(editor.why_not_kind(off_path)), "and that refusal is a pop-up")
	assert_true(DeckEditor.needs_popup(DeckEditor.REFUSED_LOCKED))
	assert_false(DeckEditor.needs_popup(DeckEditor.REFUSED_COPIES), "a copy cap stays a short line")


# ---- the game says so ---------------------------------------------------------------------------------------------------------------------


func test_the_rule_is_in_the_glossary_and_names_the_villain() -> void:
	assert_false(MultiPathLock.rule_text().contains("{"), "the villain's name is filled in")
	assert_string_contains(MultiPathLock.rule_text(), "three or four Paths")
	var source: String = FileAccess.get_file_as_string("res://ui/screens/glossary_panel.gd")
	assert_string_contains(source, "MultiPathLock.RULE_TITLE")


func test_the_unlock_notice_fires_once_after_primm() -> void:
	assert_false(Session.take_multi_path_notice(), "nothing before Primm")
	Session.unlock_postgame()
	assert_true(Session.take_multi_path_notice(), "once after his defeat")
	assert_false(Session.take_multi_path_notice(), "and never again")
	assert_string_contains(MultiPathLock.unlocked_text(), "no longer sealed")
	var town: String = FileAccess.get_file_as_string("res://world/town_scene.gd")
	assert_string_contains(town, "Session.take_multi_path_notice()", "Crosspath announces it with the other news")


func test_the_first_time_tip_shows_once_and_only_with_a_locked_card_owned() -> void:
	assert_false(Session.take_multi_path_tip(), "no locked card owned: no tip")
	Session.profile.owned_cards.append(_content.card("GRN-01"))
	assert_true(Session.take_multi_path_tip())
	assert_false(Session.take_multi_path_tip(), "once")
