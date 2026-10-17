extends SceneTree
## Mean colour of small boxes of an image: Godot --headless --path . -s res://tools/pixel_probe.gd -- <image> x,y,w,h [x,y,w,h ...]


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var image: Image = Image.load_from_file(ProjectSettings.globalize_path(args[0]) if args[0].begins_with("res://") else args[0])
	for i: int in range(1, args.size()):
		var p: PackedStringArray = args[i].split(",")
		var sum: Color = Color(0, 0, 0, 0)
		var n: int = 0
		for y: int in range(int(p[1]), int(p[1]) + int(p[3])):
			for x: int in range(int(p[0]), int(p[0]) + int(p[2])):
				sum += image.get_pixel(x, y)
				n += 1
		print("%s: %.3f %.3f %.3f" % [args[i], sum.r / n, sum.g / n, sum.b / n])
	quit(0)
