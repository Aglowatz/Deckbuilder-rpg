extends SceneTree
## Character look test importer (docs/art/character_test.md). Reads the copies in _art_inbox/character_test/ (the Drive folder is never touched) and writes:
##   assets/art/characters/hd2d/<DIR>_<FRAME>.png   true pixel art: grid detected and snapped, downscaled to the real pixel size, one shared palette, feet on one baseline
##   assets/art/characters/painted/<DIR>_<FRAME>.png  smooth painted frames: background/glow cut, one scale per direction, feet on one baseline
##   assets/art/characters/character_test_report.txt   what was found (grid sizes, palette, missing files)
## Run: Godot --headless --path . -s res://tools/char_import.gd

const SRC: String = "res://_art_inbox/character_test/"
const OUT: String = "res://assets/art/characters/"
const DIRS: Array[String] = ["FRONT", "BACK", "SIDE"]
const FRAMES: Array[String] = ["IDLE", "WALK1", "WALK2"]
const PALETTE_SIZE: int = 40
const PAINTED_CANVAS: Vector2i = Vector2i(384, 576)
const PAINTED_HEIGHT: int = 536
const PAINTED_BASELINE: int = 560

var _report: PackedStringArray = []


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT + "hd2d"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT + "painted"))
	var missing: Array[String] = []
	if not FileAccess.file_exists(SRC + "CHAR-REF.png"):
		missing.append("CHAR-REF.png")
	for set_name: String in ["HD2D", "25D"]:
		for dir_name: String in DIRS:
			for frame_name: String in FRAMES:
				var file: String = "CHAR-%s-%s_%s.png" % [set_name, dir_name, frame_name]
				if not FileAccess.file_exists(SRC + file):
					missing.append(file)
	_report.append("Missing files: %s" % (", ".join(missing) if not missing.is_empty() else "none"))
	_do_hd2d()
	_do_painted()
	var file: FileAccess = FileAccess.open(OUT + "character_test_report.txt", FileAccess.WRITE)
	file.store_string("\n".join(_report) + "\n")
	file.close()
	print("\n".join(_report))
	quit()


# ---- Shared helpers ----------------------------------------------------------------------------------------------------------------


static func _load(path: String) -> Image:
	var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
	image.convert(Image.FORMAT_RGBA8)
	return image


## Alpha below `cut` is removed, the rest is re-ramped to 0..1 over [cut, cut + ramp] (cuts the soft glow around the figure), then stray islands
## smaller than 3 % of the biggest piece are dropped. Returns the labelled-clean image.
static func _clean_alpha(image: Image, cut: float, ramp: float, binary: bool) -> Image:
	var w: int = image.get_width()
	var h: int = image.get_height()
	var data: PackedByteArray = image.get_data()
	var keep: PackedByteArray = PackedByteArray()
	keep.resize(w * h)
	for i: int in range(w * h):
		var a: float = float(data[i * 4 + 3]) / 255.0
		keep[i] = 1 if a >= cut else 0
	# Connected components (4-neighbour) over kept pixels.
	var label: PackedInt32Array = PackedInt32Array()
	label.resize(w * h)
	var sizes: Array[int] = [0]
	var next_label: int = 1
	var stack: PackedInt32Array = PackedInt32Array()
	for start: int in range(w * h):
		if keep[start] == 0 or label[start] != 0:
			continue
		var count: int = 0
		stack.append(start)
		label[start] = next_label
		while not stack.is_empty():
			var p: int = stack[stack.size() - 1]
			stack.resize(stack.size() - 1)
			count += 1
			var x: int = p % w
			var y: int = p / w
			if x > 0 and keep[p - 1] == 1 and label[p - 1] == 0:
				label[p - 1] = next_label
				stack.append(p - 1)
			if x < w - 1 and keep[p + 1] == 1 and label[p + 1] == 0:
				label[p + 1] = next_label
				stack.append(p + 1)
			if y > 0 and keep[p - w] == 1 and label[p - w] == 0:
				label[p - w] = next_label
				stack.append(p - w)
			if y < h - 1 and keep[p + w] == 1 and label[p + w] == 0:
				label[p + w] = next_label
				stack.append(p + w)
		sizes.append(count)
		next_label += 1
	var biggest: int = 0
	for s: int in sizes:
		biggest = maxi(biggest, s)
	for i: int in range(w * h):
		var ok: bool = label[i] != 0 and sizes[label[i]] >= int(biggest * 0.03)
		if not ok:
			data[i * 4 + 3] = 0
			data[i * 4] = 0
			data[i * 4 + 1] = 0
			data[i * 4 + 2] = 0
		else:
			var a: float = float(data[i * 4 + 3]) / 255.0
			var out_a: float = 1.0 if binary else clampf((a - cut) / ramp, 0.0, 1.0)
			data[i * 4 + 3] = int(round(out_a * 255.0))
	return Image.create_from_data(w, h, false, Image.FORMAT_RGBA8, data)


