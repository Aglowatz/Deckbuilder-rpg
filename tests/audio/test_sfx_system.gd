extends GutTest
## The sound-effects system (docs/audio/sound_direction.md): variants never repeat, pitch and volume drift stay in range, the voice policy keeps the
## important sounds, the bank file is complete and every file it names exists, the bus tree and ducks, the ambience profiles and the acoustics.


func test_variants_never_repeat_back_to_back() -> void:
	var picker: SfxVariantPicker = SfxVariantPicker.new(7)
	for count: int in [2, 3, 5, 6]:
		var last: int = -1
		var seen: Dictionary = {}
		for i: int in range(200):
			var index: int = picker.pick("set_%d" % count, count)
			assert_ne(index, last, "no repeat for a set of %d" % count)
			assert_between(index, 0, count - 1)
			seen[index] = true
			last = index
		assert_eq(seen.size(), count, "every variant of %d is used" % count)


func test_a_single_variant_always_plays() -> void:
	var picker: SfxVariantPicker = SfxVariantPicker.new(3)
	for i: int in range(5):
		assert_eq(picker.pick("one", 1), 0)


func test_pitch_and_volume_drift_stay_in_range() -> void:
	var picker: SfxVariantPicker = SfxVariantPicker.new(11)
	for i: int in range(300):
		assert_between(picker.pitch(0.05), 0.95, 1.05)
		assert_between(picker.volume(2.0), -2.0, 2.0)


func test_voice_policy_prefers_a_free_voice() -> void:
	var voices: Array[Dictionary] = [
		{"busy": true, "event": "a", "priority": 50, "started": 1.0},
		{"busy": false, "event": "", "priority": 0, "started": 0.0},
	]
	assert_eq(SfxVoicePolicy.choose(voices, "b", 10, 3), 1)


func test_an_event_at_its_limit_replaces_its_own_oldest_instance() -> void:
	var voices: Array[Dictionary] = [
		{"busy": true, "event": "hit", "priority": 60, "started": 2.0},
		{"busy": true, "event": "hit", "priority": 60, "started": 1.0},
		{"busy": false, "event": "", "priority": 0, "started": 0.0},
	]
	assert_eq(SfxVoicePolicy.choose(voices, "hit", 60, 2), 1, "the older hit yields, the free voice stays free")


func test_a_full_pool_drops_the_least_important_sound_only_for_a_more_important_one() -> void:
	var voices: Array[Dictionary] = [
		{"busy": true, "event": "hover", "priority": 10, "started": 3.0},
		{"busy": true, "event": "hit", "priority": 70, "started": 1.0},
	]
	assert_eq(SfxVoicePolicy.choose(voices, "trap", 80, 2), 0, "the hover yields to a trap")
	assert_eq(SfxVoicePolicy.choose(voices, "step", 5, 2), -1, "a footstep does not steal anything more important")


func test_the_bank_file_names_only_files_that_exist() -> void:
	var bank: SfxBank = SfxBank.load_from()
	assert_gt(bank.events.size(), 10, "the bank has events")
	for set_name: Variant in bank.sets.keys():
		for path: Variant in bank.files(str(set_name)) as Array:
			assert_true(ResourceLoader.exists(str(path)), "%s exists" % path)


func test_every_event_layer_has_a_valid_shape() -> void:
	var bank: SfxBank = SfxBank.load_from()
	for event_name: Variant in bank.events.keys():
		var event: Dictionary = bank.event(str(event_name))
		assert_true(["World", "Battle", "UI", "Voice", "Ambience", "SFX"].has(str(event["bus"])), "%s bus" % event_name)
		assert_gt((event["layers"] as Array).size(), 0, "%s has layers" % event_name)
		assert_between(float(event["pitch"]), 0.0, 0.12, "%s pitch range" % event_name)
		for layer: Variant in event["layers"] as Array:
			assert_between(float((layer as Dictionary)["delay"]), 0.0, 3.0, "%s layer delay" % event_name)


