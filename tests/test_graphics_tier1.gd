extends GutTest
## Graphics Tier 1 (docs/art/graphics_tier1.md): the upscaler / render scale / sharpness settings, their persistence, and the rules that keep
## Low and Intel integrated GPUs safe (no FSR 2 there, nothing heavier on Low).

const TEMP_PATH: String = "user://test_graphics_tier1.cfg"

var _saved: Dictionary = {}
var _heavy: bool = true


func before_each() -> void:
	_saved = {"mode": Settings.upscaling_mode, "pct": Settings.render_scale_pct, "sharp": Settings.sharpness, "quality": Settings.graphics_quality}
	_heavy = GraphicsQuality.heavy_passes_allowed


func after_each() -> void:
	Settings.upscaling_mode = _saved["mode"]
	Settings.render_scale_pct = _saved["pct"]
	Settings.sharpness = _saved["sharp"]
	Settings.graphics_quality = _saved["quality"]
	GraphicsQuality.heavy_passes_allowed = _heavy
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_PATH))


func test_settings_round_trip() -> void:
	Settings.upscaling_mode = GraphicsQuality.Upscaler.FSR2
	Settings.render_scale_pct = 75
	Settings.sharpness = 0.35
	Settings.save_settings(TEMP_PATH)
	Settings.upscaling_mode = GraphicsQuality.Upscaler.AUTO
	Settings.render_scale_pct = 0
	Settings.sharpness = 0.8
	Settings.load_settings(TEMP_PATH)
	assert_eq(Settings.upscaling_mode, GraphicsQuality.Upscaler.FSR2)
	assert_eq(Settings.render_scale_pct, 75)
	assert_almost_eq(Settings.sharpness, 0.35, 0.001)


func test_old_settings_file_gets_the_defaults() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("video", "quality", 1)
	config.save(TEMP_PATH)
	Settings.upscaling_mode = GraphicsQuality.Upscaler.FSR2
	Settings.render_scale_pct = 50
	Settings.load_settings(TEMP_PATH)
	assert_eq(Settings.upscaling_mode, GraphicsQuality.Upscaler.AUTO, "a pre-Tier-1 settings.cfg keeps Auto")
	assert_eq(Settings.render_scale_pct, 0, "a pre-Tier-1 settings.cfg keeps the preset scale")
	assert_almost_eq(Settings.sharpness, 0.8, 0.001)


func test_effective_render_scale() -> void:
	Settings.upscaling_mode = GraphicsQuality.Upscaler.AUTO
	Settings.render_scale_pct = 0
	assert_almost_eq(GraphicsQuality.effective_render_scale(GraphicsQuality.Level.MEDIUM), GraphicsQuality.render_scale(GraphicsQuality.Level.MEDIUM), 0.001)
	Settings.render_scale_pct = 75
	assert_almost_eq(GraphicsQuality.effective_render_scale(GraphicsQuality.Level.LOW), 0.75, 0.001)
	Settings.upscaling_mode = GraphicsQuality.Upscaler.NATIVE
	assert_almost_eq(GraphicsQuality.effective_render_scale(GraphicsQuality.Level.LOW), 1.0, 0.001, "Off means native, whatever the percentage")


func test_upscaler_rules() -> void:
	GraphicsQuality.heavy_passes_allowed = true
	assert_eq(GraphicsQuality.upscaler_mode(1, GraphicsQuality.Upscaler.AUTO, 0.58), Viewport.SCALING_3D_MODE_FSR)
	assert_eq(GraphicsQuality.upscaler_mode(2, GraphicsQuality.Upscaler.AUTO, 1.0), Viewport.SCALING_3D_MODE_BILINEAR, "nothing to upscale at native")
	assert_eq(GraphicsQuality.upscaler_mode(1, GraphicsQuality.Upscaler.NATIVE, 0.58), Viewport.SCALING_3D_MODE_BILINEAR)
	assert_eq(GraphicsQuality.upscaler_mode(1, GraphicsQuality.Upscaler.FSR2, 0.58), Viewport.SCALING_3D_MODE_FSR2)
	GraphicsQuality.heavy_passes_allowed = false
	assert_eq(GraphicsQuality.upscaler_mode(1, GraphicsQuality.Upscaler.FSR2, 0.58), Viewport.SCALING_3D_MODE_FSR, "an Intel iGPU never runs FSR 2")


func test_sharpness_maps_crisp_to_zero() -> void:
	assert_almost_eq(GraphicsQuality.fsr_sharpness(1.0), 0.0, 0.001)
	assert_true(GraphicsQuality.fsr_sharpness(0.0) > GraphicsQuality.fsr_sharpness(0.8))


func test_low_never_gets_the_tier1_effects() -> void:
	assert_false(GraphicsQuality.cloud_shadows(GraphicsQuality.Level.LOW))
	assert_false(GraphicsQuality.sprite_normals(GraphicsQuality.Level.LOW))
	assert_eq(GraphicsQuality.haze_cards(GraphicsQuality.Level.LOW), 0)
	assert_true(GraphicsQuality.effect_lights(GraphicsQuality.Level.LOW) <= 1)
	assert_true(GraphicsQuality.cull_scale(GraphicsQuality.Level.LOW) <= 1.0)
	assert_almost_eq(GraphicsQuality.render_scale(GraphicsQuality.Level.LOW), 0.5, 0.001)


func test_intel_integrated_never_gets_high_only_effects() -> void:
	GraphicsQuality.heavy_passes_allowed = false
	assert_false(GraphicsQuality.effect_light_shadows(GraphicsQuality.Level.HIGH))
	assert_false(GraphicsQuality.volumetric_fog(GraphicsQuality.Level.HIGH))
	assert_false(GraphicsQuality.ssao(GraphicsQuality.Level.HIGH))
	assert_eq(GraphicsQuality.msaa(GraphicsQuality.Level.HIGH), Viewport.MSAA_DISABLED)


func test_shadow_filter_and_blur_rise_with_the_level() -> void:
	assert_true(GraphicsQuality.shadow_blur(2) >= GraphicsQuality.shadow_blur(1))
	assert_true(GraphicsQuality.shadow_blur(1) >= GraphicsQuality.shadow_blur(0))
	assert_true(GraphicsQuality.shadow_filter(2) >= GraphicsQuality.shadow_filter(1))
