class_name QuestEdgePointer
extends Control
## Overnight Oct 16: a soft golden pointer at the edge of the screen toward the tracked quest's objective while it is off-screen (or behind
## the camera). Fades in and out; never shown while the target is on screen. Full-rect, ignores the mouse.

const INSET: float = 70.0
const SIZE: float = 22.0
const GOLD: Color = Color("ffd25a")

var camera: Camera3D
## Overnight Oct 30-31, Part 2: gold for a main line, blue for a side quest (QuestMarkerLayer sets it).
var color: Color = GOLD
var target: Vector3 = Vector3.ZERO
var target_valid: bool = false
var _alpha: float = 0.0
var _at: Vector2 = Vector2.ZERO
var _angle: float = 0.0


func _ready() -> void:
	name = "QuestEdgePointer"
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## Where the pointer sits for a projected point (screen rect `view`) and whether it is needed at all: {"show", "at", "angle"}.
static func place(view: Rect2, projected: Vector2, behind: bool) -> Dictionary:
	var inner: Rect2 = view.grow(-INSET)
	var centre: Vector2 = view.get_center()
	var point: Vector2 = projected
	if behind:
		point = centre - (projected - centre) * 1000.0
	if not behind and inner.has_point(point):
		return {"show": false, "at": point, "angle": 0.0}
	var dir: Vector2 = (point - centre)
	if dir.length() < 0.001:
		dir = Vector2.DOWN
	var half: Vector2 = inner.size * 0.5
	var scale: float = minf(half.x / maxf(absf(dir.x), 0.001), half.y / maxf(absf(dir.y), 0.001))
	return {"show": true, "at": centre + dir * scale, "angle": dir.angle()}


func _process(delta: float) -> void:
	var wanted: float = 0.0
	if camera == null or not is_instance_valid(camera):
		camera = get_viewport().get_camera_3d()
	if target_valid and camera != null and is_visible_in_tree():
		var view: Rect2 = get_viewport_rect()
		var behind: bool = camera.is_position_behind(target)
		var placed: Dictionary = place(view, camera.unproject_position(target), behind)
		if bool(placed["show"]):
			wanted = 0.85
			_at = placed["at"] as Vector2
			_angle = float(placed["angle"])
	_alpha = move_toward(_alpha, wanted, delta * 3.0)
	queue_redraw()


func is_showing() -> bool:
	return _alpha > 0.4


func _draw() -> void:
	if _alpha <= 0.01:
		return
	var forward: Vector2 = Vector2.from_angle(_angle)
	var side: Vector2 = forward.orthogonal()
	var tip: Vector2 = _at + forward * SIZE
	var points: PackedVector2Array = [tip, _at - forward * SIZE * 0.4 + side * SIZE * 0.75, _at - forward * SIZE * 0.1, _at - forward * SIZE * 0.4 - side * SIZE * 0.75]
	draw_colored_polygon(points, Color(0.08, 0.05, 0.02, 0.55 * _alpha))
	var inner: PackedVector2Array = []
	for p: Vector2 in points:
		inner.append(_at + (p - _at) * 0.78)
	draw_colored_polygon(inner, Color(color, _alpha))
	draw_circle(_at - forward * SIZE * 0.9, 5.0, Color(color, 0.6 * _alpha))
