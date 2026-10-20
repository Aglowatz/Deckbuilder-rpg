class_name TrialOfTheHollow
extends RefCounted
## The intro dungeon: a short cave trial that teaches the game. Two battles, a deck challenge,
## a healing shrine and a boss. Enemy decks are small hand-made lists of placeholder cards.

const DUNGEON_NAME: String = "The Forgotten Cave"
const CHALLENGE_ID: String = "hollow_well"

## No dungeon-wide HP blessing any more (docs/design/open_questions.md D32): the tutorial run
## uses the player's plain base HP (10) and is balanced to be winnable on that alone - see
## docs/balance_report.md for the simulated win rate.

## Rebalance Part D (Oct 18): the starting decks are full 45-card decks, so the waiver below is a no-op kept for old saves that
## still carry a 42-card colorless starter mid-tutorial (the legacy minimum).
const STARTER_DECK_SIZE: int = CampaignStart.INFRASTRUCTURE_COUNT + CampaignStart.SPELL_COUNT
const LEGACY_STARTER_DECK_SIZE: int = 42


## Waives the 45-card minimum down to the legacy 42-card starter for the whole trial (an old save's deck stays legal to play and
## to edit in the in-dungeon deck builder); the new 45-card starting decks never need it.
static func deck_size_waiver() -> ModifierSource:
	var source: ModifierSource = ModifierSource.new()
	source.source_name = "Tutorial starter deck"
	source.source_kind = ModifierSource.SourceKind.DUNGEON
	var modifier: Modifier = Modifier.new()
	modifier.kind = Modifier.Kind.MIN_DECK_SIZE
	modifier.value = LEGACY_STARTER_DECK_SIZE - DeckValidator.MIN_DECK_SIZE
	modifier.label = "Starter deck is not full size yet"
	source.modifiers = [modifier] as Array[Modifier]
	return source


static func build_map() -> DungeonMap:
	var map: DungeonMap = DungeonMap.new()
	map.dungeon_name = DUNGEON_NAME
	var start: DungeonMap.MapNode = _node(map, DungeonMap.Kind.START, "Cave Mouth", "Cold air and old stone. The tunnel goes down before it goes anywhere.", Vector2(0.09, 0.68))
	var first: DungeonMap.MapNode = _node(map, DungeonMap.Kind.BATTLE, "Scavenger's Den", "A hungry scavenger has moved into the first chamber. It does not want visitors.", Vector2(0.27, 0.38))
	first.enemy_name = "Cave Scavenger"
	first.enemy_hp = 3
	first.ai_name = "First duel (tutorial)"
	first.difficulty = DungeonMap.Difficulty.TUTORIAL
	first.gold_reward = EncounterRewards.gold_for(first.difficulty)
	first.card_choices = 3
	first.tutorial = true
	var challenge: DungeonMap.MapNode = _node(map, DungeonMap.Kind.CHALLENGE, "The Hollow Well", "A ring of old stone around a spring that ran dry long ago. Five cards fall into the well. Will it answer?", Vector2(0.46, 0.68))
	challenge.challenge_id = CHALLENGE_ID
	var second: DungeonMap.MapNode = _node(map, DungeonMap.Kind.BATTLE, "Mossy Gallery", "Roots hang from the ceiling like old rope. Something with claws moves between them.", Vector2(0.63, 0.36))
	second.enemy_name = "Hollow Stalker"
	second.enemy_hp = 3
	second.ai_name = "Aggressive (tutorial)"
	second.difficulty = DungeonMap.Difficulty.TUTORIAL
	second.gold_reward = EncounterRewards.gold_for(second.difficulty)
	second.card_choices = 3
	var shrine: DungeonMap.MapNode = _node(map, DungeonMap.Kind.SHRINE, "Whispering Shrine", "A bench carved into the rock long ago, worn smooth by nobody you know. Rest here before the last chamber.", Vector2(0.78, 0.68))
	# Full heal: the node right before the boss (docs/design/open_questions.md D32). A plain
	# large number is enough - DungeonRun.heal() already caps at max HP.
	shrine.heal_amount = 999
	var boss: DungeonMap.MapNode = _node(map, DungeonMap.Kind.BOSS, "Heart of the Hollow", "An Old Kingdom guardian of moss and stone sleeps here, very lightly. It does not like being woken.", Vector2(0.92, 0.34))
	boss.enemy_name = "Hollow Warden"
	boss.enemy_hp = 3
	boss.ai_name = "Balanced"
	boss.difficulty = DungeonMap.Difficulty.BOSS
	boss.gold_reward = EncounterRewards.gold_for(boss.difficulty)
	boss.card_choices = 3
	map.connect_nodes(start.id, first.id)
	map.connect_nodes(first.id, challenge.id)
	map.connect_nodes(challenge.id, second.id)
	map.connect_nodes(second.id, shrine.id)
	map.connect_nodes(shrine.id, boss.id)
	_apply_blueprint(map)
	return map


