extends RefCounted
## Overnight Oct 17, Part 6: how much XP one playthrough offers, to check the level curve reaches 30 around the end game.
## Sums every dungeon's battle nodes (one clear each), every quest's XP and an estimate of the overworld fights.
## Run: Godot --headless --path . -s res://tools/xp_budget_run.gd (loads this after the autoloads exist)


func run() -> void:
	var dungeon_total: int = 0
	var postgame_total: int = 0
	var lines: PackedStringArray = []
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		var def: MainDungeonDef = DungeonBuilder.build_def(blueprint)
		var map: DungeonMap = DungeonBuilder.build_map(blueprint, def)
		var xp: int = 0
		for map_node: DungeonMap.MapNode in map.nodes:
			if DungeonMap.is_battle_kind(map_node.kind):
				xp += EncounterRewards.xp_for(map_node.difficulty)
		lines.append("%s: %d xp over %d nodes" % [blueprint.id, xp, map.nodes.size()])
		if blueprint.id in ["D-LAB", "S-BEEF"]:
			postgame_total += xp
		else:
			dungeon_total += xp
	var quest_total: int = 0
	for quest: QuestData in QuestCatalog.all():
		quest_total += quest.reward_xp
	# Overworld fights: about 10 roamers/guards per Path zone (35-60 xp) and 15 in the Capital (45-120), fought once each.
	var overworld: int = 4 * 10 * 45 + 15 * 60
	var total: int = dungeon_total + quest_total + overworld
	print("\n".join(lines))
	print("dungeons (main game): %d, postgame dungeons: %d, quests: %d, overworld (estimate): %d" % [dungeon_total, postgame_total, quest_total, overworld])
	print("main game total: %d -> level %d; with the postgame: %d -> level %d" % [total, ProgressionTable.level_for_xp(total), total + postgame_total, ProgressionTable.level_for_xp(total + postgame_total)])
	for level: int in [5, 10, 15, 20, 25, 30]:
		print("level %d needs %d xp" % [level, ProgressionTable.xp_to_reach(level)])
