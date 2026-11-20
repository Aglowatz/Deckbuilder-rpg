extends GutTest
## Batch 18 (Nov 20): the 39 approved pictures are imported and wired - the two cards, the Arena's cave menu and board, the
## Doppelganger pair, the Raw Deal's front and sign, the Plain Cloak, the violet Necrocrat back and packs, the D.N.A.'s clock tower,
## hourglass plaque and couch, Rip's two three-quarter views, the cave mouth, the manhole, the five zone maps, Alembic's shop and the
## 14 stained-glass pieces of the info screens.

const KIT_IDS: Array[String] = [
	"DNA-HERO-CLOCK-TOWER", "DNA-SIGN-HOURGLASS", "DNA-PROP-HEAL-COUCH", "BUFF-HERO-RAWDEAL-FRONT", "BUFF-SIGN-RAWDEAL",
	"CAP-PROP-SERVICE-MANHOLE", "TOWN-PROP-CAVE-MOUTH-BRUSH",
]
const UI_IDS: Array[String] = [
	"UI-CARDBACK-N", "UI-PACK-N", "UI-PACK-LOCKED-N", "UI-INFO-PAGE", "UI-GLASS-STRIP", "UI-GLASS-PANE", "UI-GLASS-PANE-LIT",
	"UI-ROSE-WINDOW", "UI-INFO-DIVIDER", "UI-BTN-AMBER", "UI-BTN-GLASS", "UI-QUESTBOX", "UI-INFO-TOOLTIP", "UI-MAP-FRAME",
	"UI-QUEST-MARKS", "UI-SCROLL-RAIL", "UI-SCROLL-GRIP",
]
const KEY_ART_IDS: Array[String] = ["ARENA-MENU-BG", "VS-ALEMBIC", "STORY-REVEAL-KITCHEN", "STORY-DOPPEL"]
const ZONE_MAPS: Dictionary = {"beefcake": "MAP-WORLD-GAIN", "gourmand": "MAP-WORLD-BUFF", "refusemancer": "MAP-WORLD-DUMP", "necrocrat": "MAP-WORLD-DNA", "final": "MAP-WORLD-CAP"}


func test_every_piece_is_imported() -> void:
	for id: String in KIT_IDS:
		assert_true(EnvKit.has_art(id), "%s is in the game" % id)
	for id: String in UI_IDS:
		assert_true(UiArt.has(id), "%s is in the game" % id)
	for id: String in KEY_ART_IDS:
		assert_true(KeyArt.has(id), "%s is in the game" % id)
	assert_true(IconArt.has(IconArt.PLAIN_CLOAK_ICON))
	for id: String in ["B-37", "C-36"]:
		assert_true(ResourceLoader.exists(CardArt.path_for(id)), "%s has its own painting" % id)
		assert_true(CardArt.path_for(id).ends_with("cards/%s.webp" % id), "and no borrowed picture stands in")
	assert_true(ResourceLoader.exists("res://assets/art/battleboards/BB-ARENA.webp"))


func test_the_violet_necrocrat_back_is_not_green() -> void:
	# the old back's corner fields were green (they read as the Refusemancer back); the new ones are violet: more blue than green
	var image: Image = UiArt.texture("UI-CARDBACK-N").get_image()
	if image.is_compressed():
		image.decompress()
	var size: Vector2i = image.get_size()
	var sum: Color = Color(0, 0, 0)
	var count: int = 0
	for y: int in range(int(size.y * 0.11), int(size.y * 0.2), 3):
		for x: int in range(int(size.x * 0.2), int(size.x * 0.34), 3):
			sum += image.get_pixel(x, y)
			count += 1
	assert_gt(sum.b / float(count), sum.g / float(count), "the top-left field is violet")


func test_the_arena_menu_sits_in_its_cave() -> void:
	assert_eq(VendorStage.backdrop_for("VS-BELLOWS"), "ARENA-MENU-BG", "the Arena menu's backdrop is the cave under Crosspath")
	assert_eq(VendorStage.backdrop_for("VS-SABLE"), "VS-SABLE", "every other vendor keeps its own picture")
	assert_eq(KeyArt.kind_of("ARENA-MENU-BG"), KeyArt.Kind.VENDOR)


