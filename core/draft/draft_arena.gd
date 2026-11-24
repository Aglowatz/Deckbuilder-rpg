class_name DraftArena
extends RefCounted
## The Shuffle House, Octavia Eightfold's draft arena in Crosspath (Fable big pass Nov 23; the four modes of Fable Nov 24).
## Since Nov 24 its menu is FOUR MODES and one door (the owner's list, docs/design/draft_mode.md):
##   1. Classic Draft      choose your Paths (within the unlock rule), draft, play three random opponents. No Prismatic Packs.
##                         The Draft of the Day sits under it (one table a day, the same for everybody).
##   2. Dungeon Draft      draft, then play a LARGE dungeon you have cleared in the main game (every zone's main dungeon, Primm's
##                         Castle, the Path-ology Lab, Mount Swolympus, the Shattered Gallery; the Shuffled Halls after their first
##                         clear), or a random one of them. Pays Prismatic Packs.
##   3. Mystery Mini       draft, then a random mini dungeon (three encounters). Pays a pack of that dungeon's Path.
##   4. High Rollers Draft an entry fee; a Classic Draft whose opponents may wear every piece of equipment you may. Pays more
##                         than Classic, Prismatic Packs included.
##   and the Shuffled Halls, the house's own dungeon, behind its own door under the four.
## The separate two-Path tables, Three Paths, Four Paths and the three "win three" tables of Nov 23 are gone: their purpose is the
## Path choice of Classic and High Rollers. Winning one of those two with a set of two, three or four Paths still sets that set's
## flag (`paths_goal_flag`: the old tables' "won" flags), so the quests and feats that count Path sets carry on, old saves included.
## It opens when all four zone drafts are won OR three zones are freed. How many Paths a draft may have follows the story: one
## before any zone is freed, two once a zone is freed, three and four after Primm. Prismatic Packs are paid only after Primm
## (`DraftChallenges.pack_id`: before that the word means a Gilded Pack).
## Pure data and rules; `DraftChallenges` asks this class about every id that is not a zone draft.

const P := Affinity.Type
const PATHS: Array[int] = [P.BEEFCAKE, P.GOURMAND, P.REFUSEMANCER, P.NECROCRAT]
const ZONES_TO_OPEN: int = 3
const NPC_ID: String = "NPC-OCTAVIA"
const SPRITE_KEY: String = "OCTAVIA"
const SPEAKER: String = "Octavia Eightfold"
const HOUSE_NAME: String = "the Shuffle House"
const MET_FLAG: String = "draft_arena_met"

## Classic Draft keeps the id of the Open Draft it grew out of (saves, counters and flags carry on).
const OPEN_ID: String = "open"
const CLASSIC_ID: String = OPEN_ID
const HIGH_ID: String = "high"
const HALLS_ID: String = "halls"
const MYSTERY_ID: String = "mystery"
const DUNGEON_PREFIX: String = "dungeon:"
## Retired with the four modes (Nov 24): a saved draft of one of these still finishes, a new one cannot be started.
const QUAD_ID: String = "quad"
const PAIR_PREFIX: String = "pair:"
const TRIO_PREFIX: String = "trio:"
const HIGH_PREFIX: String = "high:"
## The Shuffled Halls' key in the dungeon catalogue (data/dungeons/postgame_dungeons.json).
const HALLS_DUNGEON: String = "D-SHUFFLE"
## The four modes of the menu, in its order.
const MODE_CLASSIC: String = "classic"
const MODE_DUNGEON: String = "dungeon"
const MODE_MYSTERY: String = "mystery"
const MODE_HIGH: String = "high"
const MODES: Array[String] = [MODE_CLASSIC, MODE_DUNGEON, MODE_MYSTERY, MODE_HIGH]

const KIND_ZONE: String = "zone"
const KIND_OPEN: String = "open"
const KIND_PAIR: String = "pair"
const KIND_TRIO: String = "trio"
const KIND_QUAD: String = "quad"
const KIND_HIGH: String = "high"
const KIND_HALLS: String = "halls"
const KIND_MYSTERY: String = "mystery"
const KIND_DUNGEON: String = "dungeon"
## Draft of the Day (docs/design/draft_mode.md): one table whose Paths, offers and rivals are worked out from the date, so every
## player sees the same draft on the same day (no internet). Its id carries the date: "daily:20261123".
const KIND_DAILY: String = "daily"
const DAILY_PREFIX: String = "daily:"
const RETIRED_KINDS: Array[String] = [KIND_PAIR, KIND_TRIO, KIND_QUAD]


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
			return "One Path a draft for now. Two Paths (and two-Path cards) open when the first zone is freed; three and four after Primm is defeated."
		2:
			return "One or two Paths a draft. Three and four Paths (and their cards) open after Primm is defeated."
	return "Any number of Paths: one, two, three or all four."


