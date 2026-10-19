class_name ZoneTitleCard
extends CanvasLayer
## The zone title card (ZONE-TITLE-* banner art): when the player enters an area from another one, the area's banner slides in from the top, the game draws the area's name in the
## middle of it (`Areas.banner_name`), holds a few seconds and fades out. Entering the same area again without leaving it (loading a save made there) shows nothing.
## It waits for the scene transition (fade and loading screen) to finish first, and never takes a click.
## Overnight Oct 18, Part 4: under the banner a small flourish (gold rules, the area's Path icon, a subtitle line); the full card plays on the
## first arrival, later arrivals get a brief, smaller one; any key or click fades it out early (the input still reaches the game);
## dungeons get a card too, on their zone's banner (`make_dungeon`).

const BANNER_WIDTH: float = 1000.0
const TOP: float = 22.0
const SLIDE_SECONDS: float = 0.7
const HOLD_SECONDS: float = 3.4
const FADE_SECONDS: float = 0.9
## Where the empty middle of the banners is (fractions of the image): the name is fitted into this rectangle.
const TEXT_AREA: Rect2 = Rect2(0.27, 0.30, 0.46, 0.34)
const FONT_SIZES: Array[int] = [64, 56, 48, 42, 36, 32, 28]
const BRIEF_HOLD_SECONDS: float = 1.3
const BRIEF_SCALE: float = 0.8
const SKIP_FADE_SECONDS: float = 0.25
## Where the flourish's top sits (fraction of the banner image's height: just under the ribbon).
const FLOURISH_TOP: float = 0.7
## The subtitle under each area's banner.
const SUBTITLES: Dictionary = {
	Areas.START: "Somewhere outside Crosspath", Areas.TOWN: "Where every Path crosses", Areas.GAINLANDS: "Home of the Beefcake Path",
	Areas.DNA: "Home of the Necrocrat Path", Areas.BUFFET: "Home of the Gourmand Path", Areas.DUMP: "Home of the Refusemancer Path",
	Areas.CAPITAL: "Seat of His Perfection",
}
const AREA_PATHS: Dictionary = {
	Areas.GAINLANDS: Affinity.Type.BEEFCAKE, Areas.DNA: Affinity.Type.NECROCRAT, Areas.BUFFET: Affinity.Type.GOURMAND, Areas.DUMP: Affinity.Type.REFUSEMANCER,
}

var area_key: String = ""
## A dungeon card's own name and banner (empty for an area card), the subtitle and the Path whose icon the flourish shows (-1: none).
var title_text: String = ""
var banner_override: String = ""
var subtitle: String = ""
var path: int = -1
## A later arrival: shorter and smaller.
var brief: bool = false
var _holder: Control
var _skipped: bool = false
var _tween: Tween
## Cards whose full version has played this session (also kept in the save as flags once there is a hero).
static var _seen: Dictionary = {}
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
	card.subtitle = str(SUBTITLES.get(key, ""))
	card.path = int(AREA_PATHS.get(key, -1))
	card.brief = was_seen(key)
	return card


## A dungeon's card: its name on its zone's banner (the town's for the town and its side dungeons), the zone's name as the subtitle.
## `in_forest`: the Forgotten Cave (the forest's banner).
static func make_dungeon(dungeon_name: String, zone_id: String, in_forest: bool = false) -> ZoneTitleCard:
	var zone_area: String = Areas.START if in_forest else Areas.key_for_zone(zone_id)
	var banner: String = Areas.banner_id(zone_area if not zone_area.is_empty() else Areas.TOWN)
	if dungeon_name.is_empty() or banner.is_empty() or not KeyArt.has(banner):
		return null
	var card: ZoneTitleCard = ZoneTitleCard.new()
	card.area_key = Areas.DUNGEON
	card.name = "ZoneTitleCard"
	card.title_text = dungeon_name
	card.banner_override = banner
	card.subtitle = Areas.banner_name(zone_area) if not zone_area.is_empty() else "Beneath Crosspath"
	card.path = int(AREA_PATHS.get(zone_area, -1))
	card.brief = was_seen(_seen_key(card))
	return card


## Whether the full card of `key` has been seen (by this hero, or this session before there is one).
static func was_seen(key: String) -> bool:
	if _seen.has(key):
		return true
	return Session.has_profile() and Session.flag(StringName("title_seen_" + key))


static func mark_seen(key: String) -> void:
	_seen[key] = true
	if Session.has_profile():
		Session.set_flag(StringName("title_seen_" + key))


