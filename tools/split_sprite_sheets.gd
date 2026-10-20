extends SceneTree
## NPC sprite SHEET splitter (art import Oct 20, Part 2). Some NPC sprites arrive as ONE sheet `SPR-<KEY>.png` with four frames left to right:
## FRONT_IDLE, FRONT_TALK, SIDE_IDLE, BACK_IDLE. This cuts each sheet in the NPC inbox into the per-frame files the NPC importer reads
## (`SPR-<KEY>-FRONT_IDLE.png` etc., next to the sheet in _art_inbox/npc_sprites/), each on a transparent background at the sheet's full height, so the
## four frames keep one baseline and one scale (tools/world_test_import.gd --npcs then cuts, aligns and scales them like any other set).
## The sheet itself is never changed. Writes docs/art/npc_sheet_split_report.md. Run by tools/import_npc_sprites.sh before the importer.
## Run: Godot --headless --path . -s res://tools/split_sprite_sheets.gd

const INBOX: String = "res://_art_inbox/npc_sprites/"
const REPORT: String = "res://docs/art/npc_sheet_split_report.md"
## Frames written by this tool (one name per line). A frame file NOT listed here came from the Drive and is never overwritten.
const WRITTEN_LIST: String = "res://_art_inbox/npc_sprites/.split_frames.txt"
const FRAMES: Array[String] = ["FRONT_IDLE", "FRONT_TALK", "SIDE_IDLE", "BACK_IDLE"]
## The sheets draw the side view facing RIGHT; the game's SIDE frames face LEFT (WorldSprite flips them for the right). Keys listed here face left already.
const SIDE_ALREADY_LEFT: Array[String] = []
const BLOCK: int = 4
const PAD: int = 12
## A sheet still more than this share opaque after removing its background did not lose it (a gradient or a scene behind the figures).
const MAX_COVERAGE: float = 0.62

var _lines: PackedStringArray = []
var _written: Dictionary = {}


func _initialize() -> void:
	var dir: String = ProjectSettings.globalize_path(INBOX)
	var previous: FileAccess = FileAccess.open(WRITTEN_LIST, FileAccess.READ)
	if previous != null:
		for line: String in previous.get_as_text().split("\n", false):
			_written[line.strip_edges()] = true
		previous.close()
	var sheet_re: RegEx = RegEx.create_from_string("^SPR-[A-Z0-9_]+$")
	var done: Array[String] = []
	var failed: Array[String] = []
	var names: PackedStringArray = DirAccess.get_files_at(dir)
	names.sort()
	for file_name: String in names:
		if file_name.get_extension().to_lower() != "png" or sheet_re.search(file_name.get_basename()) == null:
			continue
		var key: String = file_name.get_basename().trim_prefix("SPR-")
		var problem: String = _split(dir, key)
		if problem.is_empty():
			done.append(key)
		else:
			failed.append(key)
			_lines.append("- **%s: NOT SPLIT** - %s (needs a redo)" % [key, problem])
	var out: FileAccess = FileAccess.open(WRITTEN_LIST, FileAccess.WRITE)
	out.store_string("\n".join(PackedStringArray(_written.keys())) + "\n")
	out.close()
	var head: PackedStringArray = ["# NPC sprite sheet split report\n",
		"Sheets `SPR-<KEY>.png` (four frames left to right: %s) in `_art_inbox/npc_sprites/`, split by `tools/split_sprite_sheets.gd`." % ", ".join(FRAMES),
		"SIDE_IDLE is mirrored to face left (the game's convention) unless the key is in `SIDE_ALREADY_LEFT`.\n",
		"- Split (%d): %s" % [done.size(), ", ".join(done) if not done.is_empty() else "none"],
		"- Not split (%d): %s\n" % [failed.size(), ", ".join(failed) if not failed.is_empty() else "none"],
		"## Per sheet\n"]
	head.append_array(_lines)
	var report: FileAccess = FileAccess.open(REPORT, FileAccess.WRITE)
	report.store_string("\n".join(head) + "\n")
	report.close()
	print("\n".join(head))
	quit()


