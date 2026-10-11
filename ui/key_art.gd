class_name KeyArt
extends RefCounted
## The vendor-screen and key-art library (docs/art/art_pipeline.md, "import key art"): `assets/art/vendors/<VS-ID>.webp` and `assets/art/keyart/<ID>.webp`
## (LOGO-*, APP-ICON, TITLE-*, LOAD-*, ZONE-TITLE-*, STORY-*). Every screen asks by ID and keeps its fallback look when `texture` returns null.
## The importer COPIES from the two read-only Drive folders in `art_config.cfg` (`vendor_dir`, `keyart_dir`; nothing there is moved, renamed or deleted):
## backgrounds, loading screens and stills are cropped to 16:9, logos and banners keep their transparency, the app icon is also written as
## `assets/icon/app_icon.png/.ico/.icns`, and the vendor sheet rows are written to `data/vendors/vendor_screens.json`. STEAM-* and ITCH-COVER are store art, not game art
## (`marketing/store_art/`, never imported).

enum Kind { VENDOR, LOGO, ICON, TITLE, LOADING, ZONE, STORY, STORE }

const VENDOR_DIR: String = "res://assets/art/vendors"
const KEY_DIR: String = "res://assets/art/keyart"
const ICON_DIR: String = "res://assets/icon"
const MANIFEST_PATH: String = "res://data/source/key_art_import_manifest.csv"
const VENDOR_JSON: String = "res://data/vendors/vendor_screens.json"
const NPC_CSV: String = "res://data/source/npc_list.csv"
const KEY_CSV: String = "res://data/source/logo_title_art.csv"
const CONFIG_PATH: String = "res://data/source/art_config.cfg"
const STATUS_MARKER: String = "## Vendor screens and key art"
const QUALITY: float = 0.93
const ASPECT: float = 16.0 / 9.0
## Longest stored side of a background, loading screen, still or banner (the game's design resolution is 1920x1080).
const MAX_WIDTH: int = 1920
## Where the 16:9 crop sits on the longer axis (0 = keep the top, 1 = keep the bottom): loading screens keep the calm bottom fifth for the tip, stills keep the faces.
const CROP_LOADING: float = 0.75
const CROP_STORY: float = 0.35
const CROP_VENDOR: float = 0.5
const ICON_SIZES: Array[int] = [16, 24, 32, 48, 64, 128, 256]
const ICNS_TYPES: Dictionary = {128: "ic07", 256: "ic08", 512: "ic09", 1024: "ic10"}

static var _textures: Dictionary = {}


class Result extends RefCounted:
	var added: Array[String] = []
	var replaced: Array[String] = []
	var unchanged: int = 0
	var unknown: Array[String] = []
	var skipped_store: Array[String] = []
	var errors: Array[String] = []
	var have: Array[String] = []
	var missing: Array[String] = []


# ---- Loading --------------------------------------------------------------------------------


static func kind_of(id: String) -> Kind:
	if id.begins_with("VS-"):
		return Kind.VENDOR
	if id == "APP-ICON":
		return Kind.ICON
	if id.begins_with("LOGO-"):
		return Kind.LOGO
	if id.begins_with("TITLE-"):
		return Kind.TITLE
	if id.begins_with("LOAD-"):
		return Kind.LOADING
	if id.begins_with("ZONE-TITLE-"):
		return Kind.ZONE
	if id.begins_with("STORY-"):
		return Kind.STORY
	return Kind.STORE


static func path_for(id: String) -> String:
	return (VENDOR_DIR if kind_of(id) == Kind.VENDOR else KEY_DIR).path_join("%s.webp" % id)


static func has(id: String) -> bool:
	return ResourceLoader.exists(path_for(id))


## The texture of an ID; null when there is no image (the caller keeps its fallback).
static func texture(id: String) -> Texture2D:
	if _textures.has(id):
		return _textures[id] as Texture2D
	var loaded: Texture2D = load(path_for(id)) as Texture2D if has(id) else null
	_textures[id] = loaded
	return loaded


static func reset() -> void:
	_textures = {}


# ---- Sheets ---------------------------------------------------------------------------------


static func _rows(path: String) -> Array[PackedStringArray]:
	var rows: Array[PackedStringArray] = []
	if not FileAccess.file_exists(path):
		return rows
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	while not file.eof_reached():
		rows.append(file.get_csv_line())
	return rows


## Vendor Screen rows of the NPC list ("VENDOR SCREENS" section, ID in column A starting with "VS-"): {VS-ID: {vendor, portrait_id, location, goods, concept, notes, art_direction}}.
static func vendor_rows() -> Dictionary:
	var result: Dictionary = {}
	for row: PackedStringArray in _rows(NPC_CSV):
		if row.size() >= 8 and row[0].begins_with("VS-"):
			result[row[0]] = {"vendor": row[1], "portrait_id": row[2], "location": row[3], "goods": row[4], "concept": row[5], "notes": row[6], "art_direction": row[7]}
	return result


