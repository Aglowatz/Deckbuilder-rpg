extends GutTest
## Nov 18 evening, Part 3: a "defeat three" quest in every zone with roaming enemies (Kyle's Hall Monitor is the D.N.A.'s): the Gainlands
## (Foreman Gus), the Buffet (Sous-Chef Tarragon), the Dump (Billie Muckfoot), the Capital (Kestrel) and Crosspath's outskirts (Gatekeeper
## Brannoch). Each counts 0/3 -> 3/3 from when it is taken, only the area's ordinary roamers count and are marked (never the hazards that
## only hurt on contact, the elites or the bosses), and each pays a Gilded pack, gold and experience once.

const ZONES: Array[String] = ["beefcake", "gourmand", "refusemancer", "final"]
const HAZARDS: Dictionary = {"beefcake": "sprite", "necrocrat": "courier", "gourmand": "meatball", "refusemancer": "gulls", "final": "tidybot"}


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.choose_starting_path(Affinity.Type.NECROCRAT)
	Session.set_flag(&"trial_cleared")


func test_each_zone_has_one_with_a_giver_a_gilded_pack_gold_and_xp() -> void:
	var expected: Dictionary = {"beefcake": "gilded_beefcake", "gourmand": "gilded_gourmand", "refusemancer": "gilded_refusemancer", "final": "gilded_general", "town": "gilded_general"}
	for zone_id: String in expected.keys():
		var spec: Dictionary = ZoneQuestDefinitions.defeat_three_for(zone_id)
		assert_false(spec.is_empty(), zone_id)
		var quest: QuestData = QuestCatalog.find(str(spec["id"]))
		assert_not_null(quest, str(spec["id"]))
		assert_eq(quest.category, QuestData.Category.SIDE, "%s is a side quest" % quest.title)
		assert_true(quest.reward_pack_ids.has(str(expected[zone_id])), "%s pays %s" % [quest.title, expected[zone_id]])
		assert_not_null(PackCatalog.find(str(expected[zone_id])), "the pack exists")
		assert_gt(quest.reward_gold, 0)
		assert_gt(quest.reward_xp, 0)
		assert_eq(quest.giver_npc, quest.turn_in_npc)
		assert_eq(quest.objectives.size(), 1)
		assert_false(quest.objectives[0].parts.is_empty(), "the step has a marker part")
		assert_eq(str((quest.objectives[0].parts[0] as Dictionary)["spot"]), QuestMarkers.SPOT_ROAMERS, "the step marks the roamers that count")
		for part: String in ["offer", "active", "ready", "done"]:
			var lines: Array[String] = DungeonCatalog.text_lines("quest.%s.%s" % [quest.id, part])
			assert_eq(lines.size(), 1, "%s: one %s line" % [quest.id, part])
	assert_true(ZoneQuestDefinitions.defeat_three_for("necrocrat").is_empty(), "the D.N.A. has Kyle's Hall Monitor")
	# rewards rise with the zone's level, Hall Monitor's scale at the D.N.A.
	var hall: QuestData = QuestCatalog.find(ZoneQuestDefinitions.HALL_MONITOR)
	var gain: QuestData = QuestCatalog.find("gain_spot_check")
	var cap: QuestData = QuestCatalog.find("cap_patrol_thinning")
	assert_lt(gain.reward_gold, hall.reward_gold, "the Gainlands (level 5) pays less than the D.N.A. (10)")
	assert_gt(cap.reward_gold, hall.reward_gold, "the Capital (20) pays more")


func test_the_givers_are_real_npcs_of_the_zone() -> void:
	var spots: Dictionary = {"beefcake": GainlandsZone.build_def(), "gourmand": BuffetZone.build_def(), "refusemancer": HeapZone.build_def(), "final": CapitalZone.build_def()}
	for zone_id: String in spots.keys():
		var spec: Dictionary = ZoneQuestDefinitions.defeat_three_for(zone_id)
		var found: bool = false
		for entry: Dictionary in (spots[zone_id] as ZoneDef).spots:
			if str(entry["id"]) == str(spec["spot"]):
				found = true
				assert_eq(str(entry.get("npc_name", ZoneQuestDefinitions.DEFEAT_THREE_GIVERS[zone_id])), str(ZoneQuestDefinitions.DEFEAT_THREE_GIVERS[zone_id]), "the giver's name matches the spot")
		assert_true(found, "%s's giver stands at spot %s" % [zone_id, spec["spot"]])
	assert_eq(ZoneQuestDefinitions.DEFEAT_THREE_GIVERS["town"], QuestDefinitions.BRANNOCH)


