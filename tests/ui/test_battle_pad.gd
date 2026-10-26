extends GutTest
## Controller support (Oct 26): the battle screen's pad cursor (`BattlePad`) - where it starts for each decision, how the D-pad moves it, what A,
## B and Y do, and that a modal panel (the mulligan) takes ordinary focus while the cursor waits. One practice duel, no tips, no intro.

var _screen: BattleScreen


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Keybinds.reset_all()
	InputDevice.set_kind(InputDevice.Kind.PAD)
	_screen = (load("res://scenes/battle.tscn") as PackedScene).instantiate() as BattleScreen
	_screen.screenshot_prepare({"no_tutorial": "true", "no_intro": "true", "fast": "true"})
	add_child_autofree(_screen)
	await _until(func() -> bool: return _screen.mode == BattleScreen.Mode.MULLIGAN, 8.0)


func after_each() -> void:
	InputDevice.set_kind(InputDevice.Kind.KEYBOARD)


func _until(condition: Callable, limit: float) -> bool:
	var waited: float = 0.0
	while waited < limit:
		if bool(condition.call()):
			return true
		await get_tree().process_frame
		waited += get_process_delta_time()
	return bool(condition.call())


func _to_main() -> void:
	_screen._mulligan_choice(true)
	await _until(func() -> bool: return _screen.mode == BattleScreen.Mode.MAIN and not _screen.busy and PadFocus.top_root(get_tree()) == null, 10.0)
	await get_tree().process_frame
	_screen.pad.reset()


func test_the_mulligan_box_takes_focus_and_the_cursor_waits() -> void:
	assert_eq(_screen.mode, BattleScreen.Mode.MULLIGAN)
	assert_not_null(PadFocus.top_root(get_tree()), "the opening-hand box is a pad screen")
	assert_false(_screen.pad.active(), "the board cursor waits behind it")
	var focused: Control = PadFocus.focus_into(PadFocus.top_root(get_tree()))
	assert_true(focused is Button and (focused as Button).text.contains("Keep"), "Keep Hand is focused first")


func test_the_cursor_starts_on_a_playable_card_in_hand() -> void:
	await _to_main()
	assert_true(_screen.pad.active())
	var here: Dictionary = _screen.pad.current()
	assert_eq(str(here.get("kind", "")), "card")
	var card: CardInstance = _screen.game.players[0].find_hand(int(here.get("uid", 0)))
	assert_not_null(card, "a card in hand")
	assert_true(card != null and _screen._is_playable(card), "one that can be played now")
	assert_eq(_screen.board.hover_uid, int(here["uid"]), "it lifts like a hovered card")


func test_everything_clickable_is_a_stop() -> void:
	await _to_main()
	var kinds: Dictionary = {}
	var has_primary: bool = false
	var portraits: int = 0
	for stop: Dictionary in _screen.pad.stops():
		kinds[str(stop["kind"])] = true
		if stop["control"] == _screen.hud.primary_button:
			has_primary = true
		if str(stop["kind"]) == "portrait":
			portraits += 1
	assert_true(kinds.has("card") and kinds.has("pile") and kinds.has("button"))
	assert_eq(portraits, 2, "both portraits")
	assert_true(has_primary, "the Combat / End Turn button")


func test_the_d_pad_walks_along_the_hand() -> void:
	await _to_main()
	var hand: Array[CardInstance] = _screen.game.players[0].hand
	assert_gt(hand.size(), 2)
	# Start from the leftmost hand card and step right through the hand.
	var leftmost: Dictionary = {}
	for stop: Dictionary in _screen.pad.stops():
		if str(stop["kind"]) == "card" and _screen.game.players[0].find_hand(int(stop["uid"])) != null:
			if leftmost.is_empty() or (stop["rect"] as Rect2).position.x < (leftmost["rect"] as Rect2).position.x:
				leftmost = stop
	_screen.pad._set_cursor(leftmost)
	var start_x: float = (_screen.pad.current()["rect"] as Rect2).get_center().x
	assert_true(_screen.pad.move(Vector2.RIGHT))
	var next: Dictionary = _screen.pad.current()
	assert_gt((next["rect"] as Rect2).get_center().x, start_x, "moved right")
	assert_not_null(_screen.game.players[0].find_hand(int(next.get("uid", 0))), "and stayed in the hand")
	assert_true(_screen.pad.move(Vector2.UP), "up leaves the hand for the board")
	assert_lt((_screen.pad.current()["rect"] as Rect2).get_center().y, (next["rect"] as Rect2).get_center().y)


func test_a_plays_the_card_under_the_cursor() -> void:
	await _to_main()
	var infra: CardInstance = null
	for card: CardInstance in _screen.game.players[0].hand:
		if card.data.is_infrastructure() and _screen._is_playable(card):
			infra = card
	if infra == null:
		pass_test("no infrastructure in this opening hand")
		return
	for stop: Dictionary in _screen.pad.stops():
		if str(stop["kind"]) == "card" and int(stop["uid"]) == infra.uid:
			_screen.pad._set_cursor(stop)
	var before: int = _screen.game.players[0].infrastructure.size()
	_screen.pad.activate()
	await _until(func() -> bool: return _screen.game.players[0].infrastructure.size() > before, 5.0)
	assert_eq(_screen.game.players[0].infrastructure.size(), before + 1, "A played the infrastructure")


func test_targeting_starts_on_a_target_and_b_cancels() -> void:
	await _to_main()
	var options: Array[int] = [Targets.player(1)]
	_screen._begin_targeting(0, options, GameAction.Type.PLAY, 0)
	_screen.pad.reset()
	var here: Dictionary = _screen.pad.current()
	assert_eq(str(here.get("kind", "")), "portrait")
	assert_eq(int(here.get("player", -1)), 1, "the enemy portrait, the only target")
	assert_not_null(_screen.pad.aim_point(), "the targeting arrow aims at the cursor")
	_screen.pad.back()
	assert_eq(_screen.mode, BattleScreen.Mode.MAIN, "B cancelled the choice")


func test_y_hides_and_shows_the_card_details() -> void:
	await _to_main()
	assert_true(_screen.pad.details)
	_screen.pad.toggle_details()
	assert_false(_screen.pad.details)
	assert_false(_screen.hud._preview_root.visible, "the preview closes")
	_screen.pad.toggle_details()
	assert_true(_screen.pad.details)


func test_the_cursor_is_pad_only() -> void:
	await _to_main()
	InputDevice.set_kind(InputDevice.Kind.KEYBOARD)
	assert_false(_screen.pad.active(), "with the mouse in use there is no cursor")
	assert_true(_screen.pad.cursor.is_empty())
	assert_string_contains(_screen.hud.primary_button.text, "[Space]", "the button names the keyboard key")
	InputDevice.set_kind(InputDevice.Kind.PAD)
	assert_string_contains(_screen.hud.primary_button.text, "[X]", "and the pad's X once the pad is back")
