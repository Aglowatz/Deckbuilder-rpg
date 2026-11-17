extends GutTest
## Overnight Nov 17 (docs/prompts/opus_nov17_overnight.md, Part 3): the freed Capital flies the people's banners everywhere, and after
## Primm falls the tracker keeps a clear goal (The City Gathers -> After the Fall).


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	CapitalKit.freed_city = false


func after_each() -> void:
	CapitalKit.freed_city = false


func test_regime_banners_stay_while_primm_rules() -> void:
	CapitalKit.freed_city = false
	assert_eq(CapitalKit.regime_banner("CAP-SHEET-BANNERS-01"), "CAP-SHEET-BANNERS-01")


func test_the_freed_city_turns_every_regime_banner_into_a_path_banner() -> void:
	CapitalKit.freed_city = true
	var seen: Dictionary = {}
	for _i: int in range(8):
		var id: String = CapitalKit.regime_banner("CAP-SHEET-BANNERS-03")
		assert_true(CapitalKit.FREED_BANNERS.has(id), "%s is one of the four Paths' banners" % id)
		seen[id] = true
	assert_eq(seen.size(), CapitalKit.FREED_BANNERS.size(), "all four Paths take turns")


func test_the_capital_builder_sets_the_freed_city_from_the_story() -> void:
	Session.set_flag(CapitalZone.FLAG_FREED)
	var ctx: Dictionary = CapitalBuilder.story_context()
	assert_true(bool(ctx.get("final", false)))


func test_primm_s_fall_tracks_the_ending_first() -> void:
	Session.unlock_postgame()
	assert_true(Session.quest_log.is_active(QuestDefinitions.CITY_GATHERS))
	assert_eq(Session.quest_log.tracked_id(), QuestDefinitions.CITY_GATHERS)
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.CITY_GATHERS)
	assert_eq(Session.quest_log.current_index(quest, Session.unlock_state()), 0, "See the ending")


func test_after_the_credits_the_gathering_in_grave_row_is_marked() -> void:
	Session.unlock_postgame()
	Session.set_flag(StringName(QuestDefinitions.FLAG_ENDING_SEEN))
	Session.refresh_quests()
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.CITY_GATHERS)
	assert_eq(Session.quest_log.current_index(quest, Session.unlock_state()), 1, "Join the gathering")
	var targets: Array[Dictionary] = QuestMarkers.goal_targets(CapitalZone.ID, Session.quest_log, Session.unlock_state())
	var spots: Array[String] = []
	for target: Dictionary in targets:
		spots.append(str(target["spot"]))
	assert_has(spots, "old_hob", "Old Hob in Grave Row carries the goal marker")


func test_after_the_funeral_the_lab_and_the_gallery_are_tracked_and_marked() -> void:
	Session.unlock_postgame()
	Session.set_flag(StringName(QuestDefinitions.FLAG_ENDING_SEEN))
	Session.set_flag(StringName(QuestDefinitions.FLAG_FUNERAL_SEEN))
	Session.refresh_quests()
	Session.track_postgame_goal()
	assert_true(Session.quest_log.is_completed(QuestDefinitions.CITY_GATHERS))
	assert_eq(Session.quest_log.tracked_id(), QuestDefinitions.AFTER_THE_FALL)
	var town: Array[String] = []
	for target: Dictionary in QuestMarkers.goal_targets("town", Session.quest_log, Session.unlock_state()):
		town.append(str(target["spot"]))
	assert_has(town, "rift_station", "in town the way to the forest (Rip) is marked")
	var capital: Array[String] = []
	for target: Dictionary in QuestMarkers.goal_targets(CapitalZone.ID, Session.quest_log, Session.unlock_state()):
		capital.append(str(target["spot"]))
	assert_has(capital, "gallery_mirror", "in the Capital the cracked mirror is marked")


func test_after_the_fall_completes_with_both_parts() -> void:
	Session.unlock_postgame()
	Session.set_flag(StringName(QuestDefinitions.FLAG_FUNERAL_SEEN))
	Session.refresh_quests()
	Session.track_postgame_goal()
	# the Lab played through Under the Forest's steps (asking Rip moves the tracker to that quest's own steps; when it ends it comes back)
	for flag_name: String in ["rip_forest_tip", QuestDefinitions.FLAG_FOREST_ARRIVED, QuestDefinitions.FLAG_LAB_ENTERED, str(PathologyLab.FLAG_RESCUER_FREED)]:
		Session.set_flag(StringName(flag_name))
		Session.refresh_quests()
	assert_true(Session.quest_log.is_completed(QuestDefinitions.UNDER_THE_FOREST))
	assert_false(Session.quest_log.is_completed(QuestDefinitions.AFTER_THE_FALL), "the Gallery is still left")
	assert_eq(Session.quest_log.tracked_id(), QuestDefinitions.AFTER_THE_FALL, "the tracker is back on After the Fall")
	var capital: Array[String] = []
	for target: Dictionary in QuestMarkers.goal_targets(CapitalZone.ID, Session.quest_log, Session.unlock_state()):
		capital.append(str(target["spot"]))
	assert_has(capital, "gallery_mirror")
	Session.set_flag(ShatteredGallery.FLAG_CLEARED)
	Session.refresh_quests()
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.AFTER_THE_FALL)
	assert_true(Session.quest_log.objective_met(quest, 0, Session.unlock_state()))
