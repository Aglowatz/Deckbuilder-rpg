class_name HatSheet
extends RefCounted
## Apparel Part 2 (docs/art/cosmetics.md): a hat delivered as ONE sheet, COS-HAT-<NAME>-SHEET.png (2560x512, five views left to right: FRONT, FRONTSIDE, SIDE, BACKSIDE,
## BACK, transparent). `split` cuts it into the five views: the opaque pieces are found as connected parts, specks (a stray brush dot, a sliver of the next view) are
## dropped, every piece goes to the view whose fifth of the sheet holds its middle, and each view is trimmed to its pieces (pixels of dropped specks inside the box
## are cleared). `fit` turns the five views into per-direction sizes, each view scaled by its own head band (sheets do not keep one scale between views).

const DIRS: Array[String] = ["FRONT", "FRONTSIDE", "SIDE", "BACKSIDE", "BACK"]
const ALPHA_EDGE: int = 26
## The hat card is drawn over the head, so from the front a hat sits higher (the brim at the brows, not over the eyes) than from behind (over the hair).
const DIR_SINK: Dictionary = {"FRONT": 0.62, "FRONTSIDE": 0.68, "SIDE": 0.6, "BACKSIDE": 0.95, "BACK": 1.0}
## A piece smaller than this share of the biggest piece on the sheet is a speck.
const SPECK_SHARE: float = 0.015
## A piece smaller than this share of the biggest piece of its own view is a sliver (a feather tip or brim edge drawn as its own piece stays: they are bigger).
const VIEW_PIECE_SHARE: float = 0.06
const PAD: int = 2

## How wide each hat sits on the head seen from the front (a multiple of the head's width) and how far its bottom edge dips below the top of the head (in head
## widths; the top of the head is the top of the curly hair, so a brim sits about one head width down at the brows). The first guess for a hat;
## assets/art/cosmetics/hats/fit.json overrides any of it by hand.
const BASE_FIT: Dictionary = {
	"WIDEBRIM": {"width": 2.25, "sink": 1.0},
	"CHEF": {"width": 1.3, "sink": 0.75},
	"BOWLER": {"width": 1.45, "sink": 0.8},
	"TRICORN": {"width": 1.85, "sink": 0.95},
	"WIZARD": {"width": 1.9, "sink": 1.0},
	"LEAFCROWN": {"width": 1.35, "sink": 0.6},
}


## direction -> trimmed Image; a view with nothing in it is missing from the result.
static func split(sheet: Image) -> Dictionary:
	var image: Image = sheet.duplicate() as Image
	image.convert(Image.FORMAT_RGBA8)
	var w: int = image.get_width()
	var h: int = image.get_height()
	var data: PackedByteArray = image.get_data()
	var label: PackedInt32Array = PackedInt32Array()
	label.resize(w * h)
	label.fill(-1)
	var sizes: Array[int] = []
	var centres: Array[float] = []
	var stack: PackedInt32Array = PackedInt32Array()
	for start: int in range(w * h):
		if label[start] >= 0 or data[start * 4 + 3] < ALPHA_EDGE:
			continue
		var id: int = sizes.size()
		var count: int = 0
		var sum_x: float = 0.0
		label[start] = id
		stack.append(start)
		while not stack.is_empty():
			var at: int = stack[stack.size() - 1]
			stack.remove_at(stack.size() - 1)
			count += 1
			var px: int = at % w
			sum_x += float(px)
			# 8-connected, so a thin outline that only touches at corners stays one piece.
			for dy: int in range(-1, 2):
				var py: int = at / w + dy
				if py < 0 or py >= h:
					continue
				for dx: int in range(-1, 2):
					var nx: int = px + dx
					if nx < 0 or nx >= w:
						continue
					var next: int = py * w + nx
					if label[next] < 0 and data[next * 4 + 3] >= ALPHA_EDGE:
						label[next] = id
						stack.append(next)
		sizes.append(count)
		centres.append(sum_x / float(count))
	var biggest: int = 0
	for size: int in sizes:
		biggest = maxi(biggest, size)
	var cell: float = float(w) / float(DIRS.size())
	var view_of: PackedInt32Array = PackedInt32Array()
	view_of.resize(sizes.size())
	var biggest_in: Array[int] = [0, 0, 0, 0, 0]
	for id: int in range(sizes.size()):
		var at: int = clampi(int(centres[id] / cell), 0, DIRS.size() - 1)
		view_of[id] = at
		biggest_in[at] = maxi(biggest_in[at], sizes[id])
	# A speck on the sheet, or a piece small next to its view's main piece (a sliver of the neighbouring view cut off at the cell edge), is dropped.
	for id: int in range(sizes.size()):
		if float(sizes[id]) < float(biggest) * SPECK_SHARE or float(sizes[id]) < float(biggest_in[view_of[id]]) * VIEW_PIECE_SHARE:
			view_of[id] = -1
	var boxes: Array[Rect2i] = []
	for _d: String in DIRS:
		boxes.append(Rect2i())
	for i: int in range(w * h):
		var id: int = label[i]
		if id < 0 or view_of[id] < 0:
			continue
		var point: Rect2i = Rect2i(i % w, i / w, 1, 1)
		var view: int = view_of[id]
		boxes[view] = point if boxes[view].size.x == 0 else boxes[view].merge(point)
	var result: Dictionary = {}
	for view: int in range(DIRS.size()):
		var box: Rect2i = boxes[view]
		if box.size.x == 0:
			continue
		box = box.grow(PAD).intersection(Rect2i(0, 0, w, h))
		var out: Image = Image.create_empty(box.size.x, box.size.y, false, Image.FORMAT_RGBA8)
		var out_data: PackedByteArray = out.get_data()
		for y: int in range(box.size.y):
			for x: int in range(box.size.x):
				var i: int = (box.position.y + y) * w + box.position.x + x
				var id: int = label[i]
				# Keep the soft edge (below ALPHA_EDGE, unlabelled) of this view's pieces; clear specks and other views.
				var keep: bool = (id >= 0 and view_of[id] == view) or (id < 0 and data[i * 4 + 3] > 0 and _near_view(label, view_of, w, h, i, view))
				if keep:
					var o: int = (y * box.size.x + x) * 4
					for c: int in range(4):
						out_data[o + c] = data[i * 4 + c]
		out.set_data(box.size.x, box.size.y, false, Image.FORMAT_RGBA8, out_data)
		result[DIRS[view]] = out
	return result


