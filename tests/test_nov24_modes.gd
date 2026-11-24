extends GutTest
## Fable Nov 24 (Parts 2, 3 and 4): the Shuffle House's four modes, the fixes in the draft screens, and the static Shuffled Halls.
##   Part 2: Classic Draft (your Paths, no Prismatic Packs), Dungeon Draft (the large dungeons you cleared, a Random option, the
##           Halls after their first clear), Mystery Mini (a pack of the dungeon's Path), High Rollers Draft (an entry fee, every
##           piece of equipment for the opponents, better rewards); the retired tables; the quest line; the Path toggles.
##   Part 3: three cards on every pick, the Trade Counter's large card, the result as a standard pop-up, a wide cast of opponents
##           whose Paths never follow the player's choice.
##   Part 4: every fight of the Halls preset (its own deck in its own Paths, fixed equipment, its own rules), the Counting
##           Halls' cash-out, the question marks.

const P := Affinity.Type
const HALLS_FIGHT_ROOMS: Array[int] = [2, 3, 5, 7, 8, 10, 12, 14, 15, 19]

var content: ContentSet


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game()
	Session.draft = null
	Session.pending_draft_result = {}
	Session.gold = 1000
	content = Session.content
	DraftRules.reload()


func after_each() -> void:
	for panel: CanvasItem in _runner_panels:
		if is_instance_valid(panel):
			panel.visible = true
	_runner_panels.clear()
	if Session.draft_dungeon_active:
		Session.resolve_draft_dungeon(false)
	Session.draft = null
	Session.pending_draft_result = {}


func _free(zones: Array[String]) -> void:
	for zone_id: String in zones:
		Session.flags[str(ZoneCompletion.flag_name(zone_id))] = true


func _open_house() -> void:
	Session.set_flag(StringName(DraftChallenges.ARENA_FLAG))


func _after_primm() -> void:
	Session.flags[str(MultiPathLock.FLAG_UNLOCKED)] = true


func _pick_all() -> void:
	var guard: int = 0
	while Session.draft != null and Session.draft.phase == DraftState.PHASE_PICK and guard < 100:
		Session.draft_pick(guard % 3)
		guard += 1


func _to_run(challenge_id: String, paths: Array[int]) -> void:
	assert_eq(Session.draft_start_problem(challenge_id, paths), "", "%s can start" % challenge_id)
	assert_true(Session.start_draft(challenge_id, paths))
	_pick_all()
	assert_true(Session.draft_begin_run())


func _finish_fight(won: bool) -> Dictionary:
	var real: PlayerProfile = Session.profile
	var context: BattleContext = Session.make_draft_battle()
	Session._draft_real_profile = real
	Session.profile = context.draft_profile
	context.game.winner = 0 if won else 1
	return Session.resolve_draft_battle(context)


func _win_table(challenge_id: String, paths: Array[int]) -> Dictionary:
	_to_run(challenge_id, paths)
	var last: Dictionary = {}
	for i: int in range(3):
		last = _finish_fight(true)
	return last


func _halls_node(number: int) -> DungeonMap.MapNode:
	for node: DungeonMap.MapNode in Session.dungeon_map.nodes:
		if node.number == number:
			return node
	return null


func _enter_halls(paths: Array[int]) -> void:
	_open_house()
	_to_run(DraftArena.HALLS_ID, paths)
	assert_true(Session.prepare_draft_dungeon())


# ---- Part 2: the four modes ---------------------------------------------------------------------------------------------------------


func test_the_menu_is_four_modes_and_the_halls() -> void:
	assert_eq(DraftArena.MODES, [DraftArena.MODE_CLASSIC, DraftArena.MODE_DUNGEON, DraftArena.MODE_MYSTERY, DraftArena.MODE_HIGH] as Array[String])
	assert_eq(DraftArena.mode_title(DraftArena.MODE_CLASSIC), "Classic Draft")
	assert_eq(DraftArena.mode_title(DraftArena.MODE_DUNGEON), "Dungeon Draft")
	assert_eq(DraftArena.mode_title(DraftArena.MODE_MYSTERY), "Mystery Mini")
	assert_eq(DraftArena.mode_title(DraftArena.MODE_HIGH), "High Rollers Draft")
	assert_eq(DraftArena.mode_of(DraftArena.CLASSIC_ID), DraftArena.MODE_CLASSIC)
	assert_eq(DraftArena.mode_of(DraftArena.daily_id()), DraftArena.MODE_CLASSIC, "the Draft of the Day sits under Classic")
	assert_eq(DraftArena.mode_of(DraftArena.HIGH_ID), DraftArena.MODE_HIGH)
	assert_eq(DraftArena.mode_of(DraftArena.dungeon_id("beefcake")), DraftArena.MODE_DUNGEON)
	assert_eq(DraftArena.mode_of(DraftArena.HALLS_ID), "", "the Shuffled Halls are their own door")
	assert_eq(DraftChallenges.title(DraftArena.CLASSIC_ID), "Classic Draft")
	assert_eq(DraftChallenges.title(DraftArena.HIGH_ID), "High Rollers Draft")


func test_the_separate_tables_are_gone() -> void:
	_open_house()
	_free(["beefcake", "gourmand", "necrocrat", "refusemancer"] as Array[String])
	_after_primm()
	var retired: Array[String] = []
	retired.append_array(DraftArena.pair_ids())
	retired.append_array(DraftArena.trio_ids())
	retired.append_array(DraftArena.high_ids())
	retired.append(DraftArena.QUAD_ID)
	for id: String in retired:
		assert_true(DraftArena.is_retired(id), "%s is a retired table" % id)
		assert_ne(Session.draft_start_problem(id, [int(P.BEEFCAKE)] as Array[int]), "", "%s cannot be started any more" % id)
		assert_false(Session.start_draft(id, [int(P.BEEFCAKE)] as Array[int]))
	assert_false(DraftArena.is_retired(DraftArena.CLASSIC_ID))
	assert_false(DraftArena.is_retired(DraftArena.HIGH_ID))
	# the menu has no tile for them: four modes, the Draft of the Day, the Halls' door
	var screen: DraftHubScreen = DraftHubScreen.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	var tiles: Array[String] = []
	for node: Node in screen.find_children("Mode_*", "Button", true, false):
		tiles.append(str(node.name))
	tiles.sort()
	assert_eq(tiles, ["Mode_classic", "Mode_daily", "Mode_dungeon", "Mode_halls", "Mode_high", "Mode_mystery"] as Array[String])
	assert_eq(screen.find_children("Tile_*", "", true, false).size(), 0, "the grid of tiles is gone")


func test_classic_never_pays_a_prismatic_pack() -> void:
	for after_primm: bool in [false, true]:
		for first: bool in [false, true]:
			for paths: Array in [[int(P.BEEFCAKE)], [int(P.BEEFCAKE), int(P.GOURMAND)], [1, 2, 3, 4]]:
				var typed: Array[int] = []
				typed.assign(paths)
				for id: String in [DraftArena.CLASSIC_ID, DraftArena.daily_id()]:
					var pay: Dictionary = DraftChallenges.reward(3, true, first, id, typed, after_primm)
					assert_false((pay["packs"] as Array).has(PackRules.PRISMATIC_ID), "%s pays no Prismatic Pack (after Primm %s, first %s)" % [id, after_primm, first])
					assert_false((pay["packs"] as Array).is_empty(), "but it pays a pack")


