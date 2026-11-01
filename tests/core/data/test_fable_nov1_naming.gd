extends GutTest
## Fable pass Nov 1, Part 4: the Grand Chef / the Doppelganger / Escoffina on every surface. Before the reveal the disguised figure reads
## as the chef it poses as; the boss fight reads "The Doppelganger" always; after the naming cutscene the apprentice reads "Escoffina"
## and the real chef "The Grand Chef".


func before_each() -> void:
	SpoilerFree.sync({})


func after_all() -> void:
	SpoilerFree.sync({})


func test_the_real_chef_reads_the_grand_chef_everywhere() -> void:
	assert_eq(SpoilerFree.name("The Grand Chef (formerly Grand Chef Escoffina)"), "The Grand Chef")
	assert_eq(NpcRegistry.find("NPC-ESCOFFINA").plate_name(), "The Grand Chef")
	assert_eq(NpcRegistry.find("NPC-ESCOFFINA").short_name(), "The Grand Chef")
	var buffet: ZoneDef = ZoneDefs.get_def("gourmand")
	for entry: Dictionary in buffet.freed_npcs:
		if str(entry["npc_id"]) == "NPC-ESCOFFINA":
			assert_eq(str(entry["name"]), "The Grand Chef")
			assert_eq(str(entry["speaker"]), "The Grand Chef")
	assert_eq(buffet.ruler_name, "The Grand Chef")


func test_before_the_reveal_the_impostor_poses_as_the_chef_and_the_boss_reads_the_doppelganger() -> void:
	assert_false(SpoilerFree.is_revealed("NPC-DOPPEL"))
	assert_eq(SpoilerFree.name("The Doppelganger (posing as Grand Chef Escoffina)"), "Grand Chef Escoffina", "the node blurb shows the face it wears")
	assert_eq(NpcRegistry.find("NPC-DOPPEL").plate_name(), "The Doppelganger")
	assert_eq(str(BossIntros.find("The Doppelganger")["name"]), "The Doppelganger")
	assert_eq(SpoilerFree.plate_for("NPC-DOPPEL", "The Doppelganger", "x"), "The Doppelganger")
	assert_eq(SpoilerFree.plate_for("NPC-DOPPEL", "Escoffina", "x"), "Escoffina", "the naming beat keeps its label even before the flag")
	assert_eq(SpoilerFree.plate_for("NPC-DOPPEL", "", "x"), "x")
	assert_eq(SpoilerFree.plate_for("NPC-BASIL", "Basil", "x"), "x")


func test_after_the_reveal_the_apprentice_reads_escoffina_and_the_boss_still_the_doppelganger() -> void:
	SpoilerFree.sync({"cutscene_seen_wonder": true})
	assert_true(SpoilerFree.is_revealed("NPC-DOPPEL"))
	assert_eq(NpcRegistry.find("NPC-DOPPEL").plate_name(), "Escoffina")
	assert_eq(SpoilerFree.name("The Doppelganger (posing as Grand Chef Escoffina)"), "The Doppelganger", "the node blurb names the impostor once it is known")
	assert_eq(str(BossIntros.find("The Doppelganger")["name"]), "The Doppelganger", "a replay of the Test Kitchen still fights the Doppelganger")
	assert_eq(SpoilerFree.plate_for("NPC-DOPPEL", "The Doppelganger", "Escoffina"), "The Doppelganger", "a line written for the impostor keeps its label")
	var buffet: ZoneDef = ZoneDefs.get_def("gourmand")
	for entry: Dictionary in buffet.freed_npcs:
		if str(entry["npc_id"]) == "NPC-DOPPEL":
			assert_eq(str(entry["name"]), "Escoffina")
			assert_eq(str(entry["speaker"]), "Escoffina")


func test_the_other_surfaces_agree() -> void:
	var registry: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/audio/audio_registry.json")) as Dictionary
	var track: Dictionary = (registry["entries"] as Dictionary).get("MUS-GOUR-BOSS", {}) as Dictionary
	assert_eq(str(track.get("name", "")), "The Doppelganger", "the music list names the boss")
	var bestiary: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/bestiary/bestiary.json")) as Dictionary
	var names: PackedStringArray = []
	for entry: Variant in bestiary["entries"] as Array:
		names.append(str((entry as Dictionary).get("name", "")))
	assert_true(names.has("The Doppelganger"), "the Bestiary lists the boss as the Doppelganger")
	assert_false(names.has("Grand Chef Escoffina"), "and never as the chef")
	var story: ZoneStoryText = ZoneStoryText.for_zone("gourmand")
	assert_eq(story.text("cutscene.wonder.7.speaker"), "Escoffina")
	assert_eq(story.text("cutscene.wonder.6.speaker"), "The Grand Chef")
	assert_eq(story.text("cutscene.reveal.1.speaker"), "The Doppelganger")
	assert_true(story.text("freed_npc.escoffina").begins_with("Escoffina. Apprentice."))
	var quest: Dictionary = QuestDefinitions.ZONE_MAIN_TEXT["gourmand"] as Dictionary
	for key: String in quest:
		assert_false(str(quest[key]).contains("Escoffina"), "the quest log says the Grand Chef, never the name the impostor takes (%s)" % key)
