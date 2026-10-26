class_name BuildCache
extends RefCounted
## Performance pass Oct 25, Part 1 (docs/perf/perf_state.md): the expensive, deterministic results of a zone build (painted splat images,
## ground overlay meshes, scatter transforms...) are made once and loaded on later visits instead of being worked out again. The zone
## builders stay the only source of truth: a result is stored under its key plus a hash of every world script and the art/zone data, so
## any change to a builder or its data makes a fresh result on the next load.
##
## - Development: results live in `user://build_cache/<hash>/` (an older hash folder is deleted when a new one is made).
##   `WAYWARD_BUILD_CACHE=off` builds everything live; `=rebuild` rebuilds and overwrites every result it meets (or delete the folder).
## - Export: `tools/bake_build_cache.sh` loads every area so the results land in `res://build_cache/` (with `manifest.json` holding the
##   hash), and the exported game reads them from there; an area state that was not baked is simply built live, as before.
##
## Stored values: an Image or ArrayMesh (saved as a binary resource), or plain data (arrays, packed arrays, dictionaries, numbers,
## strings, vectors, transforms; `store_var` without objects).

const DEV_ROOT: String = "user://build_cache"
const BAKED_ROOT: String = "res://build_cache"
## What the hash covers: every script under these folders and every data file under the data folders.
const SCRIPT_DIRS: Array[String] = ["res://world"]
const DATA_DIRS: Array[String] = ["res://data/art", "res://data/zone_styles", "res://assets/art/textures"]
## (webp: the painted material layers prepared from assets/art/textures)
const DATA_EXTENSIONS: Array[String] = ["json", "csv", "cfg", "tres", "webp"]

## Set by the bake tool: results are written to `res://build_cache/` and the manifest.
static var baking: bool = false
static var _hash: String = ""
static var _mode: String = OS.get_environment("WAYWARD_BUILD_CACHE")
static var _baked_hash: String = ""
static var _baked_checked: bool = false
## `WAYWARD_BUILD_CACHE_SKIP=building,splat` builds the results whose keys start with those words live (bisecting a cache problem).
static var _skip: PackedStringArray = OS.get_environment("WAYWARD_BUILD_CACHE_SKIP").split(",", false)
static var hits: int = 0
static var misses: int = 0


## Returns the stored result for `key`, or calls `build` (no arguments), stores what it returns and returns it.
## `key` must name everything the result depends on besides the scripts and data (zone, story state, quality...).
static func fetch(key: String, build: Callable) -> Variant:
	if _mode == "off":
		return build.call()
	for prefix: String in _skip:
		if key.begins_with(prefix):
			return build.call()
	var safe_key: String = _safe(key)
	if _mode != "rebuild" and not baking:
		var cached: Variant = _read(safe_key)
		if cached != null:
			hits += 1
			return cached
	misses += 1
	var value: Variant = build.call()
	if value != null and not _written.has(safe_key):
		_write(safe_key, value)
		_written[safe_key] = true  # each result is saved once per run (saving the same path twice in one run crashed the bake)
	return value


static var _written: Dictionary = {}


## The hash of the builder scripts and their data (computed once per run; empty in an exported build, which cannot read its sources).
static func source_hash() -> String:
	if not _hash.is_empty():
		return _hash
	if OS.has_feature("template"):
		_hash = "exported"
		return _hash
	var files: PackedStringArray = []
	for dir: String in SCRIPT_DIRS:
		_collect(dir, ["gd", "gdshader", "gdshaderinc"] as Array[String], files)
	for dir: String in DATA_DIRS:
		_collect(dir, DATA_EXTENSIONS, files)
	files.sort()
	var ctx: HashingContext = HashingContext.new()
	ctx.start(HashingContext.HASH_MD5)
	for path: String in files:
		ctx.update(path.to_utf8_buffer())
		if path.ends_with(".webp"):
			# art: its size and date (reading 40 MB of textures every session cost more than the cache saves)
			var file: FileAccess = FileAccess.open(path, FileAccess.READ)
			ctx.update(("%d|%d" % [file.get_length() if file != null else 0, FileAccess.get_modified_time(path)]).to_utf8_buffer())
		else:
			ctx.update(FileAccess.get_file_as_bytes(path))
	_hash = ctx.finish().hex_encode().substr(0, 16)
	return _hash


