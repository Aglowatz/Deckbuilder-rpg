extends SceneTree
## Dev probe (Fable Nov 14, Part 3.5): what the Buffet's layout holds in a rectangle (anchors, props, chests, enemy homes, signs) and its walk grid.
## godot --headless --path . -s res://tools/buffet_rect_probe.gd -- --rect=28,58,44,18
func _initialize() -> void:
	var rect: Rect2 = Rect2(28, 58, 44, 18)
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--rect="):
			var p: PackedStringArray = arg.substr(7).split(",")
			rect = Rect2(float(p[0]), float(p[1]), float(p[2]), float(p[3]))
	var builder: BuffetBuilder = BuffetBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	var layout: BuffetLayout = builder.layout
	for key: Variant in layout.anchors.keys():
		var a: Vector3 = layout.anchors[key] as Vector3
		if rect.has_point(Vector2(a.x, a.z)):
			print("anchor %s (%.1f, %.1f)" % [key, a.x, a.z])
	for prop: BuffetLayout.Prop in layout.props:
		if rect.has_point(Vector2(prop.pos.x, prop.pos.z)):
			print("prop %s (%.1f, %.1f) r=%.1f" % [prop.kind, prop.pos.x, prop.pos.z, prop.radius])
	for id: Variant in layout.chests.keys():
		var c: Vector3 = layout.chests[id] as Vector3
		if rect.has_point(Vector2(c.x, c.z)):
			print("chest %s (%.1f, %.1f)" % [id, c.x, c.z])
	for spawn: Dictionary in layout.enemy_spawns:
		var h: Vector3 = spawn["home"] as Vector3
		if rect.has_point(Vector2(h.x, h.z)):
			print("enemy %s (%.1f, %.1f) r=%.1f" % [spawn["type"], h.x, h.z, float(spawn.get("patrol", 0.0))])
	var z: float = rect.position.y
	while z <= rect.end.y:
		var line: String = "%5.1f " % z
		var x: float = rect.position.x
		while x <= rect.end.x:
			line += "." if builder.is_walkable(Vector3(x, 0, z)) else "#"
			x += 1.0
		print(line)
		z += 1.0
	quit(0)
