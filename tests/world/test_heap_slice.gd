extends GutTest
## The Verdant Dump v2 (docs/art/verdant_dump_v2.md): one walkable zone rising in terraces from the market to the Rotheart, laid out by the declutter
## rules of the playbook (section 5). The way in is a walked bridge, the market an open plaza round the greenhouse, the routes wide and clear, props
## in clusters at the edges, trees at the edges, along the cliff tops and in framing groups, flowers in clumps along the paths (and big foreground
## clumps at the market's corners) that thin toward the Rotheart, the landmarks standing clear or beyond the rim, the corruption gradient read from
## data, the paint-over cameras as layout data, the ways between the terraces of several kinds with two or more per pair of neighbours.

const TREES: Array[String] = ["tree", "bush", "rock", "mushrooms"]

var layout: HeapLayout


func before_all() -> void:
	layout = HeapLayout.new()
	layout.build()


## The things that stand at an anchor (the table at the heal spot, the stable at its spot...): their own prop is not clutter round them.
func _anchored_feature(prop: HeapLayout.Prop) -> bool:
	for key: Variant in layout.anchors.keys():
		var anchor: Vector3 = layout.anchors[key] as Vector3
		if Vector2(prop.pos.x - anchor.x, prop.pos.z - anchor.z).length() < 4.0:
			return true
	return false


func test_the_six_regions_are_the_terraces_and_the_ravine() -> void:
	var ids: Dictionary = {}
	for area: HeapLayout.Area in layout.areas:
		ids[area.id] = area.title
	for id: String in HeapLayout.REGION_IDS:
		assert_true(ids.has(id), "region %s exists" % id)
	assert_eq(str(ids.get("commons", "")), "Compost Commons")
	assert_eq(str(ids.get("throne", "")), "The Throne Approach")
	assert_eq(str(ids.get("stream", "")), "The Ravine")
	# the regions name the spots that belong to them
	var expect: Dictionary = {"hub": "commons", "heal": "commons", "sorrel": "commons", "quiz": "farm", "crop_1": "farm", "barricade_dam": "farm", "minigame": "peaks", "mound_a": "peaks", "pickup_fert_3": "farm", "land_east": "peaks", "main_dungeon": "wetlands", "mini_dungeon": "throne", "puzzle": "throne"}
	for key: String in expect.keys():
		var pos: Vector3 = layout.anchors[key] as Vector3
		var area: HeapLayout.Area = layout.area_at(pos.x, pos.z)
		assert_eq(area.id if area != null else "", str(expect[key]), "%s stands in the %s region" % [key, str(expect[key])])
	for id: String in ["chest_barn", "chest_scree_ne"]:
		var chest: Vector3 = layout.chests[id] as Vector3
		assert_eq(layout.area_at(chest.x, chest.z).id, "peaks", "%s lies on the scree, the junk peaks' plateau pocket" % id)
	assert_eq(layout.area_at(46.0, HeapLayout.stream_z(46.0)).id, "stream", "the river is the Ravine region")
	assert_eq(layout.area_at(HeapLayout.GORGE_X, 70.0).id, "stream", "the gorge too")


func test_routes_are_wide_and_nothing_solid_stands_on_them() -> void:
	for path: Dictionary in layout.paths:
		var width: float = float(path["width"])
		assert_gte(width, HeapLayout.SIDE_PATH_WIDTH, "every route is at least %.1f m wide" % HeapLayout.SIDE_PATH_WIDTH)
	var main_roads: int = 0
	for path: Dictionary in layout.paths:
		if float(path["width"]) >= HeapLayout.MAIN_PATH_WIDTH:
			main_roads += 1
	assert_gte(main_roads, 8, "the roads off the plaza, the terrace lanes, the avenue and the road to the gate are four hero-widths")
	var on_route: Array[String] = []
	for prop: HeapLayout.Prop in layout.props:
		if prop.kind in ["junk_dam"] or _anchored_feature(prop):
			continue
		if prop.radius <= 0.0 and prop.kind not in TREES:
			continue
		if layout.path_edge_distance(prop.pos.x, prop.pos.z) < HeapLayout.PATH_CLEARANCE - 0.01:
			on_route.append("%s at (%.0f, %.0f)" % [prop.kind, prop.pos.x, prop.pos.z])
	assert_eq(on_route, [] as Array[String], "nothing solid within %.1f m of a route edge" % HeapLayout.PATH_CLEARANCE)
	for blocker: Vector3 in HeapLayout.LANDMARK_BLOCKERS:
		if blocker.y < HeapLayout.MIN_CORNER.y + 2.0:
			continue  # the root gate and the throne steps stand at the ends of their roads
		assert_gte(layout.path_edge_distance(blocker.x, blocker.y) - blocker.z, HeapLayout.PATH_CLEARANCE - 0.01, "the landmark at (%.0f, %.0f) keeps off the routes" % [blocker.x, blocker.y])
	# every route runs on walkable ground of its own terrace: no route crosses water, a cliff or a stair's kerb (the ways up are the ramps)
	var builder: HeapBuilder = HeapBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	builder.mounted = true
	for barricade: String in builder.layout.barricade_positions.keys():
		builder.smash_barricade(barricade)
	for path: Dictionary in layout.paths:
		var line: PackedVector2Array = path["line"] as PackedVector2Array
		for i: int in range(line.size() - 1):
			var steps: int = int(line[i].distance_to(line[i + 1]) / 1.0) + 1
			for s: int in range(steps + 1):
				var p: Vector2 = line[i].lerp(line[i + 1], float(s) / float(steps))
				assert_true(builder.is_walkable(Vector3(p.x, 0.0, p.y), 0.3), "the route through (%.1f, %.1f) is walkable" % [p.x, p.y])


