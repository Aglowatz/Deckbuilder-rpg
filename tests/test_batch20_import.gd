extends GutTest
## Fable big pass Nov 23, Part 1: Batch 20's pictures are in the game under their IDs, and Trey Pickett is one character
## everywhere (portrait, world sprite, Bestiary picture): no badger baker, no citizen stand-in.


func before_all() -> void:
	Session.save_enabled = false
	Session.ensure_game()


func test_the_draft_pictures_are_imported() -> void:
	for id: String in ["UI-DRAFT-BG", "UI-DRAFT-HALL", "UI-ALEMBIC-BREW"]:
		assert_true(UiArt.has(id), id)
	assert_true(KeyArt.has("VS-TREY"), "VS-TREY")
	for id: String in ["ICON-UI-REROLL", "ICON-MAP-DRAFT"]:
		assert_true(IconArt.has(id), id)
	for id: String in ["MAP-DRAFT", "MAP-PC"]:
		assert_true(MapArt.has_map(id), id)
	assert_not_null(Battleboards.texture_for("draft"), "the house table (BB-SHUFFLE) is the board of every draft fight")
	assert_eq(Battleboards.board_for("draft"), "BB-SHUFFLE")
	for id: String in ["TOWN-HERO-SHUFFLEHOUSE", "TOWN-SIGN-SHUFFLEHOUSE"]:
		assert_true(ResourceLoader.exists("res://assets/art/zone_kits/town/%s.webp" % id), id)
	assert_true(ResourceLoader.exists("res://assets/art/zone_kits/final/CAP-PROP-PRIMM-CELL.webp"), "Primm's cell")


func test_every_draft_piece_has_its_own_icon() -> void:
	for id: String in DraftGear.ids():
		var piece: EquipmentData = Session.content.equipment_piece(id)
		assert_not_null(piece, id)
		assert_true(IconArt.has_equipment_icon(piece), "%s has an icon" % id)
		assert_eq(IconArt.equipment_id(piece), IconArt.gear_icon_id(id), "%s shows its own picture, not a stand-in" % id)
	assert_true(IconArt.has(IconArt.gear_icon_id("cardboard_cuirass")), "the Cardboard Cuirass (already in the game) has its Batch 20 icon")


func test_the_eight_new_cards_have_their_pictures() -> void:
	for id: String in ["C-37", "C-38", "C-39", "C-40", "B-38", "R-37", "GN-17", "P4-04"]:
		assert_not_null(Session.card_by_id(id), "%s is a card" % id)
		assert_true(ResourceLoader.exists("res://assets/art/cards/%s.webp" % id), "%s has its art" % id)


func test_trey_pickett_is_one_character_everywhere() -> void:
	assert_true(Portraits.has_portrait(DraftHost.NPC_ID), "his own portrait")
	assert_eq(DraftHost.portrait_id(), DraftHost.NPC_ID, "no stand-in portrait")
	assert_true(SpriteLibrary.has_character(DraftHost.SPRITE_KEY), "his own world sprite")
	assert_eq(DraftHost.sprite_key(), DraftHost.SPRITE_KEY, "no citizen stand-in")
	assert_false(DraftHost.npc_entry("beefcake").has("tint"), "his own sprite is not tinted")
	assert_not_null(Bestiary.art("Trey Pickett"), "his Bestiary and battle picture (BST-TREY)")
	assert_eq(Bestiary.art_id("Trey Pickett"), "BST-TREY")
	var entry: NpcRegistry.Entry = NpcRegistry.find(DraftHost.NPC_ID)
	assert_not_null(entry)
	assert_eq(str(entry.species), "shark", "a card shark")


func test_octavia_eightfold_has_her_pictures() -> void:
	assert_true(Portraits.has_portrait(DraftArena.NPC_ID))
	assert_true(SpriteLibrary.has_character(DraftArena.SPRITE_KEY))
	assert_not_null(Bestiary.art("Octavia Eightfold"))
	assert_eq(NpcRegistry.display_name(DraftArena.NPC_ID), "Octavia Eightfold")


func test_trey_has_his_own_map_marker() -> void:
	assert_eq(MapDraw.icon_id(MapPoi.Kind.DRAFT), "ICON-MAP-DRAFT")
	for zone_id: String in DraftChallenges.ZONES:
		assert_eq(int(ZoneDefs.get_def(zone_id).poi_kinds[DraftHost.SPOT_ID]), int(MapPoi.Kind.DRAFT), zone_id)
