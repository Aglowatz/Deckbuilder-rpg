class_name LevelHints
extends RefCounted
## Day pass Nov 9 (release prep): a soft level hint at every dungeon entrance and on the map. The four real-fight playthroughs
## (Overnight Nov 9) stalled at Primm, the Shattered Gallery, the second and fourth main dungeons and S-NECRO whenever the hero
## arrived 2-5 levels under `ProgressionModel`'s expected player, so the game now says what level travellers usually are there:
## "Travellers here are usually around level N." It is amber when the player is UNDER_BY or more levels under, muted otherwise.
## Pure data: the expected level is `ProgressionModel.LEVELS[dungeon id]`; a dungeon without one (or the level-1 tutorial cave) shows nothing.

## Amber (the HUD's warning tint) when the player is this many levels or more under the expected level.
const UNDER_BY: int = 2
const AMBER: Color = Color("ffcf70")
const MUTED: Color = Color("a89bb5")


## The level travellers usually have at `dungeon_id`'s door; 0 when the model has none (no hint).
static func expected_level(dungeon_id: String) -> int:
	var level: int = ProgressionModel.level_for(dungeon_id, 0)
	return level if level > 1 else 0


## The entrance line, or "" when there is nothing worth saying.
static func text(dungeon_id: String) -> String:
	var level: int = expected_level(dungeon_id)
	return "Travellers here are usually around level %d." % level if level > 0 else ""


## The short form for lists and tooltips ("usually level 11"), or "".
static func short_text(dungeon_id: String) -> String:
	var level: int = expected_level(dungeon_id)
	return "usually level %d" % level if level > 0 else ""


## True when `player_level` is UNDER_BY or more levels under the dungeon's expected level.
static func is_under(dungeon_id: String, player_level: int) -> bool:
	var level: int = expected_level(dungeon_id)
	return level > 0 and player_level + UNDER_BY <= level


static func colour(dungeon_id: String, player_level: int) -> Color:
	return AMBER if is_under(dungeon_id, player_level) else MUTED
