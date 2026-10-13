extends SceneTree
## Puts two images side by side (each scaled to the given height) in one JPEG: the paint-over beside a screenshot.
##   Godot --headless --path . -s res://tools/side_by_side.gd -- --left=res://docs/art/paintovers/PAINTOVER-TOWN.png --right=res://_screenshots/vs_square.jpg --out=res://docs/art/vertical_slice/compare_square.jpg --height=540


func _initialize() -> void:
	var args: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			args[parts[0]] = parts[1] if parts.size() > 1 else ""
	var height: int = int(args.get("height", 540))
	var left: Image = Image.load_from_file(ProjectSettings.globalize_path(str(args["left"])))
	var right: Image = Image.load_from_file(ProjectSettings.globalize_path(str(args["right"])))
	for image: Image in [left, right]:
		var width: int = int(round(float(image.get_width()) * float(height) / float(image.get_height())))
		image.resize(width, height, Image.INTERPOLATE_LANCZOS)
	var out: Image = Image.create(left.get_width() + right.get_width() + 12, height, false, Image.FORMAT_RGB8)
	out.fill(Color(0.08, 0.06, 0.05))
	out.blit_rect(left, Rect2i(0, 0, left.get_width(), height), Vector2i(0, 0))
	out.blit_rect(right, Rect2i(0, 0, right.get_width(), height), Vector2i(left.get_width() + 12, 0))
	var path: String = ProjectSettings.globalize_path(str(args["out"]))
	var error: Error = out.save_jpg(path, 0.88)
	print("side_by_side: %s (%s) %dx%d" % [path, error_string(error), out.get_width(), out.get_height()])
	quit(0)
