extends GutTest
## The portrait pipeline (core/data/portraits.gd): naming and expressions, the flat-background remover, scaling, the importer (copy only, manifest, unknown files),
## the fallbacks and the status section. The fixtures are flat colour images made in user://, not NPC art.

const SOURCE: String = "user://portrait_test/source"
const OUT: String = "user://portrait_test/out"
const MANIFEST: String = "user://portrait_test/manifest.csv"
const RED: Color = Color(0.8, 0.1, 0.1, 1.0)
const GRAY: Color = Color(0.82, 0.82, 0.82, 1.0)


func before_each() -> void:
	Portraits.reset()
	_clean()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SOURCE))


func after_all() -> void:
	_clean()


func _clean() -> void:
	for dir: String in [SOURCE, OUT]:
		var real: String = ProjectSettings.globalize_path(dir)
		if DirAccess.dir_exists_absolute(real):
			for file_name: String in DirAccess.get_files_at(real):
				DirAccess.remove_absolute(real.path_join(file_name))
	var manifest: String = ProjectSettings.globalize_path(MANIFEST)
	if FileAccess.file_exists(manifest):
		DirAccess.remove_absolute(manifest)


## A 200x300 image: a red disc (antialiased edge) on `background`.
func _disc(background: Color) -> Image:
	var image: Image = Image.create(200, 300, false, Image.FORMAT_RGBA8)
	image.fill(background)
	for y: int in range(300):
		for x: int in range(200):
			var distance: float = Vector2(x + 0.5, y + 0.5).distance_to(Vector2(100, 150))
			var coverage: float = clampf(60.5 - distance, 0.0, 1.0)
			if coverage > 0.0:
				var mixed: Color = background.lerp(RED, coverage)
				mixed.a = 1.0 if background.a > 0.0 else coverage
				image.set_pixel(x, y, mixed if background.a > 0.0 else Color(RED.r, RED.g, RED.b, coverage))
	return image


func _save(image: Image, file_name: String) -> void:
	image.save_png(ProjectSettings.globalize_path(SOURCE.path_join(file_name)))


func test_split_name() -> void:
	assert_eq(Portraits.split_name("NPC-ELDER"), PackedStringArray(["NPC-ELDER", ""]))
	assert_eq(Portraits.split_name("NPC-PRIMM_ENRAGED"), PackedStringArray(["NPC-PRIMM", "enraged"]))
	assert_eq(Portraits.split_name("V-TONIC_OOPS"), PackedStringArray(["V-TONIC", "oops"]))


func test_a_flat_gray_background_is_removed_without_a_halo() -> void:
	var image: Image = _disc(GRAY)
	assert_true(Portraits.remove_flat_background(image), "a flat border is detected")
	assert_eq(image.get_pixel(2, 2).a, 0.0, "the corner is transparent")
	assert_eq(image.get_pixel(197, 297).a, 0.0)
	assert_almost_eq(image.get_pixel(100, 150).a, 1.0, 0.01, "the subject stays opaque")
	var halo: int = 0
	var edge: int = 0
	for y: int in range(300):
		for x: int in range(200):
			var pixel: Color = image.get_pixel(x, y)
			if pixel.a > 0.15:
				edge += 1
				if absf(pixel.r - RED.r) > 0.12 or absf(pixel.g - RED.g) > 0.12 or absf(pixel.b - RED.b) > 0.12:
					halo += 1
	assert_gt(edge, 1000)
	assert_eq(halo, 0, "no gray left in any visible pixel (edge colours are un-mixed from the background)")


func test_the_background_that_is_inside_the_subject_is_kept() -> void:
	var image: Image = _disc(GRAY)
	for y: int in range(140, 160):
		for x: int in range(90, 110):
			image.set_pixel(x, y, GRAY)
	Portraits.remove_flat_background(image)
	assert_almost_eq(image.get_pixel(100, 150).a, 1.0, 0.01, "a gray patch that is not connected to the border stays")


func test_a_transparent_image_is_left_alone() -> void:
	var image: Image = _disc(Color(0, 0, 0, 0))
	var before: PackedByteArray = image.get_data()
	assert_false(Portraits.remove_flat_background(image))
	assert_eq(image.get_data(), before)


func test_a_busy_background_is_not_touched() -> void:
	var image: Image = Image.create(100, 100, false, Image.FORMAT_RGBA8)
	for y: int in range(100):
		for x: int in range(100):
			image.set_pixel(x, y, Color(float(x) / 100.0, float(y) / 100.0, 0.5, 1.0))
	assert_false(Portraits.remove_flat_background(image), "a gradient is not a flat background")


func test_scaling_keeps_the_ratio_and_never_enlarges() -> void:
	var tall: Image = Image.create(1024, 1536, false, Image.FORMAT_RGBA8)
	var scaled: Image = Portraits.scaled(tall)
	assert_eq(scaled.get_height(), Portraits.HEIGHT)
	assert_eq(scaled.get_width(), 512)
	var small: Image = Image.create(200, 300, false, Image.FORMAT_RGBA8)
	assert_eq(Portraits.scaled(small).get_height(), 300)


