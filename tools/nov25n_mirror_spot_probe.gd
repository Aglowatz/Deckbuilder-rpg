extends SceneTree
## Nov 25 night (Part B): where can the Cracked Mirror stand in the freed Capital? Every spot inside the walls that is ground (a 3 x 3 m
## square), clear of every obstacle, building, prop, sign, chest, anchor (NPCs, quest spots, shops), the freed city's crowd and the
## enemies' beats, and close to a route (findable) without standing on it. Prints the best spots per area.
##   Godot --headless --path . -s res://tools/nov25n_mirror_spot_probe.gd


func _initialize() -> void:
	var layout: CapitalLayout = CapitalLayout.new()
	layout.build()
	var found: Array[Dictionary] = []
	for x: int in range(3, 117):
		for z: int in range(3, CapitalLayout.WALL_Z0 - 1):
			var spot: Vector2 = Vector2(float(x) + 0.5, float(z) + 0.5)
			var score: float = _score(layout, spot)
			if score > 0.0:
				var area: CapitalLayout.Area = layout.area_at(spot.x, spot.y)
				found.append({"spot": spot, "score": score, "area": area.id if area != null else "?"})
	found.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["score"]) > float(b["score"]))
	var per_area: Dictionary = {}
	for entry: Dictionary in found:
		var area: String = str(entry["area"])
		if int(per_area.get(area, 0)) >= 4:
			continue
		per_area[area] = int(per_area.get(area, 0)) + 1
		print("mirror_spot: %-9s (%.1f, %.1f) score %.1f route %.1f m" % [area, (entry["spot"] as Vector2).x, (entry["spot"] as Vector2).y, float(entry["score"]), layout.route_edge_distance((entry["spot"] as Vector2).x, (entry["spot"] as Vector2).y)])
	print("mirror_spot: %d candidate spots" % found.size())
	quit(0)


func _score(layout: CapitalLayout, spot: Vector2) -> float:
	var cell: Vector2i = layout.cell_of(spot.x, spot.y)
	for dx: int in range(-1, 2):
		for dz: int in range(-1, 2):
			if not layout.is_ground_cell(cell.x + dx, cell.y + dz):
				return 0.0
	var route: float = layout.route_edge_distance(spot.x, spot.y)
	if route < 1.2 or route > 5.0:
		return 0.0
	var nearest: float = 99.0
	for circle: Vector3 in layout.obstacles:
		var gap: float = Vector2(circle.x, circle.y).distance_to(spot) - circle.z
		if gap < 1.6:
			return 0.0
		nearest = minf(nearest, gap)
	for building: CapitalLayout.Building in layout.buildings:
		if building.rect.grow(2.0).has_point(spot):
			return 0.0
	for prop: CapitalLayout.Prop in layout.props:
		if Vector2(prop.pos.x, prop.pos.z).distance_to(spot) < 3.0:
			return 0.0
	for sign: CapitalLayout.Sign in layout.signs:
		if Vector2(sign.pos.x, sign.pos.z).distance_to(spot) < 3.0:
			return 0.0
	for anchor: Variant in layout.anchors.values():
		var at: Vector3 = anchor as Vector3
		if Vector2(at.x, at.z).distance_to(spot) < 6.0:
			return 0.0
	for chest: Variant in layout.chests.values():
		var where: Vector3 = chest as Vector3
		if Vector2(where.x, where.z).distance_to(spot) < 4.0:
			return 0.0
	for spawn: Dictionary in layout.enemy_spawns:
		var home: Vector3 = spawn.get("home", Vector3(-99, 0, -99)) as Vector3
		var at: Vector2 = Vector2(home.x, home.z)
		if at.distance_to(spot) < 8.0:
			return 0.0
	for group: Dictionary in CapitalCelebration.CROWD_GROUPS:
		if (group["at"] as Vector2).distance_to(spot) < 6.0:
			return 0.0
	if spot.distance_to(CapitalLayout.PLAZA_CENTER) < CapitalLayout.PLAZA_RADIUS + 4.0:
		return 0.0
	for side: Vector2 in CapitalLayout.SIDE_PLAZAS:
		if spot.distance_to(side) < CapitalLayout.SIDE_PLAZA_RADIUS + 2.0:
			return 0.0
	# room around it (the more open ground the better), close to a route (findable)
	return minf(nearest, 8.0) + (5.0 - route) * 0.5
