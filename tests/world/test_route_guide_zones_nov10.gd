extends GutTest
## Fable pass Nov 10 (Part 1.6): the goal arrows' routes over the real zones, planned the way the scenes plan them (`ZoneScene._route_walkable`
## / `_route_through_gates`): the Gainlands' arrival to the House of Gains is a strict route up the middle road; the Buffet's arrival to
## the Test Kitchen crosses the Gravy River only on a ferry's line; the Dump's arrival to the Rotheart has no strict route while no bridge
## is grown, and a gated one over a vine bridge's line.


func _plan(guide: RouteGuide, from: Vector3, to: Vector3) -> PackedVector3Array:
	var started: int = Time.get_ticks_usec()
	guide.aim(from, to)
	var slices: int = 0
	while guide.planning() and slices < 40000:
		guide.work()
		slices += 1
	assert_false(guide.planning(), "the plan finishes (%d slices)" % slices)
	gut.p("planned in %d slices, %.0f ms of search" % [slices, float(Time.get_ticks_usec() - started) / 1000.0])
	return guide.route()


func _crossings(route: PackedVector3Array, x: float) -> Array[float]:
	var result: Array[float] = []
	for index: int in range(1, route.size()):
		if (route[index - 1].x < x) != (route[index].x < x):
			result.append(route[index].z)
	return result


func test_the_gainlands_route_climbs_the_middle_road() -> void:
	var builder: GainlandsBuilder = GainlandsBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	var guide: RouteGuide = RouteGuide.new()
	guide.setup(func(at: Vector3) -> bool: return builder.is_walkable(at, ZoneScene.ROUTE_BODY), Callable(), builder.map_bounds())
	var from: Vector3 = builder.anchor("spawn")
	var door: Vector3 = Vector3(GainlandsLayout.HOUSE_OF_GAINS.x, 0.0, 6.0)
	var route: PackedVector3Array = _plan(guide, from, door)
	assert_false(route.is_empty(), "a strict route from the bridge to the House of Gains' steps")
	assert_false(guide.gated())
	var through_the_narrows: bool = false
	for point: Vector3 in route:
		if absf(point.x - 56.0) < 3.0 and point.z > 25.0 and point.z < 50.0:
			through_the_narrows = true
	assert_true(through_the_narrows, "the route runs up the middle road through the narrows (%d corners)" % route.size())
	# the critic's "dead end" at (49, 55): the aim from there heads east toward the road's foot, not north into the plateau wall
	var aim: Vector3 = guide.aim(Vector3(49.0, 4.0, 55.0), door)
	var slices: int = 0
	while guide.planning() and slices < 40000:
		guide.work()
		slices += 1
	aim = guide.aim(Vector3(49.0, 4.0, 55.0), door)
	assert_gt(aim.x, 51.0, "from the critic's dead end the arrow points east to the road (aim %s)" % str(aim.snapped(Vector3(0.1, 0.1, 0.1))))


