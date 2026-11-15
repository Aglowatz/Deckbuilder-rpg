extends SceneTree
## Dev probe (Fable Nov 14, Part 3.4): the Verdant Dump's walk grid as text. Floods on foot from the arrival point (0.5 m grid) and prints the
## rows of a window: '.' reached on foot, 'm' reached only on the mount, 's' scree, '#' not walkable, 'C' a chest (upper case = reached on foot,
## 'c' = mount only, 'x' = never). godot --headless --path . -s res://tools/heap_foot_probe.gd -- --rect=40,2,44,40
func _initialize() -> void:
	var rect: Rect2 = Rect2(40, 2, 44, 40)
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--rect="):
			var p: PackedStringArray = arg.substr(7).split(",")
			rect = Rect2(float(p[0]), float(p[1]), float(p[2]), float(p[3]))
	var builder: HeapBuilder = HeapBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	var foot: Dictionary = flood(builder, false)
	var ride: Dictionary = flood(builder, true)
	var chests: Dictionary = builder.layout.chests
	for id: Variant in chests.keys():
		var c: Vector3 = chests[id] as Vector3
		print("%s (%.1f, %.1f): %s" % [id, c.x, c.z, "foot" if near(foot, c) else ("mount" if near(ride, c) else "NEVER")])
	var z: float = rect.position.y
	while z <= rect.end.y:
		var line: String = "%5.1f " % z
		var x: float = rect.position.x
		while x <= rect.end.x:
			var key: Vector2i = Vector2i(roundi(x * 2.0), roundi(z * 2.0))
			var ch: String = "#"
			if foot.has(key):
				ch = "."
			elif ride.has(key):
				ch = "s" if builder.layout.in_scree(x, z) else "m"
			for id: Variant in chests.keys():
				var c: Vector3 = chests[id] as Vector3
				if absf(c.x - x) < 0.5 and absf(c.z - z) < 0.5:
					ch = "C"
			line += ch
			x += 1.0
		print(line)
		z += 1.0
	quit(0)


static func near(reached: Dictionary, at: Vector3) -> bool:
	for dz: int in range(-4, 5):
		for dx: int in range(-4, 5):
			if reached.has(Vector2i(roundi(at.x * 2.0) + dx, roundi(at.z * 2.0) + dz)):
				return true
	return false


static func flood(builder: HeapBuilder, mounted: bool) -> Dictionary:
	builder.mounted = mounted
	var start: Vector3 = builder.anchor("spawn")
	var first: Vector2i = Vector2i(roundi(start.x * 2.0), roundi(start.z * 2.0))
	var seen: Dictionary = {first: true}
	var queue: Array[Vector2i] = [first]
	while not queue.is_empty():
		var cell: Vector2i = queue.pop_back()
		for step: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var next: Vector2i = cell + step
			if seen.has(next):
				continue
			if builder.is_walkable_through_barricades(Vector3(float(next.x) * 0.5, 0.0, float(next.y) * 0.5)):
				seen[next] = true
				queue.append(next)
	builder.mounted = false
	return seen
