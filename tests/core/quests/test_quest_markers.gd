extends GutTest
## Overnight Oct 16: quest givers' "!" / "?" marks, the single objective marker of the tracked quest, and the edge-of-screen pointer.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.quest_log.reset()
	Session.flags = {}
	Session.counters = {}
	Session.pending_popups = []


func test_a_giver_with_a_quest_on_offer_shows_an_exclamation_mark() -> void:
	var marks: Dictionary = QuestMarkers.giver_marks("town", Session.quest_log, QuestCatalog.all(), Session.unlock_state())
	assert_eq(str(marks.get("guard", "")), QuestMarkers.MARK_OFFER, "Brannoch offers Free the Four Zones")
	var gainlands: Dictionary = QuestMarkers.giver_marks("beefcake", Session.quest_log, QuestCatalog.all(), Session.unlock_state())
	assert_eq(str(gainlands.get("gus", "")), QuestMarkers.MARK_OFFER)
	assert_false(gainlands.has("guard"), "marks belong to their own area")


func test_a_quest_ready_to_hand_in_shows_a_question_mark_instead() -> void:
	Session.start_quest(GainlandsZone.QUEST_POWER)
	var marks: Dictionary = QuestMarkers.giver_marks("beefcake", Session.quest_log, QuestCatalog.all(), Session.unlock_state())
	assert_false(marks.has("gus"), "nothing to offer or hand in while it is under way")
	Session.set_flag(GainlandsZone.FLAG_WHEEL_POWERED)
	Session.bump_counter(GainlandsZone.COUNTER_SHAKES)
	marks = QuestMarkers.giver_marks("beefcake", Session.quest_log, QuestCatalog.all(), Session.unlock_state())
	assert_eq(str(marks.get("gus", "")), QuestMarkers.MARK_TURN_IN)


func test_the_objective_marker_follows_only_the_tracked_quest() -> void:
	Session.offer_auto_quests()
	var main_id: String = QuestDefinitions.zone_main_id("beefcake")
	Session.quest_log.track(main_id)
	var target: Dictionary = QuestMarkers.objective_target("town", Session.quest_log, Session.unlock_state())
	assert_eq(str(target.get("spot", "")), "npc_beefcake", "the gatekeeper first")
	assert_false(bool(target.get("via", true)))
	Session.quest_log.track(QuestDefinitions.zone_main_id("gourmand"))
	target = QuestMarkers.objective_target("town", Session.quest_log, Session.unlock_state())
	assert_eq(str(target.get("spot", "")), "npc_gourmand", "one marker: the newly tracked quest's")


func test_a_target_in_another_area_points_at_the_way_there() -> void:
	Session.offer_auto_quests()
	var main_id: String = QuestDefinitions.zone_main_id("beefcake")
	Session.set_flag(CorruptedNpcs.unlock_flag("beefcake"))
	Session.set_flag(Gatekeepers.entered_flag("beefcake"))
	Session.quest_log.track(main_id)
	var in_town: Dictionary = QuestMarkers.objective_target("town", Session.quest_log, Session.unlock_state())
	assert_eq(str(in_town.get("spot", "")), "portal_beefcake", "the favour is in the Gainlands: point down its road")
	assert_true(bool(in_town.get("via", false)))
	var in_zone: Dictionary = QuestMarkers.objective_target("beefcake", Session.quest_log, Session.unlock_state())
	assert_eq(str(in_zone.get("spot", "")), "gus")
	var elsewhere: Dictionary = QuestMarkers.objective_target("necrocrat", Session.quest_log, Session.unlock_state())
	assert_eq(str(elsewhere.get("spot", "")), "exit", "from another zone: the way back to town")


func test_a_turn_in_adds_no_second_marker_where_the_question_mark_stands() -> void:
	Session.start_quest(GainlandsZone.QUEST_POWER)
	Session.set_flag(GainlandsZone.FLAG_WHEEL_POWERED)
	Session.bump_counter(GainlandsZone.COUNTER_SHAKES)
	Session.quest_log.track(GainlandsZone.QUEST_POWER)
	assert_true(QuestMarkers.objective_target("beefcake", Session.quest_log, Session.unlock_state()).is_empty())
	assert_eq(str(QuestMarkers.objective_target("town", Session.quest_log, Session.unlock_state()).get("spot", "")), "portal_beefcake")


func test_the_edge_pointer_only_shows_for_off_screen_targets() -> void:
	var view: Rect2 = Rect2(0, 0, 1920, 1080)
	assert_false(bool(QuestEdgePointer.place(view, Vector2(900, 500), false)["show"]), "on screen: no pointer")
	var right: Dictionary = QuestEdgePointer.place(view, Vector2(4000, 540), false)
	assert_true(bool(right["show"]))
	assert_almost_eq((right["at"] as Vector2).x, 1920.0 - QuestEdgePointer.INSET, 1.0, "clamped to the right edge")
	var behind: Dictionary = QuestEdgePointer.place(view, Vector2(900, 500), true)
	assert_true(bool(behind["show"]), "behind the camera always points")


func test_tracker_window_keeps_long_lists_short() -> void:
	assert_eq(QuestTracker.row_window(4, 2), Vector2i(0, 4))
	assert_eq(QuestTracker.row_window(8, 0), Vector2i(0, QuestTracker.MAX_ROWS))
	assert_eq(QuestTracker.row_window(8, 7), Vector2i(8 - QuestTracker.MAX_ROWS, 8))


func test_the_tracker_names_the_area_of_a_step_elsewhere() -> void:
	assert_eq(QuestTracker.elsewhere_hint(GainlandsZone.ID, Areas.TOWN), "Go to the Gainlands")
	assert_eq(QuestTracker.elsewhere_hint("town", Areas.DNA), "Go to Crosspath")
	assert_eq(QuestTracker.elsewhere_hint(GainlandsZone.ID, Areas.GAINLANDS), "", "already there")
	assert_eq(QuestTracker.elsewhere_hint("", Areas.TOWN), "", "a step with no place")
