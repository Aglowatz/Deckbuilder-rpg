extends SceneTree
## Apparel Part 1 (docs/art/cosmetics.md): builds the four cloak sets from the hero's own painted frames, no new art. The dark teal hooded cloak is found in every frame
## of the default set (assets/art/world_test/sprites/PLAYER) by its colour (cool pixels: green and blue above red, darker than the glow on the hand), cleaned up (dark folds
## inside the cloak filled in, small specks such as the glow dropped, hand-made include / exclude boxes per frame from tools/cloak_masks.json), then repainted:
##   REDCAPE    bright red with a gold clasp at the throat
##   PATCHWORK  mismatched painted patches with stitched seams, laid out in body-relative coordinates so a patch stays put from frame to frame
##   TATTERED   worn grey-green, the hem cut into frayed points and tears (alpha), darker frayed edges
##   ROYAL      deep royal blue, white fur trim along the hem and the front edges, a gold clasp and chain
## Every frame keeps the default canvas and foot line, so the sets line up with the default hero exactly (the report checks it). Output: the character
## PLAYER_CLOAK_<NAME> (frames + an entry in cosmetics_manifest.json + the shop icon), the same sets as SPR-PLAYER-CLOAK-<NAME>-<DIR>_<IDLE|WALK>.png strips in
## _art_source/cosmetics/generated/ (the delivery format of tools/import_cosmetics.sh) and the masks as overlays in _art_source/cloak_masks/ when --masks=true.
##   Godot --headless --path . -s res://tools/make_cloaks.gd -- [--only=REDCAPE,ROYAL] [--masks=true]
## Then: Godot --headless --path . -s res://tools/sprite_normals.gd -- --only=PLAYER_CLOAK_REDCAPE,... --force=true  (bash tools/make_cloaks.sh runs both and re-imports).

const SPRITES: String = "res://assets/art/world_test/sprites/"
const COS_MANIFEST: String = "res://assets/art/world_test/sprites/cosmetics_manifest.json"
const ICON_OUT: String = "res://assets/art/cosmetics/icons/"
const MASK_RULES: String = "res://tools/cloak_masks.json"
const MASK_OUT: String = "res://_art_source/cloak_masks/"
const STRIP_OUT: String = "res://_art_source/cosmetics/generated/"
const NAMES: Array[String] = ["REDCAPE", "PATCHWORK", "TATTERED", "ROYAL"]
const ICON_SIZE: int = 128
## Specks smaller than this (pixels) are not cloak: the rainbow glow on the hand, stray cool pixels in the hair.
const MIN_COMPONENT: int = 260

var _args: Dictionary = {}
var _entry: Dictionary = {}
var _frames: Array[String] = []
var _src: Dictionary = {}  # frame -> Image (RGBA8)
var _mask: Dictionary = {}  # frame -> PackedByteArray (1 = cloak)
var _soft: Dictionary = {}  # frame -> PackedFloat32Array (0..1)
var _lining: Dictionary = {}  # frame -> PackedByteArray (1 = the inside of the cloak, part of the mask)
var _last_lining: PackedByteArray = PackedByteArray()
var _lin_lo: float = 0.0
var _lin_hi: float = 1.0
var _lum_lo: float = 0.0
var _lum_hi: float = 1.0
var _noise: FastNoiseLite
var _fine: FastNoiseLite
var _report: Array[String] = []


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			_args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	_noise = FastNoiseLite.new()
	_noise.seed = 4242
	_noise.frequency = 0.035
	_fine = FastNoiseLite.new()
	_fine.seed = 777
	_fine.frequency = 0.22
	var manifest: Dictionary = _read_json(SPRITES + "manifest.json")
	_entry = manifest.get("PLAYER", {}) as Dictionary
	if _entry.is_empty():
		push_error("make_cloaks: no PLAYER entry in the sprite manifest")
		quit(1)
		return
	for frame: Variant in _entry.get("frames", []) as Array:
		_frames.append(str(frame))
	var rules: Dictionary = _read_json(MASK_RULES)
	var started: int = Time.get_ticks_msec()
	for frame: String in _frames:
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path("%sPLAYER/%s.png" % [SPRITES, frame]))
		image.convert(Image.FORMAT_RGBA8)
		_src[frame] = image
		var mask: PackedByteArray = _cloak_mask(image, rules.get(frame, {}) as Dictionary)
		_mask[frame] = mask
		_lining[frame] = _last_lining
		_soft[frame] = _soften(mask, image.get_width(), image.get_height())
	_measure_luminance()
	if str(_args.get("masks", "false")) == "true":
		_save_mask_overlays()
	var only: PackedStringArray = str(_args.get("only", "")).split(",", false)
	var cos_manifest: Dictionary = _read_json(COS_MANIFEST)
	for cloak_name: String in NAMES:
		if not only.is_empty() and not only.has(cloak_name):
			continue
		cos_manifest["PLAYER_CLOAK_" + cloak_name] = _make_set(cloak_name)
	var out: FileAccess = FileAccess.open(COS_MANIFEST, FileAccess.WRITE)
	out.store_string(JSON.stringify(cos_manifest, "\t"))
	out.close()
	_report.append("make_cloaks: done in %.1f s" % (float(Time.get_ticks_msec() - started) / 1000.0))
	print("\n".join(_report))
	quit()


