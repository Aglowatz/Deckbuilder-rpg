extends GutTest
## Oct 21 story-content brief, Part 1: Primm's four lieutenants as encounters (Lieutenants), their scenes (StoryScenes), the Paste Works
## (S-PASTE, PasteWorks) and the capture at the castle gate (StoryBeats).


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.GOURMAND)
	DungeonCatalog.reset()
	MainDungeons.reset()


func _node(dungeon_key: String, number: int) -> DungeonMap.MapNode:
	for node: DungeonMap.MapNode in MainDungeons.build_map(dungeon_key).nodes:
		if node.number == number:
			return node
	return null


func test_each_lieutenant_is_a_fight_with_a_rule_a_bestiary_entry_and_a_relic() -> void:
	var where: Dictionary = {Lieutenants.QUOTA: ["beefcake", 6], Lieutenants.CLIPWELL: ["refusemancer", 6], Lieutenants.PLUME: ["final", 14], Lieutenants.CRUMB: ["S-PASTE", 3]}
	for id: String in Lieutenants.DEFS.keys():
		var foe: String = Lieutenants.foe_name(id)
		var node: DungeonMap.MapNode = _node(str(where[id][0]), int(where[id][1]))
		assert_not_null(node, id)
		assert_eq(node.enemy_name, foe, "%s fights at %s node %d" % [id, where[id][0], where[id][1]])
		assert_true(node.kind == DungeonMap.Kind.ELITE or node.kind == DungeonMap.Kind.BOSS, "%s is an elite or a boss" % id)
		assert_false(EncounterModifiers.rules(foe).is_empty(), "%s has a one-sided rule" % id)
		for rule: EncounterModifiers.Rule in EncounterModifiers.rules(foe):
			assert_true(rule.is_enemy_side(), "%s's rule is the enemy's" % id)
		assert_not_null(Bestiary.find(foe), "%s is in the Bestiary" % id)
		var relic: EquipmentData = Session.content.equipment_piece(Lieutenants.reward_id(id))
		assert_not_null(relic, "%s pays %s" % [id, Lieutenants.reward_id(id)])
		assert_eq(Lieutenants.for_enemy(foe), id)
	assert_false(EncounterModifiers.rules(Lieutenants.YARDS_RULES_KEY).is_empty(), "Quota's Capital rematch has its rules")


func test_the_first_win_pays_the_relic_once() -> void:
	var foe: String = Lieutenants.foe_name(Lieutenants.PLUME)
	assert_eq(Session.grant_lieutenant_reward(foe), Lieutenants.PLUME)
	assert_true(Session.flag(Lieutenants.flag_beaten(Lieutenants.PLUME)))
	assert_true(Session.owned_equipment_ids().has("plumes_quill"))
	assert_eq(Session.pending_popups.size(), 1, "a reward box for the relic")
	assert_eq(Session.grant_lieutenant_reward(foe), "", "only the first win pays")
	assert_eq(Session.grant_lieutenant_reward("Flexing Brute"), "", "not a lieutenant")


func test_the_scenes_play_where_the_sheet_puts_them() -> void:
	assert_eq(_node("beefcake", 6).talk_before, "quota_checkpoint")
	assert_eq(_node("gourmand", 6).talk_before, "crumb_inspection", "Crumb inspects the Prototype Bay")
	assert_eq(_node("refusemancer", 6).talk_before, "clipwell_mill")
	assert_eq(_node("final", 1).talk_before, "pc_capture", "the castle gate's start node")
	assert_eq(_node("final", 14).talk_before, "pc_plume_memo")
	assert_eq(_node("S-PASTE", 3).talk_after, "crumb_paste_works_after")


