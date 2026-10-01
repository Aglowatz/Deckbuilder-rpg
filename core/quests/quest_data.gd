class_name QuestData
extends Resource
## A data-driven quest (saved as `data/quests/<id>.tres`, authored in `QuestDefinitions`).
## Offered either automatically (`auto_give`, when its `prerequisite` Condition is met) or by an
## NPC (`giver_npc` calls `Session.start_quest`). It completes by itself when every objective is
## met, unless `turn_in_npc` is set - then it waits ("ready") until the player talks to that NPC.

@export var id: String = ""
@export var title: String = ""
@export var summary: String = ""
## Display name of the NPC who gives it ("" for auto-given quests) and who takes it back.
@export var giver_npc: String = ""
@export var turn_in_npc: String = ""
@export var auto_give: bool = false
## Sort position in the log and the order auto-given quests are started.
@export var order: int = 100
## Null = always available once offered.
@export var prerequisite: Condition
@export var objectives: Array[QuestObjective] = []
@export var reward_gold: int = 0
@export var reward_xp: int = 0
@export var reward_item_ids: Array[String] = []
@export var reward_card_ids: Array[String] = []
@export var reward_equipment_ids: Array[String] = []
## Flags set on completion (the "unlocks" reward): vendors/gates/dialogue read them as Conditions.
@export var reward_unlock_flags: Array[String] = []


func reward_summary() -> String:
	var parts: PackedStringArray = []
	if reward_gold > 0:
		parts.append("%d gold" % reward_gold)
	if reward_xp > 0:
		parts.append("%d XP" % reward_xp)
	for item_id: String in reward_item_ids:
		parts.append(item_id.capitalize())
	for card_id: String in reward_card_ids:
		parts.append(card_id.capitalize())
	for equipment_id: String in reward_equipment_ids:
		parts.append(equipment_id.capitalize())
	return ", ".join(parts)
