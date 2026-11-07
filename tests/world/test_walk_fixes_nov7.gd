extends GutTest
## Fix pass Nov 7, Part 2 (critic item 2): the hero slides along what it meets instead of stopping dead, and the route planner the reach
## walk smoke uses finds a way round obstacles (and none through a closed wall).


## A round post of radius 1 at the origin (body included), on open ground.
func _post(at: Vector3) -> bool:
	return Vector2(at.x, at.z).length() >= 1.0


func test_walking_straight_into_a_round_post_slides_round_it() -> void:
	var from: Vector3 = Vector3(0.0, 0.0, 1.05)
	var step: Vector3 = Vector3(0.0, 0.0, -0.1)
	var moved: Vector3 = TownPlayer.slide_step(from, step, _post)
	assert_gt(moved.length(), 0.02, "the hero keeps moving (was stopped dead by the axis-only slide)")
	assert_true(_post(from + moved), "and stays out of the post")


func test_a_free_step_is_taken_whole() -> void:
	var step: Vector3 = Vector3(0.1, 0.0, 0.0)
	assert_eq(TownPlayer.slide_step(Vector3(5.0, 0.0, 5.0), step, _post), step)


func test_a_wall_at_an_angle_is_slid_along() -> void:
	# a wall along the line x = z (walkable where x > z); walking straight +z into it slides along it
	var wall: Callable = func(at: Vector3) -> bool: return at.x - at.z > 0.0
	var moved: Vector3 = TownPlayer.slide_step(Vector3(1.0, 0.0, 0.95), Vector3(0.0, 0.0, 0.1), wall)
	assert_gt(moved.length(), 0.02)
	assert_gt(moved.x, 0.0, "along the wall")


func test_a_hero_inside_an_obstacle_can_walk_out() -> void:
	var moved: Vector3 = TownPlayer.slide_step(Vector3(0.2, 0.0, 0.0), Vector3(0.1, 0.0, 0.0), _post)
	assert_eq(moved, Vector3(0.1, 0.0, 0.0))


func test_the_planner_goes_round_a_wall_with_a_gap() -> void:
	# a wall at z = 0 from x = -10 to x = 8, gap at x > 8
	var walkable: Callable = func(at: Vector3) -> bool: return not (absf(at.z) < 0.6 and at.x < 8.0)
	var route: PackedVector3Array = WalkPlanner.route(walkable, Rect2(-12.0, -12.0, 24.0, 24.0), Vector3(0.0, 0.0, -5.0), Vector3(0.0, 0.0, 5.0))
	assert_false(route.is_empty(), "a way round exists")
	assert_gt(WalkPlanner.length(route), 16.0, "round the end of the wall")
	for point: Vector3 in route:
		assert_true(walkable.call(point), "every corner is walkable")


func test_the_planner_finds_nothing_through_a_closed_wall() -> void:
	var walkable: Callable = func(at: Vector3) -> bool: return absf(at.z) >= 0.6
	var route: PackedVector3Array = WalkPlanner.route(walkable, Rect2(-12.0, -12.0, 24.0, 24.0), Vector3(0.0, 0.0, -5.0), Vector3(0.0, 0.0, 5.0))
	assert_true(route.is_empty())
