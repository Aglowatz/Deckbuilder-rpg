extends GutTest
## Overnight Oct 30-31, Part 6: the dialogue presentation - any key completes the line then advances (Esc, F keys and lone modifiers keep
## their jobs), the previous speaker of a back-and-forth stays on the other side dimmed while the next one speaks, a lone line sends the
## listener away. No line text changes.

var box: DialogueBox


func before_each() -> void:
	NpcRegistry.reset()
	Portraits.reset()
	var host: Control = Control.new()
	host.size = Vector2(1920, 1080)
	add_child_autofree(host)
	box = DialogueBox.new()
	host.add_child(box)


func _key(code: Key) -> InputEventKey:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	return event


func test_any_key_advances_but_not_escape_f_keys_or_shift() -> void:
	assert_true(DialogueBox.is_advance_key(_key(KEY_W)), "a letter")
	assert_true(DialogueBox.is_advance_key(_key(KEY_ENTER)))
	assert_false(DialogueBox.is_advance_key(_key(KEY_ESCAPE)), "Esc keeps the pause menu")
	assert_false(DialogueBox.is_advance_key(_key(KEY_F8)), "F8 keeps the report dialog")
	assert_false(DialogueBox.is_advance_key(_key(KEY_SHIFT)), "Shift (sprint) alone does nothing")
	var echo: InputEventKey = _key(KEY_W)
	echo.echo = true
	assert_false(DialogueBox.is_advance_key(echo), "a held key does not run through the lines")


func test_a_key_completes_the_line_then_closes() -> void:
	box.start("Elder Maren", ["A line long enough to still be typing when the key comes."] as Array[String])
	await wait_frames(2)
	box._unhandled_input(_key(KEY_K))
	assert_true(box.active, "the first press completes the line")
	box._unhandled_input(_key(KEY_K))
	assert_false(box.active, "the second closes it")


func test_the_last_speaker_listens_dimmed_on_the_other_side() -> void:
	box.start("Elder Maren", ["Welcome."] as Array[String])
	await wait_frames(2)
	box.press()
	box.press()
	assert_false(box.active)
	box.start("", ["I should find the way out."] as Array[String], NpcRegistry.PLAYER_ID)
	await wait_frames(2)
	var listener: PortraitView = box.listener_view()
	assert_true(listener.shown, "Maren stays up while the hero answers")
	assert_true(listener.listening)
	await wait_seconds(0.6)
	assert_lt(float(listener.get("_brightness")), PortraitView.IDLE_BRIGHTNESS, "dimmed")


func test_a_lone_conversation_has_no_listener() -> void:
	box.start("Elder Maren", ["Welcome."] as Array[String])
	await wait_frames(2)
	assert_false(box.listener_view().shown)
	box.press()
	box.press()
	await wait_seconds(0.9)
	box.start("Elder Maren", ["Again."] as Array[String])
	await wait_frames(2)
	assert_false(box.listener_view().shown, "the same speaker, or a long pause, is not a back-and-forth")
