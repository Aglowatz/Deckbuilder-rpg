extends GutTest
## Fable Nov 25, Part 4 (the owner's items 15 to 18 and 11, decisions 1 and 4): the Shuffle House's menu and draft screens.
##   - Octavia stands whole on the floor of her panel (her portrait was cut off below the knees and floated);
##   - the four mode boxes have one layout: emblem, title, text and the two lines on the same lines in every box;
##   - every box shows "Entry Fee:" and "Rewards:" on separate lines; Mystery Mini's reward reads "Path Packs";
##   - High Rollers costs 100 gold; Mount Swolympus is Mystery Mini's only;
##   - "Random" beside the Path toggles, by mouse and by controller;
##   - the deck picker after the draft is sorted by cost, then by name;
##   - Hover Boots: only opponents at the High Rollers table can get them.

const P := Affinity.Type

var _runner_panels: Array[CanvasItem] = []


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game()
	Session.draft = null
	Session.pending_draft_result = {}
	Session.gold = 1000
	DraftRules.reload()
	Session.set_flag(StringName(DraftChallenges.ARENA_FLAG))


func after_each() -> void:
	for panel: CanvasItem in _runner_panels:
		if is_instance_valid(panel):
			panel.visible = true
	_runner_panels.clear()
	Session.draft = null
	Session.pending_draft_result = {}


func _free(zones: Array[String]) -> void:
	for zone_id: String in zones:
		Session.flags[str(ZoneCompletion.flag_name(zone_id))] = true


## The test runner's own output panel would take the clicks meant for the tiles under it.
func _hide_runner_panel() -> void:
	var node: Node = get_tree().root.find_child("TestOutput", true, false)
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
	await get_tree().process_frame
	return screen


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


func _tile(screen: DraftHubScreen, mode: String) -> Control:
	return screen.find_child("Mode_%s" % mode, true, false) as Control


func _line(tile: Control, row: String) -> String:
	var line: Control = tile.find_child(row, true, false) as Control
	return "%s %s" % [(line.get_node("Heading") as Label).text, (line.get_node("Value") as Label).text]


# ---- The mode boxes -----------------------------------------------------------------------------------------------------------------


func test_every_mode_box_has_the_same_layout() -> void:
	var screen: DraftHubScreen = await _menu()
	var rows: Array[String] = ["Emblem", "Ribbon", "Pitch", "EntryFee", "Rewards"]
	var first: Dictionary = {}
	for mode: String in DraftArena.MODES:
		var tile: Control = _tile(screen, mode)
		assert_not_null(tile, "the %s box" % mode)
		for row: String in rows:
			var part: Control = tile.find_child(row, true, false) as Control
			assert_not_null(part, "%s has its %s" % [mode, row])
			if part == null:
				continue
			# where the row sits inside its own box: the same in every box (Mystery Mini sat lower)
			var top: float = part.get_global_rect().position.y - tile.get_global_rect().position.y
			var height: float = part.get_global_rect().size.y
			if not first.has(row):
				first[row] = Vector2(top, height)
			assert_almost_eq(top, (first[row] as Vector2).x, 0.6, "%s: the %s starts on the same line as in the first box" % [mode, row])
			assert_almost_eq(height, (first[row] as Vector2).y, 0.6, "%s: the %s is as tall as in the first box" % [mode, row])
			assert_lte(part.get_global_rect().end.y, tile.get_global_rect().end.y + 0.5, "%s: the %s is inside the box" % [mode, row])
		# the title is one type size in every box
		assert_eq((tile.find_child("Title", true, false) as Label).get_theme_font_size("font_size"), 24)
		# the painted emblem of the mode
		var emblem: TextureRect = tile.find_child("Emblem", true, false) as TextureRect
		assert_not_null(emblem, "%s shows a painted emblem" % mode)
		if emblem != null:
			assert_eq(emblem.texture, UiArt.texture(str(DraftHubScreen.MODE_EMBLEMS[mode])))
	# the four boxes themselves stand on one line and are one size
	var size: Vector2 = _tile(screen, DraftArena.MODE_CLASSIC).size
	for mode: String in DraftArena.MODES:
		assert_almost_eq(_tile(screen, mode).get_global_rect().position.y, _tile(screen, DraftArena.MODE_CLASSIC).get_global_rect().position.y, 0.5)
		assert_eq(_tile(screen, mode).size, size)


