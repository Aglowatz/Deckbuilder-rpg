class_name ScriptEventBanner
extends Control
## Overnight Oct 23, Part 1: a boss's or elite's scripted mid-fight event (EncounterScripts) as a banner across the top of the table -
## its icon, its name, what happened and the foe's line - and the one-line warning the turn before a timed event. Presentation only:
## the event itself has already resolved in core/.

const AMBER: Color = Color("ff9f43")
const HOLD_SECONDS: float = 2.2

var _panel: PanelContainer
var _icon_slot: Control
var _title: Label
var _body: Label
var _line: Label
var _warning: Label


func _ready() -> void:
	name = "ScriptEventBanner"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	UIKit.full_rect(self)
	_panel = PanelContainer.new()
	_panel.theme_type_variation = &"DarkPanel"
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.custom_minimum_size = Vector2(860, 0)
	_panel.position = Vector2(580, 150)
	var style: StyleBoxFlat = UIStyle.box(Color(0.07, 0.04, 0.1, 0.94), AMBER, 3, 14)
	style.content_margin_left = 18.0
	style.content_margin_right = 22.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 14.0
	_panel.add_theme_stylebox_override("panel", style)
	_panel.modulate.a = 0.0
	add_child(_panel)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(row)
	_icon_slot = Control.new()
	_icon_slot.custom_minimum_size = Vector2(64, 64)
	_icon_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_icon_slot)
	var column: VBoxContainer = UIKit.vbox(2)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(column)
	_title = UIKit.label("", &"", 30, AMBER)
	_title.add_theme_font_override("font", UIStyle.font_bold())
	column.add_child(_title)
	_body = UIKit.label("", &"", 19, UIStyle.PARCHMENT)
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.custom_minimum_size = Vector2(700, 0)
	column.add_child(_body)
	_line = UIKit.label("", &"MutedLabel", 19)
	_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_line.custom_minimum_size = Vector2(700, 0)
	_line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_child(_line)
	_warning = UIKit.label("", &"", 22, AMBER, HORIZONTAL_ALIGNMENT_CENTER)
	_warning.add_theme_font_override("font", UIStyle.font_bold())
	_warning.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_warning.add_theme_constant_override("outline_size", 7)
	_warning.position = Vector2(460, 600)
	_warning.size = Vector2(1000, 34)
	_warning.modulate.a = 0.0
	add_child(_warning)


## Overnight Nov 19 (Part 1.2): the event as a pop-up the player closes - the foe's portrait and line, what the event does in plain
## words, and "Click or press Space". The battle waits on it; the event's card and board animation play after it closes (the events
## that follow SCRIPT_TRIGGERED are presented once this returns). `wait_for_click` = false (a bot at the table, screenshots) holds it
## for a moment instead.
signal closed

var _dim: ColorRect
var _portrait: TextureRect
var _hint: Label
var _waiting: bool = false


