extends SceneTree
## Joins two screenshots into one labelled-by-position JPG (left | right): godot -s tools/side_by_side.gd -- <left.png> <right.png> <out.jpg> [width per image, default 900]


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() < 3:
		push_error("usage: -- left.png right.png out.jpg [width]")
		quit(1)
		return
	var width: int = int(args[3]) if args.size() > 3 else 900
	var left: Image = Image.load_from_file(args[0])
	var right: Image = Image.load_from_file(args[1])
	var height: int = int(round(float(width) * left.get_height() / left.get_width()))
	left.resize(width, height, Image.INTERPOLATE_LANCZOS)
	right.resize(width, height, Image.INTERPOLATE_LANCZOS)
	var sheet: Image = Image.create(width * 2 + 6, height, false, Image.FORMAT_RGB8)
	sheet.fill(Color.WHITE)
	sheet.blit_rect(left, Rect2i(0, 0, width, height), Vector2i(0, 0))
	sheet.blit_rect(right, Rect2i(0, 0, width, height), Vector2i(width + 6, 0))
	DirAccess.make_dir_recursive_absolute(args[2].get_base_dir())
	print("saved %s (%s)" % [args[2], error_string(sheet.save_jpg(args[2], 0.88))])
	quit(0)
