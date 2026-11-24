class_name DraftHost
extends RefCounted
## Draft mode: Trey Pickett, the travelling draft-master, a card shark in a striped suit and a straw boater who talks like a
## carnival auctioneer ("Pick it, pick it, PICK IT!"). A recurring character like Dex and Rip: he pushes his draft cart into each
## of the four Path zones, where he offers ONLY that zone's draft (the owner, Nov 23: choosing Paths happens at the Shuffle
## House), and gives the draft quest line: "Pick of Three" (finish any draft), one quest per zone draft, and "Last Pick, Best
## Pick" (all four won), which opens his aunt Octavia's Shuffle House in Crosspath.
## Batch 20 (Nov 23): his own portrait (NPC-TREY), world sprite (SPR-TREY) and Bestiary picture (BST-TREY) everywhere.

const NPC_ID: String = "NPC-TREY"
const SPRITE_KEY: String = "TREY"
const STAND_IN_PORTRAIT: String = "NPC-TOWNSFOLK"
const STAND_IN_SPRITE: String = "CITIZEN"
const SPEAKER: String = "Trey Pickett"
const TITLE: String = "Trey Pickett, Travelling Draft-Master"
const SPOT_ID: String = "drafthost"
const MET_FLAG: String = "drafthost_met"
const INTRO_QUEST: String = "draft_pick_of_three"
const FINALE_QUEST: String = "draft_last_pick"
## Where he stands in each zone: by the zone's trivia corner, on the other side from Dex.
const ANCHOR: String = "quiz"
const OFFSET: Vector3 = Vector3(2.6, 0.0, 2.4)
## His line while the Shuffle House is still closed and at least one zone draft is won: where it is and what opens it.
const HOUSE_HINT_KEY: String = "drafthost.house"
const ZONE_OFFSETS: Dictionary = {"refusemancer": Vector3(3.0, 0.0, 6.5)}


static func portrait_id() -> String:
	return NPC_ID if Portraits.has_portrait(NPC_ID) else STAND_IN_PORTRAIT


static func sprite_key() -> String:
	return SPRITE_KEY if SpriteLibrary.has_character(SPRITE_KEY) else STAND_IN_SPRITE


static func offset_for(zone_id: String) -> Vector3:
	return ZONE_OFFSETS.get(zone_id, OFFSET) as Vector3


static func zone_quest_id(zone_id: String) -> String:
	return "draft_zone_%s" % zone_id


## The zone entry and the talk spot ZoneDefs adds to each Path zone.
static func npc_entry(zone_id: String = "") -> Dictionary:
	var entry: Dictionary = {"id": SPOT_ID, "npc_id": NPC_ID, "sprite": sprite_key(), "model": "Rogue", "anchor": ANCHOR, "offset": offset_for(zone_id), "yaw": -30.0}
	if sprite_key() == STAND_IN_SPRITE:
		entry["tint"] = Color(0.8, 0.95, 1.2)  # only the stand-in is tinted: his own sprite (Batch 20) keeps its colours
	return entry


static func spot_entry(zone_id: String = "") -> Dictionary:
	return {"id": SPOT_ID, "title": TITLE, "anchor": ANCHOR, "offset": offset_for(zone_id) + Vector3(-0.6, 0, 0), "radius": 1.8, "prompt": "Talk", "kind": SPOT_ID,
		"npc": SPOT_ID, "npc_id": NPC_ID, "speaker": SPEAKER}


## Which of his lines fits now (keys of data/dungeons/dungeon_content.json).
static func line_key(flags: Dictionary, has_draft: bool) -> String:
	if not bool(flags.get(MET_FLAG, false)):
		return "drafthost.intro"
	if has_draft:
		return "drafthost.resume"
	if bool(flags.get(DraftChallenges.ARENA_FLAG, false)):
		return "drafthost.arena"
	return "drafthost.return"


## The draft quest line: the introduction, one quest per zone draft, the finale.
static func quests() -> Array[QuestData]:
	var result: Array[QuestData] = []
	var intro: QuestData = _quest(INTRO_QUEST, 70, "Pick of Three",
		"Trey Pickett pushes his draft cart into every Path zone: twenty-five picks, one of three each, then three fights with what you picked. It costs nothing. Play one draft to the end, win or lose.")
	intro.prerequisite = Condition.flag(MET_FLAG)
	intro.objectives = [QuestObjective.make("Finish a draft at Trey Pickett's cart (win or lose)", Condition.counter("draft_runs_finished", 1))
		.at(QuestObjective.TargetKind.NPC, DraftChallenges.ZONES[0], SPOT_ID, "Trey Pickett's draft cart, near the entrance of any Path zone")] as Array[QuestObjective]
	intro.reward_gold = 80
	intro.reward_xp = 80
	intro.reward_equipment_ids = [DraftGear.INTRO_REWARD] as Array[String]
	result.append(intro)
	var order: int = 71
	for zone_id: String in DraftChallenges.ZONES:
		var path: String = Affinity.display_name(ZoneEffects.path_of(zone_id))
		var place: String = str(DraftChallenges.ZONE_NAMES[zone_id])
		var quest: QuestData = _quest(zone_quest_id(zone_id), order, "The %s Draft" % path,
			"Win Trey Pickett's draft in %s: a deck drafted from %s and Pathless cards only, and three wins before two losses." % [place, path])
		order += 1
		quest.prerequisite = Condition.quest_completed(INTRO_QUEST)
		quest.objectives = [QuestObjective.make("Win the %s Draft in %s (three wins)" % [path, place], Condition.flag(DraftChallenges.won_flag(DraftChallenges.zone_id_for(zone_id))))
			.at(QuestObjective.TargetKind.NPC, zone_id, SPOT_ID, "Trey Pickett's draft cart, near the entrance of %s" % place)] as Array[QuestObjective]
		quest.reward_gold = 200
		quest.reward_xp = 200
		quest.reward_equipment_ids = [str(DraftGear.ZONE_REWARDS[zone_id])] as Array[String]
		result.append(quest)
	var finale: QuestData = _quest(FINALE_QUEST, order, "Last Pick, Best Pick",
		"Four carts, four Paths. Win all four of Trey Pickett's zone drafts and his aunt, Octavia Eightfold, opens the Shuffle House in Crosspath for you: the place where you choose your own Paths. (Three freed zones open it too.)")
	finale.prerequisite = Condition.quest_completed(INTRO_QUEST)
	var steps: Array[QuestObjective] = []
	for zone_id: String in DraftChallenges.ZONES:
		steps.append(QuestObjective.make("Win the %s Draft" % Affinity.display_name(ZoneEffects.path_of(zone_id)), Condition.flag(DraftChallenges.won_flag(DraftChallenges.zone_id_for(zone_id))))
			.at(QuestObjective.TargetKind.NPC, zone_id, SPOT_ID, "Trey Pickett's draft cart, near the entrance of %s" % str(DraftChallenges.ZONE_NAMES[zone_id])))
	finale.objectives = steps
	finale.reward_gold = 400
	finale.reward_xp = 400
	finale.reward_equipment_ids = [DraftGear.FINALE_REWARD] as Array[String]
	finale.reward_card_ids = [DraftRivals.TREY_CARD] as Array[String]  # Fable big pass Nov 23: his own card (Trey Pickett, C-40)
	finale.reward_unlock_flags = [DraftChallenges.ARENA_FLAG] as Array[String]
	result.append(finale)
	return result


static func _quest(id: String, order: int, title: String, summary: String) -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = id
	quest.category = QuestData.Category.SIDE
	quest.order = order
	quest.title = title
	quest.summary = summary
	quest.auto_give = true
	return quest
