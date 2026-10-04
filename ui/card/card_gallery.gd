class_name CardGallery
extends Control
## Developer scene: every card style side by side (used for visual review of card frames).

var _page: int = 0
var _multipath: bool = false


func screenshot_prepare(args: Dictionary) -> void:
	_page = int(args.get("page", 0))
	_multipath = args.has("multipath")


func _ready() -> void:
	var content: ContentSet = Session.content
	add_child(UIKit.gradient_background())
	var ids: Array = content.multipath_cards.keys() if _multipath else content.cards.keys()
	ids.sort()
	var infrastructure: Array = content.infrastructure.values()
	var margin: MarginContainer = UIKit.margin(VBoxContainer.new(), 20)
	UIKit.full_rect(margin)
	add_child(margin)
	var column: VBoxContainer = margin.get_child(0) as VBoxContainer
	var row: HBoxContainer = UIKit.hbox(14)
	column.add_child(row)
	if _page < 0:
		for index: int in range(0, 3):
			row.add_child(CardView.wrapped(content.card(str(ids[index + 3])), 1.0))
		return
	var start: int = _page * 7
	for index: int in range(start, mini(start + 7, ids.size())):
		row.add_child(CardView.wrapped(content.card(str(ids[index])), 0.62))
	var compact: HBoxContainer = UIKit.hbox(12)
	column.add_child(compact)
	for index: int in range(start, mini(start + 6, ids.size())):
		compact.add_child(CardView.wrapped(content.card(str(ids[index])), 0.5, CardView.Mode.COMPACT))
	var back: CardData = null
	compact.add_child(CardView.wrapped(back, 0.5, CardView.Mode.BACK))
	for infra: Variant in infrastructure.slice(0, 2):
		compact.add_child(CardView.wrapped(infra as CardData, 0.5))
