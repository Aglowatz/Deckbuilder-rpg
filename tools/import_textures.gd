extends SceneTree
## Painted texture importer ("import textures", docs/art/art_pipeline.md and docs/art/style_guide.md, section "Painted textures"). Reads data/source/textures.csv (rows whose first
## column starts with TEX- or DEC-), COPIES the matching PNGs from the Drive (texture_dir in data/source/art_config.cfg, or TEXTURE_SOURCE_DIR; read-only, nothing there is ever moved,
## renamed or deleted) into _art_inbox/texture_src, then writes:
##  - assets/art/textures/<name>_albedo.webp  1024 px, truly seamless (half-offset cross-blend limited to a band round the edges, the painted middle stays untouched)
##  - assets/art/textures/<name>_nr.webp      512 px: R,G = tangent-space normal (OpenGL, +Y up, from a soft blurred luminance height), B = roughness
##  - assets/art/decals/<name>.webp           512 px RGBA: transparent background kept (a plain gray background is flood-removed when present), colour bled under the transparent area
## <name> = the ID without its TEX-/DEC- prefix, lower case, '-' -> '_' (TEX-MAT-ROOF-RED -> mat_roof_red, DEC-MOSS -> moss).
## Writes data/source/texture_import_manifest.csv and prints the missing IDs and unmatched files. Options (after --): --only=ID,ID  --skip-existing
## Run: bash tools/import_textures.sh [--only=TEX-MAT-ROCK] [--skip-existing]

const CONFIG: String = "res://data/source/art_config.cfg"
const CSV_PATHS: Array[String] = ["res://data/source/textures.csv", "res://data/source/textures.csv.csv"]
const INBOX: String = "res://_art_inbox/texture_src"
const OUT_TEX: String = "res://assets/art/textures"
const OUT_DEC: String = "res://assets/art/decals"
const MANIFEST: String = "res://data/source/texture_import_manifest.csv"
const SIZE: int = 1024
const NR_SIZE: int = 512
const DECAL_SIZE: int = 512
const DEFAULT_BAND: float = 0.14
## Per-name overrides: [seam band, normal strength, roughness base, roughness luminance gain]. Everything else uses DEFAULTS.
const DEFAULTS: Array = [DEFAULT_BAND, 2.0, 0.9, 0.3]
const SETTINGS: Dictionary = {
	"town_grass": [0.16, 2.2, 0.92, 0.25],
	"town_wildflower": [0.16, 1.8, 0.9, 0.3],
	"town_stone": [0.12, 3.2, 0.82, 0.55],
	"mat_stonewall": [0.1, 3.0, 0.85, 0.5],
	"mat_brick": [0.08, 3.0, 0.85, 0.5],
	"mat_rock": [0.14, 3.4, 0.9, 0.45],
	"mat_metal": [0.1, 2.4, 0.6, 0.6],
	"mat_woodplanks": [0.1, 2.4, 0.85, 0.4],
	"mat_roof_red": [0.1, 2.6, 0.85, 0.4],
	"mat_roof_blue": [0.1, 2.6, 0.8, 0.4],
	"gain_gymmat": [0.08, 1.6, 0.8, 0.3],
	"gain_islandrock": [0.14, 3.4, 0.9, 0.45],
	"buff_cheese": [0.14, 2.2, 0.45, 0.3],
	"buff_gravy": [0.14, 1.2, 0.2, 0.3],
	"buff_frosting": [0.14, 1.6, 0.5, 0.3],
	"dna_checkertile": [0.06, 1.6, 0.55, 0.3],
	"dna_marble": [0.12, 1.2, 0.4, 0.3],
	"dump_rustmetal": [0.12, 2.4, 0.7, 0.5],
	"cap_pastelplaza": [0.06, 1.2, 0.45, 0.2],
	"cap_whitewall": [0.08, 2.0, 0.55, 0.3],
	"cap_crackedroad": [0.1, 3.0, 0.9, 0.5],
	"castle_marble": [0.12, 1.0, 0.25, 0.3],
	"castle_parquet": [0.06, 1.4, 0.35, 0.3],
}

