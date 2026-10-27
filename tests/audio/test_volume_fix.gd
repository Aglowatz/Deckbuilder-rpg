extends GutTest
## Fixes Oct 26, Part 3 ("the volume is not working", docs/audio/volume_fix_oct26.md): every slider changes its bus by an audible amount and a
## player on that bus hears it, saved values apply at startup (old files keep their loudness), and nothing stays ducked or muted after menus and
## dialogue. The cause was the slider curve (raw amplitude: one 5% step near the defaults was ~0.5 dB), not the routing.

const TEMP_PATH: String = "user://test_volume_fix.cfg"
const SLIDERS: Dictionary = {
	"MasterSlider": ["master_volume", &"Master"], "MusicSlider": ["music_volume", &"Music"], "SfxSlider": ["sfx_volume", &"SFX"],
	"UiSlider": ["ui_volume", &"UI"], "AmbienceSlider": ["ambience_volume", &"Ambience"], "VoiceSlider": ["voice_volume", &"Voice"],
}
## The bus a player of each slider's sounds plays on (Battle and World sit under SFX).
const PLAYER_BUS: Dictionary = {"MasterSlider": &"Music", "MusicSlider": &"Music", "SfxSlider": &"Battle", "UiSlider": &"UI", "AmbienceSlider": &"Ambience", "VoiceSlider": &"Voice"}

var _saved: Dictionary = {}


func before_each() -> void:
	for entry: Variant in SLIDERS.values():
		var key: String = str((entry as Array)[0])
		_saved[key] = Settings.get(key)
	_saved["mute_unfocused"] = Settings.mute_unfocused


func after_each() -> void:
	for key: String in _saved.keys():
		Settings.set(key, _saved[key])
	Settings.set_focused(true)
	Settings.apply_audio()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_PATH))


## What a player on `bus` hears relative to its own output, in dB: every bus volume on the way to the speakers (-INF when one is muted).
func _heard_db(bus: StringName) -> float:
	var total: float = 0.0
	var index: int = AudioServer.get_bus_index(bus)
	while index >= 0:
		if AudioServer.is_bus_mute(index):
			return -INF
		total += AudioServer.get_bus_volume_db(index)
		if index == 0:
			break
		index = AudioServer.get_bus_index(AudioServer.get_bus_send(index))
	return total


func _panel() -> SettingsPanel:
	var panel: SettingsPanel = SettingsPanel.new()
	panel.autosave = false
	add_child_autofree(panel)
	panel.show_page(4)
	return panel


func test_the_taper_steps_are_audible() -> void:
	assert_almost_eq(Settings.volume_db(1.0), 0.0, 0.001)
	assert_almost_eq(Settings.volume_db(0.5), -20.0, 0.001, "half way is a quarter as loud, not -6 dB")
	assert_almost_eq(Settings.volume_db(0.95) - Settings.volume_db(0.9), 2.0, 0.001, "a 5% step near the defaults is 2 dB (was ~0.5)")
	assert_eq(Settings.volume_db(0.0), -80.0, "the bottom is silence")
	var previous: float = 1.0
	for i: int in range(19, 0, -1):
		var db: float = Settings.volume_db(float(i) * 0.05)
		assert_lt(db, previous, "each step down is quieter")
		previous = db


func test_every_slider_changes_its_bus_and_what_a_player_on_it_hears() -> void:
	var panel: SettingsPanel = _panel()
	await wait_frames(2)
	for slider_name: String in SLIDERS.keys():
		var entry: Array = SLIDERS[slider_name] as Array
		var slider: HSlider = panel.find_child(slider_name, true, false) as HSlider
		assert_not_null(slider, slider_name)
		if slider == null:
			continue
		var bus: StringName = entry[1] as StringName
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = PLAYER_BUS[slider_name] as StringName
		add_child_autofree(player)
		slider.value = 0.9
		var loud: float = _heard_db(player.bus)
		assert_almost_eq(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus)), -4.0, 0.01, "%s sets %s" % [slider_name, bus])
		assert_almost_eq(float(Settings.get(str(entry[0]))), 0.9, 0.001)
		slider.value = 0.85
		assert_almost_eq(loud - _heard_db(player.bus), 2.0, 0.01, "%s: one step down is 2 dB quieter at a player on %s" % [slider_name, player.bus])
		slider.value = 0.0
		assert_eq(_heard_db(player.bus), -INF, "%s at 0: silent" % slider_name)
		slider.value = 0.9
		assert_almost_eq(_heard_db(player.bus), loud, 0.01, "%s back: as loud as before" % slider_name)


