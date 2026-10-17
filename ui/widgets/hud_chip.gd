class_name HudChip
extends PanelContainer
## Overnight Oct 16: a compact, collapsible HUD chip - one short line (the zone's buff and debuff, the Capital's broken services) that opens
## to the full panel on click. Collapsed by default so the quest tracker stays the only headline; the open/closed choice is remembered per
## kind for the session.

static var expanded: Dictionary = {}

var kind: String = ""
var _header: Button
var _body: Control
var _summary: String = ""


## `body` is the full panel (its own frame is dropped: the chip draws one).
static func wrap(chip_kind: String, summary: String, accent: Color, body: Control, tooltip: String = "") -> HudChip:
	var chip: HudChip = HudChip.new()
	chip.name = "HudChip_%s" % chip_kind
	chip.kind = chip_kind
	chip._summary = summary
	chip.theme_type_variation = &"DarkPanel"
	chip.mouse_filter = Control.MOUSE_FILTER_PASS
	chip.custom_minimum_size = Vector2(QuestTracker.WIDTH, 0)
	var column: VBoxContainer = UIKit.vbox(2)
	column.mouse_filter = Control.MOUSE_FILTER_PASS
	chip.add_child(column)
	chip._header = Button.new()
	chip._header.name = "ChipHeader"
	chip._header.flat = true
	chip._header.alignment = HORIZONTAL_ALIGNMENT_LEFT
	chip._header.focus_mode = Control.FOCUS_NONE
	chip._header.clip_text = true
	for state: String in ["normal", "hover", "pressed", "focus"]:
		chip._header.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	chip._header.add_theme_font_size_override("font_size", 16)
	chip._header.add_theme_color_override("font_color", accent)
	chip._header.add_theme_color_override("font_hover_color", accent.lightened(0.25))
	chip._header.tooltip_text = tooltip if tooltip != "" else "Click to show the details"
	chip._header.pressed.connect(chip.toggle)
	column.add_child(chip._header)
	if body is PanelContainer:
		(body as PanelContainer).add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		(body as PanelContainer).custom_minimum_size = Vector2.ZERO
	chip._body = body
	column.add_child(body)
	chip._apply()
	return chip


func is_expanded() -> bool:
	return bool(expanded.get(kind, false))


func toggle() -> void:
	expanded[kind] = not is_expanded()
	Audio.sfx(&"ui_tick")
	_apply()


func _apply() -> void:
	_header.text = "%s %s" % ["▾" if is_expanded() else "▸", _summary]
	_body.visible = is_expanded()
