extends RefCounted
## Art preparation of the Environment Kit (vertical slice, Part A). Used by tools/import_env_kit.gd after the copy: works on the converted copy only, never on the Drive file.
##   SURFACE : measures the seam of the directions the sheet says tile and repairs it (an edge-band crossfade with the half-rolled image), derives a normal map and a
##             roughness map from the painted luminance (painterly: broad relief, no photographic noise), sets the texel density (one detail scale for every surface).
##   CUTOUT / TREE : clears the plain background and any gray halo (alpha cleanup, colour bleed into the transparent border), trims to the painted bounds and finds the pivot.
## The numbers go to data/art/env_kit_prep.json (read by EnvKit): trimmed size, pivot, tile size in metres, the seam error before / after.

## Pixels of painted detail per metre of world for every tileable surface (1024 px -> 2.56 m): walls, ground and props share one detail scale.
const DENSITY: float = 400.0
const SEAM_LIMIT: float = 1.6
const BAND: float = 0.18
const NORMAL_STRENGTH: float = 2.4
## Patterns with designed posts, braces or courses: a crossfade ghosts them, so they are measured and reported but kept as painted.
const STRUCTURED: Array[String] = ["ENV-WALL-TIMBER", "ENV-WALL-TIMBER-WARM", "ENV-WALL-FOUNDATION"]


## Mean absolute colour difference between column/row `a` and `b` (0..1 per channel).
static func _line_diff(image: Image, a: int, b: int, vertical_lines: bool) -> float:
	var total: float = 0.0
	var count: int = image.get_height() if vertical_lines else image.get_width()
	var step: int = maxi(1, count / 256)
	var samples: int = 0
	for index: int in range(0, count, step):
		var p: Color = image.get_pixel(a, index) if vertical_lines else image.get_pixel(index, a)
		var q: Color = image.get_pixel(b, index) if vertical_lines else image.get_pixel(index, b)
		total += (absf(p.r - q.r) + absf(p.g - q.g) + absf(p.b - q.b)) / 3.0
		samples += 1
	return total / float(maxi(samples, 1))


## How much harder the wrap-around edge is than an ordinary neighbouring line pair (1.0 = invisible, above ~1.6 = a visible seam).
static func seam_ratio(image: Image, horizontal: bool) -> float:
	var size: int = image.get_width() if horizontal else image.get_height()
	var wrap: float = _line_diff(image, 0, size - 1, horizontal)
	var inner: float = 0.0
	for index: int in [size / 4, size / 2, size * 3 / 4]:
		inner += _line_diff(image, index, index + 1, horizontal)
	inner = maxf(inner / 3.0, 0.004)
	return wrap / inner


## Crossfades the outer bands of `image` with the half-rolled copy so the wrap-around edge matches. `horizontal` repairs left/right, otherwise top/bottom.
static func make_seamless(image: Image, horizontal: bool) -> Image:
	var width: int = image.get_width()
	var height: int = image.get_height()
	var result: Image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	var size: int = width if horizontal else height
	var band: float = float(size) * BAND
	for y: int in range(height):
		for x: int in range(width):
			var along: int = x if horizontal else y
			var edge: float = minf(float(along), float(size - 1 - along))
			var weight: float = clampf(edge / band, 0.0, 1.0)
			weight = weight * weight * (3.0 - 2.0 * weight)
			var rolled_x: int = (x + width / 2) % width if horizontal else x
			var rolled_y: int = y if horizontal else (y + height / 2) % height
			var own: Color = image.get_pixel(x, y)
			var other: Color = image.get_pixel(rolled_x, rolled_y)
			result.set_pixel(x, y, own.lerp(other, 1.0 - weight))
	return result


static func _luma(color: Color) -> float:
	return color.r * 0.299 + color.g * 0.587 + color.b * 0.114


## A normal map from the luminance height field of a surface (wraps at the borders so a tiled surface stays seamless). Strength is kept low: painted, not carved.
static func normal_map(image: Image, wrap_x: bool, wrap_y: bool) -> Image:
	var width: int = image.get_width()
	var height: int = image.get_height()
	var heights: PackedFloat32Array = PackedFloat32Array()
	heights.resize(width * height)
	for y: int in range(height):
		for x: int in range(width):
			heights[y * width + x] = _luma(image.get_pixel(x, y))
	# a soft blur first: the painted brush noise must not become pebbles
	var blurred: PackedFloat32Array = heights.duplicate()
	for y: int in range(height):
		for x: int in range(width):
			var total: float = 0.0
			for oy: int in range(-2, 3, 2):
				for ox: int in range(-2, 3, 2):
					var sx: int = (x + ox + width) % width if wrap_x else clampi(x + ox, 0, width - 1)
					var sy: int = (y + oy + height) % height if wrap_y else clampi(y + oy, 0, height - 1)
					total += heights[sy * width + sx]
			blurred[y * width + x] = total / 9.0
	var result: Image = Image.create(width, height, false, Image.FORMAT_RGB8)
	for y: int in range(height):
		for x: int in range(width):
			var xl: int = (x - 1 + width) % width if wrap_x else maxi(x - 1, 0)
			var xr: int = (x + 1) % width if wrap_x else mini(x + 1, width - 1)
			var yu: int = (y - 1 + height) % height if wrap_y else maxi(y - 1, 0)
			var yd: int = (y + 1) % height if wrap_y else mini(y + 1, height - 1)
			var dx: float = (blurred[y * width + xr] - blurred[y * width + xl]) * NORMAL_STRENGTH
			var dy: float = (blurred[yd * width + x] - blurred[yu * width + x]) * NORMAL_STRENGTH
			var n: Vector3 = Vector3(-dx * 8.0, -dy * 8.0, 1.0).normalized()
			result.set_pixel(x, y, Color(n.x * 0.5 + 0.5, n.y * 0.5 + 0.5, n.z * 0.5 + 0.5))
	return result


