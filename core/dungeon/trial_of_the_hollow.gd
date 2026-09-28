class_name TrialOfTheHollow
extends RefCounted
## The intro dungeon: a short cave trial that teaches the game. Two battles, a deck challenge,
## a healing shrine and a boss. Enemy decks are small hand-made lists of placeholder cards.

const DUNGEON_NAME: String = "Trial of the Hollow"
const CHALLENGE_ID: String = "hollow_well"

## No dungeon-wide life blessing any more (docs/design/open_questions.md D32): the tutorial run
## uses the player's plain base life (10) and is balanced to be winnable on that alone - see
## docs/balance_report.md for the simulated win rate.

const STARTER_DECK_SIZE: int = 42


## Waives the normal 45-card minimum down to the starter deck's actual size (Part C), so the
## 42-card starter is legal to play/save with (e.g. in the in-dungeon deck builder) for the whole
## trial, until the 3 reward picks bring it back up to 45 on their own.
static func deck_size_waiver() -> ModifierSource:
	var source: ModifierSource = ModifierSource.new()
	source.source_name = "Tutorial starter deck"
	source.source_kind = ModifierSource.SourceKind.DUNGEON
	var modifier: Modifier = Modifier.new()
	modifier.kind = Modifier.Kind.MIN_DECK_SIZE
	modifier.value = STARTER_DECK_SIZE - DeckValidator.MIN_DECK_SIZE
	modifier.label = "Starter deck is not full size yet"
	source.modifiers = [modifier] as Array[Modifier]
	return source


static func build_map() -> DungeonMap:
	var map: DungeonMap = DungeonMap.new()
	map.dungeon_name = DUNGEON_NAME
	var start: DungeonMap.MapNode = _node(map, DungeonMap.Kind.START, "Cave Mouth", "The trial begins.", Vector2(0.09, 0.68))
	var first: DungeonMap.MapNode = _node(map, DungeonMap.Kind.BATTLE, "Scavenger's Den", "A hungry scavenger guards the first chamber.", Vector2(0.27, 0.38))
	first.enemy_name = "Cave Scavenger"
	first.enemy_life = 3
	first.ai_name = "Aggressive (tutorial)"
	first.difficulty = DungeonMap.Difficulty.TUTORIAL
	first.gold_reward = EncounterRewards.gold_for(first.difficulty)
	first.card_choices = 3
	first.tutorial = true
	var challenge: DungeonMap.MapNode = _node(map, DungeonMap.Kind.CHALLENGE, "The Hollow Well", "Five cards fall into the well. Will it answer?", Vector2(0.46, 0.68))
	challenge.challenge_id = CHALLENGE_ID
	var second: DungeonMap.MapNode = _node(map, DungeonMap.Kind.BATTLE, "Mossy Gallery", "Something with claws prowls between the roots.", Vector2(0.63, 0.36))
	second.enemy_name = "Hollow Stalker"
	second.enemy_life = 3
	second.ai_name = "Aggressive (tutorial)"
	second.difficulty = DungeonMap.Difficulty.TUTORIAL
	second.gold_reward = EncounterRewards.gold_for(second.difficulty)
	second.card_choices = 3
	var shrine: DungeonMap.MapNode = _node(map, DungeonMap.Kind.SHRINE, "Whispering Shrine", "A quiet place to rest before the last chamber.", Vector2(0.78, 0.68))
	# Full heal: the node right before the boss (docs/design/open_questions.md D32). A plain
	# large number is enough - DungeonRun.heal() already caps at max life.
	shrine.heal_amount = 999
	var boss: DungeonMap.MapNode = _node(map, DungeonMap.Kind.BOSS, "Heart of the Hollow", "The spring's guardian wakes.", Vector2(0.92, 0.34))
	boss.enemy_name = "Hollow Warden"
	boss.enemy_life = 3
	boss.ai_name = "Balanced"
	boss.difficulty = DungeonMap.Difficulty.BOSS
	boss.gold_reward = EncounterRewards.gold_for(boss.difficulty)
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
	# Tutorial-weak (Part D): the two non-boss opponents use only low-stat vanilla creatures
	# (including 1-cost ones, same as the player's own starter) - no removal spells, no card-draw,
	# nothing that generates card advantage - and are thinner on threats/heavier on lands than a
	# normal deck, so a beginner's deck can beat them reliably (docs/balance_report.md tracks the
	# win rate). The boss is allowed real removal/value (soul_drain, necromancer) and a bigger
	# body or two - stronger, but still tuned to keep the whole dungeon's win rate above target.
	match enemy_name:
		"Cave Scavenger":
			return {
				"land:A": 17, "apprentice_blade": 1, "sellsword": 3, "cave_bat": 3, "stone_sentinel": 2,
			}
		"Hollow Stalker":
			return {
				"land:C": 11, "land:B": 8, "apprentice_blade": 1, "sellsword": 2, "cave_bat": 2,
				"mossback_bear": 2, "frost_sentry": 1,
			}
		"Hollow Warden":
			return {
				"land:D": 12, "land:C": 10, "bone_servant": 1, "grave_tender": 1,
				"bloodthirst_wolf": 1, "necromancer": 1, "mossback_bear": 1, "rampaging_boar": 1,
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
