extends GutTest
## Overnight Nov 9-10 (Part 4.3): rebinding never leaves moving, Interact or Pause without a key, the pause menu keeps Escape, and the
## bindings survive a save and load.

const TEMP_PATH: String = "user://test_keybind_essentials_nov10.cfg"


func before_each() -> void:
	Keybinds.reset_all()


func after_all() -> void:
	Keybinds.reset_all()
	if FileAccess.file_exists(TEMP_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_PATH))


func test_the_last_key_of_an_essential_action_cannot_be_cleared() -> void:
	assert_eq(Keybinds.rebind(&"interact", 1, 0), "", "clearing Space is fine while E stays")
	assert_eq(Keybinds.rebind(&"interact", 0, 0), "essential", "clearing E as well is refused")
	assert_eq(Keybinds.keys_of(&"interact")[0], KEY_E)


func test_taking_the_last_key_of_an_essential_action_is_refused() -> void:
	Keybinds.rebind(&"move_up", 1, 0)
	assert_eq(Keybinds.rebind(&"open_map", 0, KEY_W), "essential", "W is Move up's only key now")
	assert_eq(Keybinds.keys_of(&"move_up")[0], KEY_W)
	assert_eq(Keybinds.keys_of(&"open_map")[0], KEY_M, "nothing changed")
	assert_eq(Keybinds.rebind(&"open_map", 0, KEY_S), "Move down", "Move down still has Down, so S may move")


func test_pause_keeps_escape() -> void:
	assert_eq(Keybinds.rebind(&"pause", 0, KEY_P), "fixed")
	assert_eq(Keybinds.keys_of(&"pause")[0], KEY_ESCAPE)
	assert_eq(Keybinds.rebind(&"pause", 1, KEY_BACKSPACE), "", "the second slot is free to use")


func test_every_essential_action_has_a_key_by_default() -> void:
	for action: StringName in Keybinds.ESSENTIAL:
		var any: bool = false
		for key: int in Keybinds.keys_of(action):
			any = any or key != 0
		assert_true(any, "%s has a key" % action)


func test_rebinds_are_saved_and_loaded() -> void:
	Keybinds.rebind(&"interact", 0, KEY_F)
	Keybinds.rebind(&"open_quests", 1, KEY_K)
	Settings.save_settings(TEMP_PATH)
	Keybinds.reset_all()
	Settings.load_settings(TEMP_PATH)
	assert_eq(Keybinds.keys_of(&"interact")[0], KEY_F)
	assert_eq(Keybinds.keys_of(&"open_quests")[1], KEY_K)
	var press: InputEventKey = InputEventKey.new()
	press.physical_keycode = KEY_F
	press.pressed = true
	assert_true(press.is_action_pressed(&"interact"), "the InputMap follows the loaded binding")