static func _bbox(image: Image, threshold: int = 8) -> Rect2i:
	var w: int = image.get_width()
	var h: int = image.get_height()
	var data: PackedByteArray = image.get_data()
	var min_x: int = w
	var min_y: int = h
	var max_x: int = -1
	var max_y: int = -1
	for y: int in range(h):
		for x: int in range(w):
			if data[(y * w + x) * 4 + 3] > threshold:
				min_x = mini(min_x, x)
				max_x = maxi(max_x, x)
				min_y = mini(min_y, y)
				max_y = maxi(max_y, y)
	if max_x < 0:
		return Rect2i()
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)


static func _centroid_x(image: Image) -> float:
	var w: int = image.get_width()
	var h: int = image.get_height()
	var data: PackedByteArray = image.get_data()
	var total: float = 0.0
	var sum: float = 0.0
	for y: int in range(h):
		for x: int in range(w):
			var a: int = data[(y * w + x) * 4 + 3]
			if a > 8:
				total += a
				sum += float(x) * a
	return sum / maxf(total, 1.0)


# ---- HD-2D: true pixel art -------------------------------------------------------------------------------------------------------------


## Finds the size of one "fat pixel": the smallest period whose cell boundaries carry nearly all of the image's colour edges.
## Returns Vector3(period, phase_x, phase_y) (square cells).
static func _detect_grid(image: Image) -> Vector3:
	var w: int = image.get_width()
	var h: int = image.get_height()
	var data: PackedByteArray = image.get_data()
	var col_edge: PackedFloat32Array = PackedFloat32Array()
	col_edge.resize(w)
	var row_edge: PackedFloat32Array = PackedFloat32Array()
	row_edge.resize(h)
	for y: int in range(1, h):
		for x: int in range(1, w):
			var i: int = (y * w + x) * 4
			if data[i + 3] < 128 and data[i - 1] < 128:
				continue
			var left: int = i - 4
			var up: int = i - w * 4
			var dx: int = absi(data[i] - data[left]) + absi(data[i + 1] - data[left + 1]) + absi(data[i + 2] - data[left + 2])
			var dy: int = absi(data[i] - data[up]) + absi(data[i + 1] - data[up + 1]) + absi(data[i + 2] - data[up + 2])
			col_edge[x] += dx
			row_edge[y] += dy
	var best_period: float = 12.0
	var best_fraction: float = -1.0
	var results: Array[Vector3] = []
	var total_c: float = 0.0
	var total_r: float = 0.0
	for v: float in col_edge:
		total_c += v
	for v: float in row_edge:
		total_r += v
	var p: float = 9.70
	while p <= 9.90:
		var best_phase: Vector2 = Vector2.ZERO
		var best_here: float = -1.0
		var phase: float = 0.0
		while phase < p:
			var energy: float = 0.0
			var k: float = phase
			while k < w:
				var xi: int = int(round(k))
				if xi >= 1 and xi < w:
					energy += col_edge[xi]
				k += p
			var frac_c: float = energy / maxf(total_c, 1.0)
			if frac_c > best_here:
				best_here = frac_c
				best_phase.x = phase
			phase += 0.25
		var best_here_r: float = -1.0
		phase = 0.0
		while phase < p:
			var energy_r: float = 0.0
			var k2: float = phase
			while k2 < h:
				var yi: int = int(round(k2))
				if yi >= 1 and yi < h:
					energy_r += row_edge[yi]
				k2 += p
			var frac_r: float = energy_r / maxf(total_r, 1.0)
			if frac_r > best_here_r:
				best_here_r = frac_r
				best_phase.y = phase
			phase += 0.25
		var fraction: float = (best_here + best_here_r) * 0.5
		results.append(Vector3(p, best_phase.x, best_phase.y))
		if fraction > best_fraction:
			best_fraction = fraction
		p += 0.05
	# Smallest period that captures >= 93 % of the best fraction, then the best one within +-0.3 of it.
	var chosen: Vector3 = results[0]
	var chosen_score: float = -1.0
	for candidate: Vector3 in results:
		var score: float = _grid_fraction(col_edge, row_edge, total_c, total_r, candidate)
		if score >= best_fraction * 0.93:
			chosen = candidate
			chosen_score = score
			break
	var local_best: float = chosen_score
	for candidate: Vector3 in results:
		if absf(candidate.x - chosen.x) <= 0.3:
			var score2: float = _grid_fraction(col_edge, row_edge, total_c, total_r, candidate)
			if score2 > local_best:
				local_best = score2
				chosen = candidate
	return chosen


