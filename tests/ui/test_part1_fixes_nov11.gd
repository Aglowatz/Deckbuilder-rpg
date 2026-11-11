extends GutTest
## Overnight Nov 10-11, Part 1 (the exported-build critic's top 10): the main quest's dungeon step names its gate and what opens it (and
## says the way is clear once it is); identical tokens on the battlefield share one slot with a "xN" badge; the Setting Up hourglass has words
## beside it during the fight; the "Point me to..." places are alphabetical; the HUD toast never outlives TOAST_MAX_HOLD and clears on demand.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.GOURMAND)
	Session.quest_log.reset()
	Session.flags = {QuestDefinitions.LEGACY_FLAG: true}
	Session.counters = {}


# ---- 1.1 the dungeon step names its gate ------------------------------------------------------------------------------------------------


func _dungeon_step(zone_id: String) -> QuestObjective:
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.zone_main_id(zone_id))
	assert_not_null(quest, zone_id)
	return quest.objectives[3]


func test_every_zones_dungeon_step_says_what_opens_the_way() -> void:
	var expect: Dictionary = {
		"beefcake": ["Nothing is locked", "middle road"],
		"necrocrat": ["door is open", "no favour"],
		"gourmand": ["Sir Loin's gate", "Old Meatloaf", "Basil"],
		"refusemancer": ["Magic Bean", "West Sprout Mound", "barricade", "stables"],
	}
	for zone_id: String in expect.keys():
		var step: QuestObjective = _dungeon_step(zone_id)
		var words: Array = expect[zone_id] as Array
		for word: Variant in words:
			assert_string_contains(step.hint, str(word), "%s's dungeon step names it" % zone_id)


func test_the_buffets_where_to_go_names_sir_loins_gate_until_it_opens() -> void:
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.zone_main_id("gourmand"))
	var step: QuestObjective = quest.objectives[3]
	var state: UnlockState = Session.unlock_state()
	assert_false(step.way_open(state), "the gate part is still undone")
	assert_string_contains(step.hint, "Sir Loin's gate on the way wants Old Meatloaf mended - see Basil")
	Session.set_flag(BuffetZone.FLAG_GATE_QUEST)
	state = Session.unlock_state()
	assert_true(step.way_open(state), "only the Test Kitchen itself is left to mark")
	assert_string_contains(step.hint_open, "Sir Loin's gate is open")
	# the Quest Log's line, with the gatekeeper beaten, the zone entered and a favour done: the dungeon step is current and the gate open
	Session.set_flag(CorruptedNpcs.unlock_flag("gourmand"))
	Session.set_flag(Gatekeepers.entered_flag("gourmand"))
	Session.quest_log.completed.append(ZoneQuestDefinitions.favours_of("gourmand")[0])
	Session.quest_log.start(quest, Session.unlock_state())
	var line: String = QuestLogScreen.where_to_go(quest, Session.unlock_state())
	assert_string_contains(line, "Sir Loin's gate is open", "the log's Where to go line (%s)" % line)
	Session.flags.erase(BuffetZone.FLAG_GATE_QUEST)
	line = QuestLogScreen.where_to_go(quest, Session.unlock_state())
	assert_string_contains(line, "Sir Loin's gate on the way wants Old Meatloaf mended", "...and names the gate while it is shut (%s)" % line)


func test_the_dumps_where_to_go_clears_once_the_barricade_is_down() -> void:
	var step: QuestObjective = _dungeon_step("refusemancer")
	assert_false(step.way_open(Session.unlock_state()))
	Session.set_flag(HeapGrowth.find("bridge_west").flag)
	Session.set_flag(HeapGrowth.find_barricade("gate").flag)
	Session.counters[HeapZone.stock_key("bean")] = 1
	assert_true(step.way_open(Session.unlock_state()), "bridge grown, barricade smashed: the way is open")
	assert_string_contains(step.hint_open, "The way is clear")


func test_the_dna_marks_the_halls_door_from_the_favour_step() -> void:
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.zone_main_id("necrocrat"))
	var favour_step: QuestObjective = quest.objectives[2]
	var marked: Array[String] = []
	for target: Dictionary in favour_step.targets(Session.unlock_state()):
		marked.append(str(target["spot"]))
	assert_has(marked, "main_dungeon", "the Hall's door is marked while the favour step is current")
	assert_string_contains(favour_step.hint, "no favour needed")


# ---- 1.4 identical tokens share one slot ------------------------------------------------------------------------------------------------


func _game() -> GameState:
	CardSet.load_all()
	return GameFactory.blank_game()


func _board(game: GameState) -> BattleBoard:
	var fx: BattleFX = BattleFX.new()
	add_child_autofree(fx)
	var board: BattleBoard = BattleBoard.new()
	add_child_autofree(board)
	board.setup(game, fx)
	board.speed = 50.0
	board.sync_state(false)
	return board


func _weenie() -> CardData:
	var data: CardData = CardSet.card("T-03")
	assert_not_null(data, "the Sashimi Weenie token")
	return data


func test_seven_identical_tokens_make_one_slot_with_a_count() -> void:
	var game: GameState = _game()
	var data: CardData = _weenie()
	for _index: int in range(7):
		game.create_token(1, data)
	var board: BattleBoard = _board(game)
	board.layout(false)
	var stacks: Array[Dictionary] = board.field_stacks_of(1)
	assert_eq(stacks.size(), 1, "one slot")
	assert_eq(int(stacks[0]["count"]), 7)
	var badge: Label = board.get_node_or_null("FieldStack1_0") as Label
	assert_not_null(badge, "the count badge")
	if badge != null:
		assert_true(badge.visible)
		assert_eq(badge.text, "x7")
	var uids: Array = stacks[0]["uids"] as Array
	var first: CardView = board.view_for(int(uids[0]))
	var last: CardView = board.view_for(int(uids[6]))
	assert_lt(first.position.distance_to(last.position), 40.0, "the seven lie on one spot (slightly offset)")
	assert_eq(int(last.get_meta("stack_depth")), 6)


