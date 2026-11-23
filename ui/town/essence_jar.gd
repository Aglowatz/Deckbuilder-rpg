class_name EssenceJar
extends Control
## Fable Nov 21 castle (Part 8): one glass essence jar of Auntie Alembic's shelf. It fills to `capacity` (18) with essence in its
## Path's colour, shows the number on the glass, and lights up when it is chosen for the brew. Drawn here (a cork, the glass, the
## liquid with a bright surface line, a few bubbles and a shine) until Batch 19 paints an empty jar (`JAR_ART`), which then lies over the
## liquid: the game still fills and tints it.
## Batch 19 (Fable Nov 22 night): UI-ALEMBIC-JAR is in. Its inside is truly transparent (checked: one closed hole, alpha 0), so the
## liquid, the bubbles and the dark of the glass are drawn in that hole (`ART_HOLE`, as fractions of the picture) and the painting lies
## over them at its own proportions; the number is drawn on top.

const JAR_ART: String = "UI-ALEMBIC-JAR"
const SIZE: Vector2 = Vector2(150, 190)
## The see-through inside of the painted jar, as a fraction of the (trimmed) picture: left, top, width, height.
const ART_HOLE: Rect2 = Rect2(0.109, 0.281, 0.801, 0.648)

var path: Affinity.Type = Affinity.Type.BEEFCAKE
var amount: int = 0
var capacity: int = 18
var chosen: bool = false
var _time: float = 0.0
var _shown_level: float = 0.0


static func make(jar_path: Affinity.Type, jar_capacity: int) -> EssenceJar:
	var jar: EssenceJar = EssenceJar.new()
	jar.name = "Jar"
	jar.path = jar_path
	jar.capacity = maxi(1, jar_capacity)
	jar.custom_minimum_size = SIZE
	jar.size = SIZE
	jar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return jar


func set_state(new_amount: int, is_chosen: bool) -> void:
	amount = clampi(new_amount, 0, capacity)
	chosen = is_chosen
	queue_redraw()


## How full the jar is drawn, 0..1 (the liquid eases to its level).
func level() -> float:
	return float(amount) / float(capacity)


func _ready() -> void:
	_shown_level = level()


func _process(delta: float) -> void:
	_time += delta
	var target: float = level()
	if absf(_shown_level - target) > 0.002:
		_shown_level = lerpf(_shown_level, target, minf(1.0, delta * 6.0))
		queue_redraw()
	elif chosen or amount > 0:
		queue_redraw()  # the surface shimmers and the bubbles rise


