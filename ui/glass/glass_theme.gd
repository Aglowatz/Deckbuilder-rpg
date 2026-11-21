class_name GlassTheme
extends RefCounted
## Fable Nov 20 day (Part 2): the ONE look of every information screen - "Stained glass" (docs/art/ui_style_guide.md, direction B).
## A deep night-blue glass page in a leaded gold frame, a strip of coloured Path panes along its top, panes of glass that light up
## when chosen or focused, pale lettering.
##
## One place: `GlassTheme.theme()` is a Godot Theme built once from the Batch 18 pieces (UI-INFO-PAGE, UI-GLASS-PANE and -LIT,
## UI-BTN-AMBER, UI-BTN-GLASS, UI-INFO-TOOLTIP, UI-QUESTBOX, UI-SCROLL-RAIL and -GRIP, ...). A screen takes the look with
## `GlassTheme.apply(root)`; everything under that node reads the theme, so the type names the screens already use ("PrimaryButton",
## "HeadingLabel", "MutedLabel", "DarkPanel" ...) mean their glass version there. The 9-slice margins, the colours and the sizes
## below are the only copy. Path colours come from core/data/path_palette.json (PathPalette).
##
## The rules (the style guide):
## - colour means a Path wherever a Path is meant, with the Path's icon beside it; a pane that stands for no Path is SLATE;
## - one amber button per screen ("PrimaryButton"): the action you most likely want;
## - no pale grey text: secondary lines are SECONDARY, a lighter tint of the page; unknown steps are italic, not dim;
## - lit glass means chosen or focused (mouse hover and controller focus alike);
## - glow is held back: only the lit pane itself is bright.

# ---- Colours ------------------------------------------------------------------------------------------------------------------------

## The page's glass (the middle of UI-INFO-PAGE), for contrast sums and flat fills that must match it.
const PAGE: Color = Color("221e42")
## A darker pane inside the page: a row, a text field, a slider's groove.
const PAGE_DEEP: Color = Color("161330")
## Body text. 13.4:1 on PAGE.
const TEXT: Color = Color("f2ecdd")
## Secondary lines (a hint, a counter, a step done): a lighter tint of the page, never grey. 8.5:1 on PAGE.
const SECONDARY: Color = Color("bdb9ec")
## Titles and headings (the gold of the frame). 10.6:1 on PAGE.
const TITLE: Color = Color("f4ce78")
## Text on a lit pane or on the amber button.
const INK: Color = Color("17132b")
const AMBER_INK: Color = Color("2b1a00")
## The glass of a pane that stands for no Path. The neutral grey art is multiplied by these.
const SLATE: Color = Color("66739c")
const SLATE_LIT: Color = Color("c9d6ff")
## A row plate at rest: glass barely lighter than the page.
const ROW: Color = Color("3a3f6b")
## A warning that is not a Path's red pane: the label takes this colour on slate glass (Quit Game, Delete).
const CAUTION: Color = Color("ffb4a6")
const GOOD: Color = Color("9be3a8")
const GOLD_LINE: Color = Color("d9a94a")

# ---- The pieces and their 9-slice margins (fractions of the stored image: left, top, right, bottom) ------------------------------------

const PAGE_ART: String = "UI-INFO-PAGE"
const PAGE_MARGIN: Vector4 = Vector4(0.04, 0.062, 0.04, 0.062)
const PAGE_FACTOR: float = 1.0
const PAGE_CONTENT: Vector4 = Vector4(40, 34, 40, 34)
const POPUP_ART: String = "UI-INFO-TOOLTIP"
const POPUP_MARGIN: Vector4 = Vector4(0.06, 0.12, 0.06, 0.12)
const POPUP_FACTOR: float = 1.0
const TOOLTIP_FACTOR: float = 0.7
const QUESTBOX_ART: String = "UI-QUESTBOX"
const QUESTBOX_MARGIN: Vector4 = Vector4(0.085, 0.13, 0.085, 0.13)
const QUESTBOX_FACTOR: float = 0.55
const PANE_ART: String = "UI-GLASS-PANE"
const PANE_LIT_ART: String = "UI-GLASS-PANE-LIT"
const PANE_MARGIN: Vector4 = Vector4(0.08, 0.26, 0.08, 0.26)
const PANE_FACTOR: float = 0.42
const BUTTON_ART: String = "UI-BTN-GLASS"
const AMBER_ART: String = "UI-BTN-AMBER"
const BUTTON_MARGIN: Vector4 = Vector4(0.14, 0.46, 0.14, 0.46)
const BUTTON_FACTOR: float = 0.235
const DIVIDER_ART: String = "UI-INFO-DIVIDER"
const STRIP_ART: String = "UI-GLASS-STRIP"
const STRIP_HEIGHT: float = 22.0
const ROSE_ART: String = "UI-ROSE-WINDOW"
const MARKS_ART: String = "UI-QUEST-MARKS"
const MAP_FRAME_ART: String = "UI-MAP-FRAME"
const MAP_FRAME_MARGIN: Vector4 = Vector4(0.1, 0.17, 0.1, 0.17)
const RAIL_ART: String = "UI-SCROLL-RAIL"
const GRIP_ART: String = "UI-SCROLL-GRIP"
const SCROLL_WIDTH: float = 18.0

