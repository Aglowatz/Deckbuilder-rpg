extends SceneTree
## World Look Test importer (docs/art/world_look_test.md). Reads the copies in _art_inbox/world_test/ (the Drive folder is never touched) and the checklist
## data/source/world_look_test.csv, and writes assets/art/world_test/:
##   sprites/<CHAR>/<DIR>_<IDLE|TALK|WALK1..4>.png  every frame cut out (walk strips sliced per detected figure), scaled so idle and walk of one direction match,
##                                                  feet on one baseline, torso centre on the canvas centre (so a walk cycle never jitters sideways)
##   sprites/manifest.json                           canvas size, figure height, relative height and frame list per character
##   sky/, backdrop/, tex/, dec/, foliage/           trimmed and resized copies (foliage packed into one atlas)
##   import_report.txt                               missing IDs, unmatched files, per-frame numbers
## Run: Godot --headless --path . -s res://tools/world_test_import.gd

const SRC: String = "res://_art_inbox/world_test/"
## `--cosmetics`: the hats and cloak sets (tools/import_cosmetics.sh copies them here); the output goes to cosmetics_manifest.json and assets/art/cosmetics/hats/.
const COS_SRC: String = "res://_art_inbox/cosmetics/"
const COS_MANIFEST: String = "sprites/cosmetics_manifest.json"
const HAT_OUT: String = "res://assets/art/cosmetics/hats/"
var _hat_out: String = HAT_OUT
const HAT_MAX_WIDTH: int = 640
const OUT: String = "res://assets/art/world_test/"
const CSV_PATH: String = "res://data/source/world_look_test.csv"
const SHEETS: String = "res://_art_inbox/world_test_sheets/"
## Figure height (feet to top of head) in the output canvas, in pixels, for a character the size of the median idle.
const FIG_H: int = 440
const TOP_PAD: int = 40
const BOTTOM_PAD: int = 16
const ALPHA_EDGE: float = 0.32
const DIRS: Array[String] = ["FRONT", "FRONTSIDE", "SIDE", "BACKSIDE", "BACK"]
const CHARS: Array[String] = ["PLAYER", "ELDER", "GATEKEEPER", "SABLE", "TONIC", "FENWICK", "VILLAGER"]
const NPC_SRC: String = "res://_art_inbox/npc_sprites/"
const NPC_BATCH_CSV: String = "res://data/source/npc_sprite_batch.csv"
const NPC_LIST_CSV: String = "res://data/source/npc_list.csv"
const NPC_REPORT: String = "res://docs/art/npc_sprite_import_report.md"
## Characters whose frames came from the World Look Test and are tuned for the hero / baker; the NPC importer leaves them alone.
const NPC_KEEP: Array[String] = ["PLAYER", "VILLAGER"]
const FOLIAGE_CELL: int = 384
## Degrees the shore-foam strip is turned (clockwise on screen) to make its foam line horizontal.
const FOAM_TURN_DEGREES: int = 21

var _report: PackedStringArray = []
var _used: Dictionary = {}
var _manifest: Dictionary = {}
var _rel_height: Dictionary = {}
var _ids: Array[String] = []
var _src: String = SRC


func _initialize() -> void:
	if OS.get_cmdline_user_args().has("--npcs"):
		_run_npcs()
		quit()
		return
	if OS.get_cmdline_user_args().has("--cosmetics"):
		_run_cosmetics()
		quit()
		return
	for sub: String in ["sprites", "sky", "backdrop", "tex", "dec", "foliage"]:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT + sub))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHEETS))
	_read_csv()
	for character: String in CHARS:
		_do_character(character)
	var manifest_file: FileAccess = FileAccess.open(OUT + "sprites/manifest.json", FileAccess.WRITE)
	manifest_file.store_string(JSON.stringify(_manifest, "\t"))
	manifest_file.close()
	_do_sky()
	_do_backdrops()
	_do_simple("TEX-TOWN-WATER", "tex/town_water.png", 1024)
	_do_foam()
	_do_foliage()
	_unmatched()
	var file: FileAccess = FileAccess.open(OUT + "import_report.txt", FileAccess.WRITE)
	file.store_string("\n".join(_report) + "\n")
	file.close()
	print("\n".join(_report))
	quit()


# ---- Checklist -------------------------------------------------------------------------------------------------------------------


func _read_csv() -> void:
	var file: FileAccess = FileAccess.open(CSV_PATH, FileAccess.READ)
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() < 7:
			continue
		var id: String = row[0].strip_edges()
		var is_asset: bool = false
		for prefix: String in ["SPR-", "SKY-", "BD-", "TEX-", "DEC-", "FOL-"]:
			if id.begins_with(prefix):
				is_asset = true
		if not is_asset:
			continue
		_ids.append(id)
		if id.begins_with("SPR-") and row[6].strip_edges() != "":
			var parts: PackedStringArray = id.split("-")
			if not _rel_height.has(parts[1]):
				_rel_height[parts[1]] = float(row[6])
	var missing: Array[String] = []
	for id: String in _ids:
		if not FileAccess.file_exists(_src + id + ".png"):
			missing.append(id)
	_report.append("Checklist rows with an ID: %d. Missing files: %s" % [_ids.size(), ", ".join(missing) if not missing.is_empty() else "none"])


func _unmatched() -> void:
	var extra: Array[String] = []
	for file_name: String in DirAccess.get_files_at(_src):
		if file_name.get_extension() != "png":
			continue
		var id: String = file_name.get_basename()
		if not _ids.has(id) and id != "CHAR-REF":
			extra.append(file_name)
	_report.append("Files not in the checklist: %s" % (", ".join(extra) if not extra.is_empty() else "none"))
	var unused: Array[String] = []
	for file_name: String in DirAccess.get_files_at(_src):
		if file_name.get_extension() == "png" and not _used.has(file_name.get_basename()):
			unused.append(file_name)
	_report.append("Files read but not used for a game asset (model sheets, reference): %s" % ", ".join(unused))


