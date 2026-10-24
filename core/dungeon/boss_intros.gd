class_name BossIntros
extends RefCounted
## Overnight Oct 23, Part 3: who gets a short entrance before their battle (bosses, lieutenants, gatekeepers) and what it says - the
## name card's title, the opening line, the music sting and the accent colour - as data in `data/encounters/boss_intros.json`, keyed by
## the battle's enemy name. Pure data; `BossIntro` (ui/battle) draws it.

const PATH: String = "res://data/encounters/boss_intros.json"
const PATH_COLORS: Dictionary = {
	"beefcake": Color("e8743b"), "necrocrat": Color("9b7fe0"), "gourmand": Color("e9c46a"), "refusemancer": Color("6fbf73"),
	"regime": Color("d8d8e8"), "neutral": Color("ffcf70"),
}

static var _data: Dictionary = {}
static var _loaded: bool = false


static func _load() -> void:
	if _loaded:
		return
	_loaded = true
	_data = {}
	if not FileAccess.file_exists(PATH):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if parsed is Dictionary:
		for key: Variant in (parsed as Dictionary).keys():
			if not str(key).begins_with("_"):
				_data[str(key)] = (parsed as Dictionary)[key]


static func keys() -> Array[String]:
	_load()
	var result: Array[String] = []
	for key: Variant in _data.keys():
		result.append(str(key))
	return result


## The entrance for `enemy_name` as {name, title, line, sting, color}, or {} when this foe has none. "Name, Title" and "Name - Phase"
## battle names also match on the part before the separator (the title is then the part after, unless the data gives one).
static func find(enemy_name: String) -> Dictionary:
	_load()
	var key: String = enemy_name
	var shown_name: String = enemy_name
	var suffix: String = ""
	if not _data.has(key):
		for separator: String in [" - ", ", "]:
			if enemy_name.contains(separator):
				var head: String = enemy_name.get_slice(separator, 0)
				if _data.has(head):
					key = head
					suffix = enemy_name.substr(head.length() + separator.length())
					break
		if not _data.has(key):
			return {}
	var entry: Dictionary = _data[key] as Dictionary
	if enemy_name.contains(", ") and suffix.is_empty():
		shown_name = enemy_name.get_slice(", ", 0)
	elif not suffix.is_empty():
		shown_name = key
	var title: String = str(entry.get("title", ""))
	if not suffix.is_empty() and enemy_name.contains(" - "):
		title = "%s - %s" % [title, suffix] if not title.is_empty() else suffix
	elif title.is_empty() and enemy_name.contains(", "):
		title = enemy_name.get_slice(", ", 1)
	return {
		"name": shown_name,
		"title": title,
		"line": str(entry.get("line", "")),
		"sting": str(entry.get("sting", "")),
		"color": PATH_COLORS.get(str(entry.get("path", "neutral")), PATH_COLORS["neutral"]),
	}
