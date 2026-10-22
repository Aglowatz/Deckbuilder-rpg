extends SceneTree
## Review sheet for tools/split_sprite_sheets.gd: every split frame of every sheet on mid-grey (so halos and leftover background show), one row per key.
## Run: Godot --headless --path . -s res://tools/split_preview.gd -- [out=res://_screenshots/npc_sheet_split.png] [inbox=res://a/dry-run/folder/]

## The inbox read (the real one, or a dry-run folder given as inbox=).
var _inbox: String = "res://_art_inbox/npc_sprites/"
const FRAMES: Array[String] = ["FRONT_IDLE", "FRONT_TALK", "SIDE_IDLE", "BACK_IDLE"]
const CELL_H: int = 300


func _initialize() -> void:
	var out_path: String = "res://_screenshots/npc_sheet_split.png"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("inbox="):
			_inbox = arg.trim_prefix("inbox=")  # a dry-run folder (tools/split_sprite_sheets.gd --inbox=)
		if arg.begins_with("out="):
			out_path = arg.trim_prefix("out=")
	var keys: Array[String] = []
	var re: RegEx = RegEx.create_from_string("^SPR-([A-Z0-9_]+)$")
	for file_name: String in DirAccess.get_files_at(ProjectSettings.globalize_path(_inbox)):
		var m: RegExMatch = re.search(file_name.get_basename())
		if m != null and file_name.get_extension() == "png":
			keys.append(m.get_string(1))
	keys.sort()
	var cell_w: int = 240
	var sheet: Image = Image.create_empty(cell_w * 5, CELL_H * keys.size(), false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.45, 0.47, 0.5))
	for row: int in range(keys.size()):
		var whole: Image = Image.load_from_file(ProjectSettings.globalize_path(_inbox + "SPR-%s.png" % keys[row]))
		if whole != null:
			whole.convert(Image.FORMAT_RGBA8)
			_paste(sheet, whole, Rect2i(0, row * CELL_H, cell_w, CELL_H))
		for i: int in range(FRAMES.size()):
			var path: String = ProjectSettings.globalize_path(_inbox + "SPR-%s-%s.png" % [keys[row], FRAMES[i]])
			if not FileAccess.file_exists(path):
				continue
			var frame: Image = Image.load_from_file(path)
			frame.convert(Image.FORMAT_RGBA8)
			_paste(sheet, frame, Rect2i((i + 1) * cell_w, row * CELL_H, cell_w, CELL_H))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_path.get_base_dir()))
	sheet.save_png(ProjectSettings.globalize_path(out_path))
	print("split preview: %s (%d keys)" % [out_path, keys.size()])
	quit()


func _paste(sheet: Image, image: Image, cell: Rect2i) -> void:
	var factor: float = minf(float(cell.size.x - 8) / float(image.get_width()), float(cell.size.y - 8) / float(image.get_height()))
	var small: Image = image.duplicate()
	small.resize(maxi(1, int(image.get_width() * factor)), maxi(1, int(image.get_height() * factor)), Image.INTERPOLATE_BILINEAR)
	var at: Vector2i = cell.position + (cell.size - small.get_size()) / 2
	sheet.blend_rect(small, Rect2i(Vector2i.ZERO, small.get_size()), at)
