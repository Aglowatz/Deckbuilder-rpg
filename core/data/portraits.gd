class_name Portraits
extends RefCounted
## NPC dialogue portraits (docs/art/art_pipeline.md, "import portraits"): `assets/art/portraits/<Portrait Image ID>.webp`, e.g. NPC-ELDER.webp, with optional
## expression variants `NPC-ELDER_HAPPY.webp` (a missing expression falls back to the base portrait; a missing base means "no portrait" and the dialogue box
## shows no image). The importer copies from the read-only Drive folder in `art_config.cfg` (`portrait_dir`), keeps the transparent background (or removes a
## plain flat one), scales to HEIGHT px tall and writes lossy WebP with alpha. Nothing in the Drive folder is moved, renamed or deleted.

const OUT_DIR: String = "res://assets/art/portraits"
const MANIFEST_PATH: String = "res://data/source/portrait_import_manifest.csv"
const CONFIG_PATH: String = "res://data/source/art_config.cfg"
const STATUS_MARKER: String = "## Portraits"
const HEIGHT: int = 768
const QUALITY: float = 0.92
const INPUT_EXTENSIONS: Array[String] = ["png", "webp", "jpg", "jpeg"]
## A pixel whose largest channel differs from the flat background colour by at most this (0-1) is background.
const FLAT_TOLERANCE: float = 0.07

static var _textures: Dictionary = {}


## What an import run did.
class Result extends RefCounted:
	var added: Array[String] = []
	var replaced: Array[String] = []
	var unchanged: int = 0
	## Files (by name) whose flat background was removed.
	var background_removed: Array[String] = []
	## Image files whose name is not a Portrait Image ID (plus optional _EXPRESSION) of the NPC list.
	var unknown: Array[String] = []
	var errors: Array[String] = []
	## Portrait Image IDs of the list with a base image / without one.
	var have: Array[String] = []
	var missing: Array[String] = []


# ---- Loading --------------------------------------------------------------------------------


## The portrait texture for a Portrait Image ID and an optional expression ("happy"); the base portrait when the expression has no image; null when the
## NPC has no portrait at all.
static func texture_for(portrait_id: String, expression: String = "") -> Texture2D:
	if portrait_id.is_empty():
		return null
	var key: String = _key(portrait_id, expression)
	if _textures.has(key):
		return _textures[key] as Texture2D
	var texture: Texture2D = null
	if not expression.is_empty():
		texture = _load(_path(portrait_id, expression))
	if texture == null:
		texture = _load(_path(portrait_id, ""))
	if texture == null and PortraitPlaceholders.has(portrait_id):
		texture = PortraitPlaceholders.texture(portrait_id)
	_textures[key] = texture
	return texture


## True when the base portrait of `portrait_id` exists.
static func has_portrait(portrait_id: String) -> bool:
	return not portrait_id.is_empty() and ResourceLoader.exists(_path(portrait_id, ""))


## True when the exact expression image exists (not the fallback).
static func has_expression(portrait_id: String, expression: String) -> bool:
	return not expression.is_empty() and ResourceLoader.exists(_path(portrait_id, expression))


static func reset() -> void:
	_textures = {}


static func _key(portrait_id: String, expression: String) -> String:
	return "%s|%s" % [portrait_id, expression.to_lower()]


static func _path(portrait_id: String, expression: String) -> String:
	var suffix: String = "" if expression.is_empty() else "_" + expression.to_upper()
	return OUT_DIR.path_join("%s%s.webp" % [portrait_id, suffix])


static func _load(path: String) -> Texture2D:
	return load(path) as Texture2D if ResourceLoader.exists(path) else null


# ---- Import ---------------------------------------------------------------------------------


## The configured Drive folder (env PORTRAIT_SOURCE_DIR wins), "" when unset.
static func source_dir() -> String:
	var dir: String = OS.get_environment("PORTRAIT_SOURCE_DIR")
	if dir.is_empty():
		var config: ConfigFile = ConfigFile.new()
		if config.load(CONFIG_PATH) == OK:
			dir = str(config.get_value("art", "portrait_dir", ""))
	return dir.replace("\\", "/").rstrip("/")


## {Portrait Image ID -> NPC name} of the list (several NPCs never share an image).
static func known_portraits() -> Dictionary:
	var known: Dictionary = {}
	for entry: NpcRegistry.Entry in NpcRegistry.all():
		known[entry.portrait_id] = entry.plate_name()
	return known


