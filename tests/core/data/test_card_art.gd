extends GutTest
## Brief 14, Part F: the card art pipeline. The importer turns files named by Card ID into 768x1152 WebP files, moves the originals,
## honours art_map.csv and reports unknown/missing; cards without art fall back to the placeholder. The images the tests make are
## flat colour test fixtures in user://, not card art.

const ROOT: String = "user://art_test"

var _known: Dictionary = {"C-01": "Village Scout", "C-02": "Village Militia", "T-01": "Meatloaf Golem"}


func before_each() -> void:
	_clean()
	for dir: String in ["inbox", "out", "source"]:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("%s/%s" % [ROOT, dir]))


func after_all() -> void:
	_clean()
	CardArt.clear_cache()


func _clean() -> void:
	var root: String = ProjectSettings.globalize_path(ROOT)
	for dir: String in ["inbox", "out", "source"]:
		if not DirAccess.dir_exists_absolute("%s/%s" % [root, dir]):
			continue
		for file_name: String in DirAccess.get_files_at("%s/%s" % [root, dir]):
			DirAccess.remove_absolute("%s/%s/%s" % [root, dir, file_name])
		DirAccess.remove_absolute("%s/%s" % [root, dir])
	DirAccess.remove_absolute("%s/map.csv" % root)
	DirAccess.remove_absolute("%s/manifest.csv" % root)


func _fixture(file_name: String, width: int, height: int, as_jpg: bool = false) -> void:
	var image: Image = Image.create(width, height, false, Image.FORMAT_RGB8)
	image.fill(Color("3a6ea5"))
	var path: String = ProjectSettings.globalize_path("%s/inbox/%s" % [ROOT, file_name])
	if as_jpg:
		image.save_jpg(path)
	else:
		image.save_png(path)


func _run(map_path: String = "") -> ArtImporter.Result:
	return ArtImporter.import_all("%s/inbox" % ROOT, "%s/out" % ROOT, "%s/source" % ROOT, map_path, _known)


func test_a_card_named_png_becomes_a_768_by_1152_webp_and_the_original_moves() -> void:
	_fixture("C-01.png", 1024, 1024)
	var result: ArtImporter.Result = _run()
	assert_eq(result.added, ["C-01"] as Array[String])
	assert_true(result.errors.is_empty())
	var out: Image = Image.load_from_file(ProjectSettings.globalize_path("%s/out/C-01.webp" % ROOT))
	assert_not_null(out)
	assert_eq(out.get_width(), ArtImporter.WIDTH)
	assert_eq(out.get_height(), ArtImporter.HEIGHT)
	assert_true(FileAccess.file_exists("%s/source/C-01.png" % ROOT), "the original moved to the source folder")
	assert_false(FileAccess.file_exists("%s/inbox/C-01.png" % ROOT), "...and left the inbox")


func test_tokens_and_jpgs_are_accepted() -> void:
	_fixture("T-01.jpg", 600, 1200, true)
	var result: ArtImporter.Result = _run()
	assert_eq(result.added, ["T-01"] as Array[String])
	assert_true(FileAccess.file_exists("%s/out/T-01.webp" % ROOT))


func test_unknown_names_are_reported_and_left_in_the_inbox() -> void:
	_fixture("ZZ-99.png", 100, 150)
	var result: ArtImporter.Result = _run()
	assert_eq(result.unknown, ["ZZ-99.png"] as Array[String])
	assert_true(result.added.is_empty())
	assert_true(FileAccess.file_exists("%s/inbox/ZZ-99.png" % ROOT))


func test_art_map_renames_files_to_card_ids() -> void:
	_fixture("scout_final_v3.png", 300, 450)
	var map_file: FileAccess = FileAccess.open("%s/map.csv" % ROOT, FileAccess.WRITE)
	map_file.store_string("filename,Card ID\nscout_final_v3.png,C-02\n")
	map_file.close()
	var result: ArtImporter.Result = _run("%s/map.csv" % ROOT)
	assert_eq(result.added, ["C-02"] as Array[String])
	assert_true(FileAccess.file_exists("%s/out/C-02.webp" % ROOT))


func test_missing_art_is_listed_and_a_reimport_is_clean() -> void:
	_fixture("C-01.png", 768, 1152)
	var first: ArtImporter.Result = _run()
	assert_eq(first.present, 1)
	assert_eq(first.missing, ["C-02", "T-01"] as Array[String])
	var again: ArtImporter.Result = _run()
	assert_true(again.added.is_empty(), "nothing new in the inbox")
	assert_true(again.unknown.is_empty())
	assert_true(again.errors.is_empty())
	assert_eq(again.present, 1)
	var report: String = ArtImporter.status_markdown("%s/out" % ROOT, _known, again)
	assert_true(report.contains("| C-01 | Village Scout | yes |"))
	assert_true(report.contains("| C-02 | Village Militia | no |"))


