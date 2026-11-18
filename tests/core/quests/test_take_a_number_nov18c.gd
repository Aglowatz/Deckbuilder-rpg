extends GutTest
## Nov 18 evening, Part 1.6: "Take a Number" - the Waiting Room of Eternity as an official, tracked side quest. Gerald's old "Number
## 4,000,212" (two roaming fights to unseal the door) is the same quest with new steps: find the lit elevator, then clear the dungeon.
## Taking it unseals the door; turning it in pays gold, experience and a Necrocrat Path Pack.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.choose_starting_path(Affinity.Type.NECROCRAT)
	Session.set_flag(&"trial_cleared")


func test_the_quest_has_two_tracked_steps_with_markers() -> void:
	var quest: QuestData = QuestCatalog.find(ZoneQuestDefinitions.SIDE_NECRO)
	assert_not_null(quest)
	assert_eq(quest.title, "Take a Number")
	assert_eq(quest.category, QuestData.Category.SIDE, "a side quest in the log")
	assert_eq(quest.objectives.size(), 2, "find it, then beat it")
	for objective: QuestObjective in quest.objectives:
		assert_eq(objective.target_id, "mini_dungeon", "each step marks the Waiting Room's door on the map")
	assert_eq(quest.giver_npc, DnaZone.NPC_BARNABY, "Gerald (Number 4,000,212) still gives it")
	assert_eq(quest.reward_gold, roundi(float(ZoneQuestDefinitions.TAKE_A_NUMBER_GOLD) * QuestCatalog.gold_scale(quest) / 5.0) * 5, "the side-quest gold scale applies")
	assert_eq(quest.reward_xp, ZoneQuestDefinitions.TAKE_A_NUMBER_XP)
	assert_true(quest.reward_pack_ids.has("path_necrocrat"), "and a pack")


func test_taking_it_unseals_the_door_and_the_steps_follow_the_player() -> void:
	assert_false(Session.side_unlocked("S-NECRO"), "sealed before the quest")
	assert_true(Session.start_quest(ZoneQuestDefinitions.SIDE_NECRO))
	assert_true(Session.side_unlocked("S-NECRO"), "taking the quest opens the door")
	var quest: QuestData = QuestCatalog.find(ZoneQuestDefinitions.SIDE_NECRO)
	assert_false(Session.quest_log.objective_met(quest, 0, Session.unlock_state()))
	Session.set_flag(DnaZone.FLAG_WAITING_ROOM_FOUND)
	assert_true(Session.quest_log.objective_met(quest, 0, Session.unlock_state()), "found")
	assert_false(Session.quest_log.is_ready_to_turn_in(quest, Session.unlock_state()))
	Session.set_flag(DnaZone.FLAG_MINI_DUNGEON_CLEARED)
	assert_true(Session.quest_log.is_ready_to_turn_in(quest, Session.unlock_state()), "beaten")
	var packs: int = Session.pack_count("path_necrocrat")
	var gold: int = Session.gold
	assert_true(Session.turn_in_quest(ZoneQuestDefinitions.SIDE_NECRO))
	assert_eq(Session.pack_count("path_necrocrat"), packs + 1, "the pack")
	assert_gte(Session.gold - gold, ZoneQuestDefinitions.TAKE_A_NUMBER_GOLD)
	assert_true(Session.side_unlocked("S-NECRO"), "the door stays open for repeat runs")


func test_the_lines_say_where_to_go() -> void:
	for part: String in ["offer", "active", "ready", "done"]:
		var lines: Array[String] = DungeonCatalog.text_lines("quest.%s.%s" % [ZoneQuestDefinitions.SIDE_NECRO, part])
		assert_false(lines.is_empty(), part)
		for line: String in lines:
			assert_false(line.contains("two of the roaming staff"), "no line still asks for the old two fights")
	var offer: String = " ".join(DungeonCatalog.text_lines("quest.%s.offer" % ZoneQuestDefinitions.SIDE_NECRO))
	assert_true(offer.contains("elevator"), "the offer points at the lit elevator")
