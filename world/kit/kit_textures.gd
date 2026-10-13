class_name KitTextures
extends RefCounted
## The generated stand-ins of the Environment Kit (data/art/environment_kit.json, placeholder "gen:<name>"): striped canvas, burlap, icon-only hanging signs, ivy, wall stains, path
## edges, worn patches and painted-card trees. They are drawn once in code (`KitCanvas`), cached, and used until the real art is dropped in `assets/art/env_kit/<ID>.webp`.
## The signs carry no text: an emblem on a wooden board.

static var _cache: Dictionary = {}

const PATH_COLORS: Array[Color] = [Color("d9503a"), Color("e8b53a"), Color("5ab0e0"), Color("8a5fd0")]


static func texture(name: String) -> Texture2D:
	if _cache.has(name):
		return _cache[name] as Texture2D
	var image: Image = _generate(name)
	var result: Texture2D = null
	if image != null:
		image.generate_mipmaps()
		result = ImageTexture.create_from_image(image)
	_cache[name] = result
	return result


static func clear() -> void:
	_cache.clear()


static func _generate(name: String) -> Image:
	match name:
		"stripes_red":
			return _stripes(Color("d9573f"), Color("f3e4c6"))
		"stripes_green":
			return _stripes(Color("5b9a55"), Color("f1e8cf"))
		"stripes_blue":
			return _stripes(Color("4f7fc0"), Color("f1e6cc"))
		"stripes_cream":
			return _stripes(Color("efe2c4"), Color("e4d3ae"))
		"burlap":
			return _burlap()
		"sign_cards", "sign_potion", "sign_shield", "sign_needle", "sign_pack", "sign_flask", "sign_inn", "sign_path":
			return _sign(name.trim_prefix("sign_"))
		"ivy":
			return _ivy()
		"wallstain":
			return _wallstain()
		"pathedge":
			return _pathedge()
		"wornpatch":
			return _wornpatch()
		"tree_oak", "tree_fruit", "tree_pine", "tree_birch":
			return _tree(name.trim_prefix("tree_"))
	return null


static func _rng(seed_value: int) -> RandomNumberGenerator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


static func _stripes(a: Color, b: Color) -> Image:
	var canvas: KitCanvas = KitCanvas.make(64, 64, b)
	var rng: RandomNumberGenerator = _rng(11)
	for stripe: int in range(0, 64, 16):
		canvas.rect(float(stripe), 0.0, 8.0, 64.0, a)
	for y: int in range(64):
		for x: int in range(64):
			var shade: float = 1.0 + (rng.randf() - 0.5) * 0.08 + (0.04 if (x + y) % 4 == 0 else 0.0)
			var c: Color = canvas.image.get_pixel(x, y)
			canvas.image.set_pixel(x, y, Color(c.r * shade, c.g * shade, c.b * shade, 1.0))
	return canvas.image


static func _burlap() -> Image:
	var canvas: KitCanvas = KitCanvas.make(64, 64, Color("b99a68"))
	var rng: RandomNumberGenerator = _rng(12)
	for y: int in range(64):
		for x: int in range(64):
			var weave: float = 0.9 + 0.1 * float((x / 2 + y / 2) % 2) + (rng.randf() - 0.5) * 0.1
			var c: Color = canvas.image.get_pixel(x, y)
			canvas.image.set_pixel(x, y, Color(c.r * weave, c.g * weave, c.b * weave, 1.0))
	return canvas.image