func test_every_box_shows_the_entry_fee_and_the_rewards_on_separate_lines() -> void:
	var screen: DraftHubScreen = await _menu()
	for mode: String in DraftArena.MODES:
		var tile: Control = _tile(screen, mode)
		var fee: Control = tile.find_child("EntryFee", true, false) as Control
		var pay: Control = tile.find_child("Rewards", true, false) as Control
		assert_eq((fee.get_node("Heading") as Label).text, "Entry Fee:")
		assert_eq((pay.get_node("Heading") as Label).text, "Rewards:")
		assert_gte(pay.get_global_rect().position.y, fee.get_global_rect().end.y - 0.5, "%s: Rewards is on the line under Entry Fee" % mode)
	assert_eq(_line(_tile(screen, DraftArena.MODE_CLASSIC), "EntryFee"), "Entry Fee: Free")
	assert_eq(_line(_tile(screen, DraftArena.MODE_CLASSIC), "Rewards"), "Rewards: Path Packs")
	assert_eq(_line(_tile(screen, DraftArena.MODE_DUNGEON), "EntryFee"), "Entry Fee: Free")
	assert_eq(_line(_tile(screen, DraftArena.MODE_MYSTERY), "EntryFee"), "Entry Fee: Free")
	assert_eq(_line(_tile(screen, DraftArena.MODE_MYSTERY), "Rewards"), "Rewards: Path Packs", "the owner: Mystery Mini's reward says Path Packs")
	assert_eq(_line(_tile(screen, DraftArena.MODE_HIGH), "EntryFee"), "Entry Fee: 100 gold")
	# Prismatic Packs are Gilded Packs until Primm is beaten (the owner kept that rule), and the box says which
	assert_eq(_line(_tile(screen, DraftArena.MODE_HIGH), "Rewards"), "Rewards: Gilded Packs")
	Session.flags[str(MultiPathLock.FLAG_UNLOCKED)] = true
	screen._refresh()
	await get_tree().process_frame
	assert_eq(_line(_tile(screen, DraftArena.MODE_HIGH), "Rewards"), "Rewards: Prismatic Packs")
	assert_eq(_line(_tile(screen, DraftArena.MODE_DUNGEON), "Rewards"), "Rewards: Prismatic Packs")


func test_high_rollers_costs_100_gold_and_swolympus_is_mystery_minis_only() -> void:
	assert_eq(DraftRules.entry_fee_for(DraftArena.KIND_HIGH), 100)
	assert_eq(Session.draft_fee(DraftArena.HIGH_ID), 100)
	Session.gold = 100
	assert_eq(Session.draft_start_problem(DraftArena.HIGH_ID, [int(P.BEEFCAKE)] as Array[int]), "", "100 gold is enough")
	assert_true(Session.start_draft(DraftArena.HIGH_ID, [int(P.BEEFCAKE)] as Array[int]))
	assert_eq(Session.gold, 0)
	Session.close_draft()
	# Mount Swolympus (S-BEEF): cleared, it is on the wheel and not on the Dungeon Draft's list
	for plan: DungeonCatalog.Blueprint in DungeonCatalog.all():
		if plan.is_side() or plan.is_postgame():
			Session.set_flag(Session.side_cleared_flag(plan))
	assert_false(Session.draft_dungeon_keys().has("S-BEEF"), "not a Dungeon Draft")
	assert_true(Session.draft_mystery_pool().has("S-BEEF"), "on Mystery Mini's wheel")
	assert_eq((DraftRules.dungeon().get("large_extra", []) as Array).size(), 0)


# ---- Random ------------------------------------------------------------------------------------------------------------------------


