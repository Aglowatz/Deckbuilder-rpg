class_name ZoneQuestDefinitions
extends RefCounted
## Quests given by NPCs inside zones - the three D.N.A. hub quests. Each is offered by, and handed
## in to, the same hub NPC (see TownScene/DnaScene `_talk_quest_npc`). Dialogue for them lives in
## ZoneStoryText ("quest.<id>.offer/active/ready/done").

const BACKLOG: String = "dna_backlog"
const ONBOARDING: String = "dna_onboarding"
const AUDIT: String = "dna_audit"


## Brief 11: which quests also pay a Path Pack (quest id -> pack id): one per zone since Oct 16 (the zone's MAIN line pays two more), plus a minigame prize each (`ZoneDef.minigame_pack`).
## All numbers/ids are placeholders: edit here (then regenerate the quest files) or in `data/quests/*.tres`.
const PACK_REWARDS: Dictionary = {
	"dna_audit": "path_necrocrat", "gain_spot_me": "path_beefcake", "buf_mend": "path_gourmand", "heap_dam": "path_refusemancer",
}


## Overnight Oct 16: each zone's three hub favours (the zone MAIN quest's midpoint), where every NPC quest's giver stands (area, spot id; the
## giver also takes it back), each objective's target ([kind, area, spot id, where-to-go hint]; "" spot = no world marker) and extra rewards.
const FAVOURS: Dictionary = {
	"beefcake": ["gain_power", "gain_spot_me", "gain_lanes"], "necrocrat": ["dna_backlog", "dna_onboarding", "dna_audit"],
	"gourmand": ["buf_pantry", "buf_pie", "buf_mend"], "refusemancer": ["heap_herd", "heap_fert", "heap_dam"],
}
const GIVERS: Dictionary = {
	"dna_backlog": ["necrocrat", "dolores"], "dna_onboarding": ["necrocrat", "barnaby"], "dna_audit": ["necrocrat", "pip"],
	"gain_power": ["beefcake", "gus"], "gain_spot_me": ["beefcake", "brenda"], "gain_lanes": ["beefcake", "tony"],
	"buf_pantry": ["gourmand", "tarragon"], "buf_pie": ["gourmand", "dolcetta"], "buf_mend": ["gourmand", "odalys"],
	"heap_herd": ["refusemancer", "wren"], "heap_fert": ["refusemancer", "hob"], "heap_dam": ["refusemancer", "marigold"],
	"cap_burial": ["final", "pell"], "cap_wheels": ["final", "rollo"], "cap_recipes": ["final", "marlo"], "cap_paste_works": ["final", "marlo"], "cap_untidy": ["final", "fern"],
	"side_s_beef": ["beefcake", "brenda"], "side_s_gour": ["gourmand", "odalys"], "side_s_necro": ["necrocrat", "barnaby"],
	"side_s_ref": ["refusemancer", "marigold"], "side_s_cap": ["final", "kestrel"], "side_s_town": ["town", "elder"],
}
const TARGETS: Dictionary = {
	"dna_backlog": [[QuestObjective.TargetKind.BATTLE, "necrocrat", "", "Roaming staff wander every floor"]],
	"dna_onboarding": [[QuestObjective.TargetKind.SPOT, "necrocrat", "time_clock", "The time clock by the front desk"], [QuestObjective.TargetKind.SPOT, "necrocrat", "coffee", "The breakroom coffee machine"]],
	"dna_audit": [[QuestObjective.TargetKind.NPC, "necrocrat", "quiz", "Director Ectomund, Compliance Examiner"], [QuestObjective.TargetKind.SPOT, "necrocrat", "", "Hidden stashes lurk in the filing mazes"]],
	"gain_power": [[QuestObjective.TargetKind.SPOT, "beefcake", "run_wheel", "The Colossal Hamster Wheel, up the hill"], [QuestObjective.TargetKind.SPOT, "beefcake", "protein_stand", "The protein shake stand in the Swole Station"]],
	"gain_spot_me": [[QuestObjective.TargetKind.NPC, "beefcake", "spot_me", "Gary, under a barbell again. Follow the groaning."], [QuestObjective.TargetKind.SPOT, "beefcake", "flex_mirror", "A Flex Mirror, at the Station or up on Pec Perch"]],
	"gain_lanes": [[QuestObjective.TargetKind.BATTLE, "beefcake", "", "Brutes, golems and sprites roam the open ground"]],
	"buf_pantry": [[QuestObjective.TargetKind.ITEM_COUNT, "gourmand", "", "Truffle by the broccoli, salt by the river, honey up the Butte"]],
	"buf_pie": [[QuestObjective.TargetKind.SPOT, "gourmand", "oven", "The Grand Oven, by the arch"]],
	"buf_mend": [[QuestObjective.TargetKind.SPOT, "gourmand", "old_meatloaf", "Old Meatloaf, by the west wall of the Grand Pantry"]],
	"heap_herd": [[QuestObjective.TargetKind.SPOT, "refusemancer", "", "Escaped animals graze out in the fields"]],
	"heap_fert": [[QuestObjective.TargetKind.ITEM_COUNT, "refusemancer", "", "Try the fields, the east edge and across the stream"]],
	"heap_dam": [[QuestObjective.TargetKind.SPOT, "refusemancer", "stable_2", "The stables: borrow a mount, then charge the dam"]],
	"cap_burial": [[QuestObjective.TargetKind.SPOT, "final", "pickup_stamp", "Grave Row: the stamp lies north of the permit office"], [QuestObjective.TargetKind.SPOT, "final", "pell_plot", "The Pell family plot, at the north end of Grave Row"]],
	"cap_wheels": [[QuestObjective.TargetKind.SPOT, "final", "", "The energy wheels along the Transit Yards wall"], [QuestObjective.TargetKind.SPOT, "final", "cable", "The main power cable, in the Transit Yards"]],
	"cap_recipes": [[QuestObjective.TargetKind.ITEM_COUNT, "final", "", "Recipe cards hidden around the Hungry Quarter"], [QuestObjective.TargetKind.SPOT, "final", "dispenser", "The paste dispenser, in the Hungry Quarter"]],
	"cap_untidy": [[QuestObjective.TargetKind.SPOT, "final", "", "Banished heaps hide in the Reek's cellars and yards"], [QuestObjective.TargetKind.SPOT, "final", "sick_patch", "The Sick Patch in the Reek. Find the jar of old seed first"]],
	"cap_paste_works": [[QuestObjective.TargetKind.SPOT, "final", "paste_works", "The shuttered stall at the Hungry Quarter's south-west corner"], [QuestObjective.TargetKind.SPOT, "final", "paste_works", "Down through the ration hatch"]],
	"side_s_beef": [[QuestObjective.TargetKind.SPOT, "beefcake", "protein_stand", "The protein shake stand in the Swole Station"]],
	"side_s_gour": [[QuestObjective.TargetKind.SPOT, "gourmand", "", "Hidden stashes have no marker: check the odd corners"]],
	"side_s_necro": [[QuestObjective.TargetKind.BATTLE, "necrocrat", "", "Roaming staff wander every floor"]],
	"side_s_ref": [[QuestObjective.TargetKind.BATTLE, "refusemancer", "", "Scavengers prowl the junk heaps"]],
	"side_s_cap": [[QuestObjective.TargetKind.SPOT, "final", "manhole", "The manhole near the gate: knock three times"]],
	"side_s_town": [[QuestObjective.TargetKind.SPOT, "town", "", "A hidden chest in one of Crosspath's odd corners"]],
}
## Quest id -> {"equipment": [ids]} paid on top of the quest's own rewards (Block 2's pieces).
const EXTRA_REWARDS: Dictionary = {"gain_power": {"equipment": ["kettlebell_locket"]}}


