extends GutTest
## Story v2 Part H: Rip's forest portal, the hidden hatch and the postgame Path-ology Lab. Oct 21: the sheet's 16-node Lab, Elowen in Cell 4
## (T-24) and Siphon's Protocols (ProtocolJam).


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.level_track_grants = false  # these tests count gold and packs exactly; the reward track pays its own (test_level_track)
	DungeonCatalog.reset()
	MainDungeons.reset()


func test_the_lab_is_the_sheets_16_node_postgame_dungeon_with_branching_and_the_story_nodes() -> void:
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.find(PathologyLab.DUNGEON_ID)
	assert_not_null(plan)
	assert_true(plan.is_postgame())
	assert_eq(plan.nodes.size(), 16)
	assert_eq(plan.map_id, "MAP-LAB")
	assert_eq(plan.battleboard_id, "BB-LAB")
	var branching: int = 0
	var names: Array[String] = []
	for node: DungeonCatalog.BlueprintNode in plan.nodes:
		names.append(node.node_name)
		if node.next.size() > 1:
			branching += 1
	assert_true(branching >= 3, "the map branches")
	for expected: String in ["Cell 4", "The Draining Chamber", "The Mentor's Study", "The Extraction Theater"]:
		assert_true(names.has(expected), expected)
	var map: DungeonMap = MainDungeons.build_map(PathologyLab.DUNGEON_ID)
	assert_eq(map.problems(), [] as Array[String])
	assert_eq(map.boss().enemy_name, "Dr. Ambrose Siphon, Chief Path-ologist")
	assert_true(MapArt.has_map("MAP-LAB"), "placeholder map art exists")


func test_the_lab_is_far_harder_than_the_castle_on_paper() -> void:
	var lab_boss: MainDungeonDef.Foe = MainDungeons.def(PathologyLab.DUNGEON_ID).foe("Dr. Ambrose Siphon, Chief Path-ologist")
	var castle_boss: MainDungeonDef.Foe = MainDungeons.def("final").foe(PrimmBoss.BOSS_FOE)
	assert_not_null(lab_boss)
	assert_true(lab_boss.hp > castle_boss.hp, "more boss HP than Primm's first phase")
	var recipe: Dictionary = lab_boss.recipe
	for leader: String in ["N-33", "B-32", "G-33", "R-33"]:
		assert_true(recipe.has(leader), "%s in Siphon's deck" % leader)


func test_the_story_nodes_have_their_scenes() -> void:
	var map: DungeonMap = MainDungeons.build_map(PathologyLab.DUNGEON_ID)
	var by_number: Dictionary = {}
	for node: DungeonMap.MapNode in map.nodes:
		by_number[node.number] = node
	var cell: DungeonMap.MapNode = by_number[11] as DungeonMap.MapNode
	assert_eq(cell.kind, DungeonMap.Kind.RESCUE)
	assert_eq(cell.talk_before, "lab_cell4")
	var cell_text: String = "\n".join(StoryScenes.all_lines("lab_cell4"))
	assert_true(cell_text.contains("tally marks"), "ten years of tally marks")
	assert_true(cell_text.contains("four colors"), "the child's drawing of four colors")
	assert_true(cell_text.contains("Took you long enough, Tess."), "the sheet's line")
	assert_not_null(MainDungeons.def(PathologyLab.DUNGEON_ID).event(cell.event_id), "Cell 4's rescue event")
	assert_eq(map.boss().talk_before, "lab_siphon")
	assert_eq(map.boss().talk_after, "lab_siphon_after")
	for scene: String in ["lab_hatch", "lab_cell4_after", "lab_study", "lab_study_alone", "lab_siphon_alone", "lab_siphon_after_alone"]:
		assert_true(StoryScenes.has(scene), scene)
	assert_true("\n".join(StoryScenes.all_lines("lab_study")).contains("held it open"), "the Mentor's Study: he opened the doors at the coup")


func test_the_scene_variants_follow_the_rescue() -> void:
	var boss: DungeonMap.MapNode = MainDungeons.build_map(PathologyLab.DUNGEON_ID).boss()
	var alone: DungeonRun = DungeonRun.enter(Session.profile, Session.deck, [] as Array[ModifierSource])
	var together: DungeonRun = DungeonRun.enter(Session.profile, Session.deck, [PathologyLab.rescuer_boon()] as Array[ModifierSource])
	assert_eq(BossTalks.before_boss(boss, PathologyLab.DUNGEON_ID, together), "lab_siphon")
	assert_eq(BossTalks.before_boss(boss, PathologyLab.DUNGEON_ID, alone), "lab_siphon_alone")
	assert_eq(BossTalks.after_boss(boss, PathologyLab.DUNGEON_ID, alone), "lab_siphon_after_alone", "not rescued: she confronts him after the fight")
	assert_true("\n".join(StoryScenes.all_lines("lab_siphon_after_alone")).contains("Took you long enough"))
	assert_true(StoryScenes.flags_set("lab_siphon_after_alone").has(str(PathologyLab.FLAG_RESCUER_FREED)), "she walks out either way")


