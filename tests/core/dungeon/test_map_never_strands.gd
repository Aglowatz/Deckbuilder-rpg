extends GutTest
## Overnight Nov 9 (ship blocker): in Primm's Castle a dead end inside a side branch (the Portrait Gallery's wings, off the Grand Foyer)
## sent the party back one level only, onto a node with nothing left open: nothing to click, only Retreat (a full reset). Every dungeon is
## now walked by a completionist (side branches first, boss last) and by random walkers: the map must never leave the party with nothing
## open before the boss is beaten.


func before_each() -> void:
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	DungeonCatalog.reset()
	MainDungeons.reset()


func _map_for(blueprint: DungeonCatalog.Blueprint) -> DungeonMap:
	if blueprint.id == DungeonCatalog.TUTORIAL_ID:
		return TrialOfTheHollow.build_map()
	return MainDungeons.build_map(blueprint.id if (blueprint.is_side() or blueprint.is_postgame()) else blueprint.zone_id)


## Walks `map` to the end, choosing with `pick`; returns "" or a description of where it got stranded.
func _walk(map: DungeonMap, pick: Callable) -> String:
	for _step: int in range(map.nodes.size() * 3):
		if map.is_cleared(map.boss().id):
			return ""
		var open: Array[DungeonMap.MapNode] = map.available()
		if open.is_empty():
			return "stranded on node %d (%s) with cleared %s" % [map.current, map.node(map.current).title, str(map.cleared)]
		var chosen: DungeonMap.MapNode = pick.call(open)
		assert_true(map.complete(chosen.id))
	return "never reached the boss"


func test_a_completionist_is_never_stranded() -> void:
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		var map: DungeonMap = _map_for(blueprint)
		if map == null or map.boss() == null:
			continue
		var boss_id: int = map.boss().id
		var result: String = _walk(map, func(open: Array[DungeonMap.MapNode]) -> DungeonMap.MapNode:
			# the boss only when nothing else is open; otherwise the deepest side node first
			var best: DungeonMap.MapNode = null
			for node: DungeonMap.MapNode in open:
				if node.id == boss_id:
					continue
				if best == null or node.id > best.id:
					best = node
			return best if best != null else open[0])
		assert_eq(result, "", "%s: %s" % [blueprint.id, result])


func test_random_walkers_are_never_stranded() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 9112026
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		for _walker: int in range(20):
			var map: DungeonMap = _map_for(blueprint)
			if map == null or map.boss() == null:
				continue
			var result: String = _walk(map, func(open: Array[DungeonMap.MapNode]) -> DungeonMap.MapNode: return open[rng.randi_range(0, open.size() - 1)])
			assert_eq(result, "", "%s: %s" % [blueprint.id, result])
