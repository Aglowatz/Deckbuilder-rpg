class_name DungeonMap
extends RefCounted
## The node graph of a dungeon: which encounters exist, how they connect and which are done.
## Pure data + rules (no scene tree); the map screen only draws it.

## Part E (brief 9) appended ELITE (a harder battle with a card choice), EVENT (a story choice, see
## `DungeonEvent`) and TREASURE (loot) for the four zone dungeons; the original five keep their ordinals.
enum Kind { START, BATTLE, CHALLENGE, SHRINE, BOSS, ELITE, EVENT, TREASURE }

## Part E: how much XP/gold an encounter is worth (`EncounterRewards`). Tutorial < Normal <
## Elite < Boss. Only Tutorial and Boss are used by any dungeon that actually exists yet (the
## Trial of the Hollow); Normal/Elite are here so future dungeons have somewhere to plug in.
enum Difficulty { TUTORIAL, NORMAL, ELITE, BOSS }


class MapNode:
	extends RefCounted
	var id: int = 0
	var kind: Kind = Kind.BATTLE
	var title: String = ""
	var blurb: String = ""
	## Normalized (0..1) position on the map screen.
	var position: Vector2 = Vector2.ZERO
	var next: Array[int] = []
	## BATTLE / BOSS
	var enemy_name: String = ""
	var enemy_life: int = -1
	var ai_name: String = "Balanced"
	var difficulty: Difficulty = Difficulty.NORMAL
	var gold_reward: int = 0
	var card_choices: int = 0
	## The first battle is guided by the tutorial layer.
	var tutorial: bool = false
	## CHALLENGE
	var challenge_id: String = ""
	## SHRINE
	var heal_amount: int = 0
	## Part E: EVENT - the `DungeonEvent` id; TREASURE - what the chest holds ({gold, xp, heal, item, card,
	## equipment}); `section` - a named region of the dungeon ("prison"...), shown on the map; `scene` - a
	## cutscene id played when the node is entered ("rescue", "reveal", "flex"...).
	var event_id: String = ""
	var treasure: Dictionary = {}
	var section: String = ""
	var scene: String = ""
	## A cutscene played after the node is cleared (the Rotheart severed from the big bad...).
	var after_scene: String = ""
	## Story keys in the zone story file: lines shown when the node is entered / after it is cleared.
	var story_before: String = ""
	var story_after: String = ""


var dungeon_name: String = ""
var nodes: Array[MapNode] = []
var cleared: Array[int] = []
## Id of the node the party stands on (the START node at first).
var current: int = 0


func node(id: int) -> MapNode:
	for candidate: MapNode in nodes:
		if candidate.id == id:
			return candidate
	return null


func add_node(map_node: MapNode) -> MapNode:
	map_node.id = nodes.size()
	nodes.append(map_node)
	return map_node


func connect_nodes(from_id: int, to_id: int) -> void:
	node(from_id).next.append(to_id)


func is_cleared(id: int) -> bool:
	return cleared.has(id)


## Nodes the player may enter next: successors of the current node that are not done yet.
func available() -> Array[MapNode]:
	var result: Array[MapNode] = []
	for id: int in node(current).next:
		if not is_cleared(id):
			result.append(node(id))
	return result


func is_available(id: int) -> bool:
	for candidate: MapNode in available():
		if candidate.id == id:
			return true
	return false


## Marks an available node as done and moves the party onto it.
func complete(id: int) -> bool:
	if not is_available(id):
		return false
	cleared.append(id)
	current = id
	return true


## True for the node kinds that start a duel.
static func is_battle_kind(kind: Kind) -> bool:
	return kind == Kind.BATTLE or kind == Kind.ELITE or kind == Kind.BOSS


## Nodes that lead INTO `id` (more than one means two routes rejoin there).
func incoming(id: int) -> Array[int]:
	var result: Array[int] = []
	for candidate: MapNode in nodes:
		if candidate.next.has(id):
			result.append(candidate.id)
	return result


## Nodes with more than one way forward (a real choice of route).
func branch_points() -> Array[int]:
	var result: Array[int] = []
	for candidate: MapNode in nodes:
		if candidate.next.size() > 1:
			result.append(candidate.id)
	return result


## Nodes reached by more than one route (where branches rejoin).
func rejoin_points() -> Array[int]:
	var result: Array[int] = []
	for candidate: MapNode in nodes:
		if incoming(candidate.id).size() > 1:
			result.append(candidate.id)
	return result


## Every node reachable from `from_id` (including itself).
func reachable_from(from_id: int) -> Array[int]:
	var seen: Array[int] = [from_id]
	var queue: Array[int] = [from_id]
	while not queue.is_empty():
		var current_id: int = queue.pop_front()
		for next_id: int in node(current_id).next:
			if not seen.has(next_id):
				seen.append(next_id)
				queue.append(next_id)
	return seen


## How many distinct routes lead from the start (node 0) to the boss.
func route_count() -> int:
	var boss_node: MapNode = boss()
	if boss_node == null:
		return 0
	return _routes(0, boss_node.id, {})


func _routes(from_id: int, to_id: int, memo: Dictionary) -> int:
	if from_id == to_id:
		return 1
	if memo.has(from_id):
		return int(memo[from_id])
	var total: int = 0
	for next_id: int in node(from_id).next:
		total += _routes(next_id, to_id, memo)
	memo[from_id] = total
	return total


## Structural problems (empty = a sound map): every node reachable from the start, the boss reachable
## from every node, exactly one boss with nothing after it, no path back to an earlier node.
func problems() -> Array[String]:
	var found: Array[String] = []
	if nodes.is_empty() or node(0).kind != Kind.START:
		found.append("node 0 must be the START")
		return found
	var boss_nodes: int = 0
	for candidate: MapNode in nodes:
		if candidate.kind == Kind.BOSS:
			boss_nodes += 1
	if boss_nodes != 1:
		found.append("expected exactly one boss, found %d" % boss_nodes)
		return found
	var reachable: Array[int] = reachable_from(0)
	for candidate: MapNode in nodes:
		if not reachable.has(candidate.id):
			found.append("node %d (%s) is unreachable" % [candidate.id, candidate.title])
		if candidate.kind != Kind.BOSS and candidate.next.is_empty():
			found.append("node %d (%s) is a dead end" % [candidate.id, candidate.title])
		for next_id: int in candidate.next:
			if next_id <= candidate.id:
				found.append("node %d links backwards to %d" % [candidate.id, next_id])
	if not boss().next.is_empty():
		found.append("the boss has nodes after it")
	return found


func boss() -> MapNode:
	for candidate: MapNode in nodes:
		if candidate.kind == Kind.BOSS:
			return candidate
	return null


func is_complete() -> bool:
	var boss_node: MapNode = boss()
	return boss_node != null and is_cleared(boss_node.id)
