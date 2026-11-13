extends GutTest
## Batch 15 (Nov 13): the 39 approved images are imported and wired - the Capital's painted windows, easel portraits, rubble row and freed-city
## banners / lanterns / fireworks, the Buffet stalls, the D.N.A. serving orb, the Dump's raccoon statue and mill sails, the two icons, Dex's
## table and card back, the battle item slots, the locked packs, the pop-up banner, the credits panorama and Elowen's walk.

const CAPITAL_IDS: Array[String] = [
	"CAP-SHEET-WINDOWS-07", "CAP-SHEET-WINDOWS-08", "CAP-BANNER-FREED-01", "CAP-BANNER-FREED-02", "CAP-BANNER-FREED-03", "CAP-BANNER-FREED-04",
	"CAP-BD-LANTERNS", "CAP-FX-FIREWORKS", "CAP-PROP-PORTRAIT-PRIMM-01", "CAP-PROP-PORTRAIT-PRIMM-02", "CAP-PROP-PORTRAIT-PRIMM-03", "CAP-PROP-RUBBLE-ROW",
]
const ZONE_IDS: Array[String] = ["BUFF-PROP-STALL-01", "BUFF-PROP-STALL-02", "DNA-PROP-SERVING-ORB", "DUMP-HERO-RACCOON-STATUE", "DUMP-PROP-MILL-SAILS", "GAIN-GROUND-MAT"]
const UI_IDS: Array[String] = [
	"MG-BG-MATCHTABLE", "UI-CARDBACK-DEX", "UI-BATTLE-ITEMSLOT-EMPTY", "UI-BATTLE-ITEMSLOT-READY", "UI-PACK-LOCKED-B", "UI-PACK-LOCKED-G",
	"UI-PACK-LOCKED-N", "UI-PACK-LOCKED-R", "UI-NODE-BANNER",
]


func test_every_kit_piece_is_imported() -> void:
	for id: String in CAPITAL_IDS + ZONE_IDS:
		assert_true(EnvKit.has_art(id), "%s is in the game" % id)


func test_every_ui_piece_is_imported() -> void:
	for id: String in UI_IDS:
		assert_true(UiArt.has(id), "%s is in the game" % id)
	assert_true(KeyArt.has("STORY-CREDITS-PANORAMA"))
	var panorama: Texture2D = KeyArt.texture("STORY-CREDITS-PANORAMA")
	assert_almost_eq(float(panorama.get_width()) / float(panorama.get_height()), 3.0, 0.05, "the panorama keeps its 3:1 shape (never cropped to 16:9)")


func test_the_two_icons_replace_their_placeholders() -> void:
	for id: String in ["hall_pass_slippers", "earned_blade"]:
		var piece: EquipmentData = Session.content.equipment_piece(id)
		assert_not_null(piece)
		assert_true(IconArt.has_equipment_icon(piece), "%s shows its own icon" % id)
	assert_true(IconArt.has("ICON-EQ-HALLPASSSLIPPERS"))
	assert_true(IconArt.has("ICON-GEAR-EARNEDBLADE"))
	assert_false(IconArt.PLACEHOLDER_GEAR.has("hall_pass_slippers"), "the slippers need no stand-in any more")


func test_elowen_walks_in_five_directions_and_the_disguise_borrows_her_walk() -> void:
	var info: Dictionary = SpriteLibrary.info("ELOWEN")
	assert_eq((info["walk_dirs"] as Array).size(), 5, "front, front-side, side, back-side, back")
	assert_eq((info["dirs"] as Array).size(), 3, "her idles are unchanged")
	for dir_name: String in ["FRONT", "FRONTSIDE", "SIDE", "BACKSIDE", "BACK"]:
		for frame: int in range(1, 5):
			assert_true((info["frames"] as Array).has("%s_WALK%d" % [dir_name, frame]), "%s walk frame %d" % [dir_name, frame])
			assert_true(ResourceLoader.exists("res://assets/art/world_test/sprites/ELOWEN/%s_WALK%d_n.png" % [dir_name, frame]), "its normal map")
	var walker: Dictionary = SpriteLibrary.info("TOWNSFOLK_A")
	assert_eq(float(info["fig_h"]), float(walker["fig_h"]), "the same figure scale as the walkers and her own idle")
	# the disguise set has no walk: a disguised Rescuer gets Elowen's set when she walks off
	var actor: SpriteActor = NpcSprites.make_actor(RescuerDisguise.SPRITE)
	add_child_autofree(actor)
	assert_true(actor.sprite.walk_dirs().is_empty(), "the disguise has no walk frames of its own")
	assert_true(NpcSprites.use_walk_set(actor))
	assert_eq(actor.sprite.walk_dirs().size(), 5)
	assert_false(NpcSprites.use_walk_set(actor), "a set that can walk is left alone")


