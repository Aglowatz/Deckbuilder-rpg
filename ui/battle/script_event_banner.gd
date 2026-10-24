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


## Shows the event and waits until it has been read (scaled by the battle speed).
func show_event(trigger: EncounterScripts.Trigger, foe_name: String, speed: float) -> void:
	if trigger == null:
		return
	for child: Node in _icon_slot.get_children():
		child.queue_free()
	var glyph: TextureRect = IconArt.rect(trigger.icon, 60.0) if IconArt.has(trigger.icon) else IconArt.glyph_or(trigger.icon, CardIcons.named(trigger.icon), AMBER, 60.0)
	if glyph != null:
		glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
		glyph.modulate = AMBER
		glyph.custom_minimum_size = Vector2(60, 60)
		glyph.size = Vector2(60, 60)
		glyph.position = Vector2(2, 2)
		_icon_slot.add_child(glyph)
	_title.text = trigger.name
	_body.text = trigger.banner if trigger.banner != trigger.name else trigger.text
	_line.text = "%s: \"%s\"" % [foe_name, trigger.line] if not trigger.line.is_empty() else ""
	_line.visible = not trigger.line.is_empty()
	_panel.reset_size()
	_panel.position = Vector2(960.0 - _panel.size.x * 0.5, 150.0)
	_panel.pivot_offset = _panel.size * 0.5
	_panel.scale = Vector2(0.85, 0.85)
	Audio.sfx(&"trap_spring")
	var scale: float = maxf(0.25, speed)
	var tween: Tween = create_tween()
	tween.tween_property(_panel, "modulate:a", 1.0, 0.18)
	tween.parallel().tween_property(_panel, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(HOLD_SECONDS / scale)
	tween.tween_property(_panel, "modulate:a", 0.0, 0.3)
	await tween.finished


func is_showing() -> bool:
	return _panel != null and _panel.modulate.a > 0.01


## The warning the turn before a timed event (does not hold up the battle).
func warn(text: String) -> void:
	_warning.text = text
	_warning.modulate.a = 1.0
	var tween: Tween = create_tween()
	tween.tween_interval(2.6)
	tween.tween_property(_warning, "modulate:a", 0.0, 0.5)


func warning_text() -> String:
	return _warning.text if _warning.modulate.a > 0.01 else ""
