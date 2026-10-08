extends GutTest
## The dungeon list (data/source/dungeon_list.csv -> data/dungeons/dungeons.json): every dungeon, its nodes, links, types, bosses and rewards exist in the
## game as the CSV says, every map is sound and every node has what it needs to be played.

const NODE_COUNTS: Dictionary = {
	"D-TUT": 6, "D-HOG": 13, "D-TTK": 13, "D-HFA": 14, "D-ROT": 13, "D-PC": 22,
	"S-BEEF": 3, "S-GOUR": 3, "S-NECRO": 3, "S-REF": 3, "S-CAP": 3, "S-TOWN": 3, "D-LAB": 14,
}
const REWARD_CARDS: Dictionary = {
	"D-HOG": "B-32", "D-TTK": "G-33", "D-HFA": "N-33", "D-ROT": "R-33", "D-PC": "P4-02",
	"S-BEEF": "B-30", "S-GOUR": "G-27", "S-NECRO": "N-30", "S-REF": "R-27", "S-CAP": "C-29", "S-TOWN": "C-21",
}


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	DungeonCatalog.reset()
	MainDungeons.reset()


func _map_of(blueprint: DungeonCatalog.Blueprint) -> DungeonMap:
	if blueprint.id == DungeonCatalog.TUTORIAL_ID:
		return TrialOfTheHollow.build_map()
	return MainDungeons.build_map(blueprint.id if (blueprint.is_side() or blueprint.is_postgame()) else blueprint.zone_id)


func test_every_dungeon_of_the_list_is_there() -> void:
	assert_eq(DungeonCatalog.all().size(), 13, "the 12 dungeons of the sheet plus the hand-made postgame Path-ology Lab")
	for id: String in NODE_COUNTS.keys():
		var blueprint: DungeonCatalog.Blueprint = DungeonCatalog.find(id)
		assert_not_null(blueprint, id)
		assert_eq(blueprint.nodes.size(), int(NODE_COUNTS[id]), "%s node count" % id)
		assert_false(blueprint.dungeon_name.is_empty())
		assert_false(blueprint.map_id.is_empty(), "%s has a Map Image ID" % id)
		assert_eq(blueprint.map_id, "MAP-" + id.trim_prefix("D-"), id)
	assert_eq(MainDungeons.side_ids().size(), 6)
	for side: String in ["S-BEEF", "S-GOUR", "S-NECRO", "S-REF", "S-CAP", "S-TOWN"]:
		assert_true(MainDungeons.is_side(side), side)
		assert_true(MainDungeons.has_def(side), side)


func test_names_and_zones() -> void:
	assert_eq(DungeonCatalog.find("D-HOG").dungeon_name, "The House of Gains")
	assert_eq(DungeonCatalog.find("S-TOWN").dungeon_name, "The Forgotten Vault")
	assert_eq(DungeonCatalog.find("D-PC").dungeon_name, "Primm's Castle")
	assert_eq(DungeonCatalog.main_for_zone("beefcake").id, "D-HOG")
	assert_eq(DungeonCatalog.main_for_zone("final").id, "D-PC")
	assert_eq(DungeonCatalog.side_for_zone("necrocrat").id, "S-NECRO")
	assert_eq(DungeonCatalog.side_for_zone("final").id, "S-CAP")
	assert_eq(DungeonCatalog.side_for_zone("town").id, "S-TOWN")
	assert_null(DungeonCatalog.main_for_zone("town"))


func test_every_map_is_sound_and_has_the_csv_nodes() -> void:
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		var map: DungeonMap = _map_of(blueprint)
		assert_eq(map.problems(), [] as Array[String], "%s map is structurally sound" % blueprint.id)
		var visible_nodes: int = 0
		for node: DungeonMap.MapNode in map.nodes:
			if not node.hidden:
				visible_nodes += 1
		assert_eq(visible_nodes, blueprint.nodes.size(), "%s has every node of the CSV on the map" % blueprint.id)
		assert_eq(map.dungeon_name, blueprint.dungeon_name)
		for node: DungeonMap.MapNode in map.nodes:
			assert_between(node.position.x, 0.0, 1.0, "%s node %d x" % [blueprint.id, node.id])
			assert_between(node.position.y, 0.0, 1.0, "%s node %d y" % [blueprint.id, node.id])


