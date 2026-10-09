extends GutTest
## The painted texture system (docs/art/style_guide.md, "Painted textures"): every texture the presets name exists, presets build materials, the decal scatter is deterministic
## and respects its masks, and a missing texture falls back instead of crashing.


func before_each() -> void:
	PaintedLibrary.reset_for_tests()


func test_every_csv_texture_is_imported() -> void:
	var file: FileAccess = FileAccess.open("res://data/source/textures.csv.csv", FileAccess.READ)
	assert_not_null(file)
	var checked: int = 0
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() < 4:
			continue
		var id: String = row[0].strip_edges()
		var base: String = id.trim_prefix("TEX-").trim_prefix("DEC-").to_lower().replace("-", "_")
		if id.begins_with("TEX-"):
			assert_true(ResourceLoader.exists("res://assets/art/textures/%s_albedo.webp" % base), "%s albedo" % id)
			assert_true(ResourceLoader.exists("res://assets/art/textures/%s_nr.webp" % base), "%s normal/roughness" % id)
			checked += 1
		elif id.begins_with("DEC-"):
			assert_true(ResourceLoader.exists("res://assets/art/decals/%s.webp" % base), "%s decal" % id)
			checked += 1
	assert_eq(checked, 65, "51 textures + 14 decals")


func test_presets_only_name_existing_textures() -> void:
	var file: FileAccess = FileAccess.open(PaintedLibrary.PRESETS_PATH, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text()) as Dictionary
	for id: String in data.keys():
		if id.begins_with("_"):
			continue
		var preset: Dictionary = PaintedLibrary.preset(StringName(id))
		for layer: Variant in preset.get("layers", []) as Array:
			assert_not_null(PaintedLibrary.albedo(str((layer as Dictionary)["tex"])), "%s layer %s" % [id, (layer as Dictionary)["tex"]])
		for decal: Variant in preset.get("decals", []) as Array:
			assert_not_null(PaintedLibrary.decal(str((decal as Dictionary)["id"])), "%s decal %s" % [id, (decal as Dictionary)["id"]])
		var cliff: Dictionary = preset.get("cliff", {}) as Dictionary
		if not cliff.is_empty():
			assert_not_null(PaintedLibrary.albedo(str(cliff["tex"])), "%s cliff" % id)
	assert_true(PaintedLibrary.missing.is_empty(), "missing: %s" % str(PaintedLibrary.missing.keys()))


func test_town_preset_builds_a_terrain_material() -> void:
	var preset: Dictionary = PaintedLibrary.preset(StylePresets.TOWN)
	assert_false(preset.is_empty())
	var masks: Dictionary = {}
	for name: String in ["plaza", "soil", "sand"]:
		masks[name] = func(_p: Vector2) -> float: return 0.0
	var material: ShaderMaterial = PaintedTerrain.material(preset, {"masks": masks, "bounds": Rect2(0, 0, 20, 20)})
	assert_not_null(material)
	assert_eq(int(material.get_shader_parameter("layer_count")), 5)


func test_missing_base_texture_returns_null() -> void:
	var material: ShaderMaterial = PaintedTerrain.material({"layers": [{"tex": "does_not_exist", "tile": 4.0, "mode": "base"}]})
	assert_null(material, "a zone whose base texture is missing keeps its flat look")
	assert_true(PaintedLibrary.missing.has("does_not_exist"))


func test_unknown_zone_has_no_preset() -> void:
	assert_true(PaintedLibrary.preset(&"no_such_zone").is_empty())


func test_decal_scatter_is_deterministic_and_masked() -> void:
	var entries: Array = [{"id": "moss", "count": 20, "min": 0.5, "max": 1.0, "mask": "left", "mask_min": 0.5}]
	var masks: Dictionary = {"left": func(p: Vector2) -> float: return 1.0 if p.x < 0.0 else 0.0}
	var context: Dictionary = {"bounds": Rect2(-10, -10, 20, 20), "masks": masks, "floor": func(_pos: Vector3) -> bool: return true, "height": func(_pos: Vector3) -> float: return 0.0}
	var first: Array[PaintedDecals.Placement] = PaintedDecals.place(entries, context, 5, 2)
	var second: Array[PaintedDecals.Placement] = PaintedDecals.place(entries, context, 5, 2)
	assert_eq(first.size(), 20)
	assert_eq(first.size(), second.size())
	for index: int in range(first.size()):
		assert_eq(first[index].position, second[index].position)
		assert_lt(first[index].position.x, 0.0, "the mask keeps decals on the left")
		assert_gte(first[index].radius, 0.5)
		assert_lte(first[index].radius, 1.0)


