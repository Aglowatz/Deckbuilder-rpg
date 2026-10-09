class_name UiArt
extends RefCounted
## The UI art kit (docs/art/art_pipeline.md, "import UI art"): `assets/art/ui/<UI ID>.webp`, e.g. UI-FRAME-B.webp. Every screen asks for an image by ID and
## keeps its code-drawn look when the image is missing (`texture` returns null), so any asset can arrive late.
## The importer copies from the read-only Drive folder in `art_config.cfg` (`ui_dir`), keeps transparency (or removes a plain flat background), trims the
## empty margin around sprites (never around frames, card backs, packs and backgrounds, whose full canvas is the layout), scales big images down and
## writes WebP with alpha. Nothing in the Drive folder is moved, renamed or deleted.

const OUT_DIR: String = "res://assets/art/ui"
const MANIFEST_PATH: String = "res://data/source/ui_import_manifest.csv"
const CONFIG_PATH: String = "res://data/source/art_config.cfg"
const KIT_PATHS: Array[String] = ["res://data/source/ui_art_kit.csv", "res://data/source/ui_art_kit.csv.csv"]
const STATUS_MARKER: String = "## UI art kit"
const QUALITY: float = 0.94
## Longest side of a stored sprite, frame, back or pack; backgrounds keep their 1536x1024.
const MAX_SIDE: int = 1024
const MAX_SIDE_BACKGROUND: int = 1536
const MAX_SIDE_CURSOR: int = 128
const INPUT_EXTENSIONS: Array[String] = ["png", "webp", "jpg", "jpeg"]
## Alpha at or below which a pixel counts as empty when trimming the margin around a sprite.
const TRIM_ALPHA: float = 0.06
const TRIM_PAD: int = 2

static var _textures: Dictionary = {}


class Result extends RefCounted:
	var added: Array[String] = []
	var replaced: Array[String] = []
	var unchanged: int = 0
	var background_removed: Array[String] = []
	var unknown: Array[String] = []
	var errors: Array[String] = []
	var have: Array[String] = []
	var missing: Array[String] = []


# ---- Loading --------------------------------------------------------------------------------


static func path_for(id: String) -> String:
	return OUT_DIR.path_join("%s.webp" % id)


## True when the image of `id` is in the game.
static func has(id: String) -> bool:
	return ResourceLoader.exists(path_for(id))


## The texture of a UI ID; null when there is no image (the caller keeps its fallback look).
static func texture(id: String) -> Texture2D:
	if _textures.has(id):
		return _textures[id] as Texture2D
	var loaded: Texture2D = load(path_for(id)) as Texture2D if has(id) else null
	_textures[id] = loaded
	return loaded


static func reset() -> void:
	_textures = {}


## A 9-slice StyleBoxTexture of `id` with the margins (pixels of the stored image) on each side; null when there is no image. `content` is the content margin
## (inner padding for text) on every side.
static func nine(id: String, margin: Vector4, content: Vector4 = Vector4(-1, -1, -1, -1), draw_center: bool = true) -> StyleBoxTexture:
	var image: Texture2D = texture(id)
	if image == null:
		return null
	var style: StyleBoxTexture = StyleBoxTexture.new()
	style.texture = image
	style.texture_margin_left = margin.x
	style.texture_margin_top = margin.y
	style.texture_margin_right = margin.z
	style.texture_margin_bottom = margin.w
	style.draw_center = draw_center
	style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	if content.x >= 0.0:
		style.content_margin_left = content.x
		style.content_margin_top = content.y
		style.content_margin_right = content.z
		style.content_margin_bottom = content.w
	return style


# ---- Import ---------------------------------------------------------------------------------


static func source_dir() -> String:
	var dir: String = OS.get_environment("UI_SOURCE_DIR")
	if dir.is_empty():
		var config: ConfigFile = ConfigFile.new()
		if config.load(CONFIG_PATH) == OK:
			dir = str(config.get_value("art", "ui_dir", ""))
	return dir.replace("\\", "/").rstrip("/")


## {UI ID -> asset name} from the designer's kit CSV (rows whose first column starts with "UI-").
static func known_ids() -> Dictionary:
	var known: Dictionary = {}
	for path: String in KIT_PATHS:
		if not FileAccess.file_exists(path):
			continue
		var file: FileAccess = FileAccess.open(path, FileAccess.READ)
		while not file.eof_reached():
			var row: PackedStringArray = file.get_csv_line()
			if row.size() >= 2 and row[0].begins_with("UI-"):
				known[row[0].strip_edges()] = row[1].strip_edges()
		break
	return known


