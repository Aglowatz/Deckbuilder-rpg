class_name TuningPanel
extends PanelContainer
## Live tuning panel of the World Look Test (Tab toggles it): one slider per look value with its number beside it, a fog colour picker, and the buttons
## "Save as My Preset", "Reset to Recommended" and "Copy values". It edits the dictionary it is given (LookParams keys) and emits `changed` on every edit.

signal changed
signal save_pressed
signal reset_pressed

var values: Dictionary = {}
var _sliders: Dictionary = {}
var _value_labels: Dictionary = {}
var _title: Label
var _fog_button: ColorPickerButton
var _status: Label
var _suppress: bool = false


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE
	custom_minimum_size = Vector2(430, 0)
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.06, 0.1, 0.88)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(10)
	style.border_color = Color(1.0, 0.82, 0.45, 0.7)
	style.set_border_width_all(1)
	add_theme_stylebox_override("panel", style)
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 2)
	add_child(column)
	_title = Label.new()
	_title.add_theme_font_size_override("font_size", 15)
	_title.add_theme_color_override("font_color", Color(1.0, 0.9, 0.6))
	column.add_child(_title)
	for slider_data: Dictionary in LookParams.SLIDERS:
		column.add_child(_row(slider_data))
	var fog_row: HBoxContainer = HBoxContainer.new()
	var fog_label: Label = Label.new()
	fog_label.text = "Fog colour"
	fog_label.custom_minimum_size = Vector2(190, 0)
	fog_label.add_theme_font_size_override("font_size", 12)
	fog_row.add_child(fog_label)
	_fog_button = ColorPickerButton.new()
	_fog_button.custom_minimum_size = Vector2(90, 20)
	_fog_button.focus_mode = Control.FOCUS_NONE
	_fog_button.edit_alpha = false
	_fog_button.color_changed.connect(_on_fog_color)
	fog_row.add_child(_fog_button)
	column.add_child(fog_row)
	var buttons: HBoxContainer = HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 6)
	for spec: Array in [["Save as My Preset", save_pressed], ["Reset to Recommended", reset_pressed], ["Copy values", Callable(self, "_copy")]]:
		var button: Button = Button.new()
		button.text = str(spec[0])
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override("font_size", 12)
		if spec[1] is Signal:
			button.pressed.connect((spec[1] as Signal).emit)
		else:
			button.pressed.connect(spec[1] as Callable)
		buttons.add_child(button)
	column.add_child(buttons)
	_status = Label.new()
	_status.add_theme_font_size_override("font_size", 11)
	_status.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	column.add_child(_status)


func _row(slider_data: Dictionary) -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	var label: Label = Label.new()
	label.text = str(slider_data["label"])
	label.custom_minimum_size = Vector2(190, 0)
	label.add_theme_font_size_override("font_size", 12)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(label)
	var slider: HSlider = HSlider.new()
	slider.min_value = float(slider_data["min"])
	slider.max_value = float(slider_data["max"])
	slider.step = float(slider_data["step"])
	slider.custom_minimum_size = Vector2(150, 16)
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.focus_mode = Control.FOCUS_NONE
	slider.scrollable = false
	slider.value_changed.connect(_on_slider.bind(str(slider_data["key"])))
	row.add_child(slider)
	var value_label: Label = Label.new()
	value_label.custom_minimum_size = Vector2(54, 0)
	value_label.add_theme_font_size_override("font_size", 12)
	value_label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.8))
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(value_label)
	_sliders[str(slider_data["key"])] = slider
	_value_labels[str(slider_data["key"])] = value_label
	return row


func bind(new_values: Dictionary) -> void:
	values = new_values
	refresh()


## Pushes the dictionary into the sliders without emitting `changed`.
func refresh() -> void:
	_suppress = true
	for slider_data: Dictionary in LookParams.SLIDERS:
		var key: String = str(slider_data["key"])
		var value: float = float(values.get(key, 0.0))
		(_sliders[key] as HSlider).value = value
		_show_value(key, value)
	_fog_button.color = Color.html(str(values.get("fog_color", "f2cfa4")))
	_title.text = "%s    (Tab hides this panel)" % str(values.get("name", "Look"))
	_suppress = false


func set_status(text: String) -> void:
	_status.text = text


func _show_value(key: String, value: float) -> void:
	var step: float = 0.01
	for slider_data: Dictionary in LookParams.SLIDERS:
		if str(slider_data["key"]) == key:
			step = float(slider_data["step"])
	(_value_labels[key] as Label).text = LookParams._fmt(value, step)


func _on_slider(value: float, key: String) -> void:
	_show_value(key, value)
	if _suppress:
		return
	values[key] = value
	changed.emit()


func _on_fog_color(color: Color) -> void:
	if _suppress:
		return
	values["fog_color"] = color.to_html(false)
	changed.emit()


func _copy() -> void:
	var text: String = JSON.stringify(values, "\t")
	DisplayServer.clipboard_set(text)
	print("world_look: values\n" + text)
	set_status("Values copied to the clipboard and printed to the console.")
