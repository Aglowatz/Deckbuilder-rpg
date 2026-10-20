extends SceneTree
## Review sheet for a batch of imported pictures (art import Oct 20): every file of `--ids` (comma list, or @file with one id per line) in `--dir` laid out on
## mid-grey with its id, so halos, crops and leftover backgrounds show; and an edge check per picture that flags a light or dark fringe (the soft edge
## pixels much brighter or darker than the solid pixels just inside them), a picture with no transparency, or one whose content touches the border.
## Run: Godot --headless --path . -s res://tools/art_review_sheet.gd -- --dir=res://assets/art/icons --ids=@ids.txt --ext=webp --out=res://_screenshots/x.png
##   [--cell=128] [--columns=12] [--opaque_ok=true]

var _dir: String = ""
var _ids: Array[String] = []
var _ext: String = "webp"
var _out: String = "res://_screenshots/art_review.png"
var _cell: int = 128
var _columns: int = 12
var _opaque_ok: bool = false


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		var value: String = arg.get_slice("=", 1)
		if arg.begins_with("--dir="):
			_dir = value
		elif arg.begins_with("--ext="):
			_ext = value
		elif arg.begins_with("--out="):
			_out = value
		elif arg.begins_with("--cell="):
			_cell = value.to_int()
		elif arg.begins_with("--columns="):
			_columns = value.to_int()
		elif arg.begins_with("--opaque_ok="):
			_opaque_ok = value == "true"
		elif arg.begins_with("--ids="):
			if value.begins_with("@"):
				var file: FileAccess = FileAccess.open(value.substr(1), FileAccess.READ)
				if file != null:
					for line: String in file.get_as_text().split("\n", false):
						if not line.strip_edges().is_empty():
							_ids.append(line.strip_edges())
			else:
				for id: String in value.split(",", false):
					_ids.append(id.strip_edges())
	var rows: int = int(ceil(float(_ids.size()) / float(_columns)))
	var sheet: Image = Image.create_empty(_cell * _columns, maxi(1, rows) * _cell, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.45, 0.47, 0.5))
	var flagged: PackedStringArray = []
	for index: int in range(_ids.size()):
		var path: String = ProjectSettings.globalize_path(_dir.path_join("%s.%s" % [_ids[index], _ext]))
		var image: Image = Image.load_from_file(path) if FileAccess.file_exists(path) else null
		if image == null:
			flagged.append("%s: MISSING" % _ids[index])
			continue
		image.convert(Image.FORMAT_RGBA8)
		var problem: String = _check(image)
		if not problem.is_empty():
			flagged.append("%s: %s" % [_ids[index], problem])
		var factor: float = minf(float(_cell - 6) / float(image.get_width()), float(_cell - 6) / float(image.get_height()))
		var small: Image = image.duplicate()
		small.resize(maxi(1, int(image.get_width() * factor)), maxi(1, int(image.get_height() * factor)), Image.INTERPOLATE_LANCZOS)
		var cell: Vector2i = Vector2i((index % _columns) * _cell, (index / _columns) * _cell)
		sheet.blend_rect(small, Rect2i(Vector2i.ZERO, small.get_size()), cell + (Vector2i(_cell, _cell) - small.get_size()) / 2)
		if not problem.is_empty():
			sheet.fill_rect(Rect2i(cell, Vector2i(_cell, 4)), Color(0.9, 0.2, 0.2))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_out.get_base_dir()))
	sheet.save_png(ProjectSettings.globalize_path(_out))
	print("art review: %d pictures -> %s" % [_ids.size(), _out])
	for line: String in flagged:
		print("  FLAG " + line)
	print("art review: %d flagged" % flagged.size())
	quit()


## "" when the picture looks clean, else what is wrong with it.
func _check(image: Image) -> String:
	var w: int = image.get_width()
	var h: int = image.get_height()
	var step: int = maxi(1, mini(w, h) / 256)
	var soft: int = 0
	var clear: int = 0
	var total: int = 0
	var fringe_sum: float = 0.0
	var inner_sum: float = 0.0
	var pairs: int = 0
	var border_hits: int = 0
	for y: int in range(0, h, step):
		for x: int in range(0, w, step):
			total += 1
			var c: Color = image.get_pixel(x, y)
			if c.a < 0.02:
				clear += 1
				continue
			if (x < step or y < step or x >= w - step or y >= h - step) and c.a > 0.5:
				border_hits += 1
			if c.a > 0.08 and c.a < 0.6:
				soft += 1
				# the solid pixel two steps further in (toward the more opaque neighbour)
				var best: Color = c
				for d: Vector2i in [Vector2i(2, 0), Vector2i(-2, 0), Vector2i(0, 2), Vector2i(0, -2)]:
					var p: Vector2i = Vector2i(x, y) + d * step
					if p.x >= 0 and p.y >= 0 and p.x < w and p.y < h:
						var n: Color = image.get_pixel(p.x, p.y)
						if n.a > best.a:
							best = n
				if best.a > 0.9:
					fringe_sum += c.get_luminance()
					inner_sum += best.get_luminance()
					pairs += 1
	if clear == 0:
		return "" if _opaque_ok else "no transparency (a background was left in)"
	if pairs > 40:
		var diff: float = (fringe_sum - inner_sum) / float(pairs)
		if diff > 0.22:
			return "light halo round the edge (fringe %.2f brighter than the inside)" % diff
		if diff < -0.28:
			return "dark halo round the edge (fringe %.2f darker than the inside)" % -diff
	var perimeter: int = 2 * (w + h) / step
	if border_hits > perimeter / 6:
		return "content touches the border (cropped?)"
	return ""
