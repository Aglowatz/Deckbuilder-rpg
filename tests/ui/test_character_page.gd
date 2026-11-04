extends GutTest
## Overnight Nov 3-4, Part C (docs/ui/character_menu_spec.md): the redesigned Character page - the figure's five slots and the unlock pill,
## LEVEL and CARD PACKS, the ITEMS panel (the focus: largest, accented) with four positional slots, the inventory grid with charges, the
## detail row and its Equip / Unequip, the Equipment selection page; plus the tutorial highlights (Parts B5 / B6).


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.profile.owned_items.clear()
	Session.profile.item_uses_remaining.clear()
	Session.profile.equipped_item_ids.clear()


func _page() -> CharacterScreen:
	var screen: CharacterScreen = CharacterScreen.new()
	add_child_autofree(screen)
	await wait_frames(3)
	return screen


func _texts(screen: Node) -> Array[String]:
	var texts: Array[String] = []
	for node: Node in screen.find_children("*", "Label", true, false):
		texts.append((node as Label).text)
	return texts


func test_the_page_has_the_spec_panels_and_the_items_panel_leads() -> void:
	var screen: CharacterScreen = await _page()
	assert_has(_texts(screen), "CHARACTER")
	for panel_name: String in ["LevelPanel", "PacksPanel", "ItemsPanel", "EquipmentStage"]:
		assert_not_null(screen.find_child(panel_name, true, false), panel_name)
	var items: Control = screen.find_child("ItemsPanel", true, false) as Control
	var level: Control = screen.find_child("LevelPanel", true, false) as Control
	assert_gt(items.size.x * items.size.y, 2.0 * level.size.x * level.size.y, "the Items panel is the biggest")
	var style: StyleBoxFlat = items.get_theme_stylebox(&"panel") as StyleBoxFlat
	assert_gt(style.border_width_left, (level.get_theme_stylebox(&"panel") as StyleBoxFlat).border_width_left, "accent border")
	assert_gt(style.shadow_size, 0, "a glow")
	for text: String in [CharacterScreen.SUBTITLE, CharacterScreen.SLOTS_NOTE, CharacterScreen.FOOTER, "EQUIPPED", "INVENTORY", "PATH ESSENCE", "CARD PACKS", "Level %d" % Session.profile.level]:
		assert_has(_texts(screen), text)
	for rect: Rect2 in [CharacterScreen.LEVEL_RECT, CharacterScreen.PACKS_RECT, CharacterScreen.ITEMS_RECT]:
		assert_true(Rect2(0, 0, 1920, 1080).encloses(rect), "inside the 1920 x 1080 page")


func test_early_save_two_slots_and_equipment_locked() -> void:
	Session.profile.apply_level(ProgressionTable.row(3))
	var screen: CharacterScreen = await _page()
	assert_eq((screen.find_child("UnlockedCount", true, false) as Label).text, "0 / 2 unlocked")
	var captions: Array[String] = []
	for index: int in 4:
		captions.append((screen.find_child("ItemSlot_%d" % index, true, false).get_node("Caption") as Label).text)
	assert_eq(captions, ["Empty slot", "Empty slot", "Level 6 unlock", "Level 12 unlock"] as Array[String])
	assert_true((screen.find_child("UnlockPill", true, false) as Control).visible)
	assert_has(_texts(screen), CharacterScreen.PACKS_EMPTY)
	assert_has(_texts(screen), CharacterScreen.PACKS_HINT)