func test_open_ground_round_every_anchor_and_chest() -> void:
	var crowded: Array[String] = []
	for key: Variant in layout.anchors.keys():
		var anchor: Vector3 = layout.anchors[key] as Vector3
		for prop: HeapLayout.Prop in layout.props:
			if prop.kind not in TREES:
				continue
			if Vector2(prop.pos.x - anchor.x, prop.pos.z - anchor.z).length() < HeapLayout.ANCHOR_CLEARANCE - 0.01:
				crowded.append("%s near %s" % [prop.kind, str(key)])
	for id: Variant in layout.chests.keys():
		var chest: Vector3 = layout.chests[id] as Vector3
		for prop: HeapLayout.Prop in layout.props:
			if prop.kind in TREES and Vector2(prop.pos.x - chest.x, prop.pos.z - chest.z).length() < 1.9:
				crowded.append("%s on chest %s" % [prop.kind, str(id)])
	assert_eq(crowded, [] as Array[String], "every NPC, gate, pickup and chest can be reached without weaving round trees")
	# interactables never fight for the prompt
	var spots: Array[String] = ["heal", "compost_bin", "trough", "shrine", "stable_1", "stable_2", "rift_station", "wren", "hob", "marigold", "sorrel", "quiz", "minigame"]
	for a: String in spots:
		for b: String in spots:
			if a < b:
				var pa: Vector3 = layout.anchors[a] as Vector3
				var pb: Vector3 = layout.anchors[b] as Vector3
				assert_gt(Vector2(pa.x - pb.x, pa.z - pb.z).length(), 4.0, "%s and %s have breathing room" % [a, b])


func test_props_stand_in_clusters_at_the_edges_never_scattered() -> void:
	var kinds: Dictionary = {}
	for prop: HeapLayout.Prop in layout.props:
		kinds[prop.kind] = int(kinds.get(prop.kind, 0)) + 1
	for gone: String in ["arch", "landfill_gate", "composting_door", "windmill", "wall_tires", "divider"]:
		assert_false(kinds.has(gone), "no %s: the stand-ins, the tyre wall and the district dividers are gone" % gone)
	assert_lte(int(kinds.get("tire_stack", 0)), 6, "tyre stacks only in the clusters (%d)" % int(kinds.get("tire_stack", 0)))
	assert_lte(int(kinds.get("junk_pile", 0)), 4, "junk piles only in the clusters")
	assert_lte(int(kinds.get("car_husk", 0)), 2, "a wreck hides a chest, another stands by the barn; no more")
	assert_eq(int(kinds.get("market_stall", 0)), 3, "three market stalls on the market terrace")
	# every tree stands at an edge: the valley's rim, a cliff top, the ravine's lip, or in a group of three
	var trees: int = 0
	for prop: HeapLayout.Prop in layout.props:
		if prop.kind != "tree":
			continue
		trees += 1
		var near: int = 0
		for other: HeapLayout.Prop in layout.props:
			if other != prop and other.kind == "tree" and Vector2(prop.pos.x - other.pos.x, prop.pos.z - other.pos.z).length() < 6.0:
				near += 1
		var by_cliff: bool = false
		for tier: int in [1, 2, 3]:
			if absf(prop.pos.z - HeapLayout.tier_edge_z(tier, prop.pos.x)) < 5.0:
				by_cliff = true
		if absf(prop.pos.z - HeapLayout.stream_z(prop.pos.x)) < 9.0:
			by_cliff = true
		assert_true(HeapLayout.edge_distance(prop.pos.x, prop.pos.z) < 9.0 or by_cliff or near >= 2, "tree at (%.0f, %.0f) frames an edge, a cliff or stands in a group" % [prop.pos.x, prop.pos.z])
	assert_between(trees, 20, 75, "framing groups, the rims and the cliff tops, not a wood (%d trees)" % trees)
	# flowers stand in clumps along the path edges, the crop row, or the big foreground clumps at the market's corners and the ravine's lip
	var flowers: int = 0
	for prop: HeapLayout.Prop in layout.props:
		if prop.kind != "flowers":
			continue
		flowers += 1
		var by_crops: bool = prop.pos.z > 73.5 and prop.pos.z < 78.0 and prop.pos.x < 44.0
		var foreground: bool = prop.pos.z > 130.0 or (prop.pos.z > 98.0 and prop.pos.z < 104.0)
		assert_true(layout.path_edge_distance(prop.pos.x, prop.pos.z) < 3.5 or by_crops or foreground, "flowers at (%.0f, %.0f) line a path, the crop row or frame the view" % [prop.pos.x, prop.pos.z])
	assert_gte(flowers, 40, "there are flower clumps (%d flowers)" % flowers)