func test_elowen_joins_the_boss_fight_only_when_freed() -> void:
	Session.profile.intro_dungeon_cleared = true
	Session.dungeon_key = PathologyLab.DUNGEON_ID
	Session.dungeon_map = MainDungeons.build_map(PathologyLab.DUNGEON_ID)
	Session.mini_active = true
	Session.town_side_active = true
	Session.run = DungeonRun.enter(Session.profile, Session.deck, [PathologyLab.rescuer_boon()] as Array[ModifierSource])
	var context: BattleContext = Session.make_dungeon_battle(Session.dungeon_map.boss())
	assert_true(ProtocolJam.has_ally(context.game, 0), "Elowen (T-24) stands on your field")
	assert_eq(ProtocolJam.available(context.game), ["Augmentation", "Replication", "Extraction", "Containment"] as Array[String])
	Session.run = DungeonRun.enter(Session.profile, Session.deck, [] as Array[ModifierSource])
	var alone: BattleContext = Session.make_dungeon_battle(Session.dungeon_map.boss())
	assert_false(ProtocolJam.has_ally(alone.game, 0))
	Session.mini_active = false
	Session.town_side_active = false


func test_rips_tip_opens_the_forest_station_and_reveals_the_hatch() -> void:
	assert_false(FastTravel.is_unlocked(Session.flags, FastTravel.FOREST))
	assert_false(PathologyLab.is_open(Session.flags))
	Session.set_flag(PathologyLab.FLAG_FOREST_OPEN)
	Session.set_flag(PathologyLab.FLAG_REVEALED)
	assert_true(FastTravel.is_unlocked(Session.flags, FastTravel.FOREST))
	assert_true(FastTravel.can_travel(Session.flags, FastTravel.TOWN, FastTravel.FOREST))
	assert_true(FastTravel.destinations(Session.flags, FastTravel.FOREST).has(FastTravel.TOWN))
	var tip: String = "\n".join(StoryText.shared().get_lines("travel.forest_tip"))
	assert_true(tip.contains("exploring") and tip.contains("interesting things") and tip.contains("rift station"), "Rip's tip")


func test_the_hatch_is_invisible_and_blocked_until_the_lab_is_revealed() -> void:
	var closed: StartingAreaBuilder = StartingAreaBuilder.new()
	var parent: Node3D = Node3D.new()
	add_child_autofree(parent)
	closed.build(parent)
	assert_true(closed.anchors.has("lab"), "the entrance has a place from the start")
	assert_false(closed.is_floor_at(closed.anchors["lab"] as Vector3 + Vector3(0, 0, 0.6)), "the entrance cell is treeline while closed")
	assert_null(parent.find_child("LabHatch", true, false))
	var open: StartingAreaBuilder = StartingAreaBuilder.new()
	open.lab_open = true
	var parent2: Node3D = Node3D.new()
	add_child_autofree(parent2)
	open.build(parent2)
	assert_true(open.is_floor_at(open.anchors["lab"] as Vector3 + Vector3(0, 0, 0.6)), "walkable once open")
	assert_not_null(parent2.find_child("LabHatch", true, false))


func test_clearing_the_lab_rewards_the_lens_gold_and_xp_once_and_a_rescue_sets_a_flag() -> void:
	Session.profile.intro_dungeon_cleared = true
	Session.dungeon_key = PathologyLab.DUNGEON_ID
	Session.dungeon_map = MainDungeons.build_map(PathologyLab.DUNGEON_ID)
	Session.run = DungeonRun.enter(Session.profile, Session.deck, [PathologyLab.rescuer_boon()] as Array[ModifierSource])
	Session.mini_active = true
	Session.town_side_active = true
	var gold_before: int = Session.gold
	var result: Dictionary = Session.resolve_mini_dungeon(true, false)
	assert_true(bool(result.get("first_clear", false)))
	assert_eq(str(result.get("equipment", "")), "Siphon's Lens")
	assert_eq(Session.gold, gold_before + PathologyLab.REWARD_GOLD)
	assert_true(Session.flag(PathologyLab.FLAG_CLEARED))
	assert_true(Session.flag(PathologyLab.FLAG_RESCUER_FREED))
	assert_true(Session.profile.owned_equipment.has(Session.content.equipment_piece("siphons_lens")))
	# A repeat clear pays small gold and no second lens.
	Session.dungeon_key = PathologyLab.DUNGEON_ID
	Session.run = DungeonRun.enter(Session.profile, Session.deck, [] as Array[ModifierSource])
	Session.mini_active = true
	var repeat: Dictionary = Session.resolve_mini_dungeon(true, false)
	assert_false(bool(repeat.get("first_clear", false)))
	assert_false(repeat.has("equipment"))


func test_the_freed_rescuer_has_forest_lines() -> void:
	var story: StoryText = StoryText.shared()
	assert_true(story.texts.has("postgame.rescuer.freed") and story.texts.has("postgame.rescuer.cleared"))
	assert_false("\n".join(story.get_lines("postgame.rescuer.cleared")).contains("name"), "she no longer withholds her name (she gave it in the Lab)")
