class_name DeckbuilderScreen
extends OverlayScreen
## The Deck Station: browse the collection with filters, click to add a card to the deck
## (right-click to remove), see the deck list with counts and live validation of the deck
## rules (45 cards minimum, 4 copies, 2 colors - 3 or 4 once Primm is beaten and the postgame is unlocked), then save.

const CARD_SCALE: float = 0.55
const COLUMNS: int = 7

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
var _deck_picker: OptionButton
var _warning_label: Label
var _use_button: FancyButton
var _delete_button: FancyButton
var _copy_button: FancyButton
var _new_button: FancyButton
var _prompt_layer: Control


func _init() -> void:
	screen_title = "Deck Station"
	close_text = "Close (Esc)"
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


func _build() -> void:
	_editing = Session.deck_box.active
	var infrastructure: Array[CardData] = []
	for color: Affinity.Type in Affinity.colored_types():
		infrastructure.append(Session.content.infrastructure[int(color)] as CardData)
	editor = DeckEditor.from(Session.profile, _source_deck(), infrastructure, _active_modifiers())
	_preview = HoverPreview.new()
	add_child(_preview)
	var split: HBoxContainer = UIKit.hbox(22)
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(split)
	var left: VBoxContainer = UIKit.vbox(10)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split.add_child(left)
	_filter = CardFilterBar.new()
	_filter.changed.connect(_apply_filter)
	left.add_child(_filter)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	left.add_child(scroll)
	_grid = GridContainer.new()
	_grid.columns = COLUMNS
	_grid.add_theme_constant_override("h_separation", 10)
	_grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(_grid)
	_fill_grid()
	split.add_child(_build_deck_panel())
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
	var min_size: int = DeckValidator.min_deck_size(_active_modifiers())
	TipPanel.show_once(self, &"tip_deck", "Building a deck", "Click a card to add it, right-click (or the [b]-[/b] button) to remove it. A legal deck has [b]%d+ cards[/b], at most [b]%d colors[/b], and a rarity-based copy limit that grows as you level up. Infrastructure attack your spells: [b]Fill Infrastructure[/b] tops up to %d." % [min_size, DeckValidator.max_colors(Session.profile, _active_modifiers()), min_size], Vector2(300, 900))


func _build_deck_panel() -> Control:
	var panel: PanelContainer = UIKit.panel()
	panel.custom_minimum_size = Vector2(590, 0)
	var column: VBoxContainer = UIKit.vbox(10)
	panel.add_child(column)
	column.add_child(UIKit.label("Your Deck", &"HeadingLabel", 30))
	if _uses_deck_box():
		column.add_child(_build_deck_bar())
	_count_label = UIKit.label("", &"", 24, UIStyle.PARCHMENT)
	column.add_child(_count_label)
	_rules_box = UIKit.vbox(2)
	column.add_child(_rules_box)
	_warning_label = UIKit.label("", &"", 19, Color("ffb066"))
	_warning_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_warning_label.custom_minimum_size = Vector2(540, 0)
	column.add_child(_warning_label)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var frame: PanelContainer = UIKit.panel(&"DarkPanel")
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.add_child(scroll)
	column.add_child(frame)
	_list_box = UIKit.vbox(3)
	_list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_list_box)
	var buttons: HBoxContainer = UIKit.hbox(10)
	column.add_child(buttons)
	_save_button = FancyButton.make("Save Deck", &"PrimaryButton", Vector2(190, 54))
	_save_button.pressed.connect(_save)
	buttons.add_child(_save_button)
	var fill: FancyButton = FancyButton.make("Fill Infrastructure", &"", Vector2(150, 54))
	fill.tooltip_text = "Adds basic infrastructure of your deck's colors until the deck reaches the minimum size."
	fill.pressed.connect(_autofill)
	buttons.add_child(fill)
	var reset: FancyButton = FancyButton.make("Reset", &"", Vector2(120, 54))
	reset.tooltip_text = "Go back to the saved deck."
	reset.pressed.connect(_reset)
	buttons.add_child(reset)
	return panel


# ---- Saved decks (brief 16, Group E) --------------------------------------------------------


