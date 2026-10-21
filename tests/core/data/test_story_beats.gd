extends GutTest
## Oct 21: when the new story beats wait for the hero (StoryBeats): Elowen's Cave Mouth scenes after each freed zone.


func test_the_cave_mouth_scenes_come_one_per_freed_zone_in_order() -> void:
	var flags: Dictionary = {}
	assert_eq(StoryBeats.cave_mouth_scene(flags, 0), "", "nothing before the first freed zone")
	assert_eq(StoryBeats.cave_mouth_scene(flags, 1), "cave_mouth_1")
	flags["cave_mouth_1_seen"] = true
	assert_eq(StoryBeats.cave_mouth_scene(flags, 1), "", "the second waits for the second zone")
	assert_eq(StoryBeats.cave_mouth_scene(flags, 3), "cave_mouth_2", "an old save three zones in gets them one at a time, in order")
	flags["cave_mouth_2_seen"] = true
	flags["cave_mouth_3_seen"] = true
	assert_eq(StoryBeats.cave_mouth_scene(flags, 4), "cave_mouth_4", "the last one before the Capital")
	flags["cave_mouth_4_seen"] = true
	assert_eq(StoryBeats.cave_mouth_scene(flags, 4), "")


func test_no_cave_mouth_scene_after_the_capture() -> void:
	assert_eq(StoryBeats.cave_mouth_scene({StoryBeats.FLAG_SEIZED: true}, 4), "", "she is in the Lab")


func test_the_scenes_grow_warmer_and_never_name_her_early() -> void:
	for number: int in range(1, StoryBeats.CAVE_MOUTH_SCENES + 1):
		var text: String = "\n".join(StoryScenes.all_lines("cave_mouth_%d" % number))
		assert_false(text.contains("{rescuer_full}") or text.contains("Elowen") or text.contains("Siphon"), "scene %d keeps her secret" % number)
	assert_true("\n".join(StoryScenes.all_lines("cave_mouth_4")).contains("castle gate"), "the last one sets up the gate")
