extends GutTest
## Part D: zone completion state - the flag, the count, the event, save/load, the unlock thresholds,
## the freed look and the ruler's presence.

const ZONES: Array[String] = ["beefcake", "gourmand", "necrocrat", "refusemancer"]


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()


func after_each() -> void:
	for zone_id: String in ZONES:
		ZoneStoryText.set_zone_freed(zone_id, false)


func test_no_zone_is_completed_in_a_new_game() -> void:
	assert_eq(Session.completed_zone_count(), 0)
	for zone_id: String in ZONES:
		assert_false(Session.is_zone_completed(zone_id))
	assert_false(Session.arena_unlocked())
	assert_false(Session.alchemist_unlocked())


func test_complete_zone_sets_the_flag_once_and_counts() -> void:
	assert_true(Session.complete_zone("beefcake"))
	assert_true(Session.is_zone_completed("beefcake"))
	assert_eq(Session.completed_zone_count(), 1)
	assert_false(Session.complete_zone("beefcake"), "completing a zone twice does nothing")
	assert_eq(Session.completed_zone_count(), 1)
	assert_true(Session.complete_zone("gourmand"))
	assert_eq(Session.completed_zone_count(), 2)
	assert_false(Session.complete_zone("nowhere"), "an unknown zone cannot be completed")
	assert_eq(Session.completed_zone_count(), 2)


func test_completion_fires_the_event_with_the_zone_id() -> void:
	watch_signals(EventBus)
	Session.complete_zone("necrocrat")
	assert_signal_emitted_with_parameters(EventBus, "zone_completed", ["necrocrat"])
	Session.complete_zone("necrocrat")
	assert_signal_emit_count(EventBus, "zone_completed", 1)


func test_unlock_thresholds_arena_after_one_alchemist_after_two() -> void:
	Session.complete_zone("refusemancer")
	assert_true(Session.arena_unlocked())
	assert_false(Session.alchemist_unlocked())
	Session.complete_zone("beefcake")
	assert_true(Session.arena_unlocked())
	assert_true(Session.alchemist_unlocked())
	assert_eq(ZoneCompletion.progress_text(Session.flags), "2 of 4 zones free")


func test_completed_zones_survive_a_save_and_load() -> void:
	Session.ensure_game(Affinity.Type.A)
	Session.complete_zone("beefcake")
	Session.complete_zone("necrocrat")
	var data: Dictionary = Session.to_dict()
	Session.new_game()
	assert_eq(Session.completed_zone_count(), 0)
	assert_true(Session.from_dict(data))
	assert_eq(Session.completed_zone_count(), 2)
	assert_true(Session.is_zone_completed("beefcake"))
	assert_true(Session.is_zone_completed("necrocrat"))
	assert_false(Session.is_zone_completed("gourmand"))
	assert_true(ZoneStoryText.for_zone("beefcake").is_freed(), "the loaded save also switches the story to its freed text")
	assert_false(ZoneStoryText.for_zone("gourmand").is_freed())


func test_a_new_game_clears_the_freed_story_state() -> void:
	Session.complete_zone("gourmand")
	assert_true(ZoneStoryText.for_zone("gourmand").is_freed())
	Session.new_game()
	assert_false(ZoneStoryText.for_zone("gourmand").is_freed())


func _lit_scene() -> Node3D:
	var scene: Node3D = Node3D.new()
	scene.add_child(GainlandsLook.environment())
	scene.add_child(GainlandsLook.sun())
	add_child_autofree(scene)
	return scene