static func dev_dir() -> String:
	return "%s/%s" % [DEV_ROOT, source_hash()]


## Deletes every development result (the "force a rebuild" command: `bash tools/build_cache.sh clear`).
static func clear() -> void:
	_remove_tree(DEV_ROOT)


static func _read(safe_key: String) -> Variant:
	for base: String in _read_dirs():
		for ext: String in ["res", "bin"]:
			var path: String = "%s/%s.%s" % [base, safe_key, ext]
			if not FileAccess.file_exists(path) and not ResourceLoader.exists(path):
				continue
			if ext == "res":
				var res: Resource = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
				if res != null:
					return res
			else:
				var file: FileAccess = FileAccess.open(path, FileAccess.READ)
				if file != null:
					var value: Variant = file.get_var(false)
					file.close()
					return value
	return null


## Where results are looked for: the baked folder when its manifest matches (always in an exported build), then the development folder.
static func _read_dirs() -> Array[String]:
	var dirs: Array[String] = []
	if _baked_usable():
		dirs.append(BAKED_ROOT)
	if not OS.has_feature("template"):
		dirs.append(dev_dir())
	return dirs


static func _baked_usable() -> bool:
	if not _baked_checked:
		_baked_checked = true
		var manifest: String = BAKED_ROOT + "/manifest.json"
		if FileAccess.file_exists(manifest):
			var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(manifest))
			if parsed is Dictionary:
				_baked_hash = str((parsed as Dictionary).get("hash", ""))
	if _baked_hash.is_empty():
		return false
	return OS.has_feature("template") or _baked_hash == source_hash()


static func _write(safe_key: String, value: Variant) -> void:
	if OS.has_feature("template") and not baking:
		return
	var base: String = BAKED_ROOT if baking else dev_dir()
	if not DirAccess.dir_exists_absolute(base):
		DirAccess.make_dir_recursive_absolute(base)
		if not baking:
			_drop_old_hashes()
	if value is Resource:
		var res: Resource = value as Resource
		var error: Error = ResourceSaver.save(res, "%s/%s.res" % [base, safe_key], ResourceSaver.FLAG_COMPRESS)
		if error != OK:
			push_warning("BuildCache: could not save %s (%d)" % [safe_key, error])
		return
	var file: FileAccess = FileAccess.open("%s/%s.bin" % [base, safe_key], FileAccess.WRITE)
	if file == null:
		return
	file.store_var(value, false)
	file.close()


static func write_manifest() -> void:
	if not DirAccess.dir_exists_absolute(BAKED_ROOT):
		DirAccess.make_dir_recursive_absolute(BAKED_ROOT)
	var file: FileAccess = FileAccess.open(BAKED_ROOT + "/manifest.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"hash": source_hash(), "made": Time.get_datetime_string_from_system()}, "\t"))
	file.close()


static func _drop_old_hashes() -> void:
	var dir: DirAccess = DirAccess.open(DEV_ROOT)
	if dir == null:
		return
	for sub: String in dir.get_directories():
		if sub != source_hash():
			_remove_tree("%s/%s" % [DEV_ROOT, sub])


static func _remove_tree(path: String) -> void:
	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		return
	for file_name: String in dir.get_files():
		dir.remove(file_name)
	for sub: String in dir.get_directories():
		_remove_tree("%s/%s" % [path, sub])
	DirAccess.remove_absolute(path)


static func _collect(dir_path: String, extensions: Array[String], out: PackedStringArray) -> void:
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		return
	for file_name: String in dir.get_files():
		if extensions.has(file_name.get_extension()):
			out.append("%s/%s" % [dir_path, file_name])
	for sub: String in dir.get_directories():
		_collect("%s/%s" % [dir_path, sub], extensions, out)


static func _safe(key: String) -> String:
	var out: String = ""
	for i: int in range(key.length()):
		var c: String = key[i]
		out += c if (c.is_valid_identifier() or c.is_valid_int() or c == "-") else "_"
	if out.length() > 120:
		out = out.substr(0, 100) + "_" + key.md5_text().substr(0, 12)
	return out
