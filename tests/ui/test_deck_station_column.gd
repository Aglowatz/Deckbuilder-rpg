extends GutTest
## Fable Nov 16b (Part 1): the Deck Station's "Your Deck" is a narrow column down the whole right-hand side, beside the slot racks. It
## shows most of the deck at once (one slim row per card, grouped by type with counts), has a compact header (name, slot buttons, rule
## checks, cost curve) and footer, and carries no hint or tip. The deck logic is unchanged.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.set_flag(&"tip_deck")


## A mid-game deck: about twenty different cards of every type and 18 Infrastructure.
func _big_deck() -> void:
	Session.add_xp(ProgressionTable.xp_to_reach(12) - Session.profile.xp)
	var ids: Array[String] = []
	var cards: Array[CardData] = []
	for prefix: String in ["B", "C"]:
		for number: int in range(1, 12):
			var card: CardData = Session.content.card("%s-%02d" % [prefix, number])
			if card != null and not card.is_token and Session.card_available(card):
				for _copy: int in range(mini(2, Session.copy_cap(card))):
					ids.append(card.id)
					cards.append(card)
	Session.add_cards(cards)
	for _basic: int in range(18):
		ids.append("BAS-B")
	Session.use_deck(Session.new_saved_deck("Kitchen Muscle", ids))


func _station() -> DeckbuilderScreen:
	var screen: DeckbuilderScreen = DeckbuilderScreen.new()
	add_child_autofree(screen)
	return screen


## The station once its collection tiles are all in (the list is rebuilt when the last one lands).
func _built_station() -> DeckbuilderScreen:
	var screen: DeckbuilderScreen = _station()
	await wait_process_frames(4)
	for _frame: int in range(200):
		if not screen.is_building():
			break
		await wait_process_frames(1)
	await wait_process_frames(3)
	return screen


func test_the_column_runs_the_whole_height_right_of_the_racks() -> void:
	for view: Vector2 in [Vector2(1920, 1080), Vector2(1670, 939), Vector2(1477, 831)]:
		var column: Rect2 = DeckbuilderScreen.deck_column_rect(view)
		assert_gt(column.position.x, DeckRack.cell_rect(4, view).end.x, "right of the last rack slot at %s" % view)
		assert_almost_eq(column.end.x, view.x - DeckbuilderScreen.PANEL_EDGE, 0.5)
		assert_gt(column.size.y, view.y - 20.0, "the screen's whole height at %s" % view)
		assert_between(column.size.x, DeckbuilderScreen.PANEL_MIN, DeckbuilderScreen.PANEL_MAX + 0.5, "a narrow column at %s" % view)


func test_the_list_is_grouped_by_type_with_counts() -> void:
	_big_deck()
	var groups: Array[Array] = DeckbuilderScreen.list_groups(Session.deck.cards)
	var titles: Array[String] = []
	var total: int = 0
	for group: Array in groups:
		titles.append(str(DeckbuilderScreen.LIST_GROUPS[int(group[0])][1]))
		total += int(group[1])
		var last_cost: int = -1
		for entry: Array in group[2]:
			var card: CardData = entry[0] as CardData
			assert_eq(DeckbuilderScreen.list_group(card), int(group[0]))
			assert_gte(card.energy_value(), last_cost, "%s: by cost inside the group" % titles[-1])
			last_cost = card.energy_value()
	assert_eq(total, Session.deck.cards.size(), "every copy is counted in exactly one group")
	assert_eq(titles[0], "Units")
	assert_eq(titles[-1], "Infrastructure", "Infrastructure comes last")
	assert_true(titles.has("Spells"))


func test_most_of_the_deck_shows_at_once_and_no_hint_is_left() -> void:
	_big_deck()
	var screen: DeckbuilderScreen = await _built_station()
	var panel: Control = screen.find_child("DeckPanel", true, false) as Control
	assert_not_null(panel)
	assert_eq(panel.get_parent(), screen, "the column is laid over the screen's right-hand side, not squeezed between the racks")
	assert_gt(panel.size.y, screen.size.y - 20.0)
	var scroll: ScrollContainer = panel.find_child("DeckListScroll", true, false) as ScrollContainer
	var list: VBoxContainer = panel.find_child("DeckList", true, false) as VBoxContainer
	var step: float = screen.row_height() + float(list.get_theme_constant("separation"))
	assert_gte(int(scroll.size.y / step), 20, "at least 20 rows in view (list %d px high, %d px a row)" % [int(scroll.size.y), int(step)])
	var rows: Array[Node] = list.find_children("Row_*", "PanelContainer", true, false)
	assert_gt(rows.size(), 15)
	for row: Node in rows:
		assert_not_null(row.find_child("Cost", true, false))
		assert_not_null(row.find_child("PathIcon", true, false), "%s shows a Path icon" % row.name)
		assert_not_null(row.find_child("CardName", true, false))
		assert_not_null(row.find_child("Copies", true, false))
		assert_eq((row.find_child("Minus", true, false) as Control).focus_mode, Control.FOCUS_ALL)
		assert_eq((row.find_child("Plus", true, false) as Control).focus_mode, Control.FOCUS_ALL)
	assert_null(panel.find_child("PrimmAdvice", true, false), "no Primm hint")
	assert_null(panel.find_child("DeckShape", true, false))
	for label: Node in panel.find_children("*", "Label", true, false):
		var text: String = (label as Label).text
		if not (label as Label).is_visible_in_tree():
			continue
		assert_false(text.contains("Primm") or text.begins_with("Tip") or text.contains("works well") or text.contains("Click a card"), "no hint in the column: '%s'" % text)
	assert_eq((panel.find_child("RuleChecks", true, false) as Control).get_child_count(), 3, "three rule checks")
	assert_not_null(panel.find_child("CostCurve", true, false))
	for button_name: String in ["RenameDeck", "UseDeck", "BoxCoverCard", "BoxCopy", "BoxDelete", "SaveAsNewSlot", "SuggestDeck"]:
		var button: Control = panel.find_child(button_name, true, false) as Control
		assert_not_null(button, button_name)
		assert_true(panel.get_global_rect().grow(1.0).encloses(button.get_global_rect()), "%s lies inside the column" % button_name)


