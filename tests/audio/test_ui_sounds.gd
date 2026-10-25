extends GutTest
## The interface family (docs/audio/sound_direction.md, Part D): every button taps when pressed unless its screen already made a sound, tabs and
## sliders have theirs, quests are heard, and each speaker types in a voice pitched by their kind.


func test_a_silent_button_taps_when_pressed() -> void:
	var button: Button = Button.new()
	add_child_autofree(button)
	await get_tree().process_frame
	button.pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	assert_eq(Audio.history[-1], "ui_click")


func test_a_button_that_makes_its_own_sound_does_not_also_tap() -> void:
	var button: Button = Button.new()
	button.pressed.connect(func() -> void: Audio.sfx(&"ui_confirm"))
	add_child_autofree(button)
	await get_tree().process_frame
	button.pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	assert_eq(Audio.history[-1], "ui_confirm", "no tap after the screen's own confirm")


func test_a_control_can_opt_out() -> void:
	var button: Button = Button.new()
	button.set_meta(&"no_ui_sound", true)
	add_child_autofree(button)
	await get_tree().process_frame
	var before: int = Audio.history.size()
	button.pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	assert_eq(Audio.history.size(), before)


func test_quests_are_heard() -> void:
	# Fixes Oct 25: the quest banner plays the sound; without one (tools, bare scenes) UiSounds still does.
	var banner: QuestNoticeLayer = SceneManager.quest_notices
	SceneManager.quest_notices = null
	EventBus.quest_notice.emit("New quest: test", true)
	assert_eq(Audio.history[-1], "quest_accept")
	EventBus.quest_notice.emit("Quest complete: test", false)
	assert_eq(Audio.history[-1], "quest_complete")
	SceneManager.quest_notices = banner
	if banner == null:
		return
	var before: int = Audio.history.size()
	EventBus.quest_notice.emit("New quest: test", true)
	assert_eq(Audio.history.size(), before, "with the banner up, UiSounds stays quiet (no double sound)")


func test_speaker_voices_follow_their_kind() -> void:
	var mouse: Dictionary = DialogueVoice.for_speaker("mouse", "Pip")
	var bear: Dictionary = DialogueVoice.for_speaker("bear", "Brick")
	var ghost: Dictionary = DialogueVoice.for_speaker("ghost", "Agnes")
	var person: Dictionary = DialogueVoice.for_speaker("", "Tilda Thimble")
	assert_gt(float(mouse["pitch"]), float(person["pitch"]), "small creatures are higher")
	assert_lt(float(bear["pitch"]), float(person["pitch"]), "big ones lower")
	assert_eq(ghost["event"], &"dialogue_airy", "ghosts breathe")
	assert_eq(DialogueVoice.for_speaker("", "Tilda Thimble"), person, "a speaker always sounds the same")
	assert_ne(float(DialogueVoice.for_speaker("", "Marlo")["pitch"]), float(person["pitch"]), "two people differ a little")


func test_the_ui_events_exist() -> void:
	var bank: SfxBank = SfxBank.load_from()
	for event_name: String in ["ui_hover", "ui_click", "ui_back", "ui_tab", "ui_open", "ui_close", "ui_slider", "deck_add", "deck_remove", "deck_sort",
			"shop_buy", "pack_tear", "pack_flip", "pack_reveal_uncommon", "pack_reveal_rare", "pack_reveal_legend", "level_up_layer", "quest_accept",
			"quest_complete", "notify", "game_save", "game_load", "dialogue", "dialogue_airy"]:
		assert_true(bank.is_playable(event_name), event_name)
		assert_true(["UI", "Voice"].has(str(bank.event(event_name)["bus"])), "%s is an interface sound" % event_name)
