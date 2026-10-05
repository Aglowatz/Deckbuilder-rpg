extends GutTest
## Brief 11, Part D: the health and travel rules. The central town is a full heal; entering any zone from anywhere (the town, another zone,
## the Rift Express) starts a visit at full life; inside a zone the zone life rules still apply; Gainlands portal rips cost nothing.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.A)


func after_each() -> void:
	Session.zone_run = null


func test_arriving_in_town_ends_the_zone_visit_and_the_next_one_is_at_full_life() -> void:
	var visit: ZoneRun = Session.begin_zone_visit(DnaZone.ID)
	visit.damage(visit.max_life() - 1)
	assert_eq(visit.life, 1)
	Session.arrive_in_town()
	assert_null(Session.zone_run, "town has no zone life: it is a full heal")
	var next: ZoneRun = Session.begin_zone_visit(DnaZone.ID)
	assert_eq(next.life, next.max_life(), "a new visit starts at full life")


func test_entering_a_different_zone_from_a_zone_is_a_full_heal() -> void:
	for first: String in ZoneDefs.all_ids():
		for second: String in ZoneDefs.all_ids():
			if first == second:
				continue
			var visit: ZoneRun = Session.begin_zone_visit(first)
			visit.damage(visit.max_life() - 1)
			var arrived: ZoneRun = Session.begin_zone_visit(second)
			assert_eq(arrived.zone_id, second)
			assert_eq(arrived.life, arrived.max_life(), "%s -> %s arrives at full life" % [first, second])


func test_town_heals_a_lingering_run_too() -> void:
	Session.run = DungeonRun.enter(Session.profile, Session.deck, [] as Array[ModifierSource])
	Session.run.life = 2
	Session.arrive_in_town()
	assert_eq(Session.run.life, Session.run.max_life())
	Session.run = null


func test_within_a_zone_the_life_rules_still_apply() -> void:
	var visit: ZoneRun = Session.begin_zone_visit(GainlandsZone.ID)
	visit.damage(3)
	assert_eq(visit.life, visit.max_life() - 3)
	assert_eq(Session.zone_run.life, visit.max_life() - 3, "no healing just because time passed or a rip was used")


func test_the_capital_debuffs_still_apply_on_arrival() -> void:
	var visit: ZoneRun = Session.begin_zone_visit(CapitalZone.ID)
	assert_eq(visit.life, visit.max_life(), "full life even with the Capital's lowered maximum")


func test_portal_rips_cost_nothing_and_only_have_story_or_quest_locks() -> void:
	var rippers: int = 0
	for point: GainlandsTravel.Point in GainlandsTravel.points():
		if point.kind != "portal":
			continue
		rippers += 1
		assert_true(_lock_is_story_only(point.lock), "%s: no cost or purchase condition" % point.id)
		var gold_before: int = Session.gold
		var state: UnlockState = Session.unlock_state()
		GainlandsTravel.is_unlocked(point, state)
		assert_eq(Session.gold, gold_before, "checking a rip never charges")
	assert_gte(rippers, 4)
	# The ways back are always open.
	for point_id: String in ["ripper_delt_back", "ripper_calf_back"]:
		assert_true(GainlandsTravel.is_unlocked(GainlandsTravel.find(point_id), Session.unlock_state()))
	# The two forward rips are locked by the story (the wheel) and a quest, exactly as before.
	assert_false(GainlandsTravel.is_unlocked(GainlandsTravel.find("ripper_delt"), Session.unlock_state()))
	Session.flags[str(GainlandsZone.FLAG_WHEEL_POWERED)] = true
	assert_true(GainlandsTravel.is_unlocked(GainlandsTravel.find("ripper_delt"), Session.unlock_state()))


func _lock_is_story_only(lock: Condition) -> bool:
	if lock == null:
		return true
	if lock.kind == Condition.Kind.GOLD_SPENT:
		return false
	for sub: Condition in lock.sub_conditions:
		if not _lock_is_story_only(sub):
			return false
	return true
