class_name EncounterRewards
extends RefCounted
## XP and gold for one encounter, scaled by its `DungeonMap.Difficulty` (Part E). Data-driven: a
## single table, not scattered per-node numbers.

const XP_BY_DIFFICULTY: Dictionary = {
	DungeonMap.Difficulty.TUTORIAL: 15,
	DungeonMap.Difficulty.NORMAL: 30,
	DungeonMap.Difficulty.ELITE: 60,
	DungeonMap.Difficulty.BOSS: 120,
}

const GOLD_BY_DIFFICULTY: Dictionary = {
	DungeonMap.Difficulty.TUTORIAL: 40,
	DungeonMap.Difficulty.NORMAL: 70,
	DungeonMap.Difficulty.ELITE: 130,
	DungeonMap.Difficulty.BOSS: 200,
}


static func xp_for(difficulty: DungeonMap.Difficulty) -> int:
	return int(XP_BY_DIFFICULTY.get(difficulty, 0))


static func gold_for(difficulty: DungeonMap.Difficulty) -> int:
	return int(GOLD_BY_DIFFICULTY.get(difficulty, 0))


## Overnight Nov 4-5, Part 2.2: a dungeon node pays this share of what it paid before (fights were half the roaming rate, treasure its loot
## table); beating the boss pays the run's gold once more (`Session.pay_clear_bonus`), so a FINISHED run pays exactly the old amount and an
## abandoned or lost one half of it. Tuned on the no-grind study (docs/balance/gold_economy_nov3.md, "Overnight Nov 4-5").
const DUNGEON_NODE_GOLD_SHARE: float = 0.5  # Fixes Nov 8: restored


## A dungeon fight's gold (half the roaming rate, as before) after DUNGEON_NODE_GOLD_SHARE, rounded to 5.
static func dungeon_fight_gold(difficulty: DungeonMap.Difficulty) -> int:
	return dungeon_share(gold_for(difficulty) / 2)


static func dungeon_share(gold: int) -> int:
	return maxi(5, roundi(float(gold) * DUNGEON_NODE_GOLD_SHARE / 5.0) * 5) if gold > 0 else 0
