class_name TestKitchenDungeon
extends RefCounted
## THE TEST KITCHEN (D-TTK, Gourmands): an experimental kitchen, food laboratory and ridiculous weapons-development centre. The Doppelganger
## posing as The Grand Chef is the boss (cutscene "reveal"); the R&D Archives expose the impostor. 13 nodes, three routes that split and rejoin.
## The map, nodes, foes, events and rewards come from `data/source/dungeon_list.csv` through `DungeonBuilder`; this class only adds what is
## special to this dungeon (its backdrop and the numbers of the first-clear bonus). Text: data/story/gourmand_story.tres and the content file.

const ZONE_ID: String = "gourmand"
const DUNGEON_ID: String = "D-TTK"
const REWARD_CARD_ID: String = "G-33"


static func build_def() -> MainDungeonDef:
	var def: MainDungeonDef = DungeonBuilder.build_def(DungeonCatalog.find(DUNGEON_ID))
	def.backdrop = "kitchen"
	def.reward_gold = 220
	def.reward_xp = 160
	return def
