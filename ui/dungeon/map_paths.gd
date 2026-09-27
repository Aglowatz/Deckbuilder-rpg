class_name MapPaths
extends Control
## Draws the curved paths between map nodes: gold for walked paths, marching dashes for the
## path ahead, dim for locked ones.

var _map: DungeonMap
var _point_of: Callable
var _time: float = 0.0


func setup(map: DungeonMap, point_of: Callable) -> void:
	_map = map
	_point_of = point_of
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	if _map == null:
		return
	for node: DungeonMap.MapNode in _map.nodes:
		for next_id: int in node.next:
			var from: Vector2 = _point_of.call(node.id) as Vector2
			var to: Vector2 = _point_of.call(next_id) as Vector2
			var walked: bool = _map.is_cleared(next_id)
			var ahead: bool = node.id == _map.current and not walked
			var points: PackedVector2Array = _trim(_curve(from, to), 62.0)
			if walked:
				draw_polyline(points, Color(0, 0, 0, 0.5), 10.0, true)
				draw_polyline(points, UIStyle.GOLD, 6.0, true)
			elif ahead:
				_dashes(points, UIStyle.GOLD.lightened(0.2), 7.0, true)
			else:
				_dashes(points, Color(UIStyle.MUTED, 0.35), 4.0, false)


func _curve(from: Vector2, to: Vector2) -> PackedVector2Array:
	var mid: Vector2 = (from + to) * 0.5 + Vector2(0.0, (to.x - from.x) * 0.06)
	var control: Vector2 = mid + Vector2(0.0, (to.y - from.y) * 0.25)
	var points: PackedVector2Array = PackedVector2Array()
	for step: int in range(41):
		var t: float = float(step) / 40.0
		points.append(from.lerp(control, t).lerp(control.lerp(to, t), t))
	return points


func _trim(points: PackedVector2Array, radius: float) -> PackedVector2Array:
	var result: PackedVector2Array = PackedVector2Array()
	var start: Vector2 = points[0]
	var finish: Vector2 = points[points.size() - 1]
	for point: Vector2 in points:
		if point.distance_to(start) > radius and point.distance_to(finish) > radius:
			result.append(point)
	return result


func _dashes(points: PackedVector2Array, color: Color, width: float, march: bool) -> void:
	var offset: int = int(_time * 6.0) % 4 if march else 0
	var index: int = offset
	while index + 1 < points.size():
		var segment_end: int = mini(index + 2, points.size() - 1)
		draw_line(points[index], points[segment_end], color, width, true)
		index += 4
