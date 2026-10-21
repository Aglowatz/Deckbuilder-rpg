extends GutTest
## Oct 21, Part 3: Old Hob as Death (OldHob), Isla's homecoming and the royal funeral (story scenes).


func test_hob_has_a_cameo_in_every_walkable_zone() -> void:
	for zone_id: String in ["beefcake", "necrocrat", "gourmand", "refusemancer", "final"]:
		var scene: String = OldHob.cameo_scene(zone_id, {})
		assert_false(scene.is_empty(), zone_id)
		assert_true(StoryScenes.has(scene), scene)
	var freed: Dictionary = {str(ZoneCompletion.flag_name("necrocrat")): true}
	assert_eq(OldHob.cameo_scene("necrocrat", freed), "hob_necrocrat_freed", "the intake is open again")
	assert_eq(OldHob.cameo_scene("beefcake", {str(ZoneCompletion.flag_name("beefcake")): true}), "hob_beefcake", "no freed variant: the same cameo")
	assert_eq(OldHob.cameo_scene("final", {str(Lieutenants.flag_beaten(Lieutenants.PLUME)): true}), "hob_final_plume", "'Oh, I've got HIM in pen.'")
	assert_true("\n".join(StoryScenes.all_lines("hob_final")).contains("Pencilled in"), "Primm: pencilled in")


func test_hobs_town_lines_follow_the_story() -> void:
	assert_eq(OldHob.town_scene({}), "hob_town_first")
	assert_eq(OldHob.town_scene({"hob_met": true}), "hob_town")
	assert_eq(OldHob.town_scene({"hob_met": true, str(ZoneCompletion.flag_name("necrocrat")): true}), "hob_town_freed")
	assert_eq(OldHob.town_scene({"primm_defeated": true}), "hob_town_funeral")
	assert_eq(OldHob.town_scene({"primm_defeated": true, "royal_funeral_seen": true}), "hob_town_after_funeral")
	assert_true("\n".join(StoryScenes.all_lines("hob_town_first")).contains("cairn"), "he points at the Restless Cairn")


func test_hob_sends_you_back_at_zero_life() -> void:
	assert_true("\n".join(StoryScenes.all_lines(OldHob.WAKE_SCENE)).contains("Not on my list. Off you pop."))


func test_the_royal_funeral_waits_for_primms_fall_and_plays_once() -> void:
	assert_false(OldHob.funeral_waiting({}))
	assert_true(OldHob.funeral_waiting({"primm_defeated": true}))
	assert_false(OldHob.funeral_waiting({"primm_defeated": true, "royal_funeral_seen": true}))
	var speakers: Array[String] = []
	for step: Dictionary in StoryScenes.steps("royal_funeral"):
		speakers.append(str(step["speaker_id"]))
	for who: String in ["NPC-HOB", "NPC-AGNES", "NPC-KING", "NPC-QUEEN", "NPC-ELDER"]:
		assert_true(speakers.has(who), "%s is at the funeral" % who)


func test_isla_comes_home_once_and_takes_after_her_mother() -> void:
	assert_eq(StoryScenes.once_flag("isla_homecoming"), "isla_home")
	var text: String = "\n".join(StoryScenes.all_lines("isla_homecoming"))
	assert_true(text.contains("Hi, Dad. I know. I should have written."), "the bible's line")
	assert_true(text.contains("mother's"), "she takes after her mother's side")
	assert_true(StoryScenes.has("isla_talk") and StoryScenes.has("brannoch_isla"))
	assert_eq(NpcRegistry.find("NPC-ISLA").species, "bear")
