extends GutTest
## Controller support (Oct 26, docs/design/controller.md): the pad bindings (defaults, the InputMap, rebinding, persistence), the device switch and
## its glyph names (Xbox / PlayStation), prompts that re-render, the stick's fresh-press edge, the settings screen's controller column, and the
## shared focus helper (the topmost screen, the first button).

const TEMP_PATH: String = "user://test_controller_settings.cfg"

var _pad_prompts: int = 0


func before_each() -> void:
	_pad_prompts = Settings.pad_prompts
	Keybinds.reset_all()
	InputDevice.set_kind(InputDevice.Kind.KEYBOARD)


func after_each() -> void:
	Settings.pad_prompts = _pad_prompts
	InputDevice.set_kind(InputDevice.Kind.KEYBOARD)
	InputDevice.detected_layout = InputDevice.Layout.XBOX
	Keybinds.reset_all()
	if FileAccess.file_exists(TEMP_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_PATH))


func _button(index: JoyButton, pressed: bool = true) -> InputEventJoypadButton:
	var event: InputEventJoypadButton = InputEventJoypadButton.new()
	event.button_index = index
	event.pressed = pressed
	event.device = 0
	return event


func _motion(axis: JoyAxis, value: float) -> InputEventJoypadMotion:
	var event: InputEventJoypadMotion = InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = value
	event.device = 0
	return event


# ---- Defaults and the InputMap ---------------------------------------------------------------


func test_every_action_has_a_controller_button() -> void:
	for action: StringName in Keybinds.action_ids():
		assert_ne(Keybinds.pad_of(action), Keybinds.PAD_NONE, "%s has a pad default" % action)


func test_no_two_actions_of_a_group_share_a_pad_default() -> void:
	var seen: Dictionary = {}
	for action: StringName in Keybinds.action_ids():
		var key: String = "%s:%d" % [Keybinds.group_of(action), Keybinds.pad_default(action)]
		assert_false(seen.has(key), "%s and %s share a pad button" % [action, seen.get(key, "")])
		seen[key] = action


func test_the_default_layout() -> void:
	assert_eq(Keybinds.pad_of(&"interact"), JOY_BUTTON_A)
	assert_eq(Keybinds.pad_of(&"pause"), JOY_BUTTON_START)
	assert_eq(Keybinds.pad_of(&"open_map"), JOY_BUTTON_BACK)
	assert_eq(Keybinds.pad_of(&"open_menu"), JOY_BUTTON_DPAD_UP)
	assert_eq(Keybinds.pad_of(&"move_up"), Keybinds.PAD_LS_UP)
	assert_eq(Keybinds.pad_of(&"battle_advance"), JOY_BUTTON_X)
	assert_eq(Keybinds.pad_of(&"battle_inspect"), JOY_BUTTON_Y)
	assert_eq(Keybinds.pad_of(&"quest_prev"), JOY_BUTTON_LEFT_SHOULDER, "the bumpers keep cycling the tracked quest")


func test_pad_buttons_trigger_their_actions() -> void:
	assert_true(_button(JOY_BUTTON_A).is_action_pressed(&"interact"))
	assert_true(_button(JOY_BUTTON_START).is_action_pressed(&"pause"))
	assert_true(_button(JOY_BUTTON_Y).is_action_pressed(&"open_character"))
	assert_true(_button(JOY_BUTTON_X).is_action_pressed(&"battle_advance"))
	assert_false(_button(JOY_BUTTON_A, false).is_action_pressed(&"interact"), "a release is no press")


func test_menus_confirm_with_a_and_go_back_with_b() -> void:
	assert_true(_button(JOY_BUTTON_A).is_action_pressed(&"ui_accept"))
	assert_true(_button(JOY_BUTTON_B).is_action_pressed(&"ui_cancel"))
	assert_true(UiInput.is_confirm(_button(JOY_BUTTON_A)))
	assert_true(UiInput.is_back(_button(JOY_BUTTON_B)))
	assert_true(_button(JOY_BUTTON_DPAD_DOWN).is_action_pressed(&"ui_down"), "the D-pad moves menu focus")