## A hanging board with an emblem, 128 x 160, transparent outside the board.
static func _sign(kind: String) -> Image:
	var canvas: KitCanvas = KitCanvas.make(128, 160)
	canvas.round_rect(4.0, 14.0, 120.0, 142.0, 14.0, Color("4a2f1c"))
	canvas.round_rect(9.0, 19.0, 110.0, 132.0, 10.0, Color("b98450"))
	for plank: int in range(1, 4):
		canvas.rect(9.0 + float(plank) * 27.5, 22.0, 1.5, 126.0, Color(0.3, 0.19, 0.1, 0.5))
	canvas.circle(64.0, 8.0, 5.0, Color("2d2d2f"))
	var c: Vector2 = Vector2(64.0, 86.0)
	match kind:
		"cards":
			for index: int in range(3):
				var angle: float = deg_to_rad(-24.0 + 24.0 * float(index))
				var points: PackedVector2Array = PackedVector2Array()
				for corner: Vector2 in [Vector2(-20, -32), Vector2(20, -32), Vector2(20, 32), Vector2(-20, 32)]:
					points.append(c + Vector2(0, 18) + corner.rotated(angle) + Vector2(sin(angle) * 22.0, 0))
				canvas.polygon(points, Color("2e2a2a"))
				var inner: PackedVector2Array = PackedVector2Array()
				for corner: Vector2 in [Vector2(-17, -29), Vector2(17, -29), Vector2(17, 29), Vector2(-17, 29)]:
					inner.append(c + Vector2(0, 18) + corner.rotated(angle) + Vector2(sin(angle) * 22.0, 0))
				canvas.polygon(inner, Color("f6eedc") if index != 2 else Color("e0584a"))
			canvas.polygon(PackedVector2Array([c + Vector2(30, 6), c + Vector2(38, 18), c + Vector2(30, 30), c + Vector2(22, 18)]), Color("f6eedc"))
		"potion":
			canvas.circle(c.x, c.y + 14.0, 28.0, Color("2b1c3a"))
			canvas.circle(c.x, c.y + 14.0, 24.0, Color("8a52d0"))
			canvas.circle(c.x - 8.0, c.y + 6.0, 7.0, Color(1, 1, 1, 0.45))
			canvas.rect(c.x - 9.0, c.y - 24.0, 18.0, 22.0, Color("2b1c3a"))
			canvas.rect(c.x - 6.0, c.y - 22.0, 12.0, 20.0, Color("c8b0ea"))
			canvas.rect(c.x - 8.0, c.y - 34.0, 16.0, 12.0, Color("8c5a32"))
		"shield":
			var shield: PackedVector2Array = PackedVector2Array([c + Vector2(-30, -34), c + Vector2(30, -34), c + Vector2(32, 6), c + Vector2(0, 46), c + Vector2(-32, 6)])
			canvas.polygon(shield, Color("2a2a38"))
			var inner_shield: PackedVector2Array = PackedVector2Array([c + Vector2(-25, -29), c + Vector2(25, -29), c + Vector2(27, 4), c + Vector2(0, 38), c + Vector2(-27, 4)])
			canvas.polygon(inner_shield, Color("4f7fc0"))
			canvas.rect(c.x - 4.0, c.y - 29.0, 8.0, 66.0, Color("f1e6cc"))
			canvas.rect(c.x - 26.0, c.y - 8.0, 52.0, 8.0, Color("f1e6cc"))
		"needle":
			canvas.line(c + Vector2(-34, 38), c + Vector2(30, -38), 5.0, Color("d8d8e0"))
			canvas.circle(c.x + 30.0, c.y - 38.0, 6.0, Color("2b2b33"))
			canvas.circle(c.x + 30.0, c.y - 38.0, 3.0, Color(0, 0, 0, 0))
			canvas.round_rect(c.x - 34.0, c.y - 10.0, 34.0, 44.0, 6.0, Color("3c3030"))
			canvas.round_rect(c.x - 30.0, c.y - 6.0, 26.0, 36.0, 4.0, Color("d9503a"))
			canvas.line(c + Vector2(-4, 20), c + Vector2(24, 36), 3.0, Color("d9503a"))
		"pack":
			canvas.polygon(PackedVector2Array([c + Vector2(-26, -40), c + Vector2(26, -40), c + Vector2(26, 40), c + Vector2(-26, 40)]), Color("2a2230"))
			canvas.polygon(PackedVector2Array([c + Vector2(-22, -36), c + Vector2(22, -36), c + Vector2(22, 36), c + Vector2(-22, 36)]), Color("8a5fd0"))
			canvas.rect(c.x - 26.0, c.y - 42.0, 52.0, 8.0, Color("e8b53a"))
			canvas.rect(c.x - 26.0, c.y + 34.0, 52.0, 8.0, Color("e8b53a"))
			canvas.circle(c.x, c.y, 11.0, Color("2a2230"))
			canvas.circle(c.x, c.y, 8.0, Color("e8b53a"))
		"flask":
			canvas.polygon(PackedVector2Array([c + Vector2(-8, -42), c + Vector2(8, -42), c + Vector2(8, -16), c + Vector2(34, 36), c + Vector2(-34, 36), c + Vector2(-8, -16)]), Color("23303a"))
			canvas.polygon(PackedVector2Array([c + Vector2(-5, -38), c + Vector2(5, -38), c + Vector2(5, -12), c + Vector2(28, 32), c + Vector2(-28, 32), c + Vector2(-5, -12)]), Color("d6ece4"))
			canvas.polygon(PackedVector2Array([c + Vector2(-17, 8), c + Vector2(17, 8), c + Vector2(28, 32), c + Vector2(-28, 32)]), Color("5fd07a"))
			canvas.circle(c.x - 6.0, c.y - 2.0, 4.0, Color("c8f6c8"))
			canvas.circle(c.x + 8.0, c.y - 14.0, 3.0, Color("c8f6c8"))
		"inn":
			canvas.round_rect(c.x - 28.0, c.y - 20.0, 48.0, 60.0, 6.0, Color("3a2412"))
			canvas.round_rect(c.x - 24.0, c.y - 16.0, 40.0, 52.0, 4.0, Color("e8b53a"))
			canvas.ellipse(c.x + 24.0, c.y + 10.0, 14.0, 16.0, Color("3a2412"))
			canvas.ellipse(c.x + 24.0, c.y + 10.0, 8.0, 10.0, Color(0, 0, 0, 0))
			for foam: int in range(4):
				canvas.circle(c.x - 22.0 + 12.0 * float(foam), c.y - 22.0, 9.0, Color("fbf6e8"))
		"path":
			canvas.circle(c.x, c.y, 40.0, Color("2a2230"))
			for index: int in range(4):
				var a0: float = TAU * float(index) / 4.0 - PI / 2.0
				var pts: PackedVector2Array = PackedVector2Array([c])
				for step: int in range(9):
					var ang: float = a0 + (PI / 2.0) * float(step) / 8.0
					pts.append(c + Vector2(cos(ang), sin(ang)) * 36.0)
				canvas.polygon(pts, PATH_COLORS[index])
			canvas.circle(c.x, c.y, 10.0, Color("2a2230"))
			canvas.circle(c.x, c.y, 6.0, Color("f6eedc"))
	return canvas.image