func test_a_controller_walks_down_the_rows_and_reaches_the_footer() -> void:
	_big_deck()
	var screen: DeckbuilderScreen = await _built_station()
	var list: Control = screen.find_child("DeckList", true, false) as Control
	var rows: Array[Node] = list.find_children("Row_*", "PanelContainer", true, false)
	var current: Control = rows[0].find_child("Minus", true, false) as Control
	var seen: Dictionary = {}
	var reached_footer: bool = false
	for _step: int in range(rows.size() + 8):
		if list.is_ancestor_of(current):
			seen[str(current.get_meta("card_id", ""))] = true
		elif (screen.find_child("DeckButtons", true, false) as Control).is_ancestor_of(current):
			reached_footer = true
			break
		var next: Control = PadFocus.neighbor(current, Vector2.DOWN, screen)
		if next == null or next == current:
			break
		current = next
		current.grab_focus()
		await wait_process_frames(1)
	assert_eq(seen.size(), rows.size(), "down from the first row passes every row")
	assert_true(reached_footer, "and then the footer buttons")
	var plus: Control = PadFocus.neighbor(rows[0].find_child("Minus", true, false) as Control, Vector2.RIGHT, screen)
	assert_eq(plus, rows[0].find_child("Plus", true, false), "right of a row's - is its +")


func test_the_row_buttons_change_the_deck_as_before() -> void:
	_big_deck()
	var screen: DeckbuilderScreen = await _built_station()
	var list: Control = screen.find_child("DeckList", true, false) as Control
	var row: Control = list.find_children("Row_*", "PanelContainer", true, false)[0] as Control
	var card: CardData = Session.card_by_id(str(row.get_meta("card_id")))
	var before: int = screen.editor.count(card)
	(row.find_child("Minus", true, false) as Button).pressed.emit()
	await wait_process_frames(2)
	assert_eq(screen.editor.count(card), before - 1, "- takes one copy out")
	row = list.find_child("Row_%s" % card.id, true, false) as Control
	assert_not_null(row, "the row is still there with one copy fewer")
	(row.find_child("Plus", true, false) as Button).pressed.emit()
	await wait_process_frames(2)
	assert_eq(screen.editor.count(card), before, "+ puts it back")
	assert_eq(Session.deck.cards.size(), screen.editor.deck.size(), "nothing is written until Save Deck: the saved deck has the same size again")


## At a 115 % and a 130 % UI scale the station follows the scale (it was held at 100 %) and the list still shows a dozen rows or more.
func test_the_station_follows_the_ui_scale() -> void:
	_big_deck()
	for factor: float in [1.15, 1.3]:
		Settings.set_ui_scale(factor)
		var screen: DeckbuilderScreen = await _built_station()
		await wait_process_frames(6)
		var scaler: UiScale = screen.get_node_or_null(^"UiScaleFit") as UiScale
		assert_almost_eq(scaler.current_factor(), factor, 0.011, "the station is drawn at %d %%" % int(factor * 100.0))
		var panel: Control = screen.find_child("DeckPanel", true, false) as Control
		var scroll: ScrollContainer = panel.find_child("DeckListScroll", true, false) as ScrollContainer
		var list: VBoxContainer = panel.find_child("DeckList", true, false) as VBoxContainer
		var step: float = screen.row_height() + float(list.get_theme_constant("separation"))
		assert_gte(int(scroll.size.y / step), 12, "at %d %%: %d rows in view" % [int(factor * 100.0), int(scroll.size.y / step)])
		assert_lte(panel.get_global_rect().end.x, get_viewport().get_visible_rect().size.x + 1.0, "the column ends on the screen")
		assert_lte(panel.get_global_rect().end.y, get_viewport().get_visible_rect().size.y + 1.0)
		var buttons: Control = panel.find_child("DeckButtons", true, false) as Control
		assert_true(panel.get_global_rect().grow(1.0).encloses(buttons.get_global_rect()), "the footer lies inside the column")
		Settings.set_ui_scale(1.0)
		screen.queue_free()
		await wait_process_frames(2)