func test_select_an_item_then_an_empty_slot_equips_it_there() -> void:
	Session.profile.apply_level(ProgressionTable.row(12))
	var charm: ItemData = Session.content.item("firebrand_charm")
	Session.add_item(charm, 2)
	var screen: CharacterScreen = await _page()
	var cell: Button = screen.find_child("Inventory_firebrand_charm", true, false) as Button
	assert_not_null(cell)
	assert_eq((cell.find_child("ChargeBadge", true, false) as Label).text, "x2")
	cell.pressed.emit()
	await wait_frames(2)
	assert_eq((screen.find_child("DetailName", true, false) as Label).text, "Firebrand Charm")
	assert_eq((screen.find_child("DetailMeta", true, false) as Label).text, "Single-use  •  2 charges owned")
	assert_eq((screen.find_child("DetailStatus", true, false) as Label).text, "Not equipped")
	(screen.find_child("ItemSlot_2", true, false) as Button).pressed.emit()
	await wait_frames(2)
	assert_eq(Session.profile.item_in_slot(2), "firebrand_charm", "the slot that was clicked")
	assert_eq((screen.find_child("DetailStatus", true, false) as Label).text, "Equipped in slot 3")
	assert_eq((screen.find_child("DetailButton", true, false) as Button).text, "Unequip")
	assert_eq((screen.find_child("UnlockedCount", true, false) as Label).text, "1 / 4 unlocked")
	(screen.find_child("DetailButton", true, false) as Button).pressed.emit()
	await wait_frames(2)
	assert_false(Session.profile.is_item_equipped(charm))


func test_equip_button_takes_the_first_empty_slot_and_a_slot_click_selects() -> void:
	var salve: ItemData = Session.content.item("healing_salve")
	Session.add_item(salve)
	var screen: CharacterScreen = await _page()
	screen._select_item(salve)
	(screen.find_child("DetailButton", true, false) as Button).pressed.emit()
	await wait_frames(2)
	assert_eq(Session.profile.item_in_slot(0), "healing_salve")
	screen._selected_item = null
	(screen.find_child("ItemSlot_0", true, false) as Button).pressed.emit()
	await wait_frames(2)
	assert_eq(screen._selected_item, salve, "clicking an equipped slot selects it for Unequip")


func test_equipment_page_lists_owned_gear_for_the_slot_and_equips() -> void:
	Session.set_flag(&"armory_unlocked")
	for slot: Variant in EquipmentData.Slot.values():
		Session.profile.unlock_equipment_slot(slot as EquipmentData.Slot)
	var blade: EquipmentData = Session.content.equipment_piece(EquipmentRarity.STARTER_BLADE)
	Session.grant_equipment(blade)
	var screen: CharacterScreen = await _page()
	assert_false((screen.find_child("UnlockPill", true, false) as Control).visible, "no pill once unlocked")
	(screen.find_child("EquipSlot_weapon", true, false) as Button).pressed.emit()
	await wait_frames(2)
	assert_true(screen.equipment_page_open())
	var cell: Button = screen.find_child("Gear_%s" % blade.id, true, false) as Button
	assert_not_null(cell, "the blade is on the weapon page")
	cell.pressed.emit()
	await wait_frames(2)
	(screen.find_child("GearButton", true, false) as Button).pressed.emit()
	await wait_frames(2)
	assert_eq(Session.profile.equipped_in(EquipmentData.Slot.WEAPON), blade)
	(screen.find_child("BackButton", true, false) as Button).pressed.emit()
	await wait_frames(2)
	assert_false(screen.equipment_page_open())


func test_every_slot_and_cell_is_reachable_by_keyboard() -> void:
	Session.add_item(Session.content.item("power_wraps"))
	var screen: CharacterScreen = await _page()
	for index: int in 4:
		assert_eq((screen.find_child("ItemSlot_%d" % index, true, false) as Button).focus_mode, Control.FOCUS_ALL)
	assert_eq((screen.find_child("Inventory_power_wraps", true, false) as Button).focus_mode, Control.FOCUS_ALL)
	assert_eq((screen.find_child("EquipSlot_helm", true, false) as Button).focus_mode, Control.FOCUS_ALL)


# ---- Tutorials (Parts B5, B6) -------------------------------------------------------------------------------------------------------


func _merchants_active() -> void:
	Session.quest_log.reset()
	Session.quest_log.active.append(QuestDefinitions.MERCHANTS)


