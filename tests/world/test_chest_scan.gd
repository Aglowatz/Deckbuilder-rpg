extends GutTest
## Dev tool, not a check: with SCAN_CHESTS=<dir> it writes candidate spots for new hidden chests per zone (how far they are from the spawn, whether a
## jelly pad / ladder is needed, how cramped the nook is). Without the variable it does nothing.

func _zone(zone_id: String) -> ZoneMap:
	var helper: GutTest = load("res://tests/world/test_walkability_zones.gd").new() as GutTest
	var zone_map: ZoneMap = helper._make_zone(zone_id)
	helper.free()
	return zone_map


func _links(zone_id: String, zone_map: ZoneMap) -> Array:
	var helper: GutTest = load("res://tests/world/test_walkability_zones.gd").new() as GutTest
	var links: Array = helper._links_for(zone_id, zone_map)
	helper.free()
	return links


func _scan(zone_id: String) -> void:
	var dir: String = OS.get_environment("SCAN_CHESTS")
	if dir == "":
		pass_test("no scan requested")
		return
	var zone_map: ZoneMap = _zone(zone_id)
	var spawn: Vector3 = zone_map.anchor("spawn")
	var step: float = 0.6
	var bounds: Rect2 = zone_map.map_bounds()
	var can: Callable = func(p: Vector3) -> bool: return zone_map.is_walkable(p, 0.3)
	# BFS distances without links, then with links (a link seeds its target at the source's distance + 40).
	var dist: Dictionary = {}
	var queue: Array[Vector2i] = []
	var start: Vector2i = Vector2i(roundi(spawn.x / step), roundi(spawn.z / step))
	dist[start] = 0.0
	queue.append(start)
	var via_link: Dictionary = {}
	var links: Array = _links(zone_id, zone_map)
	var applied: Dictionary = {}
	var head: int = 0
	while true:
		while head < queue.size():
			var cell: Vector2i = queue[head]
			head += 1
			for d: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var n: Vector2i = cell + d
				if dist.has(n):
					continue
				var p: Vector3 = Vector3(float(n.x) * step, 0.0, float(n.y) * step)
				if not bounds.grow(2.0).has_point(Vector2(p.x, p.z)) or not can.call(p):
					continue
				dist[n] = float(dist[cell]) + step
				if via_link.has(cell):
					via_link[n] = true
				queue.append(n)
		var progressed: bool = false
		for i: int in range(links.size()):
			if applied.has(i):
				continue
			var link: Array = links[i] as Array
			var from: Vector3 = link[0] as Vector3
			var from_cell: Vector2i = Vector2i(roundi(from.x / step), roundi(from.z / step))
			var best: float = -1.0
			for dx: int in range(-5, 6):
				for dz: int in range(-5, 6):
					var c: Vector2i = from_cell + Vector2i(dx, dz)
					if dist.has(c) and (best < 0.0 or float(dist[c]) < best):
						best = float(dist[c])
			if best < 0.0:
				continue
			applied[i] = true
			var to: Vector3 = link[1] as Vector3
			var to_cell: Vector2i = Vector2i(roundi(to.x / step), roundi(to.z / step))
			if not dist.has(to_cell) and can.call(Vector3(float(to_cell.x) * step, 0.0, float(to_cell.y) * step)):
				dist[to_cell] = best + 40.0
				via_link[to_cell] = true
				queue.append(to_cell)
				progressed = true
		if not progressed:
			break
	var anchors: Array[Vector3] = []
	for key: String in _zone_anchor_keys(zone_id, zone_map):
		anchors.append(zone_map.anchor(key))
	var chests: Array = zone_map.chest_positions().values()
	var rows: Array[Array] = []
	for cell: Vector2i in dist.keys():
		var p: Vector3 = Vector3(float(cell.x) * step, 0.0, float(cell.y) * step)
		var too_close: bool = false
		for a: Vector3 in anchors:
			if Vector2(a.x - p.x, a.z - p.z).length() < 4.0:
				too_close = true
				break
		if too_close:
			continue
		for c: Variant in chests:
			if Vector2((c as Vector3).x - p.x, (c as Vector3).z - p.z).length() < 6.0:
				too_close = true
				break
		if too_close:
			continue
		# Cramped nook: how many neighbours within 1.8 m can be stood on (fewer = more tucked away).
		var open: int = 0
		for dx: int in range(-3, 4):
			for dz: int in range(-3, 4):
				if dist.has(cell + Vector2i(dx, dz)):
					open += 1
		var area: Array[String] = zone_map.area_at(p)
		rows.append([float(dist[cell]), open, bool(via_link.get(cell, false)), p.x, p.z, "|".join(area) if not area.is_empty() else "-"])
	if zone_id == "capital":
		var inner: PackedStringArray = PackedStringArray()
		for row: Array in rows:
			if float(row[3]) > 43.0 and float(row[3]) < 78.0 and float(row[4]) > 15.0 and float(row[4]) < 45.0:
				inner.append("dist %.0f open %d at (%.1f, %.1f) %s" % [row[0], row[1], row[3], row[4], row[5]])
		var inner_file: FileAccess = FileAccess.open("%s/capital_facade.txt" % dir, FileAccess.WRITE)
		inner_file.store_string("
".join(inner))
		inner_file.close()
	rows.sort_custom(func(a: Array, b: Array) -> bool: return float(a[0]) > float(b[0]))
	var lines: PackedStringArray = PackedStringArray()
	var kept: Array[Vector2] = []
	for row: Array in rows:
		var q: Vector2 = Vector2(float(row[3]), float(row[4]))
		var near: bool = false
		for k: Vector2 in kept:
			if k.distance_to(q) < 7.0:
				near = true
				break
		if near:
			continue
		kept.append(q)
		lines.append("dist %.0f open %d link %s at (%.1f, %.1f) area %s" % [row[0], row[1], str(row[2]), row[3], row[4], row[5]])
		if kept.size() >= 45:
			break
	var file: FileAccess = FileAccess.open("%s/%s.txt" % [dir, zone_id], FileAccess.WRITE)
	file.store_string("\n".join(lines))
	file.close()
	pass_test("scanned")


func _zone_anchor_keys(zone_id: String, zone_map: ZoneMap) -> Array:
	match zone_id:
		"dna":
			return (zone_map as DnaBuilder).layout.anchors.keys()
		"gainlands":
			return (zone_map as GainlandsBuilder).layout.anchors.keys()
		"buffet":
			return (zone_map as BuffetBuilder).layout.anchors.keys()
		"heap":
			return (zone_map as HeapBuilder).layout.anchors.keys()
	return (zone_map as CapitalBuilder).layout.anchors.keys()


func test_scan_dna() -> void:
	_scan("dna")


func test_scan_gainlands() -> void:
	_scan("gainlands")


func test_scan_buffet() -> void:
	_scan("buffet")


func test_scan_heap() -> void:
	_scan("heap")


func test_scan_capital() -> void:
	_scan("capital")
