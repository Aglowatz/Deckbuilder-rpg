extends GutTest
## Fable Nov 20, Part 4: "The Door Under the Well" can be done by a new player (the chest is said in words, marked and reachable),
## Gatekeeper Brannoch takes "Outskirts Watch" back, every hand-in has its NPC's spot (the static half of the hand-in probe:
## tools/run_quest_handin_probe.sh walks and talks), dungeon entrances show no level counts, a sealed one names itself and who to ask,
## and an opened side dungeon is a tracked step. Part 6: Elowen at the cave mouth after the third zone.

var _town: TownBuilder


func before_all() -> void:
	var root: Node3D = Node3D.new()
	add_child(root)
	_town = TownBuilder.new()
	_town.build(root, false)
	HubLand.build(_town.root, _town, StandardMaterial3D.new())


func after_all() -> void:
	for child: Node in get_children():
		child.queue_free()


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


# ---- 4.1 The Door Under the Well -------------------------------------------------------------------------------------------------


# Fable Nov 21 (Part 1.5): the key moved to a small chest of its own beside the well; Shiro Swindle's chest is only his again.
func test_the_wells_chest_step_is_said_in_words_and_marked() -> void:
	var quest: QuestData = QuestCatalog.find(ZoneQuestDefinitions.SIDE_TOWN)
	assert_not_null(quest)
	var step: QuestObjective = quest.objectives[0]
	assert_string_contains(step.text, "small chest beside the Old Well")
	assert_true(step.has_marker(), "the chest step has a marker")
	assert_eq(step.target_area, "town")
	assert_eq(step.target_id, ZoneQuestDefinitions.WELL_KEY_SPOT, "the marker is the small chest itself")
	assert_string_contains(step.hint, "iron hatch")
	assert_string_contains(quest.summary, "small chest beside the well")
	assert_false(quest.summary.contains("spit of land"), "not Shiro Swindle's chest any more")
	var offer: Array[String] = DungeonCatalog.text_lines("quest.side_s_town.offer")
	var active: Array[String] = DungeonCatalog.text_lines("quest.side_s_town.active")
	assert_string_contains(" ".join(offer), "little chest beside the well", "Maren says where, when she gives the quest")
	assert_string_contains(" ".join(active), "little chest beside the Old Well", "and when asked again")
	assert_string_contains(" ".join(active), "map")
	assert_false((" ".join(offer) + " ".join(active)).contains("Rift Express"), "no line still sends the player east")


func test_the_wells_chest_can_be_walked_to_from_maren() -> void:
	var chest: Vector3 = _town.anchors["well_key_chest"] as Vector3
	var well: Vector3 = _town.anchors["well"] as Vector3
	var maren: Vector3 = _town.anchors["npc_elder"] as Vector3
	var walkable: Callable = func(at: Vector3) -> bool: return _town.is_walkable(at)
	assert_lt(chest.distance_to(well), 4.0, "the small chest is beside the well")
	assert_gt(chest.distance_to(well), 3.4, "Fable big pass Nov 23: far enough that the well and the chest never share a prompt (1.7 m + the chest's reach)")
	assert_gt(chest.distance_to(well + Vector3(-2.2, 0.0, 0.6)), 2.5, "and not on the iron hatch")
	assert_false(_town.is_walkable(chest), "the chest itself is solid")
	var route: PackedVector3Array = WalkPlanner.route(walkable, _town.map_bounds(), maren, chest, 0.5, ChestKit.REACH - 0.3)
	assert_gt(route.size(), 1, "a walking route leads from Elder Maren to within reach of the chest")
	var back: PackedVector3Array = WalkPlanner.route(walkable, _town.map_bounds(), route[route.size() - 1], well + Vector3(-2.2, 0.0, 0.6), 0.5, 1.2)
	assert_gt(back.size(), 1, "and on from the chest to the iron hatch")


