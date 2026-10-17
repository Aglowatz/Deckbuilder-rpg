extends GutTest
## The Capital pass, Part E: boundaries. Everywhere the hero cannot walk there is a blocker you can see (the great wall, the city's walls and
## towers, the castle hill's terraces, a building, a prop, or the rim's rising ground), no invisible wall in open-looking space; nothing outside
## the intended ground is reachable; the road from Crosspath is the only way into the outside half.

## The ground the hero is meant to reach (x, z, w, d): the outside, the strip and its corner, the hole, the gate's opening, the city.
const INTENDED: Array[Rect2] = [
	Rect2(2.0, 76.0, 116.0, 46.0), Rect2(-5.0, 52.0, 3.0, 28.0), Rect2(-5.0, 76.0, 7.0, 4.0), Rect2(-2.0, 57.0, 4.0, 2.0),
	Rect2(55.0, 72.0, 10.0, 4.0), Rect2(2.0, 2.0, 115.0, 70.0),
]

var layout: CapitalLayout
var capital: CapitalBuilder
var rim: CapitalRim


func before_all() -> void:
	layout = CapitalLayout.new()
	layout.build()
	capital = CapitalBuilder.new()
	capital.layout = layout
	capital._index_obstacles()
	capital.gate_open = true
	var holder: Node3D = Node3D.new()
	rim = CapitalRim.build(holder, layout)
	holder.free()


func _intended(p: Vector2) -> bool:
	for rect: Rect2 in INTENDED:
		if rect.grow(0.05).has_point(p):
			return true
	return false


func test_nothing_outside_the_intended_ground_is_reachable() -> void:
	# a flood from the arrival over a 0.5 m lattice, the gate open: every point it reaches lies in the intended ground
	var seen: Dictionary = {}
	var start: Vector2i = Vector2i(int(roundf(capital.anchor("spawn").x * 2.0)), int(roundf(capital.anchor("spawn").z * 2.0)))
	var queue: Array[Vector2i] = [start]
	seen[start] = true
	var head: int = 0
	var strays: Array[String] = []
	while head < queue.size():
		var current: Vector2i = queue[head]
		head += 1
		var p: Vector2 = Vector2(float(current.x) * 0.5, float(current.y) * 0.5)
		if not _intended(p) and strays.size() < 8:
			strays.append(str(p))
		for step: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var next: Vector2i = current + step
			if seen.has(next):
				continue
			if capital.is_walkable(Vector3(float(next.x) * 0.5, 0.0, float(next.y) * 0.5), 0.3):
				seen[next] = true
				queue.append(next)
	assert_gt(seen.size(), 20000, "the flood covers the zone")
	assert_eq(strays, [] as Array[String], "every reachable point is meant to be reached")


func test_the_road_from_crosspath_is_the_only_way_into_the_outside() -> void:
	# the outside's south edge is the map's edge: the hero leaves only by the road's exit spot; the rim rises either side of the road beyond it
	for x: int in range(CapitalLayout.GRID_X0, CapitalLayout.GRID_X0 + CapitalLayout.W):
		assert_ne(layout.cell_at(x, CapitalLayout.OUT_Z1 + 1), CapitalLayout.Cell.GROUND, "nothing walkable beyond the south edge at x %d" % x)
	var exit: Vector3 = capital.anchor("exit")
	assert_lt(absf(exit.x - 60.0), 0.5, "the way home is on the road")
	assert_gt(exit.z, float(CapitalLayout.OUT_Z1) - 3.0, "at its end")
	for side: int in [52, 68]:
		assert_gt(rim.height_at(side, CapitalLayout.OUT_Z1 + 8), 1.0, "impassable land beside the road beyond the edge (x %d)" % side)


## A non-walkable cell next to walkable ground: what stops the hero there must be something you can see.
func _visible_blocker(cx: int, cz: int) -> String:
	var p: Vector2 = Vector2(float(cx) + 0.5, float(cz) + 0.5)
	for building: CapitalLayout.Building in layout.buildings:
		if building.rect.grow(0.9).has_point(p):
			return "building"
	# the city's walls and the corner towers (x -1.25..1.25 and 117.75..120.25 down to the great wall, the north wall at z -1..2, the hole's
	# lintel), the castle hill's terraces, the towers standing out from the great wall
	if p.y < 76.6 and (p.x < 2.1 or p.x > 116.9) and p.x > -2.0 and p.x < 121.6:
		return "city wall"
	if p.y < 2.1:
		return "north wall"
	if Rect2(CapitalLayout.HILL).grow(0.6).has_point(p):
		return "castle hill"
	for tower_x: float in CapitalLayout.WALL_TOWERS:
		if absf(p.x - tower_x) < 2.6 and p.y < float(CapitalLayout.WALL_Z1) + 2.0:
			return "wall tower"
	# outside the city: the rim rises within a few metres (the strip's margin by the wall is the wall's foot)
	if not CapitalLayout.is_inside(p.x, p.y):
		if cx == CapitalLayout.STRIP_X1 + 1 and cz < CapitalLayout.WALL_Z1 + 1:
			return "wall foot"
		for blocker: Vector2 in rim.blockers:
			if blocker.distance_to(p) < 2.2:
				return "rim rock"
		for reach: int in range(0, 4):
			for offset: Vector2i in [Vector2i(reach, 0), Vector2i(-reach, 0), Vector2i(0, reach), Vector2i(0, -reach)]:
				if rim.height_at(cx + offset.x, cz + offset.y) > 0.5:
					return "rim"
	return ""


func test_every_edge_of_the_walkable_ground_has_a_blocker_you_can_see() -> void:
	var invisible: Array[String] = []
	for cz: int in range(0, CapitalBuilder.CREASE_Z):
		for cx: int in range(CapitalLayout.GRID_X0, CapitalLayout.GRID_X0 + CapitalLayout.W):
			if layout.cell_at(cx, cz) != CapitalLayout.Cell.GROUND:
				continue
			for step: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var n: Vector2i = Vector2i(cx, cz) + step
				if layout.cell_at(n.x, n.y) == CapitalLayout.Cell.GROUND:
					continue
				if layout.floor_at(n.x, n.y) == CapitalLayout.Floor.ROAD and CapitalLayout.ROAD_BEYOND.has_point(n):
					continue  # the road on to Crosspath: the way out, ended by the exit spot
				if _visible_blocker(n.x, n.y) == "" and invisible.size() < 12:
					invisible.append("(%d, %d)" % [n.x, n.y])
	assert_eq(invisible, [] as Array[String], "every stop at the walkable edge is a wall, a building, the hill or the rising ground")