static func _seen_key(card: ZoneTitleCard) -> String:
	return card.area_key if card.title_text.is_empty() else "dungeon_" + card.title_text.to_snake_case()


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
	var texture: Texture2D = KeyArt.texture(banner_override if not banner_override.is_empty() else Areas.banner_id(area_key))
	mark_seen(_seen_key(self))
	var height: float = BANNER_WIDTH * float(texture.get_height()) / float(texture.get_width())
	var holder: Control = Control.new()
	holder.name = "Holder"
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.set_anchors_preset(Control.PRESET_CENTER_TOP)
	holder.offset_left = -BANNER_WIDTH * 0.5
	holder.offset_right = BANNER_WIDTH * 0.5
	holder.offset_top = TOP
	holder.offset_bottom = TOP + height
	holder.pivot_offset = Vector2(BANNER_WIDTH * 0.5, 0.0)
	if brief:
		holder.scale = Vector2.ONE * BRIEF_SCALE
	add_child(holder)
	_holder = holder
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
	_label.text = title_text if not title_text.is_empty() else Areas.banner_name(area_key)
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
	if not subtitle.is_empty():
		holder.add_child(_flourish(height))
	holder.position.y = -(height + TOP + 40.0)
	holder.modulate.a = 0.0
	# Wait for the fade / loading screen of the scene change to end, then slide in.
	while SceneManager.busy:
		await get_tree().process_frame
	if not is_inside_tree():
		return
	if _skipped:
		queue_free()
		return
	Audio.sfx(&"book", -12.0 if brief else -8.0)
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(holder, "position:y", 0.0, SLIDE_SECONDS).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(holder, "modulate:a", 1.0, SLIDE_SECONDS * 0.6)
	_tween.chain().tween_interval(BRIEF_HOLD_SECONDS if brief else HOLD_SECONDS)
	_tween.chain().tween_property(holder, "modulate:a", 0.0, FADE_SECONDS)
	_tween.chain().tween_callback(queue_free)


## A click, Enter/Space or the pad's confirm button fades the card out early (walking does not). The event is not consumed: the game still gets it.
func _input(event: InputEvent) -> void:
	if _skipped or not event.is_pressed() or event.is_echo():
		return
	if event is InputEventMouseButton or event.is_action(&"ui_accept"):
		skip()


func skip() -> void:
	if _skipped:
		return
	_skipped = true
	if _tween == null or _holder == null:
		return
	_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_holder, "modulate:a", 0.0, SKIP_FADE_SECONDS)
	_tween.tween_callback(queue_free)


## Under the banner: a gold rule, the Path's icon (a small diamond for the town, the Capital and the forest), a gold rule, then the subtitle.
func _flourish(banner_height: float) -> Control:
	var backing: PanelContainer = PanelContainer.new()
	backing.name = "Flourish"
	backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.03, 0.03, 0.6)
	style.set_corner_radius_all(16)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 4
	style.content_margin_bottom = 6
	backing.add_theme_stylebox_override("panel", style)
	# The banner art has empty space under its ribbon: the flourish tucks in right under the ribbon's lower edge.
	backing.position = Vector2(BANNER_WIDTH * 0.3, banner_height * FLOURISH_TOP)
	backing.size = Vector2(BANNER_WIDTH * 0.4, 0.0)
	var box: VBoxContainer = VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.alignment = BoxContainer.ALIGNMENT_BEGIN
	box.add_theme_constant_override("separation", 0)
	backing.add_child(box)
	var row: HBoxContainer = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 10)
	box.add_child(row)
	var gold: Color = Color(0.93, 0.78, 0.42, 0.9)
	var tint: Color = (PackDefinitions.PATH_COLORS.get(path, gold) as Color) if path >= 0 else gold
	row.add_child(_rule(gold))
	var icon_id: String = IconArt.energy_id(path as Affinity.Type) if path >= 0 else ""
	if not icon_id.is_empty() and IconArt.has(icon_id):
		var icon: TextureRect = IconArt.rect(icon_id, 36.0)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(icon)
	else:
		var diamond: Label = UIKit.label("◆", &"", 20, tint, HORIZONTAL_ALIGNMENT_CENTER)
		diamond.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(diamond)
	row.add_child(_rule(gold))
	var line: Label = UIKit.label(subtitle, &"", 22, Color(1.0, 0.95, 0.82), HORIZONTAL_ALIGNMENT_CENTER)
	line.name = "Subtitle"
	line.add_theme_font_override("font", UIStyle.font_title())
	line.add_theme_color_override("font_outline_color", Color(0.08, 0.03, 0.03, 0.95))
	line.add_theme_constant_override("outline_size", 6)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(line)
	return backing


static func _rule(color: Color) -> ColorRect:
	var rule: ColorRect = ColorRect.new()
	rule.color = color
	rule.custom_minimum_size = Vector2(90, 3)
	rule.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rule


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
