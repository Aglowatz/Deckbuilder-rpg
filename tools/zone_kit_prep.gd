extends RefCounted
## Art preparation shared by every zone kit (Approved_ZoneKits/<Zone>, tools/import_zone_kit.gd). Builds on the Environment Kit prep (tools/env_kit_prep.gd: seams, maps,
## alpha cleanup, bounds) and adds what zone kits need:
##   SHEET  : a 3x2 sheet of related cut-outs (doors, windows, signs, banners) is sliced into its six items by the transparent gaps between them (reading order), each
##            item trimmed and given a pivot like a single cut-out.
##   pivots : by what the item is (signs at their wall bracket, banners at their pole, trees and plants at the trunk base, everything else at the base centre).
##   groups : the tint / slot family of an id from the sheet's category and use text ("wall", "roof", "ground", "trim", "door", "window", "sign", "banner", "tree",
##            "prop", "decal", "backdrop", "concept").
## Pure image and string work (no scene tree) so tests can run it on synthetic images.

const Prep = preload("res://tools/env_kit_prep.gd")
const ALPHA_FLOOR: float = 0.06


## The six cells of a `cols` x `rows` sheet, reading order (left to right, top to bottom), each trimmed to its painted bounds. The split lines are the widest transparent
## gaps between items; when a gap cannot be found the sheet is divided evenly. A cell with nothing painted in it is returned as an empty Rect2i (size 0).
static func slice_grid(image: Image, cols: int = 3, rows: int = 2) -> Array[Rect2i]:
	var width: int = image.get_width()
	var height: int = image.get_height()
	var column_full: PackedByteArray = _occupancy(image, true)
	var row_full: PackedByteArray = _occupancy(image, false)
	var x_cuts: Array[int] = _cuts(column_full, width, cols)
	var y_cuts: Array[int] = _cuts(row_full, height, rows)
	var result: Array[Rect2i] = []
	for row: int in range(rows):
		for col: int in range(cols):
			var x0: int = 0 if col == 0 else x_cuts[col - 1]
			var x1: int = width if col == cols - 1 else x_cuts[col]
			var y0: int = 0 if row == 0 else y_cuts[row - 1]
			var y1: int = height if row == rows - 1 else y_cuts[row]
			result.append(_bounds_in(image, Rect2i(x0, y0, x1 - x0, y1 - y0)))
	return result


## One byte per column (or row): 1 when any pixel along it is painted.
static func _occupancy(image: Image, columns: bool) -> PackedByteArray:
	var along: int = image.get_width() if columns else image.get_height()
	var across: int = image.get_height() if columns else image.get_width()
	var result: PackedByteArray = PackedByteArray()
	result.resize(along)
	var step: int = maxi(1, across / 400)
	for index: int in range(along):
		var hit: int = 0
		var other: int = 0
		while other < across:
			var pixel: Color = image.get_pixel(index, other) if columns else image.get_pixel(other, index)
			if pixel.a > ALPHA_FLOOR:
				hit = 1
				break
			other += step
		result[index] = hit
	return result


## The `count - 1` split positions: the centres of the widest empty runs that lie inside the middle 70% of the axis, sorted; an even division when too few are found.
static func _cuts(full: PackedByteArray, length: int, count: int) -> Array[int]:
	var gaps: Array[Vector2i] = []
	var start: int = -1
	for index: int in range(length + 1):
		var empty: bool = index < length and full[index] == 0
		if empty and start < 0:
			start = index
		elif not empty and start >= 0:
			var centre: int = (start + index) / 2
			if centre > int(float(length) * 0.15) and centre < int(float(length) * 0.85):
				gaps.append(Vector2i(index - start, centre))
			start = -1
	gaps.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.x > b.x)
	var chosen: Array[int] = []
	for index: int in range(mini(count - 1, gaps.size())):
		if gaps[index].x < 4:
			break
		chosen.append(gaps[index].y)
	if chosen.size() < count - 1:
		chosen.clear()
		for index: int in range(1, count):
			chosen.append(length * index / count)
	chosen.sort()
	return chosen


