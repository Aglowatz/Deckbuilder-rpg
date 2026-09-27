extends SceneTree
## Launches a scene in a normal window, waits for it to settle, saves the viewport to
## _screenshots/<name>.png and quits. Run (NOT headless):
##   Godot --path . -s res://tools/screenshot.gd -- --scene=res://scenes/title.tscn --name=title
## Options: --wait=<seconds> (default 1.5), --size=1600x900, --setup=<key=value,key=value>
## The scene may implement `screenshot_prepare(args: Dictionary)` to reach a specific state and
## `screenshot_ready() -> bool` to say when it has finished settling.

var _scene_path: String = ""
var _shot_name: String = "shot"
var _wait: float = 1.5
var _args: Dictionary = {}
var _elapsed: float = 0.0
var _scene: Node
var _started: bool = false


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if not arg.begins_with("--"):
			continue
		var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
		var value: String = parts[1] if parts.size() > 1 else "true"
		_args[parts[0]] = value
	_scene_path = str(_args.get("scene", "res://scenes/title.tscn"))
	_shot_name = str(_args.get("name", "shot"))
	_wait = float(_args.get("wait", 1.5))
	var size_text: String = str(_args.get("size", "1600x900"))
	var size_parts: PackedStringArray = size_text.split("x")
	if size_parts.size() == 2:
		root.size = Vector2i(int(size_parts[0]), int(size_parts[1]))
		DisplayServer.window_set_size(Vector2i(int(size_parts[0]), int(size_parts[1])))
	# Never touch the player's real save.
	var session: Node = root.get_node_or_null("Session")
	if session != null:
		session.set("save_enabled", false)


func _process(delta: float) -> bool:
	if not _started:
		_started = true
		var packed: PackedScene = load(_scene_path) as PackedScene
		if packed == null:
			push_error("screenshot: cannot load %s" % _scene_path)
			quit(1)
			return true
		_scene = packed.instantiate()
		if _scene.has_method("screenshot_prepare"):
			_scene.call("screenshot_prepare", _args)
		root.add_child(_scene)
		return false
	_elapsed += delta
	if _elapsed < _wait:
		return false
	if _scene.has_method("screenshot_ready") and not bool(_scene.call("screenshot_ready")) and _elapsed < _wait + 20.0:
		return false
	var image: Image = root.get_texture().get_image()
	DirAccess.make_dir_recursive_absolute("res://_screenshots")
	var path: String = "res://_screenshots/%s.png" % _shot_name
	var error: Error = image.save_png(ProjectSettings.globalize_path(path))
	print("screenshot saved: %s (%s) %dx%d" % [path, error_string(error), image.get_width(), image.get_height()])
	quit(0)
	return true
