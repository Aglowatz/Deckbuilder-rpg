extends SceneTree
## Dialogue portrait screenshots from real scenes, several per run: `bash tools/dialogue_shots.sh <scene> <prefix> <tokens> [--size=WxH] [--zones=N]`.
## Tokens (comma separated): a spot id of the scene (`elder`, `brenda`; walks the hero there and runs the real interaction), `npc:<NPC-ID>` (that NPC's portrait
## with two placeholder lines on the scene's own dialogue box) or `story:<story key>` (a dungeon map scene: that story beat with its mapped speaker).
## Saves _screenshots/<prefix>_<token>.png once the line has typed out. Run (NOT headless).

var _args: Dictionary = {}
var _scene: Node
var _tokens: PackedStringArray = PackedStringArray()
var _prefix: String = "dlg"
var _started: bool = false
var _elapsed: float = 0.0
var _phase: int = 0
var _hold: float = 0.0
var _current: String = ""


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			_args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	_tokens = str(_args.get("talk", "")).split(",", false)
	_prefix = str(_args.get("name", "dlg"))
	var size_parts: PackedStringArray = str(_args.get("size", "1600x900")).split("x")
	if size_parts.size() == 2:
		root.size = Vector2i(int(size_parts[0]), int(size_parts[1]))
		DisplayServer.window_set_size(Vector2i(int(size_parts[0]), int(size_parts[1])))
	var session: Node = root.get_node_or_null("Session")
	if session != null:
		session.set("save_enabled", false)


func _process(delta: float) -> bool:
	if not _started:
		_started = true
		var packed: PackedScene = load(str(_args.get("scene", "res://scenes/town.tscn"))) as PackedScene
		_scene = packed.instantiate()
		if _scene.has_method("screenshot_prepare"):
			_scene.call("screenshot_prepare", _args)
		root.add_child(_scene)
		return false
	_elapsed += delta
	match _phase:
		0:
			if _elapsed >= float(_args.get("wait", 4.0)):
				_phase = 1
		1:
			if _tokens.is_empty():
				quit(0)
				return true
			_current = _tokens[0]
			_tokens.remove_at(0)
			_begin(_current)
			_hold = 0.0
			_phase = 2
		2:
			_hold += delta
			var box: Node = _box()
			if box != null and bool(box.get("active")) and _hold > 1.0 and float((box.get("_text") as Label).visible_ratio) >= 1.0:
				_hold = 0.0
				_phase = 3
			elif _hold > 12.0:
				print("dialogue_shots: no dialogue for '%s'" % _current)
				_phase = 4
		3:
			_hold += delta
			if _hold > 0.7:
				_capture(_current)
				_phase = 4
		4:
			_dismiss()
			_hold = 0.0
			_phase = 5
		5:
			_hold += delta
			if _hold > 0.5:
				_phase = 1
	return false


func _box() -> Node:
	var found: Variant = _scene.get("dialogue")
	if found == null:
		found = _scene.get("_dialogue")
	return found as Node


func _begin(token: String) -> void:
	var box: Node = _box()
	if token.begins_with("npc:"):
		var id: String = token.trim_prefix("npc:")
		box.call("start", "", ["The road north is closed again. Mind the puddles, friend.", "[happy] Long lines wrap normally: the box widens a little beside the portrait and the text never runs under the character, however many words a line takes to say."] as Array[String], id)
		return
	if token.begins_with("story:"):
		var key: String = token.trim_prefix("story:")
		var zone_id: String = str(_args.get("main", "beefcake"))
		var texts: Object = (load("res://core/data/zone_story_text.gd") as GDScript).call("for_zone", zone_id) as Object
		var speaker: String = str((load("res://core/data/npc_registry.gd") as GDScript).call("story_speaker", key))
		_scene.call("_show_story", func() -> void: pass, texts.call("get_lines", key), speaker)
		return
	_scene.call("_teleport", token)
	for spot: Variant in _scene.get("spots") as Array:
		if str((spot as Object).get("id")) == token:
			_scene.call("_interact", spot)
			return
	print("dialogue_shots: no spot '%s'" % token)


func _dismiss() -> void:
	var box: Node = _box()
	if box == null:
		return
	for connection: Dictionary in box.get_signal_connection_list("finished"):
		box.disconnect("finished", connection["callable"] as Callable)
	var guard: int = 0
	while bool(box.get("active")) and guard < 40:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = KEY_SPACE
		event.pressed = true
		box.call("_unhandled_input", event)
		guard += 1


func _capture(token: String) -> void:
	var image: Image = root.get_texture().get_image()
	DirAccess.make_dir_recursive_absolute("res://_screenshots/dialogue")
	var file_name: String = token.replace(":", "_").replace(".", "_").replace("/", "_")
	var path: String = "res://_screenshots/dialogue/%s_%s.png" % [_prefix, file_name]
	var error: Error = image.save_png(ProjectSettings.globalize_path(path))
	print("screenshot saved: %s (%s) %dx%d" % [path, error_string(error), image.get_width(), image.get_height()])
