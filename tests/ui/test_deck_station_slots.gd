extends GutTest
## Overnight Oct 17, Part 4: the Deck Station opens on the Deck Box (ten slots, padlocks on the locked ones), and saving
## asks which slot.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func _station() -> DeckbuilderScreen:
	var screen: DeckbuilderScreen = DeckbuilderScreen.new()
	add_child_autofree(screen)
	return screen


func test_the_station_opens_on_ten_slots() -> void:
	var screen: DeckbuilderScreen = _station()
	await wait_process_frames(2)
	var layer: Node = screen.find_child("DeckBoxLayer", true, false)
	assert_not_null(layer, "the Deck Box is the first thing shown")
	var grid: DeckBoxGrid = layer.find_children("*", "DeckBoxGrid", true, false)[0] as DeckBoxGrid
	assert_eq(grid.tiles.size(), 10)
	assert_eq(grid.columns, 5)
	var locked: int = 0
	for tile: FancyButton in grid.tiles:
		if tile.tooltip_text.begins_with("Opens at level"):
			locked += 1
	assert_eq(locked, 6, "4 open at level 1, 6 padlocked")
	assert_eq(grid.tiles[0].focus_mode, Control.FOCUS_ALL)


func test_esc_closes_the_box_then_the_station() -> void:
	var screen: DeckbuilderScreen = _station()
	await wait_process_frames(2)
	watch_signals(screen)
	screen.request_close()
	await wait_process_frames(1)
	assert_signal_not_emitted(screen, "closed", "Esc first closes the Deck Box")
	screen.request_close()
	assert_signal_emitted(screen, "closed")


func test_save_asks_for_a_slot_and_saves_there() -> void:
	var screen: DeckbuilderScreen = _station()
	await wait_process_frames(2)
	screen.request_close()  # close the box
	await wait_process_frames(1)
	screen.call(&"_save")
	await wait_process_frames(1)
	assert_not_null(screen.find_child("SaveSlotLayer", true, false), "saving opens the slot picker")
	assert_true(screen.save_to_slot(2))
	assert_eq(Session.deck_box.size(), 2, "saved as a new deck in slot 3")
	assert_gte(Session.deck_box.index_in_slot(2), 0)
