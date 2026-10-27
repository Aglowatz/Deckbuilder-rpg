class_name RewardPopup
extends Control
## The reward box: what a hidden chest held (gold, cards with their art, items, equipment, packs, cosmetics) or what a finished quest paid and
## opened up. Drawn in the shared `PopupFrame` look, like the level-up box. The player clicks (or presses Enter / Space / E) to continue; the
## owner (a world scene) keeps the hero still while it is open and listens to `finished`.

signal finished

const CARD_SCALE: float = 0.46
## Overnight Oct 23: the cards of an elite's or boss's pick, large enough to read their text.
const PICK_SCALE: float = 0.62
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
	var is_quest: bool = summary.kind == RewardSummary.Kind.QUEST or summary.kind == RewardSummary.Kind.QUEST_STEP
	var header: String = "QUEST COMPLETE" if summary.kind == RewardSummary.Kind.QUEST else ("STEP REWARD" if is_quest else "CHEST OPENED")
	if not summary.card_choices.is_empty():
		header = "VICTORY"
	# Overnight Oct 17, Part 7: a chest that held gear says so.
	if not is_quest and not summary.equipment.is_empty():
		header = "NEW GEAR!"
	frame = PopupFrame.make(header, "ICON-CHECK" if is_quest else "ICON-GOLD", UIStyle.GOLD if is_quest else Color("f2c14e"))
	frame.set_heading(summary.title, summary.subtitle)
	add_child(frame)
	_fill_body()
	frame.reveal_body()
	frame.confirmed.connect(_on_confirmed)
	if is_quest:
		Audio.sting(&"STG-QUEST")
	else:
		Audio.sfx(&"chest_open", -4.0)


