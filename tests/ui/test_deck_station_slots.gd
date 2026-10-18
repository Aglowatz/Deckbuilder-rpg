extends GutTest
## Playtest v0.4.0 Part F (was Overnight Oct 17, Part 4): the Deck Station's ten saved-deck slots are the racks painted into the top and
## the bottom of the screen (`DeckRack`): 4 open at the start, padlocks with the level on the rest, a cover card and Path icons on a
## saved deck, click to open a deck, and saving asks which slot by lighting the racks up (with an overwrite confirm).


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func _station() -> DeckbuilderScreen:
	var screen: DeckbuilderScreen = DeckbuilderScreen.new()
	add_child_autofree(screen)
	return screen


func test_the_station_shows_ten_rack_slots_five_top_five_bottom() -> void:
	var screen: DeckbuilderScreen = _station()
	await wait_process_frames(2)
	var rack: DeckRack = screen.find_child("DeckRack", true, false) as DeckRack
	assert_not_null(rack, "the racks are part of the station itself")
	assert_null(screen.find_child("DeckBoxLayer", true, false), "no separate Deck Box screen any more")
	assert_eq(rack.tiles.size(), 10)
	var locked: int = 0
	for tile: FancyButton in rack.tiles:
		if tile.tooltip_text.begins_with("Opens at level"):
			locked += 1
	assert_eq(locked, 6, "4 open at level 1, 6 padlocked")
	assert_eq(rack.tiles[0].focus_mode, Control.FOCUS_ALL)
	var view: Vector2 = rack.canvas
	for slot: int in range(5):
		assert_lt(rack.tiles[slot].position.y, view.y * 0.25, "slot %d sits in the top rack" % (slot + 1))
		assert_gt(rack.tiles[slot + 5].position.y, view.y * 0.7, "slot %d sits in the bottom rack" % (slot + 6))
	for slot: int in range(1, 5):
		assert_gt(rack.tiles[slot].position.x, rack.tiles[slot - 1].position.x, "the top rack runs left to right")
	assert_true(rack.tiles[0].tooltip_text.contains("Wanderer's Deck"), "the starter deck sits in slot 1 with its name")
	assert_true(rack.tiles[1].tooltip_text.begins_with("An empty slot"), "slot 2 is empty and open")
	assert_eq(rack.tiles[6].tooltip_text, "Opens at level 14.")


func test_the_slots_follow_the_deck_slot_unlocks() -> void:
	Session.add_xp(ProgressionTable.xp_to_reach(7) - Session.profile.xp)
	var screen: DeckbuilderScreen = _station()
	await wait_process_frames(2)
	var rack: DeckRack = screen.find_child("DeckRack", true, false) as DeckRack
	var locked: int = 0
	for tile: FancyButton in rack.tiles:
		if tile.tooltip_text.begins_with("Opens at level"):
			locked += 1
	assert_eq(locked, 4, "level 7 opens two more slots (6 open)")


func test_esc_leaves_save_mode_then_closes_the_station() -> void:
	var screen: DeckbuilderScreen = _station()
	await wait_process_frames(2)
	watch_signals(screen)
	screen.call(&"_save")
	await wait_process_frames(1)
	assert_true(screen.in_save_mode(), "Save Deck lights the racks up")
	screen.request_close()
	await wait_process_frames(1)
	assert_false(screen.in_save_mode(), "Esc first leaves save mode")
	assert_signal_not_emitted(screen, "closed")
	screen.request_close()
	assert_signal_emitted(screen, "closed")


func test_save_asks_for_a_slot_and_saves_there() -> void:
	var screen: DeckbuilderScreen = _station()
	await wait_process_frames(2)
	screen.call(&"_save")
	await wait_process_frames(1)
	assert_true(screen.in_save_mode(), "saving asks which slot")
	var rack: DeckRack = screen.find_child("DeckRack", true, false) as DeckRack
	assert_true(rack.tiles[1].tooltip_text.begins_with("Save the deck into slot 2"), "an empty slot offers to take the deck")
	assert_true(screen.save_to_slot(2))
	assert_false(screen.in_save_mode())
	assert_eq(Session.deck_box.size(), 2, "saved as a new deck in slot 3")
	assert_gte(Session.deck_box.index_in_slot(2), 0)
	await wait_process_frames(1)
	assert_true(rack.tiles[2].tooltip_text.contains("cards"), "slot 3 now shows the saved deck")


func test_clicking_a_slot_opens_that_deck_and_an_empty_slot_starts_a_new_one() -> void:
	Session.new_saved_deck("Second", ["BAS-B", "BAS-B", "B-01"] as Array[String])
	var screen: DeckbuilderScreen = _station()
	await wait_process_frames(2)
	var rack: DeckRack = screen.find_child("DeckRack", true, false) as DeckRack
	rack.slot_pressed.emit(1)
	await wait_process_frames(1)
	assert_eq(screen.editor.deck.size(), 3, "slot 2 opened the second deck")
	rack.slot_pressed.emit(2)
	await wait_process_frames(1)
	assert_eq(screen.editor.deck.size(), 0, "an empty open slot starts a new deck")
	rack.slot_pressed.emit(9)
	await wait_process_frames(1)
	assert_eq(screen.editor.deck.size(), 0, "a locked slot does nothing")
