extends GutTest
## Art import Oct 29, Part 1: the fifteen story stills that sit behind a scene's own narration (`StoryStills` backdrops, `StillBackdrop`).


func test_every_backdrop_still_is_in_the_game() -> void:
	assert_eq(StoryStills.BACKDROP_IDS.size(), 15)
	for id: String in StoryStills.BACKDROP_IDS:
		assert_true(KeyArt.has(id), "%s imported" % id)
		assert_true(KeyArt.known_ids().has(id), "%s is a row of logo_title_art.csv" % id)


func test_every_hook_names_a_real_moment() -> void:
	for scene_id: String in StoryStills.CUTSCENE_BACKDROPS.keys():
		assert_true(CutsceneDefs.has_scene(scene_id), "cutscene %s exists" % scene_id)
	for scene_id: String in StoryStills.SCENE_BACKDROPS.keys():
		assert_true(StoryScenes.has(scene_id), "story scene %s exists" % scene_id)
	var fxs: Array[String] = []
	for beat: Dictionary in EndingDefs.BEATS:
		fxs.append(str(beat["fx"]))
	for fx: String in StoryStills.ENDING_BACKDROPS.keys():
		assert_true(fxs.has(fx), "ending beat %s exists" % fx)
	for number: int in range(1, MemoryDefs.COUNT + 1):
		assert_true(StoryStills.BACKDROP_IDS.has(StoryStills.memory_backdrop(number)), "memory %d has a still" % number)
	assert_eq(StoryStills.memory_backdrop(0), "")
	assert_eq(StoryStills.memory_backdrop(5), "")


func test_every_backdrop_still_is_used_once() -> void:
	var used: Array[String] = []
	for map: Dictionary in [StoryStills.CUTSCENE_BACKDROPS, StoryStills.ENDING_BACKDROPS, StoryStills.SCENE_BACKDROPS]:
		for value: Variant in map.values():
			used.append(str(value))
	used.append_array(StoryStills.MEMORIES)
	used.sort()
	var expected: Array[String] = StoryStills.BACKDROP_IDS.duplicate()
	expected.sort()
	assert_eq(used, expected)


func test_backdrop_needs_no_new_text() -> void:
	# The backdrops have no captions of their own (dialogue freeze): no still.<name> key is needed.
	for id: String in StoryStills.BACKDROP_IDS:
		assert_false(StoryStills.IDS.has(id), "%s is not a caption still" % id)


func test_missing_art_keeps_the_old_look() -> void:
	assert_null(StillBackdrop.make(""))
	assert_null(StillBackdrop.make("STORY-NOT-A-STILL"))
	var backdrop: StillBackdrop = StillBackdrop.make(StoryStills.WONDER)
	assert_not_null(backdrop)
	backdrop.free()
