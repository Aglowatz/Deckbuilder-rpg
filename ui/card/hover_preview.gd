class_name HoverPreview
extends Control
## A floating zoomed card (with keyword help) that follows the hovered card in menus.

var _card: CardView
var _help: PanelContainer
var _help_box: VBoxContainer


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 300
	visible = false
	_help = UIKit.panel(&"DarkPanel")
	_help.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_help)
	_help_box = UIKit.vbox(4)
	_help.add_child(_help_box)


## Wires `target` (any Control) so hovering it shows `card` zoomed near it.
func attach(target: Control, card: CardData) -> void:
	target.mouse_entered.connect(func() -> void: show_for(target, card))
	target.mouse_exited.connect(hide_preview)


func show_for(target: Control, card: CardData) -> void:
	if _card != null:
		_card.queue_free()
	_card = CardView.create(card, CardView.Mode.FULL)
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.scale = Vector2(0.92, 0.92)
	add_child(_card)
	for child: Node in _help_box.get_children():
		child.queue_free()
	var entries: Array[Array] = KeywordInfo.entries_for(card)
	_help.visible = not entries.is_empty()
	for entry: Array in entries:
		var title: Label = UIKit.label(str(entry[0]), &"", 21, UIStyle.GOLD)
		title.add_theme_font_override("font", UIStyle.font_bold())
		_help_box.add_child(title)
		var body: Label = UIKit.label(str(entry[1]), &"", 18, UIStyle.PARCHMENT)
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body.custom_minimum_size = Vector2(260, 0)
		_help_box.add_child(body)
	_help.size = Vector2(280, 10)
	var card_size: Vector2 = CardView.SIZE * 0.92
	var rect: Rect2 = target.get_global_rect()
	var x: float = rect.end.x + 16.0
	if x + card_size.x + 300.0 > 1920.0:
		x = rect.position.x - card_size.x - 16.0 - 300.0
	var y: float = clampf(rect.position.y - 60.0, 10.0, 1070.0 - card_size.y)
	# The card view scales around its centre, so offset by the unscaled origin.
	_card.position = Vector2(x, y) - (CardView.SIZE - card_size) * 0.5
	_help.position = Vector2(x + card_size.x + 12.0, y)
	visible = true


func hide_preview() -> void:
	visible = false
