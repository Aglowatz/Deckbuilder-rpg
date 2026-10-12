extends SceneTree
## Converts every PNG in a folder to a 1280x720 JPEG next to it and deletes the PNG (documentation screenshots stay small):
##   Godot --headless --path . -s res://tools/png_to_jpg.gd -- --dir=res://docs/art/world_rollout/

func _initialize() -> void:
	var folder: String = "res://docs/art/world_rollout/"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--dir="):
			folder = arg.substr(6)
	var absolute: String = ProjectSettings.globalize_path(folder)
	for file_name: String in DirAccess.get_files_at(absolute):
		if file_name.get_extension() != "png":
			continue
		var image: Image = Image.load_from_file(absolute.path_join(file_name))
		if image == null:
			continue
		image.resize(1280, 720, Image.INTERPOLATE_LANCZOS)
		image.save_jpg(absolute.path_join(file_name.get_basename() + ".jpg"), 0.88)
		DirAccess.remove_absolute(absolute.path_join(file_name))
	quit()
