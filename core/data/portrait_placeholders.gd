class_name PortraitPlaceholders
extends RefCounted
## Code-drawn stand-in portraits for NPCs whose art has not been imported yet (`Portraits.texture_for` uses one only while
## `assets/art/portraits/<ID>.webp` does not exist, so real art always wins). Flat silhouettes, 256x384, transparent: a hooded ninja for
## Shiro Swindle (NPC-NINJA). Nothing is written to disk; the art pipeline still reports the ID as missing.

const WIDTH: int = 256
const HEIGHT: int = 384

## The silhouette is drawn at WIDTH x HEIGHT and smoothed up to SCALE times that.
const SCALE: int = 2
const IDS: Array[String] = ["NPC-NINJA", "NPC-VAULTWARDEN"]

static var _cache: Dictionary = {}


static func has(portrait_id: String) -> bool:
	return IDS.has(portrait_id)


static func texture(portrait_id: String) -> Texture2D:
	if not has(portrait_id):
		return null
	if not _cache.has(portrait_id):
		_cache[portrait_id] = ImageTexture.create_from_image(_warden() if portrait_id == "NPC-VAULTWARDEN" else _ninja())
	return _cache[portrait_id] as Texture2D


static func reset() -> void:
	_cache = {}


## A hooded figure from the waist up: dark hood and torso, a face slit with two glowing eyes, a red scarf and a tail of cloth.
static func _ninja() -> Image:
	var image: Image = Image.create(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var cloth: Color = Color("1d1a26")
	var cloth_light: Color = Color("2e2940")
	var scarf: Color = Color("c4342d")
	var scarf_dark: Color = Color("8c211d")
	var skin_shadow: Color = Color("0b0a10")
	# torso and shoulders (a trapezoid with rounded top)
	_polygon(image, PackedVector2Array([Vector2(36, 384), Vector2(52, 236), Vector2(98, 196), Vector2(158, 196), Vector2(204, 236), Vector2(220, 384)]), cloth)
	_polygon(image, PackedVector2Array([Vector2(98, 196), Vector2(158, 196), Vector2(204, 236), Vector2(220, 384), Vector2(176, 384), Vector2(150, 250)]), cloth_light)
	# hood
	_ellipse(image, Vector2(128, 120), 70.0, 84.0, cloth)
	_ellipse(image, Vector2(108, 100), 36.0, 52.0, cloth_light)
	# face opening and mask band
	_ellipse(image, Vector2(130, 128), 46.0, 36.0, skin_shadow)
	_rect(image, Rect2(84, 112, 92, 26), Color("2a2535"))
	# eyes
	_ellipse(image, Vector2(112, 124), 11.0, 5.5, Color("fff2d6"))
	_ellipse(image, Vector2(150, 124), 11.0, 5.5, Color("fff2d6"))
	_ellipse(image, Vector2(114, 124), 4.0, 4.5, Color("d6322b"))
	_ellipse(image, Vector2(148, 124), 4.0, 4.5, Color("d6322b"))
	# scarf and its trailing tail
	_polygon(image, PackedVector2Array([Vector2(70, 188), Vector2(186, 188), Vector2(196, 222), Vector2(60, 222)]), scarf)
	_polygon(image, PackedVector2Array([Vector2(150, 214), Vector2(196, 214), Vector2(236, 330), Vector2(206, 340)]), scarf_dark)
	_polygon(image, PackedVector2Array([Vector2(60, 222), Vector2(196, 222), Vector2(190, 236), Vector2(66, 236)]), scarf_dark)
	image.resize(WIDTH * SCALE, HEIGHT * SCALE, Image.INTERPOLATE_LANCZOS)
	return image


static func _ellipse(image: Image, center: Vector2, radius_x: float, radius_y: float, color: Color) -> void:
	for y: int in range(maxi(0, int(center.y - radius_y)), mini(HEIGHT, int(center.y + radius_y) + 1)):
		for x: int in range(maxi(0, int(center.x - radius_x)), mini(WIDTH, int(center.x + radius_x) + 1)):
			var nx: float = (float(x) - center.x) / radius_x
			var ny: float = (float(y) - center.y) / radius_y
			if nx * nx + ny * ny <= 1.0:
				image.set_pixel(x, y, color)


static func _rect(image: Image, rect: Rect2, color: Color) -> void:
	for y: int in range(maxi(0, int(rect.position.y)), mini(HEIGHT, int(rect.end.y))):
		for x: int in range(maxi(0, int(rect.position.x)), mini(WIDTH, int(rect.end.x))):
			image.set_pixel(x, y, color)


static func _polygon(image: Image, points: PackedVector2Array, color: Color) -> void:
	var low: Vector2 = points[0]
	var high: Vector2 = points[0]
	for point: Vector2 in points:
		low = Vector2(minf(low.x, point.x), minf(low.y, point.y))
		high = Vector2(maxf(high.x, point.x), maxf(high.y, point.y))
	for y: int in range(maxi(0, int(low.y)), mini(HEIGHT, int(high.y) + 1)):
		for x: int in range(maxi(0, int(low.x)), mini(WIDTH, int(high.x) + 1)):
			if Geometry2D.is_point_in_polygon(Vector2(float(x) + 0.5, float(y) + 0.5), points):
				image.set_pixel(x, y, color)


## A stone sentinel from the waist up: a squared grey helm with a gold visor, four glowing seals (one per Path) across the chest and heavy shoulders.
static func _warden() -> Image:
	var image: Image = Image.create(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var stone: Color = Color("5b5866")
	var stone_light: Color = Color("7b7889")
	var stone_dark: Color = Color("3a3845")
	var gold: Color = Color("e8b04a")
	_polygon(image, PackedVector2Array([Vector2(8, 384), Vector2(18, 250), Vector2(70, 212), Vector2(186, 212), Vector2(238, 250), Vector2(248, 384)]), stone)
	_polygon(image, PackedVector2Array([Vector2(8, 384), Vector2(18, 250), Vector2(54, 236), Vector2(70, 384)]), stone_dark)
	_ellipse(image, Vector2(36, 246), 38.0, 26.0, stone_light)
	_ellipse(image, Vector2(220, 246), 38.0, 26.0, stone_light)
	_rect(image, Rect2(96, 176, 64, 44), stone_dark)
	_polygon(image, PackedVector2Array([Vector2(70, 60), Vector2(186, 60), Vector2(200, 100), Vector2(194, 186), Vector2(62, 186), Vector2(56, 100)]), stone)
	_polygon(image, PackedVector2Array([Vector2(70, 60), Vector2(128, 60), Vector2(128, 186), Vector2(62, 186), Vector2(56, 100)]), stone_light)
	_rect(image, Rect2(68, 104, 120, 22), gold)
	_rect(image, Rect2(122, 104, 12, 70), gold)
	_ellipse(image, Vector2(100, 115), 8.0, 4.0, Color("fff2d6"))
	_ellipse(image, Vector2(156, 115), 8.0, 4.0, Color("fff2d6"))
	var seals: Array[Color] = [Color("e8503a"), Color("5fd6a4"), Color("6fa8ff"), Color("b48cf2")]
	for index: int in range(seals.size()):
		var cx: float = 66.0 + 41.0 * float(index)
		_ellipse(image, Vector2(cx, 300), 13.0, 13.0, stone_dark)
		_ellipse(image, Vector2(cx, 300), 8.0, 8.0, seals[index])
	image.resize(WIDTH * SCALE, HEIGHT * SCALE, Image.INTERPOLATE_LANCZOS)
	return image
