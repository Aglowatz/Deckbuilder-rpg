extends GutTest
## Cards Oct 27, Part 2: who can get which card (`CardAvailability`, `data/source/card_overrides.csv`, docs/design/card_availability.md):
## the flags import, every generator filters, enemy decks keep signatures only for their owner, the unlock flow, grandfathering.

var content: ContentSet


func before_all() -> void:
	content = ContentLibrary.load_all()


func _card(id: String) -> CardData:
	var card: CardData = content.card(id)
	assert_not_null(card, id)
	return card


func _rng(seed_value: int = 1) -> RandomNumberGenerator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


# ---- The flags ------------------------------------------------------------------------------------------------


func test_the_overrides_import_availability_and_source() -> void:
	assert_eq(CardAvailability.kind_of(_card("N-33")), CardAvailability.Kind.ENEMY_ONLY, "Mortimer is enemy-only")
	assert_eq(_card("N-33").availability_source, "Mortimer Grimsby, CE-No")
	assert_eq(CardAvailability.kind_of(_card("N-30")), CardAvailability.Kind.ENEMY_ONLY, "Betty Bones")
	assert_eq(CardAvailability.kind_of(_card("NB-16")), CardAvailability.Kind.ENEMY_ONLY, "Chancellor Clench")
	assert_eq(CardAvailability.kind_of(_card("P4-03")), CardAvailability.Kind.ENEMY_ONLY, "Mr. Tiggle")
	assert_eq(CardAvailability.kind_of(_card("N-29")), CardAvailability.Kind.REWARD_LOCKED, "Mass Layoffs: the Hall's prize")
	assert_true(_card("N-29").availability_source.contains("Hall of Final Approvals"))
	assert_eq(CardAvailability.kind_of(_card("B-05")), CardAvailability.Kind.GENERAL, "a Common is general")
	assert_eq(CardAvailability.kind_of(_card("B-35")), CardAvailability.Kind.GENERAL, "the new Commons are general")
	assert_eq(CardAvailability.parse("reward-locked"), CardAvailability.Kind.REWARD_LOCKED)
	assert_eq(CardAvailability.parse("ENEMY_ONLY"), CardAvailability.Kind.ENEMY_ONLY)
	assert_eq(CardAvailability.parse(""), CardAvailability.Kind.GENERAL)


func test_allowed_follows_the_three_kinds() -> void:
	assert_true(CardAvailability.allowed(_card("B-05")))
	assert_false(CardAvailability.allowed(_card("N-29")), "locked until earned")
	assert_true(CardAvailability.allowed(_card("N-29"), {"N-29": true}), "earned once: available at its rarity")
	assert_false(CardAvailability.allowed(_card("N-33"), {"N-33": true}), "enemy-only: never, even if owned")


func test_every_dungeon_prize_and_boss_pick_is_reward_locked() -> void:
	var locked: Array[String] = ["P4-02", "B-31", "B-30", "G-27", "N-31", "R-27", "C-29", "C-21", "G-30", "P4-01"]
	locked.append_array(ZoneCards.MAIN_DUNGEON_REWARD_IDS)
	locked.append_array(DungeonSignatures.all_ids())
	for id: String in locked:
		assert_true(CardAvailability.is_reward_locked(_card(id)), "%s is reward-locked" % id)
	for id: String in ["B-32", "G-33", "R-33", "N-29"]:
		assert_true(ZoneCards.MAIN_DUNGEON_REWARD_IDS.has(id))
	assert_eq(ZoneCards.MINI_DUNGEON_REWARD_ID, "N-31", "the Waiting Room pays the Department now")


# ---- Generators -----------------------------------------------------------------------------------------------


func test_packs_never_roll_enemy_only_or_unearned_locked_cards_and_roll_locked_ones_once_earned() -> void:
	var seen_locked_after: bool = false
	for pack: PackData in PackCatalog.all():
		for card: CardData in PackRoller.pool(pack, content):
			assert_false(CardAvailability.is_enemy_only(card), "%s in %s" % [card.id, pack.id])
			assert_false(CardAvailability.is_reward_locked(card), "%s in %s before it is earned" % [card.id, pack.id])
		for seed_value: int in range(1, 30):
			for card: CardData in PackRoller.roll(pack, content, _rng(seed_value)):
				assert_true(CardAvailability.allowed(card), "%s rolled %s" % [pack.id, card.id])
	var everything: Dictionary = {}
	for card: Variant in content.cards.values():
		everything[(card as CardData).id] = true
	for pack: PackData in PackCatalog.all():
		for card: CardData in PackRoller.pool(pack, content, everything):
			assert_false(CardAvailability.is_enemy_only(card), "%s still never in %s" % [card.id, pack.id])
			if CardAvailability.is_reward_locked(card):
				seen_locked_after = true
	assert_true(seen_locked_after, "an earned locked card joins a pool at its rarity")


