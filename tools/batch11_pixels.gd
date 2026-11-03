extends SceneTree
## Batch 11 art import (Nov 2), Part 1: pixel checks on the staged delivery (_art_inbox/batch11, from tools/batch11_delivery.js).
## Per file: min alpha (is an "opaque" picture really opaque), corner alpha (is a cut-out's background clear), the drawn bounding box
## (top / bottom = ground line / height), and for sheets the count of drawn columns / rows split by clear gaps.
## Writes _art_inbox/batch11/pixels.json. Run: Godot --headless --path . -s res://tools/batch11_pixels.gd

const STAGE := "res://_art_inbox/batch11"
const STEP := 4  # sample every 4th pixel: enough for a box at 4 px precision
const SOLID := 24  # alpha above this counts as drawn


func _init() -> void:
	var out := {}
	var dirs := [] as Array[String]
	for folder: String in DirAccess.get_directories_at(STAGE):
		dirs.append(STAGE.path_join(folder))
		for sub: String in DirAccess.get_directories_at(STAGE.path_join(folder)):
			dirs.append(STAGE.path_join(folder).path_join(sub))
	for dir: String in dirs:
		for file: String in DirAccess.get_files_at(dir):
			if file.get_extension() != "png":
				continue
			var img := Image.load_from_file(ProjectSettings.globalize_path(dir.path_join(file)))
			if img == null:
				out[file] = {"error": "cannot load"}
				continue
			out[file] = _measure(img)
			print("%s %s" % [file, JSON.stringify(out[file])])
	var f := FileAccess.open(STAGE.path_join("pixels.json"), FileAccess.WRITE)
	f.store_string(JSON.stringify(out, " "))
	f.close()
	quit()


func _measure(img: Image) -> Dictionary:
	if img.get_format() != Image.FORMAT_RGBA8:
		img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()
	var data := img.get_data()
	var min_a := 255
	var top := h
	var bottom := -1
	var left := w
	var right := -1
	var cols := PackedInt32Array()
	cols.resize(w / STEP + 1)
	var rows := PackedInt32Array()
	rows.resize(h / STEP + 1)
	for y in range(0, h, STEP):
		for x in range(0, w, STEP):
			var a := data[(y * w + x) * 4 + 3]
			min_a = mini(min_a, a)
			if a > SOLID:
				top = mini(top, y)
				bottom = maxi(bottom, y)
				left = mini(left, x)
				right = maxi(right, x)
				cols[x / STEP] += 1
				rows[y / STEP] += 1
	var corners := [img.get_pixel(2, 2).a8, img.get_pixel(w - 3, 2).a8, img.get_pixel(2, h - 3).a8, img.get_pixel(w - 3, h - 3).a8]
	return {
		"w": w, "h": h, "min_alpha": min_a, "corners": corners,
		"box": [left, top, right, bottom], "drawn_h": bottom - top, "ground_gap": h - 1 - bottom,
		"col_runs": _runs(cols), "row_runs": _runs(rows),
	}


## Drawn runs along one axis, as [start, end] pixel pairs, ignoring specks narrower than 3 samples.
func _runs(counts: PackedInt32Array) -> Array:
	var runs := []
	var start := -1
	for i in counts.size() + 1:
		var on := i < counts.size() and counts[i] > 1
		if on and start < 0:
			start = i
		elif not on and start >= 0:
			if i - start >= 3:
				runs.append([start * STEP, (i - 1) * STEP])
			start = -1
	return runs
