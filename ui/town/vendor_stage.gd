class_name VendorStage
extends Control
## The look shared by every vendor screen (docs/art/art_pipeline.md, "import key art"): the shop's own background (Vendor Screen ID, 16:9, `KeyArt`), the vendor's portrait
## on the left, a dark glass panel behind the item grid on the right (so prices and text stay readable on top of the art) and a speech bubble that talks when the shop
## opens and after a purchase (`VendorLines`). The shop's content (an `OverlayScreen`'s margin container) sits on the right, `inset` px from the left edge.
## `overlay` is a click-through layer above the content for the vendor's effects (stamps, shouts, a raccoon peeking in).

const INSET: float = 620.0
const PORTRAIT_HEIGHT: float = 0.9

var screen_id: String = ""
var inset: float = INSET
## Fires after a purchase line was said (effects hook in here).
signal said(moment: String)

var overlay: Control
var _portrait: TextureRect
var _panel: Panel
var _bubble: PanelContainer
var _bubble_label: Label
var _portrait_id: String = ""
var _line_tween: Tween
var _nod_tween: Tween


static func make(vendor_screen_id: String, left_inset: float = INSET) -> VendorStage:
	var stage: VendorStage = VendorStage.new()
	stage.screen_id = vendor_screen_id
	stage.inset = left_inset
	stage.name = "VendorStage"
	return stage


func _ready() -> void:
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var picture: TextureRect = TextureRect.new()
	picture.name = "ShopBackground"
	picture.texture = KeyArt.texture(screen_id)
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	UIKit.full_rect(picture)
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(picture)
	# A soft shade toward the left edge keeps the vendor readable against a busy shop.
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.02, 0.012, 0.04, 0.18)
	UIKit.full_rect(shade)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	_portrait_id = VendorLines.portrait_id(screen_id)
	_portrait = TextureRect.new()
	_portrait.name = "VendorPortrait"
	_portrait.texture = Portraits.texture_for(_portrait_id)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_SCALE
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_portrait)
	_panel = Panel.new()
	_panel.name = "ItemPanel"
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box: StyleBoxFlat = UIStyle.box(Color(0.035, 0.022, 0.06, 0.84), UIStyle.GOLD_DIM, 3, 18)
	_panel.add_theme_stylebox_override("panel", box)
	add_child(_panel)
	overlay = Control.new()
	overlay.name = "VendorFx"
	UIKit.full_rect(overlay)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.z_index = 50
	_build_bubble()
	resized.connect(_layout)
	_layout()
	if screen_id == "VS-GRISTLE":
		_schedule_raccoon(4.0)


## The overlay is added by the screen above its content (z_index keeps it on top either way).
func attach_overlay(parent: Control) -> void:
	parent.add_child(overlay)


func _build_bubble() -> void:
	_bubble = PanelContainer.new()
	_bubble.name = "SpeechBubble"
	_bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bubble.add_theme_stylebox_override("panel", UIStyle.box(Color(0.06, 0.04, 0.1, 0.94), UIStyle.GOLD, 3, 18))
	_bubble_label = UIKit.label("", &"", 25, UIStyle.PARCHMENT)
	_bubble_label.add_theme_font_override("font", UIStyle.font_italic())
	_bubble_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bubble.add_child(_bubble_label)
	_bubble.modulate.a = 0.0
	overlay.add_child(_bubble)


func _layout() -> void:
	if _panel == null:
		return
	_panel.position = Vector2(inset - 12.0, 14.0)
	_panel.size = Vector2(maxf(0.0, size.x - inset - 2.0), maxf(0.0, size.y - 28.0))
	var texture: Texture2D = _portrait.texture
	if texture != null:
		var aspect: float = float(texture.get_width()) / float(texture.get_height())
		var height: float = size.y * PORTRAIT_HEIGHT
		var width: float = height * aspect
		var room: float = inset + 30.0
		if width > room:
			width = room
			height = width / aspect
		_portrait.size = Vector2(width, height)
		_portrait.position = Vector2(maxf(0.0, (inset - width) * 0.5), size.y - height + 6.0)
	var bubble_width: float = inset - 70.0
	_bubble_label.custom_minimum_size = Vector2(bubble_width - 40.0, 0.0)
	_bubble.position = Vector2(34.0, 26.0)
	_bubble.size = Vector2(bubble_width, 10.0)


