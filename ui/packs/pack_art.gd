class_name PackArt
extends Control
## A card pack drawn in code: a crimped foil wrapper tinted by the pack's colour, with the pack's emblem and name. The wrapper is
## two halves (the top strip and the body) so `tear()` can rip the strip off. Frame styles: "plain", "foil" (a moving shine),
## "gilded" (gold trim and sparkles), "prismatic" (a colour-cycling rainbow).

signal torn

const SIZE: Vector2 = Vector2(300, 440)
const SEAM: float = 86.0
## With the UI art kit foil image the crimped top strip is shorter.
const ART_SEAM: float = 66.0
## The art image of each Path Pack and the centre of the medallion on the Gilded pack (fractions of its width and height) where the Path's own emblem is shown.
const PATH_PACK_IDS: Dictionary = {
	Affinity.Type.BEEFCAKE: "UI-PACK-B",
	Affinity.Type.NECROCRAT: "UI-PACK-N",
	Affinity.Type.GOURMAND: "UI-PACK-G",
	Affinity.Type.REFUSEMANCER: "UI-PACK-R",
}
const MEDALLION_CENTER: Vector2 = Vector2(0.5, 0.427)
const MEDALLION_RADIUS: float = 0.28

var pack: PackData
var _top_clip: Control
var _body_clip: Control
var _faces: Array[PackFace] = []
var _tween: Tween
var _seam: float = SEAM


## The UI art kit image ID of a pack: Path Pack by Path, Gilded (tinted per Path), Prismatic, General tier 1 / 2; "" when the pack has none or its image is missing.
static func art_id_for(pack_data: PackData) -> String:
	if pack_data == null:
		return ""
	var id: String = ""
	match pack_data.kind:
		PackData.Kind.PATH:
			id = str(PATH_PACK_IDS.get(pack_data.path, ""))
		PackData.Kind.GILDED:
			id = "UI-PACK-GILDED"
		PackData.Kind.PRISMATIC:
			id = "UI-PACK-PRISMATIC"
		PackData.Kind.GENERAL:
			id = "UI-PACK-GENERAL-2" if pack_data.general_tier >= 2 else "UI-PACK-GENERAL-1"
	return id if id != "" and UiArt.has(id) else ""


static func create(pack_data: PackData) -> PackArt:
	var art: PackArt = PackArt.new()
	art.pack = pack_data
	return art


func _ready() -> void:
	custom_minimum_size = SIZE
	size = SIZE
	pivot_offset = SIZE * 0.5
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not art_id_for(pack).is_empty():
		_seam = ART_SEAM
	_body_clip = _make_clip(Rect2(0, _seam, SIZE.x, SIZE.y - _seam))
	_top_clip = _make_clip(Rect2(0, 0, SIZE.x, _seam + 1.5))
	_add_face(_body_clip, Vector2(0, -_seam))
	_add_face(_top_clip, Vector2.ZERO)
	_top_clip.pivot_offset = Vector2(SIZE.x * 0.5, _seam)


func _make_clip(rect: Rect2) -> Control:
	var clip: Control = Control.new()
	clip.position = rect.position
	clip.size = rect.size
	clip.clip_contents = true
	clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(clip)
	return clip


func _add_face(parent: Control, offset: Vector2) -> void:
	var face: PackFace = PackFace.new()
	face.pack = pack
	face.seam = _seam
	face.position = offset
	face.size = SIZE
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(face)
	_faces.append(face)


## Rips the top strip off (it flies away spinning) and shows the torn edge. Emits `torn` when the strip has gone.
func tear() -> void:
	for face: PackFace in _faces:
		face.torn_open = true
		face.queue_redraw()
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(_top_clip, "position", Vector2(60, -150), 0.55).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.tween_property(_top_clip, "rotation", 0.5, 0.55).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.tween_property(_top_clip, "modulate:a", 0.0, 0.55).set_delay(0.15)
	_tween.chain().tween_callback(func() -> void: torn.emit())


## The body slips away after the cards have come out.
func fade_out(duration: float = 0.4) -> void:
	var fade: Tween = create_tween().set_parallel(true)
	fade.tween_property(self, "modulate:a", 0.0, duration)
	fade.tween_property(self, "scale", Vector2(0.9, 0.9), duration)
	fade.tween_property(self, "position:y", position.y + 40.0, duration)


