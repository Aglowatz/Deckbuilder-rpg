extends SceneTree
## Converts _screenshots/<name>.png to docs/art/screens/<folder>/<name>.jpg (quality 0.88) for the names given:
##   Godot --headless --path . -s res://tools/png_to_jpg.gd -- folder name1 name2 ...


func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var folder: String = args[0]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://docs/art/screens/%s" % folder))
	for index: int in range(1, args.size()):
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path("res://_screenshots/%s.png" % args[index]))
		if image == null:
			print("missing %s" % args[index])
			continue
		var error: Error = image.save_jpg(ProjectSettings.globalize_path("res://docs/art/screens/%s/%s.jpg" % [folder, args[index]]), 0.88)
		print("%s: %s" % [args[index], error_string(error)])
	quit(0)
