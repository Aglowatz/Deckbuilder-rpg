extends GutTest
## Fable pass Nov 10, Part 1.1: a quest step marks every one of its parts (sea salt, the black truffle and Old Meatloaf), a part drops once its
## own condition is met, every active quest's step is listed for the map, the "Point me to..." list names the goals first, the map writes the
## landmark names first, and the audit refuses a step with nothing to mark.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.GOURMAND)
	Session.quest_log.reset()
	Session.flags = {QuestDefinitions.LEGACY_FLAG: true}
	Session.counters = {}
	Session.pending_popups = []


func test_mend_the_meatloaf_marks_the_salt_the_truffle_and_the_golem() -> void:
	Session.start_quest(BuffetZone.QUEST_MEND)
	var quest: QuestData = QuestCatalog.find(BuffetZone.QUEST_MEND)
	var targets: Array[Dictionary] = QuestMarkers.targets_for(quest, "gourmand", Session.quest_log, Session.unlock_state())
	var spots: Array[String] = []
	for target: Dictionary in targets:
		spots.append(str(target["spot"]))
	assert_eq(spots, ["pickup_sea_salt", "pickup_truffle", "old_meatloaf"] as Array[String], "all three parts, in order")
	assert_true(str(targets[0]["label"]).contains("Salt Flats"), "each part says roughly where it is")
	# the salt in hand: its marker drops, the other two stay
	Session.bump_counter(BuffetZone.stock_key("sea_salt"))
	targets = QuestMarkers.targets_for(quest, "gourmand", Session.quest_log, Session.unlock_state())
	spots.clear()
	for target: Dictionary in targets:
		spots.append(str(target["spot"]))
	assert_eq(spots, ["pickup_truffle", "old_meatloaf"] as Array[String])
	# from town the three parts are one road
	var from_town: Array[Dictionary] = QuestMarkers.targets_for(quest, "town", Session.quest_log, Session.unlock_state())
	assert_eq(from_town.size(), 1)
	assert_eq(str(from_town[0]["spot"]), "portal_gourmand")
	assert_true(bool(from_town[0]["via"]))


func test_the_favour_step_marks_all_three_givers_and_drops_a_finished_one() -> void:
	Session.offer_auto_quests()
	Session.set_flag(CorruptedNpcs.unlock_flag("gourmand"))
	Session.set_flag(Gatekeepers.entered_flag("gourmand"))
	var main: QuestData = QuestCatalog.find(QuestDefinitions.zone_main_id("gourmand"))
	var targets: Array[Dictionary] = QuestMarkers.targets_for(main, "gourmand", Session.quest_log, Session.unlock_state())
	var spots: Array[String] = []
	for target: Dictionary in targets:
		spots.append(str(target["spot"]))
	assert_eq(spots, ["tarragon", "dolcetta", "odalys"] as Array[String], "the three favour givers")
	assert_true(str(targets[2]["label"]).begins_with("Basil"), "named after the person")
	Session.quest_log.completed.append(BuffetZone.QUEST_PIE)
	targets = QuestMarkers.targets_for(main, "gourmand", Session.quest_log, Session.unlock_state())
	# one favour done: the step is done and the line moves on to the dungeon step, which marks Sir Loin's gate and the Test Kitchen
	spots.clear()
	for target: Dictionary in targets:
		spots.append(str(target["spot"]))
	assert_eq(spots, ["gate_quest", "main_dungeon"] as Array[String], "the gate on the road is marked until it opens")
	Session.set_flag(BuffetZone.FLAG_GATE_QUEST)
	targets = QuestMarkers.targets_for(main, "gourmand", Session.quest_log, Session.unlock_state())
	assert_eq(targets.size(), 1, "the gate open: only the dungeon door is left")


