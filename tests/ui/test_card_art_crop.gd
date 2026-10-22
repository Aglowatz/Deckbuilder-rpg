extends GutTest
## UI + economy fixes Oct 22, Parts 2 and 3: card art is cut around a focus near the top of the painting (heads stay in view), per-card
## overrides come from data/art/card_focus.json, and a saved deck's slot is filled by its cover card's painting with a name banner, Path
## icons and an "In use" chip.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_a_wide_window_keeps_the_top_of_the_painting() -> void:
	var region: Rect2 = CardArt.crop_region(Vector2(768, 1152), Vector2(300, 300), CardArt.DEFAULT_FOCUS)
	assert_almost_eq(region.size.x, 768.0, 0.5, "the whole width")
	assert_almost_eq(region.size.y, 768.0, 0.5, "a square window shows a square")
	assert_lt(region.position.y, 1152.0 * 0.1, "anchored near the top, not the centre (the centre would start at 192)")


func test_the_whole_painting_fits_a_two_by_three_window() -> void:
	var region: Rect2 = CardArt.crop_region(Vector2(768, 1152), Vector2(200, 300), 0.3)
	assert_almost_eq(region.position, Vector2.ZERO, Vector2(0.5, 0.5))
	assert_almost_eq(region.size, Vector2(768, 1152), Vector2(0.5, 0.5))


func test_focus_and_zoom_move_and_tighten_the_crop() -> void:
	var low: Rect2 = CardArt.crop_region(Vector2(768, 1152), Vector2(300, 300), 0.8)
	assert_almost_eq(low.end.y, 1152.0, 0.5, "a low focus shows the bottom of the painting")
	var zoomed: Rect2 = CardArt.crop_region(Vector2(768, 1152), Vector2(300, 300), 0.3, 1.5)
	assert_almost_eq(zoomed.size.x, 512.0, 0.5)
	assert_almost_eq(zoomed.position.x, 128.0, 0.5, "zoom stays centred horizontally")
	assert_gte(zoomed.position.y, 0.0)


func test_every_focus_override_names_a_real_card_with_sane_numbers() -> void:
	var text: String = FileAccess.get_file_as_string(CardArt.FOCUS_PATH)
	var parsed: Variant = JSON.parse_string(text)
	assert_true(parsed is Dictionary, "card_focus.json parses")
	for key: Variant in (parsed as Dictionary).keys():
		if str(key).begins_with("_"):
			continue
		var id: String = str(key)
		var folder: String = "tokens" if id.begins_with("T-") else "cards"
		assert_true(ResourceLoader.exists("res://data/%s/%s.tres" % [folder, id]), "%s is a card" % id)
		var entry: Dictionary = (parsed as Dictionary)[key] as Dictionary
		var focus: float = float(entry.get("focus", CardArt.DEFAULT_FOCUS))
		assert_between(focus, 0.0, 1.0, id)
		assert_between(float(entry.get("zoom", 1.0)), 1.0, 2.0, id)


func test_a_saved_deck_slot_shows_the_cover_painting_name_paths_and_in_use() -> void:
	var cover: CardData = Session.card_by_id("B-09")
	var face: Control = DeckRack.cover_tile(cover, Vector2(150, 190), "Wanderer's Deck", [Affinity.Type.BEEFCAKE] as Array[Affinity.Type], true)
	add_child_autofree(face)
	var art: TextureRect = face.find_child("CoverArt", true, false) as TextureRect
	assert_not_null(art, "the cover card's painting")
	assert_almost_eq(art.size.x, 150.0 - 2.0 * DeckRack.ART_MARGIN, 0.5, "almost edge to edge, a small even margin")
	assert_almost_eq(art.position, Vector2(DeckRack.ART_MARGIN, DeckRack.ART_MARGIN), Vector2(0.5, 0.5))
	var label: Label = face.find_child("DeckName", true, false) as Label
	assert_eq(label.text, "Wanderer's Deck", "the name on a banner")
	assert_not_null(face.find_child("PathIcons", true, false), "the Path icons")
	assert_not_null(face.find_child("InUse", true, false), "the In use marker on the active deck")
	var other: Control = DeckRack.cover_tile(cover, Vector2(150, 190), "Spare", [] as Array[Affinity.Type], false)
	add_child_autofree(other)
	assert_null(other.find_child("InUse", true, false), "no marker on another deck")


func test_the_rack_uses_the_cover_face_and_shows_the_count_on_hover() -> void:
	var screen: DeckbuilderScreen = DeckbuilderScreen.new()
	add_child_autofree(screen)
	await wait_process_frames(2)
	var tile: FancyButton = screen.rack_tile(0)
	assert_not_null(tile.find_child("CoverFace", true, false), "slot 1 holds the starter deck's cover")
	var count: Label = tile.find_child("CardCount", true, false) as Label
	assert_false(count.visible)
	tile.mouse_entered.emit()
	assert_true(count.visible, "hover shows the card count")
	assert_true(count.text.contains("cards"))
	assert_null(screen.rack_tile(1).find_child("CoverFace", true, false), "an empty slot keeps the + Empty slot look")
