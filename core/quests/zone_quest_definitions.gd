class_name ZoneQuestDefinitions
extends RefCounted
## Quests given by NPCs inside zones - the three D.N.A. hub quests. Each is offered by, and handed
## in to, the same hub NPC (see TownScene/DnaScene `_talk_quest_npc`). Dialogue for them lives in
## ZoneStoryText ("quest.<id>.offer/active/ready/done").

const BACKLOG: String = "dna_backlog"
const ONBOARDING: String = "dna_onboarding"
## Nov 18 day (Part 4.4): Kyle's quest (it replaced his Rec Room matching game).
const HALL_MONITOR: String = "dna_hall_monitor"
const AUDIT: String = "dna_audit"


## Brief 11: which quests also pay a Path Pack (quest id -> pack id): one per zone since Oct 16 (the zone's MAIN line pays two more), plus a minigame prize each (`ZoneDef.minigame_pack`).
## All numbers/ids are placeholders: edit here (then regenerate the quest files) or in `data/quests/*.tres`.
const PACK_REWARDS: Dictionary = {
	"dna_audit": "path_necrocrat", "dna_hall_monitor": "gilded_necrocrat", "side_s_necro": "path_necrocrat", "gain_spot_me": "path_beefcake", "buf_mend": "path_gourmand", "heap_dam": "path_refusemancer",
}