func test_the_hub_plaza_is_open_round_the_greenhouse() -> void:
	var inside: Array[String] = []
	for prop: HeapLayout.Prop in layout.props:
		if prop.radius <= 0.0 and prop.kind not in TREES:
			continue
		if Vector2(prop.pos.x - HeapLayout.PLAZA_CENTER.x, prop.pos.z - HeapLayout.PLAZA_CENTER.y).length() < HeapLayout.PLAZA_RADIUS:
			inside.append("%s at (%.0f, %.0f)" % [prop.kind, prop.pos.x, prop.pos.z])
	for sign: HeapLayout.Sign in layout.signs:
		if Vector2(sign.pos.x - HeapLayout.PLAZA_CENTER.x, sign.pos.z - HeapLayout.PLAZA_CENTER.y).length() < HeapLayout.PLAZA_RADIUS:
			inside.append(sign.key)
	assert_eq(inside, [] as Array[String], "nothing solid and no board inside the plaza (%.1f m) but the greenhouse" % HeapLayout.PLAZA_RADIUS)
	assert_true(HeapLayout.GREENHOUSE.is_equal_approx(HeapLayout.PLAZA_CENTER), "the greenhouse is the plaza's centrepiece")
	var wake: Vector3 = layout.anchors["hub"] as Vector3
	assert_lt(Vector2(wake.x - HeapLayout.PLAZA_CENTER.x, wake.z - HeapLayout.PLAZA_CENTER.y).length(), HeapLayout.PLAZA_RADIUS, "the hub anchor (where you wake) is in the plaza")
	var builder: HeapBuilder = HeapBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	assert_false(builder.is_walkable(Vector3(HeapLayout.PLAZA_CENTER.x, 0.0, HeapLayout.PLAZA_CENTER.y), 0.3), "the greenhouse is solid")
	assert_true(builder.is_walkable(wake, 0.3), "the wake point is open ground")
	assert_eq(HeapLayout.tier_at(wake.x, wake.z), 0, "the market is the lowest terrace")
	for key: String in ["heal", "hob", "wren", "marigold", "rift_station", "compost_bin", "stable_1"]:
		var pos: Vector3 = layout.anchors[key] as Vector3
		var distance: float = Vector2(pos.x - HeapLayout.PLAZA_CENTER.x, pos.z - HeapLayout.PLAZA_CENTER.y).length()
		assert_between(distance, HeapLayout.PLAZA_RADIUS - 1.0, 22.0, "%s stands on the plaza's rim (%.1f m)" % [key, distance])


func test_few_sign_boards_each_with_a_pictogram_and_the_quiz_answers_stay() -> void:
	assert_lte(layout.signs.size(), 24, "the boards that label something")
	var keys: Array[String] = []
	for sign: HeapLayout.Sign in layout.signs:
		assert_true(HeapBuilder.SIGN_ICONS.has(sign.key), "%s has an icon" % sign.key)
		assert_ne(sign.style, "memo", "no memos (%s)" % sign.key)
		assert_ne(sign.style, "poster", "no posters (%s)" % sign.key)
		assert_true(layout.surface_at(sign.pos.x, sign.pos.z) in [HeapLayout.Surface.GROUND, HeapLayout.Surface.PEAK], "%s stands on the ground, not a cliff or the water" % sign.key)
		keys.append(sign.key)
	for needed: String in ["sign.hub_main", "sign.oath", "sign.crops", "sign.fields", "sign.main_dungeon", "sign.landfill", "sign.exit", "sign.barricade", "sign.dam"]:
		assert_has(keys, needed, "%s stays (a quiz answer or a label)" % needed)


func test_the_way_in_is_a_walkable_bridge_not_a_portal() -> void:
	var spawn: Vector3 = layout.anchors["spawn"] as Vector3
	var exit: Vector3 = layout.anchors["exit"] as Vector3
	assert_eq(layout.surface_at(spawn.x, spawn.z), HeapLayout.Surface.BRIDGE, "the hero arrives on the bridge")
	assert_eq(layout.surface_at(exit.x, exit.z), HeapLayout.Surface.BRIDGE, "the exit is the far end of the bridge")
	assert_gt(exit.z, spawn.z, "the exit is behind the arriving hero (town side); the zone opens up ahead")
	assert_gte((HeapLayout.ENTRANCE_HALF_WIDTH - HeapLayout.ENTRANCE_RAIL) * 2.0, 2.8, "the deck between the kerbs is four hero-widths")
	assert_gt(HeapLayout.edge_distance(HeapLayout.ENTRANCE_X, HeapLayout.ENTRANCE_Z0 + 0.5), 0.0, "the near end stands on the land")
	assert_lt(HeapLayout.edge_distance(HeapLayout.ENTRANCE_X, HeapLayout.ENTRANCE_Z1 - 1.0), 0.0, "the far end is out over the overflow pool")
	var builder: HeapBuilder = HeapBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	assert_true(builder.is_walkable(spawn, 0.3), "the arrival point is walkable")
	assert_true(builder.is_walkable(exit, 0.3), "the exit landing is walkable")
	assert_false(builder.is_walkable(Vector3(HeapLayout.ENTRANCE_X + HeapLayout.ENTRANCE_HALF_WIDTH, 0.0, HeapLayout.ENTRANCE_Z1 - 8.0), 0.3), "the kerbs hold the hero on the deck")
	assert_true(builder.map_bounds().has_point(Vector2(exit.x, exit.z)), "the map bounds reach the far landing")
	assert_almost_eq(builder.height_at(spawn), 0.0, 0.001, "the hero stands on the deck")
	assert_almost_eq(builder.height_at(Vector3(HeapLayout.ENTRANCE_X, 0.0, HeapLayout.ENTRANCE_Z0 + 1.0)), 0.0, 0.25, "the land meets the deck level at the bridge head (no step)")
	var can_stand: Callable = func(pos: Vector3) -> bool: return builder.is_walkable(pos, 0.3)
	var missing: Array[String] = WalkProbe.unreachable(can_stand, spawn, builder.map_bounds(), {"hub": layout.anchors["hub"], "heal": layout.anchors["heal"], "quiz": layout.anchors["quiz"], "minigame": layout.anchors["minigame"], "mound_a": layout.anchors["mound_a"], "giant_chest": layout.anchors["giant_chest"], "vault_lever": layout.anchors["vault_lever"], "mound_east": layout.anchors["mound_east"]}, 2.5)
	assert_eq(missing, [] as Array[String], "the bridge leads into the plaza and on (by the east stairs) to the farm and compost terraces")
	var passage: Node3D = TownPassages.build("refusemancer", "The Verdant Dump", Color.GREEN, false)
	add_child_autofree(passage)
	assert_null(passage.find_child("FarGlow", true, false), "no portal glow at the end of the Dump passage")


