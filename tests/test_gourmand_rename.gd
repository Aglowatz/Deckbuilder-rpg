extends GutTest
## Part A (brief 7): the Tide affinity is now the Gourmand affinity.


func test_affinity_display_name_is_gourmand() -> void:
	assert_eq(UIStyle.affinity_name(Affinity.Type.GOURMAND), "Gourmand")


func test_zone_portal_is_the_path_of_the_gourmand() -> void:
	var info: ZonePortals.Info = ZonePortals.find("gourmand")
	assert_not_null(info)
	assert_null(ZonePortals.find("tide"))
	assert_true(info.display_name == "Path of the Gourmand" or info.display_name == "The Endless Buffet")


func test_corrupted_npc_ids_use_gourmand() -> void:
	assert_true(CorruptedNpcs.IDS.has("gourmand"))
	assert_false(CorruptedNpcs.IDS.has("tide"))
	assert_eq(CorruptedNpcs.element("gourmand"), Affinity.Type.GOURMAND)
	assert_eq(CorruptedNpcs.unlock_flag("gourmand"), &"gourmand_zone_unlocked")
