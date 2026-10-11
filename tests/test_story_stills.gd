extends GutTest
## The story stills (Part F of the art integration round): the seven stills, their captions in the story data, where they are placed, and the screen's click-through flow.


func before_each() -> void:
	KeyArt.reset()


func test_every_still_has_art_and_captions_in_the_story_file() -> void:
	assert_eq(StoryStills.IDS.size(), 7)
	for id: String in StoryStills.IDS:
		assert_true(KeyArt.has(id), "%s art" % id)
		var lines: Array[String] = StoryStills.captions(id)
		assert_gte(lines.size(), 2, "%s has a few captions" % id)
		for line: String in lines:
			assert_false(line.begins_with("[missing text"), "%s: %s" % [id, line])
			assert_lt(line.length(), 200, "short enough for the box")
	assert_eq(StoryStills.caption_key("STORY-WAKE"), "still.wake")
	assert_true(StoryText.shared().has_text("still.primm"))


func test_the_stills_are_placed_where_the_brief_says() -> void:
	assert_eq(StoryStills.for_cutscene_fx("flex", "muscle_reveal"), StoryStills.FLEX, "Flex's reveal in the House of Gains")
	assert_eq(StoryStills.for_cutscene_fx("reveal", "reveal_form"), StoryStills.DOPPEL, "the Test Kitchen's impostor")
	assert_eq(StoryStills.for_cutscene_fx("flex", "stagger"), "")
	assert_eq(StoryStills.after_boss(HallOfApprovalsDungeon.DUNGEON_ID), StoryStills.APPROVAL)
	assert_eq(StoryStills.after_boss(RotheartDungeon.DUNGEON_ID), StoryStills.ROTHEART)
	assert_eq(StoryStills.after_boss(PrimmsCastleDungeon.DUNGEON_ID), StoryStills.PRIMM)
	assert_eq(StoryStills.after_boss(HouseOfGainsDungeon.DUNGEON_ID), "")
	assert_eq(StoryStills.for_ending_fx("reunion"), StoryStills.REUNION)
	# The effects the stills hang on really exist in the cutscenes and the ending.
	var flex_fx: Array[String] = []
	for beat: Dictionary in CutsceneDefs.beats("flex"):
		flex_fx.append(str(beat["fx"]))
	assert_true(flex_fx.has("muscle_reveal"))
	var reveal_fx: Array[String] = []
	for beat: Dictionary in CutsceneDefs.beats("reveal"):
		reveal_fx.append(str(beat["fx"]))
	assert_true(reveal_fx.has("reveal_form"))
	var ending_fx: Array[String] = []
	for beat: Dictionary in EndingDefs.BEATS:
		ending_fx.append(str(beat["fx"]))
	assert_true(ending_fx.has("reunion"))


func test_a_still_fades_in_types_its_captions_and_ends_after_the_last_click() -> void:
	var host: Node = Node.new()
	add_child_autofree(host)
	var done: Array[bool] = [false]
	var screen: StoryStillScreen = StoryStillScreen.play(host, StoryStills.REUNION, func() -> void: done[0] = true)
	assert_not_null(screen)
	assert_eq(screen.modulate.a, 0.0, "starts invisible")
	await wait_seconds(StoryStillScreen.FADE_IN + 0.3)
	assert_gt(screen.modulate.a, 0.95)
	assert_true(screen.dialogue.active)
	assert_not_null(screen.find_child("StillArt", true, false))
	var count: int = screen.captions.size()
	for index: int in range(count):
		screen.dialogue.press()   # finishes the typing
		screen.dialogue.press()   # next caption / the end
	await wait_seconds(StoryStillScreen.FADE_OUT + 0.6)
	assert_true(done[0], "then() ran after the fade-out")


func test_a_missing_picture_just_carries_on() -> void:
	var host: Node = Node.new()
	add_child_autofree(host)
	var done: Array[bool] = [false]
	var screen: StoryStillScreen = StoryStillScreen.play(host, "STORY-DOES-NOT-EXIST", func() -> void: done[0] = true)
	assert_null(screen)
	assert_true(done[0])


func test_a_click_on_the_still_advances_the_caption_box() -> void:
	var host: Node = Node.new()
	add_child_autofree(host)
	var screen: StoryStillScreen = StoryStillScreen.play(host, StoryStills.WAKE)
	await wait_seconds(StoryStillScreen.FADE_IN + 0.3)
	var click: InputEventMouseButton = InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	screen._gui_input(click)
	assert_true(screen.dialogue.active, "the first click only finished the typing")
