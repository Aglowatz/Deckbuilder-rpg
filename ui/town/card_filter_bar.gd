class_name CardFilterBar
extends VBoxContainer
## Filter chips for card lists: affinity, card type and cost. `matches(card)` applies them.

signal changed

const COST_LABELS: Array[String] = ["Any cost", "0-1", "2", "3", "4+"]
const TYPE_LABELS: Array[String] = ["All types", "Creature", "Spell", "Trap", "Artifact"]

var affinity_filter: int = -1
var type_filter: int = -1
var cost_filter: int = 0
var _groups: Array[Array] = [[], [], []]


func _ready() -> void:
	add_theme_constant_override("separation", 6)
	var affinities: Array[Dictionary] = [{"label": "All colors", "value": -1}]
	for type: Affinity.Type in [Affinity.Type.NEUTRAL, Affinity.Type.A, Affinity.Type.B, Affinity.Type.C, Affinity.Type.D]:
		affinities.append({"label": UIStyle.affinity_name(type), "value": int(type), "color": UIStyle.affinity_color(type)})
	add_child(_row(0, affinities))
	var types: Array[Dictionary] = []
	for index: int in range(TYPE_LABELS.size()):
		types.append({"label": TYPE_LABELS[index], "value": -1 if index == 0 else _card_type_for(index)})
	var costs: Array[Dictionary] = []
	for index: int in range(COST_LABELS.size()):
		costs.append({"label": COST_LABELS[index], "value": index})
	var second: HBoxContainer = UIKit.hbox(24)
	second.add_child(_row(1, types))
	second.add_child(_row(2, costs))
	add_child(second)


func _card_type_for(index: int) -> int:
	match index:
		1:
			return int(CardEnums.CardType.CREATURE)
		2:
			return int(CardEnums.CardType.SPELL)
		3:
			return int(CardEnums.CardType.TRAP)
	return int(CardEnums.CardType.ARTIFACT)


func _row(group: int, options: Array[Dictionary]) -> HBoxContainer:
	var row: HBoxContainer = UIKit.hbox(6)
	for option: Dictionary in options:
		var chip: Button = Button.new()
		chip.text = str(option["label"])
		chip.toggle_mode = true
		chip.focus_mode = Control.FOCUS_NONE
		var tint: Color = option.get("color", UIStyle.GOLD) as Color
		chip.add_theme_font_size_override("font_size", 19)
		chip.add_theme_stylebox_override("normal", _chip_style(Color(1, 1, 1, 0.05), Color(1, 1, 1, 0.12)))
		chip.add_theme_stylebox_override("hover", _chip_style(Color(1, 1, 1, 0.12), tint))
		chip.add_theme_stylebox_override("pressed", _chip_style(tint.darkened(0.15), tint.lightened(0.3)))
		chip.add_theme_stylebox_override("hover_pressed", _chip_style(tint.darkened(0.05), tint.lightened(0.4)))
		chip.add_theme_color_override("font_pressed_color", UIStyle.INK if tint.get_luminance() > 0.35 else UIStyle.PARCHMENT)
		chip.add_theme_color_override("font_hover_pressed_color", UIStyle.INK if tint.get_luminance() > 0.35 else UIStyle.PARCHMENT)
		chip.button_pressed = _is_active(group, int(option["value"]))
		var value: int = int(option["value"])
		chip.pressed.connect(func() -> void: _select(group, value))
		chip.mouse_entered.connect(func() -> void: Audio.sfx(&"ui_hover", -14.0))
		row.add_child(chip)
		_groups[group].append({"button": chip, "value": value})
	return row


func _chip_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = UIStyle.box(fill, border, 2, 16)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	return style


func _is_active(group: int, value: int) -> bool:
	match group:
		0:
			return value == affinity_filter
		1:
			return value == type_filter
	return value == cost_filter


func _select(group: int, value: int) -> void:
	match group:
		0:
			affinity_filter = value
		1:
			type_filter = value
		2:
			cost_filter = value
	for entry: Dictionary in _groups[group]:
		(entry["button"] as Button).button_pressed = int(entry["value"]) == value
	Audio.sfx(&"ui_tick")
	changed.emit()


func matches(card: CardData) -> bool:
	if affinity_filter != -1 and not card.is_on_path(affinity_filter as Affinity.Type) and int(card.color) != affinity_filter:
		return false
	if type_filter != -1 and int(card.type) != type_filter:
		return false
	var cost: int = card.energy_value()
	match cost_filter:
		1:
			return cost <= 1
		2:
			return cost == 2
		3:
			return cost == 3
		4:
			return cost >= 4
	return true
