extends GutTest
## Batch 19 (Fable Nov 22 night, Part 1): the 8 approved pictures are imported and wired - the repainted castle map (every room on its
## painted landing spot, a drawn line only where the painting has no walkway), the Pantry Mimic's portrait, Auntie Alembic's brewing
## scene and glass jar, the locked Necrocrat parcel, the Buffet's map and the two token pictures of the castle's ally rooms.

## Fable big pass Nov 23: Batch 20 repainted MAP-PC with the eleven walkways that were missing, so no link keeps a drawn line
## (the list stays, empty: every link of the castle is a painted walkway, and its line follows it - tests/test_map_curves.gd).
const DRAWN: Array = []


func test_every_picture_is_in_the_game() -> void:
	for id: String in ["UI-ALEMBIC-BREW", "UI-ALEMBIC-JAR", "UI-PACK-LOCKED-N"]:
		assert_true(UiArt.has(id), "%s is in the game" % id)
	for path: String in ["res://assets/art/bestiary/BST-THE-PANTRY-MIMIC.webp", "res://assets/art/cards/T-PC-TRAINEE.webp",
			"res://assets/art/cards/T-PC-STATUE.webp", "res://assets/art/maps/MAP-PC.webp", "res://assets/art/maps/MAP-WORLD-BUFF.webp"]:
		assert_true(ResourceLoader.exists(path), path)


func test_the_pantry_mimic_wears_its_own_portrait() -> void:
	assert_true(Bestiary.ART_STAND_INS.is_empty(), "nothing borrows a Bestiary square")
	assert_eq(Bestiary.art("The Pantry Mimic").resource_path, "res://assets/art/bestiary/BST-THE-PANTRY-MIMIC.webp")


func test_every_castle_room_sits_on_a_fitted_spot() -> void:
	var fitted: Dictionary = DungeonCatalog.fitted_layout("D-PC")
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.find("D-PC")
	assert_eq(plan.nodes.size(), 22)
	var seen: Array[Vector2] = []
	for node: DungeonCatalog.BlueprintNode in plan.nodes:
		assert_true(fitted.has(str(node.number)), "room %d is fitted" % node.number)
		assert_true(node.position.x > 0.03 and node.position.x < 0.97 and node.position.y > 0.05 and node.position.y < 0.97, "room %d is on the painting" % node.number)
		for other: Vector2 in seen:
			assert_gt(node.position.distance_to(other), 0.1, "no two rooms share a landing spot")
		seen.append(node.position)
		# Batch 21 (Nov 25): the new painting is a portrait cutaway (the gate at the bottom), so every link climbs
		for target: int in node.next:
			assert_lt(plan.node(target).position.y, node.position.y, "%d -> %d climbs" % [node.number, target])


func test_only_the_links_without_a_painted_walkway_keep_a_drawn_line() -> void:
	assert_eq(DungeonCatalog.path_style("D-PC"), "plan")
	var drawn: Dictionary = DungeonCatalog.drawn_links("D-PC")
	# Batch 21 (Nov 25): the portrait painting shows a lattice of stairs, not a walkway for each link, so the castle is no longer
	# listed: as a route-planning map it draws every link (tests/test_castle_map_nov25.gd)
	assert_false(bool(drawn["listed"]))
	var links: Dictionary = drawn["links"] as Dictionary
	assert_eq(links.size(), DRAWN.size())
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.find("D-PC")
	var total: int = 0
	for node: DungeonCatalog.BlueprintNode in plan.nodes:
		total += node.next.size()
	assert_eq(total, 41, "the castle has 41 links")
	for pair: Array in DRAWN:
		assert_true(links.has("%d>%d" % [int(pair[0]) - 1, int(pair[1]) - 1]), "%d -> %d keeps its line" % [pair[0], pair[1]])
		assert_true(plan.node(int(pair[0])).next.has(int(pair[1])), "%d -> %d is a real link" % [pair[0], pair[1]])
	# a map with no list draws every link, as before
	assert_false(bool(DungeonCatalog.drawn_links("D-HOG")["listed"]))


func test_the_ally_rooms_tokens_wear_their_own_pictures() -> void:
	var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/encounters/modifiers.json")) as Dictionary
	var expected: Dictionary = {"Coup Barracks Sergeant": "res://assets/art/cards/T-PC-TRAINEE.webp", "Seed Vault Gardener": "res://assets/art/cards/T-PC-STATUE.webp"}
	for foe: String in expected:
		var found: bool = false
		for rule: Variant in rules[foe] as Array:
			if (rule as Dictionary).has("token_art"):
				found = true
				assert_eq(str((rule as Dictionary)["token_art"]), str(expected[foe]))
				assert_false((rule as Dictionary).has("token_tint"), "no tint over its own picture")
				assert_not_null(CardArt.cropped_override(str(expected[foe]), Vector2(200, 150)), "the picture loads as card art")
		assert_true(found, "%s has a dressed token" % foe)


func test_the_painted_jar_is_see_through_where_the_liquid_shows() -> void:
	var image: Image = UiArt.texture(EssenceJar.JAR_ART).get_image()
	if image.is_compressed():
		image.decompress()
	var size: Vector2 = Vector2(image.get_size())
	var hole: Rect2 = Rect2(EssenceJar.ART_HOLE.position * size, EssenceJar.ART_HOLE.size * size)
	# the middle of the hole and points well inside it are fully transparent; the glass round it is not
	for at: Vector2 in [Vector2(0.5, 0.5), Vector2(0.2, 0.5), Vector2(0.8, 0.5), Vector2(0.5, 0.15), Vector2(0.5, 0.9)]:
		var pixel: Vector2 = hole.position + at * hole.size
		assert_lt(image.get_pixel(int(pixel.x), int(pixel.y)).a, 0.05, "see-through at %s" % str(at))
	assert_gt(image.get_pixel(int(hole.position.x * 0.4), int(hole.get_center().y)).a, 0.9, "the left wall of the glass is painted")
	assert_gt(image.get_pixel(int(size.x * 0.5), int(size.y * 0.06)).a, 0.9, "the cork is painted")
	# the jar is drawn at the picture's own proportions and its hole lies inside the control
	var drawn: Rect2 = EssenceJar.painted_rect(size)
	assert_almost_eq(drawn.size.x / drawn.size.y, size.x / size.y, 0.01)
	assert_true(Rect2(Vector2.ZERO, EssenceJar.SIZE).encloses(EssenceJar.hole_rect(drawn)))


func test_the_brew_panel_shows_the_brewing_scene_and_keeps_its_bubbles() -> void:
	assert_true(UiArt.has(AlchemistScreen.BREW_ART))
	assert_gt(AlchemistScreen.BREW_BUBBLES, 0, "the bubbles of a brew stay")
	var source: String = FileAccess.get_file_as_string("res://ui/town/alchemist_screen.gd")
	assert_true(source.contains("BrewFlash"), "the flash of a brew stays")
