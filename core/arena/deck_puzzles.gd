class_name DeckPuzzles
extends RefCounted
## Nov 26 night (Part A2): Octavia Eightfold's five deck-building puzzles at the Shuffle House ("the Puzzle Tables"), one in each level
## of the arena quest line. Unlike the Grand Clashatorium's fixed-hand puzzles, the player brings their OWN deck, gear and items; the
## opponent is fixed: its deck is basic Infrastructure only (it never plays a card), and everything it does comes from its house rules and
## timed moments (`data/encounters/modifiers.json` / `encounter_scripts.json`, key "arena:<id>"), in the same order every attempt. The
## player always goes first, so a bout depends on nothing but the player's own deck order.
##
## Each puzzle looks unfair and has a weakness to find (docs/design/arena_deck_puzzles.md). Unlimited retries, no entry fee. The first win
## pays its prize (a replay pays nothing: a deterministic bout is not a farm) and is a step of its arena quest; a puzzle opens once the one
## before it is won (the last one also waits for Primm), so a player past a level can always go back and play it.
## Data: `data/arena/deck_puzzles.json` (written by tools/nov26n_deck_puzzles.py). Battles reuse the arena's pipeline (`ArenaScenario`,
## `Session.make_arena_battle`): `ArenaDefs.find` falls back to these encounters, and `ArenaEncounter.deck_puzzle` marks them.

const FILE: String = "res://data/arena/deck_puzzles.json"
const PREFIX: String = "deckpuzzle_"
const SPEAKER: String = "Octavia Eightfold"

static var _data: Dictionary = {}
static var _encounters: Array[ArenaEncounter] = []


static func data() -> Dictionary:
	if _data.is_empty():
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(FILE))
		if parsed is Dictionary:
			_data = (parsed as Dictionary).get("puzzles", {}) as Dictionary
	return _data


static func row(id: String) -> Dictionary:
	return data().get(id, {}) as Dictionary


static func is_puzzle_id(id: String) -> bool:
	return id.begins_with(PREFIX) and data().has(id)


## The five puzzles in their order (easiest first).
static func ids() -> Array[String]:
	var result: Array[String] = []
	for key: Variant in data().keys():
		result.append(str(key))
	result.sort_custom(func(a: String, b: String) -> bool: return int(row(a).get("order", 0)) < int(row(b).get("order", 0)))
	return result


static func all() -> Array[ArenaEncounter]:
	if _encounters.is_empty():
		for id: String in ids():
			_encounters.append(_build(id))
	return _encounters


static func find(id: String) -> ArenaEncounter:
	for encounter: ArenaEncounter in all():
		if encounter.id == id:
			return encounter
	return null


static func _build(id: String) -> ArenaEncounter:
	var spec: Dictionary = row(id)
	var encounter: ArenaEncounter = ArenaEncounter.new()
	encounter.id = id
	encounter.tier = 0
	encounter.kind = ArenaEncounter.Kind.BATTLE
	encounter.deck_puzzle = true
	encounter.first_player = 0
	encounter.enemy_name = str(spec.get("enemy_name", "The House"))
	encounter.enemy_hp = int(spec.get("enemy_hp", 20))
	encounter.enemy_ai = str(spec.get("ai", "Aggressive"))
	# the opponent's deck: basic Infrastructure only, so its draws never matter (it plays no card; its rules do everything)
	encounter.enemy_recipe = {"BAS-%s" % str(spec.get("basics", "B")): 60}
	encounter.title_text = str(spec.get("title", ""))
	encounter.brief = str(spec.get("pitch", ""))
	encounter.rules_text = "A deck-building puzzle: bring your own deck. %s plays the same way every time." % encounter.enemy_name
	encounter.lesson = str(spec.get("lesson", ""))
	encounter.reward = (spec.get("reward", {}) as Dictionary).duplicate()
	encounter.replay_gold = 0
	return encounter


static func order_of(id: String) -> int:
	return int(row(id).get("order", 0))


static func hint(id: String) -> String:
	return str(row(id).get("hint", ""))


static func quest_of(id: String) -> String:
	return str(row(id).get("quest", ""))


static func level_of(id: String) -> int:
	return int(row(id).get("level", 1))


static func won_flag(id: String) -> StringName:
	return StringName("deck_puzzle_won_%s" % id)


static func is_won(id: String, flags: Dictionary) -> bool:
	return bool(flags.get(str(won_flag(id)), false))


## The puzzle before this one ("" for the first).
static func previous(id: String) -> String:
	var list: Array[String] = ids()
	var at: int = list.find(id)
	return list[at - 1] if at > 0 else ""


## Open: the Shuffle House is open, the puzzle before it is won, and (the last one) Primm has fallen.
static func is_open(id: String, flags: Dictionary) -> bool:
	return locked_reason(id, flags).is_empty()


## Why a puzzle cannot be played yet ("" when it can).
static func locked_reason(id: String, flags: Dictionary) -> String:
	if not is_puzzle_id(id):
		return "There is no such table."
	if not DraftArena.is_open(flags):
		return "The Shuffle House isn't open yet."
	var before: String = previous(id)
	if not before.is_empty() and not is_won(before, flags):
		return "Win \"%s\" first." % str(row(before).get("title", before))
	if bool(row(id).get("after_primm", false)) and not bool(flags.get(str(MultiPathLock.FLAG_UNLOCKED), false)):
		return "This table opens once Primm is defeated."
	return ""


## How many puzzles the save has won.
static func won_count(flags: Dictionary) -> int:
	var count: int = 0
	for id: String in ids():
		if is_won(id, flags):
			count += 1
	return count


## The quest step for a puzzle ("Win Octavia's puzzle table: The Tea Garden Grows").
static func step_words(id: String) -> String:
	return "Win Octavia's puzzle table \"%s\"" % str(row(id).get("title", id))


## The puzzle whose step belongs to `quest_id` ("" when none).
static func for_quest(quest_id: String) -> String:
	for id: String in ids():
		if quest_of(id) == quest_id:
			return id
	return ""


## The "Before the fight" panel's rows: the bout itself (its name and that it is a puzzle), then its rules and timed moments.
static func rule_badges(encounter: ArenaEncounter) -> Array[RuleBadges.Badge]:
	var result: Array[RuleBadges.Badge] = []
	var bout: RuleBadges.Badge = RuleBadges.special(encounter.title(), encounter.rules(), "faithtoken/card-pick", [] as Array[Modifier], true)
	bout.kind = "arena"
	result.append(bout)
	result.append_array(RuleBadges.for_encounter(EncounterModifiers.rules(ArenaScenario.rules_key(encounter))))
	return result


## The line under the result's title: a first win, a replay, or a loss (try again: same table, same order, no fee).
static func result_line(id: String, won: bool, already_won: bool) -> String:
	if won and not already_won:
		return "The table is yours! Octavia pays the prize, and the next table opens."
	if won:
		return "Solved again. The house pays each table's prize once."
	return "Same table, same rules, same order every time. Rethink the deck and sit down again: there's no fee."
