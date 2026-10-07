class_name HallOfApprovalsDungeon
extends RefCounted
## THE HALL OF FINAL APPROVALS (D-HFA, Necrocrats): the ultimate bureaucratic nightmare, a government complex where every aspect of death and
## resurrection requires authorization. Boss: Undersecretary Vellum, Acting Director of Final Approvals. 14 nodes, three routes that split and rejoin.
## The map, nodes, foes, events and rewards come from `data/source/dungeon_list.csv.csv` through `DungeonBuilder`. Text: data/story/dna_story.tres
## and the content file.

const ZONE_ID: String = "necrocrat"
const DUNGEON_ID: String = "D-HFA"
const REWARD_CARD_ID: String = "N-33"


static func build_def() -> MainDungeonDef:
	var def: MainDungeonDef = DungeonBuilder.build_def(DungeonCatalog.find(DUNGEON_ID))
	def.backdrop = "hall"
	def.reward_gold = 220
	def.reward_xp = 160
	return def
