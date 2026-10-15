extends GutTest
## Zone kits (tools/import_zone_kit.gd, tools/zone_kit_prep.gd, EnvKit zone registries): the sheet slicer finds six items in a 3x2 sheet by its transparent gaps, pivots
## follow the family, the Gainlands registry resolves every id through EnvKit, the zone's material swaps land on real art, and the zone art is not palette-tinted.

const ZonePrep = preload("res://tools/zone_kit_prep.gd")


## A synthetic 3x2 sheet: six opaque blobs of different sizes with clear gaps, slightly off-centre in their cells.
func _sheet(width: int = 300, height: int = 200) -> Image:
	var image: Image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var index: int = 0
	for row: int in range(2):
		for col: int in range(3):
			var cx: int = col * 100 + 50 + (index % 3 - 1) * 6
			var cy: int = row * 100 + 50 + (index % 2) * 5
			var w: int = 40 + index * 5
			var h: int = 50 + (5 - index) * 4
			image.fill_rect(Rect2i(cx - w / 2, cy - h / 2, w, h), Color(0.8, 0.3, 0.2, 1.0))
			index += 1
	return image


func test_slicer_finds_six_items_in_reading_order() -> void:
	var cells: Array[Rect2i] = ZonePrep.slice_grid(_sheet(), 3, 2)
	assert_eq(cells.size(), 6, "six cells")
	var expected_w: Array[int] = [40, 45, 50, 55, 60, 65]
	for index: int in range(6):
		assert_eq(cells[index].size.x, expected_w[index], "cell %d is trimmed to its item (reading order)" % index)
		assert_gt(cells[index].size.y, 20, "cell %d has a height" % index)
	assert_lt(cells[0].position.x, cells[1].position.x, "left to right")
	assert_lt(cells[2].position.y, cells[3].position.y, "top row before bottom row")


func test_slicer_marks_an_empty_cell() -> void:
	var image: Image = _sheet()
	image.fill_rect(Rect2i(200, 100, 100, 100), Color(0, 0, 0, 0))
	var cells: Array[Rect2i] = ZonePrep.slice_grid(image, 3, 2)
	assert_eq(cells[5].size, Vector2i.ZERO, "the empty bottom-right cell is empty")
	assert_gt(cells[4].size.x, 0, "its neighbour is not")


