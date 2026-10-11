class_name IconArt
extends RefCounted
## The icon set (docs/art/art_pipeline.md, "import icons"): `assets/art/icons/<ICON ID>.webp` (256 px master) plus crisp pre-downscaled `<ID>_32/_64/_128.webp`.
## Every screen asks for an icon by ID and size and keeps its old look when the image is missing (`texture` returns null), so any icon can arrive late.
## The importer copies from the read-only Drive folder in `art_config.cfg` (`icons_dir`), keeps transparency (or removes a plain flat background), trims the empty
## margin, centres the sprite on a square canvas and writes lossless WebP. Nothing in the Drive folder is moved, renamed or deleted.

const OUT_DIR: String = "res://assets/art/icons"
const MANIFEST_PATH: String = "res://data/source/icons_import_manifest.csv"
const CONFIG_PATH: String = "res://data/source/art_config.cfg"
const CSV_PATH: String = "res://data/source/icons.csv"
const STATUS_MARKER: String = "## Icons"
const INPUT_EXTENSIONS: Array[String] = ["png", "webp", "jpg", "jpeg"]
## Placeholder rows of the CSV that are not icons yet.
const PLACEHOLDER_IDS: Array[String] = ["ICON-GEAR-OTHERS", "ICON-ITEM-OTHERS", "ICON-HAT-OTHERS"]
const MASTER_SIDE: int = 256
const SIZES: Array[int] = [32, 64, 128]
## Fraction of the canvas left empty on each side so glow and outline do not touch the edge.
const CANVAS_MARGIN: float = 0.03

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


static func path_for(id: String, size: int = 0) -> String:
	return OUT_DIR.path_join(("%s.webp" % id) if size <= 0 else ("%s_%d.webp" % [id, size]))


static func has(id: String) -> bool:
	return ResourceLoader.exists(path_for(id))


## The sharpest stored size for drawing about `px` pixels wide: the smallest variant that is at least `px` (so it is only ever shrunk a little), else the master (0).
static func best_size(px: float) -> int:
	for size: int in SIZES:
		if float(size) >= px - 0.5:
			return size
	return 0


## The texture of an icon ID for drawing at about `px` pixels; null when there is no image (the caller keeps its fallback look).
static func texture(id: String, px: float = 0.0) -> Texture2D:
	var size: int = best_size(px) if px > 0.0 else 0
	var key: String = "%s|%d" % [id, size]
	if _textures.has(key):
		return _textures[key] as Texture2D
	var path: String = path_for(id, size)
	var loaded: Texture2D = load(path) as Texture2D if ResourceLoader.exists(path) else null
	if loaded == null and size > 0:
		loaded = texture(id)
	_textures[key] = loaded
	return loaded


static func reset() -> void:
	_textures = {}


## A TextureRect of the icon at `px` x `px`; null when the icon is missing. With `tooltip` text it shows it on hover, otherwise it ignores the mouse.
static func rect(id: String, px: float, tooltip: String = "") -> TextureRect:
	var tex: Texture2D = texture(id, px)
	if tex == null:
		return null
	var view: TextureRect = TextureRect.new()
	view.texture = tex
	view.custom_minimum_size = Vector2(px, px)
	view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	view.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	view.mouse_filter = Control.MOUSE_FILTER_IGNORE if tooltip.is_empty() else Control.MOUSE_FILTER_PASS
	view.tooltip_text = tooltip
	return view


## BBCode `[img]` tag of an icon for RichTextLabel text; "" when the icon is missing.
static func bbcode(id: String, px: int) -> String:
	if not has(id):
		return ""
	return "[img=%dx%d]%s[/img]" % [px, px, path_for(id, best_size(float(px)))]


# ---- Import ---------------------------------------------------------------------------------