func test_random_paths_are_an_allowed_set() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 2511
	# before a zone is freed: one Path
	for roll: int in range(40):
		var one: Array[int] = DraftArena.random_paths(DraftArena.CLASSIC_ID, Session.flags, rng)
		assert_eq(one.size(), 1)
		assert_true(DraftKit.PATH_ORDER.has(one[0]))
	# a zone freed: one or two, both seen, never a Path twice
	_free(["beefcake"] as Array[String])
	var sizes: Dictionary = {}
	var seen: Dictionary = {}
	for roll: int in range(200):
		var paths: Array[int] = DraftArena.random_paths(DraftArena.HIGH_ID, Session.flags, rng)
		sizes[paths.size()] = true
		assert_between(paths.size(), 1, 2)
		var unique: Dictionary = {}
		for path: int in paths:
			unique[path] = true
			seen[path] = true
		assert_eq(unique.size(), paths.size(), "no Path twice")
		assert_eq(Session.draft_start_problem(DraftArena.HIGH_ID, paths), "", "the set is one the house accepts")
	assert_eq(sizes.size(), 2, "one Path and two Paths both come up")
	assert_eq(seen.size(), 4, "every Path comes up")
	# after Primm: up to four
	Session.flags[str(MultiPathLock.FLAG_UNLOCKED)] = true
	var most: int = 0
	for roll: int in range(200):
		most = maxi(most, DraftArena.random_paths(DraftArena.MYSTERY_ID, Session.flags, rng).size())
	assert_eq(most, 4)
	# a table with fixed Paths (the Draft of the Day) has nothing to roll
	assert_eq(DraftArena.random_paths(DraftArena.daily_id(), Session.flags, rng), [] as Array[int])


func test_random_sits_beside_the_path_toggles_and_works_with_the_mouse() -> void:
	_free(["beefcake"] as Array[String])
	var screen: DraftHubScreen = await _menu()
	for mode: String in [DraftArena.MODE_CLASSIC, DraftArena.MODE_MYSTERY, DraftArena.MODE_HIGH, DraftHubScreen.HALLS]:
		await _click(_tile(screen, mode))
		screen.random_paths = false
		screen._paths = [int(P.NECROCRAT)] as Array[int]
		screen._refresh()
		await get_tree().process_frame
		var random: Button = screen.find_child("PathToggle_random", true, false) as Button
		assert_not_null(random, "%s: Random is there" % mode)
		var last: Button = screen.find_child("PathToggle_%d" % DraftKit.PATH_ORDER[DraftKit.PATH_ORDER.size() - 1], true, false) as Button
		assert_eq(random.get_parent(), last.get_parent(), "in the row of the Path toggles")
		assert_almost_eq(random.get_global_rect().position.y, last.get_global_rect().position.y, 0.5, "on their line")
		assert_almost_eq(random.size.y, last.size.y, 0.5, "as tall as they are")
		assert_gt(random.get_global_rect().position.x, last.get_global_rect().end.x, "after the last Path")
		assert_eq((random.find_child("PathName", true, false) as Label).text, "Random")
		assert_eq((random.find_child("State", true, false) as Label).text, "off")
		# a click switches it on: the four Paths go dark and say so
		await _click(random)
		assert_true(screen.random_paths, "%s: a click switches Random on" % mode)
		random = screen.find_child("PathToggle_random", true, false) as Button
		assert_true(random.button_pressed)
		assert_eq((random.find_child("State", true, false) as Label).text, "ON")
		for path: int in DraftKit.PATH_ORDER:
			var toggle: Button = screen.find_child("PathToggle_%d" % path, true, false) as Button
			assert_false(toggle.button_pressed, "no Path is lit while Random is on")
			assert_eq((toggle.find_child("State", true, false) as Label).text, "?")
		assert_string_contains((screen.find_child("PathCaption", true, false) as Label).text, "Random")
		# a click on a Path ends Random: that Path is the choice
		await _click(screen.find_child("PathToggle_%d" % int(P.GOURMAND), true, false) as Control)
		assert_false(screen.random_paths)
		assert_eq(screen._paths, [int(P.GOURMAND)] as Array[int])
		# and a second click on Random switches it off again without losing the choice
		await _click(screen.find_child("PathToggle_random", true, false) as Control)
		await _click(screen.find_child("PathToggle_random", true, false) as Control)
		assert_false(screen.random_paths)
		assert_eq(screen._paths, [int(P.GOURMAND)] as Array[int])