static func _near_view(label: PackedInt32Array, view_of: PackedInt32Array, w: int, h: int, i: int, view: int) -> bool:
	var px: int = i % w
	var py: int = i / w
	for dy: int in range(-2, 3):
		for dx: int in range(-2, 3):
			var nx: int = px + dx
			var ny: int = py + dy
			if nx < 0 or ny < 0 or nx >= w or ny >= h:
				continue
			var id: int = label[ny * w + nx]
			if id >= 0 and view_of[id] == view:
				return true
	return false


## The per-direction fit of one hat: {"width": front width, "sink": ..., "ratio_<DIR>": ...} for the four other views (that view's card width = width x ratio).
## Painted sheets do not keep one scale (a back view is often drawn bigger), so every view is scaled by its own HEAD BAND, the widest row in its bottom third
## (the brim, or the band of a toque): the band takes the same share of the head's width from every direction. `head_widths` is kept for the report only.
static func fit(hat_name: String, views: Dictionary, _head_widths: Dictionary = {}) -> Dictionary:
	var base: Dictionary = BASE_FIT.get(hat_name, {"width": 1.5, "sink": 0.3}) as Dictionary
	var result: Dictionary = {"width": float(base["width"]), "sink": float(base["sink"])}
	var front: Image = views.get("FRONT") as Image
	if front == null:
		return result
	var front_share: float = float(front.get_width()) / maxf(1.0, band_width(front))
	for dir_name: String in DIRS:
		result["sink_" + dir_name] = snappedf(float(base["sink"]) * float(DIR_SINK[dir_name]), 0.01)
	for dir_name: String in DIRS:
		var view: Image = views.get(dir_name) as Image
		if dir_name == "FRONT" or view == null:
			continue
		var share: float = float(view.get_width()) / maxf(1.0, band_width(view))
		result["ratio_" + dir_name] = snappedf(share / front_share, 0.01)
	return result


## The widest opaque row (leftmost to rightmost solid pixel) in the bottom third of a trimmed view, in pixels.
static func band_width(view: Image) -> float:
	var w: int = view.get_width()
	var h: int = view.get_height()
	var best: int = 0
	for y: int in range(h - 1 - h / 3, h):
		var left: int = -1
		var right: int = -1
		for x: int in range(w):
			if view.get_pixel(x, y).a > 0.5:
				if left < 0:
					left = x
				right = x
		if left >= 0:
			best = maxi(best, right - left + 1)
	return float(best)
