class_name CutsceneScreen
extends Control
## A short dungeon cutscene (Part E): two icon "actors" on a themed stage, a speaker line and typewriter text,
## advance with a click, Space or Enter. Each beat can fire a visual effect (`CutsceneDefs`): the
## doppelganger's mask coming off, the starved prisoner standing up, Grandmaster Flex throwing off his coat to
## reveal he is still incredibly muscular, the Archdruid's roots retracting. All text is in the zone story.

signal finished

## Per scene: the stage theme (backdrop tint) and the two actors (left/right): icon, tint, scale and name.
const STAGES: Dictionary = {
	"reveal": {
		"tint": Color(0.12, 0.2, 0.1),
		"left": {"icon": "delapouite/chef-toque", "color": Color("f2ead8"), "scale": 1.0},
		"right": {"icon": "lorc/pointy-hat", "color": Color("d9b86a"), "scale": 0.8},
	},
	"rescue": {
		"tint": Color(0.16, 0.08, 0.08),
		"left": {"icon": "delapouite/prisoner", "color": Color("b9a99a"), "scale": 0.85, "squash": 0.55},
		"right": {"icon": "lorc/pointy-hat", "color": Color("d9b86a"), "scale": 0.8},
	},
	"flex": {
		"tint": Color(0.2, 0.06, 0.06),
		"left": {"icon": "delapouite/prisoner", "color": Color("b9a99a"), "scale": 0.9, "squash": 0.55, "coat": true},
		"right": {"icon": "delapouite/viking-head", "color": Color("e2553f"), "scale": 1.15},
	},
	"wonder": {
		"tint": Color(0.2, 0.15, 0.06),
		"left": {"icon": "delapouite/chef-toque", "color": Color("f6e7b4"), "scale": 1.1},
		"right": {"icon": "lorc/pointy-hat", "color": Color("d9b86a"), "scale": 0.8},
	},
	"vacancy": {
		"tint": Color(0.08, 0.14, 0.14),
		"left": {"icon": "lorc/ghost", "color": Color("cfe3e3"), "scale": 1.05},
		"right": {"icon": "lorc/pointy-hat", "color": Color("d9b86a"), "scale": 0.8},
	},
	"sever": {
		"tint": Color(0.1, 0.06, 0.14),
		"left": {"icon": "cathelineau/tree-face", "color": Color("7bc86c"), "scale": 1.1, "roots": true},
		"right": {"icon": "lorc/pointy-hat", "color": Color("d9b86a"), "scale": 0.8},
	},
	# Brief 10: Primm (left) and you (right), before the fight, between its phases and after it.
	"primm_intro": {
		"tint": Color(0.16, 0.12, 0.05),
		"left": {"icon": "cathelineau/old-king", "color": Color("f2d070"), "scale": 1.1},
		"right": {"icon": "lorc/pointy-hat", "color": Color("d9b86a"), "scale": 0.8},
	},
	"primm_reveal": {
		"tint": Color(0.16, 0.1, 0.12),
		"left": {"icon": "cathelineau/old-king", "color": Color("f2d070"), "scale": 1.1},
		"right": {"icon": "lorc/pointy-hat", "color": Color("d9b86a"), "scale": 0.8},
	},
	"primm_p1": {
		"tint": Color(0.14, 0.12, 0.12),
		"left": {"icon": "cathelineau/old-king", "color": Color("f2d070"), "scale": 1.1},
		"right": {"icon": "lorc/pointy-hat", "color": Color("d9b86a"), "scale": 0.8},
	},
	"primm_p2": {
		"tint": Color(0.06, 0.12, 0.16),
		"left": {"icon": "delapouite/shinto-shrine-mirror", "color": Color("b8e8ff"), "scale": 1.1},
		"right": {"icon": "lorc/pointy-hat", "color": Color("d9b86a"), "scale": 0.8},
	},
	"primm_end": {
		"tint": Color(0.1, 0.08, 0.14),
		"left": {"icon": "cathelineau/old-king", "color": Color("cfc8d8"), "scale": 0.95},
		"right": {"icon": "lorc/pointy-hat", "color": Color("d9b86a"), "scale": 0.8},
	},
}

