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
## Fix pass Nov 7 (owner decision D3): Maren's four errands (Meet the Merchants, Make It Yours, the store room, the armory) are the
## "Settling In" line - side quests that run beside the Path's main line; they no longer gate the story (`story_gate`).
const SETTLING_IN: String = "Settling In"
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
	result.append(_loose_ends())
	result.append(_alembic())
	result.append(_under_the_forest())
	result.append(CardMatchCircuit.quest())  # Overnight Nov 7-8, Part 6.3
	for zone_id: String in Gatekeepers.IDS:
		result.append(_zone_main(zone_id))
	result.append_array(ZoneQuestDefinitions.build_all())
	return result


## Fix pass Nov 4 (B), Part 4.1: after Primm falls, Rip (the Rift Express) has news of the forest where the Wanderer woke. The quest walks the player from
## his station in Crosspath to the forest, south past where the brambles were to the Lab's hatch, and down to Cell 4 to free Elowen.
const UNDER_THE_FOREST: String = "under_the_forest"
const FLAG_FOREST_ARRIVED: String = "lab_quest_forest_arrived"
const FLAG_LAB_ENTERED: String = "lab_quest_entered"


static func _under_the_forest() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = UNDER_THE_FOREST
	quest.category = QuestData.Category.MAIN
	quest.order = 9
	quest.title = "Under the Forest"
	quest.summary = "{villain} is gone, but Rip found something in the forest where you first woke: a hatch that wasn't there before. Whatever is down there feels like yours, and so does someone."
	quest.auto_give = true
	quest.prerequisite = Condition.postgame()
	quest.giver_npc = "Rip Tearson, Rift Technician"
	quest.giver_area = "town"
	quest.giver_spot = "rift_station"
	quest.objectives = [
		QuestObjective.make("Ask Rip at Crosspath's Rift Station what he found", Condition.flag("rip_forest_tip"))
			.at(QuestObjective.TargetKind.SPOT, "town", "rift_station", "The Rift Express station in Crosspath"),
		QuestObjective.make("Take the Rift Express to the forest where you woke", Condition.flag(FLAG_FOREST_ARRIVED))
			.at(QuestObjective.TargetKind.SPOT, "town", "rift_station", "Any Rift Express station: choose the forest"),
		QuestObjective.make("Find the hatch at the end of the new path, south of the clearing", Condition.flag(FLAG_LAB_ENTERED))
			.at(QuestObjective.TargetKind.SPOT, Areas.START, "lab", "Down the new path south of the forest clearing"),
		QuestObjective.make("Free the prisoner in Cell 4", Condition.flag(str(PathologyLab.FLAG_RESCUER_FREED)))
			.at(QuestObjective.TargetKind.DUNGEON, Areas.START, "lab", "Below the hatch: the Cell Block branch"),
	] as Array[QuestObjective]
	quest.reward_gold = 200
	quest.reward_xp = 200
	return quest


## Fix pass Nov 4 (B), Part 4.2: when the Alchemist opens (two zones free) a quest points the player to Auntie Alembic's. Its first step (talking to
## her) pays MIN_ESSENCE_PER_PATH essence of every Path (`Session.visit_alchemist`), enough for one brew of any two; the second is that brew.
const ALEMBIC: String = "alembic_cauldron"
const FLAG_ALEMBIC_VISITED: String = "alembic_quest_visited"


static func _alembic() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = ALEMBIC
	quest.category = QuestData.Category.SIDE
	quest.order = 95
	quest.title = "A Pinch of Everything"
	quest.summary = "Auntie Alembic's cauldron is bubbling again. She brews cards of two Paths at once out of essence, and she has a starter jar for you."
	quest.auto_give = true
	quest.prerequisite = Condition.zones_completed(ZoneCompletion.ALCHEMIST_UNLOCK_COUNT)
	quest.giver_npc = "Auntie Alembic"
	quest.giver_area = "town"
	quest.giver_spot = "alchemist"
	quest.objectives = [
		QuestObjective.make("Visit Auntie Alembic's in Crosspath", Condition.flag(FLAG_ALEMBIC_VISITED)).at(QuestObjective.TargetKind.NPC, "town", "alchemist", "Auntie Alembic's, the alchemist's shop in Crosspath"),
		QuestObjective.make("Brew a card of two Paths at her cauldron", Condition.counter("cards_crafted", 1)).at(QuestObjective.TargetKind.NPC, "town", "alchemist", "Auntie Alembic's cauldron: pick two Paths"),
	] as Array[QuestObjective]
	quest.reward_gold = 50
	quest.reward_xp = 40
	return quest


