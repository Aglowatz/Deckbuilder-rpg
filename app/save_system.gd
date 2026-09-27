class_name SaveSystem
extends RefCounted
## JSON save/load. The save holds only plain data (ids and numbers); the Session turns ids back
## into cards through the content library.

const PATH: String = "user://save.json"
const VERSION: int = 1


static func exists(path: String = PATH) -> bool:
	return FileAccess.file_exists(path)


static func write(data: Dictionary, path: String = PATH) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_warning("SaveSystem: cannot write %s" % path)
		return false
	var payload: Dictionary = data.duplicate()
	payload["version"] = VERSION
	file.store_string(JSON.stringify(payload, "\t"))
	return true


## Returns the saved dictionary, or an empty one when there is no (valid) save.
static func read(path: String = PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed as Dictionary
	return {}


static func delete(path: String = PATH) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