## The quest step marks on UI-QUEST-MARKS, left to right.
enum Mark { OPEN, DONE, NEXT }

static var _theme: Theme = null
## The menu text factor the theme's font sizes were built at (MenuText, Fable Nov 21 review).
static var _theme_scale: float = 1.0
static var _cache: Dictionary = {}


## True when the glass set is in the game (a build without the art keeps the old look).
static func available() -> bool:
	return UiArt.has(PAGE_ART) and UiArt.has(PANE_ART) and UiArt.has(BUTTON_ART)


## Gives `root` and everything under it the stained-glass look.
static func apply(root: Control) -> void:
	if root != null and available():
		root.theme = theme()
		MenuText.follow(root)  # Fable Nov 21 review: the Text size setting reaches every glass screen


static func reset() -> void:
	_theme = null
	_cache.clear()


# ---- Style boxes --------------------------------------------------------------------------------------------------------------------


static func page_box() -> StyleBoxTexture:
	return UiArt.nine(PAGE_ART, PAGE_MARGIN, PAGE_FACTOR, PAGE_CONTENT)


## The small dark panel of a pop-up (a confirmation, a notice, a reward box).
static func popup_box() -> StyleBoxTexture:
	return UiArt.nine(POPUP_ART, POPUP_MARGIN, POPUP_FACTOR, Vector4(34, 28, 34, 28))


static func tooltip_box() -> StyleBoxTexture:
	return UiArt.nine(POPUP_ART, POPUP_MARGIN, TOOLTIP_FACTOR, Vector4(20, 16, 20, 16))


static func questbox_box() -> StyleBoxTexture:
	return UiArt.nine(QUESTBOX_ART, QUESTBOX_MARGIN, QUESTBOX_FACTOR, Vector4(22, 20, 22, 18))


## A pane of glass tinted `glass` (the art is neutral grey): dull at rest, lit from behind when `lit`. `content`: padding in pixels.
static func pane(glass: Color = SLATE, lit: bool = false, content: Vector4 = Vector4(16, 8, 16, 8), factor: float = PANE_FACTOR) -> StyleBoxTexture:
	var box: StyleBoxTexture = UiArt.nine(PANE_LIT_ART if lit else PANE_ART, PANE_MARGIN, factor, content, glass)
	return box


## A Path's colour as LIT glass: a step brighter than the Path's own colour, so dark ink reads on it (4.5:1 or better for all four).
static func lit(path_colour: Color) -> Color:
	return path_colour.lightened(0.25)


## A plate behind a row of a list or a setting: glass a shade lighter than the page.
static func row_box(lit: bool = false, glass: Color = ROW) -> StyleBoxTexture:
	return pane(glass if not lit else glass.lightened(0.45), lit, Vector4(18, 8, 18, 8))


static func _button(art: String, glass: Color, content: Vector4 = Vector4(34, 8, 34, 10)) -> StyleBoxTexture:
	return UiArt.nine(art, BUTTON_MARGIN, BUTTON_FACTOR, content, glass)


## The four states of a glass button of colour `glass`: at rest, lit (hover and focus), pressed, disabled.
static func button_boxes(glass: Color = SLATE, art: String = BUTTON_ART) -> Dictionary:
	var lit: Color = Color(minf(glass.r * 1.3 + 0.06, 1.4), minf(glass.g * 1.3 + 0.06, 1.4), minf(glass.b * 1.3 + 0.06, 1.4))
	var boxes: Dictionary = {}
	boxes["normal"] = _button(art, glass)
	boxes["hover"] = _button(art, lit)
	boxes["pressed"] = _button(art, glass.darkened(0.22), Vector4(34, 10, 34, 8))
	var off: StyleBoxTexture = UiArt.nine(art, BUTTON_MARGIN, BUTTON_FACTOR, Vector4(34, 8, 34, 10), Color(glass.r * 0.6, glass.g * 0.6, glass.b * 0.6, 0.75), 0.8)
	boxes["disabled"] = off
	return boxes