static func source_dir() -> String:
	var dir: String = OS.get_environment("ICON_SOURCE_DIR")
	if dir.is_empty():
		var config: ConfigFile = ConfigFile.new()
		if config.load(CONFIG_PATH) == OK:
			dir = str(config.get_value("art", "icons_dir", ""))
	return dir.replace("\\", "/").rstrip("/")


## {ICON ID -> asset name} from the designer's CSV (rows whose first column starts with "ICON-", placeholders skipped).
static func known_ids() -> Dictionary:
	var known: Dictionary = {}
	if not FileAccess.file_exists(CSV_PATH):
		return known
	var file: FileAccess = FileAccess.open(CSV_PATH, FileAccess.READ)
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() >= 2 and row[0].begins_with("ICON-") and not PLACEHOLDER_IDS.has(row[0].strip_edges()):
			known[row[0].strip_edges()] = row[1].strip_edges()
	return known


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
		if had and str(manifest.get(id, "")) == hash and _variants_exist(out_dir, id):
			result.unchanged += 1
			continue
		var image: Image = Image.load_from_file(full_path)
		if image == null or image.is_empty():
			result.errors.append("%s: not a readable image" % file_name)
			rows.erase(id)
			continue
		image.convert(Image.FORMAT_RGBA8)
		if Portraits.remove_flat_background(image):
			result.background_removed.append(file_name)
		image = UiArt.trimmed(image)
		var failed: bool = squared(image, MASTER_SIDE).save_webp(target, false) != OK
		for size: int in SIZES:
			failed = failed or squared(image, size).save_webp(_real(out_dir.path_join("%s_%d.webp" % [id, size])), false) != OK
		if failed:
			result.errors.append("%s: could not write" % file_name)
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


static func _variants_exist(out_dir: String, id: String) -> bool:
	for size: int in SIZES:
		if not FileAccess.file_exists(_real(out_dir.path_join("%s_%d.webp" % [id, size]))):
			return false
	return true


## `image` fitted into a transparent `side` x `side` square (centred, never stretched, CANVAS_MARGIN free), downscaled with Lanczos from the full-size source so small
## sizes are crisp. Colours are bled into transparent pixels first so the resize leaves no dark fringe.
static func squared(image: Image, side: int) -> Image:
	var inner: int = maxi(1, int(round(float(side) * (1.0 - 2.0 * CANVAS_MARGIN))))
	var longest: int = maxi(image.get_width(), image.get_height())
	var factor: float = float(inner) / float(longest)
	var work: Image = image.duplicate() as Image
	work.fix_alpha_edges()
	work.resize(maxi(1, int(round(work.get_width() * factor))), maxi(1, int(round(work.get_height() * factor))), Image.INTERPOLATE_LANCZOS)
	var canvas: Image = Image.create_empty(side, side, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0, 0, 0, 0))
	canvas.blit_rect(work, Rect2i(Vector2i.ZERO, work.get_size()), Vector2i((side - work.get_width()) / 2, (side - work.get_height()) / 2))
	return canvas


static func _size(path: String) -> int:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	return 0 if file == null else file.get_length()


static func _write_manifest(path: String, rows: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.store_csv_line(PackedStringArray(["Icon ID", "file", "bytes", "md5"]))
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
		"Generated by `tools/import_icons`. Icons load from `assets/art/icons/<ICON ID>.webp` (`IconArt.texture`); every screen keeps its old look when an icon is missing.",
		"",
		"**%d of %d** icons are in the game." % [have, ids.size()],
		"",
		"| Icon ID | Asset | Image |",
		"|---------|-------|-------|",
	]
	lines.append_array(rows)
	return "\n".join(lines) + "\n"


static func write_status(status_path: String) -> void:
	var text: String = FileAccess.get_file_as_string(status_path) if FileAccess.file_exists(status_path) else ""
	var file: FileAccess = FileAccess.open(status_path, FileAccess.WRITE)
	file.store_string(Portraits.replace_section(text, STATUS_MARKER, status_markdown()))
	file.close()
