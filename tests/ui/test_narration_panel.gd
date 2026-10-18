extends GutTest
## Overnight Oct 17 (Phase 2 cycle 11): narration (no speaker) uses the dialogue panel without its name tab; a speaker gets the tab and plate back.


func test_narration_drops_the_tab_and_a_speaker_brings_it_back() -> void:
	if not (UiArt.has("UI-PANEL-DIALOGUE") and UiArt.has("UI-NAMEPLATE")):
		pass_test("no dialogue art")
		return
	var box: DialogueBox = DialogueBox.new()
	add_child_autofree(box)
	await wait_frames(1)
	box.start("", ["You wake in a forest clearing."] as Array[String])
	assert_true(box._panel.has_theme_stylebox_override("panel"), "narration: the untabbed panel")
	assert_false(box._plate.visible)
	box.start("Elder Maren", ["Up and walking, I see."] as Array[String])
	assert_false(box._panel.has_theme_stylebox_override("panel"), "a speaker: the themed panel with its tab")
	assert_true(box._plate.visible)


func test_untabbed_panel_is_built_once() -> void:
	var first: StyleBoxTexture = UiSkin.dialogue_panel_untabbed()
	var second: StyleBoxTexture = UiSkin.dialogue_panel_untabbed()
	if first == null:
		pass_test("no dialogue art")
		return
	assert_same(first.texture, second.texture, "the untabbed image is cached")
