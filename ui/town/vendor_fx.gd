class_name VendorFx
extends RefCounted
## The small per-vendor effects of the vendor screens (the sheet's "UI / Interaction Notes"): cloches that lift on hover (Mirepoix), tin cans and supplement tubs the cards
## stand in (Gristle, Benchley), hidden compartments (Fig Sly), a frosted glass door (Tonic), velvet covers (Fenwick), a rubber stamp (Ledgerbone), a peeking raccoon
## (Gristle), sparkles (Sable). All drawn in code over the shop art; every one is purely cosmetic.


## Calls `on_change(hovered: bool)` whenever the mouse enters or leaves `target` (or one of its children, whatever their mouse filter).
class HoverWatch extends Node:
	var target: Control
	var on_change: Callable
	var _over: bool = false

	func _process(_delta: float) -> void:
		if target == null or not is_instance_valid(target) or not target.is_visible_in_tree():
			return
		var hovered: Control = target.get_viewport().gui_get_hovered_control()
		var over: bool = hovered != null and (hovered == target or target.is_ancestor_of(hovered))
		if over != _over:
			_over = over
			on_change.call(over)


static func watch_hover(target: Control, on_change: Callable) -> void:
	var watcher: HoverWatch = HoverWatch.new()
	watcher.target = target
	watcher.on_change = on_change
	target.add_child(watcher)


## A silver dome (a cloche) drawn over a card; `lift` 0 = covering it, 1 = raised away (it also fades out).
class Cloche extends Control:
	var lift: float = 0.0:
		set(value):
			lift = value
			queue_redraw()

	func _draw() -> void:
		var w: float = size.x
		var h: float = size.y
		var alpha: float = 0.5 * (1.0 - lift)
		if alpha <= 0.01:
			return
		var base_y: float = h - 6.0 - lift * h * 0.6
		var dome_h: float = h * 0.82
		var points: PackedVector2Array = PackedVector2Array()
		for step: int in range(0, 25):
			var angle: float = PI * float(step) / 24.0
			points.append(Vector2(w * 0.5 - cos(angle) * w * 0.5, base_y - sin(angle) * dome_h))
		draw_colored_polygon(points, Color(0.78, 0.82, 0.88, alpha))
		var inner: PackedVector2Array = PackedVector2Array()
		for step: int in range(0, 25):
			var angle: float = PI * float(step) / 24.0
			inner.append(Vector2(w * 0.5 - cos(angle) * w * 0.4, base_y - sin(angle) * dome_h * 0.9))
		draw_colored_polygon(inner, Color(0.92, 0.95, 1.0, alpha * 0.35))
		draw_polyline(points, Color(0.96, 0.97, 1.0, alpha + 0.2), 3.0)
		draw_line(Vector2(w * 0.06, base_y), Vector2(w * 0.94, base_y), Color(0.55, 0.58, 0.64, alpha + 0.3), 6.0)
		draw_circle(Vector2(w * 0.5, base_y - dome_h - 8.0), 11.0, Color(0.88, 0.9, 0.96, alpha + 0.3))
		draw_arc(Vector2(w * 0.32, base_y - dome_h * 0.45), dome_h * 0.5, PI * 1.05, PI * 1.35, 12, Color(1, 1, 1, alpha * 0.9), 5.0)


## Puts a cloche over `area` of `holder` that lifts while the mouse is over the tile.
static func add_cloche(holder: Control, area: Rect2) -> void:
	var dome: Cloche = Cloche.new()
	dome.name = "Cloche"
	dome.position = area.position
	dome.size = area.size
	dome.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dome.z_index = 3
	holder.add_child(dome)
	var tween_holder: Array[Tween] = []
	watch_hover(holder, func(over: bool) -> void:
		if not tween_holder.is_empty() and tween_holder[0].is_valid():
			tween_holder[0].kill()
		tween_holder.clear()
		var tween: Tween = dome.create_tween()
		tween_holder.append(tween)
		tween.tween_property(dome, "lift", 1.0 if over else 0.0, 0.28 if over else 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT))


## The kinds of stand a card is placed in.
enum Stand { CAN, TUB }