## What the player is told when they switch on more Paths than the story allows yet.
static func too_many_paths_text(flags: Dictionary) -> String:
	match max_paths(flags):
		1:
			return "One Path at a time for now, darling. Free your first zone and I will deal you two; beat Primm and you may have all four."
		2:
			return "Two Paths is the house limit for now, darling. Three and four open once Primm is defeated."
	return "Four Paths is all there are, darling. Believe me, I have looked."


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
	if challenge_id == HIGH_ID or challenge_id.begins_with(HIGH_PREFIX):
		return KIND_HIGH
	if challenge_id == HALLS_ID:
		return KIND_HALLS
	if challenge_id == MYSTERY_ID:
		return KIND_MYSTERY
	if challenge_id.begins_with(DUNGEON_PREFIX):
		return KIND_DUNGEON
	if challenge_id.begins_with(DAILY_PREFIX):
		return KIND_DAILY
	return ""


## True for a table of Nov 23 that the four modes replaced: a set two-, three- or four-Path table, or a "win three" table by its
## number of Paths ("high:1"). A saved draft of one still finishes; `DraftChallenges.start_problem` refuses a new one.
static func is_retired(challenge_id: String) -> bool:
	return RETIRED_KINDS.has(kind_of(challenge_id)) or challenge_id.begins_with(HIGH_PREFIX)


## The mode of the menu a challenge belongs to ("" for the Shuffled Halls, a zone draft and the retired tables).
static func mode_of(challenge_id: String) -> String:
	match kind_of(challenge_id):
		KIND_OPEN, KIND_DAILY:
			return MODE_CLASSIC
		KIND_DUNGEON:
			return MODE_DUNGEON
		KIND_MYSTERY:
			return MODE_MYSTERY
		KIND_HIGH:
			return MODE_HIGH
	return ""


## The challenge a mode starts (the Dungeon Draft needs its dungeon: `dungeon_id`).
static func mode_challenge(mode: String) -> String:
	match mode:
		MODE_CLASSIC:
			return CLASSIC_ID
		MODE_MYSTERY:
			return MYSTERY_ID
		MODE_HIGH:
			return HIGH_ID
	return ""


static func mode_title(mode: String) -> String:
	match mode:
		MODE_CLASSIC:
			return "Classic Draft"
		MODE_DUNGEON:
			return "Dungeon Draft"
		MODE_MYSTERY:
			return "Mystery Mini"
		MODE_HIGH:
			return "High Rollers Draft"
	return "A draft"


## One short line under a mode's name on its tile.
static func mode_pitch(mode: String) -> String:
	match mode:
		MODE_CLASSIC:
			return "Your Paths. Three random opponents."
		MODE_DUNGEON:
			return "A big dungeon you have cleared, with a drafted deck."
		MODE_MYSTERY:
			return "The wheel picks a mini dungeon."
		MODE_HIGH:
			return "Pay to sit. The opponents wear the best gear."
	return ""


## Today's Draft of the Day ("daily:YYYYMMDD" from the system clock, or from `date` = {"year", "month", "day"}).
static func daily_id(date: Dictionary = {}) -> String:
	var day: Dictionary = date if not date.is_empty() else Time.get_date_dict_from_system()
	return "%s%04d%02d%02d" % [DAILY_PREFIX, int(day.get("year", 2026)), int(day.get("month", 1)), int(day.get("day", 1))]


## The date number of a Draft of the Day (20261123), 0 for anything else.
static func daily_number(challenge_id: String) -> int:
	return int(challenge_id.substr(DAILY_PREFIX.length())) if challenge_id.begins_with(DAILY_PREFIX) else 0


## The seed every player's Draft of the Day uses on that date (the same offers, the same rivals).
static func daily_seed(challenge_id: String) -> int:
	return maxi(1, hash(["draft of the day", daily_number(challenge_id)]) & 0x3fffffff)


## The Paths of that day's draft: one Path before any zone is freed, one or two after, up to `most` after Primm - which ones is
## the date's choice.
static func daily_paths(challenge_id: String, most: int) -> Array[int]:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = daily_seed(challenge_id) + 17
	var count: int = clampi(1 + rng.randi() % maxi(1, mini(most, 2 if most < 4 else 3)), 1, maxi(1, most))
	var pool: Array[int] = PATHS.duplicate()
	var chosen: Array[int] = []
	while chosen.size() < count and not pool.is_empty():
		var at: int = rng.randi() % pool.size()
		chosen.append(pool[at])
		pool.remove_at(at)
	chosen.sort()
	return chosen


static func _set_id(prefix: String, paths: Array[int]) -> String:
	var parts: PackedStringArray = []
	for path: int in paths:
		parts.append(str(path))
	return prefix + "+".join(parts)


## The six pairs of Paths ("pair:1+2" ... in the Paths' own order): goals of the arena's quest line since Nov 24 (win a Classic or
## High Rollers Draft with each), tables of their own before.
static func pair_ids() -> Array[String]:
	var ids: Array[String] = []
	for a: int in range(PATHS.size()):
		for b: int in range(a + 1, PATHS.size()):
			ids.append(_set_id(PAIR_PREFIX, [PATHS[a], PATHS[b]] as Array[int]))
	return ids


