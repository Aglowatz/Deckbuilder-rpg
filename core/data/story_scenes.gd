class_name StoryScenes
extends RefCounted
## Short multi-speaker story scenes (Oct 21 story-content brief): the lieutenants' intros and defeats, Elowen's Cave Mouth scenes, her
## capture at the castle gate, the Lab, Isla's homecoming, the royal funeral and Old Hob. All text lives in `data/story/story_scenes.json`:
##
##   "scenes": { "<id>": { "once_flag": "<flag>", "sets": ["<flag>", ...], "steps": [ ["<NPC id or \"\">", "line", "line"], ... ] } }
##
## A step's first entry is the speaker: an NPC id from `NpcRegistry` (its portrait and name plate), `NPC-PLAYER` for the Wanderer, or "" for
## narration. `once_flag` (optional): the scene is skipped once that flag is set, and the flag is set when it has played. `sets` (optional):
## more flags set when it has played. Lines use the story tokens (`{rescuer}`, `{wanderer}`...), filled by the dialogue box. The scene player
## is `StoryScenePlayer` (ui/screens).

const PATH: String = "res://data/story/story_scenes.json"
## The Rescuer's NPC id: her name plate reads `{rescuer}` (the token), never her list name, until she has been named.
const RESCUER_ID: String = "NPC-ELOWEN"
## A step whose speaker is this sets the flags listed in its lines at that point of the scene (the name reveal mid-scene).
const SET_FLAGS: String = "@set"

static var _scenes: Dictionary = {}
static var _loaded: bool = false


static func _load() -> void:
	if _loaded:
		return
	_loaded = true
	_scenes = {}
	if not FileAccess.file_exists(PATH):
		push_warning("StoryScenes: %s not found" % PATH)
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if parsed is Dictionary and (parsed as Dictionary).get("scenes") is Dictionary:
		_scenes = (parsed as Dictionary)["scenes"] as Dictionary


static func has(id: String) -> bool:
	_load()
	return _scenes.has(id)


static func ids() -> Array[String]:
	_load()
	var result: Array[String] = []
	for id: Variant in _scenes.keys():
		result.append(str(id))
	return result


static func _scene(id: String) -> Dictionary:
	_load()
	var scene: Variant = _scenes.get(id, {})
	return scene as Dictionary if scene is Dictionary else {}


## The scene's steps: each {"speaker_id": String, "lines": Array[String]}.
static func steps(id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for raw: Variant in (_scene(id).get("steps", []) as Array):
		if not raw is Array or (raw as Array).size() < 2:
			continue
		var step: Array = raw as Array
		var lines: Array[String] = []
		for line: Variant in step.slice(1):
			lines.append(str(line))
		result.append({"speaker_id": str(step[0]), "lines": lines})
	return result


## Every line of the scene (for the text tests).
static func all_lines(id: String) -> Array[String]:
	var result: Array[String] = []
	for step: Dictionary in steps(id):
		if str(step["speaker_id"]) == SET_FLAGS:
			continue
		result.append_array(step["lines"] as Array[String])
	return result


static func once_flag(id: String) -> String:
	return str(_scene(id).get("once_flag", ""))


## Flags set when the scene has played: its `sets` list plus its `once_flag`.
static func flags_set(id: String) -> Array[String]:
	var result: Array[String] = []
	for flag: Variant in (_scene(id).get("sets", []) as Array):
		result.append(str(flag))
	var once: String = once_flag(id)
	if not once.is_empty() and not result.has(once):
		result.append(once)
	return result


## True when the scene exists and its `once_flag` (if any) is not set yet.
static func should_play(id: String, flags: Dictionary) -> bool:
	if not has(id):
		return false
	var once: String = once_flag(id)
	return once.is_empty() or not bool(flags.get(once, false))
