class_name BattleFX
extends Control
## Effects layer drawn above the board: floating numbers, targeting arrows, particle bursts,
## card dissolves and screen shake.

const NOISE_SHADER: String = "res://ui/shaders/dissolve.gdshader"

var arrows: Array[Dictionary] = []
var shake_target: Control
var _shake_tween: Tween
var _noise: NoiseTexture2D
## Graphics Tier 1, Part 3: every burst and ring also lights the table (BattleLights, set by BattleScreen; null in tests).
var lights: BattleLights
## Battle feel (overnight Oct 28-29, Part 4): the battle speed (1 = normal; BattleBoard.speed sets it, and holding Space hurries it).
## Every timed effect here runs this much faster, so nothing outlasts the turn it belongs to.
var speed: float = 1.0


func _ready() -> void:
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_noise = NoiseTexture2D.new()
	_noise.noise = FastNoiseLite.new()
	_noise.width = 256
	_noise.height = 256


func _process(_delta: float) -> void:
	if not arrows.is_empty():
		queue_redraw()


func _draw() -> void:
	for arrow: Dictionary in arrows:
		_draw_arrow(arrow["from"] as Vector2, arrow["to"] as Vector2, arrow["color"] as Color, bool(arrow.get("head", true)))


func _draw_arrow(from: Vector2, to: Vector2, color: Color, head: bool) -> void:
	var mid: Vector2 = (from + to) * 0.5 + Vector2(0, -abs(to.x - from.x) * 0.12 - 40.0)
	var points: PackedVector2Array = PackedVector2Array()
	for step: int in range(25):
		var t: float = float(step) / 24.0
		points.append(from.lerp(mid, t).lerp(mid.lerp(to, t), t))
	draw_polyline(points, Color(0, 0, 0, 0.5), 12.0, true)
	draw_polyline(points, color, 7.0, true)
	if head and points.size() > 2:
		var tip: Vector2 = points[points.size() - 1]
		var direction: Vector2 = (tip - points[points.size() - 3]).normalized()
		var side: Vector2 = Vector2(-direction.y, direction.x)
		var triangle: PackedVector2Array = PackedVector2Array([
			tip + direction * 18.0, tip - direction * 14.0 + side * 16.0, tip - direction * 14.0 - side * 16.0,
		])
		draw_colored_polygon(triangle, color)
		draw_polyline(PackedVector2Array([triangle[0], triangle[1], triangle[2], triangle[0]]), Color(0, 0, 0, 0.5), 2.0)


func set_arrows(list: Array[Dictionary]) -> void:
	arrows = list
	queue_redraw()


func clear_arrows() -> void:
	arrows = []
	queue_redraw()


## A number or word that floats up from `pos` and fades.
func floating_text(pos: Vector2, text: String, color: Color, size: int = 44) -> void:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_override("font", UIStyle.font_title())
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("outline_size", 10)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = 300
	add_child(label)
	label.reset_size()
	label.position = pos - label.size * 0.5
	label.pivot_offset = label.size * 0.5
	label.scale = Vector2(0.4, 0.4)
	var tween: Tween = create_tween().set_parallel(true)
	var pace: float = 1.0 / maxf(speed, 0.1)
	# Pops past full size, settles, floats up and fades (overnight Oct 28-29: a clearer pop).
	tween.tween_property(label, "scale", Vector2(1.18, 1.18), 0.1 * pace).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(label, "scale", Vector2.ONE, 0.1 * pace).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "position:y", label.position.y - 70.0, 0.8 * pace).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.3 * pace).set_delay(0.45 * pace)
	tween.chain().tween_callback(label.queue_free)


func burst(pos: Vector2, color: Color, amount: int = 24, speed: float = 260.0) -> void:
	var particles: CPUParticles2D = CPUParticles2D.new()
	particles.position = pos
	particles.emitting = false
	particles.one_shot = true
	particles.amount = amount
	particles.lifetime = 0.7 / clampf(speed, 1.0, 2.5)
	particles.explosiveness = 1.0
	particles.spread = 180.0
	particles.gravity = Vector2(0, 380) * clampf(speed, 1.0, 2.5)
	particles.initial_velocity_min = speed * 0.4
	particles.initial_velocity_max = speed
	particles.scale_amount_min = 4.0
	particles.scale_amount_max = 9.0
	particles.color = color
	var ramp: Gradient = Gradient.new()
	ramp.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	particles.color_ramp = ramp
	particles.z_index = 250
	add_child(particles)
	particles.emitting = true
	if lights != null:
		lights.pulse(pos, color, 220.0 + float(amount) * 5.0, 0.9, 0.55)
	get_tree().create_timer(1.2, false).timeout.connect(particles.queue_free)


