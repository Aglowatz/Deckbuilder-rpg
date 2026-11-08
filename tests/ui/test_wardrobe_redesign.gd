extends GutTest
## Overnight Nov 7-8, Part 5.1: the redesigned Wardrobe - a stage with the hero preview, Hats and Cloaks as tile grids with worn / owned states
## and detail lines, and the dyes at the bottom, greyed out with "Dyes work on the Plain Cloak" while another cloak is worn.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func _screen() -> WardrobeScreen:
	var screen: WardrobeScreen = WardrobeScreen.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	return screen


func test_the_page_has_a_stage_two_grids_and_the_dyes_at_the_bottom() -> void:
	var screen: WardrobeScreen = await _screen()
	for panel_name: String in ["Stage", "HatsPanel", "CloaksPanel", "DyesPanel"]:
		assert_not_null(screen.find_child(panel_name, true, false), panel_name)
	var dyes: Control = screen.find_child("DyesPanel", true, false) as Control
	var cloaks: Control = screen.find_child("CloaksPanel", true, false) as Control
	assert_gt(dyes.position.y, cloaks.position.y, "the dyes sit below the cloaks, at the bottom")
	assert_not_null(screen.find_child("HeroPreview", true, false), "the hero on the stage")
	assert_not_null(screen.find_child("Tile_hat_none", true, false), "a No hat tile")
	assert_not_null(screen.find_child("Tile_cloak_none", true, false), "the Plain Cloak tile")


func test_dyes_grey_out_unless_the_plain_cloak_is_worn() -> void:
	var screen: WardrobeScreen = await _screen()
	assert_true(screen.dyes_active(), "a new hero wears the Plain Cloak")
	var other: CosmeticData = null
	for item: CosmeticData in CosmeticCatalog.in_slot(CosmeticData.Slot.CLOAK):
		if SpriteCosmetics.art_ready(item):
			other = item
			break
	if other == null:
		pass_test("no other cloak with art")
		return
	Session.cosmetics.grant(other.id)
	screen.queue_free()
	screen = await _screen()
	screen._equip(CosmeticData.Slot.CLOAK, other.id)
	assert_false(screen.dyes_active())
	var note: Label = screen.find_child("DyeNote", true, false) as Label
	assert_eq(note.text, "Dyes work on the Plain Cloak.")
	var swatch: Button = screen.find_child("Dye_cloak_0", true, false) as Button
	assert_true(swatch.disabled, "the swatches rest")
	screen._equip(CosmeticData.Slot.CLOAK, "")
	assert_true(screen.dyes_active(), "back on the Plain Cloak, the dyes work again")
