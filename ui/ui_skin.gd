class_name UiSkin
extends RefCounted
## The UI art kit applied to the game theme (docs/art/ui_art_kit.md). `apply()` runs once at start (SceneManager): it replaces the project theme's panel and button styles
## with the 9-slice art (corners never stretch: each style's margins are measured on its image) and sets the mouse cursors. Anything whose image is missing keeps the
## flat look from `UIStyle.theme()`. Theme variations: "PrimaryButton", "DangerButton" (secondary art, tinted red), "Button" (secondary art); panels "PanelContainer"
## (main panel, dark parchment), "RewardPanel", "TooltipPanel", "HudChip" and "DialoguePanel".

## 9-slice margins (left, top, right, bottom) as fractions of each stored image, and the factor each is drawn at.
const MAIN_MARGIN: Vector4 = Vector4(0.17, 0.18, 0.17, 0.18)
const MAIN_FACTOR: float = 0.33
const POPUP_MARGIN: Vector4 = Vector4(0.17, 0.27, 0.17, 0.19)
const POPUP_FACTOR: float = 0.42
const TOOLTIP_MARGIN: Vector4 = Vector4(0.18, 0.28, 0.18, 0.28)
const TOOLTIP_FACTOR: float = 0.35
const CHIP_MARGIN: Vector4 = Vector4(0.1, 0.36, 0.1, 0.36)
const CHIP_FACTOR: float = 0.3
const DIALOGUE_MARGIN: Vector4 = Vector4(0.34, 0.3, 0.08, 0.12)
const DIALOGUE_FACTOR: float = 0.62
const BUTTON_MARGIN: Vector4 = Vector4(0.15, 0.4, 0.15, 0.4)
const PRIMARY_FACTOR: float = 0.23
const SECONDARY_FACTOR: float = 0.25
## Hover is a little brighter, pressed a little darker, disabled desaturated.
const HOVER_TINT: Color = Color(1.18, 1.16, 1.12)
const PRESSED_TINT: Color = Color(0.8, 0.78, 0.76)
const DISABLED_TINT: Color = Color(0.7, 0.7, 0.7, 0.9)
const CURSOR_HEIGHT: float = 44.0

static var _targeting: bool = false


static func apply() -> void:
	var theme: Theme = ThemeDB.get_project_theme()
	if theme == null:
		theme = UIStyle.theme()
	_apply_panels(theme)
	# Titles read over the painted backgrounds: a dark outline.
	theme.set_color("font_outline_color", "TitleLabel", Color(0.06, 0.03, 0.08, 0.92))
	theme.set_constant("outline_size", "TitleLabel", 9)
	theme.set_color("font_outline_color", "HeadingLabel", Color(0.06, 0.03, 0.08, 0.8))
	theme.set_constant("outline_size", "HeadingLabel", 4)
	_apply_buttons(theme)
	apply_cursors()


# ---- Panels ---------------------------------------------------------------------------------


static func main_panel() -> StyleBoxTexture:
	return UiArt.nine("UI-PANEL-MAIN-DARK", MAIN_MARGIN, MAIN_FACTOR, Vector4(34, 28, 34, 28))


static func popup_panel() -> StyleBoxTexture:
	return UiArt.nine("UI-PANEL-POPUP-DARK", POPUP_MARGIN, POPUP_FACTOR, Vector4(60, 40, 60, 70))


static func tooltip_panel() -> StyleBoxTexture:
	return UiArt.nine("UI-PANEL-TOOLTIP", TOOLTIP_MARGIN, TOOLTIP_FACTOR, Vector4(24, 18, 24, 18))


static func hud_chip() -> StyleBoxTexture:
	return UiArt.nine("UI-PANEL-HUD", CHIP_MARGIN, CHIP_FACTOR, Vector4(24, 10, 24, 10))


static func dialogue_panel() -> StyleBoxTexture:
	return UiArt.nine("UI-PANEL-DIALOGUE", DIALOGUE_MARGIN, DIALOGUE_FACTOR, Vector4(44, 66, 44, 26))


## ProgressBar skins: the bar frame is the background (its transparent channel is the content area the game fill is drawn in).
## UI-BAR-HP: channel x 0.161-0.916, y 0.388-0.699 of the image; UI-BAR-XP: x 0.195-0.935, y 0.386-0.651.
const HP_BAR_CHANNEL: Vector4 = Vector4(0.161, 0.388, 0.084, 0.301)
const XP_BAR_CHANNEL: Vector4 = Vector4(0.195, 0.386, 0.065, 0.349)


