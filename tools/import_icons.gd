extends SceneTree
## The icons importer: `bash tools/import_ui_art.sh`. Copies the Drive folder in art_config.cfg (`ui_dir`, read-only) to assets/art/ui/<icon ID>.webp and reports
## IDs without an image and files that match no ID.


func _init() -> void:
	var known: Dictionary = IconArt.known_ids()
	var source: String = IconArt.source_dir()
	if source.is_empty() or not DirAccess.dir_exists_absolute(source):
		print("Error: icons source folder not found: '%s'" % source)
		quit(1)
		return
	var result: IconArt.Result = IconArt.import_from_source(source, IconArt.OUT_DIR, IconArt.MANIFEST_PATH, known)
	print("Source: %s" % source)
	print("Added: %s" % (", ".join(result.added) if not result.added.is_empty() else "(none)"))
	print("Replaced (source changed): %s" % (", ".join(result.replaced) if not result.replaced.is_empty() else "(none)"))
	print("Unchanged: %d" % result.unchanged)
	print("Flat background removed: %s" % (", ".join(result.background_removed) if not result.background_removed.is_empty() else "(none; all images already transparent)"))
	print("Files matching no icon ID: %s" % (", ".join(result.unknown) if not result.unknown.is_empty() else "(none)"))
	print("icon IDs of the kit with no image: %s" % (", ".join(result.missing) if not result.missing.is_empty() else "(none)"))
	for problem: String in result.errors:
		print("Error: %s" % problem)
	IconArt.write_status("res://docs/art/art_status.md")
	print("HAVE: %s" % ",".join(result.have))
	quit(0)