## Roughness: matte everywhere (painted), a little lower where the paint is bright (wet stone, varnish, iron) so a soft sheen can sit on the highlights.
static func roughness_map(image: Image) -> Image:
	var result: Image = Image.create(image.get_width(), image.get_height(), false, Image.FORMAT_L8)
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var luma: float = _luma(image.get_pixel(x, y))
			result.set_pixel(x, y, Color(clampf(0.92 - maxf(luma - 0.55, 0.0) * 0.9, 0.55, 0.95), 0.0, 0.0))
	return result


## Clears faint alpha, removes any gray fringe by bleeding the colour of the painted interior into the transparent border (so linear filtering and mipmaps pick no gray up).
static func clean_alpha(image: Image) -> int:
	var width: int = image.get_width()
	var height: int = image.get_height()
	var cleared: int = 0
	for y: int in range(height):
		for x: int in range(width):
			var pixel: Color = image.get_pixel(x, y)
			if pixel.a < 0.04 and pixel.a > 0.0:
				image.set_pixel(x, y, Color(pixel.r, pixel.g, pixel.b, 0.0))
				cleared += 1
	# colour bleed: three passes of "a transparent pixel takes the average colour of its opaque neighbours"
	for _pass: int in range(3):
		var copy: Image = image.duplicate() as Image
		for y: int in range(1, height - 1):
			for x: int in range(1, width - 1):
				if copy.get_pixel(x, y).a > 0.5:
					continue
				var r: float = 0.0
				var g: float = 0.0
				var b: float = 0.0
				var n: float = 0.0
				for oy: int in range(-1, 2):
					for ox: int in range(-1, 2):
						var q: Color = copy.get_pixel(x + ox, y + oy)
						if q.a > 0.5:
							r += q.r
							g += q.g
							b += q.b
							n += 1.0
				if n > 0.0:
					var current: Color = image.get_pixel(x, y)
					image.set_pixel(x, y, Color(r / n, g / n, b / n, current.a))
	return cleared


## The painted bounds (alpha above a floor) as a Rect2i; the whole image when nothing is opaque.
static func bounds(image: Image, floor_alpha: float = 0.06) -> Rect2i:
	var min_x: int = image.get_width()
	var min_y: int = image.get_height()
	var max_x: int = -1
	var max_y: int = -1
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			if image.get_pixel(x, y).a > floor_alpha:
				min_x = mini(min_x, x)
				max_x = maxi(max_x, x)
				min_y = mini(min_y, y)
				max_y = maxi(max_y, y)
	if max_x < 0:
		return Rect2i(0, 0, image.get_width(), image.get_height())
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)


## Pivot (0..1 of the trimmed image) by what the asset is: doors and windows at the base centre, signs at their wall bracket (the left plate), trees and posts at the base of the
## trunk, trim strips at their left edge, everything else the bottom centre.
static func pivot_for(id: String, image: Image) -> Vector2:
	var width: int = image.get_width()
	var height: int = image.get_height()
	if id.begins_with("ENV-SIGN-") and id != "ENV-SIGNPOST":
		var sum_y: float = 0.0
		var count: float = 0.0
		var columns: int = maxi(3, int(float(width) * 0.05))
		for x: int in range(columns):
			for y: int in range(height):
				if image.get_pixel(x, y).a > 0.5:
					sum_y += float(y)
					count += 1.0
		return Vector2(0.0, (sum_y / maxf(count, 1.0)) / float(height))
	if id.begins_with("ENV-TREE-") or id == "ENV-SIGNPOST":
		var sum_x: float = 0.0
		var count_x: float = 0.0
		var rows: int = maxi(3, int(float(height) * 0.04))
		for y: int in range(height - rows, height):
			for x: int in range(width):
				if image.get_pixel(x, y).a > 0.5:
					sum_x += float(x)
					count_x += 1.0
		return Vector2((sum_x / maxf(count_x, 1.0)) / float(width) if count_x > 0.0 else 0.5, 1.0)
	if id.begins_with("ENV-ROOF-EAVE") or id.begins_with("ENV-BEAM") or id.begins_with("ENV-PROP-FENCE"):
		return Vector2(0.0, 1.0)
	return Vector2(0.5, 1.0)