## Nov 1 (the designer's yes to the postgame critics): after the credits the quest log said "Nothing here right now". Loose Ends
## is given at once in the postgame (old saves too) and points at what is left: Mount Swolympus, the Path-ology Lab, the Arena.
const LOOSE_ENDS: String = "loose_ends"


static func _loose_ends() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = LOOSE_ENDS
	quest.category = QuestData.Category.MAIN
	quest.order = 90
	quest.title = "Loose Ends"
	quest.summary = "{villain} is gone, but the kingdom is not quite done with you. A mountain nobody has climbed, a secret Rip has been keeping, and a crowd under Crosspath that wants a show."
	quest.auto_give = true
	quest.prerequisite = Condition.postgame()
	var arena_wins: Array[Condition] = []
	for encounter: ArenaEncounter in ArenaDefs.all():
		arena_wins.append(Condition.flag(str(ArenaDefs.flag_name(encounter.id))))
	quest.objectives = [
		QuestObjective.make("Climb Mount Swolympus: Old Man Mountain at the Swole Station knows the way up", Condition.dungeon_cleared("The Ascent of Mount Swolympus"))
			.at(QuestObjective.TargetKind.NPC, GainlandsZone.ID, "brenda", "Old Man Mountain, in front of the gym hall in the Gainlands"),
		QuestObjective.make("Find out what is under the forest (Under the Forest)", Condition.quest_completed(UNDER_THE_FOREST))  # Fix pass Nov 4 (B): its own quest
			.at(QuestObjective.TargetKind.NPC, "town", "rift_station", "Rip Tearson's Rift Express station in Crosspath starts it"),
		QuestObjective.make("Win a bout in the Arena, down the cellar hatch in Crosspath", Condition.any_of(arena_wins))
			.at(QuestObjective.TargetKind.SPOT, "town", "arena", "The cellar hatch to the Undercroft, in Crosspath"),
	] as Array[QuestObjective]
	quest.reward_gold = 500
	quest.reward_xp = 400
	return quest


static func zone_main_id(zone_id: String) -> String:
	return str(ZONE_MAIN.get(zone_id, ""))


