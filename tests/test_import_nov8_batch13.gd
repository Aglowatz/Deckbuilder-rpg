extends GutTest
## Import Nov 8 (Batch 13): the 23 approved images are in game and wired (docs/overnight_report.md, Part 1).


func test_every_batch13_image_is_imported() -> void:
	for id: String in ["BB-S-GALLERY", "BB-S-GALLERY-ALT"]:
		assert_true(Battleboards.has_own_image(id), id)
	for id: String in ["UI-CAULDRON", "UI-BG-PACKS", "UI-PACK-SHELF", "UI-BG-WARDROBE", "MG-BG-CLASSROOM", "MG-BG-GYM"]:
		assert_true(UiArt.has(id), id)
	for id: String in ["DEC-PLINTH-BEEF", "DEC-PLINTH-NECRO", "DEC-PLINTH-GOUR", "DEC-PLINTH-REF", "LEVER-LOCKED", "LEVER-OPEN", "KIT-HEAP-THORNWALL", "KIT-HEAP-THORNWALL-DEAD"]:
		assert_true(EnvKit.has(id) and EnvKit.has_art(id), id)
	assert_true(IconArt.has("ICON-EQ-MATCHING-PAIR"), "Dex's Matching Pair icon")
	assert_true(Portraits.has_portrait("NPC-DEX"), "Dex's portrait")
	assert_true(SpriteLibrary.has_character("DEX"), "Dex's sprite set")


func test_dex_stands_as_himself() -> void:
	assert_eq(CardMatchCircuit.portrait_id(), "NPC-DEX")
	assert_eq(CardMatchCircuit.sprite_key(), "DEX")


func test_the_gallery_boss_fights_on_the_alt_board() -> void:
	assert_eq(ShatteredGallery.board_for(false, "BB-S-GALLERY"), "BB-S-GALLERY")
	assert_eq(ShatteredGallery.board_for(true, "BB-S-GALLERY"), "BB-S-GALLERY-ALT")
	assert_false(Battleboards.STANDIN_BOARDS.has("BB-S-GALLERY") and not Battleboards.has_own_image("BB-S-GALLERY"), "the castle stand-in drops out")


func test_the_painted_lever_swaps_state() -> void:
	assert_true(LeverKit.has_art())
	var lever: Node3D = LeverKit.build(Color("e2553f"))
	add_child_autofree(lever)
	assert_true(LeverKit.is_painted(lever))
	var locked: Node3D = lever.get_node("Locked") as Node3D
	var open: Node3D = lever.get_node("Open") as Node3D
	assert_true(locked.visible and not open.visible, "locked at first")
	LeverKit.set_pulled(lever, true)
	assert_true(open.visible and not locked.visible, "open when pulled")
	assert_ne(LeverKit.badge_texture(LeverKit.ART_LOCKED, Color.RED), LeverKit.badge_texture(LeverKit.ART_LOCKED, Color.BLUE), "one badge tint per Path")


func test_the_thorn_wall_is_painted_and_breathes() -> void:
	assert_true(HubObstacles.painted_thorns())
	var obstacles: HubObstacles = HubObstacles.new()
	add_child_autofree(obstacles)
	var root: Node3D = Node3D.new()
	obstacles.add_child(root)
	obstacles._thorns(root, "refusemancer", false)
	var holder: Node3D = obstacles.movers["refusemancer"] as Node3D
	assert_true((holder.get_node("Alive") as Node3D).visible)
	assert_false((holder.get_node("Dead") as Node3D).visible)
	assert_eq(obstacles._breathers.size(), 1, "the closed wall breathes")
	obstacles._process(0.8)
	assert_gt((holder.get_node("Alive") as Node3D).scale.y, 1.0)


func test_the_cleared_thorn_wall_is_withered() -> void:
	var obstacles: HubObstacles = HubObstacles.new()
	add_child_autofree(obstacles)
	var root: Node3D = Node3D.new()
	obstacles.add_child(root)
	obstacles._thorns(root, "refusemancer", true)
	var holder: Node3D = obstacles.movers["refusemancer"] as Node3D
	assert_false((holder.get_node("Alive") as Node3D).visible)
	assert_true((holder.get_node("Dead") as Node3D).visible)
	assert_eq(obstacles._breathers.size(), 0)


func test_plinth_statues_cover_the_four_zones() -> void:
	var zones: Array[String] = []
	for spec: Dictionary in TownScene.PLINTH_STATUES:
		zones.append(str(spec["zone"]))
		assert_true(EnvKit.has_art(str(spec["id"])), str(spec["id"]))
	zones.sort()
	assert_eq(zones, ["beefcake", "gourmand", "necrocrat", "refusemancer"] as Array[String])
	# the plinth order matches the crest's icons (EndingDefs.PATH_ICONS: viking head, chef's toque, tree face, stamp)
	assert_eq(EndingDefs.PATH_ICONS.size(), TownScene.PLINTH_STATUES.size())


func test_the_quiz_draws_on_the_painted_board() -> void:
	assert_true(UiArt.has(QuizScreen.CLASSROOM_ART))
	var art: Vector2 = UiArt.texture(QuizScreen.CLASSROOM_ART).get_size()
	assert_almost_eq(art.x / art.y, 1.5, 0.02, "the classroom keeps its 3:2 canvas (the board rect assumes it)")
	assert_true(Rect2(550, 135, 1081, 487).encloses(QuizScreen.PAINTED_BOARD_RECT), "the question stays inside the painted board")
	assert_false(QuizScreen.new().has_method("_build_stand_in"), "the coded room stand-in is gone")


func test_the_shelf_board_is_a_trimmed_strip() -> void:
	var size: Vector2 = UiArt.texture("UI-PACK-SHELF").get_size()
	assert_gt(size.x / size.y, 5.0, "trimmed to the board, not the 3:2 canvas")
	var board: Control = PacksScreen.painted_board(1780.0, PacksScreen.PAINTED_BOARD_HEIGHT)
	assert_not_null(board)
	assert_eq(board.size, Vector2(1780.0, PacksScreen.PAINTED_BOARD_HEIGHT))
	board.free()


func test_the_forest_station_stays_off_the_list_until_rip_opens_it() -> void:
	var flags: Dictionary = {}
	assert_false(FastTravelScreen.shown_station_ids(flags).has(FastTravel.FOREST), "no '???' forest row before Rip's tip")
	flags[str(FastTravel.unlock_flag(FastTravel.FOREST))] = true
	assert_true(FastTravelScreen.shown_station_ids(flags).has(FastTravel.FOREST))
	assert_true(FastTravelScreen.shown_station_ids({}).has(FastTravel.TOWN))
