extends SceneTree
## UI + economy fixes Oct 22: opens every full-screen menu of the town (and a zone vendor) in a real window and reports, per screen:
## - controls that run past the edge of the screen (outside any scroll area that would clip them),
## - buttons whose text is cut (clip_text with a text wider than the button),
## - whether a visible exit (the close button, or a Close / Back / Continue / Resume / Done button) sits fully on screen.
## Run (NOT headless), one resolution per run:
##   Godot --path . --resolution 1280x720 -s res://tools/layout_check.gd -- --size=1280x720 [--screens=deck,vendor] [--shots=true] [--tag=after]
## or `bash tools/layout_check.sh` for the whole set. Report lines start with "LAYOUT"; shots go to _screenshots/layout/<tag>/<size>/<screen>.png.

const TOWN: String = "res://scenes/town.tscn"
const SCREENS: Array[String] = ["deck", "vendor", "item_vendor", "equipment_vendor", "pack_vendor", "tailor", "alchemist", "wardrobe",
	"character", "codex", "bestiary", "quests", "map_all", "arena", "chest_popup", "quest_popup", "level_popup", "pause", "pause_settings",
	"settings_display", "settings_text", "settings_access", "settings_controls", "settings_audio", "pause_load"]
const EXIT_WORDS: Array[String] = ["close", "back", "continue", "resume", "done", "leave", "ok", "collect", "claim", "x", "got it"]

var _args: Dictionary = {}
var _town: Node
var _queue: Array[String] = []
var _current: String = ""
var _wait: float = 0.0
var _phase: int = 0
var _size_text: String = "1920x1080"
var _problems: int = 0


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			_args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	_size_text = str(_args.get("size", "1920x1080"))
	var wh: PackedStringArray = _size_text.split("x")
	if wh.size() == 2:
		root.size = Vector2i(int(wh[0]), int(wh[1]))
		DisplayServer.window_set_size(Vector2i(int(wh[0]), int(wh[1])))
	var session: Node = root.get_node_or_null("Session")
	if session != null:
		session.set("save_enabled", false)
	var only: String = str(_args.get("screens", ""))
	for screen: String in (only.split(",", false) if only != "" else PackedStringArray(SCREENS)):
		_queue.append(screen)


func _process(delta: float) -> bool:
	if _town == null:
		# `--ui_scale=1.5`: the UI scale setting for the run (never saved). Every window size draws on a 1920x1080 canvas (canvas_items stretch,
		# keep aspect), so the UI scale is what really shrinks the room a screen has: 150 % leaves it 1280x720.
		var settings: Node = root.get_node_or_null("Settings")
		if settings != null and _args.has("ui_scale"):
			settings.set("ui_scale", float(_args["ui_scale"]))
			settings.emit_signal("ui_scale_changed")
		_size_text = "%s@%s" % [_size_text, str(_args.get("ui_scale", "1.0"))]
		print("LAYOUT canvas %s window %s" % [root.get_visible_rect().size, DisplayServer.window_get_size()])
		var packed: PackedScene = load(TOWN) as PackedScene
		_town = packed.instantiate()
		_town.call("screenshot_prepare", {"quiet": "true", "nohud": "false"})
		root.add_child(_town)
		_wait = 6.0
		return false
	_wait -= delta
	if _wait > 0.0:
		return false
	match _phase:
		0:
			if _queue.is_empty():
				print("LAYOUT DONE %s problems=%d" % [_size_text, _problems])
				quit(0)
				return true
			_current = _queue.pop_front()
			_town.call("_screenshot_open", _current)
			_phase = 1
			_wait = 2.2
		1:
			_check(_current)
			_phase = 2
			_wait = 0.1
		2:
			_close_all()
			_phase = 0
			_wait = 0.8
	return false


## The thing on top: the pause menu when it is open, else the town's overlay.
func _top() -> Node:
	var manager: Node = root.get_node_or_null("SceneManager")
	var pause: CanvasLayer = manager.get("_pause_menu") as CanvasLayer if manager != null else null
	if pause != null and pause.visible:
		return pause
	return _town.get("_overlay") as Node


