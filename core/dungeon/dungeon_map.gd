class_name DungeonMap
extends RefCounted
## The node graph of a dungeon: which encounters exist, how they connect and which are done.
## Pure data + rules (no scene tree); the map screen only draws it.

enum Kind { START, BATTLE, CHALLENGE, SHRINE, BOSS }


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
	var gold_reward: int = 0
	var card_choices: int = 0
	## The first battle is guided by the tutorial layer.
	var tutorial: bool = false
	## CHALLENGE
	var challenge_id: String = ""
	## SHRINE
	var heal_amount: int = 0


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


func boss() -> MapNode:
	for candidate: MapNode in nodes:
		if candidate.kind == Kind.BOSS:
			return candidate
	return null


func is_complete() -> bool:
	var boss_node: MapNode = boss()
	return boss_node != null and is_cleared(boss_node.id)
