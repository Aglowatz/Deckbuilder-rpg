extends SceneTree
## Draws the D.N.A.'s layout from above as a PNG (a planning aid for the grand-hall pass, Overnight Nov 18):
## `Godot --headless -s res://tools/dna_plan.gd -- --out=<png>`. Void black, floor by kind, walls grey (shell walls light), anchors red,
## props blue, rooms outlined. 8 px per metre, north up.

const PX: int = 8


func _initialize() -> void:
	var out: String = "res://_screenshots/dna_plan.png"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.trim_prefix("--out=")
	var Layout: GDScript = load("res://world/dna/dna_layout.gd") as GDScript
	var Interior: GDScript = load("res://world/dna/dna_interior.gd") as GDScript
	var layout: Object = Layout.new()
	layout.build()
	var shell: Dictionary = Interior.shell_cells(layout)
	var image: Image = Image.create(Layout.W * PX, Layout.H * PX, false, Image.FORMAT_RGB8)
	var floor_colors: Array[Color] = [Color(0.3, 0.3, 0.3), Color(0.55, 0.3, 0.3), Color(0.7, 0.7, 0.66), Color(0.5, 0.5, 0.5), Color(0.6, 0.5, 0.3), Color(0.45, 0.55, 0.45)]
	for cz: int in range(Layout.H):
		for cx: int in range(Layout.W):
			var cell: int = int(layout.cell_at(cx, cz))
			var color: Color = Color.BLACK
			if cell == 2:
				color = Color(0.85, 0.85, 0.9) if shell.has(Vector2i(cx, cz)) else Color(0.3, 0.32, 0.4)
			elif cell == 3:
				color = Color(0.4, 0.2, 0.5)
			elif cell == 1:
				color = floor_colors[int(layout.floor_at(cx, cz))]
			image.fill_rect(Rect2i(cx * PX, cz * PX, PX, PX), color)
	for prop: Variant in layout.props:
		var p: Vector3 = prop.pos
		image.fill_rect(Rect2i(int(p.x * PX) - 2, int(p.z * PX) - 2, 4, 4), Color(0.2, 0.5, 1.0))
	for key: String in layout.anchors:
		var a: Vector3 = layout.anchors[key] as Vector3
		image.fill_rect(Rect2i(int(a.x * PX) - 3, int(a.z * PX) - 3, 6, 6), Color(1, 0.1, 0.1))
	image.save_png(ProjectSettings.globalize_path(out) if out.begins_with("res://") else out)
	print("dna_plan: %s (%d anchors, %d props, %d shell cells)" % [out, layout.anchors.size(), layout.props.size(), shell.size()])
	var keys: Array = layout.anchors.keys()
	keys.sort()
	for key: String in keys:
		print("  anchor %s %s" % [key, str(layout.anchors[key])])
	quit(0)