func test_the_zone_is_narrow_deep_and_terraced_with_the_river_below() -> void:
	var width: float = HeapLayout.MAX_CORNER.x - HeapLayout.MIN_CORNER.x
	var depth: float = HeapLayout.MAX_CORNER.y - HeapLayout.MIN_CORNER.y
	assert_gt(depth, width * 1.8, "much deeper than wide (%.0f x %.0f)" % [width, depth])
	assert_eq(HeapLayout.TIER_HEIGHTS.size(), 4, "four terraces")
	for tier: int in range(1, 4):
		assert_gte(HeapLayout.TIER_HEIGHTS[tier] - HeapLayout.TIER_HEIGHTS[tier - 1], 3.0, "each terrace stands a storey or more above the one below")
	assert_lte(HeapLayout.WATER_LEVEL, HeapLayout.TIER_HEIGHTS[0] - 2.0, "the river runs in a ravine below the market")
	# the spring: the river's gorge steps down with the terraces, the ravine runs west to east under the market
	assert_gt(HeapLayout.gorge_water_level(45.0), HeapLayout.gorge_water_level(75.0), "the gorge's water steps down the terraces")
	assert_gt(HeapLayout.gorge_water_level(75.0), HeapLayout.WATER_LEVEL)
	assert_lt(HeapLayout.stream_z(30.0), HeapLayout.TIER_EDGE_Z[1] + 60.0)
	# the ways up: several kinds, two or more per pair of neighbouring terraces, and a sightline: the plateau is higher than the market
	var kinds: Dictionary = {}
	for ramp: HeapLayout.Ramp in layout.ramps:
		kinds[ramp.kind] = true
	for kind: String in ["stairs", "ramp", "ladder", "scree"]:
		assert_true(kinds.has(kind), "a %s" % kind)
	assert_gte(layout.ramps.size() + layout.bridges.size(), 8, "many ways between the terraces (%d)" % (layout.ramps.size() + layout.bridges.size()))


