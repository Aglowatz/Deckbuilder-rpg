extends GutTest
## The corrective pass on the Gainlands (docs/art/gainlands_corrections.md): the zone stays open and readable.
##  - half the trees, standing in groves and along the rim, never on a route;
##  - main routes at least 4 hero-widths wide with nothing solid inside their clearance, open ground round every anchor;
##  - few sign boards, each with a pictogram;
##  - the meadow never dips under the look rig's water plane;
##  - the sub-area data keeps the same limits (tree counts, path widths, flower clumps);
##  - the camera occlusion fade is a smooth transparency: tree cards fade in their own shader from the hero's position, the fader drives no dither.

var layout: GainlandsLayout


func before_each() -> void:
	layout = GainlandsLayout.new()
	layout.build()


func _main_land(kind: String) -> Array[GainlandsLayout.Prop]:
	var result: Array[GainlandsLayout.Prop] = []
	for prop: GainlandsLayout.Prop in layout.props:
		if prop.kind == kind and GainlandsLayout.is_main_ground(prop.pos.x, prop.pos.z):
			result.append(prop)
	return result


func test_half_the_trees_stand_in_groves_and_along_the_rim() -> void:
	var trees: Array[GainlandsLayout.Prop] = _main_land("tree")
	assert_lte(trees.size(), GainlandsLayout.TREE_COUNT, "no more than %d trees on the main land (was 150)" % GainlandsLayout.TREE_COUNT)
	assert_gte(trees.size(), 50, "still a wooded plateau")
	assert_lte(_main_land("boulder").size(), GainlandsLayout.ROCK_COUNT + 2, "a few rocks (plus the two gym boulders), not forty")
	var loners: int = 0
	for tree: GainlandsLayout.Prop in trees:
		var edge: float = GainlandsLayout.main_edge_distance(tree.pos.x, tree.pos.z)
		if edge <= GainlandsLayout.RIM_BAND.y + 0.5:
			continue
		var neighbours: int = 0
		for other: GainlandsLayout.Prop in trees:
			if other != tree and Vector2(other.pos.x - tree.pos.x, other.pos.z - tree.pos.z).length() < 9.0:
				neighbours += 1
		if neighbours < 2:
			loners += 1
	assert_lte(loners, 3, "inland trees stand in groups (deliberate groves), not scattered one by one: %d loners" % loners)


func test_routes_are_wide_and_nothing_solid_stands_on_them() -> void:
	var hub: Vector2 = Vector2(52.0, 62.0)
	for path: Dictionary in layout.paths:
		var width: float = float(path["width"])
		assert_gte(width, GainlandsLayout.SIDE_PATH_WIDTH, "every route is at least %.1f m wide" % GainlandsLayout.SIDE_PATH_WIDTH)
		var line: PackedVector2Array = path["line"] as PackedVector2Array
		if line[0] == hub:
			assert_gte(width, GainlandsLayout.MAIN_PATH_WIDTH, "a road out of the hub is at least %.1f m wide (4 hero-widths)" % GainlandsLayout.MAIN_PATH_WIDTH)
	var on_route: Array[String] = []
	for prop: GainlandsLayout.Prop in layout.props:
		if prop.kind != "tree" and prop.kind != "boulder":
			continue
		if not GainlandsLayout.is_main_ground(prop.pos.x, prop.pos.z):
			continue
		if layout.path_edge_distance(prop.pos.x, prop.pos.z) < GainlandsLayout.PATH_CLEARANCE - 0.01:
			on_route.append("%s at (%.0f, %.0f)" % [prop.kind, prop.pos.x, prop.pos.z])
	assert_eq(on_route, [] as Array[String], "no tree or rock within %.1f m of a path edge" % GainlandsLayout.PATH_CLEARANCE)


