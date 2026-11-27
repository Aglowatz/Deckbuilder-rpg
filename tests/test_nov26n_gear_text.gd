extends GutTest
## Nov 26 night (Part C.4): equipment text that was unclear or inconsistent, reworded (no numbers changed): "duel" not "battle", "toss"
## not "discard" (the game's word), a full stop not a semicolon, the HP cost as its own sentence, no ambiguous "it".


func test_the_reworded_pieces() -> void:
	var content: ContentSet = ContentLibrary.load_all()
	var expected: Dictionary = {
		"starter_blade": "The first unit you play each duel gets +1 attack.",
		"overdue_library_book": "Draw 1 extra card each turn. Then toss 1 card at random.",
		"thorned_loincloth": "Max HP -2. Whenever an enemy unit attacks you, it takes 1 damage.",
		"big_brain_beret": "Draw an extra card each turn, but you can play only one non-infrastructure card per turn. Max HP -2.",
		"xray_goggles": "The opponent's hand is revealed to you (its face-down traps stay hidden).",
		"extra_pocket": "You can use each equipped item twice per duel. The first use spends one copy, and the second is free, even if it was your last copy.",
	}
	for id: String in expected.keys():
		var piece: EquipmentData = content.equipment_piece(id)
		assert_not_null(piece, id)
		if piece != null:
			assert_eq(piece.description, str(expected[id]), id)


func test_no_piece_uses_the_old_words() -> void:
	var content: ContentSet = ContentLibrary.load_all()
	for piece: EquipmentData in GearCatalog.all_pieces(content):
		assert_false(piece.description.contains(" each battle ") or piece.description.contains(" per battle"), "%s says duel, not battle" % piece.id)
		assert_false(piece.description.to_lower().contains("discard"), "%s says toss, not discard" % piece.id)
		assert_false(piece.description.contains(";"), "%s: sentences, not semicolons" % piece.id)