func test_a_moving_elowen_plays_her_walk_and_idles_when_she_stops() -> void:
	var camera: Camera3D = Camera3D.new()
	add_child_autofree(camera)
	camera.position = Vector3(0, 3, 8)
	camera.look_at(Vector3.ZERO)
	camera.current = true
	var sprite: WorldSprite = WorldSprite.new()
	add_child_autofree(sprite)
	assert_true(sprite.setup("ELOWEN", camera))
	# walking away and to the left of the camera: the back three-quarter walk, not mirrored (the sheets face left)
	var pos: Vector3 = Vector3.ZERO
	for step: int in range(20):
		pos += Vector3(-0.7, 0.0, -0.7).normalized() * 1.2 * 0.05
		sprite.follow(pos, 0.05)
	assert_true(sprite.walking)
	assert_true(sprite.current_key.begins_with("BACKSIDE_WALK"), "walking away at an angle uses the walk-only direction (was %s)" % sprite.current_key)
	assert_false(sprite.current_flip, "facing left: as painted")
	# to the right: the same frames mirrored
	for step: int in range(30):
		pos += Vector3(0.7, 0.0, -0.7).normalized() * 1.2 * 0.05
		sprite.follow(pos, 0.05)
	assert_true(sprite.current_key.begins_with("BACKSIDE_WALK"))
	assert_true(sprite.current_flip, "facing right: mirrored")
	# she stops: an idle of a direction she has an idle for
	for step: int in range(10):
		sprite.follow(pos, 0.05)
	assert_false(sprite.walking)
	assert_true(sprite.current_key.ends_with("_IDLE"), "back to idle (was %s)" % sprite.current_key)
	assert_true(["FRONT_IDLE", "SIDE_IDLE", "BACK_IDLE"].has(sprite.current_key))


func test_the_freed_sky_is_still_or_off_with_reduce_motion_and_on_low_end() -> void:
	assert_true(CapitalSkyFx.motion_allowed(false, false))
	assert_false(CapitalSkyFx.motion_allowed(true, false), "Reduce motion: no climbing lanterns, no fireworks")
	assert_false(CapitalSkyFx.motion_allowed(false, true), "Low-end: the same")
	var holder: Node3D = Node3D.new()
	add_child_autofree(holder)
	var still: CapitalSkyFx = CapitalSkyFx.build(holder, 60.0, false)
	assert_not_null(still)
	assert_false(still.is_processing(), "nothing moves")
	assert_eq(still._bursts.size(), 0, "no fireworks")
	assert_eq(still._lanterns.size(), 1, "one still lantern card")
	var moving: CapitalSkyFx = CapitalSkyFx.build(holder, 60.0, true)
	assert_eq(moving._bursts.size(), 3)
	assert_eq(moving._lanterns.size(), 2)
	assert_almost_eq(CapitalSkyFx.burst_fade(0.0), 0.0, 0.001)
	assert_almost_eq(CapitalSkyFx.burst_fade(1.0), 0.0, 0.001)
	assert_lt(CapitalSkyFx.burst_fade(0.5), 0.9, "soft: never fully opaque")
	assert_almost_eq(CapitalSkyFx.lantern_fade(0.0), 0.0, 0.001)
	assert_almost_eq(CapitalSkyFx.lantern_fade(1.0), 0.0, 0.001)


func test_the_easel_shows_the_painted_portrait_and_can_still_be_defaced() -> void:
	for variant: int in [0, 1]:
		var easel: Node3D = CapitalProps.portrait(variant, false)
		add_child_autofree(easel)
		assert_null(easel.get_node_or_null("Picture"), "no code-drawn smiley picture")
		assert_not_null(easel.get_node_or_null("Defaced"), "the moustache group is still there for the freed city")


func test_locked_path_packs_are_painted_and_only_the_dump_seal_is_tinted() -> void:
	var painted: int = 0
	for pack: PackData in PackCatalog.all():
		if pack.kind != PackData.Kind.PATH:
			assert_null(PackArt.locked_picture(pack, PackArt.SIZE))
			continue
		var picture: TextureRect = PackArt.locked_picture(pack, PackArt.SIZE)
		assert_not_null(picture, "%s has its locked parcel" % pack.id)
		if picture != null:
			painted += 1
			assert_eq(picture.material != null, pack.path == Affinity.Type.REFUSEMANCER, "only the Refusemancer seal is re-coloured")
			picture.free()
	assert_eq(painted, 4, "one parcel per Path")
	assert_eq(PackArt.LOCKED_SEAL_TINTS.size(), 1)


func test_the_battle_item_slots_are_painted() -> void:
	assert_true(ItemBar.painted_slots())


func test_the_red_cross_recolour_is_gone() -> void:
	assert_false(ClassDB.class_exists(&"ArtPatches"))
	assert_false(FileAccess.file_exists("res://core/data/art_patches.gd"), "the stopgap is removed: the redone art carries the green leaf")
	assert_not_null(Portraits.texture_for("NPC-HESPER", ""))


