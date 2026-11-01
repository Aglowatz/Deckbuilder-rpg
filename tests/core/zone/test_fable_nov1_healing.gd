extends GutTest
## Fable pass Nov 1, Part 1 (healing; the designer: no healing after battles in freed zones): the Capital's hit toast names what hit
## you, the Crease's healer is named like one, and Primm's Castle keeps a full heal on every road to the boss near the middle of the way.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_the_capital_hit_toast_names_a_rift_or_a_roamer() -> void:
	var story: ZoneStoryText = ZoneStoryText.for_zone(CapitalZone.ID)
	assert_eq(story.hit_text(2, "rift", "a rift"), "A rift tears at you as you pass. The Capital has no record of it. (-2 HP)")
	assert_eq(story.hit_text(1, "roamer", "A Tidy-Bot"), "A Tidy-Bot knocks you flat. Please remain orderly. (-1 HP)")
	assert_eq(story.hit_text(2), story.text("fx.hit"), "no source: the plain line")
	assert_eq(story.hit_text(2, "falling_piano", "A piano"), story.text("fx.hit"), "an unknown source: the plain line")


func test_the_other_zones_keep_their_own_hit_line() -> void:
	for zone_id: String in ZoneDefs.ids():
		var story: ZoneStoryText = ZoneStoryText.for_zone(zone_id)
		var line: String = story.hit_text(2, "roamer", "A Gull")
		assert_eq(line, story.text("fx.hit"), "%s names its hazard in its own fx.hit line" % zone_id)
		assert_false(line.contains("missing text"), zone_id)


func test_the_crease_healer_is_named_and_is_a_full_heal() -> void:
	var def: ZoneDef = ZoneDefs.get_def(CapitalZone.ID)
	var heal: Dictionary = {}
	for entry: Dictionary in def.spots:
		if str(entry["kind"]) == "heal":
			heal = entry
	assert_false(heal.is_empty(), "the Crease has a heal spot")
	assert_eq(str(heal["anchor"]), "heal")
	assert_true(str(heal["title"]).begins_with("Nurse Hesper Dray"), "the label and the map name the nurse: %s" % str(heal["title"]))
	assert_eq(NpcLabels.short_title(str(heal["title"])), "Nurse Hesper Dray", "the floating label is her name")
	assert_true(str(heal["prompt"]).contains("full heal"), str(heal["prompt"]))
	assert_eq(str(heal.get("npc", "")), "hesper", "her body counts for the E reach and she gets a floating name")
	var story: ZoneStoryText = ZoneStoryText.for_zone(CapitalZone.ID)
	assert_true(story.text("fx.heal_couch").contains("Hesper"), "the heal toast is in her voice")


func test_primms_castle_has_a_full_heal_on_every_road_to_the_boss_near_the_middle() -> void:
	var map: DungeonMap = MainDungeons.build_map("final")
	assert_not_null(map)
	var shrines: Array[int] = []
	for node: DungeonMap.MapNode in map.nodes:
		if node.kind == DungeonMap.Kind.SHRINE:
			shrines.append(node.id)
			assert_gte(node.heal_amount, PlayerProfile.ENDGAME_MAX_HP, "%s restores all HP" % node.title)
	assert_eq(shrines.size(), 1, "one Safe Room")
	var boss_id: int = map.boss().id
	assert_false(_reaches(map, 0, boss_id, shrines), "every road from the gate to the boss passes the Safe Room")
	assert_true(_reaches(map, 0, boss_id, [] as Array[int]), "the boss is reachable")
	# The critical path (the shortest road from the gate to the boss): the heal sits in its middle stretch.
	var path: Array[int] = _shortest_path(map, 0, boss_id)
	var at: int = path.find(shrines[0])
	assert_gt(at, 0)
	var fraction: float = float(at) / float(path.size() - 1)
	assert_between(fraction, 0.45, 0.75, "the Safe Room is %d of %d steps along the critical path" % [at, path.size() - 1])
	var fights_before: int = 0
	var fights_after: int = 0
	for index: int in range(path.size()):
		var kind: DungeonMap.Kind = map.node(path[index]).kind
		if kind == DungeonMap.Kind.BATTLE or kind == DungeonMap.Kind.ELITE or kind == DungeonMap.Kind.BOSS:
			if index < at:
				fights_before += 1
			else:
				fights_after += 1
	assert_between(fights_before - fights_after, -1, 2, "fights are split around the heal: %d before, %d after" % [fights_before, fights_after])


## True when `goal` can be reached from `from` without stepping on any node in `avoid`.
func _reaches(map: DungeonMap, from: int, goal: int, avoid: Array[int]) -> bool:
	var seen: Dictionary = {from: true}
	var queue: Array[int] = [from]
	while not queue.is_empty():
		var current: int = queue.pop_front()
		if current == goal:
			return true
		for next_id: int in map.node(current).next:
			if avoid.has(next_id) or seen.has(next_id):
				continue
			seen[next_id] = true
			queue.append(next_id)
	return false


func _shortest_path(map: DungeonMap, from: int, goal: int) -> Array[int]:
	var parent: Dictionary = {from: -1}
	var queue: Array[int] = [from]
	while not queue.is_empty():
		var current: int = queue.pop_front()
		if current == goal:
			break
		for next_id: int in map.node(current).next:
			if parent.has(next_id):
				continue
			parent[next_id] = current
			queue.append(next_id)
	var path: Array[int] = []
	var cursor: int = goal
	while cursor != -1 and parent.has(cursor):
		path.push_front(cursor)
		cursor = int(parent[cursor])
	return path
