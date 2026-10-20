extends GutTest
## Oct 19 night (Part 3): the own-icon ID conventions (ICON-GEAR-* / ICON-ITEM-* / ICON-COS-*), the expected IDs generated from the game data, the
## forgiving file-name match and the drop-in import of those icons (copy only, sized variants, the source folder untouched).

const SOURCE: String = "user://icon_dropin_test/source"
const OUT: String = "user://icon_dropin_test/out"
const MANIFEST: String = "user://icon_dropin_test/manifest.csv"


func before_each() -> void:
	IconArt.reset()
	_clean()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SOURCE))


func after_all() -> void:
	_clean()
	IconArt.reset()


func _clean() -> void:
	for dir: String in [SOURCE, OUT]:
		var real: String = ProjectSettings.globalize_path(dir)
		if DirAccess.dir_exists_absolute(real):
			for file_name: String in DirAccess.get_files_at(real):
				DirAccess.remove_absolute(real.path_join(file_name))
	var manifest: String = ProjectSettings.globalize_path(MANIFEST)
	if FileAccess.file_exists(manifest):
		DirAccess.remove_absolute(manifest)


func _save(file_name: String) -> void:
	var image: Image = Image.create(96, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	image.fill_rect(Rect2i(20, 10, 50, 40), Color(0.8, 0.3, 0.2))
	image.save_png(ProjectSettings.globalize_path(SOURCE.path_join(file_name)))


func test_gear_icon_ids_follow_the_upper_case_no_underscore_rule() -> void:
	assert_eq(IconArt.gear_icon_id("lucky_sock"), "ICON-GEAR-LUCKYSOCK")
	assert_eq(IconArt.gear_icon_id("glass_jaw_gauntlets"), "ICON-GEAR-GLASSJAWGAUNTLETS")
	assert_eq(IconArt.gear_icon_id("starter_blade"), "ICON-GEAR-STARTERBLADE")
	for piece_id: Variant in IconArt.EQUIPMENT_IDS:
		assert_eq(IconArt.gear_icon_id(str(piece_id)), "ICON-GEAR-" + str(piece_id).to_upper().replace("_", ""), "the ten named pieces follow the same rule: %s" % piece_id)


func test_item_and_cosmetic_icon_ids() -> void:
	assert_eq(IconArt.item_icon_id("healing_draught"), "ICON-ITEM-HEALINGDRAUGHT")
	assert_eq(IconArt.item_icon_id("bag_of_rubbish"), "ICON-ITEM-BAGOFRUBBISH")
	assert_eq(IconArt.cosmetic_icon_id("WIDEBRIM"), "ICON-COS-WIDEBRIM")
	assert_eq(IconArt.cosmetic_icon_id("REDCAPE"), "ICON-COS-REDCAPE")
	var seen: Dictionary = {}
	for item: CosmeticData in CosmeticCatalog.all():
		assert_ne(item.art_name, "", "%s has an art name" % item.id)
		var id: String = IconArt.cosmetic_icon_id(item.art_name)
		assert_false(seen.has(id), "%s is one hat or cloak only" % id)
		seen[id] = true


func test_every_gear_item_and_cosmetic_has_one_expected_icon_id() -> void:
	var game: Dictionary = IconArt.game_ids()
	var pieces: int = 0
	for dir_path: String in IconArt.GAME_EQUIPMENT_DIRS:
		for file_name: String in DirAccess.get_files_at(dir_path):
			if file_name.trim_suffix(".remap").ends_with(".tres"):
				pieces += 1
	var items: int = 0
	for file_name: String in DirAccess.get_files_at("res://data/items/"):
		if file_name.trim_suffix(".remap").ends_with(".tres"):
			items += 1
	assert_eq(IconArt.game_ids_with_prefix(IconArt.GEAR_PREFIX).size(), pieces, "one gear icon per piece, no two pieces share an ID")
	assert_eq(IconArt.game_ids_with_prefix(IconArt.ITEM_PREFIX).size(), items, "one item icon per consumable")
	assert_eq(IconArt.game_ids_with_prefix(IconArt.COSMETIC_PREFIX).size(), CosmeticCatalog.all().size(), "one shop icon per hat / cloak")
	for id: String in ["ICON-GEAR-LUCKYSOCK", "ICON-GEAR-WICKEDDAGGER", "ICON-ITEM-HEALINGDRAUGHT", "ICON-COS-WIDEBRIM", "ICON-COS-ROYAL"]:
		assert_true(game.has(id), id)


func test_the_importer_accepts_the_csv_and_every_game_id() -> void:
	var accepted: Dictionary = IconArt.import_ids()
	assert_true(accepted.has("ICON-KW-FLYING"), "the CSV IDs")
	assert_true(accepted.has("ICON-GEAR-LUCKYSOCK"), "ICON-GEAR-LUCKYSOCK is never 'matches no ID'")
	assert_true(accepted.has("ICON-ITEM-SPICEPOUCH"))
	assert_true(accepted.has("ICON-COS-TRICORN"))
	assert_false(accepted.has("ICON-GEAR-OTHERS"), "placeholder rows stay out")


func test_file_names_match_forgivingly() -> void:
	var known: Dictionary = {"ICON-GEAR-LUCKYSOCK": "", "ICON-ITEM-HEALINGDRAUGHT": "", "ICON-COS-WIDEBRIM": "", "ICON-KW-FLYING": ""}
	assert_eq(IconArt.file_icon_id("ICON-GEAR-LUCKYSOCK", known), "ICON-GEAR-LUCKYSOCK")
	assert_eq(IconArt.file_icon_id("ICON-GEAR-LUCKY-SOCK", known), "ICON-GEAR-LUCKYSOCK")
	assert_eq(IconArt.file_icon_id("icon-item-healing_draught", known), "ICON-ITEM-HEALINGDRAUGHT")
	assert_eq(IconArt.file_icon_id("ICON-COS-HAT-WIDEBRIM", known), "ICON-COS-WIDEBRIM")
	assert_eq(IconArt.file_icon_id("ICON-COS-WIDE-BRIM", known), "ICON-COS-WIDEBRIM")
	assert_eq(IconArt.file_icon_id("icon-kw-flying", known), "ICON-KW-FLYING")
	assert_eq(IconArt.file_icon_id("ICON-GEAR-NOPE", known), "")


func test_drop_in_import_of_gear_item_and_cosmetic_icons() -> void:
	_save("ICON-GEAR-LUCKY-SOCK.png")
	_save("ICON-ITEM-HEALINGDRAUGHT.png")
	_save("ICON-COS-REDCAPE.png")
	_save("ICON-NOPE.png")
	var known: Dictionary = {"ICON-GEAR-LUCKYSOCK": "Gear", "ICON-ITEM-HEALINGDRAUGHT": "Item", "ICON-COS-REDCAPE": "Cloak", "ICON-COS-ROYAL": "Cloak"}
	var result: IconArt.Result = IconArt.import_from_source(ProjectSettings.globalize_path(SOURCE), OUT, MANIFEST, known)
	assert_eq(result.added.size(), 3)
	assert_eq(result.renamed, ["ICON-GEAR-LUCKY-SOCK.png -> ICON-GEAR-LUCKYSOCK"] as Array[String])
	assert_eq(result.unknown, ["ICON-NOPE.png"] as Array[String])
	assert_eq(result.missing, ["ICON-COS-ROYAL"] as Array[String])
	for id: String in ["ICON-GEAR-LUCKYSOCK", "ICON-ITEM-HEALINGDRAUGHT", "ICON-COS-REDCAPE"]:
		var master: Image = Image.load_from_file(ProjectSettings.globalize_path(OUT.path_join("%s.webp" % id)))
		assert_eq(master.get_size(), Vector2i(IconArt.MASTER_SIDE, IconArt.MASTER_SIDE), "%s is squared like every icon" % id)
		for size: int in IconArt.SIZES:
			assert_true(FileAccess.file_exists(ProjectSettings.globalize_path(OUT.path_join("%s_%d.webp" % [id, size]))), "%s_%d" % [id, size])
	assert_eq(DirAccess.get_files_at(ProjectSettings.globalize_path(SOURCE)).size(), 4, "the source folder is untouched")


func test_items_and_cosmetics_keep_their_old_look_until_their_icon_exists() -> void:
	var item: ItemData = load("res://data/items/healing_draught.tres") as ItemData
	if IconArt.has_item_icon(item):
		assert_eq(IconArt.item_texture(item, 64.0), IconArt.texture(IconArt.item_icon_id(item.id), 64.0), "its own icon once imported")
	else:
		assert_eq(IconArt.item_texture(item, 64.0), CardIcons.for_item(item), "the old game-icons picture until then")
		var glyph: TextureRect = IconArt.item_glyph(item, Color.WHITE, 40.0)
		assert_not_null(glyph.material, "the old tinted silhouette")
		glyph.free()
	var hat: CosmeticData = CosmeticCatalog.find("hat_wide_brim")
	if not IconArt.has(IconArt.cosmetic_icon_id(hat.art_name)):
		assert_null(IconArt.cosmetic_texture(hat, 52.0), "no shop icon yet: the screens keep their sprite-library picture")