func test_every_scene_exists_and_every_speaker_is_known() -> void:
	var referenced: Array[String] = [StoryBeats.MAREN_CAPTURE, StoryBeats.WREN_CAPTURE, "quota_yards", "quota_yards_after", "clipwell_lawn"]
	for id: String in Lieutenants.DEFS.keys():
		referenced.append(str((Lieutenants.DEFS[id] as Dictionary)["fled"]))
	for dungeon_id: String in ["D-HOG", "D-TTK", "D-ROT", "D-PC", "S-PASTE"]:
		var talks: Dictionary = DungeonCatalog.content_for(dungeon_id).get("talks", {}) as Dictionary
		for entry: Variant in talks.values():
			for key: String in ["before", "after"]:
				if (entry as Dictionary).has(key):
					referenced.append(str((entry as Dictionary)[key]))
	for id: String in referenced:
		assert_true(StoryScenes.has(id), "scene %s exists" % id)
	for id: String in StoryScenes.ids():
		assert_false(StoryScenes.steps(id).is_empty(), id)
		for step: Dictionary in StoryScenes.steps(id):
			var speaker: String = str(step["speaker_id"])
			if speaker.is_empty() or speaker == StoryScenes.SET_FLAGS:
				continue
			assert_not_null(NpcRegistry.find(speaker), "%s: speaker %s is in the NPC list" % [id, speaker])
			assert_true(speaker == NpcRegistry.PLAYER_ID or Portraits.texture_for(NpcRegistry.find(speaker).portrait_id) != null, "%s: %s has a portrait" % [id, speaker])


func test_the_fled_scenes_wait_for_the_freed_zone_and_play_once() -> void:
	assert_eq(Lieutenants.fled_scene("beefcake", Session.flags), "", "not before the zone is free")
	Session.complete_zone("beefcake")
	assert_eq(Lieutenants.fled_scene("beefcake", Session.flags), "quota_fled")
	assert_eq(Lieutenants.fled_scene("necrocrat", Session.flags), "", "only the freed zone")
	Session.set_flag(&"quota_fled_seen")
	assert_eq(Lieutenants.fled_scene("beefcake", Session.flags), "", "once")


func test_quota_waits_in_the_yards_until_beaten() -> void:
	var flags: Dictionary = {}
	assert_false(Lieutenants.quota_in_yards(flags, true), "the Gainlands are not free yet: she is still there")
	flags[str(ZoneCompletion.flag_name("beefcake"))] = true
	assert_false(Lieutenants.quota_in_yards(flags, false), "Rollo's quest first")
	assert_true(Lieutenants.quota_in_yards(flags, true))
	flags["quota_beaten"] = true
	assert_false(Lieutenants.quota_in_yards(flags, true))
	var context: BattleContext = Session.make_quota_yards_battle()
	assert_eq(context.enemy_name, Lieutenants.foe_name(Lieutenants.QUOTA))
	assert_eq(context.game.players[1].hp, Lieutenants.YARDS_HP)


func test_clipwell_waits_at_the_sick_patch_once() -> void:
	var flags: Dictionary = {str(ZoneCompletion.flag_name("refusemancer")): true}
	assert_false(CapitalScene.clipwell_at_patch(flags, false))
	assert_true(CapitalScene.clipwell_at_patch(flags, true))
	flags["clipwell_lawn_seen"] = true
	assert_false(CapitalScene.clipwell_at_patch(flags, true))


func test_the_paste_works_is_a_capital_side_dungeon_with_its_rules() -> void:
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.find(PasteWorks.DUNGEON_ID)
	assert_not_null(plan)
	assert_eq(plan.zone_id, CapitalZone.ID)
	assert_eq(plan.nodes.size(), 3)
	assert_eq(DungeonCatalog.side_for_zone(CapitalZone.ID).id, "S-CAP", "the Capital's own side-dungeon door still opens the tunnels")
	var names: Array[String] = []
	for rule: Dictionary in DungeonRules.rules(PasteWorks.DUNGEON_ID):
		names.append(str(rule["name"]))
	assert_eq(names, ["Bland Diet", "Real Food"] as Array[String])
	assert_true(MapArt.has_map(plan.map_id), "a stand-in map until MAP-S-PASTE exists")
	assert_true(Battleboards.has_image(plan.battleboard_id), "a stand-in board until BB-S-PASTE exists")
	assert_true(MusicDirector.DUNGEONS.has(PasteWorks.DUNGEON_ID))