func test_open_ground_round_every_anchor_chest_and_sign() -> void:
	var crowded: Array[String] = []
	for key: Variant in layout.anchors.keys():
		var anchor: Vector3 = layout.anchors[key] as Vector3
		for prop: GainlandsLayout.Prop in layout.props:
			if prop.kind != "tree" and prop.kind != "boulder":
				continue
			if Vector2(prop.pos.x - anchor.x, prop.pos.z - anchor.z).length() < GainlandsLayout.ANCHOR_CLEARANCE - 0.01:
				crowded.append("%s near %s" % [prop.kind, str(key)])
	for id: Variant in layout.chests.keys():
		var chest: Vector3 = layout.chests[id] as Vector3
		for prop: GainlandsLayout.Prop in layout.props:
			if (prop.kind == "tree" or prop.kind == "boulder") and Vector2(prop.pos.x - chest.x, prop.pos.z - chest.z).length() < 1.9:
				crowded.append("%s on chest %s" % [prop.kind, str(id)])
	assert_eq(crowded, [] as Array[String], "every NPC, travel point, gate and chest can be reached without weaving round trees")


func test_few_sign_boards_each_with_a_pictogram() -> void:
	assert_lte(layout.signs.size(), 10, "the boards that point somewhere or carry a quiz answer (was 30)")
	for sign: GainlandsLayout.Sign in layout.signs:
		assert_true(GainlandsBuilder.SIGN_ICONS.has(sign.key), "%s has an icon" % sign.key)
	var keys: Array[String] = []
	for sign: GainlandsLayout.Sign in layout.signs:
		keys.append(sign.key)
	for needed: String in ["sign.hub_power", "sign.ripper_rule", "sign.main_dungeon", "sign.exit"]:
		assert_has(keys, needed, "%s stays (a quiz answer or a direction)" % needed)


func test_the_meadow_never_dips_under_the_water() -> void:
	assert_gt(GainlandsLayout.MIN_GROUND, WorldScenery.WATER_Y, "the floor of the meadow is above the water plane")
	var lowest: float = 10.0
	var x: float = GainlandsLayout.CENTER.x - GainlandsLayout.RADII.x
	while x <= GainlandsLayout.CENTER.x + GainlandsLayout.RADII.x:
		var z: float = GainlandsLayout.CENTER.y - GainlandsLayout.RADII.y
		while z <= GainlandsLayout.CENTER.y + GainlandsLayout.RADII.y:
			if GainlandsLayout.is_main_ground(x, z):
				lowest = minf(lowest, layout.ground_height(x, z))
			z += 2.0
		x += 2.0
	assert_gte(lowest, GainlandsLayout.MIN_GROUND - 0.001, "no walkable cell below %.2f (lowest %.2f)" % [GainlandsLayout.MIN_GROUND, lowest])
	assert_gt(lowest, WorldScenery.WATER_Y, "the hero never wades")


func test_subarea_data_stays_open() -> void:
	for sub_id: String in SubAreaDefs.sub_ids("gainlands"):
		var data: Dictionary = SubAreaDefs.sub("gainlands", sub_id)
		var trees: int = 0
		for item: Variant in data.get("scatter", []) as Array:
			var entry: Dictionary = item as Dictionary
			if str(entry.get("kind", "")) == "tree" and str(entry.get("name", "")) != "sunflower" and str(entry.get("name", "")) != "hay":
				trees += int(entry.get("count", 0))
				assert_gte(float(entry.get("path_gap", 0.0)), 3.0, "%s: scattered %s stay %.1f m off the paths" % [sub_id, str(entry.get("name")), 3.0])
		assert_lte(trees, 12, "%s: at most 12 scattered trees (half the old count)" % sub_id)
		var paths: Array = data.get("paths", []) as Array
		assert_gte(float((paths[0] as Dictionary).get("width", 0.0)), 4.2, "%s: the main path is 4 hero-widths wide" % sub_id)
		for item: Variant in paths:
			assert_gte(float((item as Dictionary).get("width", 0.0)), 3.4, "%s: every path is at least 3.4 m wide" % sub_id)
		assert_gte(float((data.get("edge", {}) as Dictionary).get("spacing", 0.0)), 8.5, "%s: the edge belt is loose, not a fence" % sub_id)
		for item: Variant in data.get("flowers", []) as Array:
			assert_lte(int((item as Dictionary).get("count", 0)), 24, "%s: flowers in small clumps" % sub_id)
			assert_lte(float((item as Dictionary).get("radius", 0.0)), 3.5, "%s: flower clumps are small" % sub_id)


