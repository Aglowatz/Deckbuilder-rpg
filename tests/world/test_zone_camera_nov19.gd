extends GutTest
## Fable Nov 19 (Part 2): each place has its default camera in ONE file (data/camera/zone_camera.json). This pass changes no default:
## every place is as it was (the D.N.A. keeps its +6 degrees), and a choice is one line in that file.


func after_each() -> void:
	ZoneCamera.clear()


func test_every_place_is_listed_and_no_default_changed() -> void:
	ZoneCamera.reload()
	for place: String in ["crosspath", "forest", "beefcake", "gourmand", "refusemancer", "necrocrat", "final", "crease"]:
		assert_true(ZoneCamera.places().has(place), place)
		assert_almost_eq(ZoneCamera.distance(place), 1.0, 0.001, "%s: the distance is unchanged" % place)
		assert_almost_eq(ZoneCamera.pitch_bonus(place), 6.0 if place == "necrocrat" else 0.0, 0.001, "%s: the pitch is unchanged" % place)
	assert_almost_eq(ZoneCamera.pitch_bonus("somewhere else"), 0.0, 0.001)
	assert_almost_eq(ZoneCamera.distance("somewhere else"), 1.0, 0.001)


func test_apply_sets_the_rig_and_clear_puts_it_back() -> void:
	ZoneCamera.apply("necrocrat")
	assert_almost_eq(CameraRig.zone_pitch_bonus, 6.0, 0.001)
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
