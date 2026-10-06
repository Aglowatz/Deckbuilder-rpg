extends SceneTree
## The battleboard importer: `bash tools/import_battleboards.sh`. Copies the Drive folder in art_config.cfg (`battleboard_dir`, read-only) to
## assets/art/battleboards/<ID>.webp (centre-cropped 16:9) and reports IDs without an image, files that match no ID and unmapped boards.


func _init() -> void:
	var known: Dictionary = Battleboards.known_boards()
	var source: String = Battleboards.source_dir()
	if source.is_empty() or not DirAccess.dir_exists_absolute(source):
		print("Error: battleboard source folder not found: '%s'" % source)
		quit(1)
		return
	var result: Battleboards.Result = Battleboards.import_from_source(source, Battleboards.OUT_DIR, Battleboards.MANIFEST_PATH, known)
	print("Source: %s" % source)
	print("Added: %s" % (", ".join(result.added) if not result.added.is_empty() else "(none)"))
	print("Replaced (source changed): %s" % (", ".join(result.replaced) if not result.replaced.is_empty() else "(none)"))
	print("Unchanged: %d" % result.unchanged)
	print("Cropped to 16:9: %s" % (", ".join(result.cropped) if not result.cropped.is_empty() else "(none)"))
	print("Files matching no Battleboard ID: %s" % (", ".join(result.unknown) if not result.unknown.is_empty() else "(none)"))
	print("IDs in the CSV with no image: %s" % (", ".join(result.missing) if not result.missing.is_empty() else "(none)"))
	var used: Dictionary = {}
	for key: Variant in Battleboards.contexts():
		used[str(Battleboards.contexts()[key])] = true
	var unmapped: Array[String] = []
	for id: Variant in result.have:
		if not used.has(str(id)):
			unmapped.append("%s (%s)" % [id, (known[id] as Array)[1]])
	print("Boards in the game but mapped to no context: %s" % (", ".join(unmapped) if not unmapped.is_empty() else "(none)"))
	for problem: String in result.errors:
		print("Error: %s" % problem)
	Battleboards.write_status("res://docs/art/art_status.md")
	print("HAVE: %s" % ",".join(result.have))
	quit(0)
