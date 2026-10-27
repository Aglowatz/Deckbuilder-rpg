extends GutTest
## Settings and accessibility: persistence of every option, key rebinding, text and speed scales, reduced shake and flashing, the UI scale pivots, audio buses and the
## mute-when-unfocused rule, Path symbols on cards, and that every settings page builds.

const TEMP_PATH: String = "user://test_settings.cfg"

var _saved: Dictionary = {}


func before_each() -> void:
	_saved = {
		"master": Settings.master_volume, "music": Settings.music_volume, "sfx": Settings.sfx_volume, "ui": Settings.ui_volume, "mute": Settings.mute_unfocused,
		"mode": Settings.window_mode, "vsync": Settings.vsync, "fps": Settings.max_fps, "scale": Settings.ui_scale, "cards": Settings.text_cards,
		"dialogue": Settings.text_dialogue, "tooltips": Settings.text_tooltips, "speed": Settings.dialogue_speed, "cb": Settings.colorblind_symbols,
		"shake": Settings.reduce_shake, "flash": Settings.reduce_flashing,
	}
	Keybinds.reset_all()


func after_each() -> void:
	Settings.master_volume = _saved["master"]
	Settings.music_volume = _saved["music"]
	Settings.sfx_volume = _saved["sfx"]
	Settings.ui_volume = _saved["ui"]
	Settings.mute_unfocused = _saved["mute"]
	Settings.window_mode = _saved["mode"]
	Settings.vsync = _saved["vsync"]
	Settings.max_fps = _saved["fps"]
	Settings.ui_scale = _saved["scale"]
	Settings.text_cards = _saved["cards"]
	Settings.text_dialogue = _saved["dialogue"]
	Settings.text_tooltips = _saved["tooltips"]
	Settings.dialogue_speed = _saved["speed"]
	Settings.colorblind_symbols = _saved["cb"]
	Settings.reduce_shake = _saved["shake"]
	Settings.reduce_flashing = _saved["flash"]
	Settings.set_focused(true)
	Settings.apply_audio()
	Settings.apply_performance()
	Keybinds.reset_all()
	if FileAccess.file_exists(TEMP_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_PATH))


# ---- Persistence ----------------------------------------------------------------------------


func test_every_option_survives_a_save_and_load() -> void:
	Settings.master_volume = 0.35
	Settings.music_volume = 0.15
	Settings.sfx_volume = 0.55
	Settings.ui_volume = 0.25
	Settings.mute_unfocused = true
	Settings.window_mode = Settings.WindowMode.BORDERLESS
	Settings.vsync = false
	Settings.max_fps = 90
	Settings.ui_scale = 1.25
	Settings.text_cards = 3
	Settings.text_dialogue = 2
	Settings.text_tooltips = 0
	Settings.dialogue_speed = 3
	Settings.colorblind_symbols = true
	Settings.reduce_shake = true
	Settings.reduce_flashing = true
	Settings.save_settings(TEMP_PATH)
	Settings.master_volume = 0.8
	Settings.mute_unfocused = false
	Settings.window_mode = Settings.WindowMode.WINDOWED
	Settings.vsync = true
	Settings.max_fps = 0
	Settings.ui_scale = 1.0
	Settings.text_cards = 1
	Settings.dialogue_speed = 1
	Settings.colorblind_symbols = false
	Settings.reduce_shake = false
	Settings.reduce_flashing = false
	Settings.load_settings(TEMP_PATH)
	assert_almost_eq(Settings.master_volume, 0.35, 0.001)
	assert_almost_eq(Settings.music_volume, 0.15, 0.001)
	assert_almost_eq(Settings.sfx_volume, 0.55, 0.001)
	assert_almost_eq(Settings.ui_volume, 0.25, 0.001)
	assert_true(Settings.mute_unfocused)
	assert_eq(Settings.window_mode, Settings.WindowMode.BORDERLESS)
	assert_false(Settings.vsync)
	assert_eq(Settings.max_fps, 90)
	assert_almost_eq(Settings.ui_scale, 1.25, 0.001)
	assert_eq(Settings.text_cards, 3)
	assert_eq(Settings.text_dialogue, 2)
	assert_eq(Settings.text_tooltips, 0)
	assert_eq(Settings.dialogue_speed, 3)
	assert_true(Settings.colorblind_symbols)
	assert_true(Settings.reduce_shake)
	assert_true(Settings.reduce_flashing)