func _load(id: String) -> Image:
	var path: String = ProjectSettings.globalize_path(_src + id + ".png")
	if not FileAccess.file_exists(path):
		return null
	var image: Image = Image.load_from_file(path)
	if image == null:
		return null
	image.convert(Image.FORMAT_RGBA8)
	if _npc_mode:
		_remove_flat_background(image, id)
	_used[id] = true
	return image


func _save(image: Image, rel_path: String) -> void:
	image.save_png(ProjectSettings.globalize_path(OUT + rel_path))


# ---- Pixel helpers ---------------------------------------------------------------------------------------------------------------


## Bounding box (columns x0..x1 inclusive, rows y0..y1) of pixels whose alpha is above ALPHA_EDGE inside `area`.
func _bbox(image: Image, area: Rect2i) -> Rect2i:
	var x0: int = 1 << 30
	var y0: int = 1 << 30
	var x1: int = -1
	var y1: int = -1
	for y: int in range(area.position.y, area.end.y):
		for x: int in range(area.position.x, area.end.x):
			if image.get_pixel(x, y).a > ALPHA_EDGE:
				if x < x0:
					x0 = x
				if x > x1:
					x1 = x
				if y < y0:
					y0 = y
				if y > y1:
					y1 = y
	if x1 < 0:
		return Rect2i()
	return Rect2i(x0, y0, x1 - x0 + 1, y1 - y0 + 1)


## Alpha-weighted mean x of the head and upper-body band (10 % - 45 % of the figure height from the top): the torso line, which does not swing with the legs or the cloak.
func _torso_x(image: Image, box: Rect2i) -> float:
	var y_from: int = box.position.y + int(float(box.size.y) * 0.10)
	var y_to: int = box.position.y + int(float(box.size.y) * 0.45)
	var sum: float = 0.0
	var weight: float = 0.0
	for y: int in range(y_from, y_to):
		for x: int in range(box.position.x, box.end.x):
			var a: float = image.get_pixel(x, y).a
			if a > ALPHA_EDGE:
				sum += float(x) * a
				weight += a
	return sum / weight if weight > 0.0 else float(box.position.x + box.size.x) * 0.5


## Column runs of figure pixels in a walk strip: [[x0, x1], ...] with gaps of at least `gap` empty columns between runs.
func _runs(image: Image, gap: int) -> Array:
	var width: int = image.get_width()
	var height: int = image.get_height()
	var filled: PackedByteArray = PackedByteArray()
	filled.resize(width)
	for x: int in range(width):
		var count: int = 0
		for y: int in range(0, height, 2):
			if image.get_pixel(x, y).a > ALPHA_EDGE:
				count += 1
		filled[x] = 1 if count > 1 else 0
	var runs: Array = []
	var start: int = -1
	var empty: int = 0
	for x: int in range(width):
		if filled[x] == 1:
			if start < 0:
				start = x
			empty = 0
		elif start >= 0:
			empty += 1
			if empty >= gap:
				runs.append([start, x - empty])
				start = -1
	if start >= 0:
		runs.append([start, width - 1 - empty])
	return runs


# ---- Sprites ---------------------------------------------------------------------------------------------------------------------


## A cut-out figure: the image cropped to its box, the torso x inside the crop, and the box height in source pixels.
func _figure(source: Image, area: Rect2i) -> Dictionary:
	var box: Rect2i = _bbox(source, area)
	if box.size.x == 0:
		return {}
	var torso: float = _torso_x(source, box)
	var crop: Image = source.get_region(box)
	return {"image": crop, "torso": torso - float(box.position.x), "height": box.size.y}


## Splits a walk strip into its four figures by connected components of the (block-downsampled) alpha, so figures whose cloaks overlap in x are still told apart.
## Specks of glow smaller than a fifth of the largest piece join the nearest figure. Falls back to four equal parts when the strip does not split into four.
func _slice_strip(image: Image, label: String) -> Array:
	const BLOCK: int = 4
	var width: int = image.get_width()
	var height: int = image.get_height()
	var bw: int = width / BLOCK
	var bh: int = height / BLOCK
	var filled: PackedByteArray = PackedByteArray()
	filled.resize(bw * bh)
	for by: int in range(bh):
		for bx: int in range(bw):
			var hit: int = 0
			for oy: int in range(0, BLOCK, 2):
				for ox: int in range(0, BLOCK, 2):
					if image.get_pixel(bx * BLOCK + ox, by * BLOCK + oy).a > 0.05:
						hit = 1
			filled[by * bw + bx] = hit
	var comp: PackedInt32Array = PackedInt32Array()
	comp.resize(bw * bh)
	comp.fill(-1)
	var areas: Array[int] = []
	var sum_x: Array[float] = []
	for start: int in range(bw * bh):
		if filled[start] == 0 or comp[start] >= 0:
			continue
		var id: int = areas.size()
		areas.append(0)
		sum_x.append(0.0)
		var stack: PackedInt32Array = PackedInt32Array([start])
		comp[start] = id
		while not stack.is_empty():
			var at: int = stack[stack.size() - 1]
			stack.resize(stack.size() - 1)
			areas[id] += 1
			sum_x[id] += float(at % bw)
			var ax: int = at % bw
			var ay: int = at / bw
			for dy: int in range(-1, 2):
				for dx: int in range(-1, 2):
					var nx: int = ax + dx
					var ny: int = ay + dy
					if nx < 0 or ny < 0 or nx >= bw or ny >= bh:
						continue
					var n: int = ny * bw + nx
					if filled[n] == 1 and comp[n] < 0:
						comp[n] = id
						stack.append(n)
	var biggest: int = 1
	for area: int in areas:
		biggest = maxi(biggest, area)
	var large: Array[int] = []
	for id: int in range(areas.size()):
		if areas[id] * 5 >= biggest:
			large.append(id)
	if large.size() != 4:
		_report.append("  NOTE %s: found %d separate figures in the strip, cut it into four equal parts instead" % [label, large.size()])
		return _cut_by_columns(image)
	large.sort_custom(func(a: int, b: int) -> bool: return sum_x[a] / float(areas[a]) < sum_x[b] / float(areas[b]))
	# Owner of every component: itself when large, else the large figure whose centre is nearest.
	var owner: Array[int] = []
	for id: int in range(areas.size()):
		var best: int = 0
		var best_distance: float = 1e20
		for index: int in range(4):
			var d: float = absf(sum_x[id] / float(areas[id]) - sum_x[large[index]] / float(areas[large[index]]))
			if d < best_distance:
				best_distance = d
				best = index
		owner.append(large.find(id) if large.has(id) else best)
	var figures: Array = []
	for index: int in range(4):
		var masked: Image = Image.create_empty(width, height, false, Image.FORMAT_RGBA8)
		for by: int in range(bh):
			for bx: int in range(bw):
				var c: int = comp[by * bw + bx]
				if c < 0 or owner[c] != index:
					continue
				for oy: int in range(BLOCK):
					for ox: int in range(BLOCK):
						masked.set_pixel(bx * BLOCK + ox, by * BLOCK + oy, image.get_pixel(bx * BLOCK + ox, by * BLOCK + oy))
		figures.append(_figure(masked, Rect2i(0, 0, width, height)))
	return figures