func test_the_left_stick_moves_with_its_tilt() -> void:
	var push: InputEventJoypadMotion = _motion(JOY_AXIS_LEFT_Y, -0.8)
	assert_true(push.is_action_pressed(&"move_up"))
	assert_almost_eq(push.get_action_strength(&"move_up"), (0.8 - Keybinds.PAD_DEADZONE) / (1.0 - Keybinds.PAD_DEADZONE), 0.01)
	assert_false(_motion(JOY_AXIS_LEFT_Y, -0.1).is_action_pressed(&"move_up"), "inside the dead zone")
	assert_true(_motion(JOY_AXIS_TRIGGER_LEFT, 0.9).is_action_pressed(&"camera_swivel_left"), "LT turns the camera")


func test_keyboard_keys_are_unchanged() -> void:
	assert_eq(Keybinds.keys_of(&"interact"), [KEY_E, KEY_SPACE] as Array[int])
	assert_eq(Keybinds.keys_of(&"pause"), [KEY_ESCAPE, 0] as Array[int])
	assert_eq(Keybinds.keys_of(&"open_menu"), [0, 0] as Array[int], "the new HUD-menu action has no key: nothing new on the keyboard")
	assert_eq(Keybinds.keys_of(&"battle_inspect"), [0, 0] as Array[int])


# ---- Rebinding --------------------------------------------------------------------------------


func test_a_pad_rebind_applies_at_once() -> void:
	assert_eq(Keybinds.rebind_pad(&"open_map", JOY_BUTTON_RIGHT_STICK), "Camera: cycle angle", "R3 moves out of the camera action")
	assert_true(_button(JOY_BUTTON_RIGHT_STICK).is_action_pressed(&"open_map"))
	assert_false(_button(JOY_BUTTON_BACK).is_action_pressed(&"open_map"), "View no longer opens the map")
	assert_eq(Keybinds.pad_of(&"camera_angle"), Keybinds.PAD_NONE)
	assert_false(Keybinds.all_default())


func test_groups_keep_their_own_pad_buttons() -> void:
	Keybinds.rebind_pad(&"battle_inspect", JOY_BUTTON_A)
	assert_eq(Keybinds.pad_of(&"interact"), JOY_BUTTON_A, "the overworld keeps A")
	assert_eq(Keybinds.pad_of(&"battle_inspect"), JOY_BUTTON_A)


func test_start_is_reserved_and_pause_is_fixed() -> void:
	assert_eq(Keybinds.rebind_pad(&"open_map", JOY_BUTTON_START), "reserved")
	assert_eq(Keybinds.rebind_pad(&"pause", JOY_BUTTON_A), "fixed")
	assert_eq(Keybinds.pad_of(&"pause"), JOY_BUTTON_START)
	assert_eq(Keybinds.pad_of(&"open_map"), JOY_BUTTON_BACK)


func test_a_stick_or_trigger_can_be_bound() -> void:
	var code: int = Keybinds.pad_code_of(_motion(JOY_AXIS_TRIGGER_RIGHT, 0.9))
	assert_eq(code, Keybinds.PAD_RT)
	Keybinds.rebind_pad(&"open_deck", code)
	assert_true(_motion(JOY_AXIS_TRIGGER_RIGHT, 0.9).is_action_pressed(&"open_deck"))
	assert_eq(Keybinds.pad_code_of(_motion(JOY_AXIS_LEFT_X, 0.2)), Keybinds.PAD_NONE, "a small nudge is not a binding")


func test_reset_restores_the_pad_buttons() -> void:
	Keybinds.rebind_pad(&"interact", JOY_BUTTON_X)
	Keybinds.reset_action(&"interact")
	assert_eq(Keybinds.pad_of(&"interact"), JOY_BUTTON_A)
	Keybinds.rebind_pad(&"open_quests", Keybinds.PAD_NONE)
	Keybinds.reset_all()
	assert_true(Keybinds.all_default())


func test_pad_bindings_and_the_glyph_choice_persist() -> void:
	Keybinds.rebind_pad(&"open_quests", JOY_BUTTON_RIGHT_STICK)
	Settings.pad_prompts = 2
	Settings.save_settings(TEMP_PATH)
	Keybinds.reset_all()
	Settings.pad_prompts = 0
	Settings.load_settings(TEMP_PATH)
	assert_eq(Keybinds.pad_of(&"open_quests"), JOY_BUTTON_RIGHT_STICK)
	assert_eq(Keybinds.pad_of(&"open_map"), JOY_BUTTON_BACK, "untouched buttons stay at their default")
	assert_eq(Settings.pad_prompts, 2)


# ---- The device and its glyphs ------------------------------------------------------------------