func test_the_plain_cloak_has_its_own_picture_tinted_by_the_dye() -> void:
	assert_not_null(IconArt.plain_cloak_texture(64.0))
	assert_eq(IconArt.plain_cloak_tint(Dye.NATURAL), IconArt.PLAIN_CLOAK_TEAL, "undyed: the hero's own teal")
	var dyed: Color = IconArt.plain_cloak_tint(0)
	assert_almost_eq(dyed.h, Dye.primary(0).h, 0.02, "dyed: the dye's own hue")


func test_rip_turns_through_eight_directions() -> void:
	assert_true(SpriteLibrary.has_character("RIP"))
	for frame: String in ["FRONTSIDE_IDLE", "BACKSIDE_IDLE"]:
		assert_true(ResourceLoader.exists("res://assets/art/world_test/sprites/RIP/%s.png" % frame), "Rip's %s" % frame)
		assert_true(ResourceLoader.exists("res://assets/art/world_test/sprites/RIP/%s_n.png" % frame), "and its normal map")
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/art/world_test/sprites/manifest.json")) as Dictionary
	var dirs: Array = (manifest["RIP"] as Dictionary)["dirs"] as Array
	assert_eq(dirs.size(), 5, "five drawn views; the other three are their mirrors")
	assert_true(dirs.has("FRONTSIDE") and dirs.has("BACKSIDE"))


func test_rip_faces_each_of_the_eight_directions_with_its_own_view() -> void:
	var camera: Camera3D = Camera3D.new()
	add_child_autofree(camera)
	camera.position = Vector3(0, 3, 8)
	camera.look_at(Vector3.ZERO)
	camera.current = true
	var sprite: WorldSprite = WorldSprite.new()
	add_child_autofree(sprite)
	assert_true(sprite.setup("RIP", camera))
	# heading (x, z) -> the frame shown and whether it is mirrored. The art looks to the screen's left; +z is toward the camera.
	var cases: Array = [
		[Vector3(0, 0, 1), "FRONT_IDLE", false], [Vector3(-1, 0, 1), "FRONTSIDE_IDLE", false], [Vector3(-1, 0, 0), "SIDE_IDLE", false],
		[Vector3(-1, 0, -1), "BACKSIDE_IDLE", false], [Vector3(0, 0, -1), "BACK_IDLE", false], [Vector3(1, 0, -1), "BACKSIDE_IDLE", true],
		[Vector3(1, 0, 0), "SIDE_IDLE", true], [Vector3(1, 0, 1), "FRONTSIDE_IDLE", true],
	]
	var seen: Dictionary = {}
	for entry: Array in cases:
		sprite.snap_heading(entry[0] as Vector3)
		sprite.current_dir = ""
		for step: int in range(3):
			sprite.follow(Vector3.ZERO, 0.05)
		assert_eq(sprite.current_key, str(entry[1]), "heading %s shows %s" % [str(entry[0]), str(entry[1])])
		assert_eq(sprite.current_flip, bool(entry[2]), "heading %s mirrored: %s" % [str(entry[0]), str(entry[2])])
		seen["%s|%s" % [sprite.current_key, str(sprite.current_flip)]] = true
	assert_eq(seen.size(), 8, "eight different pictures round the circle")


func test_the_five_zone_maps_are_painted_and_fitted() -> void:
	var fit: Dictionary = (JSON.parse_string(FileAccess.get_file_as_string("res://data/maps/world_map_fit.json")) as Dictionary)["maps"] as Dictionary
	for area: String in ZONE_MAPS:
		assert_true(FullMapScreen.has_painted_map(area), "%s has a painted map" % area)
		var spec: Dictionary = FullMapScreen.PAINTED_MAPS[area] as Dictionary
		assert_true(str(spec["path"]).ends_with("%s.webp" % ZONE_MAPS[area]))
		var rect: Rect2 = spec["rect"] as Rect2
		var measured: Array = (fit[area] as Dictionary)["rect"] as Array
		assert_almost_eq(rect.position.x, float(measured[0]), 0.01, "%s: the rectangle is the measured one" % area)
		assert_almost_eq(rect.position.y, float(measured[1]), 0.01)
		assert_almost_eq(rect.size.x, float(measured[2]), 0.01)
		assert_almost_eq(rect.size.y, float(measured[3]), 0.01)
		assert_almost_eq(rect.size.x / rect.size.y, 1.0, 0.1, "%s: a square painting stays close to square in the world" % area)


