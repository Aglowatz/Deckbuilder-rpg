class_name SaveSystem
extends RefCounted
## JSON save/load. The save holds only plain data (ids and numbers); the Session turns ids back
## into cards through the content deck.

## The autosave (see SaveSlots). The pre-slots single save lived at user://save.json and is migrated into slot 1.
const PATH: String = "user://saves/autosave.json"
const VERSION: int = 1


static func exists(path: String = PATH) -> bool:
	return FileAccess.file_exists(path) or FileAccess.file_exists(backup_path(path))


## Overnight Oct 18, Part 3: crash-safe. The new save is written to `<path>.tmp` first and read back; only a complete file replaces the
## old one, and the previous save is kept as `<path>.bak` (what `read` falls back to when the main file is missing or corrupted).
static func write(data: Dictionary, path: String = PATH) -> bool:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var temp: String = path + ".tmp"
	var file: FileAccess = FileAccess.open(temp, FileAccess.WRITE)
	if file == null:
		push_warning("SaveSystem: cannot write %s" % temp)
		return false
	var payload: Dictionary = data.duplicate()
	payload["version"] = VERSION
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	if _parse(temp).is_empty():
		push_warning("SaveSystem: the new save %s did not read back; the old one is kept" % temp)
		DirAccess.remove_absolute(temp)
		return false
	if FileAccess.file_exists(path):
		if _parse(path).is_empty():
			DirAccess.remove_absolute(path)
		else:
			var backup: String = backup_path(path)
			if FileAccess.file_exists(backup):
				DirAccess.remove_absolute(backup)
			DirAccess.rename_absolute(path, backup)
	return DirAccess.rename_absolute(temp, path) == OK


## Where the previous save of `path` is kept.
static func backup_path(path: String = PATH) -> String:
	return path + ".bak"


## Returns the saved dictionary, or an empty one when there is no (valid) save. A missing or corrupted file falls back to its backup.
static func read(path: String = PATH) -> Dictionary:
	var data: Dictionary = _parse(path)
	if data.is_empty() and FileAccess.file_exists(backup_path(path)):
		data = _parse(backup_path(path))
		if not data.is_empty():
			print("SaveSystem: %s is missing or damaged; loaded its backup" % path)
	return data


static func _parse(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	# JSON.new().parse fails quietly on a damaged file (JSON.parse_string logs an engine error).
	var json: JSON = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return {}
	if json.data is Dictionary:
		return json.data as Dictionary
	return {}


static func delete(path: String = PATH) -> void:
	for each: String in [path, backup_path(path), path + ".tmp"]:
		if FileAccess.file_exists(each):
			DirAccess.remove_absolute(each)
