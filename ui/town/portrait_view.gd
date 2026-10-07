class_name PortraitView
extends Control
## An NPC portrait for the visual-novel style dialogue box: it stands behind the box on one side, the waist tucked behind the box's top edge (the view is clipped
## a few pixels below that edge, so the box can be translucent), with a soft drop shadow, a slide + fade in/out and a gentle "talking" bob while a line types out.
## Everything is laid out in the 1920x1080 design viewport, so it scales with the window.

const HEIGHT_FRACTION: float = 0.64
const DESIGN_HEIGHT: float = 1080.0
## How far the portrait overhangs the box's side edge, how far its waist reaches below the box's top edge, and where the clip ends (hidden under the box border).
const OVERHANG: float = 90.0
const TUCK: float = 36.0
const CLIP_BELOW: float = 4.0
const SHADOW_PAD: float = 32.0
const SLIDE: float = 70.0
const IDLE_BRIGHTNESS: float = 0.9

var _clip: Control
var _stage: Control
var _shadow: ColorRect
var _image: TextureRect
var _material: ShaderMaterial
var _tween: Tween
var _talking: bool = false
var _time: float = 0.0
var _brightness: float = IDLE_BRIGHTNESS
var _mirrored: bool = false
var _image_top: float = 0.0
var _image_size: Vector2 = Vector2.ZERO
var shown: bool = false


func _ready() -> void:
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_clip = Control.new()
	_clip.clip_contents = true
	_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_clip)
	_stage = Control.new()
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_clip.add_child(_stage)
	_shadow = ColorRect.new()
	_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_material = ShaderMaterial.new()
	_material.shader = load("res://ui/shaders/portrait_shadow.gdshader") as Shader
	_shadow.material = _material
	_stage.add_child(_shadow)
	_image = TextureRect.new()
	_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_image.stretch_mode = TextureRect.STRETCH_SCALE
	_image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_stage.add_child(_image)


## The width a portrait takes in the design viewport (its aspect ratio at the standard height).
static func width_for(texture: Texture2D) -> float:
	if texture == null or texture.get_height() <= 0:
		return 0.0
	return DESIGN_HEIGHT * HEIGHT_FRACTION * float(texture.get_width()) / float(texture.get_height())


## Shows `texture` on the left (`right_side` false) or right of a box whose top edge is at `panel_top` and which spans `box_left`..`box_right`.
func present(texture: Texture2D, right_side: bool, panel_top: float, box_left: float, box_right: float) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_mirrored = right_side
	_image.flip_h = right_side
	_image.texture = texture
	_material.set_shader_parameter("portrait", texture)
	_material.set_shader_parameter("flip", right_side)
	var width: float = width_for(texture)
	var height: float = DESIGN_HEIGHT * HEIGHT_FRACTION
	_image_size = Vector2(width, height)
	var left: float = box_right + OVERHANG - width if right_side else box_left - OVERHANG
	_clip.position = Vector2(left - SHADOW_PAD, 0.0)
	_place(panel_top)
	_talking = false
	_time = 0.0
	_brightness = IDLE_BRIGHTNESS
	_apply_look(0.0)
	visible = true
	shown = true
	modulate.a = 0.0
	var from_x: float = SLIDE if right_side else -SLIDE
	_stage.position.x = from_x
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(self, "modulate:a", 1.0, 0.28)
	_tween.tween_property(_stage, "position:x", 0.0, 0.32).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


## Moves the box's top edge (a taller box for a longer line); the waist stays tucked behind it.
func follow_panel_top(panel_top: float) -> void:
	if shown:
		_place(panel_top)


func _place(panel_top: float) -> void:
	_clip.size = Vector2(_image_size.x + SHADOW_PAD * 2.0, panel_top + CLIP_BELOW)
	_image_top = panel_top + TUCK - _image_size.y
	_image.position = Vector2(SHADOW_PAD, _image_top)
	_image.size = _image_size
	_shadow.position = Vector2(0.0, _image_top - SHADOW_PAD)
	_shadow.size = _image_size + Vector2(SHADOW_PAD * 2.0, SHADOW_PAD * 2.0)
	_material.set_shader_parameter("rect_size", _shadow.size)
	_material.set_shader_parameter("image_size", _image_size)
	_material.set_shader_parameter("pad", SHADOW_PAD)


## Another expression of the same character: a quick dip and return so the change reads.
func set_texture(texture: Texture2D) -> void:
	if texture == null or texture == _image.texture:
		return
	_image.texture = texture
	_material.set_shader_parameter("portrait", texture)
	_brightness = IDLE_BRIGHTNESS * 0.8


## True while the character is speaking (the line is typing out): full brightness and a slight bob.
func set_talking(talking: bool) -> void:
	_talking = talking


## Fades out (and slides a little away from the box), then hides.
func dismiss() -> void:
	if not shown:
		return
	shown = false
	_talking = false
	if _tween != null and _tween.is_valid():
		_tween.kill()
	var to_x: float = SLIDE * 0.4 if _mirrored else -SLIDE * 0.4
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(self, "modulate:a", 0.0, 0.18)
	_tween.tween_property(_stage, "position:x", to_x, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.chain().tween_callback(func() -> void:
		if not shown:
			visible = false)


func _process(delta: float) -> void:
	if not visible:
		return
	_time += delta
	var target: float = 1.0 if _talking else IDLE_BRIGHTNESS
	_brightness = move_toward(_brightness, target, delta * 2.5)
	_apply_look(sin(_time * 9.0) * 3.0 if _talking else 0.0)


func _apply_look(bob: float) -> void:
	_image.position.y = _image_top + bob
	_shadow.position.y = _image_top - SHADOW_PAD + bob
	_image.self_modulate = Color(_brightness, _brightness, _brightness, 1.0)
