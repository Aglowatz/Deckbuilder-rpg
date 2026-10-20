class_name QuestDefinitions
extends RefCounted
## Authoring source for every quest (`QuestCatalog` builds them at start-up). Dialogue spoken by quest givers lives in the story files
## (`StoryText` "quest.<id>.*", `ZoneStoryText`), not here. Overnight Oct 16: every quest has a category; each Path zone has one MAIN quest line
## (the gatekeeper, crossing in, a favour for the locals, the main dungeon) that pays a Path Pack at its gatekeeper and at its dungeon and a
## piece of equipment at its midpoint; Gatekeeper Brannoch gives "Free the Four Zones" on the Capital road. Reward table: docs/design/quests.md.

const MERCHANTS: String = "meet_the_merchants"
## Oct 20, Part 4: the early-game main chain, all from Elder Maren in this order: Meet the Merchants -> Make It Yours (the Deck Station) ->
## the ghosts in Tilly's store room -> Some Assembly Required (Bertram Beetsworth's armory). Only once the armory quest is done do the story's
## main quests start (the four zone lines, Fragments, Brannoch's Free the Four Zones, Maren's door under the well): `STORY_GATE`.
const MAREN: String = "Elder Maren"
const GHOSTS: String = "storeroom_ghosts"
## Set by `QuestMigration` on saves from before the chain that already had the story quests, so they never lose them.
const LEGACY_FLAG: String = "early_chain_legacy"
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
	result.append(_storeroom_ghosts())
	result.append(_free_the_kingdom())
	result.append(_fragments())
	result.append(_oldest_trick())
	result.append(_four_seals())
	result.append(OldWellQuest.quest())  # Overnight Oct 19-20, Part 6: the Old Well secret quest (started by the well's vision, never auto-given)
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
	quest.category = QuestData.Category.MAIN
	quest.order = 1
	quest.title = "Meet the Merchants"
	quest.summary = "Elder Maren wants you fed, kitted out and known in town. Say hello to the shopkeepers on the square and buy yourself a card. There is a trophy in it. Everyone gets the trophy."
	# Oct 20, Part 4: the one quest a new arrival has (Maren gives it in her welcome); Bertram's smithy stays shut for now.
	quest.auto_give = true
	quest.prerequisite = Condition.flag("trial_cleared")
	quest.giver_npc = MAREN
	quest.giver_area = "town"
	quest.giver_spot = "elder"
	quest.turn_in_npc = MAREN
	quest.turn_in_area = "town"
	quest.turn_in_spot = "elder"
	quest.objectives = [
		QuestObjective.make("Say hello to Sable at her card shop", Condition.flag("vendor_seen")).at(QuestObjective.TargetKind.NPC, "town", "vendor", "Sable's Cards, on the west side of Crosspath's square"),
		QuestObjective.make("Buy a card from Sable", Condition.counter("cards_bought", 1)).at(QuestObjective.TargetKind.NPC, "town", "vendor", "Sable's Cards, on the west side of Crosspath's square"),
		QuestObjective.make("Say hello to Tilly Tonic at her supply shop", Condition.flag("item_vendor_seen")).at(QuestObjective.TargetKind.NPC, "town", "item_vendor", "Tilly Tonic's Supplies, on the north side of Crosspath's square"),
		QuestObjective.make("Say hello to Pip Threadwell at the hat shop", Condition.flag("tailor_seen")).at(QuestObjective.TargetKind.NPC, "town", "tailor", "Threadwell's Hats & Hems, on the east side of Crosspath's square"),
	] as Array[QuestObjective]
	quest.reward_gold = 50
	quest.reward_xp = CHAIN_XP[MERCHANTS]
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
	quest.prerequisite = story_gate()  # Oct 20, Part 4: offered once the armory quest is done
	quest.giver_area = "town"
	quest.giver_spot = "guard"
	var objectives: Array[QuestObjective] = []
	for zone_id: String in Gatekeepers.IDS:
		objectives.append(QuestObjective.make("%s: beat its main dungeon" % ZoneDefs.get_def(zone_id).display_name, Condition.flag(str(ZoneCompletion.flag_name(zone_id))))
			.at(QuestObjective.TargetKind.ZONE_FLAG, zone_id, "main_dungeon", "%s, at its main dungeon" % ZoneDefs.get_def(zone_id).display_name))
	objectives.append(QuestObjective.make("Storm %s's castle in the Capital" % Villain.display_name(), Condition.flag("primm_defeated"))
		.at(QuestObjective.TargetKind.DUNGEON, CapitalZone.ID, "castle_door", "The castle on its hill, up the palace avenue"))
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
	quest.summary = "Your lost memories come back one piece for every zone you free. After each one, visit Elder Maren."
	quest.auto_give = true
	quest.prerequisite = story_gate()
	var names: Array[String] = ["Warmth", "The Cells", "The Coup", "A Name"]
	var objectives: Array[QuestObjective] = []
	for index: int in range(MemoryDefs.COUNT):
		objectives.append(QuestObjective.make("Fragment %d (%s): free a zone, see Elder Maren" % [index + 1, names[index]], Condition.flag(str(MemoryDefs.flag_name(index + 1))))
			.at(QuestObjective.TargetKind.NPC, "town", "elder", "Elder Maren's home, up the Gate Road from Crosspath's square"))
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
	quest.prerequisite = story_gate()
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
		"gate": "Out-muscle Brick Bronson at the gorge", "gate_hint": "The drawn-up gorge bridge, at the end of the meadow road",
		"enter": "Cross the bridge into the Gainlands", "enter_hint": "The lowered bridge over the gorge",
		"favour": "Spot the locals: finish a favour in the Gainlands", "favour_spot": "gus", "favour_hint": "Foreman Gus, Old Man Mountain or Coach Brutus Benchley",
		"dungeon": "Storm the House of Gains and free Grandmaster Flex", "dungeon_hint": "The House of Gains, beyond the north rim",
	},
	"necrocrat": {
		"title": "Take a Number",
		"summary": "A checkpoint on the cracked road wants a permit nobody has ever been issued. Get one the hard way, help the staff, and get the D.N.A. its final approval.",
		"gate": "Out-file Prudence Pallor at the permit barrier", "gate_hint": "The permit barrier, at the end of the cracked road",
		"enter": "Pass the permit barrier into the D.N.A.", "enter_hint": "The raised barrier on the cracked road",
		"favour": "Help the staff: finish a favour in the D.N.A.", "favour_spot": "dolores", "favour_hint": "Agnes Overdue, Gerald or Clerk Ledgerbone",
		"dungeon": "Get final approval in the Hall of Final Approvals", "dungeon_hint": "The Hall of Final Approvals, at the top of the building",
	},
	"gourmand": {
		"title": "Key Ingredients",
		"summary": "The great pantry door is locked and the chef with the key is extremely seasoned. Win the key, help the kitchen, and expose the fake Grand Chef.",
		"gate": "Win the pantry key from Chef Fennel Gravois", "gate_hint": "The great pantry door at the end of the orchard lane",
		"enter": "Step through the pantry door into the Endless Buffet", "enter_hint": "The open pantry door on the orchard lane",
		"favour": "Help the kitchen: finish a favour in the Endless Buffet", "favour_spot": "odalys", "favour_hint": "Basil, Sous-Chef Tarragon or Madame Mirepoix",
		"dungeon": "Shut down the Test Kitchen and unmask the fake Chef", "dungeon_hint": "The Test Kitchen, at the far end of the halls",
	},
	"refusemancer": {
		"title": "Root Cause",
		"summary": "A wall of thorns has swallowed the forest path and a druid is talking in a voice that isn't hers. Clear the way, help the locals, and cut out the Rotheart.",
		"gate": "Uproot Moss Mulligan at the thorn wall", "gate_hint": "The thorn wall across the forest path",
		"enter": "Walk the forest path into the Verdant Dump", "enter_hint": "The withered thorn wall on the forest path",
		"favour": "Lend a hand: finish a favour in the Verdant Dump", "favour_spot": "wren", "favour_hint": "Wren Muckfoot, Granny Gristle or Brother Bramble",
		"dungeon": "Descend into the Rotheart and free Archdruid Compostella", "dungeon_hint": "The way down into the Rotheart",
	},
}


