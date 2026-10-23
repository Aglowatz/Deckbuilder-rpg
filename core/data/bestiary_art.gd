class_name BestiaryArt
extends RefCounted
## Bestiary pictures (Oct 19 night, Part 3; docs/art/art_pipeline.md, "import bestiary"): `assets/art/bestiary/<BST ID>.webp`, one square picture per
## enemy or boss of data/bestiary/bestiary.json (ids from `Bestiary.art_id`, the prompts in docs/art/bestiary_image_requests.md). `Bestiary.art`
## already shows a file the moment it exists (the Collection Book and the battle plate); without one the entry keeps its dialogue-portrait crop or icon.
## The importer copies from the read-only Drive folder in `art_config.cfg` (`bestiary_dir`): it only reads there, never moves, renames or deletes.
## A non-square picture is cropped to a square (centred across, from the top down, so the head stays in) and the result is at most 512 px.

const OUT_DIR: String = "res://assets/art/bestiary"
const MANIFEST_PATH: String = "res://data/source/bestiary_import_manifest.csv"
const CONFIG_PATH: String = "res://data/source/art_config.cfg"
const STATUS_MARKER: String = "## Bestiary pictures"
const SIDE: int = 512
const QUALITY: float = 0.9
const INPUT_EXTENSIONS: Array[String] = ["png", "webp", "jpg", "jpeg"]
const FORBIDDEN_SOURCES: Array[String] = ["Pending Review", "Superseded"]


class Result extends RefCounted:
	var added: Array[String] = []
	var replaced: Array[String] = []
	var unchanged: int = 0
	## Pictures that were not square ("<ID> (<w>x<h>)"), cropped to a square.
	var cropped: Array[String] = []
	## Files whose name matched only after case / separator clean-up ("<file> -> <ID>").
	var renamed: Array[String] = []
	var unknown: Array[String] = []
	var errors: Array[String] = []
	var have: Array[String] = []
	var missing: Array[String] = []


## The configured Drive folder (env BESTIARY_SOURCE_DIR wins), "" when unset.
static func source_dir() -> String:
	var dir: String = OS.get_environment("BESTIARY_SOURCE_DIR")
	if dir.is_empty():
		var config: ConfigFile = ConfigFile.new()
		if config.load(CONFIG_PATH) == OK:
			dir = str(config.get_value("art", "bestiary_dir", ""))
	return dir.replace("\\", "/").rstrip("/")


## True when `dir` is a folder the importer must never read (the review queue or the superseded art).
static func is_forbidden_source(dir: String) -> bool:
	for forbidden: String in FORBIDDEN_SOURCES:
		if dir.contains(forbidden):
			return true
	return false


## {BST ID -> entry name} of every Bestiary entry.
static func known_ids() -> Dictionary:
	var known: Dictionary = {}
	for entry: Bestiary.Entry in Bestiary.all():
		known[Bestiary.art_id(entry.name)] = entry.name
	return known


## The BST ID a source file name stands for ("" when none): exact, else upper case with "_" / " " read as "-" ("bst_cave_scavenger" -> BST-CAVE-SCAVENGER).
static func file_id(base_name: String, known: Dictionary) -> String:
	var id: String = base_name.strip_edges()
	if known.has(id):
		return id
	var cleaned: String = id.to_upper().replace("_", "-").replace(" ", "-")
	while cleaned.contains("--"):
		cleaned = cleaned.replace("--", "-")
	return cleaned if known.has(cleaned) else ""


## `image` as a square: centred across, from the top down (a portrait keeps its head); unchanged when already square.
static func squared(image: Image) -> Image:
	var width: int = image.get_width()
	var height: int = image.get_height()
	if width == height:
		return image
	var side: int = mini(width, height)
	var x: int = (width - side) / 2
	var y: int = 0 if height > width else (height - side) / 2
	return image.get_region(Rect2i(x, y, side, side))


## Copies `<BST ID>.png|webp|jpg` files from `source` (read-only) to `out_dir` as square WebP. A file is re-imported when its MD5 differs from the manifest.
static func import_from_source(source: String, out_dir: String, manifest_path: String, known: Dictionary) -> Result:
	var result: Result = Result.new()
	if is_forbidden_source(source):
		result.errors.append("refusing to read from %s" % source)
		return result
	DirAccess.make_dir_recursive_absolute(_real(out_dir))
	var manifest: Dictionary = ArtImporter.read_manifest(_real(manifest_path))
	var rows: Dictionary = {}
	var files: Array[String] = []
	for file_name: String in DirAccess.get_files_at(source):
		files.append(file_name)
	files.sort()
	for file_name: String in ArtImporter.latest_revisions(files):
		if not INPUT_EXTENSIONS.has(file_name.get_extension().to_lower()):
			continue
		var id: String = file_id(ArtImporter.revision_base(file_name.get_basename()), known)
		if id.is_empty():
			result.unknown.append(file_name)
			continue
		if id != file_name.get_basename():
			result.renamed.append("%s -> %s" % [file_name, id])
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
		if image.get_width() != image.get_height():
			result.cropped.append("%s (%dx%d)" % [id, image.get_width(), image.get_height()])
		var square: Image = squared(image)
		if square.get_width() > SIDE:
			square.resize(SIDE, SIDE, Image.INTERPOLATE_LANCZOS)
		var error: Error = square.save_webp(target, true, QUALITY)
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
	Bestiary.reset_art()
	return result


static func _size(path: String) -> int:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	return 0 if file == null else file.get_length()


static func _write_manifest(path: String, rows: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.store_csv_line(PackedStringArray(["Bestiary ID", "file", "bytes", "md5"]))
	var keys: Array = rows.keys()
	keys.sort()
	for key: Variant in keys:
		file.store_csv_line(rows[key] as PackedStringArray)
	file.close()


static func _real(path: String) -> String:
	return ProjectSettings.globalize_path(path)


## The "Bestiary pictures" section of docs/art/art_status.md.
static func status_markdown(out_dir: String = OUT_DIR) -> String:
	var rows: Array[String] = []
	var have: int = 0
	for entry: Bestiary.Entry in Bestiary.all():
		var id: String = Bestiary.art_id(entry.name)
		var present: bool = FileAccess.file_exists(_real(out_dir.path_join("%s.webp" % id))) or FileAccess.file_exists(_real(out_dir.path_join("%s.png" % id)))
		have += 1 if present else 0
		rows.append("| %s | %s | %s | %s |" % [id, entry.name.replace("|", "/"), entry.kind, "yes" if present else "MISSING"])
	var lines: Array[String] = [
		STATUS_MARKER,
		"",
		"Generated by `tools/import_bestiary`. Pictures load from `assets/art/bestiary/<BST ID>.webp` (`Bestiary.art`); an entry without one keeps its portrait crop or icon.",
		"",
		"**%d of %d** entries have a picture." % [have, Bestiary.all().size()],
		"",
		"| Bestiary ID | Entry | Kind | Image |",
		"|-------------|-------|------|-------|",
	]
	lines.append_array(rows)
	return "\n".join(lines) + "\n"


static func write_status(status_path: String) -> void:
	var text: String = FileAccess.get_file_as_string(status_path) if FileAccess.file_exists(status_path) else ""
	var file: FileAccess = FileAccess.open(status_path, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(Portraits.replace_section(text, STATUS_MARKER, status_markdown()))
	file.close()
