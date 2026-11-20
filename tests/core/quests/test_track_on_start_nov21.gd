extends GutTest
## Fable Nov 21 (Part 7.3): a quest that starts on its own becomes the tracked quest, with a short toast.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_under_the_old_well_is_tracked_when_it_starts_by_itself() -> void:
	Session.set_flag(&"trial_cleared")
	Session.offer_auto_quests()
	DevActions.set_quest_step("town_outskirts_watch", 0)
	assert_eq(Session.quest_log.tracked_id(), "town_outskirts_watch", "the player follows another quest")
	DevActions.set_quest_step(ZoneQuestDefinitions.SIDE_TOWN, 1)
	Session.quest_log.track("town_outskirts_watch")
	var notices: Array[String] = []
	var catch: Callable = func(text: String, _important: bool) -> void: notices.append(text)
	EventBus.quest_notice.connect(catch)
	assert_true(Session.turn_in_quest(ZoneQuestDefinitions.SIDE_TOWN))
	Session.offer_auto_quests()
	EventBus.quest_notice.disconnect(catch)
	var way_in: String = ZoneQuestDefinitions.way_in_id("S-TOWN")
	assert_true(Session.quest_log.is_active(way_in), "the follow-up started by itself")
	assert_eq(Session.quest_log.tracked_id(), way_in, "and it is the tracked quest now")
	assert_has(notices, "Now tracking: Under the Old Well", "with a short toast")


func test_a_batch_of_new_quests_keeps_the_old_rule() -> void:
	Session.set_flag(&"trial_cleared")
	var notices: Array[String] = []
	var catch: Callable = func(text: String, _important: bool) -> void: notices.append(text)
	EventBus.quest_notice.connect(catch)
	Session.offer_auto_quests()
	EventBus.quest_notice.disconnect(catch)
	for text: String in notices:
		assert_false(text.begins_with("Now tracking:"), "several quests at once: no tracker toast (%s)" % text)
