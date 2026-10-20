extends GutTest
## Art import Oct 20 (docs/art/import_oct20_report.md): the screens find the newly imported pictures through their usual lookups, so nothing shows
## the old stand-in once the art is in.


func before_all() -> void:
	IconArt.reset()
	MapArt.reset()
	Battleboards.reset()
	Bestiary.reset_art()
	SpriteLibrary.reset()


func test_gear_item_and_cosmetic_icons_resolve() -> void:
	for id: String in ["ICON-GEAR-LUCKYSOCK", "ICON-GEAR-BINLID", "ICON-ITEM-HEALINGDRAUGHT", "ICON-ITEM-HEARTYPIE", "ICON-COS-WIDEBRIM", "ICON-COS-ROYAL"]:
		assert_true(IconArt.has(id), "%s is in the game" % id)
	assert_true(IconArt.has(IconArt.gear_icon_id("lucky_sock")))
	assert_true(IconArt.has(IconArt.item_icon_id("hearty_pie")), "the Hearty Pot Pie icon was matched by its display name")


func test_iron_cave_has_its_own_map_and_board() -> void:
	assert_true(Battleboards.has_own_image("BB-S-IRON"), "BB-S-IRON no longer borrows BB-S-BEEF")
	assert_true(FileAccess.file_exists(ProjectSettings.globalize_path(MapArt.OUT_DIR.path_join("MAP-S-IRON.webp"))) or ResourceLoader.exists(MapArt.OUT_DIR.path_join("MAP-S-IRON.webp")), "MAP-S-IRON no longer borrows MAP-S-BEEF")


func test_new_portraits_and_world_sprites() -> void:
	for npc: String in ["NPC-KING", "NPC-QUEEN", "NPC-ELOWEN", "NPC-SIPHON", "NPC-QUOTA", "NPC-CRUMB", "NPC-PLUME", "NPC-CLIPWELL", "NPC-ISLA", "NPC-VAULTWARDEN"]:
		assert_not_null(Portraits.texture_for(npc), "%s has a dialogue portrait" % npc)
		var key: String = NpcSprites.character_for(npc)
		assert_eq(key, npc.trim_prefix("NPC-"), "%s stands in the world as its painted sprite" % npc)
		for frame: String in ["FRONT_IDLE", "FRONT_TALK", "SIDE_IDLE", "BACK_IDLE"]:
			assert_not_null(SpriteLibrary.frame(key, frame), "%s %s" % [key, frame])


func test_bestiary_pictures() -> void:
	assert_not_null(Bestiary.art("Cave Scavenger"), "met enemies show their BST picture")
	assert_not_null(Bestiary.art("Colonel Casserole"))
