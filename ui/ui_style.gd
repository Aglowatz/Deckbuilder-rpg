class_name UIStyle
extends RefCounted
## The look of the whole UI: palette, fonts, StyleBoxes and one shared Theme. No default Godot
## widget look survives: every control type used in the game is restyled here.

const INK: Color = Color("14101c")
const PLUM: Color = Color("241c30")
const PLUM_LIGHT: Color = Color("352a45")
const PLUM_HI: Color = Color("4a3b5f")
const GOLD: Color = Color("e8b04a")
const GOLD_DIM: Color = Color("8a6d3b")
const PARCHMENT: Color = Color("f3e9d2")
const MUTED: Color = Color("a89bb5")
const DANGER: Color = Color("d9534f")
const GOOD: Color = Color("6fbf73")
const LIFE_RED: Color = Color("d8404a")

const AFFINITY_COLORS: Dictionary = {
	Affinity.Type.NEUTRAL: Color("b8a98a"),
	Affinity.Type.A: Color("e2553f"),
	Affinity.Type.B: Color("4a8fe0"),
	Affinity.Type.C: Color("5aa84e"),
	Affinity.Type.D: Color("9a5fc7"),
}
## Thematic names for the placeholder affinities (UI only; core keeps "Affinity A-D").
const AFFINITY_NAMES: Dictionary = {
	Affinity.Type.NEUTRAL: "Neutral",
	Affinity.Type.A: "Beefcake",
	Affinity.Type.B: "Tide",
	Affinity.Type.C: "Root",
	Affinity.Type.D: "Necrocrat",
}
const AFFINITY_BLURBS: Dictionary = {
	Affinity.Type.A: "Aggressive. Haste, first strike, burn.",
	Affinity.Type.B: "Control. Draw, removal, fliers.",
	Affinity.Type.C: "Big bodies. Trample, guard, growth.",
	Affinity.Type.D: "Sacrifice and value. Tokens, drain. Afterlife Services and Labor.",
}

static var _theme: Theme
static var _fonts: Dictionary = {}


static func affinity_color(type: Affinity.Type) -> Color:
	return AFFINITY_COLORS.get(type, AFFINITY_COLORS[Affinity.Type.NEUTRAL]) as Color


static func affinity_name(type: Affinity.Type) -> String:
	return str(AFFINITY_NAMES.get(type, "Neutral"))


## Fonts: Cinzel for titles, Alegreya Sans for body text.
static func font_title() -> Font:
	return _font("title")


static func font_body() -> Font:
	return _font("body")


static func font_bold() -> Font:
	return _font("bold")


static func font_italic() -> Font:
	return _font("italic")


static func font_bold_italic() -> Font:
	return _font("bold_italic")


static func _font(key: String) -> Font:
	if _fonts.has(key):
		return _fonts[key] as Font
	var font: Font = null
	match key:
		"title":
			var variation: FontVariation = FontVariation.new()
			variation.base_font = load("res://assets/fonts/Cinzel/Cinzel-Variable.ttf") as Font
			variation.variation_embolden = 0.6
			font = variation
		"body":
			font = load("res://assets/fonts/AlegreyaSans/AlegreyaSans-Regular.ttf") as Font
		"bold":
			font = load("res://assets/fonts/AlegreyaSans/AlegreyaSans-Bold.ttf") as Font
		"italic":
			font = load("res://assets/fonts/AlegreyaSans/AlegreyaSans-Italic.ttf") as Font
		"bold_italic":
			font = load("res://assets/fonts/AlegreyaSans/AlegreyaSans-BoldItalic.ttf") as Font
	_fonts[key] = font
	return font


# ---- StyleBox helpers -------------------------------------------------------------------


static func box(
	fill: Color,
	border: Color = Color(0, 0, 0, 0),
	border_width: int = 0,
	radius: int = 10,
	shadow: int = 0,
) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.anti_aliasing = true
	if shadow > 0:
		style.shadow_color = Color(0, 0, 0, 0.45)
		style.shadow_size = shadow
		style.shadow_offset = Vector2(0, shadow * 0.4)
	return style


static func panel_box(alpha: float = 0.94) -> StyleBoxFlat:
	var style: StyleBoxFlat = box(Color(PLUM.r, PLUM.g, PLUM.b, alpha), GOLD_DIM, 2, 14, 14)
	style.set_content_margin_all(18)
	return style


static func _button_box(fill: Color, border: Color, shadow: int = 4) -> StyleBoxFlat:
	var style: StyleBoxFlat = box(fill, border, 2, 10, shadow)
	style.content_margin_left = 22
	style.content_margin_right = 22
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style


static func circle_texture(diameter: int, fill: Color, border: Color = Color(0, 0, 0, 0), border_width: int = 0) -> ImageTexture:
	var image: Image = Image.create(diameter, diameter, false, Image.FORMAT_RGBA8)
	var center: Vector2 = Vector2(diameter, diameter) * 0.5
	var radius: float = diameter * 0.5 - 0.5
	for y: int in range(diameter):
		for x: int in range(diameter):
			var dist: float = Vector2(x + 0.5, y + 0.5).distance_to(center)
			var alpha: float = clampf(radius - dist + 0.5, 0.0, 1.0)
			var color: Color = fill
			if border_width > 0 and dist > radius - border_width:
				color = border
			color.a *= alpha
			image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)


