extends GutTest
## Overnight Oct 27-28, Part 2: the roster renames keep old saves and old pictures, every roaming enemy has a sprite key the importer
## can fill, and the boss intro's cut-out resolves to the transparent dialogue portrait (or an imported CUT-* file) with the Bestiary
## square as the last fallback.


func test_renamed_roamers_resolve_to_their_new_entry() -> void:
	assert_eq(Bestiary.canonical("Flexing Brute"), "Quota Spotter")
	assert_eq(Bestiary.canonical("Stray Gym Hound"), "Pantry Hound")
	assert_eq(Bestiary.canonical("Zombie Intern"), "Unpaid Intern")
	assert_eq(Bestiary.canonical("Possessed Scarecrow Druid"), "Hungry Scarecrow")
	assert_eq(Bestiary.canonical("Compliance Officer"), "Correction Officer")
	assert_eq(Bestiary.canonical("Quota Spotter"), "Quota Spotter", "a new name is its own entry")
	for old: String in Bestiary.RENAMED:
		assert_eq(Bestiary.find(old).name, str(Bestiary.RENAMED[old]), "%s finds the renamed entry" % old)
		assert_not_null(Bestiary.find(str(Bestiary.RENAMED[old])), "%s has an entry" % Bestiary.RENAMED[old])


func test_old_save_counters_count_toward_the_renamed_entry() -> void:
	var counters: Dictionary = {"bestiary_met:Flexing Brute": 3, "bestiary_won:Flexing Brute": 2, "bestiary_won:Quota Spotter": 1}
	assert_eq(Bestiary.met_count(counters, "Quota Spotter"), 3, "met under the old name")
	assert_eq(Bestiary.won_count(counters, "Quota Spotter"), 3, "won under both names add up")
	assert_true(Bestiary.is_known(counters, "Flexing Brute"))
	assert_true(Bestiary.is_known(counters, "Quota Spotter"))


func test_old_bestiary_picture_ids_are_tried_for_a_renamed_entry() -> void:
	assert_eq(Bestiary.art_id("Quota Spotter"), "BST-QUOTA-SPOTTER")
	assert_eq(Bestiary.art_id("Flexing Brute"), "BST-QUOTA-SPOTTER", "the old name maps to the new id")
	assert_eq(Bestiary.legacy_art_ids("Quota Spotter"), ["BST-FLEXING-BRUTE"] as Array[String])
	assert_eq(Bestiary.legacy_art_ids("Cave Scavenger"), [] as Array[String])
	Bestiary.reset_art()
	assert_not_null(Bestiary.art("Quota Spotter"), "the picture made under the old name still shows")


func test_every_roaming_enemy_has_a_sprite_key_the_importer_can_fill() -> void:
	assert_eq(Bestiary.sprite_key("Quota Spotter"), "FOE-QUOTA-SPOTTER")
	assert_eq(Bestiary.sprite_key("Tidy-Bot"), "FOE-TIDY-BOT")
	var seen: Dictionary = {}
	var roster: Dictionary = {"beefcake": ["brute", "golem", "sprite"], "necrocrat": ["manager", "intern", "courier"], "gourmand": ["loaf", "jelly", "meatball", "casserole"], "refusemancer": ["golem", "scarecrow", "gulls"], "final": ["officer", "inspector", "tidybot", "wretch", "swarm", "spotless"]}
	for zone_id: String in roster:
		for enemy_id: String in roster[zone_id] as Array:
			var info: ZoneEnemyInfo = ZoneEnemies.info(zone_id, enemy_id)
			var key: String = info.sprite_key()
			if enemy_id == CapitalEnemies.SPOTLESS:
				assert_eq(key, "SPOTLESS", "XP pass Oct 30: Captain Spotless wears his own NPC set")
				continue
			assert_true(key.begins_with(Bestiary.SPRITE_PREFIX), "%s/%s: %s" % [zone_id, enemy_id, key])
			assert_false(seen.has(key), "%s is unique (%s/%s vs %s)" % [key, zone_id, enemy_id, seen.get(key, "")])
			seen[key] = zone_id + "/" + enemy_id
	for type: String in ["hound", "clerk", "raccoon"]:
		var town: ZoneEnemyInfo = TownEnemies.info(type)
		assert_true(town.sprite_key().begins_with("FOE-"), type)
	var custom: ZoneEnemyInfo = ZoneEnemyInfo.new()
	custom.display_name = "Anything"
	custom.sprite = "HURL"
	assert_eq(custom.sprite_key(), "HURL", "an explicit set wins")


func test_the_three_town_roamers_are_bestiary_entries() -> void:
	for type: String in ["hound", "clerk", "raccoon"]:
		var info: ZoneEnemyInfo = TownEnemies.info(type)
		var entry: Bestiary.Entry = Bestiary.find(info.display_name)
		assert_not_null(entry, info.display_name)
		if entry != null:
			assert_eq(entry.kind, "roamer")


func test_cutout_ids_cover_every_entrance_with_a_speaking_character() -> void:
	assert_eq(Bestiary.cutout_id("Chancellor Clench, Iron Regent"), "CUT-CLENCH")
	assert_eq(Bestiary.cutout_id("Hollow Warden"), "CUT-WARDEN", "the alias table is used")
	assert_eq(Bestiary.cutout_id("Primm - Reflection"), "CUT-PRIMM", "phase names share the boss's cut-out")
	assert_eq(Bestiary.cutout_id("Brick Bronson"), "CUT-BRONSON", "a gatekeeper's plate name resolves")
	assert_eq(Bestiary.cutout_id("Cave Scavenger"), "", "a nameless foe has none")
	var ids: Array[String] = Bestiary.cutout_ids()
	assert_true(ids.size() >= 20, "one per boss / lieutenant / gatekeeper (%d)" % ids.size())
	for id: String in ids:
		assert_true(id.begins_with("CUT-"), id)
	var known: Dictionary = Portraits.known_portraits()
	for id: String in ids:
		assert_true(known.has(id), "%s is a Portrait Image ID the importer accepts" % id)


func test_cutout_falls_back_to_the_dialogue_portrait_then_to_nothing() -> void:
	var portrait: Texture2D = Bestiary.cutout("Chancellor Clench, Iron Regent")
	assert_not_null(portrait, "Clench has a transparent dialogue portrait")
	if portrait != null:
		assert_true(portrait.get_height() > portrait.get_width(), "the full 2:3 figure, not the square crop")
	assert_null(Bestiary.cutout("Cave Scavenger"), "no speaking character: the intro keeps the Bestiary square")
	assert_not_null(Bestiary.art("Cave Scavenger"), "which exists")