## A ring flash (spell impact, Wellspring pulse).
func flash_ring(pos: Vector2, color: Color, radius: float = 110.0) -> void:
	var ring: Panel = Panel.new()
	ring.size = Vector2(radius, radius) * 2.0
	ring.position = pos - ring.size * 0.5
	ring.pivot_offset = ring.size * 0.5
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ring.add_theme_stylebox_override("panel", UIStyle.box(Color(color, 0.18), color, 6, int(radius)))
	ring.scale = Vector2(0.2, 0.2)
	ring.z_index = 240
	add_child(ring)
	if lights != null:
		lights.pulse(pos, color, radius * 2.6, 1.1, 0.45)
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(ring, "scale", Vector2.ONE, 0.35 / maxf(speed, 0.1)).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(ring, "modulate:a", 0.0, 0.35 / maxf(speed, 0.1))
	tween.chain().tween_callback(ring.queue_free)


# ---- Combat feel 2.0 (Overnight Oct 17, Part 8) -------------------------------------------------------------------

## The game time scale during a hit pause / the final blow's slow motion; restored to 1.0 afterwards (real-time timers).
const HIT_PAUSE_SCALE: float = 0.06
const FINAL_BLOW_SCALE: float = 0.3
static var _time_holds: int = 0


## A short freeze on impact: the game nearly stops for `seconds` of real time (scaled to the blow by the caller), then resumes.
## Nested pauses never stack past one restore.
func hit_pause(seconds: float) -> void:
	await _hold_time(HIT_PAUSE_SCALE, clampf(seconds, 0.0, 0.12))


## The final blow in slow motion: everything runs at 30 % for `seconds` of real time.
func slow_motion(seconds: float = 0.55) -> void:
	await _hold_time(FINAL_BLOW_SCALE, seconds)


func _hold_time(scale: float, seconds: float) -> void:
	if seconds <= 0.0 or not is_inside_tree():
		return
	_time_holds += 1
	Engine.time_scale = minf(Engine.time_scale, scale)
	await get_tree().create_timer(seconds, true, false, true).timeout
	_time_holds = maxi(0, _time_holds - 1)
	if _time_holds == 0:
		Engine.time_scale = 1.0


## Leaving the battle mid-pause must never leave the game slowed down.
func _exit_tree() -> void:
	if _time_holds > 0:
		_time_holds = 0
		Engine.time_scale = 1.0


## The struck card jolts away from the blow and settles back.
func recoil(view: Control, away_from: Vector2, strength: float = 16.0) -> void:
	if view == null or not is_instance_valid(view):
		return
	var origin: Vector2 = view.position
	var centre: Vector2 = view.global_position + view.size * view.scale * 0.5
	var push: Vector2 = (centre - away_from).normalized() * strength
	if push == Vector2.ZERO:
		push = Vector2(0, -strength)
	var tween: Tween = create_tween().set_trans(Tween.TRANS_QUAD)
	tween.tween_property(view, "position", origin + push, 0.05).set_ease(Tween.EASE_OUT)
	tween.tween_property(view, "position", origin, 0.18).set_ease(Tween.EASE_IN_OUT)


