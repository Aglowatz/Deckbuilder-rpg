extends GutTest
## Nov 1: "Loose Ends", the postgame's pointer to Mount Swolympus, the Path-ology Lab and the Arena (the quest log was empty after the credits).


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_loose_ends_waits_for_the_postgame_then_is_given_and_tracked() -> void:
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.LOOSE_ENDS)
	assert_not_null(quest)
	assert_eq(quest.objectives.size(), 4)
	Session.offer_auto_quests()
	assert_false(Session.quest_log.is_active(QuestDefinitions.LOOSE_ENDS), "not during the story")
	Session.profile.postgame_unlocked = true
	Session.offer_auto_quests()  # town entry offers auto quests
	assert_true(Session.quest_log.is_active(QuestDefinitions.LOOSE_ENDS), "given at once after Primm (old postgame saves too, on load)")


func test_its_steps_follow_real_progress() -> void:
	Session.profile.postgame_unlocked = true
	Session.offer_auto_quests()  # town entry offers auto quests
	Session.set_flag(&"rip_forest_tip")
	Session.set_flag(ArenaDefs.flag_name(ArenaDefs.all()[0].id))
	Session.refresh_quests()
	assert_true(Session.quest_log.is_active(QuestDefinitions.LOOSE_ENDS), "two steps left: the summit and the Lab")
	Session.cleared_dungeons.append("The Ascent of Mount Swolympus")
	Session.cleared_dungeons.append("The Path-ology Lab")
	Session.refresh_quests()
	assert_false(Session.quest_log.is_active(QuestDefinitions.LOOSE_ENDS), "all four done: the quest is ready or complete")