## The gold ring of the keyboard / controller focus, round any glass piece.
static func focus_ring(radius: int = 16) -> StyleBoxFlat:
	var ring: StyleBoxFlat = StyleBoxFlat.new()
	ring.draw_center = false
	ring.border_color = Color("ffe9a8")
	ring.set_border_width_all(3)
	ring.set_corner_radius_all(radius)
	ring.set_expand_margin_all(3.0)
	return ring


# ---- The theme ----------------------------------------------------------------------------------------------------------------------


static func theme() -> Theme:
	if _theme != null and is_equal_approx(_theme_scale, MenuText.scale()):
		return _theme
	_theme_scale = MenuText.scale()
	var t: Theme = Theme.new()
	t.default_font = UIStyle.font_body()
	t.default_font_size = MenuText.size(22)
	_labels(t)
	_panels(t)
	_buttons(t)
	_fields(t)
	_scrollbars(t)
	t.set_constant("separation", "VBoxContainer", 10)
	t.set_constant("separation", "HBoxContainer", 10)
	_theme = t
	return t


static func _labels(t: Theme) -> void:
	t.set_color("font_color", "Label", TEXT)
	t.set_color("font_shadow_color", "Label", Color(0, 0, 0, 0.55))
	t.set_constant("shadow_offset_x", "Label", 0)
	t.set_constant("shadow_offset_y", "Label", 1)
	t.set_font("font", "Label", UIStyle.font_body())
	t.set_type_variation("TitleLabel", "Label")
	t.set_font("font", "TitleLabel", UIStyle.font_title())
	t.set_font_size("font_size", "TitleLabel", MenuText.size(40))
	t.set_color("font_color", "TitleLabel", TITLE)
	t.set_type_variation("HeadingLabel", "Label")
	t.set_font("font", "HeadingLabel", UIStyle.font_title())
	t.set_font_size("font_size", "HeadingLabel", MenuText.size(28))
	t.set_color("font_color", "HeadingLabel", TITLE)
	t.set_color("font_outline_color", "HeadingLabel", Color(0.04, 0.03, 0.1, 0.8))
	t.set_constant("outline_size", "HeadingLabel", 3)
	t.set_type_variation("MutedLabel", "Label")
	t.set_color("font_color", "MutedLabel", SECONDARY)
	t.set_type_variation("GlassInk", "Label")
	t.set_color("font_color", "GlassInk", INK)
	t.set_color("font_shadow_color", "GlassInk", Color(1, 1, 1, 0.25))
	t.set_color("default_color", "RichTextLabel", TEXT)
	t.set_font("normal_font", "RichTextLabel", UIStyle.font_body())
	t.set_font("bold_font", "RichTextLabel", UIStyle.font_bold())
	t.set_font("italics_font", "RichTextLabel", UIStyle.font_italic())
	t.set_font("bold_italics_font", "RichTextLabel", UIStyle.font_bold_italic())
	for key: String in ["normal_font_size", "bold_font_size", "italics_font_size", "bold_italics_font_size"]:
		t.set_font_size(key, "RichTextLabel", MenuText.size(22))
	t.set_color("font_color", "TooltipLabel", TEXT)
	t.set_font_size("font_size", "TooltipLabel", MenuText.size(20))


static func _panels(t: Theme) -> void:
	var page: StyleBoxTexture = page_box()
	t.set_stylebox("panel", "PanelContainer", page)
	t.set_stylebox("panel", "Panel", page)
	# A section inside a page: no second frame, just its padding.
	t.set_type_variation("DarkPanel", "PanelContainer")
	var inner: StyleBoxEmpty = StyleBoxEmpty.new()
	inner.set_content_margin_all(4)
	t.set_stylebox("panel", "DarkPanel", inner)
	t.set_type_variation("GlassPage", "PanelContainer")
	t.set_stylebox("panel", "GlassPage", page)
	t.set_type_variation("GlassPopup", "PanelContainer")
	t.set_stylebox("panel", "GlassPopup", popup_box())
	t.set_type_variation("RewardPanel", "PanelContainer")
	t.set_stylebox("panel", "RewardPanel", popup_box())
	t.set_type_variation("GlassTooltip", "PanelContainer")
	t.set_stylebox("panel", "GlassTooltip", tooltip_box())
	t.set_stylebox("panel", "TooltipPanel", tooltip_box())
	t.set_type_variation("GlassQuestBox", "PanelContainer")
	t.set_stylebox("panel", "GlassQuestBox", questbox_box())
	t.set_type_variation("GlassRow", "PanelContainer")
	t.set_stylebox("panel", "GlassRow", row_box())
	t.set_type_variation("GlassRowLit", "PanelContainer")
	t.set_stylebox("panel", "GlassRowLit", row_box(true))
	t.set_type_variation("HudChip", "PanelContainer")
	t.set_stylebox("panel", "HudChip", row_box())