## The frame of a bar as a background style for a bar `height` pixels tall: caps keep their shape, only the middle stretches. null when the art is missing.
static func bar_frame(id: String, channel: Vector4, height: float) -> StyleBoxTexture:
	var source: Texture2D = UiArt.texture(id)
	if source == null:
		return null
	var factor: float = height / float(source.get_height())
	var width: float = float(source.get_width()) * factor
	var style: StyleBoxTexture = UiArt.nine(id, Vector4(channel.x, 0.0, channel.z, 0.0), factor, Vector4(round(channel.x * width), round(channel.y * height), round(channel.z * width), round(channel.w * height)))
	return style


## Sets the fill colour of a bar: an art bar redraws, a plain ProgressBar gets the flat fill style as before.
static func set_bar_fill(bar: ProgressBar, color: Color) -> void:
	if bar is ArtBar:
		(bar as ArtBar).set_fill_color(color)
	else:
		bar.add_theme_stylebox_override("fill", UIStyle.box(color, Color(0, 0, 0, 0), 0, 8))


## Applies the HP or XP frame to a ProgressBar of height `height` (fill = the flat style the game already sets or this red/gold default).
static func skin_bar(bar: ProgressBar, kind: String, height: float, fill_color: Color) -> void:
	var id: String = "UI-BAR-HP" if kind == "hp" else "UI-BAR-XP"
	var frame: StyleBoxTexture = bar_frame(id, HP_BAR_CHANNEL if kind == "hp" else XP_BAR_CHANNEL, height)
	if frame == null:
		return
	bar.custom_minimum_size = Vector2(bar.custom_minimum_size.x, height)
	bar.set_script(ArtBar)
	(bar as ArtBar).setup(frame, fill_color)


static func _apply_panels(theme: Theme) -> void:
	var main: StyleBoxTexture = main_panel()
	if main != null:
		theme.set_stylebox("panel", "PanelContainer", main)
	theme.set_type_variation("RewardPanel", "PanelContainer")
	var popup: StyleBoxTexture = popup_panel()
	if popup != null:
		theme.set_stylebox("panel", "RewardPanel", popup)
	var tip: StyleBoxTexture = tooltip_panel()
	if tip != null:
		theme.set_stylebox("panel", "TooltipPanel", tip)
	theme.set_type_variation("HudChip", "PanelContainer")
	var chip: StyleBoxTexture = hud_chip()
	if chip != null:
		theme.set_stylebox("panel", "HudChip", chip)
		# The dark HUD boxes and inner sections of screens use the same dark wood chip.
		theme.set_stylebox("panel", "DarkPanel", chip)
	theme.set_type_variation("DialoguePanel", "PanelContainer")
	var dialogue: StyleBoxTexture = dialogue_panel()
	if dialogue != null:
		theme.set_stylebox("panel", "DialoguePanel", dialogue)


# ---- Buttons --------------------------------------------------------------------------------


## The four button styles of one art image: normal, hover (brighter), pressed (darker) and disabled (desaturated). `tint` recolours the whole button (danger = red).
static func button_styles(id: String, factor: float, tint: Color = Color.WHITE) -> Dictionary:
	var content: Vector4 = Vector4(36, 8, 36, 10)
	var styles: Dictionary = {}
	styles["normal"] = UiArt.nine(id, BUTTON_MARGIN, factor, content, tint)
	if styles["normal"] == null:
		return {}
	styles["hover"] = UiArt.nine(id, BUTTON_MARGIN, factor, content, Color(tint.r * HOVER_TINT.r, tint.g * HOVER_TINT.g, tint.b * HOVER_TINT.b))
	styles["pressed"] = UiArt.nine(id, BUTTON_MARGIN, factor, content + Vector4(0, 2, 0, -2), Color(tint.r * PRESSED_TINT.r, tint.g * PRESSED_TINT.g, tint.b * PRESSED_TINT.b))
	styles["disabled"] = UiArt.nine(id, BUTTON_MARGIN, factor, content, DISABLED_TINT, 0.85)
	return styles


static func _apply_buttons(theme: Theme) -> void:
	_set_button(theme, "Button", button_styles("UI-BTN-SECONDARY", SECONDARY_FACTOR))
	_set_button(theme, "PrimaryButton", button_styles("UI-BTN-PRIMARY", PRIMARY_FACTOR))
	_set_button(theme, "DangerButton", button_styles("UI-BTN-SECONDARY", SECONDARY_FACTOR, Color(1.45, 0.62, 0.6)))


