class_name BossTalks
extends RefCounted
## Which story scene (`StoryScenes`) closes a dungeon boss (Oct 21): the boss node's `talk_after`, or its `<id>_alone` variant when the
## dungeon's rescue was skipped (the Path-ology Lab without Elowen).


static func after_boss(boss: DungeonMap.MapNode, dungeon_key: String, run: DungeonRun) -> String:
	if boss == null or boss.talk_after.is_empty():
		return ""
	if dungeon_key == PathologyLab.DUNGEON_ID and not PathologyLab.rescued(run) and StoryScenes.has(boss.talk_after + "_alone"):
		return boss.talk_after + "_alone"
	return boss.talk_after


## The boss's opening scene: `talk_before`, or its `_alone` variant (see `after_boss`).
static func before_boss(boss: DungeonMap.MapNode, dungeon_key: String, run: DungeonRun) -> String:
	if boss == null or boss.talk_before.is_empty():
		return ""
	if dungeon_key == PathologyLab.DUNGEON_ID and not PathologyLab.rescued(run) and StoryScenes.has(boss.talk_before + "_alone"):
		return boss.talk_before + "_alone"
	return boss.talk_before