static func rounded_square_texture(size: int, fill: Color, border: Color, mark: bool) -> ImageTexture:
	var image: Image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	var radius: float = size * 0.22
	for y: int in range(size):
		for x: int in range(size):
			var px: float = x + 0.5
			var py: float = y + 0.5
			var dx: float = maxf(absf(px - size * 0.5) - (size * 0.5 - radius), 0.0)
			var dy: float = maxf(absf(py - size * 0.5) - (size * 0.5 - radius), 0.0)
			var dist: float = sqrt(dx * dx + dy * dy)
			var alpha: float = clampf(radius - dist + 0.5, 0.0, 1.0)
			var color: Color = border if dist > radius - 2.0 else fill
			if mark:
				# A check mark: down-stroke then up-stroke.
				var s: float = float(size)
				var on_short: bool = px > s * 0.24 and px < s * 0.44 and absf((py - s * 0.52) - (px - s * 0.24)) < 2.4
				var on_long: bool = px >= s * 0.42 and px < s * 0.78 and absf((py - s * 0.72) + (px - s * 0.42) * 1.0) < 2.4
				if on_short or on_long:
					color = GOLD
			color.a *= alpha
			image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)


static func gradient_texture(top: Color, bottom: Color, width: int = 4, height: int = 256) -> GradientTexture2D:
	var gradient: Gradient = Gradient.new()
	gradient.colors = PackedColorArray([top, bottom])
	gradient.offsets = PackedFloat32Array([0.0, 1.0])
	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = width
	texture.height = height
	texture.fill_from = Vector2(0, 0)
	texture.fill_to = Vector2(0, 1)
	return texture


# ---- Theme ------------------------------------------------------------------------------


