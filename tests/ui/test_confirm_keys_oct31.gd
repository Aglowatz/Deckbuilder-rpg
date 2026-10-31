extends GutTest
## Fresh eyes round 2 (Oct 31): the E key (the overworld's "interact") answers confirm dialogs and screen tips, as the HUD advertises, and
## the Path screen's More really adds something.


func _press_e() -> InputEventKey:
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = KEY_E
	event.keycode = KEY_E
	event.pressed = true
	return event


func test_e_presses_the_focused_button_of_a_confirm_dialog() -> void:
	var host: Control = Control.new()
	add_child_autofree(host)
	var dialog: ConfirmDialog = ConfirmDialog.ask(host, "The Forgotten Cave", "Go in?", "Enter", "Not yet")
	watch_signals(dialog)
	await get_tree().process_frame
	await get_tree().process_frame
	assert_true(_press_e().is_action_pressed(&"interact"), "E is the interact action")
	dialog._unhandled_input(_press_e())
	assert_signal_not_emitted(dialog, "confirmed", "ignored inside the guard time (the E that opened the dialog)")
	dialog._age = ConfirmDialog.GUARD_TIME + 0.1
	dialog._unhandled_input(_press_e())
	assert_signal_emitted(dialog, "confirmed", "E presses the focused (primary) button")


func test_e_cancels_a_dangerous_dialog_whose_safe_button_has_focus() -> void:
	var host: Control = Control.new()
	add_child_autofree(host)
	var dialog: ConfirmDialog = ConfirmDialog.ask(host, "Delete this deck?", "Gone for good.", "Delete", "Cancel", true)
	watch_signals(dialog)
	await get_tree().process_frame
	await get_tree().process_frame
	dialog._age = ConfirmDialog.GUARD_TIME + 0.1
	dialog._unhandled_input(_press_e())
	assert_signal_emitted(dialog, "cancelled", "the safe button has the focus on a dangerous question")
	assert_signal_not_emitted(dialog, "confirmed")


func test_e_dismisses_a_screen_tip_after_its_guard() -> void:
	var host: Control = Control.new()
	add_child_autofree(host)
	var flag: StringName = &"tip_test_oct31"
	Session.set_flag(flag, false)
	var was: bool = Settings.tutorial_tips
	Settings.tutorial_tips = true
	var tip: TipPanel = TipPanel.show_once(host, flag, "A test", "Press E.")
	Settings.tutorial_tips = was
	assert_not_null(tip, "a never-seen tip shows")
	if tip == null:
		return
	tip._unhandled_input(_press_e())
	assert_false(tip._dismissed, "ignored inside the guard time")
	tip._age = TipPanel.GUARD_TIME + 0.1
	tip._unhandled_input(_press_e())
	assert_true(tip._dismissed, "E presses Got it")


func test_tutorial_tips_setting_hides_screen_tips() -> void:
	var host: Control = Control.new()
	add_child_autofree(host)
	var was: bool = Settings.tutorial_tips
	Settings.tutorial_tips = false
	var tip: TipPanel = TipPanel.show_once(host, &"tip_test_oct31_off", "A test", "Hidden.")
	Settings.tutorial_tips = was
	assert_null(tip, "no tip while the setting is off")
	assert_false(Session.flag(&"tip_test_oct31_off"), "and it is not marked as seen")


func test_path_screen_more_adds_the_resource_and_the_starting_deck() -> void:
	if Session.content == null:
		pending("needs the content set")
		return
	var screen: ElementChoiceScreen = ElementChoiceScreen.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	assert_false(screen._detail_more.visible, "closed until More is pressed")
	screen._toggle_more()
	assert_true(screen._detail_more.visible)
	var text: String = screen._detail_more.text
	assert_true(text.begins_with("Resource: "), text)
	assert_true(text.contains("Starting deck, 45 cards: 19"), text)
	assert_true(text.contains("The cards: "), text)
	screen._toggle_more()
	assert_false(screen._detail_more.visible, "Less closes it")
