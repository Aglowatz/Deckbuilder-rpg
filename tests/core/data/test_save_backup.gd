extends GutTest
## Overnight Oct 18, Part 3: crash-safe saves. A write goes through a temp file, keeps the previous save as `.bak`, and a missing or
## corrupted save falls back to the backup.

const DIR: String = "user://test_save_backup"
var path: String = DIR + "/slot.json"


func before_each() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DIR))
	SaveSystem.delete(path)


func after_all() -> void:
	SaveSystem.delete(path)


func test_a_write_keeps_the_previous_save_as_backup() -> void:
	assert_true(SaveSystem.write({"gold": 1}, path))
	assert_false(FileAccess.file_exists(SaveSystem.backup_path(path)), "nothing to back up the first time")
	assert_true(SaveSystem.write({"gold": 2}, path))
	assert_eq(int(SaveSystem.read(path).get("gold", 0)), 2)
	assert_eq(int(SaveSystem._parse(SaveSystem.backup_path(path)).get("gold", 0)), 1, "the backup is the previous save")
	assert_false(FileAccess.file_exists(path + ".tmp"), "no temp file left behind")


func test_a_corrupted_save_falls_back_to_the_backup() -> void:
	SaveSystem.write({"gold": 5}, path)
	SaveSystem.write({"gold": 6}, path)
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string("{\"gold\": 7, \"cut off mid-wri")
	file.close()
	assert_eq(int(SaveSystem.read(path).get("gold", 0)), 5, "the damaged save is skipped for its backup")
	assert_true(SaveSystem.write({"gold": 8}, path), "the next write still works")
	assert_eq(int(SaveSystem.read(path).get("gold", 0)), 8)
	assert_eq(int(SaveSystem._parse(SaveSystem.backup_path(path)).get("gold", 0)), 5, "a damaged file never replaces a good backup")


func test_a_missing_save_with_a_backup_still_exists() -> void:
	SaveSystem.write({"gold": 3}, path)
	SaveSystem.write({"gold": 4}, path)
	DirAccess.remove_absolute(path)
	assert_true(SaveSystem.exists(path))
	assert_eq(int(SaveSystem.read(path).get("gold", 0)), 3)
	SaveSystem.delete(path)
	assert_false(SaveSystem.exists(path), "delete removes the backup too")