static func theme() -> Theme:
	if _theme != null:
		return _theme
	var t: Theme = Theme.new()
	t.default_font = font_body()
	t.default_font_size = 22

	# Labels
	t.set_color("font_color", "Label", PARCHMENT)
	t.set_color("font_shadow_color", "Label", Color(0, 0, 0, 0.5))
	t.set_constant("shadow_offset_x", "Label", 0)
	t.set_constant("shadow_offset_y", "Label", 1)
	t.set_font("font", "Label", font_body())
	t.set_type_variation("TitleLabel", "Label")
	t.set_font("font", "TitleLabel", font_title())
	t.set_font_size("font_size", "TitleLabel", 44)
	t.set_color("font_color", "TitleLabel", GOLD)
	t.set_color("font_shadow_color", "TitleLabel", Color(0, 0, 0, 0.7))
	t.set_constant("shadow_offset_y", "TitleLabel", 3)
	t.set_type_variation("HeadingLabel", "Label")
	t.set_font("font", "HeadingLabel", font_title())
	t.set_font_size("font_size", "HeadingLabel", 28)
	t.set_color("font_color", "HeadingLabel", GOLD)
	t.set_type_variation("MutedLabel", "Label")
	t.set_color("font_color", "MutedLabel", MUTED)

	# Rich text
	t.set_color("default_color", "RichTextLabel", PARCHMENT)
	t.set_font("normal_font", "RichTextLabel", font_body())
	t.set_font("bold_font", "RichTextLabel", font_bold())
	t.set_font("italics_font", "RichTextLabel", font_italic())
	t.set_font("bold_italics_font", "RichTextLabel", font_bold_italic())
	t.set_font_size("normal_font_size", "RichTextLabel", 22)
	t.set_font_size("bold_font_size", "RichTextLabel", 22)
	t.set_font_size("italics_font_size", "RichTextLabel", 22)
	t.set_font_size("bold_italics_font_size", "RichTextLabel", 22)

	# Buttons
	t.set_font_size("font_size", "Button", 24)
	t.set_font("font", "Button", font_bold())
	_style_button(t, "Button", PLUM_LIGHT, GOLD_DIM, PARCHMENT, PLUM_HI, GOLD)
	t.set_type_variation("PrimaryButton", "Button")
	_style_button(t, "PrimaryButton", Color("c98f2c"), Color("f5d27a"), Color("1c1408"), Color("e0a63c"), Color("fff0b8"))
	t.set_type_variation("DangerButton", "Button")
	_style_button(t, "DangerButton", Color("7a2c30"), Color("d9534f"), PARCHMENT, Color("9a3a3f"), Color("ff8a85"))
	t.set_type_variation("GhostButton", "Button")
	_style_button(t, "GhostButton", Color(1, 1, 1, 0.04), Color(1, 1, 1, 0.18), PARCHMENT, Color(1, 1, 1, 0.12), GOLD)

	# Panels
	t.set_stylebox("panel", "PanelContainer", panel_box())
	t.set_stylebox("panel", "Panel", panel_box())
	t.set_type_variation("DarkPanel", "PanelContainer")
	var dark: StyleBoxFlat = box(Color(0.05, 0.035, 0.08, 0.82), Color(1, 1, 1, 0.08), 1, 12, 10)
	dark.set_content_margin_all(14)
	t.set_stylebox("panel", "DarkPanel", dark)
	var tip: StyleBoxFlat = box(Color("120d1a"), GOLD_DIM, 2, 10, 12)
	tip.set_content_margin_all(12)
	t.set_stylebox("panel", "TooltipPanel", tip)
	t.set_color("font_color", "TooltipLabel", PARCHMENT)
	t.set_font_size("font_size", "TooltipLabel", 20)

	# Sliders
	var track: StyleBoxFlat = box(Color(0, 0, 0, 0.5), Color(1, 1, 1, 0.1), 1, 6)
	track.content_margin_top = 6
	track.content_margin_bottom = 6
	t.set_stylebox("slider", "HSlider", track)
	var fill: StyleBoxFlat = box(GOLD, Color(0, 0, 0, 0), 0, 6)
	fill.content_margin_top = 6
	fill.content_margin_bottom = 6
	t.set_stylebox("grabber_area", "HSlider", fill)
	t.set_stylebox("grabber_area_highlight", "HSlider", fill)
	var grabber: ImageTexture = circle_texture(26, PARCHMENT, GOLD_DIM, 3)
	t.set_icon("grabber", "HSlider", grabber)
	t.set_icon("grabber_highlight", "HSlider", grabber)
	t.set_icon("grabber_disabled", "HSlider", grabber)

	# Check boxes
	var unchecked: ImageTexture = rounded_square_texture(28, Color(0, 0, 0, 0.5), GOLD_DIM, false)
	var checked: ImageTexture = rounded_square_texture(28, Color(0.2, 0.15, 0.05, 0.9), GOLD, true)
	for type_name: String in ["CheckBox", "CheckButton"]:
		t.set_icon("unchecked", type_name, unchecked)
		t.set_icon("checked", type_name, checked)
		t.set_icon("unchecked_disabled", type_name, unchecked)
		t.set_icon("checked_disabled", type_name, checked)
		t.set_color("font_color", type_name, PARCHMENT)
		t.set_color("font_hover_color", type_name, GOLD)
		t.set_color("font_pressed_color", type_name, PARCHMENT)
		t.set_color("font_hover_pressed_color", type_name, GOLD)
		t.set_constant("h_separation", type_name, 12)
		t.set_stylebox("normal", type_name, StyleBoxEmpty.new())
		t.set_stylebox("hover", type_name, StyleBoxEmpty.new())
		t.set_stylebox("pressed", type_name, StyleBoxEmpty.new())
		t.set_stylebox("hover_pressed", type_name, StyleBoxEmpty.new())
		t.set_stylebox("focus", type_name, StyleBoxEmpty.new())

	# Progress bars
	t.set_stylebox("background", "ProgressBar", box(Color(0, 0, 0, 0.55), Color(1, 1, 1, 0.12), 1, 8))
	t.set_stylebox("fill", "ProgressBar", box(LIFE_RED, Color(0, 0, 0, 0), 0, 8))
	t.set_color("font_color", "ProgressBar", PARCHMENT)

	# Scrollbars
	var scroll_bg: StyleBoxFlat = box(Color(0, 0, 0, 0.35), Color(0, 0, 0, 0), 0, 6)
	var scroll_grab: StyleBoxFlat = box(GOLD_DIM, Color(0, 0, 0, 0), 0, 6)
	var scroll_grab_hi: StyleBoxFlat = box(GOLD, Color(0, 0, 0, 0), 0, 6)
	for bar: String in ["VScrollBar", "HScrollBar"]:
		t.set_stylebox("scroll", bar, scroll_bg)
		t.set_stylebox("grabber", bar, scroll_grab)
		t.set_stylebox("grabber_highlight", bar, scroll_grab_hi)
		t.set_stylebox("grabber_pressed", bar, scroll_grab_hi)
	t.set_constant("separation", "VBoxContainer", 10)
	t.set_constant("separation", "HBoxContainer", 10)
	_theme = t
	return t


static func _style_button(
	t: Theme,
	type_name: String,
	fill: Color,
	border: Color,
	font: Color,
	fill_hover: Color,
	border_hover: Color,
) -> void:
	t.set_stylebox("normal", type_name, _button_box(fill, border))
	t.set_stylebox("hover", type_name, _button_box(fill_hover, border_hover, 8))
	t.set_stylebox("pressed", type_name, _button_box(fill.darkened(0.25), border_hover, 1))
	t.set_stylebox("focus", type_name, StyleBoxEmpty.new())
	t.set_stylebox("disabled", type_name, _button_box(Color(0.12, 0.1, 0.15, 0.85), Color(1, 1, 1, 0.08), 0))
	t.set_color("font_color", type_name, font)
	t.set_color("font_hover_color", type_name, font)
	t.set_color("font_pressed_color", type_name, font)
	t.set_color("font_focus_color", type_name, font)
	t.set_color("font_disabled_color", type_name, Color(1, 1, 1, 0.3))
