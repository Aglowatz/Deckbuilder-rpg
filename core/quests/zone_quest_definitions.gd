class_name ZoneQuestDefinitions
extends RefCounted
## Quests given by NPCs inside zones - the three D.N.A. hub quests. Each is offered by, and handed
## in to, the same hub NPC (see TownScene/DnaScene `_talk_quest_npc`). Dialogue for them lives in
## ZoneStoryText ("quest.<id>.offer/active/ready/done").

const BACKLOG: String = "dna_backlog"
const ONBOARDING: String = "dna_onboarding"
const AUDIT: String = "dna_audit"


## Brief 11: which quests also pay a Path Pack (quest id -> pack id): two per zone, plus a minigame prize each (`ZoneDef.minigame_pack`).
## All numbers/ids are placeholders: edit here (then regenerate the quest files) or in `data/quests/*.tres`.
const PACK_REWARDS: Dictionary = {
	"dna_backlog": "path_necrocrat", "dna_audit": "path_necrocrat",
	"gain_spot_me": "path_beefcake", "gain_lanes": "path_beefcake",
	"buf_pantry": "path_gourmand", "buf_mend": "path_gourmand",
	"heap_fert": "path_refusemancer", "heap_dam": "path_refusemancer",
}


static func build_all() -> Array[QuestData]:
	var quests: Array[QuestData] = _build_unpacked()
	for quest: QuestData in quests:
		if PACK_REWARDS.has(quest.id):
			quest.reward_pack_ids = [str(PACK_REWARDS[quest.id])] as Array[String]
	return quests


static func _build_unpacked() -> Array[QuestData]:
	return [_backlog(), _onboarding(), _audit(), _gain_power(), _gain_spot_me(), _gain_lanes(), _buf_pantry(), _buf_pie(), _buf_mend(), _heap_herd(), _heap_fert(), _heap_dam()] as Array[QuestData] + capital_quests()


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
	quest.reward_card_ids = ["N-14"] as Array[String]
	quest.reward_equipment_ids = ["compliance_clipboard"] as Array[String]
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
	quest.reward_card_ids = ["B-17"] as Array[String]
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
	quest.reward_card_ids = ["B-12"] as Array[String]
	quest.reward_equipment_ids = ["spotters_barbell"] as Array[String]
	return quest


# ---- The Endless Buffet (brief 7): three hub quests ------------------------------------------


static func _buf_pantry() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = BuffetZone.QUEST_PANTRY
	quest.order = 310
	quest.title = "Pantry Run"
	quest.summary = "The Grand Pantry is out of everything that matters. Sous-Chef Tarragon needs three ingredients gathered from around the Endless Buffet."
	quest.giver_npc = BuffetZone.NPC_TARRAGON
	quest.turn_in_npc = BuffetZone.NPC_TARRAGON
	quest.objectives = [QuestObjective.make("Gather ingredients around the zone", Condition.counter(BuffetZone.COUNTER_GATHERED, 3))] as Array[QuestObjective]
	quest.reward_gold = 60
	quest.reward_xp = 50
	quest.reward_card_ids = ["G-25"] as Array[String]
	return quest


static func _buf_pie() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = BuffetZone.QUEST_PIE
	quest.order = 320
	quest.title = "Bake Me a Pie"
	quest.summary = "Dolcetta Crumb wants a Hearty Pot Pie, baked fresh in the Grand Oven from honey, basil and a ghost pepper, and delivered to her counter."
	quest.giver_npc = BuffetZone.NPC_DOLCETTA
	quest.turn_in_npc = BuffetZone.NPC_DOLCETTA
	quest.objectives = [QuestObjective.make("Bake a Hearty Pot Pie in the Grand Oven", Condition.counter(BuffetZone.COUNTER_BAKED, 1))] as Array[QuestObjective]
	quest.reward_gold = 70
	quest.reward_xp = 60
	quest.reward_card_ids = ["G-07"] as Array[String]
	quest.reward_equipment_ids = ["head_chef_toque"] as Array[String]
	return quest