func test_the_landmarks_stand_clear_or_beyond_the_rim() -> void:
	assert_lt(HeapLayout.ROTHEART.y, HeapLayout.MIN_CORNER.y, "the Rotheart stands north of the land")
	assert_gte(HeapLayout.ROTHEART_SIZE.y, 40.0, "the Rotheart is castle scale (%.0f m)" % HeapLayout.ROTHEART_SIZE.y)
	assert_gte(HeapLayout.ROTHEART_SIZE.x, 40.0)
	assert_lt(HeapLayout.JUNK_MOUNTAIN.y, HeapLayout.MIN_CORNER.y)
	assert_gt(HeapLayout.JUNK_MOUNTAIN.x, HeapLayout.MAX_CORNER.x, "Junk Mountain lies beyond the north-east corner")
	assert_lt(HeapLayout.THRONE.y + HeapLayout.THRONE_SIZE.z * 0.5, HeapLayout.MIN_CORNER.y, "the throne's dais is beyond the north rim; only its steps reach the land")
	assert_lt(Vector2(HeapLayout.ROTHEART.x - 50.0, 0.0).length(), 6.0, "the Rotheart stands on the zone's centre line, seen from most of it")
	for spot: Vector3 in HeapLayout.LANDMARK_SPOTS:
		assert_true(spot in layout.flat_spots, "the ground under (%.1f, %.1f) is flat" % [spot.x, spot.y])
		for key: Variant in layout.anchors.keys():
			if str(key) in ["main_dungeon", "mini_dungeon", "hub"]:
				continue
			var anchor: Vector3 = layout.anchors[key] as Vector3
			var gap: float = Vector2(spot.x - anchor.x, spot.y - anchor.z).length() - spot.z
			assert_gte(gap, 1.5, "%s stays off the landmark at (%.1f, %.1f) (%.1f m)" % [str(key), spot.x, spot.y, gap])
	for prop: HeapLayout.Prop in layout.props:
		if prop.kind in TREES or prop.kind == "flowers":
			for spot: Vector3 in HeapLayout.LANDMARK_SPOTS:
				assert_gte(Vector2(prop.pos.x - spot.x, prop.pos.z - spot.y).length(), spot.z - 0.01, "no %s under the landmark at (%.1f, %.1f)" % [prop.kind, spot.x, spot.y])
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: HeapBuilder = HeapBuilder.new()
	builder.build(host)
	for id: String in ["DUMP-HERO-ROTHEART", "DUMP-HERO-JUNK-MOUNTAIN", "DUMP-HERO-TRASH-PANDA-THRONE", "DUMP-HERO-WINDMILL", "DUMP-HERO-COMMONS-GREENHOUSE", "HEAP-ROOT-GATE"]:
		var node: Node3D = builder.landmarks.get(id) as Node3D
		assert_not_null(node, "%s stands in the zone" % id)
		if node == null:
			continue
		assert_eq(node.get_parent(), builder.root, "%s hangs off the root, never a chunk" % id)
		for piece: Node in node.find_children("*", "MeshInstance3D", true, false):
			assert_true(piece.has_meta(&"no_range_cull"), "%s never culls" % id)
			if id in ["DUMP-HERO-ROTHEART", "DUMP-HERO-JUNK-MOUNTAIN", "DUMP-HERO-TRASH-PANDA-THRONE"]:
				assert_true(piece.has_meta(&"no_occlusion_fade"), "%s never fades" % id)
	assert_not_null(builder.rotheart)
	assert_almost_eq(builder.rotheart.position.y, HeapLayout.TIER_HEIGHTS[3] - 0.4, 0.6, "the Rotheart stands at the plateau's level, its roots reaching the root gate")
	var gate: Vector3 = layout.anchors["main_dungeon"] as Vector3
	assert_true(builder.is_walkable(gate + Vector3(0.0, 0.0, 1.4), 0.3), "the hero can stand at the Rotheart's root gate")
	assert_false(builder.is_walkable(Vector3(HeapLayout.ROOT_GATE.x, 0.0, HeapLayout.ROOT_GATE.y - 1.5), 0.1), "the root gate's hollow is solid")
	var door: Vector3 = layout.anchors["mini_dungeon"] as Vector3
	assert_true(builder.is_walkable(door + Vector3(0.0, 0.0, 1.6), 0.3), "the hero can stand at the throne's steps")
	assert_false(builder.is_walkable(Vector3(HeapLayout.WINDMILL.x, 0.0, HeapLayout.WINDMILL.y), 0.1), "the windmill's tower is solid")
	assert_true((builder.landmarks["DUMP-HERO-WINDMILL"] as Node3D).has_meta("spinner"), "the windmill's sails turn")
	for key: String in ["crop_1", "quiz", "pickup_fert_2", "animal_1"]:
		var anchor: Vector3 = layout.anchors[key] as Vector3
		assert_gte(Vector2(anchor.x - HeapLayout.WINDMILL.x, anchor.z - HeapLayout.WINDMILL.y).length() - HeapLayout.WINDMILL_SIZE.x * 0.5, 3.0, "the windmill keeps %s clear" % key)
	var bridge: Node3D = builder.root.find_child("Bridge", false, false) as Node3D
	assert_not_null(bridge, "the zone builds the entrance bridge")
	if bridge != null:
		assert_gt((bridge.get_meta("circles", []) as Array).size(), 2, "its gate pillars and landing posts block")
		assert_true((bridge.find_child("Body", true, false) as Node).has_meta(&"no_occlusion_fade"), "the deck never dissolves under the hero")
	for name: String in ["Land", "FarGround", "RecyclingStream", "OverflowPool", "Gorge0", "SludgeChasm", "DrainPool"]:
		var piece: Node = builder.root.find_child(name, false, false)
		assert_true(piece != null and piece.has_meta(&"no_occlusion_fade") and piece.has_meta(&"no_range_cull"), "%s never fades or culls" % name)


