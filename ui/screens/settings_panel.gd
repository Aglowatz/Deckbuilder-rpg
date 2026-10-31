class_name SettingsPanel
extends PanelContainer
## The settings screen, in five pages: Display, Text, Accessibility, Controls and Audio. Every change applies at once (`Settings` and `Keybinds`) and is saved at once.

signal closed

const PAGES: Array[String] = ["Display", "Text", "Accessibility", "Controls", "Audio"]
const PAGE_SIZE: Vector2 = Vector2(940, 520)
const LABEL_WIDTH: float = 300.0

var _page: int = 0
var _tabs: Array[Button] = []
var _body: VBoxContainer
## The key button waiting for a key: {"action": StringName, "slot": int, "button": Button}; empty when none is.
var _capturing: Dictionary = {}
var _key_buttons: Dictionary = {}
## The controller column's slot index in `_capturing` / `_key_buttons` (after the key slots).
const PAD_SLOT: int = 9
## The frame a capture started on (the pad press that opened it is never the new binding).
var _capture_frame: int = 0
var _conflict_note: Label
var _resolution: OptionButton
var _sample: Label
## Fresh eyes round 2 (Oct 31): the page scroller (its bar is restyled so it can be seen).
var _scroll: ScrollContainer
## Saves after every change; tests turn it off so they never touch the real settings file.
var autosave: bool = true


