extends GutTest
## Oct 19 night (Part 3): the Character screen's equipment area has exactly five slots, each at its body part (helm head, armor chest, weapon at the
## figure's right hand = screen left, relic at its left hand = screen right, boots feet), on the painted-frames background and on one without frames;
## the spare painted frames are covered; the battle item slots are their own labelled row; the background flag follows the imported picture.

const CONFIG_COPY: String = "user://character_layout_test.cfg"


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func after_each() -> void:
	CharacterLayout.force_painted(null)


func after_all() -> void:
	if FileAccess.file_exists(ProjectSettings.globalize_path(CONFIG_COPY)):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(CONFIG_COPY))


func _check_body_order(centers: Dictionary, label: String) -> void:
	assert_eq(centers.size(), 5, "%s: five slots" % label)
	for slot: EquipmentData.Slot in EquipmentData.Slot.values():
		assert_true(centers.has(slot), "%s: %s has a place" % [label, EquipmentData.slot_name(slot)])
	var helm: Vector2 = centers[EquipmentData.Slot.HELM]
	var armor: Vector2 = centers[EquipmentData.Slot.ARMOR]
	var weapon: Vector2 = centers[EquipmentData.Slot.WEAPON]
	var relic: Vector2 = centers[EquipmentData.Slot.RELIC]
	var boots: Vector2 = centers[EquipmentData.Slot.BOOTS]
	assert_lt(weapon.x, relic.x, "%s: the weapon is in the figure's right hand, on the screen left" % label)
	assert_lt(helm.y, armor.y, "%s: head above chest" % label)
	assert_lt(armor.y, weapon.y, "%s: chest above the hands" % label)
	assert_lt(maxf(weapon.y, relic.y), boots.y, "%s: hands above the feet" % label)
	assert_almost_eq(weapon.y, relic.y, 20.0, "%s: both hands at one height" % label)
	var rects: Array[Rect2] = []
	for slot: Variant in centers:
		var rect: Rect2 = CharacterLayout.slot_rect(centers[slot] as Vector2)
		assert_true(Rect2(Vector2.ZERO, CharacterLayout.DESIGN_SIZE).encloses(rect), "%s: %s is on screen" % [label, EquipmentData.slot_name(slot as EquipmentData.Slot)])
		for other: Rect2 in rects:
			assert_false(rect.intersects(other), "%s: slots do not overlap" % label)
		rects.append(rect)
	assert_lt(maxf(helm.x, maxf(armor.x, maxf(weapon.x, maxf(relic.x, boots.x)))), 1100.0, "%s: the slots stay on the figure's side, left of the stats frame" % label)


func test_painted_background_layout_uses_five_painted_frames() -> void:
	var centers: Dictionary = CharacterLayout.slot_centers(true)
	_check_body_order(centers, "painted")
	assert_eq(centers[EquipmentData.Slot.HELM], Vector2(419, 150), "the top-left frame (its line points at the head)")
	assert_eq(centers[EquipmentData.Slot.WEAPON], Vector2(394, 575), "the left frame at hand height")
	assert_eq(centers[EquipmentData.Slot.RELIC], Vector2(981, 581), "the right frame at hand height")
	var spares: Array[Vector2] = CharacterLayout.spare_frame_centers(true)
	assert_eq(spares.size(), 3, "eight painted frames, five slots, three covered")
	for spare: Vector2 in spares:
		for slot: Variant in centers:
			assert_gt(spare.distance_to(centers[slot] as Vector2), CharacterLayout.SLOT_SIZE, "a covered frame is no slot")


func test_clean_background_layout_dresses_the_figure() -> void:
	var centers: Dictionary = CharacterLayout.slot_centers(false)
	_check_body_order(centers, "clean")
	assert_eq(CharacterLayout.spare_frame_centers(false).size(), 0, "nothing to cover")
	assert_almost_eq((centers[EquipmentData.Slot.HELM] as Vector2).x, (centers[EquipmentData.Slot.ARMOR] as Vector2).x, 4.0, "head and chest on the figure's middle line")
	assert_almost_eq((centers[EquipmentData.Slot.ARMOR] as Vector2).x, (centers[EquipmentData.Slot.BOOTS] as Vector2).x, 8.0, "feet under the chest")