func _do_character(character: String) -> void:
	# Gather the figures: key "DIR_KIND" -> figure.
	var figures: Dictionary = {}
	var idle_heights: Array[float] = []
	var walk_dirs: Array[String] = []
	var dirs: Array[String] = []
	for dir_name: String in DIRS:
		var idle: Image = _load("SPR-%s-%s_IDLE" % [character, dir_name])
		if idle == null:
			continue
		dirs.append(dir_name)
		var fig: Dictionary = _figure(idle, Rect2i(0, 0, idle.get_width(), idle.get_height()))
		figures[dir_name + "_IDLE"] = fig
		idle_heights.append(float(fig["height"]))
		var walk: Image = _load("SPR-%s-%s_WALK" % [character, dir_name])
		if walk != null:
			walk_dirs.append(dir_name)
			var parts: Array = _slice_strip(walk, "%s %s walk" % [character, dir_name])
			for i: int in range(parts.size()):
				figures["%s_WALK%d" % [dir_name, i + 1]] = parts[i]
	var talk: Image = _load("SPR-%s-FRONT_TALK" % character)
	if talk != null:
		figures["FRONT_TALK"] = _figure(talk, Rect2i(0, 0, talk.get_width(), talk.get_height()))
	if dirs.is_empty():
		_report.append("%s: no idle sprites found" % character)
		return
	idle_heights.sort()
	var reference: float = idle_heights[idle_heights.size() / 2]
	var base_scale: float = float(FIG_H) / reference
	# Scale per frame: idles and TALK share the character scale; the four walk frames of a direction share one scale that makes their mean height equal that direction's idle.
	var scales: Dictionary = {}
	for key: String in figures.keys():
		scales[key] = base_scale
	for dir_name: String in walk_dirs:
		var mean: float = 0.0
		for i: int in range(4):
			mean += float((figures["%s_WALK%d" % [dir_name, i + 1]] as Dictionary)["height"])
		mean /= 4.0
		var idle_h: float = float((figures[dir_name + "_IDLE"] as Dictionary)["height"])
		var walk_scale: float = clampf(base_scale * idle_h / mean, base_scale * 0.5, base_scale * 2.5)
		for i: int in range(4):
			scales["%s_WALK%d" % [dir_name, i + 1]] = walk_scale
	# Scale every figure (premultiplied, so the soft edge has no dark fringe).
	var scaled: Dictionary = {}
	var half_extent: float = 0.0
	var max_height: int = 0
	for key: String in figures.keys():
		var fig: Dictionary = figures[key] as Dictionary
		if fig.is_empty():
			_report.append("  NOTE %s %s: empty figure" % [character, key])
			continue
		var crop: Image = (fig["image"] as Image).duplicate()
		var factor: float = float(scales[key])
		var new_w: int = maxi(1, roundi(float(crop.get_width()) * factor))
		var new_h: int = maxi(1, roundi(float(crop.get_height()) * factor))
		crop.premultiply_alpha()
		crop.resize(new_w, new_h, Image.INTERPOLATE_LANCZOS)
		var torso: float = float(fig["torso"]) * factor
		scaled[key] = {"image": crop, "torso": torso}
		half_extent = maxf(half_extent, maxf(torso, float(new_w) - torso))
		max_height = maxi(max_height, new_h)
	var canvas_w: int = int(ceil((half_extent * 2.0 + 24.0) / 8.0)) * 8
	var canvas_h: int = int(ceil(float(max_height + TOP_PAD + BOTTOM_PAD) / 8.0)) * 8
	var folder_name: String = character.replace("-", "_")
	var folder: String = "sprites/" + folder_name
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT + folder))
	var names: Array[String] = []
	var sheet_items: Array[Image] = []
	for key: String in scaled.keys():
		var entry: Dictionary = scaled[key] as Dictionary
		var crop: Image = entry["image"] as Image
		var canvas: Image = Image.create_empty(canvas_w, canvas_h, false, Image.FORMAT_RGBA8)
		var x: int = roundi(float(canvas_w) * 0.5 - float(entry["torso"]))
		var y: int = canvas_h - BOTTOM_PAD - crop.get_height()
		canvas.blit_rect(crop, Rect2i(Vector2i.ZERO, crop.get_size()), Vector2i(x, y))
		_unpremultiply(canvas)
		_save(canvas, "%s/%s.png" % [folder, key])
		names.append(key)
		sheet_items.append(canvas)
	names.sort()
	var rel: float = float(_rel_height.get(character, 1.0))
	_manifest[folder_name] = {
		"canvas": [canvas_w, canvas_h], "fig_h": FIG_H, "bottom_pad": BOTTOM_PAD, "rel_height": rel, "frames": names,
		"dirs": dirs, "walk_dirs": walk_dirs, "has_talk": figures.has("FRONT_TALK"),
	}
	_report.append("%s: canvas %dx%d, %d frames, relative height %.2f, source figure height (median idle) %d px -> %d px; walk dirs: %s" % [
		character, canvas_w, canvas_h, names.size(), rel, int(reference), FIG_H, ", ".join(walk_dirs) if not walk_dirs.is_empty() else "none"])
	_contact_sheet(folder_name, names, canvas_w, canvas_h)


