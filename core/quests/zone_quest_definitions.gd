class_name ZoneQuestDefinitions
extends RefCounted
## Quests given by NPCs inside zones - the three D.N.A. hub quests. Each is offered by, and handed
## in to, the same hub NPC (see TownScene/DnaScene `_talk_quest_npc`). Dialogue for them lives in
## ZoneStoryText ("quest.<id>.offer/active/ready/done").

const BACKLOG: String = "dna_backlog"
const ONBOARDING: String = "dna_onboarding"
const AUDIT: String = "dna_audit"


static func build_all() -> Array[QuestData]:
	return [_backlog(), _onboarding(), _audit(), _gain_power(), _gain_spot_me(), _gain_lanes()] as Array[QuestData]


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


# ---- The Gainlands (brief 6): three hub quests -----------------------------------------------


static func _gain_power() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = GainlandsZone.QUEST_POWER
	quest.order = 210
	quest.title = "Juice the Station"
	quest.summary = "The Swole Station's lights are flickering. Foreman Gus needs somebody to run the Colossal Hamster Wheel and, frankly, drink something."
	quest.giver_npc = GainlandsZone.NPC_GUS
	quest.turn_in_npc = GainlandsZone.NPC_GUS
	quest.objectives = [
		QuestObjective.make("Run the Colossal Hamster Wheel", Condition.flag(str(GainlandsZone.FLAG_WHEEL_POWERED))),
		QuestObjective.make("Buy a protein shake", Condition.counter(GainlandsZone.COUNTER_SHAKES, 1)),
	] as Array[QuestObjective]
	quest.reward_gold = 50
	quest.reward_xp = 40
	quest.reward_item_ids = ["healing_salve"] as Array[String]
	return quest


static func _gain_spot_me() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = GainlandsZone.QUEST_SPOT_ME
	quest.order = 220
	quest.title = "Spot Me!"
	quest.summary = "Coach Brenda's rule: nobody lifts alone. Spot Gary (he is under a barbell again) and check your form at a Flex Mirror."
	quest.giver_npc = GainlandsZone.NPC_BRENDA
	quest.turn_in_npc = GainlandsZone.NPC_BRENDA
	quest.objectives = [
		QuestObjective.make("Spot Gary", Condition.flag(str(GainlandsZone.FLAG_SPOTTED))),
		QuestObjective.make("Flex at a Flex Mirror", Condition.counter(GainlandsZone.COUNTER_FLEXES, 1)),
	] as Array[QuestObjective]
	quest.reward_gold = 70
	quest.reward_xp = 60
	quest.reward_card_ids = ["pre_workout"] as Array[String]
	return quest


static func _gain_lanes() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = GainlandsZone.QUEST_LANES
	quest.order = 230
	quest.title = "Clear the Lanes"
	quest.summary = "Tiny Tony's protein deliveries keep getting intercepted by roaming brutes, golems and sprites. Beat three of them."
	quest.giver_npc = GainlandsZone.NPC_TONY
	quest.turn_in_npc = GainlandsZone.NPC_TONY
	quest.objectives = [QuestObjective.make("Defeat roaming Gainlands enemies", Condition.counter(GainlandsZone.COUNTER_ENEMIES, 3))] as Array[QuestObjective]
	quest.reward_gold = 80
	quest.reward_xp = 70
	quest.reward_card_ids = ["leg_day"] as Array[String]
	return quest
