extends SceneTree
## Draws the Capital's layout from above as a PNG (a planning aid for layout passes): `Godot --headless -s res://tools/capital_plan.gd -- --out=<png>`.
## Cells (void black, buildings grey, ground by floor kind), routes (pale), blocking circles (red), anchors (blue), chests (yellow), rifts (violet),
## enemy homes (orange), stand-in blockers (magenta), paint-over camera spots (green), region rects (thin white). 4 px per metre, north up.

const PX: int = 4


func _initialize() -> void:
	var out: String = "res://_screenshots/capital_plan.png"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.trim_prefix("--out=")
	var Layout: GDScript = load("res://world/capital/capital_layout.gd") as GDScript
	var layout: Object = Layout.new()
	layout.build()
	var rows: int = Layout.OUT_Z1 + 3
	var image: Image = Image.create(Layout.W * PX, rows * PX, false, Image.FORMAT_RGB8)
	var floor_colors: Dictionary = {
		Layout.Floor.GRAVEL: Color(0.45, 0.42, 0.36), Layout.Floor.ROAD: Color(0.72, 0.68, 0.58), Layout.Floor.PLAZA: Color(0.86, 0.82, 0.74),
		Layout.Floor.LAWN: Color(0.35, 0.62, 0.35), Layout.Floor.GRAY: Color(0.55, 0.55, 0.6), Layout.Floor.SOIL: Color(0.45, 0.36, 0.26),
		Layout.Floor.METAL: Color(0.5, 0.56, 0.64), Layout.Floor.TILE: Color(0.8, 0.62, 0.7), Layout.Floor.HUB: Color(0.4, 0.3, 0.2),
	}
	for cz: int in range(rows):
		for cx: int in range(Layout.W):
			var color: Color = Color.BLACK
			var cell: int = int(layout.cell_at(cx, cz))
			if cell == 2:
				color = Color(0.25, 0.25, 0.28)
			elif cell == 1:
				color = floor_colors.get(int(layout.floor_at(cx, cz)), Color(0.5, 0.5, 0.5)) as Color
			image.fill_rect(Rect2i(cx * PX, cz * PX, PX, PX), color)
	for area: Variant in layout.areas:
		_rect_outline(image, Rect2(area.rect), Color(1, 1, 1, 1) * 0.9)
	for route: Dictionary in layout.routes:
		var a: Vector2 = route["a"] as Vector2
		var b: Vector2 = route["b"] as Vector2
		var steps: int = int(a.distance_to(b) * 2.0)
		for index: int in range(steps + 1):
			var p: Vector2 = a.lerp(b, float(index) / float(maxi(steps, 1)))
			_dot(image, p, 0.15, Color(1.0, 1.0, 0.9))
	for obstacle: Vector3 in layout.obstacles:
		_circle(image, Vector2(obstacle.x, obstacle.y), obstacle.z, Color(0.9, 0.2, 0.2))
	for blocker: Vector3 in Layout.LANDMARK_BLOCKERS:
		_circle(image, Vector2(blocker.x, blocker.y), blocker.z, Color(1.0, 0.2, 1.0))
	for rift: Variant in layout.rifts:
		_circle(image, rift.pos, rift.radius, Color(0.6, 0.2, 1.0))
	for spawn: Dictionary in layout.enemy_spawns:
		var home: Vector3 = spawn["home"] as Vector3
		_dot(image, Vector2(home.x, home.z), 0.6, Color(1.0, 0.55, 0.1))
	for key: Variant in layout.anchors.keys():
		var pos: Vector3 = layout.anchors[key] as Vector3
		_dot(image, Vector2(pos.x, pos.z), 0.45, Color(0.2, 0.45, 1.0))
	for chest: Variant in layout.chests.values():
		_dot(image, Vector2((chest as Vector3).x, (chest as Vector3).z), 0.5, Color(1.0, 0.9, 0.1))
	for at: Variant in Layout.PO_CAMERAS.values():
		_dot(image, at as Vector2, 0.7, Color(0.1, 1.0, 0.3))
	for sign_data: Variant in layout.signs:
		_dot(image, Vector2(sign_data.pos.x, sign_data.pos.z), 0.3, Color(0.1, 0.9, 0.9))
	image.save_png(ProjectSettings.globalize_path(out) if out.begins_with("res://") else out)
	print("capital plan -> ", out)
	quit()


func _dot(image: Image, p: Vector2, radius: float, color: Color) -> void:
	_circle(image, p, radius, color, true)


func _circle(image: Image, center: Vector2, radius: float, color: Color, fill: bool = false) -> void:
	var r: int = int(ceilf(radius * float(PX)))
	var c: Vector2 = center * float(PX)
	for dy: int in range(-r - 1, r + 2):
		for dx: int in range(-r - 1, r + 2):
			var d: float = Vector2(float(dx), float(dy)).length()
			var on: bool = d <= float(r) if fill else absf(d - radius * float(PX)) < 0.8
			var x: int = int(c.x) + dx
			var y: int = int(c.y) + dy
			if on and x >= 0 and y >= 0 and x < image.get_width() and y < image.get_height():
				image.set_pixel(x, y, color)


func _rect_outline(image: Image, rect: Rect2, color: Color) -> void:
	var r: Rect2i = Rect2i(int(rect.position.x) * PX, int(rect.position.y) * PX, int(rect.size.x) * PX, int(rect.size.y) * PX)
	for x: int in range(r.position.x, r.end.x):
		for y: int in [r.position.y, r.end.y - 1]:
			if x >= 0 and y >= 0 and x < image.get_width() and y < image.get_height():
				image.set_pixel(x, y, color)
	for y: int in range(r.position.y, r.end.y):
		for x: int in [r.position.x, r.end.x - 1]:
			if x >= 0 and y >= 0 and x < image.get_width() and y < image.get_height():
				image.set_pixel(x, y, color)
