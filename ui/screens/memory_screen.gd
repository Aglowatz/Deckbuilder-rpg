class_name MemoryScreen
extends Control
## A memory fragment (Story v2 Part E): the screen dims, a soft four-color vignette (the four Paths) breathes in the corners and the fragment's lines appear
## one at a time. E / Space / click shows the next line, and after the last one the screen fades out and `finished` is emitted.

signal finished

const VIGNETTE_ALPHA: float = 0.42
const LINE_FADE: float = 1.1

var number: int = 1
var title: String = ""
var lines: Array[String] = []
var _shade: ColorRect
var _heading: Label
var _column: VBoxContainer
var _hint: Label
var _shown: int = 0
var _closing: bool = false


static func make(number_value: int, title_text: String, line_list: Array[String]) -> MemoryScreen:
	var screen: MemoryScreen = MemoryScreen.new()
	screen.name = "MemoryScreen"
	screen.number = number_value
	screen.title = title_text
	screen.lines = line_list
	return screen


func _ready() -> void:
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_shade = ColorRect.new()
	_shade.color = Color(0.015, 0.012, 0.03, 0.0)
	UIKit.full_rect(_shade)
	_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_shade)
	_add_vignette()
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	var stack: VBoxContainer = UIKit.vbox(26)
	stack.custom_minimum_size = Vector2(1100, 0)
	center.add_child(stack)
	_heading = UIKit.label(StoryText.shared().text("memory.title_format") % [number, title], &"", 30, Color(0.86, 0.8, 0.96, 0.0), HORIZONTAL_ALIGNMENT_CENTER)
	stack.add_child(_heading)
	_column = UIKit.vbox(18)
	stack.add_child(_column)
	_hint = UIKit.label(StoryText.shared().text("memory.hint"), &"MutedLabel", 20, Color(0.8, 0.78, 0.9, 0.0), HORIZONTAL_ALIGNMENT_CENTER)
	stack.add_child(_hint)
	var fade_in: Tween = create_tween().set_parallel(true)
	fade_in.tween_property(_shade, "color:a", 0.9, 1.4)
	fade_in.tween_property(_heading, "modulate:a", 1.0, 1.4).from(0.0)
	_heading.add_theme_color_override("font_color", Color(0.86, 0.8, 0.96, 1.0))
	_hint.add_theme_color_override("font_color", Color(0.8, 0.78, 0.9, 0.7))
	fade_in.chain().tween_callback(_next_line)
	Audio.sfx(&"ui_open", -8.0)


## Four soft glows, one per Path in its own color, in the four corners.
func _add_vignette() -> void:
	var paths: Array[Affinity.Type] = Affinity.colored_types()
	var corners: Array[Vector2] = [Vector2(0.0, 0.0), Vector2(1.0, 0.0), Vector2(0.0, 1.0), Vector2(1.0, 1.0)]
	for index: int in range(mini(paths.size(), corners.size())):
		var gradient: Gradient = Gradient.new()
		var color: Color = UIStyle.affinity_color(paths[index])
		gradient.set_color(0, Color(color.r, color.g, color.b, VIGNETTE_ALPHA))
		gradient.set_color(1, Color(color.r, color.g, color.b, 0.0))
		var texture: GradientTexture2D = GradientTexture2D.new()
		texture.gradient = gradient
		texture.fill = GradientTexture2D.FILL_RADIAL
		texture.fill_from = Vector2(0.5, 0.5)
		texture.fill_to = Vector2(1.0, 0.5)
		texture.width = 512
		texture.height = 512
		var glow: TextureRect = TextureRect.new()
		glow.texture = texture
		glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		glow.stretch_mode = TextureRect.STRETCH_SCALE
		glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		glow.set_anchors_preset(Control.PRESET_TOP_LEFT)
		glow.size = Vector2(1300, 1300)
		glow.position = Vector2(-650.0 + corners[index].x * 1920.0, -650.0 + corners[index].y * 1080.0)
		glow.modulate.a = 0.0
		add_child(glow)
		var breathe: Tween = create_tween().set_loops()
		breathe.tween_property(glow, "modulate:a", 1.0, 2.2 + 0.4 * float(index)).from(0.45)
		breathe.tween_property(glow, "modulate:a", 0.45, 2.6 + 0.3 * float(index))


func _next_line() -> void:
	if _closing:
		return
	if _shown >= lines.size():
		_close()
		return
	var line: Label = UIKit.label(lines[_shown], &"", 34, Color(0.94, 0.92, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	line.custom_minimum_size = Vector2(1100, 0)
	line.add_theme_font_override("font", UIStyle.font_italic())
	_column.add_child(line)
	# The older lines settle back so the newest one is the brightest.
	for index: int in range(_column.get_child_count() - 1):
		(_column.get_child(index) as Control).modulate.a = maxf(0.35, 0.8 - 0.15 * float(_column.get_child_count() - 2 - index))
	var fade: Tween = create_tween()
	fade.tween_property(line, "modulate:a", 1.0, LINE_FADE).from(0.0)
	_shown += 1
	Audio.sfx(&"ui_tick", -12.0)


func _close() -> void:
	_closing = true
	var out: Tween = create_tween().set_parallel(true)
	out.tween_property(self, "modulate:a", 0.0, 0.9)
	out.chain().tween_callback(func() -> void:
		finished.emit()
		queue_free())


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		_next_line()


func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not (event as InputEventKey).pressed or (event as InputEventKey).echo:
		return
	var code: Key = (event as InputEventKey).keycode
	if code == KEY_E or code == KEY_SPACE or code == KEY_ENTER:
		get_viewport().set_input_as_handled()
		_next_line()