# ---- The cloak mask ---------------------------------------------------------------------------------------------------------------


## 1 where the pixel is the teal cloak. Cool colour first, then the dark folds the cool test misses are filled in from their neighbours, specks are dropped and the
## hand-made boxes of this frame are applied ({"exclude": [[x, y, w, h], ...], "include": [[x, y, w, h], ...]}, include only takes opaque pixels).
func _cloak_mask(image: Image, rule: Dictionary) -> PackedByteArray:
	var w: int = image.get_width()
	var h: int = image.get_height()
	var data: PackedByteArray = image.get_data()
	var mask: PackedByteArray = PackedByteArray()
	mask.resize(w * h)
	for i: int in range(w * h):
		var a: int = data[i * 4 + 3]
		if a < 24:
			continue
		var r: float = float(data[i * 4]) / 255.0
		var g: float = float(data[i * 4 + 1]) / 255.0
		var b: float = float(data[i * 4 + 2]) / 255.0
		var v: float = maxf(r, maxf(g, b))
		var s: float = (v - minf(r, minf(g, b))) / v if v > 0.0 else 0.0
		var cool: float = minf(g, b) - r
		if cool > 0.012 and v < 0.62 and not (s > 0.6 and v > 0.4):
			mask[i] = 1
	# The lining (the cloak's inside, a pale olive where it swings open) is only cloak where it joins the cloak itself: olive pixels flooded from the cloak.
	var lining: PackedByteArray = PackedByteArray()
	lining.resize(w * h)
	var stack: PackedInt32Array = PackedInt32Array()
	for i: int in range(w * h):
		if mask[i] == 1:
			stack.append(i)
	while not stack.is_empty():
		var at: int = stack[stack.size() - 1]
		stack.remove_at(stack.size() - 1)
		var px: int = at % w
		for next: int in [at - 1 if px > 0 else -1, at + 1 if px < w - 1 else -1, at - w, at + w]:
			if next < 0 or next >= w * h or mask[next] == 1 or lining[next] == 1 or data[next * 4 + 3] < 24:
				continue
			if _is_lining(data, next):
				lining[next] = 1
				mask[next] = 1
				stack.append(next)
	# Dark, grey folds surrounded by cloak are cloak too (twice, so a fold a few pixels wide fills from both sides).
	for _pass: int in range(2):
		var grown: PackedByteArray = mask.duplicate()
		for y: int in range(2, h - 2):
			for x: int in range(2, w - 2):
				var i: int = y * w + x
				if mask[i] == 1 or data[i * 4 + 3] < 24:
					continue
				var r: float = float(data[i * 4]) / 255.0
				var g: float = float(data[i * 4 + 1]) / 255.0
				var b: float = float(data[i * 4 + 2]) / 255.0
				var v: float = maxf(r, maxf(g, b))
				if v > 0.34 or minf(g, b) - r < -0.05:
					continue
				var count: int = 0
				for dy: int in range(-2, 3):
					var row: int = (y + dy) * w
					for dx: int in range(-2, 3):
						count += mask[row + x + dx]
				if count >= 13:
					grown[i] = 1
		mask = grown
	# The cloak's outline: the dark antialiased fringe where it meets open air (not warm, next to the cloak, next to a clear pixel).
	var fringe: PackedByteArray = mask.duplicate()
	for y: int in range(1, h - 1):
		for x: int in range(1, w - 1):
			var i: int = y * w + x
			if mask[i] == 1 or data[i * 4 + 3] < 24:
				continue
			var near_cloak: bool = false
			var near_air: bool = false
			for j: int in [i - 1, i + 1, i - w, i + w, i - w - 1, i - w + 1, i + w - 1, i + w + 1]:
				near_cloak = near_cloak or mask[j] == 1
				near_air = near_air or data[j * 4 + 3] < 24
			var r: float = float(data[i * 4]) / 255.0
			var g: float = float(data[i * 4 + 1]) / 255.0
			var b: float = float(data[i * 4 + 2]) / 255.0
			if near_cloak and near_air and (maxf(r, maxf(g, b)) < 0.4 or minf(g, b) - r > -0.03):
				fringe[i] = 1
	mask = fringe
	_drop_specks(mask, w, h)
	for box: Variant in rule.get("exclude", []) as Array:
		_fill_box(mask, data, w, h, box as Array, 0)
	for box: Variant in rule.get("include", []) as Array:
		_fill_box(mask, data, w, h, box as Array, 1)
	for i: int in range(w * h):
		lining[i] = lining[i] * mask[i]
	_last_lining = lining
	return mask


