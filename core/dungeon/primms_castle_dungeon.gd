class_name PrimmsCastleDungeon
extends RefCounted
## PRIMM'S CASTLE (the final dungeon, Brief 10 Part C): the palace of His Perfection, entered from the heart of the Capital. 30 nodes
## and heavy branching on the shared node-map system. SIDE BRANCHES DEAD-END (a treasure, an encounter, an event, lore) and the party
## doubles back to the branch point (`MapNode.return_to`). Sections, in order:
##   the Great Hall -> the Portrait Gallery (endless "improved" portraits) -> the Hall of Mirrors (mirrors that reflect only him)
##   -> the Ministry of Correction -> the Four Wings (one for each Path: the Doppelganger's lab notes, the coup orders, the
##   notarized paperwork, the corrupted seed; each a dead-end branch) -> the Archive of Good Intentions (his early journals and
##   blueprints) -> the Scale Model Chamber (a giant model of the kingdom he rearranges by hand) and the boss, PRIMM.
## Mixes battles, elites, deck challenges, events, shrines, treasure and story nodes. Serious beats: the corrected citizens, the Archive's
## journals, the last journal (he truly believes he is the hero). Text: data/story/capital_story.tres (`dungeon.pc_*`, `event.pc_*`,
## `challenge.pc_*`, `cutscene.primm_*`). The boss is `PrimmBoss` (three phases).

const ZONE_ID: String = "final"
const DUNGEON_ID: String = "D-PC"
const REWARD_CARD_ID: String = "P4-02"
const K := DungeonMap.Kind


static func build_def() -> MainDungeonDef:
	var def: MainDungeonDef = DungeonBuilder.build_def(DungeonCatalog.find(DUNGEON_ID))
	def.backdrop = "castle"
	def.reward_gold = 500
	def.reward_xp = 400
	_challenges(def)
	_events(def)
	return def


static func _challenges(def: MainDungeonDef) -> void:
	# The Hall of Mirrors (node 6): a mirror shows you what you really lead with.
	var mirror: ChallengeData = MainDungeonDef.make_challenge("pc_mirror_test", "", "", ChallengeData.Kind.FIRST_UNIT_ATTACK, 0, 3)
	mirror.on_success = [MainDungeonDef.outcome(ChallengeOutcome.Kind.GAIN_BOON, 0, "Gain the boon Unreflected."), MainDungeonDef.outcome(ChallengeOutcome.Kind.HEAL, 2, "Heal 2 HP.")] as Array[ChallengeOutcome]
	mirror.on_success[0].boon = MainDungeonDef.boon_source("Unreflected", [CardBuilder.modifier(Modifier.Kind.STARTING_HP, 2)] as Array[Modifier])
	mirror.on_failure = [MainDungeonDef.outcome(ChallengeOutcome.Kind.LOSE_HP, 2, "Lose 2 HP.")] as Array[ChallengeOutcome]
	def.add_challenge(mirror)
	# The Ministry's desk (node 9): a form of correction. Do you have the bodies to put on it?
	var desk: ChallengeData = MainDungeonDef.make_challenge("pc_ministry_desk", "", "", ChallengeData.Kind.TOP_N_TYPE_COUNT, 5, 2)
	desk.card_type = CardEnums.CardType.UNIT
	desk.on_success = [MainDungeonDef.outcome(ChallengeOutcome.Kind.HEAL, 3, "Heal 3 HP.")] as Array[ChallengeOutcome]
	desk.on_failure = [MainDungeonDef.outcome(ChallengeOutcome.Kind.LOSE_HP, 3, "Lose 3 HP.")] as Array[ChallengeOutcome]
	def.add_challenge(desk)
	# The Escalation Shelf (node 25): reforms that got out of hand; can your deck keep its footing?
	var shelf: ChallengeData = MainDungeonDef.make_challenge("pc_escalation_shelf", "", "", ChallengeData.Kind.TOP_N_INFRASTRUCTURE_COUNT, 5, 2)
	shelf.on_success = [MainDungeonDef.outcome(ChallengeOutcome.Kind.HEAL, 4, "Heal 4 HP.")] as Array[ChallengeOutcome]
	shelf.on_failure = [MainDungeonDef.outcome(ChallengeOutcome.Kind.LOSE_HP, 3, "Lose 3 HP.")] as Array[ChallengeOutcome]
	def.add_challenge(shelf)