func test_node_types_names_and_links_follow_the_csv() -> void:
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		if blueprint.id == DungeonCatalog.TUTORIAL_ID:
			continue
		var map: DungeonMap = _map_of(blueprint)
		for plan: DungeonCatalog.BlueprintNode in blueprint.nodes:
			var node: DungeonMap.MapNode = _node_by_number(map, plan.number)
			assert_not_null(node, "%s node %d" % [blueprint.id, plan.number])
			assert_eq(node.title, plan.node_name)
			assert_eq(node.kind, DungeonBuilder.kind_of(plan.type), "%s node %d kind" % [blueprint.id, plan.number])
			for target: int in plan.next:
				assert_true(node.next.has(_node_by_number(map, target).id), "%s: %d links to %d" % [blueprint.id, plan.number, target])
			assert_eq(node.next.size(), plan.next.size(), "%s: node %d has exactly the CSV links" % [blueprint.id, plan.number])


func _node_by_number(map: DungeonMap, number: int) -> DungeonMap.MapNode:
	for node: DungeonMap.MapNode in map.nodes:
		if node.number == number:
			return node
	return null


func test_house_of_gains_prison_branch_and_rescue() -> void:
	var map: DungeonMap = MainDungeons.build_map("beefcake")
	var stairs: DungeonMap.MapNode = _node_by_number(map, 7)
	assert_eq(stairs.next.size(), 2, "the stairs split: the prison, or straight up to the garden")
	assert_true(stairs.next.has(_node_by_number(map, 8).id))
	assert_true(stairs.next.has(_node_by_number(map, 10).id))
	var cell: DungeonMap.MapNode = _node_by_number(map, 9)
	assert_eq(cell.kind, DungeonMap.Kind.RESCUE)
	assert_eq(cell.scene, "rescue")
	assert_eq(_node_by_number(map, 10).kind, DungeonMap.Kind.SHRINE)
	assert_eq(_node_by_number(map, 13).kind, DungeonMap.Kind.BOSS)
	assert_eq(_node_by_number(map, 13).enemy_name, "Chancellor Clench, Iron Regent")
	# Skipping the prison skips the rescue: the shortcut route never enters node 9.
	map.complete(map.available()[0].id)
	var steps: int = 0
	while not map.is_complete() and steps < 30:
		var options: Array[DungeonMap.MapNode] = map.available()
		var pick: DungeonMap.MapNode = options[0]
		for option: DungeonMap.MapNode in options:
			if option.number == 10:
				pick = option
		map.complete(pick.id)
		steps += 1
	assert_false(map.is_cleared(cell.id), "the rescue was skipped along with the prison")


func test_primms_castle_dead_end_branches_return_to_their_branch_point() -> void:
	var map: DungeonMap = MainDungeons.build_map("final")
	assert_eq(map.nodes.size(), 22)
	var returns: Dictionary = {11: 2, 12: 4, 13: 4, 14: 6, 15: 6, 16: 5, 17: 5, 18: 7, 19: 8, 21: 9, 22: 3}
	for number: int in returns.keys():
		var node: DungeonMap.MapNode = _node_by_number(map, number)
		assert_eq(node.return_to, _node_by_number(map, int(returns[number])).id, "node %d returns to node %d" % [number, int(returns[number])])
	# Node 20 continues to 21 before returning; it does not return by itself.
	var balcony: DungeonMap.MapNode = _node_by_number(map, 20)
	assert_eq(balcony.return_to, -1)
	assert_eq(balcony.next, [_node_by_number(map, 21).id] as Array[int])
	assert_eq(_node_by_number(map, 10).kind, DungeonMap.Kind.BOSS)


func test_walking_a_dead_end_returns_to_the_branch_point() -> void:
	var map: DungeonMap = MainDungeons.build_map("final")
	for number: int in [1, 2]:
		map.complete(_node_by_number(map, number).id)
	assert_true(map.is_available(_node_by_number(map, 11).id))
	map.complete(_node_by_number(map, 11).id)
	assert_eq(map.current, _node_by_number(map, 2).id, "the gilded pantry is a dead end: the party is back at the courtyard")
	assert_true(map.is_available(_node_by_number(map, 3).id), "the main road is still open")


