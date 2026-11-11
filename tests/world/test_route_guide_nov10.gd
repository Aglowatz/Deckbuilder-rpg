extends GutTest
## Fable pass Nov 10 (Part 1.6, the wayfinding critic): the goal arrows follow a walkable route. `RouteGuide` plans over any walkability
## test, a slice per frame, and aims LOOK_AHEAD metres along the route: round a wall, through a gap, to a shut gate when the gates are
## the only way, and straight at the target while nothing is known.

const SIZE: float = 40.0
## A wall along x = 20 from z 0 to z 30 (open from z 30 up); a "gate" in it between z 4 and z 6.
const WALL_X: float = 20.0
const WALL_END_Z: float = 30.0
var _clock: float = 100.0


func _solid_wall(at: Vector3) -> bool:
	return not (absf(at.x - WALL_X) < 0.6 and at.z < WALL_END_Z)


func _wall_with_gate(at: Vector3) -> bool:
	if absf(at.x - WALL_X) < 0.6 and at.z < WALL_END_Z:
		return at.z > 4.0 and at.z < 6.0
	return true


func _in_bounds(at: Vector3) -> bool:
	return at.x >= 0.0 and at.z >= 0.0 and at.x <= SIZE and at.z <= SIZE


func _guide(strict: Callable, gates: Callable = Callable()) -> RouteGuide:
	var guide: RouteGuide = RouteGuide.new()
	guide.setup(strict, gates, Rect2(0, 0, SIZE, SIZE))
	guide.clock = func() -> float: return _clock
	return guide


func _plan(guide: RouteGuide, from: Vector3, target: Vector3) -> Vector3:
	var aim: Vector3 = guide.aim(from, target)
	var frames: int = 0
	while guide.planning() and frames < 4000:
		guide.work()
		frames += 1
	assert_false(guide.planning(), "the plan finishes in a bounded number of slices (%d)" % frames)
	return aim


func test_nothing_known_aims_straight_at_the_target() -> void:
	var guide: RouteGuide = _guide(func(at: Vector3) -> bool: return _in_bounds(at) and _solid_wall(at))
	var from: Vector3 = Vector3(5, 0, 5)
	var target: Vector3 = Vector3(35, 0, 5)
	assert_eq(guide.aim(from, target), target, "before the first slice the arrow points straight")
	assert_true(guide.planning())


func test_the_arrow_turns_toward_the_gap_not_through_the_wall() -> void:
	var guide: RouteGuide = _guide(func(at: Vector3) -> bool: return _in_bounds(at) and _solid_wall(at))
	var from: Vector3 = Vector3(5, 0, 5)
	var target: Vector3 = Vector3(35, 0, 5)
	_plan(guide, from, target)
	var route: PackedVector3Array = guide.route()
	assert_gt(route.size(), 2, "a route with corners")
	var crosses_at: float = -1.0
	for index: int in range(1, route.size()):
		if (route[index - 1].x < WALL_X) != (route[index].x < WALL_X):
			crosses_at = route[index].z
	assert_gte(crosses_at, WALL_END_Z - 1.0, "the route crosses x 20 beyond the wall's end (at z %.1f)" % crosses_at)
	assert_false(guide.gated(), "no gate on the way")
	var aim: Vector3 = guide.aim(from, target)
	assert_ne(aim, target, "the arrow points along the route")
	assert_gt(aim.z, from.z + 4.0, "...which starts by heading up toward the gap (aim z %.1f)" % aim.z)
	assert_almost_eq(Vector2(aim.x - from.x, aim.z - from.z).length(), RouteGuide.LOOK_AHEAD, 0.6, "LOOK_AHEAD metres along it")
	# near the end the arrow points at the target itself
	var late: Vector3 = guide.aim(Vector3(31, 0, 7), target)
	assert_eq(late, target, "within LOOK_AHEAD of the end the target itself is the aim")


func test_a_shut_gate_is_on_the_route_when_the_gates_are_the_only_way() -> void:
	var strict: Callable = func(at: Vector3) -> bool: return _in_bounds(at) and _solid_wall(at) and at.z < 28.0  # the gap is out of bounds now
	var gates: Callable = func(at: Vector3) -> bool: return _in_bounds(at) and _wall_with_gate(at) and at.z < 28.0
	var guide: RouteGuide = _guide(strict, gates)
	var from: Vector3 = Vector3(5, 0, 20)
	var target: Vector3 = Vector3(35, 0, 20)
	_plan(guide, from, target)
	assert_false(guide.route().is_empty(), "a route through the gate")
	assert_true(guide.gated(), "...and it says so")
	var crosses_at: float = -1.0
	var route: PackedVector3Array = guide.route()
	for index: int in range(1, route.size()):
		if (route[index - 1].x < WALL_X) != (route[index].x < WALL_X):
			crosses_at = route[index].z
	assert_between(crosses_at, 3.0, 7.0, "it crosses the wall at the gate (z %.1f)" % crosses_at)


func test_no_route_at_all_falls_back_to_the_straight_arrow_and_retries_later() -> void:
	var strict: Callable = func(at: Vector3) -> bool: return _in_bounds(at) and _solid_wall(at) and at.z < 28.0
	var guide: RouteGuide = _guide(strict)
	var from: Vector3 = Vector3(5, 0, 20)
	var target: Vector3 = Vector3(35, 0, 20)
	var aim: Vector3 = _plan(guide, from, target)
	assert_eq(aim, target)
	assert_true(guide.route().is_empty(), "nothing found")
	assert_eq(guide.aim(from, target), target, "still straight")
	assert_false(guide.planning(), "and not planning again at once")
	_clock += RouteGuide.RETRY_SECONDS + 1.0
	guide.aim(from, target)
	assert_true(guide.planning(), "tried again after RETRY_SECONDS (a gate may have opened)")


func test_a_moved_target_is_planned_afresh() -> void:
	var guide: RouteGuide = _guide(func(at: Vector3) -> bool: return _in_bounds(at) and _solid_wall(at))
	_plan(guide, Vector3(5, 0, 5), Vector3(35, 0, 5))
	var first: PackedVector3Array = guide.route()
	guide.aim(Vector3(5, 0, 5), Vector3(35, 0, 5.5))
	assert_false(guide.planning(), "half a metre is the same target")
	assert_eq(guide.route(), first)
	guide.aim(Vector3(5, 0, 5), Vector3(10, 0, 35))
	assert_true(guide.planning(), "a target 30 m away is a new plan")
	assert_true(guide.route().is_empty())
