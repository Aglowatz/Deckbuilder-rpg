class_name DialogueBox
extends Control
## A simple bottom-of-screen dialogue box: speaker name, typewriter text, advance with E,
## Space, Enter or a click.

signal finished

var _panel: PanelContainer
var _speaker: Label
var _text: Label
var _hint: Label
var _lines: Array[String] = []
var _index: int = 0
var _tween: Tween
var active: bool = false


func _ready() -> void:
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_panel = UIKit.panel()
	# Plain top-left anchoring (the Control default): a preset anchor combined with a manually
	# set position/size fights the anchor's own offset math and pushes the panel off-screen.
	_panel.custom_minimum_size = Vector2(1100, 190)
	_panel.position = Vector2(410, 800)
	_panel.size = Vector2(1100, 190)
	add_child(_panel)
	var column: VBoxContainer = UIKit.vbox(8)
	_panel.add_child(column)
	_speaker = UIKit.label("", &"HeadingLabel", 30)
	column.add_child(_speaker)
	_text = UIKit.label("", &"", 27, UIStyle.PARCHMENT)
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.custom_minimum_size = Vector2(1060, 84)
	column.add_child(_text)
	_hint = UIKit.label("E / Click to continue", &"MutedLabel", 18, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_RIGHT)
	column.add_child(_hint)


func start(speaker: String, lines: Array[String]) -> void:
	_lines = []
	for line: String in lines:
		_lines.append(Villain.fill(line))
	_index = 0
	_speaker.text = speaker
	active = true
	visible = true
	UIKit.pop_in(_panel)
	Audio.sfx(&"ui_open", -6.0)
	_show_line()


func _show_line() -> void:
	_text.text = _lines[_index]
	_text.visible_ratio = 0.0
	_hint.text = "E / Click to close" if _index == _lines.size() - 1 else "E / Click to continue"
	if _tween != null and _tween.is_valid():
		_tween.kill()
	var duration: float = maxf(0.4, float(_lines[_index].length()) * 0.018)
	_tween = create_tween()
	_tween.tween_property(_text, "visible_ratio", 1.0, duration)
	var ticker: Tween = create_tween().set_loops(int(duration / 0.07))
	ticker.tween_callback(func() -> void: Audio.sfx(&"dialogue", -16.0, 0.2))
	ticker.tween_interval(0.07)


func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return
	var pressed: bool = false
	if event.is_action_pressed(&"interact"):
		pressed = true
	elif event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo:
		var code: Key = (event as InputEventKey).keycode
		pressed = code == KEY_SPACE or code == KEY_ENTER
	elif event is InputEventMouseButton and (event as InputEventMouseButton).pressed and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		pressed = true
	if not pressed:
		return
	get_viewport().set_input_as_handled()
	if _text.visible_ratio < 1.0:
		if _tween != null and _tween.is_valid():
			_tween.kill()
		_text.visible_ratio = 1.0
		return
	_index += 1
	if _index >= _lines.size():
		active = false
		visible = false
		finished.emit()
	else:
		Audio.sfx(&"ui_tick", -6.0)
		_show_line()
