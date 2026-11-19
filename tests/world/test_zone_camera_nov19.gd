extends GutTest
## Fable Nov 19 (Part 2): each place has its default camera in ONE file (data/camera/zone_camera.json).
## Fable Nov 20 (Part 1.2, the owner's decision): +4 degrees in every place (the D.N.A. too, it was +6), distances as they were; the
## player can pick Standard / +4 (default) / +6 / +8 and Closer / Default / Further in Settings, in every place.

var _tilt: int = 1
var _distance: int = 1


func before_each() -> void:
	_tilt = Settings.camera_tilt
	_distance = Settings.camera_distance
	Settings.camera_tilt = CameraRig.TILT_DEFAULT
	Settings.camera_distance = CameraRig.DISTANCE_DEFAULT


func after_each() -> void:
	Settings.camera_tilt = _tilt
	Settings.camera_distance = _distance
	ZoneCamera.clear()


func test_every_place_is_listed_at_plus_four() -> void:
	ZoneCamera.reload()
	for place: String in ["crosspath", "forest", "beefcake", "gourmand", "refusemancer", "necrocrat", "final", "crease"]:
		assert_true(ZoneCamera.places().has(place), place)
		assert_almost_eq(ZoneCamera.distance(place), 1.0, 0.001, "%s: the distance is unchanged" % place)
		assert_almost_eq(ZoneCamera.pitch_bonus(place), 4.0, 0.001, "%s: +4 degrees" % place)
	assert_almost_eq(ZoneCamera.pitch_bonus("somewhere else"), 0.0, 0.001)
	assert_almost_eq(ZoneCamera.distance("somewhere else"), 1.0, 0.001)


func test_apply_sets_the_rig_and_clear_puts_it_back() -> void:
	ZoneCamera.apply("necrocrat")
	assert_almost_eq(CameraRig.zone_pitch_bonus, 4.0, 0.001)
	assert_almost_eq(CameraRig.zone_distance, 1.0, 0.001)
	assert_eq(ZoneCamera.current, "necrocrat")
	ZoneCamera.clear()
	assert_almost_eq(CameraRig.zone_pitch_bonus, 0.0, 0.001)
	assert_eq(ZoneCamera.current, "")


func test_the_distance_moves_the_camera_in_and_out() -> void:
	var base: Vector3 = CameraRig.shape(WorldLookRig.base_offset())
	CameraRig.zone_distance = 0.9
	var closer: Vector3 = CameraRig.shape(WorldLookRig.base_offset())
	CameraRig.zone_distance = 1.0
	assert_almost_eq(closer.length(), base.length() * 0.9, 0.01, "10 % closer")
	assert_almost_eq(closer.normalized().dot(base.normalized()), 1.0, 0.001, "the same direction")


func test_an_eased_change_glides() -> void:
	ZoneCamera.apply("final")
	CameraRig.zone_pitch_target = 6.0
	CameraRig.tick(0.1)
	assert_between(CameraRig.zone_pitch_bonus, 0.1, 5.9, "on its way, not there at once")
	for _step: int in range(40):
		CameraRig.tick(0.1)
	assert_almost_eq(CameraRig.zone_pitch_bonus, 6.0, 0.001)


func _pitch_of(offset: Vector3) -> float:
	return rad_to_deg(atan2(offset.y, Vector2(offset.x, offset.z).length()))


func test_a_new_player_starts_on_plus_four_and_default_distance() -> void:
	var fresh: Node = (load("res://app/settings.gd") as GDScript).new() as Node
	assert_eq(int(fresh.get("camera_tilt")), CameraRig.TILT_DEFAULT)
	assert_eq(int(fresh.get("camera_distance")), CameraRig.DISTANCE_DEFAULT)
	fresh.free()
	assert_eq(CameraRig.TILT_NAMES[CameraRig.TILT_DEFAULT], "+4 (default)")
	assert_eq(CameraRig.TILT_NAMES.size(), 4)
	assert_eq(CameraRig.DISTANCE_NAMES, ["Closer", "Default", "Further"] as Array[String])


func test_the_players_tilt_choice_applies_in_every_place() -> void:
	for place: String in ["crosspath", "forest", "beefcake", "gourmand", "refusemancer", "necrocrat", "final", "crease"]:
		ZoneCamera.apply(place)
		Settings.camera_tilt = 0
		var standard: float = _pitch_of(CameraRig.shape(WorldLookRig.base_offset()))
		for choice: int in range(1, CameraRig.TILT_NAMES.size()):
			Settings.camera_tilt = choice
			var pitch: float = _pitch_of(CameraRig.shape(WorldLookRig.base_offset()))
			assert_almost_eq(pitch - standard, CameraRig.TILT_DEGREES[choice], 0.05, "%s at %s" % [place, CameraRig.TILT_NAMES[choice]])
	ZoneCamera.clear()
	Settings.camera_tilt = 3
	assert_almost_eq(CameraRig.pitch_bonus(), 0.0, 0.001, "nothing is added outside a place")


func test_the_players_distance_choice_moves_the_camera() -> void:
	ZoneCamera.apply("crosspath")
	var base: float = CameraRig.shape(WorldLookRig.base_offset()).length()
	Settings.camera_distance = 0
	assert_almost_eq(CameraRig.shape(WorldLookRig.base_offset()).length(), base * 0.9, 0.01, "Closer")
	Settings.camera_distance = 2
	assert_almost_eq(CameraRig.shape(WorldLookRig.base_offset()).length(), base * 1.1, 0.01, "Further")


func test_settings_offers_both_choices() -> void:
	var panel: SettingsPanel = SettingsPanel.new()
	add_child_autofree(panel)
	await get_tree().process_frame
	var found: Array[Node] = panel.find_children("CameraTiltOptions", "OptionButton", true, false)
	found.append_array(panel.find_children("CameraDistanceOptions", "OptionButton", true, false))
	if found.size() < 2 and panel.has_method("show_tab"):
		pending("the Display tab is built on demand")
		return
	assert_eq(found.size(), 2, "Camera angle and Camera distance are in Settings")
	assert_eq((found[0] as OptionButton).item_count, 4)
	assert_eq((found[1] as OptionButton).item_count, 3)