var scene_id: String = ""
var _story: ZoneStoryText
var _beats: Array[Dictionary] = []
var _index: int = 0
var _left: TextureRect
var _right: TextureRect
var _extras: Control
var _speaker: Label
var _text: Label
var _hint: Label
var _flash: ColorRect
var _tween: Tween
var _shake_origin: Vector2 = Vector2.ZERO
var _stage_root: Control
var _done: bool = false


static func make(scene: String) -> CutsceneScreen:
	var screen: CutsceneScreen = CutsceneScreen.new()
	screen.name = "CutsceneScreen"
	screen.scene_id = scene
	return screen


func _ready() -> void:
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 300
	_story = ZoneStoryText.for_zone(CutsceneDefs.zone_of(scene_id))
	_beats = CutsceneDefs.beats(scene_id)
	var stage: Dictionary = STAGES.get(scene_id, STAGES["reveal"]) as Dictionary
	var backdrop: ColorRect = ColorRect.new()
	backdrop.color = (stage["tint"] as Color).darkened(0.1)
	UIKit.full_rect(backdrop)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	var glow: ColorRect = UIKit.gradient_background()
	glow.modulate.a = 0.5
	add_child(glow)
	_stage_root = Control.new()
	UIKit.full_rect(_stage_root)
	_stage_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stage_root)
	_extras = Control.new()
	UIKit.full_rect(_extras)
	_extras.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage_root.add_child(_extras)
	_left = _actor(stage["left"] as Dictionary, Vector2(360, 330))
	_right = _actor(stage["right"] as Dictionary, Vector2(1180, 340))
	_stage_root.add_child(_left)
	_stage_root.add_child(_right)
	if bool((stage["left"] as Dictionary).get("coat", false)):
		_add_coat()
	if bool((stage["left"] as Dictionary).get("roots", false)):
		_add_roots()
	var panel: PanelContainer = UIKit.panel()
	panel.position = Vector2(300, 790)
	panel.custom_minimum_size = Vector2(1320, 210)
	panel.size = Vector2(1320, 210)
	add_child(panel)
	var column: VBoxContainer = UIKit.vbox(8)
	panel.add_child(column)
	_speaker = UIKit.label("", &"HeadingLabel", 32)
	column.add_child(_speaker)
	_text = UIKit.label("", &"", 27, UIStyle.PARCHMENT)
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.custom_minimum_size = Vector2(1270, 100)
	column.add_child(_text)
	_hint = UIKit.label("Click / Space to continue", &"MutedLabel", 18, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_RIGHT)
	column.add_child(_hint)
	_flash = ColorRect.new()
	_flash.color = Color(1, 1, 1, 0)
	UIKit.full_rect(_flash)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.z_index = 50
	add_child(_flash)
	_shake_origin = _stage_root.position
	_show_beat()


func _actor(spec: Dictionary, center: Vector2) -> TextureRect:
	var side: float = 380.0 * float(spec.get("scale", 1.0))
	var rect: TextureRect = CardIcons.glyph(CardIcons.named(str(spec["icon"])), spec["color"] as Color, Vector2(side, side))
	rect.size = Vector2(side, side)
	rect.pivot_offset = rect.size * 0.5
	rect.position = center - rect.size * 0.5
	rect.set_meta("squash", float(spec.get("squash", 1.0)))
	rect.scale = Vector2(float(spec.get("squash", 1.0)), 1.0)
	return rect


func _add_coat() -> void:
	var coat: TextureRect = CardIcons.glyph(CardIcons.named("delapouite/fur-shirt"), Color("7a5a3a"), Vector2(260, 260))
	coat.name = "Coat"
	coat.size = Vector2(260, 260)
	coat.pivot_offset = coat.size * 0.5
	coat.position = _left.position + Vector2(60, 110)
	coat.scale = Vector2(0.55, 1.0)
	_stage_root.add_child(coat)