func test_every_active_quest_is_listed_for_the_map_with_the_tracked_one_first() -> void:
	Session.offer_auto_quests()
	Session.start_quest(BuffetZone.QUEST_MEND)
	Session.start_quest(BuffetZone.QUEST_PANTRY)
	Session.quest_log.track(BuffetZone.QUEST_PANTRY)
	var all: Array[Dictionary] = QuestMarkers.all_targets("gourmand", Session.quest_log, Session.unlock_state())
	assert_true(all.size() >= 6 + 3, "six ingredients for the Pantry Run, three parts for the Meatloaf")
	assert_eq(str(all[0]["quest"]), BuffetZone.QUEST_PANTRY, "the tracked quest first")
	assert_true(bool(all[0]["tracked"]))
	assert_eq(str(all[0]["title"]), "Pantry Run")
	var mend_seen: bool = false
	for target: Dictionary in all:
		if str(target["quest"]) == BuffetZone.QUEST_MEND:
			mend_seen = true
			assert_false(bool(target["tracked"]))
	assert_true(mend_seen, "the untracked quest is listed too")
	# the goal pointer still follows the tracked quest and the other kind only
	var goals: Array[Dictionary] = QuestMarkers.goal_targets("gourmand", Session.quest_log, Session.unlock_state())
	for goal: Dictionary in goals:
		assert_ne(str(goal["quest"]), BuffetZone.QUEST_MEND, "two side quests: only the tracked one gets chevrons")


func test_roaming_enemy_steps_mark_the_roamers_and_stash_steps_the_stashes() -> void:
	var backlog: QuestData = QuestCatalog.find(ZoneQuestDefinitions.BACKLOG)
	assert_eq(backlog.objectives[0].targets(Session.unlock_state())[0]["spot"], QuestMarkers.SPOT_ROAMERS)
	var audit: QuestData = QuestCatalog.find(ZoneQuestDefinitions.AUDIT)
	assert_eq(audit.objectives[1].targets(Session.unlock_state())[0]["spot"], QuestMarkers.SPOT_CHESTS)
	var well: QuestData = QuestCatalog.find(ZoneQuestDefinitions.SIDE_TOWN)
	assert_eq(well.objectives[0].targets(Session.unlock_state())[0]["spot"], QuestMarkers.SPOT_HARBOR_CHEST)
	# and that quest completes on the giant chest's own secret id (the old "harbor_chest" id was set by nothing any more)
	Session.start_quest(ZoneQuestDefinitions.SIDE_TOWN)
	Session.discover_secret(NinjaBoss.secret_id(NinjaBoss.ORIGINAL_CHEST))
	assert_true(Session.quest_log.objective_met(well, 0, Session.unlock_state()))


func test_a_group_resolver_spreads_into_many_places_and_the_arrow_takes_the_nearest() -> void:
	Session.offer_auto_quests()
	Session.start_quest(ZoneQuestDefinitions.BACKLOG)
	Session.quest_log.track(ZoneQuestDefinitions.BACKLOG)
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	var hero: Node3D = Node3D.new()
	hero.name = "Player"
	root.add_child(hero)
	hero.position = Vector3(0, 0, 0)
	var camera: Camera3D = Camera3D.new()
	root.add_child(camera)
	var hud: Control = Control.new()
	root.add_child(hud)
	var roamers: Array[Dictionary] = [
		{"pos": Vector3(30, 0, 0), "top": 1.6, "title": "Clerk", "key": "a"},
		{"pos": Vector3(4, 0, 0), "top": 1.6, "title": "Clerk", "key": "b"},
		{"pos": Vector3(-12, 0, 0), "top": 1.6, "title": "Clerk", "key": "c"},
	]
	var resolver: Callable = func(spot_id: String) -> Dictionary:
		if spot_id == QuestMarkers.SPOT_ROAMERS:
			return QuestMarkerLayer.group(roamers, true)
		return {}
	var layer: QuestMarkerLayer = QuestMarkerLayer.install(root, "necrocrat", camera, resolver, hud)
	layer._hero = hero
	var was: bool = Settings.goal_pointer
	Settings.goal_pointer = true
	layer.refresh()
	assert_eq(layer.chevron_positions().size(), 3, "a chevron on every roamer")
	assert_eq(layer.goals().size(), 3, "a map dot on every roamer")
	assert_true(layer.pointer.target_valid)
	assert_almost_eq(layer.pointer.target.x, 4.0, 0.01, "the arrow points at the nearest roamer")
	var pois: Array[MapPoi] = []
	layer.add_map_pois(pois)
	assert_eq(pois.size(), 3)
	assert_true(pois[0].tracked_goal, "the tracked quest's dots pin to the minimap's rim")
	assert_eq(pois[0].label, "Clear the Backlog: Roaming staff (any)")
	Settings.goal_pointer = was