static func _set_button(t: Theme, type_name: String, boxes: Dictionary, font: Color, font_lit: Color) -> void:
	for state: String in ["normal", "hover", "pressed", "disabled"]:
		t.set_stylebox(state, type_name, boxes[state] as StyleBox)
	t.set_stylebox("hover_pressed", type_name, boxes["pressed"] as StyleBox)
	t.set_stylebox("focus", type_name, focus_ring(26))
	t.set_color("font_color", type_name, font)
	t.set_color("font_hover_color", type_name, font_lit)
	t.set_color("font_focus_color", type_name, font_lit)
	t.set_color("font_pressed_color", type_name, font)
	t.set_color("font_hover_pressed_color", type_name, font)
	t.set_color("font_disabled_color", type_name, Color(TEXT.r, TEXT.g, TEXT.b, 0.5))
	t.set_color("font_outline_color", type_name, Color(0.04, 0.03, 0.1, 0.55))
	t.set_constant("outline_size", type_name, 2)


static func _buttons(t: Theme) -> void:
	t.set_font("font", "Button", UIStyle.font_bold())
	t.set_font_size("font_size", "Button", MenuText.size(24))
	_set_button(t, "Button", button_boxes(SLATE), TEXT, Color.WHITE)
	t.set_type_variation("PrimaryButton", "Button")
	_set_button(t, "PrimaryButton", button_boxes(Color.WHITE, AMBER_ART), AMBER_INK, AMBER_INK)
	t.set_color("font_outline_color", "PrimaryButton", Color(1.0, 0.95, 0.75, 0.5))
	t.set_color("font_disabled_color", "PrimaryButton", Color(AMBER_INK.r, AMBER_INK.g, AMBER_INK.b, 0.55))
	# A dangerous choice is slate glass with a warm label: a red pane would say "Beefcake".
	t.set_type_variation("DangerButton", "Button")
	_set_button(t, "DangerButton", button_boxes(SLATE.darkened(0.12)), CAUTION, Color("ffd2c8"))
	# Tabs and other toggles: a dull pane at rest, a lit pane when chosen (dark ink on the bright glass).
	t.set_type_variation("GhostButton", "Button")
	var tab_rest: StyleBoxTexture = pane(SLATE, false, Vector4(18, 8, 18, 8))
	var tab_hover: StyleBoxTexture = pane(SLATE.lightened(0.25), false, Vector4(18, 8, 18, 8))
	var tab_lit: StyleBoxTexture = pane(SLATE_LIT, true, Vector4(18, 8, 18, 8))
	t.set_stylebox("normal", "GhostButton", tab_rest)
	t.set_stylebox("hover", "GhostButton", tab_hover)
	t.set_stylebox("pressed", "GhostButton", tab_lit)
	t.set_stylebox("hover_pressed", "GhostButton", tab_lit)
	t.set_stylebox("disabled", "GhostButton", pane(SLATE.darkened(0.4), false, Vector4(18, 8, 18, 8)))
	t.set_stylebox("focus", "GhostButton", focus_ring(12))
	t.set_color("font_color", "GhostButton", TEXT)
	t.set_color("font_hover_color", "GhostButton", Color.WHITE)
	t.set_color("font_focus_color", "GhostButton", Color.WHITE)
	t.set_color("font_pressed_color", "GhostButton", INK)
	t.set_color("font_hover_pressed_color", "GhostButton", INK)
	t.set_color("font_disabled_color", "GhostButton", Color(TEXT.r, TEXT.g, TEXT.b, 0.5))
	t.set_constant("outline_size", "GhostButton", 0)
	t.set_type_variation("GlassTab", "GhostButton")
	# A choice list (OptionButton): a pane with its arrow; lit while hovered, focused or open.
	var option_rest: StyleBoxTexture = pane(SLATE.darkened(0.25), false, Vector4(18, 6, 14, 6))
	var option_lit: StyleBoxTexture = pane(SLATE.lightened(0.2), false, Vector4(18, 6, 14, 6))
	t.set_stylebox("normal", "OptionButton", option_rest)
	t.set_stylebox("hover", "OptionButton", option_lit)
	t.set_stylebox("pressed", "OptionButton", option_lit)
	t.set_stylebox("hover_pressed", "OptionButton", option_lit)
	t.set_stylebox("disabled", "OptionButton", pane(SLATE.darkened(0.5), false, Vector4(18, 6, 14, 6)))
	t.set_stylebox("focus", "OptionButton", focus_ring(12))
	t.set_font("font", "OptionButton", UIStyle.font_bold())
	t.set_font_size("font_size", "OptionButton", MenuText.size(21))
	for key: String in ["font_color", "font_pressed_color"]:
		t.set_color(key, "OptionButton", TEXT)
	for key: String in ["font_hover_color", "font_focus_color", "font_hover_pressed_color"]:
		t.set_color(key, "OptionButton", Color.WHITE)
	t.set_color("font_disabled_color", "OptionButton", Color(TEXT.r, TEXT.g, TEXT.b, 0.5))
	t.set_constant("outline_size", "OptionButton", 0)
	# The list an OptionButton opens.
	var menu: StyleBoxFlat = UIStyle.box(PAGE_DEEP, GOLD_LINE, 2, 8, 10)
	menu.set_content_margin_all(8)
	t.set_stylebox("panel", "PopupMenu", menu)
	t.set_stylebox("hover", "PopupMenu", UIStyle.box(SLATE.lightened(0.1), Color(0, 0, 0, 0), 0, 6))
	t.set_color("font_color", "PopupMenu", TEXT)
	t.set_color("font_hover_color", "PopupMenu", Color.WHITE)
	t.set_font("font", "PopupMenu", UIStyle.font_bold())
	t.set_font_size("font_size", "PopupMenu", MenuText.size(20))
	t.set_constant("v_separation", "PopupMenu", 8)


