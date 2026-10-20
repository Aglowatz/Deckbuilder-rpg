extends GutTest
## Oct 19 night (Part 3): tomorrow's art imports are drop-in - every importer knows the IDs that are arriving (MAP-S-IRON, BB-S-IRON, the Gainlands
## and Verdant Dump zone kits, BST-*, ICON-*), stand-ins show until a file exists, and docs/ is never imported by Godot.


func before_each() -> void:
	Battleboards.reset()
	MapArt.reset()
	DungeonCatalog.reset()


func after_all() -> void:
	Battleboards.reset()


func test_the_iron_cave_names_its_own_map_and_board() -> void:
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.find("S-IRON")
	assert_not_null(plan)
	assert_eq(plan.map_id, "MAP-S-IRON")
	assert_eq(plan.battleboard_id, "BB-S-IRON")


func test_map_and_board_importers_know_the_iron_cave() -> void:
	assert_true(MapArt.known_maps().has("MAP-S-IRON"), "import maps copies MAP-S-IRON")
	var boards: Dictionary = Battleboards.known_boards()
	assert_true(boards.has("BB-S-IRON"), "import battleboards copies BB-S-IRON")
	assert_true(boards.has("BB-LAB"), "every dungeon's board is known")
	assert_true(boards.has("BB-HOG"), "the CSV boards still are")


func test_stand_ins_show_until_the_own_file_exists() -> void:
	assert_true(MapArt.has_map("MAP-S-IRON"), "the Swolympus map stands in")
	assert_true(Battleboards.has_image("BB-S-IRON"), "the Swolympus board stands in")
	if not Battleboards.has_own_image("BB-S-IRON"):
		assert_eq(Battleboards.texture_for("BB-S-IRON"), Battleboards.texture_for("BB-S-BEEF"), "the stand-in board until BB-S-IRON is imported")
	assert_eq(MusicDirector.BOARD_DUNGEON.get("BB-S-IRON", ""), "S-BEEF", "Iron Cave battles keep the cues they had")


func test_zone_kit_sheets_and_folders_for_tomorrow() -> void:
	assert_true(FileAccess.file_exists("res://data/source/gainlands_kit.csv"), "import zone kit gainlands")
	assert_true(FileAccess.file_exists("res://data/source/heap_kit.csv"), "import zone kit heap")
	var config: ConfigFile = ConfigFile.new()
	assert_eq(config.load("res://data/source/art_config.cfg"), OK)
	assert_eq(str((config.get_value("art", "zonekit_folders", {}) as Dictionary).get("heap", "")), "VerdantDump", "the DUMP-* kit lives in Approved_ZoneKits/VerdantDump")
	assert_eq(str(config.get_value("art", "bestiary_dir", "")), "G:/My Drive/Card Game Art/Approved_Bestiary")
	var heap: String = FileAccess.get_file_as_string("res://data/source/heap_kit.csv")
	assert_true(heap.contains("\nDUMP-"), "the heap sheet lists DUMP-* ids")


func test_docs_are_not_imported_as_resources() -> void:
	assert_true(FileAccess.file_exists("res://docs/.gdignore"), "docs/ has a .gdignore (its CSVs were imported as translations)")
	for file_name: String in DirAccess.get_files_at("res://docs/art"):
		assert_false(file_name.ends_with(".translation"), "no stray translation: %s" % file_name)