func test_import_copies_names_expressions_and_reports_unknown_files() -> void:
	_save(_disc(Color(0, 0, 0, 0)), "NPC-ELDER.png")
	_save(_disc(Color(0, 0, 0, 0)), "NPC-ELDER_HAPPY.png")
	_save(_disc(GRAY), "V-SABLE.png")
	_save(_disc(Color(0, 0, 0, 0)), "NPC-NOBODY.png")
	_save(_disc(Color(0, 0, 0, 0)), "NPC-ELDER_x.txt.bak")
	var known: Dictionary = {"NPC-ELDER": "Elder Maren", "V-SABLE": "Sable", "NPC-PLAYER": "The Wanderer"}
	var result: Portraits.Result = Portraits.import_from_source(SOURCE, OUT, MANIFEST, known)
	assert_eq(result.added, ["NPC-ELDER", "NPC-ELDER_HAPPY", "V-SABLE"] as Array[String])
	assert_eq(result.unknown, ["NPC-NOBODY.png"] as Array[String])
	assert_eq(result.background_removed, ["V-SABLE.png"] as Array[String], "only the flat-gray file was cleaned")
	assert_eq(result.have, ["NPC-ELDER", "V-SABLE"] as Array[String])
	assert_eq(result.missing, ["NPC-PLAYER"] as Array[String], "IDs of the list with no image are reported")
	for name: String in ["NPC-ELDER.webp", "NPC-ELDER_HAPPY.webp", "V-SABLE.webp"]:
		assert_true(FileAccess.file_exists(ProjectSettings.globalize_path(OUT.path_join(name))), name)
	# The source folder is untouched.
	assert_eq(DirAccess.get_files_at(ProjectSettings.globalize_path(SOURCE)).size(), 5)


func test_the_output_keeps_its_transparency() -> void:
	_save(_disc(Color(0, 0, 0, 0)), "NPC-ELDER.png")
	Portraits.import_from_source(SOURCE, OUT, MANIFEST, {"NPC-ELDER": "Elder Maren"})
	var image: Image = Image.load_from_file(ProjectSettings.globalize_path(OUT.path_join("NPC-ELDER.webp")))
	assert_not_null(image)
	assert_lt(image.get_pixel(1, 1).a, 0.05, "the corner is still transparent")
	assert_gt(image.get_pixel(100, 150).a, 0.95)


func test_a_second_import_skips_unchanged_files_and_replaces_changed_ones() -> void:
	_save(_disc(Color(0, 0, 0, 0)), "NPC-ELDER.png")
	var known: Dictionary = {"NPC-ELDER": "Elder Maren"}
	Portraits.import_from_source(SOURCE, OUT, MANIFEST, known)
	var again: Portraits.Result = Portraits.import_from_source(SOURCE, OUT, MANIFEST, known)
	assert_eq(again.unchanged, 1)
	assert_eq(again.added.size(), 0)
	_save(_disc(GRAY), "NPC-ELDER.png")
	var changed: Portraits.Result = Portraits.import_from_source(SOURCE, OUT, MANIFEST, known)
	assert_eq(changed.replaced, ["NPC-ELDER"] as Array[String])


func test_the_game_has_a_portrait_for_every_npc_and_falls_back_to_the_base() -> void:
	for entry: NpcRegistry.Entry in NpcRegistry.all():
		if PortraitPlaceholders.has(entry.portrait_id):
			continue  # Shiro Swindle and the Warden use a code-drawn stand-in until their art is imported
		assert_true(Portraits.has_portrait(entry.portrait_id), "%s has a portrait" % entry.portrait_id)
	var base: Texture2D = Portraits.texture_for("NPC-ELDER")
	assert_not_null(base)
	assert_eq(Portraits.texture_for("NPC-ELDER", "furious"), base, "an expression with no image falls back to the base portrait")
	assert_ne(Portraits.texture_for("NPC-ELDER", "happy"), base, "an expression that exists is used")
	assert_eq(Portraits.texture_for("NPC-ELDER", ""), base)
	assert_null(Portraits.texture_for("NPC-DOES-NOT-EXIST"))
	assert_null(Portraits.texture_for(""))
	assert_true(Portraits.has_expression("NPC-PLAYER", "confused"))
	assert_false(Portraits.has_expression("NPC-PLAYER", "furious"))


func test_the_source_folder_is_configured() -> void:
	assert_eq(Portraits.source_dir(), "G:/My Drive/Card Game Art/Approved_Characters")


func test_status_sections_are_replaced_without_touching_the_others() -> void:
	var text: String = "# Card art status\n\nrows\n\n## Battleboards\n\nboards\n\n## Portraits\n\nold\n\n## Other\n\nkeep\n"
	var replaced: String = Portraits.replace_section(text, "## Portraits", "## Portraits\n\nnew\n")
	assert_true(replaced.contains("boards"))
	assert_true(replaced.contains("new"))
	assert_false(replaced.contains("old"))
	assert_true(replaced.contains("## Other\n\nkeep"))
	var appended: String = Portraits.replace_section("# Status\n", "## Portraits", "## Portraits\n\nnew\n")
	assert_true(appended.ends_with("## Portraits\n\nnew\n"))
	assert_true(Portraits.status_markdown().contains("| NPC-ELDER | Elder Maren | yes |"))
