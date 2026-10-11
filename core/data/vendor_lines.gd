class_name VendorLines
extends RefCounted
## The vendor screens' data: `data/vendors/vendor_screens.json` (the VENDOR SCREENS rows of the NPC list: Vendor Screen ID -> portrait, notes; written by the key-art
## importer) and `data/vendors/vendor_lines.json` (hand-edited speech lines per Vendor Screen ID and moment: open, buy, poor, sold_out).

const SCREENS_PATH: String = "res://data/vendors/vendor_screens.json"
const LINES_PATH: String = "res://data/vendors/vendor_lines.json"

static var _screens: Dictionary = {}
static var _lines: Dictionary = {}
static var _loaded: bool = false


static func _load() -> void:
	if _loaded:
		return
	_loaded = true
	_screens = _read(SCREENS_PATH)
	_lines = _read(LINES_PATH)


static func _read(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


static func reset() -> void:
	_loaded = false
	_screens = {}
	_lines = {}


static func screen_ids() -> Array[String]:
	_load()
	var ids: Array[String] = []
	for id: Variant in _screens.keys():
		ids.append(str(id))
	ids.sort()
	return ids


## The Portrait Image ID the vendor screen shows on the left ("" when the sheet has no such screen).
static func portrait_id(screen_id: String) -> String:
	_load()
	return str((_screens.get(screen_id, {}) as Dictionary).get("portrait_id", ""))


## The sheet's UI / Interaction Notes of a vendor screen.
static func notes(screen_id: String) -> String:
	_load()
	return str((_screens.get(screen_id, {}) as Dictionary).get("notes", ""))


static func lines(screen_id: String, moment: String) -> Array[String]:
	_load()
	var result: Array[String] = []
	for line: Variant in ((_lines.get(screen_id, {}) as Dictionary).get(moment, []) as Array):
		result.append(str(line))
	return result


## One random line of the moment ("" when there is none); `rng` makes it repeatable in tests.
static func pick(screen_id: String, moment: String, rng: RandomNumberGenerator = null) -> String:
	var options: Array[String] = lines(screen_id, moment)
	if options.is_empty():
		return ""
	var index: int = rng.randi_range(0, options.size() - 1) if rng != null else randi_range(0, options.size() - 1)
	return options[index]