## The pale olive inside of the cloak: green at least level with red, above blue, not very saturated. Shirt, skin, hair and boots are much redder.
func _is_lining(data: PackedByteArray, i: int) -> bool:
	var r: float = float(data[i * 4]) / 255.0
	var g: float = float(data[i * 4 + 1]) / 255.0
	var b: float = float(data[i * 4 + 2]) / 255.0
	var v: float = maxf(r, maxf(g, b))
	var s: float = (v - minf(r, minf(g, b))) / v if v > 0.0 else 0.0
	return g >= r * 0.9 and g > b + 0.03 and s < 0.5 and v < 0.72 and v > 0.12


func _fill_box(mask: PackedByteArray, data: PackedByteArray, w: int, h: int, box: Array, value: int) -> void:
	if box.size() < 4:
		return
	for y: int in range(maxi(0, int(box[1])), mini(h, int(box[1]) + int(box[3]))):
		for x: int in range(maxi(0, int(box[0])), mini(w, int(box[0]) + int(box[2]))):
			var i: int = y * w + x
			if value == 0 or data[i * 4 + 3] >= 24:
				mask[i] = value


## Removes connected pieces of the mask smaller than MIN_COMPONENT pixels.
func _drop_specks(mask: PackedByteArray, w: int, h: int) -> void:
	var seen: PackedByteArray = PackedByteArray()
	seen.resize(w * h)
	var stack: PackedInt32Array = PackedInt32Array()
	var piece: PackedInt32Array = PackedInt32Array()
	for start: int in range(w * h):
		if mask[start] == 0 or seen[start] == 1:
			continue
		stack.clear()
		piece.clear()
		stack.append(start)
		seen[start] = 1
		while not stack.is_empty():
			var at: int = stack[stack.size() - 1]
			stack.remove_at(stack.size() - 1)
			piece.append(at)
			var px: int = at % w
			var py: int = at / w
			for next: int in [at - 1 if px > 0 else -1, at + 1 if px < w - 1 else -1, at - w if py > 0 else -1, at + w if py < h - 1 else -1]:
				if next >= 0 and mask[next] == 1 and seen[next] == 0:
					seen[next] = 1
					stack.append(next)
		if piece.size() < MIN_COMPONENT:
			for at: int in piece:
				mask[at] = 0


## The mask with a one-pixel soft edge (3x3 average), so the repaint blends into the shirt and hair instead of stepping.
func _soften(mask: PackedByteArray, w: int, h: int) -> PackedFloat32Array:
	var soft: PackedFloat32Array = PackedFloat32Array()
	soft.resize(w * h)
	for y: int in range(1, h - 1):
		for x: int in range(1, w - 1):
			var sum: int = 0
			for dy: int in range(-1, 2):
				var row: int = (y + dy) * w + x
				sum += mask[row - 1] + mask[row] + mask[row + 1]
			soft[y * w + x] = float(sum) / 9.0 if mask[y * w + x] == 0 else maxf(float(sum) / 9.0, 0.75)
	return soft


## The cloak's luminance range over every frame (5th and 97th percentile), the shading scale every repaint maps onto, the same for all frames.
func _measure_luminance() -> void:
	var values: PackedFloat32Array = PackedFloat32Array()
	var inside: PackedFloat32Array = PackedFloat32Array()
	for frame: String in _frames:
		var data: PackedByteArray = (_src[frame] as Image).get_data()
		var mask: PackedByteArray = _mask[frame] as PackedByteArray
		var lining: PackedByteArray = _lining[frame] as PackedByteArray
		for i: int in range(0, mask.size(), 7):
			if lining[i] == 1:
				inside.append(_lum(data, i))
			elif mask[i] == 1:
				values.append(_lum(data, i))
	values.sort()
	inside.sort()
	if values.size() > 100:
		_lum_lo = values[int(values.size() * 0.05)]
		_lum_hi = values[int(values.size() * 0.97)]
	if inside.size() > 50:
		_lin_lo = inside[int(inside.size() * 0.05)]
		_lin_hi = inside[int(inside.size() * 0.97)]
	_report.append("cloak luminance range %.3f .. %.3f (%d samples), lining %.3f .. %.3f (%d samples)" % [_lum_lo, _lum_hi, values.size(), _lin_lo, _lin_hi, inside.size()])


func _lum(data: PackedByteArray, i: int) -> float:
	return (0.3 * float(data[i * 4]) + 0.59 * float(data[i * 4 + 1]) + 0.11 * float(data[i * 4 + 2])) / 255.0


