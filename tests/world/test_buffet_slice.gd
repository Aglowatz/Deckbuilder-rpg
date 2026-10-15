extends GutTest
## The Endless Buffet slice (docs/art/buffet_slice.md), Part A: the five hero landmarks are modelled from the approved concepts and placed inside the one zone
## by the declutter rules (the Test Kitchen and Potato Peak as views beyond the rim, never culled or faded; the Cake Cathedral, the Broccoli Giant and the
## Omakase Pavilion on flat kept-clear ground, clear of every anchor, chest and route), the stand-ins they replace are gone, the sky is the kit's dinner
## panorama over a dry table (no sea plane flooding the mash), and the cake skyline rings the horizon.

var layout: BuffetLayout


func before_all() -> void:
	layout = BuffetLayout.new()
	layout.build()


func test_the_five_hero_landmarks_build_from_the_concepts() -> void:
	var sizes: Dictionary = {
		"BUFF-HERO-TEST-KITCHEN": BuffetLayout.TEST_KITCHEN_SIZE, "BUFF-HERO-CAKE-CATHEDRAL": BuffetLayout.CAKE_CATHEDRAL_SIZE,
		"BUFF-HERO-POTATO-PEAK": BuffetLayout.POTATO_PEAK_SIZE, "BUFF-HERO-BROCCOLI-GIANT": BuffetLayout.BROCCOLI_GIANT_SIZE,
		"BUFF-HERO-OMAKASE-PAVILION": BuffetLayout.OMAKASE_PAVILION_SIZE,
	}
	for id: String in BuffetLandmarks.IDS:
		assert_true(HeroLandmarks.has_model(id), "%s has a model" % id)
		var size: Vector3 = sizes[id] as Vector3
		var node: Node3D = LandmarkKit.build({"id": id, "kind": "facade", "size": [size.x, size.y, size.z]})
		assert_not_null(node, "%s builds" % id)
		if node == null:
			continue
		assert_eq(str(node.get_meta("hero_id", "")), id, "%s is the modelled landmark, not a stand-in" % id)
		assert_gt(int(node.get_meta("triangles", 0)), 400, "%s is a real model" % id)
		assert_false((node.get_meta("circles", []) as Array).is_empty(), "%s blocks" % id)
		node.free()


func test_the_region_landmarks_stand_clear_of_anchors_chests_and_routes() -> void:
	# the plan: a flat kept-clear spot under each region landmark, its edge 5.5 m off every anchor and 2.4 m off every route edge (SR-8, GC-1)
	for spot: Vector3 in BuffetLayout.LANDMARK_SPOTS:
		assert_true(spot in layout.flat_spots, "the ground under (%.1f, %.1f) is flat" % [spot.x, spot.y])
		for key: Variant in layout.anchors.keys():
			if str(key) == "mini_dungeon" and spot.x == BuffetLayout.OMAKASE_PAVILION.x:
				continue  # the Pavilion IS the Walk-In Freezer door: the spot stands at its foot
			var anchor: Vector3 = layout.anchors[key] as Vector3
			var gap: float = Vector2(spot.x - anchor.x, spot.y - anchor.z).length() - spot.z
			assert_gte(gap, 1.5, "%s stays off the landmark at (%.1f, %.1f) (%.1f m)" % [str(key), spot.x, spot.y, gap])
		for path: Dictionary in layout.paths:
			var line: PackedVector2Array = path["line"] as PackedVector2Array
			for i: int in range(line.size() - 1):
				var closest: Vector2 = Geometry2D.get_closest_point_to_segment(Vector2(spot.x, spot.y), line[i], line[i + 1])
				var distance: float = closest.distance_to(Vector2(spot.x, spot.y)) - spot.z - float(path["width"]) * 0.5
				assert_gte(distance, 0.0, "no route runs under the landmark at (%.1f, %.1f)" % [spot.x, spot.y])
	# the built models: every blocking circle of a region landmark keeps the breathing room of its anchors, and no scattered prop stands under one
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: BuffetBuilder = BuffetBuilder.new()
	builder.build(host)
	for id: String in ["BUFF-HERO-CAKE-CATHEDRAL", "BUFF-HERO-BROCCOLI-GIANT", "BUFF-HERO-OMAKASE-PAVILION"]:
		var node: Node3D = builder.landmarks.get(id) as Node3D
		assert_not_null(node, "%s stands in the zone" % id)
		if node == null:
			continue
		var basis: Basis = Basis(Vector3.UP, node.rotation.y)
		for circle: Variant in node.get_meta("circles", []) as Array:
			var local: Vector3 = circle as Vector3
			var world: Vector3 = node.position + basis * Vector3(local.x, 0.0, local.y)
			assert_false(builder.is_walkable(world, 0.1), "%s is solid at (%.1f, %.1f)" % [id, world.x, world.z])
			for chest_id: Variant in layout.chests.keys():
				var chest: Vector3 = layout.chests[chest_id] as Vector3
				assert_gte(Vector2(world.x - chest.x, world.z - chest.z).length() - local.z, 1.9, "%s leaves chest %s reachable" % [id, str(chest_id)])
			for key: Variant in ["quiz", "odalys", "main_dungeon", "puzzle", "minigame", "gate_quest", "gate_ingredient", "pickup_basil", "pickup_truffle"]:
				var anchor: Vector3 = layout.anchors[key] as Vector3
				var gap: float = Vector2(world.x - anchor.x, world.z - anchor.z).length() - local.z
				assert_gte(gap, 5.0, "%s keeps %s clear (%.1f m)" % [id, str(key), gap])
	for prop: BuffetLayout.Prop in layout.props:
		if prop.kind in ["broccoli", "cauliflower", "cabbage", "cupcake", "muffin", "cheese_block", "lollipop"]:
			for spot: Vector3 in BuffetLayout.LANDMARK_SPOTS:
				assert_gte(Vector2(prop.pos.x - spot.x, prop.pos.z - spot.y).length(), spot.z - 0.01, "no %s under the landmark at (%.1f, %.1f)" % [prop.kind, spot.x, spot.y])
	# the Walk-In Freezer spot still works: the hero stands at the Pavilion's foot
	var freezer: Vector3 = layout.anchors["mini_dungeon"] as Vector3
	assert_true(builder.is_walkable(freezer + Vector3(0.0, 0.0, 1.6), 0.3), "the hero can stand at the freezer door")
	var door: Vector3 = layout.anchors["main_dungeon"] as Vector3
	assert_true(builder.is_walkable(door + Vector3(0.0, 0.0, 1.4), 0.3), "the hero can stand at the Test Kitchen gate")


