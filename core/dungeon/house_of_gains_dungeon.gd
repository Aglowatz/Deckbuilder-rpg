class_name HouseOfGainsDungeon
extends RefCounted
## THE HOUSE OF GAINS (Beefcakes): the regime's stronghold. A major section is the IRON-LESS PRISON:
## the player descends, rescues the original leader (Grandmaster Flex: emaciated and decrepit), who then joins as a
## dungeon-wide boon for the rest of the run, and continues through the House. At the final
## confrontation a short scene (cutscene "flex"): he throws off his outer clothing, still incredibly
## muscular, and explains that true strength comes from the heart and the mind. Boss: Chancellor Clench.
## 13 nodes: two routes that split and rejoin, and the optional Iron-less Prison branch (skipping nodes 8-9 skips the rescue). The map, nodes, foes and rewards come
## from `data/source/dungeon_list.csv.csv` through `DungeonBuilder`.
## Text: data/story/gainlands_story.tres (`dungeon.hg_*`, `event.hg_*`, `cutscene.rescue.*`, `cutscene.flex.*`).

const ZONE_ID: String = "beefcake"
const DUNGEON_ID: String = "D-HOG"
const REWARD_CARD_ID: String = "B-32"
const RESCUE_NODE_KEY: String = "hg_rescue"
const BOON_NAME: String = "Grandmaster Flex Fights Beside You"
## The rescued leader as a card-game ally (the token sheet's T-15): he starts on your field in the boss fight.
const ALLY_TOKEN_ID: String = "T-15"


## True when the player rescued the leader in this run (the rescue event grants the boon).
static func rescued(run: DungeonRun) -> bool:
	for source: ModifierSource in run.dungeon_sources:
		if source.source_name == BOON_NAME:
			return true
	return false


## Puts Grandmaster Flex, the Unbroken on the player's field (ready) at the start of the boss duel.
static func place_ally(game: GameState) -> CardInstance:
	var data: CardData = TokenRegistry.data(ALLY_TOKEN_ID)
	if data == null:
		return null
	var ally: CardInstance = game.create_token(0, data)
	ally.summoning_sick = false
	return ally

## Grandmaster Flex's dungeon-wide boon: strength of heart and mind (+1/+1 to all your units, +3 max HP).
static func heartlift_boon() -> ModifierSource:
	return MainDungeonDef.boon_source(BOON_NAME, [
		CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 1, Modifier.ANY_COLOR, 1),
		CardBuilder.modifier(Modifier.Kind.MAX_HP, 3),
	] as Array[Modifier])


static func build_def() -> MainDungeonDef:
	var def: MainDungeonDef = DungeonBuilder.build_def(DungeonCatalog.find(DUNGEON_ID))
	def.backdrop = "house"
	def.reward_gold = 220
	def.reward_xp = 160
	def.boon = heartlift_boon()
	# The Stairs to the Iron-less Prison (node 7).
	var descent: DungeonEvent = DungeonEvent.make("hg_descent")
	descent.choice([DungeonEvent.nothing()] as Array[DungeonEvent.Outcome])
	descent.choice([DungeonEvent.gold(40), DungeonEvent.damage(2)] as Array[DungeonEvent.Outcome])
	descent.choice([DungeonEvent.heal(3)] as Array[DungeonEvent.Outcome])
	def.add_event(descent)
	# The Iron-less Prison (node 9): the rescue. The BOON outcome IS the rescue: Grandmaster Flex joins and fights beside you in the boss duel.
	var rescue: DungeonEvent = DungeonEvent.make("hg_rescue")
	rescue.choice([DungeonEvent.boon(def.boon)] as Array[DungeonEvent.Outcome])
	def.add_event(rescue)
	return def
