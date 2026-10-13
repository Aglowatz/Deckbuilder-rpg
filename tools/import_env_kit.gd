extends SceneTree
## "import env kit art": copies the Environment Kit art (data/art/environment_kit.json ids) from envkit_dir in data/source/art_config.cfg (read-only on the Drive) to
## assets/art/env_kit/<ID>.webp (alpha kept, 1536 px max). EnvKit picks the files up by itself: a kit id with a file is real art, without one it keeps its placeholder.
## Options: --only=ENV-DOOR-01,ENV-SIGN-INN   --out=res://_art_inbox/env_kit_preview/ (a preview folder; point ENV_KIT_ART_DIR at it to look without committing)
## Writes docs/art/env_kit_import_report.md. Never creates art.

const CONFIG: String = "res://data/source/art_config.cfg"
const MAX_SIDE: int = 1536


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
	for item: Variant in data["items"] as Array:
		var entry: Dictionary = item as Dictionary
		if bool(entry.get("suggested", false)) and not entry.has("sheet_status"):
			continue
		wanted.append(str(entry["id"]))
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
		var target: String = ProjectSettings.globalize_path("%s%s.webp" % [out_dir if out_dir.ends_with("/") else out_dir + "/", id])
		var error: Error = image.save_webp(target, true, 0.92)
		if error == OK:
			imported.append("%s (%dx%d)" % [id, image.get_width(), image.get_height()])
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
	if only.is_empty() and out_dir == "res://assets/art/env_kit/":
		var file: FileAccess = FileAccess.open("res://docs/art/env_kit_import_report.md", FileAccess.WRITE)
		file.store_string("\n".join(report) + "\n")
		file.close()
	print("import_env_kit: %d imported, %d missing, %d unmatched" % [imported.size(), missing.size(), stray.size()])
	for line: String in missing:
		print("  missing: %s" % line)
	quit(0)