func test_high_rollers_has_an_entry_fee_every_time() -> void:
	_open_house()
	var paths: Array[int] = [int(P.NECROCRAT)]
	assert_eq(Session.draft_fee(DraftArena.HIGH_ID), 200, "the owner's default")
	assert_eq(DraftRules.entry_fee_for(DraftArena.KIND_HIGH), 200)
	assert_eq(Session.draft_fee(DraftArena.CLASSIC_ID), 0, "Classic stays free")
	assert_eq(Session.draft_fee(DraftArena.MYSTERY_ID), 0)
	assert_eq(Session.draft_fee(DraftArena.HALLS_ID), 0)
	Session.gold = 150
	assert_string_contains(Session.draft_start_problem(DraftArena.HIGH_ID, paths), "200")
	assert_false(Session.start_draft(DraftArena.HIGH_ID, paths), "no seat without the fee")
	assert_eq(Session.gold, 150)
	Session.gold = 500
	assert_true(Session.start_draft(DraftArena.HIGH_ID, paths))
	assert_eq(Session.gold, 300, "the fee is paid at the door")
	assert_eq(Session.draft.fee_paid, 200)
	Session.close_draft()
	assert_true(Session.start_draft(DraftArena.HIGH_ID, paths))
	assert_eq(Session.gold, 100, "and again on the second attempt: no free first seat")


func test_high_rollers_pays_more_than_classic_prismatic_included() -> void:
	var paths: Array[int] = [int(P.GOURMAND)]
	for wins: int in range(4):
		var classic: Dictionary = DraftChallenges.reward(wins, wins == 3, false, DraftArena.CLASSIC_ID, paths, true)
		var high: Dictionary = DraftChallenges.reward(wins, wins == 3, false, DraftArena.HIGH_ID, paths, true)
		assert_gt(int(high["gold"]), int(classic["gold"]), "%d wins: more gold than Classic" % wins)
		assert_gt(int(high["xp"]), int(classic["xp"]), "%d wins: more XP than Classic" % wins)
	var after: Dictionary = DraftChallenges.reward(3, true, false, DraftArena.HIGH_ID, paths, true)
	assert_true((after["packs"] as Array).has(PackRules.PRISMATIC_ID), "three wins pay a Prismatic Pack")
	var before: Dictionary = DraftChallenges.reward(3, true, false, DraftArena.HIGH_ID, paths, false)
	assert_false((before["packs"] as Array).has(PackRules.PRISMATIC_ID), "before Primm the Prismatic Pack is a Gilded one (the lock stays)")
	assert_eq((before["packs"] as Array).size(), 1)
	# three wins clear the fee with room to spare; two wins cover it
	assert_gt(int(after["gold"]), 2 * Session.draft_fee(DraftArena.HIGH_ID))
	assert_gte(int(DraftChallenges.reward(2, false, false, DraftArena.HIGH_ID, paths, true)["gold"]), Session.draft_fee(DraftArena.HIGH_ID))
	# a Classic Draft for higher stakes: three wins or two losses, like Classic
	assert_eq(DraftChallenges.losses_to_finish(DraftArena.HIGH_ID), DraftChallenges.losses_to_finish(DraftArena.CLASSIC_ID))
	assert_eq(DraftChallenges.losses_to_finish(DraftArena.HIGH_ID), 2)


func test_high_rollers_opponents_can_get_every_piece_of_equipment() -> void:
	assert_eq(DraftRules.rival_equipment_cap(DraftArena.KIND_HIGH), int(EquipmentData.Rarity.LEGENDARY))
	assert_eq(DraftRules.rival_equipment_cap(DraftArena.KIND_OPEN), int(EquipmentData.Rarity.UNCOMMON), "Classic's opponents keep to the modest pieces")
	_open_house()
	var best: Dictionary = {DraftArena.CLASSIC_ID: -1, DraftArena.HIGH_ID: -1}
	for id: String in [DraftArena.CLASSIC_ID, DraftArena.HIGH_ID]:
		for seed_value: int in range(1, 9):
			var state: DraftState = DraftEngine.start(content, id, [int(P.BEEFCAKE)] as Array[int], 16, seed_value * 131)
			state.max_paths = 2
			for rival: Dictionary in DraftRivals.build_all(content, state):
				for piece_id: Variant in rival["equipment"] as Array:
					best[id] = maxi(int(best[id]), int(content.equipment_piece(str(piece_id)).rarity))
	assert_lte(int(best[DraftArena.CLASSIC_ID]), int(EquipmentData.Rarity.UNCOMMON))
	assert_gt(int(best[DraftArena.HIGH_ID]), int(EquipmentData.Rarity.UNCOMMON), "over eight drafts a High Rollers opponent wears something Epic or better")


func test_the_dungeon_draft_lists_the_large_dungeons_cleared_once() -> void:
	_open_house()
	assert_eq(Session.draft_dungeon_keys(), [] as Array[String], "nothing cleared: nothing to draft")
	assert_eq(Session.draft_random_dungeon(), "")
	assert_ne(Session.draft_start_problem(DraftArena.dungeon_id("beefcake"), [int(P.BEEFCAKE)] as Array[int]), "")
	_free(["beefcake"] as Array[String])
	assert_eq(Session.draft_dungeon_keys(), ["beefcake"] as Array[String], "a freed zone's main dungeon")
	# Primm's Castle after Primm; the postgame dungeons and Mount Swolympus once cleared; the other minis are Mystery Mini's
	assert_false(Session.draft_dungeon_keys().has(CapitalZone.ID))
	Session.flags[str(ZoneCompletion.flag_name(CapitalZone.ID))] = true
	assert_true(Session.draft_dungeon_keys().has(CapitalZone.ID), "Primm's Castle once it is cleared")
	for plan: DungeonCatalog.Blueprint in DungeonCatalog.all():
		if plan.is_side() or plan.is_postgame():
			Session.set_flag(Session.side_cleared_flag(plan))
	var keys: Array[String] = Session.draft_dungeon_keys()
	for id: String in ["D-LAB", "S-GALLERY", "S-BEEF"]:
		assert_true(keys.has(id), "%s is on the list" % id)
	for id: String in ["S-GOUR", "S-NECRO", "S-REF", "S-TOWN", "S-IRON", "S-CAP", "S-PASTE"]:
		assert_false(keys.has(id), "%s is a mini dungeon: Mystery Mini's" % id)
	# the Shuffled Halls after their first clear
	assert_false(keys.has(DraftArena.HALLS_DUNGEON))
	Session.set_flag(StringName(DraftChallenges.won_flag(DraftArena.HALLS_ID)))
	assert_true(Session.draft_dungeon_keys().has(DraftArena.HALLS_DUNGEON), "the Halls join the list after their first clear")
	assert_eq(DraftArena.dungeon_id(DraftArena.HALLS_DUNGEON), DraftArena.HALLS_ID, "and choosing them there is the Halls' own draft")
	# Random: one of the list
	for i: int in range(12):
		assert_true(Session.draft_dungeon_keys().has(Session.draft_random_dungeon()))


func test_a_dungeon_draft_pays_a_prismatic_pack_after_primm() -> void:
	_open_house()
	_free(["gourmand"] as Array[String])
	for after_primm: bool in [false, true]:
		if after_primm:
			_after_primm()
		_to_run(DraftArena.dungeon_id("gourmand"), [int(P.GOURMAND)] as Array[int])
		assert_true(Session.prepare_draft_dungeon())
		Session.draft.fights_won = 5
		var pay: Dictionary = Session.resolve_draft_dungeon(true)
		assert_eq((pay["packs"] as Array).has(PackRules.PRISMATIC_ID), after_primm, "a Prismatic Pack once Primm is defeated (a Gilded one before)")
		assert_true(bool(pay["keep_card"]))
		Session.close_draft()


