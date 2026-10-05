extends SceneTree
## Writes the starting pack data (PackDefinitions) to data/packs/*.tres, but ONLY for files that do not exist yet, so tuned
## weights and prices are never overwritten. Run from the project root:
##   Godot --headless --path . -s res://tools/generate_packs.gd


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(PackCatalog.DIR))
	var written: int = 0
	for pack: PackData in PackDefinitions.all():
		written += _save_if_missing(pack, PackCatalog.DIR + pack.id + ".tres")
	written += _save_if_missing(PackConfig.new(), PackCatalog.CONFIG_PATH)
	print("Wrote %d pack files (existing ones are kept)." % written)
	quit(0)


func _save_if_missing(resource: Resource, path: String) -> int:
	if FileAccess.file_exists(path):
		return 0
	resource.take_over_path(path)
	var err: int = ResourceSaver.save(resource, path)
	if err != OK:
		push_error("Failed to save %s (error %d)" % [path, err])
		return 0
	return 1
