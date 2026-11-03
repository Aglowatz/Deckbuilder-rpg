extends GutTest
## Batch 11 art import (Nov 2): the last 3D figures became painted sets. This is the 3D-figure audit of the Nov 2 pass as a test - every NPC entry of
## every zone resolves to an imported painted set, the Buffet's three gate guardians are painted, and in Crosspath only the window mannequin (a
## mannequin by design) is a 3D figure. The ambient animals of the Verdant Dump are props, not NPC entries, and stay 3D by choice.

## The sets this batch added, by the entry that wears each.
const BATCH11: Dictionary = {
	"final": {"hesper": "HESPER", "exit_clerk": "EXIT_CLERK", "guard_height": "CAPITAL_GUARD", "guard_queue": "CAPITAL_GUARD",
		"guard_in_1": "CAPITAL_GUARD", "guard_in_2": "CAPITAL_GUARD", "primm_guard": "CAPITAL_GUARD"},
	"beefcake": {"gary": "GARY", "gym_attendant": "GYM_ATTENDANT"},
	"gourmand": {"tarragon": "TARRAGON"},
	"refusemancer": {"wren": "MUCKFOOT", "sorrel": "SORREL"},
}


func test_every_zone_npc_entry_is_a_painted_set() -> void:
	var checked: int = 0
	for zone_id: String in ZoneDefs.all_ids():
		var def: ZoneDef = ZoneDefs.get_def(zone_id)
		if def == null:
			continue
		for entry: Dictionary in def.npcs + def.freed_npcs:
			assert_ne(NpcSprites.character_for_entry(entry), "", "%s / %s is a painted set, not a 3D model" % [zone_id, str(entry["id"])])
			checked += 1
	assert_gt(checked, 55, "every zone's NPC lists (and the freed leaders) were checked")


func test_batch11_entries_wear_their_new_sets() -> void:
	for zone_id: String in BATCH11.keys():
		var wanted: Dictionary = BATCH11[zone_id] as Dictionary
		var found: Dictionary = {}
		var def: ZoneDef = ZoneDefs.get_def(zone_id)
		for entry: Dictionary in def.npcs + def.freed_npcs:
			var id: String = str(entry["id"])
			if wanted.has(id):
				assert_eq(NpcSprites.character_for_entry(entry), str(wanted[id]), "%s / %s" % [zone_id, id])
				found[id] = true
		assert_eq(found.size(), wanted.size(), "%s: every batch 11 entry exists" % zone_id)


func test_relative_heights_from_the_row_notes() -> void:
	var heights: Dictionary = {"HESPER": 1.0, "EXIT_CLERK": 1.0, "GARY": 0.55, "GYM_ATTENDANT": 1.0, "TARRAGON": 1.0, "MUCKFOOT": 1.0,
		"SORREL": 1.1, "BRISKET": 1.35, "SIR_LOIN": 1.35, "DEALER": 1.0, "CAPITAL_GUARD": 1.2}
	for character: String in heights.keys():
		assert_true(SpriteLibrary.has_character(character), "%s is imported" % character)
		assert_almost_eq(float(SpriteLibrary.info(character).get("rel_height", 0.0)), float(heights[character]), 0.001, character)
		assert_eq(SpriteLibrary.info(character).get("dirs", []), ["FRONT", "SIDE", "BACK"], "%s has the three stationary views" % character)


func test_the_buffet_gate_guardians_are_painted() -> void:
	var builder: GDScript = load("res://world/buffet/buffet_builder.gd") as GDScript
	var sets: Dictionary = builder.get("GATE_SETS") as Dictionary
	for gate: BuffetGates.Gate in BuffetGates.gates():
		assert_true(sets.has(gate.id), "gate %s has a painted guardian" % gate.id)
		assert_true(SpriteLibrary.has_character(str(sets.get(gate.id, ""))), "gate %s's set is imported" % gate.id)


func test_crosspath_has_no_3d_npc_but_the_mannequin() -> void:
	var town: GDScript = load("res://world/town_scene.gd") as GDScript
	var sprites: Dictionary = town.get("NPC_SPRITES") as Dictionary
	var ids: Dictionary = town.get("NPC_IDS") as Dictionary
	for id: String in ["vendor", "elder", "guard", "hob", "isla", "hidden_vendor", "item_vendor", "pack_vendor"]:
		var character: String = str(sprites.get(id, ""))
		if character == "":
			character = NpcSprites.character_for(str(ids.get(id, "")))
		assert_true(character != "" and SpriteLibrary.has_character(character), "Crosspath %s is a painted set" % id)
	assert_eq(sprites.get("hidden_vendor", ""), "DEALER", "the Secret Dealer wears his own set")


func test_new_speakers_show_their_portraits() -> void:
	var speakers: Dictionary = {"Nurse Hesper Dray": "NPC-HESPER", "Exit Clerk": "NPC-EXIT-CLERK", "Gary": "NPC-GARY",
		"Sous-Chef Tarragon": "NPC-TARRAGON", "Billie Muckfoot": "NPC-MUCKFOOT", "A Secret Dealer": "NPC-DEALER"}
	for speaker: String in speakers.keys():
		var id: String = NpcRegistry.resolve_speaker(speaker)
		assert_eq(id, str(speakers[speaker]), speaker)
		assert_true(Portraits.has_portrait(NpcRegistry.find(id).portrait_id) if id != "" else false, "%s has a portrait" % speaker)
	assert_true(Portraits.has_portrait("NPC-SORREL"), "Sorrel's portrait is imported (the growth spots speak as Moss Mulligan; inbox)")
