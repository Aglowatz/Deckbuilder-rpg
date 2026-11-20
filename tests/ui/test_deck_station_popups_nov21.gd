extends GutTest
## Fable Nov 21 (Part 3.3 and 3.4): in the Deck Station a card refused for its Path (the wrong Path for this deck, or a sealed three- or
## four-Path card) opens a pop-up with the card's name and the reason, closed with OK by mouse, keyboard or controller. Other refusals
## (a copy cap) stay a short line. The first visit with a sealed card in the collection explains the seal once.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.set_flag(&"tip_deck")
	InputDevice.set_kind(InputDevice.Kind.KEYBOARD)


func after_each() -> void:
	InputDevice.set_kind(InputDevice.Kind.KEYBOARD)


func _station() -> DeckbuilderScreen:
	var screen: DeckbuilderScreen = DeckbuilderScreen.new()
	add_child_autofree(screen)
	await wait_process_frames(4)
	for _frame: int in range(200):
		if not screen.is_building():
			break
		await wait_process_frames(1)
	await wait_process_frames(3)
	return screen


func _notice(screen: Node) -> ConfirmDialog:
	return screen.find_child("NoticeDialog", true, false) as ConfirmDialog


func _labels(root: Node) -> String:
	var words: PackedStringArray = []
	for node: Node in root.find_children("*", "Label", true, false):
		words.append((node as Label).text)
	return "\n".join(words)


func test_a_sealed_card_opens_a_popup_with_its_name_and_the_reason() -> void:
	Session.set_flag(&"tip_multi_path_locked")
	var card: CardData = Session.content.card("GRN-01")
	Session.profile.owned_cards.append(card)
	var screen: DeckbuilderScreen = await _station()
	assert_null(_notice(screen), "nothing is open before the click")
	var before: int = screen.editor.deck.size()
	screen._add(card)
	await wait_process_frames(2)
	var dialog: ConfirmDialog = _notice(screen)
	assert_not_null(dialog, "a pop-up, not a fading line")
	var text: String = _labels(dialog)
	assert_string_contains(text, card.display_name, "the card's name")
	assert_string_contains(text, "three or four Paths", "the reason")
	assert_eq(screen.editor.deck.size(), before, "the card was not added")
	assert_eq(dialog.find_children("*", "FancyButton", true, false).size(), 1, "one button: OK")
	assert_eq((dialog.find_children("*", "FancyButton", true, false)[0] as Button).text, "OK")
	watch_signals(dialog)
	(dialog.find_children("*", "FancyButton", true, false)[0] as Button).pressed.emit()
	assert_signal_emitted(dialog, "confirmed")
	await wait_process_frames(2)
	assert_null(_notice(screen), "OK closes it")


func test_a_card_of_a_path_the_deck_cannot_walk_opens_the_popup_too() -> void:
	var card: CardData = Session.content.card("N-01")
	Session.profile.owned_cards.append(card)
	var screen: DeckbuilderScreen = await _station()
	screen._add(card)
	await wait_process_frames(2)
	var dialog: ConfirmDialog = _notice(screen)
	assert_not_null(dialog)
	var text: String = _labels(dialog)
	assert_string_contains(text, card.display_name)
	assert_string_contains(text, "Necrocrat", "which Path the card is")
	assert_string_contains(text, "one Path", "and why this deck cannot take it")


func test_the_popup_closes_with_the_keyboard_and_the_controller() -> void:
	var card: CardData = Session.content.card("N-01")
	Session.profile.owned_cards.append(card)
	var screen: DeckbuilderScreen = await _station()
	for pad: bool in [false, true]:
		InputDevice.set_kind(InputDevice.Kind.PAD if pad else InputDevice.Kind.KEYBOARD)
		screen._add(card)
		await wait_process_frames(2)
		var dialog: ConfirmDialog = _notice(screen)
		assert_not_null(dialog)
		dialog._age = 1.0
		await wait_seconds(0.5)  # UiInput ignores a second Back inside its guard time
		var press: InputEvent
		if pad:
			var button: InputEventJoypadButton = InputEventJoypadButton.new()
			button.button_index = JOY_BUTTON_B  # B (back) answers a one-button notice as well as A
			button.pressed = true
			press = button
		else:
			var key: InputEventKey = InputEventKey.new()
			key.keycode = KEY_ESCAPE
			key.physical_keycode = KEY_ESCAPE
			key.pressed = true
			press = key
		dialog._unhandled_input(press)
		await wait_process_frames(2)
		assert_null(_notice(screen), "closed with %s" % ("the pad's B" if pad else "Esc"))
	screen._add(card)
	screen._add(card)
	await wait_process_frames(2)
	assert_eq(screen.find_children("NoticeDialog*", "ConfirmDialog", true, false).size(), 1, "a second click while it is open does not stack another")


func test_a_copy_cap_stays_a_short_line() -> void:
	var screen: DeckbuilderScreen = await _station()
	var capped: CardData = null
	for card: CardData in screen.editor.deck.cards:
		if not card.is_unlimited() and screen.editor.why_not_kind(card) in [DeckEditor.REFUSED_COPIES, DeckEditor.REFUSED_NOT_OWNED]:
			capped = card
			break
	assert_not_null(capped, "the starting deck holds a card at its cap or with no spare copy")
	if capped == null:
		return
	screen._add(capped)
	await wait_process_frames(2)
	assert_null(_notice(screen), "no pop-up for a copy limit")
	assert_false(screen._toast.text.is_empty(), "the short line says why")


func test_the_first_visit_with_a_sealed_card_explains_the_seal_once() -> void:
	Session.profile.owned_cards.append(Session.content.card("GRN-01"))
	var screen: DeckbuilderScreen = await _station()
	var dialog: ConfirmDialog = _notice(screen)
	assert_not_null(dialog, "the station explains it on opening")
	if dialog != null:
		assert_string_contains(_labels(dialog), MultiPathLock.RULE_TITLE)
		assert_string_contains(_labels(dialog), "three or four Paths")
	var badge: Label = screen._badges["GRN-01"] as Label
	assert_string_contains(badge.text, "Sealed", "and the card's tile says Sealed")
	screen.queue_free()
	await wait_process_frames(2)
	var again: DeckbuilderScreen = await _station()
	assert_null(_notice(again), "only once")
