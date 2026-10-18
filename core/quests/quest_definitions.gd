class_name QuestDefinitions
extends RefCounted
## Authoring source for every quest (`QuestCatalog` builds them at start-up). Dialogue spoken by quest givers lives in the story files
## (`StoryText` "quest.<id>.*", `ZoneStoryText`), not here. Overnight Oct 16: every quest has a category; each Path zone has one MAIN quest line
## (the gatekeeper, crossing in, a favour for the locals, the main dungeon) that pays a Path Pack at its gatekeeper and at its dungeon and a
## piece of equipment at its midpoint; Gatekeeper Brannoch gives "Free the Four Zones" on the Capital road. Reward table: docs/design/quests.md.

const MERCHANTS: String = "meet_the_merchants"
const FREE_ZONES: String = "free_the_kingdom"
## Retired Oct 16 (the four gatekeepers are each zone's first MAIN step now). Old saves drop it (`QuestMigration`).
const RETIRED_PATHS: String = "clear_the_paths"

## Zone id -> its MAIN quest id.
const ZONE_MAIN: Dictionary = {
	"beefcake": "main_beefcake", "necrocrat": "main_necrocrat", "gourmand": "main_gourmand", "refusemancer": "main_refusemancer",
}
## Zone id -> the equipment piece its main quest pays at the midpoint (Block 2's pieces).
const MIDPOINT_GEAR: Dictionary = {
	"beefcake": "gotta_go_galoshes", "necrocrat": "red_tape_dispenser", "gourmand": "doggy_bag", "refusemancer": "dumpster_gloves",
}
const GATE_GOLD: int = 40
const MAIN_GOLD: int = 200
const MAIN_XP: int = 150

const BRANNOCH: String = "Gatekeeper Brannoch"


static func build_all() -> Array[QuestData]:
	var result: Array[QuestData] = []
	result.append(_meet_the_merchants())
	result.append(_free_the_kingdom())
	result.append(_fragments())
	result.append(_oldest_trick())
	result.append(_four_seals())
	result.append(_armory())
	result.append(_first_deck_edit())
	for zone_id: String in Gatekeepers.IDS:
		result.append(_zone_main(zone_id))
	result.append_array(ZoneQuestDefinitions.build_all())
	return result


static func zone_main_id(zone_id: String) -> String:
	return str(ZONE_MAIN.get(zone_id, ""))


static func _meet_the_merchants() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = MERCHANTS
	quest.category = QuestData.Category.SIDE
	quest.order = 10
	quest.title = "Meet the Merchants"
	quest.summary = "Three traders keep Crosspath running. Say hello to each of them."
	quest.auto_give = true
	quest.objectives = [
		QuestObjective.make("Talk to Sable (cards)", Condition.flag("vendor_seen")).at(QuestObjective.TargetKind.NPC, "town", "vendor", "The market stalls on the square"),
		QuestObjective.make("Talk to Tilly Tonic (items)", Condition.flag("item_vendor_seen")).at(QuestObjective.TargetKind.NPC, "town", "item_vendor", "Tilly's supply stall on the square"),
		QuestObjective.make("Talk to Bertram Beetsworth (equipment)", Condition.flag("equipment_vendor_seen")).at(QuestObjective.TargetKind.NPC, "town", "equipment_vendor", "The equipment stall on the square"),
	] as Array[QuestObjective]
	quest.reward_gold = 50
	quest.reward_xp = 40
	quest.reward_equipment_ids = ["participation_trophy"] as Array[String]  # you showed up: that is basically winning
	return quest