## Positions, numbers and names come from the dungeon list (D-TUT in `data/dungeons/dungeons.json`, fitted coordinates in `map_layout.json`); the encounters stay as built above.
static func _apply_blueprint(map: DungeonMap) -> void:
	var blueprint: DungeonCatalog.Blueprint = DungeonCatalog.find(DungeonCatalog.TUTORIAL_ID)
	if blueprint == null:
		return
	for plan: DungeonCatalog.BlueprintNode in blueprint.nodes:
		var map_node: DungeonMap.MapNode = map.node(plan.number - 1)
		if map_node != null:
			map_node.number = plan.number
			map_node.position = plan.position
			map_node.title = plan.node_name


## New brief (third), Part D: the total XP/gold the whole tutorial dungeon pays out (its 2
## battles + the boss - the challenge and shrine nodes pay neither), so the secret tunnel skip can
## grant "the same XP and gold the tutorial would have given" without duplicating these numbers.
static func total_tutorial_rewards() -> Dictionary:
	var map: DungeonMap = build_map()
	var xp: int = 0
	var gold: int = 0
	for map_node: DungeonMap.MapNode in map.nodes:
		if map_node.kind == DungeonMap.Kind.BATTLE or map_node.kind == DungeonMap.Kind.BOSS:
			xp += EncounterRewards.xp_for(map_node.difficulty)
			gold += map_node.gold_reward
	return {"xp": xp, "gold": gold}


static func _node(map: DungeonMap, kind: DungeonMap.Kind, title: String, blurb: String, position: Vector2) -> DungeonMap.MapNode:
	var map_node: DungeonMap.MapNode = DungeonMap.MapNode.new()
	map_node.kind = kind
	map_node.title = Villain.fill(title)
	map_node.blurb = Villain.fill(blurb)
	map_node.position = position
	return map.add_node(map_node)


## Enemy deck recipes: Card ID -> copies (BAS-x are the basic Infrastructure).
static func enemy_recipe(enemy_name: String) -> Dictionary:
	# Tutorial-weak (Part D): the two non-boss opponents use only low-stat vanilla units
	# (including 1-cost ones, same as the player's own starter) - no removal spells, no card-draw,
	# nothing that generates card advantage - and are thinner on threats/heavier on infrastructure than a
	# normal deck, so a beginner's deck can beat them reliably (docs/balance_report.md tracks the
	# win rate). The boss is allowed real removal/value (Pink Slip, Skeleton Clerks) and a bigger
	# body or two - stronger, but still tuned to keep the whole dungeon's win rate above target.
	match enemy_name:
		# Rebalance Part E (Oct 18): the Path starting decks have no fliers, so the cave's decks carry few walls - bodies a 1/2 or
		# a 2/2 can trade with - and the Warden keeps one real blocker (Tavern Regular) instead of three.
		"Cave Scavenger":
			return {"BAS-G": 18, "C-01": 4, "C-02": 2, "C-04": 2}
		"Hollow Stalker":
			return {"BAS-R": 12, "BAS-G": 8, "C-01": 3, "C-02": 3, "C-03": 1, "C-04": 2, "C-07": 1}
		"Hollow Warden":
			return {"BAS-G": 14, "BAS-R": 10, "C-01": 2, "C-02": 3, "C-06": 2, "C-08": 1, "R-05": 1, "R-06": 1}  # Overnight Oct 18 cycle 7: no Desperate Measures, one Curbside Rat fewer, two more basics (run clears were 76-82%)
	return {}


static func enemy_deck(content: ContentSet, enemy_name: String) -> Deck:
	return ZoneDecks.from_recipe(content, enemy_name, enemy_recipe(enemy_name))


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
	if map_node.enemy_hp > 0:
		setup.starting_hp = map_node.enemy_hp
		setup.profile = PlayerProfile.new()
		setup.profile.max_hp = maxi(map_node.enemy_hp, PlayerProfile.START_MAX_HP)
	EncounterModifiers.apply_to_enemy(setup, map_node.enemy_name)
	return setup
