class_name MapNodeButton
extends Control
## One node on the dungeon map: a round token with an icon, a name, and a state
## (locked / available / cleared / current).

signal chosen(node_id: int)
signal hovered(node_id: int)
signal unhovered(node_id: int)

const DIAMETER: float = 104.0
const PLATE_MAX_WIDTH: float = 170.0
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

## The icon set's medallions (ICON-NODE-*); a node kind without one keeps the round token with its game-icons glyph.
const NODE_ICONS: Dictionary = {
	DungeonMap.Kind.START: "ICON-NODE-START",
	DungeonMap.Kind.BATTLE: "ICON-NODE-BATTLE",
	DungeonMap.Kind.CHALLENGE: "ICON-NODE-CHALLENGE",
	DungeonMap.Kind.SHRINE: "ICON-NODE-HEAL",
	DungeonMap.Kind.BOSS: "ICON-NODE-BOSS",
	DungeonMap.Kind.ELITE: "ICON-NODE-ELITE",
	DungeonMap.Kind.EVENT: "ICON-NODE-EVENT",
	DungeonMap.Kind.TREASURE: "ICON-NODE-TREASURE",
	DungeonMap.Kind.RESCUE: "ICON-NODE-RESCUE",
}
## Boss nodes are drawn this much larger than the others, around the same centre.
const BOSS_SCALE: float = 1.35
## The cleared and unreachable stamps are drawn this much of the medallion size, so the medallion still shows around the padlock.
const DONE_STAMP_SCALE: float = 0.9
const LOCKED_STAMP_SCALE: float = 0.66

var map_node: DungeonMap.MapNode
var available: bool = false
var cleared: bool = false
var _ring: Panel
var _glyph: TextureRect
var _medallion: TextureRect
var _done_stamp: TextureRect
var _locked_stamp: TextureRect
var _name_label: Label
var _plate: PanelContainer
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
	var medallion_id: String = str(NODE_ICONS.get(map_node.kind, ""))
	if IconArt.has(medallion_id):
		_build_medallion(medallion_id)
	else:
		var icon_key: String = str(KIND_ICONS.get(map_node.kind, "map"))
		_glyph = CardIcons.glyph(CardIcons.ui(icon_key), UIStyle.PARCHMENT, Vector2(60, 60))
		_glyph.position = Vector2(DIAMETER - 60.0, DIAMETER - 60.0) * 0.5
		_glyph.size = Vector2(60, 60)
		add_child(_glyph)
	_name_label = UIKit.label(map_node.title, &"", 20, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	_name_label.add_theme_font_override("font", UIStyle.font_bold())
	# Two short lines at most (an ellipsis after that), so neighbouring nodes never run their names together; the name sits on a small dark plate so it reads on any painted map.
	_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_name_label.max_lines_visible = 2
	_name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	var text_width: float = UIStyle.font_bold().get_string_size(map_node.title, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x
	_name_label.custom_minimum_size = Vector2(minf(text_width + 6.0, PLATE_MAX_WIDTH), 0.0)
	_plate = PanelContainer.new()
	_plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var plate_style: StyleBoxFlat = UIStyle.box(Color(0.05, 0.035, 0.08, 0.78), Color(UIStyle.GOLD_DIM, 0.5), 1, 8, 0)
	plate_style.content_margin_left = 6.0
	plate_style.content_margin_right = 6.0
	plate_style.content_margin_top = 1.0
	plate_style.content_margin_bottom = 1.0
	_plate.add_theme_stylebox_override("panel", plate_style)
	_plate.add_child(_name_label)
	add_child(_plate)
	_plate.position = Vector2((DIAMETER - (_name_label.custom_minimum_size.x + 12.0)) * 0.5, DIAMETER + 2.0)
	mouse_entered.connect(func() -> void:
		hovered.emit(map_node.id)
		if available:
			Audio.sfx(&"ui_hover", -8.0)
			create_tween().tween_property(self, "scale", Vector2(1.1, 1.1), 0.1))
	mouse_exited.connect(func() -> void:
		unhovered.emit(map_node.id)
		create_tween().tween_property(self, "scale", Vector2.ONE, 0.1))
	gui_input.connect(_on_input)
	PadClick.enable(self)  # controller support (Oct 26): the D-pad moves between nodes, A picks one
	refresh()


## The medallion icon, with the cleared stamp and the unreachable padlock stamp (ICON-NODE-DONE / ICON-NODE-LOCKED) laid over it; all centred on the node.
func _build_medallion(icon_id: String) -> void:
	var side: float = DIAMETER * (BOSS_SCALE if map_node.kind == DungeonMap.Kind.BOSS else 1.0)
	var middle: Vector2 = Vector2(DIAMETER, DIAMETER) * 0.5
	_medallion = _icon_at(icon_id, side, middle)
	_done_stamp = _icon_at("ICON-NODE-DONE", side * DONE_STAMP_SCALE, middle)
	_locked_stamp = _icon_at("ICON-NODE-LOCKED", side * LOCKED_STAMP_SCALE, middle)


func _icon_at(icon_id: String, side: float, middle: Vector2) -> TextureRect:
	var icon: TextureRect = IconArt.rect(icon_id, side)
	if icon == null:
		return null
	icon.size = Vector2(side, side)
	icon.position = middle - icon.size * 0.5
	add_child(icon)
	return icon


## Medallion states: available glows (a gold ring pulses around it), cleared wears the gold check stamp, unreachable is dimmed under the padlock stamp.
func _apply_medallion_state(border: Color) -> void:
	# The start node is where the hero came in: never shown as locked.
	var unreachable: bool = not available and not cleared and map_node.kind != DungeonMap.Kind.START
	_medallion.modulate = Color(0.62, 0.62, 0.68) if unreachable else Color.WHITE
	if _done_stamp != null:
		_done_stamp.visible = cleared
	if _locked_stamp != null:
		_locked_stamp.visible = unreachable
	var radius: int = int(_medallion.size.x * 0.5)
	var ring_style: StyleBoxFlat = UIStyle.box(Color(0, 0, 0, 0), border, 5, radius, 12) if available else UIStyle.box(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0, radius, 0)
	_ring.add_theme_stylebox_override("panel", ring_style)
	_ring.size = _medallion.size
	_ring.position = _medallion.position


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
	if _medallion != null:
		_apply_medallion_state(border)
	else:
		_ring.add_theme_stylebox_override("panel", UIStyle.box(base, border, 5 if available else 3, int(DIAMETER * 0.5), 12 if available else 4))
		(_glyph.material as ShaderMaterial).set_shader_parameter("tint", glyph_color)
	_plate.modulate.a = 1.0 if (available or cleared) else 0.8
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