func _unpremultiply(image: Image) -> void:
	var data: PackedByteArray = image.get_data()
	var count: int = data.size()
	var i: int = 0
	while i < count:
		var a: int = data[i + 3]
		if a > 0 and a < 255:
			data[i] = mini(255, data[i] * 255 / a)
			data[i + 1] = mini(255, data[i + 1] * 255 / a)
			data[i + 2] = mini(255, data[i + 2] * 255 / a)
		i += 4
	image.set_data(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8, data)


## A review sheet: every frame of the character on mid-grey with the baseline and the centre line, reloaded from the files that were written.
func _contact_sheet(character: String, names: Array[String], canvas_w: int, canvas_h: int) -> void:
	var cell_scale: float = 0.34
	var cw: int = int(float(canvas_w) * cell_scale)
	var ch: int = int(float(canvas_h) * cell_scale)
	var columns: int = 5
	var rows: int = int(ceil(float(names.size()) / float(columns)))
	var sheet: Image = Image.create_empty(cw * columns, ch * rows, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.45, 0.47, 0.5, 1.0))
	for index: int in range(names.size()):
		var frame: Image = Image.load_from_file(ProjectSettings.globalize_path(OUT + "sprites/%s/%s.png" % [character, names[index]]))
		frame.resize(cw, ch, Image.INTERPOLATE_BILINEAR)
		var origin: Vector2i = Vector2i((index % columns) * cw, (index / columns) * ch)
		sheet.blend_rect(frame, Rect2i(0, 0, cw, ch), origin)
		var base_y: int = origin.y + ch - int(float(BOTTOM_PAD) * cell_scale)
		for x: int in range(cw):
			sheet.set_pixel(origin.x + x, base_y, Color(1, 0.2, 0.2, 1))
		for y: int in range(ch):
			sheet.set_pixel(origin.x + cw / 2, origin.y + y, Color(0.2, 1, 0.3, 0.6))
	sheet.save_png(ProjectSettings.globalize_path(SHEETS + character + ".png"))
	_report.append("  frames: " + ", ".join(names))


# ---- Sky, backdrops, textures, foliage -------------------------------------------------------------------------------------------


## Crops to the content box (keeping `side_pad`), optionally limits the width, and saves.
func _trimmed(id: String, rel_path: String, max_width: int, keep_bottom: bool = false) -> Dictionary:
	var image: Image = _load(id)
	if image == null:
		return {}
	if id.begins_with("BD-"):
		_clean_alpha(image, 0.12)
	var box: Rect2i = _bbox(image, Rect2i(0, 0, image.get_width(), image.get_height()))
	if box.size.x == 0:
		_report.append("  NOTE %s is empty" % id)
		return {}
	if keep_bottom:
		box = Rect2i(0, box.position.y, image.get_width(), image.get_height() - box.position.y)
	else:
		var pad: int = 6
		box = box.grow(pad).intersection(Rect2i(0, 0, image.get_width(), image.get_height()))
	var crop: Image = image.get_region(box)
	if crop.get_width() > max_width:
		var h: int = int(round(float(crop.get_height()) * float(max_width) / float(crop.get_width())))
		crop.premultiply_alpha()
		crop.resize(max_width, h, Image.INTERPOLATE_LANCZOS)
		_unpremultiply(crop)
	_save(crop, rel_path)
	return {"w": crop.get_width(), "h": crop.get_height()}


func _do_sky() -> void:
	var sizes: PackedStringArray = []
	var sun: Dictionary = _trimmed("SKY-SUN", "sky/sun.png", 512)
	sizes.append("sun %s" % str(sun))
	for i: int in range(1, 7):
		var entry: Dictionary = _trimmed("SKY-CLOUD-%02d" % i, "sky/cloud_%02d.png" % i, 768)
		sizes.append("cloud_%02d %dx%d" % [i, int(entry.get("w", 0)), int(entry.get("h", 0))])
	_report.append("Sky: " + "; ".join(sizes))


func _do_backdrops() -> void:
	var lines: PackedStringArray = []
	for pair: Array in [["BD-FAR-MOUNTAINS", "far_mountains"], ["BD-MID-HILLS", "mid_hills"], ["BD-NEAR-TREELINE", "near_treeline"]]:
		var image: Image = _load(str(pair[0]))
		if image == null:
			continue
		var box: Rect2i = _bbox(image, Rect2i(0, 0, image.get_width(), image.get_height()))
		_clean_alpha(image, 0.12)
		_seam_blend(image, 96)
		# Keep the full width (it tiles), drop the empty rows above the scenery.
		var crop: Image = image.get_region(Rect2i(0, maxi(box.position.y - 4, 0), image.get_width(), image.get_height() - maxi(box.position.y - 4, 0)))
		if crop.get_width() > 1280:
			crop.premultiply_alpha()
			crop.resize(1280, int(round(float(crop.get_height()) * 1280.0 / float(crop.get_width()))), Image.INTERPOLATE_LANCZOS)
			_unpremultiply(crop)
		_save(crop, "backdrop/%s.png" % str(pair[1]))
		lines.append("%s %dx%d (opaque from row %d of %d)" % [str(pair[1]), crop.get_width(), crop.get_height(), box.position.y, image.get_height()])
	for pair: Array in [["BD-LANDMARK-GAINLANDS", "gainlands"], ["BD-LANDMARK-DNA", "dna"], ["BD-LANDMARK-BUFFET", "buffet"], ["BD-LANDMARK-DUMP", "dump"], ["BD-LANDMARK-CAPITAL", "capital"]]:
		var entry: Dictionary = _trimmed(str(pair[0]), "backdrop/landmark_%s.png" % str(pair[1]), 1280, true)
		lines.append("landmark_%s %dx%d" % [str(pair[1]), int(entry.get("w", 0)), int(entry.get("h", 0))])
	_report.append("Backdrops: " + "; ".join(lines))


