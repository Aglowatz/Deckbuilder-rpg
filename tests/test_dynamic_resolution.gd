extends GutTest
## Performance pass Oct 25, Part 5: the dynamic resolution safety net steps the 3D scale down only when the frame is slow because of the GPU,
## back up when the GPU has room, never above the quality level's scale or below its floor, and only where the setting allows it.

const BUDGET: float = 1000.0 / 60.0


func test_auto_covers_low_and_medium_only() -> void:
	assert_true(DynamicResolution.applies(DynamicResolution.Mode.AUTO, GraphicsQuality.Level.LOW, 0, GraphicsQuality.Upscaler.AUTO))
	assert_true(DynamicResolution.applies(DynamicResolution.Mode.AUTO, GraphicsQuality.Level.MEDIUM, 0, GraphicsQuality.Upscaler.AUTO))
	assert_false(DynamicResolution.applies(DynamicResolution.Mode.AUTO, GraphicsQuality.Level.HIGH, 0, GraphicsQuality.Upscaler.AUTO), "never on High unless chosen")
	assert_true(DynamicResolution.applies(DynamicResolution.Mode.ALWAYS, GraphicsQuality.Level.HIGH, 0, GraphicsQuality.Upscaler.AUTO))
	assert_false(DynamicResolution.applies(DynamicResolution.Mode.OFF, GraphicsQuality.Level.LOW, 0, GraphicsQuality.Upscaler.AUTO))


func test_auto_respects_a_fixed_choice() -> void:
	assert_false(DynamicResolution.applies(DynamicResolution.Mode.AUTO, GraphicsQuality.Level.MEDIUM, 75, GraphicsQuality.Upscaler.AUTO), "a fixed render scale")
	assert_false(DynamicResolution.applies(DynamicResolution.Mode.AUTO, GraphicsQuality.Level.MEDIUM, 0, GraphicsQuality.Upscaler.NATIVE), "native chosen")


func test_a_slow_gpu_bound_frame_steps_down_once_it_has_lasted() -> void:
	var slow_frame: float = BUDGET * 1.3
	var busy_gpu: float = BUDGET * 0.95
	assert_eq(DynamicResolution.decide(0.58, 0.58, slow_frame, busy_gpu, BUDGET, 0.2, 0.0), 0.58, "a moment is not enough")
	assert_almost_eq(DynamicResolution.decide(0.58, 0.58, slow_frame, busy_gpu, BUDGET, 1.0, 0.0), 0.54, 0.001)


func test_a_slow_frame_with_an_idle_gpu_does_not_step_down() -> void:
	# the CPU is the limit: a smaller picture would only look worse
	assert_eq(DynamicResolution.decide(0.58, 0.58, BUDGET * 1.5, BUDGET * 0.4, BUDGET, 2.0, 0.0), 0.58)


func test_never_below_the_floor_or_above_the_level() -> void:
	var floor_scale: float = DynamicResolution.floor_for(0.58)
	assert_almost_eq(floor_scale, 0.44, 0.001)
	assert_eq(DynamicResolution.decide(floor_scale, 0.58, BUDGET * 2.0, BUDGET, BUDGET, 5.0, 0.0), floor_scale)
	assert_eq(DynamicResolution.decide(0.58, 0.58, BUDGET * 0.5, BUDGET * 0.3, BUDGET, 0.0, 5.0), 0.58, "already at the level's scale")
	assert_eq(DynamicResolution.floor_for(0.5), 0.4 if 0.5 - DynamicResolution.FLOOR_DROP < 0.4 else 0.5 - DynamicResolution.FLOOR_DROP)


func test_room_on_the_gpu_steps_back_up() -> void:
	assert_eq(DynamicResolution.decide(0.5, 0.58, BUDGET * 0.6, BUDGET * 0.5, BUDGET, 0.0, 1.0), 0.5, "waits a little")
	assert_almost_eq(DynamicResolution.decide(0.5, 0.58, BUDGET * 0.6, BUDGET * 0.5, BUDGET, 0.0, 2.5), 0.54, 0.001)


func test_the_setting_is_saved_and_loaded() -> void:
	var path: String = "user://test_settings_drs.cfg"
	var before: int = Settings.dynamic_resolution
	Settings.dynamic_resolution = DynamicResolution.Mode.OFF
	Settings.save_settings(path)
	Settings.dynamic_resolution = DynamicResolution.Mode.AUTO
	Settings.load_settings(path)
	assert_eq(Settings.dynamic_resolution, DynamicResolution.Mode.OFF)
	Settings.dynamic_resolution = before
	DirAccess.remove_absolute(path)
