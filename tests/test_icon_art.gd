extends GutTest
## The icon set (IconArt): CSV ids, placeholder rows skipped, crisp size picking, every id imported with its sized variants.


func test_known_ids_skip_placeholders() -> void:
	var known: Dictionary = IconArt.known_ids()
	assert_true(known.has("ICON-KW-FLYING"))
	assert_false(known.has("ICON-GEAR-OTHERS"))
	assert_false(known.has("ICON-ITEM-OTHERS"))
	assert_false(known.has("ICON-HAT-OTHERS"))


func test_best_size_picks_the_smallest_variant_that_fits() -> void:
	assert_eq(IconArt.best_size(20.0), 24)
	assert_eq(IconArt.best_size(32.0), 32)
	assert_eq(IconArt.best_size(40.0), 48)
	assert_eq(IconArt.best_size(60.0), 64)
	assert_eq(IconArt.best_size(100.0), 128)
	assert_eq(IconArt.best_size(90.0), 96)
	assert_eq(IconArt.best_size(300.0), 0, "bigger than every variant uses the master")


func test_every_known_icon_is_imported_with_variants() -> void:
	for id: Variant in IconArt.known_ids().keys():
		assert_true(IconArt.has(str(id)), "%s master" % id)
		for size: int in IconArt.SIZES:
			assert_true(ResourceLoader.exists(IconArt.path_for(str(id), size)), "%s_%d" % [id, size])


func test_missing_icon_returns_null_so_callers_keep_their_fallback() -> void:
	assert_null(IconArt.texture("ICON-DOES-NOT-EXIST", 32.0))
	assert_null(IconArt.rect("ICON-DOES-NOT-EXIST", 32.0))
	assert_eq(IconArt.bbcode("ICON-DOES-NOT-EXIST", 16), "")
	assert_true(IconArt.bbcode("ICON-GOLD", 16).begins_with("[img=16x16]"))
