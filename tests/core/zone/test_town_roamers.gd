extends GutTest
## Playtest v0.4.0 Part D: three easy respawning enemies roam the outskirts of Crosspath. Their decks are real, their fights pay a little
## gold and XP, every win counts for the armory quest, a beaten one stays down for a while, and the balance sim lists them.

var content: ContentSet


func before_all() -> void:
	content = ContentLibrary.load_all()


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.GOURMAND)


func test_three_roamers_with_real_decks_and_small_rewards() -> void:
	assert_eq(TownEnemies.IDS.size(), 3)
	assert_eq(TownEnemies.SPAWNS.size(), 3)
	for id: String in TownEnemies.IDS:
		var info: ZoneEnemyInfo = TownEnemies.info(id)
		assert_eq(info.kind, ZoneEnemyInfo.Kind.BATTLE, "%s starts a battle" % id)
		assert_between(info.hp, 3, 9, "%s is an easy fight" % id)  # Oct 22: 3-4 HP for the neutral-heavy starting decks
		assert_between(info.gold_reward, 8, 20, "%s pays small gold" % id)
		assert_between(info.xp_reward, 20, 40, "%s pays small XP" % id)
		var deck: Deck = TownEnemies.deck(content, id)
		assert_gte(deck.size(), 18, "%s has a thin but real deck" % id)
		assert_not_null(TownEnemies.personality(content, id))
		var setup: PlayerSetup = TownEnemies.enemy_setup(content, id)
		assert_eq(setup.starting_hp, info.hp)


func test_spawns_sit_on_the_outskirts_never_the_square() -> void:
	for spawn: Dictionary in TownEnemies.SPAWNS:
		var home: Vector3 = spawn["home"] as Vector3
		assert_gt(Vector2(home.x - TownLayout.PLAZA.x, home.z - TownLayout.PLAZA.z).length(), 25.0, "%s lives far from the square" % str(spawn["id"]))
		assert_gt(Vector2(home.x - TownLayout.SPAWN.x, home.z - TownLayout.SPAWN.z).length(), 25.0, "%s lives far from the spawn" % str(spawn["id"]))
		assert_true(TownBounds.contains(home), "%s is inside the hub" % str(spawn["id"]))


func test_a_fight_pays_counts_for_the_armory_quest_and_puts_the_roamer_down_for_a_while() -> void:
	var context: BattleContext = Session.make_town_battle(TownEnemies.HOUND, "town_hound")
	assert_eq(context.town_roamer_id, "town_hound")
	assert_eq(context.town_roamer_type, TownEnemies.HOUND)
	assert_eq(context.enemy_name, "Pantry Hound")
	assert_eq(context.game.players[1].hp, TownEnemies.info(TownEnemies.HOUND).hp)
	assert_eq(context.game.players[0].hp, Session.profile.max_hp, "the town fight starts at full HP")
	assert_false(Session.town_roamer_is_down("town_hound"))
	var gold: int = Session.gold
	var xp: int = Session.profile.xp
	context.won = true
	var result: Dictionary = Session.resolve_town_battle(context)
	assert_true(bool(result["won"]))
	assert_gte(Session.gold, gold + context.gold_reward, "the gold is paid (a quest finishing on the win may add more)")
	assert_gte(Session.profile.xp, xp + context.xp_reward, "the XP is paid (a quest finishing on the win may add more)")
	assert_eq(Session.counter("duels_won"), 1, "an outskirts win is a won fight for the armory quest")
	assert_eq(Session.counter("town_roamers_defeated"), 1)
	assert_true(Session.town_roamer_is_down("town_hound"), "the hound is away for a while")
	assert_false(Session.town_roamer_is_down("town_clerk"), "the others are still out")
	assert_eq(Session.pending_town_result.get("kind"), "roamer")
	# An old beating is forgotten: the respawn clock is in the counters, so a save from before this build never has one.
	Session.counters["town_roamer_beaten:town_hound"] = int(Time.get_unix_time_from_system()) - TownEnemies.RESPAWN_SECONDS - 1
	assert_false(Session.town_roamer_is_down("town_hound"), "it respawns after the timer")


func test_a_loss_costs_nothing() -> void:
	var context: BattleContext = Session.make_town_battle(TownEnemies.CLERK, "town_clerk")
	var gold: int = Session.gold
	context.won = false
	Session.resolve_town_battle(context)
	assert_eq(Session.gold, gold)
	assert_eq(Session.counter("duels_won"), 0)
	assert_false(Session.town_roamer_is_down("town_clerk"), "the clerk is still there to try again")


func test_the_balance_sim_lists_the_roamers_at_level_one() -> void:
	var found: int = 0
	for spec: EncounterSpec in EncounterCatalog.town(content):
		if spec.group == "town:roamer":
			found += 1
			assert_eq(spec.expected_level, 1)
			assert_eq(spec.kind, EncounterSpec.Kind.NORMAL)
			assert_false(spec.enemy_recipe.is_empty())
	assert_eq(found, 3)


func test_the_outskirts_map_keeps_roamers_off_the_square_and_the_passages() -> void:
	var builder: TownBuilder = TownBuilder.new()
	builder.hub_land = true
	var map: TownEnemyMap = TownEnemyMap.wrap(builder)
	assert_false(map.is_enemy_walkable(TownLayout.PLAZA, 0.25), "never on the square")
	assert_false(map.is_enemy_walkable(TownLayout.SPAWN + Vector3(1, 0, 0), 0.25), "never at the spawn")
	assert_eq(map.enemy_spawns().size(), 3)
