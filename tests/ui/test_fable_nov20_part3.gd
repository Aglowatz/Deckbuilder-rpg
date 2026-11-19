extends GutTest
## Fable Nov 20, Part 3: Auntie Alembic's brewed card (large, centred, its line underneath, hover magnifies; the chosen essences stay
## chosen for the next brew) and the equipment visuals (no tier anywhere; a long description wraps and fits).

var A: Affinity.Type = Affinity.Type.BEEFCAKE
var D: Affinity.Type = Affinity.Type.NECROCRAT


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(A)


func _brewed_screen(essence: int, gold: int) -> AlchemistScreen:
	Session.profile.set_essence(A, essence)
	Session.profile.set_essence(D, essence)
	Session.gold = gold
	var screen: AlchemistScreen = AlchemistScreen.new()
	add_child_autofree(screen)
	await wait_frames(3)
	((screen.find_child("EssenceRow%d" % int(A), true, false)) as Button).pressed.emit()
	((screen.find_child("EssenceRow%d" % int(D), true, false)) as Button).pressed.emit()
	await wait_frames(2)
	(screen.find_child("CraftButton", true, false) as FancyButton).pressed.emit()
	await wait_seconds(2.4)
	return screen


func test_the_brewed_card_is_large_centred_and_its_line_sits_under_it() -> void:
	var screen: AlchemistScreen = await _brewed_screen(18, 1000)
	var result: Control = screen.find_child("CraftResult", true, false) as Control
	assert_not_null(result)
	var card: Control = screen.find_child("CraftedCard", true, false) as Control
	var caption: Label = screen.find_child("CraftCaption", true, false) as Label
	assert_not_null(card)
	assert_not_null(caption)
	await wait_frames(3)
	var card_rect: Rect2 = card.get_global_rect()
	var caption_rect: Rect2 = caption.get_global_rect()
	var panel_rect: Rect2 = result.get_global_rect()
	assert_gt(card_rect.size.y, CardView.SIZE.y * 0.55 * 1.45, "large: about 1.7 times the old size (0.55 of a card)")
	assert_almost_eq(card_rect.get_center().x, panel_rect.get_center().x, 6.0, "centred in the brew panel")
	assert_gte(caption_rect.position.y, card_rect.end.y - 1.0, "the line is under the card: no overlap")
	assert_false(card_rect.intersects(caption_rect.grow(-1.0)), "the two never overlap")
	assert_string_contains(caption.text, "joins your collection")
	assert_ne(caption.autowrap_mode, TextServer.AUTOWRAP_OFF, "a long card name wraps instead of running over the card")
	assert_false((screen.find_child("PossibleCards", true, false) as Control).visible, "the possible-cards grid makes room for it")
	# hovering magnifies it, like a reward card
	assert_eq(card.mouse_filter, Control.MOUSE_FILTER_PASS, "the card takes the mouse")
	assert_true(card.mouse_entered.get_connections().size() > 0, "hover zoom is attached")


func test_the_chosen_essences_stay_chosen_and_the_next_brew_is_one_click() -> void:
	var screen: AlchemistScreen = await _brewed_screen(18, 1000)
	var craft: FancyButton = screen.find_child("CraftButton", true, false) as FancyButton
	assert_eq(Session.profile.essence_of(A), 18 - Alchemy.MIN_ESSENCE_PER_PATH)
	assert_true(bool(((screen.find_child("EssenceRow%d" % int(A), true, false)) as Button).get_meta("chosen")), "Beefcake is still chosen")
	assert_true(bool(((screen.find_child("EssenceRow%d" % int(D), true, false)) as Button).get_meta("chosen")), "Necrocrat is still chosen")
	assert_false(craft.disabled, "enough essence and gold: Craft stays enabled")
	craft.pressed.emit()
	await wait_seconds(2.4)
	assert_eq(Session.profile.essence_of(A), 18 - 2 * Alchemy.MIN_ESSENCE_PER_PATH, "a second brew at once")
	assert_eq(screen.find_children("CraftResult", "", true, false).size(), 1, "one result at a time")
	craft.pressed.emit()
	await wait_seconds(2.4)
	assert_eq(Session.profile.essence_of(A), 0, "a third")
	assert_true(craft.disabled, "no essence left: Craft is disabled and says why")
	assert_string_contains(craft.text, "essence")


