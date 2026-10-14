extends SceneTree
## Converts images to JPEG for the docs (screenshots committed under docs/art are JPEGs): scaled to a maximum width, quality 0.88.
##   Godot --headless --path . -s res://tools/image_to_jpg.gd -- --width=1600 res://_screenshots/a.png res://_screenshots/b.png
## Writes <same folder>/<name>.jpg unless --out=res://folder/ is given (then <folder>/<name>.jpg).


func _initialize() -> void:
	var width: int = 1600
	var out_dir: String = ""
	var paths: Array[String] = []
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--width="):
			width = int(arg.trim_prefix("--width="))
		elif arg.begins_with("--out="):
			out_dir = arg.trim_prefix("--out=")
			if not out_dir.ends_with("/"):
				out_dir += "/"
		elif not arg.begins_with("--"):
			paths.append(arg)
	for path: String in paths:
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
		if image == null:
			print("image_to_jpg: cannot read %s" % path)
			continue
		image.convert(Image.FORMAT_RGB8)
		if image.get_width() > width:
			image.resize(width, int(round(float(image.get_height()) * float(width) / float(image.get_width()))), Image.INTERPOLATE_LANCZOS)
		var target: String = (out_dir if out_dir != "" else path.get_base_dir() + "/") + path.get_file().get_basename() + ".jpg"
		var error: Error = image.save_jpg(ProjectSettings.globalize_path(target), 0.88)
		print("image_to_jpg: %s (%s) %dx%d" % [target, error_string(error), image.get_width(), image.get_height()])
	quit(0)
