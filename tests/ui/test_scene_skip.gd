extends GutTest
## Overnight Oct 30-31 (mid-game critic #8): a story scene seen before can be skipped with Esc - the rest of its boxes are passed over and
## every flag it sets is still set; a first viewing cannot be skipped.

var box: DialogueBox


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	var host: Control = Control.new()
	host.size = Vector2(1920, 1080)
	add_child_autofree(host)
	box = DialogueBox.new()
	host.add_child(box)


func _esc() -> InputEventKey:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = KEY_ESCAPE
	event.pressed = true
	return event


func _scene_with_flags() -> String:
	for id: String in StoryScenes.ids():
		if not StoryScenes.flags_set(id).is_empty() and StoryScenes.steps(id).size() >= 2:
			return id
	return ""


func test_a_seen_scene_skips_with_escape_and_keeps_its_flags() -> void:
	var id: String = _scene_with_flags()
	if id == "":
		pass_test("no multi-box scene with flags in the data")
		return
	Session.set_flag(StoryScenePlayer.seen_flag(id))
	var finished: Array[bool] = [false]
	StoryScenePlayer.play(box, id, func() -> void: finished[0] = true)
	await wait_frames(2)
	assert_true(box.active)
	assert_true(box.skip_callback.is_valid(), "a seen scene offers the skip")
	box._unhandled_input(_esc())
	await wait_frames(2)
	assert_true(finished[0], "Esc ends the whole scene")
	assert_false(box.active)
	for flag: String in StoryScenes.flags_set(id):
		assert_true(Session.flag(StringName(flag)), "%s still set" % flag)


func test_a_first_viewing_cannot_be_skipped() -> void:
	var id: String = _scene_with_flags()
	if id == "":
		pass_test("no multi-box scene with flags in the data")
		return
	StoryScenePlayer.play(box, id)
	await wait_frames(2)
	assert_false(box.skip_callback.is_valid())
	box._unhandled_input(_esc())
	assert_true(box.active, "Esc does nothing on a first viewing")
