class_name NpcRegistry
extends RefCounted
## The designer's NPC list (`data/source/npc_list.csv.csv`, imported into `data/npcs/npcs.json` by `tools/import_npcs`): every character
## with a dialogue portrait, keyed by NPC ID ("NPC-ELDER", "V-SABLE"). `data/npcs/npc_game_map.json` is hand-written and ties the game to
## the list: extra speaker aliases (the throwers, the rift technicians...), and which NPC speaks a dungeon story beat.
## In-game NPCs store their NPC ID in their data (zone defs, the town); a dialogue box finds the portrait through it.

const NPC_PATH: String = "res://data/npcs/npcs.json"
const MAP_PATH: String = "res://data/npcs/npc_game_map.json"
const SOURCE_PATH: String = "res://data/source/npc_list.csv.csv"
const PLAYER_ID: String = "NPC-PLAYER"


## One row of the list.
class Entry extends RefCounted:
	var id: String = ""
	var name: String = ""
	var role: String = ""
	var location: String = ""
	var portrait_id: String = ""
	var species: String = ""
	var notes: String = ""
	var expressions: Array[String] = []
	## "left" (default) or "right": which side of the dialogue box the portrait stands on.
	var side: String = "left"

	## The name shown on the dialogue name plate ("Brick Bronson (corrupted)", "The Wanderer (player)": the bracket is a list annotation, not part of the name).
	func plate_name() -> String:
		return name.replace(" (corrupted)", "").replace(" (player)", "").strip_edges()

	## The name before a comma or a bracket ("Kyle (Deceased Since '09)" -> "Kyle"): what the game data (speaker labels, quest givers) calls the NPC.
	func short_name() -> String:
		var result: String = plate_name()
		for cut: String in [",", " ("]:
			var at: int = result.find(cut)
			if at > 0:
				result = result.substr(0, at)
		return result.strip_edges()


static var _entries: Dictionary = {}
static var _by_name: Dictionary = {}
static var _aliases: Dictionary = {}
static var _prefixes: Dictionary = {}
static var _story_keys: Dictionary = {}
static var _loaded: bool = false


static func reset() -> void:
	_loaded = false
	_entries = {}
	_by_name = {}
	_aliases = {}
	_prefixes = {}
	_story_keys = {}


static func _load() -> void:
	if _loaded:
		return
	_loaded = true
	_entries = {}
	_by_name = {}
	_aliases = {}
	_prefixes = {}
	_story_keys = {}
	var parsed: Variant = _read_json(NPC_PATH)
	if parsed is Array:
		for row: Variant in parsed as Array:
			if not row is Dictionary:
				continue
			var data: Dictionary = row as Dictionary
			var entry: Entry = Entry.new()
			entry.id = str(data.get("id", ""))
			entry.name = str(data.get("name", ""))
			entry.role = str(data.get("role", ""))
			entry.location = str(data.get("location", ""))
			entry.portrait_id = str(data.get("portrait_id", entry.id))
			entry.species = str(data.get("species", ""))
			entry.notes = str(data.get("notes", ""))
			entry.side = str(data.get("side", "left"))
			for expression: Variant in data.get("expressions", []) as Array:
				entry.expressions.append(str(expression))
			if entry.id.is_empty():
				continue
			_entries[entry.id] = entry
			_by_name[entry.plate_name()] = entry.id
			_by_name[entry.name] = entry.id
			if not _by_name.has(entry.short_name()):
				_by_name[entry.short_name()] = entry.id
	var map: Variant = _read_json(MAP_PATH)
	if map is Dictionary:
		var table: Dictionary = map as Dictionary
		_aliases = (table.get("speakers", {}) as Dictionary).duplicate()
		_prefixes = (table.get("speaker_prefixes", {}) as Dictionary).duplicate()
		_story_keys = (table.get("story_keys", {}) as Dictionary).duplicate()
		var sides: Dictionary = table.get("sides", {}) as Dictionary
		for id: Variant in sides.keys():
			if _entries.has(str(id)):
				(_entries[str(id)] as Entry).side = str(sides[id])


static func _read_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	return JSON.parse_string(FileAccess.get_file_as_string(path))


## Every NPC of the list, in file order.
static func all() -> Array[Entry]:
	_load()
	var result: Array[Entry] = []
	for entry: Variant in _entries.values():
		result.append(entry as Entry)
	return result


static func has(id: String) -> bool:
	_load()
	return _entries.has(id)


static func find(id: String) -> Entry:
	_load()
	return _entries.get(id) as Entry


## The plate name of an NPC ("" for an unknown ID).
static func display_name(id: String) -> String:
	var entry: Entry = find(id)
	return "" if entry == null else entry.plate_name()


## The NPC ID a speaker label belongs to: a list name, an alias ("Brock" -> NPC-HURL) or a prefix alias ("Rip Tearson (Cousin #3)"). "" when none.
static func resolve_speaker(speaker: String) -> String:
	_load()
	var key: String = speaker.strip_edges()
	if key.is_empty():
		return ""
	if _by_name.has(key):
		return str(_by_name[key])
	if _aliases.has(key):
		return str(_aliases[key])
	for prefix: Variant in _prefixes.keys():
		if key.begins_with(str(prefix)):
			return str(_prefixes[prefix])
	return ""


## The NPC who speaks the story lines under `key` ("dungeon.hg_boss.before" -> "NPC-CLENCH"); the `.before` / `.after` suffix may be dropped in the table. "" when the beat is narration.
static func story_speaker(key: String) -> String:
	_load()
	if _story_keys.has(key):
		return str(_story_keys[key])
	var dot: int = key.rfind(".")
	if dot > 0 and _story_keys.has(key.substr(0, dot)):
		return str(_story_keys[key.substr(0, dot)])
	return ""



## The NPC ID whose list name (full or short form) is exactly `speaker`; "" for aliases and unknown labels.
static func resolve_name(speaker: String) -> String:
	_load()
	return str(_by_name.get(speaker.strip_edges(), ""))
