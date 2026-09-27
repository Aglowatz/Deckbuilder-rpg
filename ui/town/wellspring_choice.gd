class_name WellspringChoice
extends Control
## The starter-deck choice at the Wellspring: pick the color the Wanderer is drawn to. It
## decides the color of the 17 basic lands in the starter deck (see
## docs/design/starting_deck_and_affinity.md).

signal chosen(color: Affinity.Type)
signal closed

const OPTIONS: Array[Affinity.Type] = [Affinity.Type.A, Affinity.Type.B, Affinity.Type.C, Affinity.Type.D]
const LAND_ICON_IDS: Dictionary = {
	Affinity.Type.A: "land_affinity_a",
	Affinity.Type.B: "land_affinity_b",
	Affinity.Type.C: "land_affinity_c",
	Affinity.Type.D: "land_affinity_d",
}

var selected: Affinity.Type = Affinity.Type.NEUTRAL
var _tiles: Dictionary = {}
var _confirm: FancyButton
var _summary: Label


func _ready() -> void:
	UIKit.full_rect(self)
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.02, 0.02, 0.06, 0.78)
	UIKit.full_rect(shade)
	add_child(shade)
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	add_child(center)
	var panel: PanelContainer = UIKit.panel()
	center.add_child(panel)
	var column: VBoxContainer = UIKit.vbox(18)
	panel.add_child(column)
	column.add_child(UIKit.label("The Wellspring calls", &"TitleLabel", 54, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var intro: Label = UIKit.label("Every Wanderer is drawn to one of the four springs. Your choice decides the color of the basic lands in your starter deck. Neutral cards work with any color.", &"", 23, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.custom_minimum_size = Vector2(1100, 0)
	column.add_child(intro)
	var row: HBoxContainer = UIKit.hbox(20)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(row)
	for color: Affinity.Type in OPTIONS:
		row.add_child(_make_tile(color))
	_summary = UIKit.label("Choose a spring.", &"MutedLabel", 22, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(_summary)
	var buttons: HBoxContainer = UIKit.hbox(16)
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(buttons)
	_confirm = FancyButton.make("Answer the call", &"PrimaryButton", Vector2(280, 60))
	_confirm.disabled = true
	_confirm.pressed.connect(_on_confirm)
	buttons.add_child(_confirm)
	var later: FancyButton = FancyButton.make("Not yet", &"", Vector2(200, 60))
	later.pressed.connect(func() -> void: closed.emit())
	buttons.add_child(later)
	UIKit.pop_in(panel)


func _make_tile(color: Affinity.Type) -> Control:
	var tint: Color = UIStyle.affinity_color(color)
	var tile: Button = Button.new()
	tile.custom_minimum_size = Vector2(250, 300)
	tile.focus_mode = Control.FOCUS_NONE
	tile.toggle_mode = false
	tile.add_theme_stylebox_override("normal", UIStyle.box(tint.darkened(0.7), tint.darkened(0.2), 3, 16, 8))
	tile.add_theme_stylebox_override("hover", UIStyle.box(tint.darkened(0.55), tint.lightened(0.2), 4, 16, 14))
	tile.add_theme_stylebox_override("pressed", UIStyle.box(tint.darkened(0.55), UIStyle.PARCHMENT, 4, 16, 4))
	tile.pressed.connect(func() -> void: _select(color))
	tile.mouse_entered.connect(func() -> void: Audio.sfx(&"ui_hover", -8.0))
	var inner: VBoxContainer = UIKit.vbox(6)
	inner.set_anchors_preset(Control.PRESET_FULL_RECT)
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.alignment = BoxContainer.ALIGNMENT_CENTER
	tile.add_child(inner)
	var land: CardData = Session.card_by_id(str(LAND_ICON_IDS[color]))
	var icon: TextureRect = CardIcons.glyph(CardIcons.for_card(land), tint.lightened(0.35), Vector2(120, 120))
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	inner.add_child(icon)
	inner.add_child(UIKit.label(UIStyle.affinity_name(color), &"HeadingLabel", 32, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var blurb: Label = UIKit.label(str(UIStyle.AFFINITY_BLURBS[color]), &"", 20, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	blurb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	blurb.custom_minimum_size = Vector2(210, 60)
	inner.add_child(blurb)
	_tiles[color] = tile
	return tile


func _select(color: Affinity.Type) -> void:
	selected = color
	Audio.sfx(&"ui_select")
	for key: Variant in _tiles.keys():
		var tile: Button = _tiles[key] as Button
		var tint: Color = UIStyle.affinity_color(int(key) as Affinity.Type)
		var is_selected: bool = int(key) == int(color)
		tile.add_theme_stylebox_override("normal", UIStyle.box(tint.darkened(0.45 if is_selected else 0.7), UIStyle.PARCHMENT if is_selected else tint.darkened(0.2), 5 if is_selected else 3, 16, 16 if is_selected else 8))
	_confirm.disabled = false
	_summary.text = "Starter deck: 28 neutral spells and 17 %s lands. After the Trial of the Hollow the spring teaches you five %s techniques." % [UIStyle.affinity_name(color), UIStyle.affinity_name(color)]
	_summary.remove_theme_color_override("font_color")


func _on_confirm() -> void:
	if selected == Affinity.Type.NEUTRAL:
		return
	chosen.emit(selected)