var _only: PackedStringArray = PackedStringArray()
var _skip_existing: bool = false


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--only="):
			_only = arg.substr(7).split(",", false)
		elif arg == "--skip-existing":
			_skip_existing = true
	for path: String in [INBOX, OUT_TEX, OUT_DEC]:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path))
	var entries: Array[Dictionary] = _read_csv()
	if entries.is_empty():
		push_error("no TEX-/DEC- rows found in data/source/textures.csv")
		quit(1)
		return
	var source: String = _source_dir()
	print("source: %s (%d CSV rows)" % [source, entries.size()])
	var files: PackedStringArray = DirAccess.get_files_at(source) if source != "" else PackedStringArray()
	var by_id: Dictionary = {}
	for file_name: String in files:
		if file_name.get_extension().to_lower() in ["png", "jpg", "jpeg", "webp"]:
			by_id[file_name.get_basename().to_upper()] = file_name
	var manifest: PackedStringArray = PackedStringArray(["id,name,kind,source_file,status,seam_before,seam_after"])
	var missing: PackedStringArray = PackedStringArray()
	var known: Dictionary = {}
	for entry: Dictionary in entries:
		var id: String = str(entry["id"])
		known[id] = true
		if not by_id.has(id):
			missing.append(id)
			manifest.append("%s,%s,%s,,MISSING,," % [id, _name_of(id), entry["kind"]])
			continue
		if not _only.is_empty() and not _only.has(id):
			continue
		var out_name: String = _name_of(id)
		if _skip_existing and FileAccess.file_exists("%s/%s" % [OUT_DEC if id.begins_with("DEC-") else OUT_TEX, "%s.webp" % out_name if id.begins_with("DEC-") else "%s_albedo.webp" % out_name]):
			manifest.append("%s,%s,%s,%s,skipped,," % [id, out_name, entry["kind"], by_id[id]])
			continue
		var copied: String = ProjectSettings.globalize_path(INBOX).path_join(str(by_id[id]))
		if DirAccess.copy_absolute(source.path_join(str(by_id[id])), copied) != OK:
			push_error("cannot copy %s" % by_id[id])
			continue
		var image: Image = Image.load_from_file(copied)
		if image == null:
			push_error("cannot read %s" % copied)
			continue
		if id.begins_with("DEC-"):
			_convert_decal(image, id, out_name)
			manifest.append("%s,%s,decal,%s,ok,," % [id, out_name, by_id[id]])
		else:
			var seams: Vector2 = _convert_texture(image, id, out_name)
			manifest.append("%s,%s,texture,%s,ok,%.2f,%.2f" % [id, out_name, by_id[id], seams.x, seams.y])
	var unmatched: PackedStringArray = PackedStringArray()
	for id: String in by_id.keys():
		if not known.has(id):
			unmatched.append(str(by_id[id]))
			manifest.append(",,,%s,UNMATCHED_FILE,," % by_id[id])
	var manifest_file: FileAccess = FileAccess.open(MANIFEST, FileAccess.WRITE)
	manifest_file.store_string("\n".join(manifest) + "\n")
	manifest_file.close()
	print("MISSING IDs (%d): %s" % [missing.size(), ", ".join(missing) if not missing.is_empty() else "none"])
	print("UNMATCHED files (%d): %s" % [unmatched.size(), ", ".join(unmatched) if not unmatched.is_empty() else "none"])
	quit(0)


func _source_dir() -> String:
	var env: String = OS.get_environment("TEXTURE_SOURCE_DIR")
	if env != "":
		return env
	var config: ConfigFile = ConfigFile.new()
	if config.load(CONFIG) == OK:
		var dir: String = str(config.get_value("art", "texture_dir", ""))
		if dir != "" and DirAccess.dir_exists_absolute(dir):
			var lower: String = dir.to_lower()
			if lower.contains("pending review") or lower.contains("superseded"):
				push_error("refusing to read from %s" % dir)
				return ""
			return dir
	return ""


func _name_of(id: String) -> String:
	var base: String = id.trim_prefix("TEX-").trim_prefix("DEC-")
	return base.to_lower().replace("-", "_")


func _read_csv() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for path: String in CSV_PATHS:
		if not FileAccess.file_exists(path):
			continue
		var file: FileAccess = FileAccess.open(path, FileAccess.READ)
		while not file.eof_reached():
			var row: PackedStringArray = file.get_csv_line()
			if row.size() < 4:
				continue
			var id: String = row[0].strip_edges()
			if id.begins_with("TEX-") or id.begins_with("DEC-"):
				result.append({"id": id, "zone": row[2], "category": row[3], "use": row[4] if row.size() > 4 else "", "kind": "decal" if id.begins_with("DEC-") else "texture"})
		break
	return result


# ---- Textures ---------------------------------------------------------------------------------------------


