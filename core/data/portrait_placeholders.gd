class_name PortraitPlaceholders
extends RefCounted
## Code-drawn stand-in portraits for NPCs whose art has not been imported yet (`Portraits.texture_for` uses one only while
## `assets/art/portraits/<ID>.webp` does not exist, so real art always wins). Flat silhouettes, 256x384, transparent: a hooded ninja for
## Shiro Swindle (NPC-NINJA), the Warden, the Rescuer, the king and queen and Dr. Siphon. Nothing is written to disk; the art pipeline still reports the ID as missing.

const WIDTH: int = 256
const HEIGHT: int = 384

## The silhouette is drawn at WIDTH x HEIGHT and smoothed up to SCALE times that.
const SCALE: int = 2
const IDS: Array[String] = ["NPC-NINJA", "NPC-VAULTWARDEN", "NPC-RESCUER", "NPC-KING", "NPC-QUEEN", "NPC-SIPHON"]

static var _cache: Dictionary = {}


static func has(portrait_id: String) -> bool:
	return IDS.has(portrait_id)


static func texture(portrait_id: String) -> Texture2D:
	if not has(portrait_id):
		return null
	if not _cache.has(portrait_id):
		_cache[portrait_id] = ImageTexture.create_from_image(_draw(portrait_id))
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


## A hooded rescuer (NPC-RESCUER): a muted travelling cloak, a deep hood and no face to speak of, a small four-colored clasp at the throat.
static func _rescuer() -> Image:
	var image: Image = Image.create(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var cloak: Color = Color("4a4f5a")
	var cloak_light: Color = Color("646a78")
	_polygon(image, PackedVector2Array([Vector2(24, 384), Vector2(48, 232), Vector2(96, 196), Vector2(160, 196), Vector2(208, 232), Vector2(232, 384)]), cloak)
	_polygon(image, PackedVector2Array([Vector2(96, 196), Vector2(160, 196), Vector2(208, 232), Vector2(232, 384), Vector2(180, 384), Vector2(150, 250)]), cloak_light)
	_ellipse(image, Vector2(128, 118), 72.0, 88.0, cloak)
	_ellipse(image, Vector2(110, 96), 38.0, 54.0, cloak_light)
	_ellipse(image, Vector2(130, 130), 44.0, 52.0, Color("14151a"))
	var clasp: Array[Color] = [Color("e8503a"), Color("5fd6a4"), Color("6fa8ff"), Color("b48cf2")]
	for index: int in range(clasp.size()):
		_ellipse(image, Vector2(110.0 + 12.0 * float(index), 226), 6.0, 6.0, clasp[index])
	image.resize(WIDTH * SCALE, HEIGHT * SCALE, Image.INTERPOLATE_LANCZOS)
	return image


## A royal bust (NPC-KING / NPC-QUEEN): a head and shoulders in royal robes under a small crown. `crown_color` and `robe` set who it is.
static func _royal(robe: Color, hair: Color, long_hair: bool) -> Image:
	var image: Image = Image.create(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var skin: Color = Color("e0b48c")
	var gold: Color = Color("e8b04a")
	if long_hair:
		_ellipse(image, Vector2(128, 150), 66.0, 100.0, hair)
	_polygon(image, PackedVector2Array([Vector2(20, 384), Vector2(40, 250), Vector2(96, 216), Vector2(160, 216), Vector2(216, 250), Vector2(236, 384)]), robe)
	_polygon(image, PackedVector2Array([Vector2(96, 216), Vector2(128, 270), Vector2(160, 216)]), gold)
	_rect(image, Rect2(108, 180, 40, 44), skin)
	_ellipse(image, Vector2(128, 130), 48.0, 58.0, skin)
	_ellipse(image, Vector2(128, 82), 52.0, 30.0, hair)
	_ellipse(image, Vector2(110, 128), 6.0, 4.0, Color("2a2535"))
	_ellipse(image, Vector2(146, 128), 6.0, 4.0, Color("2a2535"))
	_polygon(image, PackedVector2Array([Vector2(86, 80), Vector2(94, 44), Vector2(111, 66), Vector2(128, 36), Vector2(145, 66), Vector2(162, 44), Vector2(170, 80)]), gold)
	image.resize(WIDTH * SCALE, HEIGHT * SCALE, Image.INTERPOLATE_LANCZOS)
	return image


## The Chief Path-ologist (NPC-SIPHON): a pale clinical bust in a white coat with round glasses and slicked grey hair.
static func _siphon() -> Image:
	var image: Image = Image.create(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var coat: Color = Color("e8ecf0")
	var skin: Color = Color("e6c9b0")
	_polygon(image, PackedVector2Array([Vector2(20, 384), Vector2(40, 250), Vector2(96, 216), Vector2(160, 216), Vector2(216, 250), Vector2(236, 384)]), coat)
	_polygon(image, PackedVector2Array([Vector2(96, 216), Vector2(128, 300), Vector2(160, 216)]), Color("2c5f8a"))
	_rect(image, Rect2(108, 180, 40, 44), skin)
	_ellipse(image, Vector2(128, 130), 46.0, 58.0, skin)
	_ellipse(image, Vector2(128, 84), 48.0, 26.0, Color("9aa0a8"))
	_ellipse(image, Vector2(108, 128), 15.0, 15.0, Color("1a1d24"))
	_ellipse(image, Vector2(148, 128), 15.0, 15.0, Color("1a1d24"))
	_ellipse(image, Vector2(108, 128), 12.0, 12.0, Color("bfe3ff"))
	_ellipse(image, Vector2(148, 128), 12.0, 12.0, Color("bfe3ff"))
	image.resize(WIDTH * SCALE, HEIGHT * SCALE, Image.INTERPOLATE_LANCZOS)
	return image


static func _draw(portrait_id: String) -> Image:
	match portrait_id:
		"NPC-VAULTWARDEN":
			return _warden()
		"NPC-RESCUER":
			return _rescuer()
		"NPC-KING":
			return _royal(Color("6a2f8f"), Color("3a2a22"), false)
		"NPC-QUEEN":
			return _royal(Color("2f5f8f"), Color("5a3a28"), true)
		"NPC-SIPHON":
			return _siphon()
	return _ninja()
