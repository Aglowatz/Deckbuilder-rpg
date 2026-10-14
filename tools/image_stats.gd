extends SceneTree
## Grade numbers of one or more images (the paint-over beside a screenshot): mean RGB, luma percentiles (p5 / p50 / p95), mean HSV saturation, and the mean colour of the
## top, middle and bottom thirds (sky, mid ground, foreground). Images are compared at the same size (each scaled to 400 px wide), so the numbers are comparable.
##   Godot --headless --path . -s res://tools/image_stats.gd -- res://docs/art/paintovers/PAINTOVER-GAINLANDS-HUB.png res://_screenshots/gainlands_slice/PO-GAINLANDS-HUB.png
## Prints one markdown table row per image: | file | mean RGB | luma p5 / p50 / p95 | saturation | top / mid / bottom mean RGB |


func _initialize() -> void:
	var paths: Array[String] = []
	for arg: String in OS.get_cmdline_user_args():
		if not arg.begins_with("--"):
			paths.append(arg)
	print("| image | mean RGB | luma p5 / p50 / p95 | saturation | sky / mid / ground |")
	print("|---|---|---|---|---|")
	for path: String in paths:
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
		if image == null:
			print("| %s | (unreadable) | | | |" % path.get_file())
			continue
		image.convert(Image.FORMAT_RGB8)
		var width: int = 400
		var height: int = int(round(float(image.get_height()) * float(width) / float(image.get_width())))
		image.resize(width, height, Image.INTERPOLATE_LANCZOS)
		var sum: Vector3 = Vector3.ZERO
		var sat: float = 0.0
		var lumas: PackedFloat32Array = PackedFloat32Array()
		var thirds: Array[Vector3] = [Vector3.ZERO, Vector3.ZERO, Vector3.ZERO]
		var counts: Array[int] = [0, 0, 0]
		for y: int in range(height):
			for x: int in range(width):
				var c: Color = image.get_pixel(x, y)
				sum += Vector3(c.r, c.g, c.b)
				sat += c.s
				lumas.append(c.r * 0.299 + c.g * 0.587 + c.b * 0.114)
				var third: int = mini(y * 3 / height, 2)
				thirds[third] += Vector3(c.r, c.g, c.b)
				counts[third] += 1
		var n: float = float(width * height)
		lumas.sort()
		var p: Callable = func(q: float) -> int: return int(round(lumas[int(q * float(lumas.size() - 1))] * 255.0))
		var mean: Vector3 = sum / n * 255.0
		var parts: PackedStringArray = PackedStringArray()
		for index: int in range(3):
			var t: Vector3 = thirds[index] / float(maxi(counts[index], 1)) * 255.0
			parts.append("%d,%d,%d" % [int(t.x), int(t.y), int(t.z)])
		print("| %s | %d, %d, %d | %d / %d / %d | %.2f | %s |" % [path.get_file(), int(mean.x), int(mean.y), int(mean.z), p.call(0.05), p.call(0.5), p.call(0.95), sat / n, " / ".join(parts)])
	quit(0)
