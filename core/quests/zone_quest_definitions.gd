class_name ZoneQuestDefinitions
extends RefCounted
## Quests given by NPCs inside zones - the three D.N.A. hub quests. Each is offered by, and handed
## in to, the same hub NPC (see TownScene/DnaScene `_talk_quest_npc`). Dialogue for them lives in
## ZoneStoryText ("quest.<id>.offer/active/ready/done").

const BACKLOG: String = "dna_backlog"
const ONBOARDING: String = "dna_onboarding"
const AUDIT: String = "dna_audit"


static func build_all() -> Array[QuestData]:
	return [_backlog(), _onboarding(), _audit()] as Array[QuestData]


static func _backlog() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = BACKLOG
	quest.order = 110
	quest.title = "Clear the Backlog"
	quest.summary = "Dolores' backlog has gone feral and is wandering the floors. Process three roaming staff members (win their duels)."
	quest.giver_npc = DnaZone.NPC_DOLORES
	quest.turn_in_npc = DnaZone.NPC_DOLORES
	quest.objectives = [QuestObjective.make("Defeat roaming staff", Condition.counter("zone_enemies_defeated", 3))] as Array[QuestObjective]
	quest.reward_gold = 60
	quest.reward_xp = 60
	quest.reward_item_ids = ["healing_draught"] as Array[String]
	return quest


static func _onboarding() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = ONBOARDING
	quest.order = 120
	quest.title = "Mandatory Onboarding"
	quest.summary = "Barnaby says all new hires must punch in at the time clock and pour a cup at the breakroom coffee machine. HR will know if you skip it."
	quest.giver_npc = DnaZone.NPC_BARNABY
	quest.turn_in_npc = DnaZone.NPC_BARNABY
	quest.objectives = [
		QuestObjective.make("Punch in at the time clock", Condition.counter(DnaZone.COUNTER_PUNCHED_IN, 1)),
		QuestObjective.make("Pour a cup at the coffee machine", Condition.counter(DnaZone.COUNTER_COFFEE, 1)),
	] as Array[QuestObjective]
	quest.reward_gold = 40
	quest.reward_xp = 30
	quest.reward_item_ids = ["healing_salve"] as Array[String]
	return quest


static func _audit() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = AUDIT
	quest.order = 130
	quest.title = "Compliance Audit"
	quest.summary = "Pip needs a fresh pair of hands for the audit: pass the Compliance quiz and find a hidden stash somewhere in the filing mazes."
	quest.giver_npc = DnaZone.NPC_PIP
	quest.turn_in_npc = DnaZone.NPC_PIP
	quest.objectives = [
		QuestObjective.make("Take the Compliance quiz", Condition.flag(str(DnaZone.FLAG_QUIZ_DONE))),
		QuestObjective.make("Find a hidden stash", Condition.counter(DnaZone.COUNTER_CHESTS, 1)),
	] as Array[QuestObjective]
	quest.reward_gold = 80
	quest.reward_xp = 70
	quest.reward_card_ids = ["death_benefits"] as Array[String]
	return quest
