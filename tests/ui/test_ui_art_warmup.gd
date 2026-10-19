extends GutTest
## Overnight Oct 17 (Phase 2 cycle 5): menu paintings and vendor stage pictures are loaded on a thread and land in the art caches.


func test_backgrounds_and_vendor_art_arrive_in_the_caches() -> void:
	for id: String in UiArtWarmup.UI_BACKGROUNDS:
		UiArt._textures.erase(id)
	KeyArt._textures.erase("VS-SABLE")
	var warmup: UiArtWarmup = UiArtWarmup.make(["VS-SABLE"])
	UiArtWarmup._warmed.clear()
	warmup._delay = 0.01
	warmup._screen_delay = 0.0001
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


## Daytime Oct 19: the first screens are built once, nearly invisible, then freed - and nothing of them is left behind (music, input).
func test_first_screens_are_warmed_and_freed() -> void:
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	var music_before: StringName = Audio.current_music() if Audio.has_method(&"current_music") else &""
	var warmup: UiArtWarmup = UiArtWarmup.make([], [func() -> OverlayScreen: return ItemVendorScreen.new()] as Array[Callable])
	assert_eq(warmup.first_screens.size(), 2, "the character screen plus the area's own")
	UiArtWarmup._warmed.clear()
	warmup._delay = 0.01
	warmup._screen_delay = 0.0001
	add_child_autofree(warmup)
	var seen: int = 0
	for _frame: int in range(90):
		await wait_process_frames(1)
		for node: Node in warmup.find_children("*", "OverlayScreen", true, false):
			seen += 1
			assert_true((node as OverlayScreen).warming)
			assert_lt((node as Control).modulate.a, 0.05, "nearly invisible")
	assert_gt(seen, 0, "a screen was up for a few frames")
	assert_eq(warmup.find_children("*", "OverlayScreen", true, false).size(), 0, "and gone again")
	assert_false(get_viewport().gui_disable_input, "input is back on")
	if Audio.has_method(&"current_music"):
		assert_eq(Audio.current_music(), music_before, "no shop music was pushed")