func _ready() -> void:
	custom_minimum_size = Vector2(PAGE_SIZE.x + 40.0, 0)
	var column: VBoxContainer = UIKit.vbox(12)
	add_child(column)
	column.add_child(UIKit.label("Settings", &"HeadingLabel", 34, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var tab_row: HBoxContainer = UIKit.hbox(8)
	tab_row.alignment = BoxContainer.ALIGNMENT_CENTER
	for index: int in range(PAGES.size()):
		var tab: Button = FancyButton.make(PAGES[index], &"GhostButton", Vector2(170, 46))
		tab.name = "Tab%s" % PAGES[index]
		tab.toggle_mode = true
		tab.pressed.connect(show_page.bind(index))
		tab_row.add_child(tab)
		_tabs.append(tab)
	column.add_child(tab_row)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = "PageScroll"
	scroll.custom_minimum_size = PAGE_SIZE
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	_body = UIKit.vbox(12)
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# The rows stop short of the bar (it used to lie over the right-hand checkboxes).
	var pad: MarginContainer = MarginContainer.new()
	pad.add_theme_constant_override("margin_right", 26)
	pad.add_theme_constant_override("margin_bottom", 8)
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(pad)
	pad.add_child(_body)
	# Fresh eyes round 2 (Oct 31): a scrollbar you can see. The theme's bar is a dark, 35 % black track on dark wood (invisible), so the
	# Display page looked cut off at "Render scale" with no hint that it went on. A gold grabber on a visible track, wide enough to grab,
	# and always shown on a page that overflows (`_refresh_scrollbar`).
	_scroll = scroll
	var bar: VScrollBar = scroll.get_v_scroll_bar()
	bar.custom_minimum_size = Vector2(16, 0)
	bar.add_theme_stylebox_override("scroll", UIStyle.box(Color(0.0, 0.0, 0.0, 0.45), UIStyle.GOLD_DIM, 1, 8))
	bar.add_theme_stylebox_override("grabber", UIStyle.box(UIStyle.GOLD_DIM, Color(0, 0, 0, 0), 0, 8))
	bar.add_theme_stylebox_override("grabber_highlight", UIStyle.box(UIStyle.GOLD, Color(0, 0, 0, 0), 0, 8))
	bar.add_theme_stylebox_override("grabber_pressed", UIStyle.box(UIStyle.GOLD, Color(0, 0, 0, 0), 0, 8))
	var back: FancyButton = FancyButton.make("Back", &"PrimaryButton", Vector2(200, 52))
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(_on_back)
	column.add_child(back)
	show_page(0)


## Shows one page (0 Display ... 4 Audio).
func show_page(index: int) -> void:
	_cancel_capture()
	_page = clampi(index, 0, PAGES.size() - 1)
	for tab_index: int in range(_tabs.size()):
		_tabs[tab_index].button_pressed = tab_index == _page
	for child: Node in _body.get_children():
		child.queue_free()
	_key_buttons = {}
	match _page:
		0:
			_build_display()
		1:
			_build_text()
		2:
			_build_accessibility()
		3:
			_build_controls()
		_:
			_build_audio()


# ---- Pages ----------------------------------------------------------------------------------


func _build_display() -> void:
	var mode: OptionButton = _options(["Windowed", "Fullscreen", "Borderless window"], Settings.window_mode, _on_window_mode)
	mode.name = "WindowModeOptions"
	_body.add_child(_row("Window mode", mode))
	_resolution = OptionButton.new()
	_resolution.name = "ResolutionOptions"
	_fill_resolutions()
	_resolution.item_selected.connect(_on_resolution)
	_resolution.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.add_child(_row("Resolution (windowed)", _resolution))
	_body.add_child(_check("VSync", Settings.vsync, _on_vsync, "VsyncCheck"))
	var caps: Array[String] = []
	var cap_index: int = 0
	for index: int in range(Settings.FRAME_CAPS.size()):
		caps.append("Unlimited" if Settings.FRAME_CAPS[index] == 0 else "%d fps" % Settings.FRAME_CAPS[index])
		if Settings.FRAME_CAPS[index] == Settings.max_fps:
			cap_index = index
	var cap: OptionButton = _options(caps, cap_index, _on_frame_cap)
	cap.name = "FrameCapOptions"
	_body.add_child(_row("Frame rate cap", cap))
	var quality_names: Array[String] = []
	for level: int in range(GraphicsQuality.NAMES.size()):
		quality_names.append(GraphicsQuality.display_name(level))
	var quality: OptionButton = _options(quality_names, Settings.graphics_quality, _on_quality)
	quality.name = "QualityOptions"
	_body.add_child(_row("Graphics quality", quality))
	_body.add_child(_check("Depth of field (tilt-shift blur, Medium and High)", Settings.depth_of_field, _on_dof, "DofCheck"))
	_body.add_child(_check("Bloom (soft glow around bright things)", Settings.bloom, _on_bloom, "BloomCheck"))
	var fog: OptionButton = _options(["Off", "Light", "Full"], Settings.fog_quality, _on_fog_quality)
	fog.name = "FogQualityOptions"
	_body.add_child(_row("Fog quality", fog))
	# Graphics Tier 1: the upscaler, the render scale and the sharpness (docs/art/graphics_tier1.md).
	var upscaler: OptionButton = _options(GraphicsQuality.UPSCALER_NAMES, Settings.upscaling_mode, _on_upscaling)
	upscaler.name = "UpscalerOptions"
	_body.add_child(_row("Upscaling", upscaler))
	var scale_names: Array[String] = []
	var scale_index: int = 0
	for index: int in range(GraphicsQuality.RENDER_SCALE_CHOICES.size()):
		var pct: int = GraphicsQuality.RENDER_SCALE_CHOICES[index]
		scale_names.append("Quality preset (%d%%)" % int(round(GraphicsQuality.render_scale(Settings.graphics_quality) * 100.0)) if pct == 0 else "%d%%" % pct)
		if pct == Settings.render_scale_pct:
			scale_index = index
	var scale_options: OptionButton = _options(scale_names, scale_index, _on_render_scale)
	scale_options.name = "RenderScaleOptions"
	_body.add_child(_row("Render scale (3D)", scale_options))
	_body.add_child(_slider_row("Sharpness (upscaled image)", Settings.sharpness, _on_sharpness, _percent(Settings.sharpness), "SharpnessSlider"))
	# Performance pass Oct 25: when the frame rate dips, the 3D picture renders a little smaller for a moment (Auto: Low and Medium only).
	var drs: OptionButton = _options(DynamicResolution.MODE_NAMES, Settings.dynamic_resolution, _on_dynamic_resolution)
	drs.name = "DynamicResolutionOptions"
	_body.add_child(_row("Dynamic resolution", drs))
	_body.add_child(_slider_row("UI scale", (Settings.ui_scale - Settings.UI_SCALE_MIN) / (Settings.UI_SCALE_MAX - Settings.UI_SCALE_MIN), _on_ui_scale, _scale_text(), "UiScaleSlider"))
	var angle_options: OptionButton = _options(CameraRig.ANGLE_NAMES, Settings.camera_angle, _on_camera_angle)
	angle_options.name = "CameraAngleOptions"
	_body.add_child(_row("Camera angle", angle_options))
	var zoom_options: OptionButton = _options(CameraRig.ZOOM_NAMES, CameraRig.zoom_index(), _on_camera_zoom_preset)
	zoom_options.name = "CameraZoomOptions"
	_body.add_child(_row("Camera zoom (the mouse wheel fine-tunes)", zoom_options))
	_body.add_child(_check("Show minimap", Settings.show_minimap, _on_minimap, "MinimapCheck"))
	_body.add_child(_note("UI scale resizes menus, popups and the HUD panels. Resolution applies to the windowed mode; Fullscreen and Borderless use your screen's size."))


func _build_text() -> void:
	var texts: Array[String] = []
	for name: String in Settings.TEXT_SCALE_NAMES:
		texts.append(name)
	var cards: OptionButton = _options(texts, Settings.text_cards, _on_text_cards)
	cards.name = "CardTextOptions"
	_body.add_child(_row("Card text size", cards))
	var dialogue: OptionButton = _options(texts, Settings.text_dialogue, _on_text_dialogue)
	dialogue.name = "DialogueTextOptions"
	_body.add_child(_row("Dialogue text size", dialogue))
	var tooltips: OptionButton = _options(texts, Settings.text_tooltips, _on_text_tooltips)
	tooltips.name = "TooltipTextOptions"
	_body.add_child(_row("Tooltip text size", tooltips))
	var speed_names: Array[String] = []
	for name: String in Settings.DIALOGUE_SPEED_NAMES:
		speed_names.append(name)
	var speed: OptionButton = _options(speed_names, Settings.dialogue_speed, _on_dialogue_speed)
	speed.name = "DialogueSpeedOptions"
	_body.add_child(_row("Dialogue text speed", speed))
	var battle: OptionButton = _options(Settings.BATTLE_SPEED_NAMES.duplicate(), Settings.battle_speed, _on_battle_speed)
	battle.name = "BattleSpeedOptions"
	_body.add_child(_row("Battle speed (animations only)", battle))
	_body.add_child(_check("Warn before ending a turn with energy and playable cards left", Settings.confirm_end_turn, _on_confirm_end_turn, "ConfirmEndTurnCheck"))
	_body.add_child(_check("Auto-end the turn when nothing is playable", Settings.auto_end_turn, _on_auto_end_turn, "AutoEndTurnCheck"))
	# Fresh eyes round 2 (Oct 31): the once-ever first-time tips can be switched off (and back on) here.
	_body.add_child(_check("Tutorial tips (first-time hints in duels and on new screens)", Settings.tutorial_tips, _on_tutorial_tips, "TutorialTipsCheck"))
	_sample = UIKit.label("", &"", 27, UIStyle.PARCHMENT)
	_sample.name = "DialogueSample"
	_sample.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_sample.custom_minimum_size = Vector2(PAGE_SIZE.x - 40.0, 90)
	_body.add_child(_sample)
	_refresh_sample()
	_body.add_child(_note("Card text size changes the rules text, type line and keyword chips (the text still has to fit its panel). Tooltips are the keyword and resource explanations."))


func _build_accessibility() -> void:
	_body.add_child(_check("Colour-blind friendly: show Path symbols", Settings.colorblind_symbols, _on_colorblind, "ColorblindCheck"))
	_body.add_child(_note("Adds a round Path symbol (a flexing arm for Beefcake, a chef's hat for Gourmand, a leaf and arrow for Refusemancer, a skull for Necrocrat) to every card, deck list row and Path choice that is otherwise only colour-coded."))
	var symbols: HBoxContainer = UIKit.hbox(18)
	symbols.alignment = BoxContainer.ALIGNMENT_CENTER
	for path: Affinity.Type in Affinity.colored_types():
		var symbol: TextureRect = IconArt.rect(IconArt.energy_id(path), 56.0, UIStyle.affinity_name(path))
		if symbol != null:
			symbols.add_child(symbol)
	_body.add_child(symbols)
	_body.add_child(_check("Reduce screen shake", Settings.reduce_shake, _on_reduce_shake, "ReduceShakeCheck"))
	_body.add_child(_check("Reduce flashing effects", Settings.reduce_flashing, _on_reduce_flashing, "ReduceFlashingCheck"))
	_body.add_child(_note("Reduce flashing turns full-screen flashes down to a faint glow and removes the red hit flash on cards."))
	var reset: FancyButton = FancyButton.make("Reset all settings", &"GhostButton", Vector2(260, 48))
	reset.name = "ResetSettings"
	reset.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	reset.pressed.connect(_on_reset_all)
	_body.add_child(reset)


func _build_controls() -> void:
	var top: HBoxContainer = UIKit.hbox(12)
	var help: Label = _note("Click a key, then press the new key. Esc cancels, Delete clears. A key already used in the same group moves to the new action. The last column is the controller: choose it, then press a controller button (Start or Esc cancels, Delete clears).")
	help.custom_minimum_size = Vector2(PAGE_SIZE.x - 300.0, 0)
	help.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(help)
	var reset: FancyButton = FancyButton.make("Reset to defaults", &"GhostButton", Vector2(240, 48))
	reset.name = "ResetKeys"
	reset.pressed.connect(_on_reset_keys)
	top.add_child(reset)
	_body.add_child(top)
	_conflict_note = UIKit.label("", &"", 20, UIStyle.GOLD)
	_conflict_note.name = "ConflictNote"
	_body.add_child(_conflict_note)
	# Controller support (Oct 26): the button names prompts use, and the buttons that never move
	var names: OptionButton = _options(Settings.PAD_PROMPT_NAMES, Settings.pad_prompts, _on_pad_prompts)
	names.name = "PadPromptOptions"
	_body.add_child(_row("Controller button names", names))
	_body.add_child(_note("Fixed controller buttons: %s confirms and %s goes back in every menu, %s pauses, the right stick turns the camera, the D-pad and left stick move between buttons. In a battle the D-pad and left stick move between cards, %s picks a card or target and %s cancels." % [InputDevice.pad_text(JOY_BUTTON_A), InputDevice.pad_text(JOY_BUTTON_B), InputDevice.pad_text(JOY_BUTTON_START), InputDevice.pad_text(JOY_BUTTON_A), InputDevice.pad_text(JOY_BUTTON_B)]))
	var group: String = ""
	for action: StringName in Keybinds.action_ids():
		var entry: Dictionary = Keybinds.entry(action)
		if str(entry["group"]) != group:
			group = str(entry["group"])
			_body.add_child(UIKit.label(group, &"HeadingLabel", 26))
		_body.add_child(_key_row(action, str(entry["label"])))


func _build_audio() -> void:
	_body.add_child(_slider_row("Master volume", Settings.master_volume, _on_master, _percent(Settings.master_volume), "MasterSlider"))
	_body.add_child(_slider_row("Music volume", Settings.music_volume, _on_music, _percent(Settings.music_volume), "MusicSlider"))
	_body.add_child(_slider_row("Effects volume", Settings.sfx_volume, _on_sfx, _percent(Settings.sfx_volume), "SfxSlider"))
	_body.add_child(_slider_row("Interface sounds volume", Settings.ui_volume, _on_ui_volume, _percent(Settings.ui_volume), "UiSlider"))
	_body.add_child(_slider_row("Ambience volume", Settings.ambience_volume, _on_ambience_volume, _percent(Settings.ambience_volume), "AmbienceSlider"))
	_body.add_child(_slider_row("Dialogue voices volume", Settings.voice_volume, _on_voice_volume, _percent(Settings.voice_volume), "VoiceSlider"))
	_body.add_child(_check("Mute when the game window loses focus", Settings.mute_unfocused, _on_mute_unfocused, "MuteFocusCheck"))
	_body.add_child(_note("Effects are the game sounds (hits, spells, footsteps) and include the interface sounds (clicks, hovers, menus), which have their own slider too. Ambience is each place's background (wind, birds, hum); dialogue voices are the little blips as characters talk. The master slider scales everything."))


# ---- Building blocks ------------------------------------------------------------------------


func _row(title: String, control: Control) -> Control:
	var row: HBoxContainer = UIKit.hbox(16)
	var caption: Label = UIKit.label(title)
	caption.custom_minimum_size = Vector2(LABEL_WIDTH, 0)
	row.add_child(caption)
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(control)
	return row


func _options(items: Array[String], selected: int, callback: Callable) -> OptionButton:
	var options: OptionButton = OptionButton.new()
	for index: int in range(items.size()):
		options.add_item(items[index], index)
	options.selected = selected
	options.item_selected.connect(callback)
	options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return options


func _check(text: String, value: bool, callback: Callable, node_name: String) -> CheckButton:
	var check: CheckButton = CheckButton.new()
	check.name = node_name
	check.text = text
	check.button_pressed = value
	check.toggled.connect(callback)
	return check


func _note(text: String) -> Label:
	var note: Label = UIKit.label(text, &"MutedLabel", 18)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.custom_minimum_size = Vector2(PAGE_SIZE.x - 60.0, 0)
	return note


func _slider_row(title: String, value: float, callback: Callable, value_text: String = "", node_name: String = "") -> Control:
	var row: HBoxContainer = UIKit.hbox(16)
	var caption: Label = UIKit.label(title)
	caption.custom_minimum_size = Vector2(LABEL_WIDTH, 0)
	row.add_child(caption)
	var slider: HSlider = HSlider.new()
	if not node_name.is_empty():
		slider.name = node_name
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = value
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(slider)
	var shown: Label = UIKit.label(value_text, &"", 22, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_RIGHT)
	shown.custom_minimum_size = Vector2(80, 0)
	shown.visible = not value_text.is_empty()
	row.add_child(shown)
	slider.value_changed.connect(func(new_value: float) -> void:
		callback.call(new_value)
		if shown.visible:
			shown.text = _scale_text() if node_name == "UiScaleSlider" else _percent(new_value))
	slider.drag_ended.connect(func(_changed: bool) -> void: Audio.sfx(&"ui_tick"))
	return row


func _percent(value: float) -> String:
	return "%d%%" % int(round(value * 100.0))


func _scale_text() -> String:
	return "%d%%" % int(round(Settings.ui_scale * 100.0))


func _saved() -> void:
	if autosave:
		Settings.save_settings()


# ---- Display handlers -----------------------------------------------------------------------


func _fill_resolutions() -> void:
	_resolution.clear()
	var sizes: Array[Vector2i] = Settings.available_resolutions()
	var current: Vector2i = Settings.window_size if Settings.window_size != Vector2i.ZERO else (DisplayServer.window_get_size() if DisplayServer.get_name() != "headless" else Vector2i(1600, 900))
	var selected: int = -1
	for index: int in range(sizes.size()):
		_resolution.add_item("%d x %d" % [sizes[index].x, sizes[index].y], index)
		if sizes[index] == current:
			selected = index
	if selected < 0 and not sizes.is_empty():
		_resolution.add_item("%d x %d (current)" % [current.x, current.y], sizes.size())
		selected = sizes.size()
	_resolution.selected = selected
	_resolution.disabled = Settings.window_mode != Settings.WindowMode.WINDOWED


func _on_window_mode(index: int) -> void:
	Audio.sfx(&"ui_toggle")
	Settings.set_window_mode(index)
	if _resolution != null:
		_fill_resolutions()
	_saved()


func _on_resolution(index: int) -> void:
	Audio.sfx(&"ui_toggle")
	var sizes: Array[Vector2i] = Settings.available_resolutions()
	if index >= 0 and index < sizes.size():
		Settings.set_window_size(sizes[index])
		_saved()


func _on_vsync(pressed: bool) -> void:
	Audio.sfx(&"ui_toggle")
	Settings.vsync = pressed
	Settings.apply_window()
	_saved()


func _on_frame_cap(index: int) -> void:
	Audio.sfx(&"ui_toggle")
	Settings.max_fps = Settings.FRAME_CAPS[clampi(index, 0, Settings.FRAME_CAPS.size() - 1)]
	Settings.apply_performance()
	_saved()


func _on_quality(index: int) -> void:
	Audio.sfx(&"ui_toggle")
	Settings.graphics_quality = index
	Settings.graphics_changed.emit()
	_saved()


func _on_dof(pressed: bool) -> void:
	Audio.sfx(&"ui_toggle")
	Settings.depth_of_field = pressed
	Settings.graphics_changed.emit()
	_saved()


func _on_bloom(pressed: bool) -> void:
	Audio.sfx(&"ui_toggle")
	Settings.bloom = pressed
	Settings.graphics_changed.emit()
	_saved()


func _on_fog_quality(index: int) -> void:
	Audio.sfx(&"ui_toggle")
	Settings.fog_quality = index
	Settings.graphics_changed.emit()
	_saved()


func _on_upscaling(index: int) -> void:
	Audio.sfx(&"ui_toggle")
	Settings.upscaling_mode = index
	Settings.graphics_changed.emit()
	_saved()


func _on_render_scale(index: int) -> void:
	Audio.sfx(&"ui_toggle")
	Settings.render_scale_pct = GraphicsQuality.RENDER_SCALE_CHOICES[clampi(index, 0, GraphicsQuality.RENDER_SCALE_CHOICES.size() - 1)]
	Settings.graphics_changed.emit()
	_saved()


func _on_dynamic_resolution(index: int) -> void:
	Audio.sfx(&"ui_toggle")
	Settings.dynamic_resolution = index
	Settings.graphics_changed.emit()
	_saved()


func _on_sharpness(value: float) -> void:
	Settings.sharpness = value
	Settings.graphics_changed.emit()
	_saved()


func _on_ui_scale(value: float) -> void:
	Settings.set_ui_scale(lerpf(Settings.UI_SCALE_MIN, Settings.UI_SCALE_MAX, value))
	_saved()


func _on_zoom(value: float) -> void:
	Settings.set_camera_zoom(lerpf(Settings.ZOOM_MIN, Settings.ZOOM_MAX, value))


func _on_camera_angle(index: int) -> void:
	Settings.set_camera_angle(index)


func _on_camera_zoom_preset(index: int) -> void:
	Settings.set_camera_zoom(CameraRig.ZOOM_VALUES[clampi(index, 0, CameraRig.ZOOM_VALUES.size() - 1)])


func _on_minimap(pressed: bool) -> void:
	Audio.sfx(&"ui_toggle")
	Settings.show_minimap = pressed
	Settings.minimap_toggled.emit(pressed)
	_saved()


# ---- Text handlers --------------------------------------------------------------------------


func _on_text_cards(index: int) -> void:
	Settings.text_cards = index
	Settings.text_changed.emit()
	_saved()


func _on_text_dialogue(index: int) -> void:
	Settings.text_dialogue = index
	Settings.text_changed.emit()
	_refresh_sample()
	_saved()


func _on_text_tooltips(index: int) -> void:
	Settings.text_tooltips = index
	Settings.text_changed.emit()
	Settings.apply_tooltip_theme()
	_saved()


func _on_battle_speed(index: int) -> void:
	Settings.battle_speed = index
	_saved()


func _on_confirm_end_turn(pressed: bool) -> void:
	Settings.confirm_end_turn = pressed
	_saved()


func _on_auto_end_turn(pressed: bool) -> void:
	Settings.auto_end_turn = pressed
	_saved()


func _on_tutorial_tips(pressed: bool) -> void:
	Settings.tutorial_tips = pressed
	_saved()


func _on_dialogue_speed(index: int) -> void:
	Settings.dialogue_speed = index
	Settings.text_changed.emit()
	_refresh_sample()
	_saved()


## A sample dialogue line at the chosen size, typed out at the chosen speed.
func _refresh_sample() -> void:
	if _sample == null:
		return
	_sample.text = "\"Well met, traveler. The road ahead is long, and the Paths do not wait.\""
	_sample.add_theme_font_size_override("font_size", int(round(27.0 * Settings.dialogue_text_scale())))
	_sample.visible_ratio = 1.0
	var duration: float = Settings.typewriter_time(float(_sample.text.length()) / 55.0)
	if duration > 0.0:
		_sample.visible_ratio = 0.0
		create_tween().tween_property(_sample, "visible_ratio", 1.0, duration)


# ---- Accessibility handlers -----------------------------------------------------------------


func _on_colorblind(pressed: bool) -> void:
	Audio.sfx(&"ui_toggle")
	Settings.colorblind_symbols = pressed
	Settings.accessibility_changed.emit()
	_saved()


func _on_reduce_shake(pressed: bool) -> void:
	Audio.sfx(&"ui_toggle")
	Settings.reduce_shake = pressed
	Settings.accessibility_changed.emit()
	_saved()


func _on_reduce_flashing(pressed: bool) -> void:
	Audio.sfx(&"ui_toggle")
	Settings.reduce_flashing = pressed
	Settings.accessibility_changed.emit()
	_saved()


func _on_reset_all() -> void:
	Audio.sfx(&"ui_toggle")
	Settings.reset_to_defaults()
	_saved()
	show_page(_page)


# ---- Controls -------------------------------------------------------------------------------


func _key_row(action: StringName, title: String) -> Control:
	var row: HBoxContainer = UIKit.hbox(12)
	row.name = "Key_%s" % action
	var caption: Label = UIKit.label(title)
	caption.custom_minimum_size = Vector2(LABEL_WIDTH - 10.0, 0)
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(caption)
	for slot: int in range(Keybinds.SLOTS):
		var button: Button = FancyButton.make("", &"GhostButton", Vector2(150, 44))
		button.name = "Slot%d" % slot
		button.pressed.connect(_begin_capture.bind(action, slot, button))
		row.add_child(button)
		_key_buttons["%s:%d" % [action, slot]] = button
	var pad_button: Button = FancyButton.make("", &"GhostButton", Vector2(180, 44))
	pad_button.name = "PadSlot"
	pad_button.disabled = Keybinds.pad_fixed(action)
	pad_button.tooltip_text = "The controller button (fixed)" if pad_button.disabled else "The controller button: choose, then press a button on the controller"
	pad_button.pressed.connect(_begin_capture.bind(action, PAD_SLOT, pad_button))
	row.add_child(pad_button)
	_key_buttons["%s:%d" % [action, PAD_SLOT]] = pad_button
	var reset: Button = FancyButton.make("Reset", &"GhostButton", Vector2(100, 44))
	reset.name = "ResetAction"
	reset.pressed.connect(func() -> void:
		Keybinds.reset_action(action)
		_saved()
		_refresh_keys())
	row.add_child(reset)
	_refresh_keys()
	return row


func _refresh_keys() -> void:
	for key: Variant in _key_buttons.keys():
		var parts: PackedStringArray = str(key).split(":")
		var button: Button = _key_buttons[key] as Button
		if not is_instance_valid(button):
			continue
		if int(parts[1]) == PAD_SLOT:
			var pad_code: int = Keybinds.pad_of(StringName(parts[0]))
			button.text = InputDevice.pad_text(pad_code) if pad_code != Keybinds.PAD_NONE else "Not set"
			continue
		var code: int = Keybinds.keys_of(StringName(parts[0]))[int(parts[1])]
		button.text = Keybinds.key_text(code) if code != 0 else "Not set"


func _begin_capture(action: StringName, slot: int, button: Button) -> void:
	_cancel_capture()
	Audio.sfx(&"ui_select")
	_capturing = {"action": action, "slot": slot, "button": button}
	button.text = "Press a button..." if slot == PAD_SLOT else "Press a key..."
	_capture_frame = Engine.get_process_frames()
	if _conflict_note != null:
		_conflict_note.text = ""


func _cancel_capture() -> void:
	if _capturing.is_empty():
		return
	_capturing = {}
	_refresh_keys()


func _input(event: InputEvent) -> void:
	if _capturing.is_empty():
		return
	if int(_capturing["slot"]) == PAD_SLOT:
		_input_pad_capture(event)
		return
	var key: InputEventKey = event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	get_viewport().set_input_as_handled()
	if key.keycode == KEY_ESCAPE:
		_cancel_capture()
		return
	var code: int = int(key.physical_keycode)
	if code == 0 or key.keycode in [KEY_SHIFT, KEY_CTRL, KEY_ALT, KEY_META]:
		return
	capture_key(code)


## Binds `code` to the key button that is waiting (what a key press does while capturing); Delete and Backspace clear the slot.
func capture_key(code: int) -> void:
	if _capturing.is_empty():
		return
	var action: StringName = _capturing["action"] as StringName
	var slot: int = int(_capturing["slot"])
	_capturing = {}
	var result: String = ""
	if code == KEY_DELETE or code == KEY_BACKSPACE:
		result = Keybinds.rebind(action, slot, 0)
	else:
		result = Keybinds.rebind(action, slot, code)
	if _conflict_note != null:
		if result == "reserved":
			_conflict_note.text = "That key is reserved (Esc, Enter and Tab)."
		elif not result.is_empty():
			_conflict_note.text = "%s was using that key and is now unset." % result
		else:
			_conflict_note.text = ""
	Audio.sfx(&"ui_tick")
	_saved()
	_refresh_keys()


## Controller support (Oct 26): the pad column's capture - the next controller button (or stick / trigger direction) binds; Start or Esc cancels,
## Delete / Backspace clears. The press that opened the capture (A on the slot) is not taken: only presses after the first frame count.
func _input_pad_capture(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key != null and key.pressed and not key.echo:
		get_viewport().set_input_as_handled()
		if key.keycode == KEY_ESCAPE:
			_cancel_capture()
		elif key.keycode == KEY_DELETE or key.keycode == KEY_BACKSPACE:
			capture_pad(Keybinds.PAD_NONE)
		return
	if not (event is InputEventJoypadButton or event is InputEventJoypadMotion):
		return
	get_viewport().set_input_as_handled()
	var code: int = Keybinds.pad_code_of(event)
	if code == Keybinds.PAD_NONE or Engine.get_process_frames() <= _capture_frame:
		return
	if code == JOY_BUTTON_START:
		_cancel_capture()
		return
	capture_pad(code)


## Binds pad `code` to the controller slot that is waiting (PAD_NONE clears it).
func capture_pad(code: int) -> void:
	if _capturing.is_empty() or int(_capturing["slot"]) != PAD_SLOT:
		return
	var action: StringName = _capturing["action"] as StringName
	_capturing = {}
	var result: String = Keybinds.rebind_pad(action, code)
	if _conflict_note != null:
		if result == "reserved" or result == "fixed":
			_conflict_note.text = "That button is reserved (Start pauses)."
		elif not result.is_empty():
			_conflict_note.text = "%s was using that button and is now unset." % result
		else:
			_conflict_note.text = ""
	Audio.sfx(&"ui_tick")
	_saved()
	_refresh_keys()
	PromptText.refresh_all(get_tree())


func _on_pad_prompts(index: int) -> void:
	Audio.sfx(&"ui_toggle")
	Settings.pad_prompts = index
	_saved()
	_refresh_keys()
	PromptText.refresh_all(get_tree())


func _on_reset_keys() -> void:
	Audio.sfx(&"ui_toggle")
	_cancel_capture()
	Keybinds.reset_all()
	_saved()
	if _conflict_note != null:
		_conflict_note.text = "All keys are back to their defaults."
	_refresh_keys()


# ---- Audio handlers -------------------------------------------------------------------------


func _on_master(value: float) -> void:
	Settings.master_volume = value
	Settings.apply_audio()
	_saved()


func _on_music(value: float) -> void:
	Settings.music_volume = value
	Settings.apply_audio()
	_saved()


func _on_sfx(value: float) -> void:
	Settings.sfx_volume = value
	Settings.apply_audio()
	_saved()


func _on_ui_volume(value: float) -> void:
	Settings.ui_volume = value
	Settings.apply_audio()
	_saved()


func _on_ambience_volume(value: float) -> void:
	Settings.ambience_volume = value
	Settings.apply_audio()
	_saved()


func _on_voice_volume(value: float) -> void:
	Settings.voice_volume = value
	Settings.apply_audio()
	_saved()


func _on_mute_unfocused(pressed: bool) -> void:
	Audio.sfx(&"ui_toggle")
	Settings.mute_unfocused = pressed
	Settings.apply_audio()
	_saved()


## Controller support (Oct 26): the pad's B leaves the settings like the Back button (Esc keeps closing the whole pause menu).
func _unhandled_input(event: InputEvent) -> void:
	if _capturing.is_empty() and event is InputEventJoypadButton and UiInput.is_back(event) and is_visible_in_tree():
		get_viewport().set_input_as_handled()
		_on_back()


func _on_back() -> void:
	_cancel_capture()
	_saved()
	closed.emit()