## The vendor says a random line of `moment` ("open", "buy", "poor", "sold_out") typed out in the bubble; `said` fires. Nothing happens when the vendor has none.
func say(moment: String) -> void:
	var text: String = VendorLines.pick(screen_id, moment)
	if text.is_empty():
		return
	say_text(text)
	said.emit(moment)


func say_text(text: String) -> void:
	_bubble_label.text = text
	_bubble_label.visible_ratio = 0.0
	_bubble.size = Vector2(_bubble.size.x, 10.0)
	if _line_tween != null:
		_line_tween.kill()
	_line_tween = create_tween()
	_line_tween.tween_property(_bubble, "modulate:a", 1.0, 0.15)
	_line_tween.tween_property(_bubble_label, "visible_ratio", 1.0, clampf(float(text.length()) * 0.016, 0.3, 1.8))


## The visible line (tests and screenshots).
func current_line() -> String:
	return _bubble_label.text


## A quick hop of the portrait (a nod after a sale, a flinch when the player is broke).
func nod(strength: float = 1.0) -> void:
	if _portrait == null:
		return
	if _nod_tween != null:
		_nod_tween.kill()
	var home: Vector2 = Vector2(_portrait.position.x, size.y - _portrait.size.y + 6.0)
	_portrait.position = home
	_nod_tween = create_tween()
	_nod_tween.tween_property(_portrait, "position:y", home.y - 18.0 * strength, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_nod_tween.tween_property(_portrait, "position:y", home.y, 0.18).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


## Switches to a portrait expression when the art has it (falls back to the base image).
func set_expression(expression: String) -> void:
	if _portrait != null and Portraits.has_expression(_portrait_id, expression):
		_portrait.texture = Portraits.texture_for(_portrait_id, expression)


func portrait_rect() -> Rect2:
	return Rect2(_portrait.position, _portrait.size) if _portrait != null else Rect2()



## Granny Gristle's raccoons peek over the bottom edge of the item panel now and then (comedy only).
func _schedule_raccoon(first_delay: float = 0.0) -> void:
	var wait: float = first_delay if first_delay > 0.0 else randf_range(9.0, 20.0)
	await get_tree().create_timer(wait).timeout
	if not is_inside_tree():
		return
	VendorFx.raccoon_peek(overlay, randf_range(inset + 80.0, size.x - 220.0))
	_schedule_raccoon()

## What the vendor does after `moment` ("buy", "poor", "sold_out"): a line, a nod and the vendor's own flourish (the stamp, the shout, sparkles).
func react(moment: String) -> void:
	say(moment)
	flourish(moment)


## The vendor's gesture for `moment` without a spoken line (a screen that has its own lines, like the tailor, uses this).
func flourish(moment: String) -> void:
	if moment == "poor":
		nod(0.35)
		return
	if moment != "buy":
		return
	nod(1.0)
	var middle: Vector2 = Vector2(inset + (size.x - inset) * 0.5, size.y * 0.46)
	match screen_id:
		"VS-LEDGERBONE":
			Audio.sfx(&"hit_heavy", -8.0)
			VendorFx.stamp(overlay, middle, STAMP_WORDS[randi() % STAMP_WORDS.size()])
			shake(7.0)
		"VS-BENCHLEY":
			nod(2.2)
			shake(10.0)
			_bubble.pivot_offset = Vector2(60.0, 20.0)
			var pop: Tween = create_tween()
			pop.tween_property(_bubble, "scale", Vector2(1.12, 1.12), 0.08)
			pop.tween_property(_bubble, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		"VS-SABLE", "VS-FENWICK", "VS-ALEMBIC", "VS-THREADWELL":
			VendorFx.sparkle(overlay, Rect2(inset, size.y * 0.1, size.x - inset, size.y * 0.7))


const STAMP_WORDS: Array[String] = ["APPROVED", "FILED", "STAMPED", "PROCESSED", "NOTARIZED"]


## A short screen shake (the stamp's thud, the coach's shout): the whole screen jiggles by `amount` px.
func shake(amount: float) -> void:
	var target: Control = get_parent() as Control
	if target == null:
		return
	var home: Vector2 = target.position
	var tween: Tween = create_tween()
	for step: int in range(4):
		tween.tween_property(target, "position", home + Vector2(randf_range(-amount, amount), randf_range(-amount, amount)) * (1.0 - float(step) / 4.0), 0.04)
	tween.tween_property(target, "position", home, 0.04)
