class_name StoryText
extends Resource
## All narrative/placeholder dialogue text that isn't tied to a specific zone, kept in one data file
## (`data/story/intro_story.tres`) so it is easy to find and rewrite - the script holds no text. The
## story itself is summarized in docs/design/story_bible.md.
##
## - `awakening_lines`: the hero waking up in the cave (the starting area).
## - the corrupted-NPC arrays: one set per Path (see core/dungeon/corrupted_npcs.gd).
## - `texts`: everything else, by key: "start.*" (the starting area), "town.*" (the town's NPCs, the
##   Arena and the Alchemist), "zone.complete.<zone id>" (the completion announcement) and
##   "boon.*"/"arena.*" text that the dungeon/arena code looks up. Each value is an Array of lines.

const PATH: String = "res://data/story/intro_story.tres"

## The hero wakes up alone and talks to themselves, before noticing the way out.
@export var awakening_lines: Array[String] = []

## The 4 corrupted NPCs at the town's Path gates: before the fight, after a win, after a loss.
@export var beefcake_npc_intro_lines: Array[String] = []
@export var beefcake_npc_victory_lines: Array[String] = []
@export var beefcake_npc_defeat_lines: Array[String] = []
@export var gourmand_npc_intro_lines: Array[String] = []
@export var gourmand_npc_victory_lines: Array[String] = []
@export var gourmand_npc_defeat_lines: Array[String] = []
@export var refusemancer_npc_intro_lines: Array[String] = []
@export var refusemancer_npc_victory_lines: Array[String] = []
@export var refusemancer_npc_defeat_lines: Array[String] = []
@export var necrocrat_npc_intro_lines: Array[String] = []
@export var necrocrat_npc_victory_lines: Array[String] = []
@export var necrocrat_npc_defeat_lines: Array[String] = []

## Bertram Beetsworth, "Assistant to the Regional Merchant" - the equipment vendor.
@export var equipment_vendor_intro_lines: Array[String] = []
@export var equipment_vendor_return_lines: Array[String] = []

## The Restless Cairn (the Graveyard's scripted battle): before, after a win, after a loss.
@export var graveyard_intro_lines: Array[String] = []
@export var graveyard_victory_lines: Array[String] = []
@export var graveyard_defeat_lines: Array[String] = []

## What quest givers say. Keys are "<quest id>.offer" / ".active" / ".ready" / ".done".
@export var quest_dialogue: Dictionary = {}

## Everything else, key -> Array of lines (see the header).
@export var texts: Dictionary = {}

static var _shared: StoryText


func quest_lines(key: String) -> Array[String]:
	var result: Array[String] = []
	for line: Variant in (quest_dialogue.get(key, []) as Array):
		result.append(Villain.fill(str(line)))
	return result


## The lines for `key` in `texts`, or a visible placeholder so a missing key is easy to spot.
func get_lines(key: String) -> Array[String]:
	var result: Array[String] = []
	var raw: Variant = texts.get(key)
	if raw is Array:
		for entry: Variant in (raw as Array):
			result.append(Villain.fill(str(entry)))
	if result.is_empty():
		result.append("[missing text: %s]" % key)
	return result


func has_text(key: String) -> bool:
	return texts.has(key)


func text(key: String) -> String:
	return "\n".join(get_lines(key))


func npc_intro_lines(id: String) -> Array[String]:
	match id:
		"beefcake":
			return _filled(beefcake_npc_intro_lines)
		"gourmand":
			return _filled(gourmand_npc_intro_lines)
		"refusemancer":
			return _filled(refusemancer_npc_intro_lines)
		"necrocrat":
			return _filled(necrocrat_npc_intro_lines)
	return []


func npc_victory_lines(id: String) -> Array[String]:
	match id:
		"beefcake":
			return _filled(beefcake_npc_victory_lines)
		"gourmand":
			return _filled(gourmand_npc_victory_lines)
		"refusemancer":
			return _filled(refusemancer_npc_victory_lines)
		"necrocrat":
			return _filled(necrocrat_npc_victory_lines)
	return []


func npc_defeat_lines(id: String) -> Array[String]:
	match id:
		"beefcake":
			return _filled(beefcake_npc_defeat_lines)
		"gourmand":
			return _filled(gourmand_npc_defeat_lines)
		"refusemancer":
			return _filled(refusemancer_npc_defeat_lines)
		"necrocrat":
			return _filled(necrocrat_npc_defeat_lines)
	return []


## The shared story text (loaded from the data file once).
static func shared() -> StoryText:
	if _shared == null:
		_shared = load(PATH) as StoryText
		if _shared == null:
			_shared = StoryText.new()
	return _shared


## Story lines with the `{villain}` tokens filled in.
static func _filled(source: Array[String]) -> Array[String]:
	var result: Array[String] = []
	for line: String in source:
		result.append(Villain.fill(line))
	return result
