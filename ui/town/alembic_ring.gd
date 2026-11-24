class_name AlembicRing
extends Control
## Fable big pass Nov 23 (Part 8, mock-up B): the gold circle round Auntie Alembic and her cauldron, with the four Path sockets
## on it, and the stream of essence that pours from each chosen socket into the pot. Drawn, not painted: the ring, four star
## points on it, and one glowing ribbon per chosen Path (it shimmers; it stands still with Reduce motion on).

## The circle's centre and radii inside this control.
var centre: Vector2 = Vector2(500, 265)
var radii: Vector2 = Vector2(385, 250)
## Where the streams end (the pot's mouth).
var pot_mouth: Vector2 = Vector2(500, 330)
## Path -> its socket's centre.
var sockets: Dictionary = {}
## The chosen Paths, in the order they were picked.
var chosen: Array[Affinity.Type] = []
## Two layers share this script: the circle under Alembic's picture (`show_ring`) and the streams over it (`show_streams`).
var show_ring: bool = true
var show_streams: bool = true
var _time: float = 0.0

const RING_GOLD: Color = Color(1.0, 0.82, 0.42)
const STREAM_STEPS: int = 28


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(not Settings.reduce_motion)


func _process(delta: float) -> void:
	_time += delta
	if not chosen.is_empty():
		queue_redraw()


func set_chosen(paths: Array[Affinity.Type]) -> void:
	chosen = paths.duplicate()
	queue_redraw()


## The points of the stream from `path`'s socket into the pot: out of the socket toward the centre, then down into the mouth.
func stream_points(path: Affinity.Type) -> PackedVector2Array:
	var result: PackedVector2Array = PackedVector2Array()
	if not sockets.has(path):
		return result
	var from: Vector2 = sockets[path] as Vector2
	var side: float = signf(centre.x - from.x)
	var control_a: Vector2 = from + Vector2(side * 110.0, 150.0 if from.y < pot_mouth.y - 80.0 else -70.0)
	var control_b: Vector2 = pot_mouth + Vector2(-side * 70.0, -150.0)
	for step: int in range(STREAM_STEPS + 1):
		var t: float = float(step) / float(STREAM_STEPS)
		result.append(from.bezier_interpolate(control_a, control_b, pot_mouth, t))
	return result


func _draw() -> void:
	if show_ring:
		_draw_ring()
	if show_streams:
		_draw_streams()


func _draw_ring() -> void:
	# the circle (two thin lines, the outer one faint), and four star points where it crosses the axes
	for ring: int in range(2):
		var grow: float = 0.0 if ring == 0 else 14.0
		var points: PackedVector2Array = PackedVector2Array()
		for step: int in range(97):
			var angle: float = TAU * float(step) / 96.0
			points.append(centre + Vector2(cos(angle) * (radii.x + grow), sin(angle) * (radii.y + grow)))
		draw_polyline(points, Color(RING_GOLD, 0.62 if ring == 0 else 0.2), 3.0 if ring == 0 else 1.5, true)
	for corner: Vector2 in [Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0)]:
		_star(centre + corner * radii, 13.0)


func _draw_streams() -> void:
	# the streams of the chosen Paths
	for index: int in range(chosen.size()):
		var path: Affinity.Type = chosen[index]
		var points: PackedVector2Array = stream_points(path)
		if points.size() < 2:
			continue
		var colour: Color = UIStyle.affinity_color(path)
		draw_polyline(points, Color(colour, 0.2), 30.0, true)
		draw_polyline(points, Color(colour.lightened(0.15), 0.55), 15.0, true)
		draw_polyline(points, Color(colour.lightened(0.6), 0.95), 5.0, true)
		# drops running down the stream
		for drop: int in range(4):
			var along: float = fmod(_time * 0.55 + float(drop) * 0.25 + float(index) * 0.13, 1.0)
			var at: Vector2 = points[clampi(int(along * float(points.size() - 1)), 0, points.size() - 1)]
			draw_circle(at, 6.0 - 2.0 * along, Color(1, 1, 1, 0.85 * (1.0 - along * 0.5)))


func _star(at: Vector2, size: float) -> void:
	var points: PackedVector2Array = PackedVector2Array([
		at + Vector2(0, -size), at + Vector2(size * 0.24, -size * 0.24), at + Vector2(size, 0), at + Vector2(size * 0.24, size * 0.24),
		at + Vector2(0, size), at + Vector2(-size * 0.24, size * 0.24), at + Vector2(-size, 0), at + Vector2(-size * 0.24, -size * 0.24)])
	draw_colored_polygon(points, Color(RING_GOLD, 0.95))
