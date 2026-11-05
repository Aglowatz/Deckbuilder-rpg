extends GutTest
## Overnight Nov 4-5, Part 3 (docs/balance/early_game_nov5.md): every Path is sent to its own zone first, but the zones are tuned for one order
## (Gainlands, D.N.A., Buffet, Dump). ZoneOrderEase eases a zone's foes by how many places early it is played, and the first zone a little more.


func test_the_ease_follows_the_designed_order() -> void:
	assert_eq(ZoneOrderEase.places_early("beefcake", 0), 0, "the Gainlands are designed first")
	assert_eq(ZoneOrderEase.places_early("refusemancer", 0), 3, "the Dump is designed fourth")
	assert_eq(ZoneOrderEase.places_early("refusemancer", 3), 0, "on time after three zones")
	assert_eq(ZoneOrderEase.places_early("necrocrat", 2), 0, "late is never eased")


func test_the_first_zone_is_eased_most_and_a_freed_zone_never() -> void:
	assert_almost_eq(ZoneOrderEase.hp_factor("beefcake", 0), ZoneOrderEase.FIRST_ZONE_FACTOR, 0.001)
	assert_lt(ZoneOrderEase.hp_factor("refusemancer", 0), ZoneOrderEase.hp_factor("gourmand", 0))
	assert_lt(ZoneOrderEase.hp_factor("gourmand", 0), ZoneOrderEase.hp_factor("necrocrat", 0))
	assert_eq(ZoneOrderEase.hp_factor("refusemancer", 3), 1.0, "played in its place: as designed")
	assert_eq(ZoneOrderEase.hp_factor("refusemancer", 0, true), 1.0, "a freed zone's fights are never eased")
	assert_eq(ZoneOrderEase.hp_factor("final", 0), 1.0, "the Capital keeps its own difficulty")


func test_a_first_zone_main_dungeon_foe_has_less_hp_in_a_real_battle() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.REFUSEMANCER)
	Session.zone_run = ZoneRun.enter("refusemancer", Session.profile, Session.deck)
	Session.dungeon_key = "refusemancer"
	Session.dungeon_map = MainDungeons.build_map("refusemancer")
	Session.run = DungeonRun.enter(Session.profile, Session.deck, Session.zone_run.run.dungeon_sources)
	Session.main_dungeon_active = true
	var boss: DungeonMap.MapNode = Session.dungeon_map.boss()
	var context: BattleContext = Session.make_dungeon_battle(boss)
	var expected: int = maxi(4, roundi(float(boss.enemy_hp) * ZoneOrderEase.hp_factor("refusemancer", 0)))
	assert_eq(context.game.players[1].hp, expected, "the Rotheart met first is eased")
	assert_lt(expected, boss.enemy_hp)
