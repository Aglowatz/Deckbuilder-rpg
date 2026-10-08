extends SceneTree
## The dungeon list importer: `bash tools/import_dungeons.sh`. Reads the designer's CSV (data/source/dungeon_list.csv; row 4 is the header, dungeon rows start
## with "D-" or "S-") and writes data/dungeons/dungeons.json for `DungeonCatalog`: the dungeon's text columns plus its parsed node list (number, name, type, note,
## the CSV's x/y percentages, forward links, and for D-PC's dead-end side branches the main-path node each one returns to).

const SOURCE_PATH: String = "res://data/source/dungeon_list.csv"
const OUT_PATH: String = "res://data/dungeons/dungeons.json"
const TYPES: Dictionary = {
	"Start": "start", "Battle": "battle", "Elite": "elite", "Boss": "boss", "Treasure": "treasure", "Event": "event",
	"Deck Challenge": "challenge", "Full Heal": "heal", "Rescue Event": "rescue",
}
## Column order of the CSV (see the header row).
const C_ID: int = 0
const C_NAME: int = 1
const C_TYPE: int = 2
const C_ZONE: int = 3
const C_THEME: int = 4
const C_STORY: int = 5
const C_BOSS: int = 6
const C_LAYOUT: int = 10
const C_BUFFS: int = 11
const C_FIRST: int = 12
const C_REPEAT: int = 13
const C_HOOK: int = 14
const C_MAP: int = 15
const C_BOARD: int = 17

var _problems: Array[String] = []


func _init() -> void:
	var source: String = ProjectSettings.globalize_path(SOURCE_PATH)
	if not FileAccess.file_exists(source):
		print("Error: %s not found" % source)
		quit(1)
		return
	var file: FileAccess = FileAccess.open(source, FileAccess.READ)
	var dungeons: Array = []
	var seen_header: bool = false
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.is_empty():
			continue
		var first: String = row[0].strip_edges()
		if first == "Dungeon ID":
			seen_header = true
			continue
		if not seen_header or not (first.begins_with("D-") or first.begins_with("S-")):
			continue
		dungeons.append(_dungeon(row))
	var out: FileAccess = FileAccess.open(ProjectSettings.globalize_path(OUT_PATH), FileAccess.WRITE)
	out.store_string(JSON.stringify(dungeons, "\t", false) + "\n")
	out.close()
	print("Imported %d dungeons into %s" % [dungeons.size(), OUT_PATH])
	_write_reward_doc(dungeons)
	for problem: String in _problems:
		print("Problem: %s" % problem)
	quit(0)


func _cell(row: PackedStringArray, index: int) -> String:
	return row[index].strip_edges().replace("\r", "") if index < row.size() else ""


func _dungeon(row: PackedStringArray) -> Dictionary:
	var id: String = _cell(row, C_ID)
	return {
		"id": id,
		"name": _cell(row, C_NAME),
		"type": _cell(row, C_TYPE),
		"zone": _zone_id(_cell(row, C_ZONE)),
		"zone_text": _cell(row, C_ZONE),
		"theme": _cell(row, C_THEME),
		"story": _cell(row, C_STORY),
		"boss": _cell(row, C_BOSS),
		"buffs": _cell(row, C_BUFFS),
		"reward_first": _cell(row, C_FIRST),
		"reward_repeat": _cell(row, C_REPEAT),
		"hook": _cell(row, C_HOOK),
		"map_id": _cell(row, C_MAP),
		"battleboard_id": _cell(row, C_BOARD),
		"nodes": _nodes(id, _cell(row, C_LAYOUT)),
	}


## The game's zone id of a "Zone / Path" cell ("" = the starting area, "town" = the main town).
func _zone_id(text: String) -> String:
	var lower: String = text.to_lower()
	for key: String in ["beefcake", "gourmand", "necrocrat", "refusemancer"]:
		if lower.contains(key):
			return key
	if lower.contains("capital"):
		return "final"
	if lower.contains("town"):
		return "town"
	return "start"


func _nodes(dungeon_id: String, layout: String) -> Array:
	var regex: RegEx = RegEx.new()
	regex.compile(r"^(\d+)\.\s+(.*?)\s+-\s+(Start|Battle|Elite|Boss|Treasure|Event|Deck Challenge|Full Heal|Rescue Event)(?:\s+\(([^)]*)\))?\s+-\s+\((\d+)%,\s*(\d+)%\)(.*)$")
	var nodes: Array = []
	var side: bool = false
	for raw_line: String in layout.split("\n"):
		var line: String = raw_line.strip_edges()
		if line.is_empty():
			continue
		if line.begins_with("DEAD-END"):
			side = true
			continue
		if line.begins_with("MAIN PATH"):
			continue
		var found: RegExMatch = regex.search(line)
		if found == null:
			_problems.append("%s: cannot parse node line '%s'" % [dungeon_id, line])
			continue
		var type: String = str(TYPES[found.get_string(3)])
		var note: String = found.get_string(4)
		if type == "battle" and note.to_lower() == "boss":
			type = "boss"
			note = ""
		var next: Array = []
		var tail: String = found.get_string(7)
		var arrow: int = tail.find("->")
		var tail_note: String = ""
		if arrow >= 0:
			var targets: String = tail.substr(arrow + 2)
			var paren: int = targets.find("(")
			if paren >= 0:
				tail_note = targets.substr(paren).strip_edges().trim_prefix("(").trim_suffix(")")
				targets = targets.substr(0, paren)
			for part: String in targets.split(","):
				if part.strip_edges().is_valid_int():
					next.append(int(part.strip_edges()))
		nodes.append({
			"n": int(found.get_string(1)),
			"name": found.get_string(2),
			"type": type,
			"note": note if tail_note.is_empty() else (tail_note if note.is_empty() else note + "; " + tail_note),
			"x": int(found.get_string(5)),
			"y": int(found.get_string(6)),
			"next": next,
			"side": side,
			"return_to": 0,
		})
	_assign_returns(dungeon_id, nodes)
	return nodes


