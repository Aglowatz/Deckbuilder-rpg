class_name PadGlyph
extends Control
## Controller support (Oct 26): a drawn controller button (no art): Xbox face buttons are coloured discs with their letter, PlayStation face
## buttons dark discs with the drawn cross / circle / square / triangle, everything else (bumpers, triggers, View, D-pad) a rounded tag with its
## name. Follows `InputDevice.layout()`; `action` shows that action's pad button, `code` a fixed pad code.

const XBOX_COLORS: Dictionary = {JOY_BUTTON_A: Color("5fbf4a"), JOY_BUTTON_B: Color("e0453a"), JOY_BUTTON_X: Color("3d8fe0"), JOY_BUTTON_Y: Color("f0c33c")}
const PS_COLORS: Dictionary = {JOY_BUTTON_A: Color("7fa8ff"), JOY_BUTTON_B: Color("ff6b6b"), JOY_BUTTON_X: Color("ff8fd0"), JOY_BUTTON_Y: Color("53d6a0")}

var action: StringName = &""
var code: int = Keybinds.PAD_NONE
var glyph_size: float = 34.0


static func make(for_action: StringName, size_px: float = 34.0) -> PadGlyph:
	var glyph: PadGlyph = PadGlyph.new()
	glyph.action = for_action
	glyph.glyph_size = size_px
	glyph.name = "PadGlyph_%s" % for_action
	return glyph


static func for_code(pad_code: int, size_px: float = 34.0) -> PadGlyph:
	var glyph: PadGlyph = PadGlyph.new()
	glyph.code = pad_code
	glyph.glyph_size = size_px
	glyph.name = "PadGlyph_%d" % pad_code
	return glyph


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_resize()
	EventBus.input_device_changed.connect(func(_pad: bool) -> void:
		_resize()
		queue_redraw())


func shown_code() -> int:
	return Keybinds.pad_of(action) if action != &"" else code


func _is_face(pad_code: int) -> bool:
	return pad_code in [JOY_BUTTON_A, JOY_BUTTON_B, JOY_BUTTON_X, JOY_BUTTON_Y]


func _resize() -> void:
	var pad_code: int = shown_code()
	var width: float = glyph_size
	if not _is_face(pad_code):
		var font: Font = get_theme_default_font()
		width = maxf(glyph_size, font.get_string_size(InputDevice.pad_text(pad_code), HORIZONTAL_ALIGNMENT_LEFT, -1, int(glyph_size * 0.5)).x + glyph_size * 0.6)
	custom_minimum_size = Vector2(width, glyph_size)


func _draw() -> void:
	var pad_code: int = shown_code()
	if pad_code == Keybinds.PAD_NONE:
		return
	var rect: Rect2 = Rect2(Vector2.ZERO, custom_minimum_size)
	var center: Vector2 = rect.get_center()
	var radius: float = glyph_size * 0.5 - 1.0
	var font: Font = get_theme_default_font()
	var playstation: bool = InputDevice.layout() == InputDevice.Layout.PLAYSTATION
	if _is_face(pad_code):
		if playstation:
			draw_circle(center, radius, Color("1d1b26"))
			draw_arc(center, radius, 0.0, TAU, 32, Color(1, 1, 1, 0.35), 1.5, true)
			_draw_ps_shape(pad_code, center, radius * 0.5, PS_COLORS[pad_code] as Color)
		else:
			draw_circle(center, radius, XBOX_COLORS[pad_code] as Color)
			draw_arc(center, radius, 0.0, TAU, 32, Color(0, 0, 0, 0.5), 1.5, true)
			var letter: String = InputDevice.pad_text(pad_code, InputDevice.Layout.XBOX)
			var font_size: int = int(glyph_size * 0.6)
			var text_size: Vector2 = font.get_string_size(letter, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
			draw_string(font, Vector2(center.x - text_size.x * 0.5, center.y + font.get_ascent(font_size) * 0.5 - 2.0), letter, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color("10100f"))
		return
	var tag: StyleBoxFlat = StyleBoxFlat.new()
	tag.bg_color = Color("1d1b26")
	tag.border_color = Color(1, 1, 1, 0.55)
	tag.set_border_width_all(2)
	tag.set_corner_radius_all(int(glyph_size * 0.3))
	draw_style_box(tag, rect)
	var label: String = InputDevice.pad_text(pad_code)
	var label_size: int = int(glyph_size * 0.5)
	var label_width: float = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, label_size).x
	draw_string(font, Vector2(center.x - label_width * 0.5, center.y + font.get_ascent(label_size) * 0.5 - 1.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, label_size, Color("f3ead2"))


func _draw_ps_shape(pad_code: int, center: Vector2, half: float, color: Color) -> void:
	var width: float = maxf(2.0, glyph_size * 0.08)
	match pad_code:
		JOY_BUTTON_A:
			draw_line(center + Vector2(-half, -half), center + Vector2(half, half), color, width, true)
			draw_line(center + Vector2(-half, half), center + Vector2(half, -half), color, width, true)
		JOY_BUTTON_B:
			draw_arc(center, half, 0.0, TAU, 28, color, width, true)
		JOY_BUTTON_X:
			draw_rect(Rect2(center - Vector2(half, half), Vector2(half, half) * 2.0), color, false, width)
		JOY_BUTTON_Y:
			var points: PackedVector2Array = [center + Vector2(0, -half * 1.1), center + Vector2(half, half * 0.8), center + Vector2(-half, half * 0.8), center + Vector2(0, -half * 1.1)]
			draw_polyline(points, color, width, true)
