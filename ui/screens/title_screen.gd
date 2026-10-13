class_name TitleScreen
extends Control
## Title menu: New Game / Continue / Settings / Quit. The key art (TITLE-KEYART, or TITLE-KEYART-NIGHT once the final boss was beaten) fills the screen with a slow drift,
## a gentle shimmer of light and drifting motes; the wordmark (LOGO-WORDMARK) sits in the open upper centre and the menu on the calmer right side. Without the art it falls back to
## the turning 3D view of the town and the text title.

const GAME_TITLE: String = "THE WAYWARD PATH"
const ART_ID: String = "TITLE-KEYART"
const NIGHT_ID: String = "TITLE-KEYART-NIGHT"
const LOGO_ID: String = "LOGO-WORDMARK"
## The art is drawn this much larger than the screen so the drift never shows an edge.
const ART_ZOOM: float = 1.08
const DRIFT_PIXELS: float = 26.0
const LOGO_WIDTH: float = 760.0

var _menu_column: VBoxContainer
var _overlay: CenterContainer
var _art: TextureRect
var _glow: TextureRect
var _logo: TextureRect
var _night: bool = false
var _postgame_arg: String = ""


var _screenshot_open: String = ""


func screenshot_prepare(args: Dictionary) -> void:
	_screenshot_open = str(args.get("open", ""))
	_postgame_arg = str(args.get("postgame", ""))


func _ready() -> void:
	SceneManager.pause_allowed = false
	Audio.music.clear_overlays(0.0)
	Audio.play_music(MusicDirector.title())
	_build_backdrop()
	_build_menu()
	if _screenshot_open == "settings":
		_on_settings()
	elif _screenshot_open == "confirm":
		_confirm_overwrite()


func _build_backdrop() -> void:
	_night = (_postgame_arg == "true") if not _postgame_arg.is_empty() else TitleMeta.postgame_reached()
	var picture: Texture2D = KeyArt.texture(NIGHT_ID if _night else ART_ID)
	if picture == null:
		_build_town_backdrop()
	else:
		_build_art_backdrop(picture)


## Without the key art: the turning 3D town behind a dark band for the menu.
func _build_town_backdrop() -> void:
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
	add_child(margin)
	_menu_column = UIKit.vbox(16)
	if _art != null:
		# Over the key art: the wordmark carries the title, the menu stands on the calmer right side.
		margin.add_theme_constant_override("margin_right", 120)
		margin.add_theme_constant_override("margin_top", 400)
		margin.add_theme_constant_override("margin_bottom", 70)
		var row: HBoxContainer = UIKit.hbox(0)
		row.add_child(UIKit.filler())
		row.add_child(_menu_column)
		margin.add_child(row)
	else:
		margin.add_theme_constant_override("margin_left", 140)
		margin.add_theme_constant_override("margin_top", 120)
		margin.add_theme_constant_override("margin_bottom", 100)
		margin.add_child(_menu_column)
		var title: Label = UIKit.label(GAME_TITLE, &"TitleLabel", 104)
		_menu_column.add_child(title)
		var subtitle: Label = UIKit.label("A DECKBUILDER ROLE-PLAYING GAME", &"MutedLabel", 24)
		subtitle.add_theme_color_override("font_color", UIStyle.PARCHMENT)
		_menu_column.add_child(subtitle)
	var version_text: String = "v%s" % str(ProjectSettings.get_setting("application/config/version", "0.0.0"))
	var version: Label = UIKit.label(version_text, &"MutedLabel", 20)
	version.name = "VersionLabel"
	if _art == null:
		_menu_column.add_child(version)
	_menu_column.add_child(UIKit.spacer(40 if _art == null else 6))
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
	var footer: Label = UIKit.label("Press Esc in game for the pause menu." if _art == null else "%s   Press Esc in game for the pause menu." % version_text, &"MutedLabel", 18)
	if _art != null:
		footer.add_theme_color_override("font_color", Color(1, 1, 1, 0.75))
		footer.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
		footer.add_theme_constant_override("outline_size", 5)
	footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	footer.custom_minimum_size = Vector2(360, 0)
	_menu_column.add_child(footer)
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
	var dim: Control = UiSkin.menu_backdrop(Color(0.02, 0.01, 0.04, 0.7))
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