func _add_roots() -> void:
	var roots: TextureRect = CardIcons.glyph(CardIcons.named("delapouite/tree-roots"), Color("5a3a2a"), Vector2(520, 520))
	roots.name = "Roots"
	roots.size = Vector2(520, 520)
	roots.pivot_offset = roots.size * 0.5
	roots.position = _left.position - Vector2(70, -20)
	roots.modulate.a = 0.75
	_extras.add_child(roots)


func _show_beat() -> void:
	var beat: Dictionary = _beats[_index]
	var speaker: String = _story.text(str(beat["speaker_key"]))
	_speaker.text = speaker
	var lines: Array[String] = _story.get_lines(str(beat["key"]))
	_text.text = "\n".join(lines)
	_text.visible_ratio = 0.0
	_hint.text = "Click / Space to finish" if _index == _beats.size() - 1 else "Click / Space to continue"
	var speaks_left: bool = _is_left_speaker(speaker)
	_left.modulate = Color(1, 1, 1, 1) if speaks_left else Color(0.6, 0.6, 0.66, 1)
	_right.modulate = Color(0.6, 0.6, 0.66, 1) if speaks_left else Color(1, 1, 1, 1)
	if _tween != null and _tween.is_valid():
		_tween.kill()
	var duration: float = maxf(0.5, float(_text.text.length()) * 0.016)
	_tween = create_tween()
	_tween.tween_property(_text, "visible_ratio", 1.0, duration)
	Audio.sfx(&"dialogue", -10.0)
	_fx(str(beat["fx"]))


## The left actor is the leader/boss; "You" is always the right actor.
func _is_left_speaker(speaker: String) -> bool:
	return speaker != "You" and not speaker.is_empty()


## The screen stops the mouse (so nothing behind it is clicked), which also keeps clicks away from `_unhandled_input`: handle the click here.
func _gui_input(event: InputEvent) -> void:
	if _done:
		return
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		advance()


func _unhandled_input(event: InputEvent) -> void:
	if _done:
		return
	var pressed: bool = false
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo:
		var code: Key = (event as InputEventKey).keycode
		pressed = code == KEY_SPACE or code == KEY_ENTER or code == KEY_E
	elif event is InputEventMouseButton and (event as InputEventMouseButton).pressed and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		pressed = true
	if not pressed:
		return
	get_viewport().set_input_as_handled()
	advance()


## Finishes the typewriter, or moves to the next beat (and out at the end).
func advance() -> void:
	if _text.visible_ratio < 1.0:
		if _tween != null and _tween.is_valid():
			_tween.kill()
		_text.visible_ratio = 1.0
		return
	_index += 1
	if _index >= _beats.size():
		_done = true
		finished.emit()
		queue_free()
		return
	_show_beat()


# ---- Effects ----------------------------------------------------------------------------------


func _fx(name: String) -> void:
	match name:
		"shake":
			_shake(14.0, 0.45)
		"mask_off":
			_mask_off()
		"reveal_form":
			_reveal_form()
		"stand_up":
			_stand_up()
		"coat_off":
			_coat_off()
		"muscle_reveal":
			_muscle_reveal()
		"stagger":
			_stagger()
		"roots_retract":
			_roots_retract()
		"cleansed":
			_cleansed()
		"crown":
			_flash_screen(Color("ffd36b"), 0.7)
			_burst(_left.position + _left.size * 0.5, Color("ffd36b"), 80)
			Audio.sfx(&"victory", -6.0)
		"crack":
			_flash_screen(Color("ffffff"), 0.9)
			_shake(22.0, 0.6)
			_burst(_left.position + _left.size * 0.5, Color("cfc8d8"), 90)
			Audio.sfx(&"hit_heavy", 0.0)
		"mirror":
			_flash_screen(Color("b8e8ff"), 0.85)
			_shake(10.0, 0.4)
			Audio.sfx(&"spell", -2.0)
		"unravel":
			_flash_screen(Color("d8c8ff"), 0.8)
			_shake(26.0, 0.9)
			_burst(_left.position + _left.size * 0.5, Color("b8a8d8"), 130)
			Audio.sfx(&"hit_heavy", 0.0)
		"crown_off":
			_crown_off()
		"shrink":
			var shrink: Tween = create_tween()
			shrink.tween_property(_left, "scale", Vector2(0.78, 0.78), 1.2).set_trans(Tween.TRANS_CUBIC)
		"dove":
			_flash_screen(Color("f4fff0"), 0.7)
			_burst(_left.position + _left.size * 0.5, Color("f4fff0"), 70)
			Audio.sfx(&"heal")


