class_name HouseOfGainsDungeon
extends RefCounted
## THE HOUSE OF GAINS (Beefcakes): the regime's stronghold. A major section is the IRON-LESS PRISON:
## the player descends, rescues the original leader (Heartlift: emaciated and decrepit), who then joins as a
## dungeon-wide boon for the rest of the run, and continues through the House. At the final
## confrontation a short scene (cutscene "flex"): he throws off his outer clothing, still incredibly
## muscular, and explains that true strength comes from the heart and the mind. Boss: Commander Gristle.
## 13 nodes, two branch points that rejoin.
## Text: data/story/gainlands_story.tres (`dungeon.hg_*`, `event.hg_*`, `cutscene.rescue.*`, `cutscene.flex.*`).

const ZONE_ID: String = "beefcake"
const REWARD_CARD_ID: String = "B-32"
const RESCUE_NODE_KEY: String = "hg_rescue"
const BOON_NAME: String = "Heartlift Fights Beside You"
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

## Heartlift's dungeon-wide boon: strength of heart and mind (+1/+1 to all your units, +3 max HP).
static func heartlift_boon() -> ModifierSource:
	return MainDungeonDef.boon_source(BOON_NAME, [
		CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 1, Modifier.ANY_COLOR, 1),
		CardBuilder.modifier(Modifier.Kind.MAX_HP, 3),
	] as Array[Modifier])


static func build_def() -> MainDungeonDef:
	var def: MainDungeonDef = MainDungeonDef.new()
	def.zone_id = ZONE_ID
	def.dungeon_name = "The House of Gains"
	def.backdrop = "house"
	def.reward_card_id = REWARD_CARD_ID
	def.reward_gold = 220
	def.reward_xp = 160
	def.boon = heartlift_boon()
	def.add_foe("Regime Enforcer", 12, "Aggressive", EnemyDecks.trimmed("beefcake_rush", 27, 16), "delapouite/viking-head")
	def.add_foe("Cell Block Brawler", 14, "Aggressive", EnemyDecks.trimmed("beefcake_tools", 28, 16), "lorc/muscle-up")
	def.add_foe("The Iron-less Warden", 18, "Defensive", EnemyDecks.trimmed("beefcake_bruisers", 28, 15), "lorc/imprisoned")
	def.add_foe("Barracks Drill Sergeant", 16, "Aggressive", EnemyDecks.trimmed("beefcake_rush", 30, 16), "delapouite/weight-lifting-up")
	def.add_foe("Honor Guard Captain", 22, "Aggressive", EnemyDecks.trimmed("beefcake_bruisers", 33, 15), "delapouite/strong-man")
	def.add_foe("Commander Gristle", 28, "Aggressive", EnemyDecks.recipe("beefcake_bruisers", 17), "delapouite/viking-head")
	# The Calisthenics Check (node 4): the prison has no iron, so it tests bodies, not weights.
	var check: ChallengeData = MainDungeonDef.make_challenge("hg_calisthenics", "The Calisthenics Check", "", ChallengeData.Kind.FIRST_UNIT_ATTACK, 0, 3)
	var might: ChallengeOutcome = MainDungeonDef.outcome(ChallengeOutcome.Kind.GAIN_BOON, 0, "Gain +2 max HP for the dungeon.")
	might.boon = MainDungeonDef.boon_source("Prison Push-ups", [CardBuilder.modifier(Modifier.Kind.MAX_HP, 2)] as Array[Modifier])
	check.on_success = [might] as Array[ChallengeOutcome]
	check.on_failure = [MainDungeonDef.outcome(ChallengeOutcome.Kind.LOSE_HP, 3, "Lose 3 HP.")] as Array[ChallengeOutcome]
	def.add_challenge(check)
	# The Descent (node 2).
	var descent: DungeonEvent = DungeonEvent.make("hg_descent")
	descent.choice([DungeonEvent.nothing()] as Array[DungeonEvent.Outcome])
	descent.choice([DungeonEvent.gold(40), DungeonEvent.damage(2)] as Array[DungeonEvent.Outcome])
	descent.choice([DungeonEvent.heal(3)] as Array[DungeonEvent.Outcome])
	def.add_event(descent)
	# The Rescue (node 6): the leader joins - the BOON outcome IS the rescue.
	var rescue: DungeonEvent = DungeonEvent.make("hg_rescue")
	rescue.choice([DungeonEvent.boon(def.boon)] as Array[DungeonEvent.Outcome])
	def.add_event(rescue)
	# The Trophy Hall (node 11).
	var trophies: DungeonEvent = DungeonEvent.make("hg_trophy_hall")
	trophies.choice([DungeonEvent.gold(60)] as Array[DungeonEvent.Outcome])
	trophies.choice([DungeonEvent.heal(4)] as Array[DungeonEvent.Outcome])
	trophies.choice([DungeonEvent.nothing()] as Array[DungeonEvent.Outcome])
	def.add_event(trophies)
	return def


static func build_map(def: MainDungeonDef) -> DungeonMap:
	var map: DungeonMap = DungeonMap.new()
	map.dungeon_name = def.dungeon_name
	var start: DungeonMap.MapNode = def.node(map, DungeonMap.Kind.START, "hg_gates", Vector2(0.06, 0.5))
	var check_point: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.BATTLE, "hg_checkpoint", Vector2(0.15, 0.5), "Regime Enforcer")
	var descent: DungeonMap.MapNode = def.event_node(map, "hg_descent", Vector2(0.24, 0.5), "hg_descent", "prison")
	var cells: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.BATTLE, "hg_cells", Vector2(0.34, 0.27), "Cell Block Brawler", "prison")
	var calisthenics: DungeonMap.MapNode = def.challenge_node(map, "hg_calisthenics", Vector2(0.34, 0.73), "hg_calisthenics", "prison")
	var warden: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.ELITE, "hg_warden", Vector2(0.44, 0.5), "The Iron-less Warden", "prison")
	var rescue: DungeonMap.MapNode = def.event_node(map, "hg_rescue", Vector2(0.53, 0.5), "hg_rescue", "prison", "rescue")
	var stretch: DungeonMap.MapNode = def.shrine_node(map, "hg_stretch", Vector2(0.62, 0.5), 6)
	var barracks: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.BATTLE, "hg_barracks", Vector2(0.71, 0.27), "Barracks Drill Sergeant")
	var locker: DungeonMap.MapNode = def.treasure_node(map, "hg_locker", Vector2(0.71, 0.73), {"gold": 90, "xp": 40, "item": "sharpening_stone"})
	var guard: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.ELITE, "hg_guard", Vector2(0.8, 0.5), "Honor Guard Captain")
	var trophy: DungeonMap.MapNode = def.event_node(map, "hg_trophy", Vector2(0.88, 0.5), "hg_trophy_hall")
	var boss: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.BOSS, "hg_boss", Vector2(0.95, 0.5), "Commander Gristle")
	boss.scene = "flex"
	def.link(map, [start.id], check_point.id)
	def.link(map, [check_point.id], descent.id)
	def.link(map, [descent.id], cells.id)
	def.link(map, [descent.id], calisthenics.id)
	def.link(map, [cells.id, calisthenics.id], warden.id)
	def.link(map, [warden.id], rescue.id)
	def.link(map, [rescue.id], stretch.id)
	def.link(map, [stretch.id], barracks.id)
	def.link(map, [stretch.id], locker.id)
	def.link(map, [barracks.id, locker.id], guard.id)
	def.link(map, [guard.id], trophy.id)
	def.link(map, [trophy.id], boss.id)
	return map