## The key art with its idle life: a slow drift and zoom, a warm light that breathes over the skyline, drifting motes, a dark fade on the right for the menu, the wordmark above.
func _build_art_backdrop(picture: Texture2D) -> void:
	var stage: Control = Control.new()
	stage.name = "TitleArt"
	UIKit.full_rect(stage)
	stage.clip_contents = true
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stage)
	_art = TextureRect.new()
	_art.name = "KeyArt"
	_art.texture = picture
	_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	UIKit.full_rect(_art)
	_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_art.scale = Vector2.ONE * ART_ZOOM
	stage.add_child(_art)
	stage.resized.connect(func() -> void: _art.pivot_offset = stage.size * 0.5)
	_art.pivot_offset = stage.size * 0.5
	# The light: a soft additive glow over the castle and the sky that slowly swells and fades (warmer and lower at sunrise).
	_glow = TextureRect.new()
	_glow.name = "LightShimmer"
	var radial: Gradient = Gradient.new()
	radial.colors = PackedColorArray([Color(1.0, 0.86, 0.55, 0.55), Color(1.0, 0.8, 0.5, 0.0)])
	var glow_texture: GradientTexture2D = GradientTexture2D.new()
	glow_texture.gradient = radial
	glow_texture.fill = GradientTexture2D.FILL_RADIAL
	glow_texture.fill_from = Vector2(0.5, 0.5)
	glow_texture.fill_to = Vector2(1.0, 0.5)
	glow_texture.width = 256
	glow_texture.height = 256
	_glow.texture = glow_texture
	_glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_glow.stretch_mode = TextureRect.STRETCH_SCALE
	_glow.anchor_left = 0.30
	_glow.anchor_right = 0.86
	_glow.anchor_top = -0.15
	_glow.anchor_bottom = 0.62
	_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var additive: CanvasItemMaterial = CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_glow.material = additive
	_glow.modulate.a = 0.35
	stage.add_child(_glow)
	var motes: TitleMotes = TitleMotes.new()
	motes.name = "Motes"
	motes.tint = Color(1.0, 0.78, 0.5) if _night else Color(1.0, 0.92, 0.65)
	UIKit.full_rect(motes)
	stage.add_child(motes)
	# A dark fade on the right keeps the menu readable over the busy art; a light vignette frames the whole picture.
	var side: TextureRect = TextureRect.new()
	var gradient: Gradient = Gradient.new()
	gradient.colors = PackedColorArray([Color(0.04, 0.02, 0.07, 0.0), Color(0.04, 0.02, 0.07, 0.78)])
	var side_texture: GradientTexture2D = GradientTexture2D.new()
	side_texture.gradient = gradient
	side_texture.width = 512
	side_texture.height = 4
	side_texture.fill_from = Vector2(0, 0)
	side_texture.fill_to = Vector2(1, 0)
	side.texture = side_texture
	side.stretch_mode = TextureRect.STRETCH_SCALE
	side.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	side.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	side.offset_left = -820
	side.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(side)
	stage.add_child(UIKit.vignette(0.35))
	_build_logo(stage)
	_start_idle_motion()


func _build_logo(stage: Control) -> void:
	var texture: Texture2D = KeyArt.texture(LOGO_ID)
	if texture == null:
		return
	_logo = TextureRect.new()
	_logo.name = "Wordmark"
	_logo.texture = texture
	_logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var height: float = LOGO_WIDTH * float(texture.get_height()) / float(texture.get_width())
	_logo.anchor_left = 0.5
	_logo.anchor_right = 0.5
	_logo.offset_left = -LOGO_WIDTH * 0.5
	_logo.offset_right = LOGO_WIDTH * 0.5
	_logo.offset_top = 6
	_logo.offset_bottom = 6 + height
	stage.add_child(_logo)
	_logo.modulate.a = 0.0
	_logo.pivot_offset = Vector2(LOGO_WIDTH * 0.5, height * 0.4)
	_logo.scale = Vector2(0.94, 0.94)
	var intro: Tween = create_tween().set_parallel(true)
	intro.tween_property(_logo, "modulate:a", 1.0, 1.2).set_delay(0.2)
	intro.tween_property(_logo, "scale", Vector2.ONE, 1.4).set_delay(0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


## The idle motion: the picture glides sideways and slowly zooms (about 25 seconds a leg), the light breathes. Both loop forever and stay subtle.
func _start_idle_motion() -> void:
	var drift: Tween = create_tween().set_loops()
	drift.tween_property(_art, "position:x", -DRIFT_PIXELS, 24.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	drift.tween_property(_art, "position:x", DRIFT_PIXELS, 24.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var zoom: Tween = create_tween().set_loops()
	zoom.tween_property(_art, "scale", Vector2.ONE * (ART_ZOOM + 0.025), 20.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	zoom.tween_property(_art, "scale", Vector2.ONE * ART_ZOOM, 20.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var shimmer: Tween = create_tween().set_loops()
	shimmer.tween_property(_glow, "modulate:a", 0.62 if _night else 0.5, 3.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	shimmer.tween_property(_glow, "modulate:a", 0.18, 4.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
