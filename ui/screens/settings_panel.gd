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
var _conflict_note: Label
var _resolution: OptionButton
var _sample: Label
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
	scroll.custom_minimum_size = PAGE_SIZE
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	_body = UIKit.vbox(12)
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_body)
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
	var help: Label = _note("Click a key, then press the new key. Esc cancels, Delete clears. A key already used in the same group moves to the new action.")
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
	_body.add_child(_check("Mute when the game window loses focus", Settings.mute_unfocused, _on_mute_unfocused, "MuteFocusCheck"))
	_body.add_child(_note("Effects are the game sounds (hits, spells, footsteps); interface sounds are the clicks, hovers and menu sounds. The master slider scales all three."))


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
	caption.custom_minimum_size = Vector2(LABEL_WIDTH + 40.0, 0)
	row.add_child(caption)
	for slot: int in range(Keybinds.SLOTS):
		var button: Button = FancyButton.make("", &"GhostButton", Vector2(190, 44))
		button.name = "Slot%d" % slot
		button.pressed.connect(_begin_capture.bind(action, slot, button))
		row.add_child(button)
		_key_buttons["%s:%d" % [action, slot]] = button
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
		var code: int = Keybinds.keys_of(StringName(parts[0]))[int(parts[1])]
		button.text = Keybinds.key_text(code) if code != 0 else "Not set"


func _begin_capture(action: StringName, slot: int, button: Button) -> void:
	_cancel_capture()
	Audio.sfx(&"ui_select")
	_capturing = {"action": action, "slot": slot, "button": button}
	button.text = "Press a key..."
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


func _on_mute_unfocused(pressed: bool) -> void:
	Audio.sfx(&"ui_toggle")
	Settings.mute_unfocused = pressed
	Settings.apply_audio()
	_saved()


func _on_back() -> void:
	_cancel_capture()
	_saved()
	closed.emit()
