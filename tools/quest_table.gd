extends Node
## Prints the quest reward table (markdown) for docs/design/quests.md: every quest, its category, giver, objectives with targets and milestone
## rewards, and the completion reward.
##   Godot --headless --path . res://tools/quest_table.tscn > table.md   (a scene, so the autoloads exist)


func _ready() -> void:
	await get_tree().process_frame
	var lines: PackedStringArray = []
	lines.append("| Quest | Category | Giver | Steps (target; step reward) | Completion reward |")
	lines.append("|---|---|---|---|---|")
	for quest: QuestData in QuestCatalog.all():
		var steps: PackedStringArray = []
		for index: int in range(quest.objectives.size()):
			var objective: QuestObjective = quest.objectives[index]
			var step: String = "%d. %s" % [index + 1, objective.text]
			if objective.has_marker():
				step += " (%s / %s)" % [objective.target_area, objective.target_id]
			if objective.milestone != null and not objective.milestone.is_empty():
				step += " **pays: %s**" % objective.milestone.summary()
			steps.append(step)
		var giver: String = quest.giver_npc if quest.giver_npc != "" else ("auto" if quest.auto_give else "event")
		lines.append("| %s (`%s`) | %s | %s | %s | %s |" % [quest.title, quest.id, quest.category_tag(), giver, "<br>".join(steps), quest.reward_summary()])
	print("\n".join(lines))
	get_tree().quit(0)
