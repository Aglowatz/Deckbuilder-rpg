extends GutTest
## Crosspath pass, Part D: where the hero can walk in the hub, and why not further. Every edge of the walkable country has a blocker the player can
## see just outside it (woods, thorns, a ridge, walls, a fence, a hedge, the lake, the gorge); nothing beyond the edge can be reached; the hero can
## walk a full loop round the town; each zone road is the only way through its obstacle.

var _town: TownBuilder
var _land: HubLand


func before_all() -> void:
	var root: Node3D = Node3D.new()
	add_child(root)
	_town = TownBuilder.new()
	_town.build(root, false)
	_land = HubLand.build(_town.root, _town, StandardMaterial3D.new())


func after_all() -> void:
	for child: Node in get_children():
		child.queue_free()


func _near_blocker(pos: Vector3, reach: float) -> bool:
	for blocker: Vector3 in _land.boundary.blockers:
		if Vector2(blocker.x - pos.x, blocker.z - pos.z).length() < reach:
			return true
	return false


func test_every_edge_has_a_blocker_you_can_see() -> void:
	var bare: Array[String] = []
	var gaps: Array[Vector2] = []
	for edge: Dictionary in TownBounds.edges():
		if str(edge["kind"]) == "passage":
			gaps.append(edge["a"] as Vector2)
			gaps.append(edge["b"] as Vector2)
	for sample: Dictionary in TownBounds.samples(1.5):
		var kind: String = str(sample["kind"])
		var pos: Vector3 = sample["pos"] as Vector3
		var out: Vector3 = sample["out"] as Vector3
		# the last few metres beside a passage belong to the passage's own obstacle and its wings (checked by the gate test)
		var by_gap: bool = false
		for gap: Vector2 in gaps:
			if gap.distance_to(Vector2(pos.x, pos.z)) < BoundaryKit.PASSAGE_CLEAR + 0.6:
				by_gap = true
		if by_gap:
			continue
		match kind:
			"passage":
				continue
			"gorge":
				if not _land.in_gorge(pos + out * 1.0, 0.2):
					bare.append("%s gorge %s" % [kind, str(pos)])
			"water":
				# the lake itself is the blocker: its water line is a few metres out, past the reeds and the bank
				var wet: bool = TownBounds.in_lake(pos + out * 2.5) or TownBounds.in_lake(pos + out * 4.0) or _land._lake_edge_distance(pos) < 3.5
				if not wet:
					bare.append("%s %s" % [kind, str(pos)])
			_:
				if not _near_blocker(pos + out * 1.0, 2.6):
					bare.append("%s %s" % [kind, str(pos)])
	assert_eq(bare, [] as Array[String], "every edge is a woods, thorns, a ridge, a wall, a fence, a hedge, water or the gorge")


func test_no_blocker_stands_on_walkable_ground() -> void:
	var inside: Array[String] = []
	for blocker: Vector3 in _land.boundary.blockers:
		if TownBounds.contains(blocker) and float(TownBounds.nearest_edge(blocker)["distance"]) > 0.3:
			inside.append(str(blocker))
	assert_eq(inside, [] as Array[String], "the boundary pieces stand outside the line")


func test_nothing_beyond_the_edge_can_be_reached() -> void:
	var spawn: Vector3 = _town.anchors["spawn"] as Vector3
	var can: Callable = func(p: Vector3) -> bool: return _town.is_walkable(p, 0.3)
	var reached: Dictionary = WalkProbe.flood(can, spawn, TownBounds.rect().grow(10.0), 0.6)
	var outside: int = 0
	for cell: Variant in reached.keys():
		var p: Vector3 = Vector3((cell as Vector2i).x * 0.6, 0.0, (cell as Vector2i).y * 0.6)
		if not TownBounds.contains(p) and absf(float(TownBounds.nearest_edge(p)["distance"])) > 0.4:
			outside += 1
	assert_eq(outside, 0, "the flood fill stays inside the outline")
	# and the open-looking country inside it is really open: the far corners of the fields and the lakeshore are reached
	for target: Vector3 in [Vector3(-18.0, 0, -18.0), Vector3(68.0, 0, -18.0), Vector3(54.0, 0, 30.0), Vector3(50.0, 0, 66.0), Vector3(0.0, 0, 68.0), Vector3(-18.0, 0, 42.0)]:
		assert_lt(WalkProbe.gap(reached, target, 3.0, 0.6), 1.5, "the hero can get to %s" % str(target))


