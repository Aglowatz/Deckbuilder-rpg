class_name QuestData
extends Resource
## A data-driven quest, authored in `QuestDefinitions` / `ZoneQuestDefinitions` and loaded by `QuestCatalog` (built in code since Oct 16; no .tres).
## Offered either automatically (`auto_give`, when its `prerequisite` Condition is met) or by an
## NPC (`giver_npc` calls `Session.start_quest`). It completes by itself when every objective is
## met, unless `turn_in_npc` is set - then it waits ("ready") until the player talks to that NPC.
## Overnight Oct 16: quests have a category (MAIN story lines, SIDE favours), a home area, ordered objectives with targets and milestone rewards.

enum Category { MAIN, SIDE }

@export var id: String = ""
@export var category: Category = Category.SIDE
## The quest's player-facing name.
@export var title: String = ""
## A short description (one or two sentences).
@export var summary: String = ""
## Display name of the NPC who gives it ("" for auto-given quests) and who takes it back.
@export var giver_npc: String = ""
@export var turn_in_npc: String = ""
## Where the giver / turn-in stands: "town", "forest" or a zone id, plus their spot id there (for the "!" / "?" markers and the details pane).
@export var giver_area: String = ""
@export var giver_spot: String = ""
@export var turn_in_area: String = ""
@export var turn_in_spot: String = ""
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
## Brief 11: unopened packs (pack ids, `data/packs`) paid into the inventory.
@export var reward_pack_ids: Array[String] = []
## Flags set on completion (the "unlocks" reward): vendors/gates/dialogue read them as Conditions.
@export var reward_unlock_flags: Array[String] = []


func is_main() -> bool:
	return category == Category.MAIN


func category_tag() -> String:
	return "MAIN" if category == Category.MAIN else "SIDE"


## The quest's completion payout as one bundle (the same fields, for code that pays or previews any reward).
func completion_reward() -> QuestReward:
	var reward: QuestReward = QuestReward.of(reward_gold, reward_xp)
	reward.item_ids = reward_item_ids.duplicate()
	reward.card_ids = reward_card_ids.duplicate()
	reward.equipment_ids = reward_equipment_ids.duplicate()
	reward.pack_ids = reward_pack_ids.duplicate()
	reward.unlock_flags = reward_unlock_flags.duplicate()
	return reward


func reward_summary() -> String:
	var parts: PackedStringArray = QuestReward.describe(reward_gold, reward_xp, reward_item_ids, reward_card_ids, reward_equipment_ids, reward_pack_ids)
	for flag_name: String in reward_unlock_flags:
		if flag_name.begins_with("capital_insight_"):
			parts.append("Insight into %s" % Villain.display_name())
	return ", ".join(parts)


## Every pack and equipment id this quest can pay, milestones included (the rewards preview and docs/design/quests.md).
func all_pack_ids() -> Array[String]:
	var result: Array[String] = []
	for objective: QuestObjective in objectives:
		if objective.milestone != null:
			result.append_array(objective.milestone.pack_ids)
	result.append_array(reward_pack_ids)
	return result


func all_equipment_ids() -> Array[String]:
	var result: Array[String] = []
	for objective: QuestObjective in objectives:
		if objective.milestone != null:
			result.append_array(objective.milestone.equipment_ids)
	result.append_array(reward_equipment_ids)
	return result