func test_decal_density_follows_quality() -> void:
	var entries: Array = [{"id": "leaves", "count": 20}]
	var context: Dictionary = {"bounds": Rect2(-10, -10, 20, 20), "floor": func(_pos: Vector3) -> bool: return true, "height": func(_pos: Vector3) -> float: return 0.0}
	var low: int = PaintedDecals.place(entries, context, 3, 0).size()
	var high: int = PaintedDecals.place(entries, context, 3, 2).size()
	assert_lt(low, high)


func test_decal_avoid_circles_are_respected() -> void:
	var entries: Array = [{"id": "mud", "count": 30, "min": 0.4, "max": 0.6}]
	var context: Dictionary = {"bounds": Rect2(-5, -5, 10, 10), "avoid": [Vector3(0, 0, 3.0)], "floor": func(_pos: Vector3) -> bool: return true, "height": func(_pos: Vector3) -> float: return 0.0}
	for placement: PaintedDecals.Placement in PaintedDecals.place(entries, context, 9, 2):
		assert_gt(Vector2(placement.position.x, placement.position.z).length(), 3.0)


func test_classifier_separates_materials() -> void:
	assert_eq(PaintedClasses.classify(Color("8a8a8a"), false), PaintedClasses.Kind.STONE)
	assert_eq(PaintedClasses.classify(Color("c98f5e"), false), PaintedClasses.Kind.WOOD)
	assert_eq(PaintedClasses.classify(Color("5fae4c"), false), PaintedClasses.Kind.LEAVES)
	assert_eq(PaintedClasses.classify(Color("5fae4c"), true), PaintedClasses.Kind.NONE, "flat props are never painted as foliage by colour alone")
	assert_eq(PaintedClasses.classify(Color("ff40c0"), false), PaintedClasses.Kind.NONE, "vivid pink stays as it is")


func test_material_array_has_every_layer() -> void:
	var array: Texture2DArray = PaintedLibrary.material_array()
	assert_not_null(array)
	assert_eq(array.get_layers(), PaintedLibrary.MATERIAL_LAYERS.size())


func test_every_imported_texture_is_used_somewhere() -> void:
	var used: PackedStringArray = PaintedLibrary.catalog()
	var imported: PackedStringArray = PackedStringArray()
	for file_name: String in DirAccess.get_files_at("res://assets/art/textures"):
		if file_name.ends_with("_albedo.webp"):
			imported.append(file_name.trim_suffix("_albedo.webp"))
	for file_name: String in DirAccess.get_files_at("res://assets/art/decals"):
		if file_name.ends_with(".webp"):
			imported.append("decal:%s" % file_name.trim_suffix(".webp"))
	for name: String in imported:
		assert_true(used.has(name), "%s is imported but no zone preset, variant or code path uses it" % name)
	for name: String in used:
		assert_true(imported.has(name), "%s is used but not imported" % name)


func test_variants_and_specials_name_existing_textures() -> void:
	var file: FileAccess = FileAccess.open(PaintedLibrary.PRESETS_PATH, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text()) as Dictionary
	for id: String in data.keys():
		if id.begins_with("_"):
			continue
		var preset: Dictionary = PaintedLibrary.preset(StringName(id))
		for variant: Variant in (preset.get("variants", {}) as Dictionary).values():
			for layer: Variant in (variant as Dictionary).get("layers", []) as Array:
				assert_not_null(PaintedLibrary.albedo(str((layer as Dictionary)["tex"])), "%s variant layer" % id)
		for special: Variant in preset.get("special", []) as Array:
			assert_gte(PaintedLibrary.layer_index(str((special as Dictionary)["tex"])), 0, "%s special %s must be in the material array" % [id, (special as Dictionary)["tex"]])
		assert_lte((preset.get("special", []) as Array).size() + (preset.get("atlas_override", {}) as Dictionary).size(), 3, "%s: at most three special kinds" % id)
	assert_true(PaintedLibrary.missing.is_empty())