static func build_all() -> Array[QuestData]:
	var quests: Array[QuestData] = _build_unpacked()
	for quest: QuestData in quests:
		quest.category = QuestData.Category.SIDE
		if PACK_REWARDS.has(quest.id):
			quest.reward_pack_ids.append(str(PACK_REWARDS[quest.id]))
		var where: Array = GIVERS.get(quest.id, []) as Array
		if where.size() == 2:
			quest.giver_area = str(where[0])
			quest.giver_spot = str(where[1])
			quest.turn_in_area = quest.giver_area
			quest.turn_in_spot = quest.giver_spot
		var targets: Array = TARGETS.get(quest.id, []) as Array
		for index: int in range(mini(targets.size(), quest.objectives.size())):
			var target: Array = targets[index] as Array
			quest.objectives[index].at(int(target[0]) as QuestObjective.TargetKind, str(target[1]), str(target[2]), str(target[3]))
		for extra: Variant in (EXTRA_REWARDS.get(quest.id, {}) as Dictionary).get("equipment", []):
			quest.reward_equipment_ids.append(str(extra))
	return quests


## A zone's three hub favours (its MAIN quest's midpoint is finishing any one of them).
static func favours_of(zone_id: String) -> Array[String]:
	var ids: Array[String] = []
	for quest_id: Variant in FAVOURS.get(zone_id, []) as Array:
		ids.append(str(quest_id))
	return ids


