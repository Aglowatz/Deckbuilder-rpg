class_name DraftChallenges
extends RefCounted
## Draft mode: what can be drafted, and what a finished run pays.
##   - A **zone draft** at Trey Pickett's cart in each of the four Path zones (that zone's Path plus Pathless). Since the owner's
##     decisions of Nov 23 his cart offers ONLY that zone's draft.
##   - Everything else is the Shuffle House's (`DraftArena`): the Open Draft, the two-, three- and four-Path challenges, the harder
##     win-three tables, the Shuffled Halls, Mystery Mini and the dungeon drafts.
## Every draft is free (Nov 23). Flags: `draft_won:<id>` once a challenge was won (three wins, or its dungeon cleared); counters:
## `draft_attempts:<id>`.

const ZONES: Array[String] = ["beefcake", "gourmand", "necrocrat", "refusemancer"]
const ZONE_NAMES: Dictionary = {"beefcake": "the Gainlands", "gourmand": "the Endless Buffet", "necrocrat": "the D.N.A.", "refusemancer": "the Verdant Dump"}
const OPEN_ID: String = "open"
## Set once the Shuffle House (the Crosspath draft arena) is open: all four zone drafts won, or three zones freed (`DraftArena.is_open`).
const ARENA_FLAG: String = "draft_arena_open"


static func zone_id_for(zone_id: String) -> String:
	return "zone:%s" % zone_id


## The zone of a zone draft ("" for every other draft).
static func zone_of(challenge_id: String) -> String:
	return challenge_id.substr(5) if challenge_id.begins_with("zone:") else ""


static func is_zone(challenge_id: String) -> bool:
	return ZONES.has(zone_of(challenge_id))


## True for an id the game knows.
static func exists(challenge_id: String) -> bool:
	if is_zone(challenge_id):
		return true
	match DraftArena.kind_of(challenge_id):
		DraftArena.KIND_OPEN, DraftArena.KIND_QUAD, DraftArena.KIND_HALLS, DraftArena.KIND_MYSTERY:
			return true
		DraftArena.KIND_DAILY:
			return DraftArena.daily_number(challenge_id) > 20000000
		DraftArena.KIND_PAIR:
			return DraftArena.pair_ids().has(challenge_id)
		DraftArena.KIND_TRIO:
			return DraftArena.trio_ids().has(challenge_id)
		DraftArena.KIND_HIGH:
			return DraftArena.high_ids().has(challenge_id)
		DraftArena.KIND_DUNGEON:
			return MainDungeons.has_def(DraftArena.dungeon_key_of(challenge_id))
	return false


static func title(challenge_id: String) -> String:
	if is_zone(challenge_id):
		return "The %s Draft" % Affinity.display_name(ZoneEffects.path_of(zone_of(challenge_id)))
	return DraftArena.title(challenge_id)


static func summary(challenge_id: String) -> String:
	if is_zone(challenge_id):
		var path: String = Affinity.display_name(ZoneEffects.path_of(zone_of(challenge_id)))
		return "Draft a deck from every %s card there is, plus the Pathless ones, then win three fights against three rivals who drafted the same way." % path
	return DraftArena.summary(challenge_id)


## The Paths a set challenge fixes (empty: the player chooses).
static func fixed_paths(challenge_id: String) -> Array[int]:
	var result: Array[int] = []
	if is_zone(challenge_id):
		result.append(int(ZoneEffects.path_of(zone_of(challenge_id))))
		return result
	return DraftArena.fixed_paths(challenge_id)


static func won_flag(challenge_id: String) -> String:
	return "draft_won:%s" % challenge_id


static func attempts_counter(challenge_id: String) -> String:
	return "draft_attempts:%s" % challenge_id


static func zone_drafts_won(flags: Dictionary) -> int:
	var count: int = 0
	for zone_id: String in ZONES:
		if bool(flags.get(won_flag(zone_id_for(zone_id)), false)):
			count += 1
	return count


static func all_zone_drafts_won(flags: Dictionary) -> bool:
	return zone_drafts_won(flags) >= ZONES.size()


## How many Paths a draft with a free choice may have now (the owner's rule of Nov 23: one before any zone is freed, two once a
## zone is freed, three and four after Primm).
static func max_open_paths(flags: Dictionary) -> int:
	return DraftArena.max_paths(flags)


## Three wins finish a table run; the losses that end it depend on the table (two; one at the harder win-three tables).
static func wins_to_finish(_challenge_id: String) -> int:
	return DraftRules.wins_to_finish()