func test_side_dungeons_start_on_their_first_battle_with_a_hidden_entrance() -> void:
	for side: String in MainDungeons.side_ids():
		var map: DungeonMap = MainDungeons.build_map(side)
		assert_true(map.node(0).hidden, "%s: the entrance node has no icon" % side)
		assert_eq(map.node(0).kind, DungeonMap.Kind.START)
		assert_eq(map.available().size(), 1)
		assert_eq(map.available()[0].kind, DungeonMap.Kind.BATTLE)
		assert_eq(map.boss().number, 3)


func test_bosses_use_the_names_of_the_boss_column() -> void:
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		if blueprint.id == DungeonCatalog.TUTORIAL_ID:
			continue
		var boss: DungeonMap.MapNode = _map_of(blueprint).boss()
		if blueprint.id == "D-PC":
			assert_eq(boss.enemy_name, PrimmBoss.BOSS_FOE)
		elif blueprint.id == "S-CAP":
			assert_eq(boss.enemy_name, "Enforcer Captain Spotless")
		else:
			assert_eq(boss.enemy_name, blueprint.boss_name(), blueprint.id)
	assert_eq(DungeonCatalog.find("D-TTK").boss_name(), "The Doppelganger")


func test_every_battle_has_a_real_enemy_deck() -> void:
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		if blueprint.id == DungeonCatalog.TUTORIAL_ID:
			continue
		var key: String = blueprint.id if (blueprint.is_side() or blueprint.is_postgame()) else blueprint.zone_id
		var map: DungeonMap = MainDungeons.build_map(key)
		for node: DungeonMap.MapNode in map.nodes:
			if not DungeonMap.is_battle_kind(node.kind):
				continue
			var setup: PlayerSetup = MainDungeons.enemy_setup(Session.content, node, key)
			assert_gte(setup.deck.size(), 24, "%s: %s has a deck" % [blueprint.id, node.enemy_name])
			assert_gt(setup.starting_hp, 0)


func test_every_event_challenge_and_treasure_node_can_be_played() -> void:
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		if blueprint.id == DungeonCatalog.TUTORIAL_ID:
			continue
		var key: String = blueprint.id if (blueprint.is_side() or blueprint.is_postgame()) else blueprint.zone_id
		var def: MainDungeonDef = MainDungeons.def(key)
		var story: ZoneStoryText = ZoneStoryText.for_zone(blueprint.zone_id)
		for node: DungeonMap.MapNode in MainDungeons.build_map(key).nodes:
			var where: String = "%s node %d (%s)" % [blueprint.id, node.number, node.title]
			match node.kind:
				DungeonMap.Kind.EVENT, DungeonMap.Kind.RESCUE:
					var event: DungeonEvent = def.event(node.event_id)
					assert_not_null(event, where)
					if event != null:
						assert_gte(event.choices.size(), 1, where)
						assert_false(story.text(event.title_key()).begins_with("[missing"), "%s title text" % where)
						assert_false(story.text(event.body_key()).begins_with("[missing"), "%s body text" % where)
						for index: int in range(event.choices.size()):
							assert_false(story.text(event.choice_key(index)).begins_with("[missing"), "%s choice %d text" % [where, index])
							assert_false(story.text(event.result_key(index)).begins_with("[missing"), "%s result %d text" % [where, index])
				DungeonMap.Kind.CHALLENGE:
					var challenge: ChallengeData = def.challenge(node.challenge_id)
					assert_not_null(challenge, where)
					if challenge != null:
						assert_false(challenge.display_name.begins_with("[missing"), "%s challenge title" % where)
						assert_gte(challenge.on_success.size() + challenge.on_failure.size(), 1, where)
				DungeonMap.Kind.TREASURE:
					assert_false(node.treasure.is_empty(), where)
				DungeonMap.Kind.SHRINE:
					assert_gt(node.heal_amount, 0, where)