func _build_deck_bar() -> Control:
	var bar: VBoxContainer = UIKit.vbox(6)
	bar.name = "DeckBar"
	var top: HBoxContainer = UIKit.hbox(8)
	bar.add_child(top)
	_deck_picker = OptionButton.new()
	_deck_picker.name = "DeckPicker"
	_deck_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_deck_picker.custom_minimum_size = Vector2(0, 44)
	_deck_picker.add_theme_font_size_override("font_size", 22)
	_deck_picker.item_selected.connect(_on_deck_picked)
	top.add_child(_deck_picker)
	var row: HBoxContainer = UIKit.hbox(6)
	bar.add_child(row)
	_new_button = _bar_button("New", "Start an empty deck in the next free slot.", _on_new_deck)
	_new_button.name = "NewDeck"
	row.add_child(_new_button)
	_copy_button = _bar_button("Copy", "Duplicate the saved version of this deck.", _on_copy_deck)
	_copy_button.name = "CopyDeck"
	row.add_child(_copy_button)
	var rename: FancyButton = _bar_button("Rename", "Give this deck another name.", _on_rename_deck)
	rename.name = "RenameDeck"
	row.add_child(rename)
	_delete_button = _bar_button("Delete", "Delete this deck (you always keep at least one).", _on_delete_deck)
	_delete_button.name = "DeleteDeck"
	row.add_child(_delete_button)
	_use_button = _bar_button("Use for battles", "Make this the deck battles and dungeons use.", _on_use_deck)
	_use_button.name = "UseDeck"
	row.add_child(_use_button)
	return bar


func _bar_button(text: String, tip: String, callback: Callable) -> FancyButton:
	var button: FancyButton = FancyButton.make(text, &"GhostButton", Vector2(0, 40))
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.tooltip_text = tip
	button.add_theme_font_size_override("font_size", 19)
	button.pressed.connect(callback)
	return button


func _refresh_deck_bar() -> void:
	if _warning_label != null:
		var lines: Array[String] = []
		if _uses_deck_box():
			lines = Session.deck_warnings(_editing)
		_warning_label.text = "" if lines.is_empty() else "Warning: %s" % " ".join(lines)
		_warning_label.visible = not lines.is_empty()
	if _deck_picker == null:
		return
	_deck_picker.clear()
	for index: int in range(Session.deck_box.size()):
		var saved: DeckBox.SavedDeck = Session.deck_box.decks[index]
		var label: String = "%d. %s (%d)" % [index + 1, saved.name, saved.card_count()]
		if index == Session.deck_box.active:
			label += "   [in use]"
		if not Session.deck_warnings(index).is_empty():
			label += "   [!]"
		_deck_picker.add_item(label, index)
	_deck_picker.select(_editing)
	var capacity: int = Session.deck_capacity()
	_new_button.disabled = Session.deck_box.is_full(capacity)
	_copy_button.disabled = Session.deck_box.is_full(capacity)
	_new_button.tooltip_text = "Your deck box is full (%d decks)." % capacity if _new_button.disabled else "Start an empty deck in the next free slot."
	_delete_button.disabled = Session.deck_box.size() <= 1
	_use_button.disabled = _editing == Session.deck_box.active
	_use_button.text = "In use" if _use_button.disabled else "Use for battles"


## Editing another deck; unsaved changes to this one have to be kept or thrown away first.
func _on_deck_picked(position: int) -> void:
	var target: int = _deck_picker.get_item_id(position)
	if target == _editing:
		return
	if _dirty:
		_deck_picker.select(_editing)
		var dialog: ConfirmDialog = ConfirmDialog.ask(self, "Unsaved changes", "Switch decks without saving your changes to this one?", "Discard changes", "Keep editing", true)
		dialog.confirmed.connect(func() -> void: _edit_deck(target))
		return
	_edit_deck(target)


func _edit_deck(index: int) -> void:
	_editing = index
	var infrastructure: Array[CardData] = editor.infrastructure
	editor = DeckEditor.from(Session.profile, _source_deck(), infrastructure, _active_modifiers())
	_dirty = false
	_refresh()


