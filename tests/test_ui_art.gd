extends GutTest
## The UI art kit (docs/art/ui_art_kit.md): the importer's trim, the kit IDs, the frame and back choice per card.


func test_the_kit_csv_lists_the_55_ui_ids() -> void:
	var known: Dictionary = UiArt.known_ids()
	assert_eq(known.size(), 55)
	assert_true(known.has("UI-FRAME-B"))
	assert_true(known.has("UI-PACK-GENERAL-2"))


func test_trim_crops_to_the_visible_pixels_and_keeps_a_small_pad() -> void:
	var image: Image = Image.create(100, 80, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	image.fill_rect(Rect2i(30, 20, 20, 10), Color(1, 0, 0, 1))
	var cropped: Image = UiArt.trimmed(image)
	assert_eq(cropped.get_size(), Vector2i(20 + UiArt.TRIM_PAD * 2, 10 + UiArt.TRIM_PAD * 2))


func test_scaled_never_enlarges() -> void:
	var image: Image = Image.create(200, 100, false, Image.FORMAT_RGBA8)
	assert_eq(UiArt.scaled(image, 400).get_size(), Vector2i(200, 100))
	assert_eq(UiArt.scaled(image, 100).get_size(), Vector2i(100, 50))


func test_a_missing_id_has_no_texture() -> void:
	assert_false(UiArt.has("UI-DOES-NOT-EXIST"))
	assert_null(UiArt.texture("UI-DOES-NOT-EXIST"))


func test_frame_and_back_follow_the_card() -> void:
	var card: CardData = Session.content.card("C-01")
	var view: CardView = CardView.create(card)
	assert_eq(view.frame_id(), "UI-FRAME-C" if card.color == Affinity.Type.NEUTRAL else str(CardView.PATH_FRAMES[card.color]))
	view.set_meta("opponent_back", true)
	assert_eq(view.back_id(), "UI-CARDBACK-C")
	view.free()


func test_frame_corner_colours_split_by_path_count() -> void:
	var one: Array[Color] = CardView.frame_corner_colors([Affinity.Type.BEEFCAKE] as Array[Affinity.Type])
	assert_eq(one[0], one[3])
	var two: Array[Color] = CardView.frame_corner_colors([Affinity.Type.BEEFCAKE, Affinity.Type.NECROCRAT] as Array[Affinity.Type])
	assert_eq(two[0], two[2])
	assert_ne(two[0], two[1])
	var four: Array[Color] = CardView.frame_corner_colors(Affinity.colored_types())
	assert_eq(four.size(), 4)


func test_cards_use_the_original_full_art_face_unless_the_frame_overlays_are_on() -> void:
	assert_false(UiArt.use_card_frame_overlays(), "data/ui_config.cfg ships with use_card_frame_overlays=false")
	var card: CardData = Session.content.card("C-01")
	var plain: CardView = CardView.create(card)
	add_child_autofree(plain)
	assert_false(plain._framed)
	assert_eq(plain.art_rect().size, CardView.SIZE - Vector2(10, 10), "full art fills the card inside its thin border")
	UiArt.set_card_frame_overlays(true)
	var framed: CardView = CardView.create(card)
	add_child_autofree(framed)
	assert_true(framed._framed, "the overlays come back with the one setting")
	UiArt.set_card_frame_overlays(null)


func test_card_type_lines_name_every_card_type() -> void:
	var expected: Dictionary = {
		CardEnums.CardType.UNIT: "Unit", CardEnums.CardType.SPELL: "Spell", CardEnums.CardType.TRAP: "Trap",
		CardEnums.CardType.WONDER: "Wonder", CardEnums.CardType.TOOL: "Tool", CardEnums.CardType.RESOURCE: "Resource",
		CardEnums.CardType.TOKEN: "Token",
	}
	var every: Array = Session.content.cards.values() + Session.content.tokens.values() + Session.content.infrastructure.values()
	for card: CardData in every:
		var view: CardView = CardView.create(card)
		var kind: String = view._type_text().split("  -  ")[-1]
		if card.type == CardEnums.CardType.INFRASTRUCTURE:
			assert_true(kind.ends_with("Infrastructure"), card.id)
		else:
			assert_true(kind.ends_with(str(expected[card.type])), "%s (%s) says %s" % [card.id, card.display_name, kind])
		view.free()