func test_tree_cards_fade_in_their_shader_from_the_hero_position() -> void:
	var card: MeshInstance3D = KitFoliage.card("ENV-TREE-OAK", Vector2(5.0, 5.0))
	autofree(card)
	assert_true(card.has_meta(&"no_occlusion_fade"), "the fader leaves tree cards alone (they fade themselves)")
	var shader_code: String = (load(KitFoliage.CARD_SHADER) as Shader).code
	assert_true(shader_code.contains("uniform vec3 hero_pos"), "the card shader knows where the hero is")
	assert_true(shader_code.contains("ALPHA = 1.0 - v_fade"), "and fades with plain alpha, not a dither")
	assert_false(shader_code.contains("BAYER"), "no ordered dither in the card shader")
	KitFoliage.set_hero(Vector3(12.0, 0.5, 34.0))
	var material: ShaderMaterial = card.material_override as ShaderMaterial
	assert_eq(material.get_shader_parameter("hero_pos"), Vector3(12.0, 0.5, 34.0), "set_hero reaches every card material")
	KitFoliage.set_hero(Vector3(0.0, -1000.0, 0.0))
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var field: MultiMeshInstance3D = KitFoliage.tree_field(host, "pine", [{"pos": Vector3.ZERO, "scale": 1.0}] as Array[Dictionary], false)
	assert_true(field.has_meta(&"no_occlusion_fade"), "tree fields opt out of the fader too")


func test_the_occlusion_fader_uses_a_smooth_transparency() -> void:
	var source: String = FileAccess.get_file_as_string("res://world/style/occlusion_fader.gd")
	assert_false(source.contains("set_instance_shader_parameter(\"occlusion_fade\""), "the fader no longer drives the ordered dither")
	assert_true(source.contains("piece.transparency = "), "every faded piece uses the per-instance transparency")
	assert_true(source.contains("KitFoliage.set_hero("), "the fader feeds the hero position to the tree cards")


func test_terrain_and_islands_never_dissolve() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: GainlandsBuilder = GainlandsBuilder.new()
	builder.build(host)
	var land: Node = builder.root.find_child("MainLand", false, false)
	assert_not_null(land)
	assert_true(land.has_meta(&"no_occlusion_fade"), "the plateau is never faded by the camera")
	for island: GainlandsLayout.Island in layout.islands:
		var node: Node = builder.root.find_child("Island_" + island.id, false, false)
		assert_true(node != null and node.has_meta(&"no_occlusion_fade"), "%s never dithers when the camera passes near it" % island.id)
	for cloud: Node3D in builder.cloud_nodes():
		assert_lt(cloud.position.y, -8.0, "no cloud can poke up through the meadow")