func test_a_damaged_or_attacking_token_leaves_the_stack() -> void:
	var game: GameState = _game()
	var data: CardData = _weenie()
	var tokens: Array[CardInstance] = []
	for _index: int in range(4):
		tokens.append(game.create_token(1, data))
	tokens[0].damage = 1
	var board: BattleBoard = _board(game)
	board.attacking[tokens[1].uid] = true
	board.layout(false)
	var stacks: Array[Dictionary] = board.field_stacks_of(1)
	assert_eq(stacks.size(), 3, "the hurt one, the attacker and the pair")
	var counts: Array[int] = []
	for stack: Dictionary in stacks:
		counts.append(int(stack["count"]))
	counts.sort()
	assert_eq(counts, [1, 1, 2])
	var badge: Label = board.get_node_or_null("FieldStack1_0") as Label
	assert_not_null(badge)
	if badge != null:
		assert_eq(badge.text, "x2")
	assert_true(board.get_node_or_null("FieldStack1_1") == null or not (board.get_node_or_null("FieldStack1_1") as Label).visible, "no second badge")


func test_real_cards_never_stack() -> void:
	var game: GameState = _game()
	var content: ContentSet = ContentLibrary.load_all()
	var data: CardData = null
	for id: Variant in content.cards.keys():
		var candidate: CardData = content.cards[id] as CardData
		if candidate != null and candidate.is_unit() and not candidate.is_token:
			data = candidate
			break
	assert_not_null(data)
	for _index: int in range(3):
		var card: CardInstance = game.create_instance(data, 0)
		game.players[0].field.append(card)
	var board: BattleBoard = _board(game)
	board.layout(false)
	assert_eq(board.field_stacks_of(0).size(), 3, "three copies of a real card keep three slots")


# ---- 1.5 words beside the hourglass -----------------------------------------------------------------------------------------------------


func test_the_setting_up_badge_says_when_attacks_start() -> void:
	var context: BattleContext = Session.make_town_battle(TownEnemies.HOUND, "town_hound")
	var game: GameState = context.game
	game.players[1].modifiers.add(CardBuilder.modifier(Modifier.Kind.SETUP_TURNS, 2))
	var hud: BattleHud = BattleHud.new()
	add_child_autofree(hud)
	hud.setup(game, context.enemy_name, context.enemy_icon)
	var badges: Array[RuleBadges.Badge] = RuleBadges.for_encounter([BossTempo.rule(2)] as Array[EncounterModifiers.Rule])
	hud.set_rule_badges(badges)
	await wait_process_frames(1)
	assert_eq(hud.rule_row.note_text(BossTempo.RULE_NAME), "Setting Up - attacks start Turn 3")
	# the window over: the words go, the icon stays
	game.players[1].turns_taken = 3
	hud.refresh_all()
	await wait_process_frames(1)
	assert_eq(hud.rule_row.note_text(BossTempo.RULE_NAME), "")
	assert_not_null(hud.rule_row.find_child("Badge_Setting_Up", true, false))


# ---- 1.8 the list's order ---------------------------------------------------------------------------------------------------------------


func test_point_me_to_places_are_alphabetical_after_the_goals() -> void:
	var points: Array[MapPoi] = []
	points.append(MapPoi.make(MapPoi.Kind.VENDOR, Vector3(1, 0, 0), "Madame Mirepoix"))
	points.append(MapPoi.make(MapPoi.Kind.DUNGEON, Vector3(2, 0, 0), "The Test Kitchen"))
	points.append(MapPoi.make(MapPoi.Kind.QUEST_GIVER, Vector3(3, 0, 0), "Basil"))
	points.append(MapPoi.make(MapPoi.Kind.QUEST_GIVER, Vector3(4, 0, 0), "Sous-Chef Tarragon"))
	var goal: MapPoi = MapPoi.make(MapPoi.Kind.INTERACTABLE, Vector3(5, 0, 0), "Mend the Meatloaf: Sea Salt Crystals")
	goal.objective = true
	points.append(goal)
	var labels: Array[String] = []
	for poi: MapPoi in FullMapScreen.where_to_entries(points):
		labels.append(poi.label)
	assert_eq(labels, ["Mend the Meatloaf: Sea Salt Crystals", "Basil", "Madame Mirepoix", "Sous-Chef Tarragon", "The Test Kitchen"])
	# the same points in another order give the same list
	points.reverse()
	var again: Array[String] = []
	for poi: MapPoi in FullMapScreen.where_to_entries(points):
		again.append(poi.label)
	assert_eq(again, labels, "stable whatever order the layer met them in")


# ---- 1.6 / 1.9 the HUD toast ------------------------------------------------------------------------------------------------------------


func test_the_toast_is_capped_and_clears_on_demand() -> void:
	var hud: TownHud = TownHud.new()
	add_child_autofree(hud)
	await wait_process_frames(1)
	hud.toast("Basil has a favour to ask. Talk again.", UIStyle.GOLD, 30.0)
	assert_eq(hud.toast_text(), "Basil has a favour to ask. Talk again.")
	assert_lte(hud._toast_deadline_msec - Time.get_ticks_msec(), int((TownHud.TOAST_MAX_HOLD + 0.5) * 1000.0) + 50, "a 30 s hold is capped")
	hud.clear_toast("something else")
	assert_eq(hud.toast_text(), "Basil has a favour to ask. Talk again.", "a clear for another text leaves it")
	hud.clear_toast("has a favour to ask")
	assert_eq(hud.toast_text(), "", "accepting the favour clears the hint")