## The terraces are built: stone stairs on every stair ramp, the root ramp, a vine ladder on every ladder ramp, the scree's junk, vines down the cliffs,
## rope fences along the ravine's lips, three waterfalls with mist and two turning water wheels in the gorge, the drain grate; the arched vine bridges
## climb from the market to the farm terrace.
func test_the_ways_up_and_the_water_are_built() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: HeapBuilder = HeapBuilder.new()
	builder.build(host)
	var names: Array[String] = []
	for child: Node in builder.root.get_children():
		names.append(str(child.name))
	for ramp: HeapLayout.Ramp in layout.ramps:
		var prefix: String = {"stairs": "Stairs_", "ramp": "RootRamp_", "ladder": "VineLadder_", "scree": "Scree_"}[ramp.kind]
		assert_has(names, prefix + ramp.id, "%s is built as %s" % [ramp.id, ramp.kind])
	assert_has(names, "CliffVines", "vines drape the cliff faces")
	var count: Callable = func(prefix: String) -> int:
		var n: int = 0
		for name: String in names:
			if name.begins_with(prefix):
				n += 1
		return n
	assert_gte(int(count.call("RopeFence")), 4, "rope fences along the ravine's lips")
	assert_gte(int(count.call("Fall")), 3, "three waterfalls")
	assert_eq(int(count.call("WaterWheel")), 2, "two water wheels")
	var wheel: Node3D = builder.root.find_child("WaterWheelBig", false, false) as Node3D
	var spinner: Node3D = wheel.get_meta("spinner") as Node3D
	var before: float = spinner.rotation.z
	builder.animate(0.5)
	assert_ne(spinner.rotation.z, before, "the wheels turn")
	assert_has(names, "DrainGrate", "the junk-choked drain at the ravine's end")
	for id: String in ["bridge_center", "bridge_west"]:
		var node: Node3D = builder.bridge_nodes[id] as Node3D
		var first: Node3D = node.get_node("Seg0") as Node3D
		var last: Node3D = node.get_child(node.get_child_count() - 1) as Node3D
		assert_gt(last.position.y, first.position.y + 2.0, "%s climbs from the market up to the farm terrace" % id)
		var mid: Node3D = node.get_child(node.get_child_count() / 2) as Node3D
		assert_gt(mid.position.y, (first.position.y + last.position.y) * 0.5 + 0.5, "%s arches" % id)
	# the fall: walking off the arched bridge lands the hero in the ravine's water, below the market
	var bridge: HeapLayout.Bridge = layout.bridges[0]
	var off: Vector2 = bridge.a.lerp(bridge.b, 0.5) + Vector2(HeapLayout.BRIDGE_HALF_WIDTH + 0.4, 0.0)
	assert_true(builder.is_in_hazard(Vector3(off.x, 0.0, off.y)), "stepping off the arched bridge's side is the river")
	assert_lt(layout.water_level_at(off.x, off.y), HeapLayout.TIER_HEIGHTS[0] - 2.0, "...far below")


func test_the_corruption_gradient_comes_from_data() -> void:
	var data: Dictionary = ZoneStyles.style("heap").get("corruption", {}) as Dictionary
	assert_false(data.is_empty(), "data/zone_styles/heap.json has the corruption block")
	assert_eq(layout.corruption, data, "the layout reads it")
	assert_almost_eq(layout.corruption_at(50.0, 120.0), 0.0, 0.001, "the market is healthy")
	assert_almost_eq(layout.corruption_at(34.0, 78.0), 0.0, 0.001, "the farm terrace is healthy")
	var compost: float = layout.corruption_at(50.0, 48.0)
	var plateau: float = layout.corruption_at(50.0, 22.0)
	var roots: float = layout.corruption_at(50.0, 9.0)
	assert_lt(compost, plateau, "the land grows more twisted up the terraces")
	assert_lt(plateau, roots, "...and most at the Rotheart's roots")
	assert_gte(roots, 0.95, "full corruption at the roots")
	assert_lt(layout.corruption_at(29.0, 19.0), layout.corruption_at(50.0, 19.0), "the throne approach is less twisted than the plateau's centre")
	var north: int = 0
	var south: int = 0
	for prop: HeapLayout.Prop in layout.props:
		if prop.kind == "flowers":
			if prop.pos.z < 36.0:
				north += 1
			elif prop.pos.z > 100.0:
				south += 1
	assert_lt(north * 2, south, "flowers thin toward the Rotheart (%d on the plateau, %d on the market)" % [north, south])
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: HeapBuilder = HeapBuilder.new()
	builder.build(host)
	var healthy: Color = builder._terrain_color(Vector3(34.0, 3.0, 78.0))
	var twisted: Color = builder._terrain_color(Vector3(50.0, 10.0, 12.0))
	assert_gt(twisted.b / maxf(twisted.g, 0.001), healthy.b / maxf(healthy.g, 0.001), "the plateau's ground leans violet against the farm's green")
	assert_lt(twisted.get_luminance(), healthy.get_luminance(), "and darker")
	var cliff: Color = builder._terrain_color(Vector3(56.0, 8.0, HeapLayout.tier_edge_z(3, 56.0) + 0.8), 0.9)
	assert_gt(cliff.b, cliff.g * 0.9, "the cliffs are cool grey-violet stone, not rust")


func test_the_paint_over_cameras_are_layout_data_on_open_ground_facing_the_rotheart() -> void:
	var builder: HeapBuilder = HeapBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	builder.mounted = false
	for name: String in ["po_hub", "po_junk_peaks", "po_farm_rows", "po_stream", "po_wetlands", "po_throne_approach"]:
		assert_true(HeapLayout.PO_CAMERAS.has(name), "%s is a camera spot" % name)
		var at: Vector2 = HeapLayout.PO_CAMERAS[name] as Vector2
		assert_true(builder.is_walkable(Vector3(at.x, 0.0, at.y), 0.3), "%s stands on open ground" % name)
		assert_false(layout.anchors.has(name), "%s is not an anchor" % name)
		assert_lt(HeapLayout.ROTHEART.y, at.y, "%s looks north toward the Rotheart" % name)
		var bearing: float = rad_to_deg(atan2(absf(HeapLayout.ROTHEART.x - at.x), at.y - HeapLayout.ROTHEART.y))
		assert_lt(bearing, 30.0, "%s has the Rotheart in frame (%.0f degrees off north)" % [name, bearing])
	var ravine_view: Vector2 = HeapLayout.PO_CAMERAS["po_stream"] as Vector2
	assert_eq(HeapLayout.tier_at(ravine_view.x, ravine_view.y), 0, "the reference's view is from the market's edge, looking up the terraces")