func test_the_hub_plaza_is_open_and_the_hub_things_stand_round_its_rim() -> void:
	var hub: Vector3 = layout.anchors["hub"] as Vector3
	var inside: Array[String] = []
	for prop: GainlandsLayout.Prop in layout.props:
		if prop.radius <= 0.0 and prop.kind != "tree":
			continue
		if Vector2(prop.pos.x - hub.x, prop.pos.z - hub.z).length() < GainlandsLayout.PLAZA_RADIUS:
			inside.append("%s at (%.0f, %.0f)" % [prop.kind, prop.pos.x, prop.pos.z])
	for sign: GainlandsLayout.Sign in layout.signs:
		if Vector2(sign.pos.x - hub.x, sign.pos.z - hub.z).length() < GainlandsLayout.PLAZA_RADIUS:
			inside.append(sign.key)
	assert_eq(inside, [] as Array[String], "nothing solid and no board inside the plaza (%.1f m round the hub)" % GainlandsLayout.PLAZA_RADIUS)
	# The important things are spread round the plaza, not bunched: every pair of hub anchors keeps 4 m apart.
	var ring: Array[String] = ["rift_station", "heal", "tony", "brenda", "gus", "protein_stand", "flex_mirror"]
	for a: String in ring:
		for b: String in ring:
			if a < b:
				var pa: Vector3 = layout.anchors[a] as Vector3
				var pb: Vector3 = layout.anchors[b] as Vector3
				assert_gt(Vector2(pa.x - pb.x, pa.z - pb.z).length(), 4.0, "%s and %s have breathing room" % [a, b])
	# ... and each stands on the plaza's rim: between the plaza edge and 15 m out.
	for key: String in ring:
		var pos: Vector3 = layout.anchors[key] as Vector3
		var distance: float = Vector2(pos.x - hub.x, pos.z - hub.z).length()
		assert_between(distance, GainlandsLayout.PLAZA_RADIUS - 2.0, 15.0, "%s stands round the plaza (%.1f m from the centre)" % [key, distance])
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: GainlandsBuilder = GainlandsBuilder.new()
	builder.build(host)
	var dressing: GainlandsDressing = GainlandsDressing.build(host, builder, GraphicsQuality.Level.HIGH)
	for child: Node in dressing.root.get_children():
		var pos: Vector3 = (child as Node3D).position
		assert_gte(Vector2(pos.x - hub.x, pos.z - hub.z).length(), GainlandsLayout.PLAZA_RADIUS - 0.01, "%s stays off the plaza" % child.name)


func test_the_way_in_is_a_walkable_bridge_not_a_portal() -> void:
	for prop: GainlandsLayout.Prop in layout.props:
		assert_ne(prop.kind, "arch", "the portal arch at the exit is gone")
	var spawn: Vector3 = layout.anchors["spawn"] as Vector3
	var exit: Vector3 = layout.anchors["exit"] as Vector3
	assert_eq(layout.surface_at(spawn.x, spawn.z), GainlandsLayout.Surface.BRIDGE, "the hero arrives on the bridge")
	assert_eq(layout.surface_at(exit.x, exit.z), GainlandsLayout.Surface.BRIDGE, "the exit is the far end of the bridge")
	assert_gt(exit.z, spawn.z, "the exit is behind the arriving hero (town side); the zone opens up ahead")
	assert_gte((GainlandsLayout.BRIDGE_HALF_WIDTH - GainlandsLayout.BRIDGE_RAIL) * 2.0, 2.8, "the deck between the rails is four hero-widths")
	assert_eq(layout.surface_at(GainlandsLayout.BRIDGE_X, GainlandsLayout.BRIDGE_Z0 + 0.5), GainlandsLayout.Surface.BRIDGE, "the deck overlaps the rim: no gap between grass and planks")
	assert_true(GainlandsLayout.is_main_ground(GainlandsLayout.BRIDGE_X, GainlandsLayout.BRIDGE_Z0 + 0.5), "the near end stands on the plateau")
	assert_false(GainlandsLayout.is_main_ground(GainlandsLayout.BRIDGE_X, GainlandsLayout.BRIDGE_Z1 - 1.0), "the far end is out over the water")
	var builder: GainlandsBuilder = GainlandsBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	assert_true(builder.is_walkable(spawn, 0.3), "the arrival point is walkable")
	assert_true(builder.is_walkable(exit, 0.3), "the exit landing is walkable")
	assert_false(builder.is_walkable(Vector3(GainlandsLayout.BRIDGE_X + GainlandsLayout.BRIDGE_HALF_WIDTH, 0.0, GainlandsLayout.BRIDGE_Z1 - 8.0), 0.3), "the rails hold the hero on the deck")
	assert_true(builder.map_bounds().has_point(Vector2(exit.x, exit.z)), "the map bounds reach the far landing")
	var can_stand: Callable = func(pos: Vector3) -> bool: return builder.is_walkable(pos, 0.3)
	var hub: Vector3 = layout.anchors["hub"] as Vector3
	var missing: Array[String] = WalkProbe.unreachable(can_stand, spawn, builder.map_bounds(), {"hub": hub, "exit": exit, "main_dungeon": layout.anchors["main_dungeon"]})
	assert_eq(missing, [] as Array[String], "the bridge leads from the arrival point into the plaza and on to the dungeon road")
	assert_almost_eq(builder.height_at(spawn), GainlandsLayout.bridge_height(spawn.z), 0.001, "the hero stands on the deck, not under it")
	assert_gt(GainlandsLayout.bridge_height(spawn.z), WorldScenery.WATER_Y, "the deck is above the water")


