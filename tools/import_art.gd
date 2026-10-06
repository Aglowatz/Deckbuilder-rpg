extends SceneTree
## The card art importer: `bash tools/import_art.sh`. Copies art from the read-only source folder in data/source/art_config.cfg (the
## Google Drive "Approved" folder) and from _art_inbox/, writes 768x1152 WebP files to assets/art/cards/ and docs/art/art_status.md.
## See docs/art/art_pipeline.md.

const INBOX: String = "res://_art_inbox"
const SOURCE: String = "res://_art_source"
const OUT: String = "res://assets/art/cards"
const MAP: String = "res://data/source/art_map.csv"
const CONFIG: String = "res://data/source/art_config.cfg"
const MANIFEST: String = "res://data/source/art_import_manifest.csv"
const STATUS: String = "res://docs/art/art_status.md"
const FORBIDDEN_FOLDERS: Array[String] = ["pending review", "superseded"]


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(INBOX))
	var known: Dictionary = {}
	for entry: CardImporter.Entry in CardImporter.build_all():
		known[entry.id] = entry.data.display_name
	var source_dir: String = _source_dir()
	var drive: ArtImporter.Result = null
	if not source_dir.is_empty():
		drive = ArtImporter.import_from_source(source_dir, OUT, MANIFEST, known)
	var result: ArtImporter.Result = ArtImporter.import_all(INBOX, OUT, SOURCE, MAP, known)
	if drive != null:
		result = _merge(drive, result)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(STATUS.get_base_dir()))
	var file: FileAccess = FileAccess.open(STATUS, FileAccess.WRITE)
	file.store_string(ArtImporter.status_markdown(OUT, known, result))
	file.close()
	print("Source: %s" % (source_dir if not source_dir.is_empty() else "(none; inbox only)"))
	print("Added: %s" % (", ".join(result.added) if not result.added.is_empty() else "(none)"))
	print("Replaced (source changed): %s" % (", ".join(result.replaced) if not result.replaced.is_empty() else "(none)"))
	print("Unchanged: %d" % result.unchanged)
	print("Cropped to 2:3: %s" % (", ".join(result.cropped) if not result.cropped.is_empty() else "(none)"))
	print("Unknown files: %s" % (", ".join(result.unknown) if not result.unknown.is_empty() else "(none)"))
	if not result.duplicates.is_empty():
		print("Duplicate files: %s" % ", ".join(result.duplicates))
	for problem: String in result.errors:
		print("Error: %s" % problem)
	print("HAVE: %s" % ",".join(result.have))
	print("MISSING: %s" % ",".join(result.missing))
	print(result.summary())
	quit(0)


## The configured source folder (env ART_SOURCE_DIR wins), or "" when unset, missing or one of the forbidden sibling folders.
func _source_dir() -> String:
	var dir: String = OS.get_environment("ART_SOURCE_DIR")
	if dir.is_empty():
		var config: ConfigFile = ConfigFile.new()
		if config.load(CONFIG) != OK:
			return ""
		dir = str(config.get_value("art", "source_dir", ""))
	dir = dir.replace("\\", "/").rstrip("/")
	if dir.is_empty():
		return ""
	if FORBIDDEN_FOLDERS.has(dir.get_file().to_lower()):
		push_error("Refusing to import from %s" % dir)
		print("Error: refusing to import from %s" % dir)
		return ""
	if not DirAccess.dir_exists_absolute(dir):
		print("Error: art source folder not found: %s" % dir)
		return ""
	return dir


func _merge(a: ArtImporter.Result, b: ArtImporter.Result) -> ArtImporter.Result:
	a.added.append_array(b.added)
	a.unknown.append_array(b.unknown)
	a.errors.append_array(b.errors)
	a.replaced.append_array(b.replaced)
	a.cropped.append_array(b.cropped)
	# b's tally ran after a's files and the inbox files were written, so it is the current state.
	a.missing = b.missing
	a.have = b.have
	a.present = b.present
	a.total = b.total
	return a
