extends GutTest
## Part A (brief 8): the Root affinity is now the Refusemancer affinity.


func test_affinity_display_name_is_refusemancer() -> void:
	assert_eq(UIStyle.affinity_name(Affinity.Type.C), "Refusemancer")


func test_zone_portal_is_the_path_of_the_refusemancer() -> void:
	var info: ZonePortals.Info = ZonePortals.find("refusemancer")
	assert_not_null(info)
	assert_null(ZonePortals.find("root"))
	assert_true(info.display_name == "Path of the Refusemancer" or info.display_name == "The Verdant Dump")


func test_corrupted_npc_ids_use_refusemancer() -> void:
	assert_true(CorruptedNpcs.IDS.has("refusemancer"))
	assert_false(CorruptedNpcs.IDS.has("root"))
	assert_eq(CorruptedNpcs.element("refusemancer"), Affinity.Type.C)
	assert_eq(CorruptedNpcs.unlock_flag("refusemancer"), &"refusemancer_zone_unlocked")
