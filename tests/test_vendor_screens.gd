extends GutTest
## The vendor screens (docs/art/art_pipeline.md, "import key art"): all 12 Vendor Screen IDs of the NPC list have a 16:9 background, a portrait, speech lines, and every vendor shop shows
## its stage (background, portrait, panel, speech bubble) and reacts to a sale.

const IDS: Array[String] = [
	"VS-SABLE", "VS-TONIC", "VS-BEETSWORTH", "VS-THREADWELL", "VS-FENWICK", "VS-ALEMBIC",
	"VS-FIGSLY", "VS-BENCHLEY", "VS-LEDGERBONE", "VS-MIREPOIX", "VS-GRISTLE", "VS-BELLOWS",
]


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	VendorLines.reset()
	KeyArt.reset()


func test_the_sheet_lists_the_twelve_vendors() -> void:
	var ids: Array[String] = VendorLines.screen_ids()
	for id: String in IDS:
		assert_true(ids.has(id), "%s is in the Vendor Screens section" % id)
	assert_eq(ids.size(), 12)


func test_every_vendor_has_a_background_a_portrait_and_lines() -> void:
	for id: String in IDS:
		var texture: Texture2D = KeyArt.texture(id)
		assert_not_null(texture, "%s background" % id)
		if texture != null:
			assert_almost_eq(float(texture.get_width()) / float(texture.get_height()), 16.0 / 9.0, 0.01, "%s is cropped to 16:9" % id)
		var portrait: String = VendorLines.portrait_id(id)
		assert_false(portrait.is_empty(), "%s names a portrait" % id)
		assert_true(Portraits.has_portrait(portrait), "%s portrait art" % id)
		for moment: String in ["open", "buy", "poor"]:
			assert_gt(VendorLines.lines(id, moment).size(), 0, "%s has %s lines" % [id, moment])
		assert_false(VendorLines.notes(id).is_empty(), "%s keeps its UI / Interaction Notes" % id)


func test_the_crop_makes_exact_16_by_9_and_keeps_the_chosen_end() -> void:
	var image: Image = Image.create(1536, 1024, false, Image.FORMAT_RGBA8)
	image.fill(Color.RED)
	image.fill_rect(Rect2i(0, 1000, 1536, 24), Color.BLUE)
	var bottom: Image = KeyArt.crop_16x9(image, 1.0)
	assert_eq(bottom.get_size(), Vector2i(1536, 864))
	assert_eq(bottom.get_pixel(10, 860), Color.BLUE, "bias 1 keeps the bottom")
	var top: Image = KeyArt.crop_16x9(image, 0.0)
	assert_eq(top.get_pixel(10, 860), Color.RED, "bias 0 keeps the top")
	var wide: Image = Image.create(1672, 941, false, Image.FORMAT_RGBA8)
	assert_eq(KeyArt.crop_16x9(wide).get_size(), Vector2i(1672, 941), "already 16:9: untouched")


func _stage_of(screen: OverlayScreen, id: String) -> void:
	add_child_autofree(screen)
	await wait_frames(3)
	assert_not_null(screen.stage, "%s shows its stage" % id)
	assert_eq(screen.vendor_screen_id, id)
	assert_not_null(screen.find_child("ShopBackground", true, false), "%s background" % id)
	assert_not_null(screen.find_child("VendorPortrait", true, false), "%s portrait" % id)
	assert_false(screen.stage.current_line().is_empty(), "%s greets on opening" % id)
	screen.vendor_react("buy")
	assert_false(screen.stage.current_line().is_empty(), "%s answers a sale" % id)


func test_the_town_shops_show_their_stage() -> void:
	var vendor: VendorScreen = VendorScreen.new()
	vendor.vendor_screen_id = "VS-SABLE"
	await _stage_of(vendor, "VS-SABLE")
	await _stage_of(ItemVendorScreen.new(), "VS-TONIC")
	await _stage_of(EquipmentVendorScreen.new(), "VS-BEETSWORTH")
	await _stage_of(TailorScreen.new(), "VS-THREADWELL")
	await _stage_of(PackShopScreen.make(PackData.VENDOR_PACK, "town.pack_vendor"), "VS-FENWICK")
	await _stage_of(AlchemistScreen.new(), "VS-ALEMBIC")
	await _stage_of(ArenaScreen.new(), "VS-BELLOWS")


func test_the_zone_shops_show_their_stage() -> void:
	for id: String in ["VS-BENCHLEY", "VS-LEDGERBONE", "VS-MIREPOIX", "VS-GRISTLE", "VS-FIGSLY"]:
		var vendor: VendorScreen = VendorScreen.new()
		vendor.vendor_screen_id = id
		await _stage_of(vendor, id)


func test_every_zone_def_names_its_vendor_screen() -> void:
	assert_eq(GainlandsZone.build_def().vendor_screen_id, "VS-BENCHLEY")
	assert_eq(DnaZone.build_def().vendor_screen_id, "VS-LEDGERBONE")
	assert_eq(BuffetZone.build_def().vendor_screen_id, "VS-MIREPOIX")
	assert_eq(HeapZone.build_def().vendor_screen_id, "VS-GRISTLE")
	assert_eq(CapitalZone.build_def().vendor_screen_id, "VS-FIGSLY")


func test_a_screen_without_a_vendor_id_keeps_the_plain_look() -> void:
	var plain: VendorScreen = VendorScreen.new()
	add_child_autofree(plain)
	await wait_frames(2)
	assert_null(plain.stage)
	plain.vendor_react("buy")


func test_the_app_icon_files_exist() -> void:
	assert_true(FileAccess.file_exists("res://assets/icon/app_icon.ico"))
	assert_true(FileAccess.file_exists("res://assets/icon/app_icon.icns"))
	assert_true(FileAccess.file_exists("res://assets/icon/app_icon.png"))