static func _events(def: MainDungeonDef) -> void:
	var portraits: DungeonEvent = DungeonEvent.make("pc_improved_portraits")
	portraits.choice([DungeonEvent.boon(MainDungeonDef.boon_source("Sees Through the Frame", [CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 1, Modifier.ANY_COLOR, 0)] as Array[Modifier]))] as Array[DungeonEvent.Outcome])
	portraits.choice([DungeonEvent.heal(3)] as Array[DungeonEvent.Outcome])
	portraits.choice([DungeonEvent.gold(50), DungeonEvent.damage(1)] as Array[DungeonEvent.Outcome])
	def.add_event(portraits)
	var honest: DungeonEvent = DungeonEvent.make("pc_honest_mirror")
	honest.choice([DungeonEvent.heal(4), DungeonEvent.boon(MainDungeonDef.boon_source("Seen As You Are", [CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 0, Modifier.ANY_COLOR, 1)] as Array[Modifier]))] as Array[DungeonEvent.Outcome])
	honest.choice([DungeonEvent.gold(40)] as Array[DungeonEvent.Outcome])
	def.add_event(honest)
	var corrected: DungeonEvent = DungeonEvent.make("pc_corrected_citizens")
	corrected.choice([DungeonEvent.boon(MainDungeonDef.boon_source("They Were Heard", [CardBuilder.modifier(Modifier.Kind.MAX_HP, 3)] as Array[Modifier]))] as Array[DungeonEvent.Outcome])
	corrected.choice([DungeonEvent.heal(5), DungeonEvent.damage(1)] as Array[DungeonEvent.Outcome])
	corrected.choice([DungeonEvent.gold(60)] as Array[DungeonEvent.Outcome])
	def.add_event(corrected)
	var wings: DungeonEvent = DungeonEvent.make("pc_four_wings")
	wings.choice([DungeonEvent.heal(2)] as Array[DungeonEvent.Outcome])
	wings.choice([DungeonEvent.gold(40)] as Array[DungeonEvent.Outcome])
	def.add_event(wings)
	var staircase: DungeonEvent = DungeonEvent.make("pc_grand_staircase")
	staircase.choice([DungeonEvent.damage(1), DungeonEvent.gold(70)] as Array[DungeonEvent.Outcome])
	staircase.choice([DungeonEvent.heal(3)] as Array[DungeonEvent.Outcome])
	staircase.choice([DungeonEvent.boon(MainDungeonDef.boon_source("The Servants' Way", [CardBuilder.modifier(Modifier.Kind.MAX_HP, 2)] as Array[Modifier]))] as Array[DungeonEvent.Outcome])
	def.add_event(staircase)
	var journals: DungeonEvent = DungeonEvent.make("pc_early_journals")
	journals.choice([DungeonEvent.boon(MainDungeonDef.boon_source("A Good Man's Plans", [CardBuilder.modifier(Modifier.Kind.MAX_HP, 2), CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 0, Modifier.ANY_COLOR, 1)] as Array[Modifier]))] as Array[DungeonEvent.Outcome])
	journals.choice([DungeonEvent.heal(4)] as Array[DungeonEvent.Outcome])
	def.add_event(journals)
	var last: DungeonEvent = DungeonEvent.make("pc_last_journal")
	last.choice([DungeonEvent.boon(MainDungeonDef.boon_source("Understanding", [CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 1, Modifier.ANY_COLOR, 1)] as Array[Modifier]))] as Array[DungeonEvent.Outcome])
	last.choice([DungeonEvent.heal(5)] as Array[DungeonEvent.Outcome])
	def.add_event(last)


