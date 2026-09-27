class_name BattleFX
extends Control
## Effects layer drawn above the board: floating numbers, targeting arrows, particle bursts,
## card dissolves and screen shake.

const NOISE_SHADER: String = "res://ui/shaders/dissolve.gdshader"

var arrows: Array[Dictionary] = []
var shake_target: Control
var _shake_tween: Tween
var _noise: NoiseTexture2D


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
	tween.tween_property(label, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "position:y", label.position.y - 70.0, 0.9).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.35).set_delay(0.65)
	tween.chain().tween_callback(label.queue_free)


func burst(pos: Vector2, color: Color, amount: int = 24, speed: float = 260.0) -> void:
	var particles: CPUParticles2D = CPUParticles2D.new()
	particles.position = pos
	particles.emitting = false
	particles.one_shot = true
	particles.amount = amount
	particles.lifetime = 0.7
	particles.explosiveness = 1.0
	particles.spread = 180.0
	particles.gravity = Vector2(0, 380)
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
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(ring, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(ring, "modulate:a", 0.0, 0.35)
	tween.chain().tween_callback(ring.queue_free)


func shake(strength: float = 14.0, duration: float = 0.3) -> void:
	if shake_target == null:
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