func _save_mask_overlays() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(MASK_OUT))
	for frame: String in _frames:
		var image: Image = (_src[frame] as Image).duplicate() as Image
		var mask: PackedByteArray = _mask[frame] as PackedByteArray
		var data: PackedByteArray = image.get_data()
		for i: int in range(mask.size()):
			if mask[i] == 1:
				data[i * 4] = 255
				data[i * 4 + 1] = int(float(data[i * 4 + 1]) * 0.3)
				data[i * 4 + 2] = 255
		image.set_data(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8, data)
		image.save_png(ProjectSettings.globalize_path(MASK_OUT + frame + ".png"))
	_report.append("mask overlays in %s" % MASK_OUT)


# ---- The repaint ------------------------------------------------------------------------------------------------------------------


func _make_set(cloak_name: String) -> Dictionary:
	var character: String = "PLAYER_CLOAK_" + cloak_name
	var folder: String = SPRITES + character + "/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var out_images: Dictionary = {}
	var outside_changed: int = 0
	for frame: String in _frames:
		var image: Image = _repaint(cloak_name, frame)
		out_images[frame] = image
		image.save_png(ProjectSettings.globalize_path(folder + frame + ".png"))
		outside_changed += _changed_outside(frame, image)
	var entry: Dictionary = _entry.duplicate(true)
	var back: Array = []
	for frame: String in _frames:
		if frame.begins_with("BACK_"):
			back.append(out_images[frame])
	entry["cloak_hue"] = SpriteAnchors.cloak_hue(back)
	# Line-up check: the head anchor of every frame is measured again and must match the default hero's (the head and the foot line never move).
	var head: Dictionary = {}
	var worst: float = 0.0
	var base_head: Dictionary = _entry.get("head", {}) as Dictionary
	for frame: String in _frames:
		var anchor: Array = SpriteAnchors.head_anchor(out_images[frame] as Image)
		head[frame] = [snappedf(float(anchor[0]), 0.1), float(anchor[1]), snappedf(float(anchor[2]), 0.1)] if anchor.size() >= 3 else []
		var base: Array = base_head.get(frame, []) as Array
		if anchor.size() >= 3 and base.size() >= 2:
			worst = maxf(worst, maxf(absf(float(anchor[0]) - float(base[0])), absf(float(anchor[1]) - float(base[1]))))
	entry["head"] = head
	_make_icon(out_images["FRONT_IDLE"] as Image, "CLOAK_" + cloak_name)
	_save_strips(cloak_name, out_images)
	_report.append("%s: %d frames, cloak hue %s, head anchor drift max %.1f px, pixels changed outside the cloak %d" % [character, _frames.size(), str(entry["cloak_hue"]), worst, outside_changed])
	return entry


## Opaque pixels away from the cloak (more than two pixels out) whose colour or alpha changed: the clasps and the fur add a few, nothing else should.
func _changed_outside(frame: String, image: Image) -> int:
	var a: PackedByteArray = (_src[frame] as Image).get_data()
	var b: PackedByteArray = image.get_data()
	var soft: PackedFloat32Array = _soft[frame] as PackedFloat32Array
	var count: int = 0
	for i: int in range(soft.size()):
		if soft[i] > 0.0:
			continue
		if absi(int(a[i * 4 + 3]) - int(b[i * 4 + 3])) > 8 or absi(int(a[i * 4]) - int(b[i * 4])) > 8:
			count += 1
	return count


func _repaint(cloak_name: String, frame: String) -> Image:
	var src: Image = _src[frame] as Image
	var w: int = src.get_width()
	var h: int = src.get_height()
	var data: PackedByteArray = src.get_data()
	var out: PackedByteArray = data.duplicate()
	var mask: PackedByteArray = _mask[frame] as PackedByteArray
	var soft: PackedFloat32Array = _soft[frame] as PackedFloat32Array
	var lining: PackedByteArray = _lining[frame] as PackedByteArray
	var anchor: Array = (_entry.get("head", {}) as Dictionary).get(frame, [w * 0.5, 50.0, 64.0]) as Array
	var head_x: float = float(anchor[0])
	var top: float = float(anchor[1])
	var fig: float = float(_entry.get("fig_h", 440))
	var direction: String = frame.get_slice("_", 0)
	for y: int in range(h):
		for x: int in range(w):
			var i: int = y * w + x
			var m: float = soft[i]
			if m <= 0.0:
				continue
			var t: float = clampf((_lum(data, i) - _lum_lo) / (_lum_hi - _lum_lo), 0.0, 1.0)
			# Body-relative coordinates (pixels from the head's centre line and from the crown): the same spot of the cloak in every frame of a direction.
			var bx: float = float(x) - head_x
			var by: float = float(y) - top
			var colour: Color
			if lining[i] == 1:
				var lt: float = clampf((_lum(data, i) - _lin_lo) / maxf(0.01, _lin_hi - _lin_lo), 0.0, 1.0)
				var stops: Array = LININGS.get(cloak_name, LININGS["PATCHWORK"]) as Array
				_put(out, i, _ramp(lt, stops[0] as Color, stops[1] as Color, stops[2] as Color), m)
				continue
			match cloak_name:
				"REDCAPE":
					t = clampf(t + _noise.get_noise_2d(bx, by) * 0.05, 0.0, 1.0)
					colour = _ramp(t, Color(0.24, 0.02, 0.04), Color(0.66, 0.05, 0.07), Color(0.96, 0.3, 0.24))
				"ROYAL":
					t = clampf(t + _noise.get_noise_2d(bx, by) * 0.04, 0.0, 1.0)
					colour = _ramp(t, Color(0.02, 0.03, 0.16), Color(0.07, 0.12, 0.46), Color(0.3, 0.42, 0.86))
				"TATTERED":
					colour = _tattered_colour(t, bx, by, fig)
				_:
					colour = _patch_colour(t, bx, by / fig, x, y)
			_put(out, i, colour, m)
	match cloak_name:
		"TATTERED":
			_tatter(out, data, mask, w, h, head_x, top, fig)
		"ROYAL":
			_fur(out, data, mask, w, h, head_x, top, fig, direction)
			_clasps(out, mask, w, h, head_x, top, fig, direction, 6.0, true)
		"REDCAPE":
			_clasps(out, mask, w, h, head_x, top, fig, direction, 5.0, true)
	var image: Image = Image.create_from_data(w, h, false, Image.FORMAT_RGBA8, out)
	return image


