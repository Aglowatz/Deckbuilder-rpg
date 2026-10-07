extends SceneTree
## Dev tool for fitting the node coordinates of the dungeon maps (docs/art/art_pipeline.md, "Dungeon maps"): `bash tools/map_fit_sheet.sh [dungeon ids]`.
## For each dungeon it draws the painted map with a 10% grid (the 50% lines are brighter) and every node at its current coordinates (CSV percentage, or the fitted value in
## data/dungeons/map_layout.json) as a numbered dot. Saves _screenshots/map_fit/<Dungeon ID>.png, 1536x1024. Compare the dots with the painted landing spots, then edit map_layout.json.

const FONT: Dictionary = {
	"0": ["111", "101", "101", "101", "111"], "1": ["010", "110", "010", "010", "111"], "2": ["111", "001", "111", "100", "111"],
	"3": ["111", "001", "111", "001", "111"], "4": ["101", "101", "111", "001", "001"], "5": ["111", "100", "111", "001", "111"],
	"6": ["111", "100", "111", "101", "111"], "7": ["111", "001", "010", "010", "010"], "8": ["111", "101", "111", "101", "111"],
	"9": ["111", "101", "111", "001", "111"],
}


func _init() -> void:
	var wanted: PackedStringArray = PackedStringArray()
	var crop: Rect2 = Rect2()
	for arg: String in OS.get_cmdline_user_args():
		if not arg.begins_with("--"):
			wanted.append(arg)
		elif arg.begins_with("--crop="):
			var parts: PackedStringArray = arg.trim_prefix("--crop=").split(",")
			crop = Rect2(float(parts[0]), float(parts[1]), float(parts[2]) - float(parts[0]), float(parts[3]) - float(parts[1]))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://_screenshots/map_fit"))
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		if not wanted.is_empty() and not wanted.has(blueprint.id):
			continue
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path("res://assets/art/maps/%s.webp" % blueprint.map_id))
		if image == null or image.is_empty():
			print("no map for %s" % blueprint.id)
			continue
		image.convert(Image.FORMAT_RGBA8)
		_grid(image)
		for node: DungeonCatalog.BlueprintNode in blueprint.nodes:
			_dot(image, Vector2(node.position.x * image.get_width(), node.position.y * image.get_height()), node.number, node.side)
		if crop.size.x > 0.0:
			var region: Image = image.get_region(Rect2i(int(crop.position.x * image.get_width()), int(crop.position.y * image.get_height()), int(crop.size.x * image.get_width()), int(crop.size.y * image.get_height())))
			region.resize(1536, int(1536.0 * float(region.get_height()) / float(region.get_width())), Image.INTERPOLATE_LANCZOS)
			image = region
		var path: String = "res://_screenshots/map_fit/%s.png" % (blueprint.id + ("_crop" if crop.size.x > 0.0 else ""))
		image.save_png(ProjectSettings.globalize_path(path))
		print("saved %s" % path)
	quit(0)


func _grid(image: Image) -> void:
	var w: int = image.get_width()
	var h: int = image.get_height()
	for step: int in range(1, 10):
		var colour: Color = Color(1, 1, 0.3, 0.75) if step == 5 else Color(1, 1, 1, 0.35)
		var x: int = int(round(float(w) * float(step) / 10.0))
		var y: int = int(round(float(h) * float(step) / 10.0))
		for i: int in range(h):
			image.set_pixel(x, i, image.get_pixel(x, i).blend(colour))
		for i: int in range(w):
			image.set_pixel(i, y, image.get_pixel(i, y).blend(colour))


func _dot(image: Image, center: Vector2, number: int, side: bool) -> void:
	var colour: Color = Color(1.0, 0.2, 0.9) if side else Color(1.0, 0.15, 0.1)
	var radius: int = 15
	for dy: int in range(-radius, radius + 1):
		for dx: int in range(-radius, radius + 1):
			var distance: float = sqrt(float(dx * dx + dy * dy))
			var px: int = int(center.x) + dx
			var py: int = int(center.y) + dy
			if px < 0 or py < 0 or px >= image.get_width() or py >= image.get_height():
				continue
			if distance <= float(radius) - 2.0:
				image.set_pixel(px, py, colour)
			elif distance <= float(radius):
				image.set_pixel(px, py, Color.BLACK)
	var text: String = str(number)
	var scale: int = 3
	var width: int = text.length() * 4 * scale - scale
	var origin: Vector2i = Vector2i(int(center.x) - width / 2, int(center.y) - 5 * scale / 2)
	for index: int in range(text.length()):
		var rows: Array = FONT[text[index]] as Array
		for row: int in range(5):
			for column: int in range(3):
				if (rows[row] as String)[column] == "1":
					for sy: int in range(scale):
						for sx: int in range(scale):
							var px2: int = origin.x + (index * 4 + column) * scale + sx
							var py2: int = origin.y + row * scale + sy
							if px2 >= 0 and py2 >= 0 and px2 < image.get_width() and py2 < image.get_height():
								image.set_pixel(px2, py2, Color.WHITE)
