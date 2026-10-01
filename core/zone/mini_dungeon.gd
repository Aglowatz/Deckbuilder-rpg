class_name MiniDungeon
extends RefCounted
## Part E: the D.N.A.'s mini dungeon, "Sub-Basement 3: Quarterly Reviews" - three battles in a row
## on the existing node-map system, then a unique Necrocrat card (one time only, see
## `DnaZone.FLAG_MINI_DUNGEON_CLEARED`). It follows the zone's life rules: the run starts at the
## zone's current life, nothing heals between meetings (no shrine node on purpose), and the life left
## at the end goes back to the zone. Losing wakes you at the hub (paperwork fee). Placeholder decks.

const DUNGEON_NAME: String = "Sub-Basement 3: Quarterly Reviews"
const BATTLE_COUNT: int = 3
const REWARD_CARD_ID: String = "deceased_ceo"


static func build_map() -> DungeonMap:
	var map: DungeonMap = DungeonMap.new()
	map.dungeon_name = DUNGEON_NAME
	var start: DungeonMap.MapNode = _node(map, DungeonMap.Kind.START, "Landing", "The elevator doors open on a conference room. Nobody has been invited. Everybody is here.", Vector2(0.09, 0.6))
	var first: DungeonMap.MapNode = _battle(map, "Meeting 1: Kickoff Sync", "A meeting that could have been a memo. The memo is also here.", Vector2(0.33, 0.35), "Kickoff Facilitator", 12, "Balanced", DungeonMap.Difficulty.NORMAL)
	var second: DungeonMap.MapNode = _battle(map, "Meeting 2: Budget Review", "Every line item is a soul. Every soul is over budget.", Vector2(0.58, 0.68), "Budget Reviewer", 14, "Defensive", DungeonMap.Difficulty.NORMAL)
	var third: DungeonMap.MapNode = _battle(map, "Meeting 3: Quarterly Review", "Your performance this quarter has been: deceased.", Vector2(0.84, 0.36), "The Quarterly Reviewer", 18, "Aggressive", DungeonMap.Difficulty.ELITE)
	third.kind = DungeonMap.Kind.BOSS
	map.connect_nodes(start.id, first.id)
	map.connect_nodes(first.id, second.id)
	map.connect_nodes(second.id, third.id)
	return map


static func _battle(map: DungeonMap, title: String, blurb: String, position: Vector2, enemy: String, life: int, ai: String, difficulty: DungeonMap.Difficulty) -> DungeonMap.MapNode:
	var node: DungeonMap.MapNode = _node(map, DungeonMap.Kind.BATTLE, title, blurb, position)
	node.enemy_name = enemy
	node.enemy_life = life
	node.ai_name = ai
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


static func enemy_recipe(enemy_name: String) -> Dictionary:
	match enemy_name:
		"Kickoff Facilitator":
			return {"land:D": 15, "cubicle_zombie": 4, "overdue_intern": 3, "middle_manager": 2, "death_benefits": 1}
		"Budget Reviewer":
			return {"land:D": 15, "soul_auditor": 3, "performance_review": 2, "cubicle_zombie": 3, "take_a_number": 2, "middle_manager": 1}
		"The Quarterly Reviewer":
			return {"land:D": 16, "hr_reaper": 2, "middle_manager": 3, "soul_auditor": 2, "mandatory_fun_day": 1, "performance_review": 2, "death_benefits": 1}
	return {}


static func enemy_setup(content: ContentSet, map_node: DungeonMap.MapNode) -> PlayerSetup:
	var deck: Deck = ZoneDecks.from_recipe(content, map_node.enemy_name, enemy_recipe(map_node.enemy_name))
	var setup: PlayerSetup = PlayerSetup.create(deck, null, [] as Array[ModifierSource], map_node.enemy_name)
	setup.starting_life = map_node.enemy_life
	setup.profile = PlayerProfile.new()
	setup.profile.max_life = maxi(map_node.enemy_life, PlayerProfile.START_MAX_LIFE)
	return setup
