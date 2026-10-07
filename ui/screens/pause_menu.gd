class_name PauseMenu
extends CanvasLayer
## Escape-key pause overlay: resume, settings, back to title, quit.

var _root: Control
var _menu: PanelContainer
var _settings: SettingsPanel
var _slots: SaveSlotsScreen
## The game as it looked when the menu opened (the save slot thumbnail).
var _snapshot: Image


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_root = UIKit.layer_host(self)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.02, 0.01, 0.04, 0.72)
	UIKit.full_rect(dim)
	_root.add_child(dim)
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	_root.add_child(center)
	_menu = UIKit.panel()
	_menu.custom_minimum_size = Vector2(420, 0)
	center.add_child(_menu)
	_build_menu()


func _build_menu() -> void:
	for child: Node in _menu.get_children():
		child.queue_free()
	var column: VBoxContainer = UIKit.vbox(14)
	_menu.add_child(column)
	column.add_child(UIKit.label("Paused", &"HeadingLabel", 38, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	column.add_child(UIKit.spacer(6))
	var resume: FancyButton = FancyButton.make("Resume", &"PrimaryButton", Vector2(0, 54))
	resume.pressed.connect(toggle)
	column.add_child(resume)
	if Session.has_profile():
		var save: FancyButton = FancyButton.make("Save Game", &"", Vector2(0, 54))
		save.name = "SaveButton"
		save.disabled = not Session.can_save_now()
		save.tooltip_text = "You can save anywhere except in a battle or a dungeon." if save.disabled else ""
		save.pressed.connect(func() -> void: _show_slots(SaveSlotsScreen.Mode.SAVE))
		column.add_child(save)
	var load_button: FancyButton = FancyButton.make("Load Game", &"", Vector2(0, 54))
	load_button.name = "LoadButton"
	load_button.pressed.connect(func() -> void: _show_slots(SaveSlotsScreen.Mode.LOAD))
	column.add_child(load_button)
	var settings: FancyButton = FancyButton.make("Settings", &"", Vector2(0, 54))
	settings.pressed.connect(_show_settings)
	column.add_child(settings)
	var title: FancyButton = FancyButton.make("Quit to Title", &"", Vector2(0, 54))
	title.pressed.connect(_to_title)
	column.add_child(title)
	var quit: FancyButton = FancyButton.make("Quit Game", &"DangerButton", Vector2(0, 54))
	quit.pressed.connect(SceneManager.quit_game)
	column.add_child(quit)


func toggle() -> void:
	if not visible:
		_snapshot = Session.capture_thumbnail()
	visible = not visible
	get_tree().paused = visible
	if visible:
		Audio.sfx(&"ui_open")
		_build_menu()
		if _settings != null:
			_settings.queue_free()
			_settings = null
		_close_slots()
	else:
		Audio.sfx(&"ui_close")


## The save slot list over the pause menu (Save or Load).
func _show_slots(mode: SaveSlotsScreen.Mode) -> void:
	_close_slots()
	_slots = SaveSlotsScreen.make(mode, _snapshot)
	_slots.closed.connect(_close_slots)
	_slots.loaded.connect(func() -> void:
		_close_slots()
		toggle()
		Session.resume_loaded_game())
	_root.add_child(_slots)


func _close_slots() -> void:
	if _slots != null:
		_slots.queue_free()
		_slots = null


func _show_settings() -> void:
	for child: Node in _menu.get_children():
		child.queue_free()
	_settings = SettingsPanel.new()
	_settings.theme_type_variation = &"DarkPanel"
	_menu.add_child(_settings)
	_settings.closed.connect(_build_menu)


func _to_title() -> void:
	toggle()
	Session.save_game()
	SceneManager.go_to_title()
