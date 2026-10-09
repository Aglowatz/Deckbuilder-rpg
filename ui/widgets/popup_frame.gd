class_name PopupFrame
extends Control
## The shared look of the three "something good happened" boxes: the chest reward box, the "Quest Complete" box and the level-up box.
## A dark shade over the world, one centred plum panel with a gold-trimmed header (badge icon + big title in the box's accent colour),
## a heading and a muted line, a body the box fills, a Continue button and a hint line. The player confirms with a click, Enter, Space or E
## (after a short guard time, so the E press that opened the chest cannot also close the box). Movement is paused by the owner while it is open.

## The player pressed Continue (or clicked / confirmed): the owner decides what comes next (the next level, the next box, closing).
signal confirmed

const PANEL_WIDTH: float = 820.0
## Input is ignored for this long after the box appears.
const GUARD_TIME: float = 0.5

var body: VBoxContainer
var button: FancyButton
var accent: Color = UIStyle.GOLD
var _panel: PanelContainer
var _column: VBoxContainer
var _header_row: HBoxContainer
var _badge: TextureRect
var _header: Label
var _heading: Label
var _subline: Label
var _hint: Label
var _age: float = 0.0
var _enabled: bool = true
## UI art kit: the reward panel (UI-PANEL-POPUP) has a red ribbon banner across its top; the title sits on the ribbon.
var _art: bool = false


## `header` is the big word ("QUEST COMPLETE"), `icon` a `CardIcons.ui` name.
static func make(header: String, icon: String, accent_color: Color = UIStyle.GOLD) -> PopupFrame:
	var frame: PopupFrame = PopupFrame.new()
	frame.accent = accent_color
	frame._build(header, icon)
	return frame


func _build(header_text: String, icon: String) -> void:
	name = "PopupFrame"
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.02, 0.02, 0.06, 0.82)
	UIKit.full_rect(shade)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	add_child(UIKit.vignette(0.7))
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	_art = UiArt.has("UI-PANEL-POPUP-DARK")
	_panel = UIKit.panel(&"RewardPanel" if _art else &"")
	_panel.custom_minimum_size = Vector2(PANEL_WIDTH + (60.0 if _art else 0.0), 0)
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(_panel)
	_column = UIKit.vbox(12)
	_panel.add_child(UIKit.margin(_column, 14))
	_header_row = UIKit.hbox(16)
	_header_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_column.add_child(_header_row)
	_badge = CardIcons.glyph(CardIcons.ui(icon), UIStyle.PARCHMENT if _art else accent, Vector2(44, 44) if _art else Vector2(60, 60))
	_header_row.add_child(_badge)
	_header = UIKit.label(header_text, &"TitleLabel", 38 if _art else 54, Color("fff3d6") if _art else accent, HORIZONTAL_ALIGNMENT_CENTER)
	if _art:
		_header.add_theme_color_override("font_outline_color", Color("5a1010"))
		_header.add_theme_constant_override("outline_size", 6)
	_header_row.add_child(_header)
	_column.add_child(_divider())
	_heading = UIKit.label("", &"HeadingLabel", 30, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_heading.custom_minimum_size = Vector2(PANEL_WIDTH - 80.0, 0)
	_column.add_child(_heading)
	_subline = UIKit.label("", &"MutedLabel", 19, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	_subline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_subline.custom_minimum_size = Vector2(PANEL_WIDTH - 80.0, 0)
	_column.add_child(_subline)
	body = UIKit.vbox(10)
	_column.add_child(body)
	button = FancyButton.make("Continue", &"PrimaryButton", Vector2(260, 60))
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.pressed.connect(_confirm)
	_column.add_child(UIKit.spacer(4))
	_column.add_child(button)
	_hint = UIKit.label("Click, or press Enter / Space / E", &"MutedLabel", 16, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	_column.add_child(_hint)


func _divider() -> ColorRect:
	var line: ColorRect = ColorRect.new()
	line.color = Color(accent.r, accent.g, accent.b, 0.55)
	line.custom_minimum_size = Vector2(0, 2)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return line


# ---- content setters (the level-up box re-uses one frame for several levels) ------------------------------------------------------------


func set_header(text: String, icon: String = "") -> void:
	_header.text = text
	if not icon.is_empty():
		_badge.texture = CardIcons.ui(icon)


func set_heading(text: String, subline: String = "") -> void:
	_heading.text = text
	_heading.visible = not text.is_empty()
	_subline.text = subline
	_subline.visible = not subline.is_empty()


func set_button_text(text: String) -> void:
	button.text = text


## Empties the body for the next page.
func clear_body() -> void:
	for child: Node in body.get_children():
		child.queue_free()


func set_enabled(value: bool) -> void:
	_enabled = value


# ---- showing and input --------------------------------------------------------------------------------------------------------------


func _ready() -> void:
	_panel.pivot_offset = _panel.size * 0.5
	animate_in()


## Fade + pop the panel in and burst gold sparks behind the badge; also replayed for each page of a multi-page box.
func animate_in() -> void:
	_age = 0.0
	_panel.pivot_offset = _panel.size * 0.5
	_panel.scale = Vector2(0.86, 0.86)
	_panel.modulate.a = 0.0
	var tween: Tween = _panel.create_tween().set_parallel(true)
	tween.tween_property(_panel, "modulate:a", 1.0, 0.25)
	tween.tween_property(_panel, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_burst()


func _burst() -> void:
	var particles: CPUParticles2D = CPUParticles2D.new()
	particles.position = get_viewport_rect().size * 0.5 + Vector2(0, -250)
	particles.emitting = false
	particles.one_shot = true
	particles.amount = 36
	particles.lifetime = 1.0
	particles.explosiveness = 1.0
	particles.spread = 180.0
	particles.gravity = Vector2(0, 260)
	particles.initial_velocity_min = 120.0
	particles.initial_velocity_max = 360.0
	particles.scale_amount_min = 3.0
	particles.scale_amount_max = 8.0
	var ramp: Gradient = Gradient.new()
	ramp.set_color(0, accent)
	ramp.set_color(1, Color(accent.r, accent.g, accent.b, 0.0))
	particles.color_ramp = ramp
	particles.z_index = 250
	add_child(particles)
	particles.emitting = true
	get_tree().create_timer(1.4, false).timeout.connect(particles.queue_free)


func _process(delta: float) -> void:
	_age += delta


func _gui_input(event: InputEvent) -> void:
	var click: InputEventMouseButton = event as InputEventMouseButton
	if click != null and click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
		_confirm()
		accept_event()


func _unhandled_key_input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	if key.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_E]:
		_confirm()
		get_viewport().set_input_as_handled()


func _confirm() -> void:
	if not _enabled or _age < GUARD_TIME or not is_inside_tree():
		return
	Audio.sfx(&"ui_confirm")
	confirmed.emit()
