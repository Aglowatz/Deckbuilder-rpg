extends Node
## Playtest release smoke (windowed, injected input): title with the version, New Game goes straight to the starting area (no character screen),
## F8 opens the feedback form and writes a report with a screenshot, the pause menu shows the version, and a manual save loads back.
##   Godot --path . res://tools/release_smoke.tscn        (run alone, windowed)

var driver: UiDriver
var _failures: PackedStringArray = []
const TMP: String = "user://release_smoke"


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	Session.save_enabled = false
	SaveSlots.dir = "%s/saves/" % TMP
	FeedbackReport.base = "%s/feedback" % TMP
	FeedbackForm.open_after_send = false
	driver = UiDriver.new(get_tree())
	var version: String = FeedbackReport.version()
	SceneManager.show_loading_screens = false
	# The smoke node must outlive scene changes: it is no longer the current scene.
	get_tree().current_scene = null
	SceneManager.go_to_title()
	await driver.seconds(2.5)
	var title: Node = get_tree().current_scene
	var label: Label = title.find_child("FooterLabel", true, false) as Label
	_check(label != null and label.text.contains(version), "title shows the version (%s)" % (label.text if label != null else "no label"))
	_check(get_tree().current_scene.scene_file_path == "res://scenes/title.tscn", "the game opens at the title screen")
	_check(driver.find_button("New Game") != null, "New Game button exists")
	await driver.click_button("New Game")
	await driver.seconds(3.0)
	var scene: Node = get_tree().current_scene
	_check(scene is StartingAreaScene, "New Game lands in the starting area with no character screen (%s)" % scene.name)
	# feedback form
	await driver.tap_key(KEY_F8)
	await driver.frames(40)
	var form: FeedbackForm = get_tree().root.find_child("FeedbackForm", true, false) as FeedbackForm
	_check(form != null, "F8 opens the feedback form")
	if form != null:
		(form.find_child("Notes", true, false) as TextEdit).text = "release smoke note"
		var path: String = form.submit()
		_check(not path.is_empty() and FileAccess.file_exists("%s/report.json" % path), "report.json written")
		_check(FileAccess.file_exists("%s/screenshot.png" % path), "screenshot.png written")
		_check(FileAccess.file_exists("%s/game.log" % path), "game.log copied (engine file log)")
		form.close()
		await driver.frames(5)
		_check(not get_tree().paused, "closing the form resumes the game")
	# pause menu
	await driver.tap_key(KEY_ESCAPE)
	await driver.frames(40)
	var pause: Node = get_tree().root.find_child("VersionLabel", true, false)
	_check(pause != null and (pause as Label).text.contains(version), "pause menu shows the version")
	_check(driver.find_button("Report a Problem (F8)") != null, "pause menu has Report a Problem")
	_check(driver.find_button("Open feedback folder") != null, "pause menu has Open feedback folder")
	await driver.tap_key(KEY_ESCAPE)
	await driver.frames(30)
	# Oct 20: the Dev Menu (F10) - this smoke runs a debug build, so it exists, opens, pauses, closes (the exported smoke checks it is gone)
	var dev: DevMenu = get_tree().root.find_child("DevMenu", true, false) as DevMenu
	_check(dev != null, "debug build: the Dev Menu is installed")
	await driver.tap_key(KEY_F10)
	await driver.frames(20)
	_check(dev != null and dev.is_open() and get_tree().paused, "F10 opens the Dev Menu and pauses the world")
	await driver.tap_key(KEY_F10)
	await driver.frames(20)
	_check(dev != null and not dev.is_open() and not get_tree().paused, "F10 closes it again")
	# save and load round trip (a slot in a throwaway folder)
	Session.ensure_game()
	var gold: int = Session.gold
	_check(Session.save_to_slot(2, "release smoke"), "manual save to slot 2")
	Session.gold = gold + 777
	_check(Session.load_from_slot(2), "load slot 2")
	_check(Session.gold == gold, "loaded gold is back to %d (got %d)" % [gold, Session.gold])
	_finish()


func _check(ok: bool, what: String) -> void:
	if ok:
		print("release_smoke: ok    %s" % what)
	else:
		_failures.append(what)
		print("release_smoke: FAIL  %s" % what)
		push_error("release_smoke: %s" % what)


func _finish() -> void:
	var abs_dir: String = ProjectSettings.globalize_path(TMP)
	if DirAccess.dir_exists_absolute(abs_dir):
		OS.move_to_trash(abs_dir)
	if _failures.is_empty():
		print("release_smoke: PASSED")
		get_tree().quit(0)
	else:
		print("release_smoke: FAILED - %d checks" % _failures.size())
		get_tree().quit(1)
