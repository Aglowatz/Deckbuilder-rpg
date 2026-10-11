class_name LoadingScreen
extends Control
## The loading screen shown while an area loads: the area's LOAD-* art (`Areas.loading_id`) filling the screen, and in the calm bottom fifth a random tip, hint or lore line
## (`LoadingTips`, `data/loading/loading_tips.txt`), a slim progress bar and the emblem turning slowly. `SceneManager.change_scene` shows it for at least `MIN_SECONDS` so
## it never flashes. Without the art for an area nothing is shown (the plain fade stays).

const MIN_SECONDS: float = 1.6
const FADE_IN: float = 0.28
const FADE_OUT: float = 0.4
const TIP_WIDTH: float = 1380.0
const SPIN_DEGREES_PER_SECOND: float = 55.0

var loading_id: String = ""
var tip: LoadingTips.Tip
var _bar_fill: ColorRect
var _bar_width: float = 0.0
var _emblem: TextureRect
var _tip_label: Label
var _kind_label: Label
var _progress: float = 0.0
static var _last_tip: String = ""


## The loading screen of an area; null when there is no art for it.
static func make(area_key: String, dungeon_id: String = "", rng: RandomNumberGenerator = null) -> LoadingScreen:
	var id: String = Areas.loading_id(area_key, dungeon_id)
	if id.is_empty() or not KeyArt.has(id):
		return null
	var screen: LoadingScreen = LoadingScreen.new()
	screen.loading_id = id
	screen.tip = LoadingTips.pick(id, rng, _last_tip)
	if screen.tip != null:
		_last_tip = screen.tip.text
	screen.name = "LoadingScreen"
	return screen


func _ready() -> void:
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var picture: TextureRect = TextureRect.new()
	picture.name = "LoadingArt"
	picture.texture = KeyArt.texture(loading_id)
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	UIKit.full_rect(picture)
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(picture)
	# A soft dark fade rising from the bottom edge so the tip reads on any art, even where the painting is brighter than its calm bottom fifth.
	var fade: TextureRect = TextureRect.new()
	var gradient: Gradient = Gradient.new()
	gradient.colors = PackedColorArray([Color(0.03, 0.02, 0.06, 0.0), Color(0.03, 0.02, 0.06, 0.82)])
	var fade_texture: GradientTexture2D = GradientTexture2D.new()
	fade_texture.gradient = gradient
	fade_texture.width = 4
	fade_texture.height = 256
	fade_texture.fill_from = Vector2(0, 0)
	fade_texture.fill_to = Vector2(0, 1)
	fade.texture = fade_texture
	fade.stretch_mode = TextureRect.STRETCH_SCALE
	fade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fade.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	fade.offset_top = -330
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fade)
	var strip: VBoxContainer = UIKit.vbox(8)
	strip.name = "TipStrip"
	strip.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	strip.offset_top = -214
	strip.offset_bottom = -34
	strip.alignment = BoxContainer.ALIGNMENT_CENTER
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(strip)
	_kind_label = UIKit.label("", &"", 22, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	_kind_label.name = "TipKind"
	_kind_label.add_theme_font_override("font", UIStyle.font_title())
	_outline(_kind_label)
	strip.add_child(_kind_label)
	_tip_label = UIKit.label("", &"", 30, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	_tip_label.name = "TipText"
	_tip_label.add_theme_font_override("font", UIStyle.font_italic())
	_tip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tip_label.custom_minimum_size = Vector2(TIP_WIDTH, 0)
	_tip_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_outline(_tip_label)
	strip.add_child(_tip_label)
	if tip != null:
		_kind_label.text = _kind_title(tip.kind)
		_tip_label.text = tip.text
	var bar: Panel = Panel.new()
	bar.name = "ProgressBar"
	bar.add_theme_stylebox_override("panel", UIStyle.box(Color(0.02, 0.01, 0.04, 0.8), UIStyle.GOLD_DIM, 2, 6))
	bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bar.anchor_left = 0.3
	bar.anchor_right = 0.7
	bar.offset_top = -30
	bar.offset_bottom = -18
	bar.offset_left = 0
	bar.offset_right = 0
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bar)
	_bar_fill = ColorRect.new()
	_bar_fill.color = UIStyle.GOLD
	_bar_fill.position = Vector2(3, 3)
	_bar_fill.size = Vector2(0, 6)
	_bar_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_child(_bar_fill)
	bar.resized.connect(func() -> void:
		_bar_width = bar.size.x - 6.0
		_apply_progress())
	_bar_width = 0.0
	var emblem: Texture2D = KeyArt.texture("LOGO-EMBLEM")
	if emblem != null:
		_emblem = TextureRect.new()
		_emblem.name = "Spinner"
		_emblem.texture = emblem
		_emblem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_emblem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_emblem.custom_minimum_size = Vector2(96, 96)
		_emblem.size = Vector2(96, 96)
		_emblem.pivot_offset = Vector2(48, 48)
		_emblem.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		_emblem.offset_left = -150
		_emblem.offset_top = -150
		_emblem.offset_right = -54
		_emblem.offset_bottom = -54
		_emblem.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_emblem)


func _outline(label: Label) -> void:
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("outline_size", 8)


func _kind_title(kind: String) -> String:
	match kind:
		"keyword":
			return "KEYWORD"
		"lore":
			return "LORE"
	return "TIP"


func _process(delta: float) -> void:
	if _emblem != null:
		_emblem.rotation_degrees += SPIN_DEGREES_PER_SECOND * delta


## The bar's fill, 0 to 1.
func set_progress(value: float) -> void:
	_progress = clampf(value, 0.0, 1.0)
	_apply_progress()


func _apply_progress() -> void:
	if _bar_fill != null:
		_bar_fill.size.x = maxf(0.0, _bar_width) * _progress


func progress() -> float:
	return _progress
