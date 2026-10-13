extends SceneTree
## Tiles an image 3x2 into one PNG to judge a seam by eye.   Godot --headless --path . -s res://tools/tile_preview.gd -- --ids=ENV-WALL-TIMBER,ENV-GROUND-COBBLE --out=res://_screenshots/tiles.png


func _initialize() -> void:
	var args: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			args[parts[0]] = parts[1] if parts.size() > 1 else ""
	var ids: PackedStringArray = str(args.get("ids", "")).split(",", false)
	var cell: int = 360
	var out: Image = Image.create(cell * 3 * mini(ids.size(), 2), cell * 2 * int(ceil(ids.size() / 2.0)), false, Image.FORMAT_RGB8)
	for index: int in range(ids.size()):
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path("res://assets/art/env_kit/%s.webp" % ids[index]))
		image.convert(Image.FORMAT_RGB8)
		image.resize(cell, int(cell * float(image.get_height()) / float(image.get_width())), Image.INTERPOLATE_BILINEAR)
		var ox: int = (index % 2) * cell * 3
		var oy: int = (index / 2) * cell * 2
		for ty: int in range(2):
			for tx: int in range(3):
				out.blit_rect(image, Rect2i(0, 0, image.get_width(), image.get_height()), Vector2i(ox + tx * cell, oy + ty * image.get_height()))
	out.save_png(ProjectSettings.globalize_path(str(args.get("out", "res://_screenshots/tiles.png"))))
	quit(0)