## The XP each step of the early-game chain pays. With the Forgotten Cave (150 XP: two scavengers and the Warden) and the store room
## fight (`StoreroomGhosts.XP`, 30) a new hero reaches 300 XP - level 5 - as Maren takes the ghost quest back: 150 + 40 + 30 + 30 + 60 = 310.
## Outskirts roamers are extra, never required. Test: tests/core/quests/test_early_chain.gd.
const CHAIN_XP: Dictionary = {MERCHANTS: 40, "first_deck_edit": 30, GHOSTS: 60}

## Oct 20, Part 4: the story's main quests (the four zone lines, Fragments, Free the Four Zones, the door under the well) wait for the armory
## quest - or for an old save that already had them (`LEGACY_FLAG`). Only the quest log waits: every road stays open.
static func story_gate() -> Condition:
	return Condition.any_of([Condition.quest_completed(ARMORY), Condition.flag(LEGACY_FLAG)] as Array[Condition])


## Overnight Oct 17, Part 5 / Oct 20, Part 4: the armory. Elder Maren sends the hero to Bertram Beetsworth once the store room is clear
## (it no longer starts by itself at level 5, and Bertram's smithy stays shut until it does); Bertram asks for one won fight of any kind
## (roamer, gatekeeper, dungeon, arena) and hands over the first piece of equipment, the Starter Blade; finishing it unlocks all five
## equipment slots (`Session.complete_quest`) and opens the story's main quests (`story_gate`).
const ARMORY: String = "some_assembly_required"


