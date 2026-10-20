class_name OldWellStory
extends RefCounted
## Overnight Oct 19-20, Part 6: the Old Well secret quest's words, kept in their own data file (`data/story/old_well_story.json`) so the story
## .tres files stay untouched. Two sections:
## - `beats`: key -> an ordered list of {"speaker", "lines"} (a conversation that changes speaker, played box by box: `OldWellSpot.play`).
## - `text`: key -> one string (the quest log's title, steps and hints, the prompts, the confirm dialog).
## Every line goes through `Villain.fill`, so story tokens ({wanderer}, {kingdom}, {town}...) work as in the other story files.

const PATH: String = "res://data/story/old_well_story.json"

class Beat:
	extends RefCounted
	var speaker: String = ""
	var lines: Array[String] = []


var beats: Dictionary = {}
var texts: Dictionary = {}

static var _shared: OldWellStory


static func shared() -> OldWellStory:
	if _shared == null:
		_shared = load_from(PATH)
	return _shared


static func load_from(path: String) -> OldWellStory:
	var story: OldWellStory = OldWellStory.new()
	if not FileAccess.file_exists(path):
		push_warning("OldWellStory: %s is missing" % path)
		return story
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary):
		push_warning("OldWellStory: %s is not a JSON object" % path)
		return story
	var data: Dictionary = parsed as Dictionary
	story.beats = (data.get("beats", {}) as Dictionary).duplicate(true)
	story.texts = (data.get("text", {}) as Dictionary).duplicate(true)
	return story


## The beats of `key`, tokens filled; a visible placeholder beat when the key is missing.
func get_beats(key: String) -> Array[Beat]:
	var result: Array[Beat] = []
	for raw: Variant in beats.get(key, []) as Array:
		if not (raw is Dictionary):
			continue
		var beat: Beat = Beat.new()
		beat.speaker = Villain.fill(str((raw as Dictionary).get("speaker", "")))
		for line: Variant in (raw as Dictionary).get("lines", []) as Array:
			beat.lines.append(Villain.fill(str(line)))
		if not beat.lines.is_empty():
			result.append(beat)
	if result.is_empty():
		var missing: Beat = Beat.new()
		missing.lines.append("[missing text: %s]" % key)
		result.append(missing)
	return result


func has_beats(key: String) -> bool:
	return beats.has(key)


## Every line of `key` in order, whoever speaks it (a single-speaker use, or a test).
func lines_of(key: String) -> Array[String]:
	var result: Array[String] = []
	for beat: Beat in get_beats(key):
		result.append_array(beat.lines)
	return result


func text(key: String) -> String:
	if not texts.has(key):
		return "[missing text: %s]" % key
	return Villain.fill(str(texts[key]))


## Every dialogue line in the file (raw, unfilled), keyed "<beat key>#<n>", for the box-fit and the wording tests.
func all_dialogue_lines() -> Dictionary:
	var result: Dictionary = {}
	for key: Variant in beats.keys():
		var index: int = 0
		for raw: Variant in beats[key] as Array:
			for line: Variant in (raw as Dictionary).get("lines", []) as Array:
				result["%s#%d" % [str(key), index]] = str(line)
				index += 1
	return result