## The inside of each cloak (shadow, mid, highlight): a darker red, an ivory silk under the royal blue, plain sackcloth under the patches, a dirtier green.
const LININGS: Dictionary = {
	"REDCAPE": [Color(0.22, 0.03, 0.05), Color(0.5, 0.07, 0.09), Color(0.72, 0.2, 0.18)],
	"ROYAL": [Color(0.5, 0.47, 0.42), Color(0.82, 0.79, 0.7), Color(0.97, 0.95, 0.88)],
	"PATCHWORK": [Color(0.3, 0.24, 0.16), Color(0.58, 0.49, 0.34), Color(0.78, 0.7, 0.53)],
	"TATTERED": [Color(0.14, 0.15, 0.11), Color(0.32, 0.34, 0.26), Color(0.5, 0.52, 0.42)],
}


func _ramp(t: float, shadow: Color, mid: Color, high: Color) -> Color:
	return shadow.lerp(mid, t * 2.0) if t < 0.5 else mid.lerp(high, (t - 0.5) * 2.0)


func _put(out: PackedByteArray, i: int, colour: Color, amount: float) -> void:
	out[i * 4] = int(clampf(lerpf(float(out[i * 4]) / 255.0, colour.r, amount), 0.0, 1.0) * 255.0)
	out[i * 4 + 1] = int(clampf(lerpf(float(out[i * 4 + 1]) / 255.0, colour.g, amount), 0.0, 1.0) * 255.0)
	out[i * 4 + 2] = int(clampf(lerpf(float(out[i * 4 + 2]) / 255.0, colour.b, amount), 0.0, 1.0) * 255.0)


func _tattered_colour(t: float, bx: float, by: float, fig: float) -> Color:
	var grime: float = _noise.get_noise_2d(bx * 1.6 + 300.0, by * 1.6)
	t = clampf(t + grime * 0.08, 0.0, 1.0)
	var colour: Color = _ramp(t, Color(0.11, 0.12, 0.1), Color(0.36, 0.38, 0.32), Color(0.6, 0.62, 0.54))
	# Worn, sun-bleached patches and a darker, dirtier hem.
	var worn: float = smoothstep(0.25, 0.6, _noise.get_noise_2d(bx * 0.7 - 120.0, by * 0.7 + 50.0))
	colour = colour.lerp(Color(0.56, 0.57, 0.5) * (0.55 + 0.6 * t), worn * 0.35)
	var low: float = smoothstep(fig * 0.55, fig * 0.85, by)
	return colour.darkened(low * 0.22)


## The patchwork: jittered-grid Voronoi cells in body-relative units (fractions of the figure height), each a colour of the palette, some striped or checked, with
## darker stitched seams between them. Shading comes from the painted cloak (t).
const PATCH_COLOURS: Array[Color] = [Color(0.8, 0.6, 0.18), Color(0.68, 0.27, 0.15), Color(0.47, 0.25, 0.48), Color(0.47, 0.6, 0.38), Color(0.2, 0.47, 0.5),
		Color(0.86, 0.78, 0.58), Color(0.74, 0.2, 0.22), Color(0.27, 0.38, 0.66), Color(0.52, 0.5, 0.2)]
const PATCH_CELL: float = 0.085


