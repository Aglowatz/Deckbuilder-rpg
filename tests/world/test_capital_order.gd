extends GutTest
## The Capital pass, Part C: organized. Outside, the wasteland's pieces gather in a few composed vignettes along the roads' sides and the edges
## (never scattered, never on a road); the camp is tidy. Inside, perfection is the point: the rows along the avenue's ring streets, boulevards and
## the forecourt mirror exactly about the avenue (x 60), with one spacing and nothing turned at random; the chests stand square.

var capital: CapitalBuilder
var dressing: CapitalDressing
var holder: Node3D


func before_all() -> void:
	holder = Node3D.new()
	add_child(holder)
	capital = CapitalBuilder.new()
	capital.layout.build()
	capital._index_obstacles()
	var keep_clear: Array[Vector3] = []
	for key: Variant in capital.layout.anchors.keys():
		keep_clear.append(capital.layout.anchors[key] as Vector3)
	for sign_data: CapitalLayout.Sign in capital.layout.signs:
		keep_clear.append(sign_data.pos)
	for prop: CapitalLayout.Prop in capital.layout.props:
		if prop.radius > 0.0:
			keep_clear.append(prop.pos)
	dressing = CapitalDressing.build(holder, capital, keep_clear)


func after_all() -> void:
	holder.free()


func _positions(kind: String) -> Array[Vector2]:
	var out: Array[Vector2] = []
	for entry: Dictionary in dressing.fields.get(kind, []) as Array:
		var pos: Vector3 = entry["pos"] as Vector3
		out.append(Vector2(snappedf(pos.x, 0.01), snappedf(pos.z, 0.01)))
	return out


func _nearest_route(p: Vector2) -> String:
	var best: String = ""
	var best_d: float = INF
	for route: Dictionary in capital.layout.routes:
		var d: float = p.distance_to(Geometry2D.get_closest_point_to_segment(p, route["a"] as Vector2, route["b"] as Vector2)) - float(route["width"]) * 0.5
		if d < best_d:
			best_d = d
			best = str(route["id"])
	return best


func test_the_avenue_rows_mirror_exactly() -> void:
	for kind: String in ["cap_topiary", "cap_rose", "cap_lamp", "cap_bench"]:
		var points: Array[Vector2] = _positions(kind)
		var mirrored: int = 0
		for p: Vector2 in points:
			if not _nearest_route(p) in ["ring_w", "ring_e", "boulevard_w", "boulevard_e", "forecourt"]:
				continue  # the district streets and lanes have their own symmetry (about each lane)
			var twin: Vector2 = Vector2(snappedf(120.0 - p.x, 0.01), p.y)
			var found: bool = false
			for q: Vector2 in points:
				if q.distance_to(twin) < 0.05:
					found = true
			assert_true(found, "%s at %s has its twin across the avenue" % [kind, str(p)])
			mirrored += 1


func test_the_ring_streets_have_exact_mirrored_rows() -> void:
	var west: Array[float] = []
	var east: Array[float] = []
	for prop: CapitalLayout.Prop in capital.layout.props:
		if prop.kind in ["lamp_perfect", "bench"] and absf(prop.pos.x - (38.5 + CapitalLayout.RING_ROW_KERB)) < 0.01:
			west.append(prop.pos.z)
		elif prop.kind in ["lamp_perfect", "bench"] and absf(prop.pos.x - (81.5 - CapitalLayout.RING_ROW_KERB)) < 0.01:
			east.append(prop.pos.z)
	west.sort()
	east.sort()
	assert_gte(west.size(), 8, "lamps and benches line the west ring street")
	assert_eq(west, east, "the east ring street mirrors it exactly")
	for index: int in range(1, west.size()):
		var gap: float = west[index] - west[index - 1]
		assert_almost_eq(fmod(gap, CapitalLayout.RING_ROW_STEP * 0.5), 0.0, 0.01, "one spacing down the row (%.1f)" % gap)


func test_the_wasteland_gathers_in_composed_vignettes_off_the_roads() -> void:
	var scene_root: Node3D = Node3D.new()
	holder.add_child(scene_root)
	var wasteland: CapitalWasteland = CapitalWasteland.build(scene_root, capital, capital.layout, 1)
	assert_gt(wasteland.count, 20, "the clusters are dressed")
	for child: Node in wasteland.root.get_children():
		if not child is Node3D or child.name == &"AshDrifts":
			continue
		var pos: Vector3 = (child as Node3D).position
		assert_gt(capital.layout.route_edge_distance(pos.x, pos.z), CapitalLayout.ROUTE_CLEARANCE - 0.01, "%s stands off the roads" % child.name)
		var near: bool = false
		for spot: Vector3 in capital.layout.wasteland_clusters:
			if Vector2(spot.x - pos.x, spot.y - pos.z).length() < spot.z + 3.2:
				near = true
		assert_true(near, "%s belongs to a cluster, never scattered" % child.name)
		var yaw: float = fposmod(rad_to_deg((child as Node3D).rotation.y), 90.0)
		assert_true(yaw < 0.5 or yaw > 89.5, "%s is square to its road, not turned at random" % child.name)


func test_the_chests_stand_square() -> void:
	var source: String = FileAccess.get_file_as_string("res://world/capital/capital_builder.gd")
	assert_false(source.contains("chest.rotation_degrees.y = _rng.randf() * 360.0"), "no chest is turned at random")