func test_each_zone_map_covers_its_walkable_ground() -> void:
	var layouts: Dictionary = {"gourmand": BuffetLayout.new(), "necrocrat": DnaLayout.new()}
	for area: String in layouts:
		var layout: Variant = layouts[area]
		layout.build()
		var rect: Rect2 = (FullMapScreen.PAINTED_MAPS[area] as Dictionary)["rect"] as Rect2
		for key: Variant in layout.anchors:
			var at: Vector3 = layout.anchors[key] as Vector3
			assert_true(rect.has_point(Vector2(at.x, at.z)), "%s: %s (%.1f, %.1f) lies on the painting" % [area, str(key), at.x, at.z])


func test_the_dna_pieces_are_the_painted_ones() -> void:
	assert_eq(DnaBuilder.CLOCK_TOWER_ART, "DNA-HERO-CLOCK-TOWER")
	assert_gt(DnaBuilder.CLOCK_TOWER_ART_H * 0.8, DnaHall.HALL_H, "the painted clock face stands over the building fronts")
	var couch: Node3D = DnaProps.heal_couch()
	assert_true(couch.has_meta(&"painted_couch"), "the couch is the painted card")
	assert_eq(couch.name, &"HealCouch", "same node name: the heal spot and its glow find it")
	assert_not_null(couch.find_child("Kit_DNA-PROP-HEAL-COUCH", true, false))
	couch.free()


func test_the_raw_deal_way_in_is_the_painted_freezer_door() -> void:
	var layout: BuffetLayout = BuffetLayout.new()
	layout.build()
	var door: Vector3 = layout.anchors["mini_dungeon"] as Vector3
	var left: float = BuffetLayout.OMAKASE_PAVILION.x - BuffetLayout.RAWDEAL_FRONT_WIDTH * 0.5
	var across: float = (door.x - left) / BuffetLayout.RAWDEAL_FRONT_WIDTH
	assert_almost_eq(across, BuffetLayout.RAWDEAL_DOOR_AT, 0.01, "the way in stands at the painted door (the left of the base)")
	assert_lt(across, 0.4, "left of the middle")
	assert_gt(door.z, BuffetLayout.OMAKASE_PAVILION.y + BuffetLayout.OMAKASE_PAVILION_SIZE.z * 0.5, "in front of the picture")
	var sign_at: Vector3 = Vector3.ZERO
	for sign: BuffetLayout.Sign in layout.signs:
		if sign.key == "sign.mini_dungeon":
			sign_at = sign.pos
	assert_lt(absf(sign_at.x - door.x), 3.0, "its sign hangs beside the door")


func test_the_painted_manhole_lies_flat() -> void:
	var manhole: Node3D = CapitalProps.service_manhole()
	var picture: MeshInstance3D = manhole.get_node_or_null("PaintedManhole") as MeshInstance3D
	assert_not_null(picture, "the painted cover")
	if picture != null:
		assert_almost_eq(absf(picture.global_transform.basis.z.normalized().y) if picture.is_inside_tree() else absf(picture.transform.basis.z.normalized().y), 1.0, 0.01, "it lies on the ground")
	manhole.free()


func test_the_cave_mouth_is_one_painted_piece() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var obstacles: Array[Vector3] = []
	var mouth: Node3D = TownCaveMouth.build(host, obstacles)
	assert_not_null(mouth.find_child("Kit_%s" % TownCaveMouth.PAINTED, true, false), "the painted mouth in the brush")
	assert_null(mouth.find_child("Kit_OF-PROP-BRAMBLES", true, false), "the assembled brambles are gone")
	assert_not_null(mouth.get_node_or_null("LanternGlow"))
	assert_eq(obstacles.size(), 3, "it still blocks")
