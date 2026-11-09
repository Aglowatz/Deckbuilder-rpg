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
	# Controller support (Oct 26): the menu takes the pad's focus while it is open
	PadFocus.register(_root)


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
	# Overnight Oct 23, Part 5: keywords, resources, statuses, card types and rule icons in plain words.
	var glossary: FancyButton = FancyButton.make("Glossary", &"", Vector2(0, 54))
	glossary.name = "GlossaryButton"
	IconArt.button_icon(glossary, "ICON-UI-GLOSSARY", 40.0)  # art import Oct 31
	glossary.pressed.connect(_show_glossary)
	column.add_child(glossary)
	# Overnight Oct 28, Part 3: the feats (achievements) page.
	var feats_button: FancyButton = FancyButton.make("Feats", &"", Vector2(0, 54))
	feats_button.name = "FeatsButton"
	IconArt.button_icon(feats_button, "ICON-UI-FEATS", 40.0)  # art import Oct 31
	feats_button.pressed.connect(_show_feats)
	column.add_child(feats_button)
	var feedback: FancyButton = FancyButton.make("Report a Problem (F8)", &"", Vector2(0, 54))
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
	quit.name = "QuitGameButton"
	quit.pressed.connect(_ask_quit)
	column.add_child(quit)
	var version: Label = UIKit.label("The Wayward Path  v%s" % FeedbackReport.version(), &"MutedLabel", 18, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	version.name = "VersionLabel"
	column.add_child(version)
	UiInput.make_focusable(column)
	PadFocus.focus_soon(_root)


func toggle() -> void:
	if not visible:
		_snapshot = Session.capture_thumbnail()
	visible = not visible
	get_tree().paused = visible
	if visible:
		GameLog.modal_opened("PauseMenu")
	else:
		GameLog.modal_closed("PauseMenu")
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
	_slots.closed.connect(func() -> void: Audio.sfx(&"ui_back", -6.0), CONNECT_ONE_SHOT)  # Overnight Nov 9: it opens with its own sound
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
	UiSounds.panel_sounds(_settings)


func _show_glossary() -> void:
	for child: Node in _menu.get_children():
		child.queue_free()
	var panel: GlossaryPanel = GlossaryPanel.make()
	UiSounds.panel_sounds(panel)
	_menu.add_child(panel)
	panel.closed.connect(_build_menu)


func _show_feats() -> void:
	for child: Node in _menu.get_children():
		child.queue_free()
	var panel: FeatsPanel = FeatsPanel.make()
	UiSounds.panel_sounds(panel)
	_menu.add_child(panel)
	panel.closed.connect(_build_menu)
	PadFocus.focus_soon(_root)


## Controller support (Oct 26): the pad's B steps back - out of the save slots, a settings or glossary page, then closes the menu (Esc keeps its
## old meaning: it is the pause key, so it closes the whole menu from anywhere).
func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	# Fix pass Nov 7 (item 13, C7 F6): Esc steps back to the opener like the pad's B - out of the save slots, Settings, the Glossary or the
	# Feats to the menu; only on the menu itself does Esc close it (the pause key, handled by SceneManager).
	var sub_page: bool = _slots != null or (is_instance_valid(_settings) and _settings.is_inside_tree() and not _settings.is_queued_for_deletion()) 		or _menu.find_child("GlossaryPanel", true, false) != null or _menu.find_child("FeatsPanel", true, false) != null
	if not event is InputEventJoypadButton and not sub_page:
		return
	if _root != null and _root.find_children("*", "ConfirmDialog", true, false).size() > 0:
		return  # the dialog answers Esc itself
	if not UiInput.is_back(event):
		return
	get_viewport().set_input_as_handled()
	if _slots != null:
		_close_slots()
		PadFocus.focus_soon(_root)
	elif is_instance_valid(_settings) and _settings.is_inside_tree() and not _settings.is_queued_for_deletion():
		_settings.call(&"_on_back")
	elif _menu.find_child("GlossaryPanel", true, false) != null or _menu.find_child("FeatsPanel", true, false) != null:
		_build_menu()
	else:
		toggle()


## Overnight Oct 31 - Nov 1 (second-look critic): Quit Game asks first and saves like Quit to Title (it closed at once, unsaved).
func _ask_quit() -> void:
	var dialog: ConfirmDialog = ConfirmDialog.ask(_root, "Quit the game?", "Your game is saved before it closes.", "Quit", "Keep playing", true)
	dialog.name = "QuitConfirm"
	dialog.confirmed.connect(func() -> void:
		Session.save_game()
		SceneManager.quit_game())


func _to_title() -> void:
	toggle()
	Session.save_game()
	SceneManager.go_to_title()
