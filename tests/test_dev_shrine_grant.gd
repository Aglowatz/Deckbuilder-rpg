extends GutTest
## New brief (third), Part E follow-up: the windowed final_flow_smoke driver twice measured more
## than one level gained per dev-shrine visit (once 5 visits -> level 8, once 2 visits -> level 5),
## which should be impossible if Session.grant_dev_level() really grants exactly one level per
## call. This is a direct, headless check of that specific claim - no windowed input driver
## involved, so it isolates whether the discrepancy is in Session's own logic or in the driver.

func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.A)


func test_grant_dev_level_grants_exactly_one_level_per_call() -> void:
	for i: int in range(10):
		var level_before: int = Session.profile.level
		var gained: Array[LevelData] = Session.grant_dev_level()
		assert_eq(gained.size(), 1, "call %d should grant exactly one LevelData" % i)
		assert_eq(Session.profile.level, level_before + 1, "call %d should raise the level by exactly 1 (was %d, now %d)" % [i, level_before, Session.profile.level])


func test_grant_dev_level_returns_empty_at_max_level() -> void:
	Session.profile.level = ProgressionTable.MAX_LEVEL
	Session.profile.xp = ProgressionTable.xp_to_reach(ProgressionTable.MAX_LEVEL)
	assert_eq(Session.grant_dev_level().size(), 0)
	assert_eq(Session.profile.level, ProgressionTable.MAX_LEVEL, "level should not go past MAX_LEVEL")