func test_a_freed_zone_is_lit_brighter_than_an_oppressed_one() -> void:
	var def: ZoneDef = GainlandsZone.build_def()
	var base_env: Environment = GainlandsLook.environment().environment
	var base_sun: float = GainlandsLook.sun().light_energy
	var gloomy: Node3D = _lit_scene()
	ZoneCompletionLook.apply(gloomy, def, false)
	var freed: Node3D = _lit_scene()
	ZoneCompletionLook.apply(freed, def, true)
	var gloomy_env: Environment = (gloomy.get_child(0) as WorldEnvironment).environment
	var freed_env: Environment = (freed.get_child(0) as WorldEnvironment).environment
	assert_lt(gloomy_env.tonemap_exposure, base_env.tonemap_exposure, "oppressed: dimmer than the baseline")
	assert_gt(freed_env.tonemap_exposure, base_env.tonemap_exposure, "freed: brighter than the baseline")
	assert_lt(gloomy_env.adjustment_saturation, freed_env.adjustment_saturation, "and more colorful once freed")
	var gloomy_sun: DirectionalLight3D = gloomy.get_child(1) as DirectionalLight3D
	var freed_sun: DirectionalLight3D = freed.get_child(1) as DirectionalLight3D
	assert_lt(gloomy_sun.light_energy, base_sun)
	assert_gt(freed_sun.light_energy, base_sun)
	assert_gt(gloomy_env.fog_density, freed_env.fog_density, "the oppressive fog lifts")


func _presence(zone_id: String, freed: bool) -> Node3D:
	var parent: Node3D = Node3D.new()
	add_child_autofree(parent)
	var def: ZoneDef = ZoneDefs.get_def(zone_id)
	var story: ZoneStoryText = ZoneStoryText.for_zone(zone_id)
	RulerPresence.build(parent, ZoneMap.new(), def, story, Vector3(50, 0, 60), freed)
	return parent


func test_the_rulers_statue_and_banners_stand_until_the_zone_is_freed() -> void:
	for zone_id: String in ZONES:
		var oppressed: Node3D = _presence(zone_id, false)
		assert_true(RulerPresence.has_ruler_props(oppressed), "%s: the ruler's statue stands" % zone_id)
		var banners: Node = oppressed.get_node(RulerPresence.BANNERS_NAME)
		assert_gt(banners.get_child_count(), 0)
		var freed: Node3D = _presence(zone_id, true)
		assert_false(RulerPresence.has_ruler_props(freed), "%s: the statue is toppled once freed" % zone_id)


func test_every_zone_has_a_ruler_and_a_freed_leader_with_dialogue() -> void:
	for zone_id: String in ZONES:
		var def: ZoneDef = ZoneDefs.get_def(zone_id)
		assert_false(def.ruler_name.is_empty(), zone_id)
		assert_false(def.freed_npcs.is_empty(), "%s has a freed leader" % zone_id)
		var story: ZoneStoryText = ZoneStoryText.for_zone(zone_id)
		for entry: Dictionary in def.freed_npcs:
			var lines: Array[String] = story.get_lines("freed_npc.%s" % str(entry["id"]))
			assert_false(lines[0].begins_with("[missing"), "%s has freed dialogue" % str(entry["id"]))
		assert_false(story.text("ruler.statue").begins_with("[missing"))
		assert_false(story.text("ruler.statue.freed").begins_with("[missing"))


func test_the_announcement_text_exists_for_every_zone() -> void:
	var story: StoryText = StoryText.shared()
	for zone_id: String in ZONES:
		assert_true(story.has_text("zone.complete.%s.title" % zone_id))
		assert_true(story.has_text("zone.complete.%s.body" % zone_id))


func test_the_announcement_screen_shows_the_title_and_unlock_lines() -> void:
	var screen: AnnouncementScreen = AnnouncementScreen.make("THE GAINLANDS ARE FREE!", "Body text.", ["The Arena is open!"])
	add_child_autofree(screen)
	await wait_frames(2)
	assert_not_null(screen.find_child("AnnouncementTitle", true, false))
	assert_eq((screen.find_child("AnnouncementTitle", true, false) as Label).text, "THE GAINLANDS ARE FREE!")
	watch_signals(screen)
	(screen.find_child("ContinueButton", true, false) as FancyButton).pressed.emit()
	assert_signal_emitted(screen, "finished")
