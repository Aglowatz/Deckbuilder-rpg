extends GutTest
## Fable pass Nov 10 (Part 1.6, the wayfinding critic's report): a side quest in hand keeps the tracker from the next one accepted; the
## map's "Point me to..." list has one row per goal name; the Dump's main line marks the stream crossing (a Magic Bean, the West Sprout
## Mound) until a bridge is grown; Sir Loin has a line for a mended loaf not yet reported; the Gainlands' forecourt pocket beside the
## stairs is not walkable and the Steps banner sits on the steps.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.GOURMAND)
	Session.quest_log.reset()
	Session.flags = {QuestDefinitions.LEGACY_FLAG: true}
	Session.counters = {}


func test_a_side_quest_in_hand_keeps_the_tracker_from_the_next_one() -> void:
	Session.offer_auto_quests()
	var main_id: String = QuestDefinitions.zone_main_id("gourmand")
	if not Session.quest_log.is_active(main_id):
		pass_test("the Buffet's line is not open in this setup")
		return
	Session.quest_log.track(main_id)
	var favours: Array[String] = ZoneQuestDefinitions.favours_of("gourmand")
	assert_gte(favours.size(), 2, "two favours to take")
	var state: UnlockState = Session.unlock_state()
	var first: QuestData = QuestCatalog.find(favours[0])
	var second: QuestData = QuestCatalog.find(favours[1])
	assert_true(Session.quest_log.start(first, state), "the first favour starts")
	assert_eq(Session.quest_log.tracked_id(), first.id, "a favour takes the tracker from the main quest's favour step")
	assert_true(Session.quest_log.start(second, state), "the second favour starts")
	assert_eq(Session.quest_log.tracked_id(), first.id, "...but not from the favour already in hand")
	# a main quest still takes it from a side quest
	Session.quest_log.active.erase(main_id)
	assert_true(Session.quest_log.start(QuestCatalog.find(main_id), state))
	assert_eq(Session.quest_log.tracked_id(), main_id)


func test_the_point_me_list_has_one_row_per_goal_name() -> void:
	var points: Array[MapPoi] = []
	for index: int in range(14):
		var stash: MapPoi = MapPoi.make(MapPoi.Kind.INTERACTABLE, Vector3(index * 3.0, 0, 0), "The Golden Reservation: A hidden stash (any)")
		stash.objective = true
		points.append(stash)
	var salt: MapPoi = MapPoi.make(MapPoi.Kind.INTERACTABLE, Vector3(50, 0, 0), "Mend the Meatloaf: Sea Salt Crystals (the Salt Flats, by the river)")
	salt.objective = true
	points.append(salt)
	var entries: Array[MapPoi] = FullMapScreen.where_to_entries(points)
	assert_eq(entries.size(), 2, "fourteen stashes make one row, the salt another")
	assert_eq(FullMapScreen.where_to_text(entries[0]), "Goal - The Golden Reservation: A hidden stash (any) (one of 14)")
	assert_eq(FullMapScreen.where_to_text(entries[1]), "Goal - Mend the Meatloaf: Sea Salt Crystals (the Salt Flats, by the river)")
	assert_eq(entries[0].pos, Vector3.ZERO, "the row points at the first")


func test_the_dumps_main_line_marks_the_stream_crossing_until_a_bridge_grows() -> void:
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.zone_main_id("refusemancer"))
	assert_not_null(quest)
	var state: UnlockState = Session.unlock_state()
	for index: int in [2, 3]:  # the favour step and the dungeon step
		var spots: Array[String] = []
		for target: Dictionary in quest.objectives[index].targets(state):
			spots.append(str(target["spot"]))
		assert_has(spots, "pickup_bean_1", "step %d marks the Magic Bean" % index)
		assert_has(spots, "grow_bridge_west", "step %d marks the West Sprout Mound" % index)
	Session.counters[HeapZone.stock_key("bean")] = 1
	state = Session.unlock_state()
	var with_bean: Array[String] = []
	for target: Dictionary in quest.objectives[2].targets(state):
		with_bean.append(str(target["spot"]))
	assert_does_not_have(with_bean, "pickup_bean_1", "a bean in the pocket: the pickup drops")
	assert_has(with_bean, "grow_bridge_west", "the mound stays")
	Session.set_flag(HeapGrowth.find("bridge_center").flag)
	state = Session.unlock_state()
	var crossed: Array[String] = []
	for target: Dictionary in quest.objectives[2].targets(state):
		crossed.append(str(target["spot"]))
	assert_does_not_have(crossed, "grow_bridge_west", "any grown bridge drops the crossing")


func test_sir_loin_and_the_bridge_sign_say_what_comes_next() -> void:
	var gourmand: Resource = load("res://data/story/gourmand_story.tres")
	var lines: Dictionary = gourmand.get("lines") as Dictionary
	assert_true(lines.has("gate.quest.mended"), "Sir Loin's line for a mended loaf not yet reported")
	assert_string_contains(" ".join(lines["gate.quest.mended"] as Array), "Tell Basil")
	var dump: Resource = load("res://data/story/refusemancer_story.tres")
	var dump_lines: Dictionary = dump.get("lines") as Dictionary
	assert_string_contains(" ".join(dump_lines["sign.bridge_center"] as Array), "West Sprout Mound")
	assert_string_contains(" ".join(dump_lines["grow.bridge_center.need"] as Array), "Magic Bean")


func test_the_gainlands_pocket_beside_the_stairs_is_rubble() -> void:
	assert_true(GainlandsLayout.in_forecourt(64.5, 14.6), "the critic's notch is in the forecourt")
	assert_false(GainlandsLayout.on_stairs(64.5, 14.6))
	var layout: GainlandsLayout = GainlandsLayout.new()
	layout.build()
	var steps: GainlandsLayout.Area = null
	for area: GainlandsLayout.Area in layout.areas:
		if area.id == "steps":
			steps = area
	assert_not_null(steps)
	assert_gt(Vector2(64.5 - steps.center.x, 14.6 - steps.center.y).length(), steps.radius, "the Steps banner no longer fires in the notch")
	assert_lt(Vector2(56.0 - steps.center.x, 13.0 - steps.center.y).length(), steps.radius, "...and still on the stairs")
	var builder: GainlandsBuilder = GainlandsBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	assert_false(builder.is_walkable(Vector3(64.5, 4.0, 14.6), 0.3), "the notch beside the stairs' cheek wall is rubble")
	assert_false(builder.is_walkable(Vector3(46.0, 4.0, 15.5), 0.3), "...on the west side too")
	assert_true(builder.is_walkable(Vector3(64.5, 4.0, 18.5), 0.3), "the forecourt south of it is open")
	assert_true(builder.is_walkable(Vector3(56.0, 4.0, 15.0), 0.3), "and the stairs themselves")