## {ID: Kind} of the logo/title sheet (header row "ID", asset rows have an ID in column A) plus the vendor screens.
static func known_ids() -> Dictionary:
	var known: Dictionary = {}
	var in_assets: bool = false
	for row: PackedStringArray in _rows(KEY_CSV):
		if row.is_empty():
			continue
		if row[0] == "ID":
			in_assets = true
			continue
		if in_assets and not row[0].strip_edges().is_empty():
			var id: String = row[0].strip_edges()
			if kind_of(id) != Kind.STORE:
				known[id] = kind_of(id)
	for id: Variant in vendor_rows().keys():
		known[str(id)] = Kind.VENDOR
	return known


# ---- Import ---------------------------------------------------------------------------------


static func source_dir(key: String, env: String) -> String:
	var dir: String = OS.get_environment(env)
	if dir.is_empty():
		var config: ConfigFile = ConfigFile.new()
		if config.load(CONFIG_PATH) == OK:
			dir = str(config.get_value("art", key, ""))
	return dir.replace("\\", "/").rstrip("/")


## `image` cropped to 16:9 (no change when already 16:9 within a pixel); `bias` is where the crop sits on the longer axis (0 top, 1 bottom).
static func crop_16x9(image: Image, bias: float = 0.5) -> Image:
	var width: int = image.get_width()
	var height: int = image.get_height()
	var target_height: int = int(round(float(width) / ASPECT))
	if absi(target_height - height) <= 1:
		return image
	if target_height < height:
		var top: int = int(round(float(height - target_height) * bias))
		return image.get_region(Rect2i(0, top, width, target_height))
	var target_width: int = int(round(float(height) * ASPECT))
	var left: int = int(round(float(width - target_width) * 0.5))
	return image.get_region(Rect2i(left, 0, target_width, height))


static func _process_image(image: Image, kind: Kind) -> Image:
	image.convert(Image.FORMAT_RGBA8)
	match kind:
		Kind.VENDOR:
			image = crop_16x9(image, CROP_VENDOR)
		Kind.TITLE:
			image = crop_16x9(image, 0.5)
		Kind.LOADING:
			image = crop_16x9(image, CROP_LOADING)
		Kind.STORY:
			image = crop_16x9(image, CROP_STORY)
	var limit: int = MAX_WIDTH
	if kind == Kind.LOGO or kind == Kind.ICON:
		limit = 1280
	if image.get_width() > limit:
		image.fix_alpha_edges()
		image.resize(limit, int(round(float(image.get_height()) * float(limit) / float(image.get_width()))), Image.INTERPOLATE_LANCZOS)
	return image


static func import_from_source(vendor_src: String, key_src: String) -> Result:
	var result: Result = Result.new()
	DirAccess.make_dir_recursive_absolute(_real(VENDOR_DIR))
	DirAccess.make_dir_recursive_absolute(_real(KEY_DIR))
	var known: Dictionary = known_ids()
	var manifest: Dictionary = ArtImporter.read_manifest(_real(MANIFEST_PATH))
	var rows: Dictionary = {}
	for source: String in [vendor_src, key_src]:
		if source.is_empty() or not DirAccess.dir_exists_absolute(source):
			result.errors.append("source folder not found: '%s'" % source)
			continue
		var files: Array[String] = []
		for file_name: String in DirAccess.get_files_at(source):
			files.append(file_name)
		files.sort()
		for file_name: String in files:
			if not ["png", "webp", "jpg", "jpeg"].has(file_name.get_extension().to_lower()):
				continue
			var id: String = file_name.get_basename()
			if not known.has(id):
				if kind_of(id) == Kind.STORE:
					result.skipped_store.append(file_name)
				else:
					result.unknown.append(file_name)
				continue
			var full_path: String = source.path_join(file_name)
			var hash: String = FileAccess.get_md5(full_path)
			var target: String = _real(path_for(id))
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
			var kind: Kind = kind_of(id)
			if kind == Kind.ICON:
				write_app_icons(image)
			var lossless: bool = kind == Kind.LOGO or kind == Kind.ZONE or kind == Kind.ICON
			var error: Error = _process_image(image, kind).save_webp(target, not lossless, 1.0 if lossless else QUALITY)
			if error != OK:
				result.errors.append("%s: could not write (error %d)" % [file_name, error])
				rows.erase(id)
				continue
			result.added.append(id)
			if had:
				result.replaced.append(id)
	_write_manifest(_real(MANIFEST_PATH), rows)
	write_vendor_json()
	var ids: Array = known.keys()
	ids.sort()
	for id: Variant in ids:
		if FileAccess.file_exists(_real(path_for(str(id)))):
			result.have.append(str(id))
		else:
			result.missing.append(str(id))
	reset()
	return result


## data/vendors/vendor_screens.json: the vendor sheet rows, so the exported game never reads the CSV.
static func write_vendor_json() -> void:
	DirAccess.make_dir_recursive_absolute(_real(VENDOR_JSON).get_base_dir())
	var file: FileAccess = FileAccess.open(_real(VENDOR_JSON), FileAccess.WRITE)
	file.store_string(JSON.stringify(vendor_rows(), "\t", true))
	file.close()