## Makes a horizontally tiling strip seamless: the last `width` columns fade into the mirrored first columns' continuation (cross-fade of the wrap).
func _seam_blend(image: Image, width: int) -> void:
	var w: int = image.get_width()
	var h: int = image.get_height()
	var left_edge: Image = image.get_region(Rect2i(0, 0, width, h))
	var right_edge: Image = image.get_region(Rect2i(w - width, 0, width, h))
	var difference: float = 0.0
	for y: int in range(0, h, 8):
		var l: Color = image.get_pixel(0, y)
		var r: Color = image.get_pixel(w - 1, y)
		difference += absf(l.a - r.a) + (absf(l.r - r.r) + absf(l.g - r.g) + absf(l.b - r.b)) * minf(l.a, r.a)
	_report.append("  seam mismatch (sum over sampled rows): %.2f" % difference)
	# Blend the right edge towards the left edge's content so column w-1 meets column 0: right[x] = lerp(right[x], left[x - (w - width)] ... mirrored fade)
	for x: int in range(width):
		var t: float = float(x) / float(width - 1)
		for y: int in range(h):
			var a: Color = right_edge.get_pixel(x, y)
			var b: Color = left_edge.get_pixel(x, y)
			# at the far right (t = 1) we want the colour that continues into column 0.
			var mixed: Color = a.lerp(b, t * 0.5)
			image.set_pixel(w - width + x, y, mixed)


func _do_simple(id: String, rel_path: String, max_size: int) -> void:
	var image: Image = _load(id)
	if image == null:
		return
	if image.get_width() > max_size:
		image.resize(max_size, max_size, Image.INTERPOLATE_LANCZOS)
	_save(image, rel_path)
	_report.append("%s -> %s %dx%d" % [id, rel_path, image.get_width(), image.get_height()])


## The six plants cropped to their content, fitted into square cells (base on the bottom centre) and packed 3 x 2 into one atlas.
func _do_foliage() -> void:
	var names: Array[String] = ["FOL-GRASS-01", "FOL-GRASS-02", "FOL-FLOWERS-01", "FOL-FLOWERS-02", "FOL-BUSH-01", "FOL-FERN-01"]
	var atlas: Image = Image.create_empty(FOLIAGE_CELL * 3, FOLIAGE_CELL * 2, false, Image.FORMAT_RGBA8)
	var lines: PackedStringArray = []
	for index: int in range(names.size()):
		var image: Image = _load(names[index])
		if image == null:
			continue
		var box: Rect2i = _bbox(image, Rect2i(0, 0, image.get_width(), image.get_height()))
		var crop: Image = image.get_region(box)
		var fit: float = minf(float(FOLIAGE_CELL - 8) / float(crop.get_width()), float(FOLIAGE_CELL - 8) / float(crop.get_height()))
		crop.premultiply_alpha()
		crop.resize(maxi(1, int(float(crop.get_width()) * fit)), maxi(1, int(float(crop.get_height()) * fit)), Image.INTERPOLATE_LANCZOS)
		var cell: Vector2i = Vector2i(index % 3, index / 3) * FOLIAGE_CELL
		var at: Vector2i = cell + Vector2i((FOLIAGE_CELL - crop.get_width()) / 2, FOLIAGE_CELL - 4 - crop.get_height())
		atlas.blit_rect(crop, Rect2i(Vector2i.ZERO, crop.get_size()), at)
		lines.append("%s: %dx%d in cell %d (aspect w/h %.2f)" % [names[index], crop.get_width(), crop.get_height(), index, float(crop.get_width()) / float(crop.get_height())])
	_unpremultiply(atlas)
	_save(atlas, "foliage/atlas.png")
	_report.append("Foliage atlas 3x2 of %d px cells: %s" % [FOLIAGE_CELL, "; ".join(lines)])


## Fallback for touching figures: cut at the emptiest column near each quarter boundary.
func _cut_by_columns(image: Image) -> Array:
	var width: int = image.get_width()
	var height: int = image.get_height()
	var cuts: Array[int] = [0]
	for k: int in range(1, 4):
		var centre: int = k * width / 4
		var best_x: int = centre
		var best_count: int = 1 << 30
		for x: int in range(centre - 90, centre + 90):
			var count: int = 0
			for y: int in range(0, height, 2):
				if image.get_pixel(x, y).a > 0.5:
					count += 1
			if count < best_count:
				best_count = count
				best_x = x
		cuts.append(best_x)
	cuts.append(width)
	var parts: Array = []
	for i: int in range(4):
		parts.append(_figure(image, Rect2i(cuts[i], 0, cuts[i + 1] - cuts[i], height)))
	return parts