func test_an_old_fullscreen_setting_still_loads() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("video", "fullscreen", true)
	config.save(TEMP_PATH)
	Settings.load_settings(TEMP_PATH)
	assert_eq(Settings.window_mode, Settings.WindowMode.FULLSCREEN)
	assert_true(Settings.fullscreen)


func test_loaded_values_are_clamped() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("video", "ui_scale", 9.0)
	config.set_value("text", "cards", 99)
	config.set_value("text", "dialogue_speed", -4)
	config.save(TEMP_PATH)
	Settings.load_settings(TEMP_PATH)
	assert_almost_eq(Settings.ui_scale, Settings.UI_SCALE_MAX, 0.001)
	assert_eq(Settings.text_cards, Settings.TEXT_SCALES.size() - 1)
	assert_eq(Settings.dialogue_speed, 0)


func test_the_ui_scale_stays_between_90_and_150_percent() -> void:
	Settings.set_ui_scale(0.2)
	assert_almost_eq(Settings.ui_scale, 0.9, 0.001)
	Settings.set_ui_scale(3.0)
	assert_almost_eq(Settings.ui_scale, 1.5, 0.001)
	Settings.set_ui_scale(1.17)
	assert_almost_eq(Settings.ui_scale, 1.15, 0.001, "steps of 5 percent")


func test_changing_the_ui_scale_tells_the_screens() -> void:
	watch_signals(Settings)
	Settings.set_ui_scale(1.3)
	assert_signal_emitted(Settings, "ui_scale_changed")


# ---- Text, speed, shake, flashing ------------------------------------------------------------


func test_text_scales_follow_the_options() -> void:
	Settings.text_cards = 0
	assert_almost_eq(Settings.card_text_scale(), 0.85, 0.001)
	Settings.text_dialogue = 3
	assert_almost_eq(Settings.dialogue_text_scale(), 1.4, 0.001)
	Settings.text_tooltips = 2
	assert_eq(Settings.tooltip_font(20), 24)


func test_dialogue_speed_has_an_instant_choice() -> void:
	Settings.dialogue_speed = 3
	assert_eq(Settings.dialogue_chars_per_second(), 0.0)
	assert_eq(Settings.typewriter_time(2.0), 0.0, "instant means no typing time")
	Settings.dialogue_speed = 1
	assert_almost_eq(Settings.typewriter_time(2.0), 2.0, 0.001, "Normal keeps the written time")
	Settings.dialogue_speed = 0
	assert_gt(Settings.typewriter_time(2.0), 2.0, "Slow takes longer")
	Settings.dialogue_speed = 2
	assert_lt(Settings.typewriter_time(2.0), 2.0, "Fast takes less")


func test_reduced_shake_and_flashing() -> void:
	Settings.reduce_shake = false
	Settings.reduce_flashing = false
	assert_eq(Settings.shake_scale(), 1.0)
	assert_eq(Settings.flash_scale(), 1.0)
	Settings.reduce_shake = true
	Settings.reduce_flashing = true
	assert_eq(Settings.shake_scale(), 0.0)
	assert_lt(Settings.flash_scale(), 0.5)


func test_battle_shake_does_nothing_when_reduced() -> void:
	var fx: BattleFX = BattleFX.new()
	add_child_autofree(fx)
	var target: Control = Control.new()
	add_child_autofree(target)
	fx.shake_target = target
	Settings.reduce_shake = true
	fx.shake(20.0, 0.2)
	assert_eq(target.position, Vector2.ZERO)


