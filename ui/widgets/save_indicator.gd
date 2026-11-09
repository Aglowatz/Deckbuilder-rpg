class_name SaveIndicator
extends Control
## Overnight Nov 9, Part 4 (release basics): the autosave indicator - a small quill turning in a gold ring and "Saving..." in the bottom-right
## corner whenever the campaign is written (EventBus.game_saved). It fades in fast, stays at least HOLD seconds after the last save (saves come
## in bursts: closing a screen, changing area) and fades out. Never takes the mouse. Installed once by SceneManager on its own layer.

const HOLD: float = 0.9
const SIZE: Vector2 = Vector2(176, 44)
const MARGIN: Vector2 = Vector2(22, 18)

var _left: float = 0.0
var _angle: float = 0.0
var _label: Label


static func install(parent: Node) -> SaveIndicator:
	var indicator: SaveIndicator = SaveIndicator.new()
	indicator.name = "SaveIndicator"
	parent.add_child(indicator)
	return indicator


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	size = SIZE
	position = Vector2(1920, 1080) - SIZE - MARGIN
	modulate.a = 0.0
	visible = false
	_label = UIKit.label("Saving...", &"", 20, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_LEFT)
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_label.add_theme_constant_override("outline_size", 6)
	_label.position = Vector2(50, 8)
	_label.size = Vector2(SIZE.x - 54, 28)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)
	EventBus.game_saved.connect(show_saving)


## Shows the indicator (or keeps it up) for another HOLD seconds.
func show_saving() -> void:
	_left = HOLD
	if not visible:
		visible = true
		var tween: Tween = create_tween()
		tween.tween_property(self, "modulate:a", 1.0, 0.15)


func is_showing() -> bool:
	return visible and _left > 0.0


func _process(delta: float) -> void:
	if not visible:
		return
	_angle = fmod(_angle + delta * (1.5 if Settings.reduce_motion else 4.5), TAU)
	queue_redraw()
	if _left > 0.0:
		_left -= delta
		if _left <= 0.0:
			var tween: Tween = create_tween()
			tween.tween_property(self, "modulate:a", 0.0, 0.3)
			tween.tween_callback(func() -> void:
				if _left <= 0.0:
					visible = false)


func _draw() -> void:
	var centre: Vector2 = Vector2(24, SIZE.y * 0.5)
	draw_circle(centre, 19.0, Color(0.05, 0.03, 0.08, 0.82))
	draw_arc(centre, 17.0, _angle, _angle + TAU * 0.7, 32, UIStyle.GOLD, 2.5, true)
	# the quill: a feather vane and its shaft, turning with the ring
	var tip: Vector2 = centre + Vector2(0, 10).rotated(_angle * 0.35)
	var top: Vector2 = centre + Vector2(0, -11).rotated(_angle * 0.35)
	var side: Vector2 = Vector2(4.5, 0).rotated(_angle * 0.35)
	var mid: Vector2 = tip.lerp(top, 0.45)
	draw_colored_polygon(PackedVector2Array([tip.lerp(top, 0.2), mid + side, top, mid - side * 0.6]), Color("f3e6c4"))
	draw_line(tip, top, Color("8a6a3a"), 1.5, true)
