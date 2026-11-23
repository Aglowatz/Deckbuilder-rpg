class_name PrimmsCastleDungeon
extends RefCounted
## PRIMM'S CASTLE (the final dungeon): the palace of His Perfection, entered from the heart of the Capital.
## Fable Nov 21 castle (Part 2): a LAYERED MAP - the Castle Gate, six rows of rooms (2, 4, 3, 3, 4, 4: twenty rooms) and the Model Room.
## Every link goes forward, the routes cross (the Hall of Mirrors and the Ministry are the hubs), and a run walks one room per row:
## six rooms of twenty, so no run sees everything. The four ally rooms (`CastleAllies`: the Gilded Pantry, the Beefcake, Necrocrat and
## Refusemancer wings) lie on one route that passes no heal room. The layout table is tools/castle_nov21.py (it writes the dungeon
## list's D-PC cell). Before Nov 21 the map was one middle path with dead-end side branches. The old notes, for the rooms' story:
##   the Great Hall -> the Portrait Gallery (endless "improved" portraits) -> the Hall of Mirrors (mirrors that reflect only him)
##   -> the Ministry of Correction -> the Four Wings (one for each Path: the Doppelganger's lab notes, the coup orders, the
##   notarized paperwork, the corrupted seed; each a dead-end branch) -> the Archive of Good Intentions (his early journals and
##   blueprints) -> the Model Room (a giant model of the kingdom he rearranges by hand) and the boss, PRIMM.
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
	def.reward_xp = 320  # Fable pass Nov 10 (Part 4.3): the castle's own prize, 400 x 0.8 like every completion reward
	_challenges(def)
	_events(def)
	return def


static func _challenges(def: MainDungeonDef) -> void:
	# The Mirror Maze (room 13): a mirror shows you what you really lead with.
	var mirror: ChallengeData = MainDungeonDef.make_challenge("pc_mirror_test", "", "", ChallengeData.Kind.FIRST_UNIT_ATTACK, 0, 3)
	mirror.on_success = [MainDungeonDef.outcome(ChallengeOutcome.Kind.GAIN_BOON, 0, "Gain the boon Unreflected."), MainDungeonDef.outcome(ChallengeOutcome.Kind.HEAL, 2, "Heal 2 HP.")] as Array[ChallengeOutcome]
	mirror.on_success[0].boon = MainDungeonDef.boon_source("Unreflected", [CardBuilder.modifier(Modifier.Kind.STARTING_HP, 2)] as Array[Modifier])
	mirror.on_failure = [MainDungeonDef.outcome(ChallengeOutcome.Kind.LOSE_HP, 2, "Lose 2 HP.")] as Array[ChallengeOutcome]
	def.add_challenge(mirror)


## Fable Nov 21 castle (Part 2.4): the small permanent stat boons that piled up over a castle run (about ten in the owner's last one)
## are mostly cut. Two rooms still give something that lasts to Primm: the Correction Ward Cells (room 10, "They Were Heard") and the
## Archive of Good Intentions (room 15, "A Good Man's Plans"); the Pantry Mimic's hoard gives a third (`CastleAllies.SPOILS_EVENT`).
## The other choice rooms are in data/dungeons/dungeon_content.json (D-PC) and give gold, a heal or a next-fight edge.
static func _events(def: MainDungeonDef) -> void:
	var corrected: DungeonEvent = DungeonEvent.make("pc_corrected_citizens")
	# Fable Nov 19 (Part 5.1): no purely good option in the castle either: strong boons with lasting drawbacks.
	corrected.choice([DungeonEvent.boon(MainDungeonDef.boon_source("They Were Heard", [CardBuilder.modifier(Modifier.Kind.MAX_HP, 4)] as Array[Modifier])), DungeonEvent.damage(3)] as Array[DungeonEvent.Outcome])
	corrected.choice([DungeonEvent.heal(8), DungeonEvent.boon(DungeonBuilder.boon_from("Their Voices Stay|max_hp=-6"))] as Array[DungeonEvent.Outcome])
	corrected.choice([DungeonEvent.gold(90), DungeonEvent.boon(DungeonBuilder.boon_from("Robbed the Corrected|max_hp=-8"))] as Array[DungeonEvent.Outcome])
	def.add_event(corrected)
	var journals: DungeonEvent = DungeonEvent.make("pc_early_journals")
	journals.choice([DungeonEvent.boon(MainDungeonDef.boon_source("A Good Man's Plans", [CardBuilder.modifier(Modifier.Kind.MAX_HP, 2), CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 0, Modifier.ANY_COLOR, 1)] as Array[Modifier])), DungeonEvent.damage(3)] as Array[DungeonEvent.Outcome])
	journals.choice([DungeonEvent.heal(7), DungeonEvent.boon(DungeonBuilder.boon_from("Sympathy for Him|max_hp=-6"))] as Array[DungeonEvent.Outcome])
	def.add_event(journals)
	def.add_event(spoils_event())
	def.add_event(rest_event(def))


