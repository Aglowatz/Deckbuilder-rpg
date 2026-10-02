extends GutTest

var state: UnlockState


func before_each() -> void:
	state = UnlockState.new()


func test_null_condition_is_always_met() -> void:
	assert_true(Condition.met(null, state))
	assert_eq(Condition.always(), null)


func test_flag_set() -> void:
	var condition: Condition = Condition.flag("vendor_seen")
	assert_false(Condition.met(condition, state))
	state.flags["vendor_seen"] = true
	assert_true(Condition.met(condition, state))


func test_dungeon_cleared() -> void:
	var condition: Condition = Condition.dungeon_cleared("Trial of the Hollow")
	assert_false(Condition.met(condition, state))
	state.cleared_dungeons.append("Trial of the Hollow")
	assert_true(Condition.met(condition, state))


func test_card_owned_checks_copy_count() -> void:
	var condition: Condition = Condition.card_owned("beefcake_imp", 2)
	state.owned_cards["beefcake_imp"] = 1
	assert_false(Condition.met(condition, state))
	state.owned_cards["beefcake_imp"] = 2
	assert_true(Condition.met(condition, state))


func test_secret_found() -> void:
	var condition: Condition = Condition.secret_found("hidden_chest")
	assert_false(Condition.met(condition, state))
	state.found_secrets.append("hidden_chest")
	assert_true(Condition.met(condition, state))


func test_gold_spent_threshold() -> void:
	var condition: Condition = Condition.gold_spent(500)
	state.gold_spent = 499
	assert_false(Condition.met(condition, state))
	state.gold_spent = 500
	assert_true(Condition.met(condition, state))


func test_player_level_threshold() -> void:
	var condition: Condition = Condition.player_level(3)
	state.player_level = 2
	assert_false(Condition.met(condition, state))
	state.player_level = 3
	assert_true(Condition.met(condition, state))


func test_quest_completed() -> void:
	var condition: Condition = Condition.quest_completed("find_the_smith")
	assert_false(Condition.met(condition, state))
	state.completed_quests.append("find_the_smith")
	assert_true(Condition.met(condition, state))


func test_all_of_requires_every_sub_condition() -> void:
	var condition: Condition = Condition.all_of([Condition.flag("a"), Condition.flag("b")] as Array[Condition])
	state.flags["a"] = true
	assert_false(Condition.met(condition, state))
	state.flags["b"] = true
	assert_true(Condition.met(condition, state))


func test_any_of_requires_one_sub_condition() -> void:
	var condition: Condition = Condition.any_of([Condition.flag("a"), Condition.flag("b")] as Array[Condition])
	assert_false(Condition.met(condition, state))
	state.flags["b"] = true
	assert_true(Condition.met(condition, state))


func test_teaser_text_is_never_empty_for_a_real_condition() -> void:
	for condition: Condition in [
		Condition.flag("x"), Condition.dungeon_cleared("Trial"), Condition.card_owned("x", 2),
		Condition.secret_found("x"), Condition.gold_spent(10), Condition.player_level(2),
		Condition.quest_completed("x"), Condition.all_of([] as Array[Condition]),
	]:
		assert_false(Condition.teaser(condition).is_empty())
	assert_eq(Condition.teaser(null), "")
