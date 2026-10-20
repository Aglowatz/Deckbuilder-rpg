extends GutTest
## Overnight Oct 19-20: the Collection Book's Gear tab - every piece once, by slot; owned pieces show name, rarity and effect, the rest a
## silhouette with "???" and where it comes from (secrets stay secret); "Gear x / y" progress; built only when the tab is first shown.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func _screen() -> CodexScreen:
	var screen: CodexScreen = CodexScreen.new()
	add_child_autofree(screen)
	await wait_process_frames(2)
	return screen


func _texts(tile: Node) -> String:
	var texts: PackedStringArray = []
	for label: Node in tile.find_children("*", "Label", true, false):
		texts.append((label as Label).text)
	return " | ".join(texts)


func test_the_gear_tab_exists_and_builds_lazily() -> void:
	var screen: CodexScreen = await _screen()
	assert_not_null(screen.find_child("TabGear", true, false))
	assert_null(screen.find_child("Gear_wicked_dagger", true, false), "not built before the tab is shown")
	screen.show_tab("Gear")
	assert_not_null(screen.find_child("Gear_wicked_dagger", true, false))
	assert_not_null(screen.find_child("GearHeading_Helm", true, false))
	assert_not_null(screen.find_child("GearHeading_Relic", true, false))


func test_every_piece_is_listed_once() -> void:
	var screen: CodexScreen = await _screen()
	screen.show_tab("Gear")
	var pieces: Array[EquipmentData] = GearCatalog.all_pieces(Session.content)
	var tiles: Array[Node] = screen.find_children("Gear_*", "Button", true, false)
	assert_eq(tiles.size(), pieces.size(), "one tile per piece")
	for piece: EquipmentData in pieces:
		var tile: Button = screen.find_child("Gear_%s" % piece.id, true, false) as Button
		assert_not_null(tile, piece.id)
		if tile != null:
			assert_eq(tile.focus_mode, Control.FOCUS_ALL, "%s is focusable" % piece.id)
			var grid: Node = tile.get_parent()
			assert_eq(str(grid.name), "GearGrid_%s" % EquipmentData.slot_name(piece.slot), "%s sits in its slot's section" % piece.id)


func test_owned_piece_shows_name_rarity_and_effect_others_a_silhouette() -> void:
	var dagger: EquipmentData = Session.content.equipment_piece("wicked_dagger")
	if not Session.owned_equipment_ids().has(dagger.id):
		Session.grant_equipment(dagger)
	var screen: CodexScreen = await _screen()
	screen.show_tab("Gear")
	var owned: String = _texts(screen.find_child("Gear_wicked_dagger", true, false))
	assert_true(owned.contains(dagger.source_name), owned)
	assert_true(owned.contains(EquipmentRarity.display_name(int(dagger.rarity))), owned)
	assert_true(owned.contains(dagger.description), owned)
	assert_false(owned.contains("???"), owned)
	assert_true(Session.owned_equipment_ids().find("flamethrower") < 0, "the test expects the Flamethrower not owned yet")
	var missing: Node = screen.find_child("Gear_flamethrower", true, false)
	var hidden: String = _texts(missing)
	assert_true(hidden.contains("???"), hidden)
	assert_false(hidden.contains("Flamethrower"), "the name stays hidden")
	assert_true(hidden.contains(GearCatalog.VENDOR_HINT), hidden)
	var icon: TextureRect = missing.find_child("GearIcon", true, false) as TextureRect
	assert_not_null(icon)


func test_secret_pieces_say_a_secret() -> void:
	var screen: CodexScreen = await _screen()
	screen.show_tab("Gear")
	for id: String in GearCatalog.secret_piece_ids():
		if Session.owned_equipment_ids().has(id):
			continue
		var text: String = _texts(screen.find_child("Gear_%s" % id, true, false))
		assert_true(text.contains(GearCatalog.SECRET_HINT), "%s: %s" % [id, text])
		assert_false(text.contains("Well"), "%s does not spoil the well" % id)
		assert_false(text.contains("Vault"), "%s does not spoil the vault" % id)


func test_progress_reads_gear_x_of_y() -> void:
	Session.grant_equipment(Session.content.equipment_piece("solid_plate"))
	var screen: CodexScreen = await _screen()
	screen.show_tab("Gear")
	var expected: Vector2i = GearCatalog.progress(GearCatalog.all_pieces(Session.content), Session.owned_equipment_ids())
	assert_eq(screen.gear_progress(), expected)
	assert_gt(expected.x, 0)
	assert_gt(expected.y, expected.x)
	var label: Label = screen._progress_label
	assert_true(label.text.begins_with("Gear %d / %d" % [expected.x, expected.y]), label.text)
	screen.show_tab("Cards")
	assert_true(label.text.begins_with("Found "), "switching back restores the Cards count")
