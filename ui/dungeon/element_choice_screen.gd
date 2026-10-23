class_name ElementChoiceScreen
extends Control
## Shown in the starting area, right before the tutorial dungeon (Part C): pick the element the
## Wanderer carries into the Forgotten Cave. The choice becomes `PlayerProfile.primary_affinity`
## and decides the starter deck's basic infrastructure color (`CampaignStart.starter_deck`); the neutral
## cards in the starter are the same regardless of which element is picked.
##
## Overnight Oct 22, Part 3: each tile reads at a glance - the Path's name, its icon, three of its cards and a one-line game plan
## (`ElementChoice.Offer.plan`). The full identity paragraph and playstyle show in the detail strip under the tiles while a tile is
## hovered or focused; "More" keeps the strip open for the focused or selected tile (keyboard / controller). The screen reads in
## about 15 seconds (it was 279 words, ~80 s).

signal chosen(color: Affinity.Type)

var selected: Affinity.Type = Affinity.Type.NEUTRAL
var _tiles: Dictionary = {}
var _confirm: FancyButton
var _more: FancyButton
var _offers: Array[ElementChoice.Offer] = []
var _detail: PanelContainer
var _detail_title: Label
var _detail_identity: Label
var _detail_playstyle: Label
## The tile under the mouse or with focus (NEUTRAL = none).
var _shown: Affinity.Type = Affinity.Type.NEUTRAL
var _more_open: bool = false