func test_story_beats_and_boss_speakers_exist() -> void:
	var map: DungeonMap = MainDungeons.build_map("beefcake")
	var boss: DungeonMap.MapNode = map.boss()
	assert_eq(NpcRegistry.story_speaker(boss.story_before), "NPC-CLENCH")
	assert_eq(NpcRegistry.story_speaker(_node_by_number(map, 9).story_after), "NPC-FLEX")
	for side: Array in [["S-BEEF", "NPC-SPOTTER"], ["S-GOUR", "NPC-ITAMAE"], ["S-NECRO", "NPC-BETTY"], ["S-REF", "NPC-RACCOONKING"], ["S-CAP", "NPC-SPOTLESS"], ["S-TOWN", "NPC-AUTOMATON"]]:
		var side_boss: DungeonMap.MapNode = MainDungeons.build_map(str(side[0])).boss()
		assert_false(side_boss.story_before.is_empty(), "%s boss has a pre-fight line" % side[0])
		assert_false(side_boss.story_after.is_empty(), "%s boss has a post-fight line" % side[0])
		assert_eq(NpcRegistry.story_speaker(side_boss.story_before), str(side[1]))


func test_rewards_are_unique_cards_that_stay_out_of_packs() -> void:
	for id: String in REWARD_CARDS.keys():
		var blueprint: DungeonCatalog.Blueprint = DungeonCatalog.find(id)
		assert_eq(blueprint.reward_card_id(), str(REWARD_CARDS[id]), id)
		var card: CardData = Session.content.card(str(REWARD_CARDS[id]))
		assert_not_null(card, "%s reward card exists" % id)
		assert_true(card.not_in_packs, "%s is not in packs" % str(REWARD_CARDS[id]))
	assert_eq(DungeonCatalog.find("D-TUT").reward_card_id(), "")
	assert_eq(DungeonCatalog.find("S-BEEF").repeat_pack_id(), "path_beefcake")
	assert_eq(DungeonCatalog.find("S-CAP").repeat_pack_id(), "general_1")
	assert_eq(DungeonCatalog.find("D-HFA").repeat_pack_id(), "path_necrocrat")
	assert_eq(DungeonCatalog.find("D-PC").repeat_pack_id(), "prismatic")


func test_battleboards_of_the_list_exist_and_battles_use_them() -> void:
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		assert_true(Battleboards.has_image(blueprint.battleboard_id), "%s -> %s has an image" % [blueprint.id, blueprint.battleboard_id])
	Session.zone_run = ZoneRun.enter("beefcake", Session.profile, Session.deck)
	Session.dungeon_key = "beefcake"
	Session.dungeon_map = MainDungeons.build_map("beefcake")
	Session.run = DungeonRun.enter(Session.profile, Session.deck, Session.zone_run.run.dungeon_sources)
	Session.main_dungeon_active = true
	var context: BattleContext = Session.make_dungeon_battle(Session.dungeon_map.available()[0])
	assert_eq(context.board_key, "BB-HOG")
	Session.main_dungeon_active = false
	Session.dungeon_key = "S-BEEF"
	Session.dungeon_map = MainDungeons.build_map("S-BEEF")
	Session.mini_active = true
	context = Session.make_dungeon_battle(Session.dungeon_map.available()[0])
	assert_eq(context.board_key, "BB-S-BEEF")
	Session.mini_active = false
	Session.dungeon_map = null
	Session.run = null
	Session.zone_run = null


func test_quest_hooks_name_the_npcs() -> void:
	assert_eq(DungeonCatalog.hooks_for_npc("NPC-MOUNTAIN").size(), 1)
	assert_eq(DungeonCatalog.hooks_for_npc("NPC-MOUNTAIN")[0]["dungeon"], "D-HOG")
	assert_eq(DungeonCatalog.hooks_for_npc("NPC-WREN")[0]["dungeon"], "D-PC")
	assert_eq(DungeonCatalog.hooks_for_npc("NPC-ELDER").size(), 0)
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		assert_false(blueprint.hook.is_empty(), "%s has a quest hook" % blueprint.id)
