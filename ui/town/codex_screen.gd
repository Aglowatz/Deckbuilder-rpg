class_name CodexScreen
extends OverlayScreen
## The card Codex: every card in the game, in one grid. Cards the player owns, has bought, or has
## faced in battle (`Session.has_seen`) show normally; everything else shows as a silhouette
## (a face-down card back) so the collection reads as "things left to discover".

const COLUMNS: int = 8
const CARD_SCALE: float = 0.62

var _preview: HoverPreview
var _seen_label: Label


func _ready() -> void:
	screen_title = "Codex"
	close_text = "Close"
	background_id = "UI-BG-DECKBUILDER"
	super._ready()


func _build() -> void:
	_seen_label = UIKit.label("", &"", 26, UIStyle.GOLD)
	header_extra.add_child(_seen_label)
	_preview = HoverPreview.new()
	add_child(_preview)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var grid: GridContainer = GridContainer.new()
	grid.columns = COLUMNS
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 14)
	scroll.add_child(grid)
	var ids: Array = Session.content.cards.keys()
	ids.sort()
	var seen_count: int = 0
	for id: Variant in ids:
		var card: CardData = Session.content.card(str(id))
		var seen: bool = Session.has_seen(card.id)
		if seen:
			seen_count += 1
		grid.add_child(_make_tile(card, seen))
	_seen_label.text = "Discovered %d / %d" % [seen_count, ids.size()]


func _make_tile(card: CardData, seen: bool) -> Control:
	var holder: Control = Control.new()
	holder.custom_minimum_size = CardView.SIZE * CARD_SCALE
	var view: CardView = CardView.create(card, CardView.Mode.FULL if seen else CardView.Mode.BACK)
	holder.add_child(view)
	CardView.fit(view, CARD_SCALE)
	if seen:
		view.hovered.connect(func(_v: CardView) -> void:
			_preview.show_for(holder, card)
			Audio.sfx(&"card_hover", -14.0))
		view.unhovered.connect(func(_v: CardView) -> void: _preview.hide_preview())
	else:
		view.modulate = Color(0.5, 0.5, 0.58)
	return holder