func test_the_last_device_used_decides_the_prompts() -> void:
	assert_false(InputDevice.using_pad())
	assert_true(InputDevice.note(_button(JOY_BUTTON_A)), "a pad button switches to the controller")
	assert_true(InputDevice.using_pad())
	assert_false(InputDevice.note(_motion(JOY_AXIS_LEFT_X, 0.1)), "a resting stick changes nothing")
	var nudge: InputEventMouseMotion = InputEventMouseMotion.new()
	nudge.relative = Vector2(1, 1)
	assert_false(InputDevice.note(nudge), "a jittering mouse changes nothing")
	var key: InputEventKey = InputEventKey.new()
	key.physical_keycode = KEY_W
	key.pressed = true
	assert_true(InputDevice.note(key), "a key switches back")
	assert_false(InputDevice.using_pad())


func test_playstation_pads_are_recognised_by_name() -> void:
	assert_eq(InputDevice.layout_for_name("PS5 Controller"), InputDevice.Layout.PLAYSTATION)
	assert_eq(InputDevice.layout_for_name("DualSense Wireless Controller"), InputDevice.Layout.PLAYSTATION)
	assert_eq(InputDevice.layout_for_name("Xbox Series Controller"), InputDevice.Layout.XBOX)
	assert_eq(InputDevice.layout_for_name("Generic USB Joystick"), InputDevice.Layout.XBOX)


func test_glyph_names_follow_the_layout() -> void:
	assert_eq(InputDevice.pad_text(JOY_BUTTON_A, InputDevice.Layout.XBOX), "A")
	assert_eq(InputDevice.pad_text(JOY_BUTTON_A, InputDevice.Layout.PLAYSTATION), "Cross")
	assert_eq(InputDevice.pad_text(JOY_BUTTON_Y, InputDevice.Layout.PLAYSTATION), "Triangle")
	assert_eq(InputDevice.pad_text(JOY_BUTTON_LEFT_SHOULDER, InputDevice.Layout.PLAYSTATION), "L1")
	assert_eq(InputDevice.pad_text(Keybinds.PAD_LT, InputDevice.Layout.XBOX), "LT")
	assert_eq(InputDevice.pad_text(Keybinds.PAD_RT, InputDevice.Layout.PLAYSTATION), "R2")
	assert_eq(InputDevice.pad_text(Keybinds.PAD_LS_UP, InputDevice.Layout.XBOX), "Left stick up")
	Settings.pad_prompts = 2
	assert_eq(InputDevice.pad_text(JOY_BUTTON_B), "Circle", "the setting forces PlayStation names")


func test_hints_switch_with_the_device() -> void:
	assert_eq(Keybinds.first_key(&"open_deck"), "B")
	assert_eq(Keybinds.hint(&"interact"), "E / Space")
	assert_eq(Keybinds.back_key(), "Esc")
	InputDevice.set_kind(InputDevice.Kind.PAD)
	assert_eq(Keybinds.first_key(&"open_deck"), "X")
	assert_eq(Keybinds.hint(&"interact"), "A")
	assert_eq(Keybinds.back_key(), "B")
	assert_eq(Keybinds.prompt(), "[A]")


func test_prompt_templates_render_for_each_device() -> void:
	assert_eq(PromptText.render("Leave (Esc)"), "Leave (Esc)", "keyboard text is exactly the old text")
	assert_eq(PromptText.render("[E]  Talk to Maren"), "[E]  Talk to Maren")
	assert_eq(PromptText.render("Deck ({open_deck})"), "Deck (B)")
	assert_eq(PromptText.render("{unknown} stays"), "{unknown} stays")
	InputDevice.set_kind(InputDevice.Kind.PAD)
	assert_eq(PromptText.render("Leave (Esc)"), "Leave (B)")
	assert_eq(PromptText.render("[E]  Talk to Maren"), "[A]  Talk to Maren")
	assert_eq(PromptText.render("Deck ({open_deck}), {confirm} to buy"), "Deck (X), A to buy")


func test_bound_labels_re_render_on_a_device_switch() -> void:
	var label: Label = Label.new()
	add_child_autofree(label)
	PromptText.bind(label, "Close (Esc)")
	var hints: Label = Label.new()
	add_child_autofree(hints)
	PromptText.bind(hints, "WASD: move", &"text", "Left stick: move")
	assert_eq(label.text, "Close (Esc)")
	assert_eq(hints.text, "WASD: move")
	InputDevice.set_kind(InputDevice.Kind.PAD)
	PromptText.refresh_all(get_tree())
	assert_eq(label.text, "Close (B)")
	assert_eq(hints.text, "Left stick: move")


