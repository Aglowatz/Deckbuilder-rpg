class_name PathologyLab
extends RefCounted
## THE PATH-OLOGY LAB (D-LAB): the postgame dungeon beneath the forest where the Wanderer woke. Primm's Path-ologists held Prince Tessar here for
## ten years and drained his power, and Percival Plume sent Elowen back here. Oct 21: the sheet's 16-node layout (data/source/dungeon_list.csv):
## dual- and tri-Path foes; the Observation Deck's notes on "the Subject"; the Draining Chamber; an optional branch (Cell Block, then Cell 4,
## the prince's own old cell, where Elowen is held: "Took you long enough, Tess."); the Mentor's Study (Siphon's journal: he opened the doors at
## the coup); and Dr. Ambrose Siphon, Chief Path-ologist, a four-Path boss with four one-sided Protocols (`ProtocolJam`). Freed, Elowen stands
## on your field in the boss fight as T-24 and jams one Protocol a turn; if she was not freed she confronts her father after the fight.
## Dungeon rule Specimen Conditions (`DungeonRules`): your max life -5, enemy units +1/+1. Story scenes: data/story/story_scenes.json `lab_*`.

const DUNGEON_ID: String = "D-LAB"
## The run-level marker of the rescue (a boon with no numbers: Elowen herself is the help, `place_ally`).
const BOON_NAME: String = "Elowen Fights Beside You"
## The flags: the Lab was cleared once, and Elowen is free (she then stands in the forest).
const FLAG_CLEARED: StringName = &"lab_cleared"
const FLAG_RESCUER_FREED: StringName = &"rescuer_freed"
## Set by Rip's tip: the portal station in the forest is open, and the Lab's hatch stands revealed in the clearing.
const FLAG_FOREST_OPEN: StringName = &"rift_station_forest"
const FLAG_REVEALED: StringName = &"lab_revealed"
## The first-clear rewards besides the unique card (the card id is the "(C-34)" of the dungeon's reward text).
const REWARD_EQUIPMENT_ID: String = "siphons_lens"
const REWARD_GOLD: int = 400
const REWARD_XP: int = 400
## Cell 4's event (built here, after the boon exists).
const RESCUE_EVENT: String = "lab_cell4"


## True when the player freed Elowen in this run.
static func rescued(run: DungeonRun) -> bool:
	if run == null:
		return false
	for source: ModifierSource in run.dungeon_sources:
		if source.source_name == BOON_NAME:
			return true
	return false


## The rescue's marker in the run (shown with the run's boons; Elowen's help is her token in the boss fight).
static func rescuer_boon() -> ModifierSource:
	return MainDungeonDef.boon_source(BOON_NAME, [] as Array[Modifier])


## Puts Elowen Vey, Defector (T-24) on the player's field (ready) at the start of the Siphon fight.
static func place_ally(game: GameState) -> CardInstance:
	var data: CardData = TokenRegistry.data(ProtocolJam.ALLY_TOKEN_ID)
	if data == null:
		return null
	var ally: CardInstance = game.create_token(0, data)
	ally.summoning_sick = false
	return ally


static func build_def() -> MainDungeonDef:
	var def: MainDungeonDef = DungeonBuilder.build_def(DungeonCatalog.find(DUNGEON_ID))
	def.backdrop = "lab"
	def.reward_gold = REWARD_GOLD
	def.reward_xp = REWARD_XP
	def.boon = rescuer_boon()
	# Cell 4 (node 11): the BOON outcome IS the rescue, as in the House of Gains.
	var rescue: DungeonEvent = DungeonEvent.make(RESCUE_EVENT)
	rescue.choice([DungeonEvent.boon(def.boon)] as Array[DungeonEvent.Outcome])
	def.add_event(rescue)
	return def


## True once Rip has opened the forest (Primm is down and Rip has told the Wanderer about it).
static func is_open(flags: Dictionary) -> bool:
	return bool(flags.get(str(FLAG_REVEALED), false))
