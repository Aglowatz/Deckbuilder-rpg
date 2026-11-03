extends SceneTree
## Size pass Nov 3, Part 4: decodes every texture-format test copy in assets/art/_fmt_test/ (tools/texfmt_patch.js variants) and writes
## 100 % crops of the same region as PNGs for a side-by-side look (BC7 vs BC1 vs Basis UASTC), plus the source's own crop.
## Godot --headless --path . -s res://tools/texfmt_crops.gd [-- --out=res://docs/art/size_pass/texfmt --crop=320x240 --at=x,y]
## Prints one line per file: format, mip count and the mean absolute error against the source (decoded to RGB8).

const DIR: String = "res://assets/art/_fmt_test"


func _initialize() -> void:
	var args: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	var out: String = str(args.get("out", "res://docs/art/size_pass/texfmt"))
	var crop_text: PackedStringArray = str(args.get("crop", "320x240")).split("x")
	var crop: Vector2i = Vector2i(int(crop_text[0]), int(crop_text[1]))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out))
	var sources: Dictionary = {}
	for file: String in DirAccess.get_files_at(DIR):
		if not file.ends_with(".webp"):
			continue
		var stem: String = file.get_basename()
		var base: String = stem.split("__")[0]
		var variant: String = stem.split("__")[1] if stem.contains("__") else "src"
		var texture: Texture2D = load(DIR.path_join(file)) as Texture2D
		if texture == null:
			print("%s: could not load" % file)
			continue
		var image: Image = texture.get_image()
		var format: String = _format_name(image.get_format())
		var mips: int = image.get_mipmap_count()
		if image.is_compressed():
			image.decompress()
		image.convert(Image.FORMAT_RGB8)
		if not sources.has(base):
			var src: Image = Image.load_from_file(ProjectSettings.globalize_path(DIR.path_join(file)))
			src.convert(Image.FORMAT_RGB8)
			if src.get_size() != image.get_size():
				src.resize(image.get_width(), image.get_height(), Image.INTERPOLATE_LANCZOS)
			sources[base] = src
			_save_crop(src, out.path_join("%s__src.png" % base), crop, args)
		var src_image: Image = sources[base] as Image
		var err: float = _mean_abs_error(src_image, image)
		_save_crop(image, out.path_join("%s__%s.png" % [base, variant]), crop, args)
		print("texfmt: %s variant=%s format=%s mips=%d size=%dx%d mae=%.2f" % [base, variant, format, mips, image.get_width(), image.get_height(), err])
	quit(0)


func _save_crop(image: Image, path: String, crop: Vector2i, args: Dictionary) -> void:
	var at: Vector2i = Vector2i((image.get_width() - crop.x) / 2, (image.get_height() - crop.y) / 2)
	if args.has("at"):
		var xy: PackedStringArray = str(args["at"]).split(",")
		at = Vector2i(int(xy[0]), int(xy[1]))
	at = Vector2i(clampi(at.x, 0, maxi(0, image.get_width() - crop.x)), clampi(at.y, 0, maxi(0, image.get_height() - crop.y)))
	var region: Image = image.get_region(Rect2i(at, Vector2i(mini(crop.x, image.get_width()), mini(crop.y, image.get_height()))))
	region.save_png(ProjectSettings.globalize_path(path))


func _mean_abs_error(a: Image, b: Image) -> float:
	if a.get_size() != b.get_size():
		return -1.0
	var total: float = 0.0
	var count: int = 0
	var step: int = maxi(1, a.get_width() / 256)
	for y: int in range(0, a.get_height(), step):
		for x: int in range(0, a.get_width(), step):
			var ca: Color = a.get_pixel(x, y)
			var cb: Color = b.get_pixel(x, y)
			total += (absf(ca.r - cb.r) + absf(ca.g - cb.g) + absf(ca.b - cb.b)) * 255.0 / 3.0
			count += 1
	return total / float(maxi(count, 1))


func _format_name(format: int) -> String:
	match format:
		Image.FORMAT_DXT1: return "BC1"
		Image.FORMAT_DXT5: return "BC3"
		Image.FORMAT_BPTC_RGBA: return "BC7"
		Image.FORMAT_RGBA8: return "RGBA8"
		Image.FORMAT_RGB8: return "RGB8"
	return str(format)
