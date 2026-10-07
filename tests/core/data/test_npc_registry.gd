extends GutTest
## The NPC list (data/npcs/npcs.json, NpcRegistry) and how the game's NPCs tie to it: every NPC ID stored in zone/town data exists, the in-game
## names are the list's names, speaker aliases and dungeon story speakers resolve.


func before_each() -> void:
	NpcRegistry.reset()


func test_the_list_has_every_character_row() -> void:
	assert_eq(NpcRegistry.all().size(), 60, "58 list characters plus the two the game adds itself (Shiro Swindle, the Warden of the Four Seals)")
	var entry: NpcRegistry.Entry = NpcRegistry.find("NPC-ELDER")
	assert_not_null(entry)
	assert_eq(entry.name, "Elder Maren")
	assert_eq(entry.portrait_id, "NPC-ELDER")
	assert_eq(entry.species, "tortoise")
	assert_true(entry.expressions.has("happy"))
	assert_null(NpcRegistry.find("VS-SABLE"), "vendor screen rows are not NPCs")


func test_plate_and_short_names() -> void:
	assert_eq(NpcRegistry.find("NPC-BRONSON").plate_name(), "Brick Bronson", "the (corrupted) annotation is not part of the name")
	assert_eq(NpcRegistry.find("NPC-KYLE").short_name(), "Kyle")
	assert_eq(NpcRegistry.find("NPC-GERALD").short_name(), "Gerald")
	assert_eq(NpcRegistry.display_name("NPC-GERALD"), "Gerald, Number 4,000,212")


func test_speakers_resolve_by_name_alias_and_prefix() -> void:
	assert_eq(NpcRegistry.resolve_speaker("Elder Maren"), "NPC-ELDER")
	assert_eq(NpcRegistry.resolve_speaker("Sable"), "V-SABLE")
	assert_eq(NpcRegistry.resolve_speaker("Kyle"), "NPC-KYLE", "short names work")
	assert_eq(NpcRegistry.resolve_speaker("Brock"), "NPC-HURL", "the throwers share Big Hurl")
	assert_eq(NpcRegistry.resolve_speaker("Rita"), "NPC-RIP", "the portal rippers share Rip Tearson")
	assert_eq(NpcRegistry.resolve_speaker("Rip Tearson (Cousin #3)"), "NPC-RIP")
	assert_eq(NpcRegistry.resolve_speaker("Agnes Overdue (over the intercom)"), "NPC-AGNES")
	assert_eq(NpcRegistry.resolve_speaker("Wren Muckfoot"), "", "an NPC with no list match has no portrait")
	assert_eq(NpcRegistry.resolve_speaker(""), "")
	assert_eq(NpcRegistry.resolve_speaker("The Restless Cairn"), "")


func test_story_speakers() -> void:
	assert_eq(NpcRegistry.story_speaker("dungeon.hg_boss.before"), "NPC-CLENCH")
	assert_eq(NpcRegistry.story_speaker("dungeon.hg_boss.after"), "NPC-CLENCH")
	assert_eq(NpcRegistry.story_speaker("dungeon.hg_stretch.after"), "NPC-FLEX")
	assert_eq(NpcRegistry.story_speaker("dungeon.hg_stretch.before"), "", "only the mapped beats have a speaker")
	assert_eq(NpcRegistry.story_speaker("dungeon.hg_gates.before"), "")


func test_the_game_map_only_names_real_npcs() -> void:
	var map: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(NpcRegistry.MAP_PATH)) as Dictionary
	for table: String in ["speakers", "speaker_prefixes", "story_keys"]:
		for key: Variant in (map[table] as Dictionary).keys():
			var id: String = str((map[table] as Dictionary)[key])
			assert_true(NpcRegistry.has(id), "%s['%s'] -> %s exists in the list" % [table, key, id])


func test_every_stored_npc_id_exists_and_names_match() -> void:
	var checked: int = 0
	for zone_id: String in ZoneDefs.all_ids():
		var def: ZoneDef = ZoneDefs.get_def(zone_id)
		var entries: Array[Dictionary] = []
		entries.append_array(def.npcs)
		entries.append_array(def.spots)
		entries.append_array(def.freed_npcs)
		for entry: Dictionary in entries:
			if not entry.has("npc_id"):
				continue
			var id: String = str(entry["npc_id"])
			assert_true(NpcRegistry.has(id), "%s: %s has NPC ID %s" % [zone_id, entry.get("id"), id])
			checked += 1
			var speaker: String = str(entry.get("speaker", ""))
			if not speaker.is_empty():
				assert_eq(NpcRegistry.resolve_speaker(speaker), id, "%s: speaker '%s' is NPC %s" % [zone_id, speaker, id])
	assert_gt(checked, 40, "the zones store NPC IDs")


func test_town_npc_ids_exist() -> void:
	for spot_id: Variant in TownScene.NPC_IDS.keys():
		assert_true(NpcRegistry.has(str(TownScene.NPC_IDS[spot_id])), "town spot %s" % spot_id)


func test_in_game_names_are_the_list_names() -> void:
	assert_eq(CorruptedNpcs.display_name("beefcake"), NpcRegistry.find("NPC-BRONSON").plate_name())
	assert_eq(CorruptedNpcs.display_name("gourmand"), NpcRegistry.find("NPC-GRAVOIS").plate_name())
	assert_eq(CorruptedNpcs.display_name("refusemancer"), NpcRegistry.find("NPC-MULLIGAN").plate_name())
	assert_eq(CorruptedNpcs.display_name("necrocrat"), NpcRegistry.find("NPC-PALLOR").plate_name())
	assert_eq(ZoneDefs.get_def(DnaZone.ID).quest_npc_names[0], NpcRegistry.find("NPC-AGNES").short_name())
	assert_eq(ZoneDefs.get_def(CapitalZone.ID).quest_npc_names[0], NpcRegistry.find("NPC-FERN").short_name())