func test_a_full_loop_round_the_town() -> void:
	var loop: PackedVector2Array = TownBounds.LOOP
	for index: int in range(loop.size()):
		var a: Vector2 = loop[index]
		var b: Vector2 = loop[(index + 1) % loop.size()]
		var steps: int = maxi(1, int(ceil(a.distance_to(b) / 0.5)))
		for i: int in range(steps):
			var p: Vector2 = a.lerp(b, float(i) / float(steps))
			assert_true(_town.is_walkable(Vector3(p.x, 0.0, p.y), 0.45), "the loop is open at %s" % str(p))
	# it goes round the outside of every building
	var rows: Array[TownLayout.Shop] = TownLayout.shops()
	rows.append_array(TownExpansion.shops())
	for shop: TownLayout.Shop in rows:
		assert_true(Geometry2D.is_point_in_polygon(Vector2(shop.center.x, shop.center.z), loop), "%s lies inside the loop" % shop.label)
	assert_true(Geometry2D.is_point_in_polygon(Vector2(TownLayout.ARENA_CENTER.x, TownLayout.ARENA_CENTER.z), loop), "the Undercroft cottage too")
	# no hidden chest lies on the lane (they are found off the beaten path)
	for key: String in _town.anchors.keys():
		if key.begins_with("hidden_chest_"):
			assert_gt(TownBounds.lane_distance(_town.anchors[key] as Vector3), TownBounds.LANE_WIDTH * 0.5 + 0.5, "%s is off the lane" % key)
	# and it never brushes a passage (walking it never takes the hero out of town)
	for zone_id: String in TownBuilder.PORTAL_CELLS.keys():
		var mouth: Vector3 = _town.anchors["portal_%s_mouth" % zone_id] as Vector3
		for p: Vector2 in loop:
			assert_gt(Vector2(p.x - mouth.x, p.y - mouth.z).length(), 3.0, "the loop keeps clear of the %s passage" % zone_id)


func test_each_zone_road_is_the_only_way_through_its_obstacle() -> void:
	var spawn: Vector3 = _town.anchors["spawn"] as Vector3
	for zone_id: String in Gatekeepers.IDS:
		var mouth: Vector3 = _town.anchors["portal_%s_mouth" % zone_id] as Vector3
		# locked: the scene keeps a solid circle in the passage mouth and the obstacle's own pieces; the hero cannot get to the trigger
		_town.obstacles.append(Vector3(mouth.x, mouth.z, 1.55))
		var can: Callable = func(p: Vector3) -> bool: return _town.is_walkable(p, 0.3)
		var reached: Dictionary = WalkProbe.flood(can, spawn, TownBounds.rect().grow(6.0), 0.4)
		assert_gt(WalkProbe.gap(reached, mouth, 3.0, 0.4), TownBuilder.PORTAL_TRIGGER, "%s: shut while its gatekeeper stands" % zone_id)
		_town.obstacles.pop_back()
	# the passage edges are the only gaps in the outline, one per zone road
	var gaps: int = 0
	for edge: Dictionary in TownBounds.edges():
		if str(edge["kind"]) == "passage":
			gaps += 1
	assert_eq(gaps, TownBuilder.PORTAL_CELLS.size())


func test_the_lake_has_natural_shores_and_no_water_patches() -> void:
	assert_true(_land.town_water.is_empty(), "no hex water cells drawn as discs")
	assert_not_null(_land.boundary.root.find_child("LakeBank", true, false), "a soft sandy bank")
	assert_not_null(_land.boundary.root.find_child("LakeShallows", true, false), "pale shallows")
	# the old ponds cut into the grass are gone: their cells are ground now
	for pond: Vector3 in [Vector3(-18.0, 0, 0.0), Vector3(-7.2, 0, 0.0), Vector3(-14.4, 0, 6.2), Vector3(21.6, 0, -6.2), Vector3(-18.0, 0, 31.2)]:
		assert_true(_town.is_floor_at(pond), "the pond at %s is grass now" % str(pond))
	assert_true(_town.is_walkable(Vector3(TownBounds.DOCK.get_center().x, 0.0, TownBounds.DOCK.get_center().y), 0.3), "the dock can be walked")
	assert_false(_town.is_floor_at(Vector3(75.0, 0.0, 40.0)), "the lake cannot")


func test_the_outskirts_dressing_keeps_the_lane_and_every_spot_clear() -> void:
	var dressing: OutskirtDressing = OutskirtDressing.build(_town.root, _town)
	gut.p("outskirt pieces refused: %s" % str(dressing.refused))
	assert_lte(dressing.refused.size(), 4, "most vignettes fit where they were planned")
	var loop: PackedVector2Array = TownBounds.LOOP
	for index: int in range(loop.size()):
		var a: Vector2 = loop[index]
		var b: Vector2 = loop[(index + 1) % loop.size()]
		var steps: int = maxi(1, int(ceil(a.distance_to(b) / 0.5)))
		for i: int in range(steps):
			var p: Vector2 = a.lerp(b, float(i) / float(steps))
			assert_true(_town.is_walkable(Vector3(p.x, 0.0, p.y), 0.45), "the loop is still open at %s" % str(p))
	var spawn: Vector3 = _town.anchors["spawn"] as Vector3
	var targets: Dictionary = {}
	for key: String in _town.anchors.keys():
		if key.begins_with("hidden_chest_") or key in ["lever", "dev_shrine", "graveyard_cairn", "chest"]:
			targets[key] = _town.anchors[key]
	var can: Callable = func(p: Vector3) -> bool: return _town.is_walkable(p, 0.3)
	assert_eq(WalkProbe.unreachable(can, spawn, _town.map_bounds(), targets), [] as Array[String], "every out-of-town spot still reached")


