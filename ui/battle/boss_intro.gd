class_name BossIntro
extends Control
## Overnight Oct 23, Part 3: a boss's, lieutenant's or gatekeeper's entrance on the battle board - letterbox bars close in, the foe's
## cut-out slides in from the left over the bars (Oct 28; the Bestiary square pushes in when there is no cut-out), a name card with the
## title slides up, a music sting rings and the opening line appears. About 3.3 seconds;
## any key or click skips it. The data is `BossIntros` (data/encounters/boss_intros.json). The battle starts when `finished` fires.

signal finished

const BAR_HEIGHT: float = 128.0
const HOLD_SECONDS: float = 2.4
## Overnight Oct 28: the entrance shows a cut-out character (the transparent dialogue portrait or an imported CUT-* cut-out) sliding in
## from the left over the letterbox bars, feet in the lower bar, instead of the Bestiary square in a box; the square stays the fallback.
const CUTOUT_HEIGHT: float = 940.0
const CUTOUT_X: float = 150.0
const CUTOUT_OVERLAP: float = 48.0

var _done: bool = false
var _tween: Tween
var _dim: ColorRect
var _bars: Array[ColorRect] = []
var _portrait: TextureRect
var _card: VBoxContainer
var _line: Label
var _cutout_mode: bool = false
var _halo: TextureRect


static func wanted(enemy_name: String) -> bool:
	return not BossIntros.find(enemy_name).is_empty()