func test_the_flag_follows_the_imported_background() -> void:
	assert_true(CharacterLayout.is_painted_background_md5(CharacterLayout.PAINTED_BACKGROUND_MD5))
	assert_false(CharacterLayout.is_painted_background_md5("0123456789abcdef0123456789abcdef"))
	var copy: String = ProjectSettings.globalize_path(CONFIG_COPY)
	var file: FileAccess = FileAccess.open(copy, FileAccess.WRITE)
	file.store_string("; comment\n[cards]\nuse_card_frame_overlays=false\n")
	file.close()
	assert_true(CharacterLayout.write_painted_flag(false, copy))
	var config: ConfigFile = ConfigFile.new()
	assert_eq(config.load(copy), OK)
	assert_false(bool(config.get_value("character", "background_painted_slots", true)), "section added")
	assert_false(bool(config.get_value("cards", "use_card_frame_overlays", true)), "other switches kept")
	assert_true(CharacterLayout.write_painted_flag(true, copy))
	config = ConfigFile.new()
	config.load(copy)
	assert_true(bool(config.get_value("character", "background_painted_slots", false)), "line replaced")
	assert_true(FileAccess.get_file_as_string(copy).begins_with("; comment"), "comments kept")
	assert_eq(FileAccess.get_file_as_string(copy).count("background_painted_slots="), 1)


func test_the_shipped_config_matches_the_shipped_background() -> void:
	var manifest: Dictionary = ArtImporter.read_manifest(ProjectSettings.globalize_path(UiArt.MANIFEST_PATH))
	if not manifest.has("UI-BG-CHARACTER"):
		pass_test("no character background imported")
		return
	assert_eq(CharacterLayout.painted_background(), CharacterLayout.is_painted_background_md5(str(manifest["UI-BG-CHARACTER"])), "data/ui_config.cfg says what the imported picture is")


func test_paper_colour_reads_the_parchment_round_a_frame() -> void:
	var image: Image = Image.create(192, 108, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.9, 0.8, 0.6))
	var colour: Color = CharacterLayout.paper_colour(image, Vector2(960, 540))
	assert_almost_eq(colour.r, 0.9, 0.01)
	assert_almost_eq(colour.b, 0.6, 0.01)


func _screen(painted: bool) -> CharacterScreen:
	CharacterLayout.force_painted(painted)
	var screen: CharacterScreen = CharacterScreen.new()
	add_child_autofree(screen)
	return screen


func test_the_screen_shows_exactly_five_equipment_slots_on_both_backgrounds() -> void:
	for painted: bool in [true, false]:
		var screen: CharacterScreen = _screen(painted)
		await wait_frames(3)
		if not (UiArt.has("UI-BG-CHARACTER") and UiArt.has("UI-SLOT-EQUIP")):
			pass_test("no character art: the plain layout (its own five-slot stage)")
			return
		var stage: Node = screen.find_child("EquipmentStage", true, false)
		assert_not_null(stage)
		var slots: Array[Node] = stage.find_children("EquipSlot_*", "Button", false, false)
		assert_eq(slots.size(), 5, "painted=%s: five slots" % painted)
		assert_eq(stage.find_children("Badge_*", "", true, false).size(), 0, "no badges in spare frames any more")
		assert_eq(stage.find_children("SpareFrameCover_*", "", false, false).size(), 3 if painted else 0, "spare painted frames covered")
		var centers: Dictionary = CharacterLayout.slot_centers(painted)
		for slot: EquipmentData.Slot in EquipmentData.Slot.values():
			var button: Button = stage.find_child("EquipSlot_%s" % str(CharacterLayout.SLOT_KEYS[slot]), false, false) as Button
			assert_not_null(button)
			assert_lt((button.position + button.size * 0.5).distance_to(centers[slot] as Vector2), 1.5, "painted=%s: %s in place" % [painted, EquipmentData.slot_name(slot)])


func test_item_slots_are_their_own_labelled_row_and_path_and_deck_are_stats() -> void:
	var screen: CharacterScreen = _screen(true)
	await wait_frames(3)
	var label: Label = screen.find_child("ItemSlotsLabel", true, false) as Label
	assert_not_null(label)
	assert_true(label.text.begins_with("Item slots"))
	var row: Node = screen.find_child("ItemSlots", true, false)
	assert_not_null(row)
	assert_eq(row.get_child_count(), Session.profile.item_slots, "one square per item slot")
	var stage: Node = screen.find_child("EquipmentStage", true, false)
	if stage != null:
		assert_false(stage.is_ancestor_of(row), "item slots are away from the figure")
	var texts: Array[String] = []
	for node: Node in screen.find_children("*", "Label", true, false):
		texts.append((node as Label).text)
	assert_has(texts, "Path")
	assert_has(texts, UIStyle.affinity_name(Affinity.Type.BEEFCAKE))
	assert_has(texts, "Deck")
	assert_has(texts, "%d cards" % Session.deck.size())