static func _ivy() -> Image:
	var canvas: KitCanvas = KitCanvas.make(128, 256)
	var rng: RandomNumberGenerator = _rng(21)
	var stem: Color = Color("3c4a28")
	var x: float = 64.0
	var prev: Vector2 = Vector2(x, 252.0)
	for step: int in range(1, 40):
		x = clampf(x + rng.randf_range(-9.0, 9.0), 26.0, 102.0)
		var p: Vector2 = Vector2(x, 252.0 - float(step) * 6.2)
		canvas.line(prev, p, 3.0, stem)
		prev = p
		for side: int in range(2):
			var off: Vector2 = Vector2((-1.0 if side == 0 else 1.0) * rng.randf_range(4.0, 14.0), rng.randf_range(-4.0, 4.0))
			var leaf: Color = Color("4d8a38").lerp(Color("8fbf4a"), rng.randf())
			canvas.ellipse(p.x + off.x, p.y + off.y, rng.randf_range(6.0, 10.0), rng.randf_range(4.0, 7.0), leaf, 1.2)
	return canvas.image


static func _wallstain() -> Image:
	var canvas: KitCanvas = KitCanvas.make(128, 128)
	var rng: RandomNumberGenerator = _rng(22)
	for streak: int in range(9):
		var x: float = 16.0 + float(streak) * 12.0 + rng.randf_range(-4.0, 4.0)
		var length: float = rng.randf_range(40.0, 120.0)
		for y: int in range(int(length)):
			var a: float = (1.0 - float(y) / length) * rng.randf_range(0.12, 0.22)
			canvas.circle(x, float(y), rng.randf_range(2.0, 4.0), Color(0.22, 0.17, 0.12, a), 2.0)
	return canvas.image


## Across the strip: v = 0 path side, v = 1 grass side. Dirt fades into grass with an irregular blade-like edge.
static func _pathedge() -> Image:
	var canvas: KitCanvas = KitCanvas.make(256, 64)
	var rng: RandomNumberGenerator = _rng(23)
	for x: int in range(256):
		var edge: float = 26.0 + sin(float(x) * 0.09) * 6.0 + sin(float(x) * 0.31 + 1.0) * 3.0 + rng.randf() * 3.0
		for y: int in range(64):
			var d: float = float(y) - edge
			var dirt: float = clampf(0.5 - d / 10.0, 0.0, 1.0)
			if dirt > 0.0:
				var shade: float = 0.9 + rng.randf() * 0.15
				canvas.image.set_pixel(x, y, Color(0.62 * shade, 0.47 * shade, 0.3 * shade, dirt * (1.0 - clampf((float(y) - 40.0) / 20.0, 0.0, 1.0))))
	for tuft: int in range(40):
		var x: float = rng.randf_range(0.0, 255.0)
		var base: float = 26.0 + sin(x * 0.09) * 6.0 + 6.0
		for blade: int in range(3):
			var h: float = rng.randf_range(8.0, 16.0)
			canvas.line(Vector2(x + float(blade) * 2.0, base + 4.0), Vector2(x + float(blade) * 3.0 - 2.0, base - h * 0.4), 2.0, Color("5f9a45"))
	return canvas.image


