extends SceneTree
## The NPC list importer: `bash tools/import_npcs.sh`. Reads the designer's CSV (data/source/npc_list.csv.csv; row 4 is the header, character
## rows start with "NPC-" or "V-", the VENDOR SCREENS section is ignored) and writes data/npcs/npcs.json for `NpcRegistry`.

const OUT_PATH: String = "res://data/npcs/npcs.json"
const STOP_MARKER: String = "VENDOR SCREENS"


func _init() -> void:
	var source: String = ProjectSettings.globalize_path(NpcRegistry.SOURCE_PATH)
	if not FileAccess.file_exists(source):
		print("Error: %s not found" % source)
		quit(1)
		return
	var file: FileAccess = FileAccess.open(source, FileAccess.READ)
	var rows: Array = []
	var seen_header: bool = false
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.is_empty():
			continue
		var first: String = row[0].strip_edges()
		if first == STOP_MARKER:
			break
		if first == "NPC ID":
			seen_header = true
			continue
		if not seen_header or not (first.begins_with("NPC-") or first.begins_with("V-")):
			continue
		rows.append(_entry(row))
	var out: FileAccess = FileAccess.open(ProjectSettings.globalize_path(OUT_PATH), FileAccess.WRITE)
	out.store_string(JSON.stringify(rows, "\t") + "\n")
	out.close()
	print("Imported %d NPCs into %s" % [rows.size(), OUT_PATH])
	quit(0)


func _cell(row: PackedStringArray, index: int) -> String:
	return row[index].strip_edges() if index < row.size() else ""


func _entry(row: PackedStringArray) -> Dictionary:
	var notes: String = _cell(row, 11).replace("\r", "").replace("\n", " ")
	var expressions: Array[String] = []
	for part: String in _cell(row, 9).replace(";", ",").split(","):
		var expression: String = part.strip_edges().to_lower()
		if not expression.is_empty():
			expressions.append(expression)
	return {
		"id": _cell(row, 0),
		"name": _cell(row, 1),
		"role": _cell(row, 2),
		"location": _cell(row, 3),
		"portrait_id": _cell(row, 7),
		"species": _species(notes),
		"expressions": expressions,
		"art_status": _cell(row, 10),
		"notes": notes,
	}


## "Species: fox." / "Undead: ghost." -> "fox" / "ghost"; "" when the notes do not name a creature.
func _species(notes: String) -> String:
	for marker: String in ["Species: ", "Undead: "]:
		var at: int = notes.find(marker)
		if at >= 0:
			var rest: String = notes.substr(at + marker.length())
			var end: int = rest.find(".")
			var found: String = (rest.substr(0, end) if end >= 0 else rest).strip_edges()
			var paren: int = found.find(" (")
			return found.substr(0, paren) if paren >= 0 else found
	return ""