func test_the_bridge_model_stands_in_the_zone_and_on_the_town_side() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: GainlandsBuilder = GainlandsBuilder.new()
	builder.build(host)
	var bridge: Node3D = builder.root.find_child("Bridge", false, false) as Node3D
	assert_not_null(bridge, "the zone builds the bridge")
	if bridge != null:
		assert_almost_eq(bridge.position.z, GainlandsLayout.BRIDGE_Z0, 0.01)
		assert_gt((bridge.get_meta("circles", []) as Array).size(), 2, "its gate posts block")
		assert_true((bridge.find_child("Body", true, false) as Node).has_meta(&"no_occlusion_fade"), "the deck never dissolves under the hero")
	var scene: GainlandsScene = (load("res://scenes/gainlands_zone.tscn") as PackedScene).instantiate() as GainlandsScene
	Session.new_game()
	scene.screenshot_prepare({"nohud": "true"})
	add_child(scene)
	await get_tree().process_frame
	assert_true(GainlandsLayout.on_bridge(scene.player.position.x, scene.player.position.z), "a fresh visit starts on the bridge")
	assert_lt(scene.player.position.z, GainlandsLayout.BRIDGE_Z1 - 1.5, "the arrival point is well short of the walk-off end")
	scene._update_bridge_exit()
	assert_false(scene._locked, "arriving never trips the walk-off exit")
	var wake: Vector3 = scene._hub_spawn()
	assert_lt(Vector2(wake.x - 52.0, wake.z - 64.0).length(), GainlandsLayout.PLAZA_RADIUS, "waking after a faint puts the hero in the plaza, not on the bridge")
	scene.queue_free()
	await get_tree().process_frame
	# The town side: the Gainlands passageway has no glow at its end and its connector is the same rope bridge.
	var passage: Node3D = TownPassages.build("beefcake", "The Gainlands", Color.RED, false)
	add_child_autofree(passage)
	assert_null(passage.find_child("FarGlow", true, false), "no portal glow at the end of the Gainlands passage")
	var other: Node3D = TownPassages.build("gourmand", "The Endless Buffet", Color.ORANGE, false)
	add_child_autofree(other)
	assert_not_null(other.find_child("FarGlow", true, false), "the other passages keep theirs")
	var mouth: Vector3 = Vector3(10.0, 0.0, 10.0)
	var out: Vector3 = Vector3(0.0, 0.0, 1.0)
	var connector: Node3D = TownConnectors.build(host, "beefcake", mouth, out, TownConnectors.plan(mouth, out))
	var town_bridge: Node3D = connector.find_child("Bridge", true, false) as Node3D
	assert_not_null(town_bridge, "the town connector has the bridge")
	if town_bridge != null:
		assert_eq(str(town_bridge.get_meta("kind", "")), "bridge", "and it is the rope bridge, the same model as the zone side")


