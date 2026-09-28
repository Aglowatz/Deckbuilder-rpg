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