## A switch drawn as a small pane: dark with the knob left when off, lit glass with the knob right when on.
static func switch_icon(on: bool, disabled: bool = false) -> ImageTexture:
	var key: String = "switch|%s|%s" % [str(on), str(disabled)]
	if _cache.has(key):
		return _cache[key] as ImageTexture
	var w: int = 56
	var h: int = 28
	var image: Image = Image.create(w, h, false, Image.FORMAT_RGBA8)
	var glass: Color = SLATE_LIT if on else PAGE_DEEP
	if disabled:
		glass = glass.darkened(0.35)
	var knob: Color = Color("ffe9a8") if on else SECONDARY
	var r: float = float(h) * 0.5
	for y: int in range(h):
		for x: int in range(w):
			var cx: float = clampf(float(x) + 0.5, r, float(w) - r)
			var d: float = Vector2(float(x) + 0.5 - cx, float(y) + 0.5 - r).length()
			var color: Color = Color(0, 0, 0, 0)
			if d <= r:
				color = GOLD_LINE if d > r - 2.2 else glass
				if d <= r - 2.2 and on:
					color = glass.lerp(Color.WHITE, 0.35 * (1.0 - float(y) / float(h)))
				color.a = clampf(r - d, 0.0, 1.0)
			var kx: float = float(w) - r if on else r
			var kd: float = Vector2(float(x) + 0.5 - kx, float(y) + 0.5 - r).length()
			if kd <= r - 5.0:
				color = knob
			image.set_pixel(x, y, color)
	var texture: ImageTexture = ImageTexture.create_from_image(image)
	_cache[key] = texture
	return texture


## The gold diamond a slider is dragged by.
static func diamond_icon(px: int = 26, fill: Color = Color("ffe08a")) -> ImageTexture:
	var key: String = "diamond|%d|%s" % [px, fill.to_html()]
	if _cache.has(key):
		return _cache[key] as ImageTexture
	var image: Image = Image.create(px, px, false, Image.FORMAT_RGBA8)
	var half: float = float(px) * 0.5
	for y: int in range(px):
		for x: int in range(px):
			var d: float = absf(float(x) + 0.5 - half) + absf(float(y) + 0.5 - half)
			var color: Color = Color(0, 0, 0, 0)
			if d <= half:
				color = Color("8a6420") if d > half - 2.5 else fill.lerp(Color.WHITE, 0.4 * clampf(1.0 - float(y) / half, 0.0, 1.0))
				color.a = clampf(half - d, 0.0, 1.0)
			image.set_pixel(x, y, color)
	var texture: ImageTexture = ImageTexture.create_from_image(image)
	_cache[key] = texture
	return texture


