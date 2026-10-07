class_name MapNodeButton
extends Control
## One node on the dungeon map: a round token with an icon, a name, and a state
## (locked / available / cleared / current).

signal chosen(node_id: int)
signal hovered(node_id: int)
signal unhovered(node_id: int)

const DIAMETER: float = 104.0
const KIND_ICONS: Dictionary = {
	DungeonMap.Kind.START: "map",
	DungeonMap.Kind.BATTLE: "attack",
	DungeonMap.Kind.CHALLENGE: "rune",
	DungeonMap.Kind.SHRINE: "fountain",
	DungeonMap.Kind.BOSS: "skull",
	DungeonMap.Kind.ELITE: "skull",
	DungeonMap.Kind.EVENT: "rune",
	DungeonMap.Kind.TREASURE: "gems",
	DungeonMap.Kind.RESCUE: "hp",
}

var map_node: DungeonMap.MapNode
var available: bool = false
var cleared: bool = false
var _ring: Panel
var _glyph: TextureRect
var _name_label: Label
var _pulse: Tween


func setup(node: DungeonMap.MapNode, is_available: bool, is_cleared: bool) -> void:
	map_node = node
	available = is_available
	cleared = is_cleared


func _ready() -> void:
	custom_minimum_size = Vector2(DIAMETER, DIAMETER + 46.0)
	size = Vector2(DIAMETER, DIAMETER + 46.0)
	pivot_offset = Vector2(DIAMETER, DIAMETER) * 0.5
	mouse_filter = Control.MOUSE_FILTER_STOP
	_ring = Panel.new()
	_ring.size = Vector2(DIAMETER, DIAMETER)
	_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_ring)
	var icon_key: String = str(KIND_ICONS.get(map_node.kind, "map"))
	_glyph = CardIcons.glyph(CardIcons.ui(icon_key), UIStyle.PARCHMENT, Vector2(60, 60))
	_glyph.position = Vector2(DIAMETER - 60.0, DIAMETER - 60.0) * 0.5
	_glyph.size = Vector2(60, 60)
	add_child(_glyph)
	_name_label = UIKit.label(map_node.title, &"", 20, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	_name_label.add_theme_font_override("font", UIStyle.font_bold())
	_name_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_name_label.add_theme_constant_override("outline_size", 6)
	# Two short lines at most, so neighbouring nodes never run their names together.
	_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_name_label.max_lines_visible = 2
	_name_label.position = Vector2(-22, DIAMETER + 4.0)
	_name_label.size = Vector2(DIAMETER + 44.0, 56)
	add_child(_name_label)
	mouse_entered.connect(func() -> void:
		hovered.emit(map_node.id)
		if available:
			Audio.sfx(&"ui_hover", -8.0)
			create_tween().tween_property(self, "scale", Vector2(1.1, 1.1), 0.1))
	mouse_exited.connect(func() -> void:
		unhovered.emit(map_node.id)
		create_tween().tween_property(self, "scale", Vector2.ONE, 0.1))
	gui_input.connect(_on_input)
	refresh()


func refresh() -> void:
	var boss: bool = map_node.kind == DungeonMap.Kind.BOSS
	var base: Color = Color("6b2f3a") if boss else (Color("5e3328") if map_node.kind == DungeonMap.Kind.ELITE else Color("3a2d55"))
	var border: Color = UIStyle.GOLD_DIM
	var glyph_color: Color = UIStyle.PARCHMENT
	if cleared:
		base = Color("2f5a3a")
		border = UIStyle.GOOD
	elif available:
		border = UIStyle.GOLD
		base = base.lightened(0.12)
	else:
		base = base.darkened(0.35)
		glyph_color = Color(UIStyle.PARCHMENT, 0.45)
	_ring.add_theme_stylebox_override("panel", UIStyle.box(base, border, 5 if available else 3, int(DIAMETER * 0.5), 12 if available else 4))
	(_glyph.material as ShaderMaterial).set_shader_parameter("tint", glyph_color)
	_name_label.modulate.a = 1.0 if (available or cleared) else 0.55
	if _pulse != null and _pulse.is_valid():
		_pulse.kill()
	if available:
		_pulse = create_tween().set_loops()
		_pulse.tween_property(_ring, "modulate", Color(1.35, 1.25, 1.0), 0.7).set_trans(Tween.TRANS_SINE)
		_pulse.tween_property(_ring, "modulate", Color.WHITE, 0.7).set_trans(Tween.TRANS_SINE)
	else:
		_ring.modulate = Color.WHITE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if available else Control.CURSOR_ARROW


func _on_input(event: InputEvent) -> void:
	var click: InputEventMouseButton = event as InputEventMouseButton
	if click != null and click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
		if available:
			chosen.emit(map_node.id)
		else:
			Audio.sfx(&"ui_error", -6.0)


func center_point() -> Vector2:
	return position + Vector2(DIAMETER, DIAMETER) * 0.5