static func _armory() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = ARMORY
	quest.category = QuestData.Category.MAIN
	quest.order = 4
	quest.title = "Some Assembly Required"
	quest.summary = "Maren says it is time you had something sharper than a deck. Bertram Beetsworth issues gear, by the book: report to his smithy and win him one fight."
	quest.giver_npc = MAREN
	quest.giver_area = "town"
	quest.giver_spot = "elder"
	quest.prerequisite = Condition.quest_completed(GHOSTS)
	quest.objectives = [
		QuestObjective.make("Report to Bertram Beetsworth at his smithy", Condition.flag("armory_reported")).at(QuestObjective.TargetKind.NPC, "town", "equipment_vendor", "Bertram Beetsworth's Smithy, on the west side of Crosspath's square"),
		QuestObjective.make("Win one fight (any fight)", Condition.counter("duels_won", 1)).at(QuestObjective.TargetKind.NONE, "", "", "An outskirts roamer on the lanes round Crosspath will do"),
		QuestObjective.make("Collect your gear from Bertram", Condition.flag("armory_collected")).at(QuestObjective.TargetKind.NPC, "town", "equipment_vendor", "Bertram Beetsworth's Smithy, on the west side of Crosspath's square"),
	] as Array[QuestObjective]
	quest.reward_xp = 30
	quest.reward_equipment_ids = [EquipmentRarity.STARTER_BLADE] as Array[String]
	quest.reward_unlock_flags = ["armory_unlocked"] as Array[String]
	return quest


## Overnight Oct 17, Part 9 / Oct 20, Part 4: the first deck edit, taught by doing - now Maren's second errand (after Meet the Merchants):
## open the Deck Station and save the deck to a slot (every save goes through the slot picker, `Session.save_deck_to_slot`).
const FIRST_DECK_EDIT: String = "first_deck_edit"


static func _first_deck_edit() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = FIRST_DECK_EDIT
	quest.category = QuestData.Category.MAIN
	quest.order = 2
	quest.title = "Make It Yours"
	quest.summary = "A deck you never chose is a deck you will lose with, says Maren. Look it over at the Deck Station, swap what you like and save it to a slot."
	quest.giver_npc = MAREN
	quest.giver_area = "town"
	quest.giver_spot = "elder"
	quest.turn_in_npc = MAREN
	quest.turn_in_area = "town"
	quest.turn_in_spot = "elder"
	quest.prerequisite = Condition.quest_completed(MERCHANTS)
	quest.objectives = [
		QuestObjective.make("Open the Deck Station and save your deck to a slot", Condition.flag("deck_edited")).at(QuestObjective.TargetKind.SPOT, "town", "deck", "The Deck Station, on Champions' Road south of the square"),
	] as Array[QuestObjective]
	quest.reward_gold = 30
	quest.reward_xp = CHAIN_XP[FIRST_DECK_EDIT]
	return quest


## Oct 20, Part 4: Maren's third errand - the store room behind Tilly Tonic's shop is haunted and nobody can get in. The door starts a duel
## (`Session.make_storeroom_battle`, `StoreroomGhosts`); winning it sets `StoreroomGhosts.FLAG_CLEARED`. Hand it in to Maren.
static func _storeroom_ghosts() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = GHOSTS
	quest.category = QuestData.Category.MAIN
	quest.order = 3
	quest.title = "Something in the Store Room"
	quest.summary = "Tilly Tonic's store room has been rattling, moaning and refusing visitors. Maren would like it to stop. So would Tilly."
	quest.giver_npc = MAREN
	quest.giver_area = "town"
	quest.giver_spot = "elder"
	quest.turn_in_npc = MAREN
	quest.turn_in_area = "town"
	quest.turn_in_spot = "elder"
	quest.prerequisite = Condition.quest_completed(FIRST_DECK_EDIT)
	quest.objectives = [
		QuestObjective.make("Open the store room door beside Tilly Tonic's shop", Condition.flag(str(StoreroomGhosts.FLAG_CLEARED))).at(QuestObjective.TargetKind.BATTLE, "town", StoreroomGhosts.SPOT_ID, "The row house beside Tilly Tonic's Supplies, on the north side of the square"),
	] as Array[QuestObjective]
	quest.reward_gold = 40
	quest.reward_xp = CHAIN_XP[GHOSTS]
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
	quest.summary = "Far away, a great lock ground open. A hidden lever in every Path zone answers a seal on a vault in Crosspath. Find them all."
	quest.objectives = [
		QuestObjective.make("Find the hidden lever in each Path zone", Condition.counter(VaultGuardian.COUNTER_LEVERS, VaultGuardian.ZONE_IDS.size())),
		QuestObjective.make("Open the Four-Seal Vault and beat its Warden", Condition.flag(str(VaultGuardian.FLAG_DEFEATED))).at(QuestObjective.TargetKind.SPOT, "town", "vault4", "The Four-Seal Vault, in the hills north of Crosspath"),
	] as Array[QuestObjective]
	return quest
