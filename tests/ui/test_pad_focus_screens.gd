extends GutTest
## Controller support (Oct 26): every menu can be driven by a pad alone. For each screen: the first focus lands inside it (not on the screen
## below), and walking the focus graph from there with the D-pad (and Tab order) reaches every visible, enabled button and pad-clickable card -
## nothing is reachable only by the mouse. The screens: Settings (every page), the Deck Station, Sable's shop, the item and equipment vendors,
## the Collection Book and the Bestiary, the Character screen (equipment), the save slots, the Quest Log, the Packs screen, the pause menu.

func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game()
	Keybinds.reset_all()
	InputDevice.set_kind(InputDevice.Kind.PAD)


func after_each() -> void:
	InputDevice.set_kind(InputDevice.Kind.KEYBOARD)


## The controls a pad must be able to reach under `root`.
func _targets(root: Control) -> Array[Control]:
	var result: Array[Control] = []
	for node: Node in root.find_children("*", "Control", true, false):
		var control: Control = node as Control
		if not control.is_visible_in_tree() or control.mouse_filter == Control.MOUSE_FILTER_IGNORE:
			continue
		if control is BaseButton and (control as BaseButton).disabled:
			continue
		# Every button the mouse can click counts, focusable or not (a pad press makes a screen's buttons focusable); sliders and cards too.
		if control is BaseButton or control.is_in_group(PadClick.GROUP) or (control is Range and not control is ScrollBar and not control is ProgressBar):
			result.append(control)
	return result


## Every control the pad's D-pad can reach from `start` (`PadFocus.neighbor`, the four directions), staying inside `root`.
func _reachable(root: Control, start: Control) -> Dictionary:
	var seen: Dictionary = {start: true}
	var queue: Array[Control] = [start]
	while not queue.is_empty():
		var here: Control = queue.pop_front()
		var nexts: Array[Control] = []
		for direction: Vector2 in [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]:
			nexts.append(PadFocus.neighbor(here, direction, root))
		for next: Control in nexts:
			if next != null and not seen.has(next) and root.is_ancestor_of(next):
				seen[next] = true
				queue.append(next)
	return seen