static func _buf_mend() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = BuffetZone.QUEST_MEND
	quest.order = 330
	quest.title = "Mend the Meatloaf"
	quest.summary = "Old Meatloaf, the Grand Pantry's oldest golem, has stopped working. Head Chef Odalys needs him repaired: sea salt and a black truffle should do it."
	quest.giver_npc = BuffetZone.NPC_ODALYS
	quest.turn_in_npc = BuffetZone.NPC_ODALYS
	quest.objectives = [QuestObjective.make("Repair Old Meatloaf", Condition.flag(str(BuffetZone.FLAG_MENDED)))] as Array[QuestObjective]
	quest.reward_gold = 80
	quest.reward_xp = 70
	quest.reward_card_ids = ["GR-04"] as Array[String]
	return quest


# ---- The Verdant Dump (brief 8): three hub quests ---------------------------------------------


static func _heap_herd() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = HeapZone.QUEST_HERD
	quest.order = 410
	quest.title = "Round Up the Herd"
	quest.summary = "Three of Wren Muckfoot's garbage-eating animals have wandered off into the fields. Shoo each one back towards the pen."
	quest.giver_npc = HeapZone.NPC_WREN
	quest.turn_in_npc = HeapZone.NPC_WREN
	quest.objectives = [QuestObjective.make("Shoo escaped animals back to the pen", Condition.counter(HeapZone.COUNTER_HERDED, 3))] as Array[QuestObjective]
	quest.reward_gold = 60
	quest.reward_xp = 50
	quest.reward_card_ids = ["R-04"] as Array[String]
	return quest


static func _heap_fert() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = HeapZone.QUEST_FERT
	quest.order = 420
	quest.title = "Fertilizer Run"
	quest.summary = "Farmer Hob is out of fertilizer and the crops are sulking. Gather three sacks from around the Verdant Dump."
	quest.giver_npc = HeapZone.NPC_HOB
	quest.turn_in_npc = HeapZone.NPC_HOB
	quest.objectives = [QuestObjective.make("Gather sacks of fertilizer", Condition.counter(HeapZone.COUNTER_FERTILIZER, 3))] as Array[QuestObjective]
	quest.reward_gold = 70
	quest.reward_xp = 60
	quest.reward_card_ids = ["R-25"] as Array[String]
	return quest


static func _heap_dam() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = HeapZone.QUEST_DAM
	quest.order = 430
	quest.title = "Unblock the Stream"
	quest.summary = "Somebody has dumped a junk dam across the recycling stream. Druid Marigold needs a charging mount to smash it, and she will reward you with a fine pair of compost boots."
	quest.giver_npc = HeapZone.NPC_MARIGOLD
	quest.turn_in_npc = HeapZone.NPC_MARIGOLD
	quest.objectives = [QuestObjective.make("Smash the junk dam on a charging mount", Condition.flag("heap_smashed_dam"))] as Array[QuestObjective]
	quest.reward_gold = 80
	quest.reward_xp = 70
	quest.reward_equipment_ids = ["compost_boots"] as Array[String]
	return quest


# ---- The Capital (brief 10): four Path quests, one per Path, given by citizens who show what Primm's perfection cost -------------


static func capital_quests() -> Array[QuestData]:
	return [_cap_burial(), _cap_wheels(), _cap_recipes(), _cap_untidy()] as Array[QuestData]


static func _cap_burial() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = CapitalZone.QUEST_BURIAL
	quest.order = 510
	quest.title = "Form 27-B/6: A Burial Permit"
	quest.summary = "Tilda Marrow's grandfather has sat in the family parlor for three years because the permit loops forever. Find the Stamp of Final Approval in Grave Row, then lay him to rest."
	quest.giver_npc = CapitalZone.NPC_TILDA
	quest.turn_in_npc = CapitalZone.NPC_TILDA
	quest.objectives = [
		QuestObjective.make("Find the Stamp of Final Approval", Condition.flag(str(CapitalZone.FLAG_STAMP))),
		QuestObjective.make("Lay Grandfather Marrow to rest", Condition.flag(str(CapitalZone.FLAG_LAID_TO_REST))),
	] as Array[QuestObjective]
	quest.reward_gold = 150
	quest.reward_xp = 120
	quest.reward_item_ids = ["healing_draught"] as Array[String]
	quest.reward_card_ids = ["N-28"] as Array[String]
	quest.reward_unlock_flags = [str(CapitalZone.insight_flag("necrocrat"))] as Array[String]
	return quest


