extends GutTest
## Overnight Nov 10-11 (Part 2.2, the wayfinding critic's second run): "finish a favour" accepts the zone's side-dungeon quest too (the
## critic finished Brother Bramble's Who Ate the Compost? and the step did not move); a part of the current step done (the Magic Bean
## picked up, the bridge grown) is announced as a "Quest updated" notice with the part's name; the favour hints say any local's quest counts.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.REFUSEMANCER)
	Session.quest_log.reset()
	Session.flags = {QuestDefinitions.LEGACY_FLAG: true}
	Session.counters = {}


func _dump_line_at_favour_step() -> QuestData:
	Session.set_flag(CorruptedNpcs.unlock_flag("refusemancer"))
	Session.set_flag(Gatekeepers.entered_flag("refusemancer"))
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.zone_main_id("refusemancer"))
	Session.quest_log.start(quest, Session.unlock_state())
	assert_eq(Session.quest_log.current_index(quest, Session.unlock_state()), 2, "the favour step is current")
	return quest


func test_the_side_dungeon_quest_counts_as_the_zones_favour() -> void:
	var quest: QuestData = _dump_line_at_favour_step()
	Session.quest_log.completed.append(ZoneQuestDefinitions.SIDE_REF)
	assert_eq(Session.quest_log.current_index(quest, Session.unlock_state()), 3, "Who Ate the Compost? done: the dungeon step is current")
	for zone_id: String in ["beefcake", "necrocrat", "gourmand", "refusemancer"]:
		assert_true(QuestDefinitions.ZONE_SIDE_QUEST.has(zone_id), "%s names its side quest" % zone_id)
	for zone_id: String in ["beefcake", "gourmand", "refusemancer"]:
		var main: QuestData = QuestCatalog.find(QuestDefinitions.zone_main_id(zone_id))
		assert_string_contains(main.objectives[2].hint, "any quest one of them gives you counts", zone_id)


func test_a_part_done_is_announced_with_its_name() -> void:
	var quest: QuestData = _dump_line_at_favour_step()
	var notices: Array[Array] = []
	var catcher: Callable = func(kind: String, quest_id: String, detail: String) -> void: notices.append([kind, quest_id, detail])
	EventBus.quest_update.connect(catcher)
	Session.refresh_quests()  # the baseline: nothing announced
	notices.clear()
	Session.counters[HeapZone.stock_key("bean")] = 1  # the Magic Bean picked up: its part is done, the step is not
	Session.refresh_quests()
	EventBus.quest_update.disconnect(catcher)
	var found: bool = false
	for notice: Array in notices:
		if str(notice[0]) == "step" and str(notice[1]) == quest.id and str(notice[2]).begins_with("Done: A Magic Bean"):
			found = true
	assert_true(found, "a 'Quest updated' notice names the part that was done (%s)" % str(notices))
	assert_eq(Session.quest_log.current_index(quest, Session.unlock_state()), 2, "...and the step itself stays")
