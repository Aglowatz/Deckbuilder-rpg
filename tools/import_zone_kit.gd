extends SceneTree
## "import zone kit <zone>": copies one zone's approved kit art (Approved_ZoneKits/<Zone> on the Drive, read-only) into the project, prepared by lock, and registers it so
## EnvKit resolves every id (material swaps, cut-outs, tree cards, props, backdrops). Works for every zone that has a sheet `data/source/<zone>_kit.csv` (rows 1-7 style target
## and locks, row 9 the header ID, Asset, Category, Lock, Image Description, Size / Format, In-Game Use, Priority, Status; assets from row 10) and a folder named after it.
##   Godot --headless --path . -s res://tools/import_zone_kit.gd -- --zone=gainlands [--only=GAIN-WALL-BRICK,GAIN-SHEET-DOORS] [--out=res://_art_inbox/zone_kit_preview/]
## Per lock (tools/zone_kit_prep.gd, tools/env_kit_prep.gd):
##   SURFACE  seam check and repair on the tiling axes, normal + roughness maps (<ID>_n / <ID>_r), one texel density (400 px/m) like the town kit
##   CUTOUT / TREE  alpha cleanup, trim, pivot (base, bracket, trunk)
##   SHEET    sliced into <ID>-01..06 (reading order), each a cut-out registered as a door / window / sign / banner
##   CONCEPT  reference only: a small copy under docs/art/zone_kits/<zone>/concepts/ (the landmark is modelled in code)
##   BACKDROP full width kept, transparent rows trimmed, 2048 px wide at most (ring and sky cards)
## Writes assets/art/zone_kits/<zone>/, data/art/zone_kits/<zone>.json (hand-added keys of existing entries are kept) and docs/art/zone_kits/<zone>_import_report.md.
## Never creates art; a missing file is reported and its id stays whatever the game falls back to.

const CONFIG: String = "res://data/source/art_config.cfg"
const MAX_SIDE: int = 1536
const MAX_BACKDROP: int = 2048
const Prep = preload("res://tools/env_kit_prep.gd")
const ZonePrep = preload("res://tools/zone_kit_prep.gd")

var _zone: String = ""
var _report: PackedStringArray = PackedStringArray()