static func _bounds_in(image: Image, cell: Rect2i) -> Rect2i:
	var min_x: int = cell.end.x
	var min_y: int = cell.end.y
	var max_x: int = -1
	var max_y: int = -1
	for y: int in range(cell.position.y, cell.end.y):
		for x: int in range(cell.position.x, cell.end.x):
			if image.get_pixel(x, y).a > ALPHA_FLOOR:
				min_x = mini(min_x, x)
				max_x = maxi(max_x, x)
				min_y = mini(min_y, y)
				max_y = maxi(max_y, y)
	if max_x < 0:
		return Rect2i()
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)


## Pivot (0..1 of the trimmed image) by family: signs at the wall bracket (the centroid of the left plate), banners at the middle of their pole (top), trees / plants at
## the base of the trunk, decals at their centre, everything else at the bottom centre.
static func pivot_for(group: String, image: Image) -> Vector2:
	var width: int = image.get_width()
	var height: int = image.get_height()
	match group:
		"sign":
			var sum_y: float = 0.0
			var count: float = 0.0
			var columns: int = maxi(3, int(float(width) * 0.05))
			for x: int in range(columns):
				for y: int in range(height):
					if image.get_pixel(x, y).a > 0.5:
						sum_y += float(y)
						count += 1.0
			return Vector2(0.0, (sum_y / maxf(count, 1.0)) / float(height) if count > 0.0 else 0.2)
		"banner":
			return Vector2(0.5, 0.03)
		"tree":
			var sum_x: float = 0.0
			var count_x: float = 0.0
			var rows: int = maxi(3, int(float(height) * 0.04))
			for y: int in range(height - rows, height):
				for x: int in range(width):
					if image.get_pixel(x, y).a > 0.5:
						sum_x += float(x)
						count_x += 1.0
			return Vector2((sum_x / maxf(count_x, 1.0)) / float(width) if count_x > 0.0 else 0.5, 1.0)
		"decal":
			return Vector2(0.5, 0.5)
	return Vector2(0.5, 1.0)


## The tint / slot family of a sheet row. `category` is the sheet's Category cell, `use` its In-Game Use cell, `asset` its Asset cell.
static func group_for(id: String, category: String, use: String, asset: String) -> String:
	var cat: String = category.to_lower()
	var text: String = ("%s %s %s" % [id, use, asset]).to_lower()
	if cat.begins_with("hero") or cat.contains("concept"):
		return "concept"
	if cat.contains("sky") or cat.contains("backdrop"):
		return "backdrop"
	if cat.contains("decal"):
		return "decal"
	if cat.contains("tree") or cat.contains("plant"):
		return "tree"
	if cat.contains("sheet"):
		for family: String in ["door", "window", "sign", "banner"]:
			if text.contains(family):
				return family
		# a sheet of props (the D.N.A. filing cabinets): card props standing on the ground, not wall plaques
		if text.contains("prop") or text.contains("cabinet"):
			return "prop"
		return "sign"
	if cat.contains("prop"):
		return "prop"
	for family: String in ["wall", "roof", "trim", "path", "ground"]:
		if text.contains("(%s)" % family) or id.to_lower().contains("-%s-" % family):
			return "ground" if family == "path" else family
	return "prop"


## True when the sheet says the surface tiles on this axis.
static func tiles(size_text: String, horizontal: bool) -> bool:
	var lower: String = size_text.to_lower()
	if not lower.contains("tileable"):
		return false
	if horizontal:
		return not lower.contains("vertically")
	return not lower.contains("horizontally")


## Keeps a backdrop's full width (the ring tiles by width) but drops fully transparent rows at the top and bottom.
static func trim_rows(image: Image) -> Rect2i:
	var rows: PackedByteArray = _occupancy(image, false)
	var first: int = 0
	while first < rows.size() - 1 and rows[first] == 0:
		first += 1
	var last: int = rows.size() - 1
	while last > first and rows[last] == 0:
		last -= 1
	return Rect2i(0, first, image.get_width(), last - first + 1)