static func _fields(t: Theme) -> void:
	# sliders: a dark groove that fills with lit glass, a gold diamond to drag
	var groove: StyleBoxFlat = UIStyle.box(PAGE_DEEP, GOLD_LINE.darkened(0.25), 1, 7)
	groove.content_margin_top = 7
	groove.content_margin_bottom = 7
	t.set_stylebox("slider", "HSlider", groove)
	var fill: StyleBoxFlat = UIStyle.box(SLATE_LIT, GOLD_LINE.darkened(0.1), 1, 7)
	fill.content_margin_top = 7
	fill.content_margin_bottom = 7
	t.set_stylebox("grabber_area", "HSlider", fill)
	t.set_stylebox("grabber_area_highlight", "HSlider", fill)
	t.set_icon("grabber", "HSlider", diamond_icon())
	t.set_icon("grabber_highlight", "HSlider", diamond_icon(26, Color.WHITE))
	t.set_icon("grabber_disabled", "HSlider", diamond_icon(26, SECONDARY))
	# switches and check boxes
	for type_name: String in ["CheckBox", "CheckButton"]:
		t.set_icon("unchecked", type_name, switch_icon(false))
		t.set_icon("checked", type_name, switch_icon(true))
		t.set_icon("unchecked_disabled", type_name, switch_icon(false, true))
		t.set_icon("checked_disabled", type_name, switch_icon(true, true))
		t.set_color("font_color", type_name, TEXT)
		t.set_color("font_hover_color", type_name, Color.WHITE)
		t.set_color("font_focus_color", type_name, Color.WHITE)
		t.set_color("font_pressed_color", type_name, TEXT)
		t.set_color("font_hover_pressed_color", type_name, Color.WHITE)
		t.set_color("font_disabled_color", type_name, Color(TEXT.r, TEXT.g, TEXT.b, 0.5))
		t.set_constant("h_separation", type_name, 12)
		for state: String in ["normal", "pressed", "disabled"]:
			t.set_stylebox(state, type_name, StyleBoxEmpty.new())
		var hover: StyleBoxFlat = UIStyle.box(Color(SLATE_LIT.r, SLATE_LIT.g, SLATE_LIT.b, 0.1), Color(0, 0, 0, 0), 0, 8)
		t.set_stylebox("hover", type_name, hover)
		t.set_stylebox("hover_pressed", type_name, hover)
		t.set_stylebox("focus", type_name, focus_ring(8))
	# text fields
	var field: StyleBoxFlat = UIStyle.box(PAGE_DEEP, GOLD_LINE.darkened(0.25), 1, 8)
	field.set_content_margin_all(8)
	var field_focus: StyleBoxFlat = UIStyle.box(PAGE_DEEP.lightened(0.06), Color("ffe9a8"), 2, 8)
	field_focus.set_content_margin_all(8)
	for type_name: String in ["LineEdit", "TextEdit"]:
		t.set_stylebox("normal", type_name, field)
		t.set_stylebox("focus", type_name, field_focus)
		t.set_color("font_color", type_name, TEXT)
		t.set_color("font_placeholder_color", type_name, Color(SECONDARY.r, SECONDARY.g, SECONDARY.b, 0.85))
		t.set_color("caret_color", type_name, TITLE)
	# progress bars
	t.set_stylebox("background", "ProgressBar", UIStyle.box(PAGE_DEEP, GOLD_LINE.darkened(0.25), 1, 8))
	t.set_stylebox("fill", "ProgressBar", UIStyle.box(SLATE_LIT, Color(0, 0, 0, 0), 0, 8))
	t.set_color("font_color", "ProgressBar", TEXT)
	# a plain separator is the gold hairline
	var line: StyleBoxLine = StyleBoxLine.new()
	line.color = Color(GOLD_LINE.r, GOLD_LINE.g, GOLD_LINE.b, 0.6)
	line.thickness = 2
	t.set_stylebox("separator", "HSeparator", line)
	var vline: StyleBoxLine = StyleBoxLine.new()
	vline.color = Color(GOLD_LINE.r, GOLD_LINE.g, GOLD_LINE.b, 0.6)
	vline.thickness = 2
	vline.vertical = true
	t.set_stylebox("separator", "VSeparator", vline)


static func _bar_box(id: String, rotate: bool, margin: float, tint: Color = Color.WHITE) -> StyleBoxTexture:
	var texture: Texture2D = UiArt.texture(id)
	if texture == null:
		return null
	if rotate:
		var key: String = "rot|" + id
		if not _cache.has(key):
			var image: Image = texture.get_image()
			if image.is_compressed():
				image.decompress()
			image.rotate_90(CLOCKWISE)
			_cache[key] = ImageTexture.create_from_image(image)
		texture = _cache[key] as Texture2D
	var box: StyleBoxTexture = StyleBoxTexture.new()
	box.texture = texture
	box.modulate_color = tint
	if rotate:
		box.texture_margin_left = margin * float(texture.get_width())
		box.texture_margin_right = margin * float(texture.get_width())
	else:
		box.texture_margin_top = margin * float(texture.get_height())
		box.texture_margin_bottom = margin * float(texture.get_height())
	return box


