class_name DraftArena
extends RefCounted
## Fable big pass Nov 23 (Part 4): the Shuffle House, Octavia Eightfold's draft arena in Crosspath. What it offers and when:
##   the Open Draft (1 to 4 Paths of the player's choice), the six two-Path challenges, the four three-Path challenges and the
##   four-Path one, the three harder "win three" drafts (the High Rollers' tables: no loss allowed, rivals with the player's own
##   equipment pool), the Shuffled Halls (the house's own draft dungeon), Mystery Mini (draft, then a random mini dungeon) and the
##   dungeon drafts (every dungeon the player has cleared, played with a drafted deck).
## It opens when all four zone drafts are won OR three zones are freed (the owner's rule, Nov 23). How many Paths a draft may have
## follows the story: one before any zone is freed, two once a zone is freed, three and four after Primm.
## Pure data and rules; `DraftChallenges` asks this class about every id that is not a zone draft.

const P := Affinity.Type
const PATHS: Array[int] = [P.BEEFCAKE, P.GOURMAND, P.REFUSEMANCER, P.NECROCRAT]
const ZONES_TO_OPEN: int = 3
const NPC_ID: String = "NPC-OCTAVIA"
const SPRITE_KEY: String = "OCTAVIA"
const SPEAKER: String = "Octavia Eightfold"
const HOUSE_NAME: String = "the Shuffle House"
const MET_FLAG: String = "draft_arena_met"

const OPEN_ID: String = "open"
const QUAD_ID: String = "quad"
const HALLS_ID: String = "halls"
const MYSTERY_ID: String = "mystery"
const PAIR_PREFIX: String = "pair:"
const TRIO_PREFIX: String = "trio:"
const HIGH_PREFIX: String = "high:"
const DUNGEON_PREFIX: String = "dungeon:"
## The Shuffled Halls' key in the dungeon catalogue (data/dungeons/postgame_dungeons.json).
const HALLS_DUNGEON: String = "D-SHUFFLE"
## The harder "win three" drafts by their number of Paths.
const HIGH_PATHS: Array[int] = [1, 2, 4]
const HIGH_NAMES: Dictionary = {1: "The High Rollers' Table", 2: "The Double-Down Table", 4: "The Full House Table"}

const KIND_ZONE: String = "zone"
const KIND_OPEN: String = "open"
const KIND_PAIR: String = "pair"
const KIND_TRIO: String = "trio"
const KIND_QUAD: String = "quad"
const KIND_HIGH: String = "high"
const KIND_HALLS: String = "halls"
const KIND_MYSTERY: String = "mystery"
const KIND_DUNGEON: String = "dungeon"


## True once the house is open: its flag is set (the draft quest line's finale or the main quest set it), all four zone drafts
## are won, or three zones are freed.
static func is_open(flags: Dictionary) -> bool:
	return bool(flags.get(DraftChallenges.ARENA_FLAG, false)) or DraftChallenges.all_zone_drafts_won(flags) or ZoneCompletion.count(flags) >= ZONES_TO_OPEN


## How many Paths a draft may have now: 1 before any zone is freed, 2 once one is, 4 after Primm.
static func max_paths(flags: Dictionary) -> int:
	if bool(flags.get(String(MultiPathLock.FLAG_UNLOCKED), false)) or bool(flags.get(MultiPathLock.FLAG_UNLOCKED, false)):
		return 4
	return 2 if ZoneCompletion.count(flags) >= 1 else 1


## One line for the menus: what is open now and what opens next.
static func paths_rule_text(flags: Dictionary) -> String:
	match max_paths(flags):
		1:
			return "One-Path drafts for now. Two-Path drafts and two-Path cards open when the first zone is freed; three and four Paths after Primm is defeated."
		2:
			return "One- and two-Path drafts are open. Three- and four-Path drafts and cards open after Primm is defeated."
	return "Every draft is open: one, two, three and four Paths."


static func kind_of(challenge_id: String) -> String:
	if challenge_id.begins_with("zone:"):
		return KIND_ZONE
	if challenge_id == OPEN_ID:
		return KIND_OPEN
	if challenge_id.begins_with(PAIR_PREFIX):
		return KIND_PAIR
	if challenge_id.begins_with(TRIO_PREFIX):
		return KIND_TRIO
	if challenge_id == QUAD_ID:
		return KIND_QUAD
	if challenge_id.begins_with(HIGH_PREFIX):
		return KIND_HIGH
	if challenge_id == HALLS_ID:
		return KIND_HALLS
	if challenge_id == MYSTERY_ID:
		return KIND_MYSTERY
	if challenge_id.begins_with(DUNGEON_PREFIX):
		return KIND_DUNGEON
	return ""


static func _set_id(prefix: String, paths: Array[int]) -> String:
	var parts: PackedStringArray = []
	for path: int in paths:
		parts.append(str(path))
	return prefix + "+".join(parts)


## The six two-Path challenges ("pair:1+2" ... in the Paths' own order).
static func pair_ids() -> Array[String]:
	var ids: Array[String] = []
	for a: int in range(PATHS.size()):
		for b: int in range(a + 1, PATHS.size()):
			ids.append(_set_id(PAIR_PREFIX, [PATHS[a], PATHS[b]] as Array[int]))
	return ids


## The four three-Path challenges (each leaves one Path out).
static func trio_ids() -> Array[String]:
	var ids: Array[String] = []
	for left_out: int in range(PATHS.size() - 1, -1, -1):
		var paths: Array[int] = []
		for i: int in range(PATHS.size()):
			if i != left_out:
				paths.append(PATHS[i])
		ids.append(_set_id(TRIO_PREFIX, paths))
	return ids


