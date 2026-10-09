extends SceneTree
## Verification sheet for the painted textures: each albedo tiled 2x2 (seams show as lines) at 256 px per tile, 4 per row. Args (after --): out name, then ids (e.g. mat_rock town_grass) or "all".
## Run: bash tools/texture_sheet.sh <name> <ids...>   -> docs/art/screens/textures/sheet_<name>.png

const OUT_DIR: String = "res://docs/art/screens/textures"


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var sheet_name: String = args[0] if args.size() > 0 else "sheet"
	var names: PackedStringArray = PackedStringArray()
	if args.size() < 2 or args[1] == "all":
		for file_name: String in DirAccess.get_files_at("res://assets/art/textures"):
			if file_name.ends_with("_albedo.webp"):
				names.append(file_name.trim_suffix("_albedo.webp"))
	else:
		for i: int in range(1, args.size()):
			names.append(args[i])
	var tile: int = 256
	var cols: int = 4
	var rows: int = int(ceil(float(names.size()) / float(cols)))
	var sheet: Image = Image.create(cols * tile * 2, rows * tile * 2, false, Image.FORMAT_RGB8)
	sheet.fill(Color.BLACK)
	for index: int in range(names.size()):
		var texture: Texture2D = load("res://assets/art/textures/%s_albedo.webp" % names[index]) as Texture2D
		if texture == null:
			continue
		var image: Image = texture.get_image()
		if image.is_compressed():
			image.decompress()
		image.convert(Image.FORMAT_RGB8)
		image.resize(tile, tile, Image.INTERPOLATE_BILINEAR)
		var ox: int = (index % cols) * tile * 2
		var oy: int = (index / cols) * tile * 2
		for dy: int in range(2):
			for dx: int in range(2):
				sheet.blit_rect(image, Rect2i(0, 0, tile, tile), Vector2i(ox + dx * tile, oy + dy * tile))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	sheet.save_png(ProjectSettings.globalize_path("%s/sheet_%s.png" % [OUT_DIR, sheet_name]))
	print("sheet: %s (%s)" % [sheet_name, ", ".join(names)])
	quit(0)
