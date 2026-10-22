extends GutTest
## UI + economy fixes Oct 22, Part 1: nothing on a full-screen menu may run off the screen at any UI scale (UiScale.fit takes only the part
## of the UI scale that still fits the content), screens inside a fitted screen are not scaled twice, and the Deck Station has a visible
## exit that asks Save / Discard / Cancel about unsaved changes.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func after_each() -> void:
	Settings.set_ui_scale(1.0)


func _scaler(screen: Control) -> UiScale:
	return screen.get_node_or_null(^"UiScaleFit") as UiScale


func test_a_screen_whose_content_fits_takes_the_whole_ui_scale() -> void:
	var screen: Control = Control.new()
	add_child_autofree(screen)
	var box: VBoxContainer = VBoxContainer.new()
	box.custom_minimum_size = Vector2(800, 500)
	screen.add_child(box)
	UiScale.fit(screen)
	Settings.set_ui_scale(1.5)
	await wait_process_frames(4)
	assert_almost_eq(_scaler(screen).current_factor(), 1.5, 0.001)


func test_a_screen_too_big_for_the_scale_takes_only_what_fits() -> void:
	var screen: Control = Control.new()
	add_child_autofree(screen)
	var box: VBoxContainer = VBoxContainer.new()
	box.custom_minimum_size = Vector2(1600, 1000)
	screen.add_child(box)
	UiScale.fit(screen)
	Settings.set_ui_scale(1.5)
	await wait_process_frames(4)
	var view: Vector2 = screen.get_viewport().get_visible_rect().size
	var factor: float = _scaler(screen).current_factor()
	assert_lt(factor, 1.5, "150 % would leave 1280x720 for a 1600x1000 screen")
	assert_lte(1000.0 * factor, view.y + 0.5, "the content's height fits the screen")
	assert_almost_eq(screen.size.y * screen.scale.y, view.y, 1.0, "the screen still covers the viewport")
	Settings.set_ui_scale(1.0)
	await wait_process_frames(4)
	assert_almost_eq(_scaler(screen).current_factor(), minf(1.0, view.y / 1000.0), 0.011, "changing the setting measures again")


func test_a_screen_inside_a_fitted_screen_is_not_scaled_twice() -> void:
	var outer: Control = Control.new()
	add_child_autofree(outer)
	UiScale.fit(outer)
	var inner: Control = Control.new()
	outer.add_child(inner)
	assert_null(UiScale.fit(inner), "the inner screen is already scaled with the outer one")


func test_the_deck_station_asks_save_discard_cancel_about_unsaved_changes() -> void:
	var screen: DeckbuilderScreen = DeckbuilderScreen.new()
	add_child_autofree(screen)
	await wait_process_frames(2)
	var close: Control = screen.get("_close_button") as Control
	assert_not_null(close, "the station has a close button")
	assert_true(close.visible)
	watch_signals(screen)
	screen.request_close()
	assert_signal_emitted(screen, "closed", "no changes: it just closes")
	var screen2: DeckbuilderScreen = DeckbuilderScreen.new()
	add_child_autofree(screen2)
	await wait_process_frames(2)
	watch_signals(screen2)
	screen2.editor.add(Session.content.infrastructure[int(Affinity.Type.BEEFCAKE)] as CardData)
	screen2.set("_dirty", true)
	screen2.request_close()
	var dialog: ConfirmDialog = screen2.find_child("ExitConfirm", true, false) as ConfirmDialog
	assert_not_null(dialog, "unsaved changes: it asks first")
	assert_signal_not_emitted(screen2, "closed")
	await wait_process_frames(1)
	assert_not_null(dialog.find_child("AlternativeButton", true, false), "three choices: Save, Discard, Cancel")
	var before: int = Session.deck_box.decks[Session.deck_box.active].card_count()
	dialog.confirmed.emit()
	assert_signal_emitted(screen2, "closed", "Save closes the station")
	assert_eq(Session.deck_box.decks[Session.deck_box.active].card_count(), before + 1, "and saved the change into the deck's own slot")


func test_discard_leaves_the_deck_as_it_was() -> void:
	var screen: DeckbuilderScreen = DeckbuilderScreen.new()
	add_child_autofree(screen)
	await wait_process_frames(2)
	watch_signals(screen)
	var before: int = Session.deck_box.decks[Session.deck_box.active].card_count()
	screen.editor.add(Session.content.infrastructure[int(Affinity.Type.BEEFCAKE)] as CardData)
	screen.set("_dirty", true)
	screen.request_close()
	var dialog: ConfirmDialog = screen.find_child("ExitConfirm", true, false) as ConfirmDialog
	dialog.alternative.emit()
	assert_signal_emitted(screen, "closed")
	assert_eq(Session.deck_box.decks[Session.deck_box.active].card_count(), before, "nothing saved")
