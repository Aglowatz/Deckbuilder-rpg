extends SceneTree
## Graphics Tier 1, Part 2 (docs/art/graphics_tier1.md): generates a soft normal map for every painted character frame so lanterns, the sun and effect lights
## shade the cards (world_sprite.gdshader `use_normal`). Height = a "pillow" from the blurred alpha (the figure's silhouette rounds off towards its edges, the
## part that matters for a side light) plus a little painted relief from the blurred luminance (highlights raised), smoothed, at HALF the frame's resolution
## (a normal map of a painting wants no brush detail: it must stay painterly, never plastic). Written next to the frame as <FRAME>_n.png.
##   Godot --headless --path . -s res://tools/sprite_normals.gd -- [--only=PLAYER,ELDER] [--force=true] [--hats=true]
## Skips frames whose _n.png is newer than the frame unless --force. Prints the count and the bytes written.

const SPRITES: String = "res://assets/art/world_test/sprites/"
const HATS: String = "res://assets/art/cosmetics/hats/"
const PILLOW: float = 0.7
const RELIEF: float = 0.3
const STRENGTH: float = 2.6


func _initialize() -> void:
	var args: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	var only: PackedStringArray = str(args.get("only", "")).split(",", false)
	var force: bool = str(args.get("force", "false")) == "true"
	var folders: Array[String] = [SPRITES]
	if str(args.get("hats", "true")) == "true":
		folders.append(HATS)
	var written: int = 0
	var skipped: int = 0
	var bytes: int = 0
	var started: int = Time.get_ticks_msec()
	for folder: String in folders:
		if not DirAccess.dir_exists_absolute(folder):
			continue
		for character: String in DirAccess.get_directories_at(folder):
			if not only.is_empty() and not only.has(character):
				continue
			var dir: String = folder.path_join(character)
			for file_name: String in DirAccess.get_files_at(dir):
				if not file_name.ends_with(".png") or file_name.ends_with("_n.png"):
					continue
				var source: String = dir.path_join(file_name)
				var target: String = dir.path_join(file_name.get_basename() + "_n.png")
				if not force and FileAccess.file_exists(target) and FileAccess.get_modified_time(target) >= FileAccess.get_modified_time(source):
					skipped += 1
					continue
				var image: Image = Image.load_from_file(ProjectSettings.globalize_path(source))
				if image == null:
					print("sprite_normals: cannot read %s" % source)
					continue
				var normal: Image = make_normal_map(image)
				var error: Error = normal.save_png(ProjectSettings.globalize_path(target))
				if error != OK:
					print("sprite_normals: cannot write %s (%s)" % [target, error_string(error)])
					continue
				bytes += FileAccess.get_file_as_bytes(target).size()
				written += 1
	print("sprite_normals: wrote %d normal maps (%d up to date) = %.1f MB in %.1f s" % [written, skipped, float(bytes) / 1048576.0, float(Time.get_ticks_msec() - started) / 1000.0])
	quit(0)


## The normal map of one frame at half resolution (RGB8: x right, y up, z out, each 0..1).
static func make_normal_map(source: Image) -> Image:
	var image: Image = source.duplicate() as Image
	image.convert(Image.FORMAT_RGBA8)
	var width: int = maxi(source.get_width() / 2, 8)
	var height: int = maxi(source.get_height() / 2, 8)
	image.resize(width, height, Image.INTERPOLATE_LANCZOS)
	# Height field: pillow (two wide blurs of the alpha) + relief (a mild blur of the luminance), only where the figure is.
	var alpha_wide: Image = _channel_blur(image, true, 8)
	var alpha_mid: Image = _channel_blur(image, true, 4)
	var luma: Image = _channel_blur(image, false, 2)
	var heights: PackedFloat32Array = PackedFloat32Array()
	heights.resize(width * height)
	for y: int in range(height):
		for x: int in range(width):
			var a: float = image.get_pixel(x, y).a
			var pillow: float = 0.5 * (alpha_wide.get_pixel(x, y).r + alpha_mid.get_pixel(x, y).r)
			var relief: float = luma.get_pixel(x, y).r
			# Outside the figure the height falls to zero, so the silhouette edge tilts outward; inside, the pillow dome carries most of the shape.
			heights[y * width + x] = (PILLOW * pillow + RELIEF * relief * pillow) * clampf(a * 4.0, 0.0, 1.0) + pillow * 0.5 * (1.0 - clampf(a * 4.0, 0.0, 1.0))
	var out: Image = Image.create(width, height, false, Image.FORMAT_RGB8)
	var scale: float = STRENGTH * float(width) / 192.0
	for y: int in range(height):
		for x: int in range(width):
			var left: float = heights[y * width + maxi(x - 1, 0)]
			var right: float = heights[y * width + mini(x + 1, width - 1)]
			var above: float = heights[maxi(y - 1, 0) * width + x]
			var below: float = heights[mini(y + 1, height - 1) * width + x]
			var dx: float = (right - left) * 0.5 * scale
			var dy: float = (below - above) * 0.5 * scale
			var n: Vector3 = Vector3(-dx, dy, 1.0).normalized()
			out.set_pixel(x, y, Color(n.x * 0.5 + 0.5, n.y * 0.5 + 0.5, n.z * 0.5 + 0.5))
	return out


## One channel of `image` (alpha, or luminance) blurred by shrinking it `factor` times and scaling it back up (a cheap wide Gaussian).
static func _channel_blur(image: Image, alpha: bool, factor: int) -> Image:
	var width: int = image.get_width()
	var height: int = image.get_height()
	var channel: Image = Image.create(width, height, false, Image.FORMAT_RGB8)
	for y: int in range(height):
		for x: int in range(width):
			var c: Color = image.get_pixel(x, y)
			var v: float = c.a if alpha else (0.299 * c.r + 0.587 * c.g + 0.114 * c.b) * c.a
			channel.set_pixel(x, y, Color(v, v, v))
	channel.resize(maxi(width / factor, 2), maxi(height / factor, 2), Image.INTERPOLATE_LANCZOS)
	channel.resize(width, height, Image.INTERPOLATE_CUBIC)
	return channel
