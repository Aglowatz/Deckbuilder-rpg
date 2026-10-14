extends GutTest
## Overnight Step 1: the per-area style files of the Art Bible, the swap map and the palette tinting of kit materials.


func after_each() -> void:
	ZoneStyles.use_area("")
	ZoneStyles.reload()
	EnvKit.clear_cache()


func test_every_area_has_a_complete_style_file() -> void:
	for area: String in ZoneStyles.AREAS:
		var data: Dictionary = ZoneStyles.style(area)
		assert_false(data.is_empty(), "%s has data/zone_styles/%s.json" % [area, area])
		assert_gte(ZoneStyles.palette(area).size(), 5, "%s palette has the Art Bible hex codes" % area)
		for key: String in ["light", "fog", "grade", "bloom", "material_swaps", "tints", "time_of_day"]:
			assert_true(data.has(key), "%s defines %s" % [area, key])


func test_swaps_point_at_real_kit_ids() -> void:
	for area: String in ZoneStyles.AREAS:
		var swaps: Dictionary = ZoneStyles.style(area).get("material_swaps", {}) as Dictionary
		for from_id: Variant in swaps.keys():
			assert_true(EnvKit.has(str(from_id)), "%s swaps from a kit id: %s" % [area, str(from_id)])
			assert_true(EnvKit.has(str(swaps[from_id])), "%s swaps to a kit id: %s" % [area, str(swaps[from_id])])


func test_the_town_is_untouched_by_tinting() -> void:
	ZoneStyles.use_area("main_town")
	assert_eq(ZoneStyles.swap("ENV-WALL-TIMBER"), "ENV-WALL-TIMBER")
	assert_eq(ZoneStyles.tint("wall"), Color.WHITE)


func test_a_zone_swaps_and_tints_neutral_kit_surfaces() -> void:
	# The Gainlands has its own kit now (data/art/zone_kits/gainlands.json): the shared surfaces swap to the zone art, which is painted in the palette and not tinted;
	# a neutral kit surface the zone does not swap (the cobble) still wears the zone palette. The Dump keeps the plain swap-and-tint path.
	ZoneStyles.use_area("gainlands")
	assert_eq(ZoneStyles.swap("ENV-WALL-TIMBER"), "GAIN-WALL-BLEACH")
	assert_eq(EnvKit.material("ENV-ROOF-TILE-RED").albedo_color, Color.WHITE, "zone kit art keeps its painted colours")
	var tinted: StandardMaterial3D = EnvKit.material("ENV-GROUND-COBBLE")
	ZoneStyles.use_area("main_town")
	var plain: StandardMaterial3D = EnvKit.material("ENV-GROUND-COBBLE")
	assert_ne(tinted.albedo_color.to_html(), plain.albedo_color.to_html(), "the same neutral kit ground wears the zone palette")
	ZoneStyles.use_area("heap")
	assert_ne(ZoneStyles.swap("ENV-WALL-TIMBER"), "ENV-WALL-TIMBER", "a zone without its own kit swaps within the shared kit")


func test_retint_follows_a_changed_tint() -> void:
	ZoneStyles.use_area("heap")
	var m: StandardMaterial3D = EnvKit.material("ENV-WALL-PLANK")
	var before: String = m.albedo_color.to_html()
	ZoneStyles.use_area("buffet")
	EnvKit.retint()
	assert_ne(m.albedo_color.to_html(), before, "cached materials are recoloured in place")


func test_presets_take_the_style_light() -> void:
	var gain: ZonePreset = StylePresets.get_preset(StylePresets.GAINLANDS)
	var data: Dictionary = ZoneStyles.style("gainlands")
	assert_almost_eq(gain.sun_pitch, float((data["light"] as Dictionary)["key_pitch"]), 0.001)
	assert_eq(ZoneStyles.area_for_preset(StylePresets.CAPITAL_DARK), "capital_outside", "variants share the kit tint of their area")
	var dark: ZonePreset = StylePresets.get_preset(StylePresets.CAPITAL_DARK)
	assert_lt(dark.sun_energy, 0.5, "a variant keeps its own darker light")