static func high_ids() -> Array[String]:
	var ids: Array[String] = []
	for count: int in HIGH_PATHS:
		ids.append("%s%d" % [HIGH_PREFIX, count])
	return ids


static func dungeon_id(dungeon_key: String) -> String:
	return DUNGEON_PREFIX + dungeon_key


## The dungeon a dungeon draft plays ("" for a table draft; the Shuffled Halls for "halls"; decided at the door for Mystery Mini).
static func dungeon_key_of(challenge_id: String) -> String:
	if challenge_id == HALLS_ID:
		return HALLS_DUNGEON
	if challenge_id.begins_with(DUNGEON_PREFIX):
		return challenge_id.substr(DUNGEON_PREFIX.length())
	return ""


## True for a draft that ends in a dungeon (one HP pool, a pick after each fight) instead of three table fights.
static func is_dungeon(challenge_id: String) -> bool:
	var kind: String = kind_of(challenge_id)
	return kind == KIND_HALLS or kind == KIND_MYSTERY or kind == KIND_DUNGEON


## The Paths a set challenge fixes (empty: the player chooses).
static func fixed_paths(challenge_id: String) -> Array[int]:
	var result: Array[int] = []
	match kind_of(challenge_id):
		KIND_PAIR, KIND_TRIO:
			for part: String in challenge_id.get_slice(":", 1).split("+", false):
				result.append(int(part))
		KIND_QUAD:
			result = PATHS.duplicate()
	return result


## How many Paths the player chooses (0 for a challenge with fixed Paths): [least, most], before the unlock rule.
static func choice_range(challenge_id: String) -> Array[int]:
	match kind_of(challenge_id):
		KIND_OPEN, KIND_HALLS, KIND_MYSTERY, KIND_DUNGEON:
			return [1, 4]
		KIND_HIGH:
			var count: int = int(challenge_id.get_slice(":", 1))
			return [count, count]
	return [0, 0]


## The number of Paths a challenge needs at least (for the lock).
static func paths_needed(challenge_id: String) -> int:
	var fixed: Array[int] = fixed_paths(challenge_id)
	if not fixed.is_empty():
		return fixed.size()
	return maxi(1, choice_range(challenge_id)[0])


## Why a challenge can't be started yet ("" when it can). Every arena challenge needs the house open; then the Path rule.
static func locked_reason(challenge_id: String, flags: Dictionary) -> String:
	if kind_of(challenge_id) == KIND_ZONE:
		return ""
	if not is_open(flags):
		return "The Shuffle House isn't open yet."
	var need: int = paths_needed(challenge_id)
	if need > max_paths(flags):
		return "Opens after Primm is defeated." if need >= 3 else "Opens when the first zone is freed."
	return ""


static func path_names(paths: Array[int], joiner: String = " and ") -> String:
	var names: PackedStringArray = []
	for path: int in paths:
		names.append(Affinity.display_name(path as Affinity.Type))
	if names.size() <= 2:
		return joiner.join(names)
	var last: String = names[names.size() - 1]
	names.remove_at(names.size() - 1)
	return "%s%s%s" % [", ".join(names), joiner, last]


static func title(challenge_id: String) -> String:
	match kind_of(challenge_id):
		KIND_OPEN:
			return "The Open Draft"
		KIND_PAIR:
			return "%s x %s" % [Affinity.display_name(fixed_paths(challenge_id)[0] as Affinity.Type), Affinity.display_name(fixed_paths(challenge_id)[1] as Affinity.Type)]
		KIND_TRIO:
			return "Three Paths: %s" % path_names(fixed_paths(challenge_id), ", ")
		KIND_QUAD:
			return "All Four Paths"
		KIND_HIGH:
			return str(HIGH_NAMES.get(int(challenge_id.get_slice(":", 1)), "The High Rollers' Table"))
		KIND_HALLS:
			return "The Shuffled Halls"
		KIND_MYSTERY:
			return "Mystery Mini"
		KIND_DUNGEON:
			var plan: DungeonCatalog.Blueprint = MainDungeons.blueprint(dungeon_key_of(challenge_id))
			return "Draft: %s" % (plan.dungeon_name if plan != null else "a dungeon")
	return "A draft"


static func summary(challenge_id: String) -> String:
	match kind_of(challenge_id):
		KIND_OPEN:
			return "Choose your Paths, draft a deck, and play three rival drafters. Repeatable."
		KIND_PAIR, KIND_TRIO, KIND_QUAD:
			return "Draft from %s and the Pathless cards, then win three fights against rivals who drafted the same Paths." % path_names(fixed_paths(challenge_id))
		KIND_HIGH:
			var count: int = int(challenge_id.get_slice(":", 1))
			return "A harder table: %s, and you must win all three fights (one loss ends the run). The rivals draft from the same equipment as you, the best pieces included." % ("one Path of your choice" if count == 1 else ("two Paths of your choice" if count == 2 else "all four Paths"))
		KIND_HALLS:
			return "The house's own dungeon. Draft a deck, then walk six of its eighteen rooms on one HP pool. After each fight, pick one of three cards. My nephew is in there somewhere, and I am at the end."
		KIND_MYSTERY:
			return "Draft a deck, then the wheel picks a mini dungeon you have cleared before. One HP pool; a pick of three after each fight."
		KIND_DUNGEON:
			var plan: DungeonCatalog.Blueprint = MainDungeons.blueprint(dungeon_key_of(challenge_id))
			return "Draft a deck, then play %s with it on one HP pool. After each fight, pick one of three cards. Its usual clear rewards, an extra pack, and you keep one card." % (plan.dungeon_name if plan != null else "the dungeon")
	return ""
