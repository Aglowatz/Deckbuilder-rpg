class_name PathologyLab
extends RefCounted
## THE PATH-OLOGY LAB (D-LAB, Story v2 Part H): the postgame dungeon beneath the forest where the Wanderer woke. Primm's Path-ologists held Prince Tessar
## here for ten years and drained his power. 14 nodes with two routes that split and rejoin: the break room's notes, the prince's old cell (ten years of
## tally marks and a child's drawing of four colors), the draining chamber, the captured Rescuer (rescue node: they join as a dungeon-wide boon) and the Chief
## Path-ologist, Dr. Ambrose Siphon (boss). The encounters are placeholders built to be far harder than Primm's Castle: balance is not tuned.
## The map, nodes, foes and rewards come from `data/dungeons/postgame_dungeons.json` (until the designer's sheet has a node list) and
## `data/dungeons/dungeon_content.json` through `DungeonBuilder`. The painted map and battleboard (MAP-LAB / BB-LAB) are placeholders for the art pipeline.

const DUNGEON_ID: String = "D-LAB"
const BOON_NAME: String = "The Rescuer Fights Beside You"
## The flags: the Lab was cleared once, and the captured Rescuer was freed (they then stand in the forest, hood down).
const FLAG_CLEARED: StringName = &"lab_cleared"
const FLAG_RESCUER_FREED: StringName = &"rescuer_freed"
## Set by Rip's tip: the portal station in the forest is open, and the Lab's hatch stands revealed in the clearing.
const FLAG_FOREST_OPEN: StringName = &"rift_station_forest"
const FLAG_REVEALED: StringName = &"lab_revealed"
## The first-clear rewards besides the unique card (the card id is the "(C-34)" of the dungeon's reward text).
const REWARD_EQUIPMENT_ID: String = "siphons_lens"
const REWARD_GOLD: int = 400
const REWARD_XP: int = 400


## True when the player freed the Rescuer in this run (the rescue node grants the boon).
static func rescued(run: DungeonRun) -> bool:
	if run == null:
		return false
	for source: ModifierSource in run.dungeon_sources:
		if source.source_name == BOON_NAME:
			return true
	return false


## The freed Rescuer's boon: a captured ally of the Wanderer who knows the lab by heart (+1/+1 to all your units, +3 max HP).
static func rescuer_boon() -> ModifierSource:
	return MainDungeonDef.boon_source(BOON_NAME, [
		CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 1, Modifier.ANY_COLOR, 1),
		CardBuilder.modifier(Modifier.Kind.MAX_HP, 3),
	] as Array[Modifier])


static func build_def() -> MainDungeonDef:
	var def: MainDungeonDef = DungeonBuilder.build_def(DungeonCatalog.find(DUNGEON_ID))
	def.backdrop = "hall"
	def.reward_gold = REWARD_GOLD
	def.reward_xp = REWARD_XP
	def.boon = rescuer_boon()
	return def


## True once Rip has opened the forest (Primm is down and Rip has told the Wanderer about it).
static func is_open(flags: Dictionary) -> bool:
	return bool(flags.get(str(FLAG_REVEALED), false))