func _on_new_deck() -> void:
	if _dirty:
		_say("Save or reset this deck first.", Color("ffcf70"))
		return
	var index: int = Session.new_saved_deck("New Deck %d" % (Session.deck_box.size() + 1))
	if index < 0:
		_say("Your deck box is full (%d decks)." % Session.deck_capacity(), Color("ff8a85"))
		return
	_edit_deck(index)
	_say("A new empty deck. Add cards, then Save Deck.", UIStyle.GOOD)


func _on_copy_deck() -> void:
	var index: int = Session.duplicate_saved_deck(_editing)
	if index < 0:
		_say("Your deck box is full (%d decks)." % Session.deck_capacity(), Color("ff8a85"))
		return
	if _dirty:
		_say("Copied the saved version (your unsaved changes were not included).", Color("ffcf70"))
	else:
		_say("Deck copied.", UIStyle.GOOD)
	_edit_deck(index)


func _on_rename_deck() -> void:
	_prompt_name("Rename deck", Session.deck_box.decks[_editing].name, func(new_name: String) -> void:
		Session.rename_saved_deck(_editing, new_name)
		_refresh())


func _on_delete_deck() -> void:
	if Session.deck_box.size() <= 1:
		_say("You always keep at least one deck.", Color("ffcf70"))
		return
	var doomed: int = _editing
	var dialog: ConfirmDialog = ConfirmDialog.ask(self, "Delete this deck?", "\"%s\" will be deleted. Your cards stay in your collection." % Session.deck_box.decks[doomed].name, "Delete", "Cancel", true)
	dialog.confirmed.connect(func() -> void:
		Session.delete_saved_deck(doomed)
		_edit_deck(clampi(doomed, 0, Session.deck_box.size() - 1))
		_say("Deck deleted.", UIStyle.GOOD))


func _on_use_deck() -> void:
	if _dirty:
		_say("Save this deck first.", Color("ffcf70"))
		return
	if Session.use_deck(_editing):
		Audio.sfx(&"ui_confirm")
		_say("\"%s\" is now your battle deck." % Session.deck_box.decks[_editing].name, UIStyle.GOOD)
		_refresh()
		EventBus.collection_changed.emit()


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


func _fill_grid() -> void:
	for card: CardData in _collection():
		_cards_by_id[card.id] = card
		_grid.add_child(_make_tile(card))


