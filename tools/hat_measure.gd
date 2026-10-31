extends SceneTree
## Art import Oct 31: measures hat sheets the way the slicer sees them. For every COS-HAT-<NAME>-SHEET.png in `--dir=` (default the cosmetics inbox):
## each view's opaque bounding box (width x height), its ratio to FRONT, and the head band (HatSheet.band_width) - before and after HatSheet.normalise.
## Usage: Godot --headless --path . -s res://tools/hat_measure.gd -- --dir=res://_art_inbox/cosmetics_oct31/ [--hats=CHEF,WIZARD]


func _init() -> void:
	var dir: String = "res://_art_inbox/cosmetics/"
	var only: PackedStringArray = PackedStringArray()
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--dir="):
			dir = arg.get_slice("=", 1)
		elif arg.begins_with("--hats="):
			only = arg.get_slice("=", 1).split(",")
	var names: Array[String] = []
	for file_name: String in DirAccess.get_files_at(dir):
		if file_name.begins_with("COS-HAT-") and file_name.ends_with("-SHEET.png"):
			var hat_name: String = file_name.trim_prefix("COS-HAT-").trim_suffix("-SHEET.png")
			if only.is_empty() or only.has(hat_name):
				names.append(hat_name)
	names.sort()
	for hat_name: String in names:
		var sheet: Image = Image.load_from_file(ProjectSettings.globalize_path(dir.path_join("COS-HAT-%s-SHEET.png" % hat_name)))
		print("## %s  (sheet %dx%d)" % [hat_name, sheet.get_width(), sheet.get_height()])
		var raw: Dictionary = HatSheet.split(sheet)
		_table("raw split", raw)
		var normalised: Dictionary = HatSheet.normalise(raw)
		_table("after HatSheet.normalise", normalised)
		print("fit: %s" % JSON.stringify(HatSheet.fit(hat_name, normalised, {}, true)))
		print("")
	quit(0)


func _table(title: String, views: Dictionary) -> void:
	print("%s:" % title)
	print("| view | w x h | w / FRONT | h / FRONT | band | band / FRONT |")
	var front: Image = views.get("FRONT") as Image
	for dir_name: String in HatSheet.DIRS:
		var view: Image = views.get(dir_name) as Image
		if view == null:
			print("| %s | missing | | | | |" % dir_name)
			continue
		var band: float = HatSheet.band_width(view)
		print("| %s | %d x %d | %.2f | %.2f | %d | %.2f |" % [dir_name, view.get_width(), view.get_height(),
				float(view.get_width()) / float(front.get_width()), float(view.get_height()) / float(front.get_height()),
				int(band), band / maxf(1.0, HatSheet.band_width(front))])
