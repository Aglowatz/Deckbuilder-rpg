class_name LevelTrack
extends RefCounted
## Overnight Oct 17: the level 1-30 reward track as data (`data/progression/level_track.json`). One place that says what every
## level gives and when the copy and equipment rarity caps rise; `CopyCaps` and the level-up flow read it. The file is
## hand-formatted: edit it as text. Pure data: no scene tree.

const PATH: String = "res://data/progression/level_track.json"

static var _data: Dictionary = {}


static func data() -> Dictionary:
	if _data.is_empty():
		if FileAccess.file_exists(PATH):
			var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
			if parsed is Dictionary:
				_data = parsed as Dictionary
		if _data.is_empty():
			push_error("LevelTrack: could not read %s" % PATH)
			_data = {"max_level": 30}
	return _data


## Forgets the loaded table (tests, and so an edited file is re-read).
static func reload() -> void:
	_data = {}


static func section(key: String) -> Dictionary:
	return data().get(key, {}) as Dictionary


## The track's entry for one level ({level, big, headline, grants}); {} when the level has none.
static func level_entry(level: int) -> Dictionary:
	for entry: Variant in data().get("levels", []) as Array:
		if entry is Dictionary and int((entry as Dictionary).get("level", 0)) == level:
			return _scaled(entry as Dictionary, level)
	return {}


## Overnight Nov 7-8, Part 2.4: the gold grants of a level as paid now (`Economy.level_gold`: level 6 on is scaled down; the intro's are kept).
static func _scaled(entry: Dictionary, level: int) -> Dictionary:
	var grants: Array = entry.get("grants", []) as Array
	var changed: bool = false
	for grant: Variant in grants:
		if grant is Dictionary and str((grant as Dictionary).get("kind", "")) == "gold" and Economy.level_gold(level, int((grant as Dictionary).get("amount", 0))) != int((grant as Dictionary).get("amount", 0)):
			changed = true
	if not changed:
		return entry
	var copy: Dictionary = entry.duplicate(true)
	for grant: Variant in copy.get("grants", []) as Array:
		if grant is Dictionary and str((grant as Dictionary).get("kind", "")) == "gold":
			(grant as Dictionary)["amount"] = Economy.level_gold(level, int((grant as Dictionary).get("amount", 0)))
	return copy


## Rarity names as the track spells them ("common", "uncommon", "epic", "legendary").
static func rarity_key(rarity: CardEnums.Rarity) -> String:
	return str(CardEnums.Rarity.keys()[int(rarity)]).to_lower()


static func rarity_from_key(key: String) -> int:
	var index: int = CardEnums.Rarity.keys().find(key.to_upper())
	return index
