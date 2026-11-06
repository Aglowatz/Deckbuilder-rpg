extends GutTest
## Batch 12 art import (Nov 6, docs/art/import_nov6_batch12.md): every image is in the game and wired where docs/art/art_needed_nov4.csv asked.

const PORTRAITS: Array[String] = ["NPC-FLEX", "CUT-FLEX", "NPC-TOWNSFOLK", "NPC-TOWNSFOLK-A", "NPC-TOWNSFOLK-B", "NPC-TOWNSFOLK-C",
	"NPC-GYM-ATTENDANT", "NPC-BRISKET", "NPC-SIR-LOIN", "NPC-CAPITAL-GUARD", "NPC-PLAYER"]
const SPRITE_SETS: Array[String] = ["FLEX", "FLEX_FREED", "PRIMM", "ROLLO", "KYLE", "GERALD", "TOWNSFOLK_A", "TOWNSFOLK_B", "TOWNSFOLK_C", "FIGSLY"]
const STILLS: Array[String] = ["STORY-RESCUE", "STORY-FLEX", "STORY-CLENCH-THRONE", "STORY-PRIMM-FALL", "STORY-EPI-TOGETHER", "STORY-WAKE",
	"STORY-WAKE-NIGHT"]
const BESTIARY: Array[String] = ["BST-UNPAID-INTERN", "BST-HUNGRY-SCARECROW", "BST-CORRECTION-OFFICER", "BST-UNDERSECRETARY-VELLUM",
	"BST-INTAKE-ORDERLY"]


func test_portraits_are_in() -> void:
	for id: String in PORTRAITS:
		assert_true(Portraits.has_portrait(id), "%s imported" % id)
	assert_true(ResourceLoader.exists("res://assets/art/portraits/NPC-FLEX_REVEAL.webp"), "Flex's reveal portrait imported")


func test_flex_shows_his_reveal_once_the_house_of_gains_falls() -> void:
	assert_eq(Portraits.default_expression_for("NPC-FLEX", false), "", "the frail prisoner before the House of Gains")
	assert_eq(Portraits.default_expression_for("NPC-FLEX", true), "reveal", "his revealed self after it")
	assert_eq(Portraits.default_expression_for("NPC-ELDER", true), "", "nobody else changes")
	assert_not_null(Portraits.texture_for("NPC-FLEX", "reveal"))


func test_townsfolk_speak_with_their_own_portrait() -> void:
	assert_eq(NpcRegistry.find("NPC-TOWNSFOLK").portrait_id, "NPC-TOWNSFOLK", "not Primm's perfect citizen any more")


func test_sprite_sets_are_in() -> void:
	for key: String in SPRITE_SETS:
		assert_true(SpriteLibrary.has_character(key), "%s sprite set imported" % key)
	for key: String in ["TOWNSFOLK_A", "TOWNSFOLK_B", "TOWNSFOLK_C"]:
		assert_eq((SpriteLibrary.info(key).get("walk_dirs", []) as Array).size(), 4, "%s walks in four directions" % key)


func test_npcs_wear_their_own_sets() -> void:
	assert_eq(NpcSprites.character_for("NPC-ROLLO"), "ROLLO", "Rollo no longer walks as Gus")
	for def: ZoneDef in [ZoneDefs.get_def(GainlandsZone.ID), ZoneDefs.get_def(CapitalZone.ID)]:
		var entries: Array = def.npcs.duplicate()
		entries.append_array(def.freed_npcs)
		for entry: Dictionary in entries:
			if str(entry["id"]) == "heartlift":
				assert_eq(NpcSprites.character_for_entry(entry), "FLEX_FREED", "%s: the freed Flex is the painted lion, not the Barbarian model" % def.id)
			elif str(entry["id"]) == "fig":
				assert_eq(NpcSprites.character_for_entry(entry), "FIGSLY", "Fig Sly is his painted sprite, not the 3D stand-in")


func test_crosspath_strollers_walk_the_new_townsfolk() -> void:
	var used: Array[String] = []
	for spec: Dictionary in TownScene.STROLLERS:
		var character: String = TownScene.stroller_character(spec)
		assert_eq(character, str(spec["character"]), "the %s stroller walks its own set" % spec["anchor"])
		assert_has(TownScene.TOWNSFOLK_POOL, character)
		if not used.has(character):
			used.append(character)
	used.sort()
	assert_eq(used, ["TOWNSFOLK_A", "TOWNSFOLK_B", "TOWNSFOLK_C"] as Array[String], "all three walkers are in the crowds")
	assert_eq(TownScene.stroller_character({"character": "NOT_A_SET"}), TownScene.STROLLER_FALLBACK, "a missing set falls back to the villager")


func test_stills_are_in_and_primm_falls_on_his_own_still() -> void:
	for id: String in STILLS:
		assert_true(KeyArt.has(id), "%s imported" % id)
	assert_eq(StoryStills.cutscene_backdrop("primm_end", 1), "STORY-PRIMM-FALL", "the redone still is back behind Primm's defeat")
	assert_false(StoryStills.PARKED.has("STORY-PRIMM-FALL"))
	assert_eq(StoryStills.cutscene_backdrop("flex", 1), "STORY-CLENCH-THRONE")


func test_bestiary_map_ui_and_kits() -> void:
	for id: String in BESTIARY:
		assert_true(ResourceLoader.exists("res://assets/art/bestiary/%s.webp" % id), "%s imported" % id)
	assert_true(ResourceLoader.exists("res://assets/art/maps/MAP-S-GALLERY.webp"), "the Shattered Gallery has its own map (no castle stand-in)")
	assert_true(MapArt.has_map("MAP-S-GALLERY"))
	assert_true(ResourceLoader.exists("res://assets/art/ui/UI-BG-DECKBUILDER.webp"))