func test_only_ordinary_roamers_count() -> void:
	for zone_id: String in HAZARDS.keys():
		assert_false(ZoneQuestDefinitions.is_ordinary(zone_id, str(HAZARDS[zone_id])), "%s: the contact-damage %s never counts" % [zone_id, HAZARDS[zone_id]])
	assert_false(ZoneQuestDefinitions.is_ordinary("gourmand", "casserole"), "an elite never counts")
	assert_false(ZoneQuestDefinitions.is_ordinary("final", "spotless"), "a boss never counts")
	assert_false(ZoneQuestDefinitions.is_ordinary("final", "swarm"))
	assert_true(ZoneQuestDefinitions.is_ordinary("necrocrat", "manager"))
	assert_true(ZoneQuestDefinitions.is_ordinary("beefcake", "golem"))
	assert_true(ZoneQuestDefinitions.is_ordinary("town", "raccoon"))
	# every ordinary type is a duel foe; every hazard type deals contact damage
	assert_eq(DnaEnemies.info("courier").kind, ZoneEnemyInfo.Kind.DAMAGE)
	assert_eq(GainlandsEnemies.info("sprite").kind, ZoneEnemyInfo.Kind.DAMAGE)
	for type: String in ZoneQuestDefinitions.ORDINARY_ROAMERS["necrocrat"]:
		assert_eq(DnaEnemies.info(type).kind, ZoneEnemyInfo.Kind.BATTLE)


func test_the_markers_skip_the_contact_damage_enemies() -> void:
	var source: String = FileAccess.get_file_as_string("res://world/zone/zone_scene.gd")
	var marker: String = source.get_slice("func _resolve_marker_spot", 1).get_slice("\nfunc ", 0)
	assert_true(marker.contains("enemy.info.kind != ZoneEnemyInfo.Kind.BATTLE"), "hazards (the D.N.A.'s couriers) are never marked")
	assert_true(marker.contains("ZoneQuestDefinitions.is_ordinary("), "only the area's ordinary roamers")
	# Kyle's Hall Monitor and every defeat-enemies step mark through the same filter
	for id: String in [ZoneQuestDefinitions.HALL_MONITOR, ZoneQuestDefinitions.BACKLOG, GainlandsZone.QUEST_LANES, ZoneQuestDefinitions.SIDE_REF, "gain_spot_check", "buf_leftovers", "heap_pest_control", "cap_patrol_thinning"]:
		var quest: QuestData = QuestCatalog.find(id)
		var parts: Array = quest.objectives[0].parts
		assert_false(parts.is_empty(), "%s marks roamers" % id)


func test_zero_to_three_and_the_reward_in_every_zone() -> void:
	for zone_id: String in ZONES:
		Session.new_game()
		Session.choose_starting_path(Affinity.Type.NECROCRAT)
		Session.begin_zone_visit(zone_id)
		var spec: Dictionary = ZoneQuestDefinitions.defeat_three_for(zone_id)
		var types: Array = ZoneQuestDefinitions.ORDINARY_ROAMERS[zone_id]
		_win(str(types[0]), "before_%s" % zone_id)  # a win before taking the quest does not count
		assert_true(Session.start_quest(str(spec["id"])), "%s can be taken" % spec["id"])
		var quest: QuestData = QuestCatalog.find(str(spec["id"]))
		assert_eq(Session.quest_log.objective_progress(quest, 0, Session.unlock_state()), Vector2i(0, 3), "%s starts at 0/3" % quest.title)
		for index: int in range(3):
			_win(str(types[index % types.size()]), "roamer_%s_%d" % [zone_id, index])
			assert_eq(Session.quest_log.objective_progress(quest, 0, Session.unlock_state()).x, index + 1)
		assert_true(Session.quest_log.is_ready_to_turn_in(quest, Session.unlock_state()))
		var pack: String = str(spec["pack"])
		var packs: int = Session.pack_count(pack)
		var gold: int = Session.gold
		assert_true(Session.turn_in_quest(quest.id))
		assert_eq(Session.pack_count(pack), packs + 1, "%s pays its Gilded pack" % quest.title)
		assert_gte(Session.gold - gold, quest.reward_gold)
		assert_false(Session.start_quest(quest.id), "one time only")


func test_a_hazard_never_moves_the_count() -> void:
	Session.begin_zone_visit("gourmand")
	assert_true(Session.start_quest("buf_leftovers"))
	_win("casserole", "elite_casserole")
	var quest: QuestData = QuestCatalog.find("buf_leftovers")
	assert_eq(Session.quest_log.objective_progress(quest, 0, Session.unlock_state()).x, 0, "the elite does not count")


func test_crosspath_outskirts_counts_town_roamers() -> void:
	var quest: QuestData = QuestCatalog.find("town_outskirts_watch")
	Session.quest_log.active.append(quest.id)  # past Maren's welcome (its prerequisite), as a player would be
	assert_true(Session.quest_log.is_active(quest.id))
	for index: int in range(3):
		var context: BattleContext = Session.make_town_battle(TownEnemies.IDS[index], "town_%s" % TownEnemies.IDS[index])
		context.game._end_game(0, false)
		context.won = true
		Session.resolve_town_battle(context)
	assert_eq(Session.quest_log.objective_progress(quest, 0, Session.unlock_state()).x, 3, "three outskirts roamers")


func _win(enemy_type: String, instance_id: String) -> void:
	var context: BattleContext = Session.make_zone_battle(enemy_type, instance_id)
	context.game._end_game(0, false)
	context.won = true
	Session.resolve_zone_battle(context)
