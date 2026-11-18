extends SceneTree
## Nov 18 evening: lists the D.N.A.'s building-front runs (the two-storey painted walls) and how much open ground lies behind each.
## godot --headless --path . -s res://tools/dna_fronts_dump.gd


func _init() -> void:
	var layout: DnaLayout = DnaLayout.new()
	layout.build()
	var hall: DnaHall = DnaHall.new(layout)
	for run: Dictionary in hall.outline_runs():
		var cells: Array = run["cells"] as Array
		var step: Vector2i = run["dir"] as Vector2i
		var inside: bool = bool(run["inside"])
		if inside:
			continue
		var depth_min: int = 999
		for c: Variant in cells:
			var d: int = 0
			var p: Vector2i = (c as Vector2i) + step
			while hall.is_outside(p) and d < 40:
				d += 1
				p += step
			depth_min = mini(depth_min, d)
		print("front out dir=%s first=%s last=%s n=%d depth=%d" % [step, cells[0], cells[cells.size() - 1], cells.size(), depth_min])
	quit()