func test_tilly_tutorial_highlights_the_item_then_an_empty_slot_and_completes_on_equip() -> void:
	_merchants_active()
	assert_true(Session.give_tilly_gift())
	assert_false(Session.give_tilly_gift(), "once")
	assert_eq(Session.profile.item_uses_left(Session.content.item("power_wraps")), 1)
	assert_eq(Session.tutorial_target(), "items")
	var screen: CharacterScreen = await _page()
	assert_gt(screen.highlighted(), 0)
	var ring_parent: Node = screen.find_child("TutorialHighlight", true, false).get_parent()
	assert_eq(ring_parent.name, "Inventory_power_wraps", "the gift is pointed at first")
	screen._select_item(Session.content.item("power_wraps"))
	await wait_frames(2)
	assert_eq(screen.find_child("TutorialHighlight", true, false).get_parent().name, "ItemSlot_0", "then an empty slot")
	(screen.find_child("ItemSlot_0", true, false) as Button).pressed.emit()
	await wait_frames(2)
	assert_true(Session.flag(Session.FLAG_TILLY_EQUIPPED), "the step completes on equip")
	assert_eq(Session.tutorial_target(), "")
	assert_eq(screen.highlighted(), 0)


func test_merchants_starts_with_tilly_and_her_equip_step() -> void:
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.MERCHANTS)
	assert_true(quest.objectives[0].text.contains("Tilly"))
	assert_true(quest.objectives[1].text.begins_with("Equip Tilly's Power Wraps"))
	var lines: Array[String] = StoryText.shared().get_lines("town.item_vendor.gift")
	var joined: String = " ".join(lines)
	for words: String in ["Character", "Items", "empty slot", "Power Wraps"]:
		assert_true(joined.contains(words), "Tilly says: %s" % words)


func test_bertram_tutorial_collect_hands_the_blade_and_equip_completes_the_quest() -> void:
	Session.quest_log.reset()
	Session.quest_log.active.append(QuestDefinitions.ARMORY)
	Session.set_flag(&"armory_reported")
	Session.bump_counter("duels_won")
	assert_eq(Session.armory_talk(), 3)
	var blade: EquipmentData = Session.content.equipment_piece(EquipmentRarity.STARTER_BLADE)
	assert_true(Session.profile.owned_equipment.has(blade), "the blade is handed over")
	assert_null(Session.profile.equipped_in(EquipmentData.Slot.WEAPON), "not worn yet: the player equips it")
	assert_true(Session.profile.has_equipment_slot(EquipmentData.Slot.WEAPON), "the slots are open")
	assert_eq(Session.tutorial_target(), "equipment")
	var screen: CharacterScreen = await _page()
	assert_eq(screen.find_child("TutorialHighlight", true, false).get_parent().name, "EquipSlot_weapon")
	screen.open_equipment_page(EquipmentData.Slot.WEAPON)
	await wait_frames(2)
	assert_eq(screen.find_child("TutorialHighlight", true, false).get_parent().name, "Gear_%s" % blade.id)
	assert_true(Session.equip_item(blade))
	assert_true(Session.flag(Session.FLAG_ARMORY_EQUIPPED))
	Session.refresh_quests()
	assert_true(Session.quest_log.is_completed(QuestDefinitions.ARMORY), "the last step was the equip")


## Nov 3-4 (critic): Escape closes the Equipment page first, then the Character page.
func test_escape_goes_back_then_closes() -> void:
	Session.set_flag(&"armory_unlocked")
	for slot: Variant in EquipmentData.Slot.values():
		Session.profile.unlock_equipment_slot(slot as EquipmentData.Slot)
	var screen: CharacterScreen = await _page()
	watch_signals(screen)
	screen.open_equipment_page(EquipmentData.Slot.HELM)
	var cancel: InputEventAction = InputEventAction.new()
	cancel.action = &"ui_cancel"
	cancel.pressed = true
	screen._unhandled_input(cancel)
	assert_false(screen.equipment_page_open(), "Escape: back from the Equipment page")
	assert_signal_not_emitted(screen, "closed")
	screen._unhandled_input(cancel)
	assert_signal_emitted(screen, "closed", "Escape again: the page closes")


func test_floating_energy_is_spelled_out() -> void:
	assert_eq(BattleHud.pool_text([] as Array[int]), "")
	assert_eq(BattleHud.pool_text([int(Affinity.Type.BEEFCAKE)] as Array[int]), "+1 Beefcake energy this turn")
