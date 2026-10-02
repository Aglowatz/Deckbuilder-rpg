class_name MapDraw
extends RefCounted
## Drawing helpers shared by the minimap and the full map: POI icons and the player's facing arrow.


## A POI icon: a coloured disc with a one-letter glyph; quest givers with a quest get a "!" badge;
## locked travel points are dimmed.
static func poi(canvas: CanvasItem, centre: Vector2, point: MapPoi, radius: float) -> void:
	var color: Color = MapPoi.kind_color(point.kind)
	if point.locked:
		color = color.darkened(0.5)
		color.a = 0.8
	canvas.draw_circle(centre, radius + 1.5, Color(0, 0, 0, 0.85))
	canvas.draw_circle(centre, radius, color)
	var font: Font = UIStyle.font_bold()
	var size: int = int(radius * 1.5)
	var glyph: String = MapPoi.kind_glyph(point.kind)
	var extent: Vector2 = font.get_string_size(glyph, HORIZONTAL_ALIGNMENT_LEFT, -1, size)
	canvas.draw_string(font, centre + Vector2(-extent.x * 0.5, extent.y * 0.3), glyph, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(0.05, 0.05, 0.08))
	if point.quest_marker:
		var badge: Vector2 = centre + Vector2(radius * 0.9, -radius * 1.1)
		canvas.draw_circle(badge, radius * 0.62, Color(0, 0, 0, 0.9))
		canvas.draw_circle(badge, radius * 0.5, Color("ffe14d"))
		canvas.draw_string(font, badge + Vector2(-radius * 0.18, radius * 0.3), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, int(radius * 0.95), Color(0.1, 0.05, 0.0))


## The player arrow pointing where the hero faces. `yaw` is the model's rotation.y (0 = facing +z,
## i.e. down the screen on a north-up map).
static func arrow(canvas: CanvasItem, centre: Vector2, yaw: float, size: float) -> void:
	var direction: Vector2 = Vector2(sin(yaw), cos(yaw))
	var side: Vector2 = Vector2(-direction.y, direction.x)
	var tip: Vector2 = centre + direction * size
	var left: Vector2 = centre - direction * size * 0.7 + side * size * 0.7
	var right: Vector2 = centre - direction * size * 0.7 - side * size * 0.7
	var notch: Vector2 = centre - direction * size * 0.25
	canvas.draw_colored_polygon(PackedVector2Array([tip, left, notch, right]), Color("fffbe8"))
	var outline: PackedVector2Array = PackedVector2Array([tip, left, notch, right, tip])
	canvas.draw_polyline(outline, Color(0.05, 0.05, 0.1), 2.0)