## A dead-end side branch returns to the main-path node that lists it (or, for a chain like 20 -> 21, the node the chain's first link hangs off).
func _assign_returns(dungeon_id: String, nodes: Array) -> void:
	var by_number: Dictionary = {}
	for node: Variant in nodes:
		by_number[int((node as Dictionary)["n"])] = node
	for node: Variant in nodes:
		var entry: Dictionary = node as Dictionary
		if not bool(entry["side"]):
			continue
		var returns: int = 0
		var current: int = int(entry["n"])
		var guard: int = 0
		while returns == 0 and guard < 10:
			guard += 1
			var found_parent: bool = false
			for other: Variant in nodes:
				var parent: Dictionary = other as Dictionary
				if (parent["next"] as Array).has(current):
					found_parent = true
					if bool(parent["side"]):
						current = int(parent["n"])
					else:
						returns = int(parent["n"])
					break
			if not found_parent:
				break
		if returns == 0:
			_problems.append("%s: side node %d is not linked from anywhere" % [dungeon_id, int(entry["n"])])
		entry["return_to"] = returns


## docs/design/reward_cards.md: the dungeon rewards exactly as the CSV lists them (generated; edit the sheet and re-import).
func _write_reward_doc(dungeons: Array) -> void:
	var names: Dictionary = {}
	for entry: CardImporter.Entry in CardImporter.parse_cards():
		names[entry.id] = entry.data.display_name
	var overrides: Dictionary = CardImporter.load_overrides()
	var regex: RegEx = RegEx.new()
	regex.compile(r"\(([A-Z0-9]+-\d+)(?:,[^)]*)?\)")
	var lines: PackedStringArray = PackedStringArray([
		"# Reward cards",
		"",
		"Generated by `tools/import_dungeons` from `data/source/dungeon_list.csv` (columns \"Reward for 1st Victory\" and \"Reward for Repeat Clears\"). Do not edit by hand:",
		"change the sheet and run `bash tools/import_dungeons.sh`. A unique first-victory card is granted once (`Session.resolve_main_dungeon` / `resolve_mini_dungeon`) and is flagged",
		"`not_in_packs` in `data/source/card_overrides.csv`, so it never appears in packs, vendors or ordinary reward rolls. Repeat clears pay the listed pack plus gold",
		"(`DungeonBuilder.MAIN_REPEAT_GOLD` for a main dungeon, `SIDE_REWARD_GOLD` for a side dungeon; the sheet only says \"gold\", the amounts are placeholders).",
		"",
		"| Dungeon | Name | Type | First victory | Unique card | Not in packs | Repeat clears |",
		"|---------|------|------|---------------|-------------|--------------|---------------|",
	])
	for entry: Variant in dungeons:
		var dungeon: Dictionary = entry as Dictionary
		var first: String = str(dungeon["reward_first"])
		var found: RegExMatch = regex.search(first)
		var card_id: String = found.get_string(1) if found != null else ""
		var card_text: String = "%s %s" % [card_id, names.get(card_id, "?")] if not card_id.is_empty() else "(none)"
		var flagged: String = "(n/a)"
		if not card_id.is_empty():
			flagged = "yes" if bool((overrides.get(card_id, {}) as Dictionary).get("not_in_packs", false)) else "**NO**"
		lines.append("| %s | %s | %s | %s | %s | %s | %s |" % [dungeon["id"], str(dungeon["name"]).replace("|", "/"), dungeon["type"], first.replace("|", "/"), card_text, flagged, str(dungeon["reward_repeat"]).replace("|", "/")])
	lines.append("")
	lines.append("Other reward-only cards (quests, chests, the black market, vendors) are defined in code and data: see `ZoneQuestDefinitions`, `CapitalContent`, `ZoneCards` and `data/source/card_overrides.csv`.")
	lines.append("")
	var out: FileAccess = FileAccess.open(ProjectSettings.globalize_path("res://docs/design/reward_cards.md"), FileAccess.WRITE)
	out.store_string("\n".join(lines))
	out.close()
