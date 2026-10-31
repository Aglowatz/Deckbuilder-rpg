extends GutTest
## Overnight Oct 30-31, Part 2: the goal pointer's targets - the tracked quest's step first, then the other kind's (main line / side quest),
## a turn-in in this area points at the NPC to hand it to, and the setting that hides the goal pointer.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.quest_log.reset()
	Session.flags = {QuestDefinitions.LEGACY_FLAG: true}
	Session.counters = {}
	Session.pending_popups = []


func test_the_tracked_main_line_is_the_one_goal_without_a_side_quest() -> void:
	Session.offer_auto_quests()
	Session.quest_log.track(QuestDefinitions.zone_main_id("beefcake"))
	var goals: Array[Dictionary] = QuestMarkers.goal_targets("town", Session.quest_log, Session.unlock_state())
	assert_eq(goals.size(), 1, "one goal: the other main lines are not side quests")
	assert_eq(str(goals[0]["spot"]), "npc_beefcake")
	assert_true(bool(goals[0]["main"]))


func test_a_side_quest_adds_a_second_goal_after_the_tracked_main_line() -> void:
	Session.offer_auto_quests()
	Session.start_quest(GainlandsZone.QUEST_POWER)
	Session.quest_log.track(QuestDefinitions.zone_main_id("beefcake"))
	var goals: Array[Dictionary] = QuestMarkers.goal_targets("town", Session.quest_log, Session.unlock_state())
	assert_eq(goals.size(), 2)
	assert_eq(str(goals[0]["spot"]), "npc_beefcake", "the tracked main line first")
	assert_true(bool(goals[0]["main"]))
	assert_eq(str(goals[1]["spot"]), "portal_beefcake", "the side quest is in the Gainlands: down its road")
	assert_false(bool(goals[1]["main"]))


func test_tracking_the_side_quest_puts_it_first_and_a_main_line_second() -> void:
	Session.offer_auto_quests()
	Session.start_quest(GainlandsZone.QUEST_POWER)
	Session.quest_log.track(GainlandsZone.QUEST_POWER)
	var goals: Array[Dictionary] = QuestMarkers.goal_targets("town", Session.quest_log, Session.unlock_state())
	assert_eq(goals.size(), 2)
	assert_false(bool(goals[0]["main"]), "the tracked side quest first")
	assert_true(bool(goals[1]["main"]), "then the most recent main line with a goal here")


func test_a_turn_in_here_points_at_the_npc() -> void:
	Session.start_quest(GainlandsZone.QUEST_POWER)
	Session.set_flag(GainlandsZone.FLAG_WHEEL_POWERED)
	Session.bump_counter(GainlandsZone.COUNTER_SHAKES)
	Session.quest_log.track(GainlandsZone.QUEST_POWER)
	var goals: Array[Dictionary] = QuestMarkers.goal_targets("beefcake", Session.quest_log, Session.unlock_state())
	assert_eq(goals.size(), 1)
	assert_eq(str(goals[0]["spot"]), "gus", "the arrow leads to the NPC wearing the ?")
	assert_true(bool(goals[0].get("turn_in", false)))
	assert_true(QuestMarkers.objective_target("beefcake", Session.quest_log, Session.unlock_state()).is_empty(), "the old single marker is unchanged")


func test_the_layer_draws_two_goals_and_the_setting_hides_them() -> void:
	Session.offer_auto_quests()
	Session.start_quest(GainlandsZone.QUEST_POWER)
	Session.quest_log.track(QuestDefinitions.zone_main_id("beefcake"))
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	var camera: Camera3D = Camera3D.new()
	root.add_child(camera)
	var hud: Control = Control.new()
	root.add_child(hud)
	var spots: Dictionary = {"npc_beefcake": Vector3(5, 0, 5), "portal_beefcake": Vector3(-20, 0, 3)}
	var resolver: Callable = func(spot_id: String) -> Dictionary: return {"pos": spots[spot_id], "top": 2.0} if spots.has(spot_id) else {}
	var layer: QuestMarkerLayer = QuestMarkerLayer.install(root, "town", camera, resolver, hud)
	var was: bool = Settings.goal_pointer
	Settings.goal_pointer = true
	layer.refresh()
	assert_eq(layer.goals().size(), 2)
	assert_true(layer.pointer.target_valid and layer.side_pointer.target_valid, "an arrow for each goal")
	assert_eq(layer.side_pointer.color, QuestMarkerLayer.SIDE_BLUE, "the side quest's arrow is blue")
	var pois: Array[MapPoi] = []
	layer.add_map_pois(pois)
	var dots: int = 0
	for poi: MapPoi in pois:
		if poi.objective:
			dots += 1
	assert_eq(dots, 2, "a map dot for each goal")
	Settings.goal_pointer = false
	layer.refresh()
	assert_eq(layer.goals().size(), 0, "the setting hides the goals")
	assert_false(layer.pointer.target_valid or layer.side_pointer.target_valid, "and the arrows")
	assert_eq(layer.objective_position(), Vector3.INF, "and the chevron")
	Settings.goal_pointer = was
