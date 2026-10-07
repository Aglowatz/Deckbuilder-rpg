class_name DialogueBox
extends Control
## The bottom-of-screen dialogue box: speaker name, typewriter text, advance with E, Space, Enter or a click. When the speaker is an NPC with a portrait
## (`NpcRegistry` / `Portraits`) it works like a visual novel: the portrait stands behind the box on its left (or right) side with the waist tucked behind the
## box's top edge (the portrait is clipped there, so it never reaches the text). A line can start with an expression tag, `[happy] Well met.`, which picks
## `<ID>_HAPPY` (the base portrait when that expression has no image). A speaker with no portrait shows the box exactly as before.

signal finished

const SCREEN_WIDTH: float = 1920.0
const PLAIN_WIDTH: float = 1100.0
const MIN_HEIGHT: float = 190.0
const BOTTOM: float = 990.0
const MIN_TEXT_HEIGHT: float = 84.0

var _portrait: PortraitView
var _panel: PanelContainer
var _speaker: Label
var _text: Label
var _hint: Label
var _lines: Array[String] = []
var _expressions: Array[String] = []
var _index: int = 0
var _tween: Tween
var active: bool = false
## The NPC whose portrait is up ("" for none).
var npc_id: String = ""
var _portrait_id: String = ""
var _right_side: bool = false


func _ready() -> void:
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_portrait = PortraitView.new()
	add_child(_portrait)
	_panel = UIKit.panel()
	# Plain top-left anchoring (the Control default): a preset anchor combined with a manually
	# set position/size fights the anchor's own offset math and pushes the panel off-screen.
	add_child(_panel)
	var column: VBoxContainer = UIKit.vbox(8)
	_panel.add_child(column)
	_speaker = UIKit.label("", &"HeadingLabel", 30)
	_speaker.clip_text = true
	_speaker.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	column.add_child(_speaker)
	_text = UIKit.label("", &"", 27, UIStyle.PARCHMENT)
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_text)
	_hint = UIKit.label("E / Click to continue", &"MutedLabel", 18, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_RIGHT)
	column.add_child(_hint)
	_panel.resized.connect(_anchor_panel)
	_layout()


## Starts a conversation. `speaker` is the name label; `speaker_npc_id` (an NPC ID of `NpcRegistry`) picks the portrait - when it is empty the speaker label is
## looked up in the NPC list. An NPC from the list is shown under its list name; a label that only aliases one (the throwers, a rift technician) keeps its own name.
func start(speaker: String, lines: Array[String], speaker_npc_id: String = "") -> void:
	_lines = []
	_expressions = []
	for line: String in lines:
		var parsed: Array = _split_expression(line)
		_expressions.append(str(parsed[0]))
		_lines.append(Villain.fill(str(parsed[1])))
	_index = 0
	var id: String = speaker_npc_id if not speaker_npc_id.is_empty() else NpcRegistry.resolve_speaker(speaker)
	var entry: NpcRegistry.Entry = NpcRegistry.find(id)
	var texture: Texture2D = null
	npc_id = ""
	_portrait_id = ""
	_right_side = false
	if entry != null:
		texture = Portraits.texture_for(entry.portrait_id)
		if texture != null:
			npc_id = id
			_portrait_id = entry.portrait_id
			_right_side = entry.side == "right"
	_speaker.text = _plate(speaker, entry)
	_layout()
	active = true
	visible = true
	_panel.visible = true
	UIKit.pop_in(_panel)
	if texture != null:
		_portrait.present(Portraits.texture_for(_portrait_id, _expressions[0]), _right_side, _panel.position.y, _panel.position.x, _panel.position.x + _panel.size.x)
	else:
		_portrait.dismiss()
	Audio.sfx(&"ui_open", -6.0)
	_show_line()


## The name plate: the list name for an NPC addressed by name (or with no speaker label at all), the label itself otherwise.
func _plate(speaker: String, entry: NpcRegistry.Entry) -> String:
	if entry == null:
		return speaker
	if speaker.strip_edges().is_empty() or NpcRegistry.resolve_name(speaker) == entry.id:
		return entry.plate_name()
	return speaker


