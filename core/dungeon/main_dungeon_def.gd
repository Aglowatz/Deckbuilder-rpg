class_name MainDungeonDef
extends RefCounted
## One zone's final dungeon (Part E): its node map (10-15 nodes, branching routes that rejoin), the enemy
## decks of its battles, its story events and deck challenges, and what beating its boss gives. Built
## by `MainDungeons` from the four dungeon scripts (`TestKitchenDungeon`, ...). Titles, blurbs and all
## dialogue live in the zone's story file (`dungeon.<node key>.title/.blurb/.before/.after`,
## `event.<id>.*`, `cutscene.*`); this class only holds structure and mechanics.


## One enemy of the dungeon: its display name (also its recipe key), HP, AI and deck recipe.
class Foe:
	extends RefCounted
	var enemy_name: String = ""
	var hp: int = 15
	var ai_name: String = "Balanced"
	var recipe: Dictionary = {}
	var icon: String = "lorc/imp"


var zone_id: String = ""
var dungeon_name: String = ""
## Which dungeon backdrop the map screen builds ("kitchen", "house", "hall", "rotheart").
var backdrop: String = ""
var foes: Dictionary = {}
var events: Dictionary = {}
var challenges: Dictionary = {}
## The unique card the boss drops (once), plus gold and XP for the clear.
var reward_card_id: String = ""
var reward_gold: int = 200
var reward_xp: int = 150
## Dungeon-wide boon from the dungeon's rescue/story (null if none) - applied by the `boon` node scene.
var boon: ModifierSource


func foe(enemy_name: String) -> Foe:
	return foes.get(enemy_name) as Foe


func event(event_id: String) -> DungeonEvent:
	return events.get(event_id) as DungeonEvent


func challenge(challenge_id: String) -> ChallengeData:
	return challenges.get(challenge_id) as ChallengeData


func add_foe(enemy_name: String, hp: int, ai_name: String, recipe: Dictionary, icon: String = "lorc/imp") -> void:
	var added: Foe = Foe.new()
	added.enemy_name = enemy_name
	added.hp = hp
	added.ai_name = ai_name
	added.recipe = recipe
	added.icon = icon
	foes[enemy_name] = added


func add_event(added: DungeonEvent) -> void:
	events[added.id] = added


func add_challenge(added: ChallengeData) -> void:
	challenges[added.id] = added


## Adds a node to `map`, naming it by `key` in the story file; returns it. Position is normalized (0..1).
func node(map: DungeonMap, kind: DungeonMap.Kind, key: String, position: Vector2, section: String = "") -> DungeonMap.MapNode:
	var story: ZoneStoryText = ZoneStoryText.for_zone(zone_id)
	var added: DungeonMap.MapNode = DungeonMap.MapNode.new()
	added.kind = kind
	added.title = story.text("dungeon.%s.title" % key)
	added.blurb = story.text("dungeon.%s.blurb" % key)
	added.position = position
	added.section = section
	if story.lines.has("dungeon.%s.before" % key):
		added.story_before = "dungeon.%s.before" % key
	if story.lines.has("dungeon.%s.after" % key):
		added.story_after = "dungeon.%s.after" % key
	map.add_node(added)
	return added


## A battle-kind node fought against the foe named `enemy_name`.
func battle(map: DungeonMap, kind: DungeonMap.Kind, key: String, position: Vector2, enemy_name: String, section: String = "") -> DungeonMap.MapNode:
	var added: DungeonMap.MapNode = node(map, kind, key, position, section)
	var fighter: Foe = foe(enemy_name)
	added.enemy_name = enemy_name
	added.enemy_hp = fighter.hp
	added.ai_name = fighter.ai_name
	match kind:
		DungeonMap.Kind.ELITE:
			added.difficulty = DungeonMap.Difficulty.ELITE
			added.card_choices = 3
		DungeonMap.Kind.BOSS:
			added.difficulty = DungeonMap.Difficulty.BOSS
			added.card_choices = 3
		_:
			added.difficulty = DungeonMap.Difficulty.NORMAL
			added.card_choices = 0
	added.gold_reward = EncounterRewards.gold_for(added.difficulty) / 2
	return added


func event_node(map: DungeonMap, key: String, position: Vector2, event_id: String, section: String = "", scene: String = "") -> DungeonMap.MapNode:
	var added: DungeonMap.MapNode = node(map, DungeonMap.Kind.EVENT, key, position, section)
	added.event_id = event_id
	added.scene = scene
	return added


func challenge_node(map: DungeonMap, key: String, position: Vector2, challenge_id: String, section: String = "") -> DungeonMap.MapNode:
	var added: DungeonMap.MapNode = node(map, DungeonMap.Kind.CHALLENGE, key, position, section)
	added.challenge_id = challenge_id
	return added


func shrine_node(map: DungeonMap, key: String, position: Vector2, heal: int, section: String = "") -> DungeonMap.MapNode:
	var added: DungeonMap.MapNode = node(map, DungeonMap.Kind.SHRINE, key, position, section)
	added.heal_amount = heal
	return added


func treasure_node(map: DungeonMap, key: String, position: Vector2, loot: Dictionary, section: String = "") -> DungeonMap.MapNode:
	var added: DungeonMap.MapNode = node(map, DungeonMap.Kind.TREASURE, key, position, section)
	added.treasure = loot
	return added


## `from_ids` each get a link to `to_id`.
func link(map: DungeonMap, from_ids: Array[int], to_id: int) -> void:
	for from_id: int in from_ids:
		map.connect_nodes(from_id, to_id)


## A themed copy of one of the deck-challenge kinds (the same data the Hollow Well uses).
static func make_challenge(id: String, title: String, text: String, kind: ChallengeData.Kind, reveal_count: int, threshold: int) -> ChallengeData:
	var made: ChallengeData = ChallengeData.new()
	made.id = id
	made.display_name = title
	made.description = text
	made.kind = kind
	made.reveal_count = reveal_count
	made.threshold = threshold
	return made


static func outcome(kind: ChallengeOutcome.Kind, amount: int, text: String) -> ChallengeOutcome:
	var made: ChallengeOutcome = ChallengeOutcome.make(kind, amount)
	made.description = text
	return made


static func boon_source(name: String, modifiers: Array[Modifier]) -> ModifierSource:
	return CardBuilder.modifier_source(name, ModifierSource.SourceKind.BOON, modifiers)

