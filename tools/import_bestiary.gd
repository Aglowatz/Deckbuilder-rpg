extends SceneTree
## The Bestiary picture importer: `bash tools/import_bestiary.sh`. Copies the Drive folder in art_config.cfg (`bestiary_dir`, read-only) to
## assets/art/bestiary/<BST ID>.webp (square, at most 512 px) and reports the BST IDs without a picture and files that match no ID.


func _init() -> void:
	var known: Dictionary = BestiaryArt.known_ids()
	var source: String = BestiaryArt.source_dir()
	if BestiaryArt.is_forbidden_source(source):
		print("Error: refusing to read from '%s' (Pending Review / Superseded)" % source)
		quit(1)
		return
	if source.is_empty() or not DirAccess.dir_exists_absolute(source):
		print("Error: bestiary source folder not found: '%s'" % source)
		quit(1)
		return
	var result: BestiaryArt.Result = BestiaryArt.import_from_source(source, BestiaryArt.OUT_DIR, BestiaryArt.MANIFEST_PATH, known)
	print("Source: %s" % source)
	print("Added: %s" % (", ".join(result.added) if not result.added.is_empty() else "(none)"))
	print("Replaced (source changed): %s" % (", ".join(result.replaced) if not result.replaced.is_empty() else "(none)"))
	print("Unchanged: %d" % result.unchanged)
	print("Not square (cropped to a square from the top): %s" % (", ".join(result.cropped) if not result.cropped.is_empty() else "(none)"))
	print("Matched by a forgiving name (saved under the ID): %s" % (", ".join(result.renamed) if not result.renamed.is_empty() else "(none)"))
	print("Files matching no Bestiary ID: %s" % (", ".join(result.unknown) if not result.unknown.is_empty() else "(none)"))
	print("Bestiary IDs with no picture (%d of %d): %s" % [result.missing.size(), known.size(), ", ".join(result.missing) if not result.missing.is_empty() else "(none)"])
	for problem: String in result.errors:
		print("Error: %s" % problem)
	BestiaryArt.write_status("res://docs/art/art_status.md")
	print("HAVE: %s" % ",".join(result.have))
	quit(0)
