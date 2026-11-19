class_name PathPalette
extends RefCounted
## Fable Nov 19 (Part 3): the one official colour of each Path, read from `core/data/path_palette.json` (docs/art/path_colour_guide.md).
## Every place that shows a Path by colour asks here (`UIStyle.affinity_color` is this table too), so a colour changes in ONE place: the
## JSON file. Roles: `main` (bars, borders, glows, markers), `accent` (the second colour), `text` (small text on dark panels), `ink`
## (text and lines on parchment), `frame` (the cloth tint of the tinted card frames). Pure data: no scene tree.

const FILE: String = "res://core/data/path_palette.json"
const KEYS: Dictionary = {
	Affinity.Type.BEEFCAKE: "beefcake",
	Affinity.Type.GOURMAND: "gourmand",
	Affinity.Type.REFUSEMANCER: "refusemancer",
	Affinity.Type.NECROCRAT: "necrocrat",
	Affinity.Type.NEUTRAL: "colorless",
}
const ROLES: Array[String] = ["main", "accent", "text", "ink", "frame"]

static var _table: Dictionary = {}


static func _load() -> void:
	if not _table.is_empty():
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(FILE))
	var paths: Dictionary = (parsed as Dictionary).get("paths", {}) as Dictionary if parsed is Dictionary else {}
	for key: String in paths.keys():
		var row: Dictionary = {}
		for role: String in ROLES:
			row[role] = Color.html(str((paths[key] as Dictionary).get(role, "B8A98A")))
		_table[key] = row
	if not _table.has("colorless"):
		_table["colorless"] = {"main": Color("b8a98a"), "accent": Color("4c4441"), "text": Color("cfc3a8"), "ink": Color("5a5046"), "frame": Color("9a9590")}


## Forgets the loaded file (tests, a palette edited while the game runs).
static func reload() -> void:
	_table = {}
	_load()


## The Path's colour in a role, by its zone / Path id ("beefcake", "gourmand", "refusemancer", "necrocrat"; anything else = colorless).
static func of_id(path_id: String, role: String = "main") -> Color:
	_load()
	var row: Dictionary = _table.get(path_id, _table["colorless"]) as Dictionary
	return row.get(role, row["main"]) as Color


static func of(path: Affinity.Type, role: String = "main") -> Color:
	return of_id(str(KEYS.get(path, "colorless")), role)


static func main(path: Affinity.Type) -> Color:
	return of(path, "main")


static func accent(path: Affinity.Type) -> Color:
	return of(path, "accent")


static func text(path: Affinity.Type) -> Color:
	return of(path, "text")


static func ink(path: Affinity.Type) -> Color:
	return of(path, "ink")


static func frame(path: Affinity.Type) -> Color:
	return of(path, "frame")


## The four mains in the fixed order (Beefcake, Gourmand, Refusemancer, Necrocrat: PathIcons.ORDER).
static func ring() -> Array[Color]:
	var result: Array[Color] = []
	for path: Affinity.Type in PathIcons.ORDER:
		result.append(main(path))
	return result
