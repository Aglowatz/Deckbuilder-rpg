extends GutTest
## Part B: the data-driven quest system - catalog, objectives built on Condition, counters,
## rewards, NPC turn-in, and save/load.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.level_track_grants = false  # these tests count gold and packs exactly; the reward track pays its own (test_level_track)
	Session.quest_log.reset()
	# out of the cave and past Maren's early-game chain (Oct 20), so the story quests are on offer; test_early_chain.gd covers the chain
	Session.flags = {"trial_cleared": true, QuestDefinitions.LEGACY_FLAG: true}
	Session.counters = {}
	Session.pending_level_ups = []


func test_starter_quests_exist_with_the_right_objectives() -> void:
	var merchants: QuestData = QuestCatalog.find(QuestDefinitions.MERCHANTS)
	assert_not_null(merchants)
	assert_eq(merchants.objectives.size(), 4, "Sable, a card bought, Tilly, Pip (Oct 20: Bertram's smithy waits for the armory quest)")
	assert_true(merchants.auto_give and merchants.is_main())
	assert_eq(merchants.turn_in_npc, QuestDefinitions.MAREN, "handed back to Maren")
	assert_null(QuestCatalog.find(QuestDefinitions.RETIRED_PATHS), "Clear the Paths is retired: each zone's MAIN line starts at its gatekeeper")
	for zone_id: String in Gatekeepers.IDS:
		var main: QuestData = QuestCatalog.find(QuestDefinitions.zone_main_id(zone_id))
		assert_not_null(main, zone_id)
		assert_true(main.auto_give and main.is_main())
		assert_not_null(main.prerequisite, "%s waits for the early-game chain" % zone_id)


func test_auto_quests_are_given_once() -> void:
	Session.offer_auto_quests()
	assert_true(Session.quest_log.is_active(QuestDefinitions.MERCHANTS))
	assert_true(Session.quest_log.is_active(QuestDefinitions.zone_main_id("beefcake")))
	var count: int = Session.quest_log.active.size()
	Session.offer_auto_quests()
	assert_eq(Session.quest_log.active.size(), count, "no duplicates on re-entry")


func test_merchants_quest_progresses_per_vendor_and_completes_with_rewards() -> void:
	Session.offer_auto_quests()
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.MERCHANTS)
	var gold_before: int = Session.gold
	Session.set_flag(&"vendor_seen")
	assert_eq(Session.quest_log.objectives_met_count(quest, Session.unlock_state()), 1)
	Session.bump_counter("cards_bought")
	Session.set_flag(&"item_vendor_seen")
	assert_true(Session.quest_log.is_active(quest.id))
	Session.set_flag(&"tailor_seen")
	assert_true(Session.quest_log.is_active(quest.id), "every step done: it waits for Maren")
	assert_true(Session.quest_log.is_ready_to_turn_in(quest, Session.unlock_state()))
	assert_true(Session.turn_in_quest(quest.id))
	assert_true(Session.quest_log.is_completed(quest.id))
	assert_false(Session.quest_log.is_active(quest.id))
	assert_eq(Session.gold, gold_before + quest.reward_gold)
	assert_true(Session.completed_quests.has(quest.id), "Condition.QUEST_COMPLETED sees it")
	assert_true(Condition.met(Condition.quest_completed(quest.id), Session.unlock_state()))


func test_beating_a_gatekeeper_moves_its_main_line_and_pays_the_pack_once() -> void:
	Session.offer_auto_quests()
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.zone_main_id("beefcake"))
	var state: UnlockState = Session.unlock_state()
	assert_eq(Session.quest_log.current_index(quest, state), 0, "the gatekeeper first")
	var packs_before: int = Session.profile.pack_count("path_beefcake")
	Session.set_flag(CorruptedNpcs.unlock_flag("beefcake"))
	state = Session.unlock_state()
	assert_eq(Session.quest_log.current_index(quest, state), 1, "then cross in")
	assert_true(Session.quest_log.milestone_paid(quest.id, 0))
	assert_eq(Session.quest_log.tracked_id(), quest.id, "the tracker follows the quest that just moved")
	Session.set_flag(CorruptedNpcs.unlock_flag("beefcake"))
	assert_eq(Session.pending_popups.size(), 1, "the milestone is paid once")
	assert_eq(Session.profile.pack_count("path_beefcake"), packs_before + 1, "the gatekeeper pays a Path Pack")


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


func test_objectives_are_ordered_and_the_current_one_is_the_first_not_done() -> void:
	var quest: QuestData = QuestData.new()
	quest.id = "t_order"
	quest.objectives = [QuestObjective.make("One", Condition.flag("t_one")), QuestObjective.make("Two", Condition.flag("t_two"))] as Array[QuestObjective]
	assert_true(Session.quest_log.start(quest, Session.unlock_state()))
	assert_eq(Session.quest_log.current_index(quest, Session.unlock_state()), 0)
	Session.flags["t_one"] = true
	assert_eq(Session.quest_log.current_objective(quest, Session.unlock_state()).text, "Two")
	Session.flags["t_two"] = true
	assert_null(Session.quest_log.current_objective(quest, Session.unlock_state()), "all done")