func show_event(trigger: EncounterScripts.Trigger, foe_name: String, speed: float, wait_for_click: bool = false) -> void:
	if trigger == null:
		return
	for child: Node in _icon_slot.get_children():
		child.queue_free()
	var picture: Texture2D = Bestiary.art(ShatteredGallery.original_of(foe_name))
	if picture != null:
		var frame: TextureRect = TextureRect.new()
		frame.texture = picture
		frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		frame.custom_minimum_size = Vector2(150, 150)
		frame.size = Vector2(150, 150)
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_icon_slot.custom_minimum_size = Vector2(150, 150)
		_icon_slot.add_child(frame)
		_portrait = frame
	else:
		_icon_slot.custom_minimum_size = Vector2(64, 64)
		var glyph: TextureRect = IconArt.rect(trigger.icon, 60.0) if IconArt.has(trigger.icon) else IconArt.glyph_or(trigger.icon, CardIcons.named(trigger.icon), AMBER, 60.0)
		if glyph != null:
			glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
			glyph.modulate = AMBER
			glyph.custom_minimum_size = Vector2(60, 60)
			glyph.size = Vector2(60, 60)
			glyph.position = Vector2(2, 2)
			_icon_slot.add_child(glyph)
	_title.text = trigger.name
	_body.text = describe(trigger, foe_name)
	_line.text = "%s: \"%s\"" % [foe_name, trigger.line] if not trigger.line.is_empty() else ""
	_line.visible = not trigger.line.is_empty()
	_line.add_theme_font_size_override("font_size", 22)
	if _hint == null:
		_hint = UIKit.label("", &"MutedLabel", 18, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_RIGHT)
		_hint.name = "CloseHint"
		(_body.get_parent() as VBoxContainer).add_child(_hint)
	_hint.text = "Click or press %s to continue" % Keybinds.first_key(&"battle_advance") if wait_for_click else ""
	_hint.visible = wait_for_click
	if _dim == null:
		_dim = ColorRect.new()
		_dim.name = "ScriptDim"
		_dim.color = Color(0.02, 0.01, 0.04, 0.5)
		UIKit.full_rect(_dim)
		add_child(_dim)
		move_child(_dim, 0)
		_dim.gui_input.connect(_on_dim_input)
	_dim.visible = wait_for_click
	_dim.mouse_filter = Control.MOUSE_FILTER_STOP if wait_for_click else Control.MOUSE_FILTER_IGNORE
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP if wait_for_click else Control.MOUSE_FILTER_IGNORE
	if wait_for_click and not _panel.gui_input.is_connected(_on_dim_input):
		_panel.gui_input.connect(_on_dim_input)
	_panel.reset_size()
	_panel.position = Vector2(960.0 - _panel.size.x * 0.5, 540.0 - _panel.size.y * 0.5 - 60.0)
	_panel.pivot_offset = _panel.size * 0.5
	_panel.scale = Vector2(0.85, 0.85)
	Audio.sfx(&"trap_spring")
	var tween: Tween = create_tween()
	tween.tween_property(_panel, "modulate:a", 1.0, 0.18)
	tween.parallel().tween_property(_panel, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if wait_for_click:
		_waiting = true
		await closed
	else:
		var scale: float = maxf(0.25, speed)
		tween.tween_interval(HOLD_SECONDS / scale)
		await tween.finished
	var out: Tween = create_tween()
	out.tween_property(_panel, "modulate:a", 0.0, 0.2)
	_dim.visible = false
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	await out.finished


## What the event does, in plain words: the banner line ("Vellum gains a Contract.") and, when it says more, the rule text without its
## "At half health" lead-in.
static func describe(trigger: EncounterScripts.Trigger, _foe_name: String = "") -> String:
	var what: String = trigger.banner if not trigger.banner.is_empty() and trigger.banner != trigger.name else ""
	var rule: String = trigger.text
	var colon: int = rule.find(": ")
	if colon > 0 and colon < 60:
		rule = rule.substr(colon + 2)
	rule = rule.strip_edges()
	if not rule.is_empty():
		rule = rule[0].to_upper() + rule.substr(1)
	if what.is_empty():
		return rule
	if rule.is_empty() or rule.to_lower().trim_suffix(".") == what.to_lower().trim_suffix("."):
		return what
	return "%s\n%s" % [what, rule]


func is_waiting() -> bool:
	return _waiting


## Closes a waiting pop-up (a click, Space, Enter or the pad's A).
func close() -> void:
	if not _waiting:
		return
	_waiting = false
	Audio.sfx(&"ui_select")
	closed.emit()


func _on_dim_input(event: InputEvent) -> void:
	var button: InputEventMouseButton = event as InputEventMouseButton
	if button != null and button.pressed and button.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		close()


func _unhandled_input(event: InputEvent) -> void:
	if _waiting and (event.is_action_pressed(&"battle_advance") or event.is_action_pressed(&"ui_accept")):
		get_viewport().set_input_as_handled()
		close()


func is_showing() -> bool:
	return _panel != null and _panel.modulate.a > 0.01


## The warning the turn before a timed event (does not hold up the battle).
func warn(text: String) -> void:
	_warning.text = text
	_warning.modulate.a = 1.0
	var tween: Tween = create_tween()
	tween.tween_interval(2.6)
	tween.tween_property(_warning, "modulate:a", 0.0, 0.5)


## Fable pass Nov 1: drops a pending "Next turn" warning (the fight ended first).
func clear_warning() -> void:
	_warning.modulate.a = 0.0


func warning_text() -> String:
	return _warning.text if _warning.modulate.a > 0.01 else ""
