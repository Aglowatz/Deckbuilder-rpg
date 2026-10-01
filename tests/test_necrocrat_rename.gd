extends GutTest
## Part A: the Grave affinity is now the Necrocrat affinity (Afterlife Services and Labor).


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.D)


func test_affinity_display_name_is_necrocrat() -> void:
	assert_eq(UIStyle.affinity_name(Affinity.Type.D), "Necrocrat")


func test_zone_portal_and_corrupted_npc_ids_use_necrocrat() -> void:
	assert_not_null(ZonePortals.find("necrocrat"))
	assert_null(ZonePortals.find("grave"))
	assert_true(CorruptedNpcs.IDS.has("necrocrat"))
	assert_eq(CorruptedNpcs.element("necrocrat"), Affinity.Type.D)
	assert_false(CorruptedNpcs.recipe("necrocrat").is_empty())


func test_story_lines_exist_for_necrocrat_npc() -> void:
	var story: StoryText = load("res://data/story/intro_story.tres") as StoryText
	assert_false(story.npc_intro_lines("necrocrat").is_empty())
	assert_false(story.npc_victory_lines("necrocrat").is_empty())
	assert_false(story.npc_defeat_lines("necrocrat").is_empty())


func test_old_save_flag_is_migrated() -> void:
	var data: Dictionary = Session.to_dict()
	data["flags"] = {"grave_zone_unlocked": true}
	assert_true(Session.from_dict(data))
	assert_true(Session.flag(CorruptedNpcs.unlock_flag("necrocrat")))
