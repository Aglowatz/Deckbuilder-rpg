extends GutTest
## Oct 22 art import: a redo sorted beside the first file as "<NAME>-v2" wins in every importer (icons, bestiary, zone kits).


func test_revision_base_strips_the_suffix() -> void:
	assert_eq(ArtImporter.revision_base("ICON-GEAR-STARTERBLADE-v2"), "ICON-GEAR-STARTERBLADE")
	assert_eq(ArtImporter.revision_base("BST-FROZEN-LINE-COOK"), "BST-FROZEN-LINE-COOK")
	assert_eq(ArtImporter.revision_of("GAIN-BD-MESAS-V3"), 3)
	assert_eq(ArtImporter.revision_of("GAIN-BD-MESAS"), 1)


func test_latest_revisions_keeps_the_highest() -> void:
	var files: Array[String] = ["A-v2.png", "A.png", "B.png", "C-v2.png", "C-v3.png", "C.webp"]
	assert_eq(ArtImporter.latest_revisions(files), ["A-v2.png", "B.png", "C-v3.png"] as Array[String])


func test_icon_import_takes_the_redo() -> void:
	var root: String = "user://revision_test"
	var source: String = ProjectSettings.globalize_path(root + "/source")
	DirAccess.make_dir_recursive_absolute(source)
	var old: Image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	old.fill(Color.RED)
	old.save_png(source.path_join("ICON-TEST-ONE.png"))
	var redo: Image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	redo.fill(Color.BLUE)
	redo.save_png(source.path_join("ICON-TEST-ONE-v2.png"))
	var result: IconArt.Result = IconArt.import_from_source(source, root + "/out", root + "/manifest.csv", {"ICON-TEST-ONE": true})
	assert_eq(result.added, ["ICON-TEST-ONE"] as Array[String])
	assert_true(result.unknown.is_empty(), "the -v2 file is not 'matching no ID'")
	var manifest: String = FileAccess.get_file_as_string(root + "/manifest.csv")
	assert_string_contains(manifest, "ICON-TEST-ONE-v2.png")
	for dir: String in ["/out", "/source", ""]:
		for file_name: String in DirAccess.get_files_at(root + dir):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(root + dir).path_join(file_name))
