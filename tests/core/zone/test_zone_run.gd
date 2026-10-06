extends GutTest
## Part C/D: zone HP rules and the enemy definitions.

var run: ZoneRun


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.NECROCRAT)
	run = ZoneRun.enter(DnaZone.ID, Session.profile, Session.deck)


func test_entering_starts_at_full_hp() -> void:
	assert_eq(run.hp, run.max_hp())


func test_damage_and_heal_persist_and_clamp() -> void:
	run.damage(3)
	assert_eq(run.hp, run.max_hp() - 3)
	assert_eq(run.heal(1), 1)
	assert_eq(run.heal(99), 2, "only the missing HP is restored")
	assert_eq(run.hp, run.max_hp())


func test_no_healing_after_battle_hp_carries_over() -> void:
	var game: GameState = Session.make_zone_battle(DnaEnemies.INTERN, "intern_0").game
	assert_eq(game.players[0].hp, run_hp_at_battle_start())
	game.players[0].hp = 3
	run.finish_battle(game)
	assert_eq(run.hp, 3, "HP after a battle is what is left, not refilled")


func run_hp_at_battle_start() -> int:
	return Session.zone_run.hp if Session.zone_run != null else run.max_hp()


func test_zone_battle_starts_at_the_persisted_hp() -> void:
	Session.zone_run = run
	run.damage(4)
	var context: BattleContext = Session.make_zone_battle(DnaEnemies.MANAGER, "manager_0")
	assert_eq(context.game.players[0].hp, run.max_hp() - 4)
	assert_true(context.zone_battle)
	Session.zone_run = null


func test_zero_hp_wakes_at_hub_with_paperwork_fee_and_is_logged() -> void:
	Session.zone_run = run
	Session.gold = 100
	run.damage(999)
	assert_true(run.is_down())
	var fee: int = Session.zone_wake_at_hub("test faint")
	assert_eq(fee, ZoneRun.PAPERWORK_FEE)
	assert_eq(Session.gold, 100 - ZoneRun.PAPERWORK_FEE)
	assert_eq(run.hp, run.max_hp(), "full HP after waking")
	assert_true(Session.zone_log[Session.zone_log.size() - 1].contains("test faint"))
	Session.zone_run = null


func test_fee_never_exceeds_gold() -> void:
	Session.zone_run = run
	Session.gold = 4
	assert_eq(Session.zone_wake_at_hub("broke"), 4)
	assert_eq(Session.gold, 0)
	Session.zone_run = null


func test_defeated_enemies_stay_gone_for_the_visit_only() -> void:
	run.mark_defeated("manager_0")
	assert_true(run.is_defeated("manager_0"))
	var fresh: ZoneRun = ZoneRun.enter(DnaZone.ID, Session.profile, Session.deck)
	assert_false(fresh.is_defeated("manager_0"), "re-entering the zone brings them back")


func test_slow_enemies_are_slower_than_the_player_and_courier_is_faster() -> void:
	assert_true(DnaEnemies.is_slow(DnaEnemies.MANAGER))
	assert_true(DnaEnemies.is_slow(DnaEnemies.INTERN))
	assert_false(DnaEnemies.is_slow(DnaEnemies.COURIER))
	assert_gt(DnaEnemies.info(DnaEnemies.COURIER).chase_speed, TownPlayer.SPEED)
	assert_lt(DnaEnemies.info(DnaEnemies.MANAGER).chase_speed, TownPlayer.SPEED)
	assert_eq(DnaEnemies.COURIER_DAMAGE, 2)
	assert_eq(DnaEnemies.info(DnaEnemies.COURIER).kind, ZoneEnemyInfo.Kind.DAMAGE)


func test_enemy_decks_are_legal_necrocrat_decks() -> void:
	for id: String in [DnaEnemies.MANAGER, DnaEnemies.INTERN]:
		var deck: Deck = DnaEnemies.deck(Session.content, id)
		assert_gte(deck.size(), 24, id)
		for card: CardData in deck.cards:
			assert_true(card.is_infrastructure() or card.color == Affinity.Type.NECROCRAT, "%s: %s is Necrocrat" % [id, card.id])


func test_zone_cards_exist_and_stay_out_of_normal_pools() -> void:
	assert_eq(ZoneCards.VENDOR_IDS.size(), 9)
	for id: String in ZoneCards.VENDOR_IDS:
		assert_not_null(Session.content.card(id), id)
		assert_false(Session.content.cards.has(id), "%s is zone-exclusive" % id)
	assert_not_null(Session.content.card(ZoneCards.MINI_DUNGEON_REWARD_ID))
	assert_not_null(Session.content.equipment_piece("courier_lanyard"))


func test_time_clock_buff_raises_max_hp_once() -> void:
	var before: int = run.max_hp()
	run.add_buff(DnaInteractables.punch_in_buff())
	assert_eq(run.max_hp(), before + DnaInteractables.PUNCH_IN_BONUS)
	assert_eq(run.hp, before + DnaInteractables.PUNCH_IN_BONUS)


func test_coffee_and_printer_outcomes() -> void:
	assert_eq(DnaInteractables.coffee_outcome(0.1), "good")
	assert_eq(DnaInteractables.coffee_outcome(0.4), "great")
	assert_eq(DnaInteractables.coffee_outcome(0.5), "bad")
	assert_eq(DnaInteractables.coffee_outcome(0.7), "gold")
	assert_eq(DnaInteractables.coffee_outcome(0.95), "empty")
	assert_null(DnaInteractables.print_card(0.1, 3), "jam")
	assert_not_null(DnaInteractables.print_card(0.5, 3))