func _shake(strength: float, duration: float) -> void:
	var shake: Tween = create_tween()
	var steps: int = int(duration / 0.04)
	for i: int in range(steps):
		shake.tween_property(_stage_root, "position", _shake_origin + Vector2(randf_range(-strength, strength), randf_range(-strength, strength)), 0.04)
	shake.tween_property(_stage_root, "position", _shake_origin, 0.05)


func _flash_screen(color: Color, peak: float = 0.9) -> void:
	_flash.color = Color(color.r, color.g, color.b, 0.0)
	var flash: Tween = create_tween()
	flash.tween_property(_flash, "color:a", peak, 0.08)
	flash.tween_property(_flash, "color:a", 0.0, 0.5)


func _burst(at: Vector2, color: Color, amount: int = 70) -> void:
	var particles: CPUParticles2D = CPUParticles2D.new()
	particles.position = at
	particles.emitting = false
	particles.one_shot = true
	particles.amount = amount
	particles.lifetime = 1.3
	particles.explosiveness = 1.0
	particles.spread = 180.0
	particles.gravity = Vector2(0, 260)
	particles.initial_velocity_min = 200.0
	particles.initial_velocity_max = 560.0
	particles.scale_amount_min = 4.0
	particles.scale_amount_max = 11.0
	var ramp: Gradient = Gradient.new()
	ramp.set_color(0, color)
	ramp.set_color(1, Color(color.r, color.g, color.b, 0.0))
	particles.color_ramp = ramp
	particles.z_index = 40
	add_child(particles)
	particles.emitting = true
	get_tree().create_timer(1.8, false).timeout.connect(particles.queue_free)


## The doppelganger's face slips off like a mask.
func _mask_off() -> void:
	var mask: TextureRect = CardIcons.glyph(CardIcons.named("delapouite/carnival-mask"), Color("f2ead8"), Vector2(250, 250))
	mask.size = Vector2(250, 250)
	mask.pivot_offset = mask.size * 0.5
	mask.position = _left.position + Vector2(65, 40)
	_stage_root.add_child(mask)
	Audio.sfx(&"hit_heavy", -4.0)
	var slide: Tween = create_tween().set_parallel(true)
	slide.tween_property(mask, "position", mask.position + Vector2(-220, 160), 0.9).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	slide.tween_property(mask, "rotation_degrees", -70.0, 0.9)
	slide.tween_property(mask, "modulate:a", 0.0, 0.9)
	slide.tween_callback(mask.queue_free).set_delay(1.0)
	var wobble: Tween = create_tween()
	wobble.tween_property(_left, "scale", Vector2(1.08, 0.94), 0.12)
	wobble.tween_property(_left, "scale", Vector2(0.94, 1.08), 0.12)
	wobble.tween_property(_left, "scale", Vector2.ONE, 0.12)


## ... and underneath is the doppelganger: a purple blob of the villain's making.
func _reveal_form() -> void:
	_flash_screen(Color("b46cff"), 0.85)
	_shake(18.0, 0.5)
	_left.texture = CardIcons.named("lorc/acid-blob")
	(_left.material as ShaderMaterial).set_shader_parameter("tint", Color("b46cff"))
	_left.scale = Vector2(1.25, 1.25)
	_burst(_left.position + _left.size * 0.5, Color("b46cff"))
	Audio.sfx(&"hit_heavy", 0.0)