## The painted rail and its amber grip on every scrolling list under the theme.
static func _scrollbars(t: Theme) -> void:
	for entry: Array in [["VScrollBar", false], ["HScrollBar", true]]:
		var type_name: String = str(entry[0])
		var rotate: bool = bool(entry[1])
		var rail: StyleBoxTexture = _bar_box(RAIL_ART, rotate, 0.1)
		var grip: StyleBoxTexture = _bar_box(GRIP_ART, rotate, 0.26)
		if rail == null or grip == null:
			continue
		if rotate:
			rail.content_margin_top = SCROLL_WIDTH * 0.5
			rail.content_margin_bottom = SCROLL_WIDTH * 0.5
		else:
			rail.content_margin_left = SCROLL_WIDTH * 0.5
			rail.content_margin_right = SCROLL_WIDTH * 0.5
		t.set_stylebox("scroll", type_name, rail)
		t.set_stylebox("scroll_focus", type_name, rail)
		t.set_stylebox("grabber", type_name, grip)
		t.set_stylebox("grabber_highlight", type_name, _bar_box(GRIP_ART, rotate, 0.26, Color(1.2, 1.2, 1.15)))
		t.set_stylebox("grabber_pressed", type_name, _bar_box(GRIP_ART, rotate, 0.26, Color(1.3, 1.3, 1.2)))


## Makes a scroll container's bars the painted rail and grip even where a screen styled them by hand.
static func style_scroll(scroll: ScrollContainer) -> void:
	if scroll == null or not available():
		return
	var source: Theme = theme()
	for entry: Array in [[scroll.get_v_scroll_bar(), "VScrollBar", true], [scroll.get_h_scroll_bar(), "HScrollBar", false]]:
		var bar: ScrollBar = entry[0] as ScrollBar
		var type_name: String = str(entry[1])
		if not source.has_stylebox("scroll", type_name):
			continue
		bar.custom_minimum_size = Vector2(SCROLL_WIDTH, 0) if bool(entry[2]) else Vector2(0, SCROLL_WIDTH)
		for part: String in ["scroll", "scroll_focus", "grabber", "grabber_highlight", "grabber_pressed"]:
			bar.add_theme_stylebox_override(part, source.get_stylebox(part, type_name))


# ---- Builders -----------------------------------------------------------------------------------------------------------------------


## The strip of eight coloured panes along the top of a page. With `colours` empty it is the painted strip of the four Paths; with one
## colour (a screen that belongs to one Path) or several, eight lit panes in those colours in turn.
static func strip(colours: Array[Color] = [], height: float = STRIP_HEIGHT) -> Control:
	if colours.is_empty():
		var art: TextureRect = TextureRect.new()
		art.name = "GlassStrip"
		art.texture = UiArt.texture(STRIP_ART)
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_SCALE
		art.custom_minimum_size = Vector2(0, height)
		art.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return art
	var row: HBoxContainer = UIKit.hbox(2)
	row.name = "GlassStrip"
	row.custom_minimum_size = Vector2(0, height)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for index: int in range(8):
		var cell: Panel = Panel.new()
		cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell.add_theme_stylebox_override("panel", pane(colours[index % colours.size()], true, Vector4(0, 0, 0, 0), 0.14))
		row.add_child(cell)
	return row