static func _grid_fraction(col_edge: PackedFloat32Array, row_edge: PackedFloat32Array, total_c: float, total_r: float, grid: Vector3) -> float:
	var energy_c: float = 0.0
	var k: float = grid.y
	while k < col_edge.size():
		var xi: int = int(round(k))
		if xi >= 1 and xi < col_edge.size():
			energy_c += col_edge[xi]
		k += grid.x
	var energy_r: float = 0.0
	var k2: float = grid.z
	while k2 < row_edge.size():
		var yi: int = int(round(k2))
		if yi >= 1 and yi < row_edge.size():
			energy_r += row_edge[yi]
		k2 += grid.x
	return (energy_c / maxf(total_c, 1.0) + energy_r / maxf(total_r, 1.0)) * 0.5


## One image pixel per grid cell: the median colour of the cell's centre region; the cell is solid when most of its centre is.
static func _snap_to_grid(image: Image, grid: Vector3) -> Image:
	var period: float = grid.x
	var w: int = image.get_width()
	var h: int = image.get_height()
	var cols: int = int(floor((float(w) - grid.y) / period))
	var rows: int = int(floor((float(h) - grid.z) / period))
	var out: Image = Image.create(cols, rows, false, Image.FORMAT_RGBA8)
	var data: PackedByteArray = image.get_data()
	var margin: float = period * 0.28
	for j: int in range(rows):
		for i: int in range(cols):
			var x0: int = int(round(grid.y + i * period + margin))
			var x1: int = int(round(grid.y + (i + 1) * period - margin))
			var y0: int = int(round(grid.z + j * period + margin))
			var y1: int = int(round(grid.z + (j + 1) * period - margin))
			var rs: Array[int] = []
			var gs: Array[int] = []
			var bs: Array[int] = []
			var solid: int = 0
			var total: int = 0
			for y: int in range(y0, maxi(y1, y0 + 1)):
				for x: int in range(x0, maxi(x1, x0 + 1)):
					if x >= w or y >= h:
						continue
					var idx: int = (y * w + x) * 4
					total += 1
					if data[idx + 3] > 127:
						solid += 1
						rs.append(data[idx])
						gs.append(data[idx + 1])
						bs.append(data[idx + 2])
			if total == 0 or solid * 2 <= total:
				out.set_pixel(i, j, Color(0, 0, 0, 0))
			else:
				rs.sort()
				gs.sort()
				bs.sort()
				var m: int = rs.size() / 2
				out.set_pixel(i, j, Color8(rs[m], gs[m], bs[m], 255))
	return out


