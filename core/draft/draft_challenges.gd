class_name DraftChallenges
extends RefCounted
## Draft mode, Phase 1: what can be drafted. A **zone draft** in each of the four Path zones (that zone's Path plus Pathless,
## three rivals from that zone) and the **open draft** (repeatable: the player chooses the Paths). Set challenges fix the Paths.
## Flags: `draft_won:<id>` once a challenge was won 3-0 or 3-1; counters: `draft_attempts:<id>` (the first attempt is free).

const ZONES: Array[String] = ["beefcake", "gourmand", "necrocrat", "refusemancer"]
const ZONE_NAMES: Dictionary = {"beefcake": "the Gainlands", "gourmand": "the Endless Buffet", "necrocrat": "the D.N.A.", "refusemancer": "the Verdant Dump"}
const OPEN_ID: String = "open"
## Set once all four zone drafts are won: the Crosspath draft arena is open (Phase 2 builds it; Phase 1 only unlocks and teases).
const ARENA_FLAG: String = "draft_arena_open"


static func zone_id_for(zone_id: String) -> String:
	return "zone:%s" % zone_id


## The zone of a zone draft ("" for the open draft).
static func zone_of(challenge_id: String) -> String:
	return challenge_id.substr(5) if challenge_id.begins_with("zone:") else ""


static func is_zone(challenge_id: String) -> bool:
	return ZONES.has(zone_of(challenge_id))


static func title(challenge_id: String) -> String:
	if is_zone(challenge_id):
		return "The %s Draft" % Affinity.display_name(ZoneEffects.path_of(zone_of(challenge_id)))
	return "The Open Draft"


static func summary(challenge_id: String) -> String:
	if is_zone(challenge_id):
		var path: String = Affinity.display_name(ZoneEffects.path_of(zone_of(challenge_id)))
		return "Draft a deck from every %s card there is, plus the Pathless ones, then win three fights against three drafters of %s." % [path, str(ZONE_NAMES[zone_of(challenge_id)])]
	return "Choose your Paths, draft a deck, and play three travelling drafters. Repeatable."


## The Paths a set challenge fixes (empty: the player chooses).
static func fixed_paths(challenge_id: String) -> Array[int]:
	var result: Array[int] = []
	if is_zone(challenge_id):
		result.append(int(ZoneEffects.path_of(zone_of(challenge_id))))
	return result


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


## The open draft opens once any zone draft is won (the first draft teaches the mode).
static func open_unlocked(flags: Dictionary) -> bool:
	return zone_drafts_won(flags) >= 1


## How many Paths the open draft lets the player choose: one until the Crosspath draft arena is open (all four zone drafts won:
## two-Path decks and cards belong to it), then up to four.
static func max_open_paths(flags: Dictionary) -> int:
	return 4 if bool(flags.get(ARENA_FLAG, false)) else 1


## The entry fee of the next attempt: nothing the first time a challenge is tried, the rules' fee after that.
static func fee(challenge_id: String, counters: Dictionary) -> int:
	if DraftRules.first_attempt_free() and int(counters.get(attempts_counter(challenge_id), 0)) <= 0:
		return 0
	return DraftRules.entry_fee()


## What a finished run pays: gold and XP by its wins, and on the first full win of a challenge the first-win bonus on top.
## {"gold", "xp", "first_win": bool, "keep_card": bool}.
static func reward(wins: int, full_win: bool, first_win: bool) -> Dictionary:
	var base: Dictionary = DraftRules.replay_reward(wins)
	var result: Dictionary = {"gold": int(base["gold"]), "xp": int(base["xp"]), "first_win": full_win and first_win, "keep_card": full_win}
	if full_win and first_win:
		var bonus: Dictionary = DraftRules.first_win_bonus()
		result["gold"] = int(result["gold"]) + int(bonus["gold"])
		result["xp"] = int(result["xp"]) + int(bonus["xp"])
	return result