## The Capital's main quest: Brannoch, on the imperial road, explains the four broken services and sends the hero to free the four zones,
## then to the castle. The Capital is open from the start; each zone freed lifts one broken-service debuff.
static func _free_the_kingdom() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = FREE_ZONES
	quest.category = QuestData.Category.MAIN
	quest.order = 30
	quest.title = "Free the Four Zones"
	quest.summary = "{villain}'s Capital runs on four stolen services. Free each Path zone to break one, then storm the castle."
	quest.giver_npc = BRANNOCH
	quest.giver_area = "town"
	quest.giver_spot = "guard"
	var objectives: Array[QuestObjective] = []
	for zone_id: String in Gatekeepers.IDS:
		objectives.append(QuestObjective.make("Free %s" % ZoneDefs.get_def(zone_id).display_name, Condition.flag(str(ZoneCompletion.flag_name(zone_id))))
			.at(QuestObjective.TargetKind.ZONE_FLAG, zone_id, "main_dungeon", "%s's main dungeon" % ZoneDefs.get_def(zone_id).display_name))
	objectives.append(QuestObjective.make("Storm %s's castle" % Villain.display_name(), Condition.flag("primm_defeated"))
		.at(QuestObjective.TargetKind.DUNGEON, CapitalZone.ID, "castle_door", "The castle at the heart of the Capital"))
	quest.objectives = objectives
	quest.reward_gold = 300
	quest.reward_xp = 250
	return quest


## Story v2 Part E: tracks the Wanderer's memory fragments (one returns per zone freed, played by talking to Elder Maren).
static func _fragments() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = MemoryDefs.QUEST_ID
	quest.category = QuestData.Category.MAIN
	quest.order = 35
	quest.title = "Fragments"
	quest.summary = "Pieces of the Wanderer's lost memory come back as each zone is freed. Visit Elder Maren after each one."
	quest.auto_give = true
	var names: Array[String] = ["Warmth", "The Cells", "The Coup", "A Name"]
	var objectives: Array[QuestObjective] = []
	for index: int in range(MemoryDefs.COUNT):
		objectives.append(QuestObjective.make("Recover fragment %d: %s" % [index + 1, names[index]], Condition.flag(str(MemoryDefs.flag_name(index + 1))))
			.at(QuestObjective.TargetKind.NPC, "town", "elder", "Elder Maren, on the town square, after freeing a zone"))
	quest.objectives = objectives
	quest.reward_gold = 200
	quest.reward_xp = 150
	return quest


## One Path zone's MAIN quest line: beat the gatekeeper at the obstacle (a Path Pack), cross in, do the locals a favour (a piece of gear),
## clear the main dungeon and free the leader (a Path Pack on completion).
static func _zone_main(zone_id: String) -> QuestData:
	var def: ZoneDef = ZoneDefs.get_def(zone_id)
	var text: Dictionary = ZONE_MAIN_TEXT[zone_id] as Dictionary
	var pack: String = "path_%s" % zone_id
	var quest: QuestData = QuestData.new()
	quest.id = zone_main_id(zone_id)
	quest.category = QuestData.Category.MAIN
	quest.order = 20 + Gatekeepers.IDS.find(zone_id)
	quest.title = str(text["title"])
	quest.summary = str(text["summary"])
	quest.auto_give = true
	var favours: Array[Condition] = []
	for favour_id: String in ZoneQuestDefinitions.favours_of(zone_id):
		favours.append(Condition.quest_completed(favour_id))
	quest.objectives = [
		QuestObjective.make(str(text["gate"]), Condition.flag(str(CorruptedNpcs.unlock_flag(zone_id))))
			.at(QuestObjective.TargetKind.BATTLE, "town", "npc_%s" % zone_id, str(text["gate_hint"]))
			.pays(QuestReward.of(GATE_GOLD).with_packs([pack] as Array[String])),
		QuestObjective.make(str(text["enter"]), Condition.flag(str(Gatekeepers.entered_flag(zone_id))))
			.at(QuestObjective.TargetKind.SPOT, "town", "portal_%s" % zone_id, str(text["enter_hint"])),
		QuestObjective.make(str(text["favour"]), Condition.any_of(favours))
			.at(QuestObjective.TargetKind.NPC, zone_id, str(text["favour_spot"]), str(text["favour_hint"]))
			.pays(QuestReward.of().with_equipment([str(MIDPOINT_GEAR[zone_id])] as Array[String])),
		QuestObjective.make(str(text["dungeon"]), Condition.flag(str(ZoneCompletion.flag_name(zone_id))))
			.at(QuestObjective.TargetKind.DUNGEON, zone_id, "main_dungeon", str(text["dungeon_hint"])),
	] as Array[QuestObjective]
	quest.reward_gold = MAIN_GOLD
	quest.reward_xp = MAIN_XP
	quest.reward_pack_ids = [pack] as Array[String]
	if def == null:
		push_warning("zone main quest for an unknown zone %s" % zone_id)
	return quest


