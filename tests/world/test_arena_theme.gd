extends GutTest
## ArenaTheme (battle table per zone, graphics loop BB-* tasks): every zone has a theme with dressing, a landmark and a valid preset, and each listed model exists.

const ZONES: Array[String] = ["", "necrocrat", "beefcake", "gourmand", "refusemancer", "final"]


func test_every_zone_has_rim_and_landmark() -> void:
	for zone: String in ZONES:
		var theme: ArenaTheme = ArenaTheme.for_zone(zone)
		assert_gt(theme.rim.size(), 3, "rim of '%s'" % zone)
		assert_gt(theme.landmark.size(), 2, "landmark of '%s'" % zone)
		assert_true(StylePresets.ids().has(theme.preset_id), "preset of '%s'" % zone)


func test_model_files_exist() -> void:
	for zone: String in ZONES:
		var theme: ArenaTheme = ArenaTheme.for_zone(zone)
		for item: Array in theme.rim + theme.landmark:
			var folder: String = str(item[0])
			var model: String = str(item[1])
			var path: String = "%s%s.glb" % [folder, model] if folder.begins_with("res://") else ""
			if folder.begins_with("res://"):
				assert_true(ResourceLoader.exists(path) or FileAccess.file_exists(path), "%s (%s)" % [path, zone])


func test_zone_presets_lose_the_haze_on_the_table() -> void:
	var theme: ArenaTheme = ArenaTheme.for_zone("gourmand")
	assert_eq(theme.table_preset().volumetric_density, 0.0)
	assert_lte(theme.table_preset().ambient_energy, 0.5)