class StandFront extends Control:
	var kind: Stand = Stand.CAN
	var tint: Color = Color(0.7, 0.72, 0.76)

	func _draw() -> void:
		var w: float = size.x
		var h: float = size.y
		var body: Rect2 = Rect2(0.0, 0.0, w, h)
		if kind == Stand.CAN:
			draw_rect(body, tint.darkened(0.15))
			draw_rect(Rect2(0.0, 0.0, w, h * 0.12), tint.lightened(0.25))
			draw_rect(Rect2(0.0, h * 0.30, w, h * 0.42), Color(0.78, 0.3, 0.2))
			draw_rect(Rect2(w * 0.12, h * 0.38, w * 0.76, h * 0.26), Color(0.95, 0.88, 0.7))
			draw_circle(Vector2(w * 0.5, h * 0.51), h * 0.09, Color(0.78, 0.3, 0.2))
			for index: int in range(1, 6):
				draw_line(Vector2(w * float(index) / 6.0, h * 0.14), Vector2(w * float(index) / 6.0, h), Color(1, 1, 1, 0.08), 3.0)
			draw_rect(Rect2(0.0, 0.0, w, h), tint.lightened(0.4), false, 3.0)
		else:
			# A supplement tub seen from the front, tucked under the card: lid, label stripe.
			draw_rect(body, tint)
			draw_rect(Rect2(0.0, 0.0, w, h * 0.26), tint.lightened(0.3))
			draw_rect(Rect2(0.0, h * 0.26, w, h * 0.06), tint.darkened(0.35))
			draw_rect(Rect2(w * 0.06, h * 0.5, w * 0.88, h * 0.16), Color(0.98, 0.96, 0.9, 0.9))
			draw_rect(Rect2(0.0, 0.0, w, h), tint.lightened(0.3), false, 3.0)


## A can or tub drawn over the lower part of a card (`card_area`); the card sits in it. Returns the front so a caller can raise the card on hover.
static func add_stand(holder: Control, card_area: Rect2, kind: Stand, tint: Color) -> StandFront:
	var front: StandFront = StandFront.new()
	front.name = "Stand"
	front.kind = kind
	front.tint = tint
	var height: float = card_area.size.y * 0.30 if kind == Stand.CAN else 50.0
	front.position = Vector2(card_area.position.x - 2.0, card_area.end.y - height + 4.0 if kind == Stand.CAN else card_area.end.y - 8.0)
	front.size = Vector2(card_area.size.x + 4.0, height)
	front.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(front)
	return front


