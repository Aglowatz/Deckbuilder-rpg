extends SceneTree
## Painted ground-texture test importer (docs/art/texture_test.md): COPIES (never writes to) the Drive's TEX-*.png files into _art_inbox/texture_src, makes each one truly
## seamless (half-offset cross-blend limited to a band round the edges, so the painted detail inside stays untouched), then writes
## assets/art/textures/<name>_albedo.webp, <name>_normal.webp (OpenGL tangent space: +Y is up in the image) and <name>_rough.webp.
## The normal map comes from a lightly blurred luminance height (so the brush strokes give soft relief, not noise); roughness from the luminance and a per-texture base.
## Run: bash tools/import_texture_test.sh

const SOURCE_DIRS: Array[String] = ["G:/My Drive/Card Game Art/Texture_Test", "G:/My Drive/Card Game Art/Texture_test", "G:/My Drive/Card Game Art/Texture_Test_Approved", "G:/My Drive/Card Game Art/Texture_test_approved"]
const INBOX: String = "res://_art_inbox/texture_src"
const OUT: String = "res://assets/art/textures"
## [source id, output name, seam band (fraction of the width blended on each side), normal strength, roughness base, roughness luminance gain]
const TEXTURES: Array = [
	["TEX-TOWN-GRASS", "town_grass", 0.16, 2.2, 0.92, 0.25],
	["TEX-TOWN-WILDFLOWER", "town_wildflower", 0.16, 1.8, 0.9, 0.3],
	["TEX-TOWN-STONE", "town_stone", 0.12, 3.2, 0.82, 0.55],
]


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(INBOX))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var source: String = _find_source()
	if source == "":
		push_error("no Texture_Test folder with TEX-*.png files found on the Drive")
		quit(1)
		return
	print("source: %s" % source)
	var files: PackedStringArray = DirAccess.get_files_at(source)
	for file_name: String in files:
		if file_name.begins_with("TEX-"):
			print("found: %s" % file_name)
	for entry: Array in TEXTURES:
		var file_name: String = "%s.png" % str(entry[0])
		if not files.has(file_name):
			print("MISSING: %s (skipped)" % file_name)
			continue
		var copied: String = ProjectSettings.globalize_path(INBOX).path_join(file_name)
		if DirAccess.copy_absolute(source.path_join(file_name), copied) != OK:
			push_error("cannot copy %s" % file_name)
			continue
		_convert(Image.load_from_file(copied), entry)
	quit(0)


func _find_source() -> String:
	for dir: String in SOURCE_DIRS:
		if DirAccess.dir_exists_absolute(dir) and not DirAccess.get_files_at(dir).is_empty():
			return dir
	return ""


func _convert(image: Image, entry: Array) -> void:
	var out_name: String = str(entry[1])
	image.convert(Image.FORMAT_RGBA8)
	var w: int = image.get_width()
	var h: int = image.get_height()
	var before: float = _seam_ratio(image)
	var seamless: Image = _make_seamless(image, float(entry[2]))
	var after: float = _seam_ratio(seamless)
	print("%s: %dx%d  seam step / normal step  before %.2f  after %.2f  (1.0 = invisible)" % [out_name, w, h, before, after])
	var luma: PackedFloat32Array = _luminance(seamless)
	var height: PackedFloat32Array = _blur(_blur(luma, w, h), w, h)
	var normal: Image = _normal_map(height, w, h, float(entry[3]))
	var rough: Image = _rough_map(luma, w, h, float(entry[4]), float(entry[5]))
	var base: String = ProjectSettings.globalize_path(OUT).path_join(out_name)
	seamless.convert(Image.FORMAT_RGB8)
	print("  save albedo: %s" % error_string(seamless.save_webp("%s_albedo.webp" % base, true, 0.95)))
	print("  save normal: %s" % error_string(normal.save_webp("%s_normal.webp" % base, false)))
	print("  save rough:  %s" % error_string(rough.save_webp("%s_rough.webp" % base, false)))


## How much bigger the pixel step across the wrap-around edge is than the average step between neighbouring columns/rows (1.0 = no seam).
func _seam_ratio(image: Image) -> float:
	var w: int = image.get_width()
	var h: int = image.get_height()
	var edge: float = 0.0
	var inner: float = 0.0
	for y: int in range(h):
		edge += _diff(image.get_pixel(w - 1, y), image.get_pixel(0, y))
		for x: int in range(0, w - 1, 8):
			inner += _diff(image.get_pixel(x, y), image.get_pixel(x + 1, y))
	for x: int in range(w):
		edge += _diff(image.get_pixel(x, h - 1), image.get_pixel(x, 0))
		for y: int in range(0, h - 1, 8):
			inner += _diff(image.get_pixel(x, y), image.get_pixel(x, y + 1))
	var edge_mean: float = edge / float(w + h)
	var inner_mean: float = inner / float((w * ((h - 1) / 8 + 1)) + (h * ((w - 1) / 8 + 1)))
	return edge_mean / maxf(inner_mean, 0.0001)


