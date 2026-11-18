extends GutTest
## Nov 18 day, Part 5: (1) an empty gear slot shows one normal line under OWNED, across and wrapped (it was a label squeezed into the
## ScrollContainer beside the grid, written one letter per line); (2) the Deck Station is a card-trader's stall on the square at the
## Gate Road's mouth, with a "Deck Station" label and a deck icon on the map.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_every_empty_gear_slot_says_so_in_one_wrapped_line() -> void:
	for slot: EquipmentData.Slot in [EquipmentData.Slot.HELM, EquipmentData.Slot.WEAPON, EquipmentData.Slot.ARMOR, EquipmentData.Slot.BOOTS, EquipmentData.Slot.RELIC]:
		var text: String = CharacterScreen.empty_slot_text(slot)
		assert_string_contains(text, "You don't own any")
		assert_string_contains(text, "chests and shops")
	var source: String = FileAccess.get_file_as_string("res://ui/town/character_screen.gd")
	var block: String = source.get_slice("if pieces.is_empty():", 1).get_slice("_divider(page, 690.0", 0)
	assert_false(block.contains("scroll.add_child(none)"), "never a second child of the scroll box (that squeezed it to one letter wide)")
	assert_true(block.contains("page.add_child(none)"))
	assert_true(block.contains("custom_minimum_size = Vector2(width - 56"), "the line spans the list's width")


func test_the_deck_station_is_a_stall_on_the_square() -> void:
	var deck: TownLayout.Shop = null
	for shop: TownLayout.Shop in TownLayout.shops():
		if shop.key == "deck":
			deck = shop
	assert_not_null(deck)
	assert_eq(deck.kind, "bare", "a stall the builder makes, not a house")
	var plaza: Vector3 = TownLayout.PLAZA
	assert_lt(Vector2(deck.center.x - plaza.x, deck.center.z - plaza.z).length(), TownLayout.PLAZA_RADIUS, "it stands on the square")
	assert_lt(absf(deck.door_spot().x - TownLayout.roads()["gate_road"][0].x), 6.0, "by the Gate Road's mouth, where new players walk down")
	assert_eq(deck.door_spot(), TownCardStall.door_spot(), "the interaction spot is in front of the counter")


func test_the_stall_is_built_from_kit_pieces_with_the_card_sign() -> void:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	var obstacles: Array[Vector3] = []
	var stall: Node3D = TownCardStall.build(root, TownCardStall.CENTER, TownCardStall.YAW, obstacles)
	assert_not_null(stall.find_child("Stall", true, false), "the kit market stall")
	assert_not_null(stall.find_child("CardSign", true, false), "the hanging card sign")
	assert_not_null(stall.find_child("CardBack0", true, false), "cards on the counter")
	assert_gte(obstacles.size(), 3, "it blocks the hero like any stall")
	for circle: Vector3 in obstacles:
		assert_gt(Vector2(circle.x - TownCardStall.door_spot().x, circle.y - TownCardStall.door_spot().z).length(), circle.z + 0.4, "the spot in front stays free")


func test_the_map_shows_the_deck_station_with_its_icon() -> void:
	assert_eq(TownScene.DECK_STATION_LABEL, "Deck Station")
	assert_true(IconArt.has(TownScene.DECK_STATION_ICON), "the deck icon exists")
	assert_eq(int(TownScene.POI_KINDS["deck"]), int(MapPoi.Kind.VENDOR), "a shop pin")
