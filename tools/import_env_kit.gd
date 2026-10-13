extends SceneTree
## "import env kit art": copies the Environment Kit art (data/art/environment_kit.json ids) from envkit_dir in data/source/art_config.cfg (read-only on the Drive) to
## assets/art/env_kit/<ID>.webp (alpha kept, 1536 px max). EnvKit picks the files up by itself: a kit id with a file is real art, without one it keeps its placeholder.
## Options: --only=ENV-DOOR-01,ENV-SIGN-INN   --out=res://_art_inbox/env_kit_preview/ (a preview folder; point ENV_KIT_ART_DIR at it to look without committing)
## Writes docs/art/env_kit_import_report.md. Never creates art.

const CONFIG: String = "res://data/source/art_config.cfg"
const MAX_SIDE: int = 1536
const Prep = preload("res://tools/env_kit_prep.gd")
const PREP_PATH: String = "res://data/art/env_kit_prep.json"


func _initialize() -> void:
	var args: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			args[parts[0]] = parts[1] if parts.size() > 1 else ""
	var config: ConfigFile = ConfigFile.new()
	config.load(CONFIG)
	var source: String = OS.get_environment("ENV_KIT_SOURCE_DIR")
	if source == "":
		source = str(config.get_value("", "envkit_dir", "G:/My Drive/Card Game Art/Approved_EnvKit"))
	for forbidden: String in ["Pending Review", "Superseded"]:
		if source.contains(forbidden):
			print("import_env_kit: refusing to read from %s" % forbidden)
			quit(1)
			return
	var out_dir: String = str(args.get("out", "res://assets/art/env_kit/"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	var only: PackedStringArray = str(args.get("only", "")).split(",", false)
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/art/environment_kit.json")) as Dictionary
	var wanted: Array[String] = []
	var wanted_entries: Dictionary = {}
	var prep: Dictionary = {}
	for item: Variant in data["items"] as Array:
		var entry: Dictionary = item as Dictionary
		if bool(entry.get("suggested", false)) and not entry.has("sheet_status"):
			continue
		wanted.append(str(entry["id"]))
		wanted_entries[str(entry["id"])] = entry
	var imported: PackedStringArray = PackedStringArray()
	var missing: PackedStringArray = PackedStringArray()
	for id: String in wanted:
		if not only.is_empty() and not (id in only):
			continue
		var path: String = "%s/%s.png" % [source, id]
		if not FileAccess.file_exists(path):
			missing.append(id)
			continue
		var image: Image = Image.load_from_file(path)
		if image == null or image.is_empty():
			missing.append(id + " (unreadable)")
			continue
		var longest: int = maxi(image.get_width(), image.get_height())
		if longest > MAX_SIDE:
			var scale_value: float = float(MAX_SIDE) / float(longest)
			image.resize(int(round(float(image.get_width()) * scale_value)), int(round(float(image.get_height()) * scale_value)), Image.INTERPOLATE_LANCZOS)
		image.convert(Image.FORMAT_RGBA8)
		var out_base: String = ProjectSettings.globalize_path(out_dir if out_dir.ends_with("/") else out_dir + "/")
		var info: Dictionary = _prepare(id, image, out_base, wanted_entries[id] as Dictionary)
		prep[id] = info
		var target: String = "%s%s.webp" % [out_base, id]
		var error: Error = image.save_webp(target, true, 0.92)
		if error == OK:
			imported.append("%s (%dx%d%s)" % [id, image.get_width(), image.get_height(), (", seam " + str(info.get("seam_note", ""))) if info.has("seam_note") else ""])
		else:
			missing.append("%s (save: %s)" % [id, error_string(error)])
	var stray: PackedStringArray = PackedStringArray()
	var dir: DirAccess = DirAccess.open(source)
	if dir != null:
		for file_name: String in dir.get_files():
			if file_name.get_extension().to_lower() == "png" and not (file_name.get_basename() in wanted):
				stray.append(file_name)
	var report: PackedStringArray = PackedStringArray()
	report.append("# Environment Kit import report\n")
	report.append("Source: `%s` (read-only), target: `%s`.\n" % [source, out_dir])
	report.append("\n## Imported (%d)\n" % imported.size())
	for line: String in imported:
		report.append("- %s" % line)
	report.append("\n## Missing (%d)\n" % missing.size())
	for line: String in missing:
		report.append("- %s" % line)
	report.append("\n## Files that match no kit id (%d)\n" % stray.size())
	for line: String in stray:
		report.append("- %s" % line)
	if out_dir == "res://assets/art/env_kit/":
		_write_prep(prep)
	if only.is_empty() and out_dir == "res://assets/art/env_kit/":
		var file: FileAccess = FileAccess.open("res://docs/art/env_kit_import_report.md", FileAccess.WRITE)
		file.store_string("\n".join(report) + "\n")
		file.close()
	print("import_env_kit: %d imported, %d missing, %d unmatched" % [imported.size(), missing.size(), stray.size()])
	for line: String in missing:
		print("  missing: %s" % line)
	quit(0)


## Prepares `image` in place by lock (see env_kit_prep.gd) and writes the normal / roughness maps of surfaces beside it. Returns the numbers for data/art/env_kit_prep.json.
func _prepare(id: String, image: Image, out_base: String, entry: Dictionary) -> Dictionary:
	var lock: String = str(entry.get("lock", "")).to_upper()
	var size_text: String = str(entry.get("size", "")).to_lower()
	var info: Dictionary = {"lock": lock}
	if lock == "SURFACE":
		var tile_x: bool = size_text.contains("tileable")
		var tile_y: bool = size_text.contains("tileable") and not size_text.contains("horizontally")
		var notes: PackedStringArray = PackedStringArray()
		var seam: Dictionary = {}
		for axis: String in ["x", "y"]:
			var horizontal: bool = axis == "x"
			if not (tile_x if horizontal else tile_y):
				continue
			var before: float = Prep.seam_ratio(image, horizontal)
			var after: float = before
			if before > Prep.SEAM_LIMIT and not Prep.STRUCTURED.has(id):
				var fixed: Image = Prep.make_seamless(image, horizontal)
				var fixed_ratio: float = Prep.seam_ratio(fixed, horizontal)
				if fixed_ratio >= before:
					fixed = image
				image.copy_from(fixed)
				after = Prep.seam_ratio(image, horizontal)
			seam[axis] = {"before": snappedf(before, 0.01), "after": snappedf(after, 0.01)}
			notes.append("%s %.1f->%.1f" % [axis, before, after])
		info["seam"] = seam
		info["seam_note"] = ", ".join(notes) if not notes.is_empty() else "no tiling"
		info["tile_x"] = tile_x
		info["tile_y"] = tile_y
		info["px"] = [image.get_width(), image.get_height()]
		info["tile_u"] = snappedf(float(image.get_width()) / Prep.DENSITY, 0.01)
		info["tile_v"] = snappedf(float(image.get_height()) / Prep.DENSITY, 0.01)
		var small: Image = image.duplicate() as Image
		if maxi(small.get_width(), small.get_height()) > 512:
			var factor: float = 512.0 / float(maxi(small.get_width(), small.get_height()))
			small.resize(int(small.get_width() * factor), int(small.get_height() * factor), Image.INTERPOLATE_BILINEAR)
		var normal: Image = Prep.normal_map(small, tile_x, tile_y)
		normal.save_webp("%s%s_n.webp" % [out_base, id], true, 0.9)
		var rough: Image = Prep.roughness_map(small)
		rough.convert(Image.FORMAT_RGB8)
		rough.save_webp("%s%s_r.webp" % [out_base, id], true, 0.85)
		info["maps"] = true
	else:
		var cleared: int = Prep.clean_alpha(image)
		var rect: Rect2i = Prep.bounds(image)
		var pad: int = 2
		var padded: Rect2i = Rect2i(maxi(rect.position.x - pad, 0), maxi(rect.position.y - pad, 0), 0, 0)
		padded.end = Vector2i(mini(rect.end.x + pad, image.get_width()), mini(rect.end.y + pad, image.get_height()))
		var original_size: Vector2i = image.get_size()
		var trimmed: Image = image.get_region(padded)
		image.copy_from(trimmed)
		var pivot: Vector2 = Prep.pivot_for(id, image)
		info["px"] = [image.get_width(), image.get_height()]
		info["from_px"] = [original_size.x, original_size.y]
		info["pivot"] = [snappedf(pivot.x, 0.001), snappedf(pivot.y, 0.001)]
		info["aspect"] = snappedf(float(image.get_width()) / float(image.get_height()), 0.001)
		info["cleared_alpha"] = cleared
		info["seam_note"] = "trimmed %dx%d, pivot %.2f,%.2f" % [image.get_width(), image.get_height(), pivot.x, pivot.y]
	return info


func _write_prep(prep: Dictionary) -> void:
	var existing: Dictionary = {}
	if FileAccess.file_exists(PREP_PATH):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PREP_PATH))
		if parsed is Dictionary:
			existing = (parsed as Dictionary).get("items", {}) as Dictionary
	for id: String in prep.keys():
		var info: Dictionary = (prep[id] as Dictionary).duplicate()
		info.erase("seam_note")
		existing[id] = info
	var keys: Array = existing.keys()
	keys.sort()
	var ordered: Dictionary = {}
	for key: Variant in keys:
		ordered[key] = existing[key]
	var file: FileAccess = FileAccess.open(PREP_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify({"_about": "Written by tools/import_env_kit.gd (env_kit_prep.gd): per kit id the prepared size, pivot (0..1 of the trimmed image), tile size in metres at %d px/m, the seam error before / after the repair." % int(Prep.DENSITY), "density": Prep.DENSITY, "items": ordered}, "\t"))
	file.close()