## DEC-SHOREFOAM is a diagonal strip of wet sand, shallow water and a foam line. It is turned so the foam line runs along the x axis (land / sand below, open water above)
## and cropped to its content, so one card can be laid along any piece of coastline.
func _do_foam() -> void:
	var image: Image = _load("DEC-SHOREFOAM")
	if image == null:
		return
	var angle: float = deg_to_rad(float(FOAM_TURN_DEGREES))
	var size: int = image.get_width()
	var out: Image = Image.create_empty(size, size, false, Image.FORMAT_RGBA8)
	var centre: Vector2 = Vector2(size, size) * 0.5
	image.premultiply_alpha()
	var c: float = cos(angle)
	var s: float = sin(angle)
	for y: int in range(size):
		for x: int in range(size):
			var d: Vector2 = Vector2(float(x), float(y)) - centre
			var src: Vector2 = Vector2(d.x * c - d.y * s, d.x * s + d.y * c) + centre
			if src.x < 0.0 or src.y < 0.0 or src.x >= float(size - 1) or src.y >= float(size - 1):
				continue
			var x0: int = int(src.x)
			var y0: int = int(src.y)
			var fx: float = src.x - float(x0)
			var fy: float = src.y - float(y0)
			var top: Color = image.get_pixel(x0, y0).lerp(image.get_pixel(x0 + 1, y0), fx)
			var bottom: Color = image.get_pixel(x0, y0 + 1).lerp(image.get_pixel(x0 + 1, y0 + 1), fx)
			out.set_pixel(x, y, top.lerp(bottom, fy))
	_unpremultiply(out)
	var box: Rect2i = _bbox(out, Rect2i(0, 0, size, size))
	var crop: Image = out.get_region(box.grow(6).intersection(Rect2i(0, 0, size, size)))
	_save(crop, "dec/shorefoam.png")
	_report.append("DEC-SHOREFOAM -> dec/shorefoam.png %dx%d (turned %d degrees)" % [crop.get_width(), crop.get_height(), FOAM_TURN_DEGREES])


## Painted mist: alpha below `floor_alpha` becomes fully transparent and the rest is stretched back to 0..1, so a backdrop's sky area is truly empty.
func _clean_alpha(image: Image, floor_alpha: float) -> void:
	var data: PackedByteArray = image.get_data()
	var cut: int = int(floor_alpha * 255.0)
	var i: int = 0
	var count: int = data.size()
	while i < count:
		var a: int = data[i + 3]
		if a <= cut:
			data[i + 3] = 0
		elif a < 255:
			data[i + 3] = mini(255, (a - cut) * 255 / (255 - cut))
		i += 4
	image.set_data(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8, data)


# ---- Cosmetics (hats and cloak sets) ---------------------------------------------------------------------------------------------


## `--cosmetics` mode. Cloaks: SPR-PLAYER-CLOAK-<NAME>-<DIR>_{IDLE,WALK} go through the same slicer as every character and become the character PLAYER_CLOAK_<NAME>.
## Hats: COS-HAT-<NAME>-<DIR> are trimmed to their content and saved as assets/art/cosmetics/hats/<NAME>/<DIR>.png (bottom-centre of the image = where the hat meets the head).
func _run_cosmetics() -> void:
	_src = COS_SRC
	# A dry run (Apparel Part 2: proving hat sheets before they are approved): --cos_inbox=res://... --hat_out=res://... reads and writes elsewhere, no icons.
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--cos_inbox="):
			_src = arg.get_slice("=", 1)
		elif arg.begins_with("--hat_out="):
			_hat_out = arg.get_slice("=", 1)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT + "sprites"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHEETS))
	var cloaks: Array[String] = []
	var hats: Array[String] = []
	for file_name: String in DirAccess.get_files_at(_src):
		if file_name.get_extension() != "png":
			continue
		var id: String = file_name.get_basename()
		if id.begins_with("SPR-PLAYER-CLOAK-"):
			var cloak_name: String = id.trim_prefix("SPR-PLAYER-CLOAK-").get_slice("-", 0)
			if not cloaks.has(cloak_name):
				cloaks.append(cloak_name)
		elif id.begins_with("COS-HAT-"):
			var hat_name: String = id.trim_prefix("COS-HAT-").get_slice("-", 0)
			if not hats.has(hat_name):
				hats.append(hat_name)
	cloaks.sort()
	hats.sort()
	var existing: Dictionary = {}
	var manifest_file: FileAccess = FileAccess.open(OUT + COS_MANIFEST, FileAccess.READ)
	if manifest_file != null:
		var parsed: Variant = JSON.parse_string(manifest_file.get_as_text())
		if parsed is Dictionary:
			existing = parsed as Dictionary
		manifest_file.close()
	_manifest = existing
	for cloak_name: String in cloaks:
		_do_character("PLAYER-CLOAK-" + cloak_name)
		_make_icon(OUT + "sprites/PLAYER_CLOAK_%s/FRONT_IDLE.png" % cloak_name, "CLOAK_" + cloak_name)
	var out: FileAccess = FileAccess.open(OUT + COS_MANIFEST, FileAccess.WRITE)
	out.store_string(JSON.stringify(_manifest, "\t"))
	out.close()
	for hat_name: String in hats:
		_do_hat(hat_name)
	_report.append("Cosmetics inbox: %d cloak set(s) %s, %d hat(s) %s" % [cloaks.size(), str(cloaks), hats.size(), str(hats)])
	print("\n".join(_report))


