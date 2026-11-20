extends GutTest
## Fable Nov 21 (Part 5.1 and 5.2): the Deck Station's Path filter is a set of toggles (as many as the deck may walk; none = every card;
## otherwise only the cards a deck of those Paths could hold; Pathless only when its own toggle is on; one too many opens a pop-up), and
## a search box matches names, card text and keywords alongside it.

const B: int = int(Affinity.Type.BEEFCAKE)
const G: int = int(Affinity.Type.GOURMAND)
const R: int = int(Affinity.Type.REFUSEMANCER)
const N: int = int(Affinity.Type.NECROCRAT)
const PATHLESS: int = int(Affinity.Type.NEUTRAL)


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.set_flag(&"tip_deck")
	CardSet.load_all()


func _bar(limit: int) -> CardFilterBar:
	var bar: CardFilterBar = CardFilterBar.new()
	bar.multi_path = true
	bar.max_paths = limit
	bar.show_search = true
	add_child_autofree(bar)
	return bar


func _card(id: String) -> CardData:
	return Session.content.card(id)


func _station() -> DeckbuilderScreen:
	var screen: DeckbuilderScreen = DeckbuilderScreen.new()
	add_child_autofree(screen)
	await wait_process_frames(4)
	for _frame: int in range(300):
		if not screen.is_building():
			break
		await wait_process_frames(1)
	await wait_process_frames(3)
	return screen


func _shown(screen: DeckbuilderScreen) -> Array[String]:
	var ids: Array[String] = []
	for tile: Node in screen._grid.get_children():
		if (tile as Control).visible:
			ids.append(str(tile.get_meta("card_id")))
	return ids


# ---- 5.1 the Path toggles ---------------------------------------------------------------------------------------------------------------


func test_no_toggle_shows_every_card() -> void:
	var bar: CardFilterBar = _bar(2)
	for id: String in ["B-25", "N-01", "NB-04", "C-01", "GRN-01", "P4-02"]:
		assert_true(bar.matches(_card(id)), id)


func test_one_path_shows_only_that_paths_own_cards() -> void:
	var bar: CardFilterBar = _bar(2)
	assert_true(bar.toggle_path(B))
	assert_true(bar.matches(_card("B-25")), "a Beefcake card")
	assert_false(bar.matches(_card("N-01")), "another Path's card")
	assert_false(bar.matches(_card("NB-04")), "a Necrocrat / Beefcake card needs both Paths: a Beefcake-only deck could not hold it")
	assert_false(bar.matches(_card("C-01")), "Pathless cards only when the Pathless toggle is on")
	assert_true(bar.matches(Session.content.infrastructure[B] as CardData), "the Path's own basic Infrastructure")
	assert_false(bar.matches(Session.content.infrastructure[N] as CardData))


func test_two_paths_show_what_a_deck_of_those_two_could_use() -> void:
	var bar: CardFilterBar = _bar(2)
	bar.toggle_path(B)
	bar.toggle_path(N)
	assert_true(bar.matches(_card("B-25")))
	assert_true(bar.matches(_card("N-01")))
	assert_true(bar.matches(_card("NB-04")), "the two-Path card of exactly these Paths")
	assert_false(bar.matches(_card("GB-13")), "Gourmand / Beefcake: Gourmand is not switched on")
	assert_false(bar.matches(_card("GRN-01")), "a three-Path card")
	assert_false(bar.matches(_card("C-01")), "still no Pathless cards")


func test_pathless_cards_show_only_when_tagged() -> void:
	var bar: CardFilterBar = _bar(2)
	bar.toggle_path(PATHLESS)
	assert_true(bar.pathless_selected)
	assert_true(bar.matches(_card("C-01")))
	assert_false(bar.matches(_card("B-25")), "only Pathless is on: only Pathless cards")
	bar.toggle_path(B)
	assert_true(bar.matches(_card("C-01")))
	assert_true(bar.matches(_card("B-25")), "Pathless and Beefcake together")
	bar.toggle_path(PATHLESS)
	assert_false(bar.matches(_card("C-01")), "switched off again")


func test_pathless_does_not_count_toward_the_limit() -> void:
	var bar: CardFilterBar = _bar(1)
	assert_true(bar.toggle_path(PATHLESS))
	assert_true(bar.toggle_path(B), "one Path besides Pathless")
	assert_eq(bar.selected_paths, [B] as Array[int])


func test_one_path_too_many_is_refused_and_says_so() -> void:
	var bar: CardFilterBar = _bar(1)
	watch_signals(bar)
	assert_true(bar.toggle_path(B))
	assert_false(bar.toggle_path(N), "the deck may walk one Path")
	assert_signal_emitted_with_parameters(bar, "path_refused", [1])
	assert_eq(bar.selected_paths, [B] as Array[int], "the selection is unchanged")
	assert_false(bar.matches(_card("N-01")))
	assert_true(bar.toggle_path(B), "switching one off...")
	assert_true(bar.toggle_path(N), "...makes room for another")
	assert_eq(bar.selected_paths, [N] as Array[int])