func test_point_me_to_lists_the_goals_first_and_names_them() -> void:
	var goal: MapPoi = MapPoi.make(MapPoi.Kind.INTERACTABLE, Vector3(1, 0, 1), "Mend the Meatloaf: Sea Salt Crystals")
	goal.objective = true
	var twin: MapPoi = MapPoi.make(MapPoi.Kind.INTERACTABLE, Vector3(1, 0, 1), "Mend the Meatloaf: Sea Salt Crystals")
	twin.objective = true
	var shop: MapPoi = MapPoi.make(MapPoi.Kind.VENDOR, Vector3(5, 0, 5), "Mirepoix's")
	var entries: Array[MapPoi] = FullMapScreen.where_to_entries([shop, goal, twin] as Array[MapPoi])
	assert_eq(entries.size(), 2, "one line per goal place, then the places")
	assert_eq(entries[0], goal)
	assert_eq(FullMapScreen.where_to_text(goal), "Goal - Mend the Meatloaf: Sea Salt Crystals")
	assert_eq(FullMapScreen.where_to_text(shop), "Mirepoix's (Vendor)")


func test_landmark_names_are_written_before_minor_ones() -> void:
	var pad: MapPoi = MapPoi.make(MapPoi.Kind.BOUNCE_PAD, Vector3.ZERO, "Jelly pad")
	var door: MapPoi = MapPoi.make(MapPoi.Kind.DUNGEON, Vector3.ZERO, "The Test Kitchen")
	var stew: MapPoi = MapPoi.make(MapPoi.Kind.INTERACTABLE, Vector3.ZERO, "The Mystery Stew Pot")
	var exit: MapPoi = MapPoi.make(MapPoi.Kind.EXIT, Vector3.ZERO, "Back to Town")
	var ordered: Array[MapPoi] = FullMapScreen.label_order([pad, door, stew, exit] as Array[MapPoi])
	assert_eq(ordered, [door, exit, pad, stew] as Array[MapPoi])


func test_the_audit_refuses_a_step_with_nothing_to_mark() -> void:
	var audit: QuestAudit = QuestAudit.new()
	audit._scan()
	var blank: QuestData = QuestData.new()
	blank.id = "audit_probe_blank"
	blank.auto_give = true
	blank.giver_area = "town"
	blank.turn_in_area = "town"
	blank.objectives = [
		QuestObjective.make("Do a thing somewhere", Condition.flag("trial_cleared")),
		QuestObjective.make("Open a menu", Condition.flag("trial_cleared")).in_menu(),
		QuestObjective.make("Fetch two things", Condition.flag("trial_cleared")).part(QuestObjective.TargetKind.ITEM_COUNT, "gourmand", "pickup_sea_salt").part(QuestObjective.TargetKind.ITEM_COUNT, "nowhere", "no_such_thing"),
	] as Array[QuestObjective]
	audit._check_quest(blank)
	var text: String = "\n".join(audit.errors)
	assert_string_contains(text, "step 1 (Do a thing somewhere): no marker target")
	assert_false(text.contains("step 2 (Open a menu)"), "a menu step passes")
	assert_string_contains(text, "part area 'nowhere'")
	assert_string_contains(text, "part spot 'no_such_thing'")
	assert_false(text.contains("pickup_sea_salt"), "a real spot passes")