## Splits "NPC-ELDER_HAPPY" into ["NPC-ELDER", "happy"] (the expression is "" for a base portrait).
static func split_name(base_name: String) -> PackedStringArray:
	var at: int = base_name.find("_")
	if at < 0:
		return PackedStringArray([base_name, ""])
	return PackedStringArray([base_name.substr(0, at), base_name.substr(at + 1).to_lower()])


## Copies `<ID>.png` and `<ID>_<EXPRESSION>.png` files from `source` (read-only) to `out_dir` as WebP. A file is re-imported when its MD5 differs from
## the manifest. One image is in memory at a time.
static func import_from_source(source: String, out_dir: String, manifest_path: String, known: Dictionary) -> Result:
	var result: Result = Result.new()
	DirAccess.make_dir_recursive_absolute(_real(out_dir))
	var manifest: Dictionary = ArtImporter.read_manifest(_real(manifest_path))
	var rows: Dictionary = {}
	var files: Array[String] = []
	for file_name: String in DirAccess.get_files_at(source):
		files.append(file_name)
	files.sort()
	for file_name: String in files:
		if not INPUT_EXTENSIONS.has(file_name.get_extension().to_lower()):
			continue
		var parts: PackedStringArray = split_name(file_name.get_basename())
		if not known.has(parts[0]):
			result.unknown.append(file_name)
			continue
		var key: String = file_name.get_basename()
		var full_path: String = source.path_join(file_name)
		var hash: String = FileAccess.get_md5(full_path)
		var target: String = _real(out_dir.path_join("%s%s.webp" % [parts[0], "" if parts[1].is_empty() else "_" + parts[1].to_upper()]))
		var had: bool = FileAccess.file_exists(target)
		rows[key] = PackedStringArray([key, file_name, str(_size(full_path)), hash])
		if had and str(manifest.get(key, "")) == hash:
			result.unchanged += 1
			continue
		var image: Image = Image.load_from_file(full_path)
		if image == null or image.is_empty():
			result.errors.append("%s: not a readable image" % file_name)
			rows.erase(key)
			continue
		image.convert(Image.FORMAT_RGBA8)
		if remove_flat_background(image):
			result.background_removed.append(file_name)
		var error: Error = scaled(image).save_webp(target, true, QUALITY)
		if error != OK:
			result.errors.append("%s: could not write (error %d)" % [file_name, error])
			rows.erase(key)
			continue
		result.added.append(key)
		if had:
			result.replaced.append(key)
	_write_manifest(_real(manifest_path), rows)
	var ids: Array = known.keys()
	ids.sort()
	for id: Variant in ids:
		if FileAccess.file_exists(_real(out_dir.path_join("%s.webp" % str(id)))):
			result.have.append(str(id))
		else:
			result.missing.append(str(id))
	reset()
	return result


## `image` scaled to HEIGHT px tall (never enlarged), colours bled into the transparent pixels first so the resize leaves no dark or light fringe.
static func scaled(image: Image) -> Image:
	var result: Image = image.duplicate() as Image
	if result.get_height() <= HEIGHT:
		return result
	result.fix_alpha_edges()
	var width: int = int(round(float(result.get_width()) * float(HEIGHT) / float(result.get_height())))
	result.resize(width, HEIGHT, Image.INTERPOLATE_LANCZOS)
	return result


