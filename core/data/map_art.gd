class_name MapArt
extends RefCounted
## Dungeon map art (docs/art/art_pipeline.md, "Dungeon maps"): `assets/art/maps/<Map Image ID>.webp`, e.g. MAP-HOG.webp, one painted 3:2 map per dungeon of the
## dungeon list. The importer copies from the read-only Drive folder in `art_config.cfg` (`map_dir`), never crops (nodes may sit near the edges) and writes WebP
## at the source size (at most 1536 px wide). Nothing in the Drive folder is moved, renamed or deleted. A dungeon without an image keeps its placeholder map.

const OUT_DIR: String = "res://assets/art/maps"
const MANIFEST_PATH: String = "res://data/source/map_import_manifest.csv"
const CONFIG_PATH: String = "res://data/source/art_config.cfg"
const STATUS_MARKER: String = "## Dungeon maps"
const MAX_WIDTH: int = 1536
const QUALITY: float = 0.9
const INPUT_EXTENSIONS: Array[String] = ["png", "webp", "jpg", "jpeg"]
const RATIO: float = 1.5

static var _textures: Dictionary = {}


class Result extends RefCounted:
	var added: Array[String] = []
	var replaced: Array[String] = []
	var unchanged: int = 0
	## Files whose picture is not 3:2 (kept as they are, never cropped).
	var not_three_two: Array[String] = []
	var unknown: Array[String] = []
	var errors: Array[String] = []
	var have: Array[String] = []
	var missing: Array[String] = []


## The map texture of a Map Image ID, null when the dungeon has no image yet.
static func texture_for(map_id: String) -> Texture2D:
	if map_id.is_empty():
		return null
	if not _textures.has(map_id):
		var path: String = OUT_DIR.path_join("%s.webp" % map_id)
		_textures[map_id] = load(path) as Texture2D if ResourceLoader.exists(path) else null
	return _textures[map_id] as Texture2D


static func has_map(map_id: String) -> bool:
	return not map_id.is_empty() and ResourceLoader.exists(OUT_DIR.path_join("%s.webp" % map_id))


static func reset() -> void:
	_textures = {}


## The configured Drive folder (env MAP_SOURCE_DIR wins), "" when unset.
static func source_dir() -> String:
	var dir: String = OS.get_environment("MAP_SOURCE_DIR")
	if dir.is_empty():
		var config: ConfigFile = ConfigFile.new()
		if config.load(CONFIG_PATH) == OK:
			dir = str(config.get_value("art", "map_dir", ""))
	return dir.replace("\\", "/").rstrip("/")


## {Map Image ID -> dungeon name} of the dungeon list.
static func known_maps() -> Dictionary:
	var known: Dictionary = {}
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		if not blueprint.map_id.is_empty():
			known[blueprint.map_id] = blueprint.dungeon_name
	return known


## Copies `<Map ID>.png|jpg|webp` files from `source` (read-only) to `out_dir` as WebP. A file is re-imported when its MD5 differs from the manifest.
static func import_from_source(source: String, out_dir: String, manifest_path: String, known: Dictionary) -> Result:
	var result: Result = Result.new()
	DirAccess.make_dir_recursive_absolute(_real(out_dir))
	var manifest: Dictionary = ArtImporter.read_manifest(_real(manifest_path))
	var rows: Dictionary = {}
	var files: Array[String] = []
	for file_name: String in DirAccess.get_files_at(source):
		files.append(file_name)
	files.sort()
	for file_name: String in files:
		if not INPUT_EXTENSIONS.has(file_name.get_extension().to_lower()):
			continue
		var id: String = file_name.get_basename()
		if not known.has(id):
			result.unknown.append(file_name)
			continue
		var full_path: String = source.path_join(file_name)
		var hash: String = FileAccess.get_md5(full_path)
		var target: String = _real(out_dir.path_join("%s.webp" % id))
		var had: bool = FileAccess.file_exists(target)
		rows[id] = PackedStringArray([id, file_name, str(_size(full_path)), hash])
		if had and str(manifest.get(id, "")) == hash:
			result.unchanged += 1
			continue
		var image: Image = Image.load_from_file(full_path)
		if image == null or image.is_empty():
			result.errors.append("%s: not a readable image" % file_name)
			rows.erase(id)
			continue
		if absf(float(image.get_width()) / float(image.get_height()) - RATIO) / RATIO > 0.01:
			result.not_three_two.append("%s (%dx%d)" % [file_name, image.get_width(), image.get_height()])
		image.convert(Image.FORMAT_RGB8)
		if image.get_width() > MAX_WIDTH:
			image.resize(MAX_WIDTH, int(round(float(image.get_height()) * float(MAX_WIDTH) / float(image.get_width()))), Image.INTERPOLATE_LANCZOS)
		var error: Error = image.save_webp(target, true, QUALITY)
		if error != OK:
			result.errors.append("%s: could not write (error %d)" % [file_name, error])
			rows.erase(id)
			continue
		result.added.append(id)
		if had:
			result.replaced.append(id)
	_write_manifest(_real(manifest_path), rows)
	var ids: Array = known.keys()
	ids.sort()
	for id: Variant in ids:
		if FileAccess.file_exists(_real(out_dir.path_join("%s.webp" % str(id)))):
			result.have.append(str(id))
		else:
			result.missing.append(str(id))
	reset()
	return result


static func _size(path: String) -> int:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	return 0 if file == null else file.get_length()


static func _write_manifest(path: String, rows: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.store_csv_line(PackedStringArray(["Map Image ID", "file", "bytes", "md5"]))
	var keys: Array = rows.keys()
	keys.sort()
	for key: Variant in keys:
		file.store_csv_line(rows[key] as PackedStringArray)
	file.close()


static func _real(path: String) -> String:
	return ProjectSettings.globalize_path(path)


## The "Dungeon maps" section of docs/art/art_status.md.
static func status_markdown(out_dir: String = OUT_DIR) -> String:
	var rows: Array[String] = []
	var have: int = 0
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		var present: bool = FileAccess.file_exists(_real(out_dir.path_join("%s.webp" % blueprint.map_id)))
		have += 1 if present else 0
		rows.append("| %s | %s | %s | %s | %d |" % [blueprint.map_id, blueprint.id, blueprint.dungeon_name.replace("|", "/"), "yes" if present else "MISSING", blueprint.nodes.size()])
	var lines: Array[String] = [
		STATUS_MARKER,
		"",
		"Generated by `tools/import_maps`. Maps load from `assets/art/maps/<Map Image ID>.webp` (3:2, never cropped); node coordinates are in `data/dungeons/map_layout.json`.",
		"A dungeon with no map image keeps its placeholder map.",
		"",
		"**%d of %d** dungeons have a map image." % [have, DungeonCatalog.all().size()],
		"",
		"| Map Image ID | Dungeon | Name | Image | Nodes |",
		"|--------------|---------|------|-------|-------|",
	]
	lines.append_array(rows)
	return "\n".join(lines) + "\n"


static func write_status(status_path: String) -> void:
	var text: String = FileAccess.get_file_as_string(status_path) if FileAccess.file_exists(status_path) else ""
	var file: FileAccess = FileAccess.open(status_path, FileAccess.WRITE)
	file.store_string(Portraits.replace_section(text, STATUS_MARKER, status_markdown()))
	file.close()
