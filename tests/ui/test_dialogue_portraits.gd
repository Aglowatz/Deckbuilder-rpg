extends GutTest
## The visual-novel dialogue box (ui/town/dialogue_box.gd + portrait_view.gd): which NPC shows, the name plate, expression tags and fallbacks, the layout (the box stays
## on screen, the portrait stands behind its top edge and never reaches the text), the no-portrait case and closing.

var box: DialogueBox


func before_each() -> void:
	NpcRegistry.reset()
	Portraits.reset()
	var host: Control = Control.new()
	host.size = Vector2(1920, 1080)
	add_child_autofree(host)
	box = DialogueBox.new()
	host.add_child(box)


func _press(key: Key = KEY_SPACE) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = key
	event.pressed = true
	box._unhandled_input(event)


func _plate() -> String:
	return (box.get("_speaker") as Label).text


func test_a_list_npc_shows_its_portrait_and_list_name() -> void:
	box.start("Elder Maren", ["Welcome."] as Array[String])
	await wait_frames(3)
	assert_eq(box.npc_id, "NPC-ELDER")
	assert_true((box.get("_portrait") as PortraitView).shown)
	assert_eq(_plate(), "Elder Maren")


func test_the_plate_uses_the_full_list_name_for_a_short_label() -> void:
	box.start("Gerald", ["Beep."] as Array[String])
	assert_eq(box.npc_id, "NPC-GERALD")
	assert_eq(_plate(), "Gerald, Number 4,000,212")


func test_an_alias_keeps_its_own_name_but_borrows_the_portrait() -> void:
	box.start("Brock", ["Heave!"] as Array[String])
	assert_eq(box.npc_id, "NPC-HURL")
	assert_eq(_plate(), "Brock")
	box.start("Rip Tearson (Cousin #3)", ["Rift."] as Array[String])
	assert_eq(box.npc_id, "NPC-RIP")
	assert_eq(_plate(), "Rip Tearson (Cousin #3)")


func test_an_explicit_npc_id_wins_and_fills_an_empty_plate() -> void:
	box.start("", ["I should find the way out."] as Array[String], NpcRegistry.PLAYER_ID)
	assert_eq(box.npc_id, "NPC-PLAYER")
	assert_eq(_plate(), "The Wanderer", "the list's (player) annotation is not part of the plate")


func test_an_npc_with_no_portrait_shows_the_plain_box() -> void:
	box.start("Wren Muckfoot", ["Hello."] as Array[String])
	await wait_frames(3)
	assert_eq(box.npc_id, "")
	assert_false((box.get("_portrait") as PortraitView).shown, "no broken image")
	assert_eq(_plate(), "Wren Muckfoot")
	var panel: PanelContainer = box.get("_panel") as PanelContainer
	assert_eq(panel.position.x, 410.0, "the plain box keeps its old position and width")
	assert_eq(panel.size.x, 1100.0)
	box.start("The Restless Cairn", ["It is counting."] as Array[String])
	assert_eq(box.npc_id, "")


func test_a_portrait_that_is_missing_falls_back_to_no_portrait() -> void:
	# NPC-NOBODY is not in the list, so even an explicit id shows nothing.
	box.start("Somebody", ["Hi."] as Array[String], "NPC-NOBODY")
	assert_eq(box.npc_id, "")


func test_expression_tags_are_stripped_and_fall_back() -> void:
	box.start("Elder Maren", ["[happy] Well met.", "[furious] Hmph.", "[not a tag] literal", "Plain."] as Array[String])
	assert_eq((box.get("_expressions") as Array)[0], "happy")
	assert_eq((box.get("_lines") as Array)[0], "Well met.")
	assert_eq((box.get("_expressions") as Array)[1], "furious")
	assert_eq((box.get("_expressions") as Array)[2], "", "a bracket with spaces is plain text")
	assert_eq((box.get("_lines") as Array)[2], "[not a tag] literal")
	assert_eq((box.get("_expressions") as Array)[3], "")
	assert_ne(Portraits.texture_for("NPC-ELDER", "happy"), Portraits.texture_for("NPC-ELDER"))
	assert_eq(Portraits.texture_for("NPC-ELDER", "furious"), Portraits.texture_for("NPC-ELDER"), "a missing expression shows the base portrait")


