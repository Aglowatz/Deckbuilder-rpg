class_name StyleLabel
extends RefCounted
## Legible 3D text (docs/art/graphics_loop.md, G-11): the world signs and name plates are Label3D nodes, which smeared at the lower internal resolution of
## Medium/Low quality. `title_font()` and `body_font()` return multichannel-signed-distance-field versions of the project fonts (crisp at any size and
## render scale); `tune` gives a Label3D a sturdier outline, mip filtering and a distance fade; `StyleLabelFader` fades labels hanging above the hero.

const TITLE_PATH: String = "res://assets/fonts/Cinzel/Cinzel-Variable.ttf"
const BODY_PATH: String = "res://assets/fonts/AlegreyaSans/AlegreyaSans-Regular.ttf"
const MIN_OUTLINE: int = 12
const FADE_RANGE: float = 46.0

static var _title: Font
static var _body: Font


static func _msdf(path: String, embolden: float) -> Font:
	var source: FontFile = (load(path) as FontFile).duplicate() as FontFile
	source.multichannel_signed_distance_field = true
	source.msdf_pixel_range = 10
	source.msdf_size = 56
	source.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	var variation: FontVariation = FontVariation.new()
	variation.base_font = source
	variation.variation_embolden = embolden
	return variation


static func title_font() -> Font:
	if _title == null:
		_title = _msdf(TITLE_PATH, 0.6)
	return _title


static func body_font() -> Font:
	if _body == null:
		_body = _msdf(BODY_PATH, 0.2)
	return _body


## Makes `label` robust: MSDF font (unless it already uses one), minimum outline, mip filtering, never shaded, a distance fade.
static func tune(label: Label3D) -> void:
	if label.has_meta(&"style_label_tuned"):
		return
	label.set_meta(&"style_label_tuned", true)
	label.set_meta(&"base_alpha", label.modulate.a)
	if label.font == UIStyle.font_title():
		label.font = title_font()
	elif label.font == UIStyle.font_body():
		label.font = body_font()
	if label.outline_size > 0:
		label.outline_size = maxi(label.outline_size, MIN_OUTLINE)
	label.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	label.shaded = false
	label.visibility_range_end = FADE_RANGE
	label.visibility_range_end_margin = 6.0
	label.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF


## Free-standing signs read edge-on from the high diorama camera: lean a vertical label back towards it (wall-mounted ones stay flat).
static func lean_back(label: Label3D, degrees: float = 32.0) -> void:
	if label.billboard == BaseMaterial3D.BILLBOARD_DISABLED:
		label.rotation_degrees.x = -degrees