## A hat comes as five files COS-HAT-<NAME>-<DIR> or (Apparel Part 2) as one sheet COS-HAT-<NAME>-SHEET (HatSheet.split; a single view file wins over the sheet's).
## The sheet's views also give the hat's fit per direction (one scale across the sheet, HatSheet.fit) into fit_auto.json; fit.json is the hand-tuned layer on top.
func _do_hat(hat_name: String) -> void:
	var found: Array[String] = []
	var missing: Array[String] = []
	var sheet: Image = _load("COS-HAT-%s-SHEET" % hat_name)
	var views: Dictionary = HatSheet.split(sheet) if sheet != null else {}
	for dir_name: String in DIRS:
		var image: Image = _load("COS-HAT-%s-%s" % [hat_name, dir_name])
		if image == null and views.has(dir_name):
			image = (views[dir_name] as Image).duplicate() as Image
		elif image != null:
			views[dir_name] = image
		if image == null:
			missing.append(dir_name)
			continue
		_clean_alpha(image, 0.04)
		var box: Rect2i = _bbox(image, Rect2i(0, 0, image.get_width(), image.get_height()))
		if box.size.x == 0:
			missing.append(dir_name)
			continue
		var crop: Image = image.get_region(box.grow(2).intersection(Rect2i(0, 0, image.get_width(), image.get_height())))
		if crop.get_width() > HAT_MAX_WIDTH:
			var h: int = int(round(float(crop.get_height()) * float(HAT_MAX_WIDTH) / float(crop.get_width())))
			crop.premultiply_alpha()
			crop.resize(HAT_MAX_WIDTH, h, Image.INTERPOLATE_LANCZOS)
			_unpremultiply(crop)
		var folder: String = _hat_out + hat_name + "/"
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		crop.save_png(ProjectSettings.globalize_path(folder + dir_name + ".png"))
		found.append(dir_name)
		if dir_name == "FRONT" and _hat_out == HAT_OUT:
			_make_icon(folder + "FRONT.png", "HAT_" + hat_name)
	_write_hat_fit(hat_name, views)
	_report.append("COS-HAT-%s: directions %s%s%s" % [hat_name, ", ".join(found), " (from the sheet)" if sheet != null else "", ("   MISSING: " + ", ".join(missing)) if not missing.is_empty() else ""])


## fit_auto.json: this hat's HatSheet.fit from its views and the default hero's head width per direction (the IDLE frames).
func _write_hat_fit(hat_name: String, views: Dictionary) -> void:
	var heads: Dictionary = {}
	var manifest_file: FileAccess = FileAccess.open(OUT + "sprites/manifest.json", FileAccess.READ)
	if manifest_file != null:
		var parsed: Variant = JSON.parse_string(manifest_file.get_as_text())
		manifest_file.close()
		var player: Dictionary = (parsed as Dictionary).get("PLAYER", {}) as Dictionary if parsed is Dictionary else {}
		var head: Dictionary = player.get("head", {}) as Dictionary
		for dir_name: String in DIRS:
			var anchor: Array = head.get(dir_name + "_IDLE", []) as Array
			if anchor.size() >= 3:
				heads[dir_name] = float(anchor[2])
	var path: String = _hat_out + "fit_auto.json"
	var all: Dictionary = {}
	var existing: FileAccess = FileAccess.open(path, FileAccess.READ)
	if existing != null:
		var parsed_fit: Variant = JSON.parse_string(existing.get_as_text())
		existing.close()
		if parsed_fit is Dictionary:
			all = parsed_fit as Dictionary
	all["_about"] = "Written by tools/import_cosmetics.sh from the hat sheets (HatSheet.fit): first-guess width/sink per hat and the per-direction width ratios. Hand tuning goes in fit.json, which wins."
	all[hat_name] = HatSheet.fit(hat_name, views, heads)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_hat_out))
	var out: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	out.store_string(JSON.stringify(all, "\t"))
	out.close()


# ---- NPC sprite sets (`--npcs`, tools/import_npc_sprites.sh) ---------------------------------------------------------------------


var _npc_mode: bool = false
var _bg_removed: Array[String] = []


## Every `SPR-<KEY>-*` set in the NPC inbox goes through the same cut-out / foot-baseline / scale pipeline as the hero. Relative heights come from data/source/npc_sprite_batch.csv
## (column G) and the NPC list (column O). Writes into the existing manifest (the hero and the baker are kept) and docs/art/npc_sprite_import_report.md.
func _run_npcs() -> void:
	_src = NPC_SRC
	_npc_mode = true
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT + "sprites"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHEETS))
	var existing: FileAccess = FileAccess.open(OUT + "sprites/manifest.json", FileAccess.READ)
	if existing != null:
		var parsed: Variant = JSON.parse_string(existing.get_as_text())
		if parsed is Dictionary:
			_manifest = parsed as Dictionary
		existing.close()
	var expected: Array[String] = _npc_read_heights()
	var keys: Array[String] = []
	var present: Dictionary = {}
	for file_name: String in DirAccess.get_files_at(ProjectSettings.globalize_path(_src)):
		if file_name.get_extension() != "png":
			continue
		present[file_name.get_basename()] = true
		var id: String = file_name.get_basename()
		if id.begins_with("SPR-") and id.ends_with("-FRONT_IDLE"):
			var key: String = id.trim_prefix("SPR-").trim_suffix("-FRONT_IDLE")
			if key.contains("CLOAK") or NPC_KEEP.has(key):
				continue
			keys.append(key)
	keys.sort()
	for key: String in keys:
		_do_character(key)
	var out: FileAccess = FileAccess.open(OUT + "sprites/manifest.json", FileAccess.WRITE)
	out.store_string(JSON.stringify(_manifest, "\t"))
	out.close()
	var missing: Array[String] = []
	for id: String in expected:
		if not present.has(id):
			missing.append(id)
	var listed: Dictionary = {}
	for id: String in expected:
		listed[id] = true
	var unmatched: Array[String] = []
	for id: Variant in present.keys():
		var name: String = str(id)
		if not listed.has(name) and not name.ends_with("-REF") and not NPC_KEEP.any(func(k: String) -> bool: return name.begins_with("SPR-%s-" % k)):
			unmatched.append(name)
	missing.sort()
	unmatched.sort()
	var lines: PackedStringArray = []
	lines.append("# NPC sprite import report\n")
	lines.append("Source: the copies in `_art_inbox/npc_sprites/` (from the Drive `Approved_Sprites`, copy-only). Generated by `tools/import_npc_sprites.sh`.\n")
	lines.append("- Characters imported (%d): %s" % [keys.size(), ", ".join(keys)])
	lines.append("- Background removed from: %s" % (", ".join(_bg_removed) if not _bg_removed.is_empty() else "none (all frames were already transparent)"))
	lines.append("- Listed in the batch sheet but MISSING (%d): %s" % [missing.size(), ", ".join(missing) if not missing.is_empty() else "none"])
	lines.append("- Files that match no batch row (%d): %s" % [unmatched.size(), ", ".join(unmatched) if not unmatched.is_empty() else "none"])
	lines.append("\n## Per character\n")
	lines.append_array(_report)
	var file: FileAccess = FileAccess.open(NPC_REPORT, FileAccess.WRITE)
	file.store_string("\n".join(lines) + "\n")
	file.close()
	print("\n".join(lines))