# ---- App icon -------------------------------------------------------------------------------


## assets/icon/app_icon.png (256), app_icon.ico (16..256, PNG-compressed entries) and app_icon.icns (128..1024) from the APP-ICON source.
static func write_app_icons(source: Image) -> void:
	DirAccess.make_dir_recursive_absolute(_real(ICON_DIR))
	var base: Image = source.duplicate() as Image
	base.convert(Image.FORMAT_RGBA8)
	base.fix_alpha_edges()
	var png_256: Image = _square(base, 256)
	png_256.save_png(_real(ICON_DIR.path_join("app_icon.png")))
	var big: Image = _square(base, 512)
	big.save_png(_real(ICON_DIR.path_join("app_icon_512.png")))
	var ico: PackedByteArray = PackedByteArray()
	var images: Array[PackedByteArray] = []
	for size: int in ICON_SIZES:
		images.append(_square(base, size).save_png_to_buffer())
	ico.append_array(PackedByteArray([0, 0, 1, 0, ICON_SIZES.size() & 0xFF, 0]))
	var offset: int = 6 + 16 * ICON_SIZES.size()
	for index: int in range(ICON_SIZES.size()):
		var dimension: int = ICON_SIZES[index] if ICON_SIZES[index] < 256 else 0
		ico.append_array(PackedByteArray([dimension, dimension, 0, 0, 1, 0, 32, 0]))
		ico.append_array(_u32_le(images[index].size()))
		ico.append_array(_u32_le(offset))
		offset += images[index].size()
	for data: PackedByteArray in images:
		ico.append_array(data)
	var ico_file: FileAccess = FileAccess.open(_real(ICON_DIR.path_join("app_icon.ico")), FileAccess.WRITE)
	ico_file.store_buffer(ico)
	ico_file.close()
	var chunks: PackedByteArray = PackedByteArray()
	for size: int in ICNS_TYPES.keys():
		var png: PackedByteArray = _square(base, size).save_png_to_buffer()
		chunks.append_array(str(ICNS_TYPES[size]).to_ascii_buffer())
		chunks.append_array(_u32_be(png.size() + 8))
		chunks.append_array(png)
	var icns: PackedByteArray = "icns".to_ascii_buffer()
	icns.append_array(_u32_be(chunks.size() + 8))
	icns.append_array(chunks)
	var icns_file: FileAccess = FileAccess.open(_real(ICON_DIR.path_join("app_icon.icns")), FileAccess.WRITE)
	icns_file.store_buffer(icns)
	icns_file.close()


static func _square(image: Image, size: int) -> Image:
	var copy: Image = image.duplicate() as Image
	copy.resize(size, size, Image.INTERPOLATE_LANCZOS)
	return copy


static func _u32_le(value: int) -> PackedByteArray:
	return PackedByteArray([value & 0xFF, (value >> 8) & 0xFF, (value >> 16) & 0xFF, (value >> 24) & 0xFF])


static func _u32_be(value: int) -> PackedByteArray:
	return PackedByteArray([(value >> 24) & 0xFF, (value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF])


# ---- Helpers --------------------------------------------------------------------------------


static func _size(path: String) -> int:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	return 0 if file == null else file.get_length()


static func _write_manifest(path: String, rows: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.store_csv_line(PackedStringArray(["ID", "file", "bytes", "md5"]))
	var keys: Array = rows.keys()
	keys.sort()
	for key: Variant in keys:
		file.store_csv_line(rows[key] as PackedStringArray)
	file.close()


static func _real(path: String) -> String:
	return ProjectSettings.globalize_path(path)


## The "Vendor screens and key art" section of docs/art/art_status.md.
static func status_markdown() -> String:
	var known: Dictionary = known_ids()
	var ids: Array = known.keys()
	ids.sort()
	var lines: Array[String] = [STATUS_MARKER, "", "Generated by `bash tools/import_key_art.sh` (sources `vendor_dir` and `keyart_dir` in `data/source/art_config.cfg`, copy-only). Store art (STEAM-*, ITCH-COVER) lives in `marketing/store_art/` and is not imported.", "", "| ID | Kind | Art |", "|----|------|-----|"]
	var have: int = 0
	for id: Variant in ids:
		var present: bool = FileAccess.file_exists(_real(path_for(str(id))))
		have += 1 if present else 0
		lines.append("| %s | %s | %s |" % [id, Kind.keys()[int(known[id])].capitalize(), "yes" if present else "**missing**"])
	lines.insert(3, "**%d of %d** images in the game (store art excluded)." % [have, ids.size()])
	lines.insert(4, "")
	return "\n".join(lines) + "\n"


static func write_status(status_path: String) -> void:
	var text: String = FileAccess.get_file_as_string(status_path) if FileAccess.file_exists(status_path) else ""
	var file: FileAccess = FileAccess.open(status_path, FileAccess.WRITE)
	file.store_string(Portraits.replace_section(text, STATUS_MARKER, status_markdown()))
	file.close()
