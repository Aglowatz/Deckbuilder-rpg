extends GutTest
## Dev tool (SCAN_CHESTS=<dir>): candidate spots for new hidden chests in the town.

func test_scan_town() -> void:
	var dir: String = OS.get_environment("SCAN_CHESTS")
	if dir == "":
		pass_test("no scan requested")
		return
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	var town: TownBuilder = TownBuilder.new()
	town.build(root)
	TownSquare.build(root, town, GraphicsQuality.Level.MEDIUM)
	var rift: Vector3 = town.anchors["rift_station"] as Vector3
	town.obstacles.append(Vector3(rift.x, rift.z, 1.3))
	var spawn: Vector3 = town.anchors["spawn"] as Vector3
	var step: float = 0.6
	var bounds: Rect2 = town.map_bounds()
	var dist: Dictionary = {}
	var start: Vector2i = Vector2i(roundi(spawn.x / step), roundi(spawn.z / step))
	dist[start] = 0.0
	var queue: Array[Vector2i] = [start]
	var head: int = 0
	while head < queue.size():
		var cell: Vector2i = queue[head]
		head += 1
		for d: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = cell + d
			if dist.has(n):
				continue
			var p: Vector3 = Vector3(float(n.x) * step, 0.0, float(n.y) * step)
			if not bounds.grow(2.0).has_point(Vector2(p.x, p.z)) or not town.is_walkable(p, 0.3):
				continue
			dist[n] = float(dist[cell]) + step
			queue.append(n)
	var rows: Array[Array] = []
	for cell: Vector2i in dist.keys():
		var p: Vector3 = Vector3(float(cell.x) * step, 0.0, float(cell.y) * step)
		var near_anchor: float = 1.0e9
		for key: String in town.anchors.keys():
			var a: Vector3 = town.anchors[key] as Vector3
			near_anchor = minf(near_anchor, Vector2(a.x - p.x, a.z - p.z).length())
		if near_anchor < 4.0:
			continue
		var open: int = 0
		for dx: int in range(-3, 4):
			for dz: int in range(-3, 4):
				if dist.has(cell + Vector2i(dx, dz)):
					open += 1
		rows.append([float(dist[cell]), open, p.x, p.z, HexGrid.world_to_cell(p / TownBuilder.SCALE)])
	rows.sort_custom(func(a: Array, b: Array) -> bool: return float(a[0]) - float(a[1]) * 2.0 > float(b[0]) - float(b[1]) * 2.0)
	var lines: PackedStringArray = PackedStringArray()
	var kept: Array[Vector2] = []
	for row: Array in rows:
		var q: Vector2 = Vector2(float(row[2]), float(row[3]))
		var near: bool = false
		for k: Vector2 in kept:
			if k.distance_to(q) < 8.0:
				near = true
				break
		if near:
			continue
		kept.append(q)
		lines.append("dist %.0f open %d at (%.1f, %.1f) cell %s" % [row[0], row[1], row[2], row[3], str(row[4])])
		if kept.size() >= 60:
			break
	var file: FileAccess = FileAccess.open("%s/town.txt" % dir, FileAccess.WRITE)
	file.store_string("\n".join(lines))
	file.close()
	pass_test("scanned")
