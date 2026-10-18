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