# ---- Key bindings ----------------------------------------------------------------------------


func test_default_keys_match_the_old_hard_coded_ones() -> void:
	assert_eq(Keybinds.keys_of(&"open_map"), [KEY_M, 0] as Array[int])
	assert_eq(Keybinds.keys_of(&"open_deck"), [KEY_B, 0] as Array[int])
	assert_eq(Keybinds.keys_of(&"interact"), [KEY_E, KEY_SPACE] as Array[int])
	assert_eq(Keybinds.keys_of(&"move_up"), [KEY_W, KEY_UP] as Array[int])
	assert_eq(Keybinds.keys_of(&"battle_advance"), [KEY_SPACE, 0] as Array[int])
	assert_true(Keybinds.all_default())


func test_every_action_is_in_the_input_map() -> void:
	for action: StringName in Keybinds.action_ids():
		assert_true(InputMap.has_action(action), str(action))
	assert_true(InputMap.has_action(&"pause"))


func test_a_rebind_applies_at_once() -> void:
	Keybinds.rebind(&"open_map", 0, KEY_N)
	var press: InputEventKey = InputEventKey.new()
	press.physical_keycode = KEY_N
	press.pressed = true
	assert_true(press.is_action_pressed(&"open_map"), "N opens the map now")
	var old: InputEventKey = InputEventKey.new()
	old.physical_keycode = KEY_M
	old.pressed = true
	assert_false(old.is_action_pressed(&"open_map"), "M no longer does")
	assert_false(Keybinds.all_default())


func test_a_taken_key_moves_within_its_group() -> void:
	var displaced: String = Keybinds.rebind(&"open_map", 0, KEY_B)
	assert_eq(displaced, "Deck builder")
	assert_eq(Keybinds.keys_of(&"open_deck")[0], 0, "the deck builder lost B")
	assert_eq(Keybinds.keys_of(&"open_map")[0], KEY_B)


func test_the_same_key_may_serve_the_overworld_and_the_battle() -> void:
	assert_eq(Keybinds.keys_of(&"interact")[1], KEY_SPACE)
	assert_eq(Keybinds.keys_of(&"battle_advance")[0], KEY_SPACE)
	Keybinds.rebind(&"battle_end_turn", 0, KEY_SPACE)
	assert_eq(Keybinds.keys_of(&"battle_advance")[0], 0, "within the battle group Space moved")
	assert_eq(Keybinds.keys_of(&"interact")[1], KEY_SPACE, "the overworld keeps Space")


func test_reserved_keys_are_refused() -> void:
	assert_eq(Keybinds.rebind(&"open_map", 0, KEY_ESCAPE), "reserved")
	assert_eq(Keybinds.keys_of(&"open_map")[0], KEY_M)


func test_a_slot_can_be_cleared_and_reset() -> void:
	Keybinds.rebind(&"interact", 1, 0)
	assert_eq(Keybinds.keys_of(&"interact")[1], 0)
	Keybinds.reset_action(&"interact")
	assert_eq(Keybinds.keys_of(&"interact")[1], KEY_SPACE)
	Keybinds.rebind(&"open_map", 0, KEY_N)
	Keybinds.reset_all()
	assert_true(Keybinds.all_default())


func test_key_bindings_persist() -> void:
	Keybinds.rebind(&"open_quests", 0, KEY_K)
	Keybinds.rebind(&"move_up", 1, 0)
	Settings.save_settings(TEMP_PATH)
	Keybinds.reset_all()
	assert_true(Keybinds.all_default())
	Settings.load_settings(TEMP_PATH)
	assert_eq(Keybinds.keys_of(&"open_quests")[0], KEY_K)
	assert_eq(Keybinds.keys_of(&"move_up")[1], 0)
	assert_eq(Keybinds.keys_of(&"open_map")[0], KEY_M, "untouched keys stay at their default")


