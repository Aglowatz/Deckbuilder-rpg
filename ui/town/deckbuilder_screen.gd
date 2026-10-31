class_name DeckbuilderScreen
extends OverlayScreen
## The Deck Station: browse the collection with filters, click to add a card to the deck
## (right-click to remove), see the deck list with counts and live validation of the deck
## rules (45 cards minimum, copy caps by rarity and level, 2 colors - 3 or 4 once Primm is beaten and the postgame is unlocked), then save.

const CARD_SCALE: float = 0.55
## UI + economy fixes Oct 22: on a short canvas (under 900 px, e.g. 1280x720 or a big UI scale) the collection tiles are smaller.
const CARD_SCALE_SHORT: float = 0.46
const COLUMNS: int = 7
## Playtest v0.4.0 Part F: room left for the slot racks painted into the station's top and bottom (DeckRack.cell_rect). Oct 22: the
## spacers are measured from the racks at the screen's real size (`_relayout`); these are only the first guess.
const RACK_TOP_CLEARANCE: float = 50.0
const RACK_BOTTOM_CLEARANCE: float = 196.0
## The deck panel takes this share of the screen width, between the two bounds (it used to be 590 px wide at least and grew with its longest line).
const PANEL_SHARE: float = 0.31
const PANEL_MIN: float = 440.0
const PANEL_MAX: float = 600.0

var editor: DeckEditor
var _filter: CardFilterBar
var _grid: GridContainer
var _badges: Dictionary = {}
var _cards_by_id: Dictionary = {}
var _dim_by_id: Dictionary = {}
var _list_box: VBoxContainer
var _rules_box: VBoxContainer
var _count_label: Label
var _save_button: FancyButton
var _preview: HoverPreview
var _toast: Label
var _dirty: bool = false
var _hint_shown: bool = false
## Brief 16: which saved deck of `Session.deck_box` this screen is editing, and the deck bar widgets.
var _editing: int = 0
var _warning_label: Label
var _use_button: FancyButton
var _prompt_layer: Control
## Overnight Oct 17, Part 4: the Deck Box layer (ten slots), the save-slot picker and the cover picker; `_new_slot` is the
## empty slot a new, unsaved deck (`_editing` -1) was started in.
var _editing_label: Label
var _cover_layer: Control
var _new_slot: int = 0
## UI + economy fixes Oct 22: the pieces `_relayout` sizes to the screen.
var _card_scale: float = CARD_SCALE
## A short canvas (under 900 px: 1280x720-ish room, i.e. a big UI scale): smaller headings, buttons and list rows.
var _compact: bool = false
var _top_spacer: Control
var _bottom_spacer: Control
var _deck_panel: PanelContainer
## Overnight Oct 30-31, Part 7: the deck's shape (cost curve, Paths and types); "works well with" goes in the hovered card's preview.
var _curve_chart: DeckCurveChart
var _shape_label: Label
var _grid_scroll: ScrollContainer


func _init() -> void:
	screen_title = "Deck Station"
	title_icon_id = "ICON-UI-DECK"
	close_text = "Leave the Deck Station (Esc)"
	background_id = "UI-BG-DECKBUILDER"


## Overridable so the same screen can edit the dungeon run's current deck instead of the town
## deck (see DungeonDeckbuilderScreen) with the same validation rules either way.
func _source_deck() -> Deck:
	return Session.deck_box.build(_editing, Session.deck_lookup()) if _uses_deck_box() else Session.deck


## The town Deck Station edits the saved decks of the deck box; the dungeon version edits the run's own deck.
func _uses_deck_box() -> bool:
	return true


func _active_modifiers() -> ModifierSet:
	return null


func _write_back(edited: Deck) -> void:
	Session.store_deck(_editing, edited)


## The deck station is a long planning screen: it has its own theme (a short overlay would keep the area's music).
func music_cue() -> String:
	return MusicDirector.deck_station()


