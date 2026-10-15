extends GutTest
## A zone shrine (SR-7) pays once from the zone's own chest table: a card entry that is not one-of-a-kind, deterministic per shrine, never a new reward.


func test_the_offering_is_a_card_of_the_zone_table() -> void:
	for zone_id: String in ["beefcake", "necrocrat"]:
		var table: Dictionary = ZoneDefs.get_def(zone_id).chest_rewards
		var pool: Array[String] = ZoneShrine.card_pool(table)
		assert_false(pool.is_empty(), "%s has card entries to draw from" % zone_id)
		var reward: Dictionary = ZoneShrine.reward(table, "%s:shrine" % zone_id)
		assert_true(reward.has("card"), "%s: the shrine gives a card" % zone_id)
		assert_has(pool, str(reward["card"]), "%s: a card the zone already pays out" % zone_id)
		assert_eq(reward, ZoneShrine.reward(table, "%s:shrine" % zone_id), "deterministic")


func test_one_of_a_kind_entries_are_never_drawn() -> void:
	var table: Dictionary = {
		"a": {"gold": 10, "card": "B-01", "cosmetic": "hat"},
		"b": {"gold": 10, "card": "B-02", "equipment": "belt"},
		"c": {"gold": 10, "card": "B-03", "pack": "starter"},
		"d": {"gold": 10, "card": ""},
		"e": {"gold": 10, "card": "B-05"},
	}
	assert_eq(ZoneShrine.card_pool(table), ["B-05"] as Array[String])
	assert_eq(ZoneShrine.reward(table, "x"), {"card": "B-05"})


func test_a_table_without_cards_pays_a_little_gold() -> void:
	assert_eq(ZoneShrine.reward({"a": {"gold": 30}}, "x"), {"gold": ZoneShrine.FALLBACK_GOLD})
	assert_eq(ZoneShrine.reward({}, "x"), {"gold": ZoneShrine.FALLBACK_GOLD})


func test_the_shrine_spots_and_their_flags() -> void:
	for zone_id: String in ["beefcake", "necrocrat"]:
		var def: ZoneDef = ZoneDefs.get_def(zone_id)
		var found: Dictionary = {}
		for spot: Dictionary in def.spots:
			if str(spot["kind"]) == "shrine":
				found = spot
		assert_false(found.is_empty(), "%s has one shrine spot" % zone_id)
		assert_eq(def.poi_kinds.get(str(found.get("id", "")), -1), MapPoi.Kind.INTERACTABLE, "%s: the shrine is an interactable on the minimap" % zone_id)
		assert_eq(ZoneShrine.flag(zone_id, "shrine"), StringName("shrine_%s_shrine" % zone_id))
		assert_false(ZoneStoryText.for_zone(zone_id).get_lines("shrine.used").is_empty(), "%s: the spent shrine has a line" % zone_id)