func test_every_quest_has_a_category_name_summary_and_named_objectives() -> void:
	var mains: int = 0
	for quest: QuestData in QuestCatalog.all():
		assert_false(quest.title.is_empty(), quest.id)
		assert_false(quest.summary.is_empty(), quest.id)
		assert_false(quest.objectives.is_empty(), quest.id)
		for objective: QuestObjective in quest.objectives:
			assert_false(objective.text.is_empty(), "%s has a named objective" % quest.id)
		if quest.is_main():
			mains += 1
	assert_gte(mains, 6, "fragments, free the four zones and the four zone lines")


func test_each_zone_main_line_pays_two_path_packs_and_midpoint_gear() -> void:
	for zone_id: String in Gatekeepers.IDS:
		var quest: QuestData = QuestCatalog.find(QuestDefinitions.zone_main_id(zone_id))
		assert_eq(quest.all_pack_ids().count("path_%s" % zone_id), 2, "%s: gatekeeper + dungeon" % zone_id)
		assert_eq(quest.all_equipment_ids().size(), 1, "%s: midpoint gear" % zone_id)
		assert_eq(quest.objectives[0].target_id, "npc_%s" % zone_id, "the gatekeeper is the first target")


func test_tracker_cycles_through_active_quests_main_first() -> void:
	Session.offer_auto_quests()
	var order: Array[String] = Session.quest_log.cycle_order(QuestCatalog.all())
	assert_gt(order.size(), 2)
	assert_true(QuestCatalog.find(order[0]).is_main())
	assert_eq(order[0], QuestDefinitions.MERCHANTS, "Maren's first errand leads the MAIN quests (order 1)")
	Session.quest_log.track(order[0])
	assert_eq(Session.quest_log.cycle(QuestCatalog.all(), 1), order[1])
	assert_eq(Session.quest_log.cycle(QuestCatalog.all(), -1), order[0])
	assert_eq(Session.quest_log.cycle(QuestCatalog.all(), -1), order[order.size() - 1], "wraps round")


func test_migration_of_an_old_save_retires_clear_the_paths_and_never_double_pays() -> void:
	var data: Dictionary = Session.to_dict()
	data["quests"] = {"active": ["clear_the_paths", "meet_the_merchants"], "completed": [], "baselines": {}, "tracked": "clear_the_paths"}
	var flags: Dictionary = data["flags"] as Dictionary
	flags[str(CorruptedNpcs.unlock_flag("beefcake"))] = true
	flags[str(FastTravel.unlock_flag("beefcake"))] = true
	var gold_before: int = int(data.get("gold", 0))
	assert_true(Session.from_dict(JSON.parse_string(JSON.stringify(data)) as Dictionary))
	var qlog: QuestLog = Session.quest_log
	assert_eq(qlog.version, QuestLog.VERSION)
	assert_false(qlog.is_active("clear_the_paths"))
	var main: QuestData = QuestCatalog.find(QuestDefinitions.zone_main_id("beefcake"))
	assert_true(qlog.is_active(main.id), "the new MAIN line starts")
	assert_true(Session.flag(Gatekeepers.entered_flag("beefcake")), "a zone with its station is already entered")
	assert_eq(qlog.current_index(main, Session.unlock_state()), 2, "gatekeeper and crossing already done")
	assert_true(qlog.milestone_paid(main.id, 0), "settled, not paid")
	Session.refresh_quests()
	assert_eq(Session.gold, gold_before, "no retroactive payout")
	assert_eq(Session.profile.pack_count("path_beefcake"), 0)


func test_migration_files_a_finished_line_as_completed_silently() -> void:
	var data: Dictionary = Session.to_dict()
	data["quests"] = {"active": [], "completed": ["free_the_kingdom"], "baselines": {}}
	var flags: Dictionary = data["flags"] as Dictionary
	for key: String in [str(CorruptedNpcs.unlock_flag("gourmand")), str(Gatekeepers.entered_flag("gourmand")), str(ZoneCompletion.flag_name("gourmand")), "buf_pie_done_marker"]:
		flags[key] = true
	data["quests"]["completed"].append("buf_pie")
	assert_true(Session.from_dict(JSON.parse_string(JSON.stringify(data)) as Dictionary))
	assert_true(Session.quest_log.is_completed(QuestDefinitions.zone_main_id("gourmand")))
	assert_eq(Session.pending_popups.size(), 0, "no reward box")


func test_new_saves_are_current_and_round_trip_milestones() -> void:
	Session.offer_auto_quests()
	Session.set_flag(CorruptedNpcs.unlock_flag("necrocrat"))
	var json: Dictionary = JSON.parse_string(JSON.stringify(Session.to_dict())) as Dictionary
	assert_true(Session.from_dict(json))
	assert_eq(Session.quest_log.version, QuestLog.VERSION)
	assert_true(Session.quest_log.milestone_paid(QuestDefinitions.zone_main_id("necrocrat"), 0))
