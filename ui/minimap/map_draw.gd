class_name MapDraw
extends RefCounted
## Drawing helpers shared by the minimap and the full map: POI icons and the player's facing arrow. The icon set (IconArt, ICON-MAP-*) draws the points that
## have an icon; the others (and every point while an icon is missing) keep the coloured disc with a one-letter glyph.

## POI kind -> icon id. Kinds not listed (interactables, challengers, pads, rafts...) keep the disc. There is no kind for chests or secrets, so none can be drawn.
const POI_ICONS: Dictionary = {
	MapPoi.Kind.VENDOR: "ICON-MAP-VENDOR",
	MapPoi.Kind.HEAL: "ICON-MAP-HEAL",
	MapPoi.Kind.DUNGEON: "ICON-MAP-DUNGEON",
	MapPoi.Kind.MINI_DUNGEON: "ICON-MAP-SIDEDUNGEON",
	MapPoi.Kind.PUZZLE: "ICON-MAP-PUZZLE",
	MapPoi.Kind.QUIZ: "ICON-MAP-QUIZ",
	MapPoi.Kind.MINIGAME: "ICON-MAP-MINIGAME",
	MapPoi.Kind.EXIT: "ICON-MAP-EXIT",
	MapPoi.Kind.TRAVEL_THROW: "ICON-MAP-TRAVEL",
	MapPoi.Kind.TRAVEL_PORTAL: "ICON-MAP-TRAVEL",
	MapPoi.Kind.ARENA: "ICON-MAP-ARENA",
}
## An icon is drawn this many times its disc radius wide.
const ICON_SCALE: float = 2.7


## The icon id of a POI kind, or "" when it keeps the disc (or the icon is missing).
static func icon_id(kind: MapPoi.Kind) -> String:
	var id: String = str(POI_ICONS.get(kind, ""))
	return id if id != "" and IconArt.has(id) else ""


## A POI icon: the icon (on a dark backing so it reads on any ground), or a coloured disc with a one-letter glyph; quest givers with a quest get the
## "available" or "turn in" icon above their head; locked travel points are dimmed.
static func poi(canvas: CanvasItem, centre: Vector2, point: MapPoi, radius: float) -> void:
	if point.objective:
		objective_ring(canvas, centre, radius, Color("8fd3ff") if point.side_goal else Color("ffd25a"))
		return
	var icon: String = icon_id(point.kind)
	if icon != "":
		_poi_icon(canvas, centre, icon, radius, point.locked)
	else:
		_poi_disc(canvas, centre, point, radius)
	if point.quest_marker:
		_quest_badge(canvas, centre + Vector2(radius * 0.9, -radius * 1.2), radius, point.turn_in)


static func _poi_icon(canvas: CanvasItem, centre: Vector2, icon: String, radius: float, dimmed: bool) -> void:
	var side: float = radius * ICON_SCALE
	canvas.draw_circle(centre, side * 0.5 + 0.5, Color(0.04, 0.03, 0.07, 0.62))
	var tex: Texture2D = IconArt.texture(icon, side)
	canvas.draw_texture_rect(tex, Rect2(centre - Vector2(side, side) * 0.5, Vector2(side, side)), false, Color(0.45, 0.45, 0.5, 0.8) if dimmed else Color.WHITE)


static func _poi_disc(canvas: CanvasItem, centre: Vector2, point: MapPoi, radius: float) -> void:
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


## The marker over an NPC: the golden "!" icon while a quest is on offer, the golden "?" icon when one can be handed in (the old "!" badge without the icons).
static func _quest_badge(canvas: CanvasItem, badge: Vector2, radius: float, turn_in: bool) -> void:
	var id: String = "ICON-MAP-TURNIN" if turn_in else "ICON-MAP-QUEST"
	if IconArt.has(id):
		var side: float = radius * 2.3
		canvas.draw_texture_rect(IconArt.texture(id, side), Rect2(badge - Vector2(side, side) * 0.5, Vector2(side, side)), false)
		return
	var font: Font = UIStyle.font_bold()
	canvas.draw_circle(badge, radius * 0.62, Color(0, 0, 0, 0.9))
	canvas.draw_circle(badge, radius * 0.5, Color("ffe14d"))
	canvas.draw_string(font, badge + Vector2(-radius * 0.18, radius * 0.3), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, int(radius * 0.95), Color(0.1, 0.05, 0.0))


## The tracked quest's objective: a pulsing golden ring with a bright centre.
static func objective_ring(canvas: CanvasItem, centre: Vector2, radius: float, gold: Color = Color("ffd25a")) -> void:
	var pulse: float = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.005)
	canvas.draw_arc(centre, radius * (1.3 + 0.5 * pulse), 0.0, TAU, 28, Color(gold, 0.9 - 0.5 * pulse), 3.0)
	canvas.draw_circle(centre, radius * 0.75, Color(0.08, 0.05, 0.02, 0.9))
	canvas.draw_circle(centre, radius * 0.5, gold)


## The player arrow pointing where the hero faces. `yaw` is the model's rotation.y (0 = facing +z,
## i.e. down the screen on a north-up map). With the icon (ICON-MAP-PLAYER, drawn pointing up) the picture is rotated; otherwise the plain polygon arrow.
static func arrow(canvas: CanvasItem, centre: Vector2, yaw: float, size: float) -> void:
	if IconArt.has("ICON-MAP-PLAYER"):
		var side: float = size * 2.8
		canvas.draw_set_transform(centre, PI - yaw, Vector2.ONE)
		canvas.draw_texture_rect(IconArt.texture("ICON-MAP-PLAYER", side), Rect2(-Vector2(side, side) * 0.5, Vector2(side, side)), false)
		canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	var direction: Vector2 = Vector2(sin(yaw), cos(yaw))
	var side_vector: Vector2 = Vector2(-direction.y, direction.x)
	var tip: Vector2 = centre + direction * size
	var left: Vector2 = centre - direction * size * 0.7 + side_vector * size * 0.7
	var right: Vector2 = centre - direction * size * 0.7 - side_vector * size * 0.7
	var notch: Vector2 = centre - direction * size * 0.25
	canvas.draw_colored_polygon(PackedVector2Array([tip, left, notch, right]), Color("fffbe8"))
	var outline: PackedVector2Array = PackedVector2Array([tip, left, notch, right, tip])
	canvas.draw_polyline(outline, Color(0.05, 0.05, 0.1), 2.0)
