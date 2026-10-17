extends GutTest
## Overnight Oct 16, Block 3: the hub as one country (HubLand), the obstacles on the zone roads (HubObstacles), the gatekeepers at them, Brannoch
## on the imperial road, and the Undercroft cottage replacing the colosseum.


func _town() -> TownBuilder:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	var town: TownBuilder = TownBuilder.new()
	town.build(root, false)
	return town


func test_no_islands_or_bridges_beyond_the_passages() -> void:
	var town: TownBuilder = _town()
	assert_true(town.hub_land)
	for zone_id: String in TownBuilder.PORTAL_CELLS.keys():
		assert_null(town.root.find_child("Connector_%s" % zone_id, true, false), "%s: no visual island" % zone_id)


func test_every_gatekeeper_stands_at_its_road_on_walkable_ground() -> void:
	var town: TownBuilder = _town()
	for zone_id: String in Gatekeepers.IDS:
		var mouth: Vector3 = town.anchors["portal_%s_mouth" % zone_id] as Vector3
		var keeper: Vector3 = town.anchors["npc_%s" % zone_id] as Vector3
		var distance: float = Vector2(keeper.x - mouth.x, keeper.z - mouth.z).length()
		assert_between(distance, 2.5, 5.0, "%s: the gatekeeper is at the obstacle" % zone_id)
		assert_true(town.is_floor_at(keeper), "%s: on the town's ground" % zone_id)
	var brannoch: Vector3 = town.anchors["npc_gate"] as Vector3
	var capital: Vector3 = town.anchors["portal_final_mouth"] as Vector3
	assert_lt(Vector2(brannoch.x - capital.x, brannoch.z - capital.z).length(), 5.0, "Brannoch stands on the imperial road")


func test_the_undercroft_cottage_replaces_the_colosseum() -> void:
	var town: TownBuilder = _town()
	assert_null(town.root.find_child("GrandClashatorium", true, false), "no colosseum")
	assert_not_null(town.undercroft)
	assert_true(town.is_walkable(town.anchors["arena"] as Vector3, 0.3), "the hatch can be reached")
	assert_false(town.is_walkable(TownLayout.ARENA_CENTER, 0.3), "the cottage is solid")


func test_hub_land_builds_five_roads_lakes_and_a_gorge_on_the_meadow_road() -> void:
	var town: TownBuilder = _town()
	var land: HubLand = HubLand.build(town.root, town, StandardMaterial3D.new())
	assert_eq(land.roads.size(), 5)
	assert_gte(land.lakes.size(), 2, "lakes out in the country")
	assert_false(land.town_water.is_empty(), "the town keeps its lake")
	var road: Dictionary = land.roads["beefcake"] as Dictionary
	var mouth: Vector3 = road["mouth"] as Vector3
	assert_true(land.in_gorge(mouth + (road["out"] as Vector3) * (HubLand.GORGE_FROM + 2.0)), "the gorge crosses the meadow road just past its mouth")
	assert_false(land.in_gorge(mouth), "the passage mouth itself is on solid ground")
	assert_false(town.is_floor_at(mouth + (road["out"] as Vector3) * (HubLand.GORGE_FROM + 2.0)), "nobody can walk into the gorge")
	var capital: PackedVector3Array = (land.roads["final"] as Dictionary)["points"] as PackedVector3Array
	assert_almost_eq(capital[0].x, capital[capital.size() - 1].x, 0.01, "the imperial road runs dead straight")
	assert_gt(land.tree_count, 200, "a belt of trees and groves")


func test_obstacles_follow_the_gatekeeper_flags_and_clear() -> void:
	var town: TownBuilder = _town()
	var flags: Dictionary = {str(CorruptedNpcs.unlock_flag("gourmand")): true}
	var obstacles: HubObstacles = HubObstacles.build(town.root, town, flags)
	assert_true(obstacles.is_cleared("gourmand"))
	for zone_id: String in ["beefcake", "necrocrat", "refusemancer"]:
		assert_false(obstacles.is_cleared(zone_id), zone_id)
		assert_true(obstacles.movers.has(zone_id), "%s has a moving part" % zone_id)
	obstacles.play_cleared("beefcake")
	assert_true(obstacles.is_cleared("beefcake"), "the bridge lowers")
	assert_eq(Gatekeepers.obstacle("beefcake"), Gatekeepers.Obstacle.BRIDGE)
	assert_eq(Gatekeepers.obstacle("refusemancer"), Gatekeepers.Obstacle.THORNS)