func test_a_wide_image_is_cropped_to_two_thirds_not_squashed() -> void:
	var image: Image = Image.create(1500, 900, false, Image.FORMAT_RGB8)
	image.fill(Color.RED)
	var fitted: Image = ArtImporter.fit_image(image)
	assert_eq(fitted.get_size(), Vector2i(768, 1152))


func test_cards_without_art_use_the_placeholder_and_still_build() -> void:
	assert_null(CardArt.texture("ZZ-NOART"))
	assert_false(CardArt.has_art("ZZ-NOART"))
	var card: CardData = Session.content.card("C-01")
	for mode: CardView.Mode in [CardView.Mode.FULL, CardView.Mode.COMPACT, CardView.Mode.BACK]:
		var view: CardView = CardView.create(card, mode)
		add_child_autofree(view)
		assert_gt(view.get_child_count(), 0 if mode == CardView.Mode.BACK else 3)
	assert_eq(CardView.SIZE.x / CardView.SIZE.y, CardArt.ASPECT, "the card frame is 2:3")


func test_square_and_compact_crops_come_from_the_full_art() -> void:
	var fake: ImageTexture = ImageTexture.create_from_image(Image.create(768, 1152, false, Image.FORMAT_RGB8))
	CardArt._cache["TEST-ART"] = fake
	var square: AtlasTexture = CardArt.square("TEST-ART") as AtlasTexture
	assert_eq(square.region.size.x, square.region.size.y, "square")
	var compact: AtlasTexture = CardArt.compact("TEST-ART") as AtlasTexture
	assert_lt(compact.region.size.y, 1152.0, "compact crops the upper-middle")
	assert_almost_eq(compact.region.size.x / compact.region.size.y, 768.0 / 1152.0, 0.01)
	CardArt.clear_cache()


func _drive_fixture(file_name: String, width: int, height: int, color: Color = Color("3a6ea5")) -> void:
	var image: Image = Image.create(width, height, false, Image.FORMAT_RGB8)
	image.fill(color)
	image.save_png(ProjectSettings.globalize_path("%s/inbox/%s" % [ROOT, file_name]))


func _from_source() -> ArtImporter.Result:
	return ArtImporter.import_from_source(ProjectSettings.globalize_path("%s/inbox" % ROOT), "%s/out" % ROOT, "%s/manifest.csv" % ROOT, _known)


func test_source_import_copies_never_moves_and_lists_crops_and_unknowns() -> void:
	_drive_fixture("C-01.png", 768, 1152)
	_drive_fixture("C-02.png", 1000, 1000)
	_drive_fixture("Sketch final.png", 100, 150)
	var notes: FileAccess = FileAccess.open("%s/inbox/notes.txt" % ROOT, FileAccess.WRITE)
	notes.store_string("not an image")
	notes.close()
	var result: ArtImporter.Result = _from_source()
	assert_eq(result.added, ["C-01", "C-02"] as Array[String])
	assert_eq(result.cropped, ["C-02 (1000x1000)"] as Array[String], "only the non-2:3 image was cropped")
	assert_eq(result.unknown, ["Sketch final.png"] as Array[String], "the non-image notes.txt is ignored, not listed")
	assert_true(FileAccess.file_exists("%s/inbox/C-01.png" % ROOT), "the source file is untouched")
	assert_true(FileAccess.file_exists("%s/out/C-02.webp" % ROOT))


func test_source_import_skips_unchanged_and_replaces_changed_art() -> void:
	_drive_fixture("C-01.png", 768, 1152, Color.RED)
	assert_eq(_from_source().added, ["C-01"] as Array[String])
	var again: ArtImporter.Result = _from_source()
	assert_true(again.added.is_empty(), "same file, nothing to do")
	assert_eq(again.unchanged, 1)
	_drive_fixture("C-01.png", 768, 1152, Color.GREEN)
	var changed: ArtImporter.Result = _from_source()
	assert_eq(changed.replaced, ["C-01"] as Array[String])
	assert_eq(changed.added, ["C-01"] as Array[String])


func test_art_picture_is_sized_to_the_card_not_to_the_texture() -> void:
	var fake: ImageTexture = ImageTexture.create_from_image(Image.create(768, 1152, false, Image.FORMAT_RGB8))
	CardArt._cache["C-01"] = fake
	for mode: CardView.Mode in [CardView.Mode.FULL, CardView.Mode.COMPACT]:
		var view: CardView = CardView.create(Session.content.card("C-01"), mode)
		add_child_autofree(view)
		var picture: TextureRect = null
		for child: Node in view.get_children():
			if child is TextureRect and (child as TextureRect).texture != null and not (child as TextureRect).texture is GradientTexture2D:
				picture = child as TextureRect
				break
		assert_not_null(picture, "the art picture exists")
		assert_eq(picture.size, view.art_rect().size, "art fills its window, never the texture size")
	CardArt.clear_cache()
