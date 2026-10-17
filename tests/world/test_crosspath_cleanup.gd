extends GutTest
## Crosspath pass, Part B: rigid things never sway, the building kit's trims stay on their roofs, the old toy huts are gone from the hub, the new
## outskirt buildings keep off the roads, lamps stand only on the cobbled streets and the ground clutter gathers in clumps along edges.


func _town() -> TownBuilder:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	var town: TownBuilder = TownBuilder.new()
	town.build(root, false)
	return town


func test_foliage_words_match_whole_words_only() -> void:
	assert_false(StyleToon.is_foliage_name("Cluster_well_corner"), "'corner' is not 'corn'")
	assert_true(StyleToon.is_rigid_name("Cluster_well_corner"))
	assert_true(StyleToon.is_rigid_name("DoorLeaves"), "a door is rigid whatever its leaves")
	assert_true(StyleToon.is_foliage_name("tree_pineTallA2"))
	assert_true(StyleToon.is_foliage_name("grass_leafs"))
	assert_true(StyleToon.is_foliage_name("Trees_oak_far"))
	assert_true(StyleToon.is_rigid_name("hills_A_trees"), "hills are rigid even when trees grow on them")
	assert_eq(StyleToon.name_words("tree_pineTallA2"), PackedStringArray(["tree", "pine", "tall", "a"]))


func test_rigid_kit_props_have_no_sway() -> void:
	var root: Node3D = Node3D.new()
	root.name = "Town"
	add_child_autofree(root)
	for prop_name: String in PropKit.NAMES:
		if prop_name == "bush" or prop_name == "hedge":
			continue  # plants
		var prop: Node3D = PropKit.make(prop_name)
		if prop != null:
			root.add_child(prop)
	for cluster_name: String in PropClusters.NAMES:
		var cluster: Node3D = PropClusters.make(cluster_name)
		if cluster != null:
			cluster.name = "Cluster_%s" % cluster_name
			root.add_child(cluster)
	for preset: String in BuildingPresets.names():
		root.add_child(BuildingPresets.build(preset))
	for relic: Node3D in [HubRelics.cairn(), HubRelics.headstone(1), HubRelics.lever()]:
		root.add_child(relic)
	# the pantry door's leaves, named as HubObstacles names them
	var leaves: Node3D = Node3D.new()
	leaves.name = "DoorLeaves"
	root.add_child(leaves)
	var leaf: MeshInstance3D = MeshInstance3D.new()
	leaf.mesh = BoxMesh.new()
	leaf.material_override = StandardMaterial3D.new()
	leaves.add_child(leaf)
	StyleToon.apply(root, 1.0)
	var swaying: PackedStringArray = PlanView.swaying(root)
	# the clusters' flower clumps, bushes and trees are plants: only those may be listed
	var rigid: PackedStringArray = []
	for line: String in swaying:
		if not (line.contains("Clumps") or line.contains("Bush") or line.contains("Tree") or line.contains("Hedge")):
			rigid.append(line)
	assert_eq(rigid, PackedStringArray(), "nothing rigid sways: %s" % str(rigid))


func test_plants_still_sway() -> void:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	var flower: MeshInstance3D = MeshInstance3D.new()
	flower.name = "flower_redA"
	flower.mesh = BoxMesh.new()
	flower.material_override = StandardMaterial3D.new()
	root.add_child(flower)
	StyleToon.apply(root, 1.0)
	assert_eq(PlanView.swaying(root).size(), 1, "a flower moves in the wind")


func test_rigid_card_props_stand_still() -> void:
	var still: ShaderMaterial = KitFoliage.card_material("ENV-TREE-OAK", true)
	var living: ShaderMaterial = KitFoliage.card_material("ENV-TREE-OAK", false)
	assert_eq(float(still.get_shader_parameter("sway")), 0.0)
	assert_ne(still, living, "a still card has its own material")


