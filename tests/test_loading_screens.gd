extends GutTest
## Loading screens with tips (Part D of the art integration round): which art each area uses, the editable tip file, the screen itself.


func before_each() -> void:
	LoadingTips.reset()
	KeyArt.reset()


func test_each_area_has_its_loading_art() -> void:
	assert_eq(Areas.loading_id(Areas.TOWN), "LOAD-TOWN")
	assert_eq(Areas.loading_id(Areas.GAINLANDS), "LOAD-GAINLANDS")
	assert_eq(Areas.loading_id(Areas.DNA), "LOAD-DNA")
	assert_eq(Areas.loading_id(Areas.BUFFET), "LOAD-BUFFET")
	assert_eq(Areas.loading_id(Areas.DUMP), "LOAD-DUMP")
	assert_eq(Areas.loading_id(Areas.CAPITAL), "LOAD-CAPITAL")
	assert_eq(Areas.loading_id(Areas.DUNGEON), "LOAD-DUNGEON")
	assert_eq(Areas.loading_id(Areas.START), "LOAD-TOWN", "the starting area borrows the town's")
	assert_eq(Areas.loading_id(Areas.DUNGEON, PathologyLab.DUNGEON_ID), "LOAD-DNA", "the Path-ology Lab borrows the D.N.A.'s")
	for key: String in Areas.keys():
		assert_true(KeyArt.has(Areas.loading_id(key)), "%s art is imported" % key)


func test_scenes_map_to_areas() -> void:
	assert_eq(Areas.key_for_scene("res://scenes/town.tscn"), Areas.TOWN)
	assert_eq(Areas.key_for_scene("res://scenes/starting_area.tscn"), Areas.START)
	assert_eq(Areas.key_for_scene("res://scenes/dungeon_map.tscn"), Areas.DUNGEON)
	for zone_id: String in ZoneDefs.all_ids():
		var def: ZoneDef = ZoneDefs.get_def(zone_id)
		assert_eq(Areas.key_for_scene(def.scene_path), Areas.key_for_zone(zone_id), "%s scene" % zone_id)
		assert_ne(Areas.key_for_zone(zone_id), "")
	for path: String in ["res://scenes/title.tscn", "res://scenes/battle.tscn", "res://scenes/rewards.tscn", "res://scenes/ending.tscn"]:
		assert_eq(Areas.key_for_scene(path), "", "%s is not an area" % path)


func test_the_tip_file_has_about_forty_tips_of_three_kinds() -> void:
	var tips: Array[LoadingTips.Tip] = LoadingTips.all()
	assert_gte(tips.size(), 40)
	var kinds: Dictionary = {}
	for tip: LoadingTips.Tip in tips:
		kinds[tip.kind] = true
		assert_false(tip.text.is_empty())
		assert_lt(tip.text.length(), 190, "short enough for the strip: %s" % tip.text)
	for kind: String in ["hint", "keyword", "lore"]:
		assert_true(kinds.has(kind), kind)


func test_tips_parse_comments_kinds_and_zone_limits() -> void:
	var tips: Array[LoadingTips.Tip] = LoadingTips.parse("# comment\n\nhint | Do the thing.\n@LOAD-DUNGEON lore | Only down here.\nplain line\n@broken\n")
	assert_eq(tips.size(), 3)
	assert_eq(tips[0].kind, "hint")
	assert_eq(tips[1].only_for, "LOAD-DUNGEON")
	assert_eq(tips[1].text, "Only down here.")
	assert_eq(tips[2].text, "plain line")


func test_a_zone_limited_tip_only_shows_on_its_screen() -> void:
	for tip: LoadingTips.Tip in LoadingTips.for_screen("LOAD-TOWN"):
		assert_true(tip.only_for.is_empty() or tip.only_for == "LOAD-TOWN")
	var dungeon_only: int = LoadingTips.for_screen("LOAD-DUNGEON").size() - LoadingTips.for_screen("LOAD-DNA").size()
	assert_gt(dungeon_only, 0)


func test_the_pick_avoids_repeating_the_last_tip() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 7
	var last: String = LoadingTips.pick("LOAD-TOWN", rng).text
	for index: int in range(40):
		var next: LoadingTips.Tip = LoadingTips.pick("LOAD-TOWN", rng, last)
		assert_ne(next.text, last)
		last = next.text


func test_the_loading_screen_shows_art_a_tip_and_a_bar() -> void:
	var screen: LoadingScreen = LoadingScreen.make(Areas.GAINLANDS)
	assert_not_null(screen)
	add_child_autofree(screen)
	await wait_frames(2)
	assert_eq((screen.find_child("LoadingArt", true, false) as TextureRect).texture, KeyArt.texture("LOAD-GAINLANDS"))
	assert_false((screen.find_child("TipText", true, false) as Label).text.is_empty())
	assert_not_null(screen.find_child("Spinner", true, false))
	screen.set_progress(0.5)
	assert_almost_eq(screen.progress(), 0.5, 0.001)
	assert_gte(LoadingScreen.MIN_SECONDS, 1.0, "long enough not to flash")


func test_no_loading_screen_for_a_scene_that_is_not_an_area() -> void:
	assert_null(LoadingScreen.make(""))
