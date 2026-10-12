class_name SpriteAnchors
extends RefCounted
## Measurements taken from the painted character frames (used by `tools/sprite_anchors.gd` and `tools/import_cosmetics.gd`, and by tests):
##  - the head anchor of every frame, so a hat card can follow the head through every walk and idle frame: [x, y_top, width] in canvas pixels, where x is the middle of the
##    crown, y_top the top row of the figure and width the head's width a little below the top;
##  - the cloak's dominant hue (and how wide it is), so a dye can recolour exactly the cloak and nothing else.

const ALPHA_EDGE: float = 0.32
## The crown is the top slice of the figure; the head width is measured just below it.
const CROWN_FRACTION: float = 0.10
const WIDTH_ROW_FRACTION: float = 0.075
const MIN_WIDTH_FRACTION: float = 0.06
const MAX_WIDTH_FRACTION: float = 0.2


## [x, y_top, head_width, figure_height] of one frame (canvas pixels), or an empty array when the frame has no figure.
static func head_anchor(image: Image) -> Array:
	var width: int = image.get_width()
	var height: int = image.get_height()
	var top: int = -1
	var bottom: int = -1
	for y: int in range(height):
		for x: int in range(0, width):
			if image.get_pixel(x, y).a > ALPHA_EDGE:
				if top < 0:
					top = y
				bottom = y
				break
	if top < 0:
		return []
	var figure: float = float(bottom - top + 1)
	var crown_rows: int = maxi(2, int(figure * CROWN_FRACTION))
	var sum_x: float = 0.0
	var weight: float = 0.0
	for y: int in range(top, mini(top + crown_rows, height)):
		for x: int in range(width):
			var a: float = image.get_pixel(x, y).a
			if a > ALPHA_EDGE:
				sum_x += float(x) * a
				weight += a
	var centre: float = sum_x / weight if weight > 0.0 else float(width) * 0.5
	var row: int = clampi(top + int(figure * WIDTH_ROW_FRACTION), 0, height - 1)
	var left: int = -1
	var right: int = -1
	# The head is the run of pixels on that row nearest to the crown's middle (a cloak can add a second run).
	var run_start: int = -1
	var best: Vector2i = Vector2i(-1, -1)
	var best_distance: float = 1e9
	for x: int in range(width + 1):
		var filled: bool = x < width and image.get_pixel(x, row).a > ALPHA_EDGE
		if filled and run_start < 0:
			run_start = x
		elif not filled and run_start >= 0:
			var middle: float = float(run_start + x - 1) * 0.5
			var distance: float = absf(middle - centre)
			if distance < best_distance:
				best_distance = distance
				best = Vector2i(run_start, x - 1)
			run_start = -1
	left = best.x
	right = best.y
	var head_width: float = float(right - left + 1) if left >= 0 else figure * 0.11
	head_width = clampf(head_width, figure * MIN_WIDTH_FRACTION, figure * MAX_WIDTH_FRACTION)
	return [centre, float(top), head_width, figure]


## The dominant saturated hue of a set of frames (0..1) and the half-width of the band around it that counts as cloak: [hue, half_width]. Skin, hair and boots are
## warm browns and oranges; a cloak is whatever saturated colour covers the most pixels.
static func cloak_hue(images: Array) -> Array:
	var bins: PackedFloat32Array = PackedFloat32Array()
	bins.resize(36)
	for entry: Variant in images:
		var image: Image = entry as Image
		for y: int in range(0, image.get_height(), 3):
			for x: int in range(0, image.get_width(), 3):
				var c: Color = image.get_pixel(x, y)
				if c.a < 0.6 or c.s < 0.28 or c.v < 0.12:
					continue
				bins[int(c.h * 36.0) % 36] += c.s * c.v
	var best: int = 0
	for i: int in range(36):
		if bins[i] > bins[best]:
			best = i
	# Sub-bin centre by the weighted mean over the winner and its neighbours.
	var sum_h: float = 0.0
	var sum_w: float = 0.0
	for offset: int in range(-1, 2):
		var index: int = (best + offset + 36) % 36
		var weight: float = bins[index]
		sum_h += (float(best + offset) + 0.5) / 36.0 * weight
		sum_w += weight
	var hue: float = fposmod(sum_h / sum_w if sum_w > 0.0 else (float(best) + 0.5) / 36.0, 1.0)
	return [hue, 0.07]
