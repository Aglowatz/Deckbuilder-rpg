extends GutTest
## Overnight Oct 17, Part 6: the level 1-30 reward track (data/progression/level_track.json): every level grants something, the
## anchors hold (L5 armory, L7/14/21 deck slots, copy caps reach 3 by 30, equipment cap raises), grants are paid on level-up,
## and the code constants agree with the data.


func before_each() -> void:
	ProgressionTable.reload()
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_max_level_is_30() -> void:
	assert_eq(ProgressionTable.MAX_LEVEL, 30)
	assert_eq(int(LevelTrack.data().get("max_level", 0)), 30)
	assert_eq(ProgressionTable.build().size(), 30)


func test_every_level_from_2_to_30_grants_something() -> void:
	var rows: Array[LevelData] = ProgressionTable.build()
	for index: int in range(1, rows.size()):
		var lines: Array[String] = ProgressionTable.reward_lines(rows[index], rows[index - 1], Affinity.Type.BEEFCAKE)
		assert_false(lines.is_empty(), "level %d grants something" % rows[index].level)
		assert_false(rows[index].headline.is_empty(), "level %d has a headline" % rows[index].level)
		assert_false(rows[index].grants.is_empty(), "level %d has a track grant (gold, a pack or a cosmetic)" % rows[index].level)


func test_anchors() -> void:
	assert_false(ProgressionTable.row(5).armory, "Oct 20: the armory quest comes from Elder Maren, not from a level")
	assert_true(ProgressionTable.row(5).big)
	for level: int in [7, 14, 21]:
		assert_true(ProgressionTable.row(level).reward_deck_expansion, "L%d: deck slots" % level)
		assert_true(ProgressionTable.row(level).big)
	for rarity: int in range(CardEnums.Rarity.size()):
		assert_eq(CopyCaps.cap_for(rarity as CardEnums.Rarity, 30), 3, "every rarity reaches 3 copies by 30")
	var copy_levels: Array[int] = []
	var equip_levels: Array[int] = []
	for row: LevelData in ProgressionTable.build():
		if not row.copy_cap_raises.is_empty():
			copy_levels.append(row.level)
		if not row.equip_cap_raises.is_empty():
			equip_levels.append(row.level)
	assert_eq(copy_levels, [9, 12, 18, 22, 30] as Array[int])
	assert_eq(equip_levels, [5, 10, 13, 16, 19, 22, 25, 28] as Array[int])


func test_code_constants_match_the_track() -> void:
	var stats: Dictionary = LevelTrack.section("stats")
	var vendor: Dictionary = LevelTrack.section("vendor")
	assert_eq(ProgressionTable._ints(stats["opening_hand"]), ProgressionTable.HAND_SIZE_LEVELS)
	assert_eq(ProgressionTable._ints(stats["item_slots"]), ProgressionTable.ITEM_SLOT_LEVELS)
	assert_eq(ProgressionTable._ints(stats["max_hand"]), ProgressionTable.MAX_HAND_LEVELS)
	assert_eq(ProgressionTable._ints(vendor["discount_levels"]), ProgressionTable.BONUS_DISCOUNT_LEVELS)
	assert_eq(ProgressionTable._ints(vendor["rare_stock_levels"]), ProgressionTable.BONUS_VENDOR_UNLOCK_LEVELS)
	assert_eq(int(vendor["equipment_advanced"]), ProgressionTable.EQUIPMENT_VENDOR_UNLOCK_LEVEL)
	assert_eq(int(vendor["item_advanced"]), ProgressionTable.ITEM_VENDOR_ADVANCED_UNLOCK_LEVEL)


func test_every_grant_names_something_real() -> void:
	for row: LevelData in ProgressionTable.build():
		for grant: Dictionary in row.grants:
			var kind: String = str(grant.get("kind", ""))
			assert_true(kind in ["gold", "pack", "cosmetic"], "L%d: known kind %s" % [row.level, kind])
			if kind == "pack":
				assert_not_null(PackCatalog.find(ProgressionTable.pack_id(grant, Affinity.Type.NECROCRAT)), "L%d pack %s" % [row.level, grant])
			if kind == "cosmetic":
				assert_not_null(CosmeticCatalog.find(str(grant["id"])), "L%d cosmetic %s" % [row.level, grant])
			if kind == "gold":
				assert_gt(int(grant["amount"]), 0)


func test_level_ups_pay_the_track_grants() -> void:
	var gold_before: int = Session.gold
	var packs_before: int = Session.profile.total_packs()
	Session.add_xp(ProgressionTable.xp_to_reach(4) - Session.profile.xp)
	assert_eq(Session.profile.level, 4)
	assert_eq(Session.gold, gold_before + 60 + 40, "L2 60 gold, L3 40 gold")
	assert_true(Session.cosmetics.owns("hat_bowler"), "L3: the Bowler Hat")
	assert_eq(Session.profile.total_packs(), packs_before + 1, "L4: a Path Pack")
	assert_eq(Session.profile.pack_count("path_beefcake"), 1, "of the player's own Path")


func test_the_curve_reaches_30() -> void:
	assert_eq(ProgressionTable.level_for_xp(ProgressionTable.xp_to_reach(30)), 30)
	for level: int in range(2, 31):
		assert_gt(ProgressionTable.xp_to_reach(level), ProgressionTable.xp_to_reach(level - 1))
