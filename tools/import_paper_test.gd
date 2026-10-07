extends SceneTree
## Papercraft test importer (docs/art/papercraft_test.md): COPIES (never writes to) the Drive folder's PAPER-<ID>_<IDLE|WALK|BACK>.png files, removes a plain opaque
## gray backdrop when there is one (the current files already ship with a clean alpha), crops every character to one shared canvas with the feet on the bottom edge
## (+ a transparent margin for the shader's paper outline) and writes assets/art/paper/<ID>_<FRAME>.webp. Run: bash tools/import_paper_test.sh

const SOURCE_DIRS: Array[String] = ["G:/My Drive/Card Game Art/Paper_Test", "G:/My Drive/Card Game Art/Paper_test_approved"]
const INBOX: String = "res://_art_inbox/paper_src"
const OUT: String = "res://assets/art/paper"
const IDS: Array[String] = ["NPC-PLAYER", "NPC-HURL", "NPC-ELDER", "V-FENWICK"]
const FRAMES: Array[String] = ["IDLE", "WALK", "BACK"]
const MAX_HEIGHT: int = 768
const PAD: int = 24
const ALPHA_EDGE: float = 0.08


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(INBOX))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var source: String = _find_source()
	if source == "":
		push_error("no Paper_Test folder with PAPER-*.png files found on the Drive")
		quit(1)
		return
	print("source: %s" % source)
	for id: String in IDS:
		var images: Array[Image] = []
		for frame: String in FRAMES:
			var file_name: String = "PAPER-%s_%s.png" % [id, frame]
			var copied: String = ProjectSettings.globalize_path(INBOX).path_join(file_name)
			if DirAccess.copy_absolute(source.path_join(file_name), copied) != OK:
				push_error("cannot copy %s" % file_name)
				quit(1)
				return
			var image: Image = Image.load_from_file(copied)
			image.convert(Image.FORMAT_RGBA8)
			_remove_gray_backdrop(image)
			images.append(image)
		_write_character(id, images)
	quit(0)


func _find_source() -> String:
	for dir: String in SOURCE_DIRS:
		if DirAccess.dir_exists_absolute(dir) and not DirAccess.get_files_at(dir).is_empty():
			return dir
	return ""


## Only acts when the corner is opaque and gray: flood-fills similar gray pixels from the borders to transparent.
func _remove_gray_backdrop(image: Image) -> void:
	var corner: Color = image.get_pixel(2, 2)
	if corner.a < 0.95 or absf(corner.r - corner.g) > 0.06 or absf(corner.g - corner.b) > 0.06:
		return
	var w: int = image.get_width()
	var h: int = image.get_height()
	var stack: Array[Vector2i] = [Vector2i(2, 2), Vector2i(w - 3, 2), Vector2i(2, h - 3), Vector2i(w - 3, h - 3)]
	var seen: Dictionary = {}
	while not stack.is_empty():
		var p: Vector2i = stack.pop_back()
		if p.x < 0 or p.y < 0 or p.x >= w or p.y >= h or seen.has(p):
			continue
		seen[p] = true
		var c: Color = image.get_pixelv(p)
		if c.a < 0.5 or absf(c.r - corner.r) > 0.1 or absf(c.g - corner.g) > 0.1 or absf(c.b - corner.b) > 0.1:
			continue
		image.set_pixelv(p, Color(1, 1, 1, 0))
		stack.append_array([p + Vector2i(1, 0), p + Vector2i(-1, 0), p + Vector2i(0, 1), p + Vector2i(0, -1)])


func _bbox(image: Image) -> Rect2i:
	var w: int = image.get_width()
	var h: int = image.get_height()
	var min_x: int = w
	var min_y: int = h
	var max_x: int = -1
	var max_y: int = -1
	for y: int in range(h):
		for x: int in range(w):
			if image.get_pixel(x, y).a > ALPHA_EDGE:
				min_x = mini(min_x, x)
				max_x = maxi(max_x, x)
				min_y = mini(min_y, y)
				max_y = maxi(max_y, y)
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)


func _write_character(id: String, images: Array[Image]) -> void:
	var boxes: Array[Rect2i] = []
	var tallest: int = 0
	for image: Image in images:
		var box: Rect2i = _bbox(image)
		boxes.append(box)
		tallest = maxi(tallest, box.size.y)
	var factor: float = float(MAX_HEIGHT) / float(tallest)
	var canvas_w: int = 0
	var canvas_h: int = 0
	for box: Rect2i in boxes:
		canvas_w = maxi(canvas_w, int(ceil(box.size.x * factor)))
		canvas_h = maxi(canvas_h, int(ceil(box.size.y * factor)))
	canvas_w += PAD * 2
	canvas_h += PAD * 2
	for i: int in range(images.size()):
		var cut: Image = images[i].get_region(boxes[i])
		cut.resize(maxi(1, int(round(boxes[i].size.x * factor))), maxi(1, int(round(boxes[i].size.y * factor))), Image.INTERPOLATE_LANCZOS)
		# Transparent pixels get white colour so scaling/mip filtering never pulls dark halo colour into the cut-out's edge.
		for y: int in range(cut.get_height()):
			for x: int in range(cut.get_width()):
				var c: Color = cut.get_pixel(x, y)
				if c.a < 0.02:
					cut.set_pixel(x, y, Color(1, 1, 1, 0))
		var canvas: Image = Image.create(canvas_w, canvas_h, false, Image.FORMAT_RGBA8)
		canvas.fill(Color(1, 1, 1, 0))
		canvas.blit_rect(cut, Rect2i(Vector2i.ZERO, cut.get_size()), Vector2i((canvas_w - cut.get_width()) / 2, canvas_h - PAD - cut.get_height()))
		var path: String = ProjectSettings.globalize_path(OUT).path_join("%s_%s.webp" % [id, FRAMES[i]])
		var error: Error = canvas.save_webp(path, true, 0.92)
		print("%s_%s: %dx%d (%s)" % [id, FRAMES[i], canvas_w, canvas_h, error_string(error)])