func play(enemy_name: String, picture: Texture2D, fallback_icon: String, cutout: Texture2D = null) -> void:
	var intro: Dictionary = BossIntros.find(enemy_name)
	name = "BossIntro"
	z_index = 900
	mouse_filter = Control.MOUSE_FILTER_STOP
	UIKit.full_rect(self)
	var accent: Color = intro.get("color", UIStyle.GOLD) as Color
	_dim = ColorRect.new()
	_dim.color = Color(0.02, 0.01, 0.05, 0.0)
	UIKit.full_rect(_dim)
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_dim)
	for index: int in range(2):
		var bar: ColorRect = ColorRect.new()
		bar.color = Color(0, 0, 0, 1)
		bar.size = Vector2(1920, BAR_HEIGHT)
		bar.position = Vector2(0, -BAR_HEIGHT if index == 0 else 1080)
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(bar)
		_bars.append(bar)
	_portrait = TextureRect.new()
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cutout_mode = cutout != null
	if _cutout_mode:
		_portrait.name = "IntroCutout"
		_portrait.texture = cutout
		var width: float = CUTOUT_HEIGHT * float(cutout.get_width()) / maxf(1.0, float(cutout.get_height()))
		# Phase 2 (Oct 28): a soft dark halo behind the figure, so a pale coat reads on a bright board; it slides in with the figure.
		var gradient: Gradient = Gradient.new()
		gradient.set_color(0, Color(0.02, 0.01, 0.05, 0.62))
		gradient.set_color(1, Color(0.02, 0.01, 0.05, 0.0))
		var halo_texture: GradientTexture2D = GradientTexture2D.new()
		halo_texture.gradient = gradient
		halo_texture.fill = GradientTexture2D.FILL_RADIAL
		halo_texture.fill_from = Vector2(0.5, 0.5)
		halo_texture.fill_to = Vector2(1.0, 0.5)
		halo_texture.width = 256
		halo_texture.height = 256
		_halo = TextureRect.new()
		_halo.name = "IntroHalo"
		_halo.texture = halo_texture
		_halo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_halo.stretch_mode = TextureRect.STRETCH_SCALE
		_halo.size = Vector2(width * 1.6, CUTOUT_HEIGHT * 1.1)
		_halo.position = Vector2(-width - width * 0.3, 1080.0 - BAR_HEIGHT + CUTOUT_OVERLAP - CUTOUT_HEIGHT * 1.05)
		_halo.modulate = Color(1, 1, 1, 0)
		_halo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_halo)
		_portrait.size = Vector2(width, CUTOUT_HEIGHT)
		_portrait.position = Vector2(-width, 1080.0 - BAR_HEIGHT + CUTOUT_OVERLAP - CUTOUT_HEIGHT)
		_portrait.pivot_offset = Vector2(width * 0.5, CUTOUT_HEIGHT)
		_portrait.scale = Vector2(1.06, 1.06)
		_portrait.modulate = Color(1, 1, 1, 0)
	else:
		_portrait.name = "IntroPicture"
		_portrait.texture = picture if picture != null else CardIcons.named(fallback_icon)
		_portrait.size = Vector2(620, 620)
		_portrait.position = Vector2(250, 230)
		_portrait.pivot_offset = _portrait.size * 0.5
		_portrait.scale = Vector2(1.22, 1.22)
		_portrait.modulate = Color(1, 1, 1, 0) if picture != null else Color(accent, 0)
	add_child(_portrait)
	_card = UIKit.vbox(6)
	_card.position = Vector2(930, 380)
	_card.custom_minimum_size = Vector2(840, 0)
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.modulate.a = 0.0
	add_child(_card)
	var rule: ColorRect = ColorRect.new()
	rule.color = accent
	rule.custom_minimum_size = Vector2(520, 4)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.add_child(rule)
	var title_label: Label = UIKit.label(str(intro.get("name", enemy_name)), &"", 60, UIStyle.PARCHMENT)
	title_label.name = "IntroName"
	title_label.add_theme_font_override("font", UIStyle.font_bold())
	title_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	title_label.add_theme_constant_override("outline_size", 10)
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.custom_minimum_size = Vector2(840, 0)
	_card.add_child(title_label)
	var subtitle: Label = UIKit.label(str(intro.get("title", "")), &"", 30, accent)
	subtitle.name = "IntroTitle"
	subtitle.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	subtitle.add_theme_constant_override("outline_size", 7)
	subtitle.visible = not subtitle.text.is_empty()
	_card.add_child(subtitle)
	_line = UIKit.label("\"%s\"" % str(intro.get("line", "")), &"", 26, Color(1, 1, 1, 0.92))
	_line.name = "IntroLine"
	_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_line.custom_minimum_size = Vector2(800, 0)
	_line.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_line.add_theme_constant_override("outline_size", 6)
	_line.modulate.a = 0.0
	_line.visible = not str(intro.get("line", "")).is_empty()
	_card.add_child(_line)
	var hint: Label = UIKit.label("Any key to skip", &"MutedLabel", 16)
	hint.position = Vector2(1700, 1040)
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hint)
	var sting: String = str(intro.get("sting", ""))
	if not sting.is_empty() and AudioRegistry.has_id(sting):
		Audio.sting(StringName(sting))
	_tween = create_tween()
	_tween.tween_property(_dim, "color:a", 0.72, 0.3)
	_tween.parallel().tween_property(_bars[0], "position:y", 0.0, 0.3).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(_bars[1], "position:y", 1080.0 - BAR_HEIGHT, 0.3).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(_portrait, "modulate:a", 1.0, 0.35)
	_tween.parallel().tween_property(_portrait, "scale", Vector2.ONE, HOLD_SECONDS + 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if _cutout_mode:
		_tween.parallel().tween_property(_portrait, "position:x", CUTOUT_X, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_tween.parallel().tween_property(_halo, "position:x", CUTOUT_X - _portrait.size.x * 0.3, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_tween.parallel().tween_property(_halo, "modulate:a", 1.0, 0.5)
	_tween.parallel().tween_property(_card, "modulate:a", 1.0, 0.3).set_delay(0.2)
	_tween.parallel().tween_property(_card, "position:y", 360.0, 0.4).set_delay(0.2).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(_line, "modulate:a", 1.0, 0.3).set_delay(0.7)
	_tween.tween_interval(HOLD_SECONDS - 0.4)
	_tween.tween_callback(_finish)


## For screenshots: hold on the full card.
func hold() -> void:
	if _tween != null:
		_tween.pause()
	_dim.color.a = 0.72
	_bars[0].position.y = 0.0
	_bars[1].position.y = 1080.0 - BAR_HEIGHT
	_portrait.modulate.a = 1.0
	_portrait.scale = Vector2(1.0, 1.0) if _cutout_mode else Vector2(1.05, 1.05)
	if _cutout_mode:
		_portrait.position.x = CUTOUT_X
		_halo.position.x = CUTOUT_X - _portrait.size.x * 0.3
		_halo.modulate.a = 1.0
	_card.modulate.a = 1.0
	_card.position.y = 360.0
	_line.modulate.a = 1.0


func _input(event: InputEvent) -> void:
	if _done:
		return
	var pressed: bool = (event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo) \
		or (event is InputEventMouseButton and (event as InputEventMouseButton).pressed) \
		or (event is InputEventJoypadButton and (event as InputEventJoypadButton).pressed)
	if pressed:
		get_viewport().set_input_as_handled()
		_finish()


func is_done() -> bool:
	return _done


func _finish() -> void:
	if _done:
		return
	_done = true
	if _tween != null:
		_tween.kill()
	var out: Tween = create_tween()
	out.tween_property(self, "modulate:a", 0.0, 0.25)
	out.tween_callback(func() -> void:
		finished.emit()
		queue_free())
