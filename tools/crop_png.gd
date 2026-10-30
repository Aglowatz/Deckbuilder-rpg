extends SceneTree
## Crops and enlarges part of a PNG (a contact sheet) so it can be looked at closely without another screenshot:
##   Godot --headless --path . -s res://tools/crop_png.gd -- --in=res://_screenshots/x.png --out=res://_screenshots/x_crop.png --rect=x,y,w,h --scale=2


func _initialize() -> void:
	var args: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	var image: Image = Image.load_from_file(ProjectSettings.globalize_path(str(args.get("in", ""))))
	if image == null:
		print("crop_png: cannot read %s" % str(args.get("in", "")))
		quit(1)
		return
	var numbers: PackedStringArray = str(args.get("rect", "0,0,%d,%d" % [image.get_width(), image.get_height()])).split(",")
	var rect: Rect2i = Rect2i(int(numbers[0]), int(numbers[1]), int(numbers[2]), int(numbers[3])).intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	var part: Image = image.get_region(rect)
	var scale: float = float(args.get("scale", "1"))
	if scale != 1.0:
		part.resize(int(part.get_width() * scale), int(part.get_height() * scale), Image.INTERPOLATE_LANCZOS)
	part.save_png(ProjectSettings.globalize_path(str(args.get("out", "res://_screenshots/crop.png"))))
	print("crop_png: saved %s (%dx%d)" % [str(args.get("out", "")), part.get_width(), part.get_height()])
	quit(0)
