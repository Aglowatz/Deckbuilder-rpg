extends GutTest
## Fable Nov 21 (Part 6): V cycles five camera presets: +6, +8, +10, +12 and +14 degrees from the original default, each a little
## further out as it gets steeper; a toast names the preset ("Camera 3 of 5: +10°"); the default is +6; the Settings row shows the same
## five and the choice is saved (a settings file from before maps onto the new presets).

var _tilt: int = 0
var _distance: int = 1


func before_each() -> void:
	_tilt = Settings.camera_tilt
	_distance = Settings.camera_distance
	Settings.camera_tilt = CameraRig.TILT_DEFAULT
	Settings.camera_distance = CameraRig.DISTANCE_DEFAULT
	ZoneCamera.reload()
	ZoneCamera.apply("crosspath")


func after_each() -> void:
	Settings.camera_tilt = _tilt
	Settings.camera_distance = _distance
	ZoneCamera.clear()


func _pitch() -> float:
	var offset: Vector3 = CameraRig.shape(WorldLookRig.base_offset())
	return rad_to_deg(atan2(offset.y, Vector2(offset.x, offset.z).length()))


func _original_pitch() -> float:
	ZoneCamera.clear()
	var value: float = _pitch()
	ZoneCamera.apply("crosspath")
	return value


func test_the_five_presets_are_six_to_fourteen_degrees() -> void:
	assert_eq(CameraRig.TILT_DEGREES, [6.0, 8.0, 10.0, 12.0, 14.0] as Array[float])
	assert_eq(CameraRig.TILT_NAMES.size(), 5)
	assert_eq(CameraRig.TILT_DEFAULT, 0, "+6 is the default (it replaces +4)")
	var original: float = _original_pitch()
	for index: int in range(5):
		Settings.camera_tilt = index
		assert_almost_eq(_pitch() - original, CameraRig.TILT_DEGREES[index], 0.05, "preset %d looks down +%d degrees from the original default" % [index + 1, int(CameraRig.TILT_DEGREES[index])])


func test_each_steeper_preset_stands_a_little_further_out() -> void:
	var lengths: Array[float] = []
	for index: int in range(5):
		Settings.camera_tilt = index
		lengths.append(CameraRig.shape(WorldLookRig.base_offset()).length())
	for index: int in range(1, 5):
		assert_gt(lengths[index], lengths[index - 1], "preset %d is further out than preset %d" % [index + 1, index])
		assert_lt(lengths[index] / lengths[index - 1], 1.06, "but only a little")
	assert_almost_eq(lengths[4] / lengths[0], 1.12, 0.005, "+14 stands 12 % further out than +6")


func test_v_cycles_the_five_and_wraps_with_a_toast_each_time() -> void:
	var toasts: Array[String] = []
	var catch: Callable = func(text: String) -> void: toasts.append(text)
	EventBus.toast_requested.connect(catch)
	Settings.camera_tilt = 0
	for step: int in range(5):
		Settings.cycle_camera_tilt()
	EventBus.toast_requested.disconnect(catch)
	assert_eq(Settings.camera_tilt, 0, "five presses come back round to the first")
	assert_eq(toasts, ["Camera 2 of 5: +8°", "Camera 3 of 5: +10°", "Camera 4 of 5: +12°", "Camera 5 of 5: +14°", "Camera 1 of 5: +6°"] as Array[String])


func test_the_v_key_is_bound_to_the_presets() -> void:
	var source: String = FileAccess.get_file_as_string("res://app/settings.gd")
	var at: int = source.find("event.is_action_pressed(&\"camera_angle\")")
	assert_gt(at, 0)
	assert_string_contains(source.substr(at, 120), "cycle_camera_tilt()", "the camera key walks the five presets")
	var bound: bool = false
	for event: InputEvent in InputMap.action_get_events(&"camera_angle"):
		if event is InputEventKey and ((event as InputEventKey).keycode == KEY_V or (event as InputEventKey).physical_keycode == KEY_V):
			bound = true
	assert_true(bound, "V is the camera key")


func test_every_place_starts_at_plus_six() -> void:
	for place: String in ["crosspath", "forest", "beefcake", "gourmand", "refusemancer", "necrocrat", "final", "crease"]:
		assert_almost_eq(ZoneCamera.pitch_bonus(place), 6.0, 0.001, place)
	var fresh: Node = (load("res://app/settings.gd") as GDScript).new() as Node
	assert_eq(int(fresh.get("camera_tilt")), 0, "a new player starts on preset 1: +6")
	fresh.free()


func test_the_settings_row_lists_the_same_five_and_follows_v() -> void:
	Settings.camera_tilt = 0
	Settings.cycle_camera_tilt()
	Settings.cycle_camera_tilt()
	var panel: SettingsPanel = SettingsPanel.new()
	add_child_autofree(panel)
	await wait_frames(4)
	var options: OptionButton = panel.find_child("CameraTiltOptions", true, false) as OptionButton
	assert_not_null(options, "the Settings row stays")
	if options == null:
		return
	assert_eq(options.item_count, 5)
	assert_eq(options.selected, 2, "it shows the preset V chose (+10)")
	assert_string_contains(options.get_item_text(2), "+10")
	assert_not_null(panel.find_child("CameraDistanceOptions", true, false), "Camera distance stays too")
	assert_not_null(panel.find_child("CameraAngleOptions", true, false), "and the Camera preset row")


func test_the_choice_is_saved_and_an_old_file_is_mapped() -> void:
	var path: String = "user://test_camera_presets_nov21.cfg"
	Settings.camera_tilt = 3
	Settings.save_settings(path)
	Settings.camera_tilt = 0
	Settings.load_settings(path)
	assert_eq(Settings.camera_tilt, 3, "+12 is remembered")
	# a file written before Nov 21: only the old key (0 Standard, 1 +4, 2 +6, 3 +8)
	var old: ConfigFile = ConfigFile.new()
	old.load(path)
	old.erase_section_key("video", "camera_tilt_v2")
	old.set_value("video", "camera_tilt", 3)
	old.save(path)
	Settings.load_settings(path)
	assert_eq(Settings.camera_tilt, 1, "an old +8 stays +8")
	old.set_value("video", "camera_tilt", 1)
	old.save(path)
	Settings.load_settings(path)
	assert_eq(Settings.camera_tilt, 0, "an old +4 (the old default) becomes +6, the new default")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	assert_eq([Settings.tilt_from_old(0), Settings.tilt_from_old(2)], [0, 0])


func test_outside_a_place_nothing_is_added() -> void:
	ZoneCamera.clear()
	Settings.camera_tilt = 4
	assert_almost_eq(CameraRig.pitch_bonus(), 0.0, 0.001)
	assert_almost_eq(CameraRig.distance_scale(), 1.0, 0.001)
