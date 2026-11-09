class_name CardMatchCircuit
extends RefCounted
## Overnight Nov 7-8, Part 6.3: the Cardsharp's Circuit. Dex Shufflewick, a travelling cardsharp (the generic townsfolk sprite and portrait,
## NPC-TOWNSFOLK: no story character), keeps a card-matching table in each of the four Path zones, each dealt from that Path's own card art
## (the D.N.A.'s Rec Room game uses nostalgia icons; this one uses real cards). Beat Dex's score at all four tables, then the final table
## (two cards of every Path) to win his Matching Pair. One quest, "The Cardsharp's Circuit" (QuestDefinitions). Pure rules.

const ZONES: Array[String] = ["beefcake", "necrocrat", "gourmand", "refusemancer"]
const FINAL: String = "final_table"
## Fixes Nov 8: Dex has his own art coming in Batch 13 (portrait NPC-DEX, sprite set SPR-DEX: REF, FRONT/SIDE/BACK idle, FRONT_TALK). He is
## NPC-DEX in the registry; until the art is imported the portrait falls back to the townsfolk's and the sprite to the shared CITIZEN set.
const NPC_ID: String = "NPC-DEX"
const SPRITE_KEY: String = "DEX"
const STAND_IN_PORTRAIT: String = "NPC-TOWNSFOLK"
const STAND_IN_SPRITE: String = "CITIZEN"


## The portrait id to show for Dex right now.
static func portrait_id() -> String:
	return NPC_ID if Portraits.has_portrait(NPC_ID) else STAND_IN_PORTRAIT


## The sprite set to draw Dex with right now.
static func sprite_key() -> String:
	return SPRITE_KEY if SpriteLibrary.has_character(SPRITE_KEY) else STAND_IN_SPRITE
const SPEAKER: String = "Dex Shufflewick"
const TITLE: String = "Dex Shufflewick, Travelling Cardsharp"
const QUEST_ID: String = "cardsharps_circuit"
const MET_FLAG: String = "cardsharp_met"
const PRIZE_ID: String = "dex_matching_pair"
## Beat Dex's score: find all eight pairs in at most this many moves. Overnight Nov 9, Part 3: was 12 / 11 out of 14, which even a PERFECT memory
## beat only 55 % / 9 % of the time (8 pairs need 12.4 moves on average with perfect recall). Now 15 / 14 out of TABLE_MAX_MOVES: a player who
## forgets 5-10 % of what they saw each move beats a zone table 82-97 % and the final 61-87 % of the time (docs/minigames/dex_odds_nov9.md).
const TARGET_MOVES: int = 15
const FINAL_TARGET_MOVES: int = 14
const TABLE_MAX_MOVES: int = 20
## Where Dex stands in each zone: beside the zone's trivia-giver.
const ANCHOR: String = "quiz"
const OFFSET: Vector3 = Vector3(-1.8, 0.0, 1.8)


static func flag_name(table: String) -> String:
	return "cardsharp_%s" % table


static func target_for(table: String) -> int:
	return FINAL_TARGET_MOVES if table == FINAL else TARGET_MOVES


## True once all four zone tables are beaten (the final table opens).
static func final_open(flags: Dictionary) -> bool:
	for zone_id: String in ZONES:
		if not bool(flags.get(flag_name(zone_id), false)):
			return false
	return true


## The eight card ids a table deals (each appears twice): eight GENERAL cards of the zone's Path that have art, in id order; the final table
## takes two from each Path.
static func card_ids(table: String, content: ContentSet) -> Array[String]:
	var result: Array[String] = []
	if table == FINAL:
		for zone_id: String in ZONES:
			var some: Array[String] = _path_cards(ZoneEffects.path_of(zone_id), content)
			result.append_array(some.slice(0, 2))
		return result
	return _path_cards(ZoneEffects.path_of(table), content).slice(0, MatchGame.PAIRS)


static func _path_cards(path: Affinity.Type, content: ContentSet) -> Array[String]:
	var ids: Array[String] = []
	for card: CardData in content.cards.values():
		if card.is_token or card.is_infrastructure() or CardAvailability.is_enemy_only(card) or CardAvailability.is_reward_locked(card):
			continue
		var paths: Array[Affinity.Type] = card.paths()
		if paths.size() != 1 or paths[0] != path or not card.is_unit():
			continue
		ids.append(card.id)
	ids.sort()
	return ids


## Records a finished table: a win in at most the target's moves sets that table's flag. Returns true when it was earned just now.
static func record(flags: Dictionary, table: String, won: bool, moves: int) -> bool:
	var key: String = flag_name(table)
	if not won or moves > target_for(table) or bool(flags.get(key, false)):
		return false
	if table == FINAL and not final_open(flags):
		return false
	flags[key] = true
	return true


## The zone entry and the talk spot ZoneDefs adds to each Path zone.
static func npc_entry() -> Dictionary:
	return {"id": "cardsharp", "npc_id": NPC_ID, "sprite": sprite_key(), "model": "Rogue", "anchor": ANCHOR, "offset": OFFSET, "yaw": 30.0, "tint": Color(1.0, 0.92, 0.75)}


static func spot_entry() -> Dictionary:
	return {"id": "cardsharp", "title": TITLE, "anchor": ANCHOR, "offset": OFFSET + Vector3(0.6, 0, 0), "radius": 1.8, "prompt": "Talk", "kind": "cardsharp",
		"npc": "cardsharp", "npc_id": NPC_ID, "speaker": SPEAKER}


## The Circuit's quest: give by Dex's first talk; one step per zone table, then the final table; pays the Matching Pair.
static func quest() -> QuestData:
	var quest: QuestData = QuestData.new()
	quest.id = QUEST_ID
	quest.category = QuestData.Category.SIDE
	quest.order = 60
	quest.title = "The Cardsharp's Circuit"
	quest.summary = "Dex Shufflewick keeps a card-matching table in every Path zone, dealt from that Path's own cards. Beat his score at all four, then sit down at his final table."
	quest.auto_give = true
	quest.prerequisite = Condition.flag(MET_FLAG)
	var steps: Array[QuestObjective] = []
	var names: Dictionary = {"beefcake": "the Gainlands", "necrocrat": "the D.N.A.", "gourmand": "the Endless Buffet", "refusemancer": "the Verdant Dump"}
	for zone_id: String in ZONES:
		steps.append(QuestObjective.make("Beat Dex's table in %s (%d moves or fewer)" % [str(names[zone_id]), TARGET_MOVES], Condition.flag(flag_name(zone_id)))
			.at(QuestObjective.TargetKind.NPC, zone_id, "cardsharp", "Dex Shufflewick, beside the trivia corner in %s" % str(names[zone_id])))
	steps.append(QuestObjective.make("Win Dex's final table (%d moves or fewer)" % FINAL_TARGET_MOVES, Condition.flag(flag_name(FINAL)))
		.at(QuestObjective.TargetKind.NPC, ZONES[0], "cardsharp", "Dex Shufflewick, in any Path zone"))
	quest.objectives = steps
	quest.reward_gold = 150
	quest.reward_xp = 150
	quest.reward_equipment_ids = [PRIZE_ID] as Array[String]
	return quest
