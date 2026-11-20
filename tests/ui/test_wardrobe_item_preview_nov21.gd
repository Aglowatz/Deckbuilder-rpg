extends GutTest
## Fable Nov 21 (Part 5.3): the Wardrobe's "Your Look" shows one item by itself, large, like Pip Threadwell's shop: no character
## preview with hats. The piece under the pointer or the focus is shown; it opens on what is worn; the Plain Cloak shows its dye.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func _screen() -> WardrobeScreen:
	var screen: WardrobeScreen = WardrobeScreen.new()
	add_child_autofree(screen)
	await wait_process_frames(3)
	return screen


func _own_everything() -> void:
	for slot: CosmeticData.Slot in [CosmeticData.Slot.HAT, CosmeticData.Slot.CLOAK]:
		for item: CosmeticData in CosmeticCatalog.in_slot(slot):
			Session.grant_cosmetic(item.id)


func test_there_is_no_character_preview_only_the_item() -> void:
	var screen: WardrobeScreen = await _screen()
	assert_eq(screen.find_children("*", "HeroPreview", true, false).size(), 0, "no turning hero")
	var icon: TextureRect = screen.find_child("ItemPreview", true, false) as TextureRect
	assert_not_null(icon)
	assert_gte(icon.size.x, 400.0, "the item is shown large")
	assert_eq(screen.shown_key, "cloak|", "a new hero wears no hat: the stage opens on the Plain Cloak")
	assert_string_contains((screen.find_child("ItemName", true, false) as Label).text, TailorScreen.PLAIN_CLOAK)


func test_every_piece_shows_its_own_picture_and_name_when_pointed_at() -> void:
	_own_everything()
	var screen: WardrobeScreen = await _screen()
	var icon: TextureRect = screen.find_child("ItemPreview", true, false) as TextureRect
	var name_label: Label = screen.find_child("ItemName", true, false) as Label
	var checked: int = 0
	for slot: CosmeticData.Slot in [CosmeticData.Slot.HAT, CosmeticData.Slot.CLOAK]:
		var key: String = "hat" if slot == CosmeticData.Slot.HAT else "cloak"
		for item: CosmeticData in CosmeticCatalog.in_slot(slot):
			var tile: Button = screen.find_child("Tile_%s_%s" % [key, item.id], true, false) as Button
			assert_not_null(tile, item.id)
			tile.mouse_entered.emit()
			assert_eq(screen.shown_key, "%s|%s" % [key, item.id])
			assert_eq(name_label.text, item.display_name)
			assert_not_null(icon.texture, "%s has a standalone picture" % item.display_name)
			assert_eq(icon.texture, (tile.get_node("Icon") as TextureRect).texture, "the same picture as its tile, large")
			assert_not_null(IconArt.cosmetic_texture(item, 64.0), "%s: its own ICON-COS picture (no Batch 18 row needed)" % item.id)
			checked += 1
	assert_gte(checked, 10, "every hat and cloak")


func test_the_focus_shows_a_piece_too_for_the_controller() -> void:
	_own_everything()
	var screen: WardrobeScreen = await _screen()
	var hat: CosmeticData = CosmeticCatalog.in_slot(CosmeticData.Slot.HAT)[0]
	(screen.find_child("Tile_hat_%s" % hat.id, true, false) as Button).focus_entered.emit()
	assert_eq(screen.shown_key, "hat|%s" % hat.id)


func test_putting_a_piece_on_keeps_it_on_the_stage_and_names_what_is_worn() -> void:
	_own_everything()
	var screen: WardrobeScreen = await _screen()
	var hat: CosmeticData = null
	for item: CosmeticData in CosmeticCatalog.in_slot(CosmeticData.Slot.HAT):
		if SpriteCosmetics.art_ready(item):
			hat = item
			break
	assert_not_null(hat)
	(screen.find_child("Tile_hat_%s" % hat.id, true, false) as Button).pressed.emit()
	assert_eq(Session.cosmetics.hat_id, hat.id, "it is worn")
	assert_eq(screen.shown_key, "hat|%s" % hat.id)
	assert_string_contains((screen.find_child("StageCaption", true, false) as Label).text, hat.display_name)
	screen.queue_free()
	await wait_process_frames(2)
	var again: WardrobeScreen = await _screen()
	assert_eq(again.shown_key, "hat|%s" % hat.id, "the stage opens on the worn hat")


func test_the_plain_cloak_shows_its_dye() -> void:
	Session.cosmetics.grant_dye(0)
	var screen: WardrobeScreen = await _screen()
	var swatch: Control = screen.find_child("DyeSwatch", true, false) as Control
	assert_false(swatch.visible, "undyed: no swatch")
	screen._dye(0)
	assert_eq(screen.shown_key, "cloak|")
	assert_true(swatch.visible, "the dye's colour is shown beside the cloak")
	assert_string_contains((screen.find_child("ItemName", true, false) as Label).text, Dye.dye_name(0))
