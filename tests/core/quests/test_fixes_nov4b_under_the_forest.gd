extends GutTest
## Fix pass Nov 4 (B), Part 4.1: after Primm falls the player gets "Under the Forest": ask Rip at a Rift Express station, ride it to the forest, find the
## Lab's hatch south of the clearing, free Elowen. Loose Ends points at it instead of repeating its steps.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_the_quest_is_given_in_the_postgame_and_walks_rip_forest_hatch_elowen() -> void:
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.UNDER_THE_FOREST)
	assert_not_null(quest)
	assert_true(quest.auto_give)
	assert_false(Condition.met(quest.prerequisite, Session.unlock_state()), "not before Primm")
	Session.profile.postgame_unlocked = true
	assert_true(Condition.met(quest.prerequisite, Session.unlock_state()))
	Session.offer_auto_quests()  # town entry offers auto quests
	assert_true(Session.quest_log.active.has(QuestDefinitions.UNDER_THE_FOREST), "given at once in the postgame")
	assert_eq(quest.objectives.size(), 4)
	assert_eq(quest.objectives[0].target_id, "rift_station", "Rip's station first")
	assert_eq(quest.objectives[2].target_area, Areas.START, "the hatch has a map marker in the forest")
	assert_eq(quest.objectives[2].target_id, "lab")
	for flag_name: String in ["rip_forest_tip", QuestDefinitions.FLAG_FOREST_ARRIVED, QuestDefinitions.FLAG_LAB_ENTERED, str(PathologyLab.FLAG_RESCUER_FREED)]:
		Session.set_flag(StringName(flag_name))
	Session.refresh_quests()
	assert_false(Session.quest_log.active.has(QuestDefinitions.UNDER_THE_FOREST), "done once Elowen is free")


func test_loose_ends_points_at_it() -> void:
	var loose: QuestData = QuestCatalog.find(QuestDefinitions.LOOSE_ENDS)
	var found: bool = false
	for objective: QuestObjective in loose.objectives:
		if objective.text.contains("Under the Forest"):
			found = true
	assert_true(found)


func test_rips_tip_sends_the_player_south_of_the_clearing() -> void:
	var tip: String = " ".join(StoryText.shared().get_lines("travel.forest_tip"))
	assert_string_contains(tip, "south of the clearing")
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.UNDER_THE_FOREST)
	assert_string_contains(quest.objectives[3].text, "Cell 4", "the rescue (Elowen, unnamed in quest text so the reveal stays a reveal)")