func test_opening_the_small_chest_finishes_the_step_and_maren_takes_the_key() -> void:
	Session.set_flag(&"trial_cleared")
	DevActions.set_quest_step(ZoneQuestDefinitions.SIDE_TOWN, 0)
	var quest: QuestData = QuestCatalog.find(ZoneQuestDefinitions.SIDE_TOWN)
	assert_true(Session.quest_log.is_active(quest.id))
	assert_false(Session.quest_log.is_ready_to_turn_in(quest, Session.unlock_state()))
	assert_false(Session.side_unlocked("S-TOWN"), "the hatch is sealed")
	var gold_before: int = Session.gold
	Session.discover_secret(ZoneQuestDefinitions.WELL_KEY_SECRET)
	assert_eq(Session.gold, gold_before, "the small chest takes no gold")
	assert_false(Session.quest_log.is_active(NinjaBoss.QUEST_ID), "and does not start Shiro Swindle's questline")
	assert_true(Session.quest_log.is_ready_to_turn_in(quest, Session.unlock_state()), "opening the small chest is the step")
	assert_eq(quest.turn_in_npc, QuestDefinitions.MAREN)
	assert_true(Session.turn_in_quest(quest.id))
	assert_true(Session.side_unlocked("S-TOWN"), "the hatch beside the well is open")
	Session.offer_auto_quests()
	assert_true(Session.quest_log.is_active(ZoneQuestDefinitions.way_in_id("S-TOWN")), "and the way down is the next tracked step")
	assert_string_contains(TownScene.WELL_KEY_TOAST_QUEST, "Elder Maren")


func test_shiro_swindles_chest_no_longer_holds_the_key() -> void:
	Session.set_flag(&"trial_cleared")
	DevActions.set_quest_step(ZoneQuestDefinitions.SIDE_TOWN, 0)
	var quest: QuestData = QuestCatalog.find(ZoneQuestDefinitions.SIDE_TOWN)
	Session.gold = 120
	var result: Dictionary = Session.open_giant_chest(NinjaBoss.ORIGINAL_CHEST)
	assert_eq(int(result.get("stolen", 0)), 50, "his chest still takes 50 gold")
	assert_true(Session.quest_log.is_active(NinjaBoss.QUEST_ID), "and starts his questline")
	assert_false(Session.quest_log.is_ready_to_turn_in(quest, Session.unlock_state()), "but it is not the well quest's step")
	var source: String = FileAccess.get_file_as_string("res://world/ninja/giant_chest_event.gd")
	assert_false(source.contains("iron key"), "no key toast at his chest")


# ---- 4.2 hand-ins ------------------------------------------------------------------------------------------------------------------


func test_brannoch_has_lines_for_every_stage_of_outskirts_watch() -> void:
	var quest: QuestData = QuestCatalog.find("town_outskirts_watch")
	assert_not_null(quest)
	assert_eq(quest.turn_in_npc, QuestDefinitions.BRANNOCH)
	assert_eq([quest.turn_in_area, quest.turn_in_spot], ["town", "guard"])
	for stage: String in ["offer", "active", "ready", "done"]:
		assert_false(DungeonCatalog.text_lines("quest.town_outskirts_watch.%s" % stage).is_empty(), stage)
	var source: String = FileAccess.get_file_as_string("res://world/town_scene.gd")
	var talk: String = source.substr(source.find("func _talk_guard()"), 4200)
	assert_string_contains(talk, "Session.quests_ready_for(speaker)", "he looks for a quest of his that is ready")
	assert_string_contains(talk, "Session.turn_in_quest(finished_quest.id)", "and takes it")
	assert_lt(talk.find("quests_ready_for(speaker)"), talk.find("town.guard.capital_active"), "before he talks about the Capital")


func test_outskirts_watch_can_be_handed_in_by_state() -> void:
	Session.set_flag(&"trial_cleared")
	var quest: QuestData = QuestCatalog.find("town_outskirts_watch")
	DevActions.set_quest_step(quest.id, quest.objectives.size())
	assert_has(Session.quests_ready_for(QuestDefinitions.BRANNOCH), quest, "ready for Brannoch")
	assert_true(Session.turn_in_quest(quest.id))
	assert_true(Session.quest_log.is_completed(quest.id))


