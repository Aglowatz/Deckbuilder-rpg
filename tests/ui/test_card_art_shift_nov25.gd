extends GutTest
## Fable Nov 25 (Part 6, the owner's item 10): card names covered the heads. On a full card (hand, deck builder, picks, rewards,
## the Collection, shops: every screen draws CardView) the painting starts CardArt.DEFAULT_SHIFT card units lower, so the head sits
## under the name bar; per-card "shift" overrides live in data/art/card_focus.json. The battlefield card already starts its art
## below its plate and is not moved.


func test_the_default_shift_and_the_overrides() -> void:
	assert_gt(CardArt.DEFAULT_SHIFT, 20.0, "enough to clear the name bar (it covers about 28 card units of the painting's top)")
	assert_almost_eq(float(CardArt.focus_for("B-01")["shift"]), CardArt.DEFAULT_SHIFT, 0.01)
	assert_gt(float(CardArt.focus_for("P4-04")["shift"]), CardArt.DEFAULT_SHIFT, "Octavia's feather needs more")


func test_a_full_card_draws_its_painting_lower_and_fills_the_strip_above() -> void:
	var view: CardView = CardView.create(CardSet.card("B-01"))
	add_child_autofree(view)
	await get_tree().process_frame
	var window: Rect2 = view.art_rect()
	assert_almost_eq(view.art_shift(), CardArt.DEFAULT_SHIFT, 0.01)
	# the art area's top: the frame art's window, or the plain card's border (5) when the frame overlays are off
	var top: float = CardView.FRAME_ART_RECT.position.y if view._framed else 5.0
	var bottom: float = CardView.FRAME_ART_RECT.end.y if view._framed else CardView.SIZE.y - 5.0
	assert_almost_eq(window.position.y, top + CardArt.DEFAULT_SHIFT, 0.01, "the painting starts lower")
	assert_almost_eq(window.end.y, bottom, 0.01, "and ends where it did (its bottom, behind the rules, is given up)")
	var picture: TextureRect = view.find_child("ArtPicture", true, false) as TextureRect
	assert_not_null(picture)
	if picture != null:
		assert_almost_eq(picture.position.y, window.position.y, 0.01)
		# the crop keeps the painting's top: the head moves down, not up and out
		assert_almost_eq((picture.texture as AtlasTexture).region.position.y, 0.0, 0.5)
		assert_almost_eq(picture.size.x / picture.size.y, (picture.texture as AtlasTexture).region.size.x / (picture.texture as AtlasTexture).region.size.y, 0.01, "not stretched")
	var strip: TextureRect = view.find_child("ArtTopStrip", true, false) as TextureRect
	assert_not_null(strip, "the strip above is painted")
	if strip != null:
		assert_almost_eq(strip.position.y, top, 0.01)
		assert_gte(strip.size.y, CardArt.DEFAULT_SHIFT)


func test_the_battlefield_card_is_not_moved() -> void:
	var view: CardView = CardView.create(CardSet.card("B-01"))
	view.mode = CardView.Mode.COMPACT
	assert_eq(view.art_shift(), 0.0)