func _patch_colour(t: float, bx: float, v: float, x: int, y: int) -> Color:
	var u: float = bx / float(_entry.get("fig_h", 440))
	# A little wobble so the seams are hand-cut, not ruler-straight.
	var pu: float = u + _noise.get_noise_2d(bx * 2.0, v * 900.0) * 0.008
	var pv: float = v + _noise.get_noise_2d(bx * 2.0 + 500.0, v * 900.0) * 0.008
	var gx: int = floori(pu / PATCH_CELL)
	var gy: int = floori(pv / PATCH_CELL)
	var best: float = 1e9
	var second: float = 1e9
	var cell: Vector2i = Vector2i.ZERO
	for oy: int in range(-1, 2):
		for ox: int in range(-1, 2):
			var cx: int = gx + ox
			var cy: int = gy + oy
			var sx: float = (float(cx) + 0.15 + 0.7 * _hash(cx, cy, 1)) * PATCH_CELL
			var sy: float = (float(cy) + 0.15 + 0.7 * _hash(cx, cy, 2)) * PATCH_CELL
			var d: float = Vector2(pu - sx, (pv - sy) * 0.85).length()
			if d < best:
				second = best
				best = d
				cell = Vector2i(cx, cy)
			elif d < second:
				second = d
	var pick: float = _hash(cell.x, cell.y, 3)
	var base: Color = PATCH_COLOURS[int(pick * float(PATCH_COLOURS.size())) % PATCH_COLOURS.size()]
	var pattern: float = _hash(cell.x, cell.y, 4)
	if pattern < 0.22:
		# Stripes.
		base = base.darkened(0.25) if fmod(absf(pu * 160.0 + pv * 60.0), 2.0) < 1.0 else base
	elif pattern < 0.36:
		# A check.
		if (floori(pu * 120.0) + floori(pv * 120.0)) % 2 == 0:
			base = base.lightened(0.18)
	var colour: Color = _ramp(clampf(t + _fine.get_noise_2d(float(x), float(y)) * 0.04, 0.0, 1.0), base * 0.26, base * 0.82, base.lerp(Color.WHITE, 0.3))
	colour.a = 1.0
	# Seams: a dark band where two cells meet, with lighter dashed stitches along it.
	var edge: float = second - best
	if edge < 0.0042:
		var stitch: bool = fmod(float(x + y), 6.0) < 3.0
		colour = Color(0.86, 0.8, 0.62) * (0.45 + 0.6 * t) if stitch and edge < 0.0022 else colour.darkened(0.55)
		colour.a = 1.0
	return colour


func _hash(x: int, y: int, salt: int) -> float:
	var value: float = sin(float(x) * 127.1 + float(y) * 311.7 + float(salt) * 74.7) * 43758.5453
	return value - floorf(value)


# ---- Tattered hem, fur trim, clasps -----------------------------------------------------------------------------------------------


## The hem is cut into frayed points: a cloak pixel whose way down (through cloak only) reaches open air within depth(x) becomes transparent. depth is a function of the
## body-relative x (noise plus a few V-shaped tears), so the cut sits on the same part of the cloak in every frame. A pixel above legs or boots is never cut (no holes).
const TEARS: Array[float] = [-118.0, -88.0, -52.0, -21.0, 12.0, 44.0, 79.0, 104.0, 131.0]


func _tatter(out: PackedByteArray, src: PackedByteArray, mask: PackedByteArray, w: int, h: int, head_x: float, top: float, fig: float) -> void:
	var lowest_body: float = top + fig * 0.3
	for y: int in range(int(lowest_body), h):
		for x: int in range(w):
			var i: int = y * w + x
			if mask[i] == 0:
				continue
			var bx: float = float(x) - head_x
			var depth: float = 6.0 + 12.0 * absf(_noise.get_noise_1d(bx * 1.4 + 40.0)) + 1.8 * _fine.get_noise_1d(bx * 3.0)
			for c: float in TEARS:
				depth = maxf(depth, 40.0 - absf(bx - c) * 3.2)
			var reach: int = -1
			for k: int in range(1, int(depth) + 3):
				var below: int = i + k * w
				if y + k >= h or src[below * 4 + 3] < 24:
					reach = k
					break
				if mask[below] == 0:
					break
			# The sides of the lower cloak fray too: nibbles where the cloak's edge meets open air to the left or right.
			var side_depth: float = 2.6 * maxf(0.0, _fine.get_noise_1d(float(y) * 1.7 + bx * 0.1)) * smoothstep(top + fig * 0.4, top + fig * 0.6, float(y))
			var side: int = -1
			for k: int in range(1, int(side_depth) + 2):
				for step: int in [-k, k]:
					var nx: int = x + step
					if nx < 0 or nx >= w or src[(i + step) * 4 + 3] < 24:
						side = k
						break
				if side > 0:
					break
			var cut: float = 0.0
			if reach > 0:
				cut = clampf(depth + 1.0 - float(reach), 0.0, 1.0)
			if side > 0 and float(side) <= side_depth:
				cut = maxf(cut, clampf(side_depth + 1.0 - float(side), 0.0, 1.0))
			if cut > 0.0:
				out[i * 4 + 3] = int(float(out[i * 4 + 3]) * (1.0 - cut))
			# Frayed, darker threads just above the cut.
			if reach > 0 and float(reach) < depth + 4.0:
				for ch: int in range(3):
					out[i * 4 + ch] = int(float(out[i * 4 + ch]) * 0.7)