static func _wornpatch() -> Image:
	var canvas: KitCanvas = KitCanvas.make(128, 128)
	var rng: RandomNumberGenerator = _rng(24)
	canvas.ellipse(64.0, 64.0, 52.0, 44.0, Color(0.58, 0.44, 0.28, 0.85), 14.0)
	for dot: int in range(60):
		var p: Vector2 = Vector2(64.0, 64.0) + Vector2(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0)) * 36.0
		canvas.circle(p.x, p.y, rng.randf_range(1.5, 4.0), Color(0.45, 0.33, 0.2, 0.4), 1.0)
	return canvas.image


## A painted-looking tree card, 256 x 384 (trunk at the bottom centre), transparent outside the crown.
static func _tree(kind: String) -> Image:
	var canvas: KitCanvas = KitCanvas.make(256, 384)
	var rng: RandomNumberGenerator = _rng(30 + kind.length())
	var bark: Color = Color("e6dccb") if kind == "birch" else Color("6b4a2c")
	var base_x: float = 128.0
	var dark: Color = Color("2f6a3a")
	var mid: Color = Color("4f9a45")
	var light: Color = Color("93cc58")
	match kind:
		"birch":
			dark = Color("5a8a3c")
			mid = Color("86bb4a")
			light = Color("c4e07a")
		"pine":
			dark = Color("1f5030")
			mid = Color("2f7040")
			light = Color("5ea052")
		"fruit":
			dark = Color("3a7a3a")
			mid = Color("5fa84c")
			light = Color("a3d460")
	var trunk_top: float = 250.0 if kind != "pine" else 330.0
	var trunk_w: float = 14.0 if kind != "birch" else 10.0
	canvas.polygon(PackedVector2Array([Vector2(base_x - trunk_w, 380.0), Vector2(base_x + trunk_w, 380.0), Vector2(base_x + trunk_w * 0.6, trunk_top), Vector2(base_x - trunk_w * 0.6, trunk_top)]), bark)
	canvas.polygon(PackedVector2Array([Vector2(base_x + trunk_w * 0.1, 380.0), Vector2(base_x + trunk_w, 380.0), Vector2(base_x + trunk_w * 0.6, trunk_top), Vector2(base_x + trunk_w * 0.1, trunk_top)]), bark.darkened(0.25))
	if kind == "birch":
		for mark: int in range(6):
			canvas.rect(base_x - trunk_w + rng.randf() * 6.0, 270.0 + float(mark) * 18.0, rng.randf_range(4.0, 9.0), 3.0, Color("3a3430"))
	var blobs: Array[Vector3] = []  # x, y, radius
	match kind:
		"oak":
			for i: int in range(70):
				var a: float = rng.randf() * TAU
				var r: float = sqrt(rng.randf()) * 84.0
				blobs.append(Vector3(128.0 + cos(a) * r, 150.0 + sin(a) * r * 0.82, rng.randf_range(20.0, 34.0)))
		"fruit":
			for i: int in range(55):
				var a: float = rng.randf() * TAU
				var r: float = sqrt(rng.randf()) * 62.0
				blobs.append(Vector3(128.0 + cos(a) * r, 170.0 + sin(a) * r * 0.8, rng.randf_range(16.0, 26.0)))
		"birch":
			for i: int in range(50):
				var a: float = rng.randf() * TAU
				var r: float = sqrt(rng.randf())
				blobs.append(Vector3(128.0 + cos(a) * r * 48.0, 140.0 + sin(a) * r * 92.0, rng.randf_range(14.0, 24.0)))
		"pine":
			for tier: int in range(5):
				var y: float = 80.0 + float(tier) * 50.0
				var half: float = 30.0 + float(tier) * 17.0
				for i: int in range(12):
					var t: float = float(i) / 11.0
					blobs.append(Vector3(128.0 + (t * 2.0 - 1.0) * half + rng.randf_range(-4, 4), y + absf(t - 0.5) * 34.0 + rng.randf_range(-6, 6), rng.randf_range(15.0, 23.0)))
	# painter's order: dark pass, mid pass, then light blobs nudged to the upper left (the sun side)
	for blob: Vector3 in blobs:
		canvas.circle(blob.x + 3.0, blob.y + 4.0, blob.z, dark, 2.5)
	for blob: Vector3 in blobs:
		canvas.circle(blob.x, blob.y, blob.z * 0.92, mid, 2.5)
	for blob: Vector3 in blobs:
		canvas.circle(blob.x - blob.z * 0.22, blob.y - blob.z * 0.26, blob.z * 0.55, light, 3.0)
	if kind == "fruit":
		for i: int in range(16):
			var blob: Vector3 = blobs[rng.randi() % blobs.size()]
			canvas.circle(blob.x + rng.randf_range(-8.0, 8.0), blob.y + rng.randf_range(-8.0, 8.0), 4.5, Color("e0483a") if i % 3 != 0 else Color("f0c03a"), 1.0)
	return canvas.image
