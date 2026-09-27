class_name OverlayScreen
extends Control
## Base for full-screen town/dungeon menus (deck station, vendor, rewards...): a dark backdrop,
## a title bar with a close button, and a `body` container for the content. Esc closes.

signal closed

var body: VBoxContainer
var header_extra: HBoxContainer
var screen_title: String = ""
var close_text: String = "Close"
var _panel: PanelContainer
var _close_button: FancyButton


func _ready() -> void:
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.03, 0.02, 0.06, 0.94)
	UIKit.full_rect(shade)
	add_child(shade)
	var glow: ColorRect = UIKit.gradient_background()
	glow.modulate.a = 0.35
	add_child(glow)
	var margin: MarginContainer = UIKit.margin(VBoxContainer.new(), 34)
	UIKit.full_rect(margin)
	add_child(margin)
	var root: VBoxContainer = margin.get_child(0) as VBoxContainer
	root.add_theme_constant_override("separation", 14)
	var header: HBoxContainer = UIKit.hbox(16)
	root.add_child(header)
	header.add_child(UIKit.label(screen_title, &"TitleLabel", 48))
	header.add_child(UIKit.filler())
	header_extra = UIKit.hbox(14)
	header.add_child(header_extra)
	_close_button = FancyButton.make(close_text, &"", Vector2(170, 52))
	_close_button.pressed.connect(request_close)
	header.add_child(_close_button)
	body = UIKit.vbox(12)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(body)
	_build()


## Subclasses fill `body` here.
func _build() -> void:
	pass


func request_close() -> void:
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") and is_visible_in_tree():
		get_viewport().set_input_as_handled()
		request_close()