## White fur along the hem (a band above the cloak's lowest pixel in every column, lower half only) and, seen from the front, along the front edges and the collar
## (where the cloak meets the shirt, the arms or the face: an opaque run of at least five non-cloak pixels, so a dark hole in a fold never grows fur). The band's
## width wanders with the noise, and the hem gets short tufts into the air below.
func _fur(out: PackedByteArray, src: PackedByteArray, mask: PackedByteArray, w: int, h: int, head_x: float, top: float, fig: float, direction: String) -> void:
	var bottom: PackedInt32Array = PackedInt32Array()
	bottom.resize(w)
	for x: int in range(w):
		bottom[x] = -1
		for y: int in range(h - 1, -1, -1):
			if mask[y * w + x] == 1:
				bottom[x] = y
				break
	var fronts: bool = direction == "FRONT" or direction == "FRONTSIDE" or direction == "SIDE"
	for y: int in range(h):
		for x: int in range(w):
			var i: int = y * w + x
			if mask[i] == 0:
				continue
			var bx: float = float(x) - head_x
			var by: float = float(y) - top
			var tuft: float = _fine.get_noise_2d(float(x) * 1.3, float(y) * 1.3)
			var fur: bool = false
			if bottom[x] >= 0 and by > fig * 0.45 and float(y) >= float(bottom[x]) - (10.0 + 3.0 * _noise.get_noise_1d(bx * 2.0) + 2.0 * tuft):
				fur = true
			elif fronts and by > fig * 0.09:
				var band: int = int(6.5 + 2.0 * tuft)
				for dir: int in [-1, 1]:
					for k: int in range(1, band + 1):
						var nx: int = x + dir * k
						if nx < 0 or nx >= w:
							break
						if mask[y * w + nx] == 1:
							continue
						var solid: bool = true
						for extra: int in range(0, 5):
							var ex: int = nx + dir * extra
							if ex < 0 or ex >= w or mask[y * w + ex] == 1 or src[(y * w + ex) * 4 + 3] < 140:
								solid = false
								break
						fur = fur or solid
						break
			if not fur:
				continue
			var t: float = clampf((_lum(src, i) - _lum_lo) / (_lum_hi - _lum_lo), 0.0, 1.0)
			var fluff: float = _fine.get_noise_2d(float(x) * 2.5, float(y) * 2.5) * 0.08
			var colour: Color = Color(0.64, 0.66, 0.76).lerp(Color(1.0, 0.99, 0.95), clampf(0.4 + t * 0.7 + fluff, 0.0, 1.0))
			_put(out, i, colour, 1.0)
			# Tufts below the hem into the open air.
			if y == bottom[x] and y + 1 < h and src[(i + w) * 4 + 3] < 24:
				var length: int = int(1.5 + 3.0 * maxf(0.0, _fine.get_noise_1d(float(x) * 1.9)))
				for k: int in range(1, length + 1):
					var j: int = i + k * w
					if y + k >= h or src[j * 4 + 3] >= 24:
						break
					_put(out, j, colour.darkened(0.05 * float(k)), 1.0)
					out[j * 4 + 3] = maxi(out[j * 4 + 3], int(230.0 * (1.0 - float(k) / float(length + 1))))


## Gold clasps at the throat: for the front views one on each collar edge (the first cloak pixel left and right of the face on the neck row), for the side view at the
## cloak's front edge; none from behind. `chain` adds a gold chain between the two front clasps.
func _clasps(out: PackedByteArray, mask: PackedByteArray, w: int, h: int, head_x: float, top: float, fig: float, direction: String, radius: float, chain: bool) -> void:
	if direction == "BACK" or direction == "BACKSIDE":
		return
	var neck: int = int(top + fig * 0.2)
	var points: Array[Vector2] = []
	if direction == "SIDE":
		for x: int in range(w):
			if mask[neck * w + x] == 1:
				points.append(Vector2(float(x) + radius * 0.6, float(neck)))
				break
	else:
		var reach: int = int(fig * 0.16)
		for x: int in range(int(head_x), maxi(0, int(head_x) - reach), -1):
			if mask[neck * w + x] == 1:
				points.append(Vector2(float(x) - radius * 0.45, float(neck)))
				break
		for x: int in range(int(head_x), mini(w, int(head_x) + reach)):
			if mask[neck * w + x] == 1:
				points.append(Vector2(float(x) + radius * 0.45, float(neck)))
				break
	if chain and points.size() == 2:
		var a: Vector2 = points[0]
		var b: Vector2 = points[1]
		var steps: int = int(a.distance_to(b) / 2.6)
		for s: int in range(1, steps):
			var f: float = float(s) / float(steps)
			var p: Vector2 = a.lerp(b, f) + Vector2(0.0, sin(f * PI) * radius * 1.5)
			_disc(out, w, h, p, 1.5, false)
	for p: Vector2 in points:
		_disc(out, w, h, p, radius, true)


