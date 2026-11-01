extends GutTest
## Fable pass Nov 1, Part 3: the first-clear XP bonus scales with the dungeon's tier (DungeonClearBonus) - main dungeons a bigger
## fraction of a level than side dungeons, later dungeons more than earlier ones - and every dungeon def carries it.


func test_the_bonus_grows_with_the_tier_and_mains_pay_more_than_sides() -> void:
	var hog: int = DungeonClearBonus.main_xp("D-HOG")
	var hfa: int = DungeonClearBonus.main_xp("D-HFA")
	var ttk: int = DungeonClearBonus.main_xp("D-TTK")
	var rot: int = DungeonClearBonus.main_xp("D-ROT")
	assert_true(hog < hfa and hfa < ttk and ttk < rot, "%d < %d < %d < %d" % [hog, hfa, ttk, rot])
	assert_gt(hog, 150, "the House of Gains pays at least the old flat 160 - 10")
	assert_lt(rot, 400, "never a whole level")
	assert_eq(hog % 5, 0, "rounded to 5s")
	var iron: int = DungeonClearBonus.side_xp("S-IRON")
	var beef: int = DungeonClearBonus.side_xp("S-BEEF")
	assert_true(iron < beef, "the Iron Cave (L6) pays less than Swolympus (L23): %d < %d" % [iron, beef])
	assert_lt(DungeonClearBonus.side_xp("S-REF"), DungeonClearBonus.main_xp("D-ROT"), "a side dungeon pays less than its zone's main one")
	assert_gt(iron, 0, "side dungeons pay XP now")
	assert_eq(DungeonClearBonus.tier_of("D-ROT", 1), ProgressionModel.level_for("D-ROT"))
	var expected: int = int(round(float(ProgressionTable.xp_step(ProgressionModel.level_for("D-ROT") + 1)) * DungeonClearBonus.MAIN_FRACTION / 5.0)) * 5
	assert_eq(rot, expected, "a fraction of the next level's step")


func test_every_dungeon_def_carries_its_tier_bonus() -> void:
	for key: String in ["beefcake", "necrocrat", "gourmand", "refusemancer"]:
		var def: MainDungeonDef = MainDungeons.def(key)
		assert_eq(def.reward_xp, DungeonClearBonus.main_xp(def.dungeon_id), "%s first clear XP" % key)
	assert_eq(MainDungeons.def("final").reward_xp, 400, "Primm's Castle keeps its prize")
	var checked: int = 0
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		if not blueprint.is_side() or blueprint.id == PathologyLab.DUNGEON_ID:
			continue
		var def: MainDungeonDef = MainDungeons.def(blueprint.id)
		if def == null:
			continue
		assert_eq(def.reward_xp, DungeonClearBonus.side_xp(blueprint.id), "%s first clear XP" % blueprint.id)
		checked += 1
	assert_gt(checked, 5, "side dungeons checked: %d" % checked)