## A screen's title between the two halves of the gold divider.
static func title(text: String, size: int = 34) -> Control:
	var row: HBoxContainer = UIKit.hbox(14)
	row.name = "GlassTitle"
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_rule(true))
	var label: Label = UIKit.label(text, &"HeadingLabel", size, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	label.name = "Title"
	row.add_child(label)
	row.add_child(_rule(false))
	return row


static func _rule(left: bool) -> Control:
	var art: Texture2D = UiArt.texture(DIVIDER_ART)
	var piece: TextureRect = TextureRect.new()
	piece.mouse_filter = Control.MOUSE_FILTER_IGNORE
	piece.custom_minimum_size = Vector2(120, 18)
	piece.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	piece.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if art == null:
		return piece
	# the left half ends in its diamond beside the title, the right half begins with it
	var half: AtlasTexture = AtlasTexture.new()
	half.atlas = art
	var w: float = float(art.get_width())
	var h: float = float(art.get_height())
	half.region = Rect2(0.0, 0.0, w * 0.13, h) if left else Rect2(w * 0.87, 0.0, w * 0.13, h)
	piece.texture = half
	piece.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	piece.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	piece.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	piece.custom_minimum_size = Vector2(18.0 * (w * 0.13) / h, 18)
	return piece


## The gold divider between sections (stretched in its middle).
static func divider(height: float = 16.0) -> Control:
	var art: Texture2D = UiArt.texture(DIVIDER_ART)
	if art == null:
		return HSeparator.new()
	var line: NinePatchRect = NinePatchRect.new()
	line.name = "GlassDivider"
	line.texture = art
	var scale: float = height / float(art.get_height())
	line.patch_margin_left = int(float(art.get_width()) * 0.16)
	line.patch_margin_right = int(float(art.get_width()) * 0.16)
	line.custom_minimum_size = Vector2(float(line.patch_margin_left + line.patch_margin_right) * scale + 40.0, float(art.get_height()))
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# NinePatchRect does not scale its patches: draw at the art's height inside a holder scaled to `height`
	var holder: Control = Control.new()
	holder.name = "GlassDivider"
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.custom_minimum_size = Vector2(0, height)
	holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	holder.add_child(line)
	line.scale = Vector2(scale, scale)
	holder.resized.connect(func() -> void: line.size = Vector2(holder.size.x / scale, float(art.get_height())))
	line.size = Vector2(maxf(holder.size.x, 200.0) / scale, float(art.get_height()))
	return holder


## The rose window of the four Paths (the top of the pause menu).
static func rose(px: float = 150.0) -> TextureRect:
	var art: TextureRect = TextureRect.new()
	art.name = "RoseWindow"
	art.texture = UiArt.texture(ROSE_ART)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.custom_minimum_size = Vector2(px, px)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return art


## One quest step mark (an empty diamond, a ticked diamond, an arrowhead) `px` pixels across.
static func mark(which: Mark, px: float = 22.0) -> TextureRect:
	var art: Texture2D = UiArt.texture(MARKS_ART)
	var piece: TextureRect = TextureRect.new()
	piece.name = "QuestMark"
	piece.custom_minimum_size = Vector2(px, px)
	piece.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	piece.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	piece.mouse_filter = Control.MOUSE_FILTER_IGNORE
	piece.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	if art != null:
		var cell: AtlasTexture = AtlasTexture.new()
		cell.atlas = art
		var w: float = float(art.get_width()) / 3.0
		# each mark sits inside its cell with a margin: crop to the middle so it fills its square
		cell.region = Rect2(w * float(which) + w * 0.1, float(art.get_height()) * 0.1, w * 0.8, float(art.get_height()) * 0.8)
		piece.texture = cell
	return piece


## A small tag of glass in a Path's colour with the Path's icon beside its words ("colour is never the only signal").
static func path_tag(path: Affinity.Type, text: String, font_size: int = 16) -> PanelContainer:
	var tag: PanelContainer = PanelContainer.new()
	tag.name = "PathTag"
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tag.add_theme_stylebox_override("panel", pane(lit(PathPalette.main(path)), true, Vector4(8, 2, 10, 2), 0.3))
	var row: HBoxContainer = UIKit.hbox(5)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tag.add_child(row)
	var icon: TextureRect = IconArt.rect(PathIcons.icon(path), float(font_size) + 6.0)
	if icon != null:
		row.add_child(icon)
	var label: Label = UIKit.label(text, &"GlassInk", font_size)
	label.add_theme_font_override("font", UIStyle.font_bold())
	row.add_child(label)
	return tag


## A slate tag (a kind of thing that is no Path: MAIN, SIDE, TRACKED).
static func tag(text: String, glass: Color = SLATE_LIT, font_size: int = 15) -> PanelContainer:
	var plate: PanelContainer = PanelContainer.new()
	plate.name = "GlassTag"
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_theme_stylebox_override("panel", pane(glass, true, Vector4(8, 1, 8, 1), 0.3))
	var label: Label = UIKit.label(text, &"GlassInk", font_size)
	label.add_theme_font_override("font", UIStyle.font_bold())
	plate.add_child(label)
	return plate


## Contrast ratio of two colours (WCAG): body text needs 4.5 or more.
static func contrast(a: Color, b: Color) -> float:
	var la: float = _luminance(a)
	var lb: float = _luminance(b)
	return (maxf(la, lb) + 0.05) / (minf(la, lb) + 0.05)


static func _luminance(c: Color) -> float:
	var parts: Array[float] = []
	for v: float in [c.r, c.g, c.b]:
		parts.append(v / 12.92 if v <= 0.03928 else pow((v + 0.055) / 1.055, 2.4))
	return 0.2126 * parts[0] + 0.7152 * parts[1] + 0.0722 * parts[2]