func test_the_gallery_nodes_are_fitted_to_the_new_map() -> void:
	var layout: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/dungeons/map_layout.json")) as Dictionary
	var nodes: Dictionary = layout["S-GALLERY"] as Dictionary
	assert_eq(nodes.size(), 13)
	for key: Variant in nodes:
		var at: Array = nodes[key] as Array
		assert_between(float(at[0]), 0.05, 0.95, "node %s x on the picture" % str(key))
		assert_between(float(at[1]), 0.1, 0.92, "node %s y on the picture" % str(key))


func test_the_buffet_has_two_painted_stalls_north_of_the_vendor() -> void:
	var layout: BuffetLayout = BuffetLayout.new()
	layout.build()
	var stalls: Array[BuffetLayout.Prop] = []
	for prop: BuffetLayout.Prop in layout.props:
		if prop.kind == "stall":
			stalls.append(prop)
	assert_eq(stalls.size(), 2)
	var vendor: Vector3 = layout.anchors["dolcetta"] as Vector3
	assert_lt(stalls[0].pos.z, vendor.z, "her stall stands behind her (north), so the camera sees her in front of it")
	assert_almost_eq(stalls[0].pos.x, vendor.x, 0.5)


func test_new_game_skips_the_slot_grid_only_on_an_empty_profile() -> void:
	# the rule is "no campaign slot holds a save" (the owner's answer, Fable Nov 12d item 5)
	assert_eq(TitleScreen.skips_slot_grid(), not CampaignSlots.any_save())


func test_maren_gives_her_name_in_the_cave_mouth_welcome() -> void:
	var lines: Array[String] = StoryText.shared().get_lines("cave_mouth.maren_end")
	assert_true(lines[0].contains("I'm Elder Maren"), "the player learns her name from her at the cave mouth")
	assert_lt(lines[0].length(), 240, "it still fits its box")


func test_bertram_is_clipped_again() -> void:
	var story: StoryText = StoryText.shared()
	assert_eq(story.get_lines("quest.armory.start")[3], "Beat one. Then come back and I will hand you something pointy.")
	assert_eq(story.get_lines("quest.armory.equip")[0], "Security Protocol Nine: gear in a bag protects nobody. Equip it.")
	for key: String in ["quest.armory.start", "quest.armory.equip", "quest.armory.equip_waiting", "quest.armory.done", "town.equipment_vendor.too_early"]:
		for line: String in story.get_lines(key):
			assert_lt(line.length(), 150, "%s stays short: %s" % [key, line])


func test_the_wanderer_portrait_fades_out_at_its_cut_right_edge() -> void:
	var image: Image = Image.create_empty(100, 20, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.5, 0.4, 0.3, 1.0))
	Portraits.feather_right(image, 0.1)
	assert_almost_eq(image.get_pixel(99, 5).a, 0.0, 0.001, "clear at the edge")
	assert_almost_eq(image.get_pixel(89, 5).a, 1.0, 0.001, "untouched outside the band")
	assert_between(image.get_pixel(95, 5).a, 0.2, 0.8, "a ramp between")
	assert_true(Portraits.EDGE_FEATHER.has(NpcRegistry.PLAYER_ID))
	var texture: Texture2D = Portraits.texture_for(NpcRegistry.PLAYER_ID)
	if texture != null:
		var shown: Image = texture.get_image()
		assert_lt(shown.get_pixel(shown.get_width() - 1, shown.get_height() / 2).a, 0.05, "no hard vertical edge beside the dialogue box")


func test_the_crease_camera_holds_off_the_side_walls() -> void:
	var inside: Vector3 = Vector3(40.3, 0.0, float(CapitalLayout.CREASE_Z0) + 10.0)
	var target: Vector3 = inside + Vector3(0.0, 4.0, 11.0)
	assert_almost_eq(CapitalScene.crease_camera_target(target, inside).x, 41.0 - CapitalScene.CREASE_CAMERA_MARGIN, 0.001, "held off the east wall")
	var west: Vector3 = Vector3(4.4, 0.0, float(CapitalLayout.CREASE_Z0) + 10.0)
	assert_almost_eq(CapitalScene.crease_camera_target(west + Vector3(0.0, 4.0, 11.0), west).x, 4.0 + CapitalScene.CREASE_CAMERA_MARGIN, 0.001, "and the west wall")
	var middle: Vector3 = Vector3(22.0, 0.0, float(CapitalLayout.CREASE_Z0) + 10.0)
	assert_almost_eq(CapitalScene.crease_camera_target(middle + Vector3(0.0, 4.0, 11.0), middle).x, 22.0, 0.001, "untouched in the middle")
	var city: Vector3 = Vector3(40.3, 0.0, 60.0)
	assert_almost_eq(CapitalScene.crease_camera_target(city + Vector3(0.0, 4.0, 11.0), city).x, 40.3, 0.001, "untouched in the city above")


func test_a_roamer_that_hurts_winds_up_before_it_comes() -> void:
	assert_gt(ZoneEnemy.WIND_UP_SECONDS, ZoneEnemy.THREAT_SECONDS, "longer than a fighter's threat pose")
	assert_gte(ZoneScene.SPAWN_GRACE, 3.0, "the arrival grace, counted only while the hero can move")