func _check_screen(root: Control, what: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var first: Control = PadFocus.focus_into(root) if get_viewport().gui_get_focus_owner() == null or not root.is_ancestor_of(get_viewport().gui_get_focus_owner()) else get_viewport().gui_get_focus_owner()
	assert_not_null(first, "%s: something takes the focus" % what)
	if first == null:
		return
	assert_true(root.is_ancestor_of(first), "%s: the first focus is inside the screen" % what)
	UiInput.make_focusable(root)
	var seen: Dictionary = _reachable(root, first)
	var missing: PackedStringArray = []
	for control: Control in _targets(root):
		if not seen.has(control):
			missing.append("%s '%s'" % [control.name, str(control.get("text")) if control.get("text") != null else ""])
	print("pad-walk %s: %d targets, %d reached" % [what, _targets(root).size(), seen.size()])
	assert_eq(missing.size(), 0, "%s: reachable with the pad (%d controls); missing: %s" % [what, seen.size(), ", ".join(missing)])


func _overlay(screen: OverlayScreen, what: String) -> void:
	add_child_autofree(screen)
	await _check_screen(screen, what)


func test_settings_pages() -> void:
	for page: int in range(SettingsPanel.PAGES.size()):
		var panel: SettingsPanel = SettingsPanel.new()
		panel.autosave = false
		add_child_autofree(panel)
		PadFocus.register(panel)
		panel.show_page(page)
		await _check_screen(panel, "Settings %s" % SettingsPanel.PAGES[page])
		panel.queue_free()
		await get_tree().process_frame


func test_deck_station() -> void:
	await _overlay(DeckbuilderScreen.new(), "Deck Station")


func test_card_vendor() -> void:
	var screen: VendorScreen = VendorScreen.new()
	screen.pack_vendor_id = PackData.VENDOR_CARD
	screen.pack_story_prefix = "pack.card_vendor"
	screen.vendor_screen_id = "VS-SABLE"
	await _overlay(screen, "Sable's shop")


func test_item_vendor() -> void:
	await _overlay(ItemVendorScreen.new(), "Item vendor")


func test_equipment_vendor() -> void:
	await _overlay(EquipmentVendorScreen.new(), "Equipment vendor")


func test_collection_book_and_bestiary() -> void:
	var codex: CodexScreen = CodexScreen.new()
	add_child_autofree(codex)
	await _check_screen(codex, "Collection Book")
	codex.show_tab("Bestiary")
	await _check_screen(codex, "Bestiary")


func test_character_screen() -> void:
	await _overlay(CharacterScreen.new(), "Character / equipment")


func test_quest_log() -> void:
	await _overlay(QuestLogScreen.new(), "Quest Log")


func test_packs_screen() -> void:
	Session.add_pack(PackRules.GENERAL_1_ID, 1)
	await _overlay(PacksScreen.new(), "Packs")


func test_save_slots() -> void:
	var slots: SaveSlotsScreen = SaveSlotsScreen.make(SaveSlotsScreen.Mode.LOAD, null)
	add_child_autofree(slots)
	await _check_screen(slots, "Save slots (load)")


func test_pause_menu() -> void:
	var menu: PauseMenu = PauseMenu.new()
	add_child_autofree(menu)
	await get_tree().process_frame
	menu.visible = true
	await _check_screen(menu._root, "Pause menu")
	var focused: Control = get_viewport().gui_get_focus_owner()
	assert_true(focused is Button and (focused as Button).text == "Resume", "Resume is focused first")


func test_dialogs_cancel_with_b() -> void:
	var host: Control = Control.new()
	add_child_autofree(host)
	var dialog: ConfirmDialog = ConfirmDialog.ask(host, "Leave?", "Sure?", "Leave", "Stay")
	var answers: Array[String] = []
	dialog.cancelled.connect(func() -> void: answers.append("cancel"))
	await get_tree().process_frame
	assert_eq(PadFocus.top_root(get_tree()), dialog)
	var back: InputEventJoypadButton = InputEventJoypadButton.new()
	back.button_index = JOY_BUTTON_B
	back.pressed = true
	dialog._unhandled_input(back)
	assert_eq(answers, ["cancel"] as Array[String], "B answers with the cancel button")


func test_a_three_way_question_is_walkable() -> void:
	var host: Control = Control.new()
	add_child_autofree(host)
	var dialog: ConfirmDialog = ConfirmDialog.ask_three(host, "Unsaved changes", "Save?", "Save", "Discard", "Cancel")
	await get_tree().process_frame
	await get_tree().process_frame
	var focused: Control = get_viewport().gui_get_focus_owner()
	assert_true(focused is Button and (focused as Button).text == "Cancel", "the safe answer is focused")
	var left: Control = PadFocus.neighbor(focused, Vector2.LEFT, dialog) if focused != null else null
	assert_true(left is Button and (left as Button).text == "Discard", "left of Cancel is Discard (%s)" % (left.name if left != null else "none"))
	await _check_screen(dialog, "Three-way question")


func test_character_screen_with_gear() -> void:
	Session.set_flag(&"armory_unlocked")
	assert_true(Session.gear_unlocked())
	await _overlay(CharacterScreen.new(), "Character / equipment (gear unlocked)")


func test_card_vendor_grid() -> void:
	var screen: VendorScreen = VendorScreen.new()
	screen.pack_vendor_id = PackData.VENDOR_CARD
	screen.vendor_screen_id = "VS-SABLE"
	add_child_autofree(screen)
	await get_tree().process_frame
	screen.open_category(VendorCategories.Kind.CARDS)
	for _frame: int in range(120):
		if not screen.is_building():
			break
		await get_tree().process_frame
	await _check_screen(screen, "Sable's card grid")
	var first: Control = screen.pad_first_focus()
	assert_true(first is CardView, "the pad starts on a card for sale")
