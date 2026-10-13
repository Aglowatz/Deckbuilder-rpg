extends SceneTree
## Converts PNG screenshots to JPEG (docs).   Godot --headless --path . -s res://tools/to_jpg.gd -- --in=res://_screenshots/a.png --out=res://docs/art/a.jpg [--width=1280]


func _initialize() -> void:
	var args: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			args[parts[0]] = parts[1] if parts.size() > 1 else ""
	var image: Image = Image.load_from_file(ProjectSettings.globalize_path(str(args["in"])))
	var width: int = int(args.get("width", 1280))
	if image.get_width() > width:
		image.resize(width, int(round(float(image.get_height()) * float(width) / float(image.get_width()))), Image.INTERPOLATE_LANCZOS)
	image.convert(Image.FORMAT_RGB8)
	image.save_jpg(ProjectSettings.globalize_path(str(args["out"])), 0.88)
	quit(0)
