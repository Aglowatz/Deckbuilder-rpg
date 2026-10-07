class_name QuestDefinitions
extends RefCounted
## Authoring source for every quest. Run `tools/generate_quests.gd` to write them to
## `data/quests/*.tres` (the files the game loads). Dialogue spoken by quest givers lives in
## `StoryText.quest_dialogue` (core/data/story_text.gd), not here.

const MERCHANTS: String = "meet_the_merchants"
const PATHS: String = "clear_the_paths"
const FREE_ZONES: String = "free_the_kingdom"


static func build_all() -> Array[QuestData]:
	var result: Array[QuestData] = []
	result.append(_meet_the_merchants())
	result.append(_clear_the_paths())
	result.append(_free_the_kingdom())
	result.append(_oldest_trick())
	result.append(_four_seals())
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
		QuestObjective.make("Talk to Sable (cards)", Condition.flag("vendor_seen")),
		QuestObjective.make("Talk to Tilly Tonic (items)", Condition.flag("item_vendor_seen")),
		QuestObjective.make("Talk to Bertram Beetsworth (equipment)", Condition.flag("equipment_vendor_seen")),
	] as Array[QuestObjective]
	quest.reward_gold = 50
	quest.reward_xp = 40
	return quest


static func _clear_the_paths() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = PATHS
	quest.order = 20
	quest.title = "Clear the Paths"
	quest.summary = "Four corrupted envoys, in {villain}'s thrall, block the roads out of town. Defeat each one to open its Path."
	quest.auto_give = true
	var objectives: Array[QuestObjective] = []
	for npc_id: String in CorruptedNpcs.IDS:
		objectives.append(QuestObjective.make("Defeat %s" % CorruptedNpcs.display_name(npc_id), Condition.flag(str(CorruptedNpcs.unlock_flag(npc_id)))))
	quest.objectives = objectives
	quest.reward_gold = 150
	quest.reward_xp = 120
	return quest


static func _free_the_kingdom() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = FREE_ZONES
	quest.order = 30
	quest.title = "Free the Kingdom"
	quest.summary = "{villain} rules each Path through an oppressive ruler. Defeat the boss of every zone's final dungeon to free it."
	quest.auto_give = true
	var objectives: Array[QuestObjective] = []
	for zone_id: String in ["beefcake", "gourmand", "necrocrat", "refusemancer"]:
		var dungeon: String = "The House of Gains" if zone_id == "beefcake" else ("The Test Kitchen" if zone_id == "gourmand" else ("The Hall of Final Approvals" if zone_id == "necrocrat" else "The Rotheart"))
		objectives.append(QuestObjective.make("Free the zone: clear %s" % dungeon, Condition.flag(str(ZoneCompletion.flag_name(zone_id)))))
	quest.objectives = objectives
	quest.reward_gold = 300
	quest.reward_xp = 250
	return quest


## Brief 16, Group B: started by Session.open_giant_chest the first time any giant chest is opened (never auto-given, so it stays hidden until then).
static func _oldest_trick() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = NinjaBoss.QUEST_ID
	quest.order = 40
	quest.title = "The Oldest Trick in the Book"
	quest.summary = "A giant chest was too good to be true. Someone is conning travellers across the kingdom with them, and he took your gold. Find the chests, and find him."
	quest.objectives = [
		QuestObjective.make("Open the giant chests", Condition.counter(NinjaBoss.COUNTER_OPENED, NinjaBoss.CHEST_IDS.size())),
		QuestObjective.make("Face the Master of the Oldest Trick", Condition.flag(str(NinjaBoss.FLAG_DEFEATED))),
	] as Array[QuestObjective]
	return quest


## Brief 16, Group G: a hidden quest, started by Session.pull_vault_lever the first time any of the four levers is pulled (never auto-given).
static func _four_seals() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = VaultGuardian.QUEST_ID
	quest.order = 41
	quest.title = "The Four Seals"
	quest.summary = "Far away, a great lock ground open. Somewhere in every Path zone a hidden lever answers a seal on a vault in town. Find them all."
	quest.objectives = [
		QuestObjective.make("Find the hidden levers", Condition.counter(VaultGuardian.COUNTER_LEVERS, VaultGuardian.ZONE_IDS.size())),
		QuestObjective.make("Open the vault and defeat its Warden", Condition.flag(str(VaultGuardian.FLAG_DEFEATED))),
	] as Array[QuestObjective]
	return quest