func test_vendor_shelves_filter_by_availability() -> void:
	var state: UnlockState = UnlockState.new()
	state.player_level = 30
	state.zones_completed = 4
	state.postgame = true
	state.cleared_dungeons = [TrialOfTheHollow.DUNGEON_NAME] as Array[String]
	for path: Affinity.Type in Affinity.colored_types():
		var shelf: VendorData = VendorStocks.zone_shelf(content, path, "x", [] as Array[String], "x", state)
		for entry: VendorStockEntry in shelf.entries:
			assert_true(CardAvailability.allowed(_card(entry.card_id)), "%s on a shelf unearned" % entry.card_id)
	for entry: VendorStockEntry in VendorStocks.sable_sample(content, state, Condition.dungeon_cleared(TrialOfTheHollow.DUNGEON_NAME)).entries:
		assert_true(CardAvailability.allowed(_card(entry.card_id)), "%s at Sable's unearned" % entry.card_id)
	# Earned: the Necrocrat shelf's late tier may carry the earned prize; Mortimer never.
	state.earned_cards = {"N-29": true, "N-33": true, "N-31": true}
	var necro: VendorData = VendorStocks.zone_shelf(content, Affinity.Type.NECROCRAT, "necrocrat", ZoneCards.VENDOR_IDS, "x", state)
	var ids: Array[String] = []
	for entry: VendorStockEntry in necro.entries:
		ids.append(entry.card_id)
	assert_true(ids.has("N-29"), "Mass Layoffs sells once earned (an Epic, after the boss)")
	assert_true(ids.has("N-31"), "the Department sells once earned")
	assert_false(ids.has("N-33"), "Mortimer never")
	assert_false(VendorStocks.sellable(_card("N-33"), {"N-33": true}))


func test_reward_picks_and_dungeon_picks_filter_by_availability() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	profile.primary_affinity = Affinity.Type.NECROCRAT
	for seed_value: int in range(1, 40):
		for card: CardData in RewardGenerator.card_choices(content, profile, _rng(seed_value), 3, true):
			assert_true(CardAvailability.allowed(card), "dungeon pick offered %s" % card.id)
		for card: CardData in RewardGenerator.card_choices_for_color(content, Affinity.Type.NECROCRAT, _rng(seed_value), 3, true):
			assert_true(CardAvailability.allowed(card), "tutorial pick offered %s" % card.id)
		for card: CardData in RewardPicks.choose(content, _rng(seed_value), [Affinity.Type.NECROCRAT] as Array[Affinity.Type], Affinity.Type.NECROCRAT, 20, true, false):
			assert_true(CardAvailability.allowed(card), "elite/boss pick offered %s" % card.id)
	# Earned (owned one copy): the locked Epic can be offered by a boss pick.
	var found: bool = false
	for seed_value: int in range(1, 200):
		for card: CardData in RewardPicks.choose(content, _rng(seed_value), [Affinity.Type.NECROCRAT] as Array[Affinity.Type], Affinity.Type.NECROCRAT, 20, true, false, {"N-29": 1}):
			assert_ne(card.id, "N-33")
			if card.id == "N-29":
				found = true
	assert_true(found, "an earned locked card can come up again in a pick")


func test_the_alchemist_never_crafts_clench_and_crafts_the_clerk_once_earned() -> void:
	var pool: Array[CardData] = Alchemy.possible_cards(content, Affinity.Type.NECROCRAT, Affinity.Type.BEEFCAKE)
	var ids: Array[String] = []
	for card: CardData in pool:
		ids.append(card.id)
	assert_false(ids.has("NB-16"), "Chancellor Clench is enemy-only")
	assert_false(ids.has("NB-17"), "the Iron Filing Clerk is locked until Clench's pick")
	assert_true(ids.has("NB-02"), "the pair's general cards are there")
	ids.clear()
	for card: CardData in Alchemy.possible_cards(content, Affinity.Type.NECROCRAT, Affinity.Type.BEEFCAKE, {"NB-17": true}):
		ids.append(card.id)
	assert_true(ids.has("NB-17"))
	assert_false(ids.has("NB-16"))


# ---- Enemy decks ----------------------------------------------------------------------------------------------


func test_generic_archetypes_hold_no_enemy_only_card() -> void:
	for key: Variant in EnemyDecks.ARCHETYPES.keys():
		var cards: Dictionary = (EnemyDecks.ARCHETYPES[key] as Dictionary)["cards"] as Dictionary
		assert_eq(CardAvailability.enemy_only_ids(content, cards.keys()), [] as Array[String], "archetype %s" % str(key))


func test_from_recipe_keeps_a_signature_for_its_owner_only() -> void:
	var recipe: Dictionary = {"BAS-N": 4, "N-33": 1, "N-01": 2}
	var mortimer: Deck = ZoneDecks.from_recipe(content, "Mortimer Grimsby, CE-No", recipe)
	assert_eq(mortimer.count_of("N-33"), 1, "Mortimer plays his own card")
	var clerk: Deck = ZoneDecks.from_recipe(content, "Intake Clerk", recipe)
	assert_eq(clerk.count_of("N-33"), 0, "a generic foe does not")
	assert_eq(clerk.count_of("N-01"), 2)
	var primm: Deck = ZoneDecks.from_recipe(content, "Primm (unraveling)", {"P4-03": 1, "BAS-B": 2})
	assert_eq(primm.count_of("P4-03"), 1, "every phase of Primm may run Mr. Tiggle")
	assert_true(CardAvailability.owner_allows(_card("NB-16"), "Chancellor Clench, Iron Regent"))
	assert_false(CardAvailability.owner_allows(_card("NB-16"), "Trophy Hall Honor Guard"))


