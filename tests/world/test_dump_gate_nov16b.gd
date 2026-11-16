extends GutTest
## Fable Nov 16b (Part 3): the Verdant Dump's entrance in Crosspath is a real gate - one old tree on each side of the path from town,
## leaning in until their branches cross over it, a few steps before the travel prompt. The thorns alone lie across the forest road until
## Moss Mulligan is beaten. The old flat card (two trees side by side, facing the camera) is not built any more.


func _town() -> TownBuilder:
	var town: TownBuilder = TownBuilder.new()
	var parent: Node3D = Node3D.new()
	add_child_autofree(parent)
	town.build(parent, false)
	return town


func test_the_three_pieces_are_cut_from_the_approved_thorn_wall() -> void:
	assert_true(HubObstacles.gate_pieces())
	for id: String in [HubObstacles.GATE_TREE_LEFT, HubObstacles.GATE_TREE_RIGHT, HubObstacles.THICKET_ART]:
		assert_true(EnvKit.has(id) and EnvKit.has_art(id), id)
		assert_string_contains(str(EnvKit.entry(id).get("desc", "")), "KIT-HEAP-THORNWALL", "%s says where it comes from" % id)
	assert_lt(EnvKit.aspect(HubObstacles.GATE_TREE_LEFT), 0.7, "a tree is taller than wide")
	assert_lt(EnvKit.aspect(HubObstacles.GATE_TREE_RIGHT), 0.7)


func test_one_tree_on_each_side_of_the_path_leaning_in() -> void:
	var town: TownBuilder = _town()
	var obstacles: HubObstacles = HubObstacles.build(town.root, town, {})
	var gate: Node3D = obstacles.dump_gate
	assert_not_null(gate, "the gate is built")
	var left: Node3D = gate.get_node_or_null("Left") as Node3D
	var right: Node3D = gate.get_node_or_null("Right") as Node3D
	assert_not_null(left)
	assert_not_null(right)
	assert_lt(left.position.x, -0.8, "one tree west of the path")
	assert_gt(right.position.x, 0.8, "one tree east of it")
	assert_lt(left.rotation.z, -0.1, "the west tree leans east")
	assert_gt(right.rotation.z, 0.1, "the east tree leans west")
	assert_ne(signf(left.rotation.y), signf(right.rotation.y), "each is turned toward the path: two cards at an angle, not one flat")
	# The branches meet: each top reaches past the middle of the path.
	var reach: float = HubObstacles.GATE_TREE_HEIGHT * sin(deg_to_rad(HubObstacles.GATE_LEAN)) + HubObstacles.GATE_TREE_HEIGHT * EnvKit.aspect(HubObstacles.GATE_TREE_LEFT) * 0.7
	assert_gt(reach, HubObstacles.GATE_HALF_WIDTH, "a tree's top reaches the middle of the path (%.1f m of %.1f m)" % [reach, HubObstacles.GATE_HALF_WIDTH])


func test_the_hero_walks_through_the_gate_to_the_travel_prompt() -> void:
	var town: TownBuilder = _town()
	HubObstacles.build(town.root, town, {})
	var centre: Vector3 = HubObstacles.dump_gate_centre(town)
	assert_almost_eq(centre, HubObstacles.gate_centre(), Vector3(0.01, 0.01, 0.01), "the builders that keep the view clear use the same place")
	var spot: Vector3 = town.anchors["portal_refusemancer"] as Vector3
	assert_gt(centre.z, spot.z + 3.0, "the gate stands south of the travel prompt: the path from town goes through it first")
	# A walk from six metres south of the gate, through its middle, to the travel spot: every step can be stood on.
	var steps: Array[Vector3] = []
	for i: int in range(13):
		steps.append(centre + Vector3(0.0, 0.0, 6.0 - float(i)))
	for i: int in range(1, 9):
		steps.append((centre + Vector3(0.0, 0.0, -6.0)).lerp(spot, float(i) / 8.0))
	for step: Vector3 in steps:
		assert_true(town.is_walkable(step, 0.3), "the hero can stand at %s on the way through the gate" % step)
	# The trunks are solid: nobody walks through a tree.
	for side: float in [-1.0, 1.0]:
		assert_false(town.is_walkable(centre + Vector3(side * HubObstacles.GATE_HALF_WIDTH, 0.0, -0.3 * side), 0.3), "the trunk is solid")
	# Moss Mulligan and the sign's place (the travel spot) stay reachable.
	assert_true(town.is_walkable(spot, 0.3))
	var keeper: Vector3 = town.anchors["npc_refusemancer"] as Vector3
	assert_true(town.is_walkable(keeper + Vector3(0.0, 0.0, 1.2), 0.3) or town.is_walkable(keeper + Vector3(1.2, 0.0, 0.0), 0.3), "there is room to stand by Moss Mulligan")


func test_the_thorns_block_the_forest_road_only_until_mulligan_is_beaten() -> void:
	var town: TownBuilder = _town()
	var sealed: HubObstacles = HubObstacles.build(town.root, town, {})
	var holder: Node3D = sealed.movers["refusemancer"] as Node3D
	assert_true(holder.has_meta(&"gate"))
	var alive: Node3D = holder.get_node("Alive") as Node3D
	assert_true(alive.visible, "the thicket stands while the road is sealed")
	assert_eq(str(alive.get_meta("card_id", "")), HubObstacles.THICKET_ART, "it is the thorns alone, no trees")
	assert_eq(holder.find_children("*", "MeshInstance3D", true, false).size(), 1, "the old two-tree card is not built (one card: the thicket)")
	var mouth: Vector3 = town.anchors["portal_refusemancer_mouth"] as Vector3
	assert_false(town.is_walkable(mouth + Vector3(0.6, 0.0, 0.0), 0.3), "the forest road is shut (the line of thorns lies just inside the mouth)")
	var town_free: TownBuilder = _town()
	var freed: HubObstacles = HubObstacles.build(town_free.root, town_free, {str(CorruptedNpcs.unlock_flag("refusemancer")): true})
	assert_true(freed.is_cleared("refusemancer"))
	var open: Node3D = freed.movers["refusemancer"] as Node3D
	assert_false((open.get_node("Alive") as Node3D).visible, "no thorns once he is beaten")
	assert_eq((open.get_node("Dead") as Node3D).get_child_count(), 0, "and no flat withered card in their place")
	assert_not_null(freed.dump_gate, "the tree gate stands in both states")


func test_nothing_grows_in_the_gate_or_in_front_of_it() -> void:
	var gate: Vector3 = HubObstacles.gate_centre()
	assert_true(HubObstacles.in_gate_view(gate))
	assert_true(HubObstacles.in_gate_view(gate + Vector3(-2.5, 0.0, 4.0)), "south-west of the gate, between it and the camera")
	assert_false(HubObstacles.in_gate_view(gate + Vector3(0.0, 0.0, -5.0)), "behind the gate the land is as it was")
	assert_false(HubObstacles.in_gate_view(gate + Vector3(9.0, 0.0, 2.0)))