func _check(screen: String) -> void:
	var top: Node = _top()
	var view: Rect2 = root.get_visible_rect()
	if top == null:
		print("LAYOUT %s %s: NOTHING OPEN" % [_size_text, screen])
		_problems += 1
		return
	var overflow: Array[String] = []
	var clipped: Array[String] = []
	var exit_ok: bool = false
	var close_button: Control = top.get("_close_button") as Control if top.get("_close_button") is Control else null
	for node: Node in top.find_children("*", "Control", true, false):
		var control: Control = node as Control
		if not control.is_visible_in_tree() or control.size.x < 2.0 or control.size.y < 2.0 or _clipped_by_scroll(control, top):
			continue
		if control.modulate.a < 0.05 or _transparent(control):
			continue
		var rect: Rect2 = control.get_global_rect()
		var inside: bool = rect.position.x >= view.position.x - 2.0 and rect.position.y >= view.position.y - 2.0 and rect.end.x <= view.end.x + 2.0 and rect.end.y <= view.end.y + 2.0
		if not inside and not _is_backdrop(control, view):
			overflow.append("%s %s" % [_short(control, top), _rect_text(rect)])
		var button: Button = control as Button
		if button != null and button.clip_text and button.text != "" and button.icon == null:
			var font: Font = button.get_theme_font("font")
			var width: float = font.get_string_size(button.text, HORIZONTAL_ALIGNMENT_LEFT, -1, button.get_theme_font_size("font_size")).x
			var box: StyleBox = button.get_theme_stylebox("normal")
			var room: float = button.size.x - (box.get_minimum_size().x if box != null else 8.0)
			if width > room + 1.0:
				clipped.append("'%s' (%d px text in %d px)" % [button.text, int(width), int(button.size.x)])
		if button != null and inside and not button.disabled:
			if button == close_button:
				exit_ok = true
			var words: String = ("%s %s" % [button.text, button.tooltip_text]).to_lower()
			for word: String in EXIT_WORDS:
				if words.begins_with(word) or words.contains(" %s" % word) or button.text.to_lower() == word:
					exit_ok = true
	var verdict: String = "OK" if overflow.is_empty() and clipped.is_empty() and exit_ok else "PROBLEM"
	if verdict != "OK":
		_problems += 1
	var scaler: Node = top.get_node_or_null("UiScaleFit")
	if scaler == null:
		for child: Node in top.get_children():
			if child.get_node_or_null("UiScaleFit") != null:
				scaler = child.get_node("UiScaleFit")
	var drawn_at: float = float(scaler.call("current_factor")) if scaler != null else -1.0
	print("LAYOUT %s %s: %s exit=%s overflow=%d clipped=%d drawn_at=%.2f" % [_size_text, screen, verdict, "yes" if exit_ok else "NO", overflow.size(), clipped.size(), drawn_at])
	if _args.has("mins"):
		for child: Node in top.get_children():
			if child is Control:
				print("LAYOUT   min: %s %s" % [child.name, (child as Control).get_combined_minimum_size()])
				for grandchild: Node in child.get_children():
					if grandchild is Control:
						print("LAYOUT     min: %s %s" % [grandchild.name, (grandchild as Control).get_combined_minimum_size()])
	for line: String in overflow.slice(0, 12):
		print("LAYOUT   over: ", line)
	for line: String in clipped.slice(0, 12):
		print("LAYOUT   clip: ", line)
	if str(_args.get("shots", "false")) == "true":
		var image: Image = root.get_texture().get_image()
		var folder: String = "res://_screenshots/layout/%s/%s" % [str(_args.get("tag", "check")), _size_text]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		image.save_png(ProjectSettings.globalize_path("%s/%s.png" % [folder, screen]))


func _clipped_by_scroll(control: Control, top: Node) -> bool:
	var parent: Node = control.get_parent()
	while parent != null and parent != top:
		if parent is ScrollContainer or (parent is Control and (parent as Control).clip_contents):
			return true
		parent = parent.get_parent()
	return false


## Full-screen backdrops (cover-fitted pictures, shades) are allowed to be as big as or bigger than the screen.
func _is_backdrop(control: Control, view: Rect2) -> bool:
	# The vendor's painted portrait stands behind the counter and is meant to run off the bottom edge.
	if control.name == &"VendorPortrait":
		return true
	if control is TextureRect or control is ColorRect or control is Panel:
		return control.size.x >= view.size.x * 0.9 or control.size.y >= view.size.y * 0.9
	return control.mouse_filter == Control.MOUSE_FILTER_IGNORE and control.get_child_count() == 0 and not (control is Label)


## Plain layout boxes draw nothing themselves; their children are checked one by one.
func _transparent(control: Control) -> bool:
	return control.get_class() in ["Control", "VBoxContainer", "HBoxContainer", "MarginContainer", "CenterContainer", "GridContainer", "HFlowContainer", "VFlowContainer"]


func _short(control: Control, top: Node) -> String:
	var path: String = str(top.get_path_to(control))
	var parts: PackedStringArray = path.split("/")
	var tail: String = "/".join(parts.slice(maxi(0, parts.size() - 3)))
	var text: String = ""
	if control is Label:
		text = " '%s'" % (control as Label).text.left(40)
	elif control is Button:
		text = " '%s'" % (control as Button).text.left(40)
	return "%s(%s)%s" % [tail, control.get_class(), text]


func _rect_text(rect: Rect2) -> String:
	return "[%d,%d %dx%d]" % [int(rect.position.x), int(rect.position.y), int(rect.size.x), int(rect.size.y)]


func _close_all() -> void:
	var manager: Node = root.get_node_or_null("SceneManager")
	var pause: CanvasLayer = manager.get("_pause_menu") as CanvasLayer if manager != null else null
	if pause != null and pause.visible:
		var settings: Node = pause.get("_settings") as Node
		if settings != null and settings is CanvasItem and (settings as CanvasItem).visible and settings.has_method("close"):
			settings.call("close")
		pause.call("toggle")
	if _town.get("_overlay") != null:
		_town.call("_close_overlay")
