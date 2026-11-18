extends GutTest
## Nov 18 day, Part 4: right after the cave and Maren, "Meet the Merchants" is the tracked quest (not Fragments); the whole Settling In chain
## (Meet the Merchants through the armory) is MAIN and comes before Fragments; the tracker has no "Your Path" line; Kyle's Rec Room game is
## scrapped and he gives "Hall Monitor" (beat three roamers of his wing: 0/3 -> 3/3, a Gilded pack, gold and XP).

const CHAIN: Array[String] = ["meet_the_merchants", "first_deck_edit", "storeroom_ghosts", "some_assembly_required"]


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.choose_starting_path(Affinity.Type.NECROCRAT)
	Session.set_flag(&"trial_cleared")
	Session.offer_auto_quests()


func test_after_maren_meet_the_merchants_is_tracked() -> void:
	assert_true(Session.quest_log.is_active(QuestDefinitions.MERCHANTS))
	assert_true(Session.quest_log.is_active(MemoryDefs.QUEST_ID), "Fragments has started too")
	assert_eq(Session.quest_log.tracked_id(), QuestDefinitions.MERCHANTS, "Meet the Merchants leads, not Fragments")
	Session.refresh_quests()
	assert_eq(Session.quest_log.tracked_id(), QuestDefinitions.MERCHANTS, "still after a refresh")


func test_the_chain_is_main_and_comes_before_fragments() -> void:
	var fragments: QuestData = QuestCatalog.find(MemoryDefs.QUEST_ID)
	assert_true(fragments.is_main(), "Fragments stays MAIN")
	for id: String in CHAIN:
		var quest: QuestData = QuestCatalog.find(id)
		assert_not_null(quest, id)
		assert_true(quest.is_main(), "%s is a MAIN quest" % id)
		assert_lt(quest.order, fragments.order, "%s comes before Fragments" % id)
	var order: Array[String] = Session.quest_log.cycle_order(QuestCatalog.all())
	assert_lt(order.find(QuestDefinitions.MERCHANTS), order.find(MemoryDefs.QUEST_ID))


func test_a_tracked_errand_keeps_the_tracker_when_fragments_moves() -> void:
	assert_false(Session.quest_log.follow(MemoryDefs.QUEST_ID), "Fragments moving on does not take the tracker from an errand")
	assert_eq(Session.quest_log.tracked_id(), QuestDefinitions.MERCHANTS)


func test_the_next_errand_takes_the_tracker() -> void:
	Session.quest_log.track(MemoryDefs.QUEST_ID)
	Session.quest_log.complete(QuestDefinitions.MERCHANTS)
	assert_true(Session.quest_log.start(QuestCatalog.find("first_deck_edit"), Session.unlock_state()))
	assert_eq(Session.quest_log.tracked_id(), "first_deck_edit", "Maren's next errand is tracked")


func test_the_tracker_has_no_your_path_line() -> void:
	var tracker: QuestTracker = QuestTracker.new()
	add_child_autofree(tracker)
	tracker.refresh()
	assert_null(tracker.find_child("YourPathLine", true, false), "no Your Path row")
	assert_null(tracker.find_child("YourPathTag", true, false))
	var source: String = FileAccess.get_file_as_string("res://ui/quests/quest_tracker.gd")
	assert_false(source.contains("YOUR PATH"))


func test_kyle_gives_hall_monitor_instead_of_the_rec_room() -> void:
	var def: ZoneDef = ZoneDefs.get_def(DnaZone.ID)
	assert_eq(str(def.spot_def("matching").get("kind", "")), "quest_npc")
	assert_eq(def.minigame_kind, "", "no Rec Room minigame")
	assert_false(ResourceLoader.exists("res://ui/zone/match_game_screen.gd"), "its screen is deleted")
	var quest: QuestData = QuestCatalog.find(ZoneQuestDefinitions.HALL_MONITOR)
	assert_not_null(quest)
	assert_eq(quest.giver_npc, DnaZone.NPC_KYLE)
	assert_eq(quest.giver_spot, "matching")
	assert_has(quest.reward_pack_ids, "gilded_necrocrat", "a Gilded pack")
	assert_gte(quest.reward_gold, 210, "at least the old game's first-win gold")
	assert_gte(quest.reward_xp, 70)
	assert_eq(str((quest.objectives[0].parts[0] as Dictionary)["spot"]), QuestMarkers.SPOT_ROAMERS_WEST, "the map marks the roamers of his wing")


func test_hall_monitor_counts_west_wing_roamers_to_three_and_pays() -> void:
	Session.begin_zone_visit(DnaZone.ID)
	assert_true(Session.start_quest(ZoneQuestDefinitions.HALL_MONITOR))
	var quest: QuestData = QuestCatalog.find(ZoneQuestDefinitions.HALL_MONITOR)
	assert_eq(Session.quest_log.objective_progress(quest, 0, Session.unlock_state()), Vector2i(0, 3))
	_win("manager_8")  # a Records Basement roamer: not Kyle's wing
	assert_eq(Session.quest_log.objective_progress(quest, 0, Session.unlock_state()).x, 0, "the other wing does not count")
	var layout: DnaLayout = DnaLayout.new()
	layout.build()
	var west: Array[String] = []
	for spawn: Dictionary in layout.enemy_spawns:
		if spawn.has("id") and DnaZone.is_west_wing(str(spawn["id"])):
			west.append(str(spawn["id"]))
	assert_eq(west.size(), 5, "Farm A's four roamers and the Filing Department's one")
	for index: int in range(3):
		_win(west[index])
		assert_eq(Session.quest_log.objective_progress(quest, 0, Session.unlock_state()).x, index + 1)
	var packs_before: int = Session.pack_count("gilded_necrocrat")
	var gold_before: int = Session.gold
	assert_true(Session.quest_log.is_ready_to_turn_in(quest, Session.unlock_state()))
	assert_true(Session.turn_in_quest(ZoneQuestDefinitions.HALL_MONITOR))
	assert_eq(Session.pack_count("gilded_necrocrat"), packs_before + 1, "the Gilded pack")
	assert_gte(Session.gold - gold_before, quest.reward_gold)


func test_kyles_quest_lines_exist() -> void:
	var story: ZoneStoryText = ZoneStoryText.for_zone(DnaZone.ID)
	for part: String in ["offer", "active", "ready"]:
		assert_false(story.get_lines("quest.%s.%s" % [ZoneQuestDefinitions.HALL_MONITOR, part]).is_empty(), part)
	for line: String in story.get_lines("npc.matching.intro") + story.get_lines("npc.matching.return"):
		assert_false(line.contains("match up the pairs") or line.contains("another round"), "no line still offers the matching game")


func _win(instance_id: String) -> void:
	var context: BattleContext = Session.make_zone_battle("intern", instance_id)
	context.game._end_game(0, false)
	context.won = true
	Session.resolve_zone_battle(context)
