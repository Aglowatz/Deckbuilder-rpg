extends GutTest
## Part B: the story from docs/design/story_source.md is applied everywhere, the Verdant Heap is now
## the Verdant Dump, and zone completion swaps a zone's text to its freed variants.

const ZONE_IDS: Array[String] = ["beefcake", "gourmand", "necrocrat", "refusemancer"]


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()


func after_each() -> void:
	for zone_id: String in ZONE_IDS:
		ZoneStoryText.set_zone_freed(zone_id, false)


func test_the_verdant_heap_is_now_the_verdant_dump_in_every_story_file() -> void:
	for zone_id: String in ZONE_IDS:
		var story: ZoneStoryText = ZoneStoryText.for_zone(zone_id)
		for key: Variant in story.lines.keys():
			for line: Variant in story.lines[key] as Array:
				assert_false(str(line).contains("Verdant Heap"), "%s.%s still says Verdant Heap" % [zone_id, str(key)])
	assert_true(HeapZone.build_def().full_name.begins_with("The Verdant Dump"))


func test_every_zone_text_mentions_its_oppression_and_the_ruler() -> void:
	var gain: ZoneStoryText = ZoneStoryText.for_zone("beefcake")
	assert_true(gain.text("sign.regime_rules").contains("GRISTLE"))
	assert_true(gain.text("npc.brenda.intro").contains("Grandmaster Flex"))
	var buffet: ZoneStoryText = ZoneStoryText.for_zone("gourmand")
	assert_true(buffet.text("npc.odalys.intro").contains("Special Sauce"))
	var dna: ZoneStoryText = ZoneStoryText.for_zone("necrocrat")
	assert_true(dna.text("npc.dolores.intro").contains("the authorization is valid"))
	var dump: ZoneStoryText = ZoneStoryText.for_zone("refusemancer")
	assert_true(dump.text("npc.marigold.intro").contains("Fernwick Loam"))


func test_corrupted_envoys_fit_each_factions_situation() -> void:
	var story: StoryText = StoryText.shared()
	assert_true("\n".join(story.npc_intro_lines("beefcake")).contains("regime"))
	assert_true("\n".join(story.npc_intro_lines("gourmand")).contains("Special Sauce"))
	assert_true("\n".join(story.npc_intro_lines("necrocrat")).contains("authorization is valid"))
	assert_true("\n".join(story.npc_intro_lines("refusemancer")).contains("Rot"))


func test_the_town_has_a_name_and_a_story_intro() -> void:
	var story: StoryText = StoryText.shared()
	assert_eq(story.text("town.name"), "Concord Crossing")
	assert_true(story.text("town.elder.first").contains("Primm"))
	assert_true(story.text("town.elder.first").contains("Concordia"))
	for key: String in ["town.guard", "town.vendor.first", "town.alchemist.locked", "town.arena.locked"]:
		assert_true(story.has_text(key), key)


func test_a_freed_zone_uses_the_freed_variants() -> void:
	var story: ZoneStoryText = ZoneStoryText.for_zone("beefcake")
	var oppressed: String = story.text("sign.regime_rules")
	assert_true(story.lines.has("sign.regime_rules.freed"))
	assert_true(Session.complete_zone("beefcake"))
	assert_ne(story.text("sign.regime_rules"), oppressed, "the regime's rules came down")
	assert_true(story.text("sign.regime_rules").contains("NEW HOUSE RULES"))
	assert_false(Session.complete_zone("beefcake"), "completing twice does nothing")
	# Another zone is unaffected.
	assert_false(ZoneStoryText.for_zone("gourmand").is_freed())


func test_every_freed_key_has_a_base_key() -> void:
	for zone_id: String in ZONE_IDS:
		var story: ZoneStoryText = ZoneStoryText.for_zone(zone_id)
		for key: Variant in story.lines.keys():
			if str(key).ends_with(".freed"):
				assert_true(story.lines.has(str(key).trim_suffix(".freed")), "%s has a base text for %s" % [zone_id, str(key)])
