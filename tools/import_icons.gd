extends SceneTree
## The icons importer: `bash tools/import_icons.sh`. Copies the Drive folder in art_config.cfg (`icons_dir`, read-only) to assets/art/icons/<ICON ID>.webp
## (+ sized variants) and reports IDs without an image and files that match no ID. Accepts every ID of data/source/icons.csv plus the expected own
## icon of every gear piece (ICON-GEAR-*), consumable (ICON-ITEM-*) and hat / cloak (ICON-COS-*) in the game data (`IconArt.import_ids`).


func _init() -> void:
	var known: Dictionary = IconArt.import_ids()
	var source: String = IconArt.source_dir()
	if source.is_empty() or not DirAccess.dir_exists_absolute(source):
		print("Error: icons source folder not found: '%s'" % source)
		quit(1)
		return
	for forbidden: String in ["Pending Review", "Superseded"]:
		if source.contains(forbidden):
			print("Error: refusing to read from %s" % forbidden)
			quit(1)
			return
	var result: IconArt.Result = IconArt.import_from_source(source, IconArt.OUT_DIR, IconArt.MANIFEST_PATH, known)
	print("Source: %s" % source)
	print("Added: %s" % (", ".join(result.added) if not result.added.is_empty() else "(none)"))
	print("Replaced (source changed): %s" % (", ".join(result.replaced) if not result.replaced.is_empty() else "(none)"))
	print("Unchanged: %d" % result.unchanged)
	print("Flat background removed: %s" % (", ".join(result.background_removed) if not result.background_removed.is_empty() else "(none; all images already transparent)"))
	print("Matched by a forgiving name (saved under the ID): %s" % (", ".join(result.renamed) if not result.renamed.is_empty() else "(none)"))
	print("Files matching no icon ID: %s" % (", ".join(result.unknown) if not result.unknown.is_empty() else "(none)"))
	var game: Dictionary = IconArt.game_ids()
	var kit_missing: Array[String] = []
	for id: String in result.missing:
		if not game.has(id):
			kit_missing.append(id)
	print("icon IDs of the kit (icons.csv) with no image: %s" % (", ".join(kit_missing) if not kit_missing.is_empty() else "(none)"))
	for category: Array in [["Gear", IconArt.GEAR_PREFIX], ["Items", IconArt.ITEM_PREFIX], ["Cosmetics", IconArt.COSMETIC_PREFIX]]:
		var expected: Array[String] = IconArt.game_ids_with_prefix(str(category[1]))
		var missing: Array[String] = []
		for id: String in expected:
			if result.missing.has(id):
				missing.append(id)
		print("%s icons (%s*): %d of %d in the game; missing: %s" % [category[0], category[1], expected.size() - missing.size(), expected.size(), ", ".join(missing) if not missing.is_empty() else "(none)"])
	for problem: String in result.errors:
		print("Error: %s" % problem)
	IconArt.write_status("res://docs/art/art_status.md")
	print("HAVE: %s" % ",".join(result.have))
	quit(0)
