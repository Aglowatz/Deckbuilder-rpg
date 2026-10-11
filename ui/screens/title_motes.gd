class_name TitleMotes
extends Control
## Drifting specks of light over the title art (golden pollen by day, warm lantern sparks at sunrise): a few dozen tiny circles that rise slowly and twinkle.
## Cosmetic only; costs nothing measurable (one draw pass of ~40 circles).

const COUNT: int = 42

var tint: Color = Color(1.0, 0.9, 0.6)
var _motes: Array[Vector4] = []   # x, y (0..1 of the size), speed, phase
var _time: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 1234
	for index: int in range(COUNT):
		_motes.append(Vector4(rng.randf(), rng.randf(), rng.randf_range(0.004, 0.012), rng.randf() * TAU))


func _process(delta: float) -> void:
	_time += delta
	for index: int in range(_motes.size()):
		var mote: Vector4 = _motes[index]
		mote.y -= mote.z * delta
		mote.x += sin(_time * 0.3 + mote.w) * 0.0006
		if mote.y < -0.02:
			mote.y = 1.02
		_motes[index] = mote
	queue_redraw()


func _draw() -> void:
	for mote: Vector4 in _motes:
		var twinkle: float = 0.5 + 0.5 * sin(_time * 1.3 + mote.w)
		var radius: float = 1.4 + 2.2 * mote.z * 100.0 * 0.5
		var colour: Color = Color(tint.r, tint.g, tint.b, 0.12 + 0.35 * twinkle)
		draw_circle(Vector2(mote.x * size.x, mote.y * size.y), radius, colour)
		draw_circle(Vector2(mote.x * size.x, mote.y * size.y), radius * 2.6, Color(colour.r, colour.g, colour.b, colour.a * 0.18))
