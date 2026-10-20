extends GutTest
## Art import Oct 20: a redone UI picture sits beside the first one in the Drive as "<ID>-v2" (both kept); the importer takes the highest revision.

const SOURCE: String = "user://ui_revision_test/source"
const OUT: String = "user://ui_revision_test/out"
const MANIFEST: String = "user://ui_revision_test/manifest.csv"


func before_each() -> void:
	_clean()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SOURCE))


func after_all() -> void:
	_clean()
	UiArt.reset()


func _clean() -> void:
	for dir_path: String in [SOURCE, OUT]:
		var real: String = ProjectSettings.globalize_path(dir_path)
		for file_name: String in DirAccess.get_files_at(real):
			DirAccess.remove_absolute(real.path_join(file_name))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(MANIFEST))


func _save(file_name: String, color: Color) -> void:
	var image: Image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(color)
	image.save_png(ProjectSettings.globalize_path(SOURCE.path_join(file_name)))


func test_the_highest_revision_of_an_id_is_imported() -> void:
	_save("UI-BG-TEST.png", Color(1, 0, 0))
	_save("UI-BG-TEST-v2.png", Color(0, 0, 1))
	_save("UI-NOPE-v2.png", Color(0, 1, 0))
	var result: UiArt.Result = UiArt.import_from_source(ProjectSettings.globalize_path(SOURCE), OUT, MANIFEST, {"UI-BG-TEST": ""})
	assert_eq(result.added, ["UI-BG-TEST"] as Array[String])
	assert_eq(result.unknown, ["UI-NOPE-v2.png"] as Array[String])
	var image: Image = Image.load_from_file(ProjectSettings.globalize_path(OUT.path_join("UI-BG-TEST.webp")))
	assert_not_null(image)
	var centre: Color = image.get_pixel(image.get_width() / 2, image.get_height() / 2)
	assert_gt(centre.b, 0.8, "the -v2 picture (blue) wins over the first one (red)")
