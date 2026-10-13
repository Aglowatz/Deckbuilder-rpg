extends SceneTree
## Contact sheet of the Environment Kit art on a checker (alpha shows), one PNG: shows where the art has halos, frames, backgrounds.
##   Godot --headless --path . -s res://tools/kit_contact_sheet.gd -- --dir=res://assets/art/env_kit/ --out=res://_screenshots/kit_sheet.png --cols=8 --cell=200 [--only=ENV-DOOR,ENV-WINDOW]


func _initialize() -> void:
	var args: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			args[parts[0]] = parts[1] if parts.size() > 1 else ""
	var dir_path: String = str(args.get("dir", "res://assets/art/env_kit/"))
	var cols: int = int(args.get("cols", 8))
	var cell: int = int(args.get("cell", 200))
	var only: PackedStringArray = str(args.get("only", "")).split(",", false)
	var names: Array[String] = []
	var dir: DirAccess = DirAccess.open(dir_path)
	for file_name: String in dir.get_files():
		if file_name.get_extension() == "webp" and not file_name.contains("_n.") and not file_name.contains("_r."):
			var keep: bool = only.is_empty()
			for prefix: String in only:
				if file_name.begins_with(prefix):
					keep = true
			if keep:
				names.append(file_name)
	names.sort()
	var rows: int = int(ceil(float(names.size()) / float(cols)))
	var sheet: Image = Image.create(cols * cell, rows * cell, false, Image.FORMAT_RGBA8)
	for y: int in range(sheet.get_height()):
		for x: int in range(sheet.get_width()):
			sheet.set_pixel(x, y, Color(0.55, 0.55, 0.6) if ((x / 16 + y / 16) % 2 == 0) else Color(0.4, 0.4, 0.45))
	for index: int in range(names.size()):
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path(dir_path + names[index]))
		if image == null:
			continue
		var longest: int = maxi(image.get_width(), image.get_height())
		image.convert(Image.FORMAT_RGBA8)
		var factor: float = float(cell - 8) / float(longest)
		image.resize(maxi(1, int(image.get_width() * factor)), maxi(1, int(image.get_height() * factor)), Image.INTERPOLATE_LANCZOS)
		var ox: int = (index % cols) * cell + (cell - image.get_width()) / 2
		var oy: int = (index / cols) * cell + (cell - image.get_height()) / 2
		sheet.blend_rect(image, Rect2i(0, 0, image.get_width(), image.get_height()), Vector2i(ox, oy))
	sheet.save_png(ProjectSettings.globalize_path(str(args.get("out", "res://_screenshots/kit_sheet.png"))))
	print("kit_contact_sheet: %d images" % names.size())
	for index: int in range(names.size()):
		print("%d %s" % [index, names[index]])
	quit(0)