func test_all_paths_clears_the_toggles_and_the_chips_follow() -> void:
	var bar: CardFilterBar = _bar(3)
	bar.toggle_path(G)
	bar.toggle_path(R)
	bar.toggle_path(N)
	assert_true(bar.matches(_card("GRN-01")), "with three Paths allowed and on, a three-Path card of them shows")
	var pressed: int = 0
	for entry: Dictionary in bar._groups[0]:
		if (entry["button"] as Button).button_pressed:
			pressed += 1
	assert_eq(pressed, 3, "three chips are lit")
	bar.toggle_path(-1)
	assert_eq(bar.selected_paths.size(), 0)
	assert_true(bar.matches(_card("B-25")), "everything again")
	for entry: Dictionary in bar._groups[0]:
		assert_eq((entry["button"] as Button).button_pressed, int(entry["value"]) == -1, "only 'All Paths' is lit")


# ---- 5.2 the search box ---------------------------------------------------------------------------------------------------------------


func test_search_matches_names_text_and_keywords() -> void:
	var bar: CardFilterBar = _bar(2)
	bar.set_search("yeet")
	assert_true(bar.matches(_card("B-25")), "by name")
	assert_false(bar.matches(_card("N-01")))
	bar.set_search("Reinstate")
	assert_true(bar.matches(_card("NB-03")), "by a word of the card's text (Vigor Mortis reinstates)")
	assert_false(bar.matches(_card("B-25")))
	for word: String in ["hustle", "swat", "toxic", "flying", "bulldoze"]:
		bar.set_search(word)
		var keyword: int = CardEnums.Keyword.keys().find(word.to_upper())
		var found: int = 0
		for id: Variant in Session.content.cards.keys():
			var card: CardData = Session.content.cards[id] as CardData
			if card.keywords.has(keyword as CardEnums.Keyword):
				found += 1
				assert_true(bar.matches(card), "%s has %s" % [id, word])
		assert_gt(found, 0, "some card has %s" % word)
	bar.set_search("")
	assert_true(bar.matches(_card("N-01")), "an empty box matches everything")


func test_search_needs_every_word_and_works_beside_the_path_filter() -> void:
	var bar: CardFilterBar = _bar(2)
	bar.set_search("toro toro")
	assert_true(bar.matches(_card("G-27")))
	bar.set_search("bulldoze swat")
	assert_true(bar.matches(_card("G-27")), "Toro Toro has both keywords")
	bar.set_search("bulldoze zzzz")
	assert_false(bar.matches(_card("G-27")), "every word must be found")
	bar.set_search("bulldoze")
	bar.toggle_path(B)
	assert_false(bar.matches(_card("G-27")), "a Gourmand card is hidden by the Beefcake toggle even when the search finds it")
	bar.set_search("unit")
	assert_true(bar.matches(_card("B-34")), "the card's type is searched too")


# ---- in the Deck Station ------------------------------------------------------------------------------------------------------------------


func test_the_station_uses_the_toggles_with_the_decks_own_limit() -> void:
	var screen: DeckbuilderScreen = await _station()
	assert_true(screen._filter.multi_path)
	assert_true(screen._filter.show_search)
	assert_not_null(screen._filter.search_box, "the search box is there")
	assert_eq(screen._filter.max_paths, 1, "a new hero walks one Path")
	var everything: int = _shown(screen).size()
	assert_gt(everything, 10)
	screen._filter.toggle_path(B)
	await wait_process_frames(2)
	var beefcake: Array[String] = _shown(screen)
	assert_lt(beefcake.size(), everything, "fewer tiles")
	for id: String in beefcake:
		var card: CardData = Session.content.card(id) if Session.content.card(id) != null else Session.content.infrastructure[B] as CardData
		assert_true(screen._filter.matches_paths(card), "%s is a Beefcake card" % id)


func test_one_path_too_many_opens_a_popup_in_the_station() -> void:
	var screen: DeckbuilderScreen = await _station()
	screen._filter.toggle_path(B)
	screen._filter.toggle_path(N)
	await wait_process_frames(2)
	var dialog: ConfirmDialog = screen.find_child("NoticeDialog", true, false) as ConfirmDialog
	assert_not_null(dialog, "a pop-up, not a silent refusal")
	if dialog == null:
		return
	var words: PackedStringArray = []
	for node: Node in dialog.find_children("*", "Label", true, false):
		words.append((node as Label).text)
	assert_string_contains("\n".join(words), "Too many Paths")
	assert_string_contains("\n".join(words), "one Path")
	assert_eq(dialog.find_children("*", "FancyButton", true, false).size(), 1, "one OK button")


func test_after_a_zone_is_freed_two_paths_may_be_on() -> void:
	Session.profile.zones_freed = 1
	var screen: DeckbuilderScreen = await _station()
	assert_eq(screen._filter.max_paths, 2)
	assert_true(screen._filter.toggle_path(B))
	assert_true(screen._filter.toggle_path(N))
	assert_false(screen._filter.toggle_path(G))


func test_typing_in_the_search_box_filters_the_tiles() -> void:
	var screen: DeckbuilderScreen = await _station()
	var everything: int = _shown(screen).size()
	screen._filter.search_box.text = "militia"
	screen._filter.search_box.text_changed.emit("militia")
	await wait_process_frames(2)
	var found: Array[String] = _shown(screen)
	assert_between(found.size(), 1, everything - 1, "only the matching cards stay")
	for id: String in found:
		assert_string_contains(CardFilterBar.search_haystack(Session.content.card(id)), "militia")
	screen._filter.search_box.text = ""
	screen._filter.search_box.text_changed.emit("")
	await wait_process_frames(2)
	assert_eq(_shown(screen).size(), everything, "clearing it brings them back")
