class_name MapPaths
extends Control
## Draws the straight paths between map nodes (Nov 26 day: no more curves): gold for walked paths, marching dashes for the
## path ahead, dim for locked ones.

var _map: DungeonMap
var _point_of: Callable
var _time: float = 0.0
## How far a path stops short of each node centre (smaller on dense maps whose nodes are drawn smaller).
var trim_radius: float = 62.0
## How the paths are drawn over a painted map (decided per map in `data/dungeons/map_layout.json`, key "paths"): "full" (the placeholder look: all paths), "subtle" (thin and dim
## paths, the walked and next ones highlighted), "highlight" (only the walked and the next paths; the painted path is clear enough), "none" (nothing).
var style: String = "full"
## Batch 19 (Fable Nov 22 night): on a "plan" map whose painting has its own walkways, only the links listed here ("from>to" in node
## ids) keep a drawn line while they are ahead; the painted ones show the walked and the next step only. Unset: every link is drawn.
var painted_walkways: bool = false
var drawn_links: Dictionary = {}
## Fable big pass Nov 23 (Part 7): the traced line of each link ("from>to" in node ids -> points on the picture, 0..1;
## `DungeonCatalog.curves`) and the picture's rectangle on the screen. A link with a row follows its painted walkway.
var curves: Dictionary = {}
var art_rect: Rect2 = Rect2()
## The spacing of the points a traced line is drawn with (the dashes march over every fourth point).
const CURVE_STEP: float = 9.0


func setup(map: DungeonMap, point_of: Callable) -> void:
	_map = map
	_point_of = point_of
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


## The rooms the party can still walk to (style "plan").
var _reachable: Array[int] = []


func _draw() -> void:
	if _map == null:
		return
	if style == "plan":
		_reachable = _map.reachable_from(_map.current)
	for node: DungeonMap.MapNode in _map.nodes:
		if node.hidden or style == "none":
			continue
		for next_id: int in node.next:
			var from: Vector2 = _point_of.call(node.id) as Vector2
			var to: Vector2 = _point_of.call(next_id) as Vector2
			var walked: bool = _map.is_cleared(next_id)
			if style == "plan" and walked and node.id != 0 and not _map.is_cleared(node.id):
				walked = false  # Fable Nov 22 night: on a map of crossing routes, a link out of a room the party never entered was not walked
			var ahead: bool = node.id == _map.current and not walked
			var points: PackedVector2Array = _trim(link_points(node.id, next_id, from, to), trim_radius)
			if points.size() < 2:
				continue
			var thin: float = 0.6 if style == "subtle" else 1.0
			if walked:
				draw_polyline(points, Color(0, 0, 0, 0.5), 10.0 * thin, true)
				draw_polyline(points, UIStyle.GOLD, 6.0 * thin, true)
			elif ahead:
				_dashes(points, UIStyle.GOLD.lightened(0.2), 7.0 * thin, true)
			elif style == "plan" and painted_walkways and FOLLOW_CURVES and not drawn_links.has("%d>%d" % [node.id, next_id]):
				pass  # the painting shows this walkway itself (off with the curves, Nov 26: every link gets its line)
			elif style == "plan":
				# Fable Nov 21 castle: a route-planning map draws every link - the ones still ahead of the party as a pale line on a dark
				# edge (they do not follow the painting's own paths), the ones it can no longer take very faintly.
				if _reachable.has(node.id):
					draw_polyline(points, Color(0.08, 0.05, 0.12, 0.55), 7.0, true)
					draw_polyline(points, Color(0.98, 0.93, 0.78, 0.85), 3.0, true)
				else:
					draw_polyline(points, Color(0.08, 0.05, 0.12, 0.25), 3.0, true)
			elif style == "full":
				_dashes(points, Color(UIStyle.MUTED, 0.35), 4.0, false)
			elif style == "subtle":
				_dashes(points, Color(1, 1, 1, 0.22), 3.0, false)


## Nov 26 day (Part A): every link is drawn as one straight line from room to room, on every map (the zone dungeons, the minis, the
## postgame, the castle, the Halls, the drafts). The owner saw traced lines wander off the walkways; the path-curve system (the traced
## curves, the castle's stair lines, the fitted walkways) is off for drawing. Its data stays in `map_layout.json` ("curves") and the
## code below stays, in case it returns: set FOLLOW_CURVES and give the map screen its curves again.
const FOLLOW_CURVES: bool = false


## The line from room `from_id` to room `to_id` on the screen: a straight segment, walked in even steps (so the dashes march).
func link_points(from_id: int, to_id: int, from: Vector2, to: Vector2) -> PackedVector2Array:
	if not FOLLOW_CURVES:
		return straight_points(from, to)
	var key: String = "%d>%d" % [from_id, to_id]
	if not curves.has(key) or art_rect.size.x <= 0.0:
		return straight_points(from, to)
	var traced: PackedVector2Array = curves[key] as PackedVector2Array
	var control: PackedVector2Array = PackedVector2Array()
	for point: Vector2 in traced:
		control.append(art_rect.position + point * art_rect.size)
	# the ends are the rooms as they stand on the screen (a room may be nudged off its layout spot)
	control[0] = from
	control[control.size() - 1] = to
	return spaced(smoothed(control), CURVE_STEP)


## The straight segment from `from` to `to` in 40 even steps: every point on the one line.
static func straight_points(from: Vector2, to: Vector2) -> PackedVector2Array:
	var straight: PackedVector2Array = PackedVector2Array()
	for step: int in range(41):
		straight.append(from.lerp(to, float(step) / 40.0))
	return straight


## A Catmull-Rom curve through `control` (eight steps a span).
static func smoothed(control: PackedVector2Array) -> PackedVector2Array:
	if control.size() < 3:
		return control
	var result: PackedVector2Array = PackedVector2Array()
	for i: int in range(control.size() - 1):
		var p0: Vector2 = control[maxi(i - 1, 0)]
		var p1: Vector2 = control[i]
		var p2: Vector2 = control[i + 1]
		var p3: Vector2 = control[mini(i + 2, control.size() - 1)]
		for step: int in range(8):
			var t: float = float(step) / 8.0
			result.append(0.5 * ((2.0 * p1) + (-p0 + p2) * t + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t * t + (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t * t * t))
	result.append(control[control.size() - 1])
	return result


## `points` walked again in even steps of `step` pixels.
static func spaced(points: PackedVector2Array, step: float) -> PackedVector2Array:
	var result: PackedVector2Array = PackedVector2Array()
	if points.size() < 2:
		return points
	result.append(points[0])
	var carry: float = 0.0
	for i: int in range(points.size() - 1):
		var a: Vector2 = points[i]
		var b: Vector2 = points[i + 1]
		var length: float = a.distance_to(b)
		var at: float = step - carry
		while at <= length:
			result.append(a.lerp(b, at / length))
			at += step
		carry = fmod(carry + length, step)
	if result[result.size() - 1].distance_to(points[points.size() - 1]) > 0.5:
		result.append(points[points.size() - 1])
	return result


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
