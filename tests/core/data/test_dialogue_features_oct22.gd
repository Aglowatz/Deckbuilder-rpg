extends GutTest
## Overnight Oct 22, Part 2: dialogue that needed code - the Primm fight quotes only the leaders of freed zones, Maren's short greeting
## follows progress, Agnes greets you as an old acquaintance in the Hall once you met her at the front desk, and the Capital's NPCs have
## freed-zone barks.


func test_each_lesson_line_quotes_only_freed_leaders() -> void:
	var story: ZoneStoryText = ZoneStoryText.for_zone("final")
	var all: Array[String] = ["beefcake", "necrocrat", "gourmand", "refusemancer"]
	assert_eq(CutsceneDefs.lesson_key("cutscene.primm_p1.2", all), "cutscene.primm_p1.2")
	assert_eq(CutsceneDefs.lesson_key("cutscene.primm_p1.2", ["necrocrat"] as Array[String]), "cutscene.primm_p1.2.rushed")
	assert_eq(CutsceneDefs.lesson_key("cutscene.primm_p2.2", ["gourmand"] as Array[String]), "cutscene.primm_p2.2.gourmand")
	assert_eq(CutsceneDefs.lesson_key("cutscene.primm_p2.2", ["necrocrat", "beefcake"] as Array[String]), "cutscene.primm_p2.2.necrocrat")
	assert_eq(CutsceneDefs.lesson_key("cutscene.primm_p2.2", ["gourmand", "necrocrat"] as Array[String]), "cutscene.primm_p2.2")
	assert_eq(CutsceneDefs.lesson_key("cutscene.primm_end.3", ["refusemancer"] as Array[String]), "cutscene.primm_end.3")
	assert_eq(CutsceneDefs.lesson_key("cutscene.primm_p1.1", [] as Array[String]), "cutscene.primm_p1.1", "other beats never change")
	for key: String in ["cutscene.primm_p2.2.gourmand", "cutscene.primm_p2.2.necrocrat"]:
		assert_true(story.lines.has(key), "%s is written" % key)
	var only_chef: String = "\n".join(story.get_lines("cutscene.primm_p2.2.gourmand"))
	assert_true(only_chef.contains("blank page"), "the Buffet line keeps the Grand Chef's lesson")
	assert_false(only_chef.contains("respect"), "and leaves out Agnes's")
	var only_agnes: String = "\n".join(story.get_lines("cutscene.primm_p2.2.necrocrat"))
	assert_true(only_agnes.contains("respect"), "the D.N.A. line keeps Agnes's lesson")
	assert_false(only_agnes.contains("blank page"), "and leaves out the Grand Chef's")


func test_beats_for_picks_the_variant_per_line() -> void:
	var beats: Array[Dictionary] = CutsceneDefs.beats_for("primm_p2", ["necrocrat"] as Array[String])
	var keys: Array[String] = []
	for beat: Dictionary in beats:
		keys.append(str(beat["key"]))
	assert_has(keys, "cutscene.primm_p2.2.necrocrat")


func test_maren_has_a_short_greeting_for_each_count_of_freed_zones() -> void:
	var story: StoryText = StoryText.shared()
	for freed: int in range(1, 5):
		var lines: Array[String] = story.get_lines("town.elder.idle.%d" % freed)
		assert_gte(lines.size(), 2, "town.elder.idle.%d rotates" % freed)
		for line: String in lines:
			assert_lt(line.length(), 140, "one short box: %s" % line)


func test_agnes_has_a_met_variant_in_the_hall() -> void:
	var story: ZoneStoryText = ZoneStoryText.for_zone("necrocrat")
	assert_true(story.lines.has("dungeon.ha_number.before.met"))
	assert_eq(str(DungeonMapScreen.MET_VARIANTS.get("dungeon.ha_number.before", "")), "dna_met_dolores")
	var met: String = "\n".join(story.get_lines("dungeon.ha_number.before.met"))
	assert_false(met.contains("you're new") or met.contains("haven't met"), "no stranger's greeting after the front desk")
	assert_true(met.contains("the authorization is valid"), "the seed for the Hall's records stays")


func test_capital_npcs_have_freed_barks() -> void:
	for id: String in ["NPC-CITIZEN", "NPC-WREN", "NPC-KESTREL", "NPC-SPOTLESS", "NPC-ROLLO", "NPC-MARLO", "NPC-FERN"]:
		var freed: Array[String] = NpcRegistry.barks(id, true)
		assert_gte(freed.size(), 2, id)
		assert_ne(freed, NpcRegistry.barks(id), "%s says something new once the Capital is free" % id)
		for line: String in freed:
			assert_lt(line.length(), 90, "a bark is short: %s" % line)
	assert_eq(NpcRegistry.barks("NPC-ELDER", true), NpcRegistry.barks("NPC-ELDER"), "no freed barks = the usual ones")
