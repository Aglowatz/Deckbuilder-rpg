extends GutTest
## Battleboard art: the context -> board mapping lives in data/battleboards.json, every mapped board has an image, 3:2 art is centre-cropped to
## 16:9, and the duel factories tag their battles with the right context key. Fixtures are flat colour images made in user://.

const ROOT: String = "user://bb_test"


func before_each() -> void:
	Battleboards.reset()


func after_all() -> void:
	Battleboards.reset()
	var root: String = ProjectSettings.globalize_path(ROOT)
	for dir: String in ["src", "out"]:
		if DirAccess.dir_exists_absolute("%s/%s" % [root, dir]):
			for file_name: String in DirAccess.get_files_at("%s/%s" % [root, dir]):
				DirAccess.remove_absolute("%s/%s/%s" % [root, dir, file_name])
			DirAccess.remove_absolute("%s/%s" % [root, dir])
	DirAccess.remove_absolute("%s/manifest.csv" % root)


func test_mapping_comes_from_data() -> void:
	assert_eq(Battleboards.board_for("zone:beefcake"), "BB-GAIN")
	assert_eq(Battleboards.board_for("capital:in"), "BB-CAP-IN")
	assert_eq(Battleboards.board_for("capital:out"), "BB-CAP-OUT")
	assert_eq(Battleboards.board_for("boss:final"), "BB-PC-BOSS")
	assert_eq(Battleboards.board_for("dungeon:final"), "BB-PC")
	assert_eq(Battleboards.board_for("nonsense"), "")


func test_every_mapped_board_is_in_the_csv_and_has_an_image() -> void:
	var known: Dictionary = Battleboards.known_boards()
	for key: Variant in Battleboards.contexts():
		var id: String = str(Battleboards.contexts()[key])
		assert_true(known.has(id), "%s (%s) is in the CSV" % [id, key])
		assert_true(Battleboards.has_image(id), "%s has an image" % id)


func test_unmapped_or_missing_board_falls_back_to_a_placeholder() -> void:
	assert_not_null(Battleboards.texture_for("nonsense"))
	assert_not_null(Battleboards.texture_for("BB-DOES-NOT-EXIST"))
	assert_not_null(Battleboards.texture_for("zone:gourmand"))


func test_fit_image_centre_crops_3x2_to_16x9_without_stretching() -> void:
	var image: Image = Image.create(1536, 1024, false, Image.FORMAT_RGB8)
	image.fill(Color.BLACK)
	image.fill_rect(Rect2i(0, 0, 1536, 80), Color.RED)
	image.fill_rect(Rect2i(0, 944, 1536, 80), Color.RED)
	image.fill_rect(Rect2i(0, 480, 1536, 64), Color.WHITE)
	assert_true(Battleboards.needs_crop(image))
	var fitted: Image = Battleboards.fit_image(image)
	assert_eq(fitted.get_width(), 1536)
	assert_eq(fitted.get_height(), 864)
	assert_eq(fitted.get_pixel(10, 5), Color.BLACK, "the red edge rows were cropped away")
	assert_eq(fitted.get_pixel(10, 430), Color.WHITE, "the centre band survived")
	assert_false(Battleboards.needs_crop(fitted))


func test_import_copies_only_known_ids_and_never_touches_the_source() -> void:
	var src: String = ProjectSettings.globalize_path("%s/src" % ROOT)
	DirAccess.make_dir_recursive_absolute(src)
	for file_name: String in ["BB-HOG.png", "BB-STRAY.png"]:
		var image: Image = Image.create(300, 200, false, Image.FORMAT_RGB8)
		image.fill(Color("3a6ea5"))
		image.save_png("%s/%s" % [src, file_name])
	var known: Dictionary = {"BB-HOG": ["Gym", "HoG"], "BB-TTK": ["Kitchen", "TTK"]}
	var result: Battleboards.Result = Battleboards.import_from_source(src, "%s/out" % ROOT, "%s/manifest.csv" % ROOT, known)
	assert_eq(result.added, ["BB-HOG"] as Array[String])
	assert_eq(result.unknown, ["BB-STRAY.png"] as Array[String])
	assert_eq(result.missing, ["BB-TTK"] as Array[String])
	assert_true(FileAccess.file_exists("%s/out/BB-HOG.webp" % ROOT))
	assert_eq(DirAccess.get_files_at(src).size(), 2, "the source folder is untouched")
	var again: Battleboards.Result = Battleboards.import_from_source(src, "%s/out" % ROOT, "%s/manifest.csv" % ROOT, known)
	assert_eq(again.unchanged, 1, "an unchanged file is skipped")


func test_factories_tag_their_battles() -> void:
	Session.ensure_game()
	assert_eq(Session.make_practice_battle().board_key, "dungeon:hollow")
	assert_eq(Session.make_graveyard_battle().board_key, "graveyard")
	assert_eq(Session.make_npc_challenge_battle("beefcake").board_key, "town")
	assert_eq(Session.make_arena_battle(ArenaDefs.all()[0].id).board_key, "arena")
