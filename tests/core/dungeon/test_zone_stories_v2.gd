extends GutTest
## Story v2 Part F: the zone story updates (Gainlands, Test Kitchen, D.N.A., Rotheart): text keys, cutscenes, freed NPCs, the unrescued-Flex branch.


func _story(zone_id: String) -> ZoneStoryText:
	return ZoneStoryText.for_zone(zone_id)


func test_every_cutscene_beat_has_text_and_a_speaker() -> void:
	var missing: Array[String] = []
	for scene_id: String in CutsceneDefs.SCENES.keys():
		var story: ZoneStoryText = _story(CutsceneDefs.zone_of(scene_id))
		for beat: Dictionary in CutsceneDefs.beats(scene_id):
			for key: String in [str(beat["key"]), str(beat["speaker_key"])]:
				if not story.lines.has(key):
					missing.append("%s: %s" % [scene_id, key])
	assert_eq(missing, [] as Array[String])


func test_the_new_scenes_are_attached_to_their_boss_nodes() -> void:
	var kitchen: DungeonMap = MainDungeons.build_map(TestKitchenDungeon.ZONE_ID)
	assert_eq(kitchen.boss().after_scene, "wonder", "the true chef's dish plays after the Doppelganger")
	var hall: DungeonMap = MainDungeons.build_map(HallOfApprovalsDungeon.ZONE_ID)
	assert_eq(hall.boss().after_scene, "vacancy", "Agnes takes the vacant office after Mortimer")
	assert_eq(hall.boss().enemy_name, "Mortimer Grimsby, CE-No")
	var found_vellum: bool = false
	for node: DungeonMap.MapNode in hall.nodes:
		if node.enemy_name == "Undersecretary Vellum":
			found_vellum = true
			assert_eq(node.title, "Appeals Court")
	assert_true(found_vellum, "Vellum is the Appeals Court elite")


func test_agnes_and_the_records_labyrinth_have_story_beats() -> void:
	var hall: DungeonMap = MainDungeons.build_map(HallOfApprovalsDungeon.ZONE_ID)
	var keys: Array[String] = []
	for node: DungeonMap.MapNode in hall.nodes:
		keys.append(node.story_before)
	for key: String in ["dungeon.ha_number.before", "dungeon.ha_records.before", "dungeon.ha_forms.before", "dungeon.ha_clerk.before"]:
		assert_true(keys.has(key), key)
		assert_true(_story("necrocrat").lines.has(key), key)
	var records: String = "\n".join(_story("necrocrat").get_lines("dungeon.ha_records.before"))
	assert_true(records.contains("Deceased (presumed). Remains: not on file."), "the heir clause is on the transfer document")
	assert_true(records.contains("Irregular"), "Agnes finds it irregular")
	assert_eq(NpcRegistry.story_speaker("dungeon.ha_number.before"), "NPC-AGNES")


func test_every_freed_npc_has_dialogue() -> void:
	var missing: Array[String] = []
	for zone_id: String in ZoneDefs.ids():
		var def: ZoneDef = ZoneDefs.get_def(zone_id)
		for entry: Dictionary in def.freed_npcs:
			if not _story(zone_id).lines.has("freed_npc.%s" % str(entry["id"])):
				missing.append("%s: %s" % [zone_id, str(entry["id"])])
	assert_eq(missing, [] as Array[String])
	var kitchen: ZoneDef = ZoneDefs.get_def("gourmand")
	var ids: Array[String] = []
	for entry: Dictionary in kitchen.freed_npcs:
		ids.append(str(entry["id"]))
	assert_true(ids.has("escoffina"), "Escoffina stays in the kitchen as an apprentice")
	assert_true(ids.has("grandchef"))


func test_each_freed_leader_speaks_to_the_wanderer() -> void:
	var lines: Dictionary = {
		"beefcake": ["freed_npc.heartlift", "it was not the part that matters"],
		"gourmand": ["freed_npc.grandchef", "do something worth signing"],
		"necrocrat": ["freed_npc.agnes", "Never let anyone file you under"],
		"refusemancer": ["freed_npc.compostella", "Let it be the start of something in you"],
	}
	for zone_id: String in lines.keys():
		var text: String = "\n".join(_story(zone_id).get_lines(str((lines[zone_id] as Array)[0])))
		assert_true(text.contains(str((lines[zone_id] as Array)[1])), zone_id)


func test_flex_walks_out_on_his_own_when_not_rescued() -> void:
	var run: DungeonRun = DungeonRun.enter(PlayerProfile.new(), GameFactory.make_deck())
	assert_false(HouseOfGainsDungeon.rescued(run))
	assert_eq(HouseOfGainsDungeon.boss_story_key("dungeon.hg_boss.after", run), "dungeon.hg_boss.after_alone")
	assert_eq(HouseOfGainsDungeon.boss_story_key("dungeon.hg_boss.before", run), "dungeon.hg_boss.before_alone")
	assert_eq(HouseOfGainsDungeon.boss_story_key("dungeon.hg_boss.after", null), "dungeon.hg_boss.after", "no run: the normal text")
	run.dungeon_sources.append(HouseOfGainsDungeon.heartlift_boon())
	assert_true(HouseOfGainsDungeon.rescued(run))
	assert_eq(HouseOfGainsDungeon.boss_story_key("dungeon.hg_boss.after", run), "dungeon.hg_boss.after")
	var story: ZoneStoryText = _story("beefcake")
	assert_true("\n".join(story.get_lines("dungeon.hg_boss.after_alone")).contains("Lovely day for it"))
	assert_true("\n".join(story.get_lines("dungeon.hg_boss.before")).contains("star pupil"))


func test_the_rotheart_cure_is_letting_the_seed_rot() -> void:
	var story: ZoneStoryText = _story("refusemancer")
	var cure: String = "\n".join(story.get_lines("cutscene.sever.2")) + "\n".join(story.get_lines("cutscene.sever.3"))
	assert_true(cure.contains("Let it rot"))
	assert_true("\n".join(story.get_lines("cutscene.sever.1")).contains("Primm's gift"))
	for key: String in ["dungeon.rh_pool.before", "dungeon.rh_roots.before"]:
		assert_true(story.lines.has(key), key)
	assert_false("\n".join(story.get_lines("dungeon.rh_boss.before")).contains("His eyes"), "Compostella is she/her")