func test_craft_is_disabled_after_a_brew_when_the_gold_is_gone() -> void:
	var screen: AlchemistScreen = await _brewed_screen(18, Alchemy.GOLD_COST)
	var craft: FancyButton = screen.find_child("CraftButton", true, false) as FancyButton
	assert_eq(Session.gold, 0)
	assert_true(craft.disabled, "still chosen, but no gold")


func test_no_equipment_visual_shows_a_tier() -> void:
	for path: String in ["res://ui/town/character_screen.gd", "res://ui/town/equipment_vendor_screen.gd", "res://core/data/equipment_data.gd", "res://core/data/equipment_compare.gd", "res://ui/screens/reward_screen.gd"]:
		if not FileAccess.file_exists(path):
			continue
		assert_false(FileAccess.get_file_as_string(path).contains("Tier %d"), "%s prints no tier" % path)
	for piece: Variant in Session.content.equipment.values():
		assert_false((piece as EquipmentData).tooltip_text().contains("Tier"), (piece as EquipmentData).source_name)


func test_the_longest_equipment_description_wraps_and_fits_at_large_text() -> void:
	var longest: EquipmentData = null
	var pieces: Array = Session.content.equipment.values()
	pieces.append_array(Session.content.zone_equipment.values())
	for piece: Variant in pieces:
		if longest == null or (piece as EquipmentData).description.length() > longest.description.length():
			longest = piece as EquipmentData
	var loincloth: EquipmentData = Session.content.equipment_piece("thorned_loincloth")
	assert_not_null(loincloth, "the owner's example exists")
	var saved: Array[int] = [Settings.text_dialogue, Settings.text_cards, Settings.text_tooltips]
	Settings.set_text_master(1)  # Large
	Session.set_flag(&"armory_unlocked")
	for slot: Variant in EquipmentData.Slot.values():
		Session.profile.unlock_equipment_slot(slot as EquipmentData.Slot)
	for piece: EquipmentData in [longest, loincloth]:
		Session.grant_equipment(piece)
		var screen: CharacterScreen = CharacterScreen.new()
		add_child_autofree(screen)
		await wait_frames(3)
		screen.open_equipment_page(piece.slot)
		await wait_frames(2)
		(screen.find_child("Gear_%s" % piece.id, true, false) as Button).pressed.emit()
		await wait_frames(4)
		var effect: Label = screen.find_child("GearEffect", true, false) as Label
		var page: Control = screen.find_child("EquipmentPage", true, false) as Control
		var button: Control = screen.find_child("GearButton", true, false) as Control
		var status: Control = screen.find_child("GearStatus", true, false) as Control
		assert_eq(effect.text, piece.description)
		assert_gt(effect.get_line_count(), 1, "%s: the description wraps onto more lines" % piece.source_name)
		assert_eq(effect.get_visible_line_count(), effect.get_line_count(), "every line is shown")
		assert_lte(effect.get_global_rect().end.x, button.get_global_rect().position.x, "%s: it ends left of the Equip button" % piece.source_name)
		assert_lte(status.get_global_rect().end.y, page.get_global_rect().end.y, "%s: the whole text column ends inside the panel" % piece.source_name)
		assert_gte(status.get_global_rect().position.y, effect.get_global_rect().end.y - 1.0, "the status line sits under the description")
		for label: Node in page.find_children("*", "Label", true, false):
			assert_false((label as Label).text.contains("Tier"), "no tier on the page: %s" % (label as Label).text)
		screen.queue_free()
		await wait_frames(2)
	Settings.text_dialogue = saved[0]
	Settings.text_cards = saved[1]
	Settings.text_tooltips = saved[2]
