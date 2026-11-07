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
