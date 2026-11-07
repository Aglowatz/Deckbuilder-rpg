extends GutTest
## Fixes Oct 25, Part 7: the quest update banner. Session announces a quest started, a step done and a quest finished
## (`EventBus.quest_update`); the banner names the quest and its NEW objective (or the reward) and queues notices one after another.

var _events: Array[Array] = []


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.choose_starting_path(Affinity.Type.BEEFCAKE)
	Session.level_track_grants = false
	Session.set_flag(&"trial_cleared")
	_events.clear()
	EventBus.quest_update.connect(_record)


func after_each() -> void:
	EventBus.quest_update.disconnect(_record)
	Session.save_enabled = true


func _record(kind: String, quest_id: String, detail: String) -> void:
	_events.append([kind, quest_id, detail])


func _kinds(quest_id: String) -> Array[String]:
	var result: Array[String] = []
	for event: Array in _events:
		if str(event[1]) == quest_id:
			result.append(str(event[0]))
	return result


func test_start_step_and_complete_are_announced_with_the_new_objective() -> void:
	Session.offer_auto_quests()
	var quest_id: String = QuestDefinitions.MERCHANTS
	# Fix pass Nov 7 (D3): the batch's one banner names the tracked quest - the Path's line - not Maren's errand
	var starts: int = 0
	for event: Array in _events:
		if str(event[0]) == "start":
			starts += 1
	assert_eq(starts, 1, "one banner for the batch (the Path line itself started at the Path choice)")
	assert_eq(_kinds(quest_id), [] as Array[String], "the errand joins the log quietly")
	var start: Dictionary = QuestNoticeLayer.notice_for("start", quest_id)
	assert_eq(str(start["header"]), "New quest")
	# Nov 3-4, Part B5: Tilly comes first now (her free item and how to equip it)
	assert_string_contains(str(start["line"]), "Tilly", "the banner names the first step")
	Session.set_flag(&"item_vendor_seen")
	Session.refresh_quests()
	assert_eq(_kinds(quest_id), ["step"] as Array[String], "a step done is announced")
	var step: Dictionary = QuestNoticeLayer.notice_for("step", quest_id)
	assert_eq(str(step["header"]), "Quest updated")
	assert_string_contains(str(step["line"]), "Equip Tilly", "the NEW objective, not the old one")
	Session.refresh_quests()
	assert_eq(_kinds(quest_id).size(), 1, "nothing new, no banner")
	Session.set_flag(&"tilly_item_equipped")
	Session.set_flag(&"vendor_seen")
	Session.bump_counter("cards_bought")
	Session.set_flag(&"item_vendor_seen")
	Session.set_flag(&"tailor_seen")
	Session.refresh_quests()
	assert_string_contains(str(QuestNoticeLayer.notice_for("step", quest_id)["line"]), "Hand in to Elder Maren")
	assert_true(Session.turn_in_quest(quest_id))
	assert_eq(_kinds(quest_id).back(), "complete")
	var reward: String = str(_events.back()[2])
	assert_string_contains(reward, "gold", "the complete banner carries the reward")


func test_notices_queue_and_merge() -> void:
	var layer: QuestNoticeLayer = QuestNoticeLayer.new()
	add_child_autofree(layer)
	Session.offer_auto_quests()
	layer.hold = true
	layer.set_process(false)  # nothing is shown: only the queue is checked
	layer._queue.clear()  # the batch's own banner (the Path line, Fix pass Nov 7)
	layer.push("start", QuestDefinitions.MERCHANTS)
	layer.push("step", QuestDefinitions.MERCHANTS)
	assert_eq(layer.queued(), 1, "two updates of one quest waiting read as the newest")
	for quest_id: String in ["main_beefcake", "main_necrocrat", "main_gourmand", "main_refusemancer", "fragments"]:
		layer.push("complete", quest_id, "")
	assert_eq(layer.queued(), QuestNoticeLayer.MAX_QUEUE, "a burst keeps the newest few")
	layer.push("start", "no_such_quest")
	assert_eq(layer.queued(), QuestNoticeLayer.MAX_QUEUE, "unknown quests are ignored")