func test_a_held_stick_is_one_fresh_press() -> void:
	assert_true(UiInput.is_fresh_press(_motion(JOY_AXIS_TRIGGER_RIGHT, 0.7)))
	var again: InputEventJoypadMotion = _motion(JOY_AXIS_TRIGGER_RIGHT, 0.9)
	assert_false(UiInput.is_fresh_press(again), "still held")
	assert_false(UiInput.is_fresh_press(again), "asking twice about one event gives one answer")
	assert_false(UiInput.is_fresh_press(_motion(JOY_AXIS_TRIGGER_RIGHT, 0.1)))
	assert_true(UiInput.is_fresh_press(_motion(JOY_AXIS_TRIGGER_RIGHT, 0.8)), "released and pushed again")
	assert_true(UiInput.is_fresh_press(_button(JOY_BUTTON_X)))
	assert_false(UiInput.is_fresh_press(_button(JOY_BUTTON_X, false)))


# ---- Settings > Controls ----------------------------------------------------------------------


func test_settings_screen_rebinds_a_controller_button() -> void:
	var panel: SettingsPanel = SettingsPanel.new()
	panel.autosave = false
	add_child_autofree(panel)
	panel.show_page(3)
	await get_tree().process_frame
	var row: Node = panel.find_child("Key_open_map", true, false)
	assert_not_null(row)
	var pad_button: Button = row.find_child("PadSlot", true, false) as Button
	assert_not_null(pad_button)
	assert_eq(pad_button.text, "View")
	pad_button.pressed.emit()
	assert_eq(pad_button.text, "Press a button...")
	panel.capture_pad(JOY_BUTTON_LEFT_STICK)
	assert_eq(Keybinds.pad_of(&"open_map"), JOY_BUTTON_LEFT_STICK)
	assert_eq(pad_button.text, "LS")
	var note: Label = panel.find_child("ConflictNote", true, false) as Label
	assert_string_contains(note.text, "Sprint (hold)", "Overnight Oct 30-31: L3 is the sprint now (the zoom moved to Share)")


func test_the_pause_row_shows_a_fixed_controller_button() -> void:
	var panel: SettingsPanel = SettingsPanel.new()
	panel.autosave = false
	add_child_autofree(panel)
	panel.show_page(3)
	await get_tree().process_frame
	var pad_button: Button = panel.find_child("Key_pause", true, false).find_child("PadSlot", true, false) as Button
	assert_true(pad_button.disabled)
	assert_eq(pad_button.text, "Menu")
	assert_not_null(panel.find_child("PadPromptOptions", true, false), "the button-name choice is on the page")


# ---- The focus helper -------------------------------------------------------------------------


func test_the_topmost_registered_screen_takes_the_focus() -> void:
	var lower: Control = Control.new()
	add_child_autofree(lower)
	var low_button: Button = Button.new()
	lower.add_child(low_button)
	PadFocus.register(lower)
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 20
	add_child_autofree(layer)
	var upper: Control = Control.new()
	layer.add_child(upper)
	var first: Button = Button.new()
	first.focus_mode = Control.FOCUS_NONE
	upper.add_child(first)
	var second: Button = Button.new()
	upper.add_child(second)
	PadFocus.register(upper)
	assert_eq(PadFocus.top_root(get_tree()), upper, "the higher canvas layer wins")
	assert_eq(PadFocus.focus_into(upper), first, "the first button, made focusable")
	assert_true(first.has_focus())
	upper.visible = false
	assert_eq(PadFocus.top_root(get_tree()), lower, "a hidden screen gives way")


func test_the_focus_ring_rect_is_in_screen_pixels() -> void:
	var holder: Control = Control.new()
	add_child_autofree(holder)
	holder.position = Vector2(100, 50)
	holder.scale = Vector2(2, 2)
	var button: Control = Control.new()
	holder.add_child(button)
	button.position = Vector2(10, 10)
	button.size = Vector2(40, 20)
	var rect: Rect2 = PadFocus.focus_rect(button)
	assert_eq(rect.position, Vector2(120, 70))
	assert_eq(rect.size, Vector2(80, 40))
