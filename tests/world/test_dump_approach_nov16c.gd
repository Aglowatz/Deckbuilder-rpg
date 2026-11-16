extends GutTest
## Fable Nov 16c (Part 2): the Verdant Dump's entrance in Crosspath has no gate. The two gate trees of Nov 16b (and the pieces cut for
## them) are gone; the path from town runs open to the travel prompt, the sign and Moss Mulligan, with two or three low bushes beside
## it and no tree in the way. The thorns alone lie across the forest road until Moss Mulligan is beaten.


func _town() -> TownBuilder:
	var town: TownBuilder = TownBuilder.new()
	var parent: Node3D = Node3D.new()
	add_child_autofree(parent)
	town.build(parent, false)
	return town


func test_the_gate_trees_and_their_art_are_gone() -> void:
	for id: String in ["KIT-HEAP-GATE-TREE-L", "KIT-HEAP-GATE-TREE-R"]:
		assert_false(EnvKit.has(id), "%s is no longer a kit piece" % id)
		assert_false(FileAccess.file_exists("res://assets/art/zone_kits/heap/%s.webp" % id), "%s's picture is deleted" % id)
	assert_true(HubObstacles.gate_pieces(), "the thicket cut from the thorn wall stays")
	assert_string_contains(str(EnvKit.entry(HubObstacles.THICKET_ART).get("desc", "")), "KIT-HEAP-THORNWALL")
	var town: TownBuilder = _town()
	var obstacles: HubObstacles = HubObstacles.build(town.root, town, {})
	assert_null(obstacles.get_node_or_null("DumpGate"), "no gate is built")
	assert_false("dump_gate" in obstacles, "the gate's code is gone")
	for node: Node in obstacles.find_children("*", "MeshInstance3D", true, false):
		assert_false(str(node.get_meta("card_id", "")).contains("GATE-TREE"), "no gate tree card anywhere")


func test_the_path_from_town_to_the_travel_prompt_is_open() -> void:
	var town: TownBuilder = _town()
	HubObstacles.build(town.root, town, {})
	var middle: Vector3 = HubObstacles.dump_approach_centre(town)
	assert_almost_eq(middle, HubObstacles.approach_centre(), Vector3(0.01, 0.01, 0.01), "the builders that keep the view clear use the same place")
	var spot: Vector3 = town.anchors["portal_refusemancer"] as Vector3
	# A walk from six metres south of the old gate line, up the path, to the travel spot: every step can be stood on...
	var steps: Array[Vector3] = []
	for i: int in range(13):
		steps.append(middle + Vector3(0.0, 0.0, 6.0 - float(i)))
	for i: int in range(1, 9):
		steps.append((middle + Vector3(0.0, 0.0, -6.0)).lerp(spot, float(i) / 8.0))
	for step: Vector3 in steps:
		assert_true(town.is_walkable(step, 0.3), "the hero can stand at %s on the way to the Dump's travel spot" % step)
	# ...and so can the places where the two trunks stood.
	for side: float in [-1.0, 1.0]:
		assert_true(town.is_walkable(middle + Vector3(side * 2.0, 0.0, -0.3 * side), 0.3), "no trunk stands beside the path any more")
	assert_true(town.is_walkable(spot, 0.3))
	var keeper: Vector3 = town.anchors["npc_refusemancer"] as Vector3
	assert_true(town.is_walkable(keeper + Vector3(0.0, 0.0, 1.2), 0.3) or town.is_walkable(keeper + Vector3(1.2, 0.0, 0.0), 0.3), "there is room to stand by Moss Mulligan")


func test_two_or_three_low_bushes_stand_beside_the_path_not_on_it() -> void:
	var town: TownBuilder = _town()
	var obstacles: HubObstacles = HubObstacles.build(town.root, town, {})
	assert_not_null(obstacles.dump_approach, "the approach is dressed")
	assert_between(HubObstacles.APPROACH_BUSHES.size(), 2, 3)
	var box: AABB = (obstacles.dump_approach as MeshInstance3D).get_aabb()
	assert_lt(box.end.y, 1.0, "the bushes are knee-high: they hide neither the hero nor the prompt (%.2f m)" % box.end.y)
	for bush: Vector3 in HubObstacles.APPROACH_BUSHES:
		assert_gt(absf(bush.x), 2.0, "a bush stands beside the path, not on it")


func test_no_tree_grows_on_the_approach() -> void:
	var middle: Vector3 = HubObstacles.approach_centre()
	assert_true(HubObstacles.in_dump_approach(middle))
	assert_true(HubObstacles.in_dump_approach(middle + Vector3(-2.5, 0.0, 4.0)), "south-west of the travel spot, between it and the camera")
	assert_false(HubObstacles.in_dump_approach(middle + Vector3(0.0, 0.0, -5.0)), "behind it the land is as it was")
	assert_false(HubObstacles.in_dump_approach(middle + Vector3(9.0, 0.0, 2.0)))


func test_the_thorns_block_the_forest_road_only_until_mulligan_is_beaten() -> void:
	var town: TownBuilder = _town()
	var sealed: HubObstacles = HubObstacles.build(town.root, town, {})
	var holder: Node3D = sealed.movers["refusemancer"] as Node3D
	var alive: Node3D = holder.get_node("Alive") as Node3D
	assert_true(alive.visible, "the thicket stands while the road is sealed")
	assert_eq(str(alive.get_meta("card_id", "")), HubObstacles.THICKET_ART, "it is the thorns alone, no trees")
	assert_eq(holder.find_children("*", "MeshInstance3D", true, false).size(), 1, "one card: the thicket")
	var mouth: Vector3 = town.anchors["portal_refusemancer_mouth"] as Vector3
	assert_false(town.is_walkable(mouth + Vector3(0.6, 0.0, 0.0), 0.3), "the forest road is shut (the line of thorns lies just inside the mouth)")
	var town_free: TownBuilder = _town()
	var freed: HubObstacles = HubObstacles.build(town_free.root, town_free, {str(CorruptedNpcs.unlock_flag("refusemancer")): true})
	assert_true(freed.is_cleared("refusemancer"))
	var open: Node3D = freed.movers["refusemancer"] as Node3D
	assert_false((open.get_node("Alive") as Node3D).visible, "no thorns once he is beaten")
	assert_eq((open.get_node("Dead") as Node3D).get_child_count(), 0, "and no flat withered card in their place")
