extends Control
## Bench: the longest card names in FULL and COMPACT mode side by side, for checking they never touch the cost pips.
## bash tools/shot.sh res://tools/card_names_sheet.tscn card_names

const NAMES_TO_SHOW: int = 8


func _ready() -> void:
	var cards: Array[CardData] = []
	for entry: CardImporter.Entry in CardImporter.build_all():
		if not entry.is_token and not entry.data.is_infrastructure():
			cards.append(entry.data)
	cards.sort_custom(func(a: CardData, b: CardData) -> bool: return a.display_name.length() > b.display_name.length())
	var scale_factor: float = 0.5
	for index: int in range(mini(NAMES_TO_SHOW, cards.size())):
		var full: Control = CardView.wrapped(cards[index], scale_factor, CardView.Mode.FULL)
		full.position = Vector2(10 + index * 160, 10)
		add_child(full)
		var compact: Control = CardView.wrapped(cards[index], scale_factor, CardView.Mode.COMPACT)
		compact.position = Vector2(10 + index * 160, 250)
		add_child(compact)