func _stand_up() -> void:
	var stand: Tween = create_tween().set_parallel(true)
	stand.tween_property(_left, "scale", Vector2(1.0, 1.0), 0.9).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	stand.tween_property(_left, "modulate", Color(1.2, 1.15, 1.0), 0.9)
	Audio.sfx(&"heal")


func _coat_off() -> void:
	var coat: Node = _stage_root.get_node_or_null("Coat")
	if coat == null:
		return
	var fly: Tween = create_tween().set_parallel(true)
	fly.tween_property(coat, "position", (coat as Control).position + Vector2(-380, -260), 0.9).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	fly.tween_property(coat, "rotation_degrees", -260.0, 0.9)
	fly.tween_property(coat, "modulate:a", 0.0, 0.9).set_delay(0.3)
	Audio.sfx(&"spell", -2.0)


## Grandmaster Flex is NOT the starved prisoner he appeared to be: the whole silhouette swells into pure muscle.
func _muscle_reveal() -> void:
	_flash_screen(Color("ffd36b"), 0.95)
	_shake(20.0, 0.6)
	_left.texture = CardIcons.named("lorc/muscle-up")
	(_left.material as ShaderMaterial).set_shader_parameter("tint", Color("ffcf70"))
	var swell: Tween = create_tween()
	swell.tween_property(_left, "scale", Vector2(1.45, 1.45), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	swell.tween_property(_left, "scale", Vector2(1.3, 1.3), 0.4)
	_burst(_left.position + _left.size * 0.5, Color("ffcf70"), 110)
	Audio.sfx(&"victory", -2.0)


## His crown slips off and rolls away.
func _crown_off() -> void:
	var crown: TextureRect = CardIcons.glyph(CardIcons.named("delapouite/imperial-crown"), Color("f2d070"), Vector2(220, 220))
	crown.size = Vector2(220, 220)
	crown.pivot_offset = crown.size * 0.5
	crown.position = _left.position + Vector2(80, -30)
	_stage_root.add_child(crown)
	Audio.sfx(&"hit_heavy", -4.0)
	var fall: Tween = create_tween().set_parallel(true)
	fall.tween_property(crown, "position", crown.position + Vector2(-260, 420), 1.1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	fall.tween_property(crown, "rotation_degrees", -200.0, 1.1)
	fall.tween_property(crown, "modulate:a", 0.0, 0.5).set_delay(1.1)
	fall.tween_callback(crown.queue_free).set_delay(1.7)
	var shrink: Tween = create_tween()
	shrink.tween_property(_left, "scale", Vector2(0.82, 0.82), 1.0).set_trans(Tween.TRANS_CUBIC)


func _stagger() -> void:
	var back: Tween = create_tween()
	back.tween_property(_right, "position", _right.position + Vector2(90, 20), 0.2).set_trans(Tween.TRANS_CUBIC)
	back.tween_property(_right, "rotation_degrees", 12.0, 0.2)
	Audio.sfx(&"hit_heavy", -4.0)


func _roots_retract() -> void:
	var roots: Node = _extras.get_node_or_null("Roots")
	if roots != null:
		var pull: Tween = create_tween().set_parallel(true)
		pull.tween_property(roots, "scale", Vector2(0.2, 0.2), 1.0).set_trans(Tween.TRANS_CUBIC)
		pull.tween_property(roots, "modulate:a", 0.0, 1.0)
	Audio.sfx(&"spell", -2.0)
	_shake(10.0, 0.5)


func _cleansed() -> void:
	_flash_screen(Color("9cf5a0"), 0.8)
	(_left.material as ShaderMaterial).set_shader_parameter("tint", Color("d7ffd0"))
	_burst(_left.position + _left.size * 0.5, Color("9cf5a0"), 90)
	Audio.sfx(&"heal")
