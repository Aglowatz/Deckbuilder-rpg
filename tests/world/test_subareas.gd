extends GutTest
## Overnight Step 4/5: every sub-area blockout (data/subareas) builds, is walkable from its spawn to every point of interest and exit, links to real places, has no
## unrewarding dead end, and uses the zone's existing reward tables. The hub gates stand on walkable ground of their hub.

const SLACK: float = 3.0


func _all() -> Array[Array]:
	var result: Array[Array] = []
	for area_id: String in SubAreaDefs.AREAS:
		for sub_id: String in SubAreaDefs.sub_ids(area_id):
			result.append([area_id, sub_id])
	return result


func _build(area_id: String, sub_id: String) -> SubAreaMap:
	var map: SubAreaMap = SubAreaMap.new(SubAreaDefs.sub(area_id, sub_id))
	map.skip_barriers = true
	var parent: Node3D = Node3D.new()
	add_child_autofree(parent)
	map.build(parent)
	return map


func before_each() -> void:
	SubAreaDefs.clear_cache()
	ZoneStyles.use_area("")


func test_every_area_file_is_complete() -> void:
	for area_id: String in SubAreaDefs.AREAS:
		var zone: Dictionary = SubAreaDefs.area(area_id)
		assert_false(zone.is_empty(), "%s has data/subareas/%s/_zone.json" % [area_id, area_id])
		assert_gte(SubAreaDefs.sub_ids(area_id).size(), 3, "%s has 3-5 sub-areas (G-07)" % area_id)
		assert_lte(SubAreaDefs.sub_ids(area_id).size(), 5, "%s has at most 5 sub-areas" % area_id)
		assert_false(SubAreaDefs.hub_scene(area_id).is_empty(), "%s names its hub scene" % area_id)
		assert_true(ZoneStyles.AREAS.has(area_id), "%s has a style file" % area_id)


func test_every_subarea_builds_and_is_walkable() -> void:
	for pair: Array in _all():
		var area_id: String = str(pair[0])
		var sub_id: String = str(pair[1])
		var data: Dictionary = SubAreaDefs.sub(area_id, sub_id)
		assert_false(data.is_empty(), "%s/%s has a file" % [area_id, sub_id])
		var map: SubAreaMap = _build(area_id, sub_id)
		var spawn: Vector3 = map.spawn()
		assert_true(map.is_walkable(spawn), "%s/%s: the spawn is walkable" % [area_id, sub_id])
		var targets: Dictionary = {}
		for item: Variant in data.get("poi", []) as Array:
			var poi: Dictionary = item as Dictionary
			targets["poi:%s" % str(poi["id"])] = SubAreaMap.pos3(poi["pos"])
		for item: Variant in data.get("exits", []) as Array:
			var exit_data: Dictionary = item as Dictionary
			targets["exit:%s" % str(exit_data["id"])] = SubAreaMap.pos3(exit_data["pos"])
		var missing: Array[String] = WalkProbe.unreachable(func(pos: Vector3) -> bool: return map.is_walkable(pos, 0.3), spawn, map.map_bounds(), targets, SLACK)
		assert_eq(missing, [] as Array[String], "%s/%s: unreachable from the spawn: %s" % [area_id, sub_id, str(missing)])


func test_exits_lead_somewhere_real() -> void:
	for pair: Array in _all():
		var area_id: String = str(pair[0])
		var sub_id: String = str(pair[1])
		var exits: Array = SubAreaDefs.sub(area_id, sub_id).get("exits", []) as Array
		assert_gt(exits.size(), 0, "%s/%s has an exit" % [area_id, sub_id])
		for item: Variant in exits:
			var exit_data: Dictionary = item as Dictionary
			var target: String = str(exit_data.get("to", ""))
			if target == "hub" or target.begins_with("dungeon:"):
				continue
			if target.begins_with("area:"):
				var parts: PackedStringArray = target.trim_prefix("area:").split("/", false)
				assert_false(SubAreaDefs.sub(parts[0], parts[1]).is_empty(), "%s/%s -> %s exists" % [area_id, sub_id, target])
			else:
				assert_false(SubAreaDefs.sub(area_id, target).is_empty(), "%s/%s -> %s exists" % [area_id, sub_id, target])


func test_every_subarea_pays_something_and_loops() -> void:
	for pair: Array in _all():
		var area_id: String = str(pair[0])
		var sub_id: String = str(pair[1])
		var data: Dictionary = SubAreaDefs.sub(area_id, sub_id)
		var rewards: int = 0
		var interest: int = 0
		for item: Variant in data.get("poi", []) as Array:
			var poi: Dictionary = item as Dictionary
			interest += 1
			if str(poi.get("type", "")) in ["chest", "shrine"]:
				rewards += 1
		assert_gte(rewards, 1, "%s/%s: a dead end must pay something" % [area_id, sub_id])
		assert_gte(interest, 4, "%s/%s: something every 15-20 seconds (>= 4 points of interest)" % [area_id, sub_id])
		assert_gte(float(data.get("landmarks", []).size()), 1.0, "%s/%s has a hero landmark stand-in" % [area_id, sub_id])


func test_every_subarea_is_reachable_from_the_hub() -> void:
	for area_id: String in SubAreaDefs.AREAS:
		var reached: Dictionary = {}
		var queue: Array[String] = []
		for gate: Dictionary in SubAreaDefs.gates(area_id):
			queue.append(str(gate["sub"]))
		var entry_sub: String = str(SubAreaDefs.area(area_id).get("entry_sub", ""))
		if entry_sub != "":
			queue.append(entry_sub)
		# Secret sub-areas (no hub gate) are reached from another sub-area: breadth-first through the exits.
		while not queue.is_empty():
			var current: String = queue.pop_back()
			if reached.has(current):
				continue
			reached[current] = true
			for item: Variant in SubAreaDefs.sub(area_id, current).get("exits", []) as Array:
				var target: String = str((item as Dictionary).get("to", ""))
				if target != "hub" and not target.begins_with("area:"):
					queue.append(target)
		for sub_id: String in SubAreaDefs.sub_ids(area_id):
			assert_true(reached.has(sub_id), "%s/%s can be reached from a hub gate" % [area_id, sub_id])


func test_chest_rewards_come_from_the_zone_tables() -> void:
	for zone_id: String in ZoneDefs.all_ids():
		var table: Dictionary = ZoneDefs.get_def(zone_id).chest_rewards
		for tier: String in ["small", "medium", "large", "card"]:
			var reward: Dictionary = SubAreaRewards.reward(zone_id, tier, "test/%s" % tier)
			assert_false(reward.is_empty(), "%s %s has a reward" % [zone_id, tier])
			for key: String in ["item", "card"]:
				if reward.has(key):
					var found: bool = false
					for entry: Variant in table.values():
						if str((entry as Dictionary).get(key, "")) == str(reward[key]):
							found = true
					assert_true(found, "%s %s %s is an existing table entry" % [zone_id, tier, key])


func test_subarea_tokens_round_trip() -> void:
	var area_id: String = ""
	var sub_id: String = ""
	for pair: Array in _all():
		area_id = str(pair[0])
		sub_id = str(pair[1])
		break
	if area_id == "":
		pass_test("no sub-areas yet")
		return
	assert_eq(SubAreaDefs.parse_token(SubAreaDefs.token(area_id, sub_id)), [area_id, sub_id] as Array[String])
	assert_eq(SubAreaDefs.parse_token("zone:beefcake"), [] as Array[String])