func _fill_body() -> void:
	var body: VBoxContainer = frame.body
	if summary.is_empty() and summary.unlocks.is_empty():
		body.add_child(UIKit.label("An empty chest. Somebody got here first." if summary.kind == RewardSummary.Kind.CHEST else "No reward this time. The thanks are real.", &"MutedLabel", 22, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
		return
	var only_pick: bool = not summary.card_choices.is_empty() and summary.gold <= 0 and summary.xp <= 0 and summary.cards.is_empty() and summary.items.is_empty() and summary.equipment.is_empty() and summary.packs.is_empty()
	if not summary.is_empty() and not only_pick:
		body.add_child(UIKit.label("REWARDS", &"MutedLabel", 18, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	# Currency row: gold and XP as big counters.
	var currency: HBoxContainer = UIKit.hbox(46)
	currency.alignment = BoxContainer.ALIGNMENT_CENTER
	if summary.gold > 0:
		currency.add_child(_counter("ICON-GOLD", "coins", "+%d gold" % summary.gold, UIStyle.GOLD))
	if summary.xp > 0:
		currency.add_child(_counter("ICON-XP", "level_badge", "+%d XP" % summary.xp, UIStyle.GOOD))
	if currency.get_child_count() > 0:
		body.add_child(currency)
	# Things row: cards with their art, then items, equipment, packs, cosmetics.
	var things: HFlowContainer = HFlowContainer.new()
	things.alignment = FlowContainer.ALIGNMENT_CENTER
	things.add_theme_constant_override("h_separation", 16)
	things.add_theme_constant_override("v_separation", 12)
	things.custom_minimum_size = Vector2(PopupFrame.PANEL_WIDTH - 80.0, 0)
	for card: CardData in summary.cards:
		var tile: Control = _card_tile(card)
		if int(card.rarity) >= int(CardEnums.Rarity.EPIC):
			tile.set_meta(&"highlight", CardView.RARITY_COLORS[int(card.rarity)])
		things.add_child(tile)
	for item: ItemData in summary.items:
		things.add_child(_icon_tile(IconArt.item_texture(item, 74.0), item.display_name, "Item", item.description, IconArt.has_item_icon(item)))
	for piece: EquipmentData in summary.equipment:
		var rarity: int = clampi(int(piece.rarity), 0, 3)
		var gear: Control = _icon_tile(IconArt.equipment_texture(piece, 74.0), piece.source_name, "%s %s" % [EquipmentRarity.display_name(rarity), EquipmentData.slot_name(piece.slot)], piece.description, IconArt.has_equipment_icon(piece))
		# New gear glows in its rarity's colour (the same colours as cards).
		(gear as PanelContainer).add_theme_stylebox_override("panel", UIStyle.box(Color(UIStyle.INK.r, UIStyle.INK.g, UIStyle.INK.b, 0.8), CardView.RARITY_COLORS[rarity], 3, 10))
		gear.set_meta(&"highlight", CardView.RARITY_COLORS[rarity])
		things.add_child(gear)
	for entry: Dictionary in summary.packs:
		things.add_child(_pack_tile(entry))
	for cosmetic: String in summary.cosmetics:
		var shop_icon: Texture2D = IconArt.cosmetic_texture(_cosmetic_named(cosmetic), 74.0)  # Oct 19 night: ICON-COS-* once imported
		things.add_child(_icon_tile(shop_icon if shop_icon != null else CardIcons.ui("level_badge"), cosmetic, "Wardrobe", "Open the wardrobe with T.", shop_icon != null))
	if things.get_child_count() > 0:
		body.add_child(things)
	# Cards Oct 27, Part 3: cards go to the collection, never straight into the deck; the first time, a tip points at the Deck Station.
	if not summary.cards.is_empty():
		var where: Label = UIKit.label("Added to your collection%s." % (" - build it into a deck at the Deck Station" if Session.take_collection_tip() else ""), &"MutedLabel", 18, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
		where.name = "WhereLabel"
		where.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		where.custom_minimum_size = Vector2(PopupFrame.PANEL_WIDTH - 80.0, 0)
		body.add_child(where)
	if not summary.card_choices.is_empty():
		_add_pick(body)
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


func _counter(icon_id: String, fallback: String, text: String, color: Color) -> HBoxContainer:
	var row: HBoxContainer = UIKit.hbox(10)
	row.add_child(IconArt.glyph_or(icon_id, CardIcons.ui(fallback), color, 44.0))
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


## A card shown as the real card (art, frame, rules text), scaled down (`scale`: the Oct 23 pick shows its three cards larger).
func _card_tile(card: CardData, scale: float = CARD_SCALE) -> Control:
	var holder: Control = Control.new()
	holder.custom_minimum_size = CardView.SIZE * scale
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var view: CardView = CardView.create(card, CardView.Mode.FULL, true)
	holder.add_child(view)
	CardView.fit(view, scale)
	# Fixes Oct 27, Part 1: deferred - CardView._ready() sets its own filter back to STOP, and a stopping card ate every click meant for the
	# pick tile under it (the cause of "I can't pick a card" by mouse).
	view.set_deferred(&"mouse_filter", Control.MOUSE_FILTER_IGNORE)
	return holder


## `full_colour` shows the texture as it is (an icon) instead of a tinted silhouette.
## The hat or cloak a reward line names (its display name or id), null when none matches.
static func _cosmetic_named(text: String) -> CosmeticData:
	for item: CosmeticData in CosmeticCatalog.all():
		if item.display_name == text or item.id == text:
			return item
	return null


func _icon_tile(texture: Texture2D, title: String, kind_text: String, description: String, full_colour: bool = false) -> Control:
	var tile: PanelContainer = _tile_box()
	tile.custom_minimum_size = Vector2(TILE_WIDTH, 0)
	var column: VBoxContainer = UIKit.vbox(4)
	tile.add_child(UIKit.margin(column, 10))
	var icon: TextureRect = CardIcons.glyph(texture, UIStyle.PARCHMENT, Vector2(74, 74))
	if full_colour:
		icon.material = null
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


## Overnight Oct 23, Part 4: choose one card of the elite's or boss's pick (click a card, then continue; no card = skip).
## Fixes Oct 27, Part 1: by mouse (click a card), keyboard (Left / Right or 1-3, then Enter) and pad (D-pad + A on a card, then A on the button);
## the button reads "Skip" until a card is chosen; a click beside the cards no longer continues.
var _pick_tiles: Array[Control] = []
var _pick_hint: Label
var _pick_index: int = -1

const PICK_HINT: String = "Click a card to keep it (or Left / Right, 1-3), then Keep. Skip takes none. The card goes to your collection."
const PICK_HINT_PAD: String = "Choose a card with the D-pad and {confirm}, then Keep. Skip takes none. The card goes to your collection."


func _add_pick(body: VBoxContainer) -> void:
	body.add_child(UIKit.label("CHOOSE A CARD FOR YOUR COLLECTION", &"MutedLabel", 18, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	if Session.take_collection_tip():
		var tip: Label = UIKit.label("New: cards you win go to your collection, not straight into your deck. Build them in at the Deck Station.", &"", 18, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
		tip.name = "CollectionTip"
		tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		tip.custom_minimum_size = Vector2(PopupFrame.PANEL_WIDTH - 80.0, 0)
		body.add_child(tip)
	var row: HBoxContainer = UIKit.hbox(18)
	row.name = "PickRow"
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	for index: int in range(summary.card_choices.size()):
		var tile: Control = _card_tile(summary.card_choices[index], PICK_SCALE)
		tile.name = "Pick_%d" % index
		tile.mouse_filter = Control.MOUSE_FILTER_STOP
		tile.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		tile.tooltip_text = summary.card_choices[index].display_name
		var which: int = index
		tile.gui_input.connect(func(event: InputEvent) -> void:
			var click: InputEventMouseButton = event as InputEventMouseButton
			if click != null and click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
				select_pick(which)
				tile.accept_event())
		PadClick.enable(tile)  # the pad's A on a focused card is the same click
		row.add_child(tile)
		_pick_tiles.append(tile)
	body.add_child(row)
	_pick_hint = UIKit.label(PICK_HINT, &"MutedLabel", 18, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	_pick_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_pick_hint.custom_minimum_size = Vector2(PopupFrame.PANEL_WIDTH - 80.0, 0)
	PromptText.bind(_pick_hint, PICK_HINT, &"text", PICK_HINT_PAD)
	body.add_child(_pick_hint)
	frame.click_anywhere = false
	frame.first_focus = _pick_tiles[0] if not _pick_tiles.is_empty() else null
	frame.set_button_text("Skip")


## Keyboard: Left / Right step the chosen card, 1-3 choose one directly (Enter then keeps it through the frame). Only while this box is the
## top screen and the keyboard / mouse is in use (the pad moves the focus instead).
func _input(event: InputEvent) -> void:
	if summary == null or summary.card_choices.is_empty() or not is_visible_in_tree() or InputDevice.using_pad():
		return
	var key: InputEventKey = event as InputEventKey
	if key == null or not key.pressed or key.echo or PadFocus.top_root(get_tree()) != frame:
		return
	var index: int = -1
	if key.keycode >= KEY_1 and key.keycode <= KEY_9:
		index = int(key.keycode - KEY_1)
	elif event.is_action_pressed(&"ui_left") or key.keycode == KEY_LEFT or key.keycode == KEY_A:
		index = maxi(0, _pick_index - 1) if _pick_index >= 0 else 0
	elif event.is_action_pressed(&"ui_right") or key.keycode == KEY_RIGHT or key.keycode == KEY_D:
		index = mini(summary.card_choices.size() - 1, _pick_index + 1)
	if index < 0 or index >= summary.card_choices.size():
		return
	select_pick(index)
	get_viewport().set_input_as_handled()


func select_pick(index: int) -> void:
	if index < 0 or index >= summary.card_choices.size():
		return
	summary.picked = summary.card_choices[index]
	_pick_index = index
	Audio.sfx(&"ui_select")
	for i: int in range(_pick_tiles.size()):
		_pick_tiles[i].modulate = Color.WHITE if i == index else Color(0.6, 0.6, 0.68)
	if _pick_hint != null:
		PromptText.bind(_pick_hint, "%s: added to your collection when you keep it (build it in at the Deck Station). Or choose another card." % summary.picked.display_name, &"text")
	if frame != null:
		frame.set_button_text("Keep %s" % summary.picked.display_name if summary.picked.display_name.length() <= 16 else "Keep this card")
		if InputDevice.using_pad() and frame.button.is_visible_in_tree():
			frame.button.grab_focus.call_deferred()  # the next A keeps it


## Fixes Oct 27, Part 1: a card pick closed by something else opening over it (not answered) goes back to the front of the queue, so the
## world shows it again once that has closed - the pick is never lost.
static func requeue_if_unanswered(overlay: Control) -> void:
	var popup: RewardPopup = overlay as RewardPopup
	if popup == null or not is_instance_valid(popup) or popup.answered or popup.summary == null or popup.summary.card_choices.is_empty():
		return
	popup.answered = true
	Session.pending_popups.push_front(popup.summary)


var answered: bool = false


func _on_confirmed() -> void:
	answered = true
	if not summary.card_choices.is_empty():
		Session.take_reward_pick(summary.picked)
	finished.emit()