## The whole wrapper, drawn once (the two halves each show their part of it).
class PackFace:
	extends Control

	var pack: PackData
	var torn_open: bool = false
	var _time: float = 0.0
	var _icon: Texture2D
	var seam: float = PackArt.SEAM
	var _art: bool = false

	func _ready() -> void:
		var art_id: String = PackArt.art_id_for(pack)
		if not art_id.is_empty():
			_art = true
			_build_art(art_id)
			return
		if pack != null and not pack.art_icon.is_empty():
			_icon = CardIcons.named(pack.art_icon)
			var glyph: TextureRect = CardIcons.glyph(_icon, Color(1.0, 0.96, 0.85, 0.95), Vector2(104, 104))
			glyph.position = Vector2(PackArt.SIZE.x * 0.5 - 52.0, PackArt.SIZE.y * 0.47 - 52.0)
			glyph.size = Vector2(104, 104)
			add_child(glyph)

	func _process(delta: float) -> void:
		if _art:
			return
		_time += delta
		queue_redraw()

	## The UI art kit pack image (foil wrapper): drawn whole; a Gilded pack is tinted by its Path and carries that Path's own emblem medallion over its centre.
	func _build_art(art_id: String) -> void:
		var picture: TextureRect = TextureRect.new()
		picture.texture = UiArt.texture(art_id)
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_SCALE
		picture.size = PackArt.SIZE
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(picture)
		if pack.kind == PackData.Kind.GILDED:
			picture.modulate = Color.WHITE.lerp(pack.art_color.lightened(0.15), 0.4)
			var emblem_id: String = str(PackArt.PATH_PACK_IDS.get(pack.path, ""))
			var source: Texture2D = UiArt.texture(emblem_id) if not emblem_id.is_empty() else null
			if source != null:
				var atlas: AtlasTexture = AtlasTexture.new()
				atlas.atlas = source
				var half: float = float(source.get_width()) * PackArt.MEDALLION_RADIUS
				atlas.region = Rect2(float(source.get_width()) * PackArt.MEDALLION_CENTER.x - half, float(source.get_height()) * PackArt.MEDALLION_CENTER.y - half, half * 2.0, half * 2.0)
				var medallion: TextureRect = TextureRect.new()
				medallion.texture = atlas
				medallion.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				medallion.stretch_mode = TextureRect.STRETCH_SCALE
				var span: float = PackArt.SIZE.x * PackArt.MEDALLION_RADIUS * 2.0
				medallion.size = Vector2(span, span)
				medallion.position = Vector2(PackArt.SIZE.x * PackArt.MEDALLION_CENTER.x, PackArt.SIZE.y * PackArt.MEDALLION_CENTER.y) - medallion.size * 0.5
				var crop: ShaderMaterial = ShaderMaterial.new()
				crop.shader = load("res://ui/shaders/circle_crop.gdshader") as Shader
				medallion.material = crop
				medallion.mouse_filter = Control.MOUSE_FILTER_IGNORE
				add_child(medallion)

	func _base_color() -> Color:
		if pack == null:
			return Color(0.5, 0.5, 0.5)
		if pack.frame_style == "prismatic":
			return Color.from_hsv(fposmod(_time * 0.12, 1.0), 0.55, 0.85)
		return pack.art_color

	func _draw() -> void:
		if _art:
			if torn_open:
				_draw_tear(Color("e8c25a") if pack.kind == PackData.Kind.GILDED else pack.art_color)
			return
		var base: Color = _base_color()
		var width: float = PackArt.SIZE.x
		var height: float = PackArt.SIZE.y
		var style: String = pack.frame_style if pack != null else "plain"
		# Wrapper body: a vertical gradient with a darker rim.
		var rim: StyleBoxFlat = UIStyle.box(base.darkened(0.35), base.lightened(0.25) if style != "gilded" else UIStyle.GOLD, 5, 16, 0)
		draw_style_box(rim, Rect2(Vector2.ZERO, PackArt.SIZE))
		var steps: int = 22
		for step: int in range(steps):
			var t: float = float(step) / float(steps)
			var band: Color = base.lightened(0.25 - 0.55 * t).lerp(base.darkened(0.45), t * 0.6)
			draw_rect(Rect2(8.0, 18.0 + (height - 36.0) * t, width - 16.0, (height - 36.0) / float(steps) + 1.0), band)
		# Crimped top and bottom edges.
		_draw_crimp(0.0, base, true)
		_draw_crimp(height - 20.0, base, false)
		# A moving shine across foil styles.
		if style != "plain":
			var sweep: float = fposmod(_time * 0.55, 2.4) - 0.7
			var x: float = width * sweep
			var shine: PackedVector2Array = PackedVector2Array([Vector2(x, 0), Vector2(x + 46, 0), Vector2(x - 60, height), Vector2(x - 106, height)])
			draw_colored_polygon(shine, Color(1, 1, 1, 0.16))
		# Emblem medallion.
		var centre: Vector2 = Vector2(width * 0.5, height * 0.47)
		draw_circle(centre, 82.0, base.darkened(0.55))
		draw_arc(centre, 82.0, 0.0, TAU, 48, UIStyle.GOLD if style == "gilded" else base.lightened(0.5), 5.0, true)
		draw_arc(centre, 68.0, 0.0, TAU, 48, Color(1, 1, 1, 0.25), 2.0, true)
		# Name plate.
		var font: Font = UIStyle.font_title()
		var title: String = pack.display_name.to_upper() if pack != null else "PACK"
		var title_size: int = 26 if title.length() < 16 else 21
		var lines: PackedStringArray = _wrap(title)
		var y: float = height * 0.74
		for line: String in lines:
			var line_width: float = font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size).x
			draw_string_outline(font, Vector2((width - line_width) * 0.5, y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size, 6, Color(0, 0, 0, 0.7))
			draw_string(font, Vector2((width - line_width) * 0.5, y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size, UIStyle.PARCHMENT)
			y += float(title_size) + 6.0
		# Card count tag.
		var count_text: String = "%d CARDS" % (pack.card_count if pack != null else 3)
		var small: Font = UIStyle.font_bold()
		var count_width: float = small.get_string_size(count_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 17).x
		draw_string(small, Vector2((width - count_width) * 0.5, height - 36.0), count_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color(1, 1, 1, 0.8))
		if style == "gilded" or style == "prismatic":
			for index: int in range(7):
				var angle: float = _time * 0.8 + float(index) * 0.9
				var spot: Vector2 = Vector2(width * (0.12 + 0.76 * fposmod(float(index) * 0.37 + _time * 0.05, 1.0)), height * (0.2 + 0.6 * fposmod(float(index) * 0.53, 1.0)))
				var pulse: float = 0.5 + 0.5 * sin(angle * 2.0)
				draw_texture_rect(PackFx.spark(), Rect2(spot - Vector2(14, 14) * pulse, Vector2(28, 28) * pulse), false, Color(1, 1, 0.85, 0.85 * pulse))
		if torn_open:
			_draw_tear(base)

	func _wrap(text: String) -> PackedStringArray:
		var words: PackedStringArray = text.split(" ")
		if text.length() <= 14 or words.size() < 2:
			return PackedStringArray([text])
		var best: int = words.size() / 2
		return PackedStringArray([" ".join(words.slice(0, best)), " ".join(words.slice(best))])

	func _draw_crimp(y: float, base: Color, top: bool) -> void:
		var width: float = PackArt.SIZE.x
		draw_rect(Rect2(6.0, y + (2.0 if top else 0.0), width - 12.0, 18.0), base.darkened(0.25))
		var teeth: int = 24
		for tooth: int in range(teeth):
			var x: float = 8.0 + (width - 16.0) * float(tooth) / float(teeth)
			var step: float = (width - 16.0) / float(teeth)
			draw_line(Vector2(x + step * 0.5, y + 3.0), Vector2(x + step * 0.5, y + 17.0), base.lightened(0.3), 2.0)

	## The ragged edge where the strip came off: a zig-zag in light foil along the seam.
	func _draw_tear(base: Color) -> void:
		var width: float = PackArt.SIZE.x
		var points: PackedVector2Array = PackedVector2Array()
		var teeth: int = 14
		# The foil image tapers at its top, so its torn edge is narrower than the drawn wrapper's.
		var inset: float = 20.0 if _art else 6.0
		points.append(Vector2(inset, seam + 14.0))
		for tooth: int in range(teeth + 1):
			var x: float = inset + (width - inset * 2.0) * float(tooth) / float(teeth)
			points.append(Vector2(x, seam + (-7.0 if tooth % 2 == 0 else 7.0)))
		points.append(Vector2(width - inset, seam + 14.0))
		draw_colored_polygon(points, base.lightened(0.55))
		draw_polyline(points, Color(1, 1, 1, 0.9), 2.0, true)


## A small pack icon for lists (the inventory): the pack art scaled to `scale_factor`, in a holder of that size. Falls back to the flat colour swatch when the pack has no art image.
static func icon(pack_data: PackData, scale_factor: float) -> Control:
	var holder: Control = Control.new()
	holder.custom_minimum_size = SIZE * scale_factor
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if art_id_for(pack_data).is_empty():
		var swatch: Panel = Panel.new()
		swatch.size = holder.custom_minimum_size * Vector2(0.6, 0.7)
		swatch.position = (holder.custom_minimum_size - swatch.size) * 0.5
		swatch.add_theme_stylebox_override("panel", UIStyle.box(pack_data.art_color, pack_data.art_color.lightened(0.4), 2, 4, 0))
		holder.add_child(swatch)
		return holder
	var art: PackArt = create(pack_data)
	holder.add_child(art)
	art.scale = Vector2.ONE * scale_factor
	art.position = holder.custom_minimum_size * 0.5 - SIZE * 0.5
	return holder