static func _set_button(theme: Theme, type_name: String, styles: Dictionary) -> void:
	if styles.is_empty():
		return
	for state: String in ["normal", "hover", "pressed", "disabled"]:
		theme.set_stylebox(state, type_name, styles[state] as StyleBox)
	theme.set_stylebox("hover_pressed", type_name, styles["pressed"] as StyleBox)
	theme.set_color("font_disabled_color", type_name, Color(1, 1, 1, 0.45))


## A round close button (UI-BTN-CLOSE) that scales and brightens on hover; `tip` is the tooltip (for example "Close (Esc)").
static func close_button(tip: String, size_px: float = 54.0) -> FancyButton:
	var button: FancyButton = FancyButton.new()
	button.tooltip_text = tip
	button.custom_minimum_size = Vector2(size_px, size_px)
	var art: Texture2D = UiArt.texture("UI-BTN-CLOSE")
	if art == null:
		button.text = "X"
		return button
	var empty: StyleBoxEmpty = StyleBoxEmpty.new()
	for state: String in ["normal", "hover", "pressed", "disabled", "focus", "hover_pressed"]:
		button.add_theme_stylebox_override(state, empty)
	button.icon = art
	button.expand_icon = true
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	button.add_theme_constant_override("icon_max_width", int(size_px))
	button.add_theme_color_override("icon_hover_color", Color(1.2, 1.15, 1.1))
	button.add_theme_color_override("icon_pressed_color", Color(0.8, 0.78, 0.76))
	button.add_theme_color_override("icon_hover_pressed_color", Color(0.8, 0.78, 0.76))
	return button


## A full-screen background image (cover-fitted, with a dim layer so the UI stays readable on top); null when there is no id or no image.
static func screen_background(id: String, dim: float = 0.3) -> Control:
	var art: Texture2D = UiArt.texture(id) if id != "" else null
	if art == null:
		return null
	var holder: Control = Control.new()
	UIKit.full_rect(holder)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.name = "ScreenBackground"
	var picture: TextureRect = TextureRect.new()
	picture.texture = art
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	UIKit.full_rect(picture)
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(picture)
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.03, 0.02, 0.06, dim)
	UIKit.full_rect(shade)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(shade)
	return holder


