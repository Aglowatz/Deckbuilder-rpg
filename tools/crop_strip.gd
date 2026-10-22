extends SceneTree
## Cuts the same rectangle out of several screenshots and lays the crops in a row (scaled up) so small differences (upscaler sharpness,
## shadow edges, sprite shading) can be judged side by side. Graphics Tier 1 (docs/art/graphics_tier1.md).
##   Godot --headless --path . -s res://tools/crop_strip.gd -- --in=res://_screenshots/a.png,res://_screenshots/b.png --rect=560,330,320,180 --zoom=2 --out=res://docs/art/graphics_tier1/compare/x.png
## `--rect=x,y,w,h` in source pixels; `--zoom` enlarges each crop (nearest, so the pixels stay honest); `--rows=N` wraps the strip.


func _initialize() -> void:
	var args: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			args[parts[0]] = parts[1] if parts.size() > 1 else ""
	var paths: PackedStringArray = str(args.get("in", "")).split(",", false)
	var rect_parts: PackedStringArray = str(args.get("rect", "0,0,320,180")).split(",")
	var rect: Rect2i = Rect2i(int(rect_parts[0]), int(rect_parts[1]), int(rect_parts[2]), int(rect_parts[3]))
	var zoom: int = maxi(1, int(args.get("zoom", 2)))
	var columns: int = maxi(1, int(args.get("cols", paths.size())))
	var gap: int = 6
	var cell: Vector2i = rect.size * zoom
	var rows: int = int(ceil(float(paths.size()) / float(columns)))
	var out: Image = Image.create(columns * cell.x + (columns - 1) * gap, rows * cell.y + (rows - 1) * gap, false, Image.FORMAT_RGB8)
	out.fill(Color(0.08, 0.06, 0.05))
	for index: int in range(paths.size()):
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path(paths[index]))
		if image == null:
			print("crop_strip: cannot load %s" % paths[index])
			continue
		image.convert(Image.FORMAT_RGB8)
		var crop: Image = image.get_region(rect)
		crop.resize(cell.x, cell.y, Image.INTERPOLATE_NEAREST)
		var at: Vector2i = Vector2i((index % columns) * (cell.x + gap), (index / columns) * (cell.y + gap))
		out.blit_rect(crop, Rect2i(Vector2i.ZERO, cell), at)
	var path: String = ProjectSettings.globalize_path(str(args.get("out", "res://_screenshots/crop_strip.png")))
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var error: Error = out.save_png(path) if path.ends_with(".png") else out.save_jpg(path, 0.92)
	print("crop_strip: %s (%s) %dx%d" % [path, error_string(error), out.get_width(), out.get_height()])
	quit(0)
