class_name MiniDungeon
extends RefCounted
## A zone's mini dungeon: three battles in a row on the existing node-map system, then a unique
## card (one time only, flag in the zone's `ZoneDef`). It follows the zone's life rules: the run
## starts at the zone's current life, nothing heals between fights (no shrine node on purpose), and
## the life left at the end goes back to the zone. Losing wakes you at the hub (fee). Placeholder
## decks. The battles are data in the zone's `ZoneDef.mini` (D.N.A.: Quarterly Reviews).

const BATTLE_COUNT: int = 3
## The D.N.A.'s reward (kept for the existing tests/docs); other zones read `ZoneDef.mini.reward_card_id`.
const REWARD_CARD_ID: String = "deceased_ceo"
const DUNGEON_NAME: String = "Sub-Basement 3: Quarterly Reviews"


static func build_map(zone_id: String = DnaZone.ID) -> DungeonMap:
	var mini: ZoneDef.MiniDef = ZoneDefs.get_def(zone_id).mini
	var map: DungeonMap = DungeonMap.new()
	map.dungeon_name = mini.dungeon_name
	var xs: Array[float] = [0.33, 0.58, 0.84]
	var ys: Array[float] = [0.35, 0.68, 0.36]
	var previous: DungeonMap.MapNode = _node(map, DungeonMap.Kind.START, mini.start_title, mini.start_blurb, Vector2(0.09, 0.6))
	for index: int in range(mini.battles.size()):
		var battle: ZoneDef.MiniBattle = mini.battles[index]
		var difficulty: DungeonMap.Difficulty = DungeonMap.Difficulty.ELITE if battle.elite else DungeonMap.Difficulty.NORMAL
		var node: DungeonMap.MapNode = _battle(map, battle, Vector2(xs[index % xs.size()], ys[index % ys.size()]), difficulty)
		if battle.elite:
			node.kind = DungeonMap.Kind.BOSS
		map.connect_nodes(previous.id, node.id)
		previous = node
	return map


static func _battle(map: DungeonMap, battle: ZoneDef.MiniBattle, position: Vector2, difficulty: DungeonMap.Difficulty) -> DungeonMap.MapNode:
	var node: DungeonMap.MapNode = _node(map, DungeonMap.Kind.BATTLE, battle.title, battle.blurb, position)
	node.enemy_name = battle.enemy
	node.enemy_life = battle.life
	node.ai_name = battle.ai_name
	node.difficulty = difficulty
	node.gold_reward = EncounterRewards.gold_for(difficulty) / 2
	node.card_choices = 0
	return node


static func _node(map: DungeonMap, kind: DungeonMap.Kind, title: String, blurb: String, position: Vector2) -> DungeonMap.MapNode:
	var node: DungeonMap.MapNode = DungeonMap.MapNode.new()
	node.kind = kind
	node.title = title
	node.blurb = blurb
	node.position = position
	return map.add_node(node)


static func enemy_recipe(enemy_name: String, zone_id: String = DnaZone.ID) -> Dictionary:
	return ZoneDefs.get_def(zone_id).mini.recipe_for(enemy_name)


static func enemy_setup(content: ContentSet, map_node: DungeonMap.MapNode, zone_id: String = DnaZone.ID) -> PlayerSetup:
	var deck: Deck = ZoneDecks.from_recipe(content, map_node.enemy_name, enemy_recipe(map_node.enemy_name, zone_id))
	var setup: PlayerSetup = PlayerSetup.create(deck, null, [] as Array[ModifierSource], map_node.enemy_name)
	setup.starting_life = map_node.enemy_life
	setup.profile = PlayerProfile.new()
	setup.profile.max_life = maxi(map_node.enemy_life, PlayerProfile.START_MAX_LIFE)
	return setup
