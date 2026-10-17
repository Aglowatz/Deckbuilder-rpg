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
