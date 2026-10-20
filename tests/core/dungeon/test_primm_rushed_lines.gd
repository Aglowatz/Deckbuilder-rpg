extends GutTest
## Overnight Oct 19 (Phase 2): the Capital is open from the start; a hero who reaches Primm before freeing all four zones does not quote the
## leaders' lessons (the `.rushed` lines); with all four freed the fight plays the leaders' words as written.


func test_rushed_beats_swap_only_the_three_lesson_lines() -> void:
	var story: ZoneStoryText = ZoneStoryText.for_zone("final")
	for scene_id: String in ["primm_p1", "primm_p2", "primm_end"]:
		var normal: Array[Dictionary] = CutsceneDefs.beats(scene_id)
		var rushed: Array[Dictionary] = CutsceneDefs.beats(scene_id, true)
		assert_eq(normal.size(), rushed.size(), scene_id)
		for index: int in range(normal.size()):
			var key: String = str(normal[index]["key"])
			if CutsceneDefs.RUSHED_KEYS.has(key):
				assert_eq(str(rushed[index]["key"]), key + ".rushed")
				assert_true(story.lines.has(key + ".rushed"), "%s.rushed is written" % key)
			else:
				assert_eq(str(rushed[index]["key"]), key, "other beats are the same")


func test_the_rushed_lines_name_no_leader() -> void:
	var story: ZoneStoryText = ZoneStoryText.for_zone("final")
	for key: String in CutsceneDefs.RUSHED_KEYS:
		var text: String = "\n".join(story.get_lines(key + ".rushed"))
		for leader: String in ["Flex", "Chef", "Agnes", "Compostella", "subject", "jar", "blank page"]:
			assert_false(text.contains(leader), "%s.rushed does not quote %s" % [key, leader])