## Player-facing names of each zone's main quest line (Block 4 voice pass).
const ZONE_MAIN_TEXT: Dictionary = {
	"beefcake": {
		"title": "Raise the Bar",
		"summary": "The Gainlands bridge is drawn up and a very large man is guarding the crank. Get across, help the lifters, and free Grandmaster Flex.",
		"gate": "Out-muscle Brick Bronson at the gorge", "gate_hint": "The gorge bridge at the end of the sunny meadow road",
		"enter": "Cross the bridge into the Gainlands", "enter_hint": "The lowered bridge over the gorge",
		"favour": "Spot the locals: finish a favour in the Gainlands", "favour_spot": "gus", "favour_hint": "Foreman Gus, Old Man Mountain or Coach Benchley in the Gainlands",
		"dungeon": "Storm the House of Gains and free Grandmaster Flex", "dungeon_hint": "The fortress beyond the Gainlands' north rim",
	},
	"necrocrat": {
		"title": "Take a Number",
		"summary": "A checkpoint on the cracked road wants a permit nobody has ever been issued. Get one the hard way, help the staff, and get the D.N.A. its final approval.",
		"gate": "Out-file Prudence Pallor at the checkpoint", "gate_hint": "The permit barrier on the decrepit road",
		"enter": "Pass the checkpoint into the D.N.A.", "enter_hint": "The raised barrier on the cracked road",
		"favour": "Help the staff: finish a favour in the D.N.A.", "favour_spot": "dolores", "favour_hint": "Agnes Overdue, Gerald or Clerk Ledgerbone in the D.N.A.",
		"dungeon": "Get final approval in the Hall of Final Approvals", "dungeon_hint": "The Hall at the top of the D.N.A.",
	},
	"gourmand": {
		"title": "Key Ingredients",
		"summary": "The great pantry door is locked and the chef with the key is extremely seasoned. Win the key, help the kitchen, and expose the fake Grand Chef.",
		"gate": "Win the pantry key from Chef Fennel Gravois", "gate_hint": "The great pantry door at the end of the orchard lane",
		"enter": "Step through the pantry door into the Endless Buffet", "enter_hint": "The open pantry door on the orchard lane",
		"favour": "Help the kitchen: finish a favour in the Endless Buffet", "favour_spot": "odalys", "favour_hint": "Basil, Sous-Chef Tarragon or Madame Mirepoix in the Buffet",
		"dungeon": "Shut down the Test Kitchen and expose the Doppelganger", "dungeon_hint": "The Test Kitchen at the far end of the Buffet",
	},
	"refusemancer": {
		"title": "Root Cause",
		"summary": "A wall of thorns has swallowed the forest path and a druid is talking in a voice that isn't his. Clear the way, help the locals, and cut out the Rotheart.",
		"gate": "Uproot Moss Mulligan at the thorn wall", "gate_hint": "The thorn wall across the winding forest path",
		"enter": "Walk the forest path into the Verdant Dump", "enter_hint": "The withered thorn wall on the forest path",
		"favour": "Lend a hand: finish a favour in the Verdant Dump", "favour_spot": "wren", "favour_hint": "Wren Muckfoot, Granny Gristle or Brother Bramble in the Dump",
		"dungeon": "Descend into the Rotheart and free Archdruid Compostella", "dungeon_hint": "The Rotheart, deep in the Verdant Dump",
	},
}


## Overnight Oct 17, Part 5: the armory opens at level 5. This short quest starts on its own the moment the hero reaches level 5,
## points at Bertram Beetsworth, asks for one witnessed duel ("Requisition Form 7-B") and ends with the first piece of equipment,
## the Starter Blade; finishing it unlocks all five equipment slots (`Session.complete_quest`).
const ARMORY: String = "some_assembly_required"