func _convert_texture(image: Image, id: String, out_name: String) -> Vector2:
	var params: Array = SETTINGS.get(out_name, DEFAULTS) as Array
	image.convert(Image.FORMAT_RGB8)
	if image.get_width() != SIZE or image.get_height() != SIZE:
		image.resize(SIZE, SIZE, Image.INTERPOLATE_LANCZOS)
	var before: float = _seam_ratio(image)
	var seamless: Image = _make_seamless(image, float(params[0]))
	var after: float = _seam_ratio(seamless)
	print("%s -> %s: seam step / normal step  before %.2f  after %.2f  (1.0 = invisible)" % [id, out_name, before, after])
	var base: String = ProjectSettings.globalize_path(OUT_TEX).path_join(out_name)
	var small: Image = seamless.duplicate() as Image
	small.resize(NR_SIZE, NR_SIZE, Image.INTERPOLATE_BILINEAR)
	var nr: Image = _normal_rough(small, float(params[1]), float(params[2]), float(params[3]))
	_write_import_params("%s_albedo.webp" % out_name, true)
	_write_import_params("%s_nr.webp" % out_name, false)
	seamless.save_webp("%s_albedo.webp" % base, true, 0.95)
	nr.save_webp("%s_nr.webp" % base, false)
	return Vector2(before, after)


## Albedo is VRAM-compressed (the dev PC is a fill-rate bound iGPU); the normal+roughness pack stays lossless so the data channels are exact.
func _write_import_params(file_name: String, albedo: bool) -> void:
	var path: String = "%s/%s.import" % [OUT_TEX, file_name]
	if FileAccess.file_exists(path):
		return
	var text: String = "[remap]\n\nimporter=\"texture\"\ntype=\"CompressedTexture2D\"\n\n[deps]\n\nsource_file=\"res://assets/art/textures/%s\"\n\n[params]\n\n" % file_name
	text += "compress/mode=%d\ncompress/high_quality=false\ncompress/lossy_quality=0.7\ncompress/uastc_level=0\ncompress/rdo_quality_loss=0.0\ncompress/hdr_compression=1\ncompress/normal_map=0\ncompress/channel_pack=0\nmipmaps/generate=true\nmipmaps/limit=-1\nroughness/mode=0\nroughness/src_normal=\"\"\nprocess/channel_remap/red=0\nprocess/channel_remap/green=1\nprocess/channel_remap/blue=2\nprocess/channel_remap/alpha=3\nprocess/fix_alpha_border=true\nprocess/premult_alpha=false\nprocess/normal_map_invert_y=false\nprocess/hdr_as_srgb=false\nprocess/hdr_clamp_exposure=false\nprocess/size_limit=0\ndetect_3d/compress_to=0\n" % (2 if albedo else 0)
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()


## How much bigger the pixel step across the wrap-around edge is than the average step between neighbouring columns/rows (1.0 = no seam).
func _seam_ratio(image: Image) -> float:
	var w: int = image.get_width()
	var h: int = image.get_height()
	var data: PackedByteArray = image.get_data()
	var edge: float = 0.0
	var inner: float = 0.0
	var inner_count: int = 0
	for y: int in range(0, h, 2):
		edge += _byte_diff(data, (y * w + w - 1) * 3, (y * w) * 3)
		for x: int in range(0, w - 1, 16):
			inner += _byte_diff(data, (y * w + x) * 3, (y * w + x + 1) * 3)
			inner_count += 1
	for x: int in range(0, w, 2):
		edge += _byte_diff(data, ((h - 1) * w + x) * 3, x * 3)
		for y: int in range(0, h - 1, 16):
			inner += _byte_diff(data, (y * w + x) * 3, ((y + 1) * w + x) * 3)
			inner_count += 1
	var edge_mean: float = edge / float(h / 2 + w / 2)
	var inner_mean: float = inner / float(maxi(inner_count, 1))
	return edge_mean / maxf(inner_mean, 0.0001)


func _byte_diff(data: PackedByteArray, a: int, b: int) -> float:
	return float(absi(int(data[a]) - int(data[b])) + absi(int(data[a + 1]) - int(data[b + 1])) + absi(int(data[a + 2]) - int(data[b + 2]))) / 765.0


