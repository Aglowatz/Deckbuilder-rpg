extends GutTest
## Fixes Nov 8 (owner): gatekeepers can be fought right away, at any time. The player is just not pointed at them (no quest, no tracker line,
## no map pin) until Maren's errands are done; a gatekeeper beaten early shows its step as done when Maren gives the quest.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.choose_starting_path(Affinity.Type.GOURMAND)
	Session.set_flag(&"trial_cleared")
	Session.offer_auto_quests()


func test_a_gatekeeper_can_be_fought_before_the_send_off() -> void:
	assert_false(PathDirection.sent_out(Session.flags))
	for zone_id: String in Gatekeepers.IDS:
		assert_true(Session.gatekeeper_can_fight(zone_id), zone_id)
		assert_false(Session.quest_log.is_active(QuestDefinitions.zone_main_id(zone_id)), "but no quest yet (%s)" % zone_id)
	assert_false(PathDirection.tracker_line(Affinity.Type.GOURMAND, Session.flags, "").contains("Fennel"), "the tracker does not name the gatekeeper")


func test_beating_one_early_counts_when_maren_gives_the_quest() -> void:
	Session.set_flag(CorruptedNpcs.unlock_flag("gourmand"))  # Chef Fennel beaten before the errands are done
	Session.quest_log.completed.append(QuestDefinitions.ARMORY)
	Session.set_flag(&"elder_greeted")
	Session.take_path_direction()
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.zone_main_id("gourmand"))
	assert_true(Session.quest_log.is_active(quest.id) or Session.quest_log.is_completed(quest.id), "the line is given")
	assert_true(Session.quest_log.objective_met(quest, 0, Session.unlock_state()), "its gatekeeper step shows done")
	assert_gte(Session.quest_log.current_index(quest, Session.unlock_state()), 1, "the tracker moves on to the next step")