func test_the_named_bosses_keep_their_signatures_in_the_built_dungeons() -> void:
	var hall: MainDungeonDef = MainDungeons.def("necrocrat")
	var mortimer: MainDungeonDef.Foe = hall.foe("Mortimer Grimsby, CE-No")
	assert_not_null(mortimer)
	assert_true(mortimer.recipe.has("N-33"), "Mortimer's recipe names his card")
	var deck: Deck = ZoneDecks.from_recipe(content, mortimer.enemy_name, mortimer.recipe)
	assert_eq(deck.count_of("N-33"), 1)
	for name: Variant in hall.foes.keys():
		var foe: MainDungeonDef.Foe = hall.foe(str(name))
		if foe.enemy_name != mortimer.enemy_name:
			assert_false(foe.recipe.has("N-33"), "%s has no Mortimer" % foe.enemy_name)
			assert_false(foe.recipe.has("N-30"), "%s has no Betty" % foe.enemy_name)
	var gains: MainDungeonDef = MainDungeons.def("beefcake")
	var clench: MainDungeonDef.Foe = gains.foe("Chancellor Clench, Iron Regent")
	assert_not_null(clench)
	assert_true(clench.recipe.has("NB-16"), "Clench plays his own card")
	assert_eq(ZoneDecks.from_recipe(content, clench.enemy_name, clench.recipe).count_of("NB-16"), 1)


# ---- The unlock flow and old saves (Session) ---------------------------------------------------------------------


func test_earning_a_locked_card_unlocks_it_and_old_saves_keep_enemy_only_cards_grandfathered() -> void:
	Session.new_game()
	Session.ensure_game(Affinity.Type.NECROCRAT)
	assert_false(Session.card_available(_card("N-29")), "locked before the Hall")
	Session.add_cards([_card("N-29")] as Array[CardData])
	assert_true(Session.earned_cards.has("N-29"), "earned from its source")
	assert_true(Session.card_available(_card("N-29")))
	assert_true(Session.unlock_state().earned_cards.has("N-29"))
	assert_true(Session.earned_cards_map().has("N-01"), "owned cards count as earned")
	# An old save that owns Mortimer: kept and grandfathered on load; the collection percent leaves enemy-only cards out.
	Session.profile.owned_cards.append(_card("N-33"))
	var saved: Dictionary = Session.to_dict()
	Session.new_game()
	assert_true(Session.from_dict(saved))
	assert_eq(Session.owned_count("N-33"), 1, "no removal")
	assert_true(Session.grandfathered_cards.has("N-33"), "marked grandfathered")
	assert_true(Session.earned_cards.has("N-29"), "the earned set survives the save")
	assert_false(Session.card_available(_card("N-33")), "still never generated")
	var total: int = 0
	for card: Variant in Session.content.cards.values():
		if not (card as CardData).is_token and not CardAvailability.is_enemy_only(card as CardData):
			total += 1
	var found: int = 0
	for card: Variant in Session.content.cards.values():
		if not (card as CardData).is_token and not CardAvailability.is_enemy_only(card as CardData) and Session.has_seen((card as CardData).id):
			found += 1
	assert_eq(Session.collection_percent(), int(floor(100.0 * float(found) / float(total))), "enemy-only cards are outside the 100%")
	Session.new_game()


func test_the_dev_menu_refuses_locked_cards_without_the_override() -> void:
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	var refused: String = DevActions.add_card("N-33", false)
	assert_true(refused.contains("ENEMY-ONLY"), refused)
	assert_eq(Session.owned_count("N-33"), 0)
	var locked: String = DevActions.add_card("N-29", false)
	assert_true(locked.contains("REWARD-LOCKED"), locked)
	var forced: String = DevActions.add_card("N-33", true)
	assert_true(forced.begins_with("+1"), forced)
	assert_eq(Session.owned_count("N-33"), 1)
	assert_true(Session.grandfathered_cards.has("N-33"), "the override marks it grandfathered")
	Session.new_game()


func test_a_main_dungeon_boss_offers_its_chase_card_until_earned() -> void:
	assert_eq(DungeonSignatures.boss_pick_id("D-HFA"), "N-19")
	assert_eq(DungeonSignatures.boss_pick_id("D-HOG"), "NB-17")
	assert_eq(DungeonSignatures.boss_pick_id("nope"), "")
	for id: String in DungeonSignatures.all_ids():
		assert_true(CardAvailability.is_reward_locked(_card(id)), "%s is locked to its boss's pick" % id)