## Nov 3-4, Part A4: the giant chest opens from the front AND the back - both spots stand where the hero can walk.
func test_the_giant_chest_can_be_reached_from_both_sides() -> void:
	for key: String in ["chest", "chest_back"]:
		assert_true(_town.anchors.has(key), key)
		assert_true(_town.is_walkable(_town.anchors[key] as Vector3), "%s is walkable" % key)
	var front: Vector3 = _town.anchors["chest"] as Vector3
	var back: Vector3 = _town.anchors["chest_back"] as Vector3
	var centre: Vector3 = _town.anchors["chest_centre"] as Vector3
	assert_lt((front - centre).dot(back - centre), 0.0, "opposite sides of the chest")


## Nov 3-4, Part A6: no townsperson's route goes through (or brushes) a building - every stroller loop and the baker's plaza walk, sampled
## every 10 cm, keeps the NPC clearance from every building rectangle and stays on walkable ground; every loop still has a walk.
func test_townsfolk_routes_never_cross_a_building() -> void:
	var specs: Array[Dictionary] = []
	for spec: Dictionary in TownScene.STROLLERS:
		specs.append({"plaza": _town.anchors[str(spec["anchor"])], "radius": float(spec["radius"]), "seed": int(spec["seed"]), "name": str(spec["anchor"])})
	specs.append({"plaza": TownLayout.PLAZA, "radius": SpriteWanderer.RING_RADIUS, "seed": 11, "name": "baker"})
	for spec: Dictionary in specs:
		var wanderer: SpriteWanderer = SpriteWanderer.new()
		wanderer.seed_value = int(spec["seed"])
		wanderer.ring_radius = float(spec["radius"])
		wanderer.build_graph_only(_town, spec["plaza"] as Vector3)
		var links: Array[Array] = wanderer.links()
		assert_gte(links.size(), 3, "%s still has a loop to walk" % spec["name"])
		var bad: Array[String] = []
		for link: Array in links:
			var a: Vector3 = link[0] as Vector3
			var b: Vector3 = link[1] as Vector3
			var steps: int = maxi(2, ceili(a.distance_to(b) / 0.1))
			for i: int in range(steps + 1):
				var p: Vector3 = a.lerp(b, float(i) / float(steps))
				if TownBuilder.in_building(p, 0.6) or not _town.is_walkable(p, 0.3):
					bad.append("(%.1f, %.1f)" % [p.x, p.z])
					break
		assert_eq(bad.size(), 0, "%s route clips at %s" % [spec["name"], ", ".join(bad)])
		wanderer.free()


func test_town_roamers_stay_out_of_buildings() -> void:
	var map: TownEnemyMap = TownEnemyMap.wrap(_town)
	for shop: TownLayout.Shop in TownLayout.shops() + TownExpansion.shops():
		if shop.kind != "kit":
			continue
		assert_false(map.is_enemy_walkable(shop.center), "a roamer cannot stand inside %s" % shop.label)


## Nov 3-4, Part B10: the standing townsfolk come from the non-story pool, never the Capital's citizen, and stand clear of every building.
func test_townsfolk_pool_and_standing_spots() -> void:
	assert_does_not_have(TownScene.TOWNSFOLK_POOL, "CITIZEN", "Primm's citizen walks only the Capital")
	var looks: Dictionary = {}
	for spec: Dictionary in TownScene.STANDING_TOWNSFOLK:
		assert_has(TownScene.TOWNSFOLK_POOL, str(spec["character"]))
		assert_ne(str(spec["character"]), "GYM_ATTENDANT", "Fix pass Nov 4: no gym kit in the town square")
		looks["%s %s" % [spec["character"], str(spec["tint"])]] = true
		var pos: Vector3 = (_town.anchors[str(spec["anchor"])] as Vector3) + (spec["offset"] as Vector3)
		assert_true(_town.npc_can_stand(pos), "%s by %s stands clear" % [spec["character"], spec["anchor"]])
	assert_eq(looks.size(), TownScene.STANDING_TOWNSFOLK.size(), "every standing townsperson has a look of their own (set and tint)")
