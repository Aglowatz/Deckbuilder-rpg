class_name TitleScreen
extends Control
## Title menu: New Game / Continue / Settings / Quit, over a slowly turning 3D view of the town.

const GAME_TITLE: String = "WELLSPRING"

var _menu_column: VBoxContainer
var _overlay: CenterContainer


var _screenshot_open: String = ""


func screenshot_prepare(args: Dictionary) -> void:
	_screenshot_open = str(args.get("open", ""))


func _ready() -> void:
	SceneManager.pause_allowed = false
	Audio.play_music(&"title")
	_build_backdrop()
	_build_menu()
	if _screenshot_open == "settings":
		_on_settings()
	elif _screenshot_open == "confirm":
		_confirm_overwrite()


func _build_backdrop() -> void:
	var backdrop: TownBackdrop = TownBackdrop.new()
	add_child(backdrop)
	var vignette: ColorRect = UIKit.vignette(0.9)
	add_child(vignette)
	# A dark band on the left keeps the menu readable over the scene.
	var band: TextureRect = TextureRect.new()
	var gradient: Gradient = Gradient.new()
	gradient.colors = PackedColorArray([Color(0.04, 0.02, 0.07, 0.85), Color(0.04, 0.02, 0.07, 0.0)])
	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 512
	texture.height = 4
	texture.fill_from = Vector2(0, 0)
	texture.fill_to = Vector2(1, 0)
	band.texture = texture
	band.stretch_mode = TextureRect.STRETCH_SCALE
	band.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	band.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	band.offset_right = 900
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(band)


func _build_menu() -> void:
	var margin: MarginContainer = MarginContainer.new()
	UIKit.full_rect(margin)
	margin.add_theme_constant_override("margin_left", 140)
	margin.add_theme_constant_override("margin_top", 120)
	margin.add_theme_constant_override("margin_bottom", 100)
	add_child(margin)
	_menu_column = UIKit.vbox(16)
	margin.add_child(_menu_column)
	var title: Label = UIKit.label(GAME_TITLE, &"TitleLabel", 104)
	_menu_column.add_child(title)
	var subtitle: Label = UIKit.label("A DECKBUILDER ROLE-PLAYING GAME", &"MutedLabel", 24)
	subtitle.add_theme_color_override("font_color", UIStyle.PARCHMENT)
	_menu_column.add_child(subtitle)
	var version: Label = UIKit.label("v%s" % str(ProjectSettings.get_setting("application/config/version", "0.0.0")), &"MutedLabel", 20)
	version.name = "VersionLabel"
	_menu_column.add_child(version)
	_menu_column.add_child(UIKit.spacer(40))
	Session.discard_incompatible_save()
	var has_saves: bool = SaveSlots.any_save()
	if has_saves:
		_menu_column.add_child(_menu_button("Continue", &"PrimaryButton", _on_continue))
	_menu_column.add_child(_menu_button("New Game", &"PrimaryButton" if not has_saves else &"", _on_new_game))
	if has_saves:
		_menu_column.add_child(_menu_button("Load Game", &"", _on_load_game))
	_menu_column.add_child(_menu_button("Settings", &"", _on_settings))
	_menu_column.add_child(_menu_button("Quit", &"", SceneManager.quit_game))
	if not Session.save_reset_message.is_empty():
		var notice: Label = UIKit.label(Session.save_reset_message, &"MutedLabel", 20)
		notice.name = "SaveResetNotice"
		notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		notice.custom_minimum_size = Vector2(760, 0)
		notice.add_theme_color_override("font_color", Color("ffcf7a"))
		_menu_column.add_child(notice)
		Session.save_reset_message = ""
	_menu_column.add_child(UIKit.filler())
	_menu_column.add_child(UIKit.label("Placeholder art and names. Press Esc in game for the pause menu.", &"MutedLabel", 18))
	for index: int in range(_menu_column.get_child_count()):
		var child: Control = _menu_column.get_child(index) as Control
		UIKit.pop_in(child, 0.1 * index)


func _menu_button(text: String, variation: StringName, callback: Callable) -> FancyButton:
	var button: FancyButton = FancyButton.make(text, variation, Vector2(360, 60))
	button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	button.pressed.connect(callback)
	return button


func _on_continue() -> void:
	# Continue picks up the most recently saved slot (the autosave or a manual save).
	if Session.load_from_slot(SaveSlots.latest_slot()):
		Audio.sfx(&"ui_confirm")
		Session.resume_loaded_game()
	else:
		Audio.sfx(&"ui_error")


func _on_load_game() -> void:
	var screen: SaveSlotsScreen = SaveSlotsScreen.make(SaveSlotsScreen.Mode.LOAD)
	screen.closed.connect(screen.queue_free)
	screen.loaded.connect(Session.resume_loaded_game)
	add_child(screen)


func _on_new_game() -> void:
	if SaveSlots.any_save():
		_confirm_overwrite()
		return
	_start_new_game()


func _start_new_game() -> void:
	Session.new_game()
	Audio.sfx(&"ui_confirm")
	SceneManager.go_to_start_area()


func _confirm_overwrite() -> void:
	_show_overlay(func(box: VBoxContainer) -> void:
		box.add_child(UIKit.label("Start a new game?", &"HeadingLabel", 34, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
		var text: Label = UIKit.label("Your autosave is replaced as you play. Your numbered save slots are not touched.", &"", 22, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
		text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text.custom_minimum_size = Vector2(460, 0)
		box.add_child(text)
		var row: HBoxContainer = UIKit.hbox(16)
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		var yes: FancyButton = FancyButton.make("Start Over", &"DangerButton", Vector2(190, 52))
		yes.pressed.connect(_start_new_game)
		var no: FancyButton = FancyButton.make("Cancel", &"", Vector2(190, 52))
		no.pressed.connect(_close_overlay)
		row.add_child(yes)
		row.add_child(no)
		box.add_child(row))


func _on_settings() -> void:
	_show_overlay(func(box: VBoxContainer) -> void:
		var panel: SettingsPanel = SettingsPanel.new()
		panel.theme_type_variation = &"DarkPanel"
		panel.closed.connect(_close_overlay)
		box.add_child(panel))


func _show_overlay(builder: Callable) -> void:
	_close_overlay()
	_overlay = CenterContainer.new()
	UIKit.full_rect(_overlay)
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.02, 0.01, 0.04, 0.7)
	UIKit.full_rect(dim)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)
	dim.name = "OverlayDim"
	add_child(_overlay)
	var panel: PanelContainer = UIKit.panel()
	_overlay.add_child(panel)
	var box: VBoxContainer = UIKit.vbox(18)
	panel.add_child(box)
	builder.call(box)
	UIKit.pop_in(panel)
	Audio.sfx(&"ui_open")


func _close_overlay() -> void:
	if _overlay != null:
		_overlay.queue_free()
		_overlay = null
	var dim: Node = get_node_or_null("OverlayDim")
	if dim != null:
		dim.queue_free()