## Every preset, stripped of its sockets (signs and awnings may stand proud of the front), stays inside its footprint grown by the roof overhang:
## the barge boards of a gable-front roof once stuck out two metres past the gable.
func test_roof_trims_stay_on_their_roofs() -> void:
	for preset: String in BuildingPresets.names():
		var spec: Dictionary = BuildingPresets.spec(preset).duplicate(true)
		spec.erase("faces")
		spec.erase("chimney")
		spec.erase("dormers")
		var building: Node3D = BuildingKit.build(spec)
		add_child_autofree(building)
		var body: MeshInstance3D = building.get_node("Body") as MeshInstance3D
		var box: AABB = body.mesh.get_aabb()
		var roof: Dictionary = spec.get("roof", {}) as Dictionary
		var over: float = float(roof.get("overhang", 0.75)) + 0.45
		var width: float = float(spec.get("width", 6.0))
		var depth: float = float(spec.get("depth", 5.0))
		assert_lte(box.size.x, width + over * 2.0, "%s: nothing sticks out sideways (%.2f)" % [preset, box.size.x])
		assert_lte(box.size.z, depth + over * 2.0, "%s: nothing sticks out front or back (%.2f)" % [preset, box.size.z])


func test_the_toy_huts_and_water_tiles_are_gone_from_the_hub() -> void:
	var town: TownBuilder = _town()
	var leftovers: Array[String] = []
	for node: Node in town.root.find_children("*", "Node3D", false, false):
		var path: String = node.scene_file_path
		if path.contains("kaykit") and (path.contains("/buildings/") or path.contains("hex_water") or path.contains("rock_single") or path.contains("ladder")):
			if not path.contains("tower_B"):  # the debug-only dev shrine
				leftovers.append("%s %s" % [node.name, path.get_file()])
		if path.contains("tent_detailedOpen"):
			leftovers.append(str(node.name))
	assert_eq(leftovers, [] as Array[String], "no KayKit huts, tents, rocks or water tiles in the hub")
	assert_eq(TownExpansion.sites().size(), town.expansion.size(), "every kept outskirt building is placed")


func test_outskirt_buildings_keep_off_the_roads() -> void:
	for shop: TownLayout.Shop in TownExpansion.shops():
		var half: Vector2 = shop.footprint * 0.5
		var basis: Basis = Basis(Vector3.UP, deg_to_rad(shop.yaw))
		for local: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
			var corner: Vector3 = shop.center + basis * Vector3(local.x * half.x, 0.0, local.y * half.y)
			assert_gt(TownLayout.distance_to_roads(corner), TownLayout.ROAD_WIDTH * 0.5 + 1.0, "%s keeps off the road" % shop.label)


func test_lamps_stand_only_on_the_cobbled_streets() -> void:
	var cobbled: Dictionary = {}
	var roads: Dictionary = TownLayout.roads()
	for id: String in roads.keys():
		if str(TownLayout.road_kinds().get(id, "")) == "cobble":
			cobbled[id] = roads[id]
	for pos: Vector3 in TownLayout.lamps():
		var on_square: bool = Vector2(pos.x - TownLayout.PLAZA.x, pos.z - TownLayout.PLAZA.z).length() <= TownLayout.PLAZA_RADIUS + 0.5
		assert_true(on_square or TownLayout.distance_to_roads(pos, cobbled) < TownLayout.ROAD_WIDTH * 0.5 + 1.0, "lamp at %s lights a town street" % str(pos))


func test_ground_clutter_gathers_along_edges_with_open_grass_between() -> void:
	var town: TownBuilder = _town()
	var grows: Callable = TownClutter.region(town)
	var open: int = 0
	var dressed: int = 0
	var x: float = -10.0
	while x < 60.0:
		var z: float = 30.0
		while z < 66.0:
			var p: Vector3 = Vector3(x, 0.0, z)
			if town.is_floor_at(p) and not TownLayout.is_paved(p, 0.2):
				if bool(grows.call(p)):
					dressed += 1
				else:
					open += 1
			z += 1.5
		x += 1.5
	var share: float = float(dressed) / float(maxi(1, dressed + open))
	gut.p("clutter share of the fields: %.2f" % share)
	assert_between(share, 0.05, 0.5, "clumps, not a carpet, and not bare")
	for point: Vector3 in TownLayout.road_points(2.0):
		assert_false(bool(grows.call(point)), "nothing grows on the road at %s" % str(point))
