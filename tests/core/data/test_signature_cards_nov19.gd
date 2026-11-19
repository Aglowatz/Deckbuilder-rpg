extends CardTestBase
## Overnight Nov 19 (Part 4): signature cards of the mini dungeons (first clear, never in packs, the zone's shop after the clear), the new
## Baron Quadzilla card, the Department of Final Approvals back to normal, and the Gilded General Pack at Foil Fenwick's after four zones.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_every_mini_dungeon_awards_its_signature_card() -> void:
	for dungeon_id: String in SignatureCards.TABLE.keys():
		var plan: DungeonCatalog.Blueprint = DungeonCatalog.find(dungeon_id)
		assert_not_null(plan, dungeon_id)
		assert_eq(plan.reward_card_id(), SignatureCards.card_for(dungeon_id), "%s pays its signature card first" % dungeon_id)
		assert_not_null(CardSet.card(SignatureCards.card_for(dungeon_id)), SignatureCards.card_for(dungeon_id))


func test_signature_cards_are_never_in_packs() -> void:
	CardSet.load_all()
	for dungeon_id: String in SignatureCards.TABLE.keys():
		var card: CardData = CardSet.card(SignatureCards.card_for(dungeon_id))
		assert_true(card.not_in_packs, "%s never in packs" % card.display_name)


func test_the_department_is_a_normal_card_again() -> void:
	var card: CardData = CardSet.card("N-31")
	assert_eq(CardAvailability.kind_of(card), CardAvailability.Kind.GENERAL)
	assert_false(card.not_in_packs)


func test_the_shop_sells_a_signature_card_only_after_the_first_clear() -> void:
	var state: UnlockState = Session.unlock_state()
	var shelf: VendorData = VendorStocks.zone_shelf(Session.content, Affinity.Type.NECROCRAT, "necrocrat", ZoneCards.VENDOR_IDS, "x", state)
	var ids: Array[String] = []
	for entry: VendorStockEntry in shelf.entries:
		ids.append(entry.card_id)
	assert_false(ids.has("N-30"), "not before the clear (not even a teaser)")
	Session.set_flag(SignatureCards.cleared_flag("S-NECRO"))
	shelf = VendorStocks.zone_shelf(Session.content, Affinity.Type.NECROCRAT, "necrocrat", ZoneCards.VENDOR_IDS, "x", Session.unlock_state())
	ids.clear()
	for entry: VendorStockEntry in shelf.entries:
		ids.append(entry.card_id)
	assert_true(ids.has("N-30"), "Betty Bones sells at the D.N.A.'s shop after the clear")
	var gainlands: Array[Array] = SignatureCards.for_shop("beefcake")
	assert_eq(gainlands.size(), 2, "the Gainlands sells two: Barbell and Baron Quadzilla")
	assert_eq(SignatureCards.for_shop("final").size(), 2, "the Capital sells two")
	assert_eq(SignatureCards.for_shop("town")[0][0], "C-21", "the Vault's at Sable's")


func test_swolympus_and_the_iron_cave_keep_their_own_first_clear() -> void:
	assert_ne(SignatureCards.cleared_flag("S-BEEF"), SignatureCards.cleared_flag("S-IRON"))


func test_first_clear_shows_the_card_on_the_clear_screen() -> void:
	Session.begin_zone_visit("necrocrat")
	Session.dungeon_key = "S-NECRO"
	Session.pending_popups.clear()
	var result: Dictionary = Session.resolve_mini_dungeon(true)
	assert_true(bool(result.get("first_clear", false)))
	var shown: bool = false
	for summary: Variant in Session.pending_popups:
		var reward: RewardSummary = summary as RewardSummary
		if reward != null and not reward.cards.is_empty() and reward.cards[0].id == "N-30":
			shown = true
	assert_true(shown, "a reward box with the card itself")
	assert_eq(Session.owned_count("N-30"), 1)


func test_baron_quadzilla_as_built() -> void:
	var card: CardData = CardSet.card("B-37")
	assert_eq(card.display_name, "Baron Quadzilla, Lord of Leg Day")
	assert_eq(card.rarity, CardEnums.Rarity.EPIC)
	assert_eq(card.generic_cost, 3)
	assert_eq(card.colored_pips.size(), 2)
	assert_eq(card.attack, 5)
	assert_eq(card.defense, 6)
	assert_true(card.has_keyword(CardEnums.Keyword.BULLDOZE) or card.script_text.contains("kw bulldoze"))
	assert_true(CardArt.has_art("B-37"), "stand-in art until Batch 18")


func test_baron_quadzilla_makes_two_iron_and_pumps_the_team() -> void:
	var game: GameState = _game()
	_energy(game)
	var ally: CardInstance = _unit(game, 0, 2, 2)
	var irons: int = _count(game, 0, KIND.IRON)
	var baron: CardInstance = _play(game, "B-37")
	assert_eq(_count(game, 0, KIND.IRON), irons + 2, "two Iron on entry")
	assert_true(game.players[0].field.has(baron))
	game.phase = GameState.Phase.MAIN1
	game.active = 0
	game.advance_phase()
	assert_eq(game.get_attack(ally), 3, "the AI-side automatic yes: another unit gets +1/+0 at the beginning of combat")
	assert_true(game.unit_has_keyword(ally, CardEnums.Keyword.BULLDOZE))
	assert_eq(game.get_attack(baron), 5, "not himself")


func test_the_gilded_general_pack_sells_after_four_zones() -> void:
	var pack: PackData = PackCatalog.find("gilded_general")
	assert_eq(pack.sold_by, PackData.VENDOR_PACK)
	assert_false(PackShop.is_unlocked(pack, Session.unlock_state()))
	for zone_id: String in ["beefcake", "gourmand", "necrocrat", "refusemancer"]:
		Session.complete_zone(zone_id)
	assert_true(PackShop.is_unlocked(pack, Session.unlock_state()), "all four zones free")