func test_marlo_offers_the_paste_works_after_his_recipes_and_the_freed_buffet() -> void:
	assert_false(_offered_by_marlo(), "not at first")
	Session.start_quest(CapitalZone.QUEST_RECIPES)
	Session.complete_quest(CapitalZone.QUEST_RECIPES)
	assert_false(_offered_by_marlo(), "the Buffet is not free yet")
	Session.complete_zone("gourmand")
	assert_true(_offered_by_marlo())
	Session.start_quest(PasteWorks.QUEST_ID)
	Session.zone_run = ZoneRun.enter(CapitalZone.ID, Session.profile, Session.deck)
	Session.dungeon_key = PasteWorks.DUNGEON_ID
	Session.set_flag(PasteWorks.FLAG_FOUND)
	Session.run = DungeonRun.enter(Session.profile, Session.deck, [] as Array[ModifierSource])
	Session.mini_active = true
	var result: Dictionary = Session.resolve_mini_dungeon(true)
	assert_true(bool(result.get("paste_works", false)))
	assert_true(Session.flag(PasteWorks.FLAG_CLEARED))
	assert_false(Session.flag(ZoneDefs.get_def(CapitalZone.ID).flag_mini_cleared), "the tunnels' own clear flag is untouched")
	assert_true(Session.quest_log.is_active(PasteWorks.QUEST_ID) or Session.quest_log.is_completed(PasteWorks.QUEST_ID))


func _offered_by_marlo() -> bool:
	for quest: QuestData in Session.quests_offered_by(CapitalZone.NPC_MARLO):
		if quest.id == PasteWorks.QUEST_ID:
			return true
	return false


func test_the_capital_anchors_stand_on_open_ground() -> void:
	var layout: CapitalLayout = CapitalLayout.new()
	layout.build()
	var builder: CapitalBuilder = CapitalBuilder.new()
	builder.layout = layout
	builder._index_obstacles()
	builder.gate_open = true
	for anchor: String in [Lieutenants.YARDS_SPOT, "clipwell_patch", PasteWorks.SPOT_ID]:
		assert_true(layout.anchors.has(anchor), anchor)
		var at: Vector3 = layout.anchors[anchor] as Vector3
		assert_true(builder.is_walkable(Vector3(at.x, 0.0, at.z), 0.3), "%s stands on open ground" % anchor)


func test_the_capture_names_the_rescuer_and_old_saves_catch_up() -> void:
	Session.sync_story_tokens()
	assert_eq(RoyalFamily.fill("{rescuer}"), "The Rescuer")
	assert_true(StoryScenes.should_play("pc_capture", Session.flags))
	for flag: String in StoryScenes.flags_set("pc_capture"):
		Session.set_flag(StringName(flag))
	assert_eq(RoyalFamily.fill("{rescuer}"), "Elowen", "named from the capture on")
	assert_eq(RoyalFamily.fill("{rescuer_full}"), "Elowen Vey")
	assert_false(StoryScenes.should_play("pc_capture", Session.flags), "once")
	assert_eq(StoryBeats.maren_scene(Session.flags), StoryBeats.MAREN_CAPTURE, "Maren has news next time")
	# A save that beat Primm before the capture existed: it happened, and Maren tells it as news.
	var old: Dictionary = {"primm_defeated": true}
	assert_eq(StoryBeats.migrate(old), [StoryBeats.FLAG_SEIZED, StoryBeats.FLAG_NAMED] as Array[String])
	assert_eq(StoryBeats.maren_scene(old), StoryBeats.MAREN_CAPTURE)
	assert_eq(StoryBeats.migrate(old), [] as Array[String], "once")
	assert_eq(StoryBeats.migrate({"zone_beefcake_completed": true}), [] as Array[String], "a save before the castle is left alone")
	Session.flags.clear()
	Session.sync_story_tokens()