## A small painted gold disc: dark rim, warm body, a bright highlight up and to the left. Antialiased; raises alpha where it goes past the cloak's edge.
func _disc(out: PackedByteArray, w: int, h: int, centre: Vector2, radius: float, shaded: bool) -> void:
	for y: int in range(int(centre.y - radius - 2.0), int(centre.y + radius + 3.0)):
		for x: int in range(int(centre.x - radius - 2.0), int(centre.x + radius + 3.0)):
			if x < 0 or y < 0 or x >= w or y >= h:
				continue
			var d: float = Vector2(float(x) + 0.5, float(y) + 0.5).distance_to(centre)
			var cover: float = clampf(radius + 0.5 - d, 0.0, 1.0)
			if cover <= 0.0:
				continue
			var colour: Color = Color(0.86, 0.66, 0.24)
			if shaded:
				var rel: Vector2 = (Vector2(float(x) + 0.5, float(y) + 0.5) - centre) / radius
				var light: float = clampf(1.0 - (rel - Vector2(-0.35, -0.4)).length(), 0.0, 1.0)
				colour = Color(0.5, 0.33, 0.08).lerp(Color(0.95, 0.78, 0.33), clampf(0.3 + light, 0.0, 1.0))
				colour = colour.lerp(Color(1.0, 0.97, 0.82), smoothstep(0.62, 0.95, light))
				if d > radius - 1.4:
					colour = Color(0.33, 0.21, 0.05)
			var i: int = y * w + x
			_put(out, i, colour, cover)
			out[i * 4 + 3] = maxi(out[i * 4 + 3], int(255.0 * cover))


# ---- Output helpers ---------------------------------------------------------------------------------------------------------------


## The shop / wardrobe icon (the same recipe as tools/world_test_import.gd `_make_icon`): FRONT_IDLE trimmed, centred on a square, ICON_SIZE.
func _make_icon(image: Image, icon_name: String) -> void:
	var box: Rect2i = image.get_used_rect()
	if box.size.x == 0:
		return
	var crop: Image = image.get_region(box)
	var side: int = maxi(crop.get_width(), crop.get_height()) + 8
	var square: Image = Image.create_empty(side, side, false, Image.FORMAT_RGBA8)
	square.blit_rect(crop, Rect2i(Vector2i.ZERO, crop.get_size()), Vector2i((side - crop.get_width()) / 2, (side - crop.get_height()) / 2))
	square.premultiply_alpha()
	square.resize(ICON_SIZE, ICON_SIZE, Image.INTERPOLATE_LANCZOS)
	var data: PackedByteArray = square.get_data()
	for i: int in range(0, data.size(), 4):
		var a: int = data[i + 3]
		if a > 0 and a < 255:
			for c: int in range(3):
				data[i + c] = mini(255, data[i + c] * 255 / a)
	square.set_data(ICON_SIZE, ICON_SIZE, false, Image.FORMAT_RGBA8, data)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ICON_OUT))
	square.save_png(ProjectSettings.globalize_path(ICON_OUT + icon_name + ".png"))


## The delivery-format copies: SPR-PLAYER-CLOAK-<NAME>-<DIR>_IDLE.png (one frame) and _WALK.png (the four walk frames side by side).
func _save_strips(cloak_name: String, images: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(STRIP_OUT))
	for dir_name: Variant in _entry.get("dirs", []) as Array:
		var idle: Image = images.get("%s_IDLE" % dir_name) as Image
		if idle != null:
			idle.save_png(ProjectSettings.globalize_path("%sSPR-PLAYER-CLOAK-%s-%s_IDLE.png" % [STRIP_OUT, cloak_name, dir_name]))
		var first: Image = images.get("%s_WALK1" % dir_name) as Image
		if first == null:
			continue
		var strip: Image = Image.create_empty(first.get_width() * 4, first.get_height(), false, Image.FORMAT_RGBA8)
		for n: int in range(4):
			var frame: Image = images.get("%s_WALK%d" % [dir_name, n + 1]) as Image
			if frame != null:
				strip.blit_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), Vector2i(first.get_width() * n, 0))
		strip.save_png(ProjectSettings.globalize_path("%sSPR-PLAYER-CLOAK-%s-%s_WALK.png" % [STRIP_OUT, cloak_name, dir_name]))


func _read_json(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed as Dictionary if parsed is Dictionary else {}
