class_name StillBackdrop
extends Control
## A story still (STORY-* key art) as the backdrop of a scene that keeps its own narration (art import Oct 29): the cutscene stage, an ending
## beat, a story scene in the dialogue box or a memory fragment draws its words over the picture. A soft dark band at the bottom keeps the
## narration box readable on any picture. `make` returns null when the still is not in the game, and the scene keeps its old look.

const FADE_IN: float = 0.7
const FADE_OUT: float = 0.6
## How dark the band under the narration box gets at the very bottom (0 at `SHADE_FROM` of the height).
const SHADE_ALPHA: float = 0.78
const SHADE_FROM: float = 0.5

var still_id: String = ""
var _picture: TextureRect


static func make(id: String, shade: bool = true) -> StillBackdrop:
	if id.is_empty() or not KeyArt.has(id):
		return null
	var backdrop: StillBackdrop = StillBackdrop.new()
	backdrop.name = "StillBackdrop"
	backdrop.still_id = id
	backdrop.set_meta("shade", shade)
	return backdrop


func _ready() -> void:
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var base: ColorRect = ColorRect.new()
	base.color = Color(0.02, 0.01, 0.04)
	UIKit.full_rect(base)
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(base)
	_picture = TextureRect.new()
	_picture.name = "StillArt"
	_picture.texture = KeyArt.texture(still_id)
	_picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	UIKit.full_rect(_picture)
	_picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_picture)
	if bool(get_meta("shade", true)):
		add_child(_shade())


## Fable Nov 12 (Part 4.3): a slow pan and zoom on the picture (Ken Burns) - it grows DRIFT_ZOOM over DRIFT_TIME from a corner picked by
## `variant`, so a still held under several lines of narration is never a frozen frame. Off under Reduce motion.
const DRIFT_ZOOM: float = 1.07
const DRIFT_TIME: float = 22.0


func drift(variant: int = 0) -> void:
	if _picture == null or Settings.reduce_motion:
		return
	clip_contents = true
	var corners: Array[Vector2] = [Vector2(0.3, 0.35), Vector2(0.7, 0.4), Vector2(0.5, 0.25), Vector2(0.35, 0.6), Vector2(0.65, 0.55)]
	_picture.pivot_offset = size * corners[absi(variant) % corners.size()]
	_picture.scale = Vector2.ONE
	var tween: Tween = create_tween()
	tween.tween_property(_picture, "scale", Vector2(DRIFT_ZOOM, DRIFT_ZOOM), DRIFT_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


## Swaps the picture (an ending moving from one still to the next).
func show_still(id: String) -> void:
	still_id = id
	if _picture != null:
		_picture.texture = KeyArt.texture(id)


func fade_in(duration: float = FADE_IN) -> void:
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, duration)


## Fades out, then frees itself.
func fade_out_and_free(duration: float = FADE_OUT) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, duration)
	tween.tween_callback(queue_free)


func _shade() -> TextureRect:
	var gradient: Gradient = Gradient.new()
	gradient.set_color(0, Color(0, 0, 0, 0))
	gradient.set_color(1, Color(0, 0, 0, SHADE_ALPHA))
	gradient.set_offset(0, SHADE_FROM)
	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2(0.5, 0.0)
	texture.fill_to = Vector2(0.5, 1.0)
	texture.width = 8
	texture.height = 256
	var shade: TextureRect = TextureRect.new()
	shade.name = "Shade"
	shade.texture = texture
	shade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shade.stretch_mode = TextureRect.STRETCH_SCALE
	UIKit.full_rect(shade)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return shade
