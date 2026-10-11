class_name LoadingTips
extends RefCounted
## The loading screen tips: `data/loading/loading_tips.txt`, one per line as `kind | text` (kinds hint, keyword, lore), optionally limited to one loading screen with a leading
## `@LOAD-DUNGEON`. Blank lines and lines starting with # are ignored. Edit the file freely; nothing here needs to change.

const PATH: String = "res://data/loading/loading_tips.txt"


class Tip extends RefCounted:
	var kind: String = "hint"
	var text: String = ""
	## "" = any loading screen.
	var only_for: String = ""


static var _cache: Array[Tip] = []
static var _loaded: bool = false


static func all() -> Array[Tip]:
	if not _loaded:
		_loaded = true
		_cache = parse(FileAccess.get_file_as_string(PATH) if FileAccess.file_exists(PATH) else "")
	return _cache


static func reset() -> void:
	_loaded = false
	_cache = []


static func parse(text: String) -> Array[Tip]:
	var result: Array[Tip] = []
	for raw: String in text.split("\n"):
		var line: String = raw.strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue
		var tip: Tip = Tip.new()
		if line.begins_with("@"):
			var space: int = line.find(" ")
			if space < 0:
				continue
			tip.only_for = line.substr(1, space - 1)
			line = line.substr(space + 1).strip_edges()
		var bar: int = line.find("|")
		if bar < 0:
			tip.text = line
		else:
			tip.kind = line.substr(0, bar).strip_edges().to_lower()
			tip.text = line.substr(bar + 1).strip_edges()
		if not tip.text.is_empty():
			result.append(tip)
	return result


## The tips that may show on a loading screen (the general ones plus those limited to it).
static func for_screen(loading_id: String) -> Array[Tip]:
	var result: Array[Tip] = []
	for tip: Tip in all():
		if tip.only_for.is_empty() or tip.only_for == loading_id:
			result.append(tip)
	return result


## A random tip for a loading screen, never `avoid` (the last text shown) when there is a choice; null when the file has no tips.
static func pick(loading_id: String, rng: RandomNumberGenerator = null, avoid: String = "") -> Tip:
	var options: Array[Tip] = for_screen(loading_id)
	if options.is_empty():
		return null
	if options.size() > 1 and not avoid.is_empty():
		var filtered: Array[Tip] = []
		for tip: Tip in options:
			if tip.text != avoid:
				filtered.append(tip)
		options = filtered
	var index: int = rng.randi_range(0, options.size() - 1) if rng != null else randi_range(0, options.size() - 1)
	return options[index]
