class_name MemoryDefs
extends RefCounted
## The Wanderer's memory fragments (Story v2 Part E). One fragment returns for each zone freed, in order, whichever zones they were: the Nth zone
## freed unlocks fragment N, played the next time the player talks to Elder Maren. All text lives in `data/story/intro_story.tres` under
## `memory.<n>.title`, `memory.<n>.intro` (Maren), `memory.<n>.fragment` (the dimmed screen) and `memory.<n>.after` (Maren and the Wanderer);
## fragment 4 also has `.intro_known` / `.after_known` for when Primm already told the Wanderer who they are.

const COUNT: int = 4
## Flag set when fragment N has been recovered ("memory_1" .. "memory_4").
const FLAG_PREFIX: String = "memory_"
## Set once the Wanderer knows they are the prince (fragment 4, or Primm telling them in the final fight).
const FLAG_REVEALED: StringName = &"prince_revealed"
## The counter holding how many fragments have been recovered.
const COUNTER: String = "memories_recovered"
## The quest log entry that tracks the fragments.
const QUEST_ID: String = "fragments"


static func flag_name(number: int) -> StringName:
	return StringName("%s%d" % [FLAG_PREFIX, number])


## The fragment waiting to be played: the next one when more zones are free than fragments recovered, otherwise 0 (none).
static func pending(zones_freed: int, recovered: int) -> int:
	if recovered >= COUNT or recovered >= zones_freed:
		return 0
	return recovered + 1


static func key(number: int, part: String) -> String:
	return "memory.%d.%s" % [number, part]


## Maren's stage as the number of fragments recovered (0 guarded, 1 warmer, 2 admits the resistance, 3 admits her past, 4 knows the prince).
static func stage(recovered: int) -> int:
	return clampi(recovered, 0, COUNT)
