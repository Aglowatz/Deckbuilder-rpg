class_name ArtBar
extends ProgressBar
## A ProgressBar drawn with a UI art kit bar frame (UI-BAR-HP / UI-BAR-XP): the game fill is drawn inside the frame's transparent channel by ratio, then the frame on top, so the
## end caps are never covered or stretched. Made by `UiSkin.skin_bar`, which turns an existing ProgressBar into one (`set_script`); `set_fill_color` changes the fill.

var fill_color: Color = UIStyle.HP_RED
var frame: StyleBoxTexture
var _fill_style: StyleBoxFlat = StyleBoxFlat.new()


func setup(bar_frame: StyleBoxTexture, color: Color) -> void:
	frame = bar_frame
	show_percentage = false
	var none: StyleBoxEmpty = StyleBoxEmpty.new()
	add_theme_stylebox_override("background", none)
	add_theme_stylebox_override("fill", none)
	_fill_style.set_corner_radius_all(3)
	_fill_style.anti_aliasing = true
	set_fill_color(color)


func set_fill_color(color: Color) -> void:
	fill_color = color
	_fill_style.bg_color = color
	queue_redraw()


## The transparent channel of the frame inside this control's rect (the frame's content margins are the channel insets).
func channel_rect() -> Rect2:
	var left: float = frame.content_margin_left
	var top: float = frame.content_margin_top
	return Rect2(left, top, maxf(0.0, size.x - left - frame.content_margin_right), maxf(0.0, size.y - top - frame.content_margin_bottom))


func _draw() -> void:
	if frame == null:
		return
	var channel: Rect2 = channel_rect()
	var span: float = max_value - min_value
	var ratio: float = clampf((value - min_value) / span, 0.0, 1.0) if span > 0.0 else 0.0
	if ratio > 0.0:
		draw_style_box(_fill_style, Rect2(channel.position, Vector2(maxf(2.0, channel.size.x * ratio), channel.size.y)))
	draw_style_box(frame, Rect2(Vector2.ZERO, size))
