extends GutTest
## Playtest release checks: one version everywhere, the game starts at the title, debug content is off in a release build,
## and the feedback report is written with its notes and state.

const TMP: String = "user://test_feedback"


func after_each() -> void:
	var abs_root: String = ProjectSettings.globalize_path(TMP)
	if DirAccess.dir_exists_absolute(abs_root):
		for sub: String in DirAccess.get_directories_at(abs_root):
			for file: String in DirAccess.get_files_at("%s/%s" % [abs_root, sub]):
				DirAccess.remove_absolute("%s/%s/%s" % [abs_root, sub, file])
			DirAccess.remove_absolute("%s/%s" % [abs_root, sub])
		DirAccess.remove_absolute(abs_root)


func test_export_presets_carry_the_project_version() -> void:
	var version: String = FeedbackReport.version()
	assert_ne(version, "0.0.0")
	var text: String = FileAccess.get_file_as_string("res://export_presets.cfg")
	assert_true(text.contains("application/version=\"%s\"" % version), "mac export version matches")
	assert_true(text.contains("application/short_version=\"%s\"" % version), "mac short version matches")
	assert_true(text.contains("application/file_version=\"%s.0\"" % version), "windows file version matches")


func test_game_starts_at_the_title_screen() -> void:
	assert_eq(str(ProjectSettings.get_setting("application/run/main_scene")), "res://scenes/title.tscn")


func test_release_build_has_no_dev_content() -> void:
	assert_false(DevTools.shrine_enabled(false))
	assert_false(bool(ProjectSettings.get_setting(DevTools.SETTING_PATH, false)), "no project override for the dev shrine")
	var filter: String = FileAccess.get_file_as_string("res://export_presets.cfg")
	assert_true(filter.contains("tests/*"), "test scenes (camera tuning panel, F1-F6 presets) are not exported")


func test_report_is_written_with_rating_notes_and_state() -> void:
	var image: Image = Image.create(8, 8, false, Image.FORMAT_RGB8)
	var when: Dictionary = {"year": 2026, "month": 10, "day": 13, "hour": 9, "minute": 5, "second": 7}
	var dir: String = FeedbackReport.write(4, "the vendor sign is blurry", image, TMP, when)
	assert_false(dir.is_empty())
	assert_true(FileAccess.file_exists("%s/report.json" % dir))
	assert_true(FileAccess.file_exists("%s/screenshot.png" % dir))
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("%s/report.json" % dir))
	assert_eq(int(data["rating"]), 4)
	assert_eq(str(data["notes"]), "the vendor sign is blurry")
	assert_eq(str((data["state"] as Dictionary)["version"]), FeedbackReport.version())
	var second: String = FeedbackReport.write(1, "", null, TMP, when)
	assert_ne(second, dir, "two reports in the same second never overwrite each other")
