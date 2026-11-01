class_name DungeonClearBonus
extends RefCounted
## Fable pass Nov 1 (Part 3, progression): the XP a dungeon's FIRST clear pays, scaled with the dungeon's tier instead of a flat number,
## so clearing dungeons (not grinding roamers: ~15 fights a level at L13) is what carries the level curve. The tier is the dungeon's
## expected level (`ProgressionModel.LEVELS`); the bonus is a fraction of the XP that level's next step costs (`ProgressionTable.xp_step`),
## so it keeps pace with the curve by itself. A main dungeon pays MAIN_FRACTION of a level (plus the pack config's flat first-clear
## bonus and its Gilded Pack, as before); a side dungeon pays SIDE_FRACTION (it paid no XP before Nov 1). Primm's Castle keeps its own
## prize (400). Timeline check: `docs/design/sim/economy_model.md` (the level timeline) and docs/design/progression.md.

const MAIN_FRACTION: float = 0.5
const SIDE_FRACTION: float = 0.15


## The XP of a first clear of main dungeon `dungeon_id` (its tier from the progression model; `fallback_level` for an unknown id).
static func main_xp(dungeon_id: String, fallback_level: int = 8) -> int:
	return _scaled(dungeon_id, MAIN_FRACTION, fallback_level)


## The XP of a first clear of side dungeon `dungeon_id`.
static func side_xp(dungeon_id: String, fallback_level: int = 6) -> int:
	return _scaled(dungeon_id, SIDE_FRACTION, fallback_level)


## The dungeon's tier: the level the progression model expects there.
static func tier_of(dungeon_id: String, fallback_level: int) -> int:
	return ProgressionModel.level_for(dungeon_id, fallback_level)


static func _scaled(dungeon_id: String, fraction: float, fallback_level: int) -> int:
	var level: int = tier_of(dungeon_id, fallback_level)
	# The step from this level to the next: what "a level here" costs.
	var step: int = ProgressionTable.xp_step(level + 1)
	return int(round(float(step) * fraction / 5.0)) * 5