func test_mystery_mini_lands_on_a_three_encounter_dungeon_and_pays_its_paths_pack() -> void:
	_open_house()
	for plan: DungeonCatalog.Blueprint in DungeonCatalog.all():
		assert_eq(DraftArena.is_mini(plan), DraftArena.encounters_of(plan) == 3 and not plan.is_draft_only(), "%s: a mini has three encounters" % plan.id)
	assert_false(DraftArena.is_mini(MainDungeons.blueprint("beefcake")))
	# nothing freed or cleared yet: the four Path zones' own minis
	var pool: Array[String] = Session.draft_mystery_pool()
	assert_false(pool.is_empty(), "the wheel always has somewhere to land")
	for key: String in pool:
		assert_true(DraftArena.is_mini(MainDungeons.blueprint(key)), "%s has three encounters" % key)
	# a freed zone's minis, and any cleared one
	_free(["necrocrat"] as Array[String])
	assert_true(Session.draft_mystery_pool().has("S-NECRO"))
	assert_false(Session.draft_mystery_pool().has("S-CAP"), "nothing of the Capital before it is cleared")
	Session.set_flag(Session.side_cleared_flag(MainDungeons.blueprint("S-CAP")))
	assert_true(Session.draft_mystery_pool().has("S-CAP"))
	# the reward: a pack of the dungeon's Path
	_to_run(DraftArena.MYSTERY_ID, [int(P.BEEFCAKE)] as Array[int])
	Session.draft.dungeon_key = "S-NECRO"
	assert_true(Session.prepare_draft_dungeon())
	var pay: Dictionary = Session.resolve_draft_dungeon(true)
	assert_eq(pay["packs"] as Array, [PackRules.path_pack_id(P.NECROCRAT)], "a Necrocrat Pack for the Necrocrat mini, and nothing else")
	assert_gt(int(pay["gold"]), 0)
	Session.close_draft()
	# a mini with no Path pays a General Pack
	_to_run(DraftArena.MYSTERY_ID, [int(P.BEEFCAKE)] as Array[int])
	Session.draft.dungeon_key = "S-CAP"
	assert_true(Session.prepare_draft_dungeon())
	pay = Session.resolve_draft_dungeon(true)
	assert_eq(pay["packs"] as Array, ["general_1"])


func test_a_classic_win_counts_for_its_set_of_paths() -> void:
	_open_house()
	_free(["beefcake"] as Array[String])
	var pair: Array[int] = [int(P.NECROCRAT), int(P.BEEFCAKE)]
	assert_eq(DraftArena.paths_goal_flag(pair), DraftChallenges.won_flag("pair:1+4") if int(P.NECROCRAT) == 4 else DraftArena.paths_goal_flag(pair))
	assert_eq(DraftArena.paths_goal_flag([int(P.BEEFCAKE)] as Array[int]), "", "a single Path is nobody's goal")
	assert_eq(DraftArena.paths_goal_flag(DraftArena.PATHS), DraftChallenges.won_flag(DraftArena.QUAD_ID))
	var goal: String = DraftArena.paths_goal_flag(pair)
	assert_true(DraftArena.pair_ids().has(goal.trim_prefix("draft_won:")), "the pair's flag is the old table's")
	assert_false(Session.flag(StringName(goal)))
	var last: Dictionary = _win_table(DraftArena.CLASSIC_ID, pair)
	assert_true(bool(last["over"]))
	assert_true(Session.flag(StringName(goal)), "a Classic win with two Paths ticks that pair")
	assert_true(Session.flag(StringName(DraftChallenges.won_flag(DraftArena.CLASSIC_ID))))
	Session.close_draft()
	# High Rollers counts too; a loss does not
	var other: Array[int] = [int(P.BEEFCAKE), int(P.GOURMAND)]
	_to_run(DraftArena.HIGH_ID, other)
	_finish_fight(false)
	_finish_fight(false)
	assert_false(Session.flag(StringName(DraftArena.paths_goal_flag(other))))
	Session.close_draft()
	_win_table(DraftArena.HIGH_ID, other)
	assert_true(Session.flag(StringName(DraftArena.paths_goal_flag(other))))
	assert_true(Session.flag(StringName(DraftChallenges.won_flag(DraftArena.HIGH_ID))))


func test_the_arena_quest_line_points_at_the_four_modes_and_the_halls() -> void:
	var by_id: Dictionary = {}
	for quest: QuestData in DraftArenaQuests.quests():
		by_id[quest.id] = quest
	assert_eq(by_id.size(), DraftArenaQuests.ids().size())
	var open: QuestData = by_id[DraftArenaQuests.OPEN_QUEST] as QuestData
	assert_string_contains(open.objectives[0].text, "Classic Draft")
	var pairs: QuestData = by_id[DraftArenaQuests.PAIRS_QUEST] as QuestData
	assert_eq(pairs.objectives.size(), 6, "one goal for each pair of Paths, inside Classic")
	for step: QuestObjective in pairs.objectives:
		assert_string_contains(step.text, "Classic")
	assert_eq((by_id[DraftArenaQuests.TRIOS_QUEST] as QuestData).objectives.size(), 1)
	assert_string_contains((by_id[DraftArenaQuests.HIGH_QUEST] as QuestData).objectives[0].text, "High Rollers Draft")
	assert_string_contains((by_id[DraftArenaQuests.DUNGEON_QUEST] as QuestData).objectives[0].text, "Dungeon Draft")
	assert_string_contains((by_id[DraftArenaQuests.MYSTERY_QUEST] as QuestData).objectives[0].text, "Mystery Mini")
	# beating the Halls is a SIDE quest; the main quest only asks to play them once
	var halls: QuestData = by_id[DraftArenaQuests.HALLS_QUEST] as QuestData
	assert_eq(halls.category, QuestData.Category.SIDE)
	assert_string_contains(halls.objectives[0].text, "Clear the Shuffled Halls")
	var main: QuestData = by_id[DraftArenaQuests.MAIN_QUEST] as QuestData
	assert_eq(main.category, QuestData.Category.MAIN)
	assert_string_contains(main.objectives[1].text, "win or lose")
	for quest: QuestData in DraftArenaQuests.quests():
		for step: QuestObjective in quest.objectives:
			assert_false(step.text.contains("table") and step.text.contains(" x "), "no step names a retired table: %s" % step.text)
	# a save that won the old tables keeps its progress: the high-roller step takes a win at a retired win-three table
	Session.set_flag(StringName(DraftChallenges.won_flag("high:2")))
	Session.set_flag(StringName(DraftChallenges.ARENA_FLAG))
	var state: UnlockState = Session.unlock_state()
	assert_true(Condition.met((by_id[DraftArenaQuests.HIGH_QUEST] as QuestData).objectives[0].condition, state))


# ---- Part 2.7: the Path toggles ---------------------------------------------------------------------------------------------------


var _runner_panels: Array[CanvasItem] = []


## The test runner's own output panel lies over the right-hand side of the screen and would take the clicks meant for the
## tiles under it: it is hidden while a menu is tested (`after_each` shows it again).
func _hide_runner_panel() -> void:
	var output: Node = get_tree().root.find_child("TestOutput", true, false)
	var node: Node = output
	while node != null and node != get_tree().root:
		if node is CanvasItem and (node.get_parent() == get_tree().root or node.get_parent() is CanvasLayer or node.get_parent() is Window):
			if (node as CanvasItem).visible:
				(node as CanvasItem).visible = false
				_runner_panels.append(node as CanvasItem)
		node = node.get_parent()


