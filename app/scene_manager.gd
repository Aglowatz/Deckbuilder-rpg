extends CanvasLayer
## Scene switching with a fade to black, plus the global pause menu.

const FADE_TIME: float = 0.3

var busy: bool = false
## Scenes that may be paused set this true in _ready and false when they leave.
var pause_allowed: bool = false

var _fade: ColorRect
var _pause_menu: PauseMenu


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_fade = ColorRect.new()
	_fade.color = Color(0.03, 0.02, 0.05, 1.0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.modulate.a = 0.0
	add_child(_fade)
	_pause_menu = PauseMenu.new()
	_pause_menu.layer = 90
	get_tree().root.add_child.call_deferred(_pause_menu)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause") and pause_allowed and not busy:
		_pause_menu.toggle()
		get_viewport().set_input_as_handled()


## Fades out, loads `path`, fades back in.
func change_scene(path: String, fade_time: float = FADE_TIME) -> void:
	if busy:
		return
	busy = true
	_close_pause()
	_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	var out: Tween = create_tween()
	out.tween_property(_fade, "modulate:a", 1.0, fade_time)
	await out.finished
	pause_allowed = false
	var error: Error = get_tree().change_scene_to_file(path)
	if error != OK:
		push_error("SceneManager: cannot load %s" % path)
	await get_tree().process_frame
	await get_tree().process_frame
	var back: Tween = create_tween()
	back.tween_property(_fade, "modulate:a", 0.0, fade_time)
	await back.finished
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	busy = false


func _close_pause() -> void:
	if _pause_menu != null and _pause_menu.visible:
		_pause_menu.toggle()


func quit_game() -> void:
	Settings.save_settings()
	get_tree().quit()


func go_to_title() -> void:
	change_scene("res://scenes/title.tscn")


func go_to_town() -> void:
	change_scene("res://scenes/town.tscn")
