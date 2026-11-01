extends GutTest
## Overnight Oct 30-31 (mid-game critic #8): a story scene seen before can be skipped with Esc - the rest of its boxes are passed over and
## every flag it sets is still set. Overnight Oct 31 - Nov 1 (answer 9): a first viewing asks first.

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


func test_a_first_viewing_asks_before_skipping() -> void:
	var id: String = _scene_with_flags()
	if id == "":
		pass_test("no multi-box scene with flags in the data")
		return
	var finished: Array[bool] = [false]
	StoryScenePlayer.play(box, id, func() -> void: finished[0] = true)
	await wait_frames(2)
	assert_true(box.skip_callback.is_valid(), "Esc is offered on a first viewing too (answer 9)")
	assert_true(box.skip_needs_confirm)
	box._unhandled_input(_esc())
	await wait_frames(2)
	assert_true(box.active, "Esc only asks on a first viewing")
	assert_true(is_instance_valid(box._skip_confirm), "the confirm is up")
	box._skip_confirm.confirmed.emit()
	await wait_frames(2)
	assert_true(finished[0], "confirming skips the whole scene")
	for flag: String in StoryScenes.flags_set(id):
		assert_true(Session.flag(StringName(flag)), "%s still set" % flag)


func test_keep_watching_leaves_the_scene_playing() -> void:
	var id: String = _scene_with_flags()
	if id == "":
		pass_test("no multi-box scene with flags in the data")
		return
	StoryScenePlayer.play(box, id)
	await wait_frames(2)
	box._unhandled_input(_esc())
	await wait_frames(1)
	box._skip_confirm.cancelled.emit()
	box._skip_confirm.queue_free()
	await wait_frames(2)
	assert_true(box.active, "the scene keeps playing")
	assert_true(box.skip_callback.is_valid(), "Esc still offered")


func test_the_cutscene_screen_confirms_a_first_viewing() -> void:
	var source: String = FileAccess.get_file_as_string("res://ui/dungeon/cutscene_screen.gd")
	assert_true(source.contains("You haven't seen it."), "the confirm text")
	assert_true(source.contains("_first_view = not Session.flag"), "first viewings are told apart from seen ones")
