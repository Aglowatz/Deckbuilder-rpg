extends GutTest
## Overnight Oct 17 (Phase 2 cycle 5): menu paintings and vendor stage pictures are loaded on a thread and land in the art caches.


func test_backgrounds_and_vendor_art_arrive_in_the_caches() -> void:
	for id: String in UiArtWarmup.UI_BACKGROUNDS:
		UiArt._textures.erase(id)
	KeyArt._textures.erase("VS-SABLE")
	var warmup: UiArtWarmup = UiArtWarmup.make(["VS-SABLE"])
	warmup._delay = 0.01
	add_child_autofree(warmup)
	for _i: int in range(600):
		await wait_frames(1)
		if warmup.pending() == 0:
			break
	assert_eq(warmup.pending(), 0, "every request finished")
	for id: String in UiArtWarmup.UI_BACKGROUNDS:
		if UiArt.has(id):
			assert_true(UiArt._textures.get(id) is Texture2D, id)
	if KeyArt.has("VS-SABLE"):
		assert_true(KeyArt._textures.get("VS-SABLE") is Texture2D)
	assert_eq(UiArt.texture("UI-BG-CHARACTER"), UiArt._textures.get("UI-BG-CHARACTER"), "screens read the warmed copy")


func test_the_glyph_warmup_covers_the_menu_sizes_and_outlines() -> void:
	var combos: Array[Array] = UiArtWarmup.glyph_combos()
	assert_eq(combos.size(), UiArtWarmup.GLYPH_SIZES.size() * 5, "body, bold, and the title font plain / outline 6 / outline 8 at every size")
	var has_title_outline: bool = false
	for combo: Array in combos:
		assert_not_null(combo[0] as Font)
		if combo[0] == UIStyle.font_title() and int(combo[2]) == 8:
			has_title_outline = true
	assert_true(has_title_outline)
	assert_true(UiArtWarmup.GLYPH_SIZES.has(22) and UiArtWarmup.GLYPH_SIZES.has(34), "the most used label sizes")
