extends GutTest
## The style foundation: toon conversion, presets, quality levels, settings.


func test_every_preset_id_resolves_with_a_coloured_shadow() -> void:
	for id: StringName in StylePresets.ids():
		var preset: ZonePreset = StylePresets.get_preset(id)
		assert_eq(preset.id, id, "%s has its own id" % id)
		var ambient: Color = preset.ambient_color
		assert_false(is_equal_approx(ambient.r, ambient.g) and is_equal_approx(ambient.g, ambient.b), "%s: the ambient (shadow) colour is never gray" % id)


func test_dna_is_the_monochrome_preset() -> void:
	var dna: ZonePreset = StylePresets.get_preset(StylePresets.DNA)
	assert_gt(dna.desaturate, 0.85, "near-monochrome")
	assert_false(dna.use_sky, "no sky in the D.N.A.")
	assert_gt(dna.accent.r, dna.accent.g * 3.0, "the accent is red")
	assert_eq(StylePresets.get_preset(StylePresets.TOWN).desaturate, 0.0)


func test_zone_ids_map_to_presets() -> void:
	assert_eq(StylePresets.for_zone(DnaZone.ID), StylePresets.DNA)
	assert_eq(StylePresets.for_zone(GainlandsZone.ID), StylePresets.GAINLANDS)
	assert_eq(StylePresets.for_zone(BuffetZone.ID), StylePresets.BUFFET)
	assert_eq(StylePresets.for_zone(HeapZone.ID), StylePresets.HEAP)
	assert_eq(StylePresets.for_zone(CapitalZone.ID), StylePresets.CAPITAL_OUTSKIRTS)
	assert_eq(StylePresets.capital(true, false), StylePresets.CAPITAL_DARK)
	assert_eq(StylePresets.capital(false, true), StylePresets.CAPITAL_FREED)


func test_quality_levels_toggle_the_expensive_parts() -> void:
	assert_false(GraphicsQuality.outlines(GraphicsQuality.Level.LOW))
	assert_true(GraphicsQuality.outlines(GraphicsQuality.Level.MEDIUM))
	assert_false(GraphicsQuality.volumetric_fog(GraphicsQuality.Level.MEDIUM))
	assert_true(GraphicsQuality.volumetric_fog(GraphicsQuality.Level.HIGH))
	assert_false(GraphicsQuality.ssao(GraphicsQuality.Level.LOW))
	assert_eq(GraphicsQuality.shadow_detail(GraphicsQuality.Level.LOW), 0)
	assert_false(GraphicsQuality.dof_allowed(GraphicsQuality.Level.LOW))
	assert_lt(GraphicsQuality.foliage_density(GraphicsQuality.Level.LOW), GraphicsQuality.foliage_density(GraphicsQuality.Level.HIGH))


func test_foliage_keep_is_stable_and_scales_with_level() -> void:
	var low: int = 0
	var high: int = 0
	for index: int in range(400):
		if GraphicsQuality.keep_item(GraphicsQuality.Level.LOW, index):
			low += 1
		if GraphicsQuality.keep_item(GraphicsQuality.Level.HIGH, index):
			high += 1
		assert_eq(GraphicsQuality.keep_item(GraphicsQuality.Level.MEDIUM, index), GraphicsQuality.keep_item(GraphicsQuality.Level.MEDIUM, index))
	assert_eq(high, 400, "High keeps everything")
	assert_lt(low, 250, "Low keeps well under all of it")
	assert_gt(low, 100)


func test_toon_converts_standard_materials_and_keeps_the_atlas() -> void:
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.mesh = BoxMesh.new()
	var material: StandardMaterial3D = StandardMaterial3D.new()
	var image: Image = Image.create(4, 4, false, Image.FORMAT_RGBA8)
	image.fill(Color.RED)
	material.albedo_texture = ImageTexture.create_from_image(image)
	material.albedo_color = Color(0.5, 0.6, 0.7)
	mesh_instance.mesh.surface_set_material(0, material)
	var converted: int = StyleToon.apply_mesh(mesh_instance)
	assert_eq(converted, 1)
	var toon: ShaderMaterial = mesh_instance.get_surface_override_material(0) as ShaderMaterial
	assert_not_null(toon)
	assert_eq(toon.get_shader_parameter("albedo_tex"), material.albedo_texture, "same atlas")
	assert_eq(toon.get_shader_parameter("albedo"), Color(0.5, 0.6, 0.7))
	mesh_instance.free()


func test_toon_skips_unshaded_blended_and_marked_materials() -> void:
	var unshaded: StandardMaterial3D = StandardMaterial3D.new()
	unshaded.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	assert_null(StyleToon.toon_for(unshaded))
	var blended: StandardMaterial3D = StandardMaterial3D.new()
	blended.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	assert_null(StyleToon.toon_for(blended))
	var scissor: StandardMaterial3D = StandardMaterial3D.new()
	scissor.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	assert_not_null(StyleToon.toon_for(scissor), "alpha scissor foliage is converted")
	var marked: MeshInstance3D = MeshInstance3D.new()
	marked.mesh = BoxMesh.new()
	marked.set_meta(StyleToon.META_NO_TOON, true)
	assert_eq(StyleToon.apply_mesh(marked), 0)
	marked.free()


func test_toon_shader_compiles() -> void:
	assert_not_null(StyleToon.shader())
	assert_true(StyleToon.shader().code.contains("light()"))
	assert_true(StyleToon.double_sided_shader().code.contains("cull_disabled"))


func test_settings_round_trip_quality_fields() -> void:
	var before_quality: int = Settings.graphics_quality
	var before_dof: bool = Settings.depth_of_field
	Settings.graphics_quality = GraphicsQuality.Level.HIGH
	Settings.depth_of_field = true
	Settings.save_settings()
	Settings.graphics_quality = GraphicsQuality.Level.LOW
	Settings.depth_of_field = false
	Settings.load_settings()
	assert_eq(Settings.graphics_quality, GraphicsQuality.Level.HIGH)
	assert_true(Settings.depth_of_field)
	Settings.graphics_quality = before_quality
	Settings.depth_of_field = before_dof
	Settings.save_settings()
