extends GutTest
## Batch 21 (Fable Nov 25, Part 1): the approved pictures are imported and wired - the Table Captain's and the Iron Filing
## Clerk's new card art, a Bestiary square for each of the Shuffled Halls' eight dealers, the Halls' three tokens, the four mode
## emblems of the Shuffle House menu, the two repainted maps (no drawn arc left) and the farm hand's walk cycle.

const DEALERS: Array[String] = ["Maurice, Head of Security", "Tilda Tinsel, Confetti Cannoneer", "Madame Darjeeling",
	"\"Honest\" Hal Lowball", "Dizzy Lizzie, Carousel Queen", "Professor Fineprint", "Dex Shufflewick", "Penny Sleeves"]
const TOKENS: Dictionary = {"Velvet Rope": "TOK-VELVETROPE", "Confetti Critter": "TOK-CONFETTI", "House Security": "TOK-HOUSESECURITY"}


func test_the_card_art_is_in_the_game() -> void:
	for id: String in ["GN-17", "NB-17", "TOK-VELVETROPE", "TOK-CONFETTI", "TOK-HOUSESECURITY"]:
		assert_true(ResourceLoader.exists("res://assets/art/cards/%s.webp" % id), id)


func test_every_dealer_of_the_halls_has_a_portrait_of_their_own() -> void:
	var seen: Dictionary = {}
	for dealer: String in DEALERS:
		var picture: Texture2D = Bestiary.art(dealer)
		assert_not_null(picture, "%s has a Bestiary picture" % dealer)
		if picture == null:
			continue
		assert_true(picture.resource_path.begins_with("res://assets/art/bestiary/BST-"), "%s: %s" % [dealer, picture.resource_path])
		assert_false(seen.has(picture.resource_path), "%s shares no picture" % dealer)
		seen[picture.resource_path] = true


func test_the_three_tokens_of_the_halls_wear_their_own_art() -> void:
	var found: Dictionary = {}
	for path: String in ["res://data/encounters/modifiers.json", "res://data/encounters/encounter_scripts.json"]:
		_collect(JSON.parse_string(FileAccess.get_file_as_string(path)), found)
	for token_name: String in TOKENS.keys():
		assert_true(found.has(token_name), "%s is made somewhere in the Halls" % token_name)
		assert_eq(str(found.get(token_name, "")), "res://assets/art/cards/%s.webp" % str(TOKENS[token_name]), token_name)


func _collect(value: Variant, found: Dictionary) -> void:
	if value is Dictionary:
		var entry: Dictionary = value as Dictionary
		if TOKENS.has(str(entry.get("token_name", ""))):
			found[str(entry["token_name"])] = str(entry.get("token_art", ""))
		for child: Variant in entry.values():
			_collect(child, found)
	elif value is Array:
		for child: Variant in value as Array:
			_collect(child, found)


func test_the_four_mode_emblems_share_one_canvas() -> void:
	var size: Vector2 = Vector2.ZERO
	for id: Variant in DraftHubScreen.MODE_EMBLEMS.values():
		assert_true(UiArt.has(str(id)), "%s is in the game" % str(id))
		var picture: Texture2D = UiArt.texture(str(id))
		if picture == null:
			continue
		if size == Vector2.ZERO:
			size = picture.get_size()
		assert_eq(picture.get_size(), size, "%s has the same canvas as the others" % str(id))
	assert_eq(DraftHubScreen.MODE_EMBLEMS.size(), DraftArena.MODES.size(), "an emblem for every mode")


func test_the_repainted_maps_need_no_drawn_arc() -> void:
	assert_eq(DungeonCatalog.curve_gaps("D-TTK"), [] as Array[String], "the Test Kitchen: landing 9 to 10 is painted")
	assert_eq(DungeonCatalog.curve_gaps("D-SHUFFLE"), [] as Array[String], "the Shuffled Halls: the Counting Room to the Big Wheel is painted")


func test_the_farm_hand_has_a_walk_cycle_in_four_directions() -> void:
	var info: Dictionary = SpriteLibrary.info("DUMPWORKER")
	var walk: Array = info.get("walk_dirs", []) as Array
	for direction: String in ["FRONT", "FRONTSIDE", "SIDE", "BACK"]:
		assert_true(walk.has(direction), "walks %s" % direction)
		for frame: int in range(1, 5):
			assert_true(ResourceLoader.exists("res://assets/art/world_test/sprites/DUMPWORKER/%s_WALK%d.png" % [direction, frame]), "%s_WALK%d" % [direction, frame])
	# the standing frames are the same canvas, so he does not jump when he sets off
	var idle: Texture2D = load("res://assets/art/world_test/sprites/DUMPWORKER/FRONT_IDLE.png") as Texture2D
	var step: Texture2D = load("res://assets/art/world_test/sprites/DUMPWORKER/FRONT_WALK1.png") as Texture2D
	assert_eq(step.get_size(), idle.get_size())
