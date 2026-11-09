extends GutTest
## The title screen (Part C of the art integration round): the key art, the wordmark and the sunrise version after the final boss; the app icon files.


func before_each() -> void:
	Session.save_enabled = false


func _title(args: Dictionary) -> TitleScreen:
	var title: TitleScreen = TitleScreen.new()
	title.screenshot_prepare(args)
	add_child_autofree(title)
	return title


func test_the_title_shows_the_day_art_and_the_wordmark() -> void:
	var title: TitleScreen = _title({"postgame": "false"})
	await wait_frames(2)
	var art: TextureRect = title.find_child("KeyArt", true, false) as TextureRect
	assert_not_null(art)
	assert_eq(art.texture, KeyArt.texture("TITLE-KEYART"))
	var wordmark: TextureRect = title.find_child("Wordmark", true, false) as TextureRect
	assert_not_null(wordmark)
	assert_eq(wordmark.texture, KeyArt.texture("LOGO-WORDMARK"))
	assert_not_null(title.find_child("LightShimmer", true, false))


func test_after_the_final_boss_the_title_switches_to_the_sunrise_art() -> void:
	var title: TitleScreen = _title({"postgame": "true"})
	await wait_frames(2)
	var art: TextureRect = title.find_child("KeyArt", true, false) as TextureRect
	assert_eq(art.texture, KeyArt.texture("TITLE-KEYART-NIGHT"))


func test_a_save_slot_reports_the_postgame_flag() -> void:
	var saved_dir: String = SaveSlots.dir
	SaveSlots.dir = "user://test_title_saves/"
	DirAccess.make_dir_recursive_absolute(SaveSlots.dir)
	SaveSlots.write(1, {"save_format": Session.SAVE_FORMAT, "postgame": true}, null)
	assert_true(bool(SaveSlots.info(1).get("postgame", false)))
	SaveSlots.write(2, {"save_format": Session.SAVE_FORMAT, "postgame": false}, null)
	assert_false(bool(SaveSlots.info(2).get("postgame", true)))
	SaveSlots.delete(1)
	SaveSlots.delete(2)
	SaveSlots.dir = saved_dir


## Fable Nov 9 (the exported-build check): with the keyboard, the first Enter or arrow at the title focuses the top menu button (the pad and the
## mouse are unaffected); once a menu button has the focus the key is left to it.
func test_the_first_keyboard_press_focuses_the_title_menu() -> void:
	var title: TitleScreen = _title({"postgame": "false"})
	await wait_frames(2)
	var accept: InputEventAction = InputEventAction.new()
	accept.action = &"ui_accept"
	accept.pressed = true
	assert_false(title.keyboard_focus_menu(accept), "an action event is not a keyboard key")
	var enter: InputEventKey = InputEventKey.new()
	enter.keycode = KEY_ENTER
	enter.pressed = true
	assert_true(title.keyboard_focus_menu(enter), "the first Enter takes the focus")
	var owner_now: Control = title.get_viewport().gui_get_focus_owner()
	assert_not_null(owner_now)
	assert_true(owner_now is BaseButton and title.is_ancestor_of(owner_now), "a title menu button has the focus")
	assert_false(title.keyboard_focus_menu(enter), "the next Enter is left to the focused button")