static func _keeps_canvas(id: String) -> bool:
	return id.begins_with("UI-FRAME-") or id.begins_with("UI-CARDBACK-") or id.begins_with("UI-PACK-") or id.begins_with("UI-BG-")


static func _max_side(id: String) -> int:
	if id.begins_with("UI-BG-"):
		return MAX_SIDE_BACKGROUND
	if id.begins_with("UI-CURSOR"):
		return MAX_SIDE_CURSOR
	return MAX_SIDE


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
		image.convert(Image.FORMAT_RGBA8)
		if not id.begins_with("UI-BG-") and not id.begins_with("UI-CARDBACK-") and Portraits.remove_flat_background(image):
			result.background_removed.append(file_name)
		if not _keeps_canvas(id):
			image = trimmed(image)
		image = scaled(image, _max_side(id))
		var error: Error = image.save_webp(target, false, QUALITY) if id.begins_with("UI-CURSOR") else image.save_webp(target, true, QUALITY)
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


## `image` cropped to the bounding box of its visible pixels (plus TRIM_PAD) so layout code can rely on the sprite touching its own bounds.
static func trimmed(image: Image) -> Image:
	var width: int = image.get_width()
	var height: int = image.get_height()
	var data: PackedByteArray = image.get_data()
	var threshold: int = int(TRIM_ALPHA * 255.0)
	var left: int = width
	var right: int = -1
	var top: int = height
	var bottom: int = -1
	for y: int in range(height):
		for x: int in range(width):
			if data[(y * width + x) * 4 + 3] > threshold:
				left = mini(left, x)
				right = maxi(right, x)
				top = mini(top, y)
				bottom = maxi(bottom, y)
	if right < 0:
		return image
	left = maxi(0, left - TRIM_PAD)
	top = maxi(0, top - TRIM_PAD)
	right = mini(width - 1, right + TRIM_PAD)
	bottom = mini(height - 1, bottom + TRIM_PAD)
	return image.get_region(Rect2i(left, top, right - left + 1, bottom - top + 1))


static func scaled(image: Image, max_side: int) -> Image:
	var longest: int = maxi(image.get_width(), image.get_height())
	if longest <= max_side:
		return image
	var factor: float = float(max_side) / float(longest)
	var result: Image = image.duplicate() as Image
	result.fix_alpha_edges()
	result.resize(maxi(1, int(round(image.get_width() * factor))), maxi(1, int(round(image.get_height() * factor))), Image.INTERPOLATE_LANCZOS)
	return result


static func _size(path: String) -> int:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	return 0 if file == null else file.get_length()


static func _write_manifest(path: String, rows: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.store_csv_line(PackedStringArray(["UI ID", "file", "bytes", "md5"]))
	var keys: Array = rows.keys()
	keys.sort()
	for key: Variant in keys:
		file.store_csv_line(rows[key] as PackedStringArray)
	file.close()


static func _real(path: String) -> String:
	return ProjectSettings.globalize_path(path)


# ---- Status ---------------------------------------------------------------------------------


static func status_markdown(out_dir: String = OUT_DIR) -> String:
	var known: Dictionary = known_ids()
	var ids: Array = known.keys()
	ids.sort()
	var rows: Array[String] = []
	var have: int = 0
	for id: Variant in ids:
		var present: bool = FileAccess.file_exists(_real(out_dir.path_join("%s.webp" % str(id))))
		have += 1 if present else 0
		rows.append("| %s | %s | %s |" % [id, str(known[id]).replace("|", "/"), "yes" if present else "MISSING"])
	var lines: Array[String] = [
		STATUS_MARKER,
		"",
		"Generated by `tools/import_ui_art`. UI art loads from `assets/art/ui/<UI ID>.webp` (`UiArt.texture`); every screen keeps its code-drawn look when an image is missing.",
		"",
		"**%d of %d** kit assets are in the game." % [have, ids.size()],
		"",
		"| UI ID | Asset | Image |",
		"|-------|-------|-------|",
	]
	lines.append_array(rows)
	return "\n".join(lines) + "\n"


static func write_status(status_path: String) -> void:
	var text: String = FileAccess.get_file_as_string(status_path) if FileAccess.file_exists(status_path) else ""
	var file: FileAccess = FileAccess.open(status_path, FileAccess.WRITE)
	file.store_string(Portraits.replace_section(text, STATUS_MARKER, status_markdown()))
	file.close()