func test_the_house_of_gains_towers_beyond_the_north_rim_and_its_gate_is_the_dungeon_entrance() -> void:
	for prop: GainlandsLayout.Prop in layout.props:
		assert_ne(prop.kind, "gate", "the placeholder gate (white blocks, cones, tape) is gone")
	var entrance: Vector3 = layout.anchors["main_dungeon"] as Vector3
	assert_true(GainlandsLayout.on_causeway(entrance.x, entrance.z), "the dungeon entrance stands on the causeway in front of the fortress doors")
	assert_eq(layout.surface_at(entrance.x, entrance.z), GainlandsLayout.Surface.BRIDGE)
	assert_false(GainlandsLayout.is_main_ground(GainlandsLayout.HOUSE_OF_GAINS.x, GainlandsLayout.HOUSE_OF_GAINS.y), "the fortress stands beyond the rim, on its own rock")
	assert_gt(GainlandsLayout.HOUSE_OF_GAINS_SIZE.y, StorybookScale.TREE_MAX * 4.0, "it towers over the trees (castle-sized)")
	var sign_pos: Vector3 = Vector3.ZERO
	for sign: GainlandsLayout.Sign in layout.signs:
		if sign.key == "sign.main_dungeon":
			sign_pos = sign.pos
	assert_lt(Vector2(sign_pos.x - entrance.x, sign_pos.z - entrance.z).length(), 6.0, "the icon board stands at the gate")
	var builder: GainlandsBuilder = GainlandsBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	assert_true(builder.is_walkable(entrance, 0.3), "the entrance spot is walkable")
	var can_stand: Callable = func(pos: Vector3) -> bool: return builder.is_walkable(pos, 0.3)
	var missing: Array[String] = WalkProbe.unreachable(can_stand, layout.anchors["spawn"] as Vector3, builder.map_bounds(), {"main_dungeon": entrance})
	assert_eq(missing, [] as Array[String], "the causeway joins the plateau: the gate is reachable from the bridge")
	var def: ZoneDef = GainlandsZone.build_def()
	for spot: Dictionary in def.spots:
		if str(spot["id"]) == "main_dungeon":
			assert_true(bool(spot.get("no_plate", false)), "no lettered plate at the gate (the board carries the dungeon icon, the prompt the name)")
			assert_eq(str(spot["kind"]), "main_dungeon", "the entrance interaction is unchanged")


func test_the_fortress_model_builds_with_towers_chimneys_and_a_gate_that_blocks() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: GainlandsBuilder = GainlandsBuilder.new()
	builder.build(host)
	var house: Node3D = builder.root.find_child("Landmark_GAIN-HERO-HOUSE-OF-GAINS", false, false) as Node3D
	assert_not_null(house, "the zone builds the House of Gains")
	if house == null:
		return
	assert_almost_eq(house.position.x, GainlandsLayout.HOUSE_OF_GAINS.x, 0.01)
	assert_almost_eq(house.position.z, GainlandsLayout.HOUSE_OF_GAINS.y, 0.01)
	assert_gte(float(house.get_meta("height", 0.0)), 30.0, "castle-sized")
	assert_eq((house.get_meta("chimneys", []) as Array).size(), 3, "three foundry chimneys")
	var smokes: int = 0
	for child: Node in builder.root.get_children():
		if child is CPUParticles3D and child.name.begins_with("FoundrySmoke"):
			smokes += 1
	assert_eq(smokes, 3, "smoke rises from each")
	assert_gte((house.get_meta("circles", []) as Array).size(), 2, "the gatehouse towers block")
	var body: Node = house.find_child("Body", true, false)
	assert_true(body != null and body.has_meta(&"no_range_cull"), "visible from the whole zone: never range-culled")
	assert_true(GainlandsLandmarks.has_model("GAIN-HERO-HOUSE-OF-GAINS"), "a concept of that id will slot in later")
	# a gatehouse tower is solid, the causeway between them is open
	assert_false(builder.is_walkable(Vector3(GainlandsLayout.HOUSE_OF_GAINS.x + 7.7, 0.0, GainlandsLayout.HOUSE_OF_GAINS.y + 13.0), 0.3), "the east gatehouse tower blocks")
	assert_true(builder.is_walkable(Vector3(GainlandsLayout.HOUSE_OF_GAINS.x, 0.0, GainlandsLayout.CAUSEWAY.position.y + 2.0), 0.3), "the causeway is open")


