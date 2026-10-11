class_name OverlayScreen
extends Control
## Base for full-screen town/dungeon menus (deck station, vendor, rewards...): a dark backdrop,
## a title bar with a close button, and a `body` container for the content. Esc closes.

signal closed

var body: VBoxContainer
var header_extra: HBoxContainer
var screen_title: String = ""
var close_text: String = "Close"
## A UI art kit background (UI-BG-...) drawn behind the screen; "" keeps the plain dark backdrop.
var background_id: String = ""
## A Vendor Screen ID (VS-SABLE): the shop background, the vendor's portrait on the left, a dark panel behind the content on the right and a speech bubble (`VendorStage`). "" = the plain screen.
var vendor_screen_id: String = ""
## Pixels reserved on the left for the vendor (the portrait and the speech bubble).
var vendor_inset: float = VendorStage.INSET
var stage: VendorStage
var _panel: PanelContainer
var _close_button: FancyButton


func _ready() -> void:
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_STOP
	if not vendor_screen_id.is_empty() and KeyArt.has(vendor_screen_id):
		stage = VendorStage.make(vendor_screen_id, vendor_inset)
		add_child(stage)
	var backdrop: Control = UiSkin.screen_background(background_id) if stage == null else null
	if backdrop != null:
		add_child(backdrop)
	elif stage == null:
		var shade: ColorRect = ColorRect.new()
		shade.color = Color(0.03, 0.02, 0.06, 0.94)
		UIKit.full_rect(shade)
		add_child(shade)
		var glow: ColorRect = UIKit.gradient_background()
		glow.modulate.a = 0.35
		add_child(glow)
	var margin: MarginContainer = UIKit.margin(VBoxContainer.new(), 34)
	if stage != null:
		margin.add_theme_constant_override("margin_left", 34 + int(vendor_inset))
	UIKit.full_rect(margin)
	add_child(margin)
	var root: VBoxContainer = margin.get_child(0) as VBoxContainer
	root.add_theme_constant_override("separation", 14)
	var header: HBoxContainer = UIKit.hbox(16)
	root.add_child(header)

	header.add_child(UIKit.label(screen_title, &"TitleLabel", _title_size()))
	header.add_child(UIKit.filler())
	header_extra = UIKit.hbox(14)
	header.add_child(header_extra)
	_close_button = UiSkin.close_button(close_text) if UiArt.has("UI-BTN-CLOSE") else FancyButton.make(close_text, &"", Vector2(170, 52))
	_close_button.pressed.connect(request_close)
	header.add_child(_close_button)
	body = UIKit.vbox(12)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(body)
	_build()
	if stage != null:
		stage.attach_overlay(self)
		stage.say("open")


## Subclasses fill `body` here.
func _build() -> void:
	pass


func request_close() -> void:
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") and is_visible_in_tree():
		get_viewport().set_input_as_handled()
		request_close()


## The vendor of a vendor screen reacts to `moment` ("buy", "poor", "sold_out") with a speech line and a flourish; does nothing on a plain screen.
func vendor_react(moment: String) -> void:
	if stage != null:
		stage.react(moment)


## The header font size: a long vendor title is set smaller next to the vendor stage so the gold counter and the close button stay on screen.
func _title_size() -> int:
	if stage == null or screen_title.length() <= 30:
		return 48
	return 36 if screen_title.length() <= 44 else 30
