class_name TrialOfTheHollow
extends RefCounted
## The intro dungeon: a short cave trial that teaches the game. Two battles, a deck challenge,
## a healing shrine and a boss. Enemy decks are small hand-made lists of placeholder cards.

const DUNGEON_NAME: String = "Trial of the Hollow"
const BLESSING_LIFE: int = 10
const CHALLENGE_ID: String = "hollow_well"


## The dungeon-wide rule: the Hollow's blessing raises max life so a run can survive three duels.
static func blessing() -> ModifierSource:
	return CardBuilder.modifier_source(
		"Hollow's Blessing",
		ModifierSource.SourceKind.DUNGEON,
		[CardBuilder.modifier(Modifier.Kind.MAX_LIFE, BLESSING_LIFE)] as Array[Modifier],
	)


static func build_map() -> DungeonMap:
	var map: DungeonMap = DungeonMap.new()
	map.dungeon_name = DUNGEON_NAME
	var start: DungeonMap.MapNode = _node(map, DungeonMap.Kind.START, "Cave Mouth", "The trial begins.", Vector2(0.09, 0.68))
	var first: DungeonMap.MapNode = _node(map, DungeonMap.Kind.BATTLE, "Scavenger's Den", "A hungry scavenger guards the first chamber.", Vector2(0.27, 0.38))
	first.enemy_name = "Cave Scavenger"
	first.enemy_life = 8
	first.ai_name = "Defensive"
	first.gold_reward = 40
	first.card_choices = 3
	first.tutorial = true
	var challenge: DungeonMap.MapNode = _node(map, DungeonMap.Kind.CHALLENGE, "The Hollow Well", "Five cards fall into the well. Will it answer?", Vector2(0.46, 0.68))
	challenge.challenge_id = CHALLENGE_ID
	var second: DungeonMap.MapNode = _node(map, DungeonMap.Kind.BATTLE, "Mossy Gallery", "Something with claws prowls between the roots.", Vector2(0.63, 0.36))
	second.enemy_name = "Hollow Stalker"
	second.enemy_life = 10
	second.ai_name = "Balanced"
	second.gold_reward = 60
	second.card_choices = 3
	var shrine: DungeonMap.MapNode = _node(map, DungeonMap.Kind.SHRINE, "Whispering Shrine", "A quiet place to rest before the last chamber.", Vector2(0.78, 0.68))
	shrine.heal_amount = 8
	var boss: DungeonMap.MapNode = _node(map, DungeonMap.Kind.BOSS, "Heart of the Hollow", "The spring's guardian wakes.", Vector2(0.92, 0.34))
	boss.enemy_name = "Hollow Warden"
	boss.enemy_life = 14
	boss.ai_name = "Aggressive"
	boss.gold_reward = 120
	boss.card_choices = 3
	map.connect_nodes(start.id, first.id)
	map.connect_nodes(first.id, challenge.id)
	map.connect_nodes(challenge.id, second.id)
	map.connect_nodes(second.id, shrine.id)
	map.connect_nodes(shrine.id, boss.id)
	return map


static func _node(map: DungeonMap, kind: DungeonMap.Kind, title: String, blurb: String, position: Vector2) -> DungeonMap.MapNode:
	var map_node: DungeonMap.MapNode = DungeonMap.MapNode.new()
	map_node.kind = kind
	map_node.title = title
	map_node.blurb = blurb
	map_node.position = position
	return map.add_node(map_node)


## Enemy deck recipes: card id (or "land:<A|B|C|D>") -> copies.
static func enemy_recipe(enemy_name: String) -> Dictionary:
	match enemy_name:
		"Cave Scavenger":
			return {
				"land:A": 12, "sellsword": 4, "cave_bat": 3, "stone_sentinel": 2, "ember_imp": 3,
				"raider": 2, "firebolt": 2, "field_medic": 2, "supply_cache": 2, "rusty_curse": 2,
			}
		"Hollow Stalker":
			return {
				"land:C": 9, "land:B": 4, "sellsword": 3, "cave_bat": 2, "ironclad": 2, "mossback_bear": 3,
				"rampaging_boar": 2, "stag_warden": 2, "growth": 2, "frost_sentry": 2, "rusty_curse": 2,
				"supply_cache": 2, "merchant": 1,
			}
		"Hollow Warden":
			return {
				"land:D": 9, "land:C": 7, "bone_servant": 3, "grave_tender": 2, "martyr": 2, "bloodthirst_wolf": 3,
				"soul_drain": 2, "necromancer": 1, "ironclad": 2, "stone_sentinel": 2, "mossback_bear": 2,
				"rampaging_boar": 2, "dark_bargain": 1, "field_medic": 2,
			}
	return {}


static func enemy_deck(content: ContentSet, enemy_name: String) -> Deck:
	var deck: Deck = Deck.new()
	deck.deck_name = enemy_name
	var recipe: Dictionary = enemy_recipe(enemy_name)
	for key: Variant in recipe.keys():
		var id: String = str(key)
		var card: CardData = null
		if id.begins_with("land:"):
			var color: Affinity.Type = ["", "A", "B", "C", "D"].find(id.substr(5)) as Affinity.Type
			card = content.lands[int(color)] as CardData
		else:
			card = content.card(id)
		if card == null:
			push_warning("TrialOfTheHollow: unknown card %s" % id)
			continue
		for i: int in range(int(recipe[key])):
			deck.cards.append(card)
	return deck


static func personality(content: ContentSet, ai_name: String) -> AIPersonality:
	for candidate: AIPersonality in content.personalities:
		if candidate.personality_name == ai_name:
			return candidate
	return AIPersonality.balanced()


## The enemy seat for a battle or boss node.
static func enemy_setup(content: ContentSet, map_node: DungeonMap.MapNode) -> PlayerSetup:
	var setup: PlayerSetup = PlayerSetup.create(
		enemy_deck(content, map_node.enemy_name), null, [] as Array[ModifierSource], map_node.enemy_name
	)
	if map_node.enemy_life > 0:
		setup.starting_life = map_node.enemy_life
		setup.profile = PlayerProfile.new()
		setup.profile.max_life = maxi(map_node.enemy_life, PlayerProfile.START_MAX_LIFE)
	return setup