## "[happy] text" -> ["happy", "text"]; a line with no tag -> ["", line].
static func _split_expression(line: String) -> Array:
	if line.begins_with("["):
		var close: int = line.find("]")
		if close > 1:
			var tag: String = line.substr(1, close - 1)
			var valid: bool = true
			for index: int in range(tag.length()):
				var code: int = tag.unicode_at(index)
				if not ((code >= 65 and code <= 90) or (code >= 97 and code <= 122) or code == 95):
					valid = false
			if valid:
				return [tag.to_lower(), line.substr(close + 1).strip_edges(true, false)]
	return ["", line]


## Sizes the box for the conversation: the same box as ever, as tall as the longest line needs (it grows upwards, its bottom edge stays put).
func _layout() -> void:
	var width: float = PLAIN_WIDTH
	var text_width: float = width - _panel_margins().x
	var longest: float = MIN_TEXT_HEIGHT
	var font: Font = _text.get_theme_font(&"font")
	var font_size: int = _text.get_theme_font_size(&"font_size")
	for line: String in _lines:
		var size: Vector2 = font.get_multiline_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, text_width, font_size, -1, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND | TextServer.BREAK_ADAPTIVE)
		longest = maxf(longest, size.y + 4.0)
	_text.custom_minimum_size = Vector2(text_width, longest)
	_panel.custom_minimum_size = Vector2(width, MIN_HEIGHT)
	_panel.size = Vector2(width, MIN_HEIGHT)
	_anchor_panel()


func _panel_margins() -> Vector2:
	var style: StyleBox = _panel.get_theme_stylebox(&"panel")
	return style.get_minimum_size() if style != null else Vector2(56.0, 40.0)


## Keeps the box centred with its bottom edge at BOTTOM, whatever height its content gave it, and the portrait's waist behind its top edge.
func _anchor_panel() -> void:
	_panel.position = Vector2((SCREEN_WIDTH - _panel.size.x) * 0.5, BOTTOM - _panel.size.y)
	if _portrait != null:
		_portrait.follow_panel_top(_panel.position.y)


func _show_line() -> void:
	_text.text = _lines[_index]
	_text.visible_ratio = 0.0
	_hint.text = "E / Click to close" if _index == _lines.size() - 1 else "E / Click to continue"
	if not _portrait_id.is_empty():
		_portrait.set_texture(Portraits.texture_for(_portrait_id, _expressions[_index]))
		_portrait.set_talking(true)
	if _tween != null and _tween.is_valid():
		_tween.kill()
	var duration: float = maxf(0.4, float(_lines[_index].length()) * 0.018)
	_tween = create_tween()
	_tween.tween_property(_text, "visible_ratio", 1.0, duration)
	_tween.tween_callback(_portrait.set_talking.bind(false))
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
		_portrait.set_talking(false)
		return
	_index += 1
	if _index >= _lines.size():
		active = false
		_panel.visible = false
		_portrait.dismiss()
		get_tree().create_timer(0.2).timeout.connect(_hide_when_idle)
		finished.emit()
	else:
		Audio.sfx(&"ui_tick", -6.0)
		_show_line()


## The box stays visible just long enough for the portrait's fade-out, unless a new conversation already started.
func _hide_when_idle() -> void:
	if not active:
		visible = false


## Draws the portrait behind `sibling` (the scene's HUD) instead of over it, so a portrait never covers the quest tracker, the gold counter or the buttons.
func stand_behind(sibling: Node) -> void:
	if _portrait == null or sibling == null or sibling.get_parent() == null:
		return
	_portrait.get_parent().remove_child(_portrait)
	sibling.get_parent().add_child(_portrait)
	sibling.get_parent().move_child(_portrait, sibling.get_index())


func _exit_tree() -> void:
	if _portrait != null and is_instance_valid(_portrait) and _portrait.get_parent() != self:
		_portrait.queue_free()
