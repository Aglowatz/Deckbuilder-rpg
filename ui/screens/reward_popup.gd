class_name RewardPopup
extends Control
## The reward box: what a hidden chest held (gold, cards with their art, items, equipment, packs, cosmetics) or what a finished quest paid and
## opened up. Drawn in the shared `PopupFrame` look, like the level-up box. The player clicks (or presses Enter / Space / E) to continue; the
## owner (a world scene) keeps the hero still while it is open and listens to `finished`.

signal finished

const CARD_SCALE: float = 0.46
const TILE_WIDTH: float = 190.0

var summary: RewardSummary
var frame: PopupFrame


static func make(reward: RewardSummary) -> RewardPopup:
	var popup: RewardPopup = RewardPopup.new()
	popup.summary = reward
	popup._build()
	return popup


func _build() -> void:
	name = "RewardPopup"
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var is_quest: bool = summary.kind == RewardSummary.Kind.QUEST
	frame = PopupFrame.make("QUEST COMPLETE" if is_quest else "CHEST OPENED", "level_badge" if is_quest else "gems", UIStyle.GOLD if is_quest else Color("f2c14e"))
	frame.set_heading(summary.title, summary.subtitle)
	add_child(frame)
	_fill_body()
	frame.confirmed.connect(_on_confirmed)
	Audio.sfx(&"level_up" if is_quest else &"chest_open", -4.0)


func _fill_body() -> void:
	var body: VBoxContainer = frame.body
	if summary.is_empty() and summary.unlocks.is_empty():
		body.add_child(UIKit.label("An empty chest. Somebody got here first." if summary.kind == RewardSummary.Kind.CHEST else "No reward this time. The thanks are real.", &"MutedLabel", 22, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
		return
	if not summary.is_empty():
		body.add_child(UIKit.label("REWARDS", &"MutedLabel", 18, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	# Currency row: gold and XP as big counters.
	var currency: HBoxContainer = UIKit.hbox(46)
	currency.alignment = BoxContainer.ALIGNMENT_CENTER
	if summary.gold > 0:
		currency.add_child(_counter("coins", "+%d gold" % summary.gold, UIStyle.GOLD))
	if summary.xp > 0:
		currency.add_child(_counter("level_badge", "+%d XP" % summary.xp, UIStyle.GOOD))
	if currency.get_child_count() > 0:
		body.add_child(currency)
	# Things row: cards with their art, then items, equipment, packs, cosmetics.
	var things: HFlowContainer = HFlowContainer.new()
	things.alignment = FlowContainer.ALIGNMENT_CENTER
	things.add_theme_constant_override("h_separation", 16)
	things.add_theme_constant_override("v_separation", 12)
	things.custom_minimum_size = Vector2(PopupFrame.PANEL_WIDTH - 80.0, 0)
	for card: CardData in summary.cards:
		things.add_child(_card_tile(card))
	for item: ItemData in summary.items:
		things.add_child(_icon_tile(CardIcons.for_item(item), item.display_name, "Item", item.description))
	for piece: EquipmentData in summary.equipment:
		things.add_child(_icon_tile(CardIcons.for_equipment(piece), piece.source_name, "Equipment · %s" % EquipmentData.slot_name(piece.slot), piece.description))
	for entry: Dictionary in summary.packs:
		things.add_child(_pack_tile(entry))
	for cosmetic: String in summary.cosmetics:
		things.add_child(_icon_tile(CardIcons.ui("level_badge"), cosmetic, "Wardrobe", "Open the wardrobe with T."))
	if things.get_child_count() > 0:
		body.add_child(things)
	if not summary.unlocks.is_empty():
		body.add_child(UIKit.spacer(2))
		body.add_child(UIKit.label("OPENED UP", &"MutedLabel", 18, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
		for line: String in summary.unlocks:
			var row: HBoxContainer = UIKit.hbox(10)
			row.alignment = BoxContainer.ALIGNMENT_CENTER
			row.add_child(CardIcons.glyph(CardIcons.ui("equipment_unlock"), UIStyle.GOOD, Vector2(30, 30)))
			row.add_child(UIKit.label(line, &"", 22, UIStyle.PARCHMENT))
			body.add_child(row)
	if not summary.levels_reached.is_empty():
		var last: int = summary.levels_reached[summary.levels_reached.size() - 1]
		body.add_child(UIKit.label("You reach level %d!" % last, &"HeadingLabel", 24, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))


func _counter(icon: String, text: String, color: Color) -> HBoxContainer:
	var row: HBoxContainer = UIKit.hbox(10)
	row.add_child(CardIcons.glyph(CardIcons.ui(icon), color, Vector2(44, 44)))
	var label: Label = UIKit.label(text, &"", 38, color)
	label.add_theme_font_override("font", UIStyle.font_title())
	row.add_child(label)
	return row


func _tile_box() -> PanelContainer:
	var tile: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = UIStyle.box(Color(UIStyle.INK.r, UIStyle.INK.g, UIStyle.INK.b, 0.75), UIStyle.GOLD_DIM, 2, 10)
	tile.add_theme_stylebox_override("panel", style)
	tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return tile


## A card shown as the real card (art, frame, rules text), scaled down.
func _card_tile(card: CardData) -> Control:
	var holder: Control = Control.new()
	holder.custom_minimum_size = CardView.SIZE * CARD_SCALE
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var view: CardView = CardView.create(card, CardView.Mode.FULL)
	holder.add_child(view)
	CardView.fit(view, CARD_SCALE)
	view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return holder


func _icon_tile(texture: Texture2D, title: String, kind_text: String, description: String) -> Control:
	var tile: PanelContainer = _tile_box()
	tile.custom_minimum_size = Vector2(TILE_WIDTH, 0)
	var column: VBoxContainer = UIKit.vbox(4)
	tile.add_child(UIKit.margin(column, 10))
	var icon: TextureRect = CardIcons.glyph(texture, UIStyle.PARCHMENT, Vector2(74, 74))
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.add_child(icon)
	column.add_child(_wrapped(title, 20, UIStyle.GOLD))
	column.add_child(_wrapped(kind_text, 15, UIStyle.MUTED))
	if not description.is_empty():
		column.add_child(_wrapped(description, 15, UIStyle.PARCHMENT))
	return tile


func _pack_tile(entry: Dictionary) -> Control:
	var tile: PanelContainer = _tile_box()
	tile.custom_minimum_size = Vector2(TILE_WIDTH, 0)
	var column: VBoxContainer = UIKit.vbox(4)
	tile.add_child(UIKit.margin(column, 10))
	var pack: PackData = PackCatalog.find(str(entry["id"]))
	if pack != null:
		var holder: Control = Control.new()
		holder.custom_minimum_size = PackArt.SIZE * 0.34
		holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var art: PackArt = PackArt.create(pack)
		holder.add_child(art)
		# PackArt scales about its own centre, so park that centre in the middle of the holder.
		art.scale = Vector2.ONE * 0.34
		art.position = holder.custom_minimum_size * 0.5 - PackArt.SIZE * 0.5
		column.add_child(holder)
	var count: int = int(entry["count"])
	column.add_child(_wrapped(str(entry["name"]) if count == 1 else "%dx %s" % [count, str(entry["name"])], 20, UIStyle.GOLD))
	column.add_child(_wrapped("Unopened pack", 15, UIStyle.MUTED))
	return tile


func _wrapped(text: String, size: int, color: Color) -> Label:
	var label: Label = UIKit.label(text, &"", size, color, HORIZONTAL_ALIGNMENT_CENTER)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(TILE_WIDTH - 24.0, 0)
	return label


func _on_confirmed() -> void:
	finished.emit()
