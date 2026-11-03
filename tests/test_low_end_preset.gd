extends GutTest
## Size pass Nov 3 (Part 6): the Low-end preset (Low + the memory and fill-rate savers), its first-launch rule and its settings row.

var _saved_low_end: bool = false
var _saved_quality: int = 0
var _saved_cap: int = 0


func before_each() -> void:
	_saved_low_end = Settings.low_end
	_saved_quality = Settings.graphics_quality
	_saved_cap = Settings.max_fps


func after_each() -> void:
	Settings.low_end = _saved_low_end
	Settings.graphics_quality = _saved_quality
	Settings.max_fps = _saved_cap
	GraphicsQuality.low_end = _saved_low_end
	Settings.apply_performance()


func test_low_end_is_low_with_the_savers_on_top() -> void:
	GraphicsQuality.low_end = false
	var low: int = GraphicsQuality.Level.LOW
	var foliage_low: float = GraphicsQuality.foliage_density(low)
	var particles_low: int = GraphicsQuality.ambient_particle_budget(low)
	var lights_low: int = GraphicsQuality.light_budget(low)
	assert_eq(GraphicsQuality.texture_mipmap_bias(low), 0.0, "no bias on plain Low")
	assert_true(GraphicsQuality.parks_scene(), "Low parks the world scene")
	GraphicsQuality.low_end = true
	assert_lt(GraphicsQuality.foliage_density(low), foliage_low, "fewer foliage items")
	assert_lt(GraphicsQuality.ambient_particle_budget(low), particles_low)
	assert_lt(GraphicsQuality.light_budget(low), lights_low)
	assert_lt(GraphicsQuality.cull_scale(low), 0.8)
	assert_eq(GraphicsQuality.texture_mipmap_bias(low), GraphicsQuality.LOW_END_MIPMAP_BIAS)
	assert_false(GraphicsQuality.parks_scene(), "Low-end rebuilds instead of parking (RAM first)")
	assert_eq(GraphicsQuality.render_scale(low), 0.5, "the render scale stays Low's")
	assert_false(GraphicsQuality.shadow_detail(low) > 0, "no sun shadow")
	assert_false(GraphicsQuality.glow(low))
	assert_false(GraphicsQuality.ssao(low))
	assert_false(GraphicsQuality.volumetric_fog(low))
	assert_eq(GraphicsQuality.preset_name(low, true), GraphicsQuality.LOW_END_NAME)
	assert_eq(GraphicsQuality.preset_name(low, false), "Low")


func test_the_viewport_gets_the_mipmap_bias() -> void:
	var viewport: SubViewport = SubViewport.new()
	add_child_autofree(viewport)
	GraphicsQuality.low_end = true
	GraphicsQuality.apply_to_viewport(viewport, GraphicsQuality.Level.LOW)
	assert_almost_eq(viewport.texture_mipmap_bias, GraphicsQuality.LOW_END_MIPMAP_BIAS, 0.001)
	GraphicsQuality.low_end = false
	GraphicsQuality.apply_to_viewport(viewport, GraphicsQuality.Level.LOW)
	assert_almost_eq(viewport.texture_mipmap_bias, 0.0, 0.001)


func test_settings_apply_sets_the_flag_and_the_art_budget() -> void:
	Settings.low_end = true
	Settings.graphics_quality = GraphicsQuality.Level.LOW
	Settings.apply_performance()
	assert_true(GraphicsQuality.low_end)
	assert_eq(ArtCache.budget_mb, ArtCache.LOW_END_MB)
	Settings.low_end = false
	Settings.graphics_quality = GraphicsQuality.Level.MEDIUM
	Settings.apply_performance()
	assert_false(GraphicsQuality.low_end)
	assert_eq(ArtCache.budget_mb, ArtCache.budget_for_level(GraphicsQuality.Level.MEDIUM))


func test_low_end_survives_a_save_and_load() -> void:
	var path: String = "user://test_low_end_settings.cfg"
	Settings.low_end = true
	Settings.graphics_quality = GraphicsQuality.Level.LOW
	Settings.save_settings(path)
	Settings.low_end = false
	Settings.graphics_quality = GraphicsQuality.Level.HIGH
	Settings.load_settings(path)
	assert_true(Settings.low_end)
	assert_eq(Settings.graphics_quality, GraphicsQuality.Level.LOW, "Low-end always loads as Low underneath")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func test_first_launch_rule_names_its_reason() -> void:
	# This machine (an integrated AMD GPU in the headless test run: the software / unknown adapter) or any 4 GB one gets Low-end.
	var reason: String = GraphicsQuality.low_end_reason()
	assert_eq(GraphicsQuality.recommended_low_end(), not reason.is_empty())
	var physical_mb: int = int(OS.get_memory_info().get("physical", 0)) / 1048576
	if GpuInfo.is_integrated(GpuInfo.current_kind()) or GpuInfo.current_kind() == GpuInfo.Kind.CPU or (physical_mb > 0 and physical_mb <= GraphicsQuality.LOW_END_RAM_MB):
		assert_false(reason.is_empty(), "integrated / software / small machine -> Low-end: " + reason)


func test_the_settings_row_offers_low_end_as_the_last_choice() -> void:
	Settings.low_end = false
	Settings.graphics_quality = GraphicsQuality.Level.MEDIUM
	var panel: SettingsPanel = SettingsPanel.new()
	panel.autosave = false
	add_child_autofree(panel)
	panel.show_page(0)
	await wait_frames(2)
	var options: OptionButton = panel.find_child("QualityOptions", true, false) as OptionButton
	assert_not_null(options, "the quality row")
	assert_eq(options.item_count, GraphicsQuality.NAMES.size() + 1)
	assert_eq(options.get_item_text(options.item_count - 1), GraphicsQuality.LOW_END_NAME)
	assert_eq(options.selected, GraphicsQuality.Level.MEDIUM)
	panel._on_quality(options.item_count - 1)
	assert_true(Settings.low_end)
	assert_eq(Settings.graphics_quality, GraphicsQuality.Level.LOW)
	panel._on_quality(GraphicsQuality.Level.MEDIUM)
	assert_false(Settings.low_end)
	assert_eq(Settings.graphics_quality, GraphicsQuality.Level.MEDIUM)