func test_the_frequent_sounds_have_several_variants() -> void:
	var bank: SfxBank = SfxBank.load_from()
	for event_name: String in ["ui_hover", "ui_click", "card_draw", "card_play", "hit_light", "hit_heavy"]:
		var first_set: String = bank.layer_sets(event_name)[0]
		assert_gte(bank.files(first_set).size(), 3, "%s has 3+ variants" % event_name)


func test_the_bus_tree() -> void:
	AudioMix.ensure_layout()
	var expect: Dictionary = {"Music": "Master", "SFX": "Master", "World": "SFX", "Battle": "SFX", "UI": "SFX", "Ambience": "Master", "Voice": "Master"}
	for bus_name: String in expect.keys():
		var index: int = AudioServer.get_bus_index(bus_name)
		assert_gte(index, 0, bus_name)
		assert_eq(str(AudioServer.get_bus_send(index)), str(expect[bus_name]), "%s sends to %s" % [bus_name, expect[bus_name]])
	assert_not_null(AudioMix.reverb_of("World"), "the World bus has its reverb")


func test_acoustic_profiles_change_the_world_reverb() -> void:
	AudioMix.apply_acoustics("office_halls")
	assert_almost_eq(AudioMix.reverb_of("World").room_size, 0.68, 0.001)
	AudioMix.apply_acoustics("open_meadow")
	assert_almost_eq(AudioMix.reverb_of("World").room_size, 0.3, 0.001)
	AudioMix.apply_acoustics("dry")
	for area: String in ["forest", "town", "gainlands", "dna", "buffet", "heap", "capital_out", "capital_in"]:
		assert_true(AcousticProfiles.PROFILES.has(AcousticProfiles.for_area(area)), area)


func test_a_big_moment_ducks_the_music_and_recovers() -> void:
	Audio.duck_moment(-4.0, 0.2)
	Audio.advance_ducks(0.1)
	assert_lt(Audio.duck_level("Music"), -3.0, "the music dips")
	assert_lt(Audio.duck_level("Ambience"), -3.0, "the ambience dips")
	for i: int in range(40):
		Audio._now += 0.05
		Audio.advance_ducks(0.05)
	assert_almost_eq(Audio.duck_level("Music"), 0.0, 0.01, "and comes back")


func test_dialogue_ducks_the_ambience() -> void:
	Audio.set_dialogue_duck(991, true)
	Audio.advance_ducks(0.5)
	assert_lt(Audio.duck_level("Ambience"), -4.0)
	Audio.set_dialogue_duck(991, false)
	for i: int in range(20):
		Audio.advance_ducks(0.1)
	assert_almost_eq(Audio.duck_level("Ambience"), 0.0, 0.01)


func test_ambience_profiles_resolve_their_base() -> void:
	var grave: Dictionary = AmbienceProfiles.resolved("capital_grave_broken")
	assert_eq(str(grave["acoustic"]), "perfect_plaza", "a district inherits the inside's acoustics")
	var beds: Array[String] = []
	for bed: Variant in grave["beds"] as Array:
		beds.append(str((bed as Dictionary)["set"]))
	assert_has(beds, "amb/perfect_quiet", "and its bed")


func test_the_ambience_manager_crossfades_between_places() -> void:
	var manager: AmbienceManager = AmbienceManager.new()
	add_child_autofree(manager)
	manager.set_area("capital_in", 0.1)
	assert_has(manager.bed_sets(), "amb/perfect_quiet")
	manager.set_area("capital_reek_broken", 0.1)
	assert_has(manager.bed_sets(), "amb/perfect_quiet", "the shared bed keeps playing")
	assert_has(manager.bed_sets(), "amb/flies", "the district adds its own")
	manager.set_area("none", 0.1)
	assert_eq(manager.bed_sets().size(), 0, "silence")


func test_play_records_history_even_headless() -> void:
	Audio.sfx(&"ui_click")
	assert_eq(Audio.history[-1], "ui_click")