## Median-cut-free palette: farthest-point seeds, then a few k-means passes over every opaque colour of every frame (weighted by use).
static func _build_palette(images: Array[Image], size: int) -> Array[Color]:
	var counts: Dictionary = {}
	for image: Image in images:
		for y: int in range(image.get_height()):
			for x: int in range(image.get_width()):
				var c: Color = image.get_pixel(x, y)
				if c.a > 0.5:
					var key: int = c.to_rgba32() >> 8
					counts[key] = int(counts.get(key, 0)) + 1
	var colors: Array[Vector3] = []
	var weights: Array[float] = []
	for key: int in counts:
		colors.append(Vector3(float((key >> 16) & 255), float((key >> 8) & 255), float(key & 255)))
		weights.append(float(counts[key]))
	# Seeds: the most-used colour, then repeatedly the colour farthest from all seeds weighted by sqrt(use).
	var centres: Array[Vector3] = []
	var first: int = 0
	for i: int in range(colors.size()):
		if weights[i] > weights[first]:
			first = i
	centres.append(colors[first])
	while centres.size() < size and centres.size() < colors.size():
		var far_index: int = 0
		var far_score: float = -1.0
		for i: int in range(colors.size()):
			var nearest: float = 1e20
			for c: Vector3 in centres:
				nearest = minf(nearest, colors[i].distance_squared_to(c))
			var score: float = nearest * sqrt(weights[i])
			if score > far_score:
				far_score = score
				far_index = i
		centres.append(colors[far_index])
	for _pass: int in range(8):
		var sums: Array[Vector3] = []
		var wsum: Array[float] = []
		for _c: int in range(centres.size()):
			sums.append(Vector3.ZERO)
			wsum.append(0.0)
		for i: int in range(colors.size()):
			var k: int = _nearest(centres, colors[i])
			sums[k] += colors[i] * weights[i]
			wsum[k] += weights[i]
		for k: int in range(centres.size()):
			if wsum[k] > 0.0:
				centres[k] = sums[k] / wsum[k]
	var palette: Array[Color] = []
	for c: Vector3 in centres:
		palette.append(Color8(int(round(c.x)), int(round(c.y)), int(round(c.z))))
	return palette


static func _nearest(centres: Array[Vector3], color: Vector3) -> int:
	var best: int = 0
	var best_d: float = 1e20
	for i: int in range(centres.size()):
		var d: float = color.distance_squared_to(centres[i])
		if d < best_d:
			best_d = d
			best = i
	return best


static func _apply_palette(image: Image, palette: Array[Color]) -> void:
	var centres: Array[Vector3] = []
	for c: Color in palette:
		centres.append(Vector3(c.r8, c.g8, c.b8))
	var cache: Dictionary = {}
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var c: Color = image.get_pixel(x, y)
			if c.a <= 0.5:
				image.set_pixel(x, y, Color(0, 0, 0, 0))
				continue
			var key: int = c.to_rgba32() >> 8
			if not cache.has(key):
				cache[key] = _nearest(centres, Vector3(c.r8, c.g8, c.b8))
			image.set_pixel(x, y, palette[int(cache[key])])


