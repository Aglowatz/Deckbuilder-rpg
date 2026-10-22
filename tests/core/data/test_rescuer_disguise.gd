extends GutTest
## Apparel Part 4: the Rescuer is shown disguised (NPC-RESCUER / SPR-RESCUER) from the prologue until Plume names her at the castle gate, then as Elowen; the old look
## stays while the disguise art is missing. The importers know the new IDs, and the Old Well speaks with its own portrait id.

var _was_named: bool = false


func before_each() -> void:
	_was_named = RoyalFamily.rescuer_named()


func after_each() -> void:
	RoyalFamily.set_rescuer_named(_was_named)


func test_the_portrait_is_the_disguise_until_she_is_named() -> void:
	assert_eq(RescuerDisguise.portrait_for("NPC-ELOWEN", false, true), "NPC-RESCUER", "the prologue, the Cave Mouth, the castle gate before the reveal")
	assert_eq(RescuerDisguise.portrait_for("NPC-ELOWEN", true, true), "NPC-ELOWEN", "after Plume names her")
	assert_eq(RescuerDisguise.portrait_for("NPC-ELOWEN", false, false), "NPC-ELOWEN", "no disguise art yet: the old look stays")
	assert_eq(RescuerDisguise.portrait_for("NPC-ELDER", false, true), "NPC-ELDER", "nobody else changes")


func test_the_sprite_is_the_disguise_until_she_is_named() -> void:
	RoyalFamily.set_rescuer_named(false)
	assert_true(RescuerDisguise.disguised())
	assert_eq(RescuerDisguise.sprite_key(true), "RESCUER")
	assert_eq(RescuerDisguise.sprite_key(false), "ELOWEN", "the old sprite while SPR-RESCUER is not imported")
	RoyalFamily.set_rescuer_named(true)
	assert_eq(RescuerDisguise.sprite_key(true), "ELOWEN")


func test_the_reveal_flag_drives_it() -> void:
	# The castle gate scene sets rescuer_named mid-way (the "@set" step); the session passes it to RoyalFamily.
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game()
	assert_true(RescuerDisguise.disguised(), "a new game: the Rescuer is unnamed")
	Session.set_flag(StoryBeats.FLAG_NAMED)
	assert_false(RescuerDisguise.disguised(), "named at the castle gate")
	assert_eq(RescuerDisguise.portrait_id("NPC-ELOWEN"), "NPC-ELOWEN")
	Session.new_game()


func test_the_importers_know_the_new_ids() -> void:
	assert_true(Portraits.known_portraits().has("NPC-RESCUER"), "import portraits takes NPC-RESCUER.png")
	assert_true(Portraits.known_portraits().has("NPC-OLDWELL"), "and NPC-OLDWELL.png")
	var batch: String = FileAccess.get_file_as_string("res://data/source/npc_sprite_batch.csv")
	assert_true(batch.contains("SPR-RESCUER (sheet)"), "import npc sprites expects the SPR-RESCUER sheet")


func test_the_old_well_speaks_as_its_own_npc() -> void:
	assert_eq(NpcRegistry.resolve_speaker("The Old Well"), "NPC-OLDWELL")
	assert_eq(NpcRegistry.find("NPC-OLDWELL").portrait_id, "NPC-OLDWELL")
