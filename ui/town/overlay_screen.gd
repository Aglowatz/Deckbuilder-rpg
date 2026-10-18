class_name OverlayScreen
extends Control
## Base for full-screen town/dungeon menus (deck station, vendor, rewards...): a dark backdrop,
## a title bar with a close button, and a `body` container for the content. Esc closes.

signal closed

var body: VBoxContainer
var header_extra: HBoxContainer
var screen_title: String = ""
var close_text: String = "Close"
## An icon (ICON-UI-*) shown before the title; "" for none (or when the icon is missing).
var title_icon_id: String = ""
## A UI art kit background (UI-BG-...) drawn behind the screen; "" keeps the plain dark backdrop.
var background_id: String = ""
## A Vendor Screen ID (VS-SABLE): the shop background, the vendor's portrait on the left, a dark panel behind the content on the right and a speech bubble (`VendorStage`). "" = the plain screen.
var vendor_screen_id: String = ""
## Pixels reserved on the left for the vendor (the portrait and the speech bubble).
var vendor_inset: float = VendorStage.INSET
var stage: VendorStage
var _panel: PanelContainer
var _close_button: FancyButton
var _music_token: int = 0


func _ready() -> void:
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_STOP
	UiScale.fit(self)
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

	var title_icon: TextureRect = IconArt.rect(title_icon_id, 56.0) if title_icon_id != "" else null
	if title_icon != null:
		header.add_child(title_icon)
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
	# Overnight Oct 17, Part 13: every screen opens the same way (a short fade), every button is reachable with the keyboard / a pad,
	# and the first thing in the body has focus unless the screen focused something itself.
	UiInput.make_focusable(self)
	_focus_default.call_deferred()
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, OPEN_FADE)
	# A vendor's theme (or the deck station's...) lies over the area's music while the screen is open and hands back when it closes. It is pushed once
	# per screen, never per purchase; a short overlay with no cue of its own keeps the current music.
	var cue: String = music_cue()
	if not cue.is_empty():
		_music_token = Audio.push_music(StringName(cue), 1.2, false)


const OPEN_FADE: float = 0.14


func _focus_default() -> void:
	if not is_inside_tree():
		return
	var owner_now: Control = get_viewport().gui_get_focus_owner()
	if owner_now != null and is_ancestor_of(owner_now):
		return
	if UiInput.focus_first(body) == null and _close_button != null:
		_close_button.grab_focus()


## The music this screen sets over the area's: a vendor's browsing theme by its Vendor Screen ID; "" (the default for a plain screen) keeps what plays.
func music_cue() -> String:
	return MusicDirector.shop(vendor_screen_id, Session.profile != null and Session.profile.postgame_unlocked)


func _exit_tree() -> void:
	if _music_token != 0:
		Audio.pop_music(_music_token, 1.2)
		_music_token = 0


## Subclasses fill `body` here.
func _build() -> void:
	pass


func request_close() -> void:
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if UiInput.is_back(event) and is_visible_in_tree():
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