func test_random_works_with_the_controller_and_starts_a_draft_with_allowed_paths() -> void:
	_free(["beefcake"] as Array[String])
	var screen: DraftHubScreen = await _menu()
	await _press_accept(_tile(screen, DraftArena.MODE_CLASSIC))
	var random: Button = screen.find_child("PathToggle_random", true, false) as Button
	assert_eq(random.focus_mode, Control.FOCUS_ALL, "Random takes the pad's focus")
	await _press_accept(random)
	assert_true(screen.random_paths, "confirm switches Random on")
	# Start: the house picks, the draft begins with one or two Paths
	var started: Array[bool] = [false]
	screen.reopen.connect(func() -> void: started[0] = true)
	await _press_accept(screen.find_child("Start", true, false) as Control)
	assert_true(started[0], "the draft starts")
	assert_not_null(Session.draft)
	if Session.draft != null:
		assert_eq(Session.draft.challenge_id, DraftArena.CLASSIC_ID)
		assert_between(Session.draft.paths.size(), 1, 2, "within the story's rule")
		for path: int in Session.draft.paths:
			assert_true(DraftKit.PATH_ORDER.has(path))


# ---- The deck picker ---------------------------------------------------------------------------------------------------------------


func test_the_deck_picker_is_sorted_by_cost_then_by_name() -> void:
	assert_true(Session.start_draft(DraftArena.CLASSIC_ID, [int(P.BEEFCAKE)] as Array[int]))
	var guard: int = 0
	while Session.draft.phase == DraftState.PHASE_PICK and guard < 100:
		Session.draft_pick((guard * 7) % 3)
		guard += 1
	var draft: DraftState = Session.draft
	var order: Array[int] = DraftScreen.deck_order(draft)
	assert_eq(order.size(), draft.cards.size(), "every pick is shown once")
	var seen: Dictionary = {}
	var costs: Dictionary = {}
	for position: int in range(order.size()):
		assert_false(seen.has(order[position]))
		seen[order[position]] = true
		var card: CardData = Session.card_by_id(draft.cards[order[position]])
		costs[DraftScreen.card_cost(card)] = true
		if position == 0:
			continue
		var before: CardData = Session.card_by_id(draft.cards[order[position - 1]])
		var cost_before: int = DraftScreen.card_cost(before)
		var cost: int = DraftScreen.card_cost(card)
		assert_lte(cost_before, cost, "%s (%d) comes before %s (%d)" % [before.display_name, cost_before, card.display_name, cost])
		if cost_before == cost:
			assert_lte(before.display_name.to_lower(), card.display_name.to_lower(), "the same cost: by name")
	assert_gt(costs.size(), 2, "a draft of several costs was sorted")
	# the screen lays the tiles out in that order, and a tile still answers for its own pick
	var screen: DraftScreen = DraftScreen.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	await get_tree().process_frame
	var grid: Control = screen.find_child("DeckGrid", true, false) as Control
	assert_not_null(grid, "the deck picker is open")
	if grid != null:
		var shown: Array[int] = []
		for tile: Node in grid.get_children():
			shown.append(int(str(tile.name).trim_prefix("DeckCard")))
		assert_eq(shown, order)


# ---- Hover Boots ------------------------------------------------------------------------------------------------------------------


