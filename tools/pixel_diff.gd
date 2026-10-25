extends SceneTree
## Performance pass Oct 25: how different two screenshot sets are (tools/perf_shots.sh). Headless:
## Godot --headless --path . -s res://tools/pixel_diff.gd -- --a=_screenshots/perf/before --b=_screenshots/perf/after [--out=docs/perf/diff_x.md] [--heat=dir]
## Per image: mean absolute difference (0-255, all channels), the share of pixels whose largest channel difference is over 16 and over 48,
## and the largest 32 x 32 block mean (a local change such as a missing prop shows there even when the mean is tiny). `--heat` writes
## amplified difference images. Two runs of unchanged code differ a little too (wind, clouds, particles): compare with a noise-floor pair.


func _initialize() -> void:
	var args: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	var dir_a: String = str(args.get("a", ""))
	var dir_b: String = str(args.get("b", ""))
	var heat: String = str(args.get("heat", ""))
	if not heat.is_empty():
		DirAccess.make_dir_recursive_absolute(heat)
	var lines: PackedStringArray = ["| Image | mean diff | px > 16 | px > 48 | worst 32px block |", "|---|---|---|---|---|"]
	var dir: DirAccess = DirAccess.open(dir_a)
	if dir == null:
		print("pixel_diff: cannot open ", dir_a)
		quit(1)
		return
	var names: PackedStringArray = dir.get_files()
	names.sort()
	for file_name: String in names:
		if not file_name.ends_with(".png") and not file_name.ends_with(".jpg"):
			continue
		var path_b: String = dir_b.path_join(file_name)
		if not FileAccess.file_exists(path_b):
			lines.append("| %s | (missing in b) | | | |" % file_name)
			continue
		var a: Image = Image.load_from_file(dir_a.path_join(file_name))
		var b: Image = Image.load_from_file(path_b)
		if a.get_size() != b.get_size():
			lines.append("| %s | (size %s vs %s) | | | |" % [file_name, str(a.get_size()), str(b.get_size())])
			continue
		a.convert(Image.FORMAT_RGB8)
		b.convert(Image.FORMAT_RGB8)
		var da: PackedByteArray = a.get_data()
		var db: PackedByteArray = b.get_data()
		var w: int = a.get_width()
		var h: int = a.get_height()
		var bw: int = int(ceil(float(w) / 32.0))
		var bh: int = int(ceil(float(h) / 32.0))
		var blocks: PackedFloat32Array = PackedFloat32Array()
		blocks.resize(bw * bh)
		var total: float = 0.0
		var over16: int = 0
		var over48: int = 0
		var heat_img: Image = Image.create(w, h, false, Image.FORMAT_RGB8) if not heat.is_empty() else null
		for y: int in range(h):
			for x: int in range(w):
				var i: int = (y * w + x) * 3
				var dr: int = absi(da[i] - db[i])
				var dg: int = absi(da[i + 1] - db[i + 1])
				var dbl: int = absi(da[i + 2] - db[i + 2])
				var sum: int = dr + dg + dbl
				total += float(sum)
				var top: int = maxi(dr, maxi(dg, dbl))
				if top > 16:
					over16 += 1
				if top > 48:
					over48 += 1
				blocks[(y / 32) * bw + (x / 32)] += float(sum)
				if heat_img != null:
					var v: float = minf(1.0, float(top) / 64.0)
					heat_img.set_pixel(x, y, Color(v, v * 0.3, 0.0))
		var worst: float = 0.0
		for value: float in blocks:
			worst = maxf(worst, value / (32.0 * 32.0 * 3.0))
		var px: float = float(w * h)
		lines.append("| %s | %.2f | %.2f%% | %.2f%% | %.1f |" % [file_name, total / (px * 3.0), 100.0 * float(over16) / px, 100.0 * float(over48) / px, worst])
		if heat_img != null:
			heat_img.save_png(heat.path_join(file_name.get_basename() + "_diff.png"))
	var text: String = "\n".join(lines)
	print(text)
	if args.has("out"):
		var file: FileAccess = FileAccess.open(str(args["out"]), FileAccess.WRITE)
		file.store_string("Pixel diff: `%s` vs `%s`\n\n%s\n" % [dir_a, dir_b, text])
		file.close()
	quit(0)
