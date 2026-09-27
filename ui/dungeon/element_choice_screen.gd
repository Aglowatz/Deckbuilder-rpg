class_name ElementChoiceScreen
extends Control
## Shown in the starting area, right before the tutorial dungeon (Part C): pick the element the
## Wanderer carries into the Trial of the Hollow. Each tile shows the element's identity,
## playstyle and a few representative cards. The choice becomes `PlayerProfile.primary_affinity`
## and decides the starter deck's basic land color (`CampaignStart.starter_deck`); the neutral
## cards in the starter are the same regardless of which element is picked.

signal chosen(color: Affinity.Type)

var selected: Affinity.Type = Affinity.Type.NEUTRAL
var _tiles: Dictionary = {}
var _confirm: FancyButton
var _offers: Array[ElementChoice.Offer] = []


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
	var column: VBoxContainer = UIKit.vbox(16)
	panel.add_child(column)
	column.add_child(UIKit.label("Choose your element", &"TitleLabel", 50, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var intro: Label = UIKit.label("Before the Hollow, one of the four Wellsprings will answer you. It shapes the cards you draw to it as you explore - your kit otherwise starts the same either way.", &"", 22, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.custom_minimum_size = Vector2(1200, 0)
	column.add_child(intro)
	var row: HBoxContainer = UIKit.hbox(18)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(row)
	_offers = ElementChoice.offers(Session.content)
	for offer: ElementChoice.Offer in _offers:
		row.add_child(_make_tile(offer))
	var buttons: HBoxContainer = UIKit.hbox(16)
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(buttons)
	_confirm = FancyButton.make("Begin", &"PrimaryButton", Vector2(280, 60))
	_confirm.disabled = true
	_confirm.pressed.connect(_on_confirm)
	buttons.add_child(_confirm)
	UIKit.pop_in(panel)


func _make_tile(offer: ElementChoice.Offer) -> Control:
	var tint: Color = UIStyle.affinity_color(offer.affinity)
	var tile: Button = Button.new()
	tile.custom_minimum_size = Vector2(300, 440)
	tile.focus_mode = Control.FOCUS_NONE
	tile.add_theme_stylebox_override("normal", UIStyle.box(tint.darkened(0.7), tint.darkened(0.2), 3, 16, 8))
	tile.add_theme_stylebox_override("hover", UIStyle.box(tint.darkened(0.55), tint.lightened(0.2), 4, 16, 14))
	tile.add_theme_stylebox_override("pressed", UIStyle.box(tint.darkened(0.55), UIStyle.PARCHMENT, 4, 16, 4))
	tile.pressed.connect(func() -> void: _select(offer.affinity))
	tile.mouse_entered.connect(func() -> void: Audio.sfx(&"ui_hover", -8.0))
	var inner: VBoxContainer = UIKit.vbox(8)
	inner.set_anchors_preset(Control.PRESET_FULL_RECT)
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.alignment = BoxContainer.ALIGNMENT_CENTER
	inner.add_theme_constant_override("margin_top", 14)
	tile.add_child(inner)
	inner.add_child(UIKit.label(UIStyle.affinity_name(offer.affinity), &"HeadingLabel", 28, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var identity: Label = UIKit.label(offer.identity, &"", 17, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	identity.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	identity.custom_minimum_size = Vector2(260, 70)
	inner.add_child(identity)
	var cards_row: HBoxContainer = UIKit.hbox(6)
	cards_row.alignment = BoxContainer.ALIGNMENT_CENTER
	cards_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.add_child(cards_row)
	for card: CardData in offer.sample_cards:
		cards_row.add_child(CardView.wrapped(card, 0.28))
	var playstyle: Label = UIKit.label(offer.playstyle, &"MutedLabel", 16, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	playstyle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	playstyle.custom_minimum_size = Vector2(260, 60)
	inner.add_child(playstyle)
	_tiles[offer.affinity] = tile
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
	_confirm.text = "Begin as %s" % UIStyle.affinity_name(color)


func _on_confirm() -> void:
	if selected == Affinity.Type.NEUTRAL:
		return
	chosen.emit(selected)