## The static half of the probe: every quest handed in to somebody names an area and a spot, and that spot exists there.
func test_every_hand_in_has_a_place_and_its_spot_exists() -> void:
	var town_spots: Array[String] = ["elder", "guard", "vendor", "item_vendor", "equipment_vendor", "pack_vendor", "tailor", "baker", "alchemist", "rift_station", "hob"]
	var checked: int = 0
	for quest: QuestData in QuestCatalog.all():
		if quest.turn_in_npc.is_empty():
			continue
		checked += 1
		assert_false(quest.turn_in_area.is_empty(), "%s: hand-in area" % quest.id)
		assert_false(quest.turn_in_spot.is_empty(), "%s: hand-in spot" % quest.id)
		if quest.turn_in_area == "town":
			assert_has(town_spots, quest.turn_in_spot, "%s: a talking NPC of Crosspath" % quest.id)
			continue
		assert_true(ZoneDefs.has_def(quest.turn_in_area), "%s: a real zone (%s)" % [quest.id, quest.turn_in_area])
		if not ZoneDefs.has_def(quest.turn_in_area):
			continue
		var found: bool = false
		for spot: Dictionary in ZoneDefs.get_def(quest.turn_in_area).spots:
			if str(spot["id"]) == quest.turn_in_spot:
				found = true
				assert_true(str(spot.get("npc_name", "")) == quest.turn_in_npc or str(spot.get("speaker", "")) == quest.turn_in_npc, "%s: the spot %s is %s" % [quest.id, str(spot["id"]), quest.turn_in_npc])
		assert_true(found, "%s: %s stands in %s (spot %s)" % [quest.id, quest.turn_in_npc, quest.turn_in_area, quest.turn_in_spot])
	assert_gt(checked, 25, "quests with a hand-in: %d" % checked)


func test_every_step_that_names_somebody_to_talk_to_has_a_target() -> void:
	for quest: QuestData in QuestCatalog.all():
		for objective: QuestObjective in quest.objectives:
			var text: String = objective.text.to_lower()
			if text.begins_with("talk to ") or text.begins_with("hand in to ") or text.begins_with("speak to "):
				assert_true(objective.has_marker(), "%s: '%s' has a marker" % [quest.id, objective.text])


# ---- 4.3 dungeon entrances ---------------------------------------------------------------------------------------------------------


func test_no_dungeon_entrance_prompt_counts_levels() -> void:
	var counted: RegEx = RegEx.new()
	counted.compile("(?i)\\b(one|two|three|four|five|six|seven|eight|nine|ten|\\d+)\\s+(levels?|floors?|courses|rooms?|stages?|fights?)\\b")
	var seen: int = 0
	for zone_id: String in ["beefcake", "gourmand", "refusemancer", "necrocrat", "final"]:
		for spot: Dictionary in ZoneDefs.get_def(zone_id).spots:
			if str(spot["kind"]) in ["mini_dungeon", "main_dungeon"]:
				seen += 1
				assert_null(counted.search(str(spot["prompt"])), "%s / %s: '%s' counts levels" % [zone_id, str(spot["id"]), str(spot["prompt"])])
	assert_gt(seen, 6)
	var heap_prompt: String = ""
	for spot: Dictionary in ZoneDefs.get_def("refusemancer").spots:
		if str(spot["id"]) == "mini_dungeon":
			heap_prompt = str(spot["prompt"])
	assert_eq(heap_prompt, "Climb into the landfill")


func test_a_sealed_dungeon_names_itself_and_who_to_ask() -> void:
	assert_eq(ZoneQuestDefinitions.sealed_message("S-REF"), "The landfill is sealed. Talk to Brother Bramble at the stream in the Verdant Dump; they may know more.")
	for dungeon_id: String in ZoneQuestDefinitions.SIDE_QUESTS.keys():
		var message: String = ZoneQuestDefinitions.sealed_message(dungeon_id)
		assert_false(message.contains("???"), "%s: never ???" % dungeon_id)
		assert_string_contains(message, " is sealed. Talk to ")
		assert_string_contains(message, "; they may know more.")
		var quest: QuestData = QuestCatalog.find(str(ZoneQuestDefinitions.SIDE_QUESTS[dungeon_id]))
		assert_not_null(quest, "%s has its own side quest" % dungeon_id)
		assert_string_contains(message, quest.giver_npc, "%s: the message names the quest's giver" % dungeon_id)
		assert_false(quest.giver_area.is_empty() or quest.giver_spot.is_empty(), "%s: the giver has a place (the '!' mark)" % dungeon_id)
	var zone_scene: String = FileAccess.get_file_as_string("res://world/zone/zone_scene.gd")
	assert_string_contains(zone_scene, "ZoneQuestDefinitions.sealed_message(plan.id)")
	assert_false(zone_scene.contains("is sealed. %s\" % [SpoilerFree"), "the old '??? is sealed' line is gone")


