extends SceneTree
## The card art importer: `bash tools/import_art.sh`. Reads PNG/JPG files named by Card ID (or mapped in data/source/art_map.csv)
## from _art_inbox/, writes 768x1152 WebP files to assets/art/cards/, moves the originals to _art_source/ and writes
## docs/art/art_status.md. See docs/art/art_pipeline.md.

const INBOX: String = "res://_art_inbox"
const SOURCE: String = "res://_art_source"
const OUT: String = "res://assets/art/cards"
const MAP: String = "res://data/source/art_map.csv"
const STATUS: String = "res://docs/art/art_status.md"


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(INBOX))
	var known: Dictionary = {}
	for entry: CardImporter.Entry in CardImporter.build_all():
		known[entry.id] = entry.data.display_name
	var result: ArtImporter.Result = ArtImporter.import_all(INBOX, OUT, SOURCE, MAP, known)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(STATUS.get_base_dir()))
	var file: FileAccess = FileAccess.open(STATUS, FileAccess.WRITE)
	file.store_string(ArtImporter.status_markdown(OUT, known, result))
	file.close()
	print("Added: %s" % (", ".join(result.added) if not result.added.is_empty() else "(none)"))
	if not result.unknown.is_empty():
		print("Unknown files: %s" % ", ".join(result.unknown))
	for problem: String in result.errors:
		print("Error: %s" % problem)
	print(result.summary())
	quit(0)