func test_the_buffet_route_crosses_the_gravy_on_a_ferry() -> void:
	var builder: BuffetBuilder = BuffetBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	var strict: Callable = func(at: Vector3) -> bool:
		if builder.layout.surface_at(at.x, at.z) == BuffetLayout.Surface.SOUP:
			return builder.layout.on_ferry_line(at.x, at.z)
		return builder.is_walkable(at, ZoneScene.ROUTE_BODY)
	var gates: Callable = func(at: Vector3) -> bool:
		if builder.layout.surface_at(at.x, at.z) == BuffetLayout.Surface.SOUP:
			return builder.layout.on_ferry_line(at.x, at.z)
		return builder.is_walkable_through_gates(at, ZoneScene.ROUTE_BODY)
	var guide: RouteGuide = RouteGuide.new()
	guide.setup(strict, gates, builder.map_bounds())
	var from: Vector3 = builder.anchor("spawn")
	var door: Vector3 = builder.anchor("main_dungeon") if builder.has_anchor("main_dungeon") else Vector3(BuffetLayout.TEST_KITCHEN.x, 0.0, BuffetLayout.TEST_KITCHEN.y + 4.0)
	var route: PackedVector3Array = _plan(guide, from, door)
	assert_false(route.is_empty(), "a route from the arrival to the Test Kitchen's door")
	var in_soup: int = 0
	var on_ferry: int = 0
	for index: int in range(1, route.size()):
		var steps: int = maxi(1, int(route[index - 1].distance_to(route[index]) / 0.5))
		for step: int in range(steps + 1):
			var at: Vector3 = route[index - 1].lerp(route[index], float(step) / float(steps))
			if builder.layout.surface_at(at.x, at.z) == BuffetLayout.Surface.SOUP:
				in_soup += 1
				if builder.layout.on_ferry_line(at.x, at.z):
					on_ferry += 1
	assert_gt(in_soup, 0, "the river is crossed")
	assert_eq(in_soup, on_ferry, "...only on a ferry's line (%d soup points, %d on a ferry)" % [in_soup, on_ferry])
	gut.p("Buffet: %d corners, gated %s, soup points %d" % [route.size(), str(guide.gated()), in_soup])


func test_the_dump_route_waits_at_a_bridge_until_one_is_grown() -> void:
	var builder: HeapBuilder = HeapBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	var strict: Callable = func(at: Vector3) -> bool:
		if builder.layout.surface_at(at.x, at.z) == HeapLayout.Surface.HAZARD and not builder.on_grown_bridge(at):
			return false
		return builder.is_walkable(at, ZoneScene.ROUTE_BODY)
	var gates: Callable = func(at: Vector3) -> bool:
		if builder.layout.surface_at(at.x, at.z) == HeapLayout.Surface.HAZARD:
			return builder.on_grown_bridge(at) or builder.layout.bridge_at(at.x, at.z) != null
		return builder.is_walkable_through_barricades(at, ZoneScene.ROUTE_BODY)
	# the centre bridge's line, bank to bank: what the route test says at each half metre (prints when something blocks)
	var blocked: Array[String] = []
	var z: float = 104.0
	while z >= 88.0:
		var at: Vector3 = Vector3(46.0, 0.0, z)
		if not bool(gates.call(at)):
			blocked.append("(46, %.1f) surface=%s depth=%.2f bridge=%s obstacle=%s" % [z, HeapLayout.Surface.keys()[builder.layout.surface_at(at.x, at.z)], builder.layout.hazard_depth(at.x, at.z), str(builder.layout.bridge_at(at.x, at.z) != null), str(builder._hits_obstacle(at, 0.3))])
		z -= 0.5
	assert_eq(blocked, [] as Array[String], "the centre bridge's line is open to the gated route from bank to bank")
	var guide: RouteGuide = RouteGuide.new()
	guide.setup(strict, gates, builder.map_bounds())
	var from: Vector3 = builder.anchor("hub")
	var door: Vector3 = builder.anchor("main_dungeon")
	var route: PackedVector3Array = _plan(guide, from, door)
	assert_false(route.is_empty(), "a gated route from the Commons to the Rotheart")
	assert_true(guide.gated(), "...which says it passes a gate (an ungrown bridge, a barricade)")
	var crossing: float = -1.0
	for point: Vector3 in route:
		if builder.layout.surface_at(point.x, point.z) == HeapLayout.Surface.HAZARD or absf(point.z - HeapLayout.stream_z(point.x)) < 3.0:
			crossing = point.x
	gut.p("Dump: %d corners, crosses the stream near x %.1f" % [route.size(), crossing])
	# once the centre bridge is grown the strict route exists too
	builder.set_bridge_progress("bridge_center", 1.0)
	var grown: RouteGuide = RouteGuide.new()
	grown.setup(strict, Callable(), builder.map_bounds())
	var open_route: PackedVector3Array = _plan(grown, from, Vector3(46.0, 0.0, 85.0))
	assert_false(open_route.is_empty(), "with the centre bridge grown the far bank is reached strictly")
	assert_false(grown.gated())
