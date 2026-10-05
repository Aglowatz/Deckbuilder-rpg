class_name SettingsPanel
extends PanelContainer
## Volume sliders, graphics quality, depth of field and the fullscreen toggle. Changes apply immediately and are saved on close.

signal closed


func _ready() -> void:
	custom_minimum_size = Vector2(560, 0)
	var column: VBoxContainer = UIKit.vbox(16)
	add_child(column)
	column.add_child(UIKit.label("Settings", &"HeadingLabel", 34, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	column.add_child(_slider_row("Master volume", Settings.master_volume, _on_master))
	column.add_child(_slider_row("Music volume", Settings.music_volume, _on_music))
	column.add_child(_slider_row("Effects volume", Settings.sfx_volume, _on_sfx))
	var fullscreen: CheckButton = CheckButton.new()
	fullscreen.text = "Fullscreen"
	fullscreen.button_pressed = Settings.fullscreen
	fullscreen.toggled.connect(_on_fullscreen)
	column.add_child(fullscreen)
	var minimap: CheckButton = CheckButton.new()
	minimap.text = "Show minimap"
	minimap.button_pressed = Settings.show_minimap
	minimap.toggled.connect(_on_minimap)
	column.add_child(minimap)
	column.add_child(_quality_row())
	var dof: CheckButton = CheckButton.new()
	dof.text = "Soft depth of field (Medium and High)"
	dof.button_pressed = Settings.depth_of_field
	dof.toggled.connect(_on_dof)
	column.add_child(dof)
	var back: FancyButton = FancyButton.make("Back", &"PrimaryButton", Vector2(200, 52))
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(_on_back)
	column.add_child(back)


func _slider_row(title: String, value: float, callback: Callable) -> Control:
	var row: HBoxContainer = UIKit.hbox(16)
	var caption: Label = UIKit.label(title)
	caption.custom_minimum_size = Vector2(190, 0)
	row.add_child(caption)
	var slider: HSlider = HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = value
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.value_changed.connect(callback)
	slider.drag_ended.connect(func(_changed: bool) -> void: Audio.sfx(&"ui_tick"))
	row.add_child(slider)
	return row


func _on_master(value: float) -> void:
	Settings.master_volume = value
	Settings.apply()


func _on_music(value: float) -> void:
	Settings.music_volume = value
	Settings.apply()


func _on_sfx(value: float) -> void:
	Settings.sfx_volume = value
	Settings.apply()


func _on_fullscreen(pressed: bool) -> void:
	Audio.sfx(&"ui_toggle")
	Settings.fullscreen = pressed
	Settings.apply()


func _on_minimap(pressed: bool) -> void:
	Audio.sfx(&"ui_toggle")
	Settings.show_minimap = pressed
	Settings.apply()
	Settings.minimap_toggled.emit(pressed)


func _on_back() -> void:
	Settings.save_settings()
	closed.emit()


func _quality_row() -> Control:
	var row: HBoxContainer = UIKit.hbox(16)
	var caption: Label = UIKit.label("Graphics quality")
	caption.custom_minimum_size = Vector2(190, 0)
	row.add_child(caption)
	var options: OptionButton = OptionButton.new()
	options.name = "QualityOptions"
	for level: int in range(GraphicsQuality.NAMES.size()):
		options.add_item(GraphicsQuality.display_name(level), level)
	options.selected = Settings.graphics_quality
	options.item_selected.connect(_on_quality)
	options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(options)
	return row


func _on_quality(index: int) -> void:
	Audio.sfx(&"ui_toggle")
	Settings.graphics_quality = index
	Settings.graphics_changed.emit()


func _on_dof(pressed: bool) -> void:
	Audio.sfx(&"ui_toggle")
	Settings.depth_of_field = pressed
	Settings.graphics_changed.emit()