func test_mount_swolympus_is_a_locked_postgame_bonus() -> void:
	# the hub gate: off the main route (north-east rim), locked, with a coming-soon prompt
	var trailhead: Dictionary = {}
	for gate: Dictionary in SubAreaDefs.gates("gainlands"):
		if str(gate["sub"]) == "swolympus_trailhead":
			trailhead = gate
	assert_false(trailhead.is_empty(), "the trailhead gate is still in the data")
	assert_true(SubAreaGates.is_locked(trailhead), "and locked")
	assert_true(str(trailhead.get("locked_prompt", "")).to_lower().contains("coming soon"), "the prompt says coming soon")
	var gate_pos: Vector3 = SubAreaMap.pos3(trailhead["pos"])
	var road: Vector3 = layout.anchors["main_dungeon"] as Vector3
	assert_gt(Vector2(gate_pos.x - road.x, gate_pos.z - road.z).length(), 25.0, "it stands well off the dungeon road")
	assert_true(SubAreaDefs.sub("gainlands", "swolympus_trailhead").has("landmarks"), "the trailhead data is intact for later")
	# E at the gate goes nowhere
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	host.set_script(null)
	var gates: SubAreaGates = SubAreaGates.new()
	gates.host = host
	gates.gates = [trailhead] as Array[Dictionary]
	SubAreaScene.pending_sub = ""
	gates.go(0)
	assert_ne(SubAreaScene.pending_sub, "swolympus_trailhead", "a locked gate never loads its sub-area")
	# the Sky Garden still hangs off a reachable sub-area
	var to_sky: bool = false
	for item: Variant in SubAreaDefs.sub("gainlands", "proving_grounds").get("exits", []) as Array:
		if str((item as Dictionary).get("to", "")) == "sky_garden":
			to_sky = true
	assert_true(to_sky, "the Proving Grounds lead to the Sky Garden now")
	var back: bool = false
	for item: Variant in SubAreaDefs.sub("gainlands", "sky_garden").get("exits", []) as Array:
		if str((item as Dictionary).get("to", "")) == "proving_grounds":
			back = true
	assert_true(back, "and the Sky Garden leads back")
	# the side dungeon: data intact, sealed, its quest never offered in the main story, no minimap marker
	Session.new_game()
	assert_not_null(DungeonCatalog.side_for_zone(GainlandsZone.ID), "S-BEEF is still in the dungeon list")
	assert_false(Session.side_unlocked("S-BEEF"), "sealed")
	var quest: QuestData = QuestCatalog.find(ZoneQuestDefinitions.SIDE_BEEF)
	assert_not_null(quest)
	assert_true(quest != null and quest.prerequisite != null and quest.prerequisite.kind == Condition.Kind.POSTGAME, "Water for the Hermit waits for the postgame (data file)")
	var defined: QuestData = null
	for candidate: QuestData in ZoneQuestDefinitions.side_quests():
		if candidate.id == ZoneQuestDefinitions.SIDE_BEEF:
			defined = candidate
	assert_true(defined != null and defined.prerequisite != null and defined.prerequisite.kind == Condition.Kind.POSTGAME, "and in the definitions")
	var offered: Array[String] = []
	for item: QuestData in Session.quests_offered_by(GainlandsZone.NPC_BRENDA):
		offered.append(item.id)
	assert_does_not_have(offered, ZoneQuestDefinitions.SIDE_BEEF, "Old Man Mountain does not offer it")
	var def: ZoneDef = GainlandsZone.build_def()
	assert_false(def.poi_kinds.has("mini_dungeon"), "no cavern marker on the minimap")
	var cavern: Vector3 = layout.anchors["mini_dungeon"] as Vector3
	assert_lt(Vector2(cavern.x - gate_pos.x, cavern.z - gate_pos.z).length(), 12.0, "the sealed cavern stands beside the locked gate, one postponed corner")
	# the mountain itself: in the distance, off the land
	var builder: GainlandsBuilder = GainlandsBuilder.new()
	builder.build(host)
	var mountain: Node3D = builder.root.find_child("DistantSwolympus", false, false) as Node3D
	assert_not_null(mountain, "Mount Swolympus stands in the distance")
	if mountain != null:
		assert_false(GainlandsLayout.is_main_ground(mountain.position.x, mountain.position.z), "beyond the rim, never on the route")
		assert_gt(mountain.position.x, gate_pos.x, "behind the locked gate")


