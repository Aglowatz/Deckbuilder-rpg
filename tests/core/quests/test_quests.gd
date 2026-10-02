extends GutTest
## Part B: the data-driven quest system - catalog, objectives built on Condition, counters,
## rewards, NPC turn-in, and save/load.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.A)
	Session.quest_log.reset()
	Session.flags = {}
	Session.counters = {}
	Session.pending_level_ups = []


func test_starter_quests_exist_with_the_right_objectives() -> void:
	var merchants: QuestData = QuestCatalog.find(QuestDefinitions.MERCHANTS)
	var paths: QuestData = QuestCatalog.find(QuestDefinitions.PATHS)
	assert_not_null(merchants)
	assert_not_null(paths)
	assert_eq(merchants.objectives.size(), 3, "card, item and equipment vendor")
	assert_eq(paths.objectives.size(), 4, "the four corrupted path NPCs")
	assert_true(merchants.auto_give and paths.auto_give)


func test_auto_quests_are_given_once() -> void:
	Session.offer_auto_quests()
	assert_true(Session.quest_log.is_active(QuestDefinitions.MERCHANTS))
	assert_true(Session.quest_log.is_active(QuestDefinitions.PATHS))
	var count: int = Session.quest_log.active.size()
	Session.offer_auto_quests()
	assert_eq(Session.quest_log.active.size(), count, "no duplicates on re-entry")


func test_merchants_quest_progresses_per_vendor_and_completes_with_rewards() -> void:
	Session.offer_auto_quests()
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.MERCHANTS)
	var gold_before: int = Session.gold
	Session.set_flag(&"vendor_seen")
	assert_eq(Session.quest_log.objectives_met_count(quest, Session.unlock_state()), 1)
	Session.set_flag(&"item_vendor_seen")
	assert_true(Session.quest_log.is_active(quest.id))
	Session.set_flag(&"equipment_vendor_seen")
	assert_true(Session.quest_log.is_completed(quest.id))
	assert_false(Session.quest_log.is_active(quest.id))
	assert_eq(Session.gold, gold_before + quest.reward_gold)
	assert_true(Session.completed_quests.has(quest.id), "Condition.QUEST_COMPLETED sees it")
	assert_true(Condition.met(Condition.quest_completed(quest.id), Session.unlock_state()))


func test_clear_the_paths_needs_all_four() -> void:
	Session.offer_auto_quests()
	for npc_id: String in ["beefcake", "gourmand", "root"]:
		Session.set_flag(CorruptedNpcs.unlock_flag(npc_id))
	assert_true(Session.quest_log.is_active(QuestDefinitions.PATHS))
	Session.set_flag(CorruptedNpcs.unlock_flag("necrocrat"))
	assert_true(Session.quest_log.is_completed(QuestDefinitions.PATHS))


func test_quest_xp_reward_queues_level_ups() -> void:
	var quest: QuestData = QuestData.new()
	quest.id = "t_xp"
	quest.reward_xp = ProgressionTable.xp_to_reach(3)
	var before: int = Session.profile.level
	Session.quest_log.active.append(quest.id)
	# Not in the catalog, so complete via the log + the same reward path directly.
	assert_true(Session.quest_log.complete(quest.id))
	Session.pending_level_ups.append_array(Session.add_xp(quest.reward_xp))
	assert_gt(Session.profile.level, before)
	assert_false(Session.pending_level_ups.is_empty())


func test_counter_objective_counts_from_acceptance() -> void:
	var quest: QuestData = QuestData.new()
	quest.id = "t_counter"
	quest.objectives = [QuestObjective.make("Beat 3", Condition.counter("beaten", 3))] as Array[QuestObjective]
	Session.counters["beaten"] = 5
	assert_true(Session.quest_log.start(quest, Session.unlock_state()))
	var state: UnlockState = Session.unlock_state()
	assert_eq(Session.quest_log.objective_progress(quest, 0, state), Vector2i(0, 3), "earlier wins do not count")
	Session.counters["beaten"] = 7
	state = Session.unlock_state()
	assert_eq(Session.quest_log.objective_progress(quest, 0, state), Vector2i(2, 3))
	Session.counters["beaten"] = 9
	assert_true(Session.quest_log.all_objectives_met(quest, Session.unlock_state()))


func test_turn_in_quest_waits_for_the_npc() -> void:
	var quest: QuestData = QuestData.new()
	quest.id = "t_turnin"
	quest.title = "Turn it in"
	quest.turn_in_npc = "Someone"
	quest.reward_gold = 25
	quest.objectives = [QuestObjective.make("Flag", Condition.flag("t_flag"))] as Array[QuestObjective]
	assert_true(Session.quest_log.start(quest, Session.unlock_state()))
	Session.flags["t_flag"] = true
	var state: UnlockState = Session.unlock_state()
	assert_true(Session.quest_log.is_ready_to_turn_in(quest, state))
	assert_true(Session.quest_log.auto_completable([quest] as Array[QuestData], state).is_empty(), "never auto-completes")


func test_prerequisite_blocks_start() -> void:
	var quest: QuestData = QuestData.new()
	quest.id = "t_pre"
	quest.prerequisite = Condition.flag("never_set")
	assert_false(Session.quest_log.can_start(quest, Session.unlock_state()))
	Session.flags["never_set"] = true
	assert_true(Session.quest_log.can_start(quest, Session.unlock_state()))


func test_quest_state_survives_save_and_load() -> void:
	Session.offer_auto_quests()
	Session.set_flag(&"vendor_seen")
	Session.bump_counter("zone_kills", 4)
	var data: Dictionary = Session.to_dict()
	var json: Dictionary = JSON.parse_string(JSON.stringify(data)) as Dictionary
	Session.quest_log.reset()
	Session.counters = {}
	assert_true(Session.from_dict(json))
	assert_true(Session.quest_log.is_active(QuestDefinitions.MERCHANTS))
	assert_eq(Session.counter("zone_kills"), 4)
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.MERCHANTS)
	assert_eq(Session.quest_log.objectives_met_count(quest, Session.unlock_state()), 1)


func test_old_saves_with_only_completed_quests_still_load() -> void:
	var data: Dictionary = Session.to_dict()
	data.erase("quests")
	data["completed_quests"] = ["legacy_quest"]
	assert_true(Session.from_dict(data))
	assert_true(Session.completed_quests.has("legacy_quest"))