func _make_tile(card: CardData) -> Control:
	var holder: Control = Control.new()
	holder.custom_minimum_size = CardView.SIZE * CARD_SCALE + Vector2(0, 30)
	holder.set_meta("card_id", card.id)
	var view: CardView = CardView.create(card, CardView.Mode.FULL)
	holder.add_child(view)
	CardView.fit(view, CARD_SCALE)
	view.gui_event.connect(func(_v: CardView, event: InputEvent) -> void: _on_tile_input(card, event))
	view.hovered.connect(func(_v: CardView) -> void:
		_preview.show_for(holder, card)
		Audio.sfx(&"card_hover", -14.0))
	view.unhovered.connect(func(_v: CardView) -> void: _preview.hide_preview())
	var badge: Label = UIKit.label("", &"", 19, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	badge.add_theme_font_override("font", UIStyle.font_bold())
	badge.add_theme_font_size_override("font_size", 18)
	badge.add_theme_stylebox_override("normal", UIStyle.box(Color(0.04, 0.02, 0.08, 0.92), UIStyle.GOLD_DIM, 2, 12))
	badge.position = Vector2(8, CardView.SIZE.y * CARD_SCALE + 4.0)
	badge.size = Vector2(CardView.SIZE.x * CARD_SCALE - 16.0, 26)
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
	Audio.sfx(&"card_play", -6.0)
	_refresh()


func _remove(card: CardData) -> void:
	if editor.remove(card):
		_dirty = true
		Audio.sfx(&"card_discard", -6.0)
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
			label.text = "Deck %d  Own %d" % [in_deck, editor.owned(card)]
		var view: CardView = _dim_by_id[id] as CardView
		view.modulate = Color(1, 1, 1, 1) if in_deck > 0 or card.is_basic else Color(0.82, 0.82, 0.86, 1)
	_rebuild_list()
	_rebuild_rules()
	var size: int = editor.deck.size()
	_count_label.text = "%d cards  -  %d infrastructure, %d spells" % [size, editor.infrastructure_count(), size - editor.infrastructure_count()]
	_save_button.text = "Save Deck" if _dirty else "Saved"
	_save_button.disabled = not _dirty
	_refresh_deck_bar()


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
	_rule_row(not DeckValidator.has_problem(issues, DeckValidator.Problem.TOO_MANY_COPIES), "At most %d copies of each card (infrastructure is unlimited)" % DeckValidator.MAX_COPIES)
	_rule_row(not DeckValidator.has_problem(issues, DeckValidator.Problem.TOO_MANY_COLORS), "At most %d Path%s (%s)" % [limit, "" if limit == 1 else "s", ", ".join(color_names) if not color_names.is_empty() else "none yet"])
	if DeckValidator.has_problem(issues, DeckValidator.Problem.NOT_OWNED):
		_rule_row(false, "You use cards you do not own")


func _rule_row(ok: bool, text: String) -> void:
	var row: HBoxContainer = UIKit.hbox(10)
	var dot: Panel = Panel.new()
	dot.custom_minimum_size = Vector2(16, 16)
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	dot.add_theme_stylebox_override("panel", UIStyle.box(UIStyle.GOOD if ok else UIStyle.DANGER, Color(0, 0, 0, 0.4), 2, 8))
	row.add_child(dot)
	row.add_child(UIKit.label(text, &"", 20, UIStyle.PARCHMENT if ok else Color("ff9d98")))
	_rules_box.add_child(row)


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
	var cost: Label = UIKit.label("" if card.is_infrastructure() else str(card.energy_value()), &"", 20, UIStyle.INK, HORIZONTAL_ALIGNMENT_CENTER)
	cost.custom_minimum_size = Vector2(30, 28)
	cost.add_theme_stylebox_override("normal", UIStyle.box(Color("cdc5d6") if not card.is_infrastructure() else Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0, 14))
	cost.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	line.add_child(cost)
	var name_label: Label = UIKit.label("%s Infrastructure" % UIStyle.affinity_name(card.color) if card.is_infrastructure() else card.display_name, &"", 22, UIStyle.PARCHMENT)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.add_child(name_label)
	line.add_child(_step_button("-", func() -> void: _remove(card)))
	var count_label: Label = UIKit.label("x%d" % count, &"", 22, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	count_label.custom_minimum_size = Vector2(44, 0)
	line.add_child(count_label)
	line.add_child(_step_button("+", func() -> void: _add(card)))
	row.mouse_entered.connect(func() -> void: _preview.show_for(row, card))
	row.mouse_exited.connect(_preview.hide_preview)
	return row


func _step_button(symbol: String, callback: Callable) -> Button:
	var button: FancyButton = FancyButton.make(symbol, &"GhostButton", Vector2(40, 32))
	button.add_theme_font_size_override("font_size", 22)
	button.pressed.connect(callback)
	return button


# ---- Actions ----------------------------------------------------------------------------


func _autofill() -> void:
	var added: int = editor.autofill_infrastructure()
	if added > 0:
		_dirty = true
		Audio.sfx(&"card_shuffle", -6.0)
		_say("Added %d basic infrastructure." % added)
	else:
		_say("Nothing to fill: the deck already has %d cards." % editor.deck.size())
	_refresh()


func _reset() -> void:
	var infrastructure: Array[CardData] = editor.infrastructure
	editor = DeckEditor.from(Session.profile, _source_deck(), infrastructure, _active_modifiers())
	_dirty = false
	_refresh()


func _save() -> void:
	_write_back(editor.deck)
	_dirty = false
	Audio.sfx(&"ui_confirm")
	if editor.is_valid():
		_say("Deck saved. It is ready for the dungeon.", UIStyle.GOOD)
	else:
		_say("Deck saved, but it is not legal yet: %s" % editor.issues()[0].message, Color("ffcf70"))
	_refresh()
	EventBus.collection_changed.emit()


func request_close() -> void:
	if _dirty:
		var dialog: ConfirmDialog = ConfirmDialog.ask(self, "Unsaved changes", "Leave the Deck Station without saving your changes?", "Discard changes", "Keep editing", true)
		dialog.confirmed.connect(func() -> void: closed.emit())
		return
	closed.emit()