static func _cap_wheels() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = CapitalZone.QUEST_WHEELS
	quest.order = 520
	quest.title = "The Wheel Never Stops"
	quest.summary = "Beefcake crews have run the facade's energy wheels for ten years because nobody told them they could stop. Free the three crews in the Transit Yards and cut the cable that feeds the facade."
	quest.giver_npc = CapitalZone.NPC_BRAM
	quest.turn_in_npc = CapitalZone.NPC_BRAM
	quest.objectives = [
		QuestObjective.make("Free the wheel crews", Condition.counter(CapitalZone.COUNTER_WHEELS, 3)),
		QuestObjective.make("Cut the facade's power cable", Condition.flag(str(CapitalZone.FLAG_CABLE_CUT))),
	] as Array[QuestObjective]
	quest.reward_gold = 150
	quest.reward_xp = 120
	quest.reward_item_ids = ["vitality_charm"] as Array[String]
	quest.reward_card_ids = ["B-30"] as Array[String]
	quest.reward_unlock_flags = [str(CapitalZone.insight_flag("beefcake"))] as Array[String]
	return quest


static func _cap_recipes() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = CapitalZone.QUEST_RECIPES
	quest.order = 530
	quest.title = "The Recipe Box"
	quest.summary = "Everyone eats Primm's Perfect Nutrient Paste. Chef Odile Bisque has hidden real recipes around the Hungry Quarter: recover three of them and spoil the paste dispenser."
	quest.giver_npc = CapitalZone.NPC_ODILE
	quest.turn_in_npc = CapitalZone.NPC_ODILE
	quest.objectives = [
		QuestObjective.make("Find the hidden recipe cards", Condition.counter(CapitalZone.COUNTER_RECIPES, 3)),
		QuestObjective.make("Spoil the Perfect Nutrient Paste dispenser", Condition.flag(str(CapitalZone.FLAG_PASTE_SPOILED))),
	] as Array[QuestObjective]
	quest.reward_gold = 150
	quest.reward_xp = 120
	quest.reward_item_ids = ["hearty_pie"] as Array[String]
	quest.reward_card_ids = ["G-31"] as Array[String]
	quest.reward_unlock_flags = [str(CapitalZone.insight_flag("gourmand"))] as Array[String]
	return quest


static func _cap_untidy() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = CapitalZone.QUEST_UNTIDY
	quest.order = 540
	quest.title = "Untidy"
	quest.summary = "Composting is outlawed as untidy and the Capital's garbage is hidden behind the facade, so the land is sickening. Rescue three banished compost heaps in the Reek, find the old seed and plant it in the Sick Patch."
	quest.giver_npc = CapitalZone.NPC_GUS
	quest.turn_in_npc = CapitalZone.NPC_GUS
	quest.objectives = [
		QuestObjective.make("Rescue the banished compost heaps", Condition.counter(CapitalZone.COUNTER_COMPOST, 3)),
		QuestObjective.make("Plant the old seed in the Sick Patch", Condition.flag(str(CapitalZone.FLAG_SEED_PLANTED))),
	] as Array[QuestObjective]
	quest.reward_gold = 150
	quest.reward_xp = 120
	quest.reward_item_ids = ["healing_salve"] as Array[String]
	quest.reward_card_ids = ["R-30"] as Array[String]
	quest.reward_unlock_flags = [str(CapitalZone.insight_flag("refusemancer"))] as Array[String]
	return quest
