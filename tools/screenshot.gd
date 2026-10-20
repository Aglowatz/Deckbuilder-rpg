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
var _hovered: bool = false
var _reacted: bool = false
var _went: bool = false
var _swivelled: bool = false
var _cleaned: bool = false


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


## `--set=colorblind_symbols:true,ui_scale:1.3,text_cards:3` sets Settings values for the shot (never saved). Runs on the first frame, after the Settings autoload loaded the saved file.
func _apply_settings_args() -> void:
	var settings: Node = root.get_node_or_null("Settings")
	if settings == null:
		return
	for pair: String in str(_args.get("set", "")).split(",", false):
		var kv: PackedStringArray = pair.split(":")
		if kv.size() != 2:
			continue
		var current: Variant = settings.get(kv[0])
		if typeof(current) == TYPE_BOOL:
			settings.set(kv[0], kv[1] == "true")
		elif typeof(current) == TYPE_INT:
			settings.set(kv[0], int(kv[1]))
		elif typeof(current) == TYPE_FLOAT:
			settings.set(kv[0], float(kv[1]))
	settings.call("apply_tooltip_theme")


func _find_vendor(node: Node) -> Node:
	if node.has_method("vendor_react") and node.get("stage") != null:
		return node
	for child: Node in node.get_children():
		var found: Node = _find_vendor(child)
		if found != null:
			return found
	return null


func _process(delta: float) -> bool:
	if not _started:
		_started = true
		_apply_settings_args()
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
	if _args.has("hover") and not _hovered and _elapsed >= _wait - 0.7 and str(_args["hover"]).contains(","):
		# `--hover=x,y`: puts the mouse there (viewport pixels) shortly before the shot, so hover effects show.
		_hovered = true
		var xy: PackedStringArray = str(_args["hover"]).split(",")
		var motion: InputEventMouseMotion = InputEventMouseMotion.new()
		motion.position = Vector2(float(xy[0]), float(xy[1]))
		motion.global_position = motion.position
		root.push_input(motion)
		Input.warp_mouse(motion.position)
	if _args.has("swivel") and not _swivelled and _elapsed >= 0.5:
		# `--swivel=left|right`: holds the camera swivel key (Z / X) for the shot.
		_swivelled = true
		Input.action_press(&"camera_swivel_left" if str(_args["swivel"]) == "left" else &"camera_swivel_right")
	if _args.has("goto") and not _went and _elapsed >= 0.8:
		# `--goto=res://scenes/x.tscn`: changes scene through SceneManager (fade, loading screen) so the transition itself can be photographed with --wait.
		_went = true
		var manager: Node = root.get_node_or_null("SceneManager")
		if manager != null:
			manager.call("change_scene", str(_args["goto"]))
	if _args.has("react") and not _reacted and _elapsed >= _wait - 0.45:
		# `--react=buy`: the open vendor screen reacts as after a purchase (speech line, stamp, shout...).
		_reacted = true
		var vendor: Node = _find_vendor(root)
		if vendor != null:
			vendor.call("vendor_react", str(_args["react"]))
	if _elapsed < _wait:
		return false
	if _scene.has_method("screenshot_ready") and not bool(_scene.call("screenshot_ready")) and _elapsed < _wait + 20.0:
		return false
	if _args.has("goto") and _elapsed < _wait + 0.0:
		return false
	if str(_args.get("clean", "false")) == "true" and not _cleaned:
		_cleaned = true
		# `--clean=true`: no world labels or spot markers in the picture (paint-over inputs, like tools/zone_shots.gd)
		for label: Node in root.find_children("*", "Label3D", true, false):
			(label as Label3D).visible = false
		for mesh: Node in root.find_children("*", "MeshInstance3D", true, false):
			if (mesh as MeshInstance3D).mesh is PrismMesh:
				(mesh as MeshInstance3D).visible = false
		return false  # one more frame so the hidden labels are gone from the picture
	var image: Image = root.get_texture().get_image()
	DirAccess.make_dir_recursive_absolute("res://_screenshots")
	# `--jpg=true` writes a small JPEG instead (for the screenshots committed under docs/art/screens).
	var jpg: bool = str(_args.get("jpg", "false")) == "true"
	var path: String = "res://_screenshots/%s.%s" % [_shot_name, "jpg" if jpg else "png"]
	var error: Error = image.save_jpg(ProjectSettings.globalize_path(path), 0.9) if jpg else image.save_png(ProjectSettings.globalize_path(path))
	print("screenshot saved: %s (%s) %dx%d" % [path, error_string(error), image.get_width(), image.get_height()])
	quit(0)
	return true