## A ribbon swept across the screen at the start of a turn ("YOUR TURN" / "ENEMY TURN").
func turn_banner(text: String, color: Color, duration: float = 0.75, subtitle: String = "") -> void:
	var band: Panel = Panel.new()
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	band.size = Vector2(1920, 96)
	band.position = Vector2(0, 452)
	band.add_theme_stylebox_override("panel", UIStyle.box(Color(0.04, 0.03, 0.08, 0.72), Color(color, 0.85), 0, 0))
	band.z_index = 260
	add_child(band)
	var label: Label = UIKit.label(text, &"", 64, color, HORIZONTAL_ALIGNMENT_CENTER)
	label.add_theme_font_override("font", UIStyle.font_title())
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("outline_size", 10)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = band.size
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	band.add_child(label)
	if not subtitle.is_empty():
		# Overnight Oct 28-29: the turn number under the words, small, so the band says whose turn and which one at a glance.
		var sub: Label = UIKit.label(subtitle, &"", 22, Color(color, 0.85), HORIZONTAL_ALIGNMENT_CENTER)
		sub.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
		sub.add_theme_constant_override("outline_size", 6)
		sub.size = Vector2(band.size.x, 26)
		sub.position = Vector2(0, band.size.y - 24)
		sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_child(sub)
		label.position.y = -8.0
	band.modulate.a = 0.0
	label.position.x = -260.0
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(band, "modulate:a", 1.0, duration * 0.18)
	tween.tween_property(label, "position:x", 0.0, duration * 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.chain().tween_interval(duration * 0.42)
	tween.chain().set_parallel(true).tween_property(band, "modulate:a", 0.0, duration * 0.28)
	tween.tween_property(label, "position:x", 260.0, duration * 0.28).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(band.queue_free)


## A glowing mote that flies from one point to another on a shallow arc (a resource made by a card flying to its counter, a spent one
## leaving it) and calls back when it lands. Overnight Oct 28-29. Never waited on: it plays beside the turn, not inside it.
func fly_mote(from: Vector2, to: Vector2, color: Color, landed: Callable = Callable(), seconds: float = 0.32) -> void:
	var mote: Panel = Panel.new()
	mote.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mote.size = Vector2(26, 26)
	mote.pivot_offset = mote.size * 0.5
	mote.add_theme_stylebox_override("panel", UIStyle.box(Color(color.lightened(0.35), 0.95), Color(1, 1, 1, 0.9), 3, 13))
	mote.z_index = 270
	mote.position = from - mote.size * 0.5
	add_child(mote)
	var control: Vector2 = (from + to) * 0.5 + Vector2(0, -minf(from.distance_to(to) * 0.35, 140.0))
	var duration: float = seconds / maxf(speed, 0.1)
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_method(func(t: float) -> void:
		if is_instance_valid(mote):
			var u: float = 1.0 - t
			mote.position = from * u * u + control * 2.0 * u * t + to * t * t - mote.size * 0.5, 0.0, 1.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(mote, "scale", Vector2(0.6, 0.6), duration).from(Vector2(1.25, 1.25))
	tween.chain().tween_callback(func() -> void:
		if landed.is_valid():
			landed.call()
		mote.queue_free())


func shake(strength: float = 14.0, duration: float = 0.3) -> void:
	if shake_target == null or Settings.reduce_shake:
		return
	if _shake_tween != null and _shake_tween.is_valid():
		_shake_tween.kill()
	shake_target.position = Vector2.ZERO
	_shake_tween = create_tween()
	var steps: int = 8
	for step: int in range(steps):
		var falloff: float = 1.0 - float(step) / float(steps)
		var offset: Vector2 = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * strength * falloff
		_shake_tween.tween_property(shake_target, "position", offset, duration / float(steps))
	_shake_tween.tween_property(shake_target, "position", Vector2.ZERO, 0.04)


## Dissolves a card into nothing. The card is moved into a CanvasGroup so the whole card fades
## through one noise shader; the group is freed afterwards. Returns when finished.
func dissolve(card: Control, color: Color, duration: float = 0.6) -> void:
	var group: CanvasGroup = CanvasGroup.new()
	var old_parent: Node = card.get_parent()
	var global_pos: Vector2 = card.global_position
	var index_z: int = card.z_index
	old_parent.remove_child(card)
	add_child(group)
	group.z_index = index_z + 10
	group.add_child(card)
	card.position = card.position
	group.global_position = Vector2.ZERO
	card.global_position = global_pos
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = load(NOISE_SHADER) as Shader
	material.set_shader_parameter("noise", _noise)
	material.set_shader_parameter("edge_color", color.lightened(0.3))
	material.set_shader_parameter("progress", 0.0)
	group.material = material
	burst(global_pos + card.size * 0.5 * card.scale.x, color, 22, 200.0)
	var tween: Tween = create_tween()
	tween.tween_method(func(value: float) -> void: material.set_shader_parameter("progress", value), 0.0, 1.0, duration)
	await tween.finished
	group.queue_free()
