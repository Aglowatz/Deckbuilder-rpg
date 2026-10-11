extends SceneTree
## Loading screen screenshots, one per LOAD-* image: `bash tools/loading_shots.sh [WxH]` -> _screenshots/loading/<area>_<WxH>.png (run NOT headless).

var _size: Vector2i = Vector2i(1600, 900)
var _keys: PackedStringArray = PackedStringArray(["start", "town", "gainlands", "dna", "buffet", "dump", "capital", "dungeon", "lab"])
var _index: int = -1
var _wait: float = 0.0
var _screen: Node


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--size="):
			var parts: PackedStringArray = arg.substr(7).split("x")
			_size = Vector2i(int(parts[0]), int(parts[1]))
	root.size = _size
	DisplayServer.window_set_size(_size)
	var session: Node = root.get_node_or_null("Session")
	if session != null:
		session.set("save_enabled", false)


func _process(delta: float) -> bool:
	_wait -= delta
	if _wait > 0.0:
		return false
	if _screen != null:
		var image: Image = root.get_texture().get_image()
		var name_text: String = _keys[_index]
		DirAccess.make_dir_recursive_absolute("res://_screenshots/loading")
		var error: Error = image.save_png(ProjectSettings.globalize_path("res://_screenshots/loading/%s_%dx%d.png" % [name_text, _size.x, _size.y]))
		print("screenshot saved: loading/%s (%s)" % [name_text, error_string(error)])
		_screen.queue_free()
		_screen = null
	_index += 1
	if _index >= _keys.size():
		quit(0)
		return true
	var key: String = _keys[_index]
	var area_script: GDScript = load("res://core/data/areas.gd") as GDScript
	var screen_script: GDScript = load("res://ui/screens/loading_screen.gd") as GDScript
	var dungeon_id: String = "D-LAB" if key == "lab" else ""
	var area_key: String = "dungeon" if key == "lab" else key
	_screen = screen_script.call("make", area_key, dungeon_id) as Node
	if _screen == null:
		print("no loading screen for %s" % key)
		_wait = 0.1
		return false
	root.add_child(_screen)
	_wait = 0.6
	return false