## Splits one sheet; returns "" or the reason it could not be split cleanly.
func _split(dir: String, key: String) -> String:
	var image: Image = Image.load_from_file(dir.path_join("SPR-%s.png" % key))
	if image == null:
		return "the file does not load"
	image.convert(Image.FORMAT_RGBA8)
	var w: int = image.get_width()
	var h: int = image.get_height()
	var removed: String = ""
	if image.get_pixel(0, 0).a > 0.95 and image.get_pixel(w - 1, h - 1).a > 0.95:
		if not _remove_flat_background(image):
			return "opaque background that is not one flat colour (a gradient / glow behind the figures), so the figures cannot be cut out cleanly"
		removed = ", flat background removed"
	var coverage: float = _coverage(image)
	if not removed.is_empty() and coverage > MAX_COVERAGE:
		return "background did not come off (%d %% of the sheet still opaque)" % roundi(coverage * 100.0)
	# Connected components of the block-downsampled alpha.
	var bw: int = w / BLOCK
	var bh: int = h / BLOCK
	var comp: PackedInt32Array = PackedInt32Array()
	comp.resize(bw * bh)
	comp.fill(-1)
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
	var areas: Array[int] = []
	var sum_x: Array[float] = []
	var x0: Array[int] = []
	var x1: Array[int] = []
	for start: int in range(bw * bh):
		if filled[start] == 0 or comp[start] >= 0:
			continue
		var id: int = areas.size()
		areas.append(0)
		sum_x.append(0.0)
		x0.append(bw)
		x1.append(-1)
		var stack: PackedInt32Array = PackedInt32Array([start])
		comp[start] = id
		while not stack.is_empty():
			var at: int = stack[stack.size() - 1]
			stack.resize(stack.size() - 1)
			var ax: int = at % bw
			var ay: int = at / bw
			areas[id] += 1
			sum_x[id] += float(ax)
			x0[id] = mini(x0[id], ax)
			x1[id] = maxi(x1[id], ax)
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
	if areas.size() < 4:
		return _split_by_columns(image, key, dir, "only %d separate shape(s) on the sheet (frames touch)" % areas.size())
	# The four largest pieces are the figures; each must sit in its own quarter of the sheet.
	var order: Array = range(areas.size())
	order.sort_custom(func(a: int, b: int) -> bool: return areas[a] > areas[b])
	var seeds: Array = order.slice(0, 4)
	seeds.sort_custom(func(a: int, b: int) -> bool: return sum_x[a] / float(areas[a]) < sum_x[b] / float(areas[b]))
	for index: int in range(4):
		var centre: float = sum_x[seeds[index]] / float(areas[seeds[index]])
		if int(centre * 4.0 / float(bw)) != index:
			return _split_by_columns(image, key, dir, "the four largest shapes are not one per quarter of the sheet")
	# Every other piece joins the figure whose box is nearest in x (a staff, a tail tip, a prop beside the figure); tiny far specks are dropped.
	var owner: PackedInt32Array = PackedInt32Array()
	owner.resize(areas.size())
	var dropped: int = 0
	var joined: int = 0
	for id: int in range(areas.size()):
		var seed_index: int = seeds.find(id)
		if seed_index >= 0:
			owner[id] = seed_index
			continue
		var best: int = 0
		var best_gap: float = 1e20
		for index: int in range(4):
			var s: int = seeds[index]
			var gap: float = float(maxi(0, maxi(x0[s] - x1[id], x0[id] - x1[s])))
			var tie: float = absf(sum_x[id] / float(areas[id]) - sum_x[s] / float(areas[s])) * 0.001
			if gap + tie < best_gap:
				best_gap = gap + tie
				best = index
		if areas[id] < 40 and best_gap > 10.0:
			owner[id] = -1
			dropped += 1
		else:
			owner[id] = best
			if areas[id] >= 40:
				joined += 1
	var mirror_side: bool = not SIDE_ALREADY_LEFT.has(key)
	var widths: PackedStringArray = []
	for index: int in range(4):
		var frame_name: String = "SPR-%s-%s" % [key, FRAMES[index]]
		var target: String = dir.path_join(frame_name + ".png")
		if FileAccess.file_exists(target) and not _written.has(frame_name):
			_lines.append("- %s: kept the Drive's own `%s.png` (not overwritten)" % [key, frame_name])
			continue
		var left: int = bw
		var right: int = -1
		for id: int in range(areas.size()):
			if owner[id] == index:
				left = mini(left, x0[id])
				right = maxi(right, x1[id])
		var crop_x: int = maxi(0, left * BLOCK - PAD)
		var crop_w: int = mini(w, (right + 1) * BLOCK + PAD) - crop_x
		var frame: Image = Image.create_empty(crop_w, h, false, Image.FORMAT_RGBA8)
		for by: int in range(bh):
			for bx: int in range(left, right + 1):
				var c: int = comp[by * bw + bx]
				if c < 0 or owner[c] != index:
					continue
				for oy: int in range(BLOCK):
					for ox: int in range(BLOCK):
						var sx: int = bx * BLOCK + ox
						frame.set_pixel(sx - crop_x, by * BLOCK + oy, image.get_pixel(sx, by * BLOCK + oy))
		if index == 2 and mirror_side:
			frame.flip_x()
		frame.save_png(target)
		_written[frame_name] = true
		widths.append("%s %d px" % [FRAMES[index], crop_w])
	_lines.append("- %s: %dx%d sheet%s, 4 figures; %d extra piece(s) joined to a figure, %d speck(s) dropped; SIDE %s; widths %s" % [
		key, w, h, removed, joined, dropped, "mirrored to face left" if mirror_side else "kept", ", ".join(widths)])
	return ""


