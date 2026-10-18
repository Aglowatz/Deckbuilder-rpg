extends RefCounted
## Overnight Oct 17, Part 11: dumps what the game knows about NPCs (quest givers and turn-ins resolved to NPC IDs, every NPC id the
## registry knows) to _logs/npc_dump.json for tools/npc_truth.js. Run: Godot --headless --path . -s res://tools/npc_dump_run.gd


func run() -> void:
	var quests: Array = []
	for quest: QuestData in QuestCatalog.all():
		quests.append({
			"id": quest.id, "title": quest.title,
			"giver": NpcRegistry.resolve_speaker(quest.giver_npc) if not quest.giver_npc.is_empty() else "",
			"turn_in": NpcRegistry.resolve_speaker(quest.turn_in_npc) if not quest.turn_in_npc.is_empty() else "",
			"giver_name": quest.giver_npc,
		})
	var ids: Array = []
	for entry: NpcRegistry.Entry in NpcRegistry.all():
		ids.append(entry.id)
	var file: FileAccess = FileAccess.open("res://_logs/npc_dump.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"quests": quests, "ids": ids}, "\t"))
	file.close()
	print("npc_dump: %d quests, %d npcs" % [quests.size(), ids.size()])
