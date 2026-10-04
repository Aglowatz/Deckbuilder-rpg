class_name ZoneStoryText
extends Resource
## Every line of dialogue, signage, memo, poster and quiz text in the D.N.A. zone (Department of
## Necrotic Affairs - the Necrocrats' office, run by Afterlife Services and Labor), kept in one
## place so it can be rewritten without touching code. Loaded from data/story/dna_story.tres
## (like every zone, the text itself lives in the .tres data file, not in this script).
##
## Keys: "npc.<id>.<situation>", "quest.<quest id>.<offer|active|ready|done>", "sign.<id>",
## "memo.<id>", "poster.<id>", "fx.<id>" (interactable results), "puzzle.*", "quiz.*", "match.*".
## Each value is an Array of lines (one dialogue box each, or one line of a sign).
## The quiz questions live in `quiz_questions`; every answer is findable on a sign/memo/NPC line
## here (see the "Quiz source" notes) - if you rewrite a source line, rewrite the question too.

const PATH: String = "res://data/story/dna_story.tres"


@export var lines: Dictionary = {}

## Four multiple-choice questions. Each: "q", "a" (4 answers), "correct" (index into "a"), "where"
## (design note: which sign/memo/NPC line gives it away - not shown to the player).
@export var quiz_questions: Array[Dictionary] = []

## LARGE first-pass reward tiers by correct answers (0-4; only 3 and 4 can be a first pass): gold, XP, and an item id ("" = none). Placeholder numbers.
## Small flat reward for every finished attempt after the first pass.
@export var quiz_repeat_reward: Dictionary = {"gold": 10, "xp": 5}

@export var quiz_rewards: Array[Dictionary] = [
	{"gold": 0, "xp": 0, "item": ""},
	{"gold": 10, "xp": 0, "item": ""},
	{"gold": 25, "xp": 10, "item": ""},
	{"gold": 50, "xp": 25, "item": ""},
	{"gold": 100, "xp": 60, "item": "healing_draught"},
]


## Zones the player has freed (their dungeon boss is down), kept in sync by the Session. A freed zone's
## story prefers the `<key>.freed` variant of a text when one exists (new dialogue, signs with the
## regime's rules taken down...), see docs/design/story_bible.md.
static var freed_zones: Dictionary = {}

## Which zone this story belongs to (set from the story file, so `.freed` lookups know whom to ask).
@export var zone_id: String = ""


static func set_zone_freed(id: String, freed: bool) -> void:
	freed_zones[id] = freed


func is_freed() -> bool:
	return not zone_id.is_empty() and bool(freed_zones.get(zone_id, false))


## The lines for `key`, or a visible placeholder so a missing key is easy to spot in-game. In a freed
## zone the `<key>.freed` variant wins when it exists.
func get_lines(key: String) -> Array[String]:
	var result: Array[String] = []
	var raw: Variant = lines.get(key)
	if is_freed() and lines.has(key + ".freed"):
		raw = lines.get(key + ".freed")
	if raw is Array:
		for entry: Variant in (raw as Array):
			result.append(str(entry))
	if result.is_empty():
		result.append("[missing text: %s]" % key)
	return result


## All lines of `key` joined for a sign/poster label.
func text(key: String) -> String:
	return "\n".join(get_lines(key))


static var _shared: ZoneStoryText
static var _by_zone: Dictionary = {}


## The story file of a zone (`ZoneDef.story_path`), cached; falls back to the D.N.A.'s.
static func for_zone(zone_id: String) -> ZoneStoryText:
	if zone_id == DnaZone.ID:
		return shared()
	if not _by_zone.has(zone_id):
		var loaded: ZoneStoryText = load(ZoneDefs.get_def(zone_id).story_path) as ZoneStoryText
		_by_zone[zone_id] = loaded if loaded != null else ZoneStoryText.new()
	return _by_zone[zone_id] as ZoneStoryText


## The story of the zone the player is in right now (the D.N.A.'s when not in one - tests).
static func current() -> ZoneStoryText:
	return for_zone(ZoneDefs.current().id)


## The shared instance loaded from the .tres (falls back to the script defaults).
static func shared() -> ZoneStoryText:
	if _shared == null:
		_shared = load(PATH) as ZoneStoryText
		if _shared == null:
			_shared = ZoneStoryText.new()
	return _shared