func test_every_side_dungeon_has_a_quest_that_sends_the_player_to_it() -> void:
	for plan: DungeonCatalog.Blueprint in DungeonCatalog.all():
		if not plan.is_side() or plan.always_open:
			continue
		assert_true(ZoneQuestDefinitions.SIDE_QUESTS.has(plan.id) or plan.id == PasteWorks.DUNGEON_ID, "%s has a side quest" % plan.id)
		var sent: bool = false
		for quest: QuestData in QuestCatalog.all():
			for objective: QuestObjective in quest.objectives:
				if objective.condition != null and objective.condition.kind == Condition.Kind.FLAG_SET and objective.condition.key == str(SignatureCards.cleared_flag(plan.id)):
					sent = sent or objective.has_marker() or not objective.hint.is_empty() or not objective.parts.is_empty() or ZoneQuestDefinitions.TARGETS.has(quest.id)
		assert_true(sent, "%s: some quest step says 'clear it' and points at its entrance" % plan.id)
	for dungeon_id: String in ZoneQuestDefinitions.WAY_IN.keys():
		var way: QuestData = QuestCatalog.find(ZoneQuestDefinitions.way_in_id(dungeon_id))
		assert_not_null(way)
		assert_true(way.auto_give)
		assert_eq(way.objectives[0].target_kind, QuestObjective.TargetKind.DUNGEON)
		assert_true(way.objectives[0].has_marker(), "%s: the entrance is marked" % dungeon_id)


func test_the_way_in_quest_starts_when_the_side_quest_is_handed_in() -> void:
	Session.set_flag(&"trial_cleared")
	var quest: QuestData = QuestCatalog.find(ZoneQuestDefinitions.SIDE_REF)
	var way_id: String = ZoneQuestDefinitions.way_in_id("S-REF")
	Session.offer_auto_quests()
	assert_false(Session.quest_log.is_active(way_id), "not before the side quest")
	DevActions.set_quest_step(quest.id, quest.objectives.size())
	assert_true(Session.turn_in_quest(quest.id))
	Session.offer_auto_quests()
	assert_true(Session.quest_log.is_active(way_id), "handed in: 'Little Paw Prints' starts by itself")
	Session.set_flag(SignatureCards.cleared_flag("S-REF"))
	Session.refresh_quests()
	assert_true(Session.quest_log.is_completed(way_id), "clearing the landfill finishes it (no hand-in)")


# ---- Part 6: Elowen after the third zone -------------------------------------------------------------------------------------------


func test_elowen_knows_who_he_is_after_the_third_zone() -> void:
	var scenes: Dictionary = (JSON.parse_string(FileAccess.get_file_as_string("res://data/story/story_scenes.json")) as Dictionary)["scenes"] as Dictionary
	var text: String = JSON.stringify((scenes["cave_mouth_3"] as Dictionary)["steps"])
	assert_string_contains(text, "It's coming back, isn't it?")
	assert_string_contains(text, "You know who you are. Now go free the last zone {villain} holds, and prove it.")
	assert_string_contains(text, "ate the frosting off every layer of his birthday cake", "the dumbbell-and-frosting callback stays (story bible, thread 11)")
	for doubt: String in ["only reminded me of someone", "starting to think", "Not until I'm certain", "isn't sure"]:
		assert_false(text.contains(doubt), "she does not doubt who he is: '%s'" % doubt)
	for scene_id: String in ["cave_mouth_1", "cave_mouth_2", "cave_mouth_4", "pc_capture"]:
		var other: String = JSON.stringify((scenes[scene_id] as Dictionary)["steps"])
		for doubt: String in ["reminded me of someone", "starting to think", "if you are him", "might be him", "not sure who you"]:
			assert_false(other.contains(doubt), "%s: '%s'" % [scene_id, doubt])
	var last: Array = ((scenes["cave_mouth_3"] as Dictionary)["steps"] as Array).back() as Array
	assert_eq(str(last[0]), "NPC-ELOWEN", "she closes the scene")
	assert_string_contains(str(last.back()), "prove it")
