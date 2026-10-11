extends SceneTree
## Story still screenshots, one per STORY-* image with its first caption typed out: `bash tools/story_still_shots.sh [WxH]` -> _screenshots/stills/<id>_<WxH>.png (run NOT headless).

var _size: Vector2i = Vector2i(1600, 900)
var _ids: PackedStringArray = PackedStringArray(["STORY-WAKE", "STORY-FLEX", "STORY-DOPPEL", "STORY-APPROVAL", "STORY-ROTHEART", "STORY-PRIMM", "STORY-REUNION"])
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
		DirAccess.make_dir_recursive_absolute("res://_screenshots/stills")
		var error: Error = image.save_png(ProjectSettings.globalize_path("res://_screenshots/stills/%s_%dx%d.png" % [_ids[_index], _size.x, _size.y]))
		print("screenshot saved: stills/%s (%s)" % [_ids[_index], error_string(error)])
		var layer: Node = _screen.get_parent()
		layer.get_parent().remove_child(layer)
		layer.queue_free()
		_screen = null
	_index += 1
	if _index >= _ids.size():
		quit(0)
		return true
	var script: GDScript = load("res://ui/screens/story_still_screen.gd") as GDScript
	_screen = script.call("play", root, _ids[_index], Callable()) as Node
	if _screen == null:
		print("no art for %s" % _ids[_index])
		_wait = 0.1
		return false
	_wait = 3.2
	return false
