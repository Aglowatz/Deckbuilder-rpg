class_name RotheartDungeon
extends RefCounted
## THE ROTHEART (Refusemancers): deep within the corrupted ecosystem, at the source of the magical infection.
## The deeper the heroes go, the more warped the Verdant Dump's nature becomes: uncontrolled plants, mutated
## fungi, invasive roots. Boss: the corrupted Refusemancer leader (Archdruid Fernwick Loam) at the corrupted
## core; defeating them severs the big bad's influence over the natural world. 13 nodes, three branch
## points that rejoin. The map has four sections that grow stranger: outskirts, grove, root tunnels, heartwood.
## Text: data/story/refusemancer_story.tres (`dungeon.rh_*`, `event.rh_*`, `cutscene.sever.*`).

const ZONE_ID: String = "refusemancer"
const REWARD_CARD_ID: String = "R-33"


static func build_def() -> MainDungeonDef:
	var def: MainDungeonDef = MainDungeonDef.new()
	def.zone_id = ZONE_ID
	def.dungeon_name = "The Rotheart"
	def.backdrop = "rotheart"
	def.reward_card_id = REWARD_CARD_ID
	def.reward_gold = 220
	def.reward_xp = 160
	def.add_foe("Overgrown Scarecrow", 12, "Balanced", EnemyDecks.trimmed("refuse_rats", 27, 16), "lorc/sprout")
	def.add_foe("Mutant Mushroom Troop", 14, "Aggressive", EnemyDecks.trimmed("refuse_garbage", 28, 16), "delapouite/mushrooms-cluster")
	def.add_foe("Strangler Vine", 15, "Defensive", EnemyDecks.trimmed("refuse_rats", 29, 16), "delapouite/plant-roots")
	def.add_foe("Rootbound Golem", 19, "Defensive", EnemyDecks.trimmed("refuse_garbage", 32, 15), "delapouite/tree-roots")
	def.add_foe("Root Tunnel Horror", 16, "Aggressive", EnemyDecks.trimmed("refuse_rats", 30, 16), "lorc/root-tip")
	def.add_foe("The Heartwood Treant", 22, "Balanced", EnemyDecks.trimmed("refuse_garbage", 34, 15), "cathelineau/tree-face")
	def.add_foe("Archdruid Fernwick Loam", 28, "Balanced", EnemyDecks.with_cards(EnemyDecks.recipe("refuse_garbage", 17), {"R-33": 1}), "cathelineau/tree-face")
	# The Spore Gauntlet (node 5): do you have enough sturdy bodies to push through?
	var gauntlet: ChallengeData = MainDungeonDef.make_challenge("rh_spore_gauntlet", "The Spore Gauntlet", "", ChallengeData.Kind.TOP_N_INFRASTRUCTURE_COUNT, 5, 2)
	gauntlet.on_success = [MainDungeonDef.outcome(ChallengeOutcome.Kind.HEAL, 4, "Heal 4 HP.")] as Array[ChallengeOutcome]
	gauntlet.on_failure = [MainDungeonDef.outcome(ChallengeOutcome.Kind.LOSE_HP, 3, "Lose 3 HP.")] as Array[ChallengeOutcome]
	def.add_challenge(gauntlet)
	# The Whispering Mushrooms (node 3).
	var mushrooms: DungeonEvent = DungeonEvent.make("rh_mushrooms")
	mushrooms.choice([DungeonEvent.heal(4), DungeonEvent.damage(1)] as Array[DungeonEvent.Outcome])
	mushrooms.choice([DungeonEvent.boon(MainDungeonDef.boon_source("Spore-Sight", [CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 1, Modifier.ANY_COLOR, 0)] as Array[Modifier]))] as Array[DungeonEvent.Outcome])
	mushrooms.choice([DungeonEvent.gold(35)] as Array[DungeonEvent.Outcome])
	def.add_event(mushrooms)
	# The Pulsing Wall (node 10).
	var wall: DungeonEvent = DungeonEvent.make("rh_pulsing_wall")
	wall.choice([DungeonEvent.damage(2), DungeonEvent.boon(MainDungeonDef.boon_source("Root-Bound", [CardBuilder.modifier(Modifier.Kind.MAX_HP, 4)] as Array[Modifier]))] as Array[DungeonEvent.Outcome])
	wall.choice([DungeonEvent.heal(5)] as Array[DungeonEvent.Outcome])
	wall.choice([DungeonEvent.gold(60), DungeonEvent.damage(1)] as Array[DungeonEvent.Outcome])
	def.add_event(wall)
	return def


static func build_map(def: MainDungeonDef) -> DungeonMap:
	var map: DungeonMap = DungeonMap.new()
	map.dungeon_name = def.dungeon_name
	var start: DungeonMap.MapNode = def.node(map, DungeonMap.Kind.START, "rh_gate", Vector2(0.06, 0.5), "outskirts")
	var outskirts: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.BATTLE, "rh_outskirts", Vector2(0.15, 0.5), "Overgrown Scarecrow", "outskirts")
	var grove: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.BATTLE, "rh_grove", Vector2(0.25, 0.27), "Mutant Mushroom Troop", "grove")
	var mushrooms: DungeonMap.MapNode = def.event_node(map, "rh_mushrooms", Vector2(0.25, 0.73), "rh_mushrooms", "grove")
	var soil: DungeonMap.MapNode = def.shrine_node(map, "rh_soil", Vector2(0.35, 0.5), 6, "grove")
	var gauntlet: DungeonMap.MapNode = def.challenge_node(map, "rh_gauntlet", Vector2(0.45, 0.27), "rh_spore_gauntlet", "root tunnels")
	var thicket: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.BATTLE, "rh_thicket", Vector2(0.45, 0.73), "Strangler Vine", "root tunnels")
	var vault: DungeonMap.MapNode = def.treasure_node(map, "rh_vault", Vector2(0.55, 0.5), {"gold": 85, "xp": 40, "item": "vitality_charm"}, "root tunnels")
	var golem: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.ELITE, "rh_golem", Vector2(0.64, 0.5), "Rootbound Golem", "root tunnels")
	var tunnels: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.BATTLE, "rh_tunnels", Vector2(0.73, 0.27), "Root Tunnel Horror", "heartwood")
	var wall: DungeonMap.MapNode = def.event_node(map, "rh_wall", Vector2(0.73, 0.73), "rh_pulsing_wall", "heartwood")
	var treant: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.ELITE, "rh_treant", Vector2(0.83, 0.5), "The Heartwood Treant", "heartwood")
	var boss: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.BOSS, "rh_boss", Vector2(0.94, 0.5), "Archdruid Fernwick Loam", "the Rotheart")
	boss.after_scene = "sever"
	def.link(map, [start.id], outskirts.id)
	def.link(map, [outskirts.id], grove.id)
	def.link(map, [outskirts.id], mushrooms.id)
	def.link(map, [grove.id, mushrooms.id], soil.id)
	def.link(map, [soil.id], gauntlet.id)
	def.link(map, [soil.id], thicket.id)
	def.link(map, [gauntlet.id, thicket.id], vault.id)
	def.link(map, [vault.id], golem.id)
	def.link(map, [golem.id], tunnels.id)
	def.link(map, [golem.id], wall.id)
	def.link(map, [tunnels.id, wall.id], treant.id)
	def.link(map, [treant.id], boss.id)
	return map
