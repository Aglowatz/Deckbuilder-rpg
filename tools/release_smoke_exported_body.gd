extends Node
## The body of the exported-pack release smoke (loaded by tools/release_smoke_exported.gd once the autoloads exist). Same checks as
## tools/release_smoke.gd; UiDriver's input helpers are inlined because the export leaves tools/ out.

const TMP: String = "user://release_smoke_exported"

var _failures: PackedStringArray = []
var _mouse: Vector2 = Vector2(960, 540)


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	await get_tree().process_frame
	var session: Node = get_tree().root.get_node("Session")
	session.set("save_enabled", false)
	SaveSlots.dir = "%s/saves/" % TMP
	FeedbackReport.base = "%s/feedback" % TMP
	FeedbackForm.open_after_send = false
	var version: String = FeedbackReport.version()
	print("release_smoke_exported: pack version %s" % version)
	var scene_manager: Node = get_tree().root.get_node("SceneManager")
	scene_manager.set("show_loading_screens", false)
	scene_manager.call("go_to_title")
	await _seconds(2.5)
	var title: Node = get_tree().current_scene
	var label: Label = title.find_child("FooterLabel", true, false) as Label if title != null else null
	_check(label != null and label.text.contains(version), "title shows the version (%s)" % (label.text if label != null else "no label"))
	_check(title != null and title.scene_file_path == "res://scenes/title.tscn", "the game opens at the title screen")
	_check(_find_button("New Game") != null, "New Game button exists")
	await _click_button("New Game")
	if _find_button("Start Over") != null:
		await _click_button("Start Over")
	await _seconds(3.0)
	_check(get_tree().current_scene is StartingAreaScene, "New Game lands in the starting area (%s)" % (get_tree().current_scene.name if get_tree().current_scene != null else "none"))
	await _tap_key(KEY_F8)
	await _frames(40)
	var form: FeedbackForm = get_tree().root.find_child("FeedbackForm", true, false) as FeedbackForm
	_check(form != null, "F8 opens the feedback form")
	if form != null:
		(form.find_child("Notes", true, false) as TextEdit).text = "release smoke (exported) note"
		var path: String = form.submit()
		_check(not path.is_empty() and FileAccess.file_exists("%s/report.json" % path), "report.json written")
		_check(FileAccess.file_exists("%s/screenshot.png" % path), "screenshot.png written")
		_check(FileAccess.file_exists("%s/game.log" % path), "game.log copied (engine file log)")
		form.close()
		await _frames(5)
		_check(not get_tree().paused, "closing the form resumes the game")
	await _tap_key(KEY_ESCAPE)
	await _frames(40)
	var pause: Node = get_tree().root.find_child("VersionLabel", true, false)
	_check(pause != null and (pause as Label).text.contains(version), "pause menu shows the version")
	_check(_find_button("Report a Problem (F8)") != null, "pause menu has Report a Problem")
	_check(_find_button("Open feedback folder") != null, "pause menu has Open feedback folder")
	await _tap_key(KEY_ESCAPE)
	await _frames(30)
	session.call("ensure_game")
	var gold: int = int(session.get("gold"))
	_check(bool(session.call("save_to_slot", 2, "release smoke")), "manual save to slot 2")
	session.set("gold", gold + 777)
	_check(bool(session.call("load_from_slot", 2)), "load slot 2")
	_check(int(session.get("gold")) == gold, "loaded gold is back to %d (got %d)" % [gold, int(session.get("gold"))])
	var abs_dir: String = ProjectSettings.globalize_path(TMP)
	if DirAccess.dir_exists_absolute(abs_dir):
		OS.move_to_trash(abs_dir)
	if _failures.is_empty():
		print("release_smoke_exported: PASSED (%s)" % version)
		get_tree().quit(0)
	else:
		print("release_smoke_exported: FAILED - %d checks" % _failures.size())
		get_tree().quit(1)


func _check(ok: bool, what: String) -> void:
	if ok:
		print("release_smoke_exported: ok    %s" % what)
	else:
		_failures.append(what)
		print("release_smoke_exported: FAIL  %s" % what)


# ---- Input, as UiDriver does it -------------------------------------------------------------------


func _frames(count: int) -> void:
	for _i: int in range(count):
		await get_tree().process_frame


func _seconds(duration: float) -> void:
	await get_tree().create_timer(duration, false).timeout


func _win(pos: Vector2) -> Vector2:
	return get_tree().root.get_final_transform() * pos


func _mouse_event(pos: Vector2, pressed_now: bool) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.position = _win(pos)
	event.global_position = _win(pos)
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed_now
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed_now else 0
	Input.parse_input_event(event)
	await get_tree().process_frame


func _click(pos: Vector2) -> void:
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = _win(pos)
	motion.global_position = _win(pos)
	motion.relative = _win(pos) - _win(_mouse)
	_mouse = pos
	Input.parse_input_event(motion)
	await get_tree().process_frame
	await _mouse_event(pos, true)
	await _mouse_event(pos, false)


func _tap_key(keycode: Key) -> void:
	for down: bool in [true, false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = keycode
		event.physical_keycode = keycode
		event.pressed = down
		Input.parse_input_event(event)
		await get_tree().process_frame


func _find_button(text: String) -> Button:
	for node: Node in get_tree().root.find_children("*", "Button", true, false):
		var button: Button = node as Button
		if button.is_visible_in_tree() and not button.disabled and button.text.contains(text):
			return button
	return null


func _click_button(text: String) -> bool:
	var button: Button = _find_button(text)
	if button == null:
		return false
	await _click(button.get_global_rect().get_center())
	return true