func _do_hd2d() -> void:
	var snapped: Dictionary = {}
	var images: Array[Image] = []
	_report.append("")
	_report.append("HD-2D grid detection (period in source px, phase x/y):")
	for dir_name: String in DIRS:
		for frame_name: String in FRAMES:
			var path: String = SRC + "CHAR-HD2D-%s_%s.png" % [dir_name, frame_name]
			if not FileAccess.file_exists(path):
				continue
			var cleaned: Image = _clean_alpha(_load(path), 0.5, 0.3, true)
			var box: Rect2i = _bbox(cleaned)
			var grid: Vector3 = _detect_grid(cleaned)
			var cells: Image = _snap_to_grid(cleaned, grid)
			var cell_box: Rect2i = _bbox(cells, 100)
			var trimmed: Image = cells.get_region(cell_box)
			snapped["%s_%s" % [dir_name, frame_name]] = trimmed
			images.append(trimmed)
			_report.append("  %s_%s: period %.2f px (phase %.2f, %.2f), figure %dx%d src px -> %dx%d pixel-art px" % [dir_name, frame_name, grid.x, grid.y, grid.z, box.size.x, box.size.y, cell_box.size.x, cell_box.size.y])
	var palette: Array[Color] = _build_palette(images, PALETTE_SIZE)
	_report.append("HD-2D shared palette: %d colours" % palette.size())
	var canvas_w: int = 0
	var canvas_h: int = 0
	for image: Image in images:
		_apply_palette(image, palette)
		canvas_w = maxi(canvas_w, image.get_width())
		canvas_h = maxi(canvas_h, image.get_height())
	canvas_w += 4
	canvas_h += 2
	canvas_w += canvas_w % 2
	_report.append("HD-2D canvas %dx%d, feet on the bottom row (baseline y=%d)" % [canvas_w, canvas_h, canvas_h - 1])
	for key: String in snapped:
		var image: Image = snapped[key]
		var canvas: Image = Image.create(canvas_w, canvas_h, false, Image.FORMAT_RGBA8)
		var cx: int = int(round(_centroid_x(image)))
		var ox: int = canvas_w / 2 - cx
		canvas.blit_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), Vector2i(ox, canvas_h - image.get_height()))
		canvas.save_png(ProjectSettings.globalize_path(OUT + "hd2d/%s.png" % key))


# ---- 2.5D painted ------------------------------------------------------------------------------------------------------------------------


func _do_painted() -> void:
	_report.append("")
	_report.append("2.5D painted (canvas %dx%d, mean figure height %d px per direction, baseline y=%d):" % [PAINTED_CANVAS.x, PAINTED_CANVAS.y, PAINTED_HEIGHT, PAINTED_BASELINE])
	for dir_name: String in DIRS:
		var cleaned: Dictionary = {}
		var boxes: Dictionary = {}
		var height_sum: float = 0.0
		for frame_name: String in FRAMES:
			var path: String = SRC + "CHAR-25D-%s_%s.png" % [dir_name, frame_name]
			if not FileAccess.file_exists(path):
				continue
			var image: Image = _clean_alpha(_load(path), 0.45, 0.4, false)
			cleaned[frame_name] = image
			boxes[frame_name] = _bbox(image, 40)
			height_sum += float((boxes[frame_name] as Rect2i).size.y)
		if cleaned.is_empty():
			continue
		# One scale per direction (the mean of its three frames), so the idle/walk swap never changes the figure's size.
		var scale_factor: float = float(PAINTED_HEIGHT) / (height_sum / float(cleaned.size()))
		for frame_name: String in cleaned:
			var image: Image = cleaned[frame_name]
			var box: Rect2i = boxes[frame_name]
			var cx: float = _centroid_x(image)
			var scaled: Image = image.duplicate()
			scaled.resize(int(round(image.get_width() * scale_factor)), int(round(image.get_height() * scale_factor)), Image.INTERPOLATE_LANCZOS)
			var canvas: Image = Image.create(PAINTED_CANVAS.x, PAINTED_CANVAS.y, false, Image.FORMAT_RGBA8)
			var dest: Vector2i = Vector2i(int(round(PAINTED_CANVAS.x * 0.5 - cx * scale_factor)), int(round(PAINTED_BASELINE - (box.position.y + box.size.y) * scale_factor)))
			canvas.blit_rect(scaled, Rect2i(Vector2i.ZERO, scaled.get_size()), dest)
			canvas.save_png(ProjectSettings.globalize_path(OUT + "painted/%s_%s.png" % [dir_name, frame_name]))
			_report.append("  %s_%s: figure %dx%d src px, scale %.3f" % [dir_name, frame_name, box.size.x, box.size.y, scale_factor])
