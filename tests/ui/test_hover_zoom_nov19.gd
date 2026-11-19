extends GutTest
## Fable Nov 19 (Part 5.3): hover magnification on the remaining card grids. The Collection Book magnifies a card not found yet as its
## card back; the dungeon challenge's revealed cards, a Path offer's sample cards and the Peek panel's cards grow under the mouse.


func test_the_preview_shows_an_unseen_card_as_its_back() -> void:
	CardSet.load_all()
	var preview: HoverPreview = HoverPreview.new()
	add_child_autofree(preview)
	var tile: Button = Button.new()
	tile.size = Vector2(120, 180)
	add_child_autofree(tile)
	var card: CardData = CardSet.card("C-04")
	preview.show_back_for(tile, card)
	assert_true(preview.visible)
	var shown: CardView = preview.get("_card") as CardView
	assert_not_null(shown)
	assert_eq(shown.mode, CardView.Mode.BACK, "the back, not the face")
	assert_false((preview.get("_help") as Control).visible, "no keyword help that would give the card away")
	preview.show_for(tile, card)
	assert_eq((preview.get("_card") as CardView).mode, CardView.Mode.FULL, "a seen card still shows its face")


func test_the_collection_book_magnifies_unseen_cards_as_backs() -> void:
	var source: String = FileAccess.get_file_as_string("res://ui/town/codex_screen.gd")
	assert_true(source.contains("_preview.show_back_for(tile, card)"), "the unseen tile asks for the back")
	assert_true(source.contains("_preview.show_for(tile, card)"), "the seen tile for the face")


func test_the_other_small_card_rows_magnify() -> void:
	for path: String in ["res://ui/dungeon/challenge_screen.gd", "res://ui/dungeon/element_choice_screen.gd", "res://ui/battle/peek_panel.gd", "res://ui/town/alchemist_screen.gd", "res://ui/screens/reward_popup.gd", "res://ui/dungeon/rewards_screen.gd"]:
		var source: String = FileAccess.get_file_as_string(path)
		assert_true(source.contains("CardHoverZoom.attach("), "%s magnifies its small cards" % path)
	# a wrapped card ignores the mouse unless told otherwise: each new site lets it through
	for path: String in ["res://ui/dungeon/challenge_screen.gd", "res://ui/dungeon/element_choice_screen.gd", "res://ui/battle/peek_panel.gd"]:
		assert_true(FileAccess.get_file_as_string(path).contains("MOUSE_FILTER_PASS"), path)


func test_a_wrapped_card_that_passes_the_mouse_zooms() -> void:
	Settings.reduce_motion = true
	CardSet.load_all()
	var holder: Control = CardView.wrapped(CardSet.card("C-04"), 0.28)
	holder.position = Vector2(700, 400)
	add_child_autofree(holder)
	holder.size = holder.custom_minimum_size
	holder.mouse_filter = Control.MOUSE_FILTER_PASS
	CardHoverZoom.attach(holder)
	holder.mouse_entered.emit()
	assert_true(CardHoverZoom.is_zoomed(holder))
	assert_gt(holder.get_global_rect().size.y, CardView.SIZE.y * 0.28 * 1.8, "clearly bigger")
	holder.mouse_exited.emit()
	assert_false(CardHoverZoom.is_zoomed(holder))
	Settings.reduce_motion = false
