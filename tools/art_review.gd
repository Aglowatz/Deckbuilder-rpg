class_name ArtReview
extends Control
## Developer scene for checking imported card art in every view. `--view=hand|zoom|compact|deck` shows the review sample at that
## view's real scale (hand 0.68, zoom 0.92, compact 0.56, deck builder grid 0.55); `--chunk=N` pages through it; `--list` prints it.
## The sample is every Path (colour group) x two cards, the longest names and every legendary. See docs/art/art_pipeline.md.

const SCALES: Dictionary = {"hand": 0.68, "zoom": 0.92, "compact": 0.56, "deck": 0.55}
const PER_ROW: Dictionary = {"hand": 7, "zoom": 5, "compact": 9, "deck": 9}
const ROWS: Dictionary = {"hand": 2, "zoom": 2, "compact": 3, "deck": 3}

var _view: String = "hand"
var _chunk: int = 0
var _list: bool = false


func screenshot_prepare(args: Dictionary) -> void:
	_view = str(args.get("view", "hand"))
	_chunk = int(args.get("chunk", 0))
	_list = args.has("list")


## The review sample, in a stable order.
static func sample() -> Array[CardData]:
	var cards: Array[CardData] = []
	var groups: Dictionary = {}
	var ids: Array = Session.content.cards.keys() + Session.content.multipath_cards.keys()
	ids.sort()
	for id: Variant in ids:
		var card: CardData = Session.content.card(str(id))
		if CardArt.has_art(card.id):
			var key: String = "%d-%d-%s" % [card.color, card.color2, str(card.paths_all)]
			if not groups.has(key):
				groups[key] = []
			if (groups[key] as Array).size() < 2 and (card.rarity != CardEnums.Rarity.LEGENDARY):
				(groups[key] as Array).append(card)
	for key: Variant in groups.keys():
		for card: Variant in groups[key] as Array:
			cards.append(card as CardData)
	var by_length: Array[CardData] = []
	var legendary: Array[CardData] = []
	for id: Variant in ids:
		var card: CardData = Session.content.card(str(id))
		if not CardArt.has_art(card.id):
			continue
		by_length.append(card)
		if card.rarity == CardEnums.Rarity.LEGENDARY:
			legendary.append(card)
	by_length.sort_custom(func(a: CardData, b: CardData) -> bool: return a.display_name.length() > b.display_name.length())
	for card: CardData in by_length.slice(0, 8) + legendary:
		if not cards.has(card):
			cards.append(card)
	return cards


func _ready() -> void:
	add_child(UIKit.gradient_background())
	var cards: Array[CardData] = sample()
	if _list:
		var names: Array[String] = []
		for card: CardData in cards:
			names.append("%s:%s" % [card.id, card.display_name])
		print("REVIEW SAMPLE (%d): %s" % [cards.size(), ", ".join(names)])
	var card_scale: float = float(SCALES[_view])
	var per_row: int = int(PER_ROW[_view])
	var per_page: int = per_row * int(ROWS[_view])
	var margin: MarginContainer = UIKit.margin(VBoxContainer.new(), 12)
	UIKit.full_rect(margin)
	add_child(margin)
	var column: VBoxContainer = margin.get_child(0) as VBoxContainer
	var row: HBoxContainer = null
	var start: int = _chunk * per_page
	for index: int in range(start, mini(start + per_page, cards.size())):
		if (index - start) % per_row == 0:
			row = UIKit.hbox(8)
			column.add_child(row)
		var tile: Control = CardView.wrapped(cards[index], card_scale, CardView.Mode.COMPACT if _view == "compact" else CardView.Mode.FULL)
		row.add_child(tile)
