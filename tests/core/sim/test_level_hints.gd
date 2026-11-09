extends GutTest
## Day pass Nov 9: the "travellers here are usually around level N" hint at dungeon entrances and on the map (LevelHints).


func test_every_dungeon_but_the_tutorial_cave_has_a_hint() -> void:
	for plan: DungeonCatalog.Blueprint in DungeonCatalog.all():
		if plan.id == "D-TUT":
			assert_eq(LevelHints.text(plan.id), "", "the level-1 cave says nothing")
			continue
		assert_gt(LevelHints.expected_level(plan.id), 1, "%s has an expected level in ProgressionModel.LEVELS" % plan.id)
		assert_true(LevelHints.text(plan.id).begins_with("Travellers here are usually around level "), plan.id)


func test_the_walls_the_bot_hit_read_their_model_levels() -> void:
	assert_eq(LevelHints.text("D-PC"), "Travellers here are usually around level 21.")
	assert_eq(LevelHints.text("S-GALLERY"), "Travellers here are usually around level 26.")
	assert_eq(LevelHints.text("S-NECRO"), "Travellers here are usually around level 10.")
	assert_eq(LevelHints.short_text("D-HFA"), "usually level 11")
	assert_eq(LevelHints.short_text("nowhere"), "")
	assert_eq(LevelHints.text("nowhere"), "")


func test_amber_from_two_levels_under_muted_otherwise() -> void:
	assert_false(LevelHints.is_under("D-HFA", 11), "at level: fine")
	assert_false(LevelHints.is_under("D-HFA", 10), "one under: still muted")
	assert_true(LevelHints.is_under("D-HFA", 9), "two under: amber")
	assert_true(LevelHints.is_under("D-HFA", 5))
	assert_eq(LevelHints.colour("D-HFA", 9), LevelHints.AMBER)
	assert_eq(LevelHints.colour("D-HFA", 12), LevelHints.MUTED)
	assert_false(LevelHints.is_under("D-TUT", 1), "no hint, never amber")


func test_the_map_point_carries_its_dungeon() -> void:
	var poi: MapPoi = MapPoi.make(MapPoi.Kind.DUNGEON, Vector3.ZERO, "Primm's Castle")
	assert_eq(poi.dungeon_id, "", "plain points name no dungeon")
	poi.dungeon_id = "D-PC"
	assert_eq(LevelHints.short_text(poi.dungeon_id), "usually level 21")
