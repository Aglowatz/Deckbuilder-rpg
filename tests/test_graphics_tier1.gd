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


# ---- Part 2: the ground light map and the haze cards -----------------------------------------------------------------------------------------


func _box_node(size: Vector3, at: Vector3) -> MeshInstance3D:
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	var node: MeshInstance3D = MeshInstance3D.new()
	node.mesh = box
	node.position = at + Vector3(0.0, size.y * 0.5, 0.0)
	return node


func test_ground_light_collects_buildings_and_trees_but_not_ground_or_fences() -> void:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	root.add_child(_box_node(Vector3(8.0, 5.0, 6.0), Vector3(10.0, 0.0, 4.0)))  # a house: a rect
	root.add_child(_box_node(Vector3(0.3, 6.0, 0.3), Vector3(-3.0, 0.0, 2.0)))  # a tree trunk / card: a disc
	root.add_child(_box_node(Vector3(6.0, 0.9, 0.2), Vector3(0.0, 0.0, 0.0)))  # a fence: skipped
	root.add_child(_box_node(Vector3(200.0, 0.1, 200.0), Vector3(0.0, 0.0, 0.0)))  # the ground: skipped
	var sky_piece: MeshInstance3D = _box_node(Vector3(4.0, 4.0, 4.0), Vector3(20.0, 0.0, 20.0))
	sky_piece.set_meta(&"no_range_cull", true)  # a world-look piece: skipped
	root.add_child(sky_piece)
	var found: Array[Dictionary] = GroundLight.collect_occluders(root)
	assert_eq(found.size(), 2, "the house and the tree")
	var discs: int = 0
	for entry: Dictionary in found:
		if bool(entry["disc"]):
			discs += 1
	assert_eq(discs, 1, "the thin tall one is a canopy disc")


func test_ground_light_bake_darkens_under_a_tree_and_round_a_wall_only() -> void:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	root.add_child(_box_node(Vector3(8.0, 5.0, 6.0), Vector3(10.0, 0.0, 4.0)))
	root.add_child(_box_node(Vector3(0.3, 6.0, 0.3), Vector3(-6.0, 0.0, -6.0)))
	var light: GroundLight = GroundLight.install(root, Rect2(-10.0, -10.0, 30.0, 24.0), null)
	light.bake()
	assert_not_null(light.texture)
	var image: Image = light.texture.get_image()
	var rect: Rect2 = Rect2(-10.0, -10.0, 30.0, 24.0).grow(GroundLight.MARGIN)
	var sample: Callable = func(x: float, z: float) -> float:
		var u: int = int((x - rect.position.x) / rect.size.x * float(image.get_width()))
		var v: int = int((z - rect.position.y) / rect.size.y * float(image.get_height()))
		return image.get_pixel(clampi(u, 0, image.get_width() - 1), clampi(v, 0, image.get_height() - 1)).r
	assert_true(float(sample.call(-6.0, -6.0)) < 0.8, "dark under the tree")
	assert_true(float(sample.call(10.0, 4.0)) > 0.9, "the middle of the house stays open (hidden anyway, and revealed by the fader)")
	assert_true(float(sample.call(14.3, 4.0)) < 0.95, "a band of shade at the foot of the wall")
	assert_true(float(sample.call(-8.0, 10.0)) > 0.98, "open ground away from everything")
	GroundLight.clear_globals()


func test_haze_cards_respect_the_budget_and_low_gets_none() -> void:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	var spec: Dictionary = {"fog": [[0, 0, 10, 0.3], [5, 5, 10, 0.3], [9, 9, 10, 0.3]], "shafts": [[1, 1, 10, 2.5, 0.1], [2, 2, 10, 2.5, 0.1]]}
	var low: HazeCards = HazeCards.install(root, spec, Vector3(0.4, -0.6, -0.6), Color.WHITE, Color.WHITE, GraphicsQuality.Level.LOW)
	assert_eq(low.fog_cards.size() + low.shaft_cards.size(), 0)
	var medium: HazeCards = HazeCards.install(root, spec, Vector3(0.4, -0.6, -0.6), Color.WHITE, Color.WHITE, GraphicsQuality.Level.MEDIUM)
	assert_eq(medium.fog_cards.size(), 3, "fog cards come first")
	assert_eq(medium.shaft_cards.size(), 2)
	medium.build(spec, Vector3(0.4, -0.6, -0.6), Color.WHITE, Color.WHITE, 2)
	assert_eq(medium.fog_cards.size(), 2, "a budget of two keeps the first two fog cards")
	assert_eq(medium.shaft_cards.size(), 0)


# ---- Part 3: battle effect lights and the board grade ------------------------------------------------------------------------------------


func test_battle_lights_pool_respects_the_budget_and_reuses_the_oldest() -> void:
	var lights: BattleLights = BattleLights.new()
	add_child_autofree(lights)
	lights.setup(GraphicsQuality.Level.MEDIUM)
	for i: int in range(5):
		lights.pulse(Vector2(100.0 * float(i), 50.0), Color.RED, 200.0, 1.0, 0.5)
	assert_eq(lights.get_child_count(), GraphicsQuality.effect_lights(GraphicsQuality.Level.MEDIUM), "never more lights than the level's budget")
	var low: BattleLights = BattleLights.new()
	add_child_autofree(low)
	low.setup(GraphicsQuality.Level.LOW)
	low.pulse(Vector2.ZERO, Color.RED)
	low.pulse(Vector2(10.0, 0.0), Color.RED)
	assert_eq(low.get_child_count(), 1, "Low keeps one light")
	for child: Node in lights.get_children():
		assert_false((child as PointLight2D).shadow_enabled, "no 2D shadows (D11)")


func test_mark_lit_sets_the_bit_on_every_canvas_item() -> void:
	var root: Control = Control.new()
	var inner: TextureRect = TextureRect.new()
	var deep: Label = Label.new()
	inner.add_child(deep)
	root.add_child(inner)
	add_child_autofree(root)
	BattleLights.mark_lit(root)
	for item: CanvasItem in [root, inner, deep]:
		assert_true((item.light_mask & BattleLights.LIT_BIT) != 0)


func test_board_grade_follows_the_zone_style_at_half_strength() -> void:
	var neutral: Dictionary = BattleGrade.values_for("")
	assert_almost_eq(float(neutral["warmth"]), 0.0, 0.001)
	assert_eq(neutral["shadow_tint"], Color.WHITE)
	var beefcake: Dictionary = BattleGrade.values_for("beefcake")
	var style: Dictionary = ZoneStyles.style("gainlands").get("grade", {}) as Dictionary
	if style.has("warmth"):
		assert_almost_eq(float(beefcake["warmth"]), float(style["warmth"]) * BattleGrade.STRENGTH, 0.001)
	assert_not_null(BattleGrade.material_for("beefcake").shader)
