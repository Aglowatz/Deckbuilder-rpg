class_name QuestDefinitions
extends RefCounted
## Authoring source for every quest. Run `tools/generate_quests.gd` to write them to
## `data/quests/*.tres` (the files the game loads). Dialogue spoken by quest givers lives in
## `StoryText.quest_dialogue` (core/data/story_text.gd), not here.

const MERCHANTS: String = "meet_the_merchants"
const PATHS: String = "clear_the_paths"


static func build_all() -> Array[QuestData]:
	var result: Array[QuestData] = []
	result.append(_meet_the_merchants())
	result.append(_clear_the_paths())
	result.append_array(ZoneQuestDefinitions.build_all())
	return result


static func _meet_the_merchants() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = MERCHANTS
	quest.order = 10
	quest.title = "Meet the Merchants"
	quest.summary = "Three traders keep the town running. Introduce yourself to all of them."
	quest.auto_give = true
	quest.objectives = [
		QuestObjective.make("Talk to Sable the Trader (cards)", Condition.flag("vendor_seen")),
		QuestObjective.make("Talk to Wick (items)", Condition.flag("item_vendor_seen")),
		QuestObjective.make("Talk to Wendell Cobb (equipment)", Condition.flag("equipment_vendor_seen")),
	] as Array[QuestObjective]
	quest.reward_gold = 50
	quest.reward_xp = 40
	return quest


static func _clear_the_paths() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = PATHS
	quest.order = 20
	quest.title = "Clear the Paths"
	quest.summary = "Four corrupted wanderers block the roads out of town. Defeat each one."
	quest.auto_give = true
	var objectives: Array[QuestObjective] = []
	for npc_id: String in CorruptedNpcs.IDS:
		objectives.append(QuestObjective.make("Defeat %s" % CorruptedNpcs.display_name(npc_id), Condition.flag(str(CorruptedNpcs.unlock_flag(npc_id)))))
	quest.objectives = objectives
	quest.reward_gold = 150
	quest.reward_xp = 120
	return quest