## Reads the batch sheet: fills `_rel_height` (key -> height) and returns every expected SPR file ID (patterns like {A,B} expanded).
func _npc_read_heights() -> Array[String]:
	var expected: Array[String] = []
	var batch: FileAccess = FileAccess.open(NPC_BATCH_CSV, FileAccess.READ)
	while batch != null and not batch.eof_reached():
		var row: PackedStringArray = batch.get_csv_line()
		if row.size() < 7 or row[0].strip_edges() == "" or row[0].strip_edges() == "Batch ID":
			continue
		var source: String = row[1].strip_edges()
		if (source.begins_with("NPC-") or source.begins_with("V-")) and row[6].strip_edges().is_valid_float():
			_rel_height[source.substr(source.find("-") + 1)] = float(row[6])
		for token: String in _npc_expand(row[5]):
			if token.begins_with("SPR-"):
				expected.append(token)
	var list: FileAccess = FileAccess.open(NPC_LIST_CSV, FileAccess.READ)
	while list != null and not list.eof_reached():
		var row: PackedStringArray = list.get_csv_line()
		if row.size() < 15:
			continue
		var id: String = row[0].strip_edges()
		if (id.begins_with("NPC-") or id.begins_with("V-")) and row[14].strip_edges().is_valid_float():
			var key: String = id.substr(id.find("-") + 1)
			if not _rel_height.has(key):
				_rel_height[key] = float(row[14])
	return expected


## "SPR-X-{A,B}_IDLE, SPR-X-FRONT_TALK" -> the individual file IDs ("(if regenerated)" notes dropped).
func _npc_expand(cell: String) -> Array[String]:
	var result: Array[String] = []
	var depth: int = 0
	var token: String = ""
	var tokens: Array[String] = []
	for c: String in cell:
		if c == "{":
			depth += 1
		elif c == "}":
			depth -= 1
		if c == "," and depth == 0:
			tokens.append(token.strip_edges())
			token = ""
		else:
			token += c
	tokens.append(token.strip_edges())
	for t: String in tokens:
		var open: int = t.find("{")
		if open < 0:
			result.append(t.get_slice(" ", 0))
			continue
		var close: int = t.find("}")
		for option: String in t.substr(open + 1, close - open - 1).split(","):
			result.append(t.substr(0, open) + option.strip_edges() + t.substr(close + 1))
	return result


## A frame saved on a plain opaque background (no alpha): flood from the border through pixels close to the corner colour and clear them.
func _remove_flat_background(image: Image, label: String) -> void:
	var w: int = image.get_width()
	var h: int = image.get_height()
	var corners: Array[Color] = [image.get_pixel(0, 0), image.get_pixel(w - 1, 0), image.get_pixel(0, h - 1), image.get_pixel(w - 1, h - 1)]
	var key: Color = corners[0]
	for c: Color in corners:
		if c.a < 0.95 or absf(c.r - key.r) + absf(c.g - key.g) + absf(c.b - key.b) > 0.16:
			return
	const TOLERANCE: float = 0.14
	var seen: PackedByteArray = PackedByteArray()
	seen.resize(w * h)
	var stack: PackedInt32Array = PackedInt32Array()
	for x: int in range(w):
		stack.append(x)
		stack.append((h - 1) * w + x)
	for y: int in range(h):
		stack.append(y * w)
		stack.append(y * w + w - 1)
	while not stack.is_empty():
		var at: int = stack[stack.size() - 1]
		stack.resize(stack.size() - 1)
		if seen[at] == 1:
			continue
		var px: int = at % w
		var py: int = at / w
		var c: Color = image.get_pixel(px, py)
		if c.a > 0.02 and absf(c.r - key.r) + absf(c.g - key.g) + absf(c.b - key.b) > TOLERANCE * 3.0:
			continue
		seen[at] = 1
		image.set_pixel(px, py, Color(c.r, c.g, c.b, 0.0))
		if px > 0:
			stack.append(at - 1)
		if px < w - 1:
			stack.append(at + 1)
		if py > 0:
			stack.append(at - w)
		if py < h - 1:
			stack.append(at + w)
	_bg_removed.append(label)


const ICON_OUT: String = "res://assets/art/cosmetics/icons/"
const ICON_SIZE: int = 128


## The shop / wardrobe icon: the picture (a hat's FRONT view, a cloak set's FRONT_IDLE) trimmed to its content, centred on a transparent square and scaled to ICON_SIZE.
func _make_icon(source_path: String, icon_name: String) -> void:
	var path: String = ProjectSettings.globalize_path(source_path)
	if not FileAccess.file_exists(path):
		return
	var image: Image = Image.load_from_file(path)
	if image == null:
		return
	image.convert(Image.FORMAT_RGBA8)
	var box: Rect2i = _bbox(image, Rect2i(0, 0, image.get_width(), image.get_height()))
	if box.size.x == 0:
		return
	var crop: Image = image.get_region(box)
	var side: int = maxi(crop.get_width(), crop.get_height()) + 8
	var square: Image = Image.create_empty(side, side, false, Image.FORMAT_RGBA8)
	square.blit_rect(crop, Rect2i(Vector2i.ZERO, crop.get_size()), Vector2i((side - crop.get_width()) / 2, (side - crop.get_height()) / 2))
	square.premultiply_alpha()
	square.resize(ICON_SIZE, ICON_SIZE, Image.INTERPOLATE_LANCZOS)
	_unpremultiply(square)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ICON_OUT))
	square.save_png(ProjectSettings.globalize_path(ICON_OUT + icon_name + ".png"))
	_report.append("icon %s" % icon_name)
