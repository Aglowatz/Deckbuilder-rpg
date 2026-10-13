extends SceneTree
## Merges the designer's Environment Kit sheet (data/source/env_kit.csv, the sheet's tab exported as CSV) into data/art/environment_kit.json: description, size / format, lock
## (SURFACE / CUTOUT / TREE), in-game use and status for every ID the sheet lists. The slot and the placeholder stay as they are. IDs of the sheet that the data file does not
## know are appended with `slot` "" and reported.
##   Godot --headless --path . -s res://tools/env_kit_sync.gd

const CSV_PATH: String = "res://data/source/env_kit.csv"
const JSON_PATH: String = "res://data/art/environment_kit.json"


func _initialize() -> void:
	var file: FileAccess = FileAccess.open(CSV_PATH, FileAccess.READ)
	if file == null:
		print("env_kit_sync: %s missing" % CSV_PATH)
		quit(1)
		return
	var rows: Dictionary = {}
	var header_seen: bool = false
	while not file.eof_reached():
		var cells: PackedStringArray = file.get_csv_line()
		if cells.size() < 8:
			continue
		if cells[0] == "ID":
			header_seen = true
			continue
		if not header_seen or cells[0].strip_edges() == "":
			continue
		rows[cells[0].strip_edges()] = cells
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(JSON_PATH)) as Dictionary
	var items: Array = data["items"] as Array
	var known: Dictionary = {}
	var updated: int = 0
	for item: Variant in items:
		var entry: Dictionary = item as Dictionary
		var id: String = str(entry["id"])
		known[id] = true
		if not rows.has(id):
			continue
		var cells: PackedStringArray = rows[id] as PackedStringArray
		entry["asset"] = cells[1]
		entry["category"] = cells[2]
		entry["lock"] = cells[3]
		entry["desc"] = cells[4]
		entry["size"] = cells[5]
		entry["use"] = cells[6]
		entry["sheet_status"] = cells[7]
		entry["notes"] = cells[8] if cells.size() > 8 else ""
		entry.erase("suggested")
		updated += 1
	for id: String in rows.keys():
		if not known.has(id):
			print("env_kit_sync: sheet id %s is not in the data file" % id)
	var missing: PackedStringArray = PackedStringArray()
	for item: Variant in items:
		var id: String = str((item as Dictionary)["id"])
		if not rows.has(id):
			missing.append(id)
	print("env_kit_sync: %d entries updated from the sheet; not on the sheet (suggested): %s" % [updated, ", ".join(missing)])
	var out: FileAccess = FileAccess.open(JSON_PATH, FileAccess.WRITE)
	out.store_string(JSON.stringify(data, "\t", false) + "\n")
	out.close()
	quit(0)
