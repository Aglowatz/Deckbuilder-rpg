extends GutTest
## Overnight Nov 10-11 (Part 2.1, inbox 11): the Dump's arrows plan on a 1 m grid with 12 ms a frame (`HeapScene.ROUTE_GRID` /
## `ROUTE_BUDGET_USEC`): the gated route from the Commons to the Rotheart is still found (it still crosses the stream on a vine bridge's
## line), the strict route exists once the centre bridge is grown, and the whole plan - the failing strict search plus the gated one - takes
## well under a second of search, so at 12 ms a frame the arrow follows the route within about a second of a pick.


func _plan(guide: RouteGuide, from: Vector3, to: Vector3) -> Dictionary:
	var started: int = Time.get_ticks_usec()
	guide.aim(from, to)
	var slices: int = 0
	while guide.planning() and slices < 40000:
		guide.work()
		slices += 1
	assert_false(guide.planning(), "the plan finishes (%d slices)" % slices)
	return {"route": guide.route(), "slices": slices, "msec": float(Time.get_ticks_usec() - started) / 1000.0}


func test_the_dumps_coarse_grid_finds_the_gated_route_within_a_second() -> void:
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
	var guide: RouteGuide = RouteGuide.new()
	guide.setup(strict, gates, builder.map_bounds(), HeapScene.ROUTE_GRID, HeapScene.ROUTE_BUDGET_USEC)
	assert_eq(guide.step, 1.0)
	assert_eq(guide.budget_usec, 12000)
	var from: Vector3 = builder.anchor("hub")
	var door: Vector3 = builder.anchor("main_dungeon")
	var plan: Dictionary = _plan(guide, from, door)
	var route: PackedVector3Array = plan["route"] as PackedVector3Array
	assert_false(route.is_empty(), "a gated route from the Commons to the Rotheart on the 1 m grid")
	assert_true(guide.gated(), "...through a gate (an ungrown bridge, a barricade)")
	var on_bridge: bool = false
	for index: int in range(1, route.size()):
		var steps: int = maxi(1, int(route[index - 1].distance_to(route[index]) / 0.5))
		for step: int in range(steps + 1):
			var at: Vector3 = route[index - 1].lerp(route[index], float(step) / float(steps))
			if builder.layout.surface_at(at.x, at.z) == HeapLayout.Surface.HAZARD and builder.layout.bridge_at(at.x, at.z) != null:
				on_bridge = true
	assert_true(on_bridge, "the route crosses the stream on a vine bridge's line (%d corners)" % route.size())
	gut.p("Dump, 1 m grid: %d corners, %d slices of 12 ms, %.0f ms of search" % [route.size(), int(plan["slices"]), float(plan["msec"])])
	assert_lt(float(plan["msec"]), 1000.0, "the strict (failing) and the gated search together take under a second of search")
	assert_lte(int(plan["slices"]), 90, "...so at 12 ms a frame the arrow follows the route within about 1.5 s (90 frames at 60 fps)")
	# the fine grid, for the record
	var fine: RouteGuide = RouteGuide.new()
	fine.setup(strict, gates, builder.map_bounds())
	var fine_plan: Dictionary = _plan(fine, from, door)
	gut.p("Dump, 0.75 m grid: %d corners, %d slices of 5 ms, %.0f ms of search" % [(fine_plan["route"] as PackedVector3Array).size(), int(fine_plan["slices"]), float(fine_plan["msec"])])
	# with the centre bridge grown the strict route exists too
	builder.set_bridge_progress("bridge_center", 1.0)
	var grown: RouteGuide = RouteGuide.new()
	grown.setup(strict, Callable(), builder.map_bounds(), HeapScene.ROUTE_GRID, HeapScene.ROUTE_BUDGET_USEC)
	var open_plan: Dictionary = _plan(grown, from, Vector3(46.0, 0.0, 85.0))
	assert_false((open_plan["route"] as PackedVector3Array).is_empty(), "with the centre bridge grown the far bank is reached strictly on the 1 m grid")
	assert_false(grown.gated())


func test_other_zones_keep_the_fine_grid() -> void:
	var guide: RouteGuide = RouteGuide.new()
	guide.setup(func(_at: Vector3) -> bool: return true, Callable(), Rect2(0, 0, 10, 10))
	assert_eq(guide.step, RouteGuide.STEP)
	assert_eq(guide.budget_usec, RouteGuide.BUDGET_USEC)