## The four sets of three Paths (each leaves one Path out).
static func trio_ids() -> Array[String]:
	var ids: Array[String] = []
	for left_out: int in range(PATHS.size() - 1, -1, -1):
		var paths: Array[int] = []
		for i: int in range(PATHS.size()):
			if i != left_out:
				paths.append(PATHS[i])
		ids.append(_set_id(TRIO_PREFIX, paths))
	return ids


## The "win three" tables of Nov 23 by their number of Paths (retired; their "won" flags still count for the High Roller feat).
static func high_ids() -> Array[String]:
	var ids: Array[String] = []
	for count: int in [1, 2, 4]:
		ids.append("%s%d" % [HIGH_PREFIX, count])
	return ids


## The flag a Classic or High Rollers win with exactly these Paths sets (the old table's "won" flag): a pair, a set of three, all
## four. "" for a single Path (no goal counts those).
static func paths_goal_flag(paths: Array[int]) -> String:
	var sorted: Array[int] = paths.duplicate()
	sorted.sort()
	match sorted.size():
		2:
			return DraftChallenges.won_flag(_set_id(PAIR_PREFIX, sorted))
		3:
			return DraftChallenges.won_flag(_set_id(TRIO_PREFIX, sorted))
		4:
			return DraftChallenges.won_flag(QUAD_ID)
	return ""


## The challenge that plays `dungeon_key` as a draft (the Shuffled Halls are their own challenge, also from the Dungeon Draft's list).
static func dungeon_id(dungeon_key: String) -> String:
	return HALLS_ID if dungeon_key == HALLS_DUNGEON else DUNGEON_PREFIX + dungeon_key


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


## A mini dungeon is any dungeon with exactly three encounters (the owner, Nov 24): Mystery Mini's wheel lands on those.
static func is_mini(plan: DungeonCatalog.Blueprint) -> bool:
	return plan != null and not plan.is_draft_only() and encounters_of(plan) == MINI_ENCOUNTERS
const MINI_ENCOUNTERS: int = 3
const ENCOUNTER_TYPES: Array[String] = ["battle", "elite", "boss"]


static func encounters_of(plan: DungeonCatalog.Blueprint) -> int:
	var count: int = 0
	if plan == null:
		return count
	for node: DungeonCatalog.BlueprintNode in plan.nodes:
		if ENCOUNTER_TYPES.has(node.type):
			count += 1
	return count


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
			if challenge_id.begins_with(HIGH_PREFIX):
				var count: int = int(challenge_id.get_slice(":", 1))
				return [count, count]
			return [1, 4]
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
	if kind_of(challenge_id) == KIND_DAILY:
		return "" if challenge_id == daily_id() else "That day's draft is over."
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
			return "Classic Draft"
		KIND_DAILY:
			return "Draft of the Day"
		KIND_PAIR:
			return "%s x %s" % [Affinity.display_name(fixed_paths(challenge_id)[0] as Affinity.Type), Affinity.display_name(fixed_paths(challenge_id)[1] as Affinity.Type)]
		KIND_TRIO:
			return "Three Paths: %s" % path_names(fixed_paths(challenge_id), ", ")
		KIND_QUAD:
			return "All Four Paths"
		KIND_HIGH:
			return "High Rollers Draft"
		KIND_HALLS:
			return "The Shuffled Halls"
		KIND_MYSTERY:
			return "Mystery Mini"
		KIND_DUNGEON:
			var plan: DungeonCatalog.Blueprint = MainDungeons.blueprint(dungeon_key_of(challenge_id))
			return "Dungeon Draft: %s" % (plan.dungeon_name if plan != null else "a dungeon")
	return "A draft"


static func summary(challenge_id: String) -> String:
	match kind_of(challenge_id):
		KIND_OPEN:
			return "Choose your Paths, draft a deck, then play three random opponents from all over the kingdom. Their Paths and decks are their own: you never know who sits down, or with what."
		KIND_DAILY:
			return "Today's table: the Paths, the offers and the opponents are the same for everybody who sits down today. A new one every day."
		KIND_PAIR, KIND_TRIO, KIND_QUAD:
			return "Draft from %s and the Pathless cards, then win three fights against rivals who drafted the same way." % path_names(fixed_paths(challenge_id))
		KIND_HIGH:
			return "A Classic Draft for higher stakes: an entry fee at the door, and the opponents may wear every piece of equipment you may, the best ones included. It pays more than Classic, Prismatic Packs too."
		KIND_HALLS:
			return "The house's own dungeon. Draft a deck, then walk six of its eighteen rooms on one HP pool. Every table has its own dealer and its own house rule; after each fight, pick one of three cards. My nephew is in there somewhere, and I am at the end."
		KIND_MYSTERY:
			return "Draft a deck, then the wheel picks a mini dungeon: three fights on one HP pool, a pick of three after each. It pays a pack of that dungeon's Path."
		KIND_DUNGEON:
			var plan: DungeonCatalog.Blueprint = MainDungeons.blueprint(dungeon_key_of(challenge_id))
			return "Draft a deck, then play %s with it on one HP pool. After each fight, pick one of three cards. Its usual clear rewards, a Prismatic Pack on top, and you keep one card." % (plan.dungeon_name if plan != null else "the dungeon")
	return ""