func _diff(a: Color, b: Color) -> float:
	return (absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b)) / 3.0


## Result = image in the middle, the half-offset copy at the borders, cross-faded over `band` of the width. The offset copy is continuous across the original
## borders (they sit in its middle), and the middle is untouched, so the wrap-around edge is seamless and most of the painting is the original.
func _make_seamless(image: Image, band: float) -> Image:
	var w: int = image.get_width()
	var h: int = image.get_height()
	var result: Image = Image.create(w, h, false, Image.FORMAT_RGBA8)
	for y: int in range(h):
		var wy: float = _edge_weight(float(y) / float(h), band)
		for x: int in range(w):
			var weight: float = minf(_edge_weight(float(x) / float(w), band), wy)
			var own: Color = image.get_pixel(x, y)
			if weight >= 1.0:
				result.set_pixel(x, y, own)
				continue
			var shifted: Color = image.get_pixel((x + w / 2) % w, (y + h / 2) % h)
			result.set_pixel(x, y, shifted.lerp(own, weight))
	return result


## 0 on the border, 1 from `band` inwards, smooth in between (same on both sides).
func _edge_weight(t: float, band: float) -> float:
	var d: float = minf(t, 1.0 - t) / band
	return smoothstep(0.0, 1.0, clampf(d, 0.0, 1.0))


func _luminance(image: Image) -> PackedFloat32Array:
	var w: int = image.get_width()
	var h: int = image.get_height()
	var out: PackedFloat32Array = PackedFloat32Array()
	out.resize(w * h)
	for y: int in range(h):
		for x: int in range(w):
			var c: Color = image.get_pixel(x, y)
			out[y * w + x] = c.r * 0.299 + c.g * 0.587 + c.b * 0.114
	return out


## 5-tap wrap-around box-ish blur (separable, radius 2).
func _blur(src: PackedFloat32Array, w: int, h: int) -> PackedFloat32Array:
	var tmp: PackedFloat32Array = PackedFloat32Array()
	tmp.resize(w * h)
	for y: int in range(h):
		for x: int in range(w):
			var sum: float = 0.0
			for k: int in range(-2, 3):
				sum += src[y * w + posmod(x + k, w)]
			tmp[y * w + x] = sum / 5.0
	var out: PackedFloat32Array = PackedFloat32Array()
	out.resize(w * h)
	for y: int in range(h):
		for x: int in range(w):
			var sum: float = 0.0
			for k: int in range(-2, 3):
				sum += tmp[posmod(y + k, h) * w + x]
			out[y * w + x] = sum / 5.0
	return out


func _normal_map(height: PackedFloat32Array, w: int, h: int, strength: float) -> Image:
	var image: Image = Image.create(w, h, false, Image.FORMAT_RGB8)
	for y: int in range(h):
		for x: int in range(w):
			var dx: float = height[y * w + posmod(x + 1, w)] - height[y * w + posmod(x - 1, w)]
			var dy: float = height[posmod(y + 1, h) * w + x] - height[posmod(y - 1, h) * w + x]
			var n: Vector3 = Vector3(-dx * strength * 4.0, dy * strength * 4.0, 1.0).normalized()
			image.set_pixel(x, y, Color(n.x * 0.5 + 0.5, n.y * 0.5 + 0.5, n.z * 0.5 + 0.5))
	return image


func _rough_map(luma: PackedFloat32Array, w: int, h: int, base: float, gain: float) -> Image:
	var low: float = INF
	var high: float = -INF
	var mean: float = 0.0
	for value: float in luma:
		low = minf(low, value)
		high = maxf(high, value)
		mean += value
	mean /= float(luma.size())
	var spread: float = maxf(high - low, 0.001)
	var image: Image = Image.create(w, h, false, Image.FORMAT_L8)
	for y: int in range(h):
		for x: int in range(w):
			var rough: float = clampf(base - (luma[y * w + x] - mean) / spread * gain * 2.0, 0.3, 1.0)
			image.set_pixel(x, y, Color(rough, rough, rough))
	return image
