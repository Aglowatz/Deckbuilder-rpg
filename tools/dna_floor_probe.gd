extends SceneTree
## Dev probe (Fable Nov 14, Part 3.6): the D.N.A.'s floor as text ('#' floor, '.' the apron outside) and its arrival anchors.
func _initialize() -> void:
	var builder: DnaBuilder = DnaBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	for key: String in ["spawn", "exit", "lobby_center"]:
		if builder.has_anchor(key):
			print(key, " ", builder.anchor(key))
	var z: float = 0.0
	while z <= 84.0:
		var line: String = "%5.1f " % z
		var x: float = -10.0
		while x <= 110.0:
			line += "#" if builder.is_floor_at(Vector3(x, 0, z)) else "."
			x += 2.0
		print(line)
		z += 2.0
	quit(0)
