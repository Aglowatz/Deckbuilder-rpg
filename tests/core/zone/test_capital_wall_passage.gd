extends GutTest
## The Capital pass, Part D: the hidden way into the city. The front wall has no way through but the gate (the old 2 m gap at x 22 is closed); a
## narrow strip of outside ground runs north along the city's west wall from the rift fields' corner, and a small hole low in that wall comes out
## behind the Reek's west yards. No sign, no marker, no map icon, no prompt: you find it by walking the edge.

var layout: CapitalLayout


func before_all() -> void:
	layout = CapitalLayout.new()
	layout.build()


func _builder(gate_open: bool = false) -> CapitalBuilder:
	var capital: CapitalBuilder = CapitalBuilder.new()
	capital.layout = layout
	capital._index_obstacles()
	capital.gate_open = gate_open
	return capital


func _strip_column(x: int) -> bool:
	return x >= CapitalLayout.STRIP_X0 and x <= CapitalLayout.STRIP_X1


func test_the_front_wall_has_no_way_through_but_the_gate() -> void:
	for z: int in range(CapitalLayout.WALL_Z0, CapitalLayout.WALL_Z1 + 1):
		for x: int in range(CapitalLayout.GRID_X0, CapitalLayout.GRID_X0 + CapitalLayout.W):
			if (x >= CapitalLayout.GATE_X0 and x <= CapitalLayout.GATE_X1) or _strip_column(x):
				continue  # the gate's opening; the strip runs past the wall's west end, outside the city
			assert_ne(layout.cell_at(x, z), CapitalLayout.Cell.GROUND, "the front wall is solid at (%d, %d)" % [x, z])
	var capital: CapitalBuilder = _builder(false)
	for x: float in range(2, 118):
		assert_false(capital.is_walkable(Vector3(x + 0.5, 0.0, float(CapitalLayout.WALL_Z0) + 1.5), 0.3), "no way through the wall at x %.1f" % (x + 0.5))
	for kind: String in ["wall_crack", "loose_stones", "scrub"]:
		for prop: CapitalLayout.Prop in layout.props:
			assert_ne(prop.kind, kind, "the old gap's hints are gone")
	assert_true(CapitalLayout.WALL_TOWERS.has(23.0), "a tower stands where the old gap was")


func test_the_west_wall_wraps_the_city_with_one_small_low_hole() -> void:
	var hole_rows: Array[int] = []
	for z: int in range(CapitalLayout.HOLE_Z0, CapitalLayout.HOLE_Z0 + CapitalLayout.HOLE_W):
		hole_rows.append(z)
	for z: int in range(2, CapitalLayout.WALL_Z0):
		for x: int in [-1, 0, 1]:
			if z in hole_rows:
				assert_eq(layout.cell_at(x, z), CapitalLayout.Cell.GROUND, "the hole runs through the wall at (%d, %d)" % [x, z])
			else:
				assert_ne(layout.cell_at(x, z), CapitalLayout.Cell.GROUND, "the west wall is solid at (%d, %d)" % [x, z])
	assert_lte(CapitalLayout.HOLE_W, 2, "small: no wider than the hero needs")
	assert_lte(CapitalLayout.HOLE_HEIGHT, 2.2, "low: a little over the hero's height in a 9 m wall")
	assert_true(CapitalLayout.is_inside(2.5, 58.0), "it comes out inside the city")
	assert_eq(layout.area_at(2.5, 58.0).id, "reek", "behind the Reek's yards")
	assert_false(CapitalLayout.is_inside(-3.5, 58.0), "the strip is outside")


func test_the_west_route_is_walkable_end_to_end_with_the_gate_shut() -> void:
	var capital: CapitalBuilder = _builder(false)
	var can: Callable = func(pos: Vector3) -> bool: return capital.is_walkable(pos, 0.3)
	var hole_z: float = float(CapitalLayout.HOLE_Z0) + float(CapitalLayout.HOLE_W) * 0.5
	var route: Dictionary = {
		"the rift fields' corner": Vector3(3.5, 0.0, 78.5), "the strip's mouth": Vector3(-1.0, 0.0, 78.0), "along the strip": Vector3(-3.5, 0.0, 70.0),
		"the strip by the hole": Vector3(-3.5, 0.0, hole_z), "in the hole": Vector3(0.0, 0.0, hole_z), "behind the Reek's yards": Vector3(4.0, 0.0, hole_z),
		"the Gate Plaza": capital.anchor("gate_inside"), "the passage anchor": capital.anchor("wall_passage"),
	}
	assert_eq(WalkProbe.unreachable(can, capital.anchor("spawn"), capital.map_bounds(), route), [] as Array[String], "from the road, round the wall's west end, up the strip and through the hole")
	assert_false(capital.is_walkable(Vector3(60.0, 0.0, float(CapitalLayout.WALL_Z0) + 1.0), 0.3), "the gate itself stays shut")


func test_the_strip_is_narrow_and_unremarkable() -> void:
	assert_lte(CapitalLayout.STRIP_X1 - CapitalLayout.STRIP_X0 + 1, 4, "a narrow strip between the wall and the dead hills")
	for z: int in range(CapitalLayout.STRIP_Z0, CapitalLayout.WALL_Z0):
		assert_eq(layout.area_at(-3.5, float(z) + 0.5).id, "rifts", "walking it shows no new place name")
		assert_ne(layout.cell_at(CapitalLayout.STRIP_X0 - 1, z), CapitalLayout.Cell.GROUND, "the dead hills bound it on the west")
	assert_ne(layout.cell_at(-4, CapitalLayout.STRIP_Z0 - 1), CapitalLayout.Cell.GROUND, "it ends in rubble north of the hole")


func test_no_sign_spot_or_marker_gives_the_hole_away() -> void:
	var hole: Vector2 = Vector2(0.0, float(CapitalLayout.HOLE_Z0) + 1.0)
	for sign_data: CapitalLayout.Sign in layout.signs:
		assert_gt(Vector2(sign_data.pos.x, sign_data.pos.z).distance_to(hole), 10.0, "no sign near the hole: %s" % sign_data.key)
	var def: ZoneDef = ZoneDefs.get_def(CapitalZone.ID)
	for entry: Dictionary in def.spots:
		var anchor_name: String = str(entry["anchor"])
		if not layout.anchors.has(anchor_name):
			continue
		var pos: Vector3 = (layout.anchors[anchor_name] as Vector3) + (entry["offset"] as Vector3)
		assert_gt(Vector2(pos.x, pos.z).distance_to(hole), 6.0, "no prompt near the hole: %s" % str(entry["id"]))
	for prop: CapitalLayout.Prop in layout.props:
		if prop.pos.z < float(CapitalLayout.WALL_Z0) and prop.pos.x < 0.0:
			assert_eq(prop.radius, 0.0, "nothing solid in the strip: %s" % prop.kind)
