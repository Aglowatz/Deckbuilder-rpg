extends GutTest
## Fix pass Nov 7, Part 3 (critic items 3, 8, 12, 13): one Esc closes one thing, the Open-all grid puts new cards first, hand cards are
## compact until hovered, and a big hand splits into two rows.


func before_each() -> void:
	UiInput.reset_back_guard()


func _esc() -> InputEventAction:
	var event: InputEventAction = InputEventAction.new()
	event.action = &"ui_cancel"
	event.pressed = true
	return event


func test_one_esc_is_taken_by_one_handler_only() -> void:
	var event: InputEventAction = _esc()
	assert_true(UiInput.is_back(event), "the first handler takes it")
	assert_false(UiInput.is_back(event), "a second handler of the same press does not (no two-level close)")


func test_a_second_esc_right_after_is_ignored() -> void:
	assert_true(UiInput.is_back(_esc()))
	assert_false(UiInput.is_back(_esc()), "within the guard")
	UiInput.reset_back_guard()
	assert_true(UiInput.is_back(_esc()), "after the guard")


func test_open_all_shows_new_cards_first() -> void:
	var old_card: CardData = GameFactory.vanilla(1, 1)
	var new_card: CardData = GameFactory.vanilla(2, 2)
	var opening: PackOpening = PackOpening.new()
	var a: PackOpening.Entry = PackOpening.Entry.new()
	a.card = old_card
	var b: PackOpening.Entry = PackOpening.Entry.new()
	b.card = new_card
	b.is_new = true
	opening.entries = [a, b] as Array[PackOpening.Entry]
	var ordered: Array[PackOpening.Entry] = PacksScreen.result_entries([opening] as Array[PackOpening])
	assert_eq(ordered[0], b, "the new card leads")
	assert_eq(ordered.size(), 2, "every card has a tile")


func test_hand_cards_are_compact_and_big_hands_use_two_rows() -> void:
	assert_true(BattleBoard.compact_hand)
	assert_eq(BattleBoard.TWO_ROW_HAND, 10)
	assert_gt(BattleBoard.TWO_ROW_LIFT, 0.0)


## Overnight Nov 7-8, Part 1.11: an Open-all result card shows whole and readable on hover and on keyboard / pad focus.
func test_open_all_results_zoom_on_hover_and_focus() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.add_pack(PackRules.GENERAL_1_ID, 2)
	var screen: PacksScreen = PacksScreen.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	var openings: Array[PackOpening] = [Session.open_pack(PackRules.GENERAL_1_ID), Session.open_pack(PackRules.GENERAL_1_ID)]
	screen._show_open_all(openings)
	await get_tree().process_frame
	assert_not_null(screen.open_all_preview)
	var tiles: Array[Node] = screen.find_children("Result_*", "Control", true, false)
	assert_gt(tiles.size(), 0)
	var tile: Control = tiles[0] as Control
	assert_eq(tile.focus_mode, Control.FOCUS_ALL, "keyboard and pad can focus a result")
	tile.focus_entered.emit()  # headless: the overlay is not visible in a window, so a real grab_focus is refused
	assert_true(screen.open_all_preview.visible, "focus shows the card whole")
	tile.focus_exited.emit()
	assert_false(screen.open_all_preview.visible)
	tile.mouse_entered.emit()
	assert_true(screen.open_all_preview.visible, "and so does the mouse")
