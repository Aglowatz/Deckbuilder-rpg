class_name PackFx
extends RefCounted
## Small particle and light helpers for the pack-opening screen (all drawn in code, no assets).

static var _dot: Texture2D
static var _spark: Texture2D


static func dot() -> Texture2D:
	if _dot == null:
		_dot = UIStyle.circle_texture(24, Color(1, 1, 1, 1))
	return _dot


## A soft 4-point star used for sparkles.
static func spark() -> Texture2D:
	if _spark == null:
		var image: Image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
		for y: int in range(32):
			for x: int in range(32):
				var dx: float = absf(float(x) - 15.5) / 15.5
				var dy: float = absf(float(y) - 15.5) / 15.5
				var value: float = maxf(0.0, 1.0 - (dx * 6.0 + dy * 0.6)) + maxf(0.0, 1.0 - (dy * 6.0 + dx * 0.6))
				value = clampf(value + maxf(0.0, 0.5 - (dx + dy)) * 0.8, 0.0, 1.0)
				image.set_pixel(x, y, Color(1, 1, 1, value))
		_spark = ImageTexture.create_from_image(image)
	return _spark


## A one-shot burst of particles at `at` (in `parent`'s space). Frees itself.
static func burst(parent: Node, at: Vector2, color: Color, amount: int = 30, speed: float = 380.0, lifetime: float = 1.0, star: bool = false) -> CPUParticles2D:
	var particles: CPUParticles2D = CPUParticles2D.new()
	particles.position = at
	particles.amount = amount
	particles.one_shot = true
	particles.explosiveness = 0.95
	particles.lifetime = lifetime
	particles.direction = Vector2.UP
	particles.spread = 180.0
	particles.gravity = Vector2(0, 260)
	particles.initial_velocity_min = speed * 0.4
	particles.initial_velocity_max = speed
	particles.scale_amount_min = 0.25 if not star else 0.5
	particles.scale_amount_max = 0.7 if not star else 1.3
	particles.texture = spark() if star else dot()
	var ramp: Gradient = Gradient.new()
	ramp.set_color(0, color)
	ramp.set_color(1, Color(color.r, color.g, color.b, 0.0))
	particles.color_ramp = ramp
	particles.z_index = 50
	parent.add_child(particles)
	particles.emitting = true
	particles.get_tree().create_timer(lifetime + 0.5).timeout.connect(particles.queue_free)
	return particles


## A rising stream of sparkles (for a card that keeps glowing). Returns the emitter so the caller can stop it.
static func sparkle_stream(parent: Node, at: Vector2, width: float, color: Color, amount: int = 24) -> CPUParticles2D:
	var particles: CPUParticles2D = CPUParticles2D.new()
	particles.position = at
	particles.amount = amount
	particles.lifetime = 1.6
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(width * 0.5, 6.0)
	particles.direction = Vector2.UP
	particles.spread = 12.0
	particles.gravity = Vector2(0, -20)
	particles.initial_velocity_min = 30.0
	particles.initial_velocity_max = 90.0
	particles.scale_amount_min = 0.3
	particles.scale_amount_max = 0.9
	particles.texture = spark()
	var ramp: Gradient = Gradient.new()
	ramp.set_color(0, color)
	ramp.set_color(1, Color(color.r, color.g, color.b, 0.0))
	particles.color_ramp = ramp
	particles.z_index = 40
	parent.add_child(particles)
	particles.emitting = true
	return particles


## A full-screen colour flash that fades out. `host` must be a Control.
static func flash(host: Control, color: Color, peak: float, duration: float) -> void:
	var overlay: ColorRect = ColorRect.new()
	overlay.color = color
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UIKit.full_rect(overlay)
	overlay.modulate.a = peak
	overlay.z_index = 90
	host.add_child(overlay)
	var tween: Tween = overlay.create_tween()
	tween.tween_property(overlay, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(overlay.queue_free)


## An expanding ring that fades (a shockwave). `host` is any Control; `at` is its centre.
static func ring(host: Control, at: Vector2, color: Color, radius: float, duration: float = 0.7) -> void:
	var node: PackRing = PackRing.new()
	node.color = color
	node.position = at
	node.z_index = 45
	host.add_child(node)
	var tween: Tween = node.create_tween().set_parallel(true)
	tween.tween_property(node, "radius", radius, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate:a", 0.0, duration)
	tween.chain().tween_callback(node.queue_free)


## Draws one expanding ring.
class PackRing:
	extends Node2D
	var color: Color = Color.WHITE
	var radius: float = 10.0:
		set(value):
			radius = value
			queue_redraw()

	func _draw() -> void:
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 72, color, maxf(2.0, 14.0 - radius * 0.02), true)


## God rays: wedges of light turning slowly around the centre.
class Rays:
	extends Node2D
	var color: Color = Color(1.0, 0.8, 0.3, 0.5)
	var length: float = 900.0
	var wedges: int = 14
	var spin: float = 0.35

	func _process(delta: float) -> void:
		rotation += spin * delta

	func _draw() -> void:
		for index: int in range(wedges):
			var angle: float = TAU * float(index) / float(wedges)
			var half: float = TAU / float(wedges) * 0.22
			var points: PackedVector2Array = PackedVector2Array([
				Vector2.ZERO,
				Vector2.from_angle(angle - half) * length,
				Vector2.from_angle(angle + half) * length,
			])
			var colors: PackedColorArray = PackedColorArray([color, Color(color.r, color.g, color.b, 0.0), Color(color.r, color.g, color.b, 0.0)])
			draw_polygon(points, colors)
