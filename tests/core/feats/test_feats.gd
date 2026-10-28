extends GutTest
## Overnight Oct 27-28, Part 3: the feats - the definitions, the state round trip, retroactive state feats, the live-battle watcher's
## moments, the account record paying once, the hidden "???" rows and the session wiring (a freed zone earns its feat and the save keeps it).

const ACCOUNT_PATH: String = "user://test_feats_account.json"
var _account_path: String


func before_each() -> void:
	_account_path = FeatAccount.path
	FeatAccount.path = ACCOUNT_PATH
	FeatAccount.reset()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(ACCOUNT_PATH))
	Session.save_enabled = false
	Session.pay_feat_rewards = true
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func after_each() -> void:
	Session.pay_feat_rewards = false
	Session.new_game()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(ACCOUNT_PATH))
	FeatAccount.path = _account_path
	FeatAccount.reset()


func test_definitions_load_with_unique_ids_and_known_triggers() -> void:
	var defs: Array[FeatDefs.Def] = FeatDefs.all()
	assert_eq(defs.size(), 40, "forty feats")
	var ids: Dictionary = {}
	var hidden: int = 0
	for def: FeatDefs.Def in defs:
		assert_false(ids.has(def.id), "%s is unique" % def.id)
		ids[def.id] = true
		assert_true(FeatDefs.KINDS.has(def.kind()), "%s: trigger kind %s" % [def.id, def.kind()])
		assert_true(FeatDefs.GROUP_ORDER.has(def.group), "%s: group %s" % [def.id, def.group])
		assert_false(def.name.is_empty() or def.earned_by.is_empty(), def.id)
		assert_true(def.reward_gold > 0 or def.reward_essence > 0, "%s pays something" % def.id)
		if def.hidden:
			hidden += 1
	assert_true(hidden >= 8, "a handful of hidden ones (%d)" % hidden)
	assert_eq(FeatDefs.find("hold_my_coat").group, "Zones")


func test_state_round_trips() -> void:
	var state: FeatState = FeatState.new()
	assert_true(state.unlock("overhead", 1000))
	assert_false(state.unlock("overhead"), "earned once per campaign")
	var copy: FeatState = FeatState.new()
	copy.from_dict(state.to_dict())
	assert_true(copy.has("overhead"))
	assert_eq(int(copy.unlocked["overhead"]), 1000)


func test_state_feats_are_retroactive_and_fire_once() -> void:
	var tracker: FeatTracker = FeatTracker.new()
	var snapshot: Dictionary = {"flags": {"zone_beefcake_completed": true, "zone_gourmand_completed": true, "zone_necrocrat_completed": true, "zone_refusemancer_completed": true, "trial_cleared": true},
		"zones": 4, "counters": {"packs_opened": 12}, "collection": 30, "cleared_dungeons": ["The Iron Cave"], "quests": ["meet_the_merchants"], "level": 9, "arena_cleared": 2}
	var earned: Array[String] = tracker.evaluate(snapshot)
	for id: String in ["hold_my_coat", "chef_always_tastes", "take_a_number_mortimer", "the_twelfth_tree", "four_paths_one_kingdom", "old_stone_cold_nights", "fresh_foil", "shelf_esteem", "never_skip_leg_day", "right_up_to_my_door", "leaves_in_your_hair"]:
		assert_true(earned.has(id), id)
	assert_false(earned.has("foil"), "30% is not half")
	assert_false(earned.has("gold_sand"), "two arena clears are not eight")
	assert_false(earned.has("overhead"), "a moment feat never comes from a snapshot")
	assert_true(tracker.evaluate(snapshot).is_empty(), "nothing fires twice")


func test_battle_feats_read_the_facts_and_the_moments() -> void:
	var tracker: FeatTracker = FeatTracker.new()
	var game: GameState = GameFactory.blank_game(7)
	tracker.watch(game)
	var big: CardInstance = GameFactory.add_to_field(game, 0, GameFactory.vanilla(10, 4, 1, Affinity.Type.BEEFCAKE))
	assert_not_null(big)
	game.emit_event(GameEvent.Type.STATS_CHANGED, 0, big.uid)
	for i: int in range(4):
		game.emit_event(GameEvent.Type.GARBAGE_EATEN, 0)
	game.emit_event(GameEvent.Type.TURN_STARTED, 1)
	game.emit_event(GameEvent.Type.GARBAGE_EATEN, 0)
	var moments: Dictionary = tracker.watcher.moments()
	assert_eq(int(moments["max_attack"]), 10)
	assert_eq(int(moments["max_garbage_turn"]), 4, "the turn's count resets at the next turn")
	var earned: Array[String] = tracker.on_battle({"boss": true, "flawless": true, "hp_left": 1, "deck_paths": 2})
	for id: String in ["overhead", "nothing_is_wasted", "flawless", "by_a_thread", "mixed_signals"]:
		assert_true(earned.has(id), id)
	assert_false(earned.has("the_paths_unbound"), "two Paths are not three")
	assert_false(earned.has("three_golems"))
	assert_true(tracker.on_battle({"boss": true, "flawless": true, "hp_left": 1, "deck_paths": 2}).is_empty(), "the watcher is detached and the feats are earned")