## Result = image in the middle, the half-offset copy at the borders, cross-faded over `band` of the width. The offset copy is continuous across the original
## borders (they sit in its middle), and the middle is untouched, so the wrap-around edge is seamless and most of the painting is the original.
func _make_seamless(image: Image, band: float) -> Image:
	var w: int = image.get_width()
	var h: int = image.get_height()
	var src: PackedByteArray = image.get_data()
	var out: PackedByteArray = src.duplicate()
	var weights: PackedFloat32Array = PackedFloat32Array()
	weights.resize(w)
	for i: int in range(w):
		weights[i] = _edge_weight(float(i) / float(w), band)
	var band_px: int = int(ceil(band * float(w))) + 1
	for y: int in range(h):
		var wy: float = weights[y]
		var full_row: bool = wy < 1.0
		var sy: int = (y + h / 2) % h
		for x: int in range(w):
			if not full_row and x >= band_px and x < w - band_px:
				continue
			var weight: float = minf(weights[x], wy)
			if weight >= 1.0:
				continue
			var own: int = (y * w + x) * 3
			var shifted: int = (sy * w + (x + w / 2) % w) * 3
			for c: int in range(3):
				out[own + c] = int(round(float(src[shifted + c]) * (1.0 - weight) + float(src[own + c]) * weight))
	return Image.create_from_data(w, h, false, Image.FORMAT_RGB8, out)


## 0 on the border, 1 from `band` inwards, smooth in between (same on both sides).
func _edge_weight(t: float, band: float) -> float:
	var d: float = minf(t, 1.0 - t) / band
	return smoothstep(0.0, 1.0, clampf(d, 0.0, 1.0))


## R,G = normal from a soft (twice blurred) luminance height, B = roughness (light = smoother, dark = rougher), wrap-around.
func _normal_rough(image: Image, strength: float, base: float, gain: float) -> Image:
	var w: int = image.get_width()
	var h: int = image.get_height()
	var data: PackedByteArray = image.get_data()
	var luma: PackedFloat32Array = PackedFloat32Array()
	luma.resize(w * h)
	var low: float = INF
	var high: float = -INF
	var mean: float = 0.0
	for i: int in range(w * h):
		var value: float = (float(data[i * 3]) * 0.299 + float(data[i * 3 + 1]) * 0.587 + float(data[i * 3 + 2]) * 0.114) / 255.0
		luma[i] = value
		low = minf(low, value)
		high = maxf(high, value)
		mean += value
	mean /= float(w * h)
	var spread: float = maxf(high - low, 0.001)
	var height: PackedFloat32Array = _blur(_blur(luma, w, h), w, h)
	var out: PackedByteArray = PackedByteArray()
	out.resize(w * h * 3)
	for y: int in range(h):
		var ym: int = posmod(y - 1, h) * w
		var yp: int = posmod(y + 1, h) * w
		for x: int in range(w):
			var i: int = y * w + x
			var dx: float = height[y * w + posmod(x + 1, w)] - height[y * w + posmod(x - 1, w)]
			var dy: float = height[yp + x] - height[ym + x]
			var n: Vector3 = Vector3(-dx * strength * 4.0, dy * strength * 4.0, 1.0).normalized()
			var rough: float = clampf(base - (luma[i] - mean) / spread * gain * 2.0, 0.2, 1.0)
			out[i * 3] = int(clampf(n.x * 0.5 + 0.5, 0.0, 1.0) * 255.0)
			out[i * 3 + 1] = int(clampf(n.y * 0.5 + 0.5, 0.0, 1.0) * 255.0)
			out[i * 3 + 2] = int(rough * 255.0)
	return Image.create_from_data(w, h, false, Image.FORMAT_RGB8, out)


## 3-tap separable wrap-around blur.
func _blur(src: PackedFloat32Array, w: int, h: int) -> PackedFloat32Array:
	var tmp: PackedFloat32Array = PackedFloat32Array()
	tmp.resize(w * h)
	for y: int in range(h):
		var row: int = y * w
		for x: int in range(w):
			tmp[row + x] = (src[row + posmod(x - 1, w)] + src[row + x] * 2.0 + src[row + posmod(x + 1, w)]) * 0.25
	var out: PackedFloat32Array = PackedFloat32Array()
	out.resize(w * h)
	for y: int in range(h):
		var up: int = posmod(y - 1, h) * w
		var down: int = posmod(y + 1, h) * w
		var row: int = y * w
		for x: int in range(w):
			out[row + x] = (tmp[up + x] + tmp[row + x] * 2.0 + tmp[down + x]) * 0.25
	return out


# ---- Decals -----------------------------------------------------------------------------------------------


