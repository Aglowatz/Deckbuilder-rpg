extends SceneTree
## The UI art importer: `bash tools/import_ui_art.sh`. Copies the Drive folder in art_config.cfg (`ui_dir`, read-only) to assets/art/ui/<UI ID>.webp and reports
## IDs without an image and files that match no ID.


func _init() -> void:
	var known: Dictionary = UiArt.known_ids()
	var source: String = UiArt.source_dir()
	if source.is_empty() or not DirAccess.dir_exists_absolute(source):
		print("Error: UI art source folder not found: '%s'" % source)
		quit(1)
		return
	var result: UiArt.Result = UiArt.import_from_source(source, UiArt.OUT_DIR, UiArt.MANIFEST_PATH, known)
	print("Source: %s" % source)
	print("Added: %s" % (", ".join(result.added) if not result.added.is_empty() else "(none)"))
	print("Replaced (source changed): %s" % (", ".join(result.replaced) if not result.replaced.is_empty() else "(none)"))
	print("Unchanged: %d" % result.unchanged)
	print("Flat background removed: %s" % (", ".join(result.background_removed) if not result.background_removed.is_empty() else "(none; all images already transparent)"))
	print("Files matching no UI ID: %s" % (", ".join(result.unknown) if not result.unknown.is_empty() else "(none)"))
	print("UI IDs of the kit with no image: %s" % (", ".join(result.missing) if not result.missing.is_empty() else "(none)"))
	for problem: String in result.errors:
		print("Error: %s" % problem)
	UiArt.write_status("res://docs/art/art_status.md")
	print("HAVE: %s" % ",".join(result.have))
	quit(0)