func test_the_box_stays_on_screen_and_grows_upwards_for_long_lines() -> void:
	box.start("Elder Maren", ["Short."] as Array[String])
	await wait_frames(3)
	var panel: PanelContainer = box.get("_panel") as PanelContainer
	assert_almost_eq(panel.position.y + panel.size.y, 990.0, 0.5, "the bottom edge stays put")
	var short_top: float = panel.position.y
	var long_line: String = "This is a very long line. ".repeat(24)
	box.start("Elder Maren", [long_line] as Array[String])
	await wait_frames(3)
	assert_almost_eq(panel.position.y + panel.size.y, 990.0, 0.5)
	assert_lt(panel.position.y, short_top, "a long line makes the box taller, upwards")
	assert_gt(panel.position.y, 0.0, "and it still fits on screen")


func test_the_portrait_stands_behind_the_top_edge_and_never_reaches_the_text() -> void:
	box.start("Sable", ["Well met."] as Array[String])
	await wait_frames(3)
	var view: PortraitView = box.get("_portrait") as PortraitView
	var panel: PanelContainer = box.get("_panel") as PanelContainer
	var clip: Control = view.get("_clip") as Control
	assert_almost_eq(clip.size.y, panel.position.y + box._edge() + PortraitView.CLIP_BELOW, 0.5, "the portrait is cut just below the box's top edge")
	assert_lt(clip.position.x + PortraitView.SHADOW_PAD, panel.position.x, "on the left side, overhanging the box")
	var image: TextureRect = view.get("_image") as TextureRect
	assert_almost_eq(image.size.y, 1080.0 * PortraitView.HEIGHT_FRACTION, 0.5, "sized relative to the screen height")
	assert_gt(image.size.y / 1080.0, 0.55)
	assert_lt(image.size.y / 1080.0, 0.70)
	assert_false(image.flip_h)


func test_an_npc_on_the_right_side_is_mirrored() -> void:
	var entry: NpcRegistry.Entry = NpcRegistry.find("NPC-ELDER")
	entry.side = "right"
	box.start("Elder Maren", ["Hi."] as Array[String])
	await wait_frames(3)
	var view: PortraitView = box.get("_portrait") as PortraitView
	var panel: PanelContainer = box.get("_panel") as PanelContainer
	assert_true((view.get("_image") as TextureRect).flip_h)
	assert_gt((view.get("_clip") as Control).position.x, panel.position.x + panel.size.x / 2.0, "the portrait is on the right end of the box")


func test_finishing_emits_and_dismisses_the_portrait() -> void:
	box.start("Elder Maren", ["One.", "Two."] as Array[String])
	watch_signals(box)
	_press()
	_press()
	assert_true(box.active, "one line left")
	_press()
	_press()
	assert_false(box.active)
	assert_signal_emitted(box, "finished")
	assert_false((box.get("_portrait") as PortraitView).shown)
	assert_false((box.get("_panel") as PanelContainer).visible)


func test_talking_emphasis_follows_the_typing() -> void:
	box.start("Elder Maren", ["A line that types out for a little while, long enough."] as Array[String])
	var view: PortraitView = box.get("_portrait") as PortraitView
	assert_true(view.get("_talking"), "talking while the line types")
	_press()
	assert_false(view.get("_talking"), "a click completes the line and the character stops talking")


func test_chained_conversations_do_not_hide_the_new_box() -> void:
	box.start("Elder Maren", ["One."] as Array[String])
	_press()
	_press()
	box.start("Sable", ["Two."] as Array[String])
	await wait_seconds(0.4)
	assert_true(box.visible, "the delayed hide of the first conversation does not close the second")
	assert_true(box.active)