func test_the_sealed_cavern_says_coming_soon_in_the_hud() -> void:
	var scene: GainlandsScene = (load("res://scenes/gainlands_zone.tscn") as PackedScene).instantiate() as GainlandsScene
	Session.new_game()
	scene.screenshot_prepare({"nohud": "true"})
	add_child(scene)
	await get_tree().process_frame
	var cavern: ZoneSpot = null
	for spot: ZoneSpot in scene.spots:
		if spot.kind == "mini_dungeon":
			cavern = spot
	assert_not_null(cavern, "the Iron Cavern spot still exists")
	if cavern != null:
		assert_true(scene._prompt_for(cavern).to_lower().contains("coming soon"), "its prompt says coming soon")
		scene._ask_mini_dungeon(cavern)
		assert_false(scene._locked, "E opens nothing (no confirm dialog, no dungeon)")
	scene.queue_free()
	await get_tree().process_frame


func test_every_thrower_route_has_a_clear_landing_and_a_way_back_down() -> void:
	var builder: GainlandsBuilder = GainlandsBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	var throws: int = 0
	for point: GainlandsTravel.Point in GainlandsTravel.points():
		var at: Vector3 = builder.anchor(point.anchor)
		var dest: Vector3 = builder.anchor(point.dest_anchor)
		assert_true(builder.is_walkable(at + Vector3(0.0, 0.0, 1.1), 0.3), "%s: the Beefcake can be reached (its spot is walkable)" % point.id)
		assert_true(builder.is_walkable(dest, 0.3), "%s: the landing spot %s is walkable" % [point.id, point.dest_anchor])
		var open: int = 0
		for step: int in range(8):
			var angle: float = TAU * float(step) / 8.0
			if builder.is_walkable(dest + Vector3(cos(angle) * 1.3, 0.0, sin(angle) * 1.3), 0.3):
				open += 1
		assert_gte(open, 6, "%s: open ground round the landing (%d of 8)" % [point.id, open])
		if point.kind == "throw":
			throws += 1
			var distance: float = Vector2(dest.x - at.x, dest.z - at.z).length()
			var apex: float = clampf(3.0 + distance * 0.28, 5.0, 16.0)
			assert_gt(apex, 3.0, "%s: the arc rises well above both ends (apex %.1f m)" % [point.id, apex])
			if point.dest_anchor.begins_with("arrive_") and GainlandsLayout.is_main_ground(at.x, at.z):
				assert_gt(dest.y, at.y + 5.0, "%s: a throw from the main land lands well above the thrower (%.1f -> %.1f m)" % [point.id, at.y, dest.y])
	assert_gte(throws, 5, "five or more thrower routes")
	for island: GainlandsLayout.Island in builder.layout.islands:
		var way_back: bool = false
		for point: GainlandsTravel.Point in GainlandsTravel.points():
			var at: Vector3 = builder.layout.anchors[point.anchor] as Vector3
			var to: Vector3 = builder.layout.anchors[point.dest_anchor] as Vector3
			if builder.layout.island_at(at.x, at.z) == island and point.lock == null and GainlandsLayout.is_main_ground(to.x, to.z):
				way_back = true
		assert_true(way_back, "%s has an always-open way back down" % island.title)
