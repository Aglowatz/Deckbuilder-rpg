extends GutTest
## Story v2 Part H: Rip's forest portal, the hidden hatch and the postgame Path-ology Lab.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	DungeonCatalog.reset()
	MainDungeons.reset()


func test_the_lab_is_a_14_node_postgame_dungeon_with_branching_and_the_story_nodes() -> void:
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.find(PathologyLab.DUNGEON_ID)
	assert_not_null(plan)
	assert_true(plan.is_postgame())
	assert_eq(plan.nodes.size(), 14)
	assert_eq(plan.map_id, "MAP-LAB")
	assert_eq(plan.battleboard_id, "BB-LAB")
	var branching: int = 0
	var names: Array[String] = []
	for node: DungeonCatalog.BlueprintNode in plan.nodes:
		names.append(node.node_name)
		if node.next.size() > 1:
			branching += 1
	assert_true(branching >= 3, "the map branches")
	for expected: String in ["The Prince's Old Cell", "The Draining Chamber", "The Rescuer's Cell"]:
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


func test_the_story_nodes_have_their_text_and_speakers() -> void:
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.find(PathologyLab.DUNGEON_ID)
	var map: DungeonMap = MainDungeons.build_map(PathologyLab.DUNGEON_ID)
	var story: ZoneStoryText = ZoneStoryText.for_zone(plan.zone_id)
	var cell_text: String = ""
	for key: String in ["event.dg_d_lab_7.body", "event.dg_d_lab_7.choice.0", "event.dg_d_lab_7.result.0"]:
		cell_text += "\n".join(story.get_lines(key))
	assert_true(cell_text.contains("tally marks"), "ten years of tally marks")
	assert_true(cell_text.contains("four colors"), "the child's drawing of four colors")
	assert_true("\n".join(story.get_lines("dungeon.dg_lab_drain.before")).contains("This is where it was done"))
	assert_eq(NpcRegistry.story_speaker("dungeon.dg_lab_boss.before"), "NPC-SIPHON")
	assert_eq(NpcRegistry.story_speaker("dungeon.dg_lab_rescue.after"), "NPC-RESCUER")
	assert_false(map.boss().story_before.is_empty())


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


func test_the_freed_rescuer_has_hood_down_lines() -> void:
	var story: StoryText = StoryText.shared()
	assert_true("\n".join(story.get_lines("postgame.rescuer.freed")).contains("[revealed]"), "hood down: the revealed portrait expression is tagged")
	assert_true(story.texts.has("postgame.rescuer.freed") and story.texts.has("postgame.rescuer.cleared"))
