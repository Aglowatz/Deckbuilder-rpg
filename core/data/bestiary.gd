class_name Bestiary
extends RefCounted
## Overnight Oct 17, Part 10: every enemy and boss (data/bestiary/bestiary.json): unknown until met, then its picture, a fun line,
## where it lives and how often it was beaten. Met / defeated counts live in the save's counters ("bestiary_met:<name>",
## "bestiary_won:<name>"), recorded when a battle starts and is won (`Session.start_battle` / `complete_battle`) or when a roamer
## that never fights touches the hero. Completion milestones (25/50/75/100 %) pay small rewards. Pure data: no scene tree.

const PATH: String = "res://data/bestiary/bestiary.json"
const MET_PREFIX: String = "bestiary_met:"
const WON_PREFIX: String = "bestiary_won:"
const FALLBACK_ICON: String = "lorc/magic-swirl"
## Discovery milestones: percent met -> reward ({gold} or {pack: "path"/id}). Paid once each (flag "bestiary_<percent>").
const MILESTONES: Array[Dictionary] = [
	{"percent": 25, "gold": 100},
	{"percent": 50, "pack": "path"},
	{"percent": 75, "gold": 250},
	{"percent": 100, "pack": "gilded"},
]


class Entry:
	extends RefCounted
	var name: String = ""
	var kind: String = "foe"
	var where: String = ""
	var icon: String = FALLBACK_ICON
	var blurb: String = ""

	func is_boss() -> bool:
		return kind == "boss"


static var _entries: Array[Entry] = []


static func all() -> Array[Entry]:
	if _entries.is_empty() and FileAccess.file_exists(PATH):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
		if parsed is Dictionary:
			for row: Variant in (parsed as Dictionary).get("entries", []) as Array:
				var data: Dictionary = row as Dictionary
				var entry: Entry = Entry.new()
				entry.name = str(data.get("name", ""))
				entry.kind = str(data.get("kind", "foe"))
				entry.where = str(data.get("where", ""))
				entry.icon = str(data.get("icon", FALLBACK_ICON))
				entry.blurb = str(data.get("blurb", ""))
				_entries.append(entry)
	return _entries


static func find(enemy_name: String) -> Entry:
	var key: String = canonical(enemy_name)
	for entry: Entry in all():
		if entry.name == key:
			return entry
	return null


## Battle names that differ from the entry: the final boss's node id and its phase names ("Primm - Standardization"), and the
## corrupted wanderers (all four are one entry).
static func canonical(enemy_name: String) -> String:
	if enemy_name == "PRIMM_BOSS" or enemy_name.begins_with("Primm"):
		return "Primm, His Perfection"
	if enemy_name in CorruptedNpcs.DISPLAY_NAMES.values():
		return "Corrupted Wanderers"
	return enemy_name


static func met_count(counters: Dictionary, enemy_name: String) -> int:
	return int(counters.get(MET_PREFIX + canonical(enemy_name), 0))


static func won_count(counters: Dictionary, enemy_name: String) -> int:
	return int(counters.get(WON_PREFIX + canonical(enemy_name), 0))


static func is_known(counters: Dictionary, enemy_name: String) -> bool:
	return met_count(counters, enemy_name) > 0 or won_count(counters, enemy_name) > 0


## How many entries are known: (known, total).
static func progress(counters: Dictionary) -> Vector2i:
	var known: int = 0
	for entry: Entry in all():
		if is_known(counters, entry.name):
			known += 1
	return Vector2i(known, all().size())


static func percent(counters: Dictionary) -> int:
	var p: Vector2i = progress(counters)
	return 0 if p.y == 0 else int(floor(100.0 * float(p.x) / float(p.y)))


## Milestones reached but not yet paid (their flags are not set).
static func due_milestones(counters: Dictionary, flags: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var reached: int = percent(counters)
	for milestone: Dictionary in MILESTONES:
		var flag: String = "bestiary_%d" % int(milestone["percent"])
		if reached >= int(milestone["percent"]) and not bool(flags.get(flag, false)):
			result.append(milestone)
	return result