func _draw() -> void:
	var colour: Color = UIStyle.affinity_color(path)
	var body: Rect2 = Rect2(18, 34, SIZE.x - 36, SIZE.y - 46)
	var neck: Rect2 = Rect2(42, 18, SIZE.x - 84, 22)
	var painted: bool = UiArt.has(JAR_ART)
	var art_rect: Rect2 = Rect2(Vector2.ZERO, SIZE)
	if painted:
		art_rect = painted_rect(UiArt.texture(JAR_ART).get_size())
		body = hole_rect(art_rect).grow(3.0)
	# the glow of a chosen jar
	if chosen:
		for ring: int in range(4):
			var grow: float = 6.0 + float(ring) * 5.0
			draw_style_box(UIStyle.box(Color(0, 0, 0, 0), Color(UIStyle.GOLD, 0.34 - 0.07 * float(ring)), 3, 26 + int(grow)), (body.grow(9.0) if painted else body).grow(grow))
	# the glass, dark inside
	draw_style_box(UIStyle.box(Color(0.06, 0.05, 0.11, 0.86), Color(0, 0, 0, 0), 0, 22), body)
	if not painted:
		draw_style_box(UIStyle.box(Color(0.06, 0.05, 0.11, 0.86), Color(0, 0, 0, 0), 0, 6), neck)
	# the liquid
	var inner: Rect2 = body if painted else body.grow(-6.0)
	var tall: float = inner.size.y * clampf(_shown_level, 0.0, 1.0)
	if tall > 1.0:
		var liquid: Rect2 = Rect2(inner.position.x, inner.end.y - tall, inner.size.x, tall)
		var lit: Color = colour.lightened(0.18) if chosen else colour.darkened(0.08)
		draw_style_box(UIStyle.box(Color(lit, 0.92), Color(0, 0, 0, 0), 0, 16 if tall > 30.0 else 6), liquid)
		draw_rect(Rect2(liquid.position.x + 3.0, liquid.position.y, liquid.size.x - 6.0, 4.0), colour.lightened(0.55))
		for bubble: int in range(4):
			var phase: float = fmod(_time * (0.22 + 0.05 * float(bubble)) + float(bubble) * 0.27, 1.0)
			var at: Vector2 = Vector2(liquid.position.x + 16.0 + float(bubble) * (liquid.size.x - 32.0) / 3.0 + sin(_time * 2.0 + float(bubble)) * 3.0, liquid.end.y - 8.0 - phase * maxf(0.0, tall - 14.0))
			if tall > 18.0:
				draw_circle(at, 2.5 + float(bubble % 2), Color(1, 1, 1, 0.32 * (1.0 - phase)))
	# the painted jar over the liquid, or the drawn glass
	if painted:
		draw_texture_rect(UiArt.texture(JAR_ART), art_rect, false, Color(1.18, 1.18, 1.18) if chosen else Color.WHITE)
	else:
		var rim: Color = Color(0.82, 0.9, 1.0, 0.9) if chosen else Color(0.72, 0.8, 0.92, 0.62)
		draw_style_box(UIStyle.box(Color(0, 0, 0, 0), rim, 4, 22), body)
		draw_style_box(UIStyle.box(Color(0, 0, 0, 0), rim, 4, 6), neck)
		draw_rect(Rect2(body.position.x + 12.0, body.position.y + 16.0, 7.0, body.size.y * 0.5), Color(1, 1, 1, 0.16))
		# the cork
		draw_style_box(UIStyle.box(Color("b98a55"), Color("6b4a2b"), 3, 6), Rect2(46, 4, SIZE.x - 92, 20))
	# the number on the glass
	var font: Font = UIStyle.font_title()
	var words: String = str(amount)
	var px: int = 44
	var width: float = font.get_string_size(words, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
	var number_at: Vector2 = Vector2((SIZE.x - width) * 0.5, body.position.y + body.size.y * 0.5 + 12.0)
	draw_string_outline(font, number_at, words, HORIZONTAL_ALIGNMENT_LEFT, -1, px, 8, Color(0.04, 0.02, 0.08, 0.95))
	draw_string(font, number_at, words, HORIZONTAL_ALIGNMENT_LEFT, -1, px, UIStyle.GOLD if amount >= capacity else Color.WHITE)
	var small: String = "of %d" % capacity
	var small_width: float = font.get_string_size(small, HORIZONTAL_ALIGNMENT_LEFT, -1, 17).x
	var small_at: Vector2 = Vector2((SIZE.x - small_width) * 0.5, number_at.y + 22.0)
	draw_string_outline(font, small_at, small, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, 5, Color(0.04, 0.02, 0.08, 0.95))
	draw_string(font, small_at, small, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color(0.86, 0.84, 0.78))


## Where the painted jar is drawn inside the control: as tall as the control, at the picture's own proportions, centred.
static func painted_rect(texture_size: Vector2) -> Rect2:
	var wide: float = SIZE.y * texture_size.x / maxf(1.0, texture_size.y)
	return Rect2((SIZE.x - wide) * 0.5, 0.0, wide, SIZE.y)


## The see-through inside of the painted jar drawn in `art_rect`.
static func hole_rect(art_rect: Rect2) -> Rect2:
	return Rect2(art_rect.position + ART_HOLE.position * art_rect.size, ART_HOLE.size * art_rect.size)