## A round art button (UI-BTN-ENDTURN, the gong with a plain amber centre) of `px` pixels with its label drawn over the centre. Hover is brighter, pressed darker, disabled
## desaturated; FancyButton adds the small scale-up and scale-down.
static func round_button(id: String, px: float, text: String) -> FancyButton:
	var button: FancyButton = FancyButton.make(text)
	button.custom_minimum_size = Vector2(px, px)
	button.size = Vector2(px, px)
	var source: Texture2D = UiArt.texture(id)
	if source == null:
		return button
	var factor: float = px / float(source.get_width())
	var plain: StyleBoxTexture = UiArt.nine(id, Vector4.ZERO, factor, Vector4(6, 6, 6, 10))
	var hover: StyleBoxTexture = UiArt.nine(id, Vector4.ZERO, factor, Vector4(6, 6, 6, 10), HOVER_TINT)
	var pressed: StyleBoxTexture = UiArt.nine(id, Vector4.ZERO, factor, Vector4(6, 8, 6, 8), PRESSED_TINT)
	var disabled: StyleBoxTexture = UiArt.nine(id, Vector4.ZERO, factor, Vector4(6, 6, 6, 10), DISABLED_TINT, 0.85)
	button.add_theme_stylebox_override("normal", plain)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("hover_pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_font_size_override("font_size", int(px * 0.2))
	button.add_theme_font_override("font", UIStyle.font_title())
	for state: String in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		button.add_theme_color_override(state, Color("2b1608"))
	button.add_theme_color_override("font_disabled_color", Color(0.25, 0.2, 0.15, 0.7))
	button.add_theme_constant_override("line_spacing", -4)
	return button


## `id` turned a quarter turn counter-clockwise and scaled to `size_px` (the vertical resource tray lying on its side along the right edge of the battle screen).
static func rotated_texture(id: String, size_px: Vector2) -> Texture2D:
	var key: String = "rot|%s|%.0fx%.0f" % [id, size_px.x, size_px.y]
	if UiArt._textures.has(key):
		return UiArt._textures[key] as Texture2D
	var source: Texture2D = UiArt.texture(id)
	if source == null:
		return null
	var image: Image = source.get_image()
	if image.is_compressed():
		image.decompress()
	image.convert(Image.FORMAT_RGBA8)
	image.rotate_90(COUNTERCLOCKWISE)
	image.fix_alpha_edges()
	image.resize(int(size_px.x), int(size_px.y), Image.INTERPOLATE_LANCZOS)
	var result: ImageTexture = ImageTexture.create_from_image(image)
	UiArt._textures[key] = result
	return result


# ---- Equipment slots ------------------------------------------------------------------------


## The equipment slot art (UI-SLOT-EQUIP) at `px` pixels square. "locked" is the image as drawn (its padlock is part of the art), "empty" has the padlock painted over with
## the slot's own dark interior, so an unlocked slot reads as empty; "hover" is the empty slot brighter. Null when the art is missing.
static func equip_slot_style(kind: String, px: float) -> StyleBoxTexture:
	var base: Texture2D = UiArt.texture("UI-SLOT-EQUIP")
	if base == null:
		return null
	var factor: float = px / float(base.get_width())
	var scaled: Texture2D = UiArt.scaled_texture("UI-SLOT-EQUIP", factor)
	var style: StyleBoxTexture = StyleBoxTexture.new()
	style.texture = scaled if kind == "locked" else _slot_without_lock(scaled, px)
	if kind == "hover":
		style.modulate_color = HOVER_TINT
	return style


static func _slot_without_lock(scaled: Texture2D, px: float) -> Texture2D:
	var key: String = "slot-empty|%.0f" % px
	if UiArt._textures.has(key):
		return UiArt._textures[key] as Texture2D
	var image: Image = scaled.get_image()
	var w: int = image.get_width()
	var h: int = image.get_height()
	var interior: Color = image.get_pixel(int(w * 0.18), int(h * 0.5))
	var left: float = w * 0.2
	var right: float = w * 0.8
	var top: float = h * 0.17
	var bottom: float = h * 0.83
	var feather: float = maxf(2.0, w * 0.05)
	for y: int in range(int(top - feather), int(bottom + feather)):
		for x: int in range(int(left - feather), int(right + feather)):
			var edge: float = minf(minf(float(x) - (left - feather), (right + feather) - float(x)), minf(float(y) - (top - feather), (bottom + feather) - float(y)))
			var weight: float = clampf(edge / feather, 0.0, 1.0)
			var pixel: Color = image.get_pixel(x, y)
			image.set_pixel(x, y, pixel.lerp(Color(interior.r, interior.g, interior.b, pixel.a), weight))
	var result: ImageTexture = ImageTexture.create_from_image(image)
	UiArt._textures[key] = result
	return result


## The backdrop of the pause menu, settings and save/load screens: UI-BG-MENU, or a flat dim of `fallback` when the image is missing.
static func menu_backdrop(fallback: Color) -> Control:
	var art: Control = screen_background("UI-BG-MENU", 0.0)
	if art != null:
		return art
	var dim: ColorRect = ColorRect.new()
	dim.color = fallback
	UIKit.full_rect(dim)
	return dim

# ---- Cursors --------------------------------------------------------------------------------


## The default cursor (UI-CURSOR, hotspot at the tip) or, while choosing a target, the targeting reticle (UI-CURSOR-TARGET, hotspot at its centre).
static func apply_cursors() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var shape_id: String = "UI-CURSOR-TARGET" if _targeting else "UI-CURSOR"
	var source: Texture2D = UiArt.texture(shape_id)
	if source == null:
		return
	var image: Image = source.get_image()
	if image.is_compressed():
		image.decompress()
	var factor: float = CURSOR_HEIGHT / float(image.get_height())
	image.resize(maxi(8, int(round(image.get_width() * factor))), int(CURSOR_HEIGHT), Image.INTERPOLATE_LANCZOS)
	var cursor: ImageTexture = ImageTexture.create_from_image(image)
	var hotspot: Vector2 = Vector2(image.get_size()) * 0.5 if _targeting else Vector2(2, 2)
	for shape: Input.CursorShape in [Input.CURSOR_ARROW, Input.CURSOR_POINTING_HAND]:
		Input.set_custom_mouse_cursor(cursor, shape, hotspot)


## Battle target choice on/off.
static func set_targeting(on: bool) -> void:
	if _targeting == on:
		return
	_targeting = on
	apply_cursors()