static func _meet_the_merchants() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = MERCHANTS
	quest.category = QuestData.Category.SIDE
	quest.line = SETTLING_IN
	quest.order = 1
	quest.title = "Meet the Merchants"
	quest.summary = "Elder Maren wants you fed, kitted out and known in town. Say hello to the shopkeepers on the square and buy yourself a card. There's a trophy in it, though everyone gets the trophy."
	# Oct 20, Part 4: the one quest a new arrival has (Maren gives it in her welcome); Bertram's smithy stays shut for now.
	quest.auto_give = true
	quest.prerequisite = Condition.flag("trial_cleared")
	quest.giver_npc = MAREN
	quest.giver_area = "town"
	quest.giver_spot = "elder"
	quest.turn_in_npc = MAREN
	quest.turn_in_area = "town"
	quest.turn_in_spot = "elder"
	# Overnight Nov 3-4, Part B5: right after the first fight, Tilly comes first - she gives a free Power Wraps and talks you through equipping
	# it (Character page > Items > the item > an empty slot); the step completes on equip (Session.note_item_equipped).
	quest.objectives = [
		QuestObjective.make("Say hello to Tilly Tonic at her supply shop", Condition.flag("item_vendor_seen")).at(QuestObjective.TargetKind.NPC, "town", "item_vendor", "Tilly Tonic's Supplies, on the north side of Crosspath's square"),
		QuestObjective.make("Equip Tilly's Power Wraps: press C, pick them in Items, then an empty slot", Condition.flag("tilly_item_equipped")).at(QuestObjective.TargetKind.NPC, "town", "item_vendor", "Your Character page (Menu > Character): the Items panel"),
		QuestObjective.make("Say hello to Sable at her card shop", Condition.flag("vendor_seen")).at(QuestObjective.TargetKind.NPC, "town", "vendor", "Sable's Cards, on the west side of Crosspath's square"),
		QuestObjective.make("Buy a card from Sable", Condition.counter("cards_bought", 1)).at(QuestObjective.TargetKind.NPC, "town", "vendor", "Sable's Cards, on the west side of Crosspath's square"),
		QuestObjective.make("Say hello to Pip Threadwell at the hat shop", Condition.flag("tailor_seen")).at(QuestObjective.TargetKind.NPC, "town", "tailor", "Threadwell's Hats & Hems, on the east side of Crosspath's square"),
	] as Array[QuestObjective]
	quest.reward_gold = 50
	quest.reward_xp = CHAIN_XP[MERCHANTS]
	# Fix pass Nov 7 (Part 5, C1b F7): the trophy comes with the armory (it could not be worn before the equipment slots open).
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
	# Fix pass Nov 7 (item 14, C4 F5): a step and a pin for the Crease, the resistance's hideout under the Capital, before the castle.
	objectives.append(QuestObjective.make("Find the resistance in the Crease (the manhole on the Gate Plaza)", Condition.any_of([Condition.flag(str(CapitalZone.FLAG_HUB_KNOWN)), Condition.flag("primm_defeated")] as Array[Condition]))
		.at(QuestObjective.TargetKind.SPOT, CapitalZone.ID, "manhole", "The suspicious manhole on the Gate Plaza, inside the Capital's wall"))
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
	quest.summary = "Every zone you free seems to shake something loose in your memory. Each time it happens, go and tell Elder Maren; she'll want to hear it."
	quest.auto_give = true
	quest.prerequisite = story_gate()
	# Oct 20, Part 5: the memories' names are spoilers; the steps only count them
	var names: Array[String] = ["A first memory", "A second memory", "A third memory", "A last memory"]
	var objectives: Array[QuestObjective] = []
	for index: int in range(MemoryDefs.COUNT):
		objectives.append(QuestObjective.make("%s: free a zone, then see Elder Maren" % names[index], Condition.flag(str(MemoryDefs.flag_name(index + 1))))
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
	# Overnight Nov 7-8, Part 1.2: the gatekeeper quests wait for the intro line - Maren hands all four out once Settling In (the armory
	# included) is done (`PathDirection.FLAG`, set by her talk); a save from before the early chain keeps them (`LEGACY_FLAG`).
	quest.prerequisite = gatekeepers_given()
	var favours: Array[Condition] = []
	for favour_id: String in ZoneQuestDefinitions.favours_of(zone_id):
		favours.append(Condition.quest_completed(favour_id))
	# Overnight Nov 4-5, Part 1: a freed zone finishes its line - a skipped favour no longer leaves "3/4" in the log forever.
	favours.append(Condition.flag(str(ZoneCompletion.flag_name(zone_id))))
	# Fable pass Nov 10 (Part 1.1): the favour step marks all three favour givers (a finished favour's giver drops off).
	var favour_step: QuestObjective = QuestObjective.make(str(text["favour"]), Condition.any_of(favours))
	favour_step.at(QuestObjective.TargetKind.NPC, zone_id, str(text["favour_spot"]), str(text["favour_hint"]))
	var dungeon_step: QuestObjective = QuestObjective.make(str(text["dungeon"]), Condition.flag(str(ZoneCompletion.flag_name(zone_id))))
	dungeon_step.at(QuestObjective.TargetKind.DUNGEON, zone_id, "main_dungeon", str(text["dungeon_hint"]))
	for favour_id: String in ZoneQuestDefinitions.favours_of(zone_id):
		var giver: Array = ZoneQuestDefinitions.GIVERS.get(favour_id, []) as Array
		if giver.size() != 2:
			continue
		favour_step.part(QuestObjective.TargetKind.NPC, str(giver[0]), str(giver[1]), _spot_title(def, str(giver[1])), Condition.quest_completed(favour_id))
	# Fable pass Nov 10 (Part 1.6, the wayfinding critic): the Dump's stream cuts the Compost Commons off from the rest of the zone; the main
	# line marks the crossing from the favour step on, until a bridge is grown: a Magic Bean (one lies by the stream) planted at the West
	# Sprout Mound grows the west vine bridge (Moss Mulligan grows the centre one for Billie's herd, two of whose animals graze across the water).
	if zone_id == "refusemancer":
		for step: QuestObjective in [favour_step, dungeon_step]:
			var crossed: Condition = Condition.any_of([Condition.flag(str(HeapGrowth.find("bridge_west").flag)), Condition.flag(str(HeapGrowth.find("bridge_center").flag))] as Array[Condition])
			step.part(QuestObjective.TargetKind.ITEM_COUNT, zone_id, "pickup_bean_1", "A Magic Bean (by the stream, west of the Centre Bridge)", Condition.any_of([Condition.counter(HeapZone.stock_key("bean"), 1), crossed] as Array[Condition]))
			step.part(QuestObjective.TargetKind.SPOT, zone_id, "grow_bridge_west", "The West Sprout Mound: plant a Magic Bean and a vine bridge grows across the stream", crossed)
	# Fable pass Nov 10 (Part 1.2): the way to the main dungeon is never a guessing game - where a gate stands on the road (the audit tool
	# `tools/dungeon_route_audit.gd` names them) the dungeon step marks the gate and what opens it, until it is open.
	match zone_id:
		"gourmand":
			# Sir Loin's golem gate across the road to Layer-Cake Town opens once Old Meatloaf is mended (Basil's favour, Mend the Meatloaf)
			dungeon_step.part(QuestObjective.TargetKind.SPOT, zone_id, "gate_quest", "Sir Loin's gate: mend Old Meatloaf first (Basil's favour)", Condition.flag(str(BuffetZone.FLAG_GATE_QUEST)))
			dungeon_step.part(QuestObjective.TargetKind.DUNGEON, zone_id, "main_dungeon", "The Test Kitchen, beyond Layer-Cake Town")
		"refusemancer":
			# the plateau is reached up the barricade stairs: a mount from the stables charges the junk barricade, then the stairs are open
			var smashed: Condition = Condition.flag(str(HeapGrowth.find_barricade("gate").flag))
			dungeon_step.part(QuestObjective.TargetKind.SPOT, zone_id, "stable_2", "The stables: borrow a mount (it charges junk barricades)", smashed)
			dungeon_step.part(QuestObjective.TargetKind.SPOT, zone_id, "barricade_gate", "The junk barricade on the stairs: charge it on a mount", smashed)
			dungeon_step.part(QuestObjective.TargetKind.DUNGEON, zone_id, "main_dungeon", "The Rotheart's root gate, up on the plateau")
	quest.objectives = [
		QuestObjective.make(str(text["gate"]), Condition.flag(str(CorruptedNpcs.unlock_flag(zone_id))))
			.at(QuestObjective.TargetKind.BATTLE, "town", "npc_%s" % zone_id, str(text["gate_hint"]))
			.pays(QuestReward.of(GATE_GOLD).with_packs([pack] as Array[String])),
		QuestObjective.make(str(text["enter"]), Condition.flag(str(Gatekeepers.entered_flag(zone_id))))
			.at(QuestObjective.TargetKind.SPOT, "town", "portal_%s" % zone_id, str(text["enter_hint"])),
		favour_step.pays(QuestReward.of().with_equipment([str(MIDPOINT_GEAR[zone_id])] as Array[String])),
		dungeon_step,
	] as Array[QuestObjective]
	quest.reward_gold = MAIN_GOLD
	quest.reward_xp = MAIN_XP
	quest.reward_pack_ids = [pack] as Array[String]
	if def == null:
		push_warning("zone main quest for an unknown zone %s" % zone_id)
	return quest


## The player-facing title of a zone's spot ("Basil, Keeper of the Grand Pantry"), or "" when the zone has no such spot.
static func _spot_title(def: ZoneDef, spot_id: String) -> String:
	if def == null:
		return ""
	for spot: Dictionary in def.spots:
		if str(spot.get("id", "")) == spot_id:
			return str(spot.get("title", ""))
	return ""


## Player-facing names of each zone's main quest line (Block 4 voice pass).
const ZONE_MAIN_TEXT: Dictionary = {
	"beefcake": {
		"title": "Raise the Bar",
		"summary": "The bridge into the Gainlands is drawn up, and the very large man on the crank answers to the regime. Get across and find out who is running the Beefcakes now.",
		"gate": "Out-muscle Brick Bronson at the gorge", "gate_hint": "The drawn-up gorge bridge, at the end of the meadow road",
		"enter": "Cross the bridge into the Gainlands", "enter_hint": "The lowered bridge over the gorge",
		"favour": "Spot the locals: finish a favour in the Gainlands", "favour_spot": "gus", "favour_hint": "Foreman Gus, Old Man Mountain or Coach Brutus Benchley",
		"dungeon": "Storm the House of Gains", "dungeon_hint": "The House of Gains, beyond the north rim",
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
		"summary": "The great pantry door is locked, and Chef Fennel Gravois won't give up the key. Win it, and find out what's really cooking in the Grand Chef's kitchens.",
		"gate": "Win the pantry key from Chef Fennel Gravois", "gate_hint": "The great pantry door at the end of the orchard lane",
		"enter": "Step through the pantry door into the Endless Buffet", "enter_hint": "The open pantry door on the orchard lane",
		"favour": "Help the kitchen: finish a favour in the Endless Buffet", "favour_spot": "odalys", "favour_hint": "Basil, Sous-Chef Tarragon or Madame Mirepoix",
		"dungeon": "Shut down the Test Kitchen", "dungeon_hint": "The Test Kitchen, at the far end of the halls",
	},
	"refusemancer": {
		"title": "Root Cause",
		"summary": "A wall of thorns has swallowed the forest path, and the druid guarding it sounds very wrong. Clear the way and find what is making the Dump sick.",
		"gate": "Uproot Moss Mulligan at the thorn wall", "gate_hint": "The thorn wall across the forest path",
		"enter": "Walk the forest path into the Verdant Dump", "enter_hint": "The withered thorn wall on the forest path",
		"favour": "Lend a hand: finish a favour in the Verdant Dump", "favour_spot": "wren", "favour_hint": "Billie Muckfoot, Granny Gristle or Brother Bramble",
		"dungeon": "Descend into the Rotheart", "dungeon_hint": "The way down into the Rotheart, at the bottom of the Dump",
	},
}


## The XP each step of the early-game chain pays. With the Forgotten Cave (150 XP: two scavengers and the Warden) and the store room
## fight (`StoreroomGhosts.XP`, 30) a new hero reaches 300 XP - level 5 - as Maren takes the ghost quest back: 150 + 40 + 30 + 30 + 60 = 310.
## Outskirts roamers are extra, never required. Test: tests/core/quests/test_early_chain.gd.
const CHAIN_XP: Dictionary = {MERCHANTS: 40, "first_deck_edit": 30, GHOSTS: 60}

## Oct 20, Part 4: the story's main quests (the four zone lines, Fragments, Free the Four Zones, the door under the well) waited for the armory
## quest. Fix pass Nov 7 (owner decision D3): Maren's errands are a parallel line, not a gate - the story quests open on the first arrival in
## Crosspath (`trial_cleared`), or for an old save that already had them (`LEGACY_FLAG`). Every road stays open throughout.
static func story_gate() -> Condition:
	return Condition.any_of([Condition.flag("trial_cleared"), Condition.quest_completed(ARMORY), Condition.flag(LEGACY_FLAG)] as Array[Condition])


## Overnight Nov 7-8, Part 1.2: true once Elder Maren has sent the hero out to the gatekeepers (after the whole Settling In line, the armory
## quest included), or on a save from before the early chain. Until then no gatekeeper quest starts and no gatekeeper will fight.
static func gatekeepers_given() -> Condition:
	return Condition.any_of([Condition.flag(PathDirection.FLAG), Condition.flag(LEGACY_FLAG)] as Array[Condition])


## Fix pass Nov 7 (D3): set when the player picks their starting Path (and on load for older saves): that Path zone's main line - its
## gatekeeper - is given at once and tracked.
static func own_path_flag(zone_id: String) -> String:
	return "own_path_%s" % zone_id


## Overnight Oct 17, Part 5 / Oct 20, Part 4: the armory. Elder Maren sends the hero to Bertram Beetsworth once the store room is clear
## (it no longer starts by itself at level 5, and Bertram's smithy stays shut until it does); Bertram asks for one won fight of any kind
## (roamer, gatekeeper, dungeon, arena) and hands over the first piece of equipment, the Starter Blade; finishing it unlocks all five
## equipment slots (`Session.complete_quest`) and opens the story's main quests (`story_gate`).
const ARMORY: String = "some_assembly_required"
## Fixes Oct 25, Part 4: the armory quest's "win one fight" step points at the outskirts: the town resolves this spot id to the outskirts
## roamer nearest the square (`TownScene._outskirts_spot`).
const OUTSKIRTS_SPOT: String = "outskirts"


static func _armory() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = ARMORY
	quest.category = QuestData.Category.SIDE
	quest.line = SETTLING_IN
	quest.order = 4
	quest.title = "Some Assembly Required"
	quest.summary = "Maren says it's time you had something sharper than a deck. Bertram Beetsworth issues gear strictly by the book: report to his smithy, then win one fight to earn it."
	quest.giver_npc = MAREN
	quest.giver_area = "town"
	quest.giver_spot = "elder"
	quest.prerequisite = Condition.quest_completed(GHOSTS)
	quest.objectives = [
		QuestObjective.make("Report to Bertram Beetsworth at his smithy", Condition.flag("armory_reported")).at(QuestObjective.TargetKind.NPC, "town", "equipment_vendor", "Bertram Beetsworth's Smithy, on the west side of Crosspath's square"),
		QuestObjective.make("Win one fight (any fight)", Condition.counter("duels_won", 1)).at(QuestObjective.TargetKind.SPOT, "town", OUTSKIRTS_SPOT, "Enemies roam the outskirts, on the lanes round the edge of Crosspath. Any win counts"),
		QuestObjective.make("Collect your gear from Bertram", Condition.flag("armory_collected")).at(QuestObjective.TargetKind.NPC, "town", "equipment_vendor", "Bertram Beetsworth's Smithy, on the west side of Crosspath's square"),
		# Overnight Nov 3-4, Part B6: collecting opens the slots and hands over the Starter Blade; wearing it (any piece) completes the quest.
		QuestObjective.make("Equip your new blade: press C (Character), then the Weapon slot", Condition.flag("armory_gear_equipped")).at(QuestObjective.TargetKind.NPC, "town", "equipment_vendor", "Your Character page (Menu > Character): click the Weapon slot"),
	] as Array[QuestObjective]
	quest.reward_xp = 30
	quest.reward_equipment_ids = ["participation_trophy"] as Array[String]  # Nov 3-4: the blade is handed over at "Collect your gear"; Fix pass Nov 7: the trophy too (you showed up: that is basically winning)
	quest.reward_unlock_flags = ["armory_unlocked"] as Array[String]
	return quest


## Overnight Oct 17, Part 9 / Oct 20, Part 4: the first deck edit, taught by doing - now Maren's second errand (after Meet the Merchants):
## open the Deck Station and save the deck to a slot (every save goes through the slot picker, `Session.save_deck_to_slot`).
const FIRST_DECK_EDIT: String = "first_deck_edit"
## Fixes Oct 25, Part 6: the quest's first step is opening a pack (any pack, `Session.open_pack` sets this flag). A player with no pack gets
## one General Pack when the quest starts (`Session.grant_first_pack`); saves already on or past the quest have the step settled
## (`QuestMigration`, version 4).
const FIRST_PACK_FLAG: String = "first_pack_opened"
const FIRST_PACK_ID: String = "general_1"


static func _first_deck_edit() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = FIRST_DECK_EDIT
	quest.category = QuestData.Category.SIDE
	quest.line = SETTLING_IN
	quest.order = 2
	quest.title = "Make It Yours"
	quest.summary = "Maren says a deck you never chose is a deck you'll lose with. Open a pack for some new cards, then make the deck your own at the Deck Station."
	quest.giver_npc = MAREN
	quest.giver_area = "town"
	quest.giver_spot = "elder"
	quest.turn_in_npc = MAREN
	quest.turn_in_area = "town"
	quest.turn_in_spot = "elder"
	quest.prerequisite = Condition.quest_completed(MERCHANTS)
	quest.objectives = [
		QuestObjective.make("Open a pack", Condition.flag(FIRST_PACK_FLAG)).at(QuestObjective.TargetKind.NONE, "", "", "Menu (top right), then Packs - or press P").in_menu(),
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
	quest.category = QuestData.Category.SIDE
	quest.line = SETTLING_IN
	quest.order = 3
	quest.title = "Something in the Store Room"
	quest.summary = "Tilly Tonic's store room has been rattling and moaning for a week, and nobody can get in. Maren wants it sorted, and so, very much, does Tilly."
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
	quest.summary = "That giant chest was too good to be true. Someone is conning travellers with chests like it, and he's taken your gold. Find the rest of the chests, and you'll find him."
	# Fable pass Nov 10 (Part 1.1): every giant chest still shut is marked (Crosspath's by the harbour, one per Path zone); the Master shows up
	# at the original chest in town.
	var chests: QuestObjective = QuestObjective.make("Open the giant chests", Condition.counter(NinjaBoss.COUNTER_OPENED, NinjaBoss.CHEST_IDS.size()))
	for chest_id: String in NinjaBoss.CHEST_IDS:
		var area: String = "town" if chest_id == NinjaBoss.ORIGINAL_CHEST else chest_id
		var spot: String = QuestMarkers.SPOT_HARBOR_CHEST if chest_id == NinjaBoss.ORIGINAL_CHEST else "giant_chest"
		chests.part(QuestObjective.TargetKind.SPOT, area, spot, "A giant chest", Condition.secret_found(NinjaBoss.secret_id(chest_id)))
	quest.objectives = [
		chests,
		QuestObjective.make("Face the Master of the Oldest Trick", Condition.flag(str(NinjaBoss.FLAG_DEFEATED)))
			.at(QuestObjective.TargetKind.BATTLE, "town", QuestMarkers.SPOT_HARBOR_CHEST, "The giant chest by Crosspath's harbour"),
	] as Array[QuestObjective]
	return quest


## Brief 16, Group G: a hidden quest, started by Session.pull_vault_lever the first time any of the four levers is pulled (never auto-given).
static func _four_seals() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = VaultGuardian.QUEST_ID
	quest.category = QuestData.Category.SIDE
	quest.order = 141
	quest.title = "The Four Seals"
	quest.summary = "Somewhere far off, a great lock has ground open. Each Path zone hides a lever that answers a seal near Crosspath. Find all four."
	# Fable pass Nov 10 (Part 1.1): each zone's lever is marked until it is pulled.
	var levers: QuestObjective = QuestObjective.make("Find the hidden lever in each Path zone", Condition.counter(VaultGuardian.COUNTER_LEVERS, VaultGuardian.ZONE_IDS.size()))
	for zone_id: String in VaultGuardian.ZONE_IDS:
		levers.part(QuestObjective.TargetKind.SPOT, zone_id, "vault_lever", "A hidden lever", Condition.flag(str(VaultGuardian.flag_for(zone_id))))
	quest.objectives = [
		levers,
		QuestObjective.make("Open the Four-Seal Vault", Condition.flag(str(VaultGuardian.FLAG_DEFEATED))).at(QuestObjective.TargetKind.SPOT, "town", "vault4", "The Four-Seal Vault, in the hills north of Crosspath"),
	] as Array[QuestObjective]
	return quest