func _initialize() -> void:
	var args: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			args[parts[0]] = parts[1] if parts.size() > 1 else ""
	_zone = str(args.get("zone", "")).strip_edges().to_lower()
	if _zone == "":
		print("import_zone_kit: --zone=<area id> is required (data/source/<zone>_kit.csv)")
		quit(1)
		return
	var csv_path: String = "res://data/source/%s_kit.csv" % _zone
	if not FileAccess.file_exists(csv_path):
		print("import_zone_kit: %s missing" % csv_path)
		quit(1)
		return
	var config: ConfigFile = ConfigFile.new()
	config.load(CONFIG)
	var root_dir: String = OS.get_environment("ZONEKIT_SOURCE_DIR")
	if root_dir == "":
		root_dir = str(config.get_value("art", "zonekits_dir", "G:/My Drive/Card Game Art/Approved_ZoneKits"))
	for forbidden: String in ["Pending Review", "Superseded"]:
		if root_dir.contains(forbidden):
			print("import_zone_kit: refusing to read from %s" % forbidden)
			quit(1)
			return
	var source: String = _zone_folder(root_dir)
	var out_dir: String = str(args.get("out", "res://assets/art/zone_kits/%s/" % _zone))
	if not out_dir.ends_with("/"):
		out_dir += "/"
	var preview: bool = out_dir != "res://assets/art/zone_kits/%s/" % _zone
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	var only: PackedStringArray = str(args.get("only", "")).split(",", false)
	var rows: Array[Dictionary] = _read_sheet(csv_path)
	var registry_path: String = "res://data/art/zone_kits/%s.json" % _zone
	var items: Dictionary = _existing_items(registry_path)
	var imported: PackedStringArray = PackedStringArray()
	var missing: PackedStringArray = PackedStringArray()
	var notes: PackedStringArray = PackedStringArray()
	var wanted: Dictionary = {}
	var out_base: String = ProjectSettings.globalize_path(out_dir)
	for row: Dictionary in rows:
		var id: String = str(row["id"])
		wanted[id] = true
		if not only.is_empty() and not (id in only):
			continue
		var path: String = "%s/%s.png" % [source, id]
		var entry: Dictionary = _entry_from_row(row)
		if not FileAccess.file_exists(path):
			missing.append(id)
			_merge_item(items, id, entry)
			continue
		var image: Image = Image.load_from_file(path)
		if image == null or image.is_empty():
			missing.append(id + " (unreadable)")
			_merge_item(items, id, entry)
			continue
		image.convert(Image.FORMAT_RGBA8)
		entry["from_px"] = [image.get_width(), image.get_height()]
		var lock: String = str(entry["lock"])
		var line: String = ""
		match lock:
			"SURFACE":
				line = _surface(id, image, out_base, entry)
			"SHEET":
				line = _sheet(id, image, out_base, entry, items, preview)
			"CONCEPT":
				line = _concept(id, image, entry, preview)
			"BACKDROP":
				line = _backdrop(id, image, out_base, entry)
			_:
				line = _cutout(id, image, out_base, entry)
		if line.begins_with("!"):
			missing.append("%s (%s)" % [id, line.substr(1)])
		else:
			imported.append(line)
		if entry.has("note"):
			notes.append("%s: %s" % [id, str(entry["note"])])
			entry.erase("note")
		_merge_item(items, id, entry)
	var stray: PackedStringArray = PackedStringArray()
	var dir: DirAccess = DirAccess.open(source)
	if dir != null:
		for file_name: String in dir.get_files():
			if file_name.get_extension().to_lower() == "png" and not wanted.has(file_name.get_basename()):
				stray.append(file_name)
	else:
		notes.append("source folder not found: %s" % source)
	if not preview and only.is_empty():
		_write_registry(registry_path, items, source)
	elif not preview:
		_write_registry(registry_path, items, source)
	_report.append("# Zone kit import report: %s\n" % _zone)
	_report.append("Source: `%s` (read-only), target: `%s`, registry: `%s`.\n" % [source, out_dir, registry_path])
	_report.append("\n## Imported (%d)\n" % imported.size())
	for text: String in imported:
		_report.append("- %s" % text)
	_report.append("\n## Missing ids (%d)\n" % missing.size())
	for text: String in missing:
		_report.append("- %s" % text)
	_report.append("\n## Files that match no kit id (%d)\n" % stray.size())
	for text: String in stray:
		_report.append("- %s" % text)
	_report.append("\n## Notes (%d)\n" % notes.size())
	for text: String in notes:
		_report.append("- %s" % text)
	if not preview and only.is_empty():
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://docs/art/zone_kits/"))
		var file: FileAccess = FileAccess.open("res://docs/art/zone_kits/%s_import_report.md" % _zone, FileAccess.WRITE)
		file.store_string("\n".join(_report) + "\n")
		file.close()
	print("import_zone_kit %s: %d imported, %d missing, %d unmatched" % [_zone, imported.size(), missing.size(), stray.size()])
	for text: String in missing:
		print("  missing: %s" % text)
	for text: String in stray:
		print("  unmatched file: %s" % text)
	for text: String in notes:
		print("  note: %s" % text)
	quit(0)


## The Drive folder of this zone: zonekit_folders[zone] in art_config.cfg when set, else a sub-folder of zonekits_dir whose name matches the zone id (case and underscores ignored), else the capitalised id.
func _zone_folder(root_dir: String) -> String:
	var config: ConfigFile = ConfigFile.new()
	config.load(CONFIG)
	var mapped: Dictionary = config.get_value("art", "zonekit_folders", {})
	if mapped.has(_zone):
		return "%s/%s" % [root_dir, str(mapped[_zone])]
	var wanted: String = _zone.replace("_", "")
	var dir: DirAccess = DirAccess.open(root_dir)
	if dir != null:
		for name: String in dir.get_directories():
			if name.to_lower().replace("_", "").replace(" ", "") == wanted:
				return "%s/%s" % [root_dir, name]
	return "%s/%s" % [root_dir, _zone.capitalize().replace(" ", "")]


