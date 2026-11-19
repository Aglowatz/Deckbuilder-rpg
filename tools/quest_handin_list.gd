extends SceneTree
## Fable Nov 20 (Part 4.2): lists every quest that is handed in to somebody (id | hand-in NPC | area | spot | steps), for the hand-in probe.
##   Godot --headless --path . -s res://tools/quest_handin_list.gd


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var catalog: GDScript = load("res://core/quests/quest_catalog.gd") as GDScript
	var count: int = 0
	for quest: Variant in catalog.call("all") as Array:
		var data: QuestData = quest as QuestData
		if data.turn_in_npc.is_empty():
			continue
		count += 1
		var steps: PackedStringArray = []
		for objective: QuestObjective in data.objectives:
			steps.append(objective.text)
		print("handin | %s | %s | %s | %s | giver %s @ %s/%s | %s" % [data.id, data.turn_in_npc, data.turn_in_area, data.turn_in_spot, data.giver_npc, data.giver_area, data.giver_spot, " // ".join(steps)])
	print("handin: %d quests are handed in to somebody" % count)
	quit(0)
