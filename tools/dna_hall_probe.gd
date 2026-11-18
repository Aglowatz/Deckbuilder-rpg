extends SceneTree
## Prints the grand hall's cell kinds around a point and the outline runs that pass near it (Overnight Nov 18 debugging aid):
## `Godot --headless -s res://tools/dna_hall_probe.gd -- --at=28,47 --r=8`


func _initialize() -> void:
	var at: Vector2i = Vector2i(28, 47)
	var radius: int = 8
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--at="):
			var p: PackedStringArray = arg.trim_prefix("--at=").split(",")
			at = Vector2i(int(p[0]), int(p[1]))
		elif arg.begins_with("--r="):
			radius = int(arg.trim_prefix("--r="))
	var Layout: GDScript = load("res://world/dna/dna_layout.gd") as GDScript
	var Hall: GDScript = load("res://world/dna/dna_hall.gd") as GDScript
	var layout: Object = Layout.new()
	layout.build()
	var hall: Object = Hall.new(layout)
	var glyph: Dictionary = {0: ".", 1: "v", 2: "O", 3: "p"}
	for cz: int in range(at.y - radius, at.y + radius + 1):
		var line: String = "%3d " % cz
		for cx: int in range(at.x - radius * 2, at.x + radius * 2 + 1):
			var k: int = int(hall.kind_at(Vector2i(cx, cz)))
			var ch: String = str(glyph[k])
			if k == 0:
				ch = "f" if layout.is_floor(cx, cz) else ("x" if hall.is_outside(Vector2i(cx, cz)) else ".")
			line += ch
		print(line)
	for run: Dictionary in hall.outline_runs():
		var cells: Array = run["cells"] as Array
		var near: bool = false
		for c: Variant in cells:
			if (c as Vector2i).distance_to(at) <= float(radius):
				near = true
		if near:
			print("run dir=%s inside=%s from %s to %s (%d)" % [str(run["dir"]), str(run["inside"]), str(cells[0]), str(cells[cells.size() - 1]), cells.size()])
	quit(0)
