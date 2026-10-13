class_name KitCanvas
extends RefCounted
## A tiny software painter for the kit's generated placeholder art (signs, trees, ivy, path edges): soft circles, ellipses, polygons and thick lines composited with
## "over" blending onto an RGBA8 image. Slow-ish (per pixel) but only used once per texture at start-up and at 128..384 px.

var image: Image
var width: int = 0
var height: int = 0


static func make(w: int, h: int, fill: Color = Color(0, 0, 0, 0)) -> KitCanvas:
	var canvas: KitCanvas = KitCanvas.new()
	canvas.width = w
	canvas.height = h
	canvas.image = Image.create(w, h, false, Image.FORMAT_RGBA8)
	canvas.image.fill(fill)
	return canvas


func blend(x: int, y: int, color: Color) -> void:
	if x < 0 or y < 0 or x >= width or y >= height or color.a <= 0.0:
		return
	var below: Color = image.get_pixel(x, y)
	var out_a: float = color.a + below.a * (1.0 - color.a)
	if out_a <= 0.0:
		return
	var rgb: Vector3 = (Vector3(color.r, color.g, color.b) * color.a + Vector3(below.r, below.g, below.b) * below.a * (1.0 - color.a)) / out_a
	image.set_pixel(x, y, Color(rgb.x, rgb.y, rgb.z, out_a))


## A filled ellipse with an `edge` px soft rim.
func ellipse(cx: float, cy: float, rx: float, ry: float, color: Color, edge: float = 1.5) -> void:
	var x0: int = maxi(int(floor(cx - rx - edge)), 0)
	var x1: int = mini(int(ceil(cx + rx + edge)), width - 1)
	var y0: int = maxi(int(floor(cy - ry - edge)), 0)
	var y1: int = mini(int(ceil(cy + ry + edge)), height - 1)
	for y: int in range(y0, y1 + 1):
		for x: int in range(x0, x1 + 1):
			var nx: float = (float(x) + 0.5 - cx) / maxf(rx, 0.5)
			var ny: float = (float(y) + 0.5 - cy) / maxf(ry, 0.5)
			var d: float = (sqrt(nx * nx + ny * ny) - 1.0) * minf(rx, ry)
			var cover: float = clampf(0.5 - d / maxf(edge, 0.01), 0.0, 1.0)
			if cover > 0.0:
				blend(x, y, Color(color.r, color.g, color.b, color.a * cover))


func circle(cx: float, cy: float, r: float, color: Color, edge: float = 1.5) -> void:
	ellipse(cx, cy, r, r, color, edge)


func rect(x: float, y: float, w: float, h: float, color: Color) -> void:
	for py: int in range(maxi(int(floor(y)), 0), mini(int(ceil(y + h)), height)):
		for px: int in range(maxi(int(floor(x)), 0), mini(int(ceil(x + w)), width)):
			blend(px, py, color)


## Rounded rectangle (corner radius `r`).
func round_rect(x: float, y: float, w: float, h: float, r: float, color: Color) -> void:
	for py: int in range(maxi(int(floor(y)), 0), mini(int(ceil(y + h)), height)):
		for px: int in range(maxi(int(floor(x)), 0), mini(int(ceil(x + w)), width)):
			var fx: float = float(px) + 0.5
			var fy: float = float(py) + 0.5
			var qx: float = absf(fx - (x + w * 0.5)) - (w * 0.5 - r)
			var qy: float = absf(fy - (y + h * 0.5)) - (h * 0.5 - r)
			var d: float = Vector2(maxf(qx, 0.0), maxf(qy, 0.0)).length() + minf(maxf(qx, qy), 0.0) - r
			var cover: float = clampf(0.5 - d, 0.0, 1.0)
			if cover > 0.0:
				blend(px, py, Color(color.r, color.g, color.b, color.a * cover))


func polygon(points: PackedVector2Array, color: Color) -> void:
	if points.size() < 3:
		return
	var lo: Vector2 = points[0]
	var hi: Vector2 = points[0]
	for p: Vector2 in points:
		lo = Vector2(minf(lo.x, p.x), minf(lo.y, p.y))
		hi = Vector2(maxf(hi.x, p.x), maxf(hi.y, p.y))
	for y: int in range(maxi(int(floor(lo.y)), 0), mini(int(ceil(hi.y)) + 1, height)):
		for x: int in range(maxi(int(floor(lo.x)), 0), mini(int(ceil(hi.x)) + 1, width)):
			if Geometry2D.is_point_in_polygon(Vector2(float(x) + 0.5, float(y) + 0.5), points):
				blend(x, y, color)


## A thick line drawn as a polygon.
func line(a: Vector2, b: Vector2, thickness: float, color: Color) -> void:
	var dir: Vector2 = (b - a)
	if dir.length() < 0.001:
		circle(a.x, a.y, thickness * 0.5, color)
		return
	var normal: Vector2 = Vector2(-dir.y, dir.x).normalized() * thickness * 0.5
	polygon(PackedVector2Array([a + normal, b + normal, b - normal, a - normal]), color)


## Multiplies the whole image's alpha by a vertical or radial edge fade (so a card never ends with a hard line).
func finish() -> Image:
	return image
