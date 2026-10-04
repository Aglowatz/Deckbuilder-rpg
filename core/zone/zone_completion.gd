class_name ZoneCompletion
extends RefCounted
## Zone completion state (Part D): a zone is "completed" (freed from its oppressive ruler) when its
## main dungeon's boss is defeated. The state is one saved flag per zone; this class owns the flag
## names and the unlock thresholds that depend on how many zones are free, so the rules stay in
## `core/` and the Session / scenes only call into it.

## The Arena (The Grand Clashatorium) opens after this many zones are completed.
const ARENA_UNLOCK_COUNT: int = 1
## The Alchemist (Crucible & Co.) opens after this many zones are completed.
const ALCHEMIST_UNLOCK_COUNT: int = 2
const TOTAL_ZONES: int = 4


static func flag_name(zone_id: String) -> StringName:
	return StringName("zone_%s_completed" % zone_id)


static func is_completed(flags: Dictionary, zone_id: String) -> bool:
	return bool(flags.get(str(flag_name(zone_id)), false))


static func completed_ids(flags: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for zone_id: String in ZoneDefs.ids():
		if is_completed(flags, zone_id):
			result.append(zone_id)
	return result


static func count(flags: Dictionary) -> int:
	return completed_ids(flags).size()


static func arena_unlocked(flags: Dictionary) -> bool:
	return count(flags) >= ARENA_UNLOCK_COUNT


static func alchemist_unlocked(flags: Dictionary) -> bool:
	return count(flags) >= ALCHEMIST_UNLOCK_COUNT


## The player-facing "N of 4 zones free" line.
static func progress_text(flags: Dictionary) -> String:
	return "%d of %d zones free" % [count(flags), TOTAL_ZONES]
