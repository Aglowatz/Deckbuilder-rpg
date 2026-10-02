extends GutTest
## Every GDScript file in the project must load and compile (catches typos in rarely-run code such
## as tools and zone screens that no other test touches).

const SKIP_DIRS: Array[String] = ["addons", "_asset_library", ".godot", "_screenshots"]


func _collect(dir_path: String, into: Array[String]) -> void:
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		return
	for sub: String in dir.get_directories():
		if dir_path == "res://" and SKIP_DIRS.has(sub):
			continue
		if sub.begins_with("."):
			continue
		_collect(dir_path.path_join(sub), into)
	for file: String in dir.get_files():
		if file.ends_with(".gd"):
			into.append(dir_path.path_join(file))


func test_every_script_compiles() -> void:
	var paths: Array[String] = []
	_collect("res://", paths)
	assert_gt(paths.size(), 100, "found the project's scripts")
	var failures: Array[String] = []
	for path: String in paths:
		var script: GDScript = load(path) as GDScript
		if script == null or not script.can_instantiate():
			failures.append(path)
	assert_eq(failures, [] as Array[String], "scripts that fail to compile")
