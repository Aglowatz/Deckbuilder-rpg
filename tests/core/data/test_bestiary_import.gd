extends GutTest
## Oct 19 night (Part 3): the Bestiary picture importer (core/data/bestiary_art.gd, `bash tools/import_bestiary.sh`): copy only from the read-only Drive
## folder, BST IDs from the Bestiary, square WebP at most 512 px, forgiving names, unknown files reported, never the review folders.

const SOURCE: String = "user://bestiary_test/source"
const OUT: String = "user://bestiary_test/out"
const MANIFEST: String = "user://bestiary_test/manifest.csv"


func before_each() -> void:
	_clean()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SOURCE))


func after_all() -> void:
	_clean()
	Bestiary.reset_art()


func _clean() -> void:
	for dir: String in [SOURCE, OUT]:
		var real: String = ProjectSettings.globalize_path(dir)
		if DirAccess.dir_exists_absolute(real):
			for file_name: String in DirAccess.get_files_at(real):
				DirAccess.remove_absolute(real.path_join(file_name))
	var manifest: String = ProjectSettings.globalize_path(MANIFEST)
	if FileAccess.file_exists(manifest):
		DirAccess.remove_absolute(manifest)


func _save(width: int, height: int, file_name: String) -> void:
	var image: Image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.2, 0.3, 0.5))
	image.fill_rect(Rect2i(0, 0, width, mini(width, height) / 4), Color(0.9, 0.2, 0.2))  # a red band at the top (the "head")
	image.save_png(ProjectSettings.globalize_path(SOURCE.path_join(file_name)))


func test_the_source_folder_is_configured() -> void:
	assert_eq(BestiaryArt.source_dir(), "G:/My Drive/Card Game Art/Approved_Bestiary")
	assert_false(BestiaryArt.is_forbidden_source(BestiaryArt.source_dir()))
	assert_true(BestiaryArt.is_forbidden_source("G:/My Drive/Card Game Art/Pending Review"))


func test_known_ids_are_the_bestiary_art_ids() -> void:
	var known: Dictionary = BestiaryArt.known_ids()
	assert_eq(known.size(), Bestiary.all().size(), "one picture per entry")
	assert_true(known.has("BST-CAVE-SCAVENGER"))
	assert_true(known.has("BST-BARON-QUADZILLA"))
	for id: Variant in known:
		assert_true(str(id).begins_with("BST-"), str(id))


func test_file_names_match_forgivingly() -> void:
	var known: Dictionary = {"BST-CAVE-SCAVENGER": "Cave Scavenger"}
	assert_eq(BestiaryArt.file_id("BST-CAVE-SCAVENGER", known), "BST-CAVE-SCAVENGER")
	assert_eq(BestiaryArt.file_id("bst_cave_scavenger", known), "BST-CAVE-SCAVENGER")
	assert_eq(BestiaryArt.file_id("BST CAVE  SCAVENGER", known), "BST-CAVE-SCAVENGER")
	assert_eq(BestiaryArt.file_id("BST-NOBODY", known), "")


func test_squared_keeps_the_top_of_a_portrait() -> void:
	var tall: Image = Image.create(100, 150, false, Image.FORMAT_RGBA8)
	tall.fill(Color(0, 0, 1))
	tall.fill_rect(Rect2i(0, 0, 100, 10), Color(1, 0, 0))
	var square: Image = BestiaryArt.squared(tall)
	assert_eq(square.get_size(), Vector2i(100, 100))
	assert_almost_eq(square.get_pixel(50, 2).r, 1.0, 0.01, "the head (top) stays in")
	var wide: Image = Image.create(300, 200, false, Image.FORMAT_RGBA8)
	assert_eq(BestiaryArt.squared(wide).get_size(), Vector2i(200, 200), "a wide picture is centred across")


func test_the_import_copies_squares_and_reports() -> void:
	_save(1024, 1024, "BST-CAVE-SCAVENGER.png")
	_save(1024, 1536, "bst_hollow_stalker.png")
	_save(300, 300, "BST-TIDY-BOT.png")
	_save(512, 512, "BST-NOBODY.png")
	var known: Dictionary = {"BST-CAVE-SCAVENGER": "Cave Scavenger", "BST-HOLLOW-STALKER": "Hollow Stalker", "BST-TIDY-BOT": "Tidy-Bot", "BST-RIFT-WRETCH": "Rift Wretch"}
	var result: BestiaryArt.Result = BestiaryArt.import_from_source(ProjectSettings.globalize_path(SOURCE), OUT, MANIFEST, known)
	assert_eq(result.added.size(), 3)
	assert_eq(result.unknown, ["BST-NOBODY.png"] as Array[String])
	assert_eq(result.missing, ["BST-RIFT-WRETCH"] as Array[String])
	assert_eq(result.renamed, ["bst_hollow_stalker.png -> BST-HOLLOW-STALKER"] as Array[String])
	assert_eq(result.cropped.size(), 1, "the 2:3 picture is cropped to a square")
	var big: Image = Image.load_from_file(ProjectSettings.globalize_path(OUT.path_join("BST-CAVE-SCAVENGER.webp")))
	assert_eq(big.get_size(), Vector2i(BestiaryArt.SIDE, BestiaryArt.SIDE), "scaled down to 512")
	var tall: Image = Image.load_from_file(ProjectSettings.globalize_path(OUT.path_join("BST-HOLLOW-STALKER.webp")))
	assert_eq(tall.get_size(), Vector2i(BestiaryArt.SIDE, BestiaryArt.SIDE))
	var small: Image = Image.load_from_file(ProjectSettings.globalize_path(OUT.path_join("BST-TIDY-BOT.webp")))
	assert_eq(small.get_size(), Vector2i(300, 300), "never scaled up")
	assert_eq(DirAccess.get_files_at(ProjectSettings.globalize_path(SOURCE)).size(), 4, "the source folder is untouched")
	var again: BestiaryArt.Result = BestiaryArt.import_from_source(ProjectSettings.globalize_path(SOURCE), OUT, MANIFEST, known)
	assert_eq(again.unchanged, 3, "unchanged files are skipped")
	assert_eq(again.added.size(), 0)


func test_a_review_folder_is_refused() -> void:
	var result: BestiaryArt.Result = BestiaryArt.import_from_source("G:/My Drive/Card Game Art/Pending Review", OUT, MANIFEST, {"BST-TIDY-BOT": ""})
	assert_eq(result.added.size(), 0)
	assert_eq(result.errors.size(), 1)


func test_the_status_section_lists_every_entry() -> void:
	var text: String = BestiaryArt.status_markdown()
	assert_true(text.begins_with(BestiaryArt.STATUS_MARKER))
	assert_true(text.contains("| BST-CAVE-SCAVENGER | Cave Scavenger |"))
