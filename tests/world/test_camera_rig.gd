extends GutTest
## Overnight Steps 2 and 3: the storybook scale numbers and the nine-combination camera (Art Bible G-01, G-02).

var _angle: int
var _zoom: float


func before_each() -> void:
	_angle = Settings.camera_angle
	_zoom = Settings.camera_zoom
	CameraRig.reset_swivel()


func after_each() -> void:
	Settings.camera_angle = _angle
	Settings.camera_zoom = _zoom
	CameraRig.reset_swivel()


func _pitch_of(offset: Vector3) -> float:
	return rad_to_deg(atan2(offset.y, Vector2(offset.x, offset.z).length()))


func test_storybook_numbers_follow_the_art_bible() -> void:
	assert_between(StorybookScale.HERO_HEIGHT / StorybookScale.DOOR_H, 0.85, 0.9, "hero is 85-90% of a door")
	assert_almost_eq(StorybookScale.STOREY_H / StorybookScale.HERO_HEIGHT, 1.5, 0.001, "a storey is 1.5 heroes")
	assert_almost_eq(WorldSprite.PLAYER_HEIGHT, StorybookScale.HERO_HEIGHT, 0.001)
	assert_almost_eq(TownPlayer.MODEL_SCALE, StorybookScale.MODEL_SCALE, 0.0001)


func test_angle_presets_set_the_camera_pitch() -> void:
	Settings.camera_zoom = Settings.ZOOM_DEFAULT
	var base: Vector3 = WorldLookRig.base_offset()
	var wanted: Array[float] = [20.0, 30.0, 45.0]
	for index: int in range(3):
		Settings.camera_angle = index
		assert_almost_eq(_pitch_of(CameraRig.shape(base)), wanted[index], 0.2, "%s pitch" % CameraRig.ANGLE_NAMES[index])


func test_zoom_presets_move_the_camera_out() -> void:
	Settings.camera_angle = 0
	var base: Vector3 = WorldLookRig.base_offset()
	var lengths: Array[float] = []
	for value: float in CameraRig.ZOOM_VALUES:
		Settings.camera_zoom = value
		lengths.append(CameraRig.shape(base).length())
	assert_lt(lengths[0], lengths[1])
	assert_lt(lengths[1], lengths[2])


func test_the_hero_is_about_eleven_percent_of_the_screen_at_normal() -> void:
	Settings.camera_angle = 0
	Settings.camera_zoom = Settings.ZOOM_DEFAULT
	var distance: float = CameraRig.shape(WorldLookRig.base_offset()).length()
	var fov: float = float(CameraRig.adjust(WorldLookRig.game_values())["fov"])
	var visible_height: float = 2.0 * distance * tan(deg_to_rad(fov) * 0.5)
	assert_between(StorybookScale.HERO_HEIGHT / visible_height, 0.10, 0.125, "10-12% of the screen height")


func test_every_combination_adjusts_tilt_shift_and_fov() -> void:
	var values: Dictionary = WorldLookRig.game_values()
	var seen: Dictionary = {}
	for angle: int in range(3):
		for zoom: float in CameraRig.ZOOM_VALUES:
			Settings.camera_angle = angle
			Settings.camera_zoom = zoom
			var adjusted: Dictionary = CameraRig.adjust(values)
			for key: String in ["fov", "focus", "band", "blur_far", "blur_near"]:
				assert_true(adjusted.has(key), "%s has %s" % [CameraRig.combo_name(), key])
			assert_between(float(adjusted["fov"]), 30.0, 60.0)
			seen[CameraRig.combo_name()] = true
	assert_eq(seen.size(), 9, "nine distinct combinations")


func test_swivel_turns_and_eases_back() -> void:
	Settings.camera_angle = 0
	var base: Vector3 = WorldLookRig.base_offset()
	var straight: Vector3 = CameraRig.shape(base)
	CameraRig.swivel_target = CameraRig.MAX_SWIVEL_DEGREES
	for _step: int in range(120):
		CameraRig.tick(0.05)
	assert_almost_eq(CameraRig.swivel, CameraRig.MAX_SWIVEL_DEGREES, 0.1)
	var turned: Vector3 = CameraRig.shape(base)
	var angle: float = rad_to_deg(Vector2(straight.x, straight.z).angle_to(Vector2(turned.x, turned.z)))
	assert_between(absf(angle), 15.0, 20.0, "about 15-20 degrees")
	assert_almost_eq(turned.length(), straight.length(), 0.01, "the distance does not change")
	CameraRig.swivel_target = 0.0
	for _step: int in range(160):
		CameraRig.tick(0.05)
	assert_almost_eq(CameraRig.swivel, 0.0, 0.05, "it eases back when released")


func test_angle_and_zoom_cycle_and_persist() -> void:
	Settings.camera_angle = 0
	Settings.cycle_camera_angle()
	assert_eq(Settings.camera_angle, 1)
	Settings.cycle_camera_angle()
	Settings.cycle_camera_angle()
	assert_eq(Settings.camera_angle, 0, "wraps")
	Settings.camera_zoom = Settings.ZOOM_DEFAULT
	Settings.cycle_camera_zoom()
	assert_eq(CameraRig.zoom_index(), 2)
	var path: String = "user://test_camera_settings.cfg"
	Settings.camera_angle = 2
	Settings.save_settings(path)
	Settings.camera_angle = 0
	Settings.load_settings(path)
	assert_eq(Settings.camera_angle, 2, "the angle is remembered in the settings file")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func test_camera_actions_are_rebindable() -> void:
	for action: StringName in [&"camera_swivel_left", &"camera_swivel_right", &"camera_angle", &"camera_zoom"]:
		assert_true(Keybinds.action_ids().has(action), "%s is a rebindable action" % action)