func _build() -> void:
	_editing = Session.deck_box.active
	var infrastructure: Array[CardData] = []
	for color: Affinity.Type in Affinity.colored_types():
		infrastructure.append(Session.content.infrastructure[int(color)] as CardData)
	editor = DeckEditor.from(Session.profile, _source_deck(), infrastructure, _active_modifiers())
	_preview = HoverPreview.new()
	add_child(_preview)
	_compact = size.y > 100.0 and size.y < 900.0
	_card_scale = CARD_SCALE_SHORT if _compact else CARD_SCALE
	if _uses_deck_box():
		# Playtest v0.4.0 Part F: the saved-deck slots live in the racks painted at the top and the bottom of the station (DeckRack); the
		# collection and the deck list sit between them.
		_top_spacer = UIKit.spacer(int(RACK_TOP_CLEARANCE))
		body.add_child(_top_spacer)
	var split: HBoxContainer = UIKit.hbox(22)
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(split)
	if _uses_deck_box():
		_bottom_spacer = UIKit.spacer(int(RACK_BOTTOM_CLEARANCE))
		body.add_child(_bottom_spacer)
	var left: VBoxContainer = UIKit.vbox(10)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split.add_child(left)
	_filter = CardFilterBar.new()
	_filter.show_extra = _uses_deck_box()
	_filter.changed.connect(_apply_filter)
	left.add_child(_filter)
	_grid_scroll = ScrollContainer.new()
	_grid_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# SHOW_NEVER, not DISABLED: a disabled direction takes the grid's width as its own minimum, and as the columns follow the width the
	# screen's measured size followed them (UiScale kept shrinking it). The columns always fit, so nothing ever scrolls sideways.
	_grid_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	left.add_child(_grid_scroll)
	_grid = GridContainer.new()
	_grid.columns = COLUMNS
	_grid.add_theme_constant_override("h_separation", 10)
	_grid.add_theme_constant_override("v_separation", 10)
	_grid_scroll.add_child(_grid)
	# The number of columns follows the room the collection has (it was a fixed 7, which pushed the deck panel off a 1280 px screen).
	_grid.columns = _columns_for(size.x - PANEL_MIN - 90.0 if size.x > 100.0 else 1300.0)
	_grid_scroll.resized.connect(func() -> void: _grid.columns = _columns_for(_grid_scroll.size.x))
	_fill_grid()
	_deck_panel = _build_deck_panel() as PanelContainer
	split.add_child(_deck_panel)
	_toast = UIKit.label("", &"", 26, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	_toast.add_theme_font_override("font", UIStyle.font_bold())
	_toast.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_toast.add_theme_constant_override("outline_size", 8)
	_toast.position = Vector2(300, 990)
	_toast.size = Vector2(900, 40)
	_toast.modulate.a = 0.0
	_toast.z_index = 250
	add_child(_toast)
	_refresh()
	if _uses_deck_box():
		_build_rack()
		_refresh_rack()
	resized.connect(_relayout)
	_relayout()
	_relayout.call_deferred()
	var min_size: int = DeckValidator.min_deck_size(_active_modifiers())
	TipPanel.show_once(self, &"tip_deck", "Building a deck", "Click a card to add it, right-click (or the [b]-[/b] button) to remove it. A legal deck has [b]%d+ cards[/b], at most [b]%d colors[/b], and a rarity-based copy limit that grows as you level up. Infrastructure powers your spells: [b]Fill Infrastructure[/b] tops up to %d. Your saved decks sit in the racks at the top and the bottom." % [min_size, DeckValidator.max_colors(Session.profile, _active_modifiers()), min_size], Vector2(1000, 905))  # Overnight Oct 30-31 (critic #14): over the lower rack, clear of the filters and the toast


## How many collection columns fit in `width` pixels (at least 2).
func _columns_for(width: float) -> int:
	var tile: float = CardView.SIZE.x * _card_scale + 10.0
	return maxi(2, int((width - 16.0 + 10.0) / tile))


## UI + economy fixes Oct 22: sizes the station to the screen - the deck panel's width, the gaps kept free for the slot racks (measured on
## the racks at this size, so the collection and the deck list use all the room between them) and the toast's place.
func _relayout() -> void:
	if not is_inside_tree() or size.x < 100.0 or _deck_panel == null:
		return
	_deck_panel.custom_minimum_size.x = clampf(size.x * PANEL_SHARE, PANEL_MIN, PANEL_MAX)
	_toast.size = Vector2(minf(900.0, size.x - 80.0), 40)
	_toast.position = Vector2((size.x - _toast.size.x) * 0.5, size.y - _toast.size.y - 50.0)
	if _top_spacer == null or _bottom_spacer == null:
		return
	var body_top: float = (body.global_position.y - global_position.y) / maxf(scale.y, 0.01)
	var body_bottom: float = size.y - float(SCREEN_MARGIN)
	var top_rack: Rect2 = DeckRack.cell_rect(0, size)
	var bottom_rack: Rect2 = DeckRack.cell_rect(5, size)
	_top_spacer.custom_minimum_size.y = maxf(0.0, top_rack.end.y + 6.0 - body_top)
	_bottom_spacer.custom_minimum_size.y = maxf(0.0, body_bottom - bottom_rack.position.y + 6.0)
	# The top rack is painted over the header's middle: the title stays only while it ends before the first slot (the book icon says the rest).
	if title_label != null:
		title_label.add_theme_font_size_override("font_size", 48 if not _compact else 34)
		var title_end: float = (title_label.global_position.x - global_position.x) / maxf(scale.x, 0.01) + title_label.get_minimum_size().x
		title_label.visible = title_end < top_rack.position.x - 8.0


func _build_deck_panel() -> Control:
	var panel: PanelContainer = UIKit.panel()
	panel.name = "DeckPanel"
	panel.custom_minimum_size = Vector2(PANEL_MIN, 0)
	var column: VBoxContainer = UIKit.vbox(8)
	panel.add_child(column)
	# On a short canvas the slot line under it already names the deck, so the heading makes room for the list.
	if not _compact:
		column.add_child(UIKit.label("Your Deck", &"HeadingLabel", 30))
	if _uses_deck_box():
		column.add_child(_build_deck_bar())
	_count_label = UIKit.label("", &"", 22, UIStyle.PARCHMENT)
	_wrap(_count_label)
	column.add_child(_count_label)
	# Overnight Oct 30-31, Part 7: the cost curve stands beside the rule rows, so the deck list keeps its height.
	var rules_row: HBoxContainer = UIKit.hbox(10)
	column.add_child(rules_row)
	_rules_box = UIKit.vbox(2)
	_rules_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rules_row.add_child(_rules_box)
	_curve_chart = DeckCurveChart.new()
	_curve_chart.name = "CostCurve"
	_curve_chart.custom_minimum_size = Vector2(170, 76)
	_curve_chart.tooltip_text = "Cost curve: your spells and units by energy cost (Infrastructure left out)."
	rules_row.add_child(_curve_chart)
	_warning_label = UIKit.label("", &"", 19, Color("ffb066"))
	_wrap(_warning_label)
	column.add_child(_warning_label)
	_shape_label = UIKit.label("", &"", 15, UIStyle.MUTED)
	_shape_label.name = "DeckShape"
	_shape_label.clip_text = true
	_shape_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_shape_label.custom_minimum_size = Vector2(PANEL_MIN - 40.0, 0)
	column.add_child(_shape_label)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var frame: PanelContainer = UIKit.panel(&"DarkPanel")
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.custom_minimum_size = Vector2(0, 96)
	frame.add_child(scroll)
	column.add_child(frame)
	_list_box = UIKit.vbox(3)
	_list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_list_box)
	# A flow row: on a narrow panel Reset moves under the other two instead of running past the panel's edge.
	var buttons: HFlowContainer = HFlowContainer.new()
	buttons.add_theme_constant_override("h_separation", 10)
	buttons.add_theme_constant_override("v_separation", 8)
	column.add_child(buttons)
	var button_height: float = 54.0 if not _compact else 46.0
	_save_button = FancyButton.make("Save Deck", &"PrimaryButton", Vector2(150, button_height))
	_save_button.pressed.connect(_save)
	buttons.add_child(_save_button)
	var reset: FancyButton = FancyButton.make("Reset", &"", Vector2(110, button_height))
	reset.tooltip_text = "Go back to the saved deck."
	reset.pressed.connect(_reset)
	buttons.add_child(reset)
	var fill: FancyButton = FancyButton.make("Fill Infrastructure", &"", Vector2(150, button_height))
	fill.tooltip_text = "Adds basic infrastructure of your deck's colors until the deck reaches the minimum size."
	fill.pressed.connect(_autofill)
	buttons.add_child(fill)
	if _uses_deck_box():
		var suggest: FancyButton = FancyButton.make("Suggest a deck", &"", Vector2(170, button_height))
		suggest.name = "SuggestDeck"
		suggest.tooltip_text = "Builds a deck from your collection for the Path(s) you choose: a cost curve, units first, the best cards you own within the copy caps. Review it, then Save Deck."
		suggest.pressed.connect(open_suggest)
		buttons.add_child(suggest)
	return panel