## If `image` has a plain flat background (its border is opaque and one solid colour, e.g. light gray) instead of transparency, makes that background
## transparent: an edge-aware flood fill from the border with a soft alpha ramp, and the background colour un-mixed from the edge pixels so there is no halo.
## Returns true when it changed the image. Images that already have a transparent border are left alone.
static func remove_flat_background(image: Image) -> bool:
	var width: int = image.get_width()
	var height: int = image.get_height()
	var border: Array[Vector2i] = []
	for x: int in range(width):
		border.append(Vector2i(x, 0))
		border.append(Vector2i(x, height - 1))
	for y: int in range(1, height - 1):
		border.append(Vector2i(0, y))
		border.append(Vector2i(width - 1, y))
	var transparent: int = 0
	for point: Vector2i in border:
		if image.get_pixelv(point).a < 0.1:
			transparent += 1
	if float(transparent) / float(border.size()) > 0.5:
		return false
	var background: Color = _flat_colour(image, border)
	if background.a < 0.0:
		return false
	var data: PackedByteArray = image.get_data()
	var count: int = width * height
	# 1 = background: a flood fill from the border over pixels that match the flat colour.
	var mask: PackedByteArray = PackedByteArray()
	mask.resize(count)
	var stack: Array[int] = []
	for point: Vector2i in border:
		var index: int = point.y * width + point.x
		if mask[index] == 0 and _distance(data, index, background) <= FLAT_TOLERANCE:
			mask[index] = 1
			stack.append(index)
	while not stack.is_empty():
		var index: int = stack.pop_back()
		for next: int in _neighbours(index, width, height):
			if mask[next] == 0 and _distance(data, next, background) <= FLAT_TOLERANCE:
				mask[next] = 1
				stack.append(next)
	# 2 = edge band: the two rings of subject pixels next to the background (the antialiased edge).
	var frontier: Array[int] = []
	for index: int in range(count):
		if mask[index] != 1:
			continue
		for next: int in _neighbours(index, width, height):
			if mask[next] == 0:
				mask[next] = 2
				frontier.append(next)
	var second: Array[int] = []
	for index: int in frontier:
		for next: int in _neighbours(index, width, height):
			if mask[next] == 0:
				mask[next] = 2
				second.append(next)
	frontier.append_array(second)
	# Edge pixels: alpha from how far the pixel is from the background towards the nearby subject colour, then the background un-mixed.
	var edge: Array[int] = frontier
	var results: Dictionary = {}
	for index: int in edge:
		var x: int = index % width
		var y: int = index / width
		var sum: Vector3 = Vector3.ZERO
		var seen: int = 0
		for dy: int in range(-4, 5):
			for dx: int in range(-4, 5):
				var nx: int = x + dx
				var ny: int = y + dy
				if nx < 0 or ny < 0 or nx >= width or ny >= height:
					continue
				var neighbour: int = ny * width + nx
				if mask[neighbour] == 0:
					var offset: int = neighbour * 4
					sum += Vector3(data[offset], data[offset + 1], data[offset + 2]) / 255.0
					seen += 1
		var offset: int = index * 4
		var pixel: Vector3 = Vector3(data[offset], data[offset + 1], data[offset + 2]) / 255.0
		if seen == 0:
			results[index] = [pixel, 1.0]
			continue
		var subject: Vector3 = sum / float(seen)
		var base: Vector3 = Vector3(background.r, background.g, background.b)
		var span: Vector3 = subject - base
		var length_squared: float = span.length_squared()
		if length_squared < 0.0004:
			results[index] = [pixel, 1.0]
			continue
		var alpha: float = clampf((pixel - base).dot(span) / length_squared, 0.0, 1.0)
		if alpha < 0.02:
			results[index] = [pixel, 0.0]
			continue
		var colour: Vector3 = ((pixel - (1.0 - alpha) * base) / alpha).clamp(Vector3.ZERO, Vector3.ONE)
		results[index] = [colour, alpha]
	for index: int in results.keys():
		var offset: int = index * 4
		var entry: Array = results[index] as Array
		var colour: Vector3 = entry[0] as Vector3
		data[offset] = int(round(colour.x * 255.0))
		data[offset + 1] = int(round(colour.y * 255.0))
		data[offset + 2] = int(round(colour.z * 255.0))
		data[offset + 3] = int(round(float(entry[1]) * 255.0))
	for index: int in range(count):
		if mask[index] == 1:
			data[index * 4 + 3] = 0
	image.set_data(width, height, false, Image.FORMAT_RGBA8, data)
	return true


static func _neighbours(index: int, width: int, height: int) -> Array[int]:
	var result: Array[int] = []
	var x: int = index % width
	var y: int = index / width
	if x > 0:
		result.append(index - 1)
	if x < width - 1:
		result.append(index + 1)
	if y > 0:
		result.append(index - width)
	if y < height - 1:
		result.append(index + width)
	return result


## The flat colour of the border (the median of its opaque pixels) when at least 85% of the border is within tolerance of it; alpha -1 otherwise.
static func _flat_colour(image: Image, border: Array[Vector2i]) -> Color:
	var reds: Array[float] = []
	var greens: Array[float] = []
	var blues: Array[float] = []
	var stride: int = maxi(1, border.size() / 400)
	for index: int in range(0, border.size(), stride):
		var pixel: Color = image.get_pixelv(border[index])
		reds.append(pixel.r)
		greens.append(pixel.g)
		blues.append(pixel.b)
	reds.sort()
	greens.sort()
	blues.sort()
	var middle: int = reds.size() / 2
	var colour: Color = Color(reds[middle], greens[middle], blues[middle], 1.0)
	var close: int = 0
	for index: int in range(0, border.size(), stride):
		var pixel: Color = image.get_pixelv(border[index])
		if pixel.a > 0.9 and _colour_distance(pixel, colour) <= FLAT_TOLERANCE:
			close += 1
	if float(close) / float(reds.size()) < 0.85:
		return Color(0, 0, 0, -1.0)
	return colour