func _ready() -> void:
	UIKit.full_rect(self)
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.02, 0.02, 0.06, 0.88)
	UIKit.full_rect(shade)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	add_child(UIKit.gradient_background())
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	add_child(center)
	var panel: PanelContainer = UIKit.panel()
	center.add_child(panel)
	var column: VBoxContainer = UIKit.vbox(14)
	panel.add_child(column)
	column.add_child(UIKit.label("Choose your Path", &"TitleLabel", 50, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var intro: Label = UIKit.label("Pick the Path that feels like you. It shapes the deck you carry into the cave.", &"", 22, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.custom_minimum_size = Vector2(1180, 0)
	column.add_child(intro)
	var row: HBoxContainer = UIKit.hbox(18)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(row)
	_offers = ElementChoice.offers(Session.content)
	for offer: ElementChoice.Offer in _offers:
		row.add_child(_make_tile(offer))
	_detail = _make_detail()
	column.add_child(_detail)
	var buttons: HBoxContainer = UIKit.hbox(16)
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(buttons)
	_more = FancyButton.make("More", &"", Vector2(170, 60))
	_more.tooltip_text = "Show the whole description of the highlighted Path"
	_more.pressed.connect(_toggle_more)
	buttons.add_child(_more)
	_confirm = FancyButton.make("Begin", &"PrimaryButton", Vector2(280, 60))
	_confirm.disabled = true
	_confirm.pressed.connect(_on_confirm)
	buttons.add_child(_confirm)
	_link_focus()
	_refresh_detail()
	UIKit.pop_in(panel)


func _make_tile(offer: ElementChoice.Offer) -> Control:
	var tint: Color = UIStyle.affinity_color(offer.affinity)
	var tile: Button = Button.new()
	tile.custom_minimum_size = Vector2(290, 400)
	tile.focus_mode = Control.FOCUS_ALL
	UiSkin.choice_tile(tile, tint)
	tile.pressed.connect(func() -> void: _select(offer.affinity))
	tile.mouse_entered.connect(func() -> void:
		Audio.sfx(&"ui_hover", -8.0)
		_show(offer.affinity))
	tile.mouse_exited.connect(func() -> void: _show(Affinity.Type.NEUTRAL))
	tile.focus_entered.connect(func() -> void: _show(offer.affinity))
	tile.focus_exited.connect(func() -> void: _show(Affinity.Type.NEUTRAL))
	var inner: VBoxContainer = UIKit.vbox(10)
	inner.set_anchors_preset(Control.PRESET_FULL_RECT)
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.alignment = BoxContainer.ALIGNMENT_CENTER
	tile.add_child(inner)
	inner.add_child(UIKit.label(UIStyle.affinity_name(offer.affinity), &"HeadingLabel", 30, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var symbol: TextureRect = IconArt.rect(IconArt.energy_id(offer.affinity), 72.0)
	if symbol != null:
		symbol.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		symbol.mouse_filter = Control.MOUSE_FILTER_IGNORE
		inner.add_child(symbol)
	var cards_row: HBoxContainer = UIKit.hbox(6)
	cards_row.alignment = BoxContainer.ALIGNMENT_CENTER
	cards_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.add_child(cards_row)
	for card: CardData in offer.sample_cards:
		cards_row.add_child(CardView.wrapped(card, 0.28))
	var plan: Label = UIKit.label(offer.plan, &"", 19, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	plan.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	plan.custom_minimum_size = Vector2(250, 72)
	plan.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.add_child(plan)
	_tiles[offer.affinity] = tile
	return tile


## The strip under the tiles: the hovered / focused Path's identity and playstyle (a hint line when nothing is highlighted).
func _make_detail() -> PanelContainer:
	var strip: PanelContainer = UIKit.panel()
	strip.custom_minimum_size = Vector2(1220, 128)
	var box: VBoxContainer = UIKit.vbox(4)
	strip.add_child(box)
	_detail_title = UIKit.label("", &"HeadingLabel", 22, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(_detail_title)
	_detail_identity = UIKit.label("", &"", 18, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	_detail_identity.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_identity.custom_minimum_size = Vector2(1180, 0)
	box.add_child(_detail_identity)
	_detail_playstyle = UIKit.label("", &"MutedLabel", 17, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	_detail_playstyle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_playstyle.custom_minimum_size = Vector2(1180, 0)
	box.add_child(_detail_playstyle)
	return strip


## Left / right walk the tiles, down reaches the buttons (keyboard and controller).
func _link_focus() -> void:
	var order: Array[Button] = []
	for offer: ElementChoice.Offer in _offers:
		order.append(_tiles[offer.affinity] as Button)
	for index: int in range(order.size()):
		var tile: Button = order[index]
		tile.focus_neighbor_left = tile.get_path_to(order[(index - 1 + order.size()) % order.size()])
		tile.focus_neighbor_right = tile.get_path_to(order[(index + 1) % order.size()])
		tile.focus_neighbor_bottom = tile.get_path_to(_more)
	if not order.is_empty():
		_more.focus_neighbor_top = _more.get_path_to(order[0])
		_confirm.focus_neighbor_top = _confirm.get_path_to(order[0])


func _show(color: Affinity.Type) -> void:
	_shown = color
	_refresh_detail()


func _toggle_more() -> void:
	_more_open = not _more_open
	_more.text = "Less" if _more_open else "More"
	_refresh_detail()


## Which Path the strip describes: the highlighted tile; with More open and nothing highlighted, the selected one (or the first).
func _detail_path() -> Affinity.Type:
	if _shown != Affinity.Type.NEUTRAL:
		return _shown
	if _more_open:
		if selected != Affinity.Type.NEUTRAL:
			return selected
		if not _offers.is_empty():
			return _offers[0].affinity
	return Affinity.Type.NEUTRAL


func _refresh_detail() -> void:
	if _detail == null:
		return
	var path: Affinity.Type = _detail_path()
	var offer: ElementChoice.Offer = null
	for candidate: ElementChoice.Offer in _offers:
		if candidate.affinity == path:
			offer = candidate
	if offer == null:
		_detail_title.text = ""
		_detail_identity.text = "Point at a Path (or press More) to read how it plays. You can mix in other Paths later."
		_detail_playstyle.text = ""
		return
	_detail_title.text = UIStyle.affinity_name(offer.affinity)
	_detail_title.add_theme_color_override("font_color", UIStyle.affinity_color(offer.affinity).lightened(0.25))
	_detail_identity.text = offer.identity
	_detail_playstyle.text = offer.playstyle


func _select(color: Affinity.Type) -> void:
	selected = color
	Audio.sfx(&"ui_select")
	for key: Variant in _tiles.keys():
		var tile: Button = _tiles[key] as Button
		var tint: Color = UIStyle.affinity_color(int(key) as Affinity.Type)
		var is_selected: bool = int(key) == int(color)
		UiSkin.choice_tile(tile, tint, is_selected)
	_confirm.disabled = false
	_confirm.text = "Begin as %s" % UIStyle.affinity_name(color)
	_refresh_detail()


func _on_confirm() -> void:
	if selected == Affinity.Type.NEUTRAL:
		return
	chosen.emit(selected)