func test_hover_boots_only_reach_opponents_at_the_high_rollers_table() -> void:
	var content: ContentSet = Session.content
	assert_not_null(content.equipment_piece("hover_boots"), "the piece exists")
	# the rule: every kind of table but High Rollers leaves them out of an opponent's offers
	for kind: String in [DraftArena.KIND_ZONE, DraftArena.KIND_OPEN, DraftArena.KIND_DAILY, DraftArena.KIND_DUNGEON, DraftArena.KIND_MYSTERY, DraftArena.KIND_HALLS]:
		assert_true(DraftRules.rival_equipment_excluded(kind).has("hover_boots"), "no Hover Boots for an opponent at a %s table" % kind)
	assert_false(DraftRules.rival_equipment_excluded(DraftArena.KIND_HIGH).has("hover_boots"), "High Rollers opponents may get them")
	# the player's own offers are not touched
	var boots_slot: int = int(content.equipment_piece("hover_boots").slot)
	var for_player: Array[String] = []
	for piece: EquipmentData in DraftEngine.equipment_pool(content, boots_slot):
		for_player.append(piece.id)
	assert_true(for_player.has("hover_boots"), "the player can still draft them")
	# many opponents drafted at every kind of table: only High Rollers' ever wear them
	_free(["beefcake", "gourmand", "necrocrat"] as Array[String])
	Session.flags[str(MultiPathLock.FLAG_UNLOCKED)] = true
	var tables: Dictionary = {"zone:beefcake": false, DraftArena.CLASSIC_ID: false, DraftArena.daily_id(): false, DraftArena.MYSTERY_ID: false, DraftArena.HIGH_ID: true}
	for challenge: String in tables.keys():
		var wearers: int = 0
		for seed_value: int in range(1, 41):
			var state: DraftState = DraftState.new()
			state.challenge_id = challenge
			state.paths = [int(P.BEEFCAKE)] as Array[int]
			state.level = 16
			state.max_paths = 4
			state.seed = seed_value * 977
			for index: int in range(3):
				var rival: Dictionary = DraftRivals.build(content, state, "rollo", "A rival", "aggressive", index)
				if (rival["equipment"] as Array).has("hover_boots"):
					wearers += 1
		if bool(tables[challenge]):
			assert_gt(wearers, 0, "at High Rollers some opponent of 120 drafts the Hover Boots")
		else:
			assert_eq(wearers, 0, "%s: no opponent of 120 wears the Hover Boots" % challenge)
	# the hand-made opponents: nobody in a dungeon (the Shuffled Halls' dealers included) wears them
	for path: String in ["res://data/dungeons/dungeon_content.json", "res://data/encounters/modifiers.json", "res://data/encounters/encounter_scripts.json"]:
		assert_false(FileAccess.get_file_as_string(path).contains("hover_boots"), "%s gives no foe the Hover Boots" % path.get_file())


# ---- Octavia -----------------------------------------------------------------------------------------------------------------------


func test_octavia_stands_whole_on_the_floor_of_her_panel() -> void:
	var path: String = str(DraftHubScreen.FULL_BODY[DraftArena.NPC_ID])
	assert_true(ResourceLoader.exists(path), "her full-body picture is in the game")
	var whole: Texture2D = load(path) as Texture2D
	assert_gt(whole.get_size().y / whole.get_size().x, 1.4, "a standing figure")
	# the picture reaches her hem: its last rows hold the gown, its first rows the feather
	var image: Image = whole.get_image()
	if image.is_compressed():
		image.decompress()
	var bottom: int = 0
	for x: int in range(0, image.get_width(), 4):
		if image.get_pixel(x, image.get_height() - 40).a > 0.5:
			bottom += 1
	assert_gt(bottom, 20, "the hem of the gown is at the picture's bottom edge (not a cut at the knees: a cut would fill the whole row)")
	assert_lt(bottom, image.get_width() / 4 * 0.9, "and the figure does not fill the row from edge to edge")
	var screen: DraftHubScreen = await _menu()
	var stage: Control = screen.find_child("HostStage", true, false) as Control
	assert_not_null(stage, "at 16:9 she stands beside the board")
	if stage == null:
		return
	var picture: TextureRect = stage.get_node("HostPortrait") as TextureRect
	assert_eq(picture.texture, whole)
	var frame: Rect2 = stage.get_global_rect()
	var figure: Rect2 = picture.get_global_rect()
	assert_almost_eq(figure.end.y, frame.end.y - DraftHubScreen.HOST_FLOOR, 2.5, "her feet are on the floor of the panel")
	assert_gte(figure.position.y, frame.position.y - 0.5, "her head is inside the panel")
	assert_almost_eq(figure.size.y / figure.size.x, whole.get_size().y / whole.get_size().x, 0.01, "not stretched")
	assert_gt(figure.size.y, 500.0, "and large")
	var shadow: TextureRect = stage.get_node("HostFloorShadow") as TextureRect
	assert_true(shadow.get_global_rect().intersects(Rect2(figure.position.x, figure.end.y - 30.0, figure.size.x, 30.0)), "a shadow lies under her")
	# in the world she stands on the cobbles of the apron
	assert_almost_eq(TownShuffleHouse.host_spot().y, 0.07, 0.02)
