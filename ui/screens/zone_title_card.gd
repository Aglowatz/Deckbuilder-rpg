class_name ZoneTitleCard
extends CanvasLayer
## The zone title card (ZONE-TITLE-* banner art): when the player enters an area from another one, the area's banner slides in from the top, the game draws the area's name in the
## middle of it (`Areas.banner_name`), holds a few seconds and fades out. Entering the same area again without leaving it (loading a save made there) shows nothing.
## It waits for the scene transition (fade and loading screen) to finish first, and never takes a click.

const BANNER_WIDTH: float = 1000.0
const TOP: float = 22.0
const SLIDE_SECONDS: float = 0.7
const HOLD_SECONDS: float = 3.4
const FADE_SECONDS: float = 0.9
## Where the empty middle of the banners is (fractions of the image): the name is fitted into this rectangle.
const TEXT_AREA: Rect2 = Rect2(0.27, 0.30, 0.46, 0.34)
const FONT_SIZES: Array[int] = [64, 56, 48, 42, 36, 32, 28]

var area_key: String = ""
var _banner: TextureRect
var _label: Label
var _dark_text: bool = false
static var _luminance_cache: Dictionary = {}


## Whether entering `area_key` after `previous_area` shows a card: only when the area has a banner and the player comes from a different area.
static func should_show(area_key: String, previous_area: String) -> bool:
	return not Areas.banner_id(area_key).is_empty() and area_key != previous_area


## The card of an area (not yet in a scene); null when it has no banner art or name.
static func make(key: String) -> ZoneTitleCard:
	var id: String = Areas.banner_id(key)
	if id.is_empty() or not KeyArt.has(id) or Areas.banner_name(key).is_empty():
		return null
	var card: ZoneTitleCard = ZoneTitleCard.new()
	card.area_key = key
	card.name = "ZoneTitleCard"
	return card


## Adds the card to `scene` when the player really arrived from another area. `allowed` is false in screenshot runs (they ask for it with --card).
static func show_in(scene: Node, key: String, allowed: bool = true) -> ZoneTitleCard:
	if not allowed or not should_show(key, SceneManager.previous_area):
		return null
	var card: ZoneTitleCard = make(key)
	if card != null:
		scene.add_child(card)
	return card


func _ready() -> void:
	layer = 60
	var texture: Texture2D = KeyArt.texture(Areas.banner_id(area_key))
	var height: float = BANNER_WIDTH * float(texture.get_height()) / float(texture.get_width())
	var holder: Control = Control.new()
	holder.name = "Holder"
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.set_anchors_preset(Control.PRESET_CENTER_TOP)
	holder.offset_left = -BANNER_WIDTH * 0.5
	holder.offset_right = BANNER_WIDTH * 0.5
	holder.offset_top = TOP
	holder.offset_bottom = TOP + height
	add_child(holder)
	_banner = TextureRect.new()
	_banner.name = "Banner"
	_banner.texture = texture
	_banner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_banner.stretch_mode = TextureRect.STRETCH_SCALE
	UIKit.full_rect(_banner)
	_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(_banner)
	_dark_text = ZoneTitleCard.is_bright_middle(texture)
	_label = Label.new()
	_label.name = "ZoneName"
	_label.text = Areas.banner_name(area_key)
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var text_box: Rect2 = Rect2(TEXT_AREA.position * Vector2(BANNER_WIDTH, height), TEXT_AREA.size * Vector2(BANNER_WIDTH, height))
	_label.position = text_box.position
	_label.size = text_box.size
	var font: Font = UIStyle.font_title()
	_label.add_theme_font_override("font", font)
	_label.add_theme_font_size_override("font_size", fitted_font_size(font, _label.text, text_box.size))
	var ink: Color = Color(0.16, 0.1, 0.06) if _dark_text else Color(1.0, 0.95, 0.8)
	var halo: Color = Color(1, 0.97, 0.88, 0.55) if _dark_text else Color(0.1, 0.03, 0.03, 0.95)
	_label.add_theme_color_override("font_color", ink)
	_label.add_theme_color_override("font_outline_color", halo)
	_label.add_theme_constant_override("outline_size", 6 if _dark_text else 8)
	holder.add_child(_label)
	holder.position.y = -(height + TOP + 40.0)
	holder.modulate.a = 0.0
	# Wait for the fade / loading screen of the scene change to end, then slide in.
	while SceneManager.busy:
		await get_tree().process_frame
	if not is_inside_tree():
		return
	Audio.sfx(&"book", -8.0)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(holder, "position:y", 0.0, SLIDE_SECONDS).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(holder, "modulate:a", 1.0, SLIDE_SECONDS * 0.6)
	tween.chain().tween_interval(HOLD_SECONDS)
	tween.chain().tween_property(holder, "modulate:a", 0.0, FADE_SECONDS)
	tween.chain().tween_callback(queue_free)


## The largest size of `FONT_SIZES` at which `text` (wrapped to the box width) fits the box.
static func fitted_font_size(font: Font, text: String, box: Vector2) -> int:
	for size: int in FONT_SIZES:
		var measured: Vector2 = font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, box.x, size)
		if measured.y <= box.y and measured.x <= box.x + 1.0:
			return size
	return FONT_SIZES[FONT_SIZES.size() - 1]


## True when the middle of the banner is light (parchment, white and gold), so the name is drawn dark; false for dark ribbons (light name).
static func is_bright_middle(texture: Texture2D) -> bool:
	var id: String = texture.resource_path
	if _luminance_cache.has(id):
		return bool(_luminance_cache[id])
	var image: Image = texture.get_image()
	if image.is_compressed():
		image.decompress()
	var total: float = 0.0
	var count: int = 0
	var area: Rect2i = Rect2i(int(image.get_width() * TEXT_AREA.position.x), int(image.get_height() * TEXT_AREA.position.y), int(image.get_width() * TEXT_AREA.size.x), int(image.get_height() * TEXT_AREA.size.y))
	for y: int in range(area.position.y, area.end.y, 6):
		for x: int in range(area.position.x, area.end.x, 6):
			var pixel: Color = image.get_pixel(x, y)
			if pixel.a > 0.5:
				total += pixel.get_luminance()
				count += 1
	var bright: bool = count > 0 and total / float(count) > 0.45
	_luminance_cache[id] = bright
	return bright
