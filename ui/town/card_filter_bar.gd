class_name CardFilterBar
extends VBoxContainer
## Filter chips for card lists: affinity, card type and cost. `matches(card)` applies them.
## Overnight Oct 30-31, Part 7: rarity, and "New" (cards that joined the collection since the station was last closed) when `show_extra`.

signal changed

const COST_LABELS: Array[String] = ["Any cost", "0-1", "2", "3", "4+"]
const TYPE_LABELS: Array[String] = ["All types", "Unit", "Spell", "Trap", "Wonder", "Tool"]
const RARITY_LABELS: Array[String] = ["Any rarity", "Common", "Uncommon", "Epic", "Legendary"]

var affinity_filter: int = -1
var type_filter: int = -1
var cost_filter: int = 0
## -1 = any; else a CardEnums.Rarity.
var rarity_filter: int = -1
## 1 = only cards that are new to the collection.
var new_filter: int = 0
## The Deck Station sets it before the bar enters the tree (the dungeon deck editor keeps the three rows).
var show_extra: bool = false
var _groups: Array[Array] = [[], [], [], [], []]


func _ready() -> void:
	add_theme_constant_override("separation", 6)
	var affinities: Array[Dictionary] = [{"label": "All colors", "value": -1}]
	for type: Affinity.Type in [Affinity.Type.NEUTRAL, Affinity.Type.BEEFCAKE, Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER, Affinity.Type.NECROCRAT]:
		affinities.append({"label": UIStyle.affinity_name(type), "value": int(type), "color": UIStyle.affinity_color(type), "icon": IconArt.energy_id(type)})
	add_child(_row(0, affinities))
	var types: Array[Dictionary] = []
	for index: int in range(TYPE_LABELS.size()):
		var type_value: int = -1 if index == 0 else _card_type_for(index)
		types.append({"label": TYPE_LABELS[index], "value": type_value, "icon": "" if index == 0 else IconArt.type_id(type_value as CardEnums.CardType)})
	var costs: Array[Dictionary] = []
	for index: int in range(COST_LABELS.size()):
		costs.append({"label": COST_LABELS[index], "value": index})
	# UI + economy fixes Oct 22: the chips flow onto another line when the bar is narrow (a fixed row pushed the screen wider than 1280 px).
	var second: HFlowContainer = _row(1, types)
	second.add_child(UIKit.spacer(0, 14))
	_row(2, costs, second)
	add_child(second)
	if show_extra:
		var rarities: Array[Dictionary] = []
		for index: int in range(RARITY_LABELS.size()):
			rarities.append({"label": RARITY_LABELS[index], "value": index - 1})
		var third: HFlowContainer = _row(3, rarities)
		third.add_child(UIKit.spacer(0, 14))
		_row(4, [{"label": "Any", "value": 0}, {"label": "New", "value": 1, "color": UIStyle.GOLD}] as Array[Dictionary], third)
		add_child(third)


func _card_type_for(index: int) -> int:
	match index:
		1:
			return int(CardEnums.CardType.UNIT)
		2:
			return int(CardEnums.CardType.SPELL)
		3:
			return int(CardEnums.CardType.TRAP)
		5:
			return int(CardEnums.CardType.TOOL)
	return int(CardEnums.CardType.WONDER)


func _row(group: int, options: Array[Dictionary], into: HFlowContainer = null) -> HFlowContainer:
	var row: HFlowContainer = into
	if row == null:
		row = HFlowContainer.new()
		row.add_theme_constant_override("h_separation", 6)
		row.add_theme_constant_override("v_separation", 6)
	for option: Dictionary in options:
		var chip: Button = Button.new()
		chip.text = str(option["label"])
		var chip_icon: String = str(option.get("icon", ""))
		if chip_icon != "" and IconArt.has(chip_icon):
			chip.icon = IconArt.texture(chip_icon, 24.0)
			chip.add_theme_constant_override("icon_max_width", 24)
			chip.add_theme_constant_override("h_separation", 6)
			for icon_color: String in ["icon_normal_color", "icon_hover_color", "icon_pressed_color", "icon_hover_pressed_color", "icon_focus_color"]:
				chip.add_theme_color_override(icon_color, Color.WHITE)
		chip.toggle_mode = true
		chip.focus_mode = Control.FOCUS_NONE
		var tint: Color = option.get("color", UIStyle.GOLD) as Color
		chip.add_theme_font_size_override("font_size", 18)
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
		3:
			return value == rarity_filter
		4:
			return value == new_filter
	return value == cost_filter


func _select(group: int, value: int) -> void:
	match group:
		0:
			affinity_filter = value
		1:
			type_filter = value
		2:
			cost_filter = value
		3:
			rarity_filter = value
		4:
			new_filter = value
	for entry: Dictionary in _groups[group]:
		(entry["button"] as Button).button_pressed = int(entry["value"]) == value
	Audio.sfx(&"ui_tick")
	changed.emit()


func matches(card: CardData) -> bool:
	if affinity_filter != -1 and not card.is_on_path(affinity_filter as Affinity.Type) and int(card.color) != affinity_filter:
		return false
	if type_filter != -1 and int(card.type) != type_filter:
		return false
	if rarity_filter != -1 and (card.is_basic or int(card.rarity) != rarity_filter):
		return false
	if new_filter == 1 and not Session.new_cards.has(card.id):
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