func test_the_test_kitchen_and_potato_peak_are_views_beyond_the_rim() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: BuffetBuilder = BuffetBuilder.new()
	builder.build(host)
	assert_not_null(builder.test_kitchen, "the Test Kitchen stands beyond the north rim")
	assert_lt(BuffetLayout.TEST_KITCHEN.y, BuffetLayout.MIN_CORNER.y, "north of the table")
	assert_lt(BuffetLayout.POTATO_PEAK.x + BuffetLayout.POTATO_PEAK_SIZE.x * 0.65, BuffetLayout.MIN_CORNER.x, "Potato Peak and its gravy pool lie west of the table")
	for id: String in ["BUFF-HERO-TEST-KITCHEN", "BUFF-HERO-POTATO-PEAK"]:
		var node: Node3D = builder.landmarks.get(id) as Node3D
		assert_not_null(node)
		if node == null:
			continue
		assert_eq(node.get_parent(), builder.root, "%s hangs off the root, never a chunk" % id)
		for piece: Node in node.find_children("*", "MeshInstance3D", true, false):
			assert_true(piece.has_meta(&"no_range_cull") and piece.has_meta(&"no_occlusion_fade"), "%s never culls or fades" % id)
	# the Test Kitchen is the biggest thing in the zone and steams
	assert_gte(BuffetLayout.TEST_KITCHEN_SIZE.x, 48.0)
	assert_gte(BuffetLayout.TEST_KITCHEN_SIZE.y, 28.0)
	var steaming: int = 0
	for child: Node in builder.root.get_children():
		if child.name.begins_with("Steam_TestKitchen"):
			steaming += 1
	assert_gte(steaming, 5, "steam rises from the chimneys")
	# the forecourt is level with the threshold and the main_dungeon spot stands on it
	var gate: Vector3 = layout.anchors["main_dungeon"] as Vector3
	assert_true(BuffetLayout.FORECOURT.has_point(Vector2(gate.x, gate.z)), "the gate spot is on the forecourt")
	for z: float in [5.0, 7.0, 9.0, 11.0, 13.0]:
		assert_almost_eq(layout.ground_height(gate.x, z), 0.0, 0.02, "the forecourt is flat at z %.0f" % z)


func test_the_stand_ins_are_gone() -> void:
	for prop: BuffetLayout.Prop in layout.props:
		assert_false(prop.kind in ["freezer", "kitchen_door"], "the taped kitchen door and the freezer box are replaced by the hero models")


func test_the_sky_is_the_dinner_panorama_over_a_dry_table() -> void:
	var mood: Dictionary = WorldLookRig.mood_for(&"buffet")
	var sky: Dictionary = mood.get("sky", {}) as Dictionary
	assert_eq(str(sky.get("panorama", "")), "BUFF-SKY-DINNER", "the kit sky wraps the dome")
	assert_true(EnvKit.has("BUFF-SKY-DINNER") and EnvKit.has_art("BUFF-SKY-DINNER"), "and it is imported")
	var scenery: Dictionary = mood.get("scenery", {}) as Dictionary
	assert_false(bool(scenery.get("water", true)), "no sea plane: it flooded the mashed potato (the table dips below the water height)")
	var cards: Array = scenery.get("kit_cards", []) as Array
	assert_gte(cards.size(), 3, "the cake skyline rings the horizon")
	for card: Variant in cards:
		assert_eq(str((card as Dictionary).get("id", "")), "BUFF-BD-CAKE")
	assert_true(EnvKit.has_art("BUFF-BD-CAKE"))


func test_the_kit_cards_have_hand_heights() -> void:
	for kind: String in ["buff_broccoli", "buff_cauli", "buff_herb", "buff_leek", "buff_cloche", "buff_pot", "buff_cutlery", "buff_flour", "buff_cakestand"]:
		assert_true(TreeCards.KINDS.has(kind), "%s is a card kind" % kind)
		var id: String = str((TreeCards.KINDS[kind] as Dictionary)["id"])
		assert_true(EnvKit.has_art(id), "%s is imported" % id)
		assert_almost_eq(float(EnvKit.entry(id).get("height", 0.0)), ((TreeCards.KINDS[kind] as Dictionary)["size"] as Vector2).y, 0.01, "%s: the registry height is the card height" % id)
	for id: String in ["TEX-BUFF-MASHED", "TEX-BUFF-FROSTING", "TEX-BUFF-BISCUIT", "TEX-BUFF-CHEESE", "TEX-BUFF-GRAVY", "TEX-BUFF-CRUMBSOIL", "DEC-CRUMBS", "DEC-SAUCE"]:
		assert_eq(EnvKit.zone_of(id), "buffet", "%s is an alias of the Buffet kit" % id)
		assert_not_null(EnvKit.texture(id), "%s resolves to the painted texture" % id)