static func losses_to_finish(challenge_id: String) -> int:
	if DraftArena.kind_of(challenge_id) == DraftArena.KIND_HIGH:
		return maxi(1, int(DraftRules.section("high").get("losses_to_finish", 1)))
	return DraftRules.losses_to_finish()


## The entry fee of the next attempt: nothing (every draft is free since Nov 23; the rules file can bring a fee back).
static func fee(challenge_id: String, counters: Dictionary) -> int:
	if DraftRules.entry_fee() <= 0:
		return 0
	if DraftRules.first_attempt_free() and int(counters.get(attempts_counter(challenge_id), 0)) <= 0:
		return 0
	return DraftRules.entry_fee()


## Why a draft can't start with these Paths ("" when it can): an unknown id, a locked challenge, too few or too many Paths.
static func start_problem(challenge_id: String, paths: Array[int], flags: Dictionary) -> String:
	if not exists(challenge_id):
		return "There is no such draft."
	var locked: String = DraftArena.locked_reason(challenge_id, flags)
	if not locked.is_empty():
		return locked
	if not fixed_paths(challenge_id).is_empty() or DraftArena.kind_of(challenge_id) == DraftArena.KIND_DAILY:
		return ""  # the Paths are the challenge's own (the Draft of the Day takes them from the date)
	var bounds: Array[int] = DraftArena.choice_range(challenge_id)
	var most: int = mini(bounds[1], max_open_paths(flags))
	if paths.size() < bounds[0] or paths.is_empty():
		return "Choose %s first." % ("a Path" if bounds[0] <= 1 else "%d Paths" % bounds[0])
	if paths.size() > most:
		return "This draft takes %s for now." % ("one Path" if most == 1 else "up to %d Paths" % most)
	for path: int in paths:
		if not DraftArena.PATHS.has(path):
			return "That is not a Path."
	return ""


## The pack word of the rules file ("path", "gilded", "prismatic", or a pack id) as a real pack id for a draft of `paths`.
## Prismatic packs are draft rewards only after Primm: before that the word means a Gilded Pack.
static func pack_id(word: String, paths: Array[int], after_primm: bool, pick: int = 0) -> String:
	if word.is_empty():
		return ""
	var path: Affinity.Type = (paths[absi(pick) % paths.size()] as Affinity.Type) if not paths.is_empty() else Affinity.Type.NEUTRAL
	match word:
		"path":
			return PackRules.path_pack_id(path) if path != Affinity.Type.NEUTRAL else "general_1"
		"gilded":
			return PackRules.gilded_pack_id(path) if path != Affinity.Type.NEUTRAL else "gilded_general"
		"prismatic":
			if after_primm:
				return PackRules.PRISMATIC_ID
			return PackRules.gilded_pack_id(path) if path != Affinity.Type.NEUTRAL else "gilded_general"
	return word


## What a finished TABLE run pays: gold and XP by its wins; a full win adds a pack and the card to keep; the first full win of a
## challenge adds the first-win bonus and (for most arena tables) a second pack.
## {"gold", "xp", "first_win": bool, "keep_card": bool, "packs": [pack ids]}.
static func reward(wins: int, full_win: bool, first_win: bool, challenge_id: String = "", paths: Array[int] = [], after_primm: bool = false, pick: int = 0) -> Dictionary:
	var base: Dictionary = DraftRules.replay_reward(wins)
	var packs: Array[String] = []
	var result: Dictionary = {"gold": int(base["gold"]), "xp": int(base["xp"]), "first_win": full_win and first_win, "keep_card": full_win, "packs": packs}
	if not full_win:
		return result
	var kind: String = DraftArena.kind_of(challenge_id)
	var table: Dictionary = DraftRules.rewards()
	var word: String = str((table.get("full_win_pack", {}) as Dictionary).get(kind, ""))
	if after_primm and (table.get("after_primm_full_win_pack", {}) as Dictionary).has(kind):
		word = str((table.get("after_primm_full_win_pack", {}) as Dictionary)[kind])
	var pack: String = pack_id(word, paths, after_primm, pick)
	if not pack.is_empty():
		packs.append(pack)
	if first_win:
		var bonus: Dictionary = DraftRules.first_win_bonus()
		result["gold"] = int(result["gold"]) + int(bonus["gold"])
		result["xp"] = int(result["xp"]) + int(bonus["xp"])
		var first_pack: String = pack_id(str((table.get("first_win_pack", {}) as Dictionary).get(kind, "")), paths, after_primm, pick + 1)
		if not first_pack.is_empty():
			packs.append(first_pack)
	return result