## Fable Nov 22 night: the Archivists' Kettle, the all-allies route's one "heal for a cost" stop (room 11, after Plume's fight). The
## Garden's rules exactly: heal 6 for 60 gold, heal 6 for a drawback in the next fight (the foe's units +1 attack), or nothing.
static func rest_event(def: MainDungeonDef) -> DungeonEvent:
	var event: DungeonEvent = DungeonEvent.make(CastleAllies.REST_EVENT)
	DungeonCatalog.set_text(event.title_key(), ["The Archivists' Kettle"])
	DungeonCatalog.set_text(event.body_key(), ["Behind the last shelf of the Notarized Archives somebody keeps a kettle, a tin of biscuits and an honesty box. The kettle is still warm. A card on the tin says: \"Tea and two biscuits, %d gold. Receipts on request.\"" % CastleAllies.REST_COST])
	var names: Array[String] = ["Pay the honesty box and sit down", "Help yourself and skip the box", "Leave the kettle for the clerks"]
	var results: Array[String] = [
		"Sixty coins rattle into the box. The tea is strong, the biscuits are plain, and for five minutes nobody stamps anything.",
		"The tea is just as good unpaid for. Somebody has counted these biscuits, though, and the count goes upstairs ahead of you.",
		"You straighten the tin and walk on. The kettle goes on ticking as it cools.",
	]
	var outcomes: Array = [
		["heal:%d" % CastleAllies.REST_HEAL, "pay:%d" % CastleAllies.REST_COST],
		["heal:%d" % CastleAllies.REST_HEAL, "curse:Two Biscuits Short|foe_atk=1,next=1"],
		["nothing"],
	]
	for index: int in range(outcomes.size()):
		DungeonCatalog.set_text(event.choice_key(index), [names[index]])
		DungeonCatalog.set_text(event.result_key(index), [results[index]])
		var made: Array[DungeonEvent.Outcome] = []
		for token: Variant in outcomes[index] as Array:
			made.append(DungeonBuilder.event_outcome(str(token), def))
		event.choice(made)
	return event


## The Pantry Mimic's hoard (Part 4): after the fight, one strong boon for the rest of the run, the last fight above all. A reward, so
## its three options have no drawback. Its text is set here (`DungeonCatalog.set_text`), like a room built from the content file.
static func spoils_event() -> DungeonEvent:
	var event: DungeonEvent = DungeonEvent.make(CastleAllies.SPOILS_EVENT)
	DungeonCatalog.set_text(event.title_key(), ["The Mimic's Hoard"])
	DungeonCatalog.set_text(event.body_key(), ["The cupboard hangs open. Behind the false jars it has kept the real things: everything it copied and could never use. A Gilded Pack is already under your arm. There is room in your bag for one thing more."])
	var names: Array[String] = ["Take the second helping", "Take the stolen seasoning", "Take the Mimic's own trick"]
	var results: Array[String] = [
		"A proper dinner, kept warm for ten years by something that could not taste it. You eat it standing up, and you have not felt this solid since the forest.",
		"A twist of paper with a pinch of something red in it. Everybody you send out from now on hits a little harder, and sneezes.",
		"At the very back lies the only thing it ever kept for itself: how to look at a hand of cards and see one more. You see one more.",
	]
	var boons: Array[ModifierSource] = [
		MainDungeonDef.boon_source("Second Helping", [CardBuilder.modifier(Modifier.Kind.MAX_HP, SPOILS_MAX_HP)] as Array[Modifier]),
		MainDungeonDef.boon_source("Stolen Seasoning", [CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 1, Modifier.ANY_COLOR, 0)] as Array[Modifier]),
		MainDungeonDef.boon_source("The Mimic's Trick", [CardBuilder.modifier(Modifier.Kind.OPENING_HAND_SIZE, 1)] as Array[Modifier]),
	]
	for index: int in range(boons.size()):
		DungeonCatalog.set_text(event.choice_key(index), [names[index]])
		DungeonCatalog.set_text(event.result_key(index), [results[index]])
		event.choice([DungeonEvent.boon(boons[index])] as Array[DungeonEvent.Outcome])
	return event


const SPOILS_MAX_HP: int = 6