## Fallback when the frames touch: near each quarter line (within 12 % of the width) find the top-to-bottom seam (one x per row, moving at most
## 2 px from row to row) that crosses the fewest figure pixels, so a cut can wind around a hand reaching over a neighbour's bag. Accepted when the
## seam crosses less than 1.5 % of the sheet height in figure pixels; each frame keeps the pixels between its two seams.
func _split_by_columns(image: Image, key: String, dir: String, why: String) -> String:
	var w: int = image.get_width()
	var h: int = image.get_height()
	var seams: Array = []
	var worst: int = 0
	for q: int in range(1, 4):
		var lo: int = maxi(1, w * q / 4 - int(float(w) * 0.12))
		var hi: int = mini(w - 1, w * q / 4 + int(float(w) * 0.12))
		var span: int = hi - lo
		var cost: PackedInt32Array = PackedInt32Array()
		cost.resize(span * h)
		var from: PackedInt32Array = PackedInt32Array()
		from.resize(span * h)
		for y: int in range(h):
			for i: int in range(span):
				var here: int = 1 if image.get_pixel(lo + i, y).a > 0.05 else 0
				if y == 0:
					cost[i] = here
					continue
				var best: int = i
				for d: int in range(-2, 3):
					var j: int = i + d
					if j >= 0 and j < span and cost[(y - 1) * span + j] < cost[(y - 1) * span + best]:
						best = j
				cost[y * span + i] = cost[(y - 1) * span + best] + here
				from[y * span + i] = best
		var end: int = 0
		for i: int in range(span):
			if cost[(h - 1) * span + i] < cost[(h - 1) * span + end]:
				end = i
		worst = maxi(worst, cost[(h - 1) * span + end])
		var seam: PackedInt32Array = PackedInt32Array()
		seam.resize(h)
		var at: int = end
		for y: int in range(h - 1, -1, -1):
			seam[y] = lo + at
			at = from[y * span + at]
		seams.append(seam)
	if float(worst) > float(h) * 0.015:
		return "%s, and no clean seam to cut along (the best one crosses %d px of figure)" % [why, worst]
	var left_edge: PackedInt32Array = PackedInt32Array()
	left_edge.resize(h)
	var right_edge: PackedInt32Array = PackedInt32Array()
	right_edge.resize(h)
	right_edge.fill(w)
	seams.push_front(left_edge)
	seams.append(right_edge)
	var widths: PackedStringArray = []
	for index: int in range(4):
		var frame_name: String = "SPR-%s-%s" % [key, FRAMES[index]]
		var target: String = dir.path_join(frame_name + ".png")
		if FileAccess.file_exists(target) and not _written.has(frame_name):
			_lines.append("- %s: kept the Drive's own `%s.png` (not overwritten)" % [key, frame_name])
			continue
		var a: PackedInt32Array = seams[index]
		var b: PackedInt32Array = seams[index + 1]
		var x0: int = w
		var x1: int = 0
		for y: int in range(h):
			x0 = mini(x0, a[y])
			x1 = maxi(x1, b[y])
		var frame: Image = Image.create_empty(x1 - x0, h, false, Image.FORMAT_RGBA8)
		for y: int in range(h):
			for x: int in range(a[y], b[y]):
				frame.set_pixel(x - x0, y, image.get_pixel(x, y))
		if index == 2 and not SIDE_ALREADY_LEFT.has(key):
			frame.flip_x()
		frame.save_png(target)
		_written[frame_name] = true
		widths.append("%s %d px" % [FRAMES[index], frame.get_width()])
	_lines.append("- %s: %dx%d sheet; %s, so cut along winding seams (each crosses at most %d px of figure - check the frame edges); widths %s" % [
		key, w, h, why, worst, ", ".join(widths)])
	return ""



func _coverage(image: Image) -> float:
	var opaque: int = 0
	var total: int = 0
	for y: int in range(0, image.get_height(), 4):
		for x: int in range(0, image.get_width(), 4):
			total += 1
			if image.get_pixel(x, y).a > 0.5:
				opaque += 1
	return float(opaque) / float(maxi(1, total))


## A sheet on one flat opaque colour: flood from the border through pixels close to the corner colour and clear them. False when the corners differ.
func _remove_flat_background(image: Image) -> bool:
	var w: int = image.get_width()
	var h: int = image.get_height()
	var corners: Array[Color] = [image.get_pixel(0, 0), image.get_pixel(w - 1, 0), image.get_pixel(0, h - 1), image.get_pixel(w - 1, h - 1)]
	var key: Color = corners[0]
	for c: Color in corners:
		if absf(c.r - key.r) + absf(c.g - key.g) + absf(c.b - key.b) > 0.16:
			return false
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
	return true
