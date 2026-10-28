class_name FeatAccount
extends RefCounted
## Overnight Oct 27-28, Part 3: the account-wide feat record (every campaign slot together): the first time any slot earned a feat, so a
## reward is paid once per account and the Feats screen shows everything ever earned. A JSON file beside the saves (`path`; tests
## redirect it). Writing is skipped when the session's saving is off (`enabled`), like TitleMeta.

const VERSION: int = 1

static var path: String = "user://feats_account.json"
static var _loaded: bool = false
static var _unlocked: Dictionary = {}


## Forgets the in-memory record (tests; a changed `path`).
static func reset() -> void:
	_loaded = false
	_unlocked = {}


static func _load() -> void:
	if _loaded:
		return
	_loaded = true
	_unlocked = {}
	if not FileAccess.file_exists(path):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed is Dictionary:
		for key: Variant in ((parsed as Dictionary).get("unlocked", {}) as Dictionary).keys():
			_unlocked[str(key)] = int(((parsed as Dictionary)["unlocked"] as Dictionary)[key])


static func has(id: String) -> bool:
	_load()
	return _unlocked.has(id)


static func unlocked_ids() -> Array[String]:
	_load()
	var ids: Array[String] = []
	for key: Variant in _unlocked.keys():
		ids.append(str(key))
	ids.sort()
	return ids


static func count() -> int:
	_load()
	return _unlocked.size()


## Records `id` for the account. Returns true the FIRST time (the reward is paid then); `enabled` false keeps the record in memory only.
static func record(id: String, enabled: bool = true) -> bool:
	_load()
	if _unlocked.has(id):
		return false
	_unlocked[id] = int(Time.get_unix_time_from_system())
	if enabled:
		_save()
	return true


static func _save() -> void:
	var dir: String = path.get_base_dir()
	if not dir.is_empty():
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify({"version": VERSION, "unlocked": _unlocked}, "\t"))
	file.close()