## Makes `card` rise by `lift` px while the mouse is over `holder` (a card pulled out of its can).
static func add_pull_out(holder: Control, card: Control, rest: Vector2, lift: float) -> void:
	card.position = rest
	var tween_holder: Array[Tween] = []
	watch_hover(holder, func(over: bool) -> void:
		if not tween_holder.is_empty() and tween_holder[0].is_valid():
			tween_holder[0].kill()
		tween_holder.clear()
		var tween: Tween = card.create_tween()
		tween_holder.append(tween)
		tween.tween_property(card, "position:y", rest.y - (lift if over else 0.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT))


## A hidden compartment: a wooden door over `area` of `holder` that slides up while the mouse is over the tile, revealing the goods behind it.
static func add_compartment(holder: Control, area: Rect2) -> void:
	holder.clip_contents = true
	var door: Panel = Panel.new()
	door.name = "Compartment"
	var style: StyleBoxFlat = UIStyle.box(Color(0.22, 0.13, 0.08, 0.97), Color(0.7, 0.5, 0.2), 3, 10)
	door.add_theme_stylebox_override("panel", style)
	door.position = area.position
	door.size = area.size
	door.mouse_filter = Control.MOUSE_FILTER_IGNORE
	door.z_index = 3
	holder.add_child(door)
	for plank: int in range(1, 5):
		var seam: ColorRect = ColorRect.new()
		seam.color = Color(0, 0, 0, 0.28)
		seam.position = Vector2(0.0, area.size.y * float(plank) / 5.0)
		seam.size = Vector2(area.size.x, 3.0)
		seam.mouse_filter = Control.MOUSE_FILTER_IGNORE
		door.add_child(seam)
	var handle: ColorRect = ColorRect.new()
	handle.color = Color(0.82, 0.62, 0.25)
	handle.size = Vector2(46, 10)
	handle.position = Vector2(area.size.x * 0.5 - 23.0, area.size.y * 0.5)
	handle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	door.add_child(handle)
	var knot: Label = UIKit.label("?", &"", 54, Color(0.7, 0.5, 0.2, 0.7), HORIZONTAL_ALIGNMENT_CENTER)
	knot.position = Vector2(0.0, area.size.y * 0.2)
	knot.size = Vector2(area.size.x, 70.0)
	knot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	door.add_child(knot)
	var tween_holder: Array[Tween] = []
	watch_hover(holder, func(over: bool) -> void:
		if not tween_holder.is_empty() and tween_holder[0].is_valid():
			tween_holder[0].kill()
		tween_holder.clear()
		var tween: Tween = door.create_tween()
		tween_holder.append(tween)
		tween.tween_property(door, "position:y", area.position.y - area.size.y - 12.0 if over else area.position.y, 0.24 if over else 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT))


## A frosted pane over `parent` (a shelf behind glass); null-safe label in the middle.
static func frosted_pane(text: String) -> Panel:
	var pane: Panel = Panel.new()
	pane.name = "FrostedGlass"
	pane.add_theme_stylebox_override("panel", UIStyle.box(Color(0.78, 0.9, 0.97, 0.30), Color(0.92, 0.97, 1.0, 0.8), 4, 14))
	pane.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pane.z_index = 3
	var label: Label = UIKit.label(text, &"", 26, Color(0.06, 0.1, 0.16), HORIZONTAL_ALIGNMENT_CENTER)
	label.add_theme_font_override("font", UIStyle.font_bold())
	label.add_theme_stylebox_override("normal", UIStyle.box(Color(0.9, 0.96, 1.0, 0.85), Color(1, 1, 1, 0.9), 2, 10))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	label.custom_minimum_size = Vector2(380, 0)
	label.position = Vector2(-190.0, -30.0)
	pane.add_child(label)
	return pane


## A velvet cloth over a pedestal: a bell-shaped drape in `colour` with folds and a tassel.
class VelvetCover extends Control:
	var cloth: Color = Color(0.5, 0.1, 0.18)

	func _draw() -> void:
		var w: float = size.x
		var h: float = size.y
		var points: PackedVector2Array = PackedVector2Array()
		for step: int in range(0, 21):
			var angle: float = PI * float(step) / 20.0
			points.append(Vector2(w * 0.5 - cos(angle) * w * 0.48, h * 0.9 - sin(angle) * h * 0.88))
		points.append(Vector2(w * 0.98, h * 0.98))
		points.append(Vector2(w * 0.02, h * 0.98))
		draw_colored_polygon(points, cloth)
		for fold: int in range(-3, 4):
			var x: float = w * 0.5 + float(fold) * w * 0.12
			draw_line(Vector2(x * 0.5 + w * 0.25, h * 0.25 + absf(float(fold)) * 10.0), Vector2(x, h * 0.97), cloth.darkened(0.3), 4.0)
			draw_line(Vector2(x * 0.5 + w * 0.25 + 6.0, h * 0.25 + absf(float(fold)) * 10.0), Vector2(x + 6.0, h * 0.97), cloth.lightened(0.18), 2.0)
		draw_polyline(points, cloth.lightened(0.35), 3.0)
		draw_line(Vector2(w * 0.02, h * 0.98), Vector2(w * 0.98, h * 0.98), Color(0.9, 0.75, 0.3), 6.0)
		draw_circle(Vector2(w * 0.5, h * 0.06), 9.0, Color(0.9, 0.75, 0.3))


static func velvet_cover(cloth: Color) -> VelvetCover:
	var cover: VelvetCover = VelvetCover.new()
	cover.name = "VelvetCover"
	cover.cloth = cloth
	cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return cover


## Twinkling four-point stars over a rect, for a few seconds (`parent` is any Control; the node frees itself).
class Sparkles extends Control:
	var _age: float = 0.0
	var _stars: Array[Vector3] = []
	var duration: float = 2.4

	func _ready() -> void:
		for index: int in range(14):
			_stars.append(Vector3(randf() * size.x, randf() * size.y, randf() * 0.8))

	func _process(delta: float) -> void:
		_age += delta
		queue_redraw()
		if _age >= duration:
			queue_free()

	func _draw() -> void:
		for star: Vector3 in _stars:
			var phase: float = clampf((_age - star.z) / 0.9, 0.0, 1.0)
			if phase <= 0.0 or phase >= 1.0:
				continue
			var pulse: float = sin(phase * PI)
			var reach: float = 14.0 * pulse
			var colour: Color = Color(1.0, 0.92, 0.55, pulse)
			var centre: Vector2 = Vector2(star.x, star.y)
			draw_line(centre - Vector2(reach, 0.0), centre + Vector2(reach, 0.0), colour, 3.0)
			draw_line(centre - Vector2(0.0, reach), centre + Vector2(0.0, reach), colour, 3.0)
			draw_circle(centre, 3.0 * pulse, Color(1, 1, 1, pulse))


static func sparkle(parent: Control, rect: Rect2) -> void:
	var node: Sparkles = Sparkles.new()
	node.position = rect.position
	node.size = rect.size
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(node)


## The government stamp: a boxed word slammed on the screen at `centre` (in `parent`'s space) with a thud, then fading.
static func stamp(parent: Control, centre: Vector2, word: String) -> void:
	var holder: Control = Control.new()
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.position = centre
	holder.rotation = deg_to_rad(randf_range(-14.0, -6.0))
	holder.z_index = 20
	var label: Label = UIKit.label(word, &"", 76, Color(0.78, 0.12, 0.14))
	label.add_theme_font_override("font", UIStyle.font_title())
	label.add_theme_stylebox_override("normal", UIStyle.box(Color(0.9, 0.85, 0.8, 0.0), Color(0.78, 0.12, 0.14, 0.95), 8, 10))
	label.add_theme_constant_override("outline_size", 0)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	holder.add_child(label)
	parent.add_child(holder)
	var half: Vector2 = label.get_combined_minimum_size() * 0.5
	label.position = -half
	holder.pivot_offset = Vector2.ZERO
	holder.scale = Vector2(2.6, 2.6)
	holder.modulate.a = 0.0
	var tween: Tween = holder.create_tween()
	tween.set_parallel(true)
	tween.tween_property(holder, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(holder, "modulate:a", 1.0, 0.1)
	tween.chain().tween_interval(0.9)
	tween.chain().tween_property(holder, "modulate:a", 0.0, 0.5)
	tween.chain().tween_callback(holder.queue_free)


## A raccoon head that peeks up from the bottom edge of `parent` at `x`, looks around and ducks away (comedy only).
class Raccoon extends Control:
	func _draw() -> void:
		var fur: Color = Color(0.45, 0.45, 0.5)
		draw_circle(Vector2(36.0, 38.0), 4.0, fur)
		draw_colored_polygon(PackedVector2Array([Vector2(8, 38), Vector2(14, 6), Vector2(36, 24)]), fur.darkened(0.3))
		draw_colored_polygon(PackedVector2Array([Vector2(92, 38), Vector2(86, 6), Vector2(64, 24)]), fur.darkened(0.3))
		draw_circle(Vector2(50.0, 66.0), 44.0, fur)
		draw_rect(Rect2(8.0, 52.0, 84.0, 22.0), Color(0.12, 0.12, 0.15))
		draw_circle(Vector2(32.0, 62.0), 11.0, Color(1, 1, 1))
		draw_circle(Vector2(68.0, 62.0), 11.0, Color(1, 1, 1))
		draw_circle(Vector2(35.0, 63.0), 5.0, Color(0.05, 0.05, 0.05))
		draw_circle(Vector2(71.0, 63.0), 5.0, Color(0.05, 0.05, 0.05))
		draw_circle(Vector2(50.0, 86.0), 8.0, Color(0.1, 0.08, 0.08))
		draw_line(Vector2(50, 94), Vector2(50, 106), Color(0.1, 0.08, 0.08), 3.0)


static func raccoon_peek(parent: Control, x: float) -> void:
	var animal: Raccoon = Raccoon.new()
	animal.name = "Raccoon"
	animal.size = Vector2(100, 108)
	animal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	animal.position = Vector2(x, parent.size.y)
	animal.z_index = 10
	parent.add_child(animal)
	var tween: Tween = animal.create_tween()
	tween.tween_property(animal, "position:y", parent.size.y - 96.0, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(animal, "position:x", x - 26.0, 0.4)
	tween.tween_property(animal, "position:x", x + 26.0, 0.6)
	tween.tween_property(animal, "position:y", parent.size.y + 4.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(animal.queue_free)
