class_name CardFilterBar
extends VBoxContainer
## Filter chips for card lists: affinity, card type and cost. `matches(card)` applies them.
## Overnight Oct 30-31, Part 7: rarity, and "New" (cards that joined the collection since the station was last closed) when `show_extra`.

signal changed
## Fable Nov 21 (Part 5.1): the player tried to switch on one Path more than the deck may walk (`max_paths`); the screen shows a pop-up.
signal path_refused(limit: int)

const COST_LABELS: Array[String] = ["Any cost", "0-1", "2", "3", "4+"]
## Fable Nov 21 castle (Part 1.7): Infrastructure is a type of its own in the selector (index 6).
const TYPE_LABELS: Array[String] = ["All types", "Unit", "Spell", "Trap", "Wonder", "Tool", "Infrastructure"]
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
## Fable Nov 21 (Part 5.1, the Deck Station): the Path row is a set of TOGGLES instead of one choice. Up to `max_paths` Paths may be on
## at once (as many as the deck may walk). None on = every card. With one or more on, only the cards a deck of exactly those Paths
## could hold are shown: every Path of the card must be switched on. Pathless cards show only while the Pathless toggle is on.
var multi_path: bool = false
var max_paths: int = 4
var selected_paths: Array[int] = []
var pathless_selected: bool = false
## Fable Nov 21 (Part 5.2): a search box (names, card text, keywords such as Reinstate, Swat, Hustle, Toxic; also the type and the Path).
var show_search: bool = false
var search_text: String = ""
var search_box: LineEdit
## The search box's own colours (Fable Nov 21 review): a dark walnut field, a gold hairline, a hint that reads at 5:1 or better.
const SEARCH_FILL: Color = Color(0.11, 0.075, 0.05, 0.94)
const SEARCH_BORDER: Color = Color(0.83, 0.66, 0.32, 0.7)
const SEARCH_HINT: Color = Color(0.82, 0.76, 0.64)
var _groups: Array[Array] = [[], [], [], [], []]


func _ready() -> void:
	add_theme_constant_override("separation", 6)
	if show_search:
		search_box = LineEdit.new()
		search_box.name = "SearchBox"
		search_box.placeholder_text = "Search: a name, card text or a keyword (Hustle, Swat, Toxic, Reinstate...)"
		search_box.clear_button_enabled = true
		search_box.custom_minimum_size = Vector2(560, 40)
		search_box.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		search_box.add_theme_font_size_override("font_size", 20)
		# Fable Nov 21 review (polish): a field you can see and a hint you can read - the box was a faint grey veil on the wood and its
		# hint a darker grey on top of it (contrast about 2:1); now dark walnut with a gold hairline, the hint in parchment
		var field: StyleBoxFlat = UIStyle.box(SEARCH_FILL, SEARCH_BORDER, 1, 8)
		field.content_margin_left = 12.0
		field.content_margin_right = 8.0
		search_box.add_theme_stylebox_override("normal", field)
		var lit: StyleBoxFlat = field.duplicate() as StyleBoxFlat
		lit.border_color = UIStyle.GOLD
		lit.set_border_width_all(2)
		search_box.add_theme_stylebox_override("focus", lit)
		search_box.add_theme_color_override("font_placeholder_color", SEARCH_HINT)
		search_box.add_theme_color_override("font_color", UIStyle.PARCHMENT)
		search_box.focus_mode = Control.FOCUS_CLICK  # typed with a keyboard; the controller's cursor skips it
		search_box.text_changed.connect(func(typed: String) -> void: set_search(typed))
		add_child(search_box)
	var affinities: Array[Dictionary] = [{"label": "All Paths", "value": -1}]
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
		6:
			return int(CardEnums.CardType.INFRASTRUCTURE)
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


## The search words as typed; the list updates at once.
func set_search(typed: String) -> void:
	var cleaned: String = typed.strip_edges().to_lower()
	if cleaned == search_text:
		return
	search_text = cleaned
	if search_box != null and search_box.text.strip_edges().to_lower() != cleaned:
		search_box.text = typed
	changed.emit()


## Everything of a card the search looks through, lower case: its name, its text, its keywords, its type, its rarity and its Paths.
static func search_haystack(card: CardData) -> String:
	var parts: PackedStringArray = [card.display_name, card.rules_text, str(CardEnums.CardType.keys()[int(card.type)]).replace("_", " ")]
	for keyword: CardEnums.Keyword in card.keywords:
		parts.append(str(CardEnums.Keyword.keys()[int(keyword)]).replace("_", " "))
		parts.append(str(CardEnums.Keyword.keys()[int(keyword)]).replace("_", "-"))
	for path: Affinity.Type in card.paths():
		parts.append(Affinity.display_name(path))
	if card.paths().is_empty():
		parts.append("Pathless")
	if card.is_infrastructure():
		parts.append("Infrastructure")
	return " ".join(parts).to_lower()


## Every typed word must be found (so "toxic unit" finds Toxic units).
func matches_search(card: CardData) -> bool:
	if search_text.is_empty():
		return true
	var haystack: String = search_haystack(card)
	for word: String in search_text.split(" ", false):
		if not haystack.contains(word):
			return false
	return true


## Fable Nov 21 (Part 5.1): the toggle rule. No toggle on: every card. Otherwise a Pathless card needs the Pathless toggle, and a card
## with Paths needs every one of its Paths switched on.
func matches_paths(card: CardData) -> bool:
	if selected_paths.is_empty() and not pathless_selected:
		return true
	var paths: Array[Affinity.Type] = card.paths()
	if paths.is_empty():
		return pathless_selected
	if selected_paths.is_empty():
		return false
	for path: Affinity.Type in paths:
		if not selected_paths.has(int(path)):
			return false
	return true


## Switches a Path toggle (or Pathless: `Affinity.Type.NEUTRAL`; -1 clears them all). False when the Path was refused (over the limit).
func toggle_path(value: int) -> bool:
	if value == -1:
		selected_paths.clear()
		pathless_selected = false
	elif value == int(Affinity.Type.NEUTRAL):
		pathless_selected = not pathless_selected
	elif selected_paths.has(value):
		selected_paths.erase(value)
	elif selected_paths.size() >= max_paths:
		_sync_path_chips()
		Audio.sfx(&"ui_error", -4.0)
		path_refused.emit(max_paths)
		return false
	else:
		selected_paths.append(value)
	_sync_path_chips()
	Audio.sfx(&"ui_tick")
	changed.emit()
	return true


func _sync_path_chips() -> void:
	for entry: Dictionary in _groups[0]:
		(entry["button"] as Button).set_pressed_no_signal(_is_active(0, int(entry["value"])))


func _is_active(group: int, value: int) -> bool:
	match group:
		0:
			if multi_path:
				if value == -1:
					return selected_paths.is_empty() and not pathless_selected
				return pathless_selected if value == int(Affinity.Type.NEUTRAL) else selected_paths.has(value)
			return value == affinity_filter
		1:
			return value == type_filter
		3:
			return value == rarity_filter
		4:
			return value == new_filter
	return value == cost_filter


func _select(group: int, value: int) -> void:
	if group == 0 and multi_path:
		toggle_path(value)
		return
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
	if multi_path:
		if not matches_paths(card):
			return false
	elif affinity_filter != -1 and not card.is_on_path(affinity_filter as Affinity.Type) and int(card.color) != affinity_filter:
		return false
	if not matches_search(card):
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
