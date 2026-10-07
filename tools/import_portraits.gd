extends SceneTree
## The portrait importer: `bash tools/import_portraits.sh`. Copies the Drive folder in art_config.cfg (`portrait_dir`, read-only) to
## assets/art/portraits/<Portrait Image ID>[_EXPRESSION].webp (transparent, 768 px tall) and reports IDs without an image and files that match no ID.


func _init() -> void:
	var known: Dictionary = Portraits.known_portraits()
	var source: String = Portraits.source_dir()
	if source.is_empty() or not DirAccess.dir_exists_absolute(source):
		print("Error: portrait source folder not found: '%s'" % source)
		quit(1)
		return
	var result: Portraits.Result = Portraits.import_from_source(source, Portraits.OUT_DIR, Portraits.MANIFEST_PATH, known)
	print("Source: %s" % source)
	print("Added: %s" % (", ".join(result.added) if not result.added.is_empty() else "(none)"))
	print("Replaced (source changed): %s" % (", ".join(result.replaced) if not result.replaced.is_empty() else "(none)"))
	print("Unchanged: %d" % result.unchanged)
	print("Flat background removed: %s" % (", ".join(result.background_removed) if not result.background_removed.is_empty() else "(none; all images already transparent)"))
	print("Files matching no Portrait Image ID: %s" % (", ".join(result.unknown) if not result.unknown.is_empty() else "(none)"))
	print("Portrait Image IDs in the NPC list with no image: %s" % (", ".join(result.missing) if not result.missing.is_empty() else "(none)"))
	for problem: String in result.errors:
		print("Error: %s" % problem)
	Portraits.write_status("res://docs/art/art_status.md")
	print("HAVE: %s" % ",".join(result.have))
	quit(0)