func test_destroyed_by_one_card_counts_enemy_deaths_after_the_players_card() -> void:
	var tracker: FeatTracker = FeatTracker.new()
	var game: GameState = GameFactory.blank_game(8)
	tracker.watch(game)
	game.emit_event(GameEvent.Type.CARD_PLAYED, 0, 1)
	for i: int in range(4):
		game.emit_event(GameEvent.Type.UNIT_DIED, 1, 10 + i)
	game.emit_event(GameEvent.Type.UNIT_DIED, 0, 20)
	assert_eq(int(tracker.watcher.moments()["max_destroyed_by_card"]), 4, "own losses do not count")
	game.emit_event(GameEvent.Type.CARD_PLAYED, 1, 2)
	game.emit_event(GameEvent.Type.UNIT_DIED, 1, 30)
	assert_eq(int(tracker.watcher.moments()["max_destroyed_by_card"]), 4, "the opponent's card does not count")
	tracker.watcher.detach()


func test_account_record_pays_once_and_persists() -> void:
	assert_true(FeatAccount.record("overhead", true), "first time")
	assert_false(FeatAccount.record("overhead", true), "never again on this account")
	assert_true(FileAccess.file_exists(ACCOUNT_PATH), "written when saving is on")
	FeatAccount.reset()
	assert_true(FeatAccount.has("overhead"), "read back from disk")
	assert_true(FeatAccount.unlocked_ids().has("overhead"), "listed (the setup game earned a few too)")


func test_hidden_rows_read_as_question_marks_until_earned() -> void:
	var def: FeatDefs.Def = FeatDefs.find("a_name")
	assert_true(def.hidden)
	assert_eq(FeatsPanel.row_texts(def)[0], "???")
	FeatAccount.record("a_name", false)
	assert_eq(FeatsPanel.row_texts(def)[0], "A Name")
	assert_true(FeatsPanel.row_texts(def)[1].contains("50 gold"))


func test_session_earns_a_zone_feat_pays_it_once_and_saves_it() -> void:
	var gold_before: int = Session.gold
	assert_true(Session.complete_zone("beefcake"))
	assert_true(Session.feats.state.has("hold_my_coat"), "the zone's feat")
	assert_true(Session.feats.state.has("first_gate") == Session.flag(&"beefcake_zone_unlocked"), "the gate feat needs the gate flag")
	assert_eq(Session.gold, gold_before + 50, "the account's first time pays 50 gold")
	assert_true(FeatAccount.has("hold_my_coat"))
	var data: Dictionary = Session.to_dict()
	assert_true((data["feats"] as Dictionary).has("unlocked"))
	Session.new_game()
	assert_false(Session.feats.state.has("hold_my_coat"), "a new game starts clean")
	Session.from_dict(data)
	assert_true(Session.feats.state.has("hold_my_coat"), "loaded back")
	assert_true(Session.feats.state.has("old_stone_cold_nights"), "retroactive: the cleared cave")
	Session.new_game()
	Session.ensure_game(Affinity.Type.GOURMAND)
	var second_base: int = Session.gold
	Session.complete_zone("beefcake")
	assert_true(Session.feats.state.has("hold_my_coat"), "the second campaign gets the entry")
	assert_eq(Session.gold, second_base, "but not the gold again")


func test_old_saves_without_a_feats_key_load() -> void:
	var data: Dictionary = Session.to_dict()
	data.erase("feats")
	Session.new_game()
	assert_true(Session.from_dict(data))
	assert_not_null(Session.feats.state)
	assert_true(Session.feats.state.has("old_stone_cold_nights"), "and earn what they already did")


func test_feat_toasts_wait_while_a_battle_is_pending() -> void:
	var shown: int = Session.toasts.history.size()
	Session.pending_battle = BattleContext.new()
	Session.complete_zone("gourmand")
	assert_true(Session.feats.state.has("chef_always_tastes"))
	assert_eq(Session.toasts.history.size(), shown, "no toast over the battle")
	Session.pending_battle = null
	Session.flush_feat_toasts()
	assert_true(Session.toasts.history.size() > shown, "shown once the battle is over")
	assert_true(Session.toasts.history[Session.toasts.history.size() - 1].begins_with("Feat: Chef Always Tastes"))