static func _colour_distance(a: Color, b: Color) -> float:
	return maxf(absf(a.r - b.r), maxf(absf(a.g - b.g), absf(a.b - b.b)))


static func _distance(data: PackedByteArray, index: int, background: Color) -> float:
	var offset: int = index * 4
	return maxf(absf(float(data[offset]) / 255.0 - background.r), maxf(absf(float(data[offset + 1]) / 255.0 - background.g), absf(float(data[offset + 2]) / 255.0 - background.b)))


static func _size(path: String) -> int:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	return 0 if file == null else file.get_length()


static func _write_manifest(path: String, rows: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.store_csv_line(PackedStringArray(["Portrait Image ID", "file", "bytes", "md5"]))
	var keys: Array = rows.keys()
	keys.sort()
	for key: Variant in keys:
		file.store_csv_line(rows[key] as PackedStringArray)
	file.close()


static func _real(path: String) -> String:
	return ProjectSettings.globalize_path(path)


# ---- Status ---------------------------------------------------------------------------------


## The "Portraits" section of docs/art/art_status.md: every NPC of the list, its Portrait Image ID, whether the base image exists and which expressions do.
static func status_markdown(out_dir: String = OUT_DIR) -> String:
	var rows: Array[String] = []
	var have: int = 0
	var entries: Array[NpcRegistry.Entry] = NpcRegistry.all()
	var variants: Dictionary = {}
	for file_name: String in DirAccess.get_files_at(_real(out_dir)):
		if file_name.get_extension().to_lower() == "webp":
			var parts: PackedStringArray = split_name(file_name.get_basename())
			if not parts[1].is_empty():
				variants[parts[0]] = (variants.get(parts[0], []) as Array) + [parts[1]]
	for entry: NpcRegistry.Entry in entries:
		var present: bool = FileAccess.file_exists(_real(out_dir.path_join("%s.webp" % entry.portrait_id)))
		have += 1 if present else 0
		var extra: Array = variants.get(entry.portrait_id, []) as Array
		extra.sort()
		rows.append("| %s | %s | %s | %s |" % [entry.portrait_id, entry.plate_name().replace("|", "/"), "yes" if present else "MISSING", ", ".join(extra) if not extra.is_empty() else ""])
	var lines: Array[String] = [
		STATUS_MARKER,
		"",
		"Generated by `tools/import_portraits`. Portraits load from `assets/art/portraits/<Portrait Image ID>.webp` (768 px tall, transparent background); an expression variant is `<ID>_<EXPRESSION>.webp`",
		"and falls back to the base portrait. An NPC without a portrait shows the dialogue box with no image.",
		"",
		"**%d of %d** NPCs have a portrait." % [have, entries.size()],
		"",
		"| Portrait Image ID | NPC | Image | Expressions in the game |",
		"|-------------------|-----|-------|-------------------------|",
	]
	lines.append_array(rows)
	return "\n".join(lines) + "\n"


## Replaces the section that starts with `marker` (up to the next "## " heading) in `text`; appends it when absent. Other sections stay as they are.
static func replace_section(text: String, marker: String, section: String) -> String:
	var start: int = -1
	if text.begins_with(marker + "\n"):
		start = 0
	else:
		var found: int = text.find("\n" + marker + "\n")
		if found >= 0:
			start = found + 1
	if start < 0:
		var base: String = text
		if not base.is_empty() and not base.ends_with("\n\n"):
			base += "\n" if base.ends_with("\n") else "\n\n"
		return base + section
	var next: int = text.find("\n## ", start + marker.length())
	var tail: String = "" if next < 0 else text.substr(next + 1)
	return text.substr(0, start) + section + ("\n" + tail if not tail.is_empty() else "")


## Rewrites the Portraits section of `status_path` (keeps every other section).
static func write_status(status_path: String) -> void:
	var text: String = FileAccess.get_file_as_string(status_path) if FileAccess.file_exists(status_path) else ""
	var file: FileAccess = FileAccess.open(status_path, FileAccess.WRITE)
	file.store_string(replace_section(text, STATUS_MARKER, status_markdown()))
	file.close()
