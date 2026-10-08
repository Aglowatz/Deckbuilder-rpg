class_name RotheartDungeon
extends RefCounted
## THE ROTHEART (D-ROT, Refusemancers): the Verdant Dump's blight at its source. Boss: Compostella, the Rotheart, the corrupted Refusemancer
## leader. Severing the Heart Roots (the event before the boss) weakens her: she starts the duel with `SEVERED_HP_LOSS` less HP (cutscene "sever" after
## the fight). 13 nodes, three routes that split and rejoin. The map, nodes, foes, events and rewards come from `data/source/dungeon_list.csv`
## through `DungeonBuilder`. Text: data/story/refusemancer_story.tres and the content file.

const ZONE_ID: String = "refusemancer"
const DUNGEON_ID: String = "D-ROT"
const REWARD_CARD_ID: String = "R-33"
const SEVERED_BOON_NAME: String = "The Heart Roots Are Severed"
const SEVERED_HP_LOSS: int = 6


static func build_def() -> MainDungeonDef:
	var def: MainDungeonDef = DungeonBuilder.build_def(DungeonCatalog.find(DUNGEON_ID))
	def.backdrop = "rotheart"
	def.reward_gold = 220
	def.reward_xp = 160
	return def


## The marker boon the Heart Roots event adds to the run (it changes no stat).
static func severed_boon() -> ModifierSource:
	return MainDungeonDef.boon_source(SEVERED_BOON_NAME, [CardBuilder.modifier(Modifier.Kind.MAX_HP, 0)] as Array[Modifier])


## True when the player severed the Heart Roots in this run.
static func severed(run: DungeonRun) -> bool:
	if run == null:
		return false
	for source: ModifierSource in run.dungeon_sources:
		if source.source_name == SEVERED_BOON_NAME:
			return true
	return false