func test_a_fresh_visit_starts_on_the_bridge_facing_the_commons() -> void:
	var scene: HeapScene = (load("res://scenes/heap_zone.tscn") as PackedScene).instantiate() as HeapScene
	Session.new_game()
	scene.screenshot_prepare({"nohud": "true"})
	add_child(scene)
	await get_tree().process_frame
	assert_true(HeapLayout.on_entrance(scene.player.position.x, scene.player.position.z), "a fresh visit starts on the bridge")
	assert_lt(scene.player.position.z, HeapLayout.ENTRANCE_Z1 - 1.5, "the arrival point is well short of the walk-off end")
	scene._update_entrance_exit()
	assert_false(scene._locked, "arriving never trips the walk-off exit")
	var wake: Vector3 = scene._hub_spawn()
	assert_lt(Vector2(wake.x - HeapLayout.PLAZA_CENTER.x, wake.z - HeapLayout.PLAZA_CENTER.y).length(), HeapLayout.PLAZA_RADIUS, "waking after a faint puts the hero in the plaza, not on the bridge")
	for spot: ZoneSpot in scene.spots:
		if spot.kind in ["main_dungeon", "mini_dungeon"]:
			assert_false(spot.plate.visible, "%s: no lettered plate at the door (its board carries a pictogram)" % spot.id)
	assert_null(scene.heap.root.find_child("MM_tire_stack", false, false), "no scattered tyre multimesh")
	scene.queue_free()
	await get_tree().process_frame


func test_the_occlusion_fader_uses_a_smooth_transparency() -> void:
	var source: String = FileAccess.get_file_as_string("res://world/style/occlusion_fader.gd")
	assert_false(source.contains("set_instance_shader_parameter(\"occlusion_fade\""), "the fader no longer drives the ordered dither")
	assert_true(source.contains("piece.transparency = "), "every faded piece uses the per-instance transparency")


func test_the_rotheart_is_the_concept_model_with_a_living_heart() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: HeapBuilder = HeapBuilder.new()
	builder.build(host)
	var tree: Node3D = builder.rotheart
	assert_eq(str(tree.get_meta("hero_id", "")), "DUMP-HERO-ROTHEART", "the Rotheart is the concept model, not a stand-in")
	assert_not_null(tree.get_meta("heart", null), "its hollow has a glow the builder pulses")
	var lights: Array = tree.get_meta("lights", []) as Array
	assert_eq(lights.size(), 1, "one real light: the heart's")
	assert_not_null(tree.find_child("HeartMotes", true, false), "violet motes drift out of the hollow")
	var approach: Vector3 = tree.get_meta("approach", Vector3.ZERO) as Vector3
	var reach_z: float = HeapLayout.ROTHEART.y + approach.z
	assert_almost_eq(reach_z, HeapLayout.ROOT_GATE.y - HeapLayout.ROOT_GATE_SIZE.z * 0.5, 2.0, "the approach roots end at the back of the root gate")
	var heart: StandardMaterial3D = tree.get_meta("heart") as StandardMaterial3D
	var before: Color = heart.albedo_color
	builder.animate(1.3)
	assert_ne(heart.albedo_color, before, "the heart pulses")
	HeapLandmarks.set_freed(tree, true)
	var freed_hue: Color = heart.get_meta("base_color") as Color
	assert_gt(freed_hue.g, freed_hue.r, "freed, the heart glows green")
	HeapLandmarks.set_freed(tree, false)
	assert_gt((heart.get_meta("base_color") as Color).b, (heart.get_meta("base_color") as Color).g, "the Rot is violet again")
	var gate: Node3D = builder.landmarks["HEAP-ROOT-GATE"] as Node3D
	assert_not_null(gate.find_child("Walk", false, false), "a plank walk leads in to the gate")
	assert_not_null(gate.get_meta("heart", null), "the gate's doorway glows with the heart")


