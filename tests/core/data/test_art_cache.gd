extends GutTest
## Size pass Nov 3 (Part 5): the bounded art cache behind UiArt / KeyArt / Portraits / CardArt / Battleboards / MapArt / Bestiary.

var _saved_budget: int = 0


func before_each() -> void:
	_saved_budget = ArtCache.budget_mb
	ArtCache.reset()


func after_each() -> void:
	ArtCache.reset()
	ArtCache.budget_mb = _saved_budget


static func _tex(side: int) -> ImageTexture:
	return ImageTexture.create_from_image(Image.create(side, side, false, Image.FORMAT_RGBA8))


func test_fetch_loads_once_and_returns_the_held_texture() -> void:
	var calls: Array[int] = [0]
	var loader: Callable = func() -> Texture2D:
		calls[0] += 1
		return _tex(8)
	var first: Texture2D = ArtCache.fetch(&"t", "a", loader)
	var second: Texture2D = ArtCache.fetch(&"t", "a", loader)
	assert_eq(calls[0], 1, "loaded once")
	assert_same(first, second)
	assert_true(ArtCache.has(&"t", "a"))
	assert_eq(ArtCache.bytes_held(), 8 * 8 * 4)


func test_missing_art_is_remembered_without_cost() -> void:
	var calls: Array[int] = [0]
	var loader: Callable = func() -> Texture2D:
		calls[0] += 1
		return null
	assert_null(ArtCache.fetch(&"t", "none", loader))
	assert_null(ArtCache.fetch(&"t", "none", loader))
	assert_eq(calls[0], 1, "the disk is asked once")
	assert_true(ArtCache.known(&"t", "none"))
	assert_false(ArtCache.has(&"t", "none"))
	assert_eq(ArtCache.bytes_held(), 0)


func test_the_least_recently_used_entry_goes_first_when_the_budget_is_passed() -> void:
	ArtCache.budget_mb = 1  # 1 MB; a 512x512 RGBA8 texture is exactly 1 MB
	ArtCache.put(&"t", "a", _tex(512))
	ArtCache.put(&"t", "b", _tex(256))  # 0.25 MB -> over budget: a (older) goes
	assert_false(ArtCache.has(&"t", "a"), "a evicted")
	assert_true(ArtCache.has(&"t", "b"), "the newest stays")
	ArtCache.put(&"t", "c", _tex(256))
	ArtCache.put(&"t", "d", _tex(256))
	ArtCache.fetch(&"t", "b", Callable())  # touch b: it is now more recent than c and d
	ArtCache.put(&"t", "e", _tex(256))  # exactly 1 MB held: nothing goes
	assert_true(ArtCache.has(&"t", "c"))
	ArtCache.put(&"t", "f", _tex(256))  # 1.25 MB -> the oldest (c) goes, b was touched so it stays
	assert_false(ArtCache.has(&"t", "c"), "c evicted (oldest)")
	assert_true(ArtCache.has(&"t", "b"), "touched entry kept")
	assert_true(ArtCache.has(&"t", "d"))
	assert_true(ArtCache.has(&"t", "f"), "the entry just put in is never the one evicted")
	assert_eq(ArtCache.evictions, 2)
	assert_eq(ArtCache.bytes_held(), 1048576)


func test_forget_group_drops_only_that_group() -> void:
	ArtCache.put(&"x", "a", _tex(4))
	ArtCache.put(&"y", "a", _tex(4))
	ArtCache.fetch(&"x", "gone", func() -> Texture2D: return null)
	assert_eq(ArtCache.forget_group(&"x"), 1)
	assert_false(ArtCache.has(&"x", "a"))
	assert_false(ArtCache.known(&"x", "gone"), "the missing memo of the group goes too")
	assert_true(ArtCache.has(&"y", "a"))
	assert_eq(ArtCache.bytes_held(), 4 * 4 * 4)


func test_bytes_of_knows_compressed_and_float_formats() -> void:
	assert_eq(ArtCache.bytes_of(null), 0)
	assert_eq(ArtCache.bytes_of(_tex(16)), 16 * 16 * 4, "RGBA8")
	var rgb: ImageTexture = ImageTexture.create_from_image(Image.create(16, 16, false, Image.FORMAT_RGB8))
	assert_eq(ArtCache.bytes_of(rgb), 16 * 16 * 3, "RGB8")
	var atlas: AtlasTexture = AtlasTexture.new()
	atlas.atlas = _tex(16)
	assert_eq(ArtCache.bytes_of(atlas), 0, "an atlas window costs nothing on its own")
	var budget_low: int = ArtCache.budget_for_level(GraphicsQuality.Level.LOW)
	assert_lt(budget_low, ArtCache.budget_for_level(GraphicsQuality.Level.HIGH))
	assert_lt(ArtCache.budget_for_level(GraphicsQuality.Level.LOW, true), budget_low, "Low-end holds less than Low")


func test_the_loaders_share_the_cache_through_their_groups() -> void:
	var fake: ImageTexture = _tex(8)
	ArtCache.put(CardArt.CACHE_GROUP, "TEST-ART-CACHE", fake)
	assert_same(CardArt.texture("TEST-ART-CACHE"), fake)
	ArtCache.put(UiArt.CACHE_GROUP, "UI-TEST-CACHE", fake)
	assert_same(UiArt.texture("UI-TEST-CACHE"), fake)
	assert_true(UiArt.is_cached("UI-TEST-CACHE"))
	UiArt.store("UI-TEST-CACHE", _tex(4))
	assert_same(UiArt.texture("UI-TEST-CACHE"), fake, "store never replaces a held picture")
	var stats: Dictionary = ArtCache.stats()
	assert_eq(int((stats[CardArt.CACHE_GROUP] as Dictionary)["count"]), 1)
	assert_eq(int((stats["_total"] as Dictionary)["count"]), 2)