func test_saved_values_apply_at_startup() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("meta", "version", Settings.SETTINGS_VERSION)
	config.set_value("audio", "master", 0.7)
	config.set_value("audio", "music", 0.4)
	config.set_value("audio", "sfx", 0.55)
	config.save(TEMP_PATH)
	Settings.load_settings(TEMP_PATH)
	Settings.apply_audio()
	assert_almost_eq(Settings.master_volume, 0.7, 0.001)
	assert_almost_eq(AudioServer.get_bus_volume_db(0), -12.0, 0.01)
	assert_almost_eq(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Music")), -24.0, 0.01)
	assert_almost_eq(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"SFX")), -18.0, 0.01)


func test_an_old_settings_file_keeps_its_loudness() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("meta", "version", 2)
	config.set_value("audio", "master", 0.8)
	config.set_value("audio", "music", 0.6)
	config.set_value("audio", "sfx", 0.3)
	config.set_value("audio", "ui", 0.0)
	config.save(TEMP_PATH)
	Settings.load_settings(TEMP_PATH)
	assert_almost_eq(Settings.master_volume, 0.95, 0.001, "old 0.8 (-1.9 dB) -> 0.95 (-2 dB)")
	assert_almost_eq(Settings.music_volume, 0.9, 0.001, "old 0.6 (-4.4 dB) -> 0.9 (-4 dB)")
	assert_almost_eq(Settings.sfx_volume, 0.75, 0.001, "old 0.3 (-10.5 dB) -> 0.75 (-10 dB)")
	assert_eq(Settings.ui_volume, 0.0, "off stays off")
	for amplitude: float in [1.0, 0.8, 0.6, 0.45, 0.3, 0.15]:
		var position: float = Settings.position_from_amplitude(amplitude)
		assert_almost_eq(Settings.volume_db(position), linear_to_db(amplitude), 1.1, "loudness kept for %.2f" % amplitude)
	# a file written now is not converted again
	Settings.save_settings(TEMP_PATH)
	Settings.load_settings(TEMP_PATH)
	assert_almost_eq(Settings.master_volume, 0.95, 0.001)


func test_new_defaults_sound_like_the_old_ones() -> void:
	assert_almost_eq(Settings.volume_db(0.95), linear_to_db(0.8), 0.2)
	assert_almost_eq(Settings.volume_db(0.9), linear_to_db(0.6), 0.5)


func test_nothing_stays_ducked_after_dialogue_and_moments() -> void:
	var owner: int = 4242
	Audio.set_dialogue_duck(owner, true)
	Audio.duck_moment(-8.0, 0.2)
	Audio.advance_ducks(1.0)
	assert_lt(AudioMix.duck_of("Ambience"), -1.0, "ducked during the line")
	Audio.set_dialogue_duck(owner, false)
	for i: int in range(30):
		Audio.set("_now", float(Audio.get("_now")) + 0.1)
		Audio.advance_ducks(0.1)
	assert_almost_eq(AudioMix.duck_of("Music"), 0.0, 0.001, "music back up")
	assert_almost_eq(AudioMix.duck_of("Ambience"), 0.0, 0.001, "ambience back up")


func test_nothing_stays_muted_after_the_settings_menu_and_focus() -> void:
	Settings.master_volume = 0.95
	Settings.music_volume = 0.9
	Settings.apply_audio()
	var before: float = _heard_db(&"Music")
	var panel: SettingsPanel = _panel()
	await wait_frames(2)
	panel.queue_free()
	await wait_frames(2)
	assert_almost_eq(_heard_db(&"Music"), before, 0.01, "opening and closing Settings changes nothing")
	Settings.mute_unfocused = true
	Settings.set_focused(false)
	assert_eq(_heard_db(&"Music"), -INF)
	Settings.set_focused(true)
	assert_almost_eq(_heard_db(&"Music"), before, 0.01, "focus back: sound back at the same level")


func test_a_held_pad_direction_keeps_moving_a_slider() -> void:
	var pad: PadFocus = PadFocus.new()
	add_child_autofree(pad)
	var slider: HSlider = HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = 0.5
	slider.focus_mode = Control.FOCUS_ALL
	add_child_autofree(slider)
	await wait_frames(1)
	slider.grab_focus()
	pad.set("_held_range", slider)
	pad.set("_held_range_dir", 1.0)
	pad.set("_held_range_time", 0.0)
	Input.action_press(&"ui_right")
	for i: int in range(10):
		pad.call("_repeat_range", 0.1)
	Input.action_release(&"ui_right")
	assert_gt(slider.value, 0.6, "held for a second: several steps, not one")
	var now: float = slider.value
	pad.call("_repeat_range", 0.5)
	assert_eq(slider.value, now, "let go: it stops")
