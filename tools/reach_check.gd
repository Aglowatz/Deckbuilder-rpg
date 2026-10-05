extends SceneTree
## Flood-fills the town's walkable ground and reports which anchors cannot be reached from the spawn: Godot --headless --path . -s res://tools/reach_check.gd
func _initialize() -> void:
	var t: TownBuilder = TownBuilder.new()
	var root: Node3D = Node3D.new()
	t.build(root)
	TownSquare.build(root, t, GraphicsQuality.Level.MEDIUM)
	var step: float = 0.45
	var start: Vector3 = t.anchors["spawn"] as Vector3
	var seen: Dictionary = {}
	var queue: Array[Vector2i] = [Vector2i(roundi(start.x / step), roundi(start.z / step))]
	seen[queue[0]] = true
	var head: int = 0
	while head < queue.size():
		var c: Vector2i = queue[head]
		head += 1
		for d: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = c + d
			if seen.has(n):
				continue
			var p: Vector3 = Vector3(float(n.x) * step, 0.0, float(n.y) * step)
			if t.is_walkable(p):
				seen[n] = true
				queue.append(n)
	print("reach: cells ", seen.size())
	for key: String in t.anchors:
		if key.begins_with("hidden_chest") or key == "dev_shrine":
			pass
		var a: Vector3 = t.anchors[key] as Vector3
		var best: float = 1e9
		for dx: int in range(-4, 5):
			for dz: int in range(-4, 5):
				var cell: Vector2i = Vector2i(roundi(a.x / step) + dx, roundi(a.z / step) + dz)
				if seen.has(cell):
					best = minf(best, Vector2(float(cell.x) * step - a.x, float(cell.y) * step - a.z).length())
		print("reach: %-34s nearest reachable %.2f %s" % [key, best, "" if best < 1.6 else "  <-- UNREACHABLE"])
	quit()