func test_the_corruption_gradient_is_data_and_recedes_when_freed() -> void:
	var c: Dictionary = ZoneStyles.style("heap").get("corruption", {}) as Dictionary
	for key: String in ["trees", "fungus", "texture", "grade", "light", "freed"]:
		assert_true(c.has(key), "the gradient's %s is data in data/zone_styles/heap.json" % key)
	var hub: float = layout.corruption_at(50.0, 120.0)
	var compost: float = layout.corruption_at(50.0, 46.0)
	var plateau: float = layout.corruption_at(50.0, 22.0)
	var roots: float = layout.corruption_at(50.0, 9.0)
	assert_almost_eq(hub, 0.0, 0.001, "the market is healthy")
	assert_almost_eq(layout.corruption_at(34.0, 78.0), 0.0, 0.001, "the farm terrace is healthy")
	assert_true(compost > hub and plateau > compost and roots > plateau, "it deepens toward the Rotheart (%.2f %.2f %.2f %.2f)" % [hub, compost, plateau, roots])
	var step: float = 0.0
	for z: int in range(130, 8, -1):
		step = maxf(step, absf(layout.corruption_at(50.0, float(z)) - layout.corruption_at(50.0, float(z) + 1.0)))
	assert_lt(step, 0.08, "no hard line: at most %.2f per metre" % step)
	for freed: bool in [false, true]:
		var host: Node3D = Node3D.new()
		add_child_autofree(host)
		var builder: HeapBuilder = HeapBuilder.new()
		builder.freed = freed
		builder.build(host)
		var twisted: MultiMeshInstance3D = builder.root.find_child("Trees_dump_twisted_shadow", false, false) as MultiMeshInstance3D
		var oaks: MultiMeshInstance3D = builder.root.find_child("Trees_dump_oak_shadow", false, false) as MultiMeshInstance3D
		assert_not_null(oaks, "vine oaks stand where it is healthy")
		# Oct 19 (Part 4): the route's purple-mushroom trees stand in the Dump whether or not it is freed, thickest at the bridge head
		var shroom: MultiMeshInstance3D = builder.root.find_child("Trees_dump_shroom_shadow", false, false) as MultiMeshInstance3D
		assert_not_null(shroom, "the purple-mushroom trees lead into the zone")
		if shroom != null:
			var points: Array = shroom.get_meta("points", []) as Array
			var near_entrance: int = 0
			for point: Variant in points:
				var at: Vector3 = (point as Dictionary)["pos"] as Vector3
				if at.z > 120.0:
					near_entrance += 1
			assert_gte(points.size(), 20, "a few dozen of them")
			assert_gte(near_entrance, 10, "densest round the entrance bridge head")
			assert_lt(near_entrance, points.size(), "and some scattered through the tiers")
		if freed:
			assert_null(twisted, "freed: no twisted trees")
			assert_almost_eq(builder.twist_at(50.0, 9.0), 0.0, 0.001, "freed: the corruption is gone")
		else:
			assert_not_null(twisted, "twisted trees toward the Rotheart")
			if twisted != null:
				for point: Variant in twisted.get_meta("points", []) as Array:
					var at: Vector3 = (point as Dictionary)["pos"] as Vector3
					assert_gt(layout.corruption_at(at.x, at.z), 0.15, "a twisted tree at (%.0f, %.0f) stands in the corruption" % [at.x, at.z])
			assert_not_null(builder.root.find_child("Trees_dump_fungus_far", false, false), "violet fungus grows toward the roots")


func test_the_dressing_is_the_kit_in_tidy_clusters_off_the_routes() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: HeapBuilder = HeapBuilder.new()
	builder.build(host)
	var dressing: HeapDressing = HeapDressing.build(host, builder, 1)
	assert_gte(dressing.count, 14, "the kit clusters, reeds and fungus are placed where they fit (%d)" % dressing.count)
	var layout: HeapLayout = builder.layout
	for child: Node in dressing.root.get_children():
		var pos: Vector3 = (child as Node3D).position
		var solid: bool = not ((child as Node3D).get_meta("circles", []) as Array).is_empty()
		if solid:
			assert_gte(layout.path_edge_distance(pos.x, pos.z), HeapLayout.PATH_CLEARANCE - 0.01, "%s keeps off the routes" % child.name)
			assert_null(layout.ramp_at(pos.x, pos.z), "%s keeps off the stairs and ramps" % child.name)
		assert_gte(Vector2(pos.x - HeapLayout.PLAZA_CENTER.x, pos.z - HeapLayout.PLAZA_CENTER.y).length(), HeapLayout.PLAZA_RADIUS, "%s keeps out of the plaza" % child.name)
		for key: Variant in layout.anchors.keys():
			var anchor: Vector3 = layout.anchors[key] as Vector3
			assert_gte(Vector2(pos.x - anchor.x, pos.z - anchor.z).length(), 2.0, "%s keeps off %s" % [child.name, key])
	if EnvKit.has_art("DUMP-PROP-WINDMILL"):
		var mills: Array[Node] = dressing.root.find_children("Cluster_windmill_plot_*", "", false, false)
		var spots: Array[String] = []
		for mill: Node in mills:
			spots.append("(%.0f, %.0f)" % [(mill as Node3D).position.x, (mill as Node3D).position.z])
		assert_eq(mills.size(), 3, "the three little windmills stand on the farm and market terraces: %s" % ", ".join(spots))
	assert_null(builder.root.find_child("ScrapFence", false, false), "no tyre wall and no dividers any more")
	assert_not_null(builder.root.find_child("PlankWalks", false, false), "plank walks on the main routes")
	var shacks: int = 0
	for child: Node in builder.root.get_children():
		if child.find_child("Body", false, false) != null and str(child.name).contains("Shack"):
			shacks += 1
	assert_eq(shacks, 2, "the two barns are patched shacks")
	assert_not_null(builder.root.find_child("SwapStall", true, false), "Gristle's stall")
	assert_eq(builder.root.find_children("MarketStall_*", "", false, false).size(), 3, "three market stalls under awnings")
	for id: String in builder.bridge_nodes.keys():
		assert_not_null((builder.bridge_nodes[id] as Node3D).get_node_or_null("Seg0"), "the %s bridge still grows segment by segment" % id)
	assert_not_null(builder.root.find_child("Woods_dump_oak", false, false), "woods stand on the rim above the valley's walls")