func test_key_text_and_hints() -> void:
	assert_eq(Keybinds.first_key(&"open_map"), "M")
	assert_eq(Keybinds.hint(&"interact"), "E / Space")
	Keybinds.rebind(&"open_map", 0, 0)
	assert_eq(Keybinds.hint(&"open_map"), "unbound")


func test_settings_screen_captures_a_key() -> void:
	var panel: SettingsPanel = SettingsPanel.new()
	panel.autosave = false
	add_child_autofree(panel)
	panel.show_page(3)
	await get_tree().process_frame
	var button: Button = panel.find_child("Slot0", true, false) as Button
	assert_not_null(button)
	button.pressed.emit()
	assert_eq(button.text, "Press a key...")
	panel.capture_key(KEY_Y)
	assert_eq(Keybinds.keys_of(&"move_up")[0], KEY_Y, "the first row is Move up")


# ---- UI scale --------------------------------------------------------------------------------


func test_panels_scale_around_their_screen_edge() -> void:
	var view: Vector2 = Vector2(1920, 1080)
	var top_left: Vector2 = UiScale.pivot_for(Vector2(200, 100), Vector2(300, 100), view)
	assert_eq(top_left, Vector2.ZERO)
	var bottom_right: Vector2 = UiScale.pivot_for(Vector2(1750, 950), Vector2(300, 100), view)
	assert_eq(bottom_right, Vector2(300, 100))
	var top_middle: Vector2 = UiScale.pivot_for(Vector2(960, 80), Vector2(400, 60), view)
	assert_eq(top_middle, Vector2(200, 0))


func test_a_fitted_screen_covers_the_viewport_at_any_scale() -> void:
	var screen: Control = Control.new()
	add_child_autofree(screen)
	UiScale.fit(screen)
	Settings.set_ui_scale(1.5)
	var view: Vector2 = screen.get_viewport().get_visible_rect().size
	assert_almost_eq(screen.size.x * screen.scale.x, view.x, 1.0)
	assert_almost_eq(screen.size.y * screen.scale.y, view.y, 1.0)
	Settings.set_ui_scale(0.9)
	assert_almost_eq(screen.size.x * screen.scale.x, view.x, 1.0)


# ---- Audio -----------------------------------------------------------------------------------


func test_four_volume_buses_exist() -> void:
	for bus: StringName in [&"Master", Settings.BUS_MUSIC, Settings.BUS_SFX, Settings.BUS_UI]:
		assert_gte(AudioServer.get_bus_index(bus), 0, str(bus))


func test_each_volume_sets_its_own_bus() -> void:
	Settings.master_volume = 1.0
	Settings.music_volume = 0.5
	Settings.sfx_volume = 0.25
	Settings.ui_volume = 0.1
	Settings.apply_audio()
	assert_almost_eq(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(Settings.BUS_MUSIC)), -20.0, 0.01, "the dB taper: half way is -20 dB")
	assert_almost_eq(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(Settings.BUS_SFX)), -30.0, 0.01)
	assert_almost_eq(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(Settings.BUS_UI)), -36.0, 0.01)


func test_the_game_mutes_when_unfocused_only_if_asked() -> void:
	var master: int = AudioServer.get_bus_index(&"Master")
	Settings.master_volume = 0.8
	Settings.mute_unfocused = false
	Settings.set_focused(false)
	assert_false(AudioServer.is_bus_mute(master), "off: losing focus changes nothing")
	Settings.mute_unfocused = true
	Settings.set_focused(false)
	assert_true(AudioServer.is_bus_mute(master), "on: silent while unfocused")
	assert_true(Settings.is_muted_by_focus())
	Settings.set_focused(true)
	assert_false(AudioServer.is_bus_mute(master), "sound is back with the focus")


# ---- Path symbols ----------------------------------------------------------------------------