# ---- Saved decks (brief 16, Group E; Overnight Oct 17, Part 4: the ten-slot Deck Box; Playtest v0.4.0, Part F: the slot racks) --------
## Playtest v0.4.0 Part F: the ten saved-deck slots are the slot racks painted into the top and the bottom of the Deck Station itself
## (`DeckRack`), not a separate Deck Box screen. Click a slot to open that deck (or start a new one in an empty slot); Save Deck asks
## which slot by lighting the racks up (`_save_mode`), with an overwrite confirm on a slot that holds another deck. Rename, Use, Cover,
## Copy and Delete act on the deck being edited and sit in the deck bar.

var _rack: DeckRack
var _save_mode: bool = false


func _build_rack() -> void:
	_rack = DeckRack.new()
	_rack.name = "DeckRack"
	_rack.canvas = size if size.x > 100.0 else Vector2(1920, 1080)
	_rack.highlight = _editing_slot()
	_rack.slot_pressed.connect(_on_rack_slot)
	_rack.z_index = 5
	add_child(_rack)
	resized.connect(func() -> void:
		if _rack != null and is_instance_valid(_rack) and size.x > 100.0 and _rack.canvas != size:
			_rack.canvas = size
			_rack.rebuild())


func _refresh_rack() -> void:
	if _rack == null or not is_instance_valid(_rack):
		return
	_rack.highlight = _editing_slot()
	_rack.save_mode = _save_mode
	_rack.rebuild()


## Where the racks are on this screen (tests and smokes): the tile of slot `slot`.
func rack_tile(slot: int) -> FancyButton:
	return _rack.tiles[slot] if _rack != null and slot >= 0 and slot < _rack.tiles.size() else null


func _build_deck_bar() -> Control:
	var column: VBoxContainer = UIKit.vbox(6)
	column.name = "DeckBar"
	_editing_label = UIKit.label("", &"", 20, UIStyle.PARCHMENT)
	_editing_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_editing_label.clip_text = true
	_editing_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	column.add_child(_editing_label)
	var bar: HBoxContainer = UIKit.hbox(6)
	column.add_child(bar)
	var rename: FancyButton = _bar_button("Rename", "Give this deck another name.", _on_rename_deck)
	rename.name = "RenameDeck"
	bar.add_child(rename)
	_use_button = _bar_button("Use", "Make this the deck battles and dungeons use.", _on_use_deck)
	_use_button.name = "UseDeck"
	bar.add_child(_use_button)
	var cover: FancyButton = _bar_button("Cover", "Pick the card shown on this deck's slot.", _box_cover)
	cover.name = "BoxCoverCard"
	bar.add_child(cover)
	var copy: FancyButton = _bar_button("Copy", "Copy this deck into a free slot.", _box_copy)
	copy.name = "BoxCopy"
	bar.add_child(copy)
	var delete: FancyButton = _bar_button("Delete", "Delete this deck (your cards stay in the collection).", _box_delete)
	delete.name = "BoxDelete"
	bar.add_child(delete)
	return column


func _bar_button(text: String, tip: String, callback: Callable) -> FancyButton:
	var button: FancyButton = FancyButton.make(text, &"GhostButton", Vector2(0, 40))
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(0, 40)
	button.clip_text = true
	button.tooltip_text = tip
	button.add_theme_font_size_override("font_size", 17)
	# Oct 22: slim side margins so five buttons keep their whole word on a narrow panel ("Renam" was cut). Done once the button is in the
	# tree, where its GhostButton look is known.
	button.ready.connect(func() -> void:
		for state: String in ["normal", "hover", "pressed", "disabled", "focus", "hover_pressed"]:
			var box: StyleBox = button.get_theme_stylebox(state)
			if box != null:
				var slim: StyleBox = box.duplicate() as StyleBox
				slim.content_margin_left = minf(box.content_margin_left, 4.0)
				slim.content_margin_right = minf(box.content_margin_right, 4.0)
				button.add_theme_stylebox_override(state, slim), CONNECT_ONE_SHOT)
	button.pressed.connect(callback)
	return button


func _editing_deck() -> DeckBox.SavedDeck:
	return Session.deck_box.decks[_editing] if Session.deck_box.is_valid_index(_editing) else null


## The slot the deck being edited sits in (a new deck: the empty slot it was started in).
func _editing_slot() -> int:
	var saved: DeckBox.SavedDeck = _editing_deck()
	return saved.slot if saved != null else _new_slot


func _refresh_deck_bar() -> void:
	if _warning_label != null:
		var lines: Array[String] = []
		if _uses_deck_box() and Session.deck_box.is_valid_index(_editing):
			lines = Session.deck_warnings(_editing)
		_warning_label.text = "" if lines.is_empty() else "Warning: %s" % " ".join(lines)
		_warning_label.visible = not lines.is_empty()
	if _editing_label == null:
		return
	var saved: DeckBox.SavedDeck = _editing_deck()
	if saved == null:
		_editing_label.text = "Slot %d: a new deck (not saved yet)" % (_new_slot + 1)
	else:
		_editing_label.text = "Slot %d: %s%s" % [saved.slot + 1, saved.name, "  (in use)" if _editing == Session.deck_box.active else ""]
	_use_button.disabled = saved == null or _editing == Session.deck_box.active
	_use_button.text = "In use" if saved != null and _editing == Session.deck_box.active else "Use"


func _edit_deck(index: int) -> void:
	_editing = index
	var infrastructure: Array[CardData] = editor.infrastructure
	editor = DeckEditor.from(Session.profile, _source_deck(), infrastructure, _active_modifiers())
	_dirty = false
	_refresh()


## Runs `then` now, or after the player agrees to drop unsaved changes.
func _guard_dirty(then: Callable, parent: Node = null) -> void:
	if not _dirty:
		then.call()
		return
	var dialog: ConfirmDialog = ConfirmDialog.ask(parent if parent != null else self, "Unsaved changes", "Leave this deck without saving your changes?", "Discard changes", "Keep editing", true)
	dialog.confirmed.connect(then)


func _start_new_deck(slot: int) -> void:
	_new_slot = slot
	_edit_deck(-1)
	_say("A new empty deck for slot %d. Add cards, then Save Deck." % (slot + 1), UIStyle.GOOD)


func _on_rename_deck() -> void:
	if _editing_deck() == null:
		_say("Save this deck first, then name it.", Color("ffcf70"))
		return
	_prompt_name("Rename deck", _editing_deck().name, func(new_name: String) -> void:
		Session.rename_saved_deck(_editing, new_name)
		_refresh())