static func _armory() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = ARMORY
	quest.category = QuestData.Category.SIDE
	quest.order = 5
	quest.title = "Some Assembly Required"
	quest.summary = "Level five: the armory will finally issue you gear. Bertram Beetsworth has a form for that."
	quest.auto_give = true
	quest.prerequisite = Condition.player_level(ProgressionTable.ARMORY_LEVEL)
	quest.objectives = [
		QuestObjective.make("Report to Bertram Beetsworth's equipment stall", Condition.flag("armory_reported")).at(QuestObjective.TargetKind.NPC, "town", "equipment_vendor", "The equipment stall on the square"),
		QuestObjective.make("Win one duel for Form 7-B", Condition.counter("duels_won", 1)),
		QuestObjective.make("Collect your gear from Bertram", Condition.flag("armory_collected")).at(QuestObjective.TargetKind.NPC, "town", "equipment_vendor", "The equipment stall on the square"),
	] as Array[QuestObjective]
	quest.reward_xp = 30
	quest.reward_equipment_ids = [EquipmentRarity.STARTER_BLADE] as Array[String]
	quest.reward_unlock_flags = ["armory_unlocked"] as Array[String]
	return quest


## Overnight Oct 17, Part 9: the first deck edit, taught by doing. Starts by itself when the hero walks out of the Forgotten Cave with
## the three cards it paid: open the Deck Station and save the deck (every save goes through the slot picker, `Session.save_deck_to_slot`).
const FIRST_DECK_EDIT: String = "first_deck_edit"


static func _first_deck_edit() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = FIRST_DECK_EDIT
	quest.category = QuestData.Category.SIDE
	quest.order = 2
	quest.title = "Make It Yours"
	quest.summary = "The cave paid you in cards. Put the ones you like into your deck at the Deck Station."
	quest.auto_give = true
	quest.prerequisite = Condition.flag("trial_cleared")
	quest.objectives = [
		QuestObjective.make("Open the Deck Station and save your deck", Condition.flag("deck_edited")).at(QuestObjective.TargetKind.SPOT, "town", "deck", "The Deck Station on the square"),
	] as Array[QuestObjective]
	quest.reward_gold = 30
	quest.reward_xp = 20
	return quest


## Brief 16, Group B: started by Session.open_giant_chest the first time any giant chest is opened (never auto-given, so it stays hidden until then).
static func _oldest_trick() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = NinjaBoss.QUEST_ID
	quest.category = QuestData.Category.SIDE
	quest.order = 140
	quest.title = "The Oldest Trick in the Book"
	quest.summary = "A giant chest was too good to be true. Someone is conning travellers with them, and he took your gold. Find the chests, and find him."
	quest.objectives = [
		QuestObjective.make("Open the giant chests", Condition.counter(NinjaBoss.COUNTER_OPENED, NinjaBoss.CHEST_IDS.size())),
		QuestObjective.make("Face the Master of the Oldest Trick", Condition.flag(str(NinjaBoss.FLAG_DEFEATED))),
	] as Array[QuestObjective]
	return quest


## Brief 16, Group G: a hidden quest, started by Session.pull_vault_lever the first time any of the four levers is pulled (never auto-given).
static func _four_seals() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = VaultGuardian.QUEST_ID
	quest.category = QuestData.Category.SIDE
	quest.order = 141
	quest.title = "The Four Seals"
	quest.summary = "Far away, a great lock ground open. A hidden lever in every Path zone answers a seal on a vault in town. Find them all."
	quest.objectives = [
		QuestObjective.make("Find the hidden levers", Condition.counter(VaultGuardian.COUNTER_LEVERS, VaultGuardian.ZONE_IDS.size())),
		QuestObjective.make("Open the vault and defeat its Warden", Condition.flag(str(VaultGuardian.FLAG_DEFEATED))).at(QuestObjective.TargetKind.SPOT, "town", "vault4", "The Four-Seal Vault in the north hills of town"),
	] as Array[QuestObjective]
	return quest
