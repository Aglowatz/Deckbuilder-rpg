extends SceneTree
## Contact sheet of the imported character frames: Godot --headless --path . -s res://tools/char_sheet.gd -- hd2d|painted <out.png>
func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var kind: String = args[0]
	var cols: Array[Image] = []
	var tile: Vector2i = Vector2i.ZERO
	for d: String in ["FRONT", "BACK", "SIDE"]:
		for f: String in ["IDLE", "WALK1", "WALK2"]:
			var img: Image = Image.load_from_file(ProjectSettings.globalize_path("res://assets/art/characters/%s/%s_%s.png" % [kind, d, f]))
			cols.append(img)
			tile = img.get_size()
	var zoom: float = 4.0 if kind == "hd2d" else 0.6
	var tw: int = int(tile.x * zoom)
	var th: int = int(tile.y * zoom)
	var sheet: Image = Image.create(tw * 3, th * 3, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.55, 0.62, 0.5))
	for i: int in range(cols.size()):
		var img: Image = cols[i].duplicate()
		img.resize(tw, th, Image.INTERPOLATE_NEAREST if kind == "hd2d" else Image.INTERPOLATE_LANCZOS)
		sheet.blend_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), Vector2i((i % 3) * tw, (i / 3) * th))
		# baseline marker
	sheet.save_png(args[1])
	quit()
