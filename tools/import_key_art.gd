extends SceneTree
## The vendor-screen and key-art importer: `bash tools/import_key_art.sh`. Copies the Drive folders in art_config.cfg (`vendor_dir`, `keyart_dir`, read-only) to
## assets/art/vendors and assets/art/keyart, writes the app icon files and data/vendors/vendor_screens.json, and reports IDs without an image and unmatched files.


func _init() -> void:
	var vendor_src: String = KeyArt.source_dir("vendor_dir", "VENDOR_SOURCE_DIR")
	var key_src: String = KeyArt.source_dir("keyart_dir", "KEYART_SOURCE_DIR")
	var result: KeyArt.Result = KeyArt.import_from_source(vendor_src, key_src)
	print("Sources: %s | %s" % [vendor_src, key_src])
	print("Added: %s" % (", ".join(result.added) if not result.added.is_empty() else "(none)"))
	print("Replaced (source changed): %s" % (", ".join(result.replaced) if not result.replaced.is_empty() else "(none)"))
	print("Unchanged: %d" % result.unchanged)
	print("Store art left alone (not game art): %s" % (", ".join(result.skipped_store) if not result.skipped_store.is_empty() else "(none)"))
	print("Files matching no ID: %s" % (", ".join(result.unknown) if not result.unknown.is_empty() else "(none)"))
	print("IDs of the sheets with no image: %s" % (", ".join(result.missing) if not result.missing.is_empty() else "(none)"))
	for problem: String in result.errors:
		print("Error: %s" % problem)
	KeyArt.write_status("res://docs/art/art_status.md")
	print("HAVE: %s" % ",".join(result.have))
	quit(0)
