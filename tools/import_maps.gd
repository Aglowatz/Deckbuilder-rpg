extends SceneTree
## The dungeon map importer: `bash tools/import_maps.sh`. Copies the Drive folder in art_config.cfg (`map_dir`, read-only) to assets/art/maps/<Map Image ID>.webp (3:2,
## never cropped) and reports IDs without an image and files that match no ID.


func _init() -> void:
	var known: Dictionary = MapArt.known_maps()
	var source: String = MapArt.source_dir()
	if source.is_empty() or not DirAccess.dir_exists_absolute(source):
		print("Error: map source folder not found: '%s'" % source)
		quit(1)
		return
	var result: MapArt.Result = MapArt.import_from_source(source, MapArt.OUT_DIR, MapArt.MANIFEST_PATH, known)
	print("Source: %s" % source)
	print("Added: %s" % (", ".join(result.added) if not result.added.is_empty() else "(none)"))
	print("Replaced (source changed): %s" % (", ".join(result.replaced) if not result.replaced.is_empty() else "(none)"))
	print("Unchanged: %d" % result.unchanged)
	print("Not 3:2 (kept as they are): %s" % (", ".join(result.not_three_two) if not result.not_three_two.is_empty() else "(none)"))
	print("Files matching no Map Image ID: %s" % (", ".join(result.unknown) if not result.unknown.is_empty() else "(none)"))
	print("Map Image IDs in the dungeon list with no image: %s" % (", ".join(result.missing) if not result.missing.is_empty() else "(none)"))
	for problem: String in result.errors:
		print("Error: %s" % problem)
	MapArt.write_status("res://docs/art/art_status.md")
	print("HAVE: %s" % ",".join(result.have))
	quit(0)