func _on_use_deck() -> void:
	if _dirty:
		_say("Save this deck first.", Color("ffcf70"))
		return
	if Session.use_deck(_editing):
		Audio.sfx(&"ui_confirm")
		_say("\"%s\" is now your battle deck." % Session.deck_box.decks[_editing].name, UIStyle.GOOD)
		_refresh()
		EventBus.collection_changed.emit()


## A dimmed full-screen layer with a centred panel; returns [layer, column].
func _layer(layer_name: String, title: String, subtitle: String) -> Array[Control]:
	var layer: Control = Control.new()
	layer.name = layer_name
	UIKit.full_rect(layer)
	layer.z_index = 200
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(layer)
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.02, 0.01, 0.05, 0.78)
	UIKit.full_rect(shade)
	layer.add_child(shade)
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	layer.add_child(center)
	var panel: PanelContainer = UIKit.panel()
	center.add_child(panel)
	var column: VBoxContainer = UIKit.vbox(12)
	panel.add_child(column)
	column.add_child(UIKit.label(title, &"HeadingLabel", 34, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	if not subtitle.is_empty():
		column.add_child(UIKit.label(subtitle, &"MutedLabel", 19, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	return [layer, column] as Array[Control]


func _close_layer(layer: Control) -> void:
	if layer != null and is_instance_valid(layer):
		layer.queue_free()


func _slots_subtitle() -> String:
	var open: int = Session.deck_capacity()
	if open >= DeckSlots.SLOT_COUNT:
		return "All ten slots are open."
	return "%d of %d slots open. Two more open at level %d." % [open, DeckSlots.SLOT_COUNT, DeckSlots.level_for_slot(open)]


## Kept for callers that used to open the Deck Box screen: the slots are the racks now, so this just points at the current one.
func open_deck_box() -> void:
	if _rack != null:
		_rack.focus_slot(maxi(_editing_slot(), 0))


## A rack slot was clicked: in save mode it is the slot to save into; otherwise it opens that deck or starts a new one in an empty slot.
func _on_rack_slot(slot: int) -> void:
	if _save_mode:
		_on_save_slot(slot)
		return
	if not Session.slot_open(slot):
		_say("Slot %d opens at level %d." % [slot + 1, DeckSlots.level_for_slot(slot)], Color("ffcf70"))
		return
	var index: int = Session.deck_box.index_in_slot(slot)
	if index < 0:
		_guard_dirty(func() -> void: _start_new_deck(slot))
		return
	if index == _editing:
		_say("That is the deck you are editing.", UIStyle.MUTED)
		return
	_guard_dirty(func() -> void:
		_edit_deck(index)
		_say("Opened \"%s\" from slot %d." % [Session.deck_box.decks[index].name, slot + 1], UIStyle.GOOD))


func _box_index() -> int:
	return _editing if Session.deck_box.is_valid_index(_editing) else -1


func _box_copy() -> void:
	var index: int = _box_index()
	if index < 0:
		_say("Save this deck first, then copy it.", Color("ffcf70"))
		return
	var created: int = Session.duplicate_saved_deck(index)
	if created < 0:
		_say("No free slot to copy into.", Color("ff8a85"))
		return
	_say("Deck copied into slot %d." % (Session.deck_box.decks[created].slot + 1), UIStyle.GOOD)
	_refresh_rack()


func _box_delete() -> void:
	var index: int = _box_index()
	if index < 0:
		_say("This deck is not saved yet; there is nothing to delete.", Color("ffcf70"))
		return
	if Session.deck_box.size() <= 1:
		_say("You always keep at least one deck.", Color("ffcf70"))
		return
	var doomed_name: String = Session.deck_box.decks[index].name
	var dialog: ConfirmDialog = ConfirmDialog.ask(self, "Delete this deck?", "\"%s\" will be deleted. Your cards stay in your collection." % doomed_name, "Delete", "Cancel", true)
	dialog.confirmed.connect(func() -> void:
		Session.delete_saved_deck(index)
		_edit_deck(Session.deck_box.active)
		_say("Deck deleted.", UIStyle.GOOD))


## Pick the slot's cover card from the deck's own cards (its rarest card is the default).
func _box_cover() -> void:
	var index: int = _box_index()
	if index < 0:
		_say("Save this deck first, then pick its cover.", Color("ffcf70"))
		return
	var saved: DeckBox.SavedDeck = Session.deck_box.decks[index]
	var parts: Array[Control] = _layer("CoverLayer", "Cover Card", "The card shown on \"%s\"'s slot." % saved.name)
	var layer: Control = parts[0]
	layer.z_index = 210
	var column: VBoxContainer = parts[1] as VBoxContainer
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(1180, 230)
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	var row: HBoxContainer = UIKit.hbox(10)
	scroll.add_child(row)
	var current: String = DeckSlots.cover_id(saved.card_ids, Session.deck_lookup(), saved.cover_id)
	var seen: Dictionary = {}
	var first: Button = null
	for id: String in saved.card_ids:
		var card: CardData = Session.card_by_id(id)
		if card == null or card.is_unlimited() or seen.has(id):
			continue
		seen[id] = true
		var pick: FancyButton = FancyButton.make("", &"GhostButton", CardView.SIZE * 0.42 + Vector2(8, 8))
		pick.tooltip_text = card.display_name
		var view: CardView = CardView.create(card, CardView.Mode.FULL)
		view.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pick.add_child(view)
		CardView.fit(view, 0.42)
		view.position += Vector2(4, 4)
		for child: Node in view.find_children("*", "Control", true, false):
			(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
		if id == current:
			pick.add_theme_stylebox_override("normal", UIStyle.box(Color(0, 0, 0, 0), UIStyle.GOLD, 3, 10))
		pick.pressed.connect(func() -> void:
			Session.set_deck_cover(index, id)
			Audio.sfx(&"ui_confirm")
			_close_layer(layer)
			_cover_layer = null
			_refresh_rack())
		row.add_child(pick)
		pick.focus_mode = Control.FOCUS_ALL
		if first == null:
			first = pick
	if seen.is_empty():
		column.add_child(UIKit.label("This deck has only infrastructure.", &"", 20, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	var back: FancyButton = FancyButton.make("Back", &"", Vector2(170, 50))
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(func() -> void:
		_close_layer(layer)
		_cover_layer = null)
	column.add_child(back)
	back.focus_mode = Control.FOCUS_ALL
	if first != null:
		first.call_deferred(&"grab_focus")
	_cover_layer = layer


## Saving asks which slot: the racks light up ("Save here"), the deck's own slot is highlighted, and a slot holding another deck asks
## before overwriting it. Esc leaves save mode.
func open_save_picker() -> void:
	_save_mode = true
	_refresh_rack()
	_say("Save to which slot? Click a slot in the racks above or below (Esc cancels).", Color("ffcf70"))
	_rack.focus_slot(maxi(_editing_slot(), 0))


func in_save_mode() -> bool:
	return _save_mode


func cancel_save_mode() -> void:
	if not _save_mode:
		return
	_save_mode = false
	_refresh_rack()


func _on_save_slot(slot: int) -> void:
	if not Session.slot_open(slot):
		_say("Slot %d opens at level %d." % [slot + 1, DeckSlots.level_for_slot(slot)], Color("ffcf70"))
		return
	var index: int = Session.deck_box.index_in_slot(slot)
	if index >= 0 and index != _editing:
		var dialog: ConfirmDialog = ConfirmDialog.ask(self, "Overwrite slot %d?" % (slot + 1), "\"%s\" in slot %d will be replaced by this deck." % [Session.deck_box.decks[index].name, slot + 1], "Overwrite", "Cancel", true)
		dialog.confirmed.connect(func() -> void: save_to_slot(slot))
		return
	save_to_slot(slot)


## Saves the edited deck into `slot` (tests and smokes call this directly).
func save_to_slot(slot: int) -> bool:
	var saved: DeckBox.SavedDeck = _editing_deck()
	var deck_name: String = saved.name if saved != null else "New Deck %d" % (slot + 1)
	var cover: String = saved.cover_id if saved != null else ""
	var index: int = Session.save_deck_to_slot(slot, editor.deck, deck_name, cover)
	if index < 0:
		return false
	_save_mode = false
	_editing = index
	_dirty = false
	Audio.sfx(&"ui_confirm")
	if editor.is_valid():
		_say("Deck saved in slot %d. It is ready for the dungeon." % (slot + 1), UIStyle.GOOD)
	else:
		_say("Deck saved in slot %d, but it is not legal yet: %s" % [slot + 1, editor.issues()[0].message], Color("ffcf70"))
	_refresh()
	EventBus.collection_changed.emit()
	return true



## A small name prompt over the screen.
func _prompt_name(title: String, default_text: String, done: Callable) -> void:
	if _prompt_layer != null:
		_prompt_layer.queue_free()
	_prompt_layer = Control.new()
	_prompt_layer.name = "NamePrompt"
	UIKit.full_rect(_prompt_layer)
	_prompt_layer.z_index = 220
	add_child(_prompt_layer)
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.02, 0.01, 0.05, 0.7)
	UIKit.full_rect(shade)
	_prompt_layer.add_child(shade)
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	_prompt_layer.add_child(center)
	var panel: PanelContainer = UIKit.panel()
	panel.custom_minimum_size = Vector2(560, 0)
	center.add_child(panel)
	var column: VBoxContainer = UIKit.vbox(14)
	panel.add_child(column)
	column.add_child(UIKit.label(title, &"HeadingLabel", 32, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var edit: LineEdit = LineEdit.new()
	edit.name = "NameEdit"
	edit.text = default_text
	edit.max_length = DeckBox.MAX_NAME_LENGTH
	edit.custom_minimum_size = Vector2(0, 48)
	edit.add_theme_font_size_override("font_size", 26)
	column.add_child(edit)
	var row: HBoxContainer = UIKit.hbox(14)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(row)
	var accept: FancyButton = FancyButton.make("OK", &"PrimaryButton", Vector2(200, 52))
	accept.pressed.connect(func() -> void:
		done.call(edit.text)
		_prompt_layer.queue_free()
		_prompt_layer = null)
	row.add_child(accept)
	var cancel: FancyButton = FancyButton.make("Cancel", &"", Vector2(200, 52))
	cancel.pressed.connect(func() -> void:
		_prompt_layer.queue_free()
		_prompt_layer = null)
	row.add_child(cancel)
	edit.text_submitted.connect(func(_text: String) -> void: accept.pressed.emit())
	edit.grab_focus()
	edit.select_all()


# ---- Collection grid --------------------------------------------------------------------


func _collection() -> Array[CardData]:
	var seen: Dictionary = {}
	var result: Array[CardData] = []
	for card: CardData in Session.profile.owned_cards:
		if not seen.has(card.id):
			seen[card.id] = true
			result.append(card)
	result.sort_custom(func(a: CardData, b: CardData) -> bool:
		if a.color != b.color:
			return int(a.color) < int(b.color)
		if a.energy_value() != b.energy_value():
			return a.energy_value() < b.energy_value()
		return a.display_name < b.display_name)
	for color: Affinity.Type in Affinity.colored_types():
		result.append(Session.content.infrastructure[int(color)] as CardData)
	return result


## Overnight Oct 17 (Phase 2, performance): the first rows of the collection are built at once, the rest a few per frame, so
## opening the station never stalls on one long frame.
const FIRST_TILES: int = 0  # Oct 17 cycle 25: 8 -> 4 (~60 ms cold for 8); Oct 18 cycle 33: 0 - the opening frame 110-124 -> 80-90 ms, cards from the next frame
const TILES_PER_FRAME: int = 3
var _pending_tiles: Array[CardData] = []


func _fill_grid() -> void:
	var cards: Array[CardData] = _collection()
	for index: int in range(cards.size()):
		var card: CardData = cards[index]
		_cards_by_id[card.id] = card
		if index < FIRST_TILES:
			_grid.add_child(_make_tile(card))
		else:
			_pending_tiles.append(card)


## True while collection tiles are still being added (tests and smokes wait for it).
func is_building() -> bool:
	return not _pending_tiles.is_empty()


func _process(_delta: float) -> void:
	if _pending_tiles.is_empty():
		return
	for _step: int in range(TILES_PER_FRAME):
		if _pending_tiles.is_empty():
			break
		var card: CardData = _pending_tiles.pop_front()
		var tile: Control = _make_tile(card)
		tile.visible = _filter == null or _filter.matches(card)
		_grid.add_child(tile)
	if _pending_tiles.is_empty():
		_refresh()


func _make_tile(card: CardData) -> Control:
	var holder: Control = Control.new()
	holder.custom_minimum_size = CardView.SIZE * _card_scale + Vector2(0, 30)
	holder.set_meta("card_id", card.id)
	var view: CardView = CardView.create(card, CardView.Mode.FULL, true)
	holder.add_child(view)
	CardView.fit(view, _card_scale)
	view.gui_event.connect(func(_v: CardView, event: InputEvent) -> void: _on_tile_input(card, event))
	PadClick.enable(view)  # controller support (Oct 26): A adds the card, X takes one out
	view.hovered.connect(func(_v: CardView) -> void:
		_preview.show_for(holder, card, synergy_entries(card))
		Audio.sfx(&"card_hover", -14.0))
	view.unhovered.connect(func(_v: CardView) -> void: _preview.hide_preview())
	var badge: Label = UIKit.label("", &"", 19, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	badge.add_theme_font_override("font", UIStyle.font_bold())
	badge.add_theme_font_size_override("font_size", 18)
	badge.add_theme_stylebox_override("normal", UIStyle.box(Color(0.04, 0.02, 0.08, 0.92), UIStyle.GOLD_DIM, 2, 12))
	badge.position = Vector2(4, CardView.SIZE.y * _card_scale + 4.0)
	badge.size = Vector2(CardView.SIZE.x * _card_scale - 8.0, 26)
	badge.clip_text = true
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(badge)
	_badges[card.id] = badge
	_dim_by_id[card.id] = view
	return holder


func _apply_filter() -> void:
	for tile: Node in _grid.get_children():
		var card: CardData = _cards_by_id.get(str(tile.get_meta("card_id"))) as CardData
		(tile as Control).visible = _filter.matches(card)


func _on_tile_input(card: CardData, event: InputEvent) -> void:
	var click: InputEventMouseButton = event as InputEventMouseButton
	if click == null or not click.pressed:
		return
	if click.button_index == MOUSE_BUTTON_LEFT:
		_add(card)
	elif click.button_index == MOUSE_BUTTON_RIGHT:
		_remove(card)


func _add(card: CardData) -> void:
	var reason: String = editor.why_not_add(card)
	if reason != "":
		Audio.sfx(&"ui_error", -4.0)
		_say(reason, Color("ff8a85"))
		return
	editor.add(card)
	_dirty = true
	Audio.sfx(&"deck_add")
	_refresh()


func _remove(card: CardData) -> void:
	if editor.remove(card):
		_dirty = true
		Audio.sfx(&"deck_remove")
		_refresh()


func _say(text: String, color: Color = UIStyle.PARCHMENT) -> void:
	_toast.text = text
	_toast.add_theme_color_override("font_color", color)
	_toast.modulate.a = 1.0
	var tween: Tween = create_tween()
	tween.tween_interval(1.8)
	tween.tween_property(_toast, "modulate:a", 0.0, 0.4)


# ---- Deck panel -------------------------------------------------------------------------


func _refresh() -> void:
	for id: Variant in _badges.keys():
		var card: CardData = _cards_by_id[id] as CardData
		var label: Label = _badges[id] as Label
		var in_deck: int = editor.count(card)
		if card.is_basic:
			label.text = "In deck: %d" % in_deck
		else:
			# Cards Oct 27, Part 3: "NEW" until the station is next closed (Session.new_cards: the cards that joined the collection since).
			label.text = "%sDeck %s  Own %d" % ["NEW  " if Session.new_cards.has(str(id)) else "", editor.cap_text(card), editor.owned(card)]
			label.add_theme_color_override("font_color", UIStyle.GOLD if Session.new_cards.has(str(id)) else UIStyle.PARCHMENT)
		var view: CardView = _dim_by_id[id] as CardView
		view.modulate = Color(1, 1, 1, 1) if in_deck > 0 or card.is_basic else Color(0.82, 0.82, 0.86, 1)
	_rebuild_list()
	_rebuild_rules()
	_refresh_shape()
	var size: int = editor.deck.size()
	_count_label.text = "%d cards  -  %d infrastructure, %d spells" % [size, editor.infrastructure_count(), size - editor.infrastructure_count()]
	# Daytime Oct 19 (onboarding timing): a new hero owns no spare copies (the cave's cards are already in the deck), so "Make It Yours"
	# could only finish after a pointless change. Until the first save, Save Deck stays available.
	var first_save: bool = not Session.flag(&"deck_edited")
	_save_button.text = "Save Deck" if _dirty or first_save else "Saved"
	_save_button.disabled = not (_dirty or first_save)
	_refresh_deck_bar()
	_refresh_rack()


func _rebuild_rules() -> void:
	for child: Node in _rules_box.get_children():
		child.queue_free()
	var issues: Array[DeckValidator.Issue] = editor.issues()
	var colors: Array[Affinity.Type] = editor.deck.colors()
	var color_names: Array[String] = []
	for color: Affinity.Type in colors:
		color_names.append(UIStyle.affinity_name(color))
	var limit: int = DeckValidator.max_colors(Session.profile, _active_modifiers())
	_rule_row(not DeckValidator.has_problem(issues, DeckValidator.Problem.TOO_FEW_CARDS), "At least %d cards (you have %d)" % [DeckValidator.min_deck_size(_active_modifiers()), editor.deck.size()])
	_rule_row(not DeckValidator.has_problem(issues, DeckValidator.Problem.TOO_MANY_COPIES), "Copy caps: %s; infrastructure unlimited" % _caps_summary())
	_rule_row(not DeckValidator.has_problem(issues, DeckValidator.Problem.TOO_MANY_COLORS), "At most %d Path%s (%s)" % [limit, "" if limit == 1 else "s", ", ".join(color_names) if not color_names.is_empty() else "none yet"])
	if DeckValidator.has_problem(issues, DeckValidator.Problem.NOT_OWNED):
		_rule_row(false, "You use cards you do not own")


## "Common 3, Uncommon 2, Epic 1, Legendary 1" at the player's level.
func _caps_summary() -> String:
	var parts: PackedStringArray = []
	for rarity: int in range(CardEnums.Rarity.size()):
		parts.append("%s %d" % [CopyCaps.rarity_name(rarity as CardEnums.Rarity), CopyCaps.cap_for(rarity as CardEnums.Rarity, Session.profile.level)])
	return ", ".join(parts)


func _rule_row(ok: bool, text: String) -> void:
	var row: HBoxContainer = UIKit.hbox(10)
	var dot: Panel = Panel.new()
	dot.custom_minimum_size = Vector2(16, 16)
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	dot.add_theme_stylebox_override("panel", UIStyle.box(UIStyle.GOOD if ok else UIStyle.DANGER, Color(0, 0, 0, 0.4), 2, 8))
	row.add_child(dot)
	var line: Label = UIKit.label(text, &"", 19 if not _compact else 17, UIStyle.PARCHMENT if ok else Color("ff9d98"))
	_wrap(line)
	row.add_child(line)
	_rules_box.add_child(row)


## A label that wraps inside its container instead of setting the container's width (a long rules line pushed the deck panel off the screen).
func _wrap(label: Label) -> void:
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.custom_minimum_size = Vector2(60, 0)


func _rebuild_list() -> void:
	for child: Node in _list_box.get_children():
		child.queue_free()
	var counts: Dictionary = editor.deck.copy_counts()
	var entries: Array[CardData] = []
	for id: Variant in counts.keys():
		var card: CardData = _cards_by_id.get(str(id)) as CardData
		if card == null:
			card = Session.card_by_id(str(id))
		entries.append(card)
	entries.sort_custom(func(a: CardData, b: CardData) -> bool:
		if a.is_infrastructure() != b.is_infrastructure():
			return b.is_infrastructure()
		if a.energy_value() != b.energy_value():
			return a.energy_value() < b.energy_value()
		return a.display_name < b.display_name)
	var last_group: String = ""
	for card: CardData in entries:
		var group: String = "Infrastructure" if card.is_infrastructure() else "Spells and units"
		if group != last_group:
			last_group = group
			_list_box.add_child(UIKit.label(group, &"MutedLabel", 19))
		_list_box.add_child(_list_row(card, int(counts[card.id])))


func _list_row(card: CardData, count: int) -> Control:
	var tint: Color = UIStyle.affinity_color(card.color)
	var row: PanelContainer = PanelContainer.new()
	row.add_theme_stylebox_override("panel", UIStyle.box(Color(1, 1, 1, 0.05), Color(0, 0, 0, 0), 0, 8))
	var line: HBoxContainer = UIKit.hbox(8)
	row.add_child(line)
	var bar: Panel = Panel.new()
	bar.custom_minimum_size = Vector2(6, 28)
	bar.add_theme_stylebox_override("panel", UIStyle.box(tint, Color(0, 0, 0, 0), 0, 3))
	line.add_child(bar)
	if card.is_multipath():
		var bar2: Panel = Panel.new()
		bar2.custom_minimum_size = Vector2(6, 28)
		bar2.add_theme_stylebox_override("panel", UIStyle.box(UIStyle.affinity_color(card.color2), Color(0, 0, 0, 0), 0, 3))
		line.add_child(bar2)
	if Settings.colorblind_symbols:
		for path: Affinity.Type in card.paths():
			var path_symbol: TextureRect = IconArt.rect(IconArt.energy_id(path), 26.0, "%s Path" % UIStyle.affinity_name(path))
			if path_symbol != null:
				line.add_child(path_symbol)
	var cost: Label = UIKit.label("" if card.is_infrastructure() else str(card.energy_value()), &"", 20, UIStyle.INK, HORIZONTAL_ALIGNMENT_CENTER)
	cost.custom_minimum_size = Vector2(30, 28)
	cost.add_theme_stylebox_override("normal", UIStyle.box(Color("cdc5d6") if not card.is_infrastructure() else Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0, 14))
	cost.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	line.add_child(cost)
	var name_label: Label = UIKit.label(card.display_name if not card.display_name.is_empty() else "%s Infrastructure" % UIStyle.affinity_name(card.color), &"", 21, UIStyle.PARCHMENT)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.clip_text = true
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	line.add_child(name_label)
	line.add_child(_step_button("-", func() -> void: _remove(card)))
	var count_label: Label = UIKit.label("x%d" % count if card.is_unlimited() else editor.cap_text(card), &"", 22, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	count_label.custom_minimum_size = Vector2(52, 0)
	line.add_child(count_label)
	var plus: Button = _step_button("+", func() -> void: _add(card))
	var blocked: String = editor.why_not_add(card)
	if blocked != "":
		plus.modulate = Color(1, 1, 1, 0.45)
		plus.tooltip_text = blocked
	line.add_child(plus)
	row.mouse_entered.connect(func() -> void: _preview.show_for(row, card))
	row.mouse_exited.connect(_preview.hide_preview)
	return row


func _step_button(symbol: String, callback: Callable) -> Button:
	var button: FancyButton = FancyButton.make(symbol, &"GhostButton", Vector2(40, 32) if not _compact else Vector2(32, 28))
	button.add_theme_font_size_override("font_size", 22)
	button.pressed.connect(callback)
	return button


# ---- Actions ----------------------------------------------------------------------------


func _autofill() -> void:
	var added: int = editor.autofill_infrastructure()
	if added > 0:
		_dirty = true
		Audio.sfx(&"deck_sort")
		_say("Added %d basic infrastructure." % added)
	else:
		_say("Nothing to fill: the deck already has %d cards." % editor.deck.size())
	_refresh()


## Overnight Oct 30-31, Part 7: the cost curve and the "Paths ... / Units ... Spells ..." line under it.
func _refresh_shape() -> void:
	if _curve_chart == null:
		return
	_curve_chart.set_curve(DeckInsights.cost_curve(editor.deck.cards))
	_shape_label.text = shape_text(editor.deck.cards)
	_shape_label.tooltip_text = _shape_label.text


## "Beefcake 27, Colorless 4  |  Units 18, Spells 5, Tools 2, Traps 1, Infrastructure 19" for a deck.
static func shape_text(cards: Array[CardData]) -> String:
	var mix: Dictionary = DeckInsights.path_mix(cards)
	var paths: Array[String] = []
	for path: Affinity.Type in [Affinity.Type.BEEFCAKE, Affinity.Type.NECROCRAT, Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER, Affinity.Type.NEUTRAL]:
		if int(mix.get(int(path), 0)) > 0:
			paths.append("%s %d" % [UIStyle.affinity_name(path), int(mix[int(path)])])
	var counts: Dictionary = DeckInsights.type_counts(cards)
	var kinds: Array[String] = []
	for entry: Array in [[CardEnums.CardType.UNIT, "Units"], [CardEnums.CardType.SPELL, "Spells"], [CardEnums.CardType.TOOL, "Tools"], [CardEnums.CardType.TRAP, "Traps"], [CardEnums.CardType.WONDER, "Wonders"]]:
		var count: int = int(counts.get(int(entry[0]), 0))
		if count > 0:
			kinds.append("%s %d" % [str(entry[1]), count])
	kinds.append("Infrastructure %d" % int(counts.get("infrastructure", 0)))
	return "%s  |  %s" % [", ".join(paths) if not paths.is_empty() else "No Path yet", ", ".join(kinds)]


## Overnight Oct 30-31, Part 7: "Works well with" for the hovered card's preview, from the collection (DeckInsights.works_well_with): [] when
## nothing in the collection is a real partner.
func synergy_entries(card: CardData) -> Array[Array]:
	if card == null or card.is_infrastructure():
		return []
	var pool: Array[CardData] = []
	for owned_card: CardData in Session.profile.owned_cards:
		pool.append(owned_card)
	var partners: Array[Dictionary] = DeckInsights.works_well_with(card, pool, 3)
	if partners.is_empty():
		return []
	var parts: Array[String] = []
	for partner: Dictionary in partners:
		var other: CardData = partner["card"] as CardData
		parts.append("%s%s - %s" % [other.display_name, " (in deck)" if editor.count(other) > 0 else "", str(partner["why"])])
	return [["Works well with", "\n".join(parts)]]


## Overnight Oct 30-31, Part 7: "Suggest a deck" - pick the Path(s), get a deck built from the collection (DeckInsights.suggest) to review.
func open_suggest() -> void:
	var built: Array[Control] = _layer("SuggestLayer", "Suggest a deck", "A deck from the cards you own, within the copy caps. It replaces the deck being edited until you Reset.")
	var layer: Control = built[0]
	var column: Control = built[1]
	var options: HFlowContainer = HFlowContainer.new()
	options.add_theme_constant_override("h_separation", 12)
	options.add_theme_constant_override("v_separation", 10)
	options.custom_minimum_size = Vector2(900, 0)
	column.add_child(options)
	for choice: Array in suggest_choices():
		var paths: Array[Affinity.Type] = []
		for path: Variant in choice:
			paths.append(path as Affinity.Type)
		var names: Array[String] = []
		for path: Affinity.Type in paths:
			names.append(UIStyle.affinity_name(path))
		var button: FancyButton = FancyButton.make(" + ".join(names), &"PrimaryButton" if paths.size() == 1 else &"", Vector2(280, 56))
		button.name = "Suggest_%s" % "_".join(names)
		button.pressed.connect(func() -> void:
			_close_layer(layer)
			apply_suggestion(paths))
		options.add_child(button)
	var cancel: FancyButton = FancyButton.make("Cancel", &"GhostButton", Vector2(200, 50))
	cancel.pressed.connect(func() -> void: _close_layer(layer))
	column.add_child(cancel)
	PadFocus.register(layer)


## The Path choices offered: each Path the player owns 8+ cards of (the main Path first), then pairs with it when two Paths are allowed.
func suggest_choices() -> Array[Array]:
	var mix: Dictionary = DeckInsights.path_mix(Session.profile.owned_cards)
	var main: Affinity.Type = Session.profile.primary_affinity
	var singles: Array[Affinity.Type] = [main]
	for path: Affinity.Type in Affinity.colored_types():
		if path != main and int(mix.get(int(path), 0)) >= 8:
			singles.append(path)
	var result: Array[Array] = []
	for path: Affinity.Type in singles:
		result.append([path])
	if DeckValidator.max_colors(Session.profile, _active_modifiers()) >= 2:
		for path: Affinity.Type in singles:
			if path != main:
				result.append([main, path])
	return result


func apply_suggestion(paths: Array[Affinity.Type]) -> void:
	var suggested: Deck = DeckInsights.suggest(Session.profile.owned_cards, paths, Session.profile.level, editor.infrastructure, DeckValidator.min_deck_size(_active_modifiers()))
	suggested.deck_name = editor.deck.deck_name
	editor = DeckEditor.from(Session.profile, suggested, editor.infrastructure, _active_modifiers())
	_dirty = true
	Audio.sfx(&"deck_sort")
	_say("Suggested a %d-card deck: review it, then Save Deck (Reset goes back)." % editor.deck.size(), UIStyle.GOLD)
	_refresh()


func _reset() -> void:
	var infrastructure: Array[CardData] = editor.infrastructure
	editor = DeckEditor.from(Session.profile, _source_deck(), infrastructure, _active_modifiers())
	_dirty = false
	_refresh()


func _save() -> void:
	if _uses_deck_box():
		open_save_picker()
		return
	_write_back(editor.deck)
	_dirty = false
	Audio.sfx(&"ui_confirm")
	if editor.is_valid():
		_say("Deck saved. It is ready for the dungeon.", UIStyle.GOOD)
	else:
		_say("Deck saved, but it is not legal yet: %s" % editor.issues()[0].message, Color("ffcf70"))
	_refresh()
	EventBus.collection_changed.emit()


## Cards Oct 27, Part 3: leaving the station counts every new card as viewed (the "NEW" badges go).
func _exit_tree() -> void:
	# Fresh eyes Oct 30: the base class releases the WorldCover (3D rendering back on), pops the station's music and logs the close;
	# without it the forest stayed black after leaving the station (the critic's "Deck Station X blacks out the world").
	super._exit_tree()
	Session.mark_new_cards_viewed()


func request_close() -> void:
	# Esc closes the topmost thing first: a confirm dialog waits, then the cover picker, then save mode, then the station.
	if get_children().any(func(child: Node) -> bool: return child is ConfirmDialog):
		return
	if _cover_layer != null and is_instance_valid(_cover_layer) and not _cover_layer.is_queued_for_deletion():
		if _cover_layer.get_children().any(func(child: Node) -> bool: return child is ConfirmDialog):
			return
		_close_layer(_cover_layer)
		_cover_layer = null
		return
	if _save_mode:
		cancel_save_mode()
		_say("Save cancelled.", UIStyle.MUTED)
		return
	if _dirty:
		# UI + economy fixes Oct 22: Save / Discard / Cancel. Save writes the deck back to the slot it came from (a new deck: the empty slot
		# it was started in) and leaves.
		var dialog: ConfirmDialog = ConfirmDialog.ask_three(self, "Unsaved changes", "Save your changes to this deck before leaving the Deck Station?", "Save", "Discard", "Cancel")
		dialog.name = "ExitConfirm"
		dialog.confirmed.connect(save_and_close)
		dialog.alternative.connect(func() -> void: closed.emit())
		return
	closed.emit()


## Saves the edited deck where it belongs and closes the station (the Save choice of the unsaved-changes question).
func save_and_close() -> void:
	if _uses_deck_box():
		if not save_to_slot(_editing_slot()):
			_say("That slot is not open; the deck was not saved.", Color("ff8a85"))
			return
	else:
		_write_back(editor.deck)
		_dirty = false
		EventBus.collection_changed.emit()
	closed.emit()
