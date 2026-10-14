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
	UiScale.fit(_root)
	var dim: Control = UiSkin.menu_backdrop(Color(0.02, 0.01, 0.04, 0.72))
	_root.add_child(dim)
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	_root.add_child(center)
	_menu = UIKit.panel()
	_menu.custom_minimum_size = Vector2(480, 0)
	center.add_child(_menu)
	_build_menu()


func _build_menu() -> void:
	for child: Node in _menu.get_children():
		child.queue_free()
	var column: VBoxContainer = UIKit.vbox(14)
	_menu.add_child(column)
	var emblem: Texture2D = KeyArt.texture("LOGO-EMBLEM")
	if emblem != null:
		# The small logo (the four Paths meeting at the crossroads stone) tops the pause menu.
		var badge: TextureRect = TextureRect.new()
		badge.name = "Emblem"
		badge.texture = emblem
		badge.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		badge.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		badge.custom_minimum_size = Vector2(112, 112)
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		column.add_child(badge)
	column.add_child(UIKit.label("Paused", &"HeadingLabel", 38, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	column.add_child(UIKit.spacer(6))
	var resume: FancyButton = FancyButton.make("Resume", &"PrimaryButton", Vector2(0, 54))
	resume.pressed.connect(toggle)
	column.add_child(resume)
	if Session.has_profile():
		var save: FancyButton = FancyButton.make("Save Game", &"", Vector2(0, 54))
		save.name = "SaveButton"
		IconArt.button_icon(save, "ICON-UI-SAVE", 40.0)
		save.disabled = not Session.can_save_now()
		save.tooltip_text = "You can save anywhere except in a battle or a dungeon." if save.disabled else ""
		save.pressed.connect(func() -> void: _show_slots(SaveSlotsScreen.Mode.SAVE))
		column.add_child(save)
	var load_button: FancyButton = FancyButton.make("Load Game", &"", Vector2(0, 54))
	load_button.name = "LoadButton"
	IconArt.button_icon(load_button, "ICON-UI-LOAD", 40.0)
	load_button.pressed.connect(func() -> void: _show_slots(SaveSlotsScreen.Mode.LOAD))
	column.add_child(load_button)
	var settings: FancyButton = FancyButton.make("Settings", &"", Vector2(0, 54))
	IconArt.button_icon(settings, "ICON-UI-SETTINGS", 40.0)
	settings.pressed.connect(_show_settings)
	column.add_child(settings)
	var feedback: FancyButton = FancyButton.make("Send Feedback (F8)", &"", Vector2(0, 54))
	feedback.name = "FeedbackButton"
	feedback.pressed.connect(SceneManager.open_feedback)
	column.add_child(feedback)
	var folder: FancyButton = FancyButton.make("Open feedback folder", &"", Vector2(0, 54))
	folder.name = "OpenFeedbackFolderButton"
	folder.pressed.connect(FeedbackReport.open_folder)
	column.add_child(folder)
	var title: FancyButton = FancyButton.make("Quit to Title", &"", Vector2(0, 54))
	title.pressed.connect(_to_title)
	column.add_child(title)
	var quit: FancyButton = FancyButton.make("Quit Game", &"DangerButton", Vector2(0, 54))
	quit.pressed.connect(SceneManager.quit_game)
	column.add_child(quit)
	var version: Label = UIKit.label("The Wayward Path  v%s" % FeedbackReport.version(), &"MutedLabel", 18, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	version.name = "VersionLabel"
	column.add_child(version)


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