func test_path_symbols_appear_only_with_the_colour_blind_option() -> void:
	var card: CardData = load("res://data/cards/B-03.tres") as CardData
	Settings.colorblind_symbols = false
	var plain: CardView = CardView.create(card, CardView.Mode.FULL)
	add_child_autofree(plain)
	assert_eq(_symbols_on(plain), 0)
	Settings.colorblind_symbols = true
	var marked: CardView = CardView.create(card, CardView.Mode.FULL)
	add_child_autofree(marked)
	assert_eq(_symbols_on(marked), card.paths().size())
	var neutral: CardData = load("res://data/cards/C-01.tres") as CardData
	var colourless: CardView = CardView.create(neutral, CardView.Mode.FULL)
	add_child_autofree(colourless)
	assert_eq(_symbols_on(colourless), 0, "a colourless card has no Path to show")


func test_a_card_redraws_when_the_option_changes() -> void:
	var card: CardData = load("res://data/cards/B-03.tres") as CardData
	Settings.colorblind_symbols = false
	var view: CardView = CardView.create(card, CardView.Mode.FULL)
	add_child_autofree(view)
	assert_eq(_symbols_on(view), 0)
	Settings.colorblind_symbols = true
	Settings.accessibility_changed.emit()
	await get_tree().process_frame
	assert_gt(_symbols_on(view), 0)


func _symbols_on(view: CardView) -> int:
	var count: int = 0
	for child: Node in view.get_children():
		var rect: TextureRect = child as TextureRect
		if rect != null and rect.tooltip_text.ends_with(" Path"):
			count += 1
	return count


# ---- Card text -------------------------------------------------------------------------------


func test_bigger_card_text_raises_the_font_ceiling() -> void:
	var card: CardData = load("res://data/cards/B-03.tres") as CardData
	var view: CardView = CardView.create(card, CardView.Mode.FULL)
	add_child_autofree(view)
	Settings.text_cards = 1
	var normal: int = view._max_rules_font()
	Settings.text_cards = 3
	assert_gt(view._max_rules_font(), normal)
	Settings.text_cards = 0
	assert_lt(view._max_rules_font(), normal)


# ---- The settings screen ---------------------------------------------------------------------


func test_every_settings_page_builds() -> void:
	var panel: SettingsPanel = SettingsPanel.new()
	panel.autosave = false
	add_child_autofree(panel)
	for page: int in range(SettingsPanel.PAGES.size()):
		panel.show_page(page)
		await get_tree().process_frame
		assert_gt(panel.find_children("*", "Control", true, false).size(), 10, SettingsPanel.PAGES[page])


func test_dialogue_speed_option_is_offered_with_instant() -> void:
	var panel: SettingsPanel = SettingsPanel.new()
	panel.autosave = false
	add_child_autofree(panel)
	panel.show_page(1)
	await get_tree().process_frame
	var speed: OptionButton = panel.find_child("DialogueSpeedOptions", true, false) as OptionButton
	assert_not_null(speed)
	assert_eq(speed.item_count, 4)
	assert_eq(speed.get_item_text(3), "Instant")


func test_battle_options_survive_a_save_and_load() -> void:
	assert_eq(Settings.BATTLE_SPEEDS, [1.0, 1.5, 2.0] as Array[float], "1x / 1.5x / 2x")
	Settings.battle_speed = 2
	Settings.confirm_end_turn = false
	Settings.auto_end_turn = true
	Settings.save_settings(TEMP_PATH)
	Settings.battle_speed = 0
	Settings.confirm_end_turn = true
	Settings.auto_end_turn = false
	Settings.load_settings(TEMP_PATH)
	assert_eq(Settings.battle_speed, 2)
	assert_false(Settings.confirm_end_turn)
	assert_true(Settings.auto_end_turn)
	assert_almost_eq(Settings.battle_speed_scale(), 2.0, 0.001)
	Settings.battle_speed = 0
	Settings.confirm_end_turn = true
	Settings.auto_end_turn = false
