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
	assert_eq(map.boss().enemy_name, "The Quarterly Reviewer")
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
	assert_eq(context.enemy_name, "Kickoff Facilitator")


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
