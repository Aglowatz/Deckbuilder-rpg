class_name SaveGuard
extends RefCounted
## Overnight Nov 16 (Part 3.1): a test run can never write the player's real files. Twice a test run rewrote the owner's campaign 1
## autosave (a test file that switched saving back on at the default path; a run started without its `-gconfig=` flag). The earlier
## guard lived in the Session (`save_path`) and could be undone by any test. This one sits under every file call of the save system:
## in test mode a path inside the player's save folder is turned into the same path under `user://test_saves/` before the file is
## opened, read, written, renamed or deleted, whatever a test sets `Session.save_path`, `SaveSlots.dir` or `CampaignSlots.root` to and
## whatever flags the run was started with.
##
## Test mode: GUT is on the command line (`gut_cmdln.gd`, or any `-gtest` / `-gdir` / `-gconfig` / `-gexit` flag), or the environment
## variable WAYWARD_TEST_SAVES is 1 (a tool that wants the same protection). It is decided once per process and cannot be switched off.
##
## Protected: `user://saves/` (every campaign, slot, autosave, backup, temp file and thumbnail), the pre-slots `user://save.json`,
## the account's feats (`user://feats_account.json`), the title screen's memory (`user://meta.cfg`) and, for writes, the settings
## (`user://settings.cfg`). `tests/test_save_guard.gd` fails when a test run changes any of them; `tools/run_tests.sh` compares the
## real folder before the first shard and after the last one and fails the run when it changed.

const TEST_DIR: String = "user://test_saves/"
const REAL_SAVES: String = "user://saves/"
const REAL_FILES: Array[String] = ["user://save.json", "user://feats_account.json", "user://meta.cfg", "user://settings.cfg"]

static var _mode: int = -1
## The real files as they were when this process first asked (path -> "size|modified time"); see `real_fingerprint`.
static var startup_fingerprint: Dictionary = {}


## True in a test run (see the header). The first call in a test run also empties `TEST_DIR` of an earlier run's files and records
## what the real files look like.
static func test_mode() -> bool:
	if _mode < 0:
		_mode = 1 if _detect() else 0
		if _mode == 1:
			_wipe(TEST_DIR)
			startup_fingerprint = real_fingerprint()
	return _mode == 1


static func _detect() -> bool:
	if OS.get_environment("WAYWARD_TEST_SAVES") == "1":
		return true
	for arg: String in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		if arg.contains("gut_cmdln") or arg.begins_with("-gtest") or arg.begins_with("-gdir") or arg.begins_with("-gconfig") or arg.begins_with("-gexit"):
			return true
	return false


## `path` as the save system may use it: unchanged in the real game, redirected under `TEST_DIR` in a test run when it points at one
## of the player's files.
static func safe(path: String) -> String:
	return redirected(path) if test_mode() else path


## The redirect itself (also for the test): a path inside the protected set becomes the same path under `TEST_DIR`; every other path
## comes back unchanged. An absolute path into the real user folder counts too.
static func redirected(path: String) -> String:
	var normal: String = _user_path(path)
	if normal.begins_with(TEST_DIR):
		return normal
	if normal == REAL_SAVES.trim_suffix("/") or normal.begins_with(REAL_SAVES):
		return TEST_DIR + normal.trim_prefix("user://")
	for file: String in REAL_FILES:
		if normal == file or normal.begins_with(file + "."):
			return TEST_DIR + normal.trim_prefix("user://")
	return path


## True when `path` is one of the player's own files (the protected set).
static func is_protected(path: String) -> bool:
	return redirected(path) != path and not _user_path(path).begins_with(TEST_DIR)


## `path` with back slashes turned, "." and ".." resolved and an absolute path into the user folder written as `user://...`.
static func _user_path(path: String) -> String:
	var normal: String = path.replace("\\", "/")
	var user_root: String = OS.get_user_data_dir().replace("\\", "/").trim_suffix("/")
	if not user_root.is_empty() and normal.to_lower().begins_with(user_root.to_lower() + "/"):
		normal = "user://" + normal.substr(user_root.length() + 1)
	if normal.begins_with("user://"):
		var rest: String = ("/" + normal.trim_prefix("user://")).simplify_path().trim_prefix("/")
		var keeps_slash: bool = normal.ends_with("/") and not rest.is_empty()
		normal = "user://" + rest + ("/" if keeps_slash else "")
	return normal


## What the player's real files look like right now: every file under the real save folder and each protected file, as
## path -> "size|modified time". Read-only.
static func real_fingerprint() -> Dictionary:
	var found: Dictionary = {}
	_scan(REAL_SAVES.trim_suffix("/"), found)
	for file: String in REAL_FILES:
		if FileAccess.file_exists(file):
			found[file] = _stamp(file)
	return found


## The real files that differ between two fingerprints (added, removed or changed), sorted.
static func changed_files(before: Dictionary, after: Dictionary) -> Array[String]:
	var changed: Array[String] = []
	for key: Variant in before.keys():
		if not after.has(key) or str(after[key]) != str(before[key]):
			changed.append(str(key))
	for key: Variant in after.keys():
		if not before.has(key):
			changed.append(str(key))
	changed.sort()
	return changed


static func _stamp(path: String) -> String:
	var length: int = -1
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file != null:
		length = file.get_length()
		file.close()
	return "%d|%d" % [length, FileAccess.get_modified_time(path)]


static func _scan(dir_path: String, found: Dictionary) -> void:
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		return
	for file: String in dir.get_files():
		found[dir_path.path_join(file)] = _stamp(dir_path.path_join(file))
	for sub: String in dir.get_directories():
		_scan(dir_path.path_join(sub), found)


static func _wipe(dir_path: String) -> void:
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		return
	for file: String in dir.get_files():
		dir.remove(file)
	for sub: String in dir.get_directories():
		_wipe(dir_path.path_join(sub))
		dir.remove(sub)
