extends GutTest
## Part A (brief 6): the Ember affinity is now the Beefcake affinity.


func test_affinity_display_name_is_beefcake() -> void:
	assert_eq(UIStyle.affinity_name(Affinity.Type.BEEFCAKE), "Beefcake")


func test_zone_portal_is_the_beefcake_path() -> void:
	var info: ZonePortals.Info = ZonePortals.find("beefcake")
	assert_not_null(info)
	assert_null(ZonePortals.find("ember"))
	assert_true(info.display_name.contains("Beefcake Path") or info.display_name == "The Gainlands")


func test_corrupted_npc_ids_use_beefcake() -> void:
	assert_true(CorruptedNpcs.IDS.has("beefcake"))
	assert_false(CorruptedNpcs.IDS.has("ember"))
	assert_eq(CorruptedNpcs.element("beefcake"), Affinity.Type.BEEFCAKE)
