class_name Battleboards
extends RefCounted
## Battleboard art (docs/art/art_pipeline.md): the 16:9 background of every duel. `data/battleboards.json` maps a battle context key
## ("zone:beefcake", "dungeon:necrocrat", "capital:in", "arena"...) to a Battleboard ID; `assets/art/battleboards/<ID>.webp` is the image.
## The importer copies from the read-only Drive folder in `art_config.cfg` (`battleboard_dir`), centre-crops 3:2 art to 16:9 and writes WebP.

const MAP_PATH: String = "res://data/battleboards.json"
const LIST_PATH: String = "res://data/source/battleboard_list.csv.csv"
const MANIFEST_PATH: String = "res://data/source/battleboard_import_manifest.csv"
const OUT_DIR: String = "res://assets/art/battleboards"
const CONFIG_PATH: String = "res://data/source/art_config.cfg"
const WIDTH: int = 1920
const HEIGHT: int = 1080
const QUALITY: float = 0.85
const INPUT_EXTENSIONS: Array[String] = ["png", "jpg", "jpeg", "webp"]

static var _textures: Dictionary = {}
static var _contexts: Dictionary = {}
static var _loaded: bool = false


## What an import run did.
class Result extends RefCounted:
	var added: Array[String] = []
	var replaced: Array[String] = []
	var unchanged: int = 0
	var cropped: Array[String] = []
	## Image files whose name is not a Battleboard ID in the CSV.
	var unknown: Array[String] = []
	var errors: Array[String] = []
	var have: Array[String] = []
	var missing: Array[String] = []


# ---- Mapping and loading ------------------------------------------------------------------


## The Battleboard ID a battle context key maps to ("" when the key is not mapped).
static func board_for(key: String) -> String:
	_load_map()
	return str(_contexts.get(key, ""))


## The whole key -> ID table (a copy).
static func contexts() -> Dictionary:
	_load_map()
	return _contexts.duplicate()


static func _load_map() -> void:
	if _loaded:
		return
	_loaded = true
	_contexts = {}
	if not FileAccess.file_exists(MAP_PATH):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(MAP_PATH))
	if parsed is Dictionary and (parsed as Dictionary).get("contexts") is Dictionary:
		_contexts = ((parsed as Dictionary)["contexts"] as Dictionary).duplicate()


## Forgets the loaded table and textures (tests, and so an edited JSON is re-read).
static func reset() -> void:
	_loaded = false
	_contexts = {}
	_textures = {}


## The board image for a context key or Battleboard ID; a neutral placeholder when the ID is unmapped or its image is missing.
static func texture_for(key_or_id: String) -> Texture2D:
	var id: String = key_or_id if key_or_id.begins_with("BB-") else board_for(key_or_id)
	if id.is_empty():
		return _placeholder()
	if not _textures.has(id):
		var path: String = OUT_DIR.path_join("%s.webp" % id)
		var loaded: Texture2D = load(path) as Texture2D if ResourceLoader.exists(path) else null
		_textures[id] = loaded
	var texture: Texture2D = _textures[id] as Texture2D
	return texture if texture != null else _placeholder()


## True when the image for `id` exists in the game.
static func has_image(id: String) -> bool:
	return FileAccess.file_exists(OUT_DIR.path_join("%s.webp" % id)) or ResourceLoader.exists(OUT_DIR.path_join("%s.webp" % id))


## The neutral stand-in: a dark slate table with a soft lighter centre.
static func _placeholder() -> Texture2D:
	if _textures.has(""):
		return _textures[""] as Texture2D
	var gradient: Gradient = Gradient.new()
	gradient.set_color(0, Color(0.20, 0.21, 0.26))
	gradient.set_color(1, Color(0.08, 0.08, 0.11))
	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.9)
	texture.width = 256
	texture.height = 144
	_textures[""] = texture
	return texture


# ---- Import ---------------------------------------------------------------------------------


## Battleboard IDs and names from the designer's CSV: {ID -> [name, used in]}.
static func known_boards() -> Dictionary:
	var known: Dictionary = {}
	if not FileAccess.file_exists(LIST_PATH):
		return known
	var file: FileAccess = FileAccess.open(LIST_PATH, FileAccess.READ)
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() >= 3 and row[0].begins_with("BB-"):
			known[row[0].strip_edges()] = [row[1], row[2]]
	return known


## Centre-crops to 16:9 (never stretches); art wider than WIDTH is scaled down to WIDTH x HEIGHT, smaller art keeps its size (the screen scales it). 3:2 art loses its top and bottom 5.5% each.
static func fit_image(image: Image) -> Image:
	var target_ratio: float = float(WIDTH) / float(HEIGHT)
	var ratio: float = float(image.get_width()) / float(image.get_height())
	var crop: Rect2i = Rect2i(0, 0, image.get_width(), image.get_height())
	if ratio < target_ratio:
		crop.size.y = int(round(float(image.get_width()) / target_ratio))
		crop.position.y = (image.get_height() - crop.size.y) / 2
	elif ratio > target_ratio:
		crop.size.x = int(round(float(image.get_height()) * target_ratio))
		crop.position.x = (image.get_width() - crop.size.x) / 2
	var result: Image = image.get_region(crop)
	result.convert(Image.FORMAT_RGBA8)
	if result.get_width() > WIDTH:
		result.resize(WIDTH, HEIGHT, Image.INTERPOLATE_LANCZOS)
	return result


