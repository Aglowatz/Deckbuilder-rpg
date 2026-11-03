extends GutTest
## Overnight Nov 2-3, Part 5: the Capital's city camera (CityCamera): Standard changes nothing and is the default, Raised and Low only act
## inside the Capital, Low sits low and close behind the hero looking up, and its pull-in keeps the lens out of buildings but never inside the hero.

var _saved_mode: int = 0
var _saved_zoom: float = 1.5


func before_each() -> void:
	_saved_mode = Settings.city_camera
	_saved_zoom = Settings.camera_zoom
	Settings.camera_zoom = Settings.ZOOM_DEFAULT
	CameraRig.reset_swivel()


func after_each() -> void:
	Settings.city_camera = _saved_mode
	Settings.camera_zoom = _saved_zoom
	CityCamera.in_capital = false


func test_standard_is_the_default_and_changes_nothing() -> void:
	var fresh: Object = Settings.get_script().new()
	assert_eq(int(fresh.get("city_camera")), 0, "Standard until the designer picks")
	(fresh as Node).free()
	var offset: Vector3 = Vector3(0.0, 4.0, 8.0)
	CityCamera.in_capital = true
	Settings.city_camera = CityCamera.STANDARD
	assert_eq(CityCamera.shape(offset), CameraRig.shape(offset))
	assert_eq(CityCamera.extra_tilt(), 0.0)
	assert_true(CityCamera.adjust({"fov": 44.0}).is_empty())


func test_outside_the_capital_every_mode_is_standard() -> void:
	CityCamera.in_capital = false
	for mode: int in [CityCamera.RAISED, CityCamera.LOW]:
		Settings.city_camera = mode
		assert_eq(CityCamera.mode(), CityCamera.STANDARD)
		assert_eq(CityCamera.shape(Vector3(0, 4, 8)), CameraRig.shape(Vector3(0, 4, 8)))


func test_raised_is_steeper_and_low_is_low_and_close() -> void:
	CityCamera.in_capital = true
	var offset: Vector3 = Vector3(0.0, 4.0, 8.0)
	Settings.city_camera = CityCamera.RAISED
	var raised: Vector3 = CityCamera.shape(offset)
	assert_almost_eq(rad_to_deg(atan2(raised.y, Vector2(raised.x, raised.z).length())), CityCamera.RAISED_PITCH, 0.5)
	assert_gt(CityCamera.extra_tilt(), 0.0, "aimed a little higher: roofs and sky")
	Settings.city_camera = CityCamera.LOW
	var low: Vector3 = CityCamera.shape(offset)
	assert_lt(low.y, 3.0, "about head height")
	assert_lt(low.length(), 7.0, "close behind")
	assert_gt(low.z, 3.0, "behind the hero (the fixed facing: the camera south of the hero)")
	assert_gt(low.x, 0.3, "over the right shoulder")
	assert_gt(CityCamera.extra_tilt(), 10.0, "looking up at the facades")
	assert_lt(CityCamera.follow_rate(), 5.0, "a gentle follow lag")
	var look: Dictionary = CityCamera.adjust({"fov": 44.0, "blur_far": 7.0, "blur_near": 6.0})
	assert_gt(float(look["fov"]), 44.0)
	assert_lt(float(look["blur_near"]), 6.0, "a subtle tilt-shift")


func test_low_pulls_in_out_of_a_building_but_not_into_the_hero() -> void:
	CityCamera.in_capital = true
	Settings.city_camera = CityCamera.LOW
	var hero: Vector3 = Vector3(10.0, 0.0, 10.0)
	var desired: Vector3 = hero + Vector3(0.0, 2.0, 5.0)
	var wall_behind: Callable = func(p: Vector3) -> bool: return p.z > 13.0
	var pulled: Vector3 = CityCamera.pull_in(hero, desired, wall_behind)
	assert_lt(pulled.z, 13.0, "the lens stops short of the wall")
	assert_gt(pulled.distance_to(hero + Vector3(0, CityCamera.HEAD, 0)), CityCamera.PULL_MIN - 0.01)
	var wall_at_once: Callable = func(_p: Vector3) -> bool: return true
	var nearest: Vector3 = CityCamera.pull_in(hero, desired, wall_at_once)
	assert_almost_eq(nearest.distance_to(hero + Vector3(0, CityCamera.HEAD, 0)), CityCamera.PULL_MIN, 0.01, "never inside the hero")
	var open: Callable = func(_p: Vector3) -> bool: return false
	assert_eq(CityCamera.pull_in(hero, desired, open), desired)
	Settings.city_camera = CityCamera.RAISED
	assert_eq(CityCamera.pull_in(hero, desired, wall_at_once), desired, "only Low pulls in")


func test_the_setting_round_trips_and_cycles() -> void:
	Settings.city_camera = 0
	Settings.cycle_city_camera()
	assert_eq(Settings.city_camera, 1)
	Settings.cycle_city_camera()
	Settings.cycle_city_camera()
	assert_eq(Settings.city_camera, 0)
	assert_eq(CityCamera.MODE_NAMES, ["Standard", "Raised", "Low"] as Array[String])