## Overnight Oct 16: each zone's three hub favours (the zone MAIN quest's midpoint), where every NPC quest's giver stands (area, spot id; the
## giver also takes it back), each objective's target ([kind, area, spot id, where-to-go hint]; "" spot = no world marker) and extra rewards.
const FAVOURS: Dictionary = {
	"beefcake": ["gain_power", "gain_spot_me", "gain_lanes"], "necrocrat": ["dna_backlog", "dna_onboarding", "dna_audit"],
	"gourmand": ["buf_pantry", "buf_pie", "buf_mend"], "refusemancer": ["heap_herd", "heap_fert", "heap_dam"],
}
const GIVERS: Dictionary = {
	"dna_backlog": ["necrocrat", "dolores"], "dna_hall_monitor": ["necrocrat", "matching"], "dna_onboarding": ["necrocrat", "barnaby"], "dna_audit": ["necrocrat", "pip"],
	"gain_power": ["beefcake", "gus"], "gain_spot_me": ["beefcake", "brenda"], "gain_lanes": ["beefcake", "tony"],
	"buf_pantry": ["gourmand", "tarragon"], "buf_pie": ["gourmand", "dolcetta"], "buf_mend": ["gourmand", "odalys"],
	"heap_herd": ["refusemancer", "wren"], "heap_fert": ["refusemancer", "hob"], "heap_dam": ["refusemancer", "marigold"],
	"cap_burial": ["final", "pell"], "cap_wheels": ["final", "rollo"], "cap_recipes": ["final", "marlo"], "cap_paste_works": ["final", "marlo"], "cap_untidy": ["final", "fern"],
	"side_s_beef": ["beefcake", "brenda"], "side_s_gour": ["gourmand", "odalys"], "side_s_necro": ["necrocrat", "barnaby"],
	"side_s_ref": ["refusemancer", "marigold"], "side_s_cap": ["final", "kestrel"], "side_s_town": ["town", "elder"],
	"cracks_in_the_glass": ["final", "wren"],
}
const TARGETS: Dictionary = {
	"dna_backlog": [[QuestObjective.TargetKind.BATTLE, "necrocrat", "", "Roaming staff wander every floor"]],
	"dna_hall_monitor": [[QuestObjective.TargetKind.BATTLE, "necrocrat", "", "Cubicle Farm A and the Filing Department: the D.N.A.'s west wing, around Kyle's Rec Room"]],
	"dna_onboarding": [[QuestObjective.TargetKind.SPOT, "necrocrat", "time_clock", "The time clock by the front desk"], [QuestObjective.TargetKind.SPOT, "necrocrat", "coffee", "The breakroom coffee machine"]],
	"dna_audit": [[QuestObjective.TargetKind.NPC, "necrocrat", "quiz", "Director Ectomund, Compliance Examiner"], [QuestObjective.TargetKind.SPOT, "necrocrat", "", "Hidden stashes lurk in the filing mazes"]],
	"gain_power": [[QuestObjective.TargetKind.SPOT, "beefcake", "run_wheel", "The Colossal Hamster Wheel, up the hill"], [QuestObjective.TargetKind.SPOT, "beefcake", "protein_stand", "The protein shake stand in the Swole Station"]],
	"gain_spot_me": [[QuestObjective.TargetKind.NPC, "beefcake", "spot_me", "Gary, under a barbell again. Follow the groaning."], [QuestObjective.TargetKind.SPOT, "beefcake", "flex_mirror", "A Flex Mirror, at the Station or up on Pec Perch"]],
	"gain_lanes": [[QuestObjective.TargetKind.BATTLE, "beefcake", "", "Brutes, golems and sprites roam the open ground"]],
	"buf_pantry": [[QuestObjective.TargetKind.ITEM_COUNT, "gourmand", "", "Truffle by the broccoli, salt by the river, honey up the Butte"]],
	"buf_pie": [[QuestObjective.TargetKind.SPOT, "gourmand", "oven", "The Grand Oven, by the arch"]],
	"buf_mend": [[QuestObjective.TargetKind.SPOT, "gourmand", "old_meatloaf", "Black truffle under the Broccoli Forest's trees (south-west), sea salt on the Salt Flats by the river; then Old Meatloaf, by the west wall of the Grand Pantry"]],  # Nov 9-10 (mid critic #2)
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
	"side_s_necro": [[QuestObjective.TargetKind.SPOT, "necrocrat", "mini_dungeon", "The lit elevator in the Elevator Bank, north of the Mail Room (follow the red runner)"],
		[QuestObjective.TargetKind.SPOT, "necrocrat", "mini_dungeon", "Down the lit elevator in the Elevator Bank"]],
	"side_s_ref": [[QuestObjective.TargetKind.BATTLE, "refusemancer", "", "Scavengers prowl the junk heaps"]],
	"side_s_cap": [[QuestObjective.TargetKind.SPOT, "final", "manhole", "The manhole near the gate: knock three times"]],
	# Fable Nov 20 (Part 4.1): the chest is marked and said in words (it had no marker and "somewhere in Crosspath" for a hint)
	"side_s_town": [[QuestObjective.TargetKind.SPOT, "town", QuestMarkers.SPOT_HARBOR_CHEST, "The big chest on the little spit of land at the east edge of town: follow the lane east past the Rift Express stop until it meets the water"]],
	"cracks_in_the_glass": [[QuestObjective.TargetKind.SPOT, "final", "gallery_mirror", "The cracked mirror beside the castle door"]],
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
		_add_parts(quest)
	return quests


## Fable pass Nov 10 (Part 1.1): the steps with several things to find mark each of them (`QuestObjective.part`), and a part's marker drops
## once that thing is in hand. Steps that count roaming enemies mark every live roamer of the zone (`QuestMarkers.SPOT_ROAMERS`); steps that
## want a hidden stash mark every stash still shut (`QuestMarkers.SPOT_CHESTS`).
static func _add_parts(quest: QuestData) -> void:
	var kind_item: QuestObjective.TargetKind = QuestObjective.TargetKind.ITEM_COUNT
	var kind_spot: QuestObjective.TargetKind = QuestObjective.TargetKind.SPOT
	var kind_battle: QuestObjective.TargetKind = QuestObjective.TargetKind.BATTLE
	match quest.id:
		BuffetZone.QUEST_MEND:
			quest.objectives[0].part(kind_item, BuffetZone.ID, "pickup_sea_salt", "Sea Salt Crystals (the Salt Flats, by the river)", Condition.counter(BuffetZone.stock_key("sea_salt"), 1)) \
				.part(kind_item, BuffetZone.ID, "pickup_truffle", "Black Truffle (under the Broccoli Forest's trees, south-west)", Condition.counter(BuffetZone.stock_key("truffle"), 1)) \
				.part(kind_spot, BuffetZone.ID, "old_meatloaf", "Old Meatloaf (the Grand Pantry's west wall)")
		BuffetZone.QUEST_PANTRY:
			for ingredient_id: String in BuffetZone.INGREDIENTS.keys():
				quest.objectives[0].part(kind_item, BuffetZone.ID, "pickup_" + ingredient_id, str(BuffetZone.INGREDIENTS[ingredient_id]), Condition.counter(BuffetZone.stock_key(ingredient_id), 1))
		HALL_MONITOR:
			quest.objectives[0].part(kind_battle, DnaZone.ID, QuestMarkers.SPOT_ROAMERS_WEST, "Roaming staff in the west wing")
		"gain_spot_check", "buf_leftovers", "heap_pest_control", "cap_patrol_thinning", "town_outskirts_watch":
			quest.objectives[0].part(kind_battle, quest.giver_area, QuestMarkers.SPOT_ROAMERS, "A roamer that counts (any)")
		BACKLOG:
			quest.objectives[0].part(kind_battle, DnaZone.ID, QuestMarkers.SPOT_ROAMERS, "Roaming staff (any)")
		AUDIT:
			quest.objectives[1].part(kind_spot, DnaZone.ID, QuestMarkers.SPOT_CHESTS, "A hidden stash (any)")
		GainlandsZone.QUEST_LANES:
			quest.objectives[0].part(kind_battle, GainlandsZone.ID, QuestMarkers.SPOT_ROAMERS, "Roaming brutes and golems (any)")
		HeapZone.QUEST_HERD:
			for number: int in range(1, HeapGrowth.ESCAPED_ANIMALS + 1):
				quest.objectives[0].part(kind_spot, HeapZone.ID, "animal_%d" % number, "An escaped animal")
		HeapZone.QUEST_FERT:
			for number: int in range(1, 4):
				quest.objectives[0].part(kind_item, HeapZone.ID, "pickup_fert_%d" % number, "Sack of Fertilizer")
		SIDE_REF:
			quest.objectives[0].part(kind_battle, HeapZone.ID, QuestMarkers.SPOT_ROAMERS, "Scavengers (any)")
		SIDE_GOUR:
			quest.objectives[0].part(kind_spot, BuffetZone.ID, QuestMarkers.SPOT_CHESTS, "A hidden stash (any)")
		SIDE_TOWN:
			quest.objectives[0].part(kind_spot, "town", QuestMarkers.SPOT_HARBOR_CHEST, "The big chest on the spit of land (east edge of town)")
		CapitalZone.QUEST_WHEELS:
			for number: int in range(1, 4):
				quest.objectives[0].part(kind_spot, CapitalZone.ID, "wheel_%d" % number, "Energy Wheel %d" % number, Condition.secret_found(CapitalZone.secret_id("wheel", str(number))))
		CapitalZone.QUEST_RECIPES:
			for number: int in range(1, 4):
				quest.objectives[0].part(kind_item, CapitalZone.ID, "pickup_recipe_%d" % number, "A hidden recipe card", Condition.secret_found(CapitalZone.secret_id("pick", "recipe_%d" % number)))
		CapitalZone.QUEST_UNTIDY:
			for number: int in range(1, 4):
				quest.objectives[0].part(kind_spot, CapitalZone.ID, "pickup_heap_%d" % number, "A banished compost heap", Condition.secret_found(CapitalZone.secret_id("pick", "heap_%d" % number)))


## A zone's three hub favours (its MAIN quest's midpoint is finishing any one of them).
static func favours_of(zone_id: String) -> Array[String]:
	var ids: Array[String] = []
	for quest_id: Variant in FAVOURS.get(zone_id, []) as Array:
		ids.append(str(quest_id))
	return ids


static func _build_unpacked() -> Array[QuestData]:
	return [_backlog(), _onboarding(), _audit(), _hall_monitor(), _gain_power(), _gain_spot_me(), _gain_lanes(), _buf_pantry(), _buf_pie(), _buf_mend(), _heap_herd(), _heap_fert(), _heap_dam()] as Array[QuestData] + capital_quests() + side_quests() + defeat_three_quests()


# ---- Nov 18 evening (Part 3): "defeat three" in every zone -------------------------------------------------------------------------

## A quest like Kyle's "Hall Monitor" in every zone with roaming enemies (the D.N.A.'s is Kyle's own; Crosspath's outskirts have three
## roamers, so it has one too; the Opening Forest has none): beat three of the area's ORDINARY roamers - not the hazards that only hurt on
## contact (sprites, meatballs, gulls, Tidy-Bots, shard swarms, couriers), not the elites or bosses (Colonel Casserole, Captain Spotless, the
## foes that block a way). The count starts at 0/3 when the quest is taken (`defeat_three_counter` only moves while it is active), the map,
## the minimap and the world mark only those roamers (`is_ordinary`). Reward: a Gilded pack (the zone's Path; a General gilded pack in the
## Capital and Crosspath) plus gold and experience on Hall Monitor's scale for the zone's level. One time only; a side quest.
const DEFEAT_THREE: Dictionary = {
	"beefcake": {"id": "gain_spot_check", "title": "Spot Check", "spot": "gus", "pack": "gilded_beefcake", "gold": 150, "xp": 50, "order": 236,
		"step": "Beat roaming brutes and golems in the Gainlands", "where": "Brutes and golems roam the open ground (the sprites only bump into you)",
		"summary": "The regime's brutes and golems keep 'spotting' Foreman Gus's crew off the wheels. Beat three of them."},
	"gourmand": {"id": "buf_leftovers", "title": "Leftovers", "spot": "tarragon", "pack": "gilded_gourmand", "gold": 260, "xp": 100, "order": 336,
		"step": "Beat roaming meatloaf golems and gelatin sentinels in the Buffet", "where": "Meatloaf golems and gelatin sentinels roam the Buffet (the meatballs only roll into you)",
		"summary": "The roaming dishes have gone off the menu and are chasing the staff. Send three of them back to the kitchen for Sous-Chef Tarragon."},
	"refusemancer": {"id": "heap_pest_control", "title": "Pest Control", "spot": "wren", "pack": "gilded_refusemancer", "gold": 300, "xp": 115, "order": 436,
		"step": "Beat roaming trash golems and scarecrows in the Dump", "where": "Trash golems and scarecrows roam the fields and heaps (the gull flocks only dive at you)",
		"summary": "The Dump's golems and scarecrows keep frightening Billie Muckfoot's animals. See off three of them."},
	"final": {"id": "cap_patrol_thinning", "title": "Thin the Patrols", "spot": "kestrel", "pack": "gilded_general", "gold": 350, "xp": 135, "order": 536,
		"step": "Beat roaming officers, inspectors and rift wretches in the Capital", "where": "Correction Officers, Perfection Inspectors and Rift Wretches patrol the Capital (Tidy-Bots and shard swarms only clip you)",
		"summary": "Too many patrols on Kestrel's streets, and they have started reading her chalk marks. Beat three of them."},
	"town": {"id": "town_outskirts_watch", "title": "Outskirts Watch", "spot": "guard", "pack": "gilded_general", "gold": 90, "xp": 35, "order": 96,
		"step": "Beat roamers on Crosspath's outskirts", "where": "A hound on the north lane, a lost clerk on the west road, a raccoon by the harbour (they come back after a while)",
		"summary": "Something keeps frightening travellers on Crosspath's outskirts lanes. Gatekeeper Brannoch wants three of the roamers seen off."},
}
## The ordinary roaming enemies of each area (the ones "defeat three" quests count and mark).
const ORDINARY_ROAMERS: Dictionary = {
	"beefcake": ["brute", "golem"], "necrocrat": ["manager", "intern"], "gourmand": ["loaf", "jelly"], "refusemancer": ["golem", "scarecrow"],
	"final": ["officer", "inspector", "wretch"], "town": ["hound", "clerk", "raccoon"],
}
const DEFEAT_THREE_GIVERS: Dictionary = {
	"beefcake": GainlandsZone.NPC_GUS, "gourmand": BuffetZone.NPC_TARRAGON, "refusemancer": HeapZone.NPC_WREN, "final": CapitalZone.NPC_KESTREL, "town": QuestDefinitions.BRANNOCH,
}


## The "defeat three" quest of a zone ({} for none; the D.N.A.'s is Kyle's Hall Monitor).
static func defeat_three_for(zone_id: String) -> Dictionary:
	return DEFEAT_THREE.get(zone_id, {}) as Dictionary


static func defeat_three_counter(zone_id: String) -> String:
	return "defeat3:%s" % zone_id


## True for an ordinary roamer of the area: a duel foe of its everyday types, not a hazard, an elite, a boss or a foe that blocks a way.
static func is_ordinary(zone_id: String, enemy_type: String, instance_id: String = "") -> bool:
	if not (ORDINARY_ROAMERS.get(zone_id, []) as Array).has(enemy_type):
		return false
	return instance_id == "" or BossBlockers.flag_for(zone_id, instance_id) == &""


static func defeat_three_quests() -> Array[QuestData]:
	var quests: Array[QuestData] = []
	for zone_id: String in DEFEAT_THREE.keys():
		var spec: Dictionary = DEFEAT_THREE[zone_id]
		var quest: QuestData = QuestData.new()
		quest.id = str(spec["id"])
		quest.order = int(spec["order"])
		quest.title = str(spec["title"])
		quest.summary = str(spec["summary"])
		quest.giver_npc = str(DEFEAT_THREE_GIVERS[zone_id])
		quest.turn_in_npc = quest.giver_npc
		quest.giver_area = zone_id
		quest.giver_spot = str(spec["spot"])
		quest.turn_in_area = zone_id
		quest.turn_in_spot = quest.giver_spot
		var step: QuestObjective = QuestObjective.make(str(spec["step"]), Condition.counter(defeat_three_counter(zone_id), 3))
		step.at(QuestObjective.TargetKind.BATTLE, zone_id, "", str(spec["where"]))
		quest.objectives = [step] as Array[QuestObjective]
		quest.reward_gold = int(spec["gold"])
		quest.reward_xp = int(spec["xp"])
		quest.reward_pack_ids = [str(spec["pack"])] as Array[String]
		if zone_id == "town":
			quest.prerequisite = QuestDefinitions.story_gate()  # after Maren's welcome: the first hour keeps its errands
		quests.append(quest)
	return quests


static func _backlog() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = BACKLOG
	quest.order = 110
	quest.title = "Clear the Backlog"
	quest.summary = "Agnes Overdue's backlog has gone feral and is wandering the floors. Process three roaming staff members: by duel, per policy."
	quest.giver_npc = DnaZone.NPC_DOLORES
	quest.turn_in_npc = DnaZone.NPC_DOLORES
	quest.objectives = [QuestObjective.make("Duel roaming staff on the D.N.A. floors", Condition.counter("zone_enemies_defeated", 3))] as Array[QuestObjective]
	quest.reward_gold = 60
	quest.reward_xp = 60
	quest.reward_item_ids = ["energy_draught"] as Array[String]
	return quest


## Nov 18 day (Part 4.4): Kyle's quest, at his Rec Room corner. The roamers of his wing (Cubicle Farm A and the Filing Department) keep him
## from his old television; beat three. It replaced his matching game and pays a little more than its first win did (210 gold, 70 XP,
## a Path Pack): a Gilded Necrocrat Pack, 220 gold and 80 XP.
static func _hall_monitor() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = HALL_MONITOR
	quest.order = 125
	quest.title = "Hall Monitor"
	quest.summary = "Kyle's corner of the floor has gone rowdy: the roaming staff of Cubicle Farm A and the Filing Department keep him from his old television. Beat three of them."
	quest.giver_npc = DnaZone.NPC_KYLE
	quest.turn_in_npc = DnaZone.NPC_KYLE
	quest.objectives = [QuestObjective.make("Beat roaming staff in the west wing (Cubicle Farm A, the Filing Department)", Condition.counter(DnaZone.COUNTER_WEST_WING, 3))] as Array[QuestObjective]
	quest.reward_gold = 220
	quest.reward_xp = 80
	return quest


static func _onboarding() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = ONBOARDING
	quest.order = 120
	quest.title = "Mandatory Onboarding"
	quest.summary = "Gerald says every new hire must complete onboarding, starting at the time clock, because HR will know. HR is in the walls."
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
	quest.summary = "Old Meatloaf, the Grand Pantry's oldest golem, has stopped working. Basil thinks sea salt and a black truffle will get him back on his loaf. Needed for the gate: Sir Loin opens the way to Layer-Cake Town and the Test Kitchen for a mended loaf."
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
	quest.summary = "Three of Billie Muckfoot's animals got out: a goat, a pig and a raccoon with a briefcase. Shoo each one back to the pen before the Rot gets them."
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
	quest.summary = "Granny Gristle is out of fertilizer and the crops are sulking. Gather three sacks from around the Dump, and hold your nose while you do."
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
	quest.summary = "Widow Pell's husband has sat in the family parlour for three years because his burial permit loops forever. It needs the Stamp of Final Approval, somewhere in Grave Row."
	quest.giver_npc = CapitalZone.NPC_PELL
	quest.turn_in_npc = CapitalZone.NPC_PELL
	quest.objectives = [
		QuestObjective.make("Find the Stamp of Final Approval in Grave Row", Condition.flag(str(CapitalZone.FLAG_STAMP))),
		QuestObjective.make("Lay Mr. Pell to rest at the family plot", Condition.flag(str(CapitalZone.FLAG_LAID_TO_REST))),
	] as Array[QuestObjective]
	quest.reward_gold = 150
	quest.reward_xp = 120
	quest.reward_item_ids = ["energy_draught"] as Array[String]
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
const SIDE_GALLERY: String = ShatteredGallery.QUEST_ID
## Dungeon ID -> quest id.
const SIDE_QUESTS: Dictionary = {
	"S-BEEF": SIDE_BEEF, "S-GOUR": SIDE_GOUR, "S-NECRO": SIDE_NECRO, "S-REF": SIDE_REF, "S-CAP": SIDE_CAP, "S-TOWN": SIDE_TOWN,
	"S-GALLERY": SIDE_GALLERY,
}


static func side_quests() -> Array[QuestData]:
	return [
		_side(SIDE_BEEF, "S-BEEF", 230, "Only the Worthy...", GainlandsZone.NPC_BRENDA, "With Primm gone, Old Man Mountain will open the gate to Mount Swolympus. Only for the worthy. The worthy bring him a protein shake from the Station's stand.",
			[QuestObjective.make("Buy a protein shake at the Station's stand", Condition.counter(GainlandsZone.COUNTER_SHAKES, 1))], Condition.postgame()),  # Mount Swolympus is a postgame bonus (GC-11); handing it in opens the gate and the ridge (Fix pass Nov 4 (B), Part 1.2)
		_side(SIDE_GOUR, "S-GOUR", 330, "The Golden Reservation", BuffetZone.NPC_ODALYS, "Basil knows of a golden reservation card: 'Seating: 1. Courses: 3. Survival: optional.' It is in one of the Buffet's hidden stashes.",
			[QuestObjective.make("Find a hidden stash in the Buffet", Condition.counter(BuffetZone.COUNTER_CHESTS, 1))]),
		_take_a_number(),
		_side(SIDE_REF, "S-REF", 240, "Who Ate the Compost?", HeapZone.NPC_MARIGOLD, "Little paw prints, a tiny crown, and no compost. Drive off two scavengers to follow the trail.",
			[QuestObjective.make("Drive off scavengers in the Dump", Condition.counter(HeapZone.COUNTER_ENEMIES, 2))]),
		_side(SIDE_CAP, "S-CAP", 360, "The Older Way", CapitalZone.NPC_KESTREL, "Kestrel only shows her older way into the city to friends of Wren's. Get through the gate, knock at the manhole and ask Wren in the Crease about the old tunnels.",
			[QuestObjective.make("Reach the Crease: knock at the manhole by the gate", Condition.flag(str(CapitalZone.FLAG_HUB_KNOWN)))]),
		_side(SIDE_TOWN, "S-TOWN", 90, "The Door Under the Well", "Elder Maren", "Elder Maren says the door under the Old Well has been locked since before she was born. Its key is in the big chest on the spit of land at the east edge of town, past the Rift Express stop. Open the chest, then bring her the key.",
			# Oct 20: after the armory quest. Fable pass Nov 10: the chest is the original giant chest by the harbour (brief 16 renamed its secret
			# to NinjaBoss.secret_id("town"); the old "harbor_chest" id still counts for saves from before that).
			[QuestObjective.make("Open the big chest by the water, east of the Rift Express stop", Condition.any_of([Condition.secret_found("harbor_chest"), Condition.secret_found(NinjaBoss.secret_id(NinjaBoss.ORIGINAL_CHEST))] as Array[Condition]))], QuestDefinitions.story_gate()),
		_gallery_quest(),
		_gallery_line(),
	] as Array[QuestData] + way_in_quests()


# ---- Fable Nov 20 (Part 4.3): sealed entrances say who to ask, and an opened side dungeon is a tracked step ---------------------------

## Dungeon id -> what a sealed entrance says: [what the entrance is called there, where its quest giver stands]. The giver is the side
## quest's own (`SIDE_QUESTS`), so the message always points at the quest that opens the door.
const SEALED_PLACES: Dictionary = {
	"S-REF": ["The landfill", "the stream in the Verdant Dump"],
	"S-GOUR": ["The freezer", "the Grand Pantry"],
	"S-NECRO": ["The Waiting Room's elevator", "the breakroom coffee bar"],
	"S-BEEF": ["The trail up Mount Swolympus", "the Swole Station"],
	"S-CAP": ["The tunnel mouth", "the road outside the Capital's gate"],
	"S-TOWN": ["The hatch", "the north end of Crosspath"],
	"S-GALLERY": ["The cracked mirror", "the Crease, under the Capital"],
}


## "The landfill is sealed. Talk to Brother Bramble at the stream in the Verdant Dump; they may know more." Never "???", never the hook.
static func sealed_message(dungeon_id: String) -> String:
	var place: Array = SEALED_PLACES.get(dungeon_id, ["This way", ""]) as Array
	var quest: QuestData = QuestCatalog.find(str(SIDE_QUESTS.get(dungeon_id, "")))
	if quest == null or quest.giver_npc.is_empty():
		return "%s is sealed." % str(place[0])
	var where: String = str(place[1])
	return "%s is sealed. Talk to %s%s; they may know more." % [str(place[0]), quest.giver_npc, "" if where.is_empty() else " at " + where]


## Once a side quest is handed in its dungeon is open, and nothing sent the player there. Each such dungeon now has a one-step quest that
## starts by itself at that moment, with the entrance on the tracker, the map and in the world: [title, summary, step, area, spot, where].
## (The Waiting Room, the Paste Works and the Shattered Gallery already carry their own "clear it" steps.)
const WAY_IN: Dictionary = {
	"S-TOWN": ["Under the Old Well", "Elder Maren has the old key and the iron hatch beside the Old Well is open. Whatever is under it belonged to the Old Kingdom.",
		"Go down the iron hatch beside the Old Well and clear what is under it", "town", "well_door", "The iron hatch beside the Old Well, west of the market square"],
	"S-REF": ["Little Paw Prints", "The trail of paw prints and crumbs of compost ends at the landfill, and its way down is open now.",
		"Climb into the landfill and find who ate the compost", "refusemancer", "mini_dungeon", "The landfill's mouth in the Verdant Dump (marked on the map)"],
	"S-GOUR": ["Seating: 1", "The golden reservation card opens the walk-in freezer's door. Seating: 1. Courses: 3. Survival: optional.",
		"Open the freezer door and keep your reservation", "gourmand", "mini_dungeon", "The walk-in freezer's door in the Endless Buffet (marked on the map)"],
	"S-CAP": ["The Older Way In", "Kestrel has shown you the mouth of the old service tunnels: an older way into the city that nobody remembers.",
		"Go through the Old Service Tunnels", "final", "old_tunnels", "The tunnel mouth outside the Capital's wall (marked on the map)"],
	"S-BEEF": ["Only the Worthy Climb", "Old Man Mountain has opened the gate. The trail up Mount Swolympus starts at the far end of the ridge.",
		"Climb Mount Swolympus", "beefcake", GainlandsZone.SWOLYMPUS_TRAIL, "Through the open gate at the overlook, at the far end of the ridge"],
}


static func way_in_id(dungeon_id: String) -> String:
	return "way_in_" + dungeon_id.to_lower().replace("-", "_")


static func way_in_quests() -> Array[QuestData]:
	var result: Array[QuestData] = []
	for dungeon_id: String in WAY_IN.keys():
		var row: Array = WAY_IN[dungeon_id] as Array
		var quest: QuestData = QuestData.new()
		quest.id = way_in_id(dungeon_id)
		quest.category = QuestData.Category.SIDE
		quest.title = str(row[0])
		quest.summary = str(row[1])
		quest.auto_give = true
		quest.prerequisite = Condition.quest_completed(str(SIDE_QUESTS[dungeon_id]))
		quest.objectives = [
			QuestObjective.make(str(row[2]), Condition.flag(str(SignatureCards.cleared_flag(dungeon_id))))
				.at(QuestObjective.TargetKind.DUNGEON, str(row[3]), str(row[4]), str(row[5])),
		] as Array[QuestObjective]
		quest.reward_gold = 30
		quest.reward_xp = 20
		quest.order = WAY_IN_ORDER + result.size()
		result.append(quest)
	return result


const WAY_IN_ORDER: int = 372


## Fix pass Nov 7 (item 14, C5 F4): the Shattered Gallery's own line in the postgame - given at once, with a pin at every step: find Wren in
## the Crease, look into the cracked mirror at the castle door (Wren's "Cracks in the Glass" opens the glass), clear the Gallery.
const GALLERY_LINE: String = "the_shattered_gallery"


static func _gallery_line() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = GALLERY_LINE
	quest.category = QuestData.Category.SIDE
	quest.order = 369
	quest.title = "The Shattered Gallery"
	quest.summary = "Something is wrong with the mirrors in the Capital. Wren and the resistance keep watch from the Crease, under the city; she will know what it is."
	quest.auto_give = true
	quest.prerequisite = Condition.postgame()
	quest.objectives = [
		QuestObjective.make("Find Wren in the Crease: knock at the manhole on the Gate Plaza", Condition.any_of([Condition.flag(str(CapitalZone.FLAG_HUB_KNOWN)), Condition.flag(ShatteredGallery.FLAG_MIRROR_SEEN)] as Array[Condition]))
			.at(QuestObjective.TargetKind.SPOT, CapitalZone.ID, "manhole", "The suspicious manhole on the Gate Plaza, inside the Capital's wall"),
		QuestObjective.make("Look into the cracked mirror by the castle door", Condition.flag(ShatteredGallery.FLAG_MIRROR_SEEN))
			.at(QuestObjective.TargetKind.SPOT, CapitalZone.ID, "gallery_mirror", "Beside the castle door, at the top of the Palace Approach"),
		QuestObjective.make("Clear the Shattered Gallery", Condition.flag(str(ShatteredGallery.FLAG_CLEARED)))
			.at(QuestObjective.TargetKind.DUNGEON, CapitalZone.ID, "gallery_mirror", "Through the cracked mirror by the castle door"),
	] as Array[QuestObjective]
	quest.reward_gold = 150
	quest.reward_xp = 150
	return quest


## Overnight Nov 4-5, Part 5: Wren's postgame errand. Looking into the cracked mirror at the castle door finishes it (no hand-in) and opens
## The Shattered Gallery (S-GALLERY); the mirror itself starts the quest for a player who never asked Wren.
static func _gallery_quest() -> QuestData:
	var quest: QuestData = _side(SIDE_GALLERY, ShatteredGallery.DUNGEON_ID, 370, "Cracks in the Glass", CapitalZone.NPC_WREN,
		"Wren says one of the mirrors at the castle door has cracked from the inside, and it is still showing a kingdom that never was. Go and look.",
		[QuestObjective.make("Look into the cracked mirror at the castle door", Condition.flag(ShatteredGallery.FLAG_MIRROR_SEEN))], Condition.postgame())
	quest.turn_in_npc = ""
	quest.reward_gold = 60
	quest.reward_xp = 60
	return quest


## Nov 18 evening (Part 1.6): "Take a Number" - the Waiting Room of Eternity (S-NECRO) as a real, tracked quest. It was Gerald's
## "Number 4,000,212" (process two roaming staff to unseal the door), which never sent anyone to the dungeon itself; it is the same quest
## (same id, same giver) with new steps: find the lit elevator in the Elevator Bank, then clear the Waiting Room. Accepting it unseals the
## door (`OPEN_ON_ACCEPT`). Its reward fits a three-fight side dungeon with a boss: gold, experience and a Necrocrat Path Pack.
const OPEN_ON_ACCEPT: Dictionary = {"S-NECRO": "side_s_necro"}
const TAKE_A_NUMBER_GOLD: int = 260
const TAKE_A_NUMBER_XP: int = 120


static func _take_a_number() -> QuestData:
	var quest: QuestData = _side(SIDE_NECRO, "S-NECRO", 140, "Take a Number", DnaZone.NPC_BARNABY,
		"Gerald is Number 4,000,212 and they are on 3. The Waiting Room of Eternity is down the lit elevator in the Elevator Bank: find it, then fight your way to the front of the line.",
		[QuestObjective.make("Find the Waiting Room of Eternity (the lit elevator in the Elevator Bank)", Condition.flag(str(DnaZone.FLAG_WAITING_ROOM_FOUND))),
			QuestObjective.make("Clear the Waiting Room of Eternity", Condition.flag(str(DnaZone.FLAG_MINI_DUNGEON_CLEARED)))] as Array[QuestObjective])
	quest.reward_gold = TAKE_A_NUMBER_GOLD
	quest.reward_xp = TAKE_A_NUMBER_XP
	return quest


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
