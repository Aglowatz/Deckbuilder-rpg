extends GutTest
## Part E: the mini dungeon - 3 battles in a row, zone HP rules, a one-time unique card.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.NECROCRAT)
	Session.zone_run = ZoneRun.enter(DnaZone.ID, Session.profile, Session.deck)
	Session.mini_active = false


func after_each() -> void:
	Session.zone_run = null
	Session.run = null
	Session.dungeon_map = null
	Session.mini_active = false


func _enter() -> void:
	Session.dungeon_key = "S-NECRO"
	Session.dungeon_map = MiniDungeon.build_map()
	Session.run = DungeonRun.enter(Session.profile, Session.deck, Session.zone_run.run.dungeon_sources)
	Session.run.hp = Session.zone_run.hp
	Session.mini_active = true


func test_map_is_three_battles_in_a_row_ending_in_a_boss() -> void:
	var map: DungeonMap = MiniDungeon.build_map()
	var battles: int = 0
	for node: DungeonMap.MapNode in map.nodes:
		if node.kind == DungeonMap.Kind.BATTLE or node.kind == DungeonMap.Kind.BOSS:
			battles += 1
			assert_false(MiniDungeon.enemy_recipe(node.enemy_name).is_empty(), node.enemy_name)
			assert_gte(MiniDungeon.enemy_setup(Session.content, node).deck.size(), 24)
		assert_ne(node.kind, DungeonMap.Kind.SHRINE, "nothing heals between meetings")
	assert_eq(battles, MiniDungeon.BATTLE_COUNT)
	assert_eq(map.boss().enemy_name, "Betty Bones, Surly Secretary")
	# A straight line: each node leads to exactly the next.
	var node: DungeonMap.MapNode = map.node(map.current)
	var steps: int = 0
	while not node.next.is_empty():
		assert_eq(node.next.size(), 1)
		node = map.node(node.next[0])
		steps += 1
	assert_eq(steps, 3)


func test_run_starts_at_the_zone_hp_and_battles_use_mini_decks() -> void:
	Session.zone_run.damage(4)
	_enter()
	assert_eq(Session.run.hp, Session.zone_run.max_hp() - 4)
	var node: DungeonMap.MapNode = Session.dungeon_map.available()[0]
	var context: BattleContext = Session.make_dungeon_battle(node)
	assert_eq(context.game.players[0].hp, Session.zone_run.max_hp() - 4, "no heal on entry")
	assert_eq(context.enemy_name, "Receptionist of Number One")


func test_clearing_grants_the_unique_card_exactly_once() -> void:
	_enter()
	var before: int = Session.owned_count(MiniDungeon.REWARD_CARD_ID)
	var first: Dictionary = Session.resolve_mini_dungeon(true)
	assert_true(bool(first.get("first_clear", false)))
	assert_eq(Session.owned_count(MiniDungeon.REWARD_CARD_ID), before + 1)
	assert_true(Session.flag(DnaZone.FLAG_MINI_DUNGEON_CLEARED))
	_enter()
	var second: Dictionary = Session.resolve_mini_dungeon(true)
	assert_false(second.has("first_clear"))
	assert_eq(int(second.get("gold", 0)), DungeonBuilder.SIDE_REWARD_GOLD, "a repeat clear pays gold")
	assert_eq(Session.pack_count("path_necrocrat"), 1, "and a Necrocrat Path Pack")
	assert_eq(Session.owned_count(MiniDungeon.REWARD_CARD_ID), before + 1, "one-time reward")


func test_hp_left_goes_back_to_the_zone() -> void:
	_enter()
	Session.run.hp = 3
	Session.resolve_mini_dungeon(false)
	assert_eq(Session.zone_run.hp, 3)


func test_losing_wakes_at_the_hub_for_a_fee() -> void:
	Session.gold = 50
	_enter()
	Session.run.hp = 0
	var result: Dictionary = Session.resolve_mini_dungeon(false, true)
	assert_true(bool(result.get("woke_at_hub", false)))
	assert_eq(Session.zone_run.hp, Session.zone_run.max_hp())
	assert_eq(Session.gold, 50 - ZoneRun.PAPERWORK_FEE)
	assert_false(Session.mini_active)


func test_the_old_service_tunnels_are_the_secret_way_into_the_capital() -> void:
	Session.zone_run = ZoneRun.enter(CapitalZone.ID, Session.profile, Session.deck)
	Session.dungeon_key = "S-CAP"
	Session.dungeon_map = MainDungeons.build_map("S-CAP")
	Session.run = DungeonRun.enter(Session.profile, Session.deck, Session.zone_run.run.dungeon_sources)
	Session.mini_active = true
	assert_false(Session.flag(CapitalZone.FLAG_INSIDE))
	var result: Dictionary = Session.resolve_mini_dungeon(true)
	assert_true(bool(result.get("secret_way", false)), "clearing the tunnels is the way in")
	assert_true(Session.flag(CapitalZone.FLAG_INSIDE) and Session.flag(CapitalZone.FLAG_HUB_KNOWN) and Session.flag(CapitalZone.FLAG_TUNNEL_FOUND))
	assert_eq(Session.owned_count("C-29"), 1, "and the unique card The Wanderer")
	assert_false(ZoneStoryText.for_zone(CapitalZone.ID).text("fx.old_tunnels_way_in").begins_with("[missing"))


func test_every_side_dungeon_is_sealed_until_its_quest_is_done() -> void:
	for dungeon_id: String in ZoneQuestDefinitions.SIDE_QUESTS.keys():
		assert_false(Session.side_unlocked(dungeon_id), "%s starts sealed" % dungeon_id)
		var quest: QuestData = QuestCatalog.find(str(ZoneQuestDefinitions.SIDE_QUESTS[dungeon_id]))
		assert_not_null(quest, "%s has its quest" % dungeon_id)
		if quest == null:
			continue
		assert_eq(quest.reward_unlock_flags, [str(DungeonCatalog.side_unlock_flag(dungeon_id))] as Array[String], "finishing it unlocks the dungeon")
		assert_false(quest.giver_npc.is_empty())
		assert_false(DungeonCatalog.text_lines("quest.%s.offer" % quest.id).is_empty(), "%s has offer dialogue" % quest.id)
		assert_false(DungeonCatalog.text_lines("quest.%s.ready" % quest.id).is_empty())
		assert_false(DungeonCatalog.text_lines("quest.%s.done" % quest.id).is_empty())
	var givers: Dictionary = {"S-BEEF": "Old Man Mountain", "S-GOUR": "Basil", "S-NECRO": "Gerald", "S-REF": "Brother Bramble", "S-CAP": "Kestrel", "S-TOWN": "Elder Maren"}
	for dungeon_id: String in givers.keys():
		assert_eq(QuestCatalog.find(str(ZoneQuestDefinitions.SIDE_QUESTS[dungeon_id])).giver_npc, str(givers[dungeon_id]), dungeon_id)