func _convert_decal(image: Image, id: String, out_name: String) -> void:
	image.convert(Image.FORMAT_RGBA8)
	image.resize(DECAL_SIZE, DECAL_SIZE, Image.INTERPOLATE_LANCZOS)
	var w: int = image.get_width()
	var h: int = image.get_height()
	var data: PackedByteArray = image.get_data()
	var removed: int = _remove_plain_background(data, w, h)
	# Near-invisible pixels become fully transparent; the colour under the transparent area is bled from the painted edge so mip-maps and filtering never show a gray fringe.
	var sum: Vector3 = Vector3.ZERO
	var weight: float = 0.0
	for i: int in range(w * h):
		var a: int = data[i * 4 + 3]
		if a < 6:
			data[i * 4 + 3] = 0
		elif a > 200:
			sum += Vector3(data[i * 4], data[i * 4 + 1], data[i * 4 + 2])
			weight += 1.0
	var average: Vector3 = sum / maxf(weight, 1.0)
	for i: int in range(w * h):
		if data[i * 4 + 3] < 40:
			var keep: float = float(data[i * 4 + 3]) / 40.0
			data[i * 4] = int(lerpf(average.x, float(data[i * 4]), keep))
			data[i * 4 + 1] = int(lerpf(average.y, float(data[i * 4 + 1]), keep))
			data[i * 4 + 2] = int(lerpf(average.z, float(data[i * 4 + 2]), keep))
	var result: Image = Image.create_from_data(w, h, false, Image.FORMAT_RGBA8, data)
	var path: String = ProjectSettings.globalize_path(OUT_DEC).path_join("%s.webp" % out_name)
	var import_path: String = "%s/%s.webp.import" % [OUT_DEC, out_name]
	if not FileAccess.file_exists(import_path):
		var text: String = "[remap]\n\nimporter=\"texture\"\ntype=\"CompressedTexture2D\"\n\n[deps]\n\nsource_file=\"res://assets/art/decals/%s.webp\"\n\n[params]\n\ncompress/mode=0\ncompress/high_quality=false\ncompress/lossy_quality=0.7\ncompress/uastc_level=0\ncompress/rdo_quality_loss=0.0\ncompress/hdr_compression=1\ncompress/normal_map=0\ncompress/channel_pack=0\nmipmaps/generate=true\nmipmaps/limit=-1\nroughness/mode=0\nroughness/src_normal=\"\"\nprocess/channel_remap/red=0\nprocess/channel_remap/green=1\nprocess/channel_remap/blue=2\nprocess/channel_remap/alpha=3\nprocess/fix_alpha_border=true\nprocess/premult_alpha=false\nprocess/normal_map_invert_y=false\nprocess/hdr_as_srgb=false\nprocess/hdr_clamp_exposure=false\nprocess/size_limit=0\ndetect_3d/compress_to=0\n" % out_name
		var file: FileAccess = FileAccess.open(import_path, FileAccess.WRITE)
		file.store_string(text)
		file.close()
	result.save_webp(path, false)
	print("%s -> %s: decal %dx%d%s" % [id, out_name, w, h, ("  (removed %d px of plain background)" % removed) if removed > 0 else ""])


## When the picture has an opaque plain gray/white/black background (all four corners opaque and nearly the same low-saturation colour), flood it away from the corners with a
## soft edge. Decals that already have a transparent background are left alone.
func _remove_plain_background(data: PackedByteArray, w: int, h: int) -> int:
	var corners: Array[int] = [0, (w - 1) * 4, (h - 1) * w * 4, ((h - 1) * w + w - 1) * 4]
	var ref: Color = Color8(data[corners[0]], data[corners[0] + 1], data[corners[0] + 2], data[corners[0] + 3])
	for corner: int in corners:
		if data[corner + 3] < 250:
			return 0
		var c: Color = Color8(data[corner], data[corner + 1], data[corner + 2], 255)
		if absf(c.r - ref.r) + absf(c.g - ref.g) + absf(c.b - ref.b) > 0.12 or c.s > 0.12:
			return 0
	var visited: PackedByteArray = PackedByteArray()
	visited.resize(w * h)
	var stack: PackedInt32Array = PackedInt32Array()
	for corner: int in corners:
		stack.append(corner / 4)
	var removed: int = 0
	while not stack.is_empty():
		var index: int = stack[stack.size() - 1]
		stack.resize(stack.size() - 1)
		if visited[index] == 1:
			continue
		visited[index] = 1
		var p: int = index * 4
		var diff: float = (absf(float(data[p]) / 255.0 - ref.r) + absf(float(data[p + 1]) / 255.0 - ref.g) + absf(float(data[p + 2]) / 255.0 - ref.b))
		if diff > 0.14:
			# Soft edge: partly transparent right at the boundary.
			data[p + 3] = int(clampf((diff - 0.14) / 0.12, 0.0, 1.0) * float(data[p + 3]))
			continue
		data[p + 3] = 0
		removed += 1
		var x: int = index % w
		var y: int = index / w
		if x > 0:
			stack.append(index - 1)
		if x < w - 1:
			stack.append(index + 1)
		if y > 0:
			stack.append(index - w)
		if y < h - 1:
			stack.append(index + w)
	return removed
