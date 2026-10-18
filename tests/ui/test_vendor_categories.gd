extends GutTest
## Overnight Oct 17, Part 2: a vendor with more than one category opens on a category selection screen; each category view
## has a Back button to it; a single-category vendor skips it.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_category_list_and_picker_rule() -> void:
	assert_eq(VendorCategories.list(true, false, false).size(), 1)
	assert_false(VendorCategories.needs_picker(VendorCategories.list(true, false, false)))
	var all: Array[VendorCategories.Kind] = VendorCategories.list(true, true, true)
	assert_eq(all, [VendorCategories.Kind.CARDS, VendorCategories.Kind.PACKS, VendorCategories.Kind.GEAR] as Array[VendorCategories.Kind])
	assert_true(VendorCategories.needs_picker(all))
	for kind: VendorCategories.Kind in all:
		assert_false(VendorCategories.label(kind).is_empty())
		assert_true(IconArt.texture(VendorCategories.icon(kind), 128.0) != null, "%s has an icon" % VendorCategories.label(kind))


func _screen(with_packs: bool) -> VendorScreen:
	var screen: VendorScreen = VendorScreen.new()
	if with_packs:
		screen.pack_vendor_id = PackData.VENDOR_CARD
		screen.pack_story_prefix = "pack.card_vendor"
	add_child_autofree(screen)
	return screen


func test_multi_category_vendor_opens_on_the_picker_and_back_returns_to_it() -> void:
	var screen: VendorScreen = _screen(true)
	await wait_process_frames(2)
	assert_true(screen.is_on_picker(), "cards + packs: the picker first")
	assert_not_null(screen.find_child("CategoryCards", true, false))
	assert_not_null(screen.find_child("CategoryCardPacks", true, false))
	watch_signals(screen)
	screen.open_category(VendorCategories.Kind.CARDS)
	assert_false(screen.is_on_picker())
	screen.request_close()
	assert_true(screen.is_on_picker(), "Back from the cards returns to the picker")
	assert_signal_not_emitted(screen, "closed")
	screen.request_close()
	assert_signal_emitted(screen, "closed", "Esc on the picker leaves the shop")


func test_packs_view_back_returns_to_the_picker() -> void:
	var screen: VendorScreen = _screen(true)
	await wait_process_frames(2)
	screen.open_category(VendorCategories.Kind.PACKS)
	await wait_process_frames(2)
	var shop: PackShopScreen = null
	for child: Node in screen.get_children():
		if child is PackShopScreen:
			shop = child as PackShopScreen
	assert_not_null(shop, "the pack stall opened over the picker")
	assert_eq(shop.close_text, "Back (Esc)")
	shop.request_close()
	await wait_process_frames(2)
	assert_true(screen.is_on_picker())


func test_single_category_vendor_skips_the_picker() -> void:
	var screen: VendorScreen = _screen(false)
	await wait_process_frames(2)
	assert_false(screen.is_on_picker())
	assert_null(screen.find_child("CategoryPicker", true, false))


func test_picker_tiles_take_keyboard_focus() -> void:
	var screen: VendorScreen = _screen(true)
	await wait_process_frames(3)
	var tile: Button = screen.find_child("CategoryCards", true, false) as Button
	assert_eq(tile.focus_mode, Control.FOCUS_ALL)
	assert_true(tile.has_focus(), "the first tile has focus for keyboard and pad")