func test_pivots_follow_the_family() -> void:
	var image: Image = Image.create(100, 100, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	image.fill_rect(Rect2i(0, 10, 10, 60), Color(1, 1, 1, 1))  # a bracket post down the left
	image.fill_rect(Rect2i(45, 90, 10, 10), Color(1, 1, 1, 1))  # a trunk at the bottom, right of centre
	var sign_pivot: Vector2 = ZonePrep.pivot_for("sign", image)
	assert_almost_eq(sign_pivot.x, 0.0, 0.001, "a sign pivots at its left plate")
	assert_almost_eq(sign_pivot.y, 0.4, 0.02, "at the plate's middle")
	var tree_pivot: Vector2 = ZonePrep.pivot_for("tree", image)
	assert_almost_eq(tree_pivot.y, 1.0, 0.001, "a tree pivots at the ground")
	assert_almost_eq(tree_pivot.x, 0.5, 0.03, "under its trunk")
	assert_eq(ZonePrep.pivot_for("banner", image), Vector2(0.5, 0.03), "a banner hangs from its pole")
	assert_eq(ZonePrep.pivot_for("decal", image), Vector2(0.5, 0.5), "a decal is centred")
	assert_eq(ZonePrep.pivot_for("prop", image), Vector2(0.5, 1.0), "a prop stands on its base")


func test_groups_from_the_sheet_columns() -> void:
	assert_eq(ZonePrep.group_for("GAIN-WALL-BRICK", "Surface", "Kit material swap for this zone (wall)", "Red brick"), "wall")
	assert_eq(ZonePrep.group_for("GAIN-PATH-CHALK", "Surface", "Kit material swap for this zone (path)", "Chalk track"), "ground")
	assert_eq(ZonePrep.group_for("GAIN-SHEET-BANNERS", "Cutout sheet", "Sliced into kit cutouts (banners)", "Red-gold banners"), "banner")
	assert_eq(ZonePrep.group_for("GAIN-PLANT-HAY", "Tree / plant", "Plant card", "Hay bale stack"), "tree")
	assert_eq(ZonePrep.group_for("GAIN-HERO-WHEEL", "Hero landmark", "Replaces the wheel", "Wheel"), "concept")
	assert_eq(ZonePrep.group_for("GAIN-BD-MOUNT", "Sky / backdrop", "Backdrop ring", "Mount"), "backdrop")
	assert_true(ZonePrep.tiles("1024x1024 PNG, tileable", true) and ZonePrep.tiles("1024x1024 PNG, tileable", false), "tileable both ways")
	assert_true(ZonePrep.tiles("1024x512 PNG, tileable horizontally", true) and not ZonePrep.tiles("1024x512 PNG, tileable horizontally", false), "horizontal only")


func test_gainlands_registry_resolves_through_envkit() -> void:
	var ids: Array[String] = EnvKit.zone_ids("gainlands")
	assert_gt(ids.size(), 50, "the Gainlands registry is loaded (sheet ids plus sheet parts plus aliases)")
	for id: String in ["GAIN-WALL-BRICK", "GAIN-ROOF-RED", "GAIN-SHEET-DOORS-03", "GAIN-SHEET-SIGNS-01", "GAIN-TREE-OAK", "GAIN-PROP-RACK", "GAIN-BD-MOUNT"]:
		assert_true(EnvKit.has(id), "%s is a kit id" % id)
		assert_eq(EnvKit.zone_of(id), "gainlands", "%s belongs to the Gainlands" % id)
		assert_eq(EnvKit.status(id), "art", "%s is real art" % id)
		assert_not_null(EnvKit.texture(id), "%s loads" % id)
	assert_almost_eq(EnvKit.tile_size("GAIN-WALL-BRICK"), 2.56, 0.01, "one texel density with the town kit (400 px/m)")
	assert_not_null(EnvKit.map_texture("GAIN-WALL-BRICK", "n"), "surfaces carry a normal map")
	assert_not_null(EnvKit.map_texture("GAIN-WALL-BRICK", "r"), "and a roughness map")
	assert_almost_eq(EnvKit.pivot("GAIN-SHEET-SIGNS-01").x, 0.0, 0.001, "sliced signs pivot at their bracket")
	assert_almost_eq(EnvKit.pivot("GAIN-TREE-PINE").y, 1.0, 0.001, "trees at the trunk base")
	assert_eq(EnvKit.entry("GAIN-SHEET-DOORS").get("parts", []).size(), 6, "a sheet lists its six parts")
	assert_eq(EnvKit.status("TEX-GAIN-GRASS"), "placeholder", "a painted texture alias has no kit file of its own")
	assert_not_null(EnvKit.texture("TEX-GAIN-GRASS"), "but resolves to the painted texture")


func test_gainlands_swaps_land_on_zone_art_untinted() -> void:
	var previous: String = ZoneStyles.current
	ZoneStyles.use_area("gainlands")
	assert_eq(ZoneStyles.swap("ENV-WALL-TIMBER"), "GAIN-WALL-BLEACH")
	assert_eq(ZoneStyles.swap("ENV-DOOR-03"), "GAIN-SHEET-DOORS-03")
	assert_eq(ZoneStyles.swap("ENV-TREE-PINE"), "GAIN-TREE-PINE")
	var material: StandardMaterial3D = EnvKit.material("ENV-WALL-TIMBER")
	assert_eq(material.resource_name, "GAIN-WALL-BLEACH", "the material is the zone surface")
	assert_eq(material.albedo_color, Color.WHITE, "zone art keeps its painted colours (no palette tint)")
	assert_true(material.normal_enabled, "with its normal map")
	var card: ShaderMaterial = KitFoliage.card_material("ENV-TREE-OAK")
	assert_eq((card.get_shader_parameter("card_tex") as Texture2D).resource_path.get_file(), "GAIN-TREE-OAK.webp", "tree cards swap to the zone trees")
	var path_material: ShaderMaterial = PathTool.surface_material("dirt")
	assert_eq((path_material.get_shader_parameter("surface_tex") as Texture2D).resource_path.get_file(), "GAIN-PATH-CHALK.webp", "dirt paths become chalk tracks")
	ZoneStyles.use_area(previous)
	EnvKit.clear_cache()
	KitFoliage.clear_cache()


func test_buffet_registry_resolves_through_envkit() -> void:
	var ids: Array[String] = EnvKit.zone_ids("buffet")
	assert_gte(ids.size(), 28 + 24, "28 sheet ids, their 24 sheet parts and the painted-texture aliases")
	for id: String in ["BUFF-WALL-BISCUIT", "BUFF-ROOF-COPPER", "BUFF-SHEET-DOORS-02", "BUFF-SHEET-SIGNS-05", "BUFF-SHEET-AWNINGS-03", "BUFF-TREE-BROCCOLI", "BUFF-PLANT-LEEK", "BUFF-PROP-POT", "BUFF-DEC-STEAM", "BUFF-BD-CAKE", "BUFF-SKY-DINNER"]:
		assert_true(EnvKit.has(id), "%s is in the registry" % id)
		assert_eq(EnvKit.zone_of(id), "buffet", "%s belongs to the Buffet" % id)
		assert_true(EnvKit.has_art(id), "%s has its file" % id)
	assert_almost_eq(EnvKit.tile_size("BUFF-WALL-BISCUIT"), 2.56, 0.01, "one texel density with the town kit (400 px/m)")
	assert_not_null(EnvKit.map_texture("BUFF-WALL-OVEN", "n"), "surfaces carry a normal map")
	assert_almost_eq(EnvKit.pivot("BUFF-SHEET-SIGNS-01").x, 0.0, 0.001, "sliced signs pivot at their bracket")
	assert_almost_eq(EnvKit.pivot("BUFF-TREE-CAULI").y, 1.0, 0.001, "trees at the trunk base")
	assert_almost_eq(EnvKit.pivot("BUFF-DEC-FLOUR").y, 0.5, 0.001, "decals are centred")
	assert_eq(EnvKit.entry("BUFF-SHEET-AWNINGS").get("parts", []).size(), 6, "the awning sheet lists its six parts")
	assert_eq(EnvKit.status("TEX-BUFF-MASHED"), "placeholder", "a painted texture alias has no kit file of its own")
	assert_not_null(EnvKit.texture("TEX-BUFF-MASHED"), "but resolves to the painted texture")
	assert_false(bool(EnvKit.entry("BUFF-WALL-BISCUIT").get("tinted", true)), "zone art is untinted")