## The asset rows of the sheet (everything after the header row whose first cell is ID).
func _read_sheet(path: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var header_seen: bool = false
	while not file.eof_reached():
		var cells: PackedStringArray = file.get_csv_line()
		if cells.size() < 4:
			continue
		if cells[0].strip_edges() == "ID":
			header_seen = true
			continue
		if not header_seen or cells[0].strip_edges() == "":
			continue
		var get: Callable = func(index: int) -> String: return cells[index].strip_edges() if index < cells.size() else ""
		result.append({"id": cells[0].strip_edges(), "asset": get.call(1), "category": get.call(2), "lock": str(get.call(3)).to_upper(), "desc": get.call(4), "size": get.call(5),
			"use": get.call(6), "priority": get.call(7), "status": get.call(8)})
	file.close()
	return result


func _entry_from_row(row: Dictionary) -> Dictionary:
	var id: String = str(row["id"])
	var group: String = ZonePrep.group_for(id, str(row["category"]), str(row["use"]), str(row["asset"]))
	return {"id": id, "zone": _zone, "asset": row["asset"], "category": row["category"], "lock": row["lock"], "desc": row["desc"], "size": row["size"], "use": row["use"],
		"priority": row["priority"], "sheet_status": row["status"], "group": group, "slot": "%s.%s" % [group, id.to_lower()], "tinted": false}


func _existing_items(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed is Dictionary:
		return ((parsed as Dictionary).get("items", {}) as Dictionary).duplicate(true)
	return {}


## New numbers win; keys the importer does not write (hand-added height, width, tile, placeholder ...) are kept.
func _merge_item(items: Dictionary, id: String, entry: Dictionary) -> void:
	var merged: Dictionary = (items.get(id, {}) as Dictionary).duplicate()
	for key: Variant in entry.keys():
		merged[key] = entry[key]
	# a hand pivot (a stray leaf at the base pulls the measured trunk centre off) wins over the measured one
	if merged.has("pivot_hand"):
		merged["pivot"] = merged["pivot_hand"]
	items[id] = merged


func _write_registry(path: String, items: Dictionary, source: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://data/art/zone_kits/"))
	var keys: Array = items.keys()
	keys.sort()
	var ordered: Dictionary = {}
	for key: Variant in keys:
		ordered[key] = items[key]
	var data: Dictionary = {
		"_about": "Written by tools/import_zone_kit.gd from data/source/%s_kit.csv and the art in %s: one entry per kit id with its lock, family (group / slot), prepared size, pivot (0..1 of the trimmed image), tile size in metres at %d px/m, sheet parts. EnvKit reads it: every id here resolves like an Environment Kit id (assets/art/zone_kits/%s/<ID>.webp). Hand-added keys (height, width, tile, placeholder, slot) survive a re-import; entries not on the sheet (aliases) are kept." % [_zone, source, int(Prep.DENSITY), _zone],
		"zone": _zone,
		"density": Prep.DENSITY,
		"items": ordered,
	}
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t") + "\n")
	file.close()


# ---- per lock ------------------------------------------------------------------------------------------------------------------------------


func _downscale(image: Image, max_side: int) -> void:
	var longest: int = maxi(image.get_width(), image.get_height())
	if longest > max_side:
		var scale_value: float = float(max_side) / float(longest)
		image.resize(int(round(float(image.get_width()) * scale_value)), int(round(float(image.get_height()) * scale_value)), Image.INTERPOLATE_LANCZOS)


func _surface(id: String, image: Image, out_base: String, entry: Dictionary) -> String:
	_downscale(image, MAX_SIDE)
	var size_text: String = str(entry.get("size", ""))
	var tile_x: bool = ZonePrep.tiles(size_text, true)
	var tile_y: bool = ZonePrep.tiles(size_text, false)
	var notes: PackedStringArray = PackedStringArray()
	var seam: Dictionary = {}
	for axis: String in ["x", "y"]:
		var horizontal: bool = axis == "x"
		if not (tile_x if horizontal else tile_y):
			continue
		var before: float = Prep.seam_ratio(image, horizontal)
		var after: float = before
		if before > Prep.SEAM_LIMIT:
			var fixed: Image = Prep.make_seamless(image, horizontal)
			if Prep.seam_ratio(fixed, horizontal) < before:
				image.copy_from(fixed)
			after = Prep.seam_ratio(image, horizontal)
		seam[axis] = {"before": snappedf(before, 0.01), "after": snappedf(after, 0.01)}
		notes.append("%s %.1f->%.1f" % [axis, before, after])
	entry["seam"] = seam
	entry["tile_x"] = tile_x
	entry["tile_y"] = tile_y
	entry["px"] = [image.get_width(), image.get_height()]
	entry["tile_u"] = snappedf(float(image.get_width()) / Prep.DENSITY, 0.01)
	entry["tile_v"] = snappedf(float(image.get_height()) / Prep.DENSITY, 0.01)
	var small: Image = image.duplicate() as Image
	if maxi(small.get_width(), small.get_height()) > 512:
		var factor: float = 512.0 / float(maxi(small.get_width(), small.get_height()))
		small.resize(int(small.get_width() * factor), int(small.get_height() * factor), Image.INTERPOLATE_BILINEAR)
	Prep.normal_map(small, tile_x, tile_y).save_webp("%s%s_n.webp" % [out_base, id], true, 0.9)
	var rough: Image = Prep.roughness_map(small)
	rough.convert(Image.FORMAT_RGB8)
	rough.save_webp("%s%s_r.webp" % [out_base, id], true, 0.85)
	entry["maps"] = true
	var error: Error = image.save_webp("%s%s.webp" % [out_base, id], true, 0.92)
	if error != OK:
		return "!save: %s" % error_string(error)
	return "%s (surface %dx%d, %.2f m tile, seam %s)" % [id, image.get_width(), image.get_height(), float(entry["tile_u"]), ", ".join(notes) if not notes.is_empty() else "no tiling"]


## Cleans, trims and pivots one cut-out image in place; returns the numbers for the registry.
func _prepare_cutout(image: Image, group: String, entry: Dictionary) -> void:
	var cleared: int = Prep.clean_alpha(image)
	var rect: Rect2i = Prep.bounds(image)
	var pad: int = 2
	var padded: Rect2i = Rect2i(maxi(rect.position.x - pad, 0), maxi(rect.position.y - pad, 0), 0, 0)
	padded.end = Vector2i(mini(rect.end.x + pad, image.get_width()), mini(rect.end.y + pad, image.get_height()))
	image.copy_from(image.get_region(padded))
	var pivot: Vector2 = ZonePrep.pivot_for(group, image)
	entry["px"] = [image.get_width(), image.get_height()]
	entry["pivot"] = [snappedf(pivot.x, 0.001), snappedf(pivot.y, 0.001)]
	entry["aspect"] = snappedf(float(image.get_width()) / float(image.get_height()), 0.001)
	entry["cleared_alpha"] = cleared


func _cutout(id: String, image: Image, out_base: String, entry: Dictionary) -> String:
	_downscale(image, MAX_SIDE)
	var corner_alpha: float = maxf(maxf(image.get_pixel(0, 0).a, image.get_pixel(image.get_width() - 1, 0).a), maxf(image.get_pixel(0, image.get_height() - 1).a, image.get_pixel(image.get_width() - 1, image.get_height() - 1).a))
	if corner_alpha > 0.5:
		entry["note"] = "opaque corners: the file has no transparent background (kept as painted)"
	_prepare_cutout(image, str(entry["group"]), entry)
	var error: Error = image.save_webp("%s%s.webp" % [out_base, id], true, 0.92)
	if error != OK:
		return "!save: %s" % error_string(error)
	var pivot: Array = entry["pivot"] as Array
	return "%s (%s %dx%d trimmed, pivot %.2f,%.2f)" % [id, str(entry["lock"]).to_lower(), image.get_width(), image.get_height(), float(pivot[0]), float(pivot[1])]


func _sheet(id: String, image: Image, out_base: String, entry: Dictionary, items: Dictionary, _preview: bool) -> String:
	var cells: Array[Rect2i] = ZonePrep.slice_grid(image, 3, 2)
	var parts: Array = []
	var sizes: PackedStringArray = PackedStringArray()
	var group: String = str(entry["group"])
	var empty: int = 0
	for index: int in range(cells.size()):
		var cell: Rect2i = cells[index]
		var part_id: String = "%s-%02d" % [id, index + 1]
		if cell.size.x <= 0 or cell.size.y <= 0:
			empty += 1
			continue
		var part: Image = image.get_region(cell)
		var part_entry: Dictionary = {"id": part_id, "zone": _zone, "parent": id, "index": index + 1, "lock": "CUTOUT", "group": group, "slot": "%s.%s" % [group, part_id.to_lower()],
			"asset": "%s %d" % [str(entry["asset"]), index + 1], "category": str(entry["category"]), "desc": str(entry["desc"]), "use": str(entry["use"]), "tinted": false,
			"from_px": [cell.size.x, cell.size.y], "sheet_cell": [cell.position.x, cell.position.y, cell.size.x, cell.size.y]}
		_prepare_cutout(part, group, part_entry)
		var error: Error = part.save_webp("%s%s.webp" % [out_base, part_id], true, 0.92)
		if error != OK:
			return "!save %s: %s" % [part_id, error_string(error)]
		parts.append(part_id)
		sizes.append("%dx%d" % [part.get_width(), part.get_height()])
		_merge_item(items, part_id, part_entry)
	entry["parts"] = parts
	entry["px"] = [image.get_width(), image.get_height()]
	if empty > 0:
		entry["note"] = "%d of 6 sheet cells were empty" % empty
	return "%s (sheet sliced into %d %ss: %s)" % [id, parts.size(), group, ", ".join(sizes)]


func _concept(id: String, image: Image, entry: Dictionary, preview: bool) -> String:
	var dir: String = "res://docs/art/zone_kits/%s/concepts/" % _zone
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	var copy: Image = image.duplicate() as Image
	_downscale(copy, 1024)
	copy.convert(Image.FORMAT_RGB8)
	var target: String = "%s%s.jpg" % [dir, id]
	if not preview:
		var error: Error = copy.save_jpg(ProjectSettings.globalize_path(target), 0.85)
		if error != OK:
			return "!save: %s" % error_string(error)
	entry["px"] = [image.get_width(), image.get_height()]
	entry["concept"] = target
	return "%s (concept reference %dx%d -> %s)" % [id, image.get_width(), image.get_height(), target]


func _backdrop(id: String, image: Image, out_base: String, entry: Dictionary) -> String:
	var corner_alpha: float = maxf(image.get_pixel(0, 0).a, image.get_pixel(image.get_width() - 1, 0).a)
	var transparent_sky: bool = corner_alpha < 0.5
	if transparent_sky:
		Prep.clean_alpha(image)
		var rows: Rect2i = ZonePrep.trim_rows(image)
		if rows.size.y < image.get_height():
			image.copy_from(image.get_region(rows))
	else:
		entry["note"] = "opaque: no transparent sky above the skyline (a full-frame picture, not a ring strip)"
	_downscale(image, MAX_BACKDROP)
	entry["px"] = [image.get_width(), image.get_height()]
	entry["aspect"] = snappedf(float(image.get_width()) / float(image.get_height()), 0.001)
	entry["transparent"] = transparent_sky
	entry["pivot"] = [0.5, 1.0]
	var error: Error = image.save_webp("%s%s.webp" % [out_base, id], true, 0.9)
	if error != OK:
		return "!save: %s" % error_string(error)
	return "%s (backdrop %dx%d%s)" % [id, image.get_width(), image.get_height(), ", transparent sky" if transparent_sky else ", opaque"]