static func _build_unpacked() -> Array[QuestData]:
	return [_backlog(), _onboarding(), _audit(), _gain_power(), _gain_spot_me(), _gain_lanes(), _buf_pantry(), _buf_pie(), _buf_mend(), _heap_herd(), _heap_fert(), _heap_dam()] as Array[QuestData] + capital_quests() + side_quests()


static func _backlog() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = BACKLOG
	quest.order = 110
	quest.title = "Clear the Backlog"
	quest.summary = "Agnes Overdue's backlog has gone feral and is wandering the floors. Process three roaming staff members. By duel. Per policy."
	quest.giver_npc = DnaZone.NPC_DOLORES
	quest.turn_in_npc = DnaZone.NPC_DOLORES
	quest.objectives = [QuestObjective.make("Duel roaming staff on the D.N.A. floors", Condition.counter("zone_enemies_defeated", 3))] as Array[QuestObjective]
	quest.reward_gold = 60
	quest.reward_xp = 60
	quest.reward_item_ids = ["healing_draught"] as Array[String]
	return quest


static func _onboarding() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = ONBOARDING
	quest.order = 120
	quest.title = "Mandatory Onboarding"
	quest.summary = "Gerald says every new hire must complete onboarding, starting at the time clock. HR will know. HR is in the walls."
	quest.giver_npc = DnaZone.NPC_BARNABY
	quest.turn_in_npc = DnaZone.NPC_BARNABY
	quest.objectives = [
		QuestObjective.make("Punch in at the time clock by the front desk", Condition.counter(DnaZone.COUNTER_PUNCHED_IN, 1)),
		QuestObjective.make("Pour a cup at the breakroom coffee machine", Condition.counter(DnaZone.COUNTER_COFFEE, 1)),
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
	quest.summary = "Compliance is auditing and Clerk Ledgerbone can't leave the desk. Start with Director Ectomund's quiz. Bring a spare pen."
	quest.giver_npc = DnaZone.NPC_PIP
	quest.turn_in_npc = DnaZone.NPC_PIP
	quest.objectives = [
		QuestObjective.make("Pass Director Ectomund's Compliance quiz", Condition.flag(str(DnaZone.FLAG_QUIZ_DONE))),
		QuestObjective.make("Find a hidden stash in the filing mazes", Condition.counter(DnaZone.COUNTER_CHESTS, 1)),
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
		QuestObjective.make("Run the Colossal Hamster Wheel up the hill", Condition.flag(str(GainlandsZone.FLAG_WHEEL_POWERED))),
		QuestObjective.make("Buy a protein shake at the Station's stand", Condition.counter(GainlandsZone.COUNTER_SHAKES, 1)),
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
	quest.summary = "Old Man Mountain's rule: nobody lifts alone. Start by spotting Gary. He is under a barbell again."
	quest.giver_npc = GainlandsZone.NPC_BRENDA
	quest.turn_in_npc = GainlandsZone.NPC_BRENDA
	quest.objectives = [
		QuestObjective.make("Spot Gary under his barbell", Condition.flag(str(GainlandsZone.FLAG_SPOTTED))),
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
	quest.summary = "Benchley's protein deliveries keep getting 'inspected' by roaming brutes, golems and sprites. Beat three of them. Deliver the gains."
	quest.giver_npc = GainlandsZone.NPC_TONY
	quest.turn_in_npc = GainlandsZone.NPC_TONY
	quest.objectives = [QuestObjective.make("Beat roaming enemies in the Gainlands", Condition.counter(GainlandsZone.COUNTER_ENEMIES, 3))] as Array[QuestObjective]
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
	quest.summary = "The Grand Pantry is out of everything that matters. Sous-Chef Tarragon needs three ingredients from around the Buffet. Lettuce not panic."
	quest.giver_npc = BuffetZone.NPC_TARRAGON
	quest.turn_in_npc = BuffetZone.NPC_TARRAGON
	quest.objectives = [QuestObjective.make("Gather ingredients around the Buffet", Condition.counter(BuffetZone.COUNTER_GATHERED, 3))] as Array[QuestObjective]
	quest.reward_gold = 60
	quest.reward_xp = 50
	quest.reward_card_ids = ["G-25"] as Array[String]
	return quest


static func _buf_pie() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = BuffetZone.QUEST_PIE
	quest.order = 320
	quest.title = "Bake Me a Pie"
	quest.summary = "Madame Mirepoix wants a Hearty Pot Pie, baked fresh in the Grand Oven from honey, basil and a ghost pepper, and delivered to her counter."
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
	quest.summary = "Old Meatloaf, the Grand Pantry's oldest golem, has stopped working. Basil thinks sea salt and a black truffle will get him back on his loaf."
	quest.giver_npc = BuffetZone.NPC_ODALYS
	quest.turn_in_npc = BuffetZone.NPC_ODALYS
	quest.objectives = [QuestObjective.make("Mend Old Meatloaf with sea salt and a black truffle", Condition.flag(str(BuffetZone.FLAG_MENDED)))] as Array[QuestObjective]
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
	quest.summary = "Three of Wren Muckfoot's animals got out: a goat, a pig and a raccoon with a briefcase. Shoo each one back to the pen before the Rot gets them."
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
	quest.summary = "Granny Gristle is out of fertilizer and the crops are sulking. Gather three sacks from around the Dump. Hold your nose. Hold the sack."
	quest.giver_npc = HeapZone.NPC_HOB
	quest.turn_in_npc = HeapZone.NPC_HOB
	quest.objectives = [QuestObjective.make("Gather fertilizer sacks around the Dump", Condition.counter(HeapZone.COUNTER_FERTILIZER, 3))] as Array[QuestObjective]
	quest.reward_gold = 70
	quest.reward_xp = 60
	quest.reward_card_ids = ["R-25"] as Array[String]
	return quest


static func _heap_dam() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = HeapZone.QUEST_DAM
	quest.order = 430
	quest.title = "Unblock the Stream"
	quest.summary = "Somebody dumped a junk dam across the feeder channel on the north bank. Borrow a mount from the stables and charge it. Brother Bramble's compost boots are the prize."
	quest.giver_npc = HeapZone.NPC_MARIGOLD
	quest.turn_in_npc = HeapZone.NPC_MARIGOLD
	quest.objectives = [QuestObjective.make("Ride a mount into the junk dam on the north bank", Condition.flag("heap_smashed_dam"))] as Array[QuestObjective]
	quest.reward_gold = 80
	quest.reward_xp = 70
	quest.reward_equipment_ids = ["compost_boots"] as Array[String]
	return quest


# ---- The Capital (brief 10): four Path quests, one per Path, given by citizens who show what Primm's perfection cost -------------


static func capital_quests() -> Array[QuestData]:
	return [_cap_burial(), _cap_wheels(), _cap_recipes(), _cap_untidy(), _cap_paste_works()] as Array[QuestData]


static func _cap_burial() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = CapitalZone.QUEST_BURIAL
	quest.order = 510
	quest.title = "Form 27-B/6: A Burial Permit"
	quest.summary = "Widow Pell's husband has sat in the family parlor for three years because his burial permit loops forever. It needs the Stamp of Final Approval, somewhere in Grave Row."
	quest.giver_npc = CapitalZone.NPC_PELL
	quest.turn_in_npc = CapitalZone.NPC_PELL
	quest.objectives = [
		QuestObjective.make("Find the Stamp of Final Approval in Grave Row", Condition.flag(str(CapitalZone.FLAG_STAMP))),
		QuestObjective.make("Lay Mr. Pell to rest at the family plot", Condition.flag(str(CapitalZone.FLAG_LAID_TO_REST))),
	] as Array[QuestObjective]
	quest.reward_gold = 150
	quest.reward_xp = 120
	quest.reward_item_ids = ["healing_draught"] as Array[String]
	quest.reward_card_ids = ["N-28"] as Array[String]
	quest.reward_equipment_ids = ["clerks_stamp"] as Array[String]
	quest.reward_unlock_flags = [str(CapitalZone.insight_flag("necrocrat"))] as Array[String]
	return quest


static func _cap_wheels() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = CapitalZone.QUEST_WHEELS
	quest.order = 520
	quest.title = "The Wheel Never Stops"
	quest.summary = "Beefcake crews have run the facade's energy wheels for ten years because nobody told them they could stop. Go and tell them, in the Transit Yards."
	quest.giver_npc = CapitalZone.NPC_ROLLO
	quest.turn_in_npc = CapitalZone.NPC_ROLLO
	quest.objectives = [
		QuestObjective.make("Free the wheel crews in the Transit Yards", Condition.counter(CapitalZone.COUNTER_WHEELS, 3)),
		QuestObjective.make("Cut the facade's power cable in the Yards", Condition.flag(str(CapitalZone.FLAG_CABLE_CUT))),
	] as Array[QuestObjective]
	quest.reward_gold = 150
	quest.reward_xp = 120
	quest.reward_item_ids = ["vitality_charm"] as Array[String]
	quest.reward_card_ids = ["B-30"] as Array[String]
	quest.reward_equipment_ids = ["iron_knuckles"] as Array[String]
	quest.reward_unlock_flags = [str(CapitalZone.insight_flag("beefcake"))] as Array[String]
	return quest


static func _cap_recipes() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = CapitalZone.QUEST_RECIPES
	quest.order = 530
	quest.title = "The Recipe Box"
	quest.summary = "Everyone eats {villain}'s Perfect Nutrient Paste. Chef Marlo's three real recipes are hidden in the Hungry Quarter. Find them before the inspectors do."
	quest.giver_npc = CapitalZone.NPC_MARLO
	quest.turn_in_npc = CapitalZone.NPC_MARLO
	quest.objectives = [
		QuestObjective.make("Find Chef Marlo's recipe cards in the Hungry Quarter", Condition.counter(CapitalZone.COUNTER_RECIPES, 3)),
		QuestObjective.make("Spoil the paste dispenser in the Hungry Quarter", Condition.flag(str(CapitalZone.FLAG_PASTE_SPOILED))),
	] as Array[QuestObjective]
	quest.reward_gold = 150
	quest.reward_xp = 120
	quest.reward_item_ids = ["hearty_pie"] as Array[String]
	quest.reward_card_ids = ["G-31"] as Array[String]
	quest.reward_equipment_ids = ["pantry_apron"] as Array[String]
	quest.reward_unlock_flags = [str(CapitalZone.insight_flag("gourmand"))] as Array[String]
	return quest


static func _cap_untidy() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = CapitalZone.QUEST_UNTIDY
	quest.order = 540
	quest.title = "Untidy"
	quest.summary = "Composting is outlawed as untidy, and the land is sickening for it. Three banished compost heaps are hiding in the Reek. Rescue them."
	quest.giver_npc = CapitalZone.NPC_FERN
	quest.turn_in_npc = CapitalZone.NPC_FERN
	quest.objectives = [
		QuestObjective.make("Rescue the banished compost heaps in the Reek", Condition.counter(CapitalZone.COUNTER_COMPOST, 3)),
		QuestObjective.make("Plant the old seed in the Sick Patch", Condition.flag(str(CapitalZone.FLAG_SEED_PLANTED))),
	] as Array[QuestObjective]
	quest.reward_gold = 150
	quest.reward_xp = 120
	quest.reward_item_ids = ["healing_salve"] as Array[String]
	quest.reward_card_ids = ["R-30"] as Array[String]
	quest.reward_equipment_ids = ["bin_lid"] as Array[String]
	quest.reward_unlock_flags = [str(CapitalZone.insight_flag("refusemancer"))] as Array[String]
	return quest


## Oct 21: Chef Marlo's second quest, the way into the Paste Works (S-PASTE). No twist in the text: the Colonel is a surprise at the bottom.
static func _cap_paste_works() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = PasteWorks.QUEST_ID
	quest.order = 535
	quest.title = "The Paste Works"
	quest.summary = "The paste comes from somewhere. Chef Marlo thinks the shuttered stall at the Hungry Quarter's south-west corner is a door, and that something real is locked up behind it."
	quest.giver_npc = CapitalZone.NPC_MARLO
	quest.turn_in_npc = CapitalZone.NPC_MARLO
	quest.prerequisite = PasteWorks.prerequisite()
	quest.objectives = [
		QuestObjective.make("Open the shuttered stall in the Hungry Quarter", Condition.flag(str(PasteWorks.FLAG_FOUND))),
		QuestObjective.make("Shut down the Paste Works", Condition.flag(str(PasteWorks.FLAG_CLEARED))),
	] as Array[QuestObjective]
	quest.reward_gold = 200
	quest.reward_xp = 180
	quest.reward_item_ids = ["hearty_pie"] as Array[String]
	return quest


# ---- Side dungeon quests (the dungeon list's quest hooks) -------------------------------------------------------------------
# Each side dungeon is unlocked by a quest from the NPC its hook names; finishing the quest sets `DungeonCatalog.side_unlock_flag(<dungeon id>)`, which opens
# the dungeon's entrance. The hook line of the dungeon list is the quest's summary; the dialogue lives in the dungeon content file (`quest.<id>.*`).

const SIDE_BEEF: String = "side_s_beef"
const SIDE_GOUR: String = "side_s_gour"
const SIDE_NECRO: String = "side_s_necro"
const SIDE_REF: String = "side_s_ref"
const SIDE_CAP: String = "side_s_cap"
const SIDE_TOWN: String = "side_s_town"
## Dungeon ID -> quest id.
const SIDE_QUESTS: Dictionary = {
	"S-BEEF": SIDE_BEEF, "S-GOUR": SIDE_GOUR, "S-NECRO": SIDE_NECRO, "S-REF": SIDE_REF, "S-CAP": SIDE_CAP, "S-TOWN": SIDE_TOWN,
}


static func side_quests() -> Array[QuestData]:
	return [
		_side(SIDE_BEEF, "S-BEEF", 230, "Water for the Hermit", GainlandsZone.NPC_BRENDA, "Old Man Mountain won't show you the way up Mount Swolympus on an empty cup. Bring him a protein shake from the Station's stand.",
			[QuestObjective.make("Buy a protein shake at the Station's stand", Condition.counter(GainlandsZone.COUNTER_SHAKES, 1))], Condition.postgame()),  # Mount Swolympus is a postgame bonus (GC-11): never offered in the main story
		_side(SIDE_GOUR, "S-GOUR", 330, "The Golden Reservation", BuffetZone.NPC_ODALYS, "Basil knows of a golden reservation card: 'Seating: 1. Courses: 3. Survival: optional.' It is in one of the Buffet's hidden stashes.",
			[QuestObjective.make("Find a hidden stash in the Buffet", Condition.counter(BuffetZone.COUNTER_CHESTS, 1))]),
		_side(SIDE_NECRO, "S-NECRO", 140, "Number 4,000,212", DnaZone.NPC_BARNABY, "Gerald is Number 4,000,212 and they are on 3. Thin out the queue to the Waiting Room of Eternity: process two roaming staff.",
			[QuestObjective.make("Duel roaming staff on the D.N.A. floors", Condition.counter("zone_enemies_defeated", 2))]),
		_side(SIDE_REF, "S-REF", 240, "Who Ate the Compost?", HeapZone.NPC_MARIGOLD, "Little paw prints, a tiny crown, and no compost. Drive off two scavengers to follow the trail.",
			[QuestObjective.make("Drive off scavengers in the Dump", Condition.counter(HeapZone.COUNTER_ENEMIES, 2))]),
		_side(SIDE_CAP, "S-CAP", 360, "The Older Way", CapitalZone.NPC_KESTREL, "Kestrel knows an older way into the city. Get inside, find Wren in the Crease and ask her about the old tunnels.",
			[QuestObjective.make("Reach the Crease: knock at the manhole by the gate", Condition.flag(str(CapitalZone.FLAG_HUB_KNOWN)))]),
		_side(SIDE_TOWN, "S-TOWN", 90, "The Door Under the Well", "Elder Maren", "Elder Maren says the door under the Old Well has been locked since before she was born. Its key is in a hidden chest somewhere in Crosspath.",
			[QuestObjective.make("Find the hidden chest in Crosspath", Condition.secret_found("harbor_chest"))], QuestDefinitions.story_gate()),  # Oct 20: after the armory quest
	] as Array[QuestData]


static func _side(quest_id: String, dungeon_id: String, order: int, title: String, giver: String, summary: String, objectives: Array[QuestObjective], prerequisite: Condition = null) -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.prerequisite = prerequisite
	quest.id = quest_id
	quest.order = order
	quest.title = title
	quest.summary = summary
	quest.giver_npc = giver
	quest.turn_in_npc = giver
	quest.objectives = objectives
	quest.reward_gold = 40
	quest.reward_xp = 30
	quest.reward_unlock_flags = [str(DungeonCatalog.side_unlock_flag(dungeon_id))] as Array[String]
	return quest