func _menu() -> DraftHubScreen:
	_hide_runner_panel()
	var screen: DraftHubScreen = DraftHubScreen.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	await get_tree().process_frame
	return screen


func _toggle(screen: DraftHubScreen, path: int) -> Button:
	return screen.find_child("PathToggle_%d" % path, true, false) as Button


func _click(control: Control) -> void:
	var at: Vector2 = control.get_global_rect().get_center()
	for pressed: bool in [true, false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = at
		event.global_position = at
		get_viewport().push_input(event, true)
	await get_tree().process_frame
	await get_tree().process_frame


func _press_accept(control: Control) -> void:
	control.grab_focus()
	for pressed: bool in [true, false]:
		var event: InputEventAction = InputEventAction.new()
		event.action = &"ui_accept"
		event.pressed = pressed
		get_viewport().push_input(event)
	await get_tree().process_frame
	await get_tree().process_frame


func _on_paths(screen: DraftHubScreen) -> Array[int]:
	var result: Array[int] = []
	for path: int in DraftKit.PATH_ORDER:
		var toggle: Button = _toggle(screen, path)
		if toggle != null and toggle.button_pressed:
			result.append(path)
	result.sort()
	return result


func test_the_path_toggles_work_with_the_mouse_in_every_mode() -> void:
	_open_house()
	_free(["beefcake"] as Array[String])  # two Paths allowed
	Session.set_flag(StringName(DraftChallenges.won_flag(DraftArena.HALLS_ID)))
	var screen: DraftHubScreen = await _menu()
	for mode: String in [DraftArena.MODE_CLASSIC, DraftArena.MODE_DUNGEON, DraftArena.MODE_MYSTERY, DraftArena.MODE_HIGH, DraftHubScreen.HALLS]:
		await _click(screen.find_child("Mode_%s" % mode, true, false) as Control)
		assert_eq(screen._mode, mode, "the %s tile is chosen by a click" % mode)
		screen._paths = [int(P.BEEFCAKE)] as Array[int]
		screen._refresh()
		await get_tree().process_frame
		for path: int in DraftKit.PATH_ORDER:
			var toggle: Button = _toggle(screen, path)
			assert_not_null(toggle, "%s: a toggle for Path %d" % [mode, path])
			assert_gte(toggle.size.x, 180.0, "a big rectangle, not a small badge")
			assert_gte(toggle.size.y, 70.0)
			assert_eq((toggle.find_child("PathName", true, false) as Label).text, Affinity.display_name(path as Affinity.Type), "with the Path's name")
			assert_eq((toggle.find_child("State", true, false) as Label).text, "ON" if path == int(P.BEEFCAKE) else "off", "lit when on")
		# a click on the middle of a toggle switches it (the old badges swallowed the click)
		await _click(_toggle(screen, int(P.NECROCRAT)))
		var both: Array[int] = [int(P.BEEFCAKE), int(P.NECROCRAT)]
		both.sort()
		assert_eq(_on_paths(screen), both, "%s: a second Path switches on" % mode)
		await _click(_toggle(screen, int(P.BEEFCAKE)))
		assert_eq(_on_paths(screen), [int(P.NECROCRAT)] as Array[int], "%s: and a Path switches off" % mode)
		await _click(_toggle(screen, int(P.BEEFCAKE)))
		# one more than the story allows: refused, with a pop-up
		assert_null(screen.limit_popup)
		await _click(_toggle(screen, int(P.GOURMAND)))
		assert_eq(_on_paths(screen), both, "%s: a third Path is refused before Primm" % mode)
		var popup: PopupFrame = screen.limit_popup
		assert_not_null(popup, "%s: a pop-up says why" % mode)
		popup.confirmed.emit()
		await get_tree().process_frame
		await get_tree().process_frame
		assert_null(screen.limit_popup, "the pop-up closes")


func test_the_path_toggles_work_with_the_controller() -> void:
	_open_house()
	_after_primm()  # all four allowed
	var screen: DraftHubScreen = await _menu()
	for mode: String in [DraftArena.MODE_CLASSIC, DraftArena.MODE_MYSTERY, DraftArena.MODE_HIGH, DraftHubScreen.HALLS]:
		await _press_accept(screen.find_child("Mode_%s" % mode, true, false) as Control)
		assert_eq(screen._mode, mode, "the %s tile is chosen with the pad" % mode)
		screen._paths = [] as Array[int]
		screen._refresh()
		await get_tree().process_frame
		var expected: Array[int] = _on_paths(screen)
		for path: int in DraftKit.PATH_ORDER:
			var toggle: Button = _toggle(screen, path)
			assert_eq(toggle.focus_mode, Control.FOCUS_ALL, "a toggle takes the pad's focus")
			if expected.has(path):
				continue
			await _press_accept(toggle)
			expected.append(path)
			expected.sort()
			assert_eq(_on_paths(screen), expected, "%s: confirm switches Path %d on" % [mode, path])
		assert_eq(expected.size(), 4, "all four after Primm")
		assert_null(screen.limit_popup)
		await _press_accept(_toggle(screen, int(P.GOURMAND)))
		assert_false(_on_paths(screen).has(int(P.GOURMAND)), "%s: and confirm again switches it off" % mode)


func test_the_start_button_starts_the_chosen_mode_with_the_chosen_paths() -> void:
	_open_house()
	_free(["beefcake"] as Array[String])
	var screen: DraftHubScreen = await _menu()
	screen._mode = DraftArena.MODE_HIGH
	screen._paths = [int(P.GOURMAND), int(P.REFUSEMANCER)] as Array[int]
	screen._refresh()
	await get_tree().process_frame
	assert_eq(screen.selected_challenge(), DraftArena.HIGH_ID)
	assert_string_contains((screen.find_child("FeeLine", true, false) as Label).text, "200")
	assert_string_contains((screen.find_child("Start", true, false) as Button).text, "200", "the Start button names the fee")
	var gold: int = Session.gold
	(screen.find_child("Start", true, false) as Button).pressed.emit()
	assert_not_null(Session.draft)
	assert_eq(Session.draft.challenge_id, DraftArena.HIGH_ID)
	var want: Array[int] = [int(P.GOURMAND), int(P.REFUSEMANCER)]
	want.sort()
	assert_eq(Session.draft.paths, want)
	assert_eq(Session.gold, gold - 200)
	Session.close_draft()
	# the Dungeon Draft: nothing to start until a large dungeon is cleared; then Random and the list
	screen._mode = DraftArena.MODE_DUNGEON
	Session.flags.erase(str(ZoneCompletion.flag_name("beefcake")))
	screen._refresh()
	await get_tree().process_frame
	assert_eq(screen.selected_challenge(), "")
	assert_true((screen.find_child("Start", true, false) as Button).disabled)
	assert_not_null(screen.find_child("NoDungeons", true, false))
	_free(["beefcake", "gourmand"] as Array[String])
	screen._refresh()
	await get_tree().process_frame
	assert_not_null(screen.find_child("Dungeon_random", true, false), "a Random option")
	assert_not_null(screen.find_child("Dungeon_beefcake", true, false))
	assert_not_null(screen.find_child("Dungeon_gourmand", true, false))
	assert_eq(screen.selected_challenge(), DraftHubScreen.RANDOM, "Random is the default")
	screen._paths = [int(P.BEEFCAKE)] as Array[int]
	(screen.find_child("Start", true, false) as Button).pressed.emit()
	assert_not_null(Session.draft)
	assert_true(["beefcake", "gourmand"].has(Session.draft.dungeon_key), "Random starts one of the unlocked dungeons")


# ---- Part 3: the draft screens ------------------------------------------------------------------------------------------------------


func test_every_pick_offers_three_cards() -> void:
	# every Path set, single Paths and pairs, the whole draft: three options at every card pick
	for paths: Array in [[1], [2], [3], [4], [1, 2], [3, 4], [1, 2, 3, 4]]:
		var typed: Array[int] = []
		typed.assign(paths)
		var state: DraftState = DraftEngine.start(content, DraftArena.CLASSIC_ID, typed, 16, 77 + paths.size(), typed.size() >= 2, typed.size() >= 3)
		var guard: int = 0
		while state.phase == DraftState.PHASE_PICK and guard < 100:
			if str(state.offer["kind"]) == DraftEngine.KIND_CARD:
				assert_eq((state.offer["options"] as Array).size(), 3, "Paths %s, pick %d: three cards" % [str(paths), int(state.offer["pick"])])
			DraftEngine.pick(content, state, guard % 3)
			guard += 1
	# a pool with too few Epic cards still fills its rare slot with three (it used to come up short)
	var thin: DraftState = DraftEngine.start(content, DraftArena.CLASSIC_ID, [int(P.BEEFCAKE)] as Array[int], 16, 5)
	var banned: Dictionary = {}
	var kept: int = 0
	for card: CardData in DraftEngine.card_pool(content, thin):
		if int(card.rarity) >= int(CardEnums.Rarity.EPIC):
			kept += 1
			if kept > 1:
				banned[card.id] = true
	var rules: Dictionary = DraftRules.data()
	var before: Array = (rules.get("banned_cards", []) as Array).duplicate()
	rules["banned_cards"] = banned.keys()
	assert_eq(DraftEngine.card_offer(content, thin, true).size(), 3, "one Epic card left in the pool: the rare pick still shows three")
	rules["banned_cards"] = before


func test_the_three_options_fit_a_narrow_window() -> void:
	# 16:9 keeps the mock-up's large cards; the owner's squarer window (a 1,570 px canvas) gets three smaller ones side by side
	assert_almost_eq(DraftScreen.scale_for(1920.0, DraftScreen.SIDE_WIDTH, 3), DraftScreen.PICK_SCALE, 0.001)
	for canvas: float in [1920.0, 1700.0, 1570.0, 1440.0]:
		var side: float = DraftScreen.SIDE_WIDTH if canvas >= 1800.0 else DraftScreen.SIDE_WIDTH_NARROW
		var scale_now: float = DraftScreen.scale_for(canvas, side, 3)
		var used: float = 3.0 * CardView.SIZE.x * scale_now + 2.0 * float(DraftScreen.PICK_GAP) + 22.0 + side + DraftScreen.PAGE_MARGIN
		assert_lte(used, canvas + 0.5, "three cards and the side panel fit a %d px canvas" % int(canvas))
		assert_gte(scale_now, 0.9, "and stay large enough to read at %d px" % int(canvas))
	# the screen itself: three option columns, each as wide as the scale says
	_open_house()
	assert_true(Session.start_draft(DraftArena.CLASSIC_ID, [int(P.BEEFCAKE)] as Array[int]))
	var screen: DraftScreen = DraftScreen.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	await get_tree().process_frame
	var options: Control = screen.find_child("Options", true, false) as Control
	assert_eq(options.get_child_count(), 3)
	var page: Rect2 = screen.get_global_rect()
	for index: int in range(3):
		var card: Control = options.get_child(index).find_child("Card%d" % index, true, false) as Control
		assert_gte(card.get_global_rect().position.x, page.position.x, "card %d starts on the page" % index)
		assert_lte(card.get_global_rect().end.x, page.end.x, "card %d ends on the page" % index)
	assert_null(screen.find_child("ShortOffer", true, false), "nothing is missing, so nothing says so")
	# a short offer says so
	(Session.draft.offer["options"] as Array).remove_at(2)
	screen._refresh()
	await get_tree().process_frame
	assert_not_null(screen.find_child("ShortOffer", true, false), "one fewer: the screen says the pool ran out")


func test_the_trade_counters_card_is_shown_whole_with_its_label_clear_of_it() -> void:
	_enter_halls([int(P.BEEFCAKE)] as Array[int])
	DraftEngine.make_trade_offer(content, Session.draft, 4)
	assert_eq((Session.draft.offer["options"] as Array).size(), 3, "three cards on the counter")
	var screen: DraftScreen = DraftScreen.new()
	screen.dungeon_mode = true
	add_child_autofree(screen)
	await get_tree().process_frame
	await get_tree().process_frame
	var grid: Control = screen.find_child("SwapGrid", true, false) as Control
	assert_gt(grid.get_child_count(), 10, "the deck's cards are listed to give one up")
	var tile: Button = grid.get_child(0) as Button
	assert_not_null(tile)
	assert_eq(tile.tooltip_text, "", "no tooltip lies across the card any more")
	assert_null(screen.find_child("SwapPreview", true, false))
	tile.mouse_entered.emit()
	var preview: Control = screen.find_child("SwapPreview", true, false) as Control
	assert_not_null(preview, "the card under the pointer is shown large")
	assert_true(preview.top_level, "in a layer of its own: the scrolling list cannot cut it off")
	assert_gt(preview.z_index, 100, "on top of everything on the page")
	var card: Rect2 = Rect2(preview.global_position, CardView.SIZE * DraftScreen.SWAP_PREVIEW_SCALE)
	var plate: Control = preview.get_node("Plate") as Control
	var plate_rect: Rect2 = Rect2(preview.global_position + plate.position, plate.size)
	assert_false(card.intersects(plate_rect), "the label sits clear of the card")
	assert_string_contains((plate.get_node("Words") as Label).text, "Swap ")
	assert_string_contains((plate.get_node("Words") as Label).text, " out")
	var screen_rect: Rect2 = Rect2(Vector2.ZERO, screen.get_viewport_rect().size)
	assert_true(screen_rect.encloses(card), "the whole card is on the screen")
	assert_gte(card.size.y, 400.0, "enlarged")
	tile.mouse_exited.emit()
	await get_tree().process_frame
	assert_null(screen.find_child("SwapPreview", true, false), "and gone when the pointer leaves")


func test_the_result_of_a_draft_is_a_standard_pop_up() -> void:
	_open_house()
	_free(["beefcake"] as Array[String])
	_win_table(DraftArena.CLASSIC_ID, [int(P.BEEFCAKE), int(P.GOURMAND)] as Array[int])
	var draft: DraftState = Session.draft
	assert_true(DraftHubScreen.needs_keep(draft), "a full win: first the card to keep")
	assert_false(DraftHubScreen.shows(draft))
	assert_true(DraftHubScreen.for_state("", {}) is DraftScreen, "the draft table shows the picks to choose from")
	var kept_id: String = draft.cards[0]
	assert_true(Session.draft_keep(kept_id))
	assert_true(DraftHubScreen.shows(draft), "then the result")
	var screen: OverlayScreen = DraftHubScreen.for_state("", {})
	assert_true(screen is DraftHubScreen)
	add_child_autofree(screen)
	await get_tree().process_frame
	await get_tree().process_frame
	var popup: RewardPopup = (screen as DraftHubScreen).result_popup
	assert_not_null(popup, "a pop-up, not a table")
	var summary: RewardSummary = popup.summary
	assert_eq(summary.header, "DRAFT WON")
	assert_string_contains(summary.subtitle, "Wins 3 of 3")
	assert_string_contains(summary.subtitle, "Losses 0 of 2")
	assert_eq(summary.gold, int(draft.result["gold"]))
	assert_eq(summary.xp, int(draft.result["xp"]))
	assert_eq(summary.packs.size(), (draft.result["packs"] as Array).size(), "every pack as an icon with its name")
	for entry: Dictionary in summary.packs:
		assert_false(str(entry["name"]).is_empty())
	assert_eq(summary.cards.size(), 1, "the kept card shown as a card")
	assert_eq(summary.cards[0].id, kept_id)
	assert_eq(popup.frame.button.text, "Finish")
	assert_eq(screen.find_children("Keep_*", "", true, false).size(), 0, "no empty card places behind it")
	popup.finished.emit()
	await get_tree().process_frame
	assert_null(Session.draft, "Finish puts the draft away")
	# a run that was lost goes straight to the pop-up
	_to_run(DraftArena.CLASSIC_ID, [int(P.BEEFCAKE)] as Array[int])
	_finish_fight(false)
	_finish_fight(false)
	assert_true(DraftHubScreen.shows(Session.draft))
	var lost: RewardSummary = DraftHubScreen.result_summary(Session.draft)
	assert_eq(lost.header, "RUN OVER")
	assert_true(lost.cards.is_empty())
	assert_gt(lost.gold, 0, "something for every result")


func test_the_tables_seat_a_wide_cast_of_opponents() -> void:
	assert_gte(DraftRivals.ARENA_ROSTER.size(), 30, "a wide cast")
	var names: Dictionary = {}
	for row: Variant in DraftRivals.ARENA_ROSTER:
		var who: Array = row as Array
		assert_false(names.has(str(who[1])), "%s is on the list once" % str(who[1]))
		names[str(who[1])] = true
		assert_true(Portraits.has_portrait(str(who[0])), "%s has a portrait for the next-opponent screen" % str(who[1]))
		assert_true(DraftRivals.PERSONALITIES.has(str(who[2])))
		assert_eq(DraftRivals.portrait_id(str(who[1])), str(who[0]))
	var seen: Dictionary = {}
	for seed_value: int in range(1, 13):
		var state: DraftState = DraftEngine.start(content, DraftArena.CLASSIC_ID, [int(P.GOURMAND)] as Array[int], 16, seed_value * 977)
		state.max_paths = 2
		var rivals: Array[Dictionary] = DraftRivals.build_all(content, state)
		assert_eq(rivals.size(), 3)
		var trio: Dictionary = {}
		for rival: Dictionary in rivals:
			trio[str(rival["name"])] = true
			seen[str(rival["name"])] = true
			# the tendencies and the description the next-opponent screen shows are still there
			assert_false(str(rival["personality"]).is_empty())
			assert_false(str(rival["title"]).is_empty())
		assert_eq(trio.size(), 3, "three different opponents in one draft")
	assert_gte(seen.size(), 15, "twelve drafts meet many different people (%d)" % seen.size())
	# a zone draft keeps its own three
	var zone: DraftState = DraftEngine.start(content, "zone:beefcake", [int(P.BEEFCAKE)] as Array[int], 10, 3)
	var zone_names: Array[String] = []
	for rival: Dictionary in DraftRivals.build_all(content, zone):
		zone_names.append(str(rival["name"]))
	assert_eq(zone_names, ["Rollo Spokes", "Chet Thunderabs", "Professor Pump"] as Array[String])


func test_the_opponents_paths_never_follow_the_players_choice() -> void:
	# the same seed, the same story: whatever the player switches on, the same opponents with the same Paths and decks
	var seen_by_choice: Array = []
	for paths: Array in [[int(P.BEEFCAKE)], [int(P.NECROCRAT), int(P.GOURMAND)], [1, 2, 3, 4]]:
		var typed: Array[int] = []
		typed.assign(paths)
		var state: DraftState = DraftEngine.start(content, DraftArena.CLASSIC_ID, typed, 16, 4242, typed.size() >= 2, typed.size() >= 3)
		state.max_paths = 4
		var summary: Array = []
		for rival: Dictionary in DraftRivals.build_all(content, state):
			summary.append([str(rival["name"]), rival["paths"], rival["recipe"]])
		seen_by_choice.append(summary)
	assert_eq(seen_by_choice[0], seen_by_choice[1], "one Path or two: the same three opponents, Paths and decks")
	assert_eq(seen_by_choice[0], seen_by_choice[2], "or all four")
	# a new draft meets new decks; the number of Paths is random within the story's limit
	var counts: Dictionary = {}
	var path_sets: Dictionary = {}
	for seed_value: int in range(1, 25):
		var state: DraftState = DraftEngine.start(content, DraftArena.CLASSIC_ID, [int(P.BEEFCAKE)] as Array[int], 16, seed_value * 311)
		state.max_paths = 4
		for index: int in range(3):
			var own: Array[int] = DraftRivals.rival_paths(state, index)
			counts[own.size()] = true
			path_sets[str(own)] = true
			assert_lte(own.size(), 3)
	assert_true(counts.has(1) and counts.has(2) and counts.has(3), "after Primm an opponent drafts one, two or three Paths")
	assert_gte(path_sets.size(), 8, "many different Path sets across drafts")
	var before_primm: DraftState = DraftEngine.start(content, DraftArena.CLASSIC_ID, [1, 2] as Array[int], 16, 99, true, false)
	before_primm.max_paths = 2
	for index: int in range(12):
		assert_lte(DraftRivals.rival_paths(before_primm, index).size(), 2, "never more Paths than the story has opened")
	var early: DraftState = DraftEngine.start(content, DraftArena.CLASSIC_ID, [1] as Array[int], 16, 99)
	early.max_paths = 1
	for index: int in range(6):
		assert_eq(DraftRivals.rival_paths(early, index).size(), 1)
	# the session writes the story's limit into the draft
	_open_house()
	_free(["beefcake"] as Array[String])
	assert_true(Session.start_draft(DraftArena.CLASSIC_ID, [int(P.BEEFCAKE)] as Array[int]))
	assert_eq(Session.draft.max_paths, 2)
	assert_eq(DraftState.from_dict(Session.draft.to_dict()).max_paths, 2, "and it is saved with the draft")


# ---- Part 4: the Shuffled Halls, static -------------------------------------------------------------------------------------------


func test_every_fight_of_the_halls_is_a_hand_made_encounter() -> void:
	assert_eq(EncounterModifiers.problems(), [] as Array[String], "the rules data is clean")
	assert_eq(EncounterScripts.problems(), [] as Array[String], "the scripted moments are clean")
	var plan: DungeonCatalog.Blueprint = MainDungeons.blueprint(DraftArena.HALLS_DUNGEON)
	var def: MainDungeonDef = MainDungeons.def(DraftArena.HALLS_DUNGEON)
	var names: Dictionary = {}
	var decks: Dictionary = {}
	for room: int in HALLS_FIGHT_ROOMS:
		var node: DungeonCatalog.BlueprintNode = plan.node(room)
		var enemy_name: String = DungeonBuilder.foe_name_of(plan, node)
		var fighter: MainDungeonDef.Foe = def.foe(enemy_name)
		assert_not_null(fighter, "room %d has its own dealer" % room)
		assert_false(names.has(enemy_name), "%s holds one room" % enemy_name)
		names[enemy_name] = true
		# a fixed deck: real cards, a sensible size, its own Paths
		var size: int = 0
		var paths: Dictionary = {}
		for id: Variant in fighter.recipe.keys():
			var card: CardData = content.card(str(id))
			assert_not_null(card, "%s: %s is a card" % [enemy_name, str(id)])
			size += int(fighter.recipe[id])
			if card != null:
				for path: Affinity.Type in card.paths():
					paths[int(path)] = true
		assert_between(size, 30, 36, "%s: a deck of %d cards" % [enemy_name, size])
		assert_false(paths.is_empty(), "%s plays a Path of its own" % enemy_name)
		assert_false(fighter.paths_text.is_empty(), "%s: the room card says what it plays" % enemy_name)
		assert_false(decks.has(str(fighter.recipe)), "%s: no two dealers share a deck" % enemy_name)
		decks[str(fighter.recipe)] = true
		# fixed equipment (never random), a skill, an HP measured from the player's
		assert_false(fighter.equipment.is_empty(), "%s wears something" % enemy_name)
		for piece_id: String in fighter.equipment:
			assert_not_null(content.equipment_piece(piece_id), "%s: %s is a piece of equipment" % [enemy_name, piece_id])
		assert_true(["normal", "elite", "boss"].has(fighter.skill))
		assert_true(fighter.has_hp_vs_player)
		# its own rules and at least one scripted moment
		var standing: int = 0
		var scripted: int = 0
		for rule: EncounterModifiers.Rule in EncounterModifiers.rules(enemy_name):
			if rule.scripted:
				scripted += 1
			elif not rule.modifiers.is_empty() and rule.modifiers[0].kind != Modifier.Kind.SETUP_TURNS:
				standing += 1
		assert_gte(standing, 1, "%s has a rule of the fight" % enemy_name)
		assert_gte(scripted, 1, "%s has a scripted moment" % enemy_name)
	assert_eq(names.size(), 10)
	assert_eq(def.foe("Trey Pickett").skill, "elite")
	assert_eq(def.foe("Dex Shufflewick").skill, "elite")
	assert_eq(def.foe("Octavia Eightfold").skill, "boss")
	assert_true(def.foe("Octavia Eightfold").recipe.has(DraftRivals.OCTAVIA_CARD), "Octavia plays her own card")
	assert_true(def.foe("Trey Pickett").recipe.has(DraftRivals.TREY_CARD), "and Trey his")


func test_the_halls_meet_the_same_dealers_whatever_the_player_drafted() -> void:
	var met: Array = []
	for paths: Array in [[int(P.NECROCRAT)], [int(P.BEEFCAKE), int(P.GOURMAND)]]:
		var typed: Array[int] = []
		typed.assign(paths)
		_free(["beefcake"] as Array[String])
		_enter_halls(typed)
		assert_true(Session.draft.rivals.is_empty(), "no drafted rival copies the player's Paths")
		var rooms: Array = []
		for room: int in HALLS_FIGHT_ROOMS:
			var node: DungeonMap.MapNode = _halls_node(room)
			var context: BattleContext = Session.make_dungeon_battle(node)
			var deck: Array[String] = []
			for card: CardInstance in context.game.players[1].deck:
				deck.append(card.data.id)
			for card: CardInstance in context.game.players[1].hand:
				deck.append(card.data.id)
			deck.sort()
			rooms.append([node.enemy_name, deck, node.enemy_hp])
			Session.run.finish_encounter(context.game)
		met.append(rooms)
		Session.resolve_draft_dungeon(false)
		Session.close_draft()
	assert_eq(met[0], met[1], "a Necrocrat draft and a Beefcake-Gourmand draft meet the same ten dealers with the same decks")
	# a Necrocrat draft does not meet only Necrocrat decks (it did, on Nov 23)
	var off_path: int = 0
	for room: Array in met[0] as Array:
		var necro_only: bool = true
		for id: Variant in room[1] as Array:
			var card: CardData = content.card(str(id))
			if card != null and not card.paths().is_empty() and not card.paths().has(P.NECROCRAT):
				necro_only = false
		off_path += 0 if necro_only else 1
	assert_gte(off_path, 7, "most rooms play Paths the player did not draft")


func test_a_dealers_hp_is_measured_from_the_players_and_its_gear_shows() -> void:
	_enter_halls([int(P.REFUSEMANCER)] as Array[int])
	var base_hp: int = ProgressionTable.row(Session.draft.level).max_hp
	var def: MainDungeonDef = MainDungeons.def(DraftArena.HALLS_DUNGEON)
	for room: int in HALLS_FIGHT_ROOMS:
		var node: DungeonMap.MapNode = _halls_node(room)
		var fighter: MainDungeonDef.Foe = def.foe(node.enemy_name)
		assert_eq(node.enemy_hp, maxi(8, base_hp + fighter.hp_vs_player), "%s: HP from the player's base HP" % node.enemy_name)
		assert_string_contains(node.blurb, "Plays ")
		assert_string_contains(node.blurb, "Wears ")
	# the gate fight: fixed equipment as battle effects under the dealer's name, its rules, no gold or XP of its own
	var gate: DungeonMap.MapNode = _halls_node(2)
	var context: BattleContext = Session.make_dungeon_battle(gate)
	assert_true(context.draft)
	assert_eq(context.gold_reward, 0)
	assert_eq(context.board_key, "BB-SHUFFLE", "on the house table")
	var wears: int = 0
	for badge: RuleBadges.Badge in context.rule_badges:
		if badge.side == RuleBadges.SIDE_ENEMY and badge.text.contains("wears this"):
			wears += 1
	assert_eq(wears, def.foe(gate.enemy_name).equipment.size())
	assert_false(context.encounter_rules.is_empty(), "the dealer's own rules are on the table")
	# Maurice's rope stands on his side from the start
	while context.game.stage == GameState.Stage.MULLIGAN:
		context.game.keep_hand(context.game.awaiting_player())
	var rope: bool = false
	for card: CardInstance in context.game.players[1].field:
		rope = rope or card.data.display_name == "Velvet Rope"
	assert_true(rope, "the Velvet Rope is on Maurice's side")
	Session.run.finish_encounter(context.game)
	# skills: each dealer plays as its block says - the gates at normal level, the champions at elite, Octavia at boss
	assert_eq(Session._skill_for_node(_halls_node(2)), AIPlayer.Skill.NORMAL, "the gates play at normal level")
	assert_eq(Session._skill_for_node(_halls_node(3)), AIPlayer.Skill.NORMAL)
	assert_eq(Session._skill_for_node(_halls_node(5)), MainDungeons.skill_of(DraftArena.HALLS_DUNGEON, _halls_node(5).enemy_name, AIPlayer.Skill.NORMAL), "a dealer plays as its block says")
	assert_eq(Session._skill_for_node(_halls_node(8)), AIPlayer.Skill.ELITE)
	assert_eq(Session._skill_for_node(_halls_node(19)), AIPlayer.Skill.BOSS)


func test_cashing_out_at_the_counting_halls_ends_the_run_and_is_not_a_win() -> void:
	var plan: DungeonCatalog.Blueprint = MainDungeons.blueprint(DraftArena.HALLS_DUNGEON)
	assert_eq(plan.node(18).node_name, "The Counting Halls")
	assert_eq(plan.node(18).type, "event", "a room with a choice, not a chest on the way to the boss")
	assert_true(plan.node(16).next.has(18) and plan.node(17).next.has(18), "reached from the last corridor's rooms")
	assert_true(plan.node(18).next.has(19), "and the Big Wheel is still open to somebody who does not cash out")
	_enter_halls([int(P.BEEFCAKE)] as Array[int])
	var room: DungeonMap.MapNode = _halls_node(18)
	assert_eq(room.kind, DungeonMap.Kind.EVENT)
	var event: DungeonEvent = MainDungeons.def(DraftArena.HALLS_DUNGEON).event(room.event_id)
	assert_not_null(event)
	# the room says what cashing out gives, and that it is not a win
	var cash: Dictionary = DraftRules.dungeon_rewards()["halls_cash_out"] as Dictionary
	var told: Dictionary = (DungeonCatalog.content_for(DraftArena.HALLS_DUNGEON)["events"] as Dictionary)["18"] as Dictionary
	var words: String = "%s %s %s" % [str(told["body"]), " ".join((told["choices"] as Array)[0] as Array), room.blurb]
	assert_string_contains(words.to_lower(), "not a win")
	assert_string_contains(words.to_lower(), "does not count as a win")
	assert_string_contains(words, "%d gold" % int(cash["gold"]))
	assert_string_contains(words, "%d XP" % int(cash["xp"]))
	# walking on: nothing ends
	Session.draft.fights_won = 3
	var passed: EventResolver.Result = Session.resolve_dungeon_event(event, 1)
	assert_true(passed.ok)
	assert_false(Session.draft_cash_out_pending, "not cashing out leaves the run going")
	assert_true(Session.draft_dungeon_active)
	# cashing out
	var gold: int = Session.gold
	var result: EventResolver.Result = Session.resolve_dungeon_event(event, 0)
	assert_true(result.ok)
	assert_true(Session.draft_cash_out_pending, "the first choice cashes out")
	var pay: Dictionary = Session.resolve_draft_dungeon(false, true)
	assert_false(Session.draft_dungeon_active, "the run is over")
	assert_true(bool(pay.get("cashed_out", false)))
	var per_fight: int = int(DraftRules.dungeon_rewards()["gold_per_fight_won"])
	assert_eq(int(pay["gold"]), int(cash["gold"]) + 3 * per_fight, "part of the prize, on top of the gold for the fights won")
	assert_gte(Session.gold - gold, int(pay["gold"]), "the gold is in the purse (a level gained on the way may add its own)")
	assert_eq(pay["packs"] as Array, [str(cash["pack"])])
	assert_lt(int(pay["gold"]), int(DraftRules.dungeon_rewards()["halls_clear_gold"]) + 6 * per_fight, "less than a clear pays")
	# not a win
	assert_false(bool(pay["cleared"]))
	assert_false(bool(pay["keep_card"]), "no card to keep")
	assert_false(pay.has("equipment"), "no first-clear prize")
	assert_false(Session.draft.full_win())
	assert_false(Session.flag(StringName(DraftChallenges.won_flag(DraftArena.HALLS_ID))), "the Halls are not cleared")
	assert_eq(Session.counter("draft_runs_won"), 0)
	assert_eq(Session.counter("draft_won_kind:%s" % DraftArena.KIND_HALLS), 0)
	assert_eq(Session.counter("draft_halls_played"), 1, "but the main quest's walk counts")
	assert_eq(DraftHubScreen.result_summary(Session.draft).header, "CASHED OUT")
	assert_false(DraftHubScreen.needs_keep(Session.draft))


func test_unseen_rooms_of_the_halls_are_question_marks_until_stepped_on() -> void:
	assert_false(DungeonMapScreen.ROUTE_PLANNING.has(DraftArena.HALLS_DUNGEON), "the Halls no longer show every room from the start")
	assert_false(Session.node_revealed(DraftArena.HALLS_DUNGEON, 4))
	Session.note_node_seen(DraftArena.HALLS_DUNGEON, 4)
	assert_true(Session.node_revealed(DraftArena.HALLS_DUNGEON, 4), "a room stepped on stays known for later runs")
	assert_false(Session.node_revealed(DraftArena.HALLS_DUNGEON, 5))


func test_a_scripted_rule_can_leave_both_seats_and_a_dealer_can_fold() -> void:
	# Professor Fineprint: "No Running" on both seats, struck from both by the amendment, and Rule 2 on both
	_enter_halls([int(P.BEEFCAKE)] as Array[int])
	var context: BattleContext = Session.make_dungeon_battle(_halls_node(12))
	var game: GameState = context.game
	var label: String = "Rule 1: No Running"
	for seat: int in [0, 1]:
		var has_rule: bool = false
		for modifier: Modifier in game.players[seat].modifiers.modifiers:
			has_rule = has_rule or modifier.label == label
		assert_true(has_rule, "seat %d plays under No Running" % seat)
	var run: EncounterScripts.Run = null
	for candidate: Variant in game.script_runs:
		run = candidate as EncounterScripts.Run
	assert_not_null(run)
	for trigger: EncounterScripts.Trigger in EncounterScripts.triggers("Professor Fineprint"):
		for effect: Dictionary in trigger.effects:
			EncounterScripts._resolve(game, run, effect)
	for seat: int in [0, 1]:
		var left: bool = false
		var open_book: bool = false
		for modifier: Modifier in game.players[seat].modifiers.modifiers:
			left = left or modifier.label == label
			open_book = open_book or modifier.label == "Rule 2: Open Book"
		assert_false(left, "seat %d: Rule 1 is struck out" % seat)
		assert_true(open_book, "seat %d: Rule 2 is in" % seat)
	Session.run.finish_encounter(game)
	# "Honest" Hal folds only to a full table
	context = Session.make_dungeon_battle(_halls_node(7))
	game = context.game
	for candidate: Variant in game.script_runs:
		run = candidate as EncounterScripts.Run
	var fold: Dictionary = {"kind": "concede", "if_foe_units_at_least": 3}
	EncounterScripts._resolve(game, run, fold)
	assert_false(game.is_over(), "an empty table: Hal plays on")
	for i: int in range(3):
		game.put_onto_field(game.create_instance(content.card("C-02"), 0), 0, false)
	EncounterScripts._resolve(game, run, fold)
	assert_true(game.is_over(), "three units on your side: Hal folds")
	assert_eq(game.winner, 0, "and the fight is yours")
	# his ante is on the player's seat
	var ante: bool = false
	for rule: EncounterModifiers.Rule in EncounterModifiers.rules("\"Honest\" Hal Lowball"):
		ante = ante or (rule.name == "The Ante" and not rule.is_enemy_side() and rule.harmful)
	assert_true(ante)


# ---- the pick of three after a Halls fight: a card met by the pointer while the table slides in stays on the page -------------------


func test_a_card_hovered_while_its_screen_is_still_off_the_page_grows_where_it_stands() -> void:
	var row: HBoxContainer = HBoxContainer.new()
	add_child_autofree(row)
	row.position = Vector2(300, 2600)  # the table has not slid in yet: far below the window
	var tile: Button = Button.new()
	tile.custom_minimum_size = CardView.SIZE * 0.9
	row.add_child(tile)
	await get_tree().process_frame
	CardHoverZoom.set_height(tile, 640.0)
	CardHoverZoom.zoom_in(tile)
	assert_true(CardHoverZoom.is_zoomed(tile))
	row.position = Vector2(300, 200)  # and now it has
	var grown: Vector2 = tile.size * CardHoverZoom.factor_for(tile)
	var top: float = tile.global_position.y + tile.pivot_offset.y * (1.0 - CardHoverZoom.factor_for(tile))
	assert_gt(top, -200.0, "its grown top edge is near the page (it was thrown 2,000 px above it)")
	assert_lt(top + grown.y, get_viewport().get_visible_rect().size.y + 400.0)
	assert_between(tile.pivot_offset.y, -tile.size.y, tile.size.y * 2.0, "the pivot stays near the card")
	CardHoverZoom.zoom_out(tile)
