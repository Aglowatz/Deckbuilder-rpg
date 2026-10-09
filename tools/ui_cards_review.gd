extends Control
## UI art kit review sheet for cards: one unit of every Path, a multi-Path card (two and four Paths), a token, an Infrastructure and a card with a very long name, as a hand row
## (FULL), a battlefield row (COMPACT) and one zoomed card. `bash tools/shot.sh res://scenes/dev/ui_cards_review.tscn ui_cards [--size=1280x720]`


func _ready() -> void:
	var content: ContentSet = Session.content
	add_child(UIKit.gradient_background())
	var picks: Array[CardData] = []
	for path: Affinity.Type in [Affinity.Type.BEEFCAKE, Affinity.Type.NECROCRAT, Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER, Affinity.Type.NEUTRAL]:
		picks.append(_first(content, func(c: CardData) -> bool: return c.is_unit() and c.color == path and not c.is_multipath() and not c.is_token))
	var multi: Array[CardData] = []
	for id: Variant in content.multipath_cards.keys():
		multi.append(content.multipath_cards[id] as CardData)
	for card: CardData in content.cards.values():
		if card.is_multipath():
			multi.append(card)
	multi.sort_custom(func(a: CardData, b: CardData) -> bool: return a.paths().size() < b.paths().size())
	picks.append(multi[0])
	picks.append(multi[multi.size() - 1])
	var token: CardData = null
	for entry: Variant in content.tokens.values():
		var candidate: CardData = entry as CardData
		if candidate != null and candidate.is_unit():
			token = candidate
			break
	if token != null:
		picks.append(token)
	picks.append(content.infrastructure.values()[1] as CardData)
	var longest: CardData = picks[0]
	for card: CardData in content.cards.values():
		if card.display_name.length() > longest.display_name.length() and card.is_unit():
			longest = card
	picks.append(longest)
	var margin: MarginContainer = UIKit.margin(VBoxContainer.new(), 14)
	UIKit.full_rect(margin)
	add_child(margin)
	var column: VBoxContainer = margin.get_child(0) as VBoxContainer
	column.add_theme_constant_override("separation", 6)
	var hand: HBoxContainer = UIKit.hbox(6)
	column.add_child(hand)
	for card: CardData in picks:
		hand.add_child(CardView.wrapped(card, 0.5))
	var field: HBoxContainer = UIKit.hbox(6)
	column.add_child(field)
	for card: CardData in picks:
		field.add_child(CardView.wrapped(card, 0.5, CardView.Mode.COMPACT))
	var zoom: Control = CardView.wrapped(picks[5], 1.0)
	zoom.position = Vector2(1280, 20)
	add_child(zoom)


func _first(content: ContentSet, test: Callable) -> CardData:
	var ids: Array = content.cards.keys()
	ids.sort()
	for id: Variant in ids:
		var card: CardData = content.cards[id] as CardData
		if bool(test.call(card)):
			return card
	return content.cards[ids[0]] as CardData