## Whether `image` is not 16:9 (beyond 0.5%), so `fit_image` crops it.
static func needs_crop(image: Image) -> bool:
	var target_ratio: float = float(WIDTH) / float(HEIGHT)
	return absf(float(image.get_width()) / float(image.get_height()) - target_ratio) / target_ratio > 0.005


## The configured Drive folder (env BATTLEBOARD_SOURCE_DIR wins), "" when unset.
static func source_dir() -> String:
	var dir: String = OS.get_environment("BATTLEBOARD_SOURCE_DIR")
	if dir.is_empty():
		var config: ConfigFile = ConfigFile.new()
		if config.load(CONFIG_PATH) == OK:
			dir = str(config.get_value("art", "battleboard_dir", ""))
	return dir.replace("\\", "/").rstrip("/")


## Copies `<ID>.png|jpg|webp` files from `source_dir` (read-only: nothing there is moved, renamed or deleted) to `out_dir` as 16:9 WebP.
## A file is re-imported when its MD5 differs from the manifest. One image is in memory at a time.
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
		var note: String = "%dx%d" % [image.get_width(), image.get_height()] if needs_crop(image) else "ok"
		var error: Error = fit_image(image).save_webp(target, true, QUALITY)
		if error != OK:
			result.errors.append("%s: could not write (error %d)" % [file_name, error])
			rows.erase(id)
			continue
		result.added.append(id)
		if had:
			result.replaced.append(id)
		if note != "ok":
			result.cropped.append("%s (%s)" % [id, note])
	_write_manifest(_real(manifest_path), rows)
	var ids: Array = known.keys()
	ids.sort()
	for id: Variant in ids:
		if FileAccess.file_exists(_real(out_dir.path_join("%s.webp" % str(id)))):
			result.have.append(str(id))
		else:
			result.missing.append(str(id))
	return result


static func _size(path: String) -> int:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	return 0 if file == null else file.get_length()


static func _write_manifest(path: String, rows: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.store_csv_line(PackedStringArray(["Battleboard ID", "file", "bytes", "md5"]))
	var ids: Array = rows.keys()
	ids.sort()
	for id: Variant in ids:
		file.store_csv_line(rows[id] as PackedStringArray)
	file.close()


static func _real(path: String) -> String:
	return ProjectSettings.globalize_path(path)


# ---- Status ---------------------------------------------------------------------------------

const STATUS_MARKER: String = "## Battleboards"


## The "Battleboards" section of docs/art/art_status.md: every Battleboard ID of the CSV, its name, whether it has an image and the contexts that use it.
static func status_markdown() -> String:
	var used: Dictionary = {}
	var contexts_table: Dictionary = contexts()
	var keys: Array = contexts_table.keys()
	keys.sort()
	for key: Variant in keys:
		var id: String = str(contexts_table[key])
		used[id] = str(used.get(id, "")) + ("" if not used.has(id) else ", ") + str(key)
	var known: Dictionary = known_boards()
	var ids: Array = known.keys()
	var have: int = 0
	var rows: Array[String] = []
	for id: Variant in ids:
		var present: bool = FileAccess.file_exists(_real(OUT_DIR.path_join("%s.webp" % str(id))))
		have += 1 if present else 0
		rows.append("| %s | %s | %s | %s |" % [id, (known[id] as Array)[0], "yes" if present else "MISSING", str(used.get(id, "(no context in the game yet)"))])
	var lines: Array[String] = [
		STATUS_MARKER,
		"",
		"Generated by `tools/import_battleboards`. Images load from `assets/art/battleboards/<ID>.webp` (16:9); the context -> board mapping is `data/battleboards.json`.",
		"A battle with an unmapped context or a missing image shows the neutral placeholder board.",
		"",
		"**%d of %d** boards have an image." % [have, ids.size()],
		"",
		"| ID | Name | Image | Used by context |",
		"|----|------|-------|-----------------|",
	]
	lines.append_array(rows)
	return "\n".join(lines) + "\n"


## Rewrites the Battleboards section of `status_path` (keeps everything before the marker; appends it when absent).
static func write_status(status_path: String) -> void:
	var text: String = FileAccess.get_file_as_string(status_path) if FileAccess.file_exists(status_path) else ""
	var cut: int = text.find(STATUS_MARKER)
	if cut >= 0:
		text = text.substr(0, cut)
	if not text.is_empty() and not text.ends_with("\n\n"):
		text += "\n" if text.ends_with("\n") else "\n\n"
	var file: FileAccess = FileAccess.open(status_path, FileAccess.WRITE)
	file.store_string(text + status_markdown())
	file.close()
