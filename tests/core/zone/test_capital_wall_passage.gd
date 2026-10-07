extends GutTest
## Brief 16, Group C: the hidden gap in the left-hand city wall lets the hero into the city without opening the Approved Gate.


func _builder() -> CapitalBuilder:
	var capital: CapitalBuilder = CapitalBuilder.new()
	capital.layout.build()
	capital._index_obstacles()
	capital.gate_open = false
	return capital


func test_the_gap_is_on_the_left_hand_side_and_two_metres_wide() -> void:
	var layout: CapitalLayout = CapitalLayout.new()
	layout.build()
	assert_lt(CapitalLayout.PASSAGE_X0 + CapitalLayout.PASSAGE_W, CapitalLayout.GATE_X0, "left of the gate")
	assert_lt(CapitalLayout.PASSAGE_X0, 30, "far along the left-hand wall")
	for z: int in range(CapitalLayout.WALL_Z0, CapitalLayout.WALL_Z1 + 1):
		for x: int in range(CapitalLayout.PASSAGE_X0, CapitalLayout.PASSAGE_X0 + CapitalLayout.PASSAGE_W):
			assert_eq(layout.cell_at(x, z), CapitalLayout.Cell.GROUND, "passage cell %d,%d" % [x, z])
		assert_ne(layout.cell_at(CapitalLayout.PASSAGE_X0 - 1, z), CapitalLayout.Cell.GROUND, "wall left of the gap")
		assert_ne(layout.cell_at(CapitalLayout.PASSAGE_X0 + CapitalLayout.PASSAGE_W, z), CapitalLayout.Cell.GROUND, "wall right of the gap")


func test_the_hero_can_walk_from_the_spawn_into_the_city_with_the_gate_closed() -> void:
	var capital: CapitalBuilder = _builder()
	var spawn: Vector3 = capital.anchor("spawn")
	var inside: Vector3 = Vector3(23.0, 0.0, 55.0)
	var can: Callable = func(pos: Vector3) -> bool: return capital.is_walkable(pos, 0.3)
	assert_eq(WalkProbe.unreachable(can, spawn, capital.map_bounds(), {"inside": inside}), [] as Array[String], "through the gap past the closed gate")
	var gate_inside: Vector3 = capital.anchor("gate_inside")
	assert_false(capital.is_walkable(Vector3(60.0, 0.0, 61.0), 0.3), "the gate itself stays shut")
	assert_eq(WalkProbe.unreachable(can, spawn, capital.map_bounds(), {"plaza": gate_inside}), [] as Array[String], "the plaza is reachable through the passage too")


func test_no_sign_or_marker_names_the_passage() -> void:
	var layout: CapitalLayout = CapitalLayout.new()
	layout.build()
	for sign: CapitalLayout.Sign in layout.signs:
		assert_false(absf(sign.pos.x - 23.0) < 4.0 and sign.pos.z > 58.0 and sign.pos.z < 68.0, "no sign by the gap: %s" % sign.key)
	var hints: int = 0
	for prop: CapitalLayout.Prop in layout.props:
		if prop.kind in ["wall_crack", "loose_stones", "scrub"]:
			hints += 1
	assert_gte(hints, 5, "a crack, loose stones and scrub hide it")
