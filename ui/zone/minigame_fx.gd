class_name MinigameFx
extends RefCounted
## Overnight Nov 7-8, Part 6.2 (docs/design/minigame_graphics_plan.md): the code-only flourishes every zone minigame shares - no new images.
## A spark burst where the player scored, a shake on a miss, a gold flash and a confetti shower on a win, a red pulse on a loss.

const SPARK: Color = Color("ffe08a")
const CONFETTI: Array[Color] = [Color("f2c35a"), Color("6fdc7a"), Color("7fc8ff"), Color("ff8ab0"), Color("fff3b0")]


## A short burst of sparks at `at` (global canvas position) on `host`.
static func sparkle(host: Node, at: Vector2, color: Color = SPARK, amount: int = 18) -> void:
	if host == null or not host.is_inside_tree():
		return
	var burst: CPUParticles2D = CPUParticles2D.new()
	burst.name = "FxSparkle"
	burst.position = at
	burst.amount = amount
	burst.lifetime = 0.7
	burst.one_shot = true
	burst.explosiveness = 0.95
	burst.spread = 180.0
	burst.initial_velocity_min = 140.0
	burst.initial_velocity_max = 320.0
	burst.gravity = Vector2(0, 400)
	burst.scale_amount_min = 3.0
	burst.scale_amount_max = 7.0
	burst.color = color
	burst.z_index = 60
	host.add_child(burst)
	burst.emitting = true
	host.get_tree().create_timer(1.0).timeout.connect(burst.queue_free)


## Sparks where the mouse is (the click that scored).
static func sparkle_at_mouse(host: CanvasItem) -> void:
	if host != null and host.is_inside_tree():
		sparkle(host, host.get_global_mouse_position())


## A quick side-to-side shake of `node` (a miss).
static func shake(node: Control, strength: float = 8.0) -> void:
	if node == null or not node.is_inside_tree():
		return
	var base: Vector2 = node.position
	var tween: Tween = node.create_tween()
	for k: int in range(4):
		tween.tween_property(node, "position", base + Vector2(strength if k % 2 == 0 else -strength, 0.0), 0.04)
	tween.tween_property(node, "position", base, 0.05)


## The end of a game: a gold flash and a confetti shower for a win, a red pulse for a loss.
static func finish(host: Control, won: bool) -> void:
	if host == null or not host.is_inside_tree():
		return
	var flash: ColorRect = ColorRect.new()
	flash.name = "FxFlash"
	flash.color = Color(1.0, 0.85, 0.4, 0.28) if won else Color(1.0, 0.3, 0.25, 0.22)
	flash.size = Vector2(1920, 1080)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.z_index = 55
	host.add_child(flash)
	var tween: Tween = flash.create_tween()
	tween.tween_property(flash, "color:a", 0.0, 0.6)
	tween.tween_callback(flash.queue_free)
	if not won:
		return
	for i: int in range(5):
		var shower: CPUParticles2D = CPUParticles2D.new()
		shower.name = "FxConfetti"
		shower.position = Vector2(200.0 + float(i) * 380.0, -20.0)
		shower.amount = 40
		shower.lifetime = 2.2
		shower.one_shot = true
		shower.explosiveness = 0.7
		shower.direction = Vector2.DOWN
		shower.spread = 35.0
		shower.initial_velocity_min = 120.0
		shower.initial_velocity_max = 260.0
		shower.gravity = Vector2(0, 260)
		shower.angular_velocity_min = -360.0
		shower.angular_velocity_max = 360.0
		shower.scale_amount_min = 5.0
		shower.scale_amount_max = 10.0
		shower.color = CONFETTI[i % CONFETTI.size()]
		shower.z_index = 56
		host.add_child(shower)
		shower.emitting = true
		host.get_tree().create_timer(2.6).timeout.connect(shower.queue_free)
